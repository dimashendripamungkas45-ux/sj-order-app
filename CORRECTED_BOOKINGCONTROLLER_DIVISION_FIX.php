<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Room;
use App\Models\Vehicle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;

class BookingController extends Controller
{
    /**
     * Get authenticated user safely with fallback
     */
    private function getAuthUser()
    {
        try {
            $user = auth('sanctum')->user();
            if ($user) {
                \Log::info('✅ User authenticated via Sanctum', ['user_id' => $user->id]);
                return $user;
            }
        } catch (\Exception $e) {
            \Log::warning('⚠️ Sanctum auth failed', ['error' => $e->getMessage()]);
        }

        try {
            $user = auth('api')->user();
            if ($user) {
                \Log::info('✅ User authenticated via api guard', ['user_id' => $user->id]);
                return $user;
            }
        } catch (\Exception $e) {
            \Log::warning('⚠️ API guard auth failed', ['error' => $e->getMessage()]);
        }

        $user = auth()->user();
        if ($user) {
            \Log::info('✅ User authenticated via default guard', ['user_id' => $user->id]);
            return $user;
        }

        \Log::error('❌ No user authenticated', [
            'sanctum_user' => auth('sanctum')->check(),
            'api_user' => auth('api')->check(),
            'default_user' => auth()->check(),
        ]);
        return null;
    }

    /**
     * Create new booking
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function store(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        $validator = Validator::make($request->all(), [
            'booking_type' => 'required|in:room,vehicle',
            'booking_date' => 'required|date|after_or_equal:today',
            'start_time' => 'required|date_format:H:i',
            'end_time' => 'required|date_format:H:i|after:start_time',
            'purpose' => 'required|min:5',
            'room_id' => 'required_if:booking_type,room|nullable|integer|exists:rooms,id',
            'vehicle_id' => 'required_if:booking_type,vehicle|nullable|integer|exists:vehicles,id',
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
            // Prepare booking data
            $bookingData = [
                'user_id' => $user->id,
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
            ];

            // Add division_id ONLY if user has one (optional)
            if (isset($user->division_id) && $user->division_id) {
                $bookingData['division_id'] = $user->division_id;
            }

            // Add booking_code only if column exists
            if (Schema::hasColumn('bookings', 'booking_code')) {
                $bookingCode = date('Ymd') . strtoupper(substr(md5(uniqid()), 0, 4));
                $bookingData['booking_code'] = $bookingCode;
            }

            $booking = Booking::create($bookingData);

            return response()->json([
                'success' => true,
                'message' => 'Booking created successfully',
                'data' => $booking->toApiResponse()
            ], 201);
        } catch (\Exception $e) {
            \Log::error('❌ Error creating booking', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error creating booking: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get available rooms for booking
     */
    public function getAvailableRooms(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        try {
            $rooms = Room::where('is_active', true)
                        ->select('id', 'name', 'capacity', 'description')
                        ->get();

            return response()->json([
                'success' => true,
                'message' => 'Available rooms retrieved',
                'data' => $rooms
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving rooms: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get available vehicles for booking
     */
    public function getAvailableVehicles(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        try {
            $vehicles = Vehicle::where('is_active', true)
                              ->select('id', 'name', 'type', 'capacity', 'description')
                              ->get();

            return response()->json([
                'success' => true,
                'message' => 'Available vehicles retrieved',
                'data' => $vehicles
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving vehicles: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all bookings
     */
    public function index(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        try {
            $bookings = Booking::where('user_id', $user->id)
                              ->orderBy('booking_date', 'desc')
                              ->get();

            return response()->json([
                'success' => true,
                'message' => 'Bookings retrieved successfully',
                'data' => $bookings,
                'count' => $bookings->count(),
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving bookings: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get single booking detail
     */
    public function show($id)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        try {
            $booking = Booking::find($id);

            if (!$booking) {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking not found'
                ], 404);
            }

            // Check permission - user can only see their own bookings
            if ($booking->user_id !== $user->id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            return response()->json([
                'success' => true,
                'data' => $booking->toApiResponse()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving booking: ' . $e->getMessage()
            ], 500);
        }
    }
}

