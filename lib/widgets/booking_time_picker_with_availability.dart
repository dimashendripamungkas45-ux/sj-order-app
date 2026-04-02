// lib/widgets/booking_time_picker_with_availability.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/available_slot_model.dart';
import '../providers/booking_schedule_provider.dart';
import '../services/booking_schedule_service.dart';

/// Widget untuk memilih time slot dengan validasi availability
///
/// Menampilkan:
/// - Dropdown jam dengan hanya slot yang tersedia
/// - Visual indicator untuk jam yang busy/available
/// - Pesan error jika ada conflict
class BookingTimePickerWithAvailability extends StatefulWidget {
  final String bookingType; // 'room' atau 'vehicle'
  final int facilityId;
  final String selectedDate;
  final String? initialStartTime;
  final String? initialEndTime;
  final ValueChanged<String> onStartTimeChanged;
  final ValueChanged<String> onEndTimeChanged;
  final Function(bool)? onAvailabilityChanged;

  const BookingTimePickerWithAvailability({
    Key? key,
    required this.bookingType,
    required this.facilityId,
    required this.selectedDate,
    this.initialStartTime,
    this.initialEndTime,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
    this.onAvailabilityChanged,
  }) : super(key: key);

  @override
  State<BookingTimePickerWithAvailability> createState() =>
      _BookingTimePickerWithAvailabilityState();
}

class _BookingTimePickerWithAvailabilityState
    extends State<BookingTimePickerWithAvailability> {
  String? _selectedStartTime;
  String? _selectedEndTime;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedStartTime = widget.initialStartTime;
    _selectedEndTime = widget.initialEndTime;
    _loadAvailableSlots();
  }

  @override
  void didUpdateWidget(BookingTimePickerWithAvailability oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedDate != widget.selectedDate ||
        oldWidget.facilityId != widget.facilityId) {
      _loadAvailableSlots();
    }
  }

  Future<void> _loadAvailableSlots() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final provider =
          context.read<BookingScheduleProvider>();
      await provider.loadAvailableSlots(
        bookingType: widget.bookingType,
        facilityId: widget.facilityId,
        bookingDate: widget.selectedDate,
      );

      setState(() {
        _isLoading = false;
      });

      widget.onAvailabilityChanged?.call(
        provider.availableSlots.isNotEmpty,
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _checkTimeSlotConflict(String startTime, String endTime) async {
    if (startTime.isEmpty || endTime.isEmpty) return;

    try {
      final provider = context.read<BookingScheduleProvider>();
      await provider.checkAvailability(
        bookingType: widget.bookingType,
        facilityId: widget.facilityId,
        bookingDate: widget.selectedDate,
        startTime: startTime,
        endTime: endTime,
      );

      widget.onAvailabilityChanged?.call(!provider.hasConflict);
    } catch (e) {
      debugPrint('❌ Error checking conflict: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingScheduleProvider>(
      builder: (context, provider, _) {
        if (_isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (_error != null) {
          return Card(
            color: Colors.red.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Error',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error ?? 'Unknown error',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: _loadAvailableSlots,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (provider.availableSlots.isEmpty) {
          return Card(
            color: Colors.orange.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '❌ Tidak Ada Waktu Tersedia',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Semua waktu pada ${widget.selectedDate} sudah terbooking. '
                    'Perlu jeda minimal 30 menit antara booking.',
                    style: const TextStyle(color: Colors.orange),
                  ),
                  if (provider.suggestedDates.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Tanggal tersedia:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...provider.suggestedDates
                        .map((date) => Text('• $date'))
                        .toList(),
                  ],
                ],
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Busy slots info
            if (provider.busySlots.isNotEmpty)
              Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🔴 Waktu Terbooking:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...provider.busySlots.map((slot) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${slot.displayTime} - ${slot.reason}',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),

            // Available slots info
            Card(
              color: Colors.green.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🟢 Waktu Tersedia:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: provider.availableSlots.map((slot) {
                        final isSelected = _selectedStartTime == slot.startTime &&
                            _selectedEndTime == slot.endTime;

                        return FilterChip(
                          label: Text(slot.displayTime),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedStartTime = slot.startTime;
                                _selectedEndTime = slot.endTime;
                              });
                              widget.onStartTimeChanged(slot.startTime);
                              widget.onEndTimeChanged(slot.endTime);
                              _checkTimeSlotConflict(
                                slot.startTime,
                                slot.endTime,
                              );
                            }
                          },
                          backgroundColor: Colors.transparent,
                          selectedColor: Colors.green.shade200,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Selected time display
            if (_selectedStartTime != null && _selectedEndTime != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Waktu Pilihan:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '$_selectedStartTime - $_selectedEndTime',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error message if conflict
            if (provider.hasConflict && provider.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            provider.error ?? '',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Widget untuk menampilkan jadwal lengkap (timeline view)
class FacilityScheduleTimeline extends StatefulWidget {
  final String facilityType; // 'room' atau 'vehicle'
  final int facilityId;
  final String facilityName;
  final String selectedDate;

  const FacilityScheduleTimeline({
    Key? key,
    required this.facilityType,
    required this.facilityId,
    required this.facilityName,
    required this.selectedDate,
  }) : super(key: key);

  @override
  State<FacilityScheduleTimeline> createState() =>
      _FacilityScheduleTimelineState();
}

class _FacilityScheduleTimelineState extends State<FacilityScheduleTimeline> {
  late Timer _pollingTimer;

  @override
  void initState() {
    super.initState();
    _loadBookings();

    // Poll every 15 seconds untuk real-time updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _loadBookings();
    });
  }

  @override
  void dispose() {
    _pollingTimer.cancel();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    try {
      final provider = context.read<BookingScheduleProvider>();
      await provider.loadFacilityBookings(
        facilityType: widget.facilityType,
        facilityId: widget.facilityId,
        bookingDate: widget.selectedDate,
      );
    } catch (e) {
      debugPrint('❌ Error loading bookings: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<BookingScheduleProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final bookings = provider.facilityBookings?['bookings'] as List? ?? [];

        if (bookings.isEmpty) {
          return Card(
            color: Colors.green.shade50,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 32
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Hari ini ${widget.facilityName} belum ada booking',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Semua waktu tersedia',
                    style: TextStyle(
                      color: Colors.green.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index] as Map<String, dynamic>;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 60,
                          color: Colors.blue,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                booking['purpose'] ?? 'No purpose',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.schedule,
                                    size: 14,
                                    color: Colors.grey[600]
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${booking['start_time']} - ${booking['end_time']}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.person,
                                    size: 14,
                                    color: Colors.grey[600]
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    booking['user']?['name'] ?? 'Unknown',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

