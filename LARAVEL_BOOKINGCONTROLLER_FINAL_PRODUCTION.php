<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Room;
use App\Models\Vehicle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

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

        \Log::error('❌ No user authenticated');
        return null;
    }

    /**
     * ✅ Create new booking
     * Endpoint: POST /api/bookings
     * Role: employee, head_division, admin
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
            $bookingCode = date('Ymd') . strtoupper(substr(md5(uniqid()), 0, 4));

            $bookingData = [
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

            $booking = Booking::create($bookingData);

            \Log::info('✅ Booking created', [
                'booking_id' => $booking->id,
                'booking_code' => $bookingCode,
                'user_id' => $user->id,
                'division_id' => $user->division_id,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Booking created successfully',
                'data' => $booking->toArray()
            ], 201);

        } catch (\Exception $e) {
            \Log::error('❌ Error creating booking: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error creating booking: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * ✅ Get available rooms
     * Endpoint: GET /api/available-rooms
     * Role: All authenticated users
     */
    public function getAvailableRooms(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
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
            \Log::error('❌ Error retrieving rooms: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving rooms: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * ✅ Get available vehicles
     * Endpoint: GET /api/available-vehicles
     * Role: All authenticated users
     */
    public function getAvailableVehicles(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
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
            \Log::error('❌ Error retrieving vehicles: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving vehicles: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * ✅✅✅ THE FIX: Get all bookings - ROLE-BASED FILTERING ✅✅✅
     *
     * Endpoint: GET /api/bookings
     *
     * ✅ Employee: hanya booking miliknya sendiri
     * ✅ Leader Division (head_division): semua booking di divisinya
     * ✅ Admin/GA (admin, divum_admin): SEMUA booking di sistem
     *
     * THIS IS THE CRITICAL FIX FOR ADMIN DASHBOARD!
     */
    public function index(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            \Log::info('📥 [BookingController.index] User: ' . $user->name . ' (Role: ' . $user->role . ')');
            \Log::info('📥 [BookingController.index] Division ID: ' . ($user->division_id ?? 'NULL'));

            $query = Booking::query();

            // ✅✅✅ ROLE-BASED FILTERING - THE CRITICAL FIX! ✅✅✅
            if ($user->role === 'employee') {
                // 👤 EMPLOYEE: hanya booking miliknya sendiri
                \Log::info('📊 [BookingController.index] Mode: EMPLOYEE - showing only own bookings');
                $query->where('user_id', $user->id);
            }
            elseif ($user->role === 'head_division') {
                // 👔 LEADER DIVISI: semua booking di divisinya
                \Log::info('📊 [BookingController.index] Mode: LEADER DIVISION - showing division bookings');
                $query->where('division_id', $user->division_id);
            }
            elseif ($user->role === 'admin' || $user->role === 'divum_admin') {
                // 👨‍💼 ADMIN/GA: LIHAT SEMUA BOOKING (NO FILTER!)
                // This is the fix - no filter applied for admin
                \Log::info('📊 [BookingController.index] Mode: ADMIN - showing ALL bookings');
                // ✅ PENTING: Tidak ada filter untuk admin! Query berjalan normal
            }
            else {
                // Default: hanya booking miliknya
                \Log::info('📊 [BookingController.index] Mode: DEFAULT - showing own bookings');
                $query->where('user_id', $user->id);
            }

            // Get bookings
            $bookings = $query->orderBy('booking_date', 'desc')->get();

            \Log::info('✅ [BookingController.index] Found ' . $bookings->count() . ' bookings');

            return response()->json([
                'success' => true,
                'message' => 'Bookings retrieved successfully',
                'data' => $bookings,
                'count' => $bookings->count(),
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error retrieving bookings: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving bookings: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * ✅ Get single booking detail
     * Endpoint: GET /api/bookings/{id}
     *
     * Permissions:
     * - Employee: hanya booking milik sendiri
     * - Leader: booking di divisinya
     * - Admin: semua booking
     */
    public function show($id)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            $booking = Booking::find($id);

            if (!$booking) {
                return response()->json(['success' => false, 'message' => 'Booking not found'], 404);
            }

            // ✅ PERMISSION CHECK
            if ($user->role === 'employee' && $booking->user_id !== $user->id) {
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
            }

            if ($user->role === 'head_division' && $booking->division_id !== $user->division_id) {
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
            }

            // Admin dapat melihat semua

            \Log::info('✅ Booking detail retrieved', ['booking_id' => $booking->id, 'user_id' => $user->id]);

            return response()->json([
                'success' => true,
                'data' => $booking->toArray()
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error retrieving booking: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error retrieving booking: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * ✅ Approve booking by Division Leader (STEP 1 APPROVAL)
     *
     * Endpoint: PUT /api/bookings/{id}/approve-division
     * Role: head_division
     *
     * Flow:
     * pending_division ──[LEADER APPROVES]──> pending_ga (tunggu admin)
     * pending_division ──[LEADER REJECTS]──> rejected_division (selesai)
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

            // ✅ Check permission - hanya leader di divisi yang sama
            if ($booking->division_id !== $user->division_id) {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized to approve this booking'
                ], 403);
            }

            // ✅ Check status - hanya pending_division yang bisa di-approve
            if ($booking->status !== 'pending_division') {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be approved. Current status: ' . $booking->status
                ], 400);
            }

            $action = $request->input('action'); // 'approve' atau 'reject'
            $notes = $request->input('notes', '');

            \Log::info('📋 [approveDivision] Booking: ' . $booking->booking_code . ', Action: ' . $action);

            if ($action === 'approve') {
                $booking->update([
                    'status' => 'pending_ga',
                    'division_approval_by' => $user->id,
                    'division_approval_at' => now(),
                    'division_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivision] Approved - moved to pending_ga');
                $message = 'Booking approved and moved to GA for final approval';
            }
            elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_division',
                    'division_approval_by' => $user->id,
                    'division_approval_at' => now(),
                    'division_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivision] Rejected');
                $message = 'Booking rejected by division leader';
            }
            else {
                return response()->json(['success' => false, 'message' => 'Invalid action'], 400);
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => $booking->toArray(),
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
     * ✅ Approve booking by GA/Admin (STEP 2 APPROVAL - FINAL!)
     *
     * Endpoint: PUT /api/bookings/{id}/approve-divum
     * Role: admin, divum_admin
     *
     * Flow:
     * pending_ga ──[ADMIN APPROVES]──> approved (FINAL - SELESAI!)
     * pending_ga ──[ADMIN REJECTS]──> rejected_ga (selesai)
     */
    public function approveDivum(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user || ($user->role !== 'admin' && $user->role !== 'divum_admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can do final approval'
            ], 403);
        }

        try {
            $booking = Booking::findOrFail($id);

            // ✅ Check status - hanya pending_ga yang bisa di-final-approve
            if ($booking->status !== 'pending_ga') {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be final approved. Current status: ' . $booking->status
                ], 400);
            }

            $action = $request->input('action'); // 'approve' atau 'reject'
            $notes = $request->input('notes', '');

            \Log::info('📋 [approveDivum] Booking: ' . $booking->booking_code . ', Action: ' . $action);

            if ($action === 'approve') {
                $booking->update([
                    'status' => 'approved',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivum] FINAL APPROVED - Booking is now APPROVED!');
                $message = '✅ Booking FINAL APPROVED and confirmed!';
            }
            elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_ga',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivum] REJECTED by GA');
                $message = 'Booking rejected by GA/Admin';
            }
            else {
                return response()->json(['success' => false, 'message' => 'Invalid action'], 400);
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => $booking->toArray(),
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

