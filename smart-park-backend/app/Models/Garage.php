<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Factories\HasFactory;

class Garage extends Model
{
    use HasFactory;

    protected $fillable = [
        'owner_id',
        'name',
        'city',
        'address',
        'price_per_hour',
        'capacity',
        'available_spots',
        'open_time',
        'close_time',
        'description',
        'is_active',
        'is_approved',
        'approval_status',
    ];

    public static function createGarage(array $data, int $ownerId)
    {
        return self::create([
            'owner_id' => $ownerId,
            'name' => $data['name'],
            'city' => $data['city'],
            'address' => $data['address'],
            'price_per_hour' => $data['price_per_hour'],
            'capacity' => $data['capacity'],
            'available_spots' => $data['capacity'],
            'open_time' => $data['open_time'] ?? null,
            'close_time' => $data['close_time'] ?? null,
            'description' => $data['description'] ?? null,
            'is_active' => true,
        ]);
    }
    public static function updateGarage(Garage $garage, array $data)
    {
        $oldCapacity = $garage->capacity;
        $oldAvailableSpots = $garage->available_spots;
        $newCapacity = (int) $data['capacity'];

        $difference = $newCapacity - $oldCapacity;
        $newAvailableSpots = $oldAvailableSpots + $difference;

        if ($newAvailableSpots < 0) {
            $newAvailableSpots = 0;
        }

        if ($newAvailableSpots > $newCapacity) {
            $newAvailableSpots = $newCapacity;
        }

        $garage->update([
            'name' => $data['name'],
            'city' => $data['city'],
            'address' => $data['address'],
            'price_per_hour' => $data['price_per_hour'],
            'capacity' => $newCapacity,
            'available_spots' => $newAvailableSpots,
            'open_time' => $data['open_time'] ?? null,
            'close_time' => $data['close_time'] ?? null,
            'description' => $data['description'] ?? null,
            'is_active' => $data['is_active'],
        ]);

        return $garage->fresh();
    }

    public static function updateAvailability(Garage $garage, array $data)
    {
        $availableSpots = (int) $data['available_spots'];

        if ($availableSpots > $garage->capacity) {
            $availableSpots = $garage->capacity;
        }

        $garage->update([
            'available_spots' => $availableSpots,
            'is_active' => $data['is_active'],
        ]);

        return $garage->fresh();
    }
    public function owner()
    {
        return $this->belongsTo(User::class, 'owner_id');
    }
    public function reservations()
    {
        return $this->hasMany(Reservation::class);
    }
    public function favoritedBy()
    {
        return $this->belongsToMany(User::class, 'favorites', 'garage_id', 'user_id')->withTimestamps();
    }

    public function images()
    {
        return $this->hasMany(GarageImage::class, 'garage_id');
    }

    public function services()
    {
        return $this->hasMany(GarageService::class, 'garage_id');
    }

    public function ratings()
    {
        return $this->hasMany(Rating::class, 'garage_id');
    }

    public function reports()
    {
        return $this->hasMany(Report::class, 'garage_id');
    }

    public function getAverageRatingAttribute(): float
    {
        return Rating::averageForGarage($this->id);
    }

    public function getRatingsCountAttribute(): int
    {
        return Rating::countForGarage($this->id);
    }
}
