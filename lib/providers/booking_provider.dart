import 'package:flutter/material.dart';
import '../models/booking_model.dart';
import '../services/api_service.dart';

class BookingProvider extends ChangeNotifier {
  List<Booking> _bookings = [];
  bool _isLoading = false;
  String? _error;

  List<Booking> get bookings => _bookings;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchBookings() async {
    print('📥 [BookingProvider.fetchBookings] Starting...');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📤 [BookingProvider] Calling ApiService.getBookings()...');
      final result = await ApiService.getBookings();

      print('📦 [BookingProvider] API Result: $result');
      print('📦 [BookingProvider] Result type: ${result.runtimeType}');
      print('📦 [BookingProvider] Result keys: ${result.keys}');

      if (result['success']) {
        // ✅ Handle both response formats:
        // Format 1: { success: true, bookings: [...] }
        // Format 2: { success: true, data: [...] }
        var bookingsList = result['bookings'] ?? result['data'] ?? [];

        print('✅ [BookingProvider] Got bookings list');
        print('✅ [BookingProvider] Bookings type: ${bookingsList.runtimeType}');
        print('✅ [BookingProvider] Is List: ${bookingsList is List}');
        print('✅ [BookingProvider] Count: ${bookingsList is List ? bookingsList.length : 'N/A'}');

        if (bookingsList is! List) {
          print('❌ [BookingProvider] ERROR: bookingsList is not a List!');
          print('❌ [BookingProvider] Actual type: ${bookingsList.runtimeType}');
          print('❌ [BookingProvider] Value: $bookingsList');
          _error = 'Invalid bookings format: ${bookingsList.runtimeType}';
          _bookings = [];
        } else if (bookingsList.isEmpty) {
          print('⚠️ [BookingProvider] API returned empty bookings list');
          _bookings = [];
          _error = null;
        } else {
          print('✅ [BookingProvider] Success! Got ${bookingsList.length} bookings from API');

          _bookings = [];
          for (int i = 0; i < bookingsList.length; i++) {
            try {
              final json = bookingsList[i] as Map<String, dynamic>;
              print('   [${i+1}/${bookingsList.length}] Parsing booking...');
              print('   - Code: ${json['booking_code']}');
              print('   - User ID: ${json['user_id']}');
              print('   - Status: ${json['status']}');

              final booking = Booking.fromJson(json);
              _bookings.add(booking);
              print('   ✅ Parsed: ${booking.bookingCode} (userId: ${booking.userId})');
            } catch (e, stackTrace) {
              print('   ❌ Error parsing booking ${i+1}: $e');
              print('   Stack: $stackTrace');
              print('   Data: ${bookingsList[i]}');
            }
          }

          print('📋 [BookingProvider] FINAL RESULT:');
          print('   Total bookings parsed: ${_bookings.length}');
          for (var booking in _bookings) {
            print('   - ${booking.bookingCode}: userId=${booking.userId}, status=${booking.status}');
          }

          _error = null;
        }
      } else {
        print('❌ [BookingProvider] API returned success=false');
        print('   Message: ${result['message']}');
        _error = result['message'] ?? 'Failed to fetch bookings';
        _bookings = [];
      }
    } catch (e, stackTrace) {
      print('❌ [BookingProvider] Exception: $e');
      print('❌ [BookingProvider] Stack trace: $stackTrace');
      _error = 'Error fetching bookings: $e';
      _bookings = [];
    }

    _isLoading = false;
    print('✅ [BookingProvider] fetchBookings completed');
    print('   Total bookings available: ${_bookings.length}');
    print('   Error: ${_error ?? 'None'}');
    notifyListeners();
  }

  /// Fetch booking detail dengan approval fields
  Future<Booking?> fetchBookingDetail(int id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.getBookingDetail(id);

      if (result['success']) {
        final booking = Booking.fromJson(result['data']);
        _error = null;
        return booking;
      } else {
        _error = result['message'] ?? 'Failed to fetch booking detail';
        return null;
      }
    } catch (e) {
      print('❌ Error fetching booking detail: $e');
      _error = 'Error: $e';
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve booking by division leader (Tahap 1)
  Future<bool> approveDivision({
    required int bookingId,
    required String action,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.approveDivision(
        bookingId,
        action: action,
        notes: notes ?? '',
      );

      if (result['success']) {
        // Refresh bookings
        await fetchBookings();
        _error = null;
        return true;
      } else {
        _error = result['message'] ?? 'Failed to approve booking';
        return false;
      }
    } catch (e) {
      print('❌ Error approving booking: $e');
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Approve booking by DIVUM admin (Tahap 2)
  Future<bool> approveDivum({
    required int bookingId,
    required String action,
    String? notes,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final result = await ApiService.approveDivum(
        bookingId,
        action: action,
        notes: notes ?? '',
      );

      if (result['success']) {
        // Refresh bookings
        await fetchBookings();
        _error = null;
        return true;
      } else {
        _error = result['message'] ?? 'Failed to approve booking';
        return false;
      }
    } catch (e) {
      print('❌ Error approving booking: $e');
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearBookings() {
    _bookings = [];
    _error = null;
    notifyListeners();
  }

  Future<void> refreshBookings() async {
    print('🔄 [BookingProvider] Refreshing bookings...');
    await fetchBookings();
    print('✅ [BookingProvider] Bookings refreshed');
  }


  /// Get booking by ID dari cache
  Booking? getBookingById(int id) {
    try {
      return _bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }
}
