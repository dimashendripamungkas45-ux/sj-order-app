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
    // ...existing code (store, getAvailableRooms, getAvailableVehicles, index, show)...

    /**
     * Approve booking by Division Leader (Step 1)
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

            // Check permission - hanya leader di divisi yang sama
            if ($booking->division_id !== $user->division_id) {
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
                \Log::info('✅ [approveDivision] Rejected - status is now rejected_division');
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid action'
                ], 400);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking ' . ($action === 'approve' ? 'approved' : 'rejected') . ' successfully',
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
     * Approve booking by GA/Admin (Step 2)
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

            // Check status
            if ($booking->status !== 'pending_ga') {
                return response()->json([
                    'success' => false,
                    'message' => 'Booking cannot be approved in current status: ' . $booking->status
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
                \Log::info('✅ [approveDivum] Approved - status is now approved');
            } elseif ($action === 'reject') {
                $booking->update([
                    'status' => 'rejected_ga',
                    'ga_approval_by' => $user->id,
                    'ga_approval_at' => now(),
                    'ga_approval_notes' => $notes,
                ]);
                \Log::info('✅ [approveDivum] Rejected - status is now rejected_ga');
            } else {
                return response()->json([
                    'success' => false,
                    'message' => 'Invalid action'
                ], 400);
            }

            return response()->json([
                'success' => true,
                'message' => 'Booking ' . ($action === 'approve' ? 'approved' : 'rejected') . ' successfully',
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

    /**
     * Get authenticated user safely with fallback
     */
    private function getAuthUser()
    {
        try {
            $user = auth('sanctum')->user();
            if ($user) {
                return $user;
            }
        } catch (\Exception $e) {
            // Fallback
        }

        try {
            $user = auth('api')->user();
            if ($user) {
                return $user;
            }
        } catch (\Exception $e) {
            // Fallback
        }

        return auth()->user();
    }
}

