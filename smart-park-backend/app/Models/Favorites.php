<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use App\Models\Garage;

class Favorites extends Model
{
    public function favorites()
    {
        return $this->belongsToMany(Garage::class, 'favorites');
    }
}
