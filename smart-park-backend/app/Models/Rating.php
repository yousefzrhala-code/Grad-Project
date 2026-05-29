<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Rating extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'garage_id',
        'reservation_id',
        'stars',
        'comment',
    ];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }

    public function garage()
    {
        return $this->belongsTo(Garage::class, 'garage_id');
    }

    public function reservation()
    {
        return $this->belongsTo(Reservation::class, 'reservation_id');
    }

    public static function averageForGarage(int $garageId): float
    {
        return round((float) self::where('garage_id', $garageId)->avg('stars'), 2);
    }

    public static function countForGarage(int $garageId): int
    {
        return self::where('garage_id', $garageId)->count();
    }
}
