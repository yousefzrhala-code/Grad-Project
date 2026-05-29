<?php

namespace App\Models;

use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'car_type',
        'phone',
        'approval_status',
        'is_active',
        'fcm_token',
    ];

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

    public static function registerUser(array $data)
    {
        $approvalStatus = $data['role'] === 'garage_owner' ? 'pending' : 'approved';
        $isActive = $data['role'] === 'garage_owner' ? false : true;

        return self::create([
            'name' => $data['name'],
            'email' => $data['email'],
            'password' => Hash::make($data['password']),
            'role' => $data['role'],
            'car_type' => $data['role'] === 'car_owner' ? ($data['car_type'] ?? null) : null,
            'phone' => $data['phone'] ?? null,
            'approval_status' => $approvalStatus,
            'is_active' => $isActive,
        ]);
    }

    public static function loginUser(array $data)
    {
        $user = self::where('email', $data['email'])->first();
        if (! $user) {
            return null;
        }
        if (! Hash::check($data['password'], $user->password)) {
            return null;
        }
        return $user;
    }

    public function reservations()
    {
        return $this->hasMany(Reservation::class, 'car_owner_id');
    }
    public function garage()
    {
        return $this->hasOne(Garage::class, 'owner_id');
    }
    public function favoritedBy()
    {
        return $this->belongsToMany(User::class, 'favorites', 'garage_id', 'user_id')->withTimestamps();
    }
    public function favorites()
    {
        return $this->belongsToMany(Garage::class, 'favorites', 'user_id', 'garage_id')->withTimestamps();
    }
}
