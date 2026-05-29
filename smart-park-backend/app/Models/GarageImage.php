<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class GarageImage extends Model
{
    use HasFactory;

    protected $fillable = [
        'garage_id',
        'image_path',
    ];

    public function garage()
    {
        return $this->belongsTo(Garage::class, 'garage_id');
    }
}
