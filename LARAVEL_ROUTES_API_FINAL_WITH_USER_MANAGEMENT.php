<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\BookingController;
use App\Http\Controllers\RoomController;
use App\Http\Controllers\VehicleController;
use App\Http\Controllers\UserManagementController;

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

// PUBLIC ROUTES (No authentication required)
Route::post('/login', [AuthController::class, 'login']);
Route::post('/logout', [AuthController::class, 'logout']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/refresh', [AuthController::class, 'refresh']);

// PROTECTED ROUTES (Authentication required)
Route::middleware('auth:sanctum')->group(function () {

    // ========== BOOKING ROUTES ==========
    Route::get('/bookings', [BookingController::class, 'index']);
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/{id}', [BookingController::class, 'show']);
    Route::put('/bookings/{id}', [BookingController::class, 'update']);
    Route::delete('/bookings/{id}', [BookingController::class, 'destroy']);
    Route::get('/bookings/{id}/show', [BookingController::class, 'show']);
    Route::get('/available-rooms', [BookingController::class, 'getAvailableRooms']);
    Route::get('/available-vehicles', [BookingController::class, 'getAvailableVehicles']);
    Route::get('/bookings/check-availability', [BookingController::class, 'checkAvailability']);
    Route::put('/bookings/{id}/approve-division', [BookingController::class, 'approveDivision']);
    Route::put('/bookings/{id}/approve-divum', [BookingController::class, 'approveDivum']);

    // ========== ROOM ROUTES ==========
    Route::get('/rooms', [RoomController::class, 'index']);
    Route::post('/rooms', [RoomController::class, 'store']);
    Route::get('/rooms/{id}', [RoomController::class, 'show']);
    Route::put('/rooms/{id}', [RoomController::class, 'update']);
    Route::delete('/rooms/{id}', [RoomController::class, 'destroy']);

    // ========== VEHICLE ROUTES ==========
    Route::get('/vehicles', [VehicleController::class, 'index']);
    Route::post('/vehicles', [VehicleController::class, 'store']);
    Route::get('/vehicles/{id}', [VehicleController::class, 'show']);
    Route::put('/vehicles/{id}', [VehicleController::class, 'update']);
    Route::delete('/vehicles/{id}', [VehicleController::class, 'destroy']);

    // ========== USER MANAGEMENT ROUTES ==========
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::post('/users', [UserManagementController::class, 'store']);
    Route::get('/users/{id}', [UserManagementController::class, 'show']);
    Route::put('/users/{id}', [UserManagementController::class, 'update']);
    Route::delete('/users/{id}', [UserManagementController::class, 'destroy']);

});

// CSRF Cookie Route
Route::get('/sanctum/csrf-cookie', function (Request $request) {
    return response()->json(['status' => 'ok']);
});

// Storage routes for file uploads
Route::get('/storage/{path}', function (Request $request, $path) {
    return response()->download(storage_path('app/' . $path));
})->where('path', '.*');

Route::post('/storage/{path}/upload', function (Request $request, $path) {
    if ($request->hasFile('file')) {
        $file = $request->file('file');
        $name = time() . '_' . $file->getClientOriginalName();
        $file->storeAs($path, $name);
        return response()->json(['success' => true, 'filename' => $name]);
    }
    return response()->json(['success' => false], 400);
})->where('path', '.*')->middleware('auth:sanctum');

// Health check route
Route::get('/health', function () {
    return response()->json(['status' => 'ok']);
});

