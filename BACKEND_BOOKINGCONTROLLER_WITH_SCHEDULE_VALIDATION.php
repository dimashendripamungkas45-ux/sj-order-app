<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Room;
use App\Models\Vehicle;
use App\Traits\BookingScheduleValidator;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Schema;
use Carbon\Carbon;

/**
 * BookingController dengan Time-Slot Validation
 *
 * FITUR BARU:
 * 1. Validasi jadwal (cegah double-booking)
 * 2. Jeda minimal 30 menit antara booking
 * 3. API untuk cek available slots
 * 4. Notifikasi konflik booking
 *
 * ENDPOINTS BARU:
 * - GET /api/bookings/check-availability
 * - GET /api/bookings/{id}/available-slots/{date}
 * - GET /api/facility-bookings/{type}/{id}/{date}
 */
class BookingController extends Controller
{
    use BookingScheduleValidator;

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

        \Log::error('❌ No user authenticated');
        return null;
    }

    /**
     * ✅ NEW: Check availability sebelum create booking
     *
     * Endpoint: GET /api/bookings/check-availability?booking_type=room&room_id=1&booking_date=2024-03-15&start_time=10:00&end_time=11:00
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function checkAvailability(Request $request)
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
            'room_id' => 'required_if:booking_type,room|nullable|integer|exists:rooms,id',
            'vehicle_id' => 'required_if:booking_type,vehicle|nullable|integer|exists:vehicles,id',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $bookingData = [
                'booking_type' => $request->booking_type,
                'booking_date' => $request->booking_date,
                'start_time' => $request->start_time,
                'end_time' => $request->end_time,
                'room_id' => $request->room_id,
                'vehicle_id' => $request->vehicle_id,
            ];

            $result = $this->isTimeSlotAvailable($bookingData);

            \Log::info('📅 [checkAvailability] Result', [
                'booking_type' => $request->booking_type,
                'booking_date' => $request->booking_date,
                'available' => $result['available'],
                'conflicts_count' => count($result['conflicts']),
            ]);

            return response()->json([
                'success' => $result['available'],
                'available' => $result['available'],
                'message' => $result['message'],
                'conflicts' => $result['conflicts'],
            ], $result['available'] ? 200 : 422);

        } catch (\Exception $e) {
            \Log::error('❌ Error checking availability', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error checking availability: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * ✅ NEW: Get available time slots untuk fasilitas pada tanggal tertentu
     *
     * Endpoint: GET /api/facilities/available-slots?booking_type=room&facility_id=1&booking_date=2024-03-15
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getAvailableSlotsForFacility(Request $request)
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
            'facility_id' => 'required|integer|min:1',
            'booking_date' => 'required|date|after_or_equal:today',
            'interval' => 'nullable|in:15,30,60', // Minutes
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        try {
            $bookingType = $request->booking_type;
            $facilityId = $request->facility_id;
            $bookingDate = $request->booking_date;
            $interval = $request->input('interval', 30);

            // Verify facility exists
            if ($bookingType === 'room') {
                $facility = Room::find($facilityId);
                if (!$facility) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Room not found'
                    ], 404);
                }
                $facilityName = $facility->name;
            } else {
                $facility = Vehicle::find($facilityId);
                if (!$facility) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Vehicle not found'
                    ], 404);
                }
                $facilityName = $facility->name;
            }

            $slots = $this->getAvailableSlots($bookingType, $facilityId, $bookingDate, $interval);

            \Log::info('📅 [getAvailableSlotsForFacility] Facility: ' . $facilityName, [
                'booking_date' => $bookingDate,
                'available_count' => count($slots['available_slots']),
                'busy_count' => count($slots['busy_slots']),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Available slots retrieved',
                'facility' => [
                    'id' => $facility->id,
                    'name' => $facilityName,
                    'type' => $bookingType,
                ],
                'date' => $bookingDate,
                'interval_minutes' => $interval,
                'available_slots' => $slots['available_slots'],
                'busy_slots' => $slots['busy_slots'],
                'operating_hours' => $slots['operating_hours'],
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error getting available slots', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error getting available slots: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * ✅ NEW: Get facility bookings untuk hari tertentu (untuk lihat jadwal lengkap)
     *
     * Endpoint: GET /api/facilities/bookings/{type}/{id}/{date}
     * Contoh: GET /api/facilities/bookings/room/1/2024-03-15
     *
     * @param string $type room atau vehicle
     * @param int $id facility_id
     * @param string $date booking_date (YYYY-MM-DD)
     * @return \Illuminate\Http\JsonResponse
     */
    public function getFacilityBookingsByDate(Request $request, string $type, int $id, string $date)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        try {
            // Validate date format
            $bookingDate = Carbon::createFromFormat('Y-m-d', $date);

            // Validate facility exists
            if ($type === 'room') {
                $facility = Room::find($id);
                if (!$facility) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Room not found'
                    ], 404);
                }
            } elseif ($type === 'vehicle') {
                $facility = Vehicle::find($id);
                if (!$facility) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Vehicle not found'
                    ], 404);
                }
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid facility type'
                ], 422);
            }

            // Get approved bookings only
            $query = Booking::where('booking_type', $type)
                           ->where('booking_date', $date)
                           ->where('status', 'approved');

            if ($type === 'room') {
                $query->where('room_id', $id);
            } else {
                $query->where('vehicle_id', $id);
            }

            $bookings = $query->orderBy('start_time', 'asc')->get();

            // Format response dengan informasi yang detail
            $formattedBookings = $bookings->map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'booking_code' => $booking->booking_code,
                    'start_time' => $booking->start_time,
                    'end_time' => $booking->end_time,
                    'purpose' => $booking->purpose,
                    'user' => [
                        'id' => $booking->user_id,
                        'name' => $booking->user->name ?? 'Unknown',
                    ],
                    'participants_count' => $booking->participants_count,
                    'status' => $booking->status,
                ];
            })->toArray();

            \Log::info('📅 [getFacilityBookingsByDate] Retrieved bookings', [
                'type' => $type,
                'facility_id' => $id,
                'date' => $date,
                'bookings_count' => count($bookings),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Facility bookings retrieved',
                'facility' => [
                    'id' => $facility->id,
                    'name' => $facility->name,
                    'type' => $type,
                ],
                'date' => $date,
                'bookings' => $formattedBookings,
                'bookings_count' => count($bookings),
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error getting facility bookings', [
                'error' => $e->getMessage(),
                'type' => $type,
                'facility_id' => $id,
                'date' => $date,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error getting facility bookings: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Create new booking dengan validasi jadwal
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
            // ✅ VALIDATION: Check time slot availability
            $bookingData = [
                'booking_type' => $request->booking_type,
                'booking_date' => $request->booking_date,
                'start_time' => $request->start_time,
                'end_time' => $request->end_time,
                'room_id' => $request->booking_type === 'room' ? $request->room_id : null,
                'vehicle_id' => $request->booking_type === 'vehicle' ? $request->vehicle_id : null,
            ];

            $availabilityCheck = $this->isTimeSlotAvailable($bookingData);

            if (!$availabilityCheck['available']) {
                \Log::warning('⚠️ Time slot not available', [
                    'user_id' => $user->id,
                    'booking_type' => $request->booking_type,
                    'conflicts' => $availabilityCheck['conflicts'],
                ]);

                return response()->json([
                    'success' => false,
                    'message' => $availabilityCheck['message'],
                    'conflicts' => $availabilityCheck['conflicts'],
                    'error_code' => 'SLOT_NOT_AVAILABLE',
                ], 422);
            }

            // Generate booking code
            $bookingCode = date('Ymd') . strtoupper(substr(md5(uniqid()), 0, 4));

            // Prepare booking data
            $newBooking = [
                'user_id' => $user->id,
                'division_id' => $user->division_id,
                'booking_code' => $bookingCode,
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

            $booking = Booking::create($newBooking);

            \Log::info('✅ Booking created successfully (schedule validated)', [
                'booking_id' => $booking->id,
                'booking_code' => $bookingCode,
                'user_id' => $user->id,
                'booking_type' => $request->booking_type,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Booking created successfully and waiting for approval',
                'data' => $booking->toApiResponse(),
                'next_steps' => 'Booking sudah dikirim untuk persetujuan ke leader divisi Anda',
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

            \Log::info('✅ Available rooms retrieved', [
                'user_id' => $user->id,
                'rooms_count' => $rooms->count(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Available rooms retrieved',
                'data' => $rooms
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error retrieving rooms', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

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

            \Log::info('✅ Available vehicles retrieved', [
                'user_id' => $user->id,
                'vehicles_count' => $vehicles->count(),
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Available vehicles retrieved',
                'data' => $vehicles
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error retrieving vehicles', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error retrieving vehicles: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get all bookings (ROLE-BASED FILTERING)
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
            $query = Booking::query();

            if ($user->role === 'employee') {
                $query->where('user_id', $user->id);
            }
            elseif ($user->role === 'head_division') {
                $query->where('division_id', $user->division_id);
            }
            elseif ($user->role !== 'admin' && $user->role !== 'divum_admin') {
                $query->where('user_id', $user->id);
            }

            $bookings = $query->orderBy('booking_date', 'desc')->get();

            return response()->json([
                'success' => true,
                'message' => 'Bookings retrieved successfully',
                'data' => $bookings,
                'count' => $bookings->count(),
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error retrieving bookings', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
            ]);

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

            return response()->json([
                'success' => true,
                'data' => $booking
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error retrieving booking', [
                'error' => $e->getMessage(),
                'user_id' => $user->id,
                'booking_id' => $id,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error retrieving booking: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Approve booking by Division Leader
     */
    public function approveDivision(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user || $user->role !== 'head_division') {
            return response()->json([
                'success' => false,
                'message' => 'Only division leaders can approve'
            ], 403);
        }

        try {
            $booking = Booking::findOrFail($id);

            if ($booking->division_id !== $user->division_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized to approve this booking'
                ], 403);
            }

            if ($booking->status !== 'pending_division') {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be approved in current status: ' . $booking->status
                ], 400);
            }

            $action = $request->input('action');
            $notes = $request->input('notes', '');

            if ($action === 'approve') {
                $booking->update([
                    'status' => 'pending_ga',
                    'division_approval_by' => $user->id,
                    'division_approval_at' => now(),
                    'division_approval_notes' => $notes,
                ]);
            } elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_division',
                    'division_approval_by' => $user->id,
                    'division_approval_at' => now(),
                    'division_approval_notes' => $notes,
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid action'
                ], 400);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking ' . ($action === 'approve' ? 'approved' : 'rejected') . ' successfully',
                'data' => $booking,
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error in approveDivision: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Approve booking by GA/Admin
     */
    public function approveDivum(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user || ($user->role !== 'admin' && $user->role !== 'divum_admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can approve'
            ], 403);
        }

        try {
            $booking = Booking::findOrFail($id);

            if ($booking->status !== 'pending_ga') {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be approved in current status: ' . $booking->status
                ], 400);
            }

            $action = $request->input('action');
            $notes = $request->input('notes', '');

            if ($action === 'approve') {
                $booking->update([
                    'status' => 'approved',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
            } elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_ga',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid action'
                ], 400);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking ' . ($action === 'approve' ? 'approved' : 'rejected') . ' successfully',
                'data' => $booking,
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error in approveDivum: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}

