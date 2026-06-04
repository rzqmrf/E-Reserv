<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Slot extends Model
{
    protected $fillable = [
        'field_id',
        'date',
        'start_time',
        'end_time',
        'capacity',
        'booked_count',
        'is_available',
    ];

    protected $casts = [
        'date'         => 'date',
        'is_available' => 'boolean',
    ];

    public function field()
    {
        return $this->belongsTo(Field::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    // Hitung sisa kapasitas (memperhitungkan booking pending dan approved)
    public function getRemainingCapacityAttribute()
    {
        $overlappingBookings = Booking::where('field_id', $this->field_id)
            ->where('date', $this->date)
            ->where('start_time', '<=', $this->start_time)
            ->where('end_time', '>=', $this->end_time)
            ->whereIn('status', ['pending', 'approved'])
            ->get(['person_count', 'is_private']);

        if ($overlappingBookings->contains(fn ($booking) => (bool) $booking->is_private)) {
            return 0;
        }

        $alreadyBooked = $overlappingBookings->sum('person_count');

        return max(0, $this->capacity - $alreadyBooked);
    }

    // Override is_available berdasarkan sisa kapasitas
    public function getIsAvailableAttribute($value)
    {
        return $value && $this->remaining_capacity > 0;
    }
}
