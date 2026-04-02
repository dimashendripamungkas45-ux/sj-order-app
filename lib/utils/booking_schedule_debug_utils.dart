// lib/utils/booking_schedule_debug_utils.dart

import 'package:flutter/material.dart';
import '../models/available_slot_model.dart';
import '../services/booking_schedule_service.dart';

/// Debug utilities untuk testing dan troubleshooting booking schedule system
class BookingScheduleDebugUtils {
  /// Print availability check result untuk debugging
  static void printAvailabilityResult(AvailabilityCheckResult result) {
    debugPrint('═════════════════════════════════════════');
    debugPrint('📋 AVAILABILITY CHECK RESULT');
    debugPrint('═════════════════════════════════════════');
    debugPrint('Available: ${result.available}');
    debugPrint('Message: ${result.message}');
    debugPrint('');

    if (result.conflicts.isNotEmpty) {
      debugPrint('🔴 Conflicts Found (${result.conflicts.length}):');
      for (var conflict in result.conflicts) {
        debugPrint('  • ${conflict.bookingCode}');
        debugPrint('    Time: ${conflict.startTime} - ${conflict.endTime}');
        debugPrint('    Purpose: ${conflict.purpose}');
        debugPrint('');
      }
    } else {
      debugPrint('🟢 No conflicts - slot is available');
    }
    debugPrint('═════════════════════════════════════════');
  }

  /// Print facility availability untuk debugging
  static void printFacilityAvailability(FacilityAvailability availability) {
    debugPrint('═════════════════════════════════════════');
    debugPrint('📅 FACILITY AVAILABILITY');
    debugPrint('═════════════════════════════════════════');
    debugPrint('Facility: ${availability.facilityName} (${availability.facilityType})');
    debugPrint('Date: ${availability.bookingDate}');
    debugPrint('Operating Hours: ${availability.operatingHours['start']} - ${availability.operatingHours['end']}');
    debugPrint('');

    debugPrint('🟢 Available Slots (${availability.availableSlots.length}):');
    for (var slot in availability.availableSlots) {
      debugPrint('  • ${slot.displayTime}');
    }
    debugPrint('');

    debugPrint('🔴 Busy Slots (${availability.busySlots.length}):');
    for (var slot in availability.busySlots) {
      debugPrint('  • ${slot.displayTime} - ${slot.reason}');
    }
    debugPrint('═════════════════════════════════════════');
  }

  /// Test scenario: simulasi booking conflict
  static Future<void> testBookingConflictScenario() async {
    debugPrint('\n🧪 TEST SCENARIO: Booking Conflict\n');

    // Scenario: Room A sudah terbooking 10:00-11:00
    // User coba booking 10:30-11:30 (overlap)
    // Expected: Conflict detected

    debugPrint('Existing Booking: Room A, 10:00-11:00 (Meeting)');
    debugPrint('Requested Time: 10:30-11:30');
    debugPrint('');
    debugPrint('Expected Result: CONFLICT ❌');
    debugPrint('Reason: Waktu overlap + perlu buffer 30 menit');
  }

  /// Test scenario: simulasi booking dengan buffer
  static Future<void> testBookingBufferScenario() async {
    debugPrint('\n🧪 TEST SCENARIO: Buffer Time\n');

    // Scenario: Room A sudah terbooking 10:00-11:00
    // User coba booking 11:00-12:00 (langsung setelah)
    // Expected: Conflict (perlu buffer 30 menit)

    debugPrint('Existing Booking: Room A, 10:00-11:00 (Meeting)');
    debugPrint('Requested Time: 11:00-12:00 (langsung setelah)');
    debugPrint('');
    debugPrint('Expected Result: CONFLICT ❌');
    debugPrint('Reason: Perlu buffer 30 menit, baru bisa 11:30+');
    debugPrint('Suggested Time: 11:30-12:30');
  }

  /// Test scenario: simulasi booking OK
  static Future<void> testBookingOkScenario() async {
    debugPrint('\n🧪 TEST SCENARIO: Booking OK\n');

    // Scenario: Room A sudah terbooking 10:00-11:00
    // User coba booking 11:45-12:45 (dengan buffer)
    // Expected: OK

    debugPrint('Existing Booking: Room A, 10:00-11:00 (Meeting)');
    debugPrint('Requested Time: 11:45-12:45 (dengan buffer 30min)');
    debugPrint('');
    debugPrint('Expected Result: OK ✅');
    debugPrint('Reason: Gap > 30 menit (11:00 + 30min = 11:30 ✓)');
  }

  /// Generate sample bookings untuk testing
  static List<Map<String, dynamic>> generateSampleBookings() {
    return [
      {
        'id': 1,
        'booking_code': '20240315001',
        'facility_id': 1,
        'facility_name': 'Meeting Room A',
        'start_time': '09:00',
        'end_time': '10:00',
        'purpose': 'Team Meeting',
        'status': 'approved',
      },
      {
        'id': 2,
        'booking_code': '20240315002',
        'facility_id': 1,
        'facility_name': 'Meeting Room A',
        'start_time': '13:00',
        'end_time': '14:30',
        'purpose': 'Client Meeting',
        'status': 'approved',
      },
      {
        'id': 3,
        'booking_code': '20240315003',
        'facility_id': 1,
        'facility_name': 'Meeting Room A',
        'start_time': '15:00',
        'end_time': '16:00',
        'purpose': 'Planning Session',
        'status': 'approved',
      },
    ];
  }

