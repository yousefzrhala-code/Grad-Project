<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Admin\AdminController;
use App\Models\User;
use App\Models\Garage;
use App\Models\Reservation;
use App\Models\ContactMessage;

class AdminDashboardController extends AdminController
{
    public function index()
    {
        $this->checkAdmin();
        $total = User::where('role', 'car_owner')->count() + User::where('role', 'garage_owner')->count();
        $stats = [
            'total_users' => $total,
            'car_owners' => User::where('role', 'car_owner')->count(),
            'garage_owners' => User::where('role', 'garage_owner')->count(),
            'total_garages' => Garage::count(),
            'pending_garages' => Garage::where('approval_status', 'pending')->count(),
            'approved_garages' => Garage::where('approval_status', 'approved')->count(),
            'rejected_garages' => Garage::where('approval_status', 'rejected')->count(),
            'total_reservations' => Reservation::count(),
            'contact_messages' => ContactMessage::count(),
            'new_messages' => ContactMessage::where('status', 'new')->count(),
        ];

        return view('admin.dashboard', compact('stats'));
    }
}
