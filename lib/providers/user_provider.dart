import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUser() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      print('📍 [UserProvider] Fetching user...');

      // Check token first
      final token = await AuthService.getToken();
      print('📍 [UserProvider] Token available: ${token != null}');

      if (token == null) {
        _error = 'No authentication token found. Please login again.';
        _user = null;
        print('❌ [UserProvider] Error: No token found');
      } else {
        // Try to load from SharedPreferences first (faster)
        print('📍 [UserProvider] Trying to load user from storage first...');
        final prefs = await SharedPreferences.getInstance();
        final savedUserJson = prefs.getString('user_data');

        if (savedUserJson != null) {
          try {
            _user = User.fromJson(jsonDecode(savedUserJson));
            _error = null;
            print('✅ [UserProvider] User loaded from storage: ${_user?.name}');
          } catch (e) {
            print('⚠️ [UserProvider] Failed to parse cached user: $e');
          }
        }

        // Then try to fetch fresh data from API (with timeout handling)
        print('📍 [UserProvider] Fetching fresh user data from API...');
        try {
          final result = await ApiService.getCurrentUser();
          print('📍 [UserProvider] API Response: ${result['success']}');

          if (result['success']) {
            _user = result['user'];
            _error = null;
            print('✅ [UserProvider] User fetched successfully: ${_user?.name}');
          } else {
            // Use cached user if API fails but we have cached data
            if (_user != null) {
              _error = null;
              print('⚠️ [UserProvider] Using cached user data (API failed)');
            } else {
              _error = result['message'] ?? 'Failed to fetch user data';
              _user = null;
              print('❌ [UserProvider] Error: ${_error}');
            }
          }
        } on TimeoutException catch (e) {
          print('⏱️ [UserProvider] API timeout: $e');
          if (_user != null) {
            _error = null;
            print('⚠️ [UserProvider] Using cached user data (API timeout)');
          } else {
            _error = 'Server timeout. Using cached data if available.';
            print('❌ [UserProvider] Timeout and no cached data');
          }
        }
      }
    } catch (e) {
      _error = 'Error fetching user: $e';
      if (_user == null) {
        _user = null;
      }
      print('💥 [UserProvider] Exception: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearUser() {
    print('🗑️ [UserProvider] Clearing cached user data');
    _user = null;
    _error = null;
    notifyListeners();
  }
}

