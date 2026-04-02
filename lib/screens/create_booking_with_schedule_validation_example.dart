// lib/screens/create_booking_with_schedule_validation_example.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_schedule_provider.dart';
import '../services/booking_schedule_service.dart';
import '../widgets/booking_time_picker_with_availability.dart';

/// EXAMPLE: Create Booking Screen dengan Schedule Validation
///
/// Ini adalah contoh lengkap bagaimana mengintegrasikan:
/// - Schedule validation sebelum booking
/// - Time picker dengan available slots
/// - Conflict notification
/// - Real-time schedule view
///
/// MODIFY sesuai desain aplikasi Anda
class CreateBookingWithScheduleValidationScreen extends StatefulWidget {
  final String token;
  final String apiBaseUrl;

  const CreateBookingWithScheduleValidationScreen({
    Key? key,
    required this.token,
    required this.apiBaseUrl,
  }) : super(key: key);

  @override
  State<CreateBookingWithScheduleValidationScreen> createState() =>
      _CreateBookingWithScheduleValidationScreenState();
}

class _CreateBookingWithScheduleValidationScreenState
    extends State<CreateBookingWithScheduleValidationScreen> {
  // Form state
  String? _selectedBookingType = 'room';
  int? _selectedFacilityId;
  String? _selectedFacilityName;
  DateTime? _selectedDate;
  String? _selectedStartTime;
  String? _selectedEndTime;
  String _selectedPurpose = '';
  int? _participantsCount;
  String? _destination;
  bool _isTimeAvailable = true;
  bool _isSubmitting = false;

  // Data
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      // TODO: Call API untuk load rooms dan vehicles
      // Contoh:
      // final response = await http.get(
      //   Uri.parse('${widget.apiBaseUrl}/api/available-rooms'),
      //   headers: {'Authorization': 'Bearer ${widget.token}'},
      // );
    } catch (e) {
      debugPrint('❌ Error loading facilities: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedStartTime = null;
        _selectedEndTime = null;
      });
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedFacilityId == null ||
        _selectedDate == null ||
        _selectedStartTime == null ||
        _selectedEndTime == null ||
        _selectedPurpose.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi semua data!')),
      );
      return;
    }

    if (!_isTimeAvailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waktu tidak tersedia! Pilih waktu lain.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // TODO: Call API untuk create booking
      // final response = await http.post(
      //   Uri.parse('${widget.apiBaseUrl}/api/bookings'),
      //   headers: {
      //     'Authorization': 'Bearer ${widget.token}',
      //     'Content-Type': 'application/json',
      //   },
      //   body: jsonEncode({
      //     'booking_type': _selectedBookingType,
      //     'room_id': _selectedBookingType == 'room' ? _selectedFacilityId : null,
      //     'vehicle_id': _selectedBookingType == 'vehicle' ? _selectedFacilityId : null,
      //     'booking_date': BookingScheduleService.dateTimeToDateString(_selectedDate!),
      //     'start_time': _selectedStartTime,
      //     'end_time': _selectedEndTime,
      //     'purpose': _selectedPurpose,
      //     'participants_count': _participantsCount,
      //     'destination': _destination,
      //   }),
      // );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Booking berhasil dibuat! Menunggu persetujuan...'),
            backgroundColor: Colors.green,
          ),
        );

        // TODO: Navigate ke booking detail atau list
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => BookingScheduleProvider(
            BookingScheduleService(
              baseUrl: widget.apiBaseUrl,
              token: widget.token,
            ),
          ),
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Buat Pemesanan Fasilitas'),
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ========== BOOKING TYPE ==========
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Jenis Pemesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SegmentedButton<String>(
                        segments: const [
                          ButtonSegment(
                            value: 'room',
                            label: Text('🏢 Ruangan'),
                          ),
                          ButtonSegment(
                            value: 'vehicle',
                            label: Text('🚗 Kendaraan'),
                          ),
                        ],
                        selected: {_selectedBookingType ?? 'room'},
                        onSelectionChanged: (value) {
                          setState(() {
                            _selectedBookingType = value.first;
                            _selectedFacilityId = null;
                            _selectedFacilityName = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ========== FACILITY SELECTION ==========
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedBookingType == 'room'
                            ? 'Pilih Ruangan'
                            : 'Pilih Kendaraan',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButton<int>(
                        value: _selectedFacilityId,
                        hint: const Text('- Pilih -'),
                        isExpanded: true,
                        items: (_selectedBookingType == 'room'
                                ? _rooms
                                : _vehicles)
                            .map((facility) {
                          return DropdownMenuItem(
                            value: facility['id'] as int,
                            child: Text(facility['name'] ?? 'Unknown'),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedFacilityId = value;
                            _selectedFacilityName = (_selectedBookingType == 'room'
                                    ? _rooms
                                    : _vehicles)
                                .firstWhere((f) => f['id'] == value)['name'];
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ========== DATE SELECTION ==========
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggal Pemesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today),
                              const SizedBox(width: 12),
                              Text(
                                _selectedDate == null
                                    ? 'Pilih Tanggal'
                                    : '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // ========== TIME PICKER WITH AVAILABILITY ==========
              if (_selectedBookingType != null &&
                  _selectedFacilityId != null &&
                  _selectedDate != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Waktu',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        BookingTimePickerWithAvailability(
                          bookingType: _selectedBookingType!,
                          facilityId: _selectedFacilityId!,
                          selectedDate: BookingScheduleService.dateTimeToDateString(
                            _selectedDate!,
                          ),
                          initialStartTime: _selectedStartTime,
                          initialEndTime: _selectedEndTime,
                          onStartTimeChanged: (time) {
                            setState(() => _selectedStartTime = time);
                          },
                          onEndTimeChanged: (time) {
                            setState(() => _selectedEndTime = time);
                          },
                          onAvailabilityChanged: (available) {
                            setState(() => _isTimeAvailable = available);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ========== SCHEDULE TIMELINE ==========
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Jadwal Fasilitas',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        FacilityScheduleTimeline(
                          facilityType: _selectedBookingType!,
                          facilityId: _selectedFacilityId!,
                          facilityName: _selectedFacilityName ?? 'Fasilitas',
                          selectedDate: BookingScheduleService.dateTimeToDateString(
                            _selectedDate!,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // ========== DETAILS ==========
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Detail Pemesanan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Tujuan Pemesanan *',
                          hintText: 'Contoh: Rapat Tim, Meeting Client',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        minLines: 2,
                        maxLines: 3,
                        onChanged: (value) {
                          setState(() => _selectedPurpose = value);
                        },
                      ),
                      const SizedBox(height: 12),
                      if (_selectedBookingType == 'room')
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Jumlah Peserta',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              _participantsCount = int.tryParse(value);
                            });
                          },
                        ),
                      if (_selectedBookingType == 'vehicle') ...[
                        const SizedBox(height: 12),
                        TextField(
                          decoration: InputDecoration(
                            labelText: 'Tujuan Perjalanan',
                            hintText: 'Contoh: Kantor Cabang, Meeting Klien',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() => _destination = value);
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ========== SUBMIT BUTTON ==========
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isSubmitting || !_isTimeAvailable
                      ? null
                      : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.grey,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Buat Pemesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

