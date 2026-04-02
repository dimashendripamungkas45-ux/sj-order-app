<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Carbon\Carbon;

class BookingApprovalController extends Controller
{
    /**
     * Get authenticated user safely
     */
    private function getAuthUser()
    {
        $user = auth('sanctum')->user();
        if ($user) {
            \Log::info('✅ User authenticated via Sanctum', ['user_id' => $user->id]);
            return $user;
        }

        $user = auth('api')->user();
        if ($user) {
            \Log::info('✅ User authenticated via api guard', ['user_id' => $user->id]);
            return $user;
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
     * TAHAP 1: Pimpinan Divisi - Approve atau Reject Pemesanan
     *
     * Transisi Status:
     * - APPROVE: pending_division → pending_ga
     * - REJECT: pending_division → rejected_division
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

        // Check role
        if ($user->role !== 'head_division' && $user->role !== 'pimpinan_divisi') {
            \Log::error('❌ User tidak memiliki role pimpinan_divisi', [
                'user_id' => $user->id,
                'role' => $user->role
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Only division leaders can approve bookings'
            ], 403);
        }

        // Find booking
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Check booking status
        if ($booking->status !== 'pending_division') {
            \Log::error('❌ Booking status tidak pending_division', [
                'booking_id' => $id,
                'current_status' => $booking->status
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Booking cannot be approved at this stage. Current status: ' . $booking->status
            ], 422);
        }

        // Check division ownership
        if ($booking->division_id !== $user->division_id) {
            \Log::error('❌ User tidak dari divisi booking', [
                'user_division' => $user->division_id,
                'booking_division' => $booking->division_id
            ]);
            return response()->json([
                'success' => false,
                'message' => 'You can only approve bookings from your division'
            ], 403);
        }

        // Validate request
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
                // APPROVE: Change to pending_ga (untuk review GA)
                $booking->update([
                    'status' => 'pending_ga',
                    'division_approval_by' => $user->id,
                    'division_approval_at' => Carbon::now(),
                    'division_approval_notes' => $request->notes ?? '',
                ]);

                \Log::info('✅ Booking approved by division leader', [
                    'booking_id' => $id,
                    'approved_by' => $user->id,
                    'new_status' => 'pending_ga'
                ]);

                $message = '✅ Booking disetujui & diteruskan ke GA';
            } else {
                // REJECT: Change to rejected_division
                $booking->update([
                    'status' => 'rejected_division',
                    'division_approval_by' => $user->id,
                    'division_approval_at' => Carbon::now(),
                    'division_approval_notes' => $request->notes ?? '',
                    'rejection_reason' => $request->notes ?? 'Ditolak oleh pimpinan divisi',
                ]);

                \Log::info('❌ Booking rejected by division leader', [
                    'booking_id' => $id,
                    'rejected_by' => $user->id,
                    'reason' => $request->notes
                ]);

                $message = '❌ Booking ditolak oleh pimpinan divisi';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => [
                    'id' => $booking->id,
                    'bookingCode' => $booking->booking_code,
                    'status' => $booking->status,
                    'division_approval_by' => $booking->division_approval_by,
                    'division_approval_at' => $booking->division_approval_at,
                    'division_approval_notes' => $booking->division_approval_notes,
                ]
            ], 200);
        } catch (\Exception $e) {
            \Log::error('💥 Error in approveDivision', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * TAHAP 2: Admin GA/DIVUM - Final Approve atau Reject Pemesanan
     *
     * Transisi Status:
     * - APPROVE: pending_ga → approved (FINAL!)
     * - REJECT: pending_ga → rejected_ga
     */
    public function approveGA(Request $request, $id)
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        // Check role - Admin GA or Admin DIVUM
        if ($user->role !== 'admin_ga' && $user->role !== 'admin_divum') {
            \Log::error('❌ User tidak memiliki role admin_ga', [
                'user_id' => $user->id,
                'role' => $user->role
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Only GA admin can give final approval'
            ], 403);
        }

        // Find booking
        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Check booking status - must be pending_ga
        if ($booking->status !== 'pending_ga') {
            \Log::error('❌ Booking status tidak pending_ga', [
                'booking_id' => $id,
                'current_status' => $booking->status
            ]);
            return response()->json([
                'success' => false,
                'message' => 'Booking cannot be approved at this stage. Current status: ' . $booking->status
            ], 422);
        }

        // Validate request
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
                // FINAL APPROVE: Change to approved (DONE!)
                $booking->update([
                    'status' => 'approved',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => Carbon::now(),
                    'ga_approval_notes' => $request->notes ?? '',
                ]);

                \Log::info('✅ Booking FINAL APPROVED by GA admin', [
                    'booking_id' => $id,
                    'approved_by' => $user->id,
                    'new_status' => 'approved'
                ]);

                $message = '✅ Booking DISETUJUI FINAL oleh GA!';
            } else {
                // REJECT: Change to rejected_ga
                $booking->update([
                    'status' => 'rejected_ga',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => Carbon::now(),
                    'ga_approval_notes' => $request->notes ?? '',
                    'rejection_reason' => $request->notes ?? 'Ditolak oleh GA admin',
                ]);

                \Log::info('❌ Booking rejected by GA admin', [
                    'booking_id' => $id,
                    'rejected_by' => $user->id,
                    'reason' => $request->notes
                ]);

                $message = '❌ Booking ditolak oleh GA admin';
            }

            return response()->json([
                'success' => true,
                'message' => $message,
                'data' => [
                    'id' => $booking->id,
                    'bookingCode' => $booking->booking_code,
                    'status' => $booking->status,
                    'ga_approval_by' => $booking->ga_approval_by,
                    'ga_approval_at' => $booking->ga_approval_at,
                    'ga_approval_notes' => $booking->ga_approval_notes,
                ]
            ], 200);
        } catch (\Exception $e) {
            \Log::error('💥 Error in approveGA', [
                'error' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine()
            ]);

            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get pending approvals untuk dashboard pimpinan divisi
     */
    public function getPendingDivision()
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        if ($user->role !== 'head_division' && $user->role !== 'pimpinan_divisi') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        try {
            $bookings = Booking::where('division_id', $user->division_id)
                ->where('status', 'pending_division')
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $bookings,
                'count' => $bookings->count()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Get pending GA approvals untuk dashboard admin GA
     */
    public function getPendingGA()
    {
        $user = $this->getAuthUser();

        if (!$user) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 401);
        }

        if ($user->role !== 'admin_ga' && $user->role !== 'admin_divum') {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        try {
            $bookings = Booking::where('status', 'pending_ga')
                ->orderBy('created_at', 'desc')
                ->get();

            return response()->json([
                'success' => true,
                'data' => $bookings,
                'count' => $bookings->count()
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}

