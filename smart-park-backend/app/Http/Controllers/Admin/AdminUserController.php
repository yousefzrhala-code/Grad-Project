<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Admin\AdminController;
use App\Models\User;
use Illuminate\Http\Request;

class AdminUserController extends AdminController
{

    public function carOwners()
    {
        $this->checkAdmin();

        $users = User::where('role', 'car_owner')->get();

        return view('admin.car_owners.index', compact('users'));
    }

    public function garageOwners()
    {
        $this->checkAdmin();

        $users = User::where('role', 'garage_owner')->get();

        return view('admin.garage_owners.index', compact('users'));
    }

    public function approveGarageOwner($id)
    {
        $this->checkAdmin();

        $user = User::findOrFail($id);
        $user->approval_status = 'approved';
        $user->save();

        return back()->with('success', 'Garage owner approved');
    }

    public function rejectGarageOwner($id)
    {
        $this->checkAdmin();

        $user = User::findOrFail($id);
        $user->approval_status = 'rejected';
        $user->save();

        return back()->with('success', 'Garage owner rejected');
    }

    public function deleteUser($id)
    {
        $this->checkAdmin();

        User::findOrFail($id)->delete();

        return back()->with('success', 'User deleted');
    }

    public function createGarageOwner()
    {
        return view('admin.garage_owners.create');
    }

    public function storeGarageOwner(Request $request)
    {
        $request->validate([
            'name' => 'required',
            'email' => 'required|email|unique:users,email',
            'password' => 'required|min:6',
            'mobile' => 'required|max:10|min:10',

        ]);
        User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password),
            'mobile' => $request->mobile,
            'role' => 'garage_owner',
            'approval_status' => 'approved',

        ]);
        return redirect()->back()->with('success', 'Garage owner created');
    }
}