  /// Check if time conflicts (dengan buffer)
  static bool hasTimeConflict({
    required String requestedStart,
    required String requestedEnd,
    required String existingStart,
    required String existingEnd,
    int bufferMinutes = 30,
  }) {
    final rs = BookingScheduleService.parseTimeString(requestedStart);
    final re = BookingScheduleService.parseTimeString(requestedEnd);
    final es = BookingScheduleService.parseTimeString(existingStart)
        .subtract(Duration(minutes: bufferMinutes));
    final ee = BookingScheduleService.parseTimeString(existingEnd)
        .add(Duration(minutes: bufferMinutes));

    // Check overlap
    bool hasConflict = rs.isBefore(ee) && re.isAfter(es);

    debugPrint('Time Conflict Check:');
    debugPrint('  Requested: ${BookingScheduleService.dateTimeToTimeString(rs)} - ${BookingScheduleService.dateTimeToTimeString(re)}');
    debugPrint('  Existing (with buffer): ${BookingScheduleService.dateTimeToTimeString(es)} - ${BookingScheduleService.dateTimeToTimeString(ee)}');
    debugPrint('  Has Conflict: $hasConflict');

    return hasConflict;
  }

  /// Calculate next available time setelah existing booking
  static String calculateNextAvailableTime(
    String existingEndTime, {
    int bufferMinutes = 30,
  }) {
    final endTime = BookingScheduleService.parseTimeString(existingEndTime);
    final nextTime = endTime.add(Duration(minutes: bufferMinutes));
    final result = BookingScheduleService.dateTimeToTimeString(nextTime);

    debugPrint('Next Available Time After $existingEndTime (buffer $bufferMinutes min): $result');

    return result;
  }

  /// Print time slot analysis
  static void analyzeTimeSlots({
    required List<AvailableSlot> available,
    required List<BusySlot> busy,
  }) {
    debugPrint('═════════════════════════════════════════');
    debugPrint('📊 TIME SLOT ANALYSIS');
    debugPrint('═════════════════════════════════════════');

    final totalSlots = available.length + busy.length;
    final occupancyRate = ((busy.length / totalSlots) * 100).toStringAsFixed(1);

    debugPrint('Total Slots: $totalSlots');
    debugPrint('Available: ${available.length} (${((available.length / totalSlots) * 100).toStringAsFixed(1)}%)');
    debugPrint('Busy: ${busy.length} ($occupancyRate%)');
    debugPrint('');

    debugPrint('Occupancy Level:');
    if (double.parse(occupancyRate) < 30) {
      debugPrint('  🟢 LOW - Banyak slot tersedia');
    } else if (double.parse(occupancyRate) < 60) {
      debugPrint('  🟡 MEDIUM - Cukup slot tersedia');
    } else if (double.parse(occupancyRate) < 80) {
      debugPrint('  🟠 HIGH - Slot mulai terbatas');
    } else {
      debugPrint('  🔴 VERY HIGH - Hampir penuh');
    }

    debugPrint('═════════════════════════════════════════');
  }

  /// Validate time format
  static bool isValidTimeFormat(String time) {
    final regex = RegExp(r'^([0-1][0-9]|2[0-3]):[0-5][0-9]$');
    return regex.hasMatch(time);
  }

  /// Validate date format (YYYY-MM-DD)
  static bool isValidDateFormat(String date) {
    final regex = RegExp(r'^\d{4}-\d{2}-\d{2}$');
    if (!regex.hasMatch(date)) return false;

    try {
      DateTime.parse(date);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Print validation errors
  static void printValidationErrors({
    required String? bookingType,
    required String? bookingDate,
    required String? startTime,
    required String? endTime,
    required int? facilityId,
  }) {
    debugPrint('═════════════════════════════════════════');
    debugPrint('⚠️ VALIDATION ERRORS');
    debugPrint('═════════════════════════════════════════');

    if (bookingType == null || bookingType.isEmpty) {
      debugPrint('❌ Booking Type: Required');
    } else {
      debugPrint('✅ Booking Type: $bookingType');
    }

    if (bookingDate == null || bookingDate.isEmpty) {
      debugPrint('❌ Booking Date: Required');
    } else if (!isValidDateFormat(bookingDate)) {
      debugPrint('❌ Booking Date: Invalid format (use YYYY-MM-DD)');
    } else {
      debugPrint('✅ Booking Date: $bookingDate');
    }

    if (startTime == null || startTime.isEmpty) {
      debugPrint('❌ Start Time: Required');
    } else if (!isValidTimeFormat(startTime)) {
      debugPrint('❌ Start Time: Invalid format (use HH:mm)');
    } else {
      debugPrint('✅ Start Time: $startTime');
    }

    if (endTime == null || endTime.isEmpty) {
      debugPrint('❌ End Time: Required');
    } else if (!isValidTimeFormat(endTime)) {
      debugPrint('❌ End Time: Invalid format (use HH:mm)');
    } else {
      debugPrint('✅ End Time: $endTime');
    }

    if (facilityId == null || facilityId <= 0) {
      debugPrint('❌ Facility ID: Invalid');
    } else {
      debugPrint('✅ Facility ID: $facilityId');
    }

    debugPrint('═════════════════════════════════════════');
  }
}

