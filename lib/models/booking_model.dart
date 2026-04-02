import 'package:flutter/material.dart';

class Booking {
  final int id;
  final int userId; // ✅ Add user_id field
  final String bookingCode;
  final String bookingType; // 'room' atau 'vehicle'
  final String purpose;
  final String bookingDate;
  final String startTime;
  final String endTime;
  final String status; // pending_division, pending_ga, approved, rejected_division, rejected_ga
  final int? roomId;
  final int? vehicleId;
  final int? participantsCount;
  final String? destination;
  final String? divisionApprovalNotes;
  final String? gaApprovalNotes;
  final int? approvedByDivision;
  final int? approvedByDivum;

  Booking({
    required this.id,
    required this.userId, // ✅ Add to constructor
    required this.bookingCode,
    required this.bookingType,
    required this.purpose,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.roomId,
    this.vehicleId,
    this.participantsCount,
    this.destination,
    this.divisionApprovalNotes,
    this.gaApprovalNotes,
    this.approvedByDivision,
    this.approvedByDivum,
  });

  // ✅ Helper methods for status checking
  bool get isPendingDivision => status.toLowerCase() == 'pending_division';
  bool get isPendingGA => status.toLowerCase() == 'pending_ga';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isRejected => status.toLowerCase().contains('rejected');
  bool get isRejectedDivision => status.toLowerCase() == 'rejected_division';
  bool get isRejectedGA => status.toLowerCase() == 'rejected_ga';

  // Status display methods
  String getStatusLabelIndonesian() {
    switch (status.toLowerCase()) {
      case 'pending_division':
        return 'Menunggu Divisi';
      case 'pending_ga':
        return 'Menunggu GA';
      case 'approved':
        return 'Disetujui';
      case 'rejected_division':
        return 'Ditolak Divisi';
      case 'rejected_ga':
        return 'Ditolak GA';
      default:
        return status;
    }
  }

  Color getStatusColor() {
    switch (status.toLowerCase()) {
      case 'pending_division':
        return const Color(0xFFFFC107); // Amber
      case 'pending_ga':
        return const Color(0xFF2196F3); // Blue
      case 'approved':
        return const Color(0xFF4CAF50); // Green
      case 'rejected_division':
      case 'rejected_ga':
        return const Color(0xFFf44336); // Red
      default:
        return Colors.grey;
    }
  }

  String getStatusEmoji() {
    switch (status.toLowerCase()) {
      case 'pending_division':
        return '🟡';
      case 'pending_ga':
        return '🔵';
      case 'approved':
        return '🟢';
      case 'rejected_division':
      case 'rejected_ga':
        return '🔴';
      default:
        return '⚫';
    }
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    try {
      print('🔧 [Booking.fromJson] Parsing: ${json['booking_code']}');
      final booking = Booking(
        id: json['id'] ?? 0,
        userId: json['user_id'] ?? 0, // ✅ Parse user_id
        bookingCode: json['booking_code'] ?? '',
        bookingType: json['booking_type'] ?? '',
        purpose: json['purpose'] ?? '',
        bookingDate: json['booking_date'] ?? '',
        startTime: json['start_time'] ?? '',
        endTime: json['end_time'] ?? '',
        status: json['status'] ?? 'pending_division',
        roomId: json['room_id'],
        vehicleId: json['vehicle_id'],
        participantsCount: json['participants_count'],
        destination: json['destination'],
        divisionApprovalNotes: json['division_approval_notes'],
        gaApprovalNotes: json['ga_approval_notes'] ?? json['divum_approval_notes'],
        approvedByDivision: json['division_approval_by'],
        approvedByDivum: json['ga_approval_by'],
      );
      print('✅ [Booking.fromJson] Success: ${booking.bookingCode}');
      return booking;
    } catch (e, stackTrace) {
      print('❌ [Booking.fromJson] Error: $e');
      print('❌ [Booking.fromJson] JSON: $json');
      print('❌ [Booking.fromJson] Stack: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId, // ✅ Include user_id
      'booking_code': bookingCode,
      'booking_type': bookingType,
      'purpose': purpose,
      'booking_date': bookingDate,
      'start_time': startTime,
      'end_time': endTime,
      'status': status,
      'room_id': roomId,
      'vehicle_id': vehicleId,
      'participants_count': participantsCount,
      'destination': destination,
      'division_approval_notes': divisionApprovalNotes,
      'ga_approval_notes': gaApprovalNotes,
      'division_approval_by': approvedByDivision,
      'ga_approval_by': approvedByDivum,
    };
  }

  // ✅ Helper method to check if booking belongs to a division
  bool isDivisionId(int divisionId) {
    // This can be extended if booking has division_id field
    // For now, return true to show all bookings
    return true;
  }
}


