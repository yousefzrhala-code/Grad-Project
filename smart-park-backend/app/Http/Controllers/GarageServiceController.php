<?php

namespace App\Http\Controllers;

use App\Models\GarageService;
use Illuminate\Http\Request;

class GarageServiceController extends Controller
{
    public function index(Request $request)
    {
        $user = $request->user();

        if ($user->role !== 'garage_owner') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $garage = $user->garage;
        if (!$garage) {
            return response()->json(['message' => 'Garage not found'], 404);
        }

        return response()->json([
            'services' => $garage->services,
        ]);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:100',
            'icon' => 'nullable|string|max:100',
        ]);

        $user = $request->user();

        if ($user->role !== 'garage_owner') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $garage = $user->garage;
        if (!$garage) {
            return response()->json(['message' => 'Garage not found'], 404);
        }
        $exists = GarageService::where('garage_id', $garage->id)
            ->where('name', $validated['name'])
            ->exists();

        if ($exists) {
            return response()->json(['message' => 'Service already added'], 422);
        }

        $service = GarageService::create([
            'garage_id' => $garage->id,
            'name'      => $validated['name'],
            'icon'      => $validated['icon'] ?? null,
        ]);

        return response()->json([
            'message' => 'Service added successfully',
            'service' => $service,
        ], 201);
    }

    public function destroy(Request $request, $id)
    {
        $user = $request->user();

        if ($user->role !== 'garage_owner') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $garage = $user->garage;
        if (!$garage) {
            return response()->json(['message' => 'Garage not found'], 404);
        }

        $service = GarageService::where('id', $id)
            ->where('garage_id', $garage->id)
            ->first();

        if (!$service) {
            return response()->json(['message' => 'Service not found'], 404);
        }

        $service->delete();

        return response()->json(['message' => 'Service removed successfully']);
    }
}
