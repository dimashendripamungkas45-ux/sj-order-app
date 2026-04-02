import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AdminProvider with ChangeNotifier {
  bool _isLoading = false;
  String _errorMessage = '';
  String _successMessage = '';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get successMessage => _successMessage;

  // API Base URL - change this sesuai environment Anda
  final String apiBaseUrl = 'http://localhost:8000/api';

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString('auth_token');
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  /// Create new room
  Future<bool> createRoom(Map<String, dynamic> roomData) async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();

      if (token == null) {
        _errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/rooms'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(roomData),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        _successMessage = 'Ruangan berhasil ditambahkan!';
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 403) {
        _errorMessage = 'Anda tidak memiliki akses untuk menambah ruangan';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        try {
          final error = jsonDecode(response.body);
          _errorMessage = error['message'] ?? 'Error: ${response.statusCode}';
        } catch (e) {
          _errorMessage = 'Error: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create new vehicle
  Future<bool> createVehicle(Map<String, dynamic> vehicleData) async {
    _isLoading = true;
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();

      if (token == null) {
        _errorMessage = 'Token tidak ditemukan. Silakan login kembali.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/vehicles'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(vehicleData),
      ).timeout(
        Duration(seconds: 30),
        onTimeout: () => throw TimeoutException('Request timeout'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201) {
        _successMessage = 'Kendaraan berhasil ditambahkan!';
        _isLoading = false;
        notifyListeners();
        return true;
      } else if (response.statusCode == 403) {
        _errorMessage = 'Anda tidak memiliki akses untuk menambah kendaraan';
        _isLoading = false;
        notifyListeners();
        return false;
      } else {
        try {
          final error = jsonDecode(response.body);
          _errorMessage = error['message'] ?? 'Error: ${response.statusCode}';
        } catch (e) {
          _errorMessage = 'Error: ${response.statusCode}';
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update room
  Future<bool> updateRoom(int roomId, Map<String, dynamic> roomData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();

      if (token == null) {
        _errorMessage = 'Token tidak ditemukan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse('$apiBaseUrl/rooms/$roomId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(roomData),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['message'] ?? 'Error: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update vehicle
  Future<bool> updateVehicle(int vehicleId, Map<String, dynamic> vehicleData) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();

      if (token == null) {
        _errorMessage = 'Token tidak ditemukan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.put(
        Uri.parse('$apiBaseUrl/vehicles/$vehicleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(vehicleData),
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['message'] ?? 'Error: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete room
  Future<bool> deleteRoom(int roomId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();

      if (token == null) {
        _errorMessage = 'Token tidak ditemukan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/rooms/$roomId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['message'] ?? 'Error: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete vehicle
  Future<bool> deleteVehicle(int vehicleId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final token = await _getToken();

      if (token == null) {
        _errorMessage = 'Token tidak ditemukan.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final response = await http.delete(
        Uri.parse('$apiBaseUrl/vehicles/$vehicleId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final error = jsonDecode(response.body);
        _errorMessage = error['message'] ?? 'Error: ${response.statusCode}';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearMessages() {
    _errorMessage = '';
    _successMessage = '';
    notifyListeners();
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

