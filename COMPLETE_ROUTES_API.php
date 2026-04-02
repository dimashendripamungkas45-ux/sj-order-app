<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\BookingController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

// Public Routes (No Authentication)
Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

// Protected Routes (Authentication Required)
Route::middleware('auth:sanctum')->group(function () {

    // Auth Routes
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::post('/refresh', [AuthController::class, 'refresh']);

    // Booking CRUD Routes
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/{id}', [BookingController::class, 'show']);

    // Booking Approval Routes - Division Leader
    Route::post('/bookings/{id}/approve-division', [BookingController::class, 'approveDivision']);
    Route::post('/bookings/{id}/reject-division', [BookingController::class, 'rejectDivision']);

    // Booking Approval Routes - DIVUM Admin
    Route::post('/bookings/{id}/approve-divum', [BookingController::class, 'approveDivum']);
    Route::post('/bookings/{id}/reject-divum', [BookingController::class, 'rejectDivum']);

    // Available Resources Routes
    Route::get('/available-rooms', [BookingController::class, 'getAvailableRooms']);
    Route::get('/available-vehicles', [BookingController::class, 'getAvailableVehicles']);
});

