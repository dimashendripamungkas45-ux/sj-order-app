<?php
/**
 * ✅ BACKEND FIX - BookingController.php
 *
 * MASALAH: Aplikasi tidak menampilkan data pemesanan di Admin Dashboard
 * PENYEBAB: Method index() hanya return bookings milik user yang login
 * SOLUSI: Update method index() dengan ROLE-BASED filtering
 */

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use Illuminate\Http\Request;

class BookingController extends Controller
{
    /**
     * ✅ FIXED: Get all bookings (ROLE-BASED FILTERING)
     *
     * ✅ Employee: hanya booking miliknya
     * ✅ Leader Divisi: semua booking di divisinya
     * ✅ Admin/GA: SEMUA booking di sistem
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
            \Log::info('📥 [BookingController.index] User: ' . $user->name . ' (Role: ' . $user->role . ')');
            \Log::info('📥 [BookingController.index] Division ID: ' . ($user->division_id ?? 'NULL'));

            $query = Booking::query();

            // ✅ ROLE-BASED FILTERING - CRITICAL!
            if ($user->role === 'employee') {
                // Employee: lihat hanya booking miliknya
                \Log::info('📊 [BookingController.index] Employee mode - filter by user_id: ' . $user->id);
                $query->where('user_id', $user->id);
            }
            elseif ($user->role === 'head_division') {
                // Leader Divisi: lihat semua booking di divisinya
                \Log::info('📊 [BookingController.index] Leader mode - filter by division_id: ' . $user->division_id);
                $query->where('division_id', $user->division_id);
            }
            elseif ($user->role === 'admin' || $user->role === 'divum_admin') {
                // ✅ ADMIN/GA: LIHAT SEMUA BOOKING (NO FILTER!)
                \Log::info('📊 [BookingController.index] Admin mode - showing ALL bookings');
                // No filter - show all
            }
            else {
                // Default: hanya booking miliknya
                \Log::info('📊 [BookingController.index] Default mode - filter by user_id: ' . $user->id);
                $query->where('user_id', $user->id);
            }

            // Execute query
            $bookings = $query->orderBy('booking_date', 'desc')->get();

            \Log::info('✅ [BookingController.index] Found ' . $bookings->count() . ' bookings');

            // Map ke format yang diharapkan
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

            return response()->json([
                'success' => true,
                'message' => 'Bookings retrieved successfully',
                'data' => $mappedBookings,
                'count' => $mappedBookings->count(),
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
}

