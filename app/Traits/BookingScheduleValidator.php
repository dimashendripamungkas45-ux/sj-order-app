<?php

namespace App\Traits;

use App\Models\Booking;
use Carbon\Carbon;

/**
 * Trait untuk validasi jadwal pemesanan fasilitas (ruangan dan kendaraan)
 *
 * FITUR:
 * 1. Cegah double-booking (overlap time)
 * 2. Terapkan jeda minimal 30 menit antara booking
 * 3. Check hanya booking yang sudah approved
 *
 * USAGE:
 * class BookingController extends Controller {
 *     use BookingScheduleValidator;
 *
 *     public function store(Request $request) {
 *         // Check if slot is available
 *         if (!$this->isTimeSlotAvailable($request)) {
 *             return response()->json(['error' => 'Slot tidak tersedia'], 422);
 *         }
 *     }
 * }
 */
trait BookingScheduleValidator
{
    /**
     * Minimum gap (dalam menit) antara booking
     * Setelah booking selesai, harus tunggu 30 menit sebelum fasilitas bisa dipakai lagi
     */
    private const MINIMUM_GAP_MINUTES = 30;

    /**
     * Check apakah time slot tersedia untuk booking
     *
     * @param array $bookingData Mengandung: booking_type, booking_date, start_time, end_time, room_id (optional), vehicle_id (optional)
     * @param int|null $excludeBookingId Exclude booking ID tertentu (untuk update case)
     * @return array ['available' => bool, 'conflicts' => array, 'message' => string]
     */
    public function isTimeSlotAvailable(array $bookingData, ?int $excludeBookingId = null): array
    {
        $bookingType = $bookingData['booking_type'];
        $bookingDate = $bookingData['booking_date'];
        $startTime = $bookingData['start_time']; // Format: H:i
        $endTime = $bookingData['end_time'];     // Format: H:i
        $roomId = $bookingData['room_id'] ?? null;
        $vehicleId = $bookingData['vehicle_id'] ?? null;

        // Validasi input
        if (!$bookingType || !$bookingDate || !$startTime || !$endTime) {
            return [
                'available' => false,
                'conflicts' => [],
                'message' => 'Data pemesanan tidak lengkap'
            ];
        }

        try {
            // Parse times ke datetime untuk comparison
            $bookingDateTime = Carbon::parse($bookingDate);
            $slotStartDateTime = Carbon::parse($bookingDate . ' ' . $startTime);
            $slotEndDateTime = Carbon::parse($bookingDate . ' ' . $endTime);

            // Hitung buffer time: mulai 30 menit sebelum booking sampai 30 menit setelah booking
            $bufferStartDateTime = $slotStartDateTime->copy()->subMinutes(self::MINIMUM_GAP_MINUTES);
            $bufferEndDateTime = $slotEndDateTime->copy()->addMinutes(self::MINIMUM_GAP_MINUTES);

            \Log::debug('🔍 [Conflict Check] Parameters:', [
                'booking_type' => $bookingType,
                'booking_date' => $bookingDate,
                'requested_slot' => "{$startTime} - {$endTime}",
                'buffer_zone' => "{$bufferStartDateTime->format('H:i')} - {$bufferEndDateTime->format('H:i')}",
                'minimum_gap_minutes' => self::MINIMUM_GAP_MINUTES,
            ]);

            // Query untuk cek conflict
            // Menggunakan CAST untuk memastikan comparison dilakukan dengan proper format
            $query = Booking::where('booking_type', $bookingType)
                           ->where('booking_date', $bookingDate)
                           // Hanya check approved bookings
                           ->where('status', 'approved')
                           ->where(function ($q) use ($bookingDate, $bufferStartDateTime, $bufferEndDateTime) {
                               // Check if any existing booking overlaps dengan buffer zone
                               // Conflict terjadi jika:
                               // - Existing start < buffer end AND
                               // - Existing end > buffer start

                               // Convert time columns to comparable format (HH:mm as number)
                               $bufferStart = $bufferStartDateTime->format('H:i');
                               $bufferEnd = $bufferEndDateTime->format('H:i');

                               // Overlap condition: existing_start < buffer_end AND existing_end > buffer_start
                               $q->whereRaw("start_time < ?", [$bufferEnd])
                                 ->whereRaw("end_time > ?", [$bufferStart]);
                           });

            // Sesuaikan query berdasarkan tipe booking
            if ($bookingType === 'room' && $roomId) {
                $query->where('room_id', $roomId);
            } elseif ($bookingType === 'vehicle' && $vehicleId) {
                $query->where('vehicle_id', $vehicleId);
            }

            // Exclude booking yang sedang diupdate
            if ($excludeBookingId) {
                $query->where('id', '!=', $excludeBookingId);
            }

            $conflicts = $query->get()->map(function ($booking) {
                return [
                    'id' => $booking->id,
                    'booking_code' => $booking->booking_code,
                    'start_time' => $booking->start_time,
                    'end_time' => $booking->end_time,
                    'purpose' => $booking->purpose,
                ];
            })->toArray();

            \Log::debug('🔍 [Conflict Check] Query Result:', [
                'conflicts_found' => count($conflicts),
                'conflicts_detail' => $conflicts,
            ]);

            if (!empty($conflicts)) {
                $facilityName = $bookingType === 'room' ? 'Ruangan' : 'Kendaraan';

                // Format conflict details untuk user
                $conflictDetails = [];
                foreach ($conflicts as $conflict) {
                    $conflictDetails[] = "{$conflict['purpose']} ({$conflict['start_time']} - {$conflict['end_time']})";
                }

                $message = "{$facilityName} telah terbooking pada jadwal tersebut.\n\n";
                $message .= "Booking yang bentrok:\n";
                $message .= implode("\n", $conflictDetails) . "\n\n";
                $message .= "⏱️ Perlu jeda minimal 30 menit sebelum dan sesudah booking yang ada.\n";
                $message .= "Silakan pilih waktu lain.";

                \Log::warning('⚠️ [Conflict Detected]', [
                    'booking_type' => $bookingType,
                    'facility_id' => $roomId ?? $vehicleId,
                    'requested_time' => "{$startTime} - {$endTime}",
                    'conflicts_count' => count($conflicts),
                    'conflict_details' => $conflictDetails,
                ]);

                return [
                    'available' => false,
                    'conflicts' => $conflicts,
                    'message' => $message
                ];
            }

            \Log::info('✅ [Slot Available]', [
                'booking_type' => $bookingType,
                'facility_id' => $roomId ?? $vehicleId,
                'booking_date' => $bookingDate,
                'requested_time' => "{$startTime} - {$endTime}",
            ]);

            return [
                'available' => true,
                'conflicts' => [],
                'message' => 'Waktu tersedia untuk booking'
            ];

        } catch (\Exception $e) {
            \Log::error('❌ [CRITICAL] Error checking time slot availability', [
                'error' => $e->getMessage(),
                'booking_type' => $bookingType,
                'booking_date' => $bookingDate,
                'start_time' => $startTime,
                'end_time' => $endTime,
                'room_id' => $roomId,
                'vehicle_id' => $vehicleId,
                'file' => $e->getFile(),
                'line' => $e->getLine(),
                'trace' => $e->getTraceAsString(),
            ]);

            return [
                'available' => false,
                'conflicts' => [],
                'message' => 'Error checking availability: ' . $e->getMessage()
            ];
        }
    }

