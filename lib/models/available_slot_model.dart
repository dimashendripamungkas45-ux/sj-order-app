// lib/models/available_slot_model.dart

class AvailableSlot {
  final String startTime;  // Format: "08:00"
  final String endTime;    // Format: "09:00"

  AvailableSlot({
    required this.startTime,
    required this.endTime,
  });

  factory AvailableSlot.fromJson(Map<String, dynamic> json) {
    return AvailableSlot(
      startTime: json['start'] ?? '',
      endTime: json['end'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'start': startTime,
    'end': endTime,
  };

  // Untuk display di UI
  String get displayTime => '$startTime - $endTime';
}

class BusySlot {
  final String startTime;
  final String endTime;
  final String reason;

  BusySlot({
    required this.startTime,
    required this.endTime,
    required this.reason,
  });

  factory BusySlot.fromJson(Map<String, dynamic> json) {
    return BusySlot(
      startTime: json['start'] ?? '',
      endTime: json['end'] ?? '',
      reason: json['reason'] ?? 'Tersedia',
    );
  }

  String get displayTime => '$startTime - $endTime';
}

class FacilityAvailability {
  final int facilityId;
  final String facilityName;
  final String facilityType; // 'room' atau 'vehicle'
  final String bookingDate;
  final int intervalMinutes;
  final List<AvailableSlot> availableSlots;
  final List<BusySlot> busySlots;
  final Map<String, String> operatingHours;

  FacilityAvailability({
    required this.facilityId,
    required this.facilityName,
    required this.facilityType,
    required this.bookingDate,
    required this.intervalMinutes,
    required this.availableSlots,
    required this.busySlots,
    required this.operatingHours,
  });

  factory FacilityAvailability.fromJson(Map<String, dynamic> json) {
    var facility = json['facility'] as Map<String, dynamic>? ?? {};
    var slotsJson = json['available_slots'] as List? ?? [];
    var busyJson = json['busy_slots'] as List? ?? [];
    var operatingJson = json['operating_hours'] as Map<String, dynamic>? ?? {};

    return FacilityAvailability(
      facilityId: facility['id'] ?? 0,
      facilityName: facility['name'] ?? 'Unknown',
      facilityType: facility['type'] ?? 'room',
      bookingDate: json['date'] ?? '',
      intervalMinutes: json['interval_minutes'] ?? 30,
      availableSlots: slotsJson
          .map((s) => AvailableSlot.fromJson(s as Map<String, dynamic>))
          .toList(),
      busySlots: busyJson
          .map((b) => BusySlot.fromJson(b as Map<String, dynamic>))
          .toList(),
      operatingHours: {
        'start': operatingJson['start'] ?? '08:00',
        'end': operatingJson['end'] ?? '17:00',
      },
    );
  }

  // Check apakah slot tersedia
  bool isSlotAvailable(String startTime, String endTime) {
    return availableSlots.any((slot) =>
      slot.startTime == startTime && slot.endTime == endTime
    );
  }

  // Get list jam tersedia (tanpa minutes)
  List<String> getAvailableHours() {
    return availableSlots
        .map((s) => s.startTime.split(':')[0])
        .toSet()
        .toList();
  }
}

class BookingConflict {
  final int conflictId;
  final String bookingCode;
  final String startTime;
  final String endTime;
  final String purpose;

  BookingConflict({
    required this.conflictId,
    required this.bookingCode,
    required this.startTime,
    required this.endTime,
    required this.purpose,
  });

  factory BookingConflict.fromJson(Map<String, dynamic> json) {
    return BookingConflict(
      conflictId: json['id'] ?? 0,
      bookingCode: json['booking_code'] ?? '',
      startTime: json['start_time'] ?? '',
      endTime: json['end_time'] ?? '',
      purpose: json['purpose'] ?? '',
    );
  }

  String get conflictMessage =>
      'Bentrok dengan booking $bookingCode ($startTime-$endTime): $purpose';
}

class AvailabilityCheckResult {
  final bool available;
  final String message;
  final List<BookingConflict> conflicts;

  AvailabilityCheckResult({
    required this.available,
    required this.message,
    required this.conflicts,
  });

  factory AvailabilityCheckResult.fromJson(Map<String, dynamic> json) {
    var conflictsJson = json['conflicts'] as List? ?? [];

    return AvailabilityCheckResult(
      available: json['available'] ?? false,
      message: json['message'] ?? 'Unknown error',
      conflicts: conflictsJson
          .map((c) => BookingConflict.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}

