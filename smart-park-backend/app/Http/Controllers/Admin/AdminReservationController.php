<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Admin\AdminController;
use App\Models\Reservation;

class AdminReservationController extends AdminController
{
    public function index()
    {
        $this->checkAdmin();
        $reservations = Reservation::with(['carOwner', 'garage'])->latest()->get();
        return view('admin.reservations.index', compact('reservations'));
    }
}