    /**
     * Get available time slots untuk fasilitas pada tanggal tertentu
     *
     * @param string $bookingType 'room' atau 'vehicle'
     * @param int $facilityId room_id atau vehicle_id
     * @param string $bookingDate Format: YYYY-MM-DD
     * @param int $intervalMinutes Interval waktu (15, 30, 60)
     * @return array ['available_slots' => array, 'busy_slots' => array]
     */
    public function getAvailableSlots(string $bookingType, int $facilityId, string $bookingDate, int $intervalMinutes = 30): array
    {
        try {
            // Jam operasional: 08:00 - 17:00
            $operatingStart = Carbon::parse($bookingDate . ' 08:00');
            $operatingEnd = Carbon::parse($bookingDate . ' 17:00');

            $availableSlots = [];
            $busySlots = [];

            // Get semua booking yang approved untuk fasilitas ini pada tanggal tersebut
            $bookings = Booking::where('booking_type', $bookingType)
                              ->where('booking_date', $bookingDate)
                              ->where('status', 'approved')
                              ->when($bookingType === 'room', function ($q) use ($facilityId) {
                                  return $q->where('room_id', $facilityId);
                              })
                              ->when($bookingType === 'vehicle', function ($q) use ($facilityId) {
                                  return $q->where('vehicle_id', $facilityId);
                              })
                              ->get();

            // Generate semua possible time slots
            $current = $operatingStart->copy();

            while ($current < $operatingEnd) {
                $slotStart = $current->copy();
                $slotEnd = $current->copy()->addMinutes($intervalMinutes);

                // Skip jika slot end melebihi jam operasional
                if ($slotEnd > $operatingEnd) {
                    break;
                }

                // Cek apakah slot ini conflict dengan booking yang ada
                $hasConflict = false;
                foreach ($bookings as $booking) {
                    $bookingStart = Carbon::parse($bookingDate . ' ' . $booking->start_time);
                    $bookingEnd = Carbon::parse($bookingDate . ' ' . $booking->end_time);

                    // Tambah buffer 30 menit
                    $bufferStart = $bookingStart->copy()->subMinutes(self::MINIMUM_GAP_MINUTES);
                    $bufferEnd = $bookingEnd->copy()->addMinutes(self::MINIMUM_GAP_MINUTES);

                    // Check overlap
                    if ($slotStart < $bufferEnd && $slotEnd > $bufferStart) {
                        $hasConflict = true;
                        $busySlots[] = [
                            'start' => $slotStart->format('H:i'),
                            'end' => $slotEnd->format('H:i'),
                            'reason' => $booking->purpose
                        ];
                        break;
                    }
                }

                if (!$hasConflict) {
                    $availableSlots[] = [
                        'start' => $slotStart->format('H:i'),
                        'end' => $slotEnd->format('H:i'),
                    ];
                }

                $current->addMinutes($intervalMinutes);
            }

            return [
                'available_slots' => $availableSlots,
                'busy_slots' => $busySlots,
                'operating_hours' => [
                    'start' => '08:00',
                    'end' => '17:00'
                ]
            ];

        } catch (\Exception $e) {
            \Log::error('❌ Error getting available slots', [
                'error' => $e->getMessage(),
                'booking_type' => $bookingType,
                'facility_id' => $facilityId,
                'booking_date' => $bookingDate,
            ]);

            return [
                'available_slots' => [],
                'busy_slots' => [],
                'error' => $e->getMessage()
            ];
        }
    }

    /**
     * Get next available date untuk fasilitas (minimal 1 hari ke depan)
     *
     * @param string $bookingType
     * @param int $facilityId
     * @return string Format YYYY-MM-DD atau null jika tidak ada
     */
    public function getNextAvailableDate(string $bookingType, int $facilityId): ?string
    {
        try {
            // Cek 30 hari ke depan
            for ($i = 1; $i <= 30; $i++) {
                $date = Carbon::now()->addDays($i)->format('Y-m-d');
                $slots = $this->getAvailableSlots($bookingType, $facilityId, $date, 60);

                if (!empty($slots['available_slots'])) {
                    return $date;
                }
            }

            return null;

        } catch (\Exception $e) {
            \Log::error('❌ Error getting next available date', [
                'error' => $e->getMessage(),
            ]);
            return null;
        }
    }
}

