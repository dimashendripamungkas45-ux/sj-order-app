<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Room;
use App\Models\Vehicle;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
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
                \Log::info('✅ User authenticated via Sanctum', ['user_id' => $user->id, 'role' => $user->role]);
                return $user;
            }
        } catch (\Exception $e) {
            \Log::warning('⚠️ Sanctum auth failed', ['error' => $e->getMessage()]);
        }

        try {
            $user = auth('api')->user();
            if ($user) {
                \Log::info('✅ User authenticated via api guard', ['user_id' => $user->id, 'role' => $user->role]);
                return $user;
            }
        } catch (\Exception $e) {
            \Log::warning('⚠️ API guard auth failed', ['error' => $e->getMessage()]);
        }

        $user = auth()->user();
        if ($user) {
            \Log::info('✅ User authenticated via default guard', ['user_id' => $user->id, 'role' => $user->role]);
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
     * Get all bookings (ROLE-BASED FILTERING)
     *
     * ✅ Employee (employee): hanya booking miliknya
     * ✅ Leader (head_division): semua booking di divisinya
     * ✅ Admin (admin/divum_admin): SEMUA booking di sistem
     */
    public function index(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            \Log::error('❌ No authenticated user');
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        try {
            \Log::info('📥 [BookingController.index] START', [
                'user_id' => $user->id,
                'user_name' => $user->name,
                'user_role' => $user->role,
                'user_division_id' => $user->division_id ?? 'NULL',
            ]);

            // ✅ PENTING: Mulai dengan query kosong
            $query = Booking::query();

            // ✅ ROLE-BASED FILTERING
            if ($user->role === 'employee') {
                // 👤 Employee: hanya booking miliknya sendiri
                \Log::info('📊 [BookingController.index] Mode: EMPLOYEE', ['user_id' => $user->id]);
                $query->where('user_id', $user->id);
            }
            elseif ($user->role === 'head_division') {
                // 🏢 Leader Divisi: semua booking di divisinya
                \Log::info('📊 [BookingController.index] Mode: LEADER_DIVISION', ['division_id' => $user->division_id]);
                $query->where('division_id', $user->division_id);
            }
            elseif ($user->role === 'admin' || $user->role === 'divum_admin') {
                // 🔐 Admin/GA: SEMUA booking (NO FILTER)
                \Log::info('📊 [BookingController.index] Mode: ADMIN - SHOWING ALL BOOKINGS');
                // ✅ PENTING: Tidak ada filter untuk admin!
            }
            else {
                // Default: hanya booking miliknya
                \Log::info('📊 [BookingController.index] Mode: DEFAULT', ['user_id' => $user->id]);
                $query->where('user_id', $user->id);
            }

            // ✅ Eksekusi query dan sort
            $bookings = $query->orderBy('booking_date', 'desc')->get();

            \Log::info('✅ [BookingController.index] Query executed', [
                'total_count' => $bookings->count(),
                'role' => $user->role,
            ]);

            // ✅ Map ke format API response
            $mappedBookings = $bookings->map(function($booking) {
                return [
                    'id' => $booking->id,
                    'booking_code' => $booking->booking_code,
                    'user_id' => $booking->user_id,
                    'division_id' => $booking->division_id,
                    'booking_type' => $booking->booking_type,
                    'room_id' => $booking->room_id,
                    'vehicle_id' => $booking->vehicle_id,
                    'booking_date' => $booking->booking_date,
                    'start_time' => $booking->start_time,
                    'end_time' => $booking->end_time,
                    'purpose' => $booking->purpose,
                    'participants_count' => $booking->participants_count,
                    'destination' => $booking->destination,
                    'status' => $booking->status,
                    'division_approval_by' => $booking->division_approval_by,
                    'division_approval_at' => $booking->division_approval_at,
                    'division_approval_notes' => $booking->division_approval_notes,
                    'ga_approval_by' => $booking->ga_approval_by,
                    'ga_approval_at' => $booking->ga_approval_at,
                    'ga_approval_notes' => $booking->ga_approval_notes,
                    'rejection_reason' => $booking->rejection_reason,
                    'created_at' => $booking->created_at,
                    'updated_at' => $booking->updated_at,
                ];
            });

            \Log::info('✅ [BookingController.index] RESPONSE SUCCESS', [
                'bookings_count' => $mappedBookings->count(),
                'user_role' => $user->role,
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Bookings retrieved successfully',
                'data' => $mappedBookings,
                'count' => $mappedBookings->count(),
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ [BookingController.index] ERROR', [
                'error_message' => $e->getMessage(),
                'error_file' => $e->getFile(),
                'error_line' => $e->getLine(),
                'user_id' => $user->id,
                'user_role' => $user->role,
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error retrieving bookings: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Create new booking
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
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Booking created successfully',
                'data' => $booking
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
     * Get available rooms
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
            \Log::error('❌ Error retrieving rooms: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Error retrieving rooms: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get available vehicles
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
            \Log::error('❌ Error retrieving vehicles: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Error retrieving vehicles: ' . $e->getMessage()
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

            // Check permission
            if ($booking->user_id !== $user->id && $user->role === 'employee') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized'
                ], 403);
            }

            return response()->json([
                'success' => true,
                'data' => $booking
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
     * ✅ Approve booking by Division Leader (Step 1)
     * Status: pending_division → pending_ga
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
     * ✅ Approve booking by GA/Admin (Step 2 - FINAL)
     * Status: pending_ga → approved or rejected_ga
     */
    public function approveDivum(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user || ($user->role !== 'admin' && $user->role !== 'divum_admin')) {
            \Log::warning('❌ Unauthorized user trying to approve', [
                'user_role' => $user->role ?? 'NULL',
                'booking_id' => $id,
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Only admins can approve'
            ], 403);
        }

        try {
            $booking = Booking::findOrFail($id);

            if ($booking->status !== 'pending_ga') {
                \Log::warning('❌ Cannot approve booking not in pending_ga status', [
                    'booking_id' => $id,
                    'current_status' => $booking->status,
                ]);
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be approved in current status: ' . $booking->status
                ], 400);
            }

            $action = $request->input('action');
            $notes = $request->input('notes', '');

            \Log::info('📋 [approveDivum] Processing', [
                'booking_code' => $booking->booking_code,
                'action' => $action,
                'admin_id' => $user->id,
            ]);

            if ($action === 'approve') {
                $booking->update([
                    'status' => 'approved',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivum] Approved', ['booking_code' => $booking->booking_code]);
            } elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_ga',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivum] Rejected', ['booking_code' => $booking->booking_code]);
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

