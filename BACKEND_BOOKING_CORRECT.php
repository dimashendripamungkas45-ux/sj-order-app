<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    /**
     * Get all bookings for current user
     */
    public function index()
    {
        $user = auth('api')->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $bookings = Booking::where('user_id', $user->id)
            ->orderBy('booking_date', 'desc')
            ->get()
            ->map(function($booking) {
                return [
                    'id' => $booking->id,
                    'booking_code' => $booking->booking_code,
                    'booking_type' => $booking->booking_type,
                    'booking_date' => $booking->booking_date,
                    'start_time' => $booking->start_time,
                    'end_time' => $booking->end_time,
                    'purpose' => $booking->purpose,
                    'status' => $booking->status,
                    'room_id' => $booking->room_id,
                    'vehicle_id' => $booking->vehicle_id,
                    'participants_count' => $booking->participants_count,
                    'destination' => $booking->destination,
                ];
            });

        return response()->json([
            'success' => true,
            'message' => 'Bookings retrieved successfully',
            'data' => $bookings
        ], 200);
    }

    /**
     * Get single booking detail
     */
    public function show($id)
    {
        $user = auth('api')->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $booking = Booking::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $booking->id,
                'booking_code' => $booking->booking_code,
                'booking_type' => $booking->booking_type,
                'booking_date' => $booking->booking_date,
                'start_time' => $booking->start_time,
                'end_time' => $booking->end_time,
                'purpose' => $booking->purpose,
                'status' => $booking->status,
                'room_id' => $booking->room_id,
                'vehicle_id' => $booking->vehicle_id,
                'participants_count' => $booking->participants_count,
                'destination' => $booking->destination,
                'division_approval_notes' => $booking->division_approval_notes,
                'ga_approval_notes' => $booking->ga_approval_notes,
            ]
        ], 200);
    }

    /**
     * Create new booking
     */
    public function store(Request $request)
    {
        $user = auth('api')->user();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'booking_type' => 'required|in:room,vehicle',
            'booking_date' => 'required|date|after:today',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'purpose' => 'required|min:5',
            'room_id' => 'required_if:booking_type,room|nullable|exists:rooms,id',
            'vehicle_id' => 'required_if:booking_type,vehicle|nullable|exists:vehicles,id',
            'participants_count' => 'nullable|integer|min:1',
            'destination' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            // Generate booking code: YYYYMMDD + Random 4 chars
            $bookingCode = date('Ymd') . strtoupper(substr(md5(uniqid()), 0, 4));

            $booking = Booking::create([
                'booking_code' => $bookingCode,
                'user_id' => $user->id,
                'division_id' => $user->division_id,
                'booking_type' => $request->booking_type,
                'booking_date' => $request->booking_date,
                'start_time' => $request->start_time,
                'end_time' => $request->end_time,
                'purpose' => $request->purpose,
                'room_id' => $request->booking_type === 'room' ? $request->room_id : null,
                'vehicle_id' => $request->booking_type === 'vehicle' ? $request->vehicle_id : null,
                'participants_count' => $request->participants_count,
                'destination' => $request->destination,
                'status' => 'pending_division',
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Booking created successfully',
                'data' => [
                    'id' => $booking->id,
                    'booking_code' => $booking->booking_code,
                    'status' => $booking->status,
                ]
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to create booking: ' . $e->getMessage(),
            ], 500);
        }
    }

    /**
     * Get available rooms
     */
    public function getAvailableRooms(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'booking_date' => 'required|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $bookedRoomIds = Booking::where('booking_date', $request->booking_date)
            ->where('booking_type', 'room')
            ->whereIn('status', ['pending_division', 'pending_ga', 'approved'])
            ->pluck('room_id')
            ->toArray();

        $rooms = \App\Models\Room::where('is_active', 1)
            ->whereNotIn('id', $bookedRoomIds)
            ->get(['id', 'name', 'capacity', 'location', 'facilities']);

        return response()->json([
            'success' => true,
            'data' => $rooms
        ], 200);
    }

    /**
     * Get available vehicles
     */
    public function getAvailableVehicles(Request $request)
    {
        $validator = \Illuminate\Support\Facades\Validator::make($request->all(), [
            'booking_date' => 'required|date',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $bookedVehicleIds = Booking::where('booking_date', $request->booking_date)
            ->where('booking_type', 'vehicle')
            ->whereIn('status', ['pending_division', 'pending_ga', 'approved'])
            ->pluck('vehicle_id')
            ->toArray();

        $vehicles = \App\Models\Vehicle::where('is_active', 1)
            ->whereNotIn('id', $bookedVehicleIds)
            ->get(['id', 'name', 'type', 'capacity', 'license_plate', 'driver_name']);

        return response()->json([
            'success' => true,
            'data' => $vehicles
        ], 200);
    }
}

