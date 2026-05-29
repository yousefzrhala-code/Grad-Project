<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\ContactController;
use App\Http\Controllers\FavoriteController;
use App\Http\Controllers\GarageController;
use App\Http\Controllers\GaragePhotoController;
use App\Http\Controllers\GarageServiceController;
use App\Http\Controllers\NotificationController;
use App\Http\Controllers\PaymentController;
use App\Http\Controllers\RatingController;
use App\Http\Controllers\ReportController;
use App\Http\Controllers\ReservationController;
use Illuminate\Support\Facades\Route;

Route::post('/auth/register', [AuthController::class, 'register']);
Route::post('/auth/login', [AuthController::class, 'login']);

Route::get('/garages', [GarageController::class, 'index']);
Route::get('/garages/{id}', [GarageController::class, 'show']);
Route::get('/garages/{id}/availability', [GarageController::class, 'availability']);
Route::get('/garages/{id}/ratings', [RatingController::class, 'garageRatings']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user/profile', [AuthController::class, 'profile']);
    Route::post('/change-password', [AuthController::class, 'changePassword']);

    Route::get('/garage/my', [GarageController::class, 'myGarage']);
    Route::post('/garage/store', [GarageController::class, 'store']);
    Route::post('/garage/update', [GarageController::class, 'update']);
    Route::post('/garage/update-availability', [GarageController::class, 'updateAvailability']);

    // Garage owner — photos
    Route::get('/garage/photos', [GaragePhotoController::class, 'index']);
    Route::post('/garage/photos', [GaragePhotoController::class, 'store']);
    Route::delete('/garage/photos/{id}', [GaragePhotoController::class, 'destroy']);

    // Garage owner — services
    Route::get('/garage/services', [GarageServiceController::class, 'index']);
    Route::post('/garage/services', [GarageServiceController::class, 'store']);
    Route::delete('/garage/services/{id}', [GarageServiceController::class, 'destroy']);

    // Car owner — booking (payment fields included in the booking request)
    Route::post('/reservations',                         [ReservationController::class, 'store']);
    Route::get('/reservations/my',                       [ReservationController::class, 'myReservations']);
    Route::get('/reservations/upcoming',                 [ReservationController::class, 'upcomingReservations']);
    Route::get('/reservations/previous',                 [ReservationController::class, 'previousReservations']);
    Route::post('/reservations/{id}/cancel',             [ReservationController::class, 'cancel']);

    // Garage owner — manage reservations (?status= filter supported)
    Route::get('/garage-owner/reservations',             [ReservationController::class, 'garageOwnerReservations']);
    Route::get('/garage-owner/statistics',               [ReservationController::class, 'statistics']);
    Route::post('/reservations/{id}/respond',            [ReservationController::class, 'respondToReservation']);
    Route::post('/reservations/{id}/cancel-by-owner',    [ReservationController::class, 'cancelByOwner']);

    // Shared — check-in / check-out (either party)
    Route::post('/reservations/{id}/check-in',           [ReservationController::class, 'checkIn']);
    Route::post('/reservations/{id}/check-out',          [ReservationController::class, 'checkOut']);

    Route::post('/toggle-favorite', [FavoriteController::class, 'toggleFavorite']);
    Route::get('/favorites', [FavoriteController::class, 'getFavorites']);

    Route::post('/ratings', [RatingController::class, 'store']);

    Route::post('/reports', [ReportController::class, 'store']);
    Route::get('/reports/my', [ReportController::class, 'myReports']);

    Route::post('/user/device-token', [NotificationController::class, 'saveDeviceToken']);
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);

    // Fake payment simulation
    Route::post('/payments', [PaymentController::class, 'pay']);
    Route::get('/payments/my', [PaymentController::class, 'myPayments']);
});

Route::get('/payments/demo-card', [PaymentController::class, 'demoCard']);

Route::post('/contact/send', [ContactController::class, 'send']);
