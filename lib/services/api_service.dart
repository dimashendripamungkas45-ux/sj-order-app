import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';

  // LOGIN
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('🔄 [ApiService.login] Starting login flow...');

      // Clear old user data COMPLETELY before login
      // This ensures no stale data from previous user
      await AuthService.clearAuthData();
      print('🔄 [ApiService.login] Old auth data cleared completely');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Save token first
        if (data['token'] != null) {
          await AuthService.saveToken(data['token']);
          print('✅ [ApiService.login] Token saved');

          // Save user data
          final userData = data['data'] ?? data['user'];
          if (userData != null) {
            await AuthService.saveUserData(jsonEncode(userData));
            print('✅ [ApiService.login] User data saved');
          }
        }

        print('✅ [ApiService.login] Login successful');
        return {
          'success': true,
          'message': data['message'] ?? 'Login successful',
          'user': data['data'] ?? data['user'],
          'token': data['token'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        print('❌ [ApiService.login] Login failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      print('💥 [ApiService.login] Exception: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // REGISTER
  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Simpan token jika ada
        if (data['token'] != null) {
          await AuthService.saveToken(data['token']);
          await AuthService.saveUserData(jsonEncode(data['user']));
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
          'user': data['user'],
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? errorData['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // GET BOOKINGS
  static Future<Map<String, dynamic>> getBookings() async {
    try {
      print('📡 [ApiService.getBookings] Starting...');
      final token = await AuthService.getToken();

      if (token == null) {
        print('❌ [ApiService.getBookings] No token found');
        return {
          'success': false,
          'message': 'No token found. Please login first.',
        };
      }

      print('🔑 [ApiService.getBookings] Token: ${token.substring(0, 30)}...');
      print('📍 [ApiService.getBookings] URL: $baseUrl/bookings');

      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      print('📥 [ApiService.getBookings] Response Status: ${response.statusCode}');
      print('📝 [ApiService.getBookings] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService.getBookings] Parsed JSON: ${data.runtimeType}');
        print('📦 [ApiService.getBookings] Data keys: ${data.keys}');

        final bookingsList = data['data'] ?? data;
        print('📋 [ApiService.getBookings] Bookings count: ${(bookingsList is List ? bookingsList.length : 0)}');

        return {
          'success': true,
          'bookings': bookingsList,
          'message': 'Bookings fetched successfully',
        };
      } else {
        print('❌ [ApiService.getBookings] Error status: ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to fetch bookings: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ [ApiService.getBookings] Exception: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // GET CURRENT USER
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('🌐 [ApiService.getCurrentUser] Starting...');
      final token = await AuthService.getToken();

      print('🔑 [ApiService] Token from storage: ${token != null ? 'EXISTS' : 'NULL'}');

      if (token == null) {
        print('❌ [ApiService] No token found!');
        return {
          'success': false,
          'message': 'No token found - Please login again',
        };
      }

      print('📤 [ApiService] Sending request to: $baseUrl/user');
      print('📋 [ApiService] Headers: Authorization: Bearer ${token.substring(0, 20)}...');

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️ [ApiService] Request timeout after 30 seconds');
          print('⏱️ [ApiService] Endpoint /user not responding - check backend');
          throw TimeoutException('GET request timeout', Duration(seconds: 30));
        },
      );

      print('📥 [ApiService] Response status: ${response.statusCode}');
      if (response.body.isNotEmpty) {
        final preview = response.body.length > 100
            ? response.body.substring(0, 100)
            : response.body;
        print('📥 [ApiService] Response body: $preview...');
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService] User data parsed successfully');
        print('✅ [ApiService] User: ${data['data'] ?? data}');
        return {
          'success': true,
          'user': User.fromJson(data['data'] ?? data),
          'message': 'User fetched successfully',
        };
      } else if (response.statusCode == 401) {
        print('❌ [ApiService] Unauthorized (401) - Token may be invalid');
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        print('❌ [ApiService] Failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to fetch user data (${response.statusCode})',
        };
      }
    } catch (e) {
      print('💥 [ApiService] Exception: $e');
      print('💥 [ApiService] Stack: ${StackTrace.current}');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // LOGOUT
  static Future<void> logout() async {
    try {
      print('🚪 [ApiService.logout] Starting logout process...');

      final token = await AuthService.getToken();

      // Try to notify backend about logout
      if (token != null && token.isNotEmpty) {
        try {
          print('📤 [ApiService.logout] Sending logout request to backend...');
          final response = await http.post(
            Uri.parse('$baseUrl/logout'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
          ).timeout(const Duration(seconds: 10));

          print('✅ [ApiService.logout] Backend logout response: ${response.statusCode}');
        } catch (e) {
          print('⚠️ [ApiService.logout] Backend logout failed (will continue): $e');
          // Continue with local cleanup even if API call fails
        }
      } else {
        print('⚠️ [ApiService.logout] No token found to send to backend');
      }

      // Clear all local data
      await AuthService.clearAuthData();
      print('✅ [ApiService.logout] Local auth data cleared');

    } catch (e) {
      print('💥 [ApiService.logout] Exception during logout: $e');
      // Still clear local data even if there's an error
      try {
        await AuthService.clearAuthData();
        print('✅ [ApiService.logout] Local data cleared despite error');
      } catch (clearError) {
        print('❌ [ApiService.logout] Failed to clear local data: $clearError');
      }
    }
  }

  // GET ROOMS
  static Future<Map<String, dynamic>> getRooms() async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch rooms',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ADD ROOM
  static Future<Map<String, dynamic>> addRoom({
    required String name,
    required String location,
    required int capacity,
    String? description,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/rooms'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'location': location,
          'capacity': capacity,
          'description': description,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add room',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // DELETE ROOM
  static Future<Map<String, dynamic>> deleteRoom(int id) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/rooms/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Room deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete room',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // GET VEHICLES
  static Future<Map<String, dynamic>> getVehicles() async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'] ?? data,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to fetch vehicles',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ADD VEHICLE
  static Future<Map<String, dynamic>> addVehicle({
    required String name,
    required String licensePlate,
    required String type,
    required int capacity,
    String? driverName,
    String? driverPhone,
  }) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/vehicles'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'license_plate': licensePlate,
          'type': type,
          'capacity': capacity,
          'driver_name': driverName,
          'driver_phone': driverPhone,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add vehicle',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // DELETE VEHICLE
  static Future<Map<String, dynamic>> deleteVehicle(int id) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/vehicles/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'Vehicle deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to delete vehicle',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // APPROVE BOOKING
  static Future<Map<String, dynamic>> approveBooking(int id, {String? notes}) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$id/approve'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to approve booking',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // REJECT BOOKING
  static Future<Map<String, dynamic>> rejectBooking(int id, {String? reason}) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      final response = await http.post(
        Uri.parse('$baseUrl/bookings/$id/reject'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'reason': reason,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        final data = jsonDecode(response.body);
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to reject booking',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // CREATE BOOKING
  static Future<Map<String, dynamic>> createBooking(Map<String, dynamic> bookingData) async {
    try {
      final token = await AuthService.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'No token found',
        };
      }

      print('📤 [ApiService.createBooking] Sending data: $bookingData');

      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(bookingData),
      ).timeout(const Duration(seconds: 30));

      print('📥 [ApiService.createBooking] Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService.createBooking] Success: ${data['message']}');
        return {
          'success': true,
          'message': data['message'] ?? 'Booking created successfully',
          'data': data['data'],
        };
      } else if (response.statusCode == 422) {
        // Validation error - provide detailed error message
        final data = jsonDecode(response.body);
        final errorMessage = data['message'] ?? 'Validation failed';
        final errors = data['errors'];

        print('❌ [ApiService.createBooking] Validation Error: $errorMessage');
        if (errors != null) {
          print('📋 [ApiService.createBooking] Validation Details: $errors');
        }

        // Build detailed error message
        String detailedMessage = errorMessage;
        if (errors is Map) {
          final errorDetails = errors.entries
              .map((e) => '${e.key}: ${e.value.join(', ')}')
              .join('\n');
          detailedMessage = '$errorMessage\n\n$errorDetails';
        }

        return {
          'success': false,
          'message': detailedMessage,
          'errors': errors,
        };
      } else {
        final data = jsonDecode(response.body);
        print('❌ [ApiService.createBooking] Error: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create booking',
        };
      }
    } catch (e) {
      print('💥 [ApiService.createBooking] Exception: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    }
  }

  // ===== APPROVAL METHODS =====

  /// Get booking detail
  static Future<Map<String, dynamic>> getBookingDetail(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return {'success': false, 'message': 'Failed to fetch booking'};
    } catch (e) {
      print('❌ Error fetching booking detail: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get available rooms for booking
  static Future<Map<String, dynamic>> getAvailableRooms() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      print('📤 [ApiService.getAvailableRooms] Calling endpoint: /available-rooms');

      final response = await http.get(
        Uri.parse('$baseUrl/available-rooms'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📥 [ApiService.getAvailableRooms] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final rooms = data['data'] ?? [];
        print('✅ [ApiService.getAvailableRooms] Rooms fetched: ${rooms.length} items');
        return {
          'success': true,
          'data': rooms,
        };
      }

      final data = jsonDecode(response.body);
      print('❌ [ApiService.getAvailableRooms] Error: ${data['message']}');
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch rooms'};
    } catch (e) {
      print('❌ Error fetching rooms: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get available vehicles for booking
  static Future<Map<String, dynamic>> getAvailableVehicles() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      print('📤 [ApiService.getAvailableVehicles] Calling endpoint: /available-vehicles');

      final response = await http.get(
        Uri.parse('$baseUrl/available-vehicles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      print('📥 [ApiService.getAvailableVehicles] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final vehicles = data['data'] ?? [];
        print('✅ [ApiService.getAvailableVehicles] Vehicles fetched: ${vehicles.length} items');
        return {
          'success': true,
          'data': vehicles,
        };
      }

      final data = jsonDecode(response.body);
      print('❌ [ApiService.getAvailableVehicles] Error: ${data['message']}');
      return {'success': false, 'message': data['message'] ?? 'Failed to fetch vehicles'};
    } catch (e) {
      print('❌ Error fetching vehicles: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Approve booking by Division Leader (Step 1)
  static Future<Map<String, dynamic>> approveDivision(
    int bookingId, {
    required String action, // 'approve' atau 'reject'
    required String notes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      print('📤 [ApiService.approveDivision] Calling: /bookings/$bookingId/approve-division');
      print('   Action: $action');
      print('   Notes: $notes');

      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/approve-division'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'action': action,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📥 [ApiService.approveDivision] Response status: ${response.statusCode}');
      print('📝 [ApiService.approveDivision] Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService.approveDivision] Success');
        return {
          'success': true,
          'message': data['message'] ?? 'Approved successfully',
          'data': data['data'],
        };
      }

      final data = jsonDecode(response.body);
      print('❌ [ApiService.approveDivision] Error: ${data['message']}');
      return {'success': false, 'message': data['message'] ?? 'Failed to approve'};
    } catch (e) {
      print('❌ Error approving division: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Approve booking by GA/Admin (Step 2)
  static Future<Map<String, dynamic>> approveDivum(
    int bookingId, {
    required String action, // 'approve' atau 'reject'
    required String notes,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      // Validate action
      if (action != 'approve' && action != 'reject') {
        print('❌ [ApiService.approveDivum] Invalid action: $action');
        return {
          'success': false,
          'message': 'Invalid action. Must be "approve" or "reject"'
        };
      }

      print('📤 [ApiService.approveDivum] Calling: /bookings/$bookingId/approve-divum');
      print('   Action: $action');
      print('   Notes: $notes');
      print('   Token: ${token.substring(0, 20)}...');

      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$bookingId/approve-divum'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'action': action,
          'notes': notes,
        }),
      ).timeout(const Duration(seconds: 10));

      print('📥 [ApiService.approveDivum] Response status: ${response.statusCode}');
      print('📝 [ApiService.approveDivum] Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService.approveDivum] Success - ${data['message']}');
        return {
          'success': true,
          'message': data['message'] ?? 'Request processed successfully',
          'data': data['data'],
        };
      }

      final data = jsonDecode(response.body);
      print('❌ [ApiService.approveDivum] Error (${response.statusCode}): ${data['message']}');
      return {
        'success': false,
        'message': data['message'] ?? 'Request failed with status ${response.statusCode}'
      };
    } catch (e) {
      print('❌ [ApiService.approveDivum] Exception: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // USER MANAGEMENT - Get all users
  static Future<Map<String, dynamic>> getUsers() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      print('📤 [ApiService.getUsers] Fetching all users...');

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 [ApiService.getUsers] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> userList = data['data'] ?? [];
        final users = userList
            .map((json) => User.fromJson(json as Map<String, dynamic>))
            .toList();

        print('✅ [ApiService.getUsers] Fetched ${users.length} users');
        return {
          'success': true,
          'users': users,
          'message': 'Users fetched successfully',
        };
      } else if (response.statusCode == 401) {
        print('❌ [ApiService.getUsers] Unauthorized');
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        print('❌ [ApiService.getUsers] Failed with status ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to fetch users',
        };
      }
    } catch (e) {
      print('❌ [ApiService.getUsers] Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // USER MANAGEMENT - Create user
  static Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String status,
    String? division,
    String? phoneNumber,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      print('📤 [ApiService.createUser] Creating user: $email');

      final body = {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'status': status,
      };

      if (division != null && division.isNotEmpty) {
        body['division'] = division;
      }
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = phoneNumber;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📥 [ApiService.createUser] Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService.createUser] User created successfully');
        return {
          'success': true,
          'user': data['data'],
          'message': data['message'] ?? 'User created successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        print('❌ [ApiService.createUser] Error: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create user',
        };
      }
    } catch (e) {
      print('❌ [ApiService.createUser] Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // USER MANAGEMENT - Update user
  static Future<Map<String, dynamic>> updateUser({
    required int userId,
    String? name,
    String? email,
    String? role,
    String? status,
    String? division,
    String? phoneNumber,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      print('📤 [ApiService.updateUser] Updating user: $userId');

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (email != null) body['email'] = email;
      if (role != null) body['role'] = role;
      if (status != null) body['status'] = status;
      if (division != null && division.isNotEmpty) body['division'] = division;
      if (phoneNumber != null && phoneNumber.isNotEmpty) {
        body['phone_number'] = phoneNumber;
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📥 [ApiService.updateUser] Response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService.updateUser] User updated successfully');
        return {
          'success': true,
          'user': data['data'],
          'message': data['message'] ?? 'User updated successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        print('❌ [ApiService.updateUser] Error: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update user',
        };
      }
    } catch (e) {
      print('❌ [ApiService.updateUser] Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // USER MANAGEMENT - Delete user
  static Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'Unauthorized'};
      }

      print('📤 [ApiService.deleteUser] Deleting user: $userId');

      final response = await http.delete(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📥 [ApiService.deleteUser] Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [ApiService.deleteUser] User deleted successfully');
        return {
          'success': true,
          'message': data['message'] ?? 'User deleted successfully',
        };
      } else {
        final data = jsonDecode(response.body);
        print('❌ [ApiService.deleteUser] Error: ${data['message']}');
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete user',
        };
      }
    } catch (e) {
      print('❌ [ApiService.deleteUser] Exception: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}

