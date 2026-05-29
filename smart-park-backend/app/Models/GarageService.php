<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GarageService extends Model
{
    use HasFactory;

    protected $fillable = [
        'garage_id',
        'name',
        'icon',
    ];

    public function garage()
    {
        return $this->belongsTo(Garage::class, 'garage_id');
    }
}
