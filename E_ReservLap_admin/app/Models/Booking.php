<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    public static $skipSlotUpdate = false;

    protected $appends = ['host_name', 'host_phone'];

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
        'is_private',
        'status',
    ];

    protected static function boot()
    {
        parent::boot();

        static::created(function ($booking) {
            if (self::$skipSlotUpdate) {
                return;
            }

            if ($booking->status === 'approved') {
                self::updateSlotCapacity($booking, true);
            }
        });

        static::updated(function ($booking) {
            if (self::$skipSlotUpdate) {
                return;
            }

            if ($booking->wasChanged('status')) {
                $oldStatus = $booking->getOriginal('status');
                $newStatus = $booking->status;

                // Sync status of Joiners if Host booking changes status to rejected/pending
                if ($booking->total_price > 0 && in_array($newStatus, ['rejected', 'pending'])) {
                    $joiners = self::where('slot_id', $booking->slot_id)
                        ->where('id', '!=', $booking->id)
                        ->where('total_price', 0)
                        ->whereIn('status', ['pending', 'approved'])
                        ->get();

                    foreach ($joiners as $joiner) {
                        $joiner->status = $newStatus;
                        $joiner->save();
                    }
                }

                // pending/rejected -> approved
                if ($oldStatus !== 'approved' && $newStatus === 'approved') {
                    self::updateSlotCapacity($booking, true);
                }

                // approved -> rejected/pending
                if ($oldStatus === 'approved' && $newStatus !== 'approved') {
                    self::updateSlotCapacity($booking, false);
                }
            }
        });

        static::deleted(function ($booking) {
            if (self::$skipSlotUpdate) {
                return;
            }

            // Sync status of Joiners if Host booking is deleted
            if ($booking->total_price > 0) {
                $joiners = self::where('slot_id', $booking->slot_id)
                    ->where('id', '!=', $booking->id)
                    ->where('total_price', 0)
                    ->whereIn('status', ['pending', 'approved'])
                    ->get();

                foreach ($joiners as $joiner) {
                    $joiner->status = 'rejected';
                    $joiner->save();
                }
            }

            if ($booking->status === 'approved') {
                self::updateSlotCapacity($booking, false);
            }
        });
    }

    public static function updateSlotCapacity($booking, $isAdding)
    {
        $slots = Slot::where('field_id', $booking->field_id)
            ->where('date', $booking->date)
            ->where('start_time', '>=', $booking->start_time)
            ->where('end_time', '<=', $booking->end_time)
            ->get();

        foreach ($slots as $slot) {
            if ($isAdding) {
                if ($booking->is_private) {
                    $slot->booked_count = $slot->capacity;
                } else {
                    $slot->booked_count += $booking->person_count;
                }
            } else {
                if ($booking->is_private) {
                    $slot->booked_count = 0;
                } else {
                    $slot->booked_count = max(0, $slot->booked_count - $booking->person_count);
                }
            }

            if ($slot->booked_count >= $slot->capacity) {
                $slot->is_available = false;
            } else {
                $slot->is_available = true;
            }
            $slot->save();
        }
    }

    public static function canBeApproved($booking): bool
    {
        $slots = Slot::where('field_id', $booking->field_id)
            ->where('date', $booking->date)
            ->where('start_time', '>=', $booking->start_time)
            ->where('end_time', '<=', $booking->end_time)
            ->get();

        foreach ($slots as $slot) {
            $approvedBookings = self::where('field_id', $booking->field_id)
                ->where('date', $booking->date)
                ->where('id', '!=', $booking->id)
                ->where('start_time', '<=', $slot->start_time)
                ->where('end_time', '>=', $slot->end_time)
                ->where('status', 'approved')
                ->get(['person_count', 'is_private']);

            if ($approvedBookings->contains(fn ($item) => (bool) $item->is_private)) {
                return false;
            }

            $approvedCount = $approvedBookings->sum('person_count');
            if ($booking->is_private && $approvedCount > 0) {
                return false;
            }

            if (!$booking->is_private && ($slot->capacity - $approvedCount) < $booking->person_count) {
                return false;
            }
        }

        return true;
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

    public function getHostNameAttribute()
    {
        $hostBooking = self::where('slot_id', $this->slot_id)
            ->where('status', 'approved')
            ->with('user')
            ->orderBy('created_at', 'asc')
            ->first();

        return $hostBooking && $hostBooking->user ? $hostBooking->user->name : null;
    }

    public function getHostPhoneAttribute()
    {
        $hostBooking = self::where('slot_id', $this->slot_id)
            ->where('status', 'approved')
            ->with('user')
            ->orderBy('created_at', 'asc')
            ->first();

        return $hostBooking && $hostBooking->user ? $hostBooking->user->phone : null;
    }
}
