enum UserRole {
  employee,
  divisionalLeader,
  divumAdmin,
}

class User {
  final int id;
  final String employeeId;
  final String name;
  final String email;
  final int divisionId;
  final String? divisionName;
  final String? role;
  final DateTime? createdAt;
  final bool isActive;

  // Cache parsed role to avoid repeated parsing
  late final UserRole? _cachedRole = role != null ? _roleFromString(role!) : null;

  User({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    required this.divisionId,
    this.divisionName,
    this.role,
    this.createdAt,
    this.isActive = true,
  });

  // Get role from role field or determine from context
  UserRole? get userRole {
    if (role == null) {
      return null;
    }
    // ✅ Return cached value (no logging here to reduce spam)
    return _cachedRole;
  }

  bool get isEmployee => userRole == UserRole.employee;
  bool get isDivisionalLeader => userRole == UserRole.divisionalLeader;
  bool get isDivumAdmin => userRole == UserRole.divumAdmin;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      employeeId: json['employee_id'] as String? ?? json['id'].toString(),
      name: json['name'] as String,
      email: json['email'] as String,
      divisionId: json['division_id'] == null
          ? 0
          : (json['division_id'] is int
              ? json['division_id']
              : int.parse(json['division_id'].toString())),
      divisionName: json['division_name'] as String?,
      role: json['role'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      isActive: _parseIsActive(json['is_active'] ?? json['is_acttive']),
    );
  }

  static bool _parseIsActive(dynamic value) {
    if (value is bool) return value;
    if (value is int) return value != 0;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return true;
  }

  static UserRole? _roleFromString(String roleString) {
    switch (roleString.toLowerCase().trim()) {
      // Employee roles
      case 'employee':
      case 'regular_employee':
        return UserRole.employee;

      // Divisional Leader roles
      case 'divisional_leader':
      case 'head_division':
      case 'division_head':
      case 'pimpinan_divisi':
        return UserRole.divisionalLeader;

      // Admin roles (DIVUM & GA)
      case 'divum_admin':
      case 'admin':
      case 'admin_divum':
      case 'admin_ga':
      case 'ga_admin':
      case 'superadmin':
      case 'administrator':
        return UserRole.divumAdmin;

      default:
        return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'name': name,
      'email': email,
      'division_id': divisionId,
      'division_name': divisionName,
      'role': role,
      'created_at': createdAt?.toIso8601String(),
      'is_active': isActive,
    };
  }
}







