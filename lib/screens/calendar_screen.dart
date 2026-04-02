import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentDate;
  String _selectedType = 'Semua';
  String _viewMode = 'Bulan'; // ✅ ADD: Track current view mode
  final List<String> _filterTypes = ['Semua', 'Ruangan', 'Kendaraan'];
  final Map<String, Color> _statusColors = {
    'Menunggu Divisi': const Color(0xFFFFC107),
    'Menunggu GA': const Color(0xFF2196F3),
    'Disetujui': const Color(0xFF4CAF50),
    'Ditolak': const Color(0xFFf44336),
  };

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  void _previousMonth() {
    setState(() {
      if (_viewMode == 'Bulan') {
        // Previous month
        _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
      } else if (_viewMode == 'Minggu') {
        // Previous week (7 days)
        _currentDate = _currentDate.subtract(const Duration(days: 7));
      } else if (_viewMode == 'Hari') {
        // Previous day
        _currentDate = _currentDate.subtract(const Duration(days: 1));
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_viewMode == 'Bulan') {
        // Next month
        _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
      } else if (_viewMode == 'Minggu') {
        // Next week (7 days)
        _currentDate = _currentDate.add(const Duration(days: 7));
      } else if (_viewMode == 'Hari') {
        // Next day
        _currentDate = _currentDate.add(const Duration(days: 1));
      }
    });
  }

  void _goToToday() {
    setState(() {
      _currentDate = DateTime.now();
    });
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  String _getShortDayName(int day) {
    const days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return days[day];
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_division':
        return 'Menunggu Divisi';
      case 'pending_ga':
        return 'Menunggu GA';
      case 'approved':
        return 'Disetujui';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  List<dynamic> _getBookingsForDate(DateTime date, List<dynamic> allBookings) {
    return allBookings.where((booking) {
      final bookingDate = DateTime.parse(booking.bookingDate);
      return bookingDate.year == date.year &&
          bookingDate.month == date.month &&
          bookingDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Pemesanan'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          final bookings = bookingProvider.bookings;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Year Header
                Center(
                  child: Text(
                    '${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Navigation Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _previousMonth,
                      icon: const Icon(Icons.chevron_left),
                      label: const Text(''),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton(
                      onPressed: _goToToday,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Hari Ini'),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _nextMonth,
                      icon: const Text(''),
                      label: const Icon(Icons.chevron_right),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // View Mode Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _viewMode = 'Bulan');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _viewMode == 'Bulan' ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                        foregroundColor: _viewMode == 'Bulan' ? Colors.white : Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Bulan'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _viewMode = 'Minggu');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _viewMode == 'Minggu' ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                        foregroundColor: _viewMode == 'Minggu' ? Colors.white : Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Minggu'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => _viewMode = 'Hari');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _viewMode == 'Hari' ? const Color(0xFF4CAF50) : Colors.grey.shade300,
                        foregroundColor: _viewMode == 'Hari' ? Colors.white : Colors.grey.shade600,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      child: const Text('Hari'),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // ✅ CONDITIONAL: Show different view based on _viewMode
                if (_viewMode == 'Bulan')
                  _buildCalendarGrid(bookings)
                else if (_viewMode == 'Minggu')
                  _buildWeekView(bookings)
                else
                  _buildDayView(bookings),
                const SizedBox(height: 24),

                // Filter Section (Collapsible)
                _buildCollapsibleSection(
                  title: 'Filter',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tipe Pemesanan',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(6),
                          color: Colors.white,
                        ),
                        child: DropdownButton<String>(
                          value: _selectedType,
                          isExpanded: true,
                          underline: const SizedBox(),
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          items: _filterTypes.map((type) {
                            return DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedType = value;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Legend Section (Collapsible)
                _buildCollapsibleSection(
                  title: 'Keterangan',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ..._statusColors.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: entry.value,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                entry.key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF666666),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Create Booking Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed('/create-booking');
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: const Text('Buat Pemesanan Baru'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required Widget child,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: child,
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<dynamic> bookings) {
    final firstDay = DateTime(_currentDate.year, _currentDate.month, 1);
    final lastDay = DateTime(_currentDate.year, _currentDate.month + 1, 0);
    final daysInMonth = lastDay.day;
    final firstWeekday = firstDay.weekday;

    // Day names
    List<Widget> dayNames = [];
    for (int i = 0; i < 7; i++) {
      dayNames.add(
        Center(
          child: Text(
            _getShortDayName(i),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
        ),
      );
    }

    // Calendar days
    List<Widget> days = [];

    // Empty cells for days before month starts
    for (int i = 1; i < firstWeekday; i++) {
      days.add(const SizedBox());
    }

    // Days of the month
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentDate.year, _currentDate.month, day);
      final dayBookings = _getBookingsForDate(date, bookings);

      days.add(
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(6),
            color: Colors.white,
          ),
          padding: const EdgeInsets.all(4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$day',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: dayBookings.take(1).map((booking) {
                      final status = _getStatusLabel(booking.status);
                      final color = _statusColors[status] ?? Colors.grey;
                      final timeStr = booking.startTime.substring(0, 5);
                      final resourceType = booking.bookingType == 'room' ? 'Ruangan' : 'Kendaraan';

                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                        margin: const EdgeInsets.only(bottom: 1),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '🟢 $timeStr $resourceType',
                          style: TextStyle(
                            fontSize: 7,
                            color: color,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              if (dayBookings.length > 1)
                Text(
                  '+${dayBookings.length - 1}',
                  style: const TextStyle(
                    fontSize: 7,
                    color: Color(0xFF999999),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 4,
      crossAxisSpacing: 4,
      childAspectRatio: 0.85,
      children: [
        ...dayNames,
        ...days,
      ],
    );
  }

  // ✅ BUILD WEEK VIEW
  Widget _buildWeekView(List<dynamic> bookings) {
    // Get Monday of current week
    final now = _currentDate;
    final monday = now.subtract(Duration(days: now.weekday - 1));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Week header
        Text(
          '${monday.day} - ${monday.add(const Duration(days: 6)).day} ${_getMonthName(monday.month)} ${monday.year}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
        ),
        const SizedBox(height: 16),

        // Days of week
        ListView(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: List.generate(7, (index) {
            final date = monday.add(Duration(days: index));
            final dayBookings = _getBookingsForDate(date, bookings);
            final dayName = _getShortDayName(date.weekday % 7);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$dayName, ${date.day}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (dayBookings.isEmpty)
                    const Text(
                      'Tidak ada pemesanan',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: dayBookings.map((booking) {
                        final status = _getStatusLabel(booking.status);
                        final color = _statusColors[status] ?? Colors.grey;
                        final timeStr = booking.startTime.substring(0, 5);
                        final resourceType = booking.bookingType == 'room' ? 'Ruangan' : 'Kendaraan';

                        return Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: color.withValues(alpha: 0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '🕐 $timeStr - ${booking.endTime.substring(0, 5)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '$resourceType: ${booking.purpose}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF666666),
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  status,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // ✅ BUILD DAY VIEW
  Widget _buildDayView(List<dynamic> bookings) {
    final dayBookings = _getBookingsForDate(_currentDate, bookings);
    final dayName = _getShortDayName(_currentDate.weekday % 7);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF4CAF50)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$dayName, ${_currentDate.day} ${_getMonthName(_currentDate.month)} ${_currentDate.year}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${dayBookings.length} pemesanan',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF666666),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (dayBookings.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_available, size: 48, color: Colors.grey),
                SizedBox(height: 12),
                Text(
                  'Tidak ada pemesanan pada hari ini',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dayBookings.length,
            itemBuilder: (context, index) {
              final booking = dayBookings[index];
              final status = _getStatusLabel(booking.status);
              final color = _statusColors[status] ?? Colors.grey;
              final resourceType = booking.bookingType == 'room' ? '🏢 Ruangan' : '🚗 Kendaraan';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${booking.startTime.substring(0, 5)} - ${booking.endTime.substring(0, 5)}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF333333),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resourceType,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      booking.purpose,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF666666),
                      ),
                    ),
                    if (booking.participantsCount != null && booking.participantsCount! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '👥 ${booking.participantsCount} peserta',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}


