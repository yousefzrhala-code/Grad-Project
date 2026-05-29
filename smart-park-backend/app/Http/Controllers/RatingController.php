<?php

namespace App\Http\Controllers;

use App\Models\Rating;
use App\Models\Reservation;
use Illuminate\Http\Request;

class RatingController extends Controller
{
    public function store(Request $request)
    {
        $validated = $request->validate([
            'garage_id' => 'required|exists:garages,id',
            'reservation_id' => 'required|exists:reservations,id',
            'stars' => 'required|integer|min:1|max:5',
            'comment' => 'nullable|string|max:1000',
        ]);

        $user = $request->user();

        $reservation = Reservation::where('id', $validated['reservation_id'])
            ->where('car_owner_id', $user->id)
            ->where('garage_id', $validated['garage_id'])
            ->first();

        if (!$reservation) {
            return response()->json([
                'message' => 'Reservation not found',
            ], 404);
        }

        if ($reservation->status !== 'completed') {
            return response()->json([
                'message' => 'You can only rate a garage after completing a reservation',
            ], 400);
        }

        $existing = Rating::where('reservation_id', $reservation->id)
            ->where('user_id', $user->id)
            ->first();

        if ($existing) {
            return response()->json([
                'message' => 'You already rated this reservation',
            ], 409);
        }

        $rating = Rating::create([
            'user_id' => $user->id,
            'garage_id' => $validated['garage_id'],
            'reservation_id' => $reservation->id,
            'stars' => $validated['stars'],
            'comment' => $validated['comment'] ?? null,
        ]);

        return response()->json([
            'message' => 'Rating submitted successfully',
            'rating' => $rating,
            'average_rating' => Rating::averageForGarage($rating->garage_id),
            'ratings_count' => Rating::countForGarage($rating->garage_id),
        ], 201);
    }

    public function garageRatings($garageId)
    {
        $ratings = Rating::with('user:id,name')
            ->where('garage_id', $garageId)
            ->orderByDesc('created_at')
            ->get();

        return response()->json([
            'ratings' => $ratings,
            'average_rating' => Rating::averageForGarage($garageId),
            'ratings_count' => Rating::countForGarage($garageId),
        ]);
    }
}
