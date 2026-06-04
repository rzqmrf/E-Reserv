<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Slot;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    public function index(Request $request)
    {
        $user = null;

        // 1. Cek autentikasi lewat session web guard
        if (auth()->check()) {
            $user = auth()->user();
        } 
        // 2. Cek autentikasi lewat Sanctum guard secara manual
        else {
            $header = $request->header('Authorization');
            if ($header && preg_match('/Bearer\s(\S+)/', $header, $matches)) {
                $tokenModel = \Laravel\Sanctum\PersonalAccessToken::findToken($matches[1]);
                if ($tokenModel) {
                    $user = $tokenModel->tokenable;
                }
            }
        }

        // Jika user terautentikasi dan perannya bukan admin, kembalikan hanya booking miliknya
        if ($user && $user->role !== 'admin') {
            return response()->json(
                Booking::with(['user', 'field', 'payment'])
                    ->where('user_id', $user->id)
                    ->latest()
                    ->get()
            );
        }

        // Jika ada filter manual user_id dari parameter request (opsional)
        if ($request->has('user_id')) {
            return response()->json(
                Booking::with(['user', 'field', 'payment'])
                    ->where('user_id', $request->user_id)
                    ->latest()
                    ->get()
            );
        }

        // Default: Kembalikan semua booking (untuk halaman admin)
        return response()->json(
            Booking::with(['user', 'field', 'payment'])->latest()->get()
        );
    }

    public function store(Request $request)
    {
        $request->validate([
            'user_id'        => 'required|exists:users,id',
            'field_id'       => 'required|exists:fields,id',
            'date'           => 'required|date',
            'start_time'     => 'required',
            'duration_hours' => 'required|integer|min:1',
            'total_price'    => 'required|integer|min:0',
            'person_count'   => 'required|integer|min:1',
            'is_private'     => 'nullable|boolean',
        ]);

        $startTime = \Carbon\Carbon::parse($request->start_time);
        $startTimeFormatted = $startTime->format('H:i');
        $endTimeFormatted = $startTime->copy()->addHours($request->duration_hours)->format('H:i');

        // Ambil semua slot dalam rentang waktu
        $slots = Slot::where('field_id', $request->field_id)
            ->where('date', $request->date)
            ->where('start_time', '>=', $startTimeFormatted)
            ->where('end_time', '<=', $endTimeFormatted)
            ->orderBy('start_time')
            ->get();

        if ($slots->count() < $request->duration_hours) {
            return response()->json([
                'message' => 'Beberapa slot waktu dalam rentang tersebut tidak tersedia.'
            ], 422);
        }

        $requestedPrivate = $request->boolean('is_private');

        // Validasi kapasitas untuk setiap slot
        foreach ($slots as $slot) {
            $overlappingBookings = Booking::where('field_id', $request->field_id)
                ->where('date', $request->date)
                ->where('start_time', '<=', $slot->start_time)
                ->where('end_time', '>=', $slot->end_time)
                ->whereIn('status', ['pending', 'approved'])
                ->get(['person_count', 'is_private']);

            $hasPrivateBooking = $overlappingBookings->contains(fn ($booking) => (bool) $booking->is_private);
            $alreadyBooked = $overlappingBookings->sum('person_count');
            $remaining = $hasPrivateBooking ? 0 : $slot->capacity - $alreadyBooked;

            if (!$slot->is_available || $hasPrivateBooking) {
                $formattedStart = \Carbon\Carbon::parse($slot->start_time)->format('H:i');
                $formattedEnd = \Carbon\Carbon::parse($slot->end_time)->format('H:i');
                return response()->json([
                    'message' => "Slot jam {$formattedStart} - {$formattedEnd} tidak tersedia."
                ], 422);
            }

            if ($requestedPrivate && $alreadyBooked > 0) {
                $formattedStart = \Carbon\Carbon::parse($slot->start_time)->format('H:i');
                $formattedEnd = \Carbon\Carbon::parse($slot->end_time)->format('H:i');
                return response()->json([
                    'message' => "Slot jam {$formattedStart} - {$formattedEnd} sudah memiliki peserta, tidak bisa disewa privat."
                ], 422);
            }

            if ($remaining < $request->person_count) {
                $formattedStart = \Carbon\Carbon::parse($slot->start_time)->format('H:i');
                $formattedEnd = \Carbon\Carbon::parse($slot->end_time)->format('H:i');
                return response()->json([
                    'message' => "Sisa kapasitas slot jam {$formattedStart} - {$formattedEnd} tidak mencukupi (Sisa: {$remaining} orang)."
                ], 422);
            }
        }

        // Ambil field untuk kalkulasi total_price otomatis
        $field = \App\Models\Field::findOrFail($request->field_id);

        // Cek apakah sudah ada booking (Host) di slot pertama
        $hasHost = Booking::where('slot_id', $slots->first()->id)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        if ($hasHost) {
            // Joiner: gratis, langsung approved, tidak bisa privat
            $totalPrice = 0;
            $status = 'approved';
            $isPrivate = false;
        } else {
            // Host: bayar sewa lapangan per jam, pending, bisa privat
            $status = 'pending';
            $isPrivate = $requestedPrivate;
            $privateMultiplier = $isPrivate ? (float) config('services.booking.private_multiplier', 1.5) : 1;
            $totalPrice = (int) round($field->price * $request->duration_hours * $privateMultiplier);
        }

        $booking = new \App\Models\Booking();
        $booking->booking_code   = 'BK' . strtoupper(Str::random(8));
        $booking->user_id        = $request->user_id;
        $booking->field_id       = $request->field_id;
        $booking->slot_id        = $slots->first()->id;
        $booking->date           = $request->date;
        $booking->start_time     = $startTimeFormatted;
        $booking->end_time       = $endTimeFormatted;
        $booking->duration_hours = $request->duration_hours;
        $booking->total_price    = $totalPrice;
        $booking->person_count   = $request->person_count;
        $booking->is_private     = $isPrivate;
        $booking->status         = $status;
        $booking->save();

        $booking->load('field');

        return response()->json([
            'success' => true,
            'data'    => $booking
        ]);
    }

    public function show($id)
    {
        $booking = Booking::with(['user', 'field', 'payment'])->findOrFail($id);
        return response()->json($booking);
    }

    public function update(Request $request, $id)
    {
        $booking = Booking::findOrFail($id);
        $booking->update($request->all());
        return response()->json($booking);
    }

    public function destroy($id)
    {
        Booking::findOrFail($id)->delete();
        return response()->json(['message' => 'Booking berhasil dihapus']);
    }

    public function approve($id)
    {
        $booking = Booking::findOrFail($id);

        if ($booking->status === 'approved') {
            return response()->json(['message' => 'Booking sudah disetujui sebelumnya', 'booking' => $booking]);
        }

        // Hindari double processing dari model events
        Booking::$skipSlotUpdate = true;

        $slots = Slot::where('field_id', $booking->field_id)
            ->where('date', $booking->date)
            ->where('start_time', '>=', $booking->start_time)
            ->where('end_time', '<=', $booking->end_time)
            ->get();

        foreach ($slots as $slot) {
            $slot->booked_count = $booking->is_private
                ? $slot->capacity
                : $slot->booked_count + $booking->person_count;

            if ($slot->booked_count >= $slot->capacity) {
                $slot->is_available = false;
            }
            $slot->save();
        }

        $booking->update(['status' => 'approved']);

        Booking::$skipSlotUpdate = false;

        return response()->json(['message' => 'Booking disetujui', 'booking' => $booking]);
    }

    public function reject($id)
    {
        $booking = Booking::findOrFail($id);

        if ($booking->status === 'rejected') {
            return response()->json(['message' => 'Booking sudah ditolak sebelumnya', 'booking' => $booking]);
        }

        // Hindari double processing dari model events
        Booking::$skipSlotUpdate = true;

        if ($booking->status === 'approved') {
            $slots = Slot::where('field_id', $booking->field_id)
                ->where('date', $booking->date)
                ->where('start_time', '>=', $booking->start_time)
                ->where('end_time', '<=', $booking->end_time)
                ->get();

            foreach ($slots as $slot) {
                $slot->booked_count = $booking->is_private
                    ? 0
                    : max(0, $slot->booked_count - $booking->person_count);

                if ($slot->booked_count < $slot->capacity) {
                    $slot->is_available = true;
                }
                $slot->save();
            }
        }

        $booking->update(['status' => 'rejected']);

        Booking::$skipSlotUpdate = false;

        return response()->json(['message' => 'Booking ditolak', 'booking' => $booking]);
    }

    public function byUser($userId)
    {
        $bookings = Booking::with(['field', 'payment'])
            ->where('user_id', $userId)
            ->latest()
            ->get();
        return response()->json($bookings);
    }
}
