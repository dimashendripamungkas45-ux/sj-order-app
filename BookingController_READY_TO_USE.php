<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\Room;
use App\Models\Vehicle;
use App\Traits\BookingScheduleValidator;  // ← TAMBAHKAN IMPORT INI
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
    use BookingScheduleValidator;  // ← TAMBAHKAN TRAIT INI

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
     * Store (Create) new booking - DENGAN VALIDASI CONFLICT
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
            // ✅ VALIDATION: Check time slot availability SEBELUM CREATE
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
                'data' => $booking,
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

    // ... tambahkan method lainnya dari controller Anda yang sebelumnya
}

