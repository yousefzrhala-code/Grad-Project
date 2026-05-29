<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Admin\AdminAuthController;
use App\Http\Controllers\Admin\AdminUserController;
use App\Http\Controllers\Admin\AdminDashboardController;
use App\Http\Controllers\Admin\AdminGarageController;
use App\Http\Controllers\Admin\AdminContactController;
use App\Http\Controllers\Admin\AdminReportController;
use App\Http\Controllers\Admin\AdminReservationController;

Route::get('/admin', [AdminAuthController::class, 'showLogin']);
Route::get('/admin/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
Route::post('/admin/login', [AdminAuthController::class, 'login'])->name('admin.login.submit');
Route::post('/admin/logout', [AdminAuthController::class, 'logout'])->name('admin.logout');
Route::prefix('admin')->group(function () {
    Route::get('/dashboard', [AdminDashboardController::class, 'index'])->name('admin.dashboard');
    Route::get('/car-owners', [AdminUserController::class, 'carOwners'])->name('admin.carOwners');
    Route::get('/garage-owners', [AdminUserController::class, 'garageOwners'])->name('admin.garageOwners');
    Route::post('/garage-owners/{id}/approve', [AdminUserController::class, 'approveGarageOwner'])->name('admin.garageOwners.approve');
    Route::post('/garage-owners/{id}/reject', [AdminUserController::class, 'rejectGarageOwner'])->name('admin.garageOwners.reject');
    Route::delete('/users/{id}', [AdminUserController::class, 'deleteUser'])->name('admin.users.delete');
    Route::get('/garages', [AdminGarageController::class, 'index'])->name('admin.garages.index');
    Route::post('/garages/{id}/approve', [AdminGarageController::class, 'approve'])->name('admin.garages.approve');
    Route::post('/garages/{id}/reject', [AdminGarageController::class, 'reject'])->name('admin.garages.reject');
    Route::delete('/garages/{id}', [AdminGarageController::class, 'delete'])->name('admin.garages.delete');
    Route::get('/contact-messages', [AdminContactController::class, 'index'])->name('admin.contact.index');
    Route::post('/contact-messages/{id}/replied', [AdminContactController::class, 'markReplied'])->name('admin.contact.replied');
    Route::delete('/contact-messages/{id}', [AdminContactController::class, 'delete'])->name('admin.contact.delete');
    Route::get('/reservations', [AdminReservationController::class, 'index'])->name('admin.reservations.index');

    // Garage reports (complaints)
    Route::get('/reports', [AdminReportController::class, 'index'])->name('admin.reports.index');
    Route::post('/reports/{id}/reviewed', [AdminReportController::class, 'markReviewed'])->name('admin.reports.reviewed');
    Route::post('/reports/{id}/resolved', [AdminReportController::class, 'markResolved'])->name('admin.reports.resolved');
    Route::delete('/reports/{id}', [AdminReportController::class, 'delete'])->name('admin.reports.delete');

    Route::get('/admin/garage-owners/create', [AdminUserController::class, 'createGarageOwner'])->name('admin.garageOwners.create');
    Route::post('/admin/garage-owners/store', [AdminUserController::class, 'storeGarageOwner'])->name('admin.garageOwners.store');

    Route::get('/admin/garages/create', [AdminGarageController::class, 'createGarage'])->name('admin.garages.create');
    Route::post('/admin/garages/store', [AdminGarageController::class, 'storeGarage'])->name('admin.garages.store');
});
