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
     * Format booking untuk API response
     * Ensure semua field yang dibutuhkan Flutter tersedia
     */
    private function formatBooking(Booking $booking)
    {
        return [
            'id' => $booking->id,
            'booking_code' => $booking->booking_code,
            'booking_type' => $booking->booking_type,
            'purpose' => $booking->purpose,
            'booking_date' => $booking->booking_date,
            'start_time' => $booking->start_time,
            'end_time' => $booking->end_time,
            'status' => $booking->status,
            'room_id' => $booking->room_id,
            'vehicle_id' => $booking->vehicle_id,
            'participants_count' => $booking->participants_count,
            'destination' => $booking->destination,
            'division_approval_notes' => $booking->division_approval_notes,
            'ga_approval_notes' => $booking->ga_approval_notes,
            'division_approval_by' => $booking->division_approval_by,
            'ga_approval_by' => $booking->ga_approval_by,
            'created_at' => $booking->created_at,
            'updated_at' => $booking->updated_at,
        ];
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

            \Log::info('✅ Booking created', ['booking_id' => $booking->id]);

            return response()->json([
                'success' => true,
                'message' => 'Booking created successfully',
                'data' => $this->formatBooking($booking)
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
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
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
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
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
     * ✅ Get all bookings - ROLE-BASED FILTERING
     *
     * ✅ Employee: hanya booking miliknya
     * ✅ Leader: semua booking di divisinya
     * ✅ Admin: SEMUA booking di sistem
     *
     * 🔧 FIXED: Consistent response format + Proper logging
     */
    public function index(Request $request)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            \Log::error('❌ [BookingController.index] Unauthorized - no user');
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        try {
            \Log::info('📥 [BookingController.index] START');
            \Log::info('   User: ' . $user->name);
            \Log::info('   Role: ' . $user->role);
            \Log::info('   Division ID: ' . $user->division_id);

            $query = Booking::query();

            // ✅ ROLE-BASED FILTERING
            if ($user->role === 'employee') {
                \Log::info('   Mode: EMPLOYEE (showing own bookings)');
                $query->where('user_id', $user->id);
            }
            elseif ($user->role === 'head_division') {
                \Log::info('   Mode: LEADER (showing division bookings)');
                $query->where('division_id', $user->division_id);
            }
            elseif ($user->role === 'admin' || $user->role === 'divum_admin') {
                \Log::info('   Mode: ADMIN (showing ALL bookings)');
                // No filter - show all
            }
            else {
                \Log::info('   Mode: DEFAULT (showing own bookings)');
                $query->where('user_id', $user->id);
            }

            $bookings = $query->orderBy('booking_date', 'desc')
                             ->orderBy('created_at', 'desc')
                             ->get();

            // ✅ Format setiap booking
            $formattedBookings = $bookings->map(function ($booking) {
                return $this->formatBooking($booking);
            })->toArray();

            \Log::info('✅ [BookingController.index] Success');
            \Log::info('   Total bookings: ' . count($formattedBookings));

            // ✅ STANDARDIZED RESPONSE FORMAT
            return response()->json([
                'success' => true,
                'message' => 'Bookings retrieved successfully',
                'data' => $formattedBookings,  // ← Array of formatted bookings
                'count' => count($formattedBookings),
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ [BookingController.index] Error: ' . $e->getMessage());
            \Log::error('   Stack: ' . $e->getTraceAsString());

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
            return response()->json(['success' => false, 'message' => 'Unauthorized'], 401);
        }

        try {
            \Log::info('📥 [BookingController.show] ID: ' . $id);

            $booking = Booking::find($id);

            if (!$booking) {
                \Log::warning('⚠️ Booking not found: ' . $id);
                return response()->json(['success' => false, 'message' => 'Booking not found'], 404);
            }

            // Check permission
            if ($booking->user_id !== $user->id && $user->role === 'employee') {
                \Log::warning('⚠️ Unauthorized access to booking: ' . $id);
                return response()->json(['success' => false, 'message' => 'Unauthorized'], 403);
            }

            \Log::info('✅ Booking detail retrieved');

            return response()->json([
                'success' => true,
                'data' => $this->formatBooking($booking)
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
     *
     * Status: pending_division → pending_ga (approve) atau rejected_division (reject)
     * Role: head_division
     */
    public function approveDivision(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user || $user->role !== 'head_division') {
            \Log::warning('⚠️ Unauthorized approval attempt');
            return response()->json([
                'success' => false,
                'message' => 'Only division leaders can approve'
            ], 403);
        }

        try {
            $booking = Booking::findOrFail($id);

            // Check permission
            if ($booking->division_id !== $user->division_id) {
                \Log::warning('⚠️ Unauthorized to approve booking: ' . $id);
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized to approve this booking'
                ], 403);
            }

            // Check status
            if ($booking->status !== 'pending_division') {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be approved in current status: ' . $booking->status
                ], 400);
            }

            $action = $request->input('action');
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
            } elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_division',
                    'division_approval_by' => $user->id,
                    'division_approval_at' => now(),
                    'division_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivision] Rejected');
            } else {
                return response()->json(['success' => false, 'message' => 'Invalid action'], 400);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking ' . ($action === 'approve' ? 'approved' : 'rejected') . ' successfully',
                'data' => $this->formatBooking($booking),
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
     * ✅ Approve booking by GA/Admin (Step 2 - FINAL APPROVAL)
     *
     * Status: pending_ga → approved (approve) atau rejected_ga (reject)
     * Role: admin, divum_admin, atau admin_ga
     *
     * 🔧 FIXED: Recognize admin_ga role as admin
     */
    public function approveDivum(Request $request, $id)
    {
        $user = $this->getAuthUser();

        // ✅ FIXED: Recognize admin_ga as admin role
        $isAdmin = $user && (
            $user->role === 'admin' ||
            $user->role === 'divum_admin' ||
            $user->role === 'admin_ga'
        );

        if (!$isAdmin) {
            \Log::warning('⚠️ Unauthorized approval attempt by: ' . ($user ? $user->name . ' (' . $user->role . ')' : 'unknown'));
            return response()->json([
                'success' => false,
                'message' => 'Only admins can approve'
            ], 403);
        }

        try {
            \Log::info('📋 [approveDivum] START - Admin: ' . $user->name . ' (Role: ' . $user->role . ')');
            \Log::info('   Booking ID: ' . $id);

            $booking = Booking::findOrFail($id);

            \Log::info('   Booking Code: ' . $booking->booking_code);
            \Log::info('   Current Status: ' . $booking->status);

            // Check status
            if ($booking->status !== 'pending_ga') {
                \Log::warning('⚠️ Invalid status for approval: ' . $booking->status);
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be approved in current status: ' . $booking->status
                ], 400);
            }

            $action = $request->input('action');
            $notes = $request->input('notes', '');

            \Log::info('   Action: ' . $action);
            \Log::info('   Notes: ' . ($notes ? substr($notes, 0, 50) . '...' : '(empty)'));

            if ($action === 'approve') {
                $booking->update([
                    'status' => 'approved',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivum] APPROVED - FINAL!');
            } elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_ga',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivum] REJECTED');
            } else {
                return response()->json(['success' => false, 'message' => 'Invalid action'], 400);
            }

            // Refresh dari database untuk ensure consistency
            $booking->refresh();

            return response()->json([
                'success' => true,
                'message' => 'Booking ' . ($action === 'approve' ? 'approved' : 'rejected') . ' successfully',
                'data' => $this->formatBooking($booking),
            ], 200);

        } catch (\Exception $e) {
            \Log::error('❌ Error in approveDivum: ' . $e->getMessage());
            \Log::error('   Stack: ' . $e->getTraceAsString());

            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}

