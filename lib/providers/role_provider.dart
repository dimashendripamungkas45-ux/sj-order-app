import 'package:flutter/material.dart';
import '../models/role_model.dart';
import '../services/role_service.dart';

class RoleProvider extends ChangeNotifier {
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _userSetFromLogin = false; // Flag to prevent multiple initialization

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;

  UserRole? get currentRole => _currentUser?.userRole;

  bool get isEmployee => _currentUser?.isEmployee ?? false;
  bool get isDivisionalLeader => _currentUser?.isDivisionalLeader ?? false;
  bool get isDivumAdmin => _currentUser?.isDivumAdmin ?? false;

  // Permissions
  bool get canApproveBooking => isDivisionalLeader || isDivumAdmin;
  bool get canManageFacilities => isDivumAdmin;
  bool get canCreateBooking => _currentUser != null;
  bool get canViewAllBookings => isDivumAdmin;
  bool get canViewDivisionBookings => isDivisionalLeader || isDivumAdmin;

  // Initialize user data on app start
  Future<void> initializeUser() async {
    // Skip if user already set from login
    if (_userSetFromLogin && _currentUser != null) {
      print('✅ [RoleProvider] User already set from login, skipping initialize');
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await RoleService.getCurrentUser();
      if (user != null) {
        print('📍 [RoleProvider] Loaded user from storage: ${user.name}');
        _currentUser = user;
      }
      _isLoading = false;
    } catch (e) {
      _error = 'Error loading user: $e';
      _isLoading = false;
      print('❌ [RoleProvider] Error initializing user: $e');
    }
    notifyListeners();
  }

  // Set user after login (from login response)
  Future<void> setUserFromLogin(Map<String, dynamic> userData) async {
    try {
      print('📋 [RoleProvider] Setting user from login...');

      final user = User.fromJson(userData);
      await RoleService.setCurrentUser(user);

      // Set all state variables at once
      _currentUser = user;
      _userSetFromLogin = true;
      _error = null;

      // Only notify listeners once after all state is set
      notifyListeners();

      // Debug log (after notifyListeners to reduce rebuilds)
      print('✅ [RoleProvider] User set from login');
      print('   Name: ${user.name}');
      print('   Email: ${user.email}');
      print('   Raw role: ${user.role}');
      print('   Parsed role: ${user.userRole}');
      print('   isEmployee: ${user.isEmployee}');
      print('   isDivisionalLeader: ${user.isDivisionalLeader}');
      print('   isDivumAdmin: ${user.isDivumAdmin}');
    } catch (e) {
      _error = 'Error setting user: $e';
      print('❌ [RoleProvider] Error setting user: $e');
      notifyListeners();
    }
  }

  // Refresh user data from storage
  Future<void> refreshUser() async {
    try {
      final user = await RoleService.getCurrentUser();
      _currentUser = user;
      _error = null;
      notifyListeners();
      print('🔄 [RoleProvider] User refreshed');
    } catch (e) {
      _error = 'Error refreshing user: $e';
      notifyListeners();
      print('❌ [RoleProvider] Error refreshing user: $e');
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      print('🚪 [RoleProvider] Logout initiated');
      await RoleService.logout();
      _currentUser = null;
      _userSetFromLogin = false; // Reset flag on logout
      _error = null;
      notifyListeners();
      print('✅ [RoleProvider] User cleared from RoleProvider');
    } catch (e) {
      _error = 'Error logout: $e';
      print('❌ [RoleProvider] Logout error: $e');
      // Still clear user even if service error
      _currentUser = null;
      _userSetFromLogin = false; // Reset flag even on error
      notifyListeners();
    }
  }

  // Get role display name
  String getRoleDisplayName() {
    if (_currentUser == null || _currentUser!.userRole == null) {
      return 'Unknown';
    }
    return RoleService.getRoleDisplayName(_currentUser!.userRole!);
  }
}






