import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/role_model.dart';
import 'auth_service.dart';

class RoleService {
  static const String _userKey = 'current_user';

  // Get current user dari local storage
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);

      if (userJson == null) {
        // Coba dari auth service
        final userData = await AuthService.getUserData();
        if (userData != null) {
          return User.fromJson(jsonDecode(userData));
        }
        return null;
      }

      return User.fromJson(jsonDecode(userJson));
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Simpan user data setelah login
  static Future<void> setCurrentUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await AuthService.saveUserData(jsonEncode(user.toJson()));
    } catch (e) {
      print('Error setting current user: $e');
    }
  }

  // Get current role
  static Future<UserRole?> getCurrentRole() async {
    final user = await getCurrentUser();
    return user?.userRole;
  }

  // Check permissions
  static Future<bool> canApproveBooking() async {
    final role = await getCurrentRole();
    return role == UserRole.divisionalLeader || role == UserRole.divumAdmin;
  }

  static Future<bool> canManageFacilities() async {
    final role = await getCurrentRole();
    return role == UserRole.divumAdmin;
  }

  static Future<bool> canCreateBooking() async {
    final role = await getCurrentRole();
    return role != null;
  }

  static Future<bool> canViewAllBookings() async {
    final role = await getCurrentRole();
    return role == UserRole.divumAdmin;
  }

  static Future<bool> canViewDivisionBookings() async {
    final role = await getCurrentRole();
    return role == UserRole.divisionalLeader || role == UserRole.divumAdmin;
  }

  // Logout
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await AuthService.clearAuthData();
    } catch (e) {
      print('Error logout: $e');
    }
  }

  // Helper function untuk display role name
  static String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.employee:
        return 'Karyawan';
      case UserRole.divisionalLeader:
        return 'Pimpinan Divisi';
      case UserRole.divumAdmin:
        return 'Admin DIVUM';
    }
  }
}



