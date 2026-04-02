<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\VehicleController;
use App\Http\Controllers\Api\DashboardController;

/*
|--------------------------------------------------------------------------
| API Routes WITH SCHEDULE VALIDATION
|--------------------------------------------------------------------------
|
| FITUR BARU:
| - GET /api/bookings/check-availability - Cek jadwal sebelum booking
| - GET /api/facilities/available-slots - Lihat jadwal kosong per hari
| - GET /api/facilities/bookings/{type}/{id}/{date} - Lihat jadwal penuh
|
*/

Route::middleware('api')->group(function () {

    // ===== PUBLIC ROUTES (Tanpa Authentication) =====
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);

    // ===== PROTECTED ROUTES (Require Authentication) =====
    Route::middleware('auth:sanctum')->group(function () {

        // ===== AUTH ROUTES =====
        Route::post('/logout', [AuthController::class, 'logout']);
        Route::get('/me', [AuthController::class, 'me']);

        // ===== BOOKING ROUTES =====
        Route::prefix('bookings')->group(function () {
            // Standard CRUD
            Route::get('/', [BookingController::class, 'index']);
            Route::post('/', [BookingController::class, 'store']);
            Route::get('/{id}', [BookingController::class, 'show']);

            // ✅ NEW: Schedule Validation
            Route::get('/check-availability', [BookingController::class, 'checkAvailability']);

            // Approval workflows
            Route::post('/{id}/approve-division', [BookingController::class, 'approveDivision']);
            Route::post('/{id}/approve-divum', [BookingController::class, 'approveDivum']);
        });

        // ===== FACILITY ROUTES (BARU) =====
        Route::prefix('facilities')->group(function () {
            // Available slots untuk time picker di UI
            Route::get('/available-slots', [BookingController::class, 'getAvailableSlotsForFacility']);

            // Jadwal lengkap untuk kalender/timeline view
            Route::get('/bookings/{type}/{id}/{date}', [BookingController::class, 'getFacilityBookingsByDate']);
        });

        // ===== RESOURCE ENDPOINTS =====
        Route::get('/available-rooms', [BookingController::class, 'getAvailableRooms']);
        Route::get('/available-vehicles', [BookingController::class, 'getAvailableVehicles']);

        // ===== ROOM MANAGEMENT =====
        Route::get('/rooms', [RoomController::class, 'index']);
        Route::post('/rooms', [RoomController::class, 'store']);
        Route::put('/rooms/{id}', [RoomController::class, 'update']);
        Route::delete('/rooms/{id}', [RoomController::class, 'destroy']);

        // ===== VEHICLE MANAGEMENT =====
        Route::get('/vehicles', [VehicleController::class, 'index']);
        Route::post('/vehicles', [VehicleController::class, 'store']);
        Route::put('/vehicles/{id}', [VehicleController::class, 'update']);
        Route::delete('/vehicles/{id}', [VehicleController::class, 'destroy']);

        // ===== DASHBOARD (Admin Only) =====
        Route::prefix('dashboard')->middleware('admin')->group(function () {
            Route::get('/stats', [DashboardController::class, 'getStats']);
            Route::get('/bookings', [DashboardController::class, 'getBookings']);
        });
    });
});

// Middleware definition for admin role check
Route::middleware('auth:sanctum')->group(function () {
    // Apply admin check per request if needed
});

