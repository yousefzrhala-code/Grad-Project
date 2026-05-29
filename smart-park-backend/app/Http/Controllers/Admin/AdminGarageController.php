<?php

namespace App\Http\Controllers\Admin;
use App\Http\Controllers\Admin\AdminController;
use App\Models\Garage;
use App\Models\User;
use Illuminate\Http\Request;

class AdminGarageController extends AdminController

{
    public function index()
    {
        $this->checkAdmin();

        $garages = Garage::with('owner')->latest()->get();

        return view('admin.garages.index', compact('garages'));
    }

    public function approve($id)
    {
        $this->checkAdmin();

        $garage = Garage::findOrFail($id);
        $garage->approval_status = 'approved';
        $garage->is_approved = true;
        $garage->save();

        return back()->with('success', 'Garage approved successfully');
    }

    public function reject($id)
    {
        $this->checkAdmin();

        $garage = Garage::findOrFail($id);
        $garage->approval_status = 'rejected';
        $garage->is_approved = false;
        $garage->save();

        return back()->with('success', 'Garage rejected successfully');
    }

    public function delete($id)
    {
        $this->checkAdmin();

        Garage::findOrFail($id)->delete();

        return back()->with('success', 'Garage deleted successfully');
    }

    public function createGarage()
    {
        $owners = User::where('role', 'garage_owner')->get();
        return view('admin.garages.create', compact('owners'));
    }

    public function storeGarage(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'city' => 'required',
            'price_per_hour' => 'required|numeric',
            'capacity' => 'required|integer',
            'owner_id' => 'required|exists:users,id',
            'address' => 'required|max:255'
        ]);

        Garage::create([
            'name' => $request->name,
            'city' => $request->city,
            'price_per_hour' => $request->price_per_hour,
            'capacity' => $request->capacity,
            'owner_id' => $request->owner_id,
            'approval_status' => 'approved',
            'is_active' => 1,
            'available_spots' => $request->capacity,
            'address' => $request->address
        ]);

        return redirect()->route('admin.garages.index')->with('success', 'Garage created');
    }
}
