<?php

namespace App\Http\Controllers\Admin;

abstract class AdminController
{
    public function checkAdmin()
    {
        if (!auth()->check() || auth()->user()->role !== 'admin') {
            abort(403, 'Unauthorized');
        }
    }
}
