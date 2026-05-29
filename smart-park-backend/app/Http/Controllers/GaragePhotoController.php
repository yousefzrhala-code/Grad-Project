<?php

namespace App\Http\Controllers;

use App\Models\GarageImage;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class GaragePhotoController extends Controller
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
            'photos' => $garage->images,
        ]);
    }

    public function store(Request $request)
    {
        $request->validate([
            'photos'   => 'required|array|min:1|max:10',
            'photos.*' => 'required|image|mimes:jpeg,png,jpg,webp|max:5120',
        ]);

        $user = $request->user();

        if ($user->role !== 'garage_owner') {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $garage = $user->garage;
        if (!$garage) {
            return response()->json(['message' => 'Garage not found'], 404);
        }

        $saved = [];
        foreach ($request->file('photos') as $file) {
            $path = $file->store("garage_images/{$garage->id}", 'public');
            $image = GarageImage::create([
                'garage_id'  => $garage->id,
                'image_path' => $path,
            ]);
            $saved[] = $image;
        }

        return response()->json([
            'message' => 'Photos uploaded successfully',
            'photos'  => $saved,
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

        $photo = GarageImage::where('id', $id)
            ->where('garage_id', $garage->id)
            ->first();

        if (!$photo) {
            return response()->json(['message' => 'Photo not found'], 404);
        }
        if (Storage::disk('public')->exists($photo->image_path)) {
            Storage::disk('public')->delete($photo->image_path);
        }

        $photo->delete();

        return response()->json(['message' => 'Photo deleted successfully']);
    }
}
