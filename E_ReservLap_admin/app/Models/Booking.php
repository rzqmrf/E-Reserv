<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    public static $skipSlotUpdate = false;

    protected $fillable = [
        'booking_code',
        'user_id',
        'field_id',
        'slot_id',       
        'date',
        'start_time',
        'end_time',
        'duration_hours',
        'total_price',
        'person_count',
        'status',
    ];

    protected static function boot()
    {
        parent::boot();

        static::updated(function ($booking) {
            if (self::$skipSlotUpdate) {
                return;
            }

            if ($booking->wasChanged('status')) {
                $oldStatus = $booking->getOriginal('status');
                $newStatus = $booking->status;

                // pending/rejected -> approved
                if ($oldStatus !== 'approved' && $newStatus === 'approved') {
                    $slots = Slot::where('field_id', $booking->field_id)
                        ->where('date', $booking->date)
                        ->where('start_time', '>=', $booking->start_time)
                        ->where('end_time', '<=', $booking->end_time)
                        ->get();

                    foreach ($slots as $slot) {
                        $slot->booked_count += $booking->person_count;
                        if ($slot->booked_count >= $slot->capacity) {
                            $slot->is_available = false;
                        }
                        $slot->save();
                    }
                }

                // approved -> rejected/pending
                if ($oldStatus === 'approved' && $newStatus !== 'approved') {
                    $slots = Slot::where('field_id', $booking->field_id)
                        ->where('date', $booking->date)
                        ->where('start_time', '>=', $booking->start_time)
                        ->where('end_time', '<=', $booking->end_time)
                        ->get();

                    foreach ($slots as $slot) {
                        $slot->booked_count = max(0, $slot->booked_count - $booking->person_count);
                        if ($slot->booked_count < $slot->capacity) {
                            $slot->is_available = true;
                        }
                        $slot->save();
                    }
                }
            }
        });
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function field()
    {
        return $this->belongsTo(Field::class);
    }

    public function payment()
    {
        return $this->hasOne(Payment::class);
    }

    // tambah ini
    public function slot()
    {
        return $this->belongsTo(Slot::class);
    }
}
