<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    protected $fillable = [
        'booking_id',
        'amount',
        'method',
        'snap_token',
        'status',
        'proof_url',
        'paid_at',
    ];

    protected $casts = [
        'paid_at' => 'datetime',
    ];

    // Relasi ke Booking
    public function booking()
    {
        return $this->belongsTo(Booking::class);
    }
}
