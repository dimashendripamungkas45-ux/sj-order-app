import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // Simpan token
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      print('✅ Token saved: ${token.substring(0, 20)}...');
    } catch (e) {
      print('❌ Error saving token: $e');
      rethrow;
    }
  }

  // Ambil token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      print('🔍 Token retrieved: ${token != null ? token.substring(0, 20) + '...' : 'NULL'}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  // Simpan data user
  static Future<void> saveUserData(String userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, userData);
      print('✅ User data saved');
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  // Ambil data user
  static Future<String?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      print('🔍 User data retrieved: ${userData != null ? 'OK' : 'NULL'}');
      return userData;
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  // Hapus token dan data user (logout)
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      print('✅ Auth data cleared (token and user data removed)');
    } catch (e) {
      print('❌ Error clearing auth data: $e');
      rethrow;
    }
  }

  // Hapus semua data termasuk yang lain (untuk logout yang lebih lengkap)
  static Future<void> clearAllData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('✅ All app data cleared');
    } catch (e) {
      print('❌ Error clearing all data: $e');
      rethrow;
    }
  }

  // Check apakah user sudah login
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final isLoggedIn = token != null && token.isNotEmpty;
      print('🔐 isLoggedIn: $isLoggedIn');
      return isLoggedIn;
    } catch (e) {
      print('❌ Error checking login status: $e');
      return false;
    }
  }
}

