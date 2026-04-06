import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserManagementProvider extends ChangeNotifier {
  List<User> users = [];
  bool isLoading = false;
  String? error;

  Future<void> fetchUsers() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final response = await ApiService.getUsers();
      if (response['success']) {
        users = response['users'] ?? [];
        error = null;
      } else {
        error = response['message'] ?? 'Failed to fetch users';
      }
    } catch (e) {
      error = 'Error: $e';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> createUser({
    required String name,
    required String email,
    required String password,
    required String role,
    required String status,
    String? division,
    String? phoneNumber,
  }) async {
    try {
      final response = await ApiService.createUser(
        name: name,
        email: email,
        password: password,
        role: role,
        status: status,
        division: division,
        phoneNumber: phoneNumber,
      );

      if (response['success']) {
        await fetchUsers();
        return {
          'success': true,
          'message': response['message'] ?? 'User created successfully',
          'user': response['user'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to create user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> updateUser({
    required int userId,
    String? name,
    String? email,
    String? role,
    String? status,
    String? division,
    String? phoneNumber,
  }) async {
    try {
      final response = await ApiService.updateUser(
        userId: userId,
        name: name,
        email: email,
        role: role,
        status: status,
        division: division,
        phoneNumber: phoneNumber,
      );

      if (response['success']) {
        await fetchUsers();
        return {
          'success': true,
          'message': response['message'] ?? 'User updated successfully',
          'user': response['user'],
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to update user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  Future<Map<String, dynamic>> deleteUser(int userId) async {
    try {
      final response = await ApiService.deleteUser(userId);

      if (response['success']) {
        await fetchUsers();
        return {
          'success': true,
          'message': response['message'] ?? 'User deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': response['message'] ?? 'Failed to delete user',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }
}

