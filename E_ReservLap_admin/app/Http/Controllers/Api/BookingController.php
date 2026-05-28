<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Str;

class BookingController extends Controller
{
    public function index()
    {
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
            'end_time'       => 'required',
            'duration_hours' => 'required|integer|min:1',
            'total_price'    => 'required|integer|min:0',
            'person_count' => 'required|integer|min:1', // default dan akan berubah FE & BE
        ]);


        // instansi objek manual agar tidak terfilter masalah fillable    
        $booking = new \App\Models\Booking();
        $booking->booking_code   = 'BK' . strtoupper(\Illuminate\Support\Str::random(8));
        $booking->user_id        = $request->user_id;
        $booking->field_id       = $request->field_id;
        $booking->slot_id        = $request->slot_id;
        $booking->date           = $request->date;
        $booking->start_time     = $request->start_time;
        $booking->end_time       = $request->end_time;
        $booking->duration_hours = $request->duration_hours;
        $booking->total_price    = $request->total_price;
        $booking->person_count   = $request->person_count; // DIPAKSA MASUK KE DATABASE COY
        $booking->status         = 'pending';
        $booking->save();

        // load relasi field 

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

    // Approve booking
    public function approve($id)
    {
        $booking = Booking::findOrFail($id);
        $booking->update(['status' => 'approved']);
        return response()->json(['message' => 'Booking disetujui', 'booking' => $booking]);
    }

    // Reject booking
    public function reject($id)
    {
        $booking = Booking::findOrFail($id);
        $booking->update(['status' => 'rejected']);
        return response()->json(['message' => 'Booking ditolak', 'booking' => $booking]);
    }

    // Booking by user
    public function byUser($userId)
    {
        $bookings = Booking::with(['field', 'payment'])
            ->where('user_id', $userId)
            ->latest()
            ->get();
        return response()->json($bookings);
    }
}
