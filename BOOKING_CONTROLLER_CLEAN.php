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
     * Get all bookings (filtered by role)
     *
     * @return \Illuminate\Http\JsonResponse
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

        $query = Booking::with(['user', 'room', 'vehicle', 'divisionApprover', 'divumApprover']);

        // Filter berdasarkan role
        if ($user->role === 'user') {
            // User hanya melihat booking miliknya sendiri
            $query->where('user_id', $user->id);
        } elseif ($user->role === 'pimpinan_divisi') {
            // Pimpinan Divisi melihat booking pending_division dari divisinya
            $query->where('division_id', $user->division_id)
                  ->where('status', 'pending_division');
        } elseif ($user->role === 'admin_divum') {
            // Admin DIVUM melihat booking pending_divum
            $query->where('status', 'pending_divum');
        } else {
            return response()->json([
                'success' => false,
                'message' => 'Invalid role'
            ], 403);
        }

        $bookings = $query->orderBy('booking_date', 'desc')
                          ->get()
                          ->map(fn($booking) => $booking->toApiResponse());

        return response()->json([
            'success' => true,
            'message' => 'Bookings retrieved successfully',
            'data' => $bookings,
            'count' => $bookings->count(),
        ], 200);
    }

    /**
     * Get single booking detail
     *
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
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

        $booking = Booking::with(['user', 'room', 'vehicle', 'divisionApprover', 'divumApprover'])
                          ->find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Check permission
        if ($user->role === 'user' && $booking->user_id !== $user->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $booking->toApiResponse()
        ], 200);
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
            'purpose' => 'required|min:10',
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
                'division_id' => $user->division_id ?? null,
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
            return response()->json([
                'success' => false,
                'message' => 'Error creating booking: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Approve booking (Tahap 1: Pimpinan Divisi)
     *
     * @param \Illuminate\Http\Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function approveDivision(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        // Check if user is pimpinan_divisi
        if ($user->role !== 'pimpinan_divisi') {
            return response()->json([
                'success' => false,
                'message' => 'Only division leaders can approve bookings'
            ], 403);
        }

        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Check if booking is in correct status
        if ($booking->status !== 'pending_division') {
            return response()->json([
                'success' => false,
                'message' => 'Booking cannot be approved at this status'
            ], 422);
        }

        // Check if user's division matches
        if ($booking->division_id !== $user->division_id) {
            return response()->json([
                'success' => false,
                'message' => 'You can only approve bookings from your division'
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'action' => 'required|in:approve,reject',
            'notes' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            if ($request->action === 'approve') {
                $booking->update([
                    'status' => 'pending_divum',
                    'approved_by_division' => $user->id,
                    'approved_at_division' => Carbon::now(),
                    'division_approval_notes' => $request->notes,
                ]);
                $message = 'Booking approved by division leader';
            } else {
                $booking->update([
                    'status' => 'rejected_division',
                    'approved_by_division' => $user->id,
                    'approved_at_division' => Carbon::now(),
                    'division_approval_notes' => $request->notes,
                ]);
                $message = 'Booking rejected by division leader';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => $booking->toApiResponse()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating booking: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Approve booking (Tahap 2: Admin DIVUM)
     *
     * @param \Illuminate\Http\Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function approveDivum(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        // Check if user is admin_divum
        if ($user->role !== 'admin_divum') {
            return response()->json([
                'success' => false,
                'message' => 'Only DIVUM admin can approve bookings'
            ], 403);
        }

        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Check if booking is in correct status
        if ($booking->status !== 'pending_divum') {
            return response()->json([
                'success' => false,
                'message' => 'Booking cannot be approved at this status'
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'action' => 'required|in:approve,reject',
            'notes' => 'nullable|string|max:500',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            if ($request->action === 'approve') {
                $booking->update([
                    'status' => 'approved',
                    'approved_by_divum' => $user->id,
                    'approved_at_divum' => Carbon::now(),
                    'divum_approval_notes' => $request->notes,
                ]);
                $message = 'Booking fully approved by DIVUM';
            } else {
                $booking->update([
                    'status' => 'rejected_divum',
                    'approved_by_divum' => $user->id,
                    'approved_at_divum' => Carbon::now(),
                    'divum_approval_notes' => $request->notes,
                ]);
                $message = 'Booking rejected by DIVUM';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => $booking->toApiResponse()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error updating booking: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get available rooms for booking
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
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
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
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
}

