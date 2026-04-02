<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;
use App\Http\Controllers\Api\RoomController;
use App\Http\Controllers\Api\VehicleController;

// Public routes
Route::post('/login', [AuthController::class, 'login']);

// Protected routes (token validated in controller)
Route::get('/user', [AuthController::class, 'getUser']);
Route::post('/logout', [AuthController::class, 'logout']);

// ===== BOOKINGS ROUTES =====
Route::get('/bookings', [BookingController::class, 'index']);
Route::post('/bookings', [BookingController::class, 'store']);  // ✅ CREATE booking
Route::get('/bookings/{id}', [BookingController::class, 'show']);

// ===== APPROVAL ROUTES (NEW) =====
Route::put('/bookings/{id}/approve-division', [BookingController::class, 'approveDivision']);  // Tahap 1
Route::put('/bookings/{id}/approve-divum', [BookingController::class, 'approveDivum']);        // Tahap 2

// Legacy approval routes (keep for backward compatibility)
Route::post('/bookings/{id}/approve', [BookingController::class, 'approve']);
Route::post('/bookings/{id}/reject', [BookingController::class, 'reject']);

// ===== RESOURCE ENDPOINTS =====
Route::get('/available-rooms', [BookingController::class, 'getAvailableRooms']);
Route::get('/available-vehicles', [BookingController::class, 'getAvailableVehicles']);

// Rooms routes
Route::get('/rooms', [RoomController::class, 'index']);
Route::post('/rooms', [RoomController::class, 'store']);
Route::put('/rooms/{id}', [RoomController::class, 'update']);
Route::delete('/rooms/{id}', [RoomController::class, 'destroy']);

// Vehicles routes
Route::get('/vehicles', [VehicleController::class, 'index']);
Route::post('/vehicles', [VehicleController::class, 'store']);
Route::put('/vehicles/{id}', [VehicleController::class, 'update']);
Route::delete('/vehicles/{id}', [VehicleController::class, 'destroy']);

