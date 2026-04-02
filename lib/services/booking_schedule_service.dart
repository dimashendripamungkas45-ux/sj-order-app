// lib/services/booking_schedule_service.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/available_slot_model.dart';

/// Service untuk handle booking schedule validation dan availability checking
class BookingScheduleService {
  final String baseUrl;
  final String token;

  BookingScheduleService({
    required this.baseUrl,
    required this.token,
  });

  // HTTP Headers dengan authentication
  Map<String, String> get _headers => {
    'Authorization': 'Bearer $token',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  /// Check apakah waktu booking tersedia (tanpa double-booking)
  ///
  /// Parameters:
  /// - bookingType: 'room' atau 'vehicle'
  /// - facilityId: id ruangan atau kendaraan
  /// - bookingDate: tanggal dalam format YYYY-MM-DD
  /// - startTime: jam mulai dalam format HH:mm
  /// - endTime: jam selesai dalam format HH:mm
  Future<AvailabilityCheckResult> checkAvailability({
    required String bookingType,
    required int facilityId,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/bookings/check-availability');

      final response = await http.get(
        url.replace(queryParameters: {
          'booking_type': bookingType,
          if (bookingType == 'room') 'room_id': facilityId.toString()
          else 'vehicle_id': facilityId.toString(),
          'booking_date': bookingDate,
          'start_time': startTime,
          'end_time': endTime,
        }),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200 || response.statusCode == 422) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('✅ Availability Check Result: ${data['available']}');

        return AvailabilityCheckResult.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Token expired - please login again');
      } else {
        throw Exception('Failed to check availability: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error checking availability: $e');
      rethrow;
    }
  }

  /// Get available time slots untuk fasilitas pada tanggal tertentu
  ///
  /// Mengembalikan list waktu yang kosong/tersedia
  Future<FacilityAvailability> getAvailableSlots({
    required String bookingType,
    required int facilityId,
    required String bookingDate,
    int intervalMinutes = 30,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/facilities/available-slots');

      final response = await http.get(
        url.replace(queryParameters: {
          'booking_type': bookingType,
          'facility_id': facilityId.toString(),
          'booking_date': bookingDate,
          'interval': intervalMinutes.toString(),
        }),
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('✅ Available Slots Retrieved: ${data['available_slots']?.length ?? 0} slots');

        return FacilityAvailability.fromJson(data);
      } else if (response.statusCode == 404) {
        throw Exception('Facility not found');
      } else if (response.statusCode == 401) {
        throw Exception('Token expired - please login again');
      } else {
        throw Exception('Failed to get available slots: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting available slots: $e');
      rethrow;
    }
  }

  /// Get jadwal lengkap (semua booking) untuk fasilitas pada tanggal tertentu
  ///
  /// Berguna untuk menampilkan timeline/kalender dengan semua booking
  Future<Map<String, dynamic>> getFacilityBookingsByDate({
    required String facilityType, // 'room' atau 'vehicle'
    required int facilityId,
    required String bookingDate,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/api/facilities/bookings/$facilityType/$facilityId/$bookingDate'
      );

      final response = await http.get(
        url,
        headers: _headers,
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        debugPrint('✅ Facility Bookings Retrieved: ${data['bookings_count'] ?? 0} bookings');

        return data;
      } else if (response.statusCode == 404) {
        throw Exception('Facility not found');
      } else if (response.statusCode == 401) {
        throw Exception('Token expired - please login again');
      } else {
        throw Exception('Failed to get facility bookings: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error getting facility bookings: $e');
      rethrow;
    }
  }

  /// Generate suggested available dates jika booking date tidak ada slot
  ///
  /// Membantu user menemukan tanggal alternatif yang tersedia
  Future<List<String>> getSuggestedDates({
    required String bookingType,
    required int facilityId,
    required String currentDate,
    int daysAhead = 7,
  }) async {
    List<String> suggestedDates = [];

    try {
      final now = DateTime.parse(currentDate);

      // Cek 7 hari ke depan
      for (int i = 1; i <= daysAhead; i++) {
        final checkDate = now.add(Duration(days: i)).toString().split(' ')[0];

        try {
          final availability = await getAvailableSlots(
            bookingType: bookingType,
            facilityId: facilityId,
            bookingDate: checkDate,
          );

          if (availability.availableSlots.isNotEmpty) {
            suggestedDates.add(checkDate);
            if (suggestedDates.length >= 3) break; // Max 3 saran
          }
        } catch (e) {
          debugPrint('Skipped date $checkDate: $e');
        }
      }

      return suggestedDates;
    } catch (e) {
      debugPrint('❌ Error getting suggested dates: $e');
      return [];
    }
  }

  /// Format time untuk display di UI
  static String formatTime(String time) {
    try {
      final parts = time.split(':');
      return '${parts[0]}:${parts[1]}';
    } catch (e) {
      return time;
    }
  }

  /// Check apakah 2 waktu bertabrakan dengan buffer 30 menit
  static bool isTimeConflict(
    String slot1Start,
    String slot1End,
    String slot2Start,
    String slot2End,
    {int bufferMinutes = 30}
  ) {
    try {
      final s1Start = _timeToMinutes(slot1Start) - bufferMinutes;
      final s1End = _timeToMinutes(slot1End) + bufferMinutes;
      final s2Start = _timeToMinutes(slot2Start);
      final s2End = _timeToMinutes(slot2End);

      return s1Start < s2End && s1End > s2Start;
    } catch (e) {
      debugPrint('❌ Error checking time conflict: $e');
      return false;
    }
  }

  /// Convert time string to minutes from midnight
  static int _timeToMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  /// Format DateTime to API format (HH:mm)
  static String dateTimeToTimeString(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  /// Format DateTime to API format (YYYY-MM-DD)
  static String dateTimeToDateString(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  /// Parse time string to DateTime
  static DateTime parseTimeString(String time, [DateTime? baseDate]) {
    final base = baseDate ?? DateTime.now();
    final parts = time.split(':');
    return DateTime(
      base.year,
      base.month,
      base.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }
}

