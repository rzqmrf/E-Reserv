<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Field extends Model
{
    protected $fillable = [
        'name',
        'foto_lapangan',
        'type',
        'location_type',
        'price',
        'capacity',
        'status',
        'description',
    ];

    public function schedules()
    {
        return $this->hasMany(Schedule::class);
    }

    public function slots()
    {
        return $this->hasMany(Slot::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }
}
