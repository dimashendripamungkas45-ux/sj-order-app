<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\VehicleController;

/*
|--------------------------------------------------------------------------
| API Routes - Final Production Version
|--------------------------------------------------------------------------
|
| These routes are hit by the Flutter mobile app
| All endpoints require authentication (token)
|
*/

// ==========================================
// 🔴 PUBLIC ROUTES (NO AUTH REQUIRED)
// ==========================================
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// ==========================================
// 🟢 PROTECTED ROUTES (AUTH REQUIRED)
// ==========================================
Route::middleware(['auth:sanctum'])->group(function () {

    // ===== AUTH ENDPOINTS =====
    Route::get('/user', [AuthController::class, 'getUser']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/refresh', [AuthController::class, 'refresh']);

    // ===== BOOKING ENDPOINTS (CORE) =====
    Route::get('/bookings', [BookingController::class, 'index']);                    // ✅ Get all bookings (ROLE-BASED)
    Route::post('/bookings', [BookingController::class, 'store']);                   // ✅ Create booking
    Route::get('/bookings/{id}', [BookingController::class, 'show']);                // ✅ Get booking detail

    // ===== APPROVAL ENDPOINTS - STEP 1 (LEADER DIVISION) =====
    Route::put('/bookings/{id}/approve-division', [BookingController::class, 'approveDivision']);

    // ===== APPROVAL ENDPOINTS - STEP 2 (ADMIN - FINAL APPROVAL) =====
    Route::put('/bookings/{id}/approve-divum', [BookingController::class, 'approveDivum']);

    // ===== RESOURCE ENDPOINTS (UTILITY) =====
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
});

