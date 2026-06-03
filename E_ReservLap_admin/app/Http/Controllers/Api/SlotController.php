<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Slot;
use App\Models\Field;
use Illuminate\Http\Request;

class SlotController extends Controller
{
    public function index()
    {
        return response()->json(Slot::with('field')->latest()->get());
    }

    public function store(Request $request)
    {
        $request->validate([
            'field_id'   => 'required|exists:fields,id',
            'date'       => 'required|date',
            'start_time' => 'required',
            'end_time'   => 'required',
            'capacity'   => 'required|integer|min:1',
        ]);

        $slot = Slot::create([
            'field_id'    => $request->field_id,
            'date'        => $request->date,
            'start_time'  => $request->start_time,
            'end_time'    => $request->end_time,
            'capacity'    => $request->capacity,
            'booked_count'=> 0,
            'is_available'=> true,
        ]);

        return response()->json($slot, 201);
    }

    public function show($id)
    {
        return response()->json(Slot::with('field')->findOrFail($id));
    }

    public function update(Request $request, $id)
    {
        $slot = Slot::findOrFail($id);
        $slot->update($request->all());
        return response()->json($slot);
    }

    public function destroy($id)
    {
        Slot::findOrFail($id)->delete();
        return response()->json(['message' => 'Slot berhasil dihapus']);
    }

    // Ambil slot berdasarkan field + tanggal (untuk Flutter)
    public function byFieldAndDate(Request $request, $fieldId)
    {
        $request->validate(['date' => 'required|date']);

        $exists = Slot::where('field_id', $fieldId)->where('date', $request->date)->exists();
        if (!$exists) {
            $genRequest = new Request([
                'field_id' => $fieldId,
                'date'     => $request->date,
            ]);
            try {
                $this->generate($genRequest);
            } catch (\Exception $e) {
                // Ignore errors like no schedule found
            }
        }

        $slots = Slot::where('field_id', $fieldId)
            ->where('date', $request->date)
            ->orderBy('start_time')
            ->get()
            ->map(function ($slot) {
                // Cari booking pertama yang berstatus pending/approved di slot ini (sebagai Host)
                $hostBooking = \App\Models\Booking::where('slot_id', $slot->id)
                    ->whereIn('status', ['pending', 'approved'])
                    ->with('user')
                    ->orderBy('created_at', 'asc')
                    ->first();

                return [
                    'id'                 => $slot->id,
                    'field_id'           => $slot->field_id,
                    'date'               => $slot->date->format('Y-m-d'),
                    'start_time'         => $slot->start_time,
                    'end_time'           => $slot->end_time,
                    'capacity'           => $slot->capacity,
                    'booked_count'       => $slot->booked_count,
                    'remaining_capacity' => $slot->remaining_capacity,
                    'is_available'       => $slot->is_available && $slot->booked_count < $slot->capacity,
                    'host_name'          => $hostBooking ? $hostBooking->user->name : null,
                    'host_phone'         => $hostBooking ? $hostBooking->user->phone : null,
                ];
            });

        return response()->json($slots);
    }

    // Generate slot otomatis dari jadwal lapangan
    public function generate(Request $request)
    {
        $request->validate([
            'field_id' => 'required|exists:fields,id',
            'date'     => 'required|date',
        ]);

        $field    = Field::findOrFail($request->field_id);
        $date     = $request->date;
        $dayName  = strtolower(now()->parse($date)->locale('id')->dayName);
        $schedule = $field->schedules()->where('day_of_week', $dayName)->where('is_open', true)->first();

        if (!$schedule) {
            return response()->json(['message' => 'Tidak ada jadwal untuk hari ini'], 404);
        }

        $slots = [];
        $open  = (int) substr($schedule->open_time, 0, 2);
        $close = (int) substr($schedule->close_time, 0, 2);

        for ($h = $open; $h < $close; $h++) {
            $start = str_pad($h, 2, '0', STR_PAD_LEFT) . ':00';
            $end   = str_pad($h + 1, 2, '0', STR_PAD_LEFT) . ':00';

            // Skip jika sudah ada
            $exists = Slot::where('field_id', $field->id)->where('date', $date)->where('start_time', $start)->exists();
            if (!$exists) {
                $slots[] = Slot::create([
                    'field_id'    => $field->id,
                    'date'        => $date,
                    'start_time'  => $start,
                    'end_time'    => $end,
                    'capacity'    => $field->capacity,
                    'booked_count'=> 0,
                    'is_available'=> true,
                ]);
            }
        }

        return response()->json(['message' => count($slots) . ' slot berhasil dibuat', 'slots' => $slots]);
    }
}
