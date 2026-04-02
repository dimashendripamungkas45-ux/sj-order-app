<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\User;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    /**
     * Get all bookings (role-based filtering)
     * - Employee: hanya booking miliknya
     * - Leader: semua booking di divisinya
     * - Admin: semua booking di sistem
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

        \Log::info('📥 [BookingController.index] User: ' . $user->name . ' (Role: ' . $user->role . ')');
        \Log::info('📥 [BookingController.index] Division ID: ' . $user->division_id);

        $query = Booking::query();

        // Role-based filtering
        if ($user->role === 'employee') {
            // Employee: lihat hanya booking miliknya
            \Log::info('📊 [BookingController.index] Employee mode - filter by user_id: ' . $user->id);
            $query->where('user_id', $user->id);
        } elseif ($user->role === 'head_division') {
            // Leader Divisi: lihat semua booking di divisinya yang sudah masuk sistem
            // Booking yang masuk adalah yang dibuat oleh employee di divisi yang sama
            \Log::info('📊 [BookingController.index] Leader mode - filter by division_id: ' . $user->division_id);
            $query->whereHas('user', function($q) use ($user) {
                $q->where('division_id', $user->division_id);
            });
        } elseif ($user->role === 'admin' || $user->role === 'divum_admin') {
            // Admin/GA: lihat semua booking
            \Log::info('📊 [BookingController.index] Admin mode - showing all bookings');
            // No filter - show all
        } else {
            // Default: hanya booking miliknya
            \Log::info('📊 [BookingController.index] Default mode - filter by user_id: ' . $user->id);
            $query->where('user_id', $user->id);
        }

        $bookings = $query->orderBy('created_at', 'desc')->get();

        \Log::info('✅ [BookingController.index] Found ' . $bookings->count() . ' bookings');

        // Map ke format yang diharapkan
        $mappedBookings = $bookings->map(function($booking) {
            return [
                'id' => $booking->id,
                'booking_code' => $booking->booking_code,
                'user_id' => $booking->user_id,
                'division_id' => $booking->division_id,
                'booking_type' => $booking->booking_type, // 'room' atau 'vehicle'
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

        return response()->json([
            'success' => true,
            'message' => 'Bookings retrieved successfully',
            'data' => $mappedBookings,
            'count' => $mappedBookings->count(),
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

        $booking = Booking::findOrFail($id);

        // Check permission
        $canView = false;
        if ($user->role === 'employee' && $booking->user_id === $user->id) {
            $canView = true;
        } elseif ($user->role === 'head_division' && $booking->user->division_id === $user->division_id) {
            $canView = true;
        } elseif ($user->role === 'admin' || $user->role === 'divum_admin') {
            $canView = true;
        }

        if (!$canView) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to view this booking'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => [
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
            ]
        ], 200);
    }

    /**
     * Create new booking
     */
    public function store(Request $request)
    {
        $user = auth('api')->user();

        if (!$user || $user->role !== 'employee') {
            return response()->json([
                'success' => false,
                'message' => 'Only employees can create bookings'
            ], 403);
        }

        $validated = $request->validate([
            'booking_type' => 'required|in:room,vehicle',
            'room_id' => 'nullable|integer|exists:rooms,id',
            'vehicle_id' => 'nullable|integer|exists:vehicles,id',
            'booking_date' => 'required|date',
            'start_time' => 'required|date_format:H:i:s',
            'end_time' => 'required|date_format:H:i:s|after:start_time',
            'purpose' => 'required|string|max:255',
            'participants_count' => 'nullable|integer|min:1',
            'destination' => 'nullable|string|max:255',
        ]);

        // Generate booking code
        $bookingCode = $this->generateBookingCode();

        $booking = Booking::create([
            'booking_code' => $bookingCode,
            'user_id' => $user->id,
            'division_id' => $user->division_id,
            'booking_type' => $validated['booking_type'],
            'room_id' => $validated['room_id'] ?? null,
            'vehicle_id' => $validated['vehicle_id'] ?? null,
            'booking_date' => $validated['booking_date'],
            'start_time' => $validated['start_time'],
            'end_time' => $validated['end_time'],
            'purpose' => $validated['purpose'],
            'participants_count' => $validated['participants_count'] ?? 0,
            'destination' => $validated['destination'] ?? null,
            'status' => 'pending_division', // First status
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully',
            'data' => $booking,
        ], 201);
    }

    /**
     * Approve booking by Division Leader (Step 1)
     */
    public function approveDivision(Request $request, $id)
    {
        $user = auth('api')->user();

        if (!$user || $user->role !== 'head_division') {
            return response()->json([
                'success' => false,
                'message' => 'Only division leaders can approve'
            ], 403);
        }

        $booking = Booking::findOrFail($id);

        // Check permission - hanya leader di divisi yang sama
        if ($booking->user->division_id !== $user->division_id) {
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

        $action = $request->input('action'); // 'approve' atau 'reject'
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
            'message' => 'Booking ' . $action . 'ed successfully',
            'data' => $booking,
        ], 200);
    }

    /**
     * Approve booking by GA/Admin (Step 2)
     */
    public function approveDivum(Request $request, $id)
    {
        $user = auth('api')->user();

        if (!$user || ($user->role !== 'admin' && $user->role !== 'divum_admin')) {
            return response()->json([
                'success' => false,
                'message' => 'Only admins can approve'
            ], 403);
        }

        $booking = Booking::findOrFail($id);

        // Check status
        if ($booking->status !== 'pending_ga') {
            return response()->json([
                'success' => false,
                'message' => 'Booking cannot be approved in current status: ' . $booking->status
            ], 400);
        }

        $action = $request->input('action'); // 'approve' atau 'reject'
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
            'message' => 'Booking ' . $action . 'ed successfully',
            'data' => $booking,
        ], 200);
    }

    /**
     * Generate unique booking code
     */
    private function generateBookingCode()
    {
        $date = date('Ymd');
        $random = strtoupper(substr(md5(uniqid()), 0, 4));
        return $date . $random;
    }
}

