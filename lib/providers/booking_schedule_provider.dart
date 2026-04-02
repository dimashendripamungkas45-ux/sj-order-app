// lib/providers/booking_schedule_provider.dart

import 'package:flutter/material.dart';
import '../models/available_slot_model.dart';
import '../services/booking_schedule_service.dart';

class BookingScheduleProvider extends ChangeNotifier {
  final BookingScheduleService _service;

  BookingScheduleProvider(this._service);

  // State variables
  FacilityAvailability? _currentAvailability;
  AvailabilityCheckResult? _lastCheckResult;
  Map<String, dynamic>? _facilityBookings;
  List<String> _suggestedDates = [];

  bool _isLoading = false;
  String? _error;
  bool _hasConflict = false;

  // Getters
  FacilityAvailability? get currentAvailability => _currentAvailability;
  AvailabilityCheckResult? get lastCheckResult => _lastCheckResult;
  Map<String, dynamic>? get facilityBookings => _facilityBookings;
  List<String> get suggestedDates => _suggestedDates;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasConflict => _hasConflict;

  // Available slots untuk UI
  List<AvailableSlot> get availableSlots => _currentAvailability?.availableSlots ?? [];
  List<BusySlot> get busySlots => _currentAvailability?.busySlots ?? [];

  /// Check availability dan simpan hasilnya
  Future<bool> checkAvailability({
    required String bookingType,
    required int facilityId,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final result = await _service.checkAvailability(
        bookingType: bookingType,
        facilityId: facilityId,
        bookingDate: bookingDate,
        startTime: startTime,
        endTime: endTime,
      );

      _lastCheckResult = result;
      _hasConflict = !result.available;

      if (!result.available) {
        _error = result.message;

        // Get suggested dates
        _suggestedDates = await _service.getSuggestedDates(
          bookingType: bookingType,
          facilityId: facilityId,
          currentDate: bookingDate,
        );
      }

      _setLoading(false);
      return result.available;

    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  /// Load available slots untuk time picker
  Future<void> loadAvailableSlots({
    required String bookingType,
    required int facilityId,
    required String bookingDate,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final availability = await _service.getAvailableSlots(
        bookingType: bookingType,
        facilityId: facilityId,
        bookingDate: bookingDate,
      );

      _currentAvailability = availability;
      _setLoading(false);

    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  /// Load facility bookings untuk kalender/timeline view
  Future<void> loadFacilityBookings({
    required String facilityType,
    required int facilityId,
    required String bookingDate,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      final bookings = await _service.getFacilityBookingsByDate(
        facilityType: facilityType,
        facilityId: facilityId,
        bookingDate: bookingDate,
      );

      _facilityBookings = bookings;
      _setLoading(false);

    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      rethrow;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Clear all data
  void clear() {
    _currentAvailability = null;
    _lastCheckResult = null;
    _facilityBookings = null;
    _suggestedDates = [];
    _error = null;
    _hasConflict = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}

/// Provider untuk notifikasi booking conflicts
class BookingNotificationProvider extends ChangeNotifier {
  final BookingScheduleService _service;

  BookingNotificationProvider(this._service);

  List<String> _notifications = [];
  DateTime _lastCheckTime = DateTime.now();

  List<String> get notifications => _notifications;

  /// Polling untuk check booking baru setiap 15 detik
  /// Gunakan ini di screen untuk real-time notifications
  Future<void> pollForNotifications({
    required String facilityType,
    required int facilityId,
    required String bookingDate,
  }) async {
    try {
      final now = DateTime.now();

      // Prevent excessive polling
      if (now.difference(_lastCheckTime).inSeconds < 10) {
        return;
      }

      final bookings = await _service.getFacilityBookingsByDate(
        facilityType: facilityType,
        facilityId: facilityId,
        bookingDate: bookingDate,
      );

      final bookingsList = bookings['bookings'] as List? ?? [];

      if (bookingsList.isNotEmpty) {
        _notifications.clear();
        for (var booking in bookingsList) {
          _notifications.add(
            '${booking['purpose']} - ${booking['start_time']} s/d ${booking['end_time']}'
          );
        }
      }

      _lastCheckTime = now;
      notifyListeners();

    } catch (e) {
      debugPrint('❌ Error polling notifications: $e');
    }
  }

  void clearNotifications() {
    _notifications.clear();
    notifyListeners();
  }
}

