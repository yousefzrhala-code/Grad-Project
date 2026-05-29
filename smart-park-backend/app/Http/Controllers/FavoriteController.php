<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class FavoriteController extends Controller
{
    public function toggleFavorite(Request $request)
    {
        $request->validate([
            'garage_id' => 'required|exists:garages,id'
        ]);
        $user = auth()->user();
        $garageId = $request->garage_id;
        if ($user->favorites()->where('garage_id', $garageId)->exists()) {
            $user->favorites()->detach($garageId);
            return response()->json([
                'status' => 'removed'
            ]);
        }
        $user->favorites()->attach($garageId);
        return response()->json([
            'status' => 'added'
        ]);
    }

    public function getFavorites()
    {
        $user = auth()->user();
        $favorites = $user->favorites()->get();
        $favorites = $favorites->map(function ($garage) {
            return [
                'id' => $garage->id,
                'name' => $garage->name,
                'location' => $garage->location,
                'city' => $garage->city,
                'available_spots' => $garage->available_spots,
                'price_per_hour' => $garage->price_per_hour,
            ];
        });

        return response()->json([
            'status' => 'success',
            'data' => $favorites
        ]);
    }
}
