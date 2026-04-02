import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../providers/booking_provider.dart';

class CreateBookingScreen extends StatefulWidget {
  const CreateBookingScreen({Key? key}) : super(key: key);

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  // Form key & Controllers
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();
  final _participantsController = TextEditingController();
  final _destinationController = TextEditingController();

  // State variables
  String _bookingType = 'room'; // 'room' atau 'vehicle'
  int? _selectedRoomId;
  int? _selectedVehicleId;
  DateTime? _selectedDate;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = false;
  bool _roomsLoading = false;
  bool _vehiclesLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadVehicles();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    _participantsController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    setState(() => _roomsLoading = true);
    try {
      print('📤 [CreateBooking] Loading available rooms...');
      final result = await ApiService.getAvailableRooms();
      if (result['success']) {
        final roomsList = result['data'] ?? [];
        print('✅ [CreateBooking] Rooms loaded: ${roomsList.length} items');
        setState(() {
          _rooms = List<Map<String, dynamic>>.from(roomsList);
        });
      } else {
        print('❌ [CreateBooking] Failed to load rooms: ${result['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      print('❌ [CreateBooking] Error loading rooms: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading rooms: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _roomsLoading = false);
      }
    }
  }

  Future<void> _loadVehicles() async {
    setState(() => _vehiclesLoading = true);
    try {
      print('📤 [CreateBooking] Loading available vehicles...');
      final result = await ApiService.getAvailableVehicles();
      if (result['success']) {
        final vehiclesList = result['data'] ?? [];
        print('✅ [CreateBooking] Vehicles loaded: ${vehiclesList.length} items');
        setState(() {
          _vehicles = List<Map<String, dynamic>>.from(vehiclesList);
        });
      } else {
        print('❌ [CreateBooking] Failed to load vehicles: ${result['message']}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${result['message']}')),
          );
        }
      }
    } catch (e) {
      print('❌ [CreateBooking] Error loading vehicles: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading vehicles: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _vehiclesLoading = false);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay(hour: 9, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _startTime = picked);
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime ?? TimeOfDay(hour: 10, minute: 0),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _endTime = picked);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _submitBooking() async {
    // Validate form fields first
    if (!_formKey.currentState!.validate()) {
      print('❌ [CreateBooking] Form validation failed');
      return;
    }

    // Validate purpose (must be at least 5 characters for backend)
    if (_purposeController.text.isEmpty || _purposeController.text.length < 5) {
      _showError('Tujuan harus diisi minimal 5 karakter');
      print('❌ [CreateBooking] Purpose validation failed: "${_purposeController.text}"');
      return;
    }

    if (_selectedDate == null) {
      _showError('Pilih tanggal');
      print('❌ [CreateBooking] Date not selected');
      return;
    }

    if (_startTime == null) {
      _showError('Pilih waktu mulai');
      print('❌ [CreateBooking] Start time not selected');
      return;
    }

    if (_endTime == null) {
      _showError('Pilih waktu selesai');
      print('❌ [CreateBooking] End time not selected');
      return;
    }

    // Validate that end_time is after start_time
    if (_endTime!.hour < _startTime!.hour ||
        (_endTime!.hour == _startTime!.hour && _endTime!.minute <= _startTime!.minute)) {
      _showError('Waktu selesai harus lebih besar dari waktu mulai');
      print('❌ [CreateBooking] End time must be after start time');
      print('   Start: ${_startTime!.hour}:${_startTime!.minute.toString().padLeft(2, '0')}');
      print('   End: ${_endTime!.hour}:${_endTime!.minute.toString().padLeft(2, '0')}');
      return;
    }

    if (_bookingType == 'room' && _selectedRoomId == null) {
      _showError('Pilih ruangan');
      print('❌ [CreateBooking] Room not selected');
      return;
    }

    if (_bookingType == 'vehicle' && _selectedVehicleId == null) {
      _showError('Pilih kendaraan');
      print('❌ [CreateBooking] Vehicle not selected');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate!);
      final startTimeStr = '${_startTime!.hour.toString().padLeft(2, '0')}:${_startTime!.minute.toString().padLeft(2, '0')}';
      final endTimeStr = '${_endTime!.hour.toString().padLeft(2, '0')}:${_endTime!.minute.toString().padLeft(2, '0')}';

      // Parse participants count - only required for room type
      int? participantsCount;
      if (_bookingType == 'room') {
        participantsCount = int.tryParse(_participantsController.text);
        if (participantsCount == null || participantsCount <= 0) {
          _showError('Jumlah peserta harus angka positif');
          setState(() => _isLoading = false);
          return;
        }
      } else {
        // For vehicle, participants_count is optional
        participantsCount = int.tryParse(_participantsController.text);
        // If empty or invalid, send null (not 0)
        if (participantsCount != null && participantsCount <= 0) {
          participantsCount = null;
        }
      }

      final bookingData = {
        'booking_type': _bookingType,
        'purpose': _purposeController.text.trim(),
        'booking_date': dateStr,
        'start_time': startTimeStr,
        'end_time': endTimeStr,
        'room_id': _bookingType == 'room' ? _selectedRoomId : null,
        'vehicle_id': _bookingType == 'vehicle' ? _selectedVehicleId : null,
        'participants_count': participantsCount,
        'destination': _destinationController.text.isNotEmpty ? _destinationController.text.trim() : null,
      };

      // Log each field for debugging
      print('📤 [CreateBooking] Building booking data:');
      print('   - booking_type: ${bookingData['booking_type']}');
      print('   - purpose: "${bookingData['purpose']}" (length: ${(bookingData['purpose'] as String).length})');
      print('   - booking_date: ${bookingData['booking_date']}');
      print('   - start_time: ${bookingData['start_time']}');
      print('   - end_time: ${bookingData['end_time']}');
      print('   - room_id: ${bookingData['room_id']}');
      print('   - vehicle_id: ${bookingData['vehicle_id']}');
      print('   - participants_count: ${bookingData['participants_count']}');
      print('   - destination: ${bookingData['destination']}');
      print('📤 [CreateBooking] Full data: $bookingData');

      final result = await ApiService.createBooking(bookingData);

      if (result['success']) {
        _showSuccess(result['message'] ?? 'Pemesanan berhasil dibuat');

        // Refresh booking provider
        if (mounted) {
          Provider.of<BookingProvider>(context, listen: false).refreshBookings();

          // Navigate back
          Navigator.of(context).pop(true);
        }
      } else {
        _showError(result['message'] ?? 'Gagal membuat pemesanan');
      }
    } catch (e) {
      print('❌ [CreateBooking] Error: $e');
      print('❌ [CreateBooking] Stack trace: ${StackTrace.current}');
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Pemesanan Baru'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ===== TIPE PEMESANAN =====
              const Text(
                'Tipe Pemesanan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey.shade50,
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Radio Ruangan Rapat
                    GestureDetector(
                      onTap: () => setState(() => _bookingType = 'room'),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'room',
                            groupValue: _bookingType,
                            onChanged: (value) => setState(() => _bookingType = value!),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Ruangan Rapat',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Radio Kendaraan Kantor
                    GestureDetector(
                      onTap: () => setState(() => _bookingType = 'vehicle'),
                      child: Row(
                        children: [
                          Radio<String>(
                            value: 'vehicle',
                            groupValue: _bookingType,
                            onChanged: (value) => setState(() => _bookingType = value!),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Kendaraan Kantor',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ===== PILIH RUANGAN / KENDARAAN =====
              if (_bookingType == 'room')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Ruangan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_roomsLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_rooms.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Tidak ada ruangan tersedia'),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedRoomId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: '-- Pilih Ruangan --',
                        ),
                        items: _rooms.map((room) {
                          final roomName = room['name'] ?? 'Unknown';
                          final capacity = room['capacity'] ?? 0;
                          // Display: "Room Name (X orang)" - more compact
                          final displayText = '$roomName ($capacity orang)';

                          return DropdownMenuItem<int>(
                            value: room['id'],
                            child: Text(
                              displayText,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedRoomId = value),
                        validator: (value) {
                          if (_bookingType == 'room' && value == null) {
                            return 'Pilih ruangan';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pilih Kendaraan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_vehiclesLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_vehicles.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text('Tidak ada kendaraan tersedia'),
                      )
                    else
                      DropdownButtonFormField<int>(
                        value: _selectedVehicleId,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: '-- Pilih Kendaraan --',
                        ),
                        items: _vehicles.map((vehicle) {
                          final vehicleName = vehicle['name'] ?? 'Unknown';
                          final licensePlate = vehicle['license_plate'] ?? '';
                          // Display: "Name (LICENSE_PLATE)"
                          final displayText = licensePlate.isNotEmpty
                              ? '$vehicleName ($licensePlate)'
                              : vehicleName;

                          return DropdownMenuItem<int>(
                            value: vehicle['id'],
                            child: Text(displayText),
                          );
                        }).toList(),
                        onChanged: (value) => setState(() => _selectedVehicleId = value),
                        validator: (value) {
                          if (_bookingType == 'vehicle' && value == null) {
                            return 'Pilih kendaraan';
                          }
                          return null;
                        },
                      ),
                    const SizedBox(height: 24),
                  ],
                ),

              // ===== JUMLAH PESERTA (required untuk ruangan, optional untuk kendaraan) =====
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Jumlah Peserta${_bookingType == 'room' ? '' : ' (Opsional)'}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _participantsController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: _bookingType == 'room'
                          ? 'Masukkan jumlah peserta'
                          : 'Masukkan jumlah peserta (opsional)',
                    ),
                    validator: (value) {
                      if (_bookingType == 'room') {
                        if (value == null || value.isEmpty) {
                          return 'Masukkan jumlah peserta';
                        }
                        final count = int.tryParse(value);
                        if (count == null || count <= 0) {
                          return 'Jumlah peserta harus angka positif (minimal 1)';
                        }
                      } else {
                        // For vehicle, if filled, must be a valid positive number
                        if (value != null && value.isNotEmpty) {
                          final count = int.tryParse(value);
                          if (count == null || count <= 0) {
                            return 'Jumlah peserta harus angka positif (jika diisi)';
                          }
                        }
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),

              // ===== TANGGAL =====
              const Text(
                'Tanggal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
                            : 'Pilih Tanggal',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedDate != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== WAKTU MULAI =====
              const Text(
                'Waktu Mulai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectStartTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        _startTime != null
                            ? _startTime!.format(context)
                            : 'Pilih Waktu Mulai',
                        style: TextStyle(
                          fontSize: 14,
                          color: _startTime != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== WAKTU SELESAI =====
              const Text(
                'Waktu Selesai',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _selectEndTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: Colors.blue),
                      const SizedBox(width: 12),
                      Text(
                        _endTime != null
                            ? _endTime!.format(context)
                            : 'Pilih Waktu Selesai',
                        style: TextStyle(
                          fontSize: 14,
                          color: _endTime != null ? Colors.black : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ===== TUJUAN / DESTINATION =====
              Text(
                _bookingType == 'vehicle' ? 'Tujuan Perjalanan' : 'Tujuan',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _purposeController,
                maxLines: 3,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  hintText: 'Jelaskan tujuan atau keperluan pemesanan ini (minimal 10 karakter)',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Masukkan tujuan pemesanan';
                  }
                  if (value.length < 10) {
                    return 'Tujuan minimal 10 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Destination field (hanya untuk vehicle)
              if (_bookingType == 'vehicle') ...[
                const SizedBox(height: 12),
                const Text(
                  'Tujuan Perjalanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _destinationController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    hintText: 'Contoh: Kantor Proyek Ciangkap',
                  ),
                ),
                const SizedBox(height: 24),
              ] else
                const SizedBox(height: 24),

              // ===== KETENTUAN PEMESANAN (Collapsible) =====
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    'Ketentuan Pemesanan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRequirementItem('Pemesanan hanya dapat dilakukan untuk hari Senin - Jumat'),
                          _buildRequirementItem('Jam operasional: 08:00 - 17:00'),
                          _buildRequirementItem('Pemesanan memerlukan persetujuan Pimpinan Divisi'),
                          _buildRequirementItem('Persetujuan final dari DIVUM'),
                          _buildRequirementItem('Pastikan tidak ada jadwal yang bertabrakan'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ===== ALUR PERSETUJUAN (Collapsible) =====
              Theme(
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  title: const Text(
                    'Alur Persetujuan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildApprovalStep(
                            number: '1',
                            title: 'Pengajuan',
                            description: 'Karyawan mengajukan pemesanan',
                            backgroundColor: Colors.blue,
                          ),
                          const SizedBox(height: 16),
                          _buildApprovalStep(
                            number: '2',
                            title: 'Persetujuan Divisi',
                            description: 'Pimpinan divisi meninjau',
                            backgroundColor: Colors.amber,
                          ),
                          const SizedBox(height: 16),
                          _buildApprovalStep(
                            number: '3',
                            title: 'Persetujuan DIVUM',
                            description: 'Admin DIVUM memberikan persetujuan final',
                            backgroundColor: Colors.cyan,
                          ),
                          const SizedBox(height: 16),
                          _buildApprovalStep(
                            number: '4',
                            title: 'Disetujui',
                            description: 'Pemesanan dikonfirmasi',
                            backgroundColor: Colors.green,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // ===== SUBMIT BUTTON =====
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Kirim Pemesanan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApprovalStep({
    required String number,
    required String title,
    required String description,
    required Color backgroundColor,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}




