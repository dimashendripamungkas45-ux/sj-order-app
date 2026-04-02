<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;

/*
|--------------------------------------------------------------------------
| API Routes with Full Booking Approval Workflow
|--------------------------------------------------------------------------
|
| Routes untuk sistem pemesanan ruang dan kendaraan dengan approval bertahap
| - Tahap 1: Pimpinan Divisi (pending_division → pending_divum/rejected_division)
| - Tahap 2: Admin DIVUM (pending_divum → approved/rejected_divum)
|
*/

// ===== PUBLIC ROUTES (tanpa autentikasi) =====
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// ===== PROTECTED ROUTES (memerlukan autentikasi) =====
Route::middleware('auth:api')->group(function () {

    // ===== AUTH ROUTES =====
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/refresh', [AuthController::class, 'refresh']);

    // ===== BOOKING ROUTES =====

    // List bookings (filtered by role)
    // - user: melihat booking miliknya
    // - pimpinan_divisi: melihat pending_division dari divisinya
    // - admin_divum: melihat pending_divum
    Route::get('/bookings', [BookingController::class, 'index']);

    // Create new booking (user)
    // Status awal: pending_division
    Route::post('/bookings', [BookingController::class, 'store']);

    // Get booking detail
    Route::get('/bookings/{id}', [BookingController::class, 'show']);

    // ===== APPROVAL ROUTES =====

    // Tahap 1: Approval oleh Pimpinan Divisi
    // PUT /bookings/{id}/approve-division
    // Body: { "action": "approve|reject", "notes": "..." }
    // Status transition: pending_division → pending_divum (approve) / rejected_division (reject)
    Route::put('/bookings/{id}/approve-division', [BookingController::class, 'approveDivision']);

    // Tahap 2: Final approval oleh Admin DIVUM
    // PUT /bookings/{id}/approve-divum
    // Body: { "action": "approve|reject", "notes": "..." }
    // Status transition: pending_divum → approved (approve) / rejected_divum (reject)
    Route::put('/bookings/{id}/approve-divum', [BookingController::class, 'approveDivum']);

    // ===== RESOURCE ROUTES =====

    // Get available rooms for dropdown
    Route::get('/available-rooms', [BookingController::class, 'getAvailableRooms']);

    // Get available vehicles for dropdown
    Route::get('/available-vehicles', [BookingController::class, 'getAvailableVehicles']);
});

// Fallback untuk undefined routes
Route::fallback(function () {
    return response()->json([
        'success' => false,
        'message' => 'Route not found',
    ], 404);
});

