<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;

/*
|--------------------------------------------------------------------------
| API Routes (routes/api.php)
|--------------------------------------------------------------------------
|
| Add these routes to your routes/api.php file
| Include the approval endpoints for the booking workflow
|
*/

// Public routes (no authentication required)
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected routes (authentication required)
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/refresh', [AuthController::class, 'refresh']);

    // Booking routes
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/{id}', [BookingController::class, 'show']);

    // ✅ APPROVAL ENDPOINTS - Add these!
    Route::post('/bookings/{id}/approve-division', [BookingController::class, 'approveDivision']);
    Route::post('/bookings/{id}/approve-divum', [BookingController::class, 'approveDivum']);

    // Available resources
    Route::get('/available-rooms', [BookingController::class, 'getAvailableRooms']);
    Route::get('/available-vehicles', [BookingController::class, 'getAvailableVehicles']);
});

