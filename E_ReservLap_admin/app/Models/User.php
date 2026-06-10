<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'password',
        'role',
        'photo_url',
    ];

    // Accessor: kembalikan URL lengkap photo
    public function getPhotoUrlAttribute($value): ?string
    {
        if (!$value) return null;
        // Jika sudah URL penuh, kembalikan apa adanya
        if (str_starts_with($value, 'http')) return $value;
        return url('storage/' . $value);
    }

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
        ];
    }

    // tambah ini
    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }
}
