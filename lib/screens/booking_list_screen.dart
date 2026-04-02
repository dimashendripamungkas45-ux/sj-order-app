import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';

class BookingListScreen extends StatefulWidget {
  const BookingListScreen({Key? key}) : super(key: key);

  @override
  State<BookingListScreen> createState() => _BookingListScreenState();
}

class _BookingListScreenState extends State<BookingListScreen> {
  String _selectedStatus = 'Semua';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_division':
        return const Color(0xFFFFC107); // Yellow
      case 'pending_divum':
        return const Color(0xFF2196F3); // Blue
      case 'approved':
        return const Color(0xFF4CAF50); // Green
      case 'rejected_division':
      case 'rejected_divum':
      case 'rejected':
        return const Color(0xFFf44336); // Red
      default:
        return const Color(0xFF999999); // Gray
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_division':
        return 'Menunggu Divisi';
      case 'pending_divum':
        return 'Menunggu GA';
      case 'approved':
        return 'Disetujui';
      case 'rejected_division':
      case 'rejected_divum':
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _getBookingTypeLabel(String type) {
    return type.toLowerCase() == 'room' ? 'Ruangan' : 'Kendaraan';
  }

  IconData _getBookingTypeIcon(String type) {
    return type.toLowerCase() == 'room' ? Icons.apartment : Icons.directions_car;
  }

  Widget _buildStatusChip(String label, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(
            color: color,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : color,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Pemesanan'),
            backgroundColor: Colors.white,
            elevation: 1,
            foregroundColor: Colors.black,
            actions: [
              IconButton(
                onPressed: () {
                  // Show search dialog
                  showSearch(
                    context: context,
                    delegate: BookingSearchDelegate(
                      onSearch: (query) {
                        setState(() {
                          _searchQuery = query;
                        });
                      },
                    ),
                  );
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          body: Consumer<BookingProvider>(
            builder: (context, bookingProvider, _) {
              List<dynamic> bookings = bookingProvider.bookings;

              // Filter by selected status
              if (_selectedStatus != 'Semua') {
                bookings = bookings
                    .where((booking) =>
                        _getStatusLabel(booking.status) == _selectedStatus)
                    .toList();
              }

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                bookings = bookings
                    .where((booking) =>
                        booking.bookingCode
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()) ||
                        booking.purpose
                            .toLowerCase()
                            .contains(_searchQuery.toLowerCase()))
                    .toList();
              }

              if (bookingProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (bookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Belum Ada Pemesanan',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Tidak ada hasil untuk "$_searchQuery"'
                            : 'Anda belum memiliki pemesanan apapun',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status Filter Chips
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildStatusChip(
                              'Semua',
                              const Color(0xFF999999),
                              _selectedStatus == 'Semua',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              'Menunggu Divisi',
                              const Color(0xFFFFC107),
                              _selectedStatus == 'Menunggu Divisi',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              'Menunggu GA',
                              const Color(0xFF2196F3),
                              _selectedStatus == 'Menunggu GA',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              'Disetujui',
                              const Color(0xFF4CAF50),
                              _selectedStatus == 'Disetujui',
                            ),
                            const SizedBox(width: 8),
                            _buildStatusChip(
                              'Ditolak',
                              const Color(0xFFf44336),
                              _selectedStatus == 'Ditolak',
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Booking Cards
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: bookings.length,
                        itemBuilder: (context, index) {
                          final booking = bookings[index];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildBookingCard(booking),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final statusLabel = _getStatusLabel(booking.status);
    final statusColor = _getStatusColor(booking.status);
    final bookingType = _getBookingTypeLabel(booking.bookingType);
    final bookingTypeIcon = _getBookingTypeIcon(booking.bookingType);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Top Section - Code, Type, Date
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Code
                Text(
                  'KODE: ${booking.bookingCode}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                // Type and Date Row
                Row(
                  children: [
                    Icon(bookingTypeIcon, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      bookingType,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '•',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      booking.bookingDate,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Time
                Text(
                  '${booking.startTime} - ${booking.endTime}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey.shade200),
          // Card Middle Section - Resource Name
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  booking.bookingType.toLowerCase() == 'room'
                      ? Icons.apartment
                      : Icons.directions_car,
                  size: 20,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.bookingType.toLowerCase() == 'room' ? 'Ruangan' : 'Kendaraan',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.purpose,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Divider
          Divider(height: 1, color: Colors.grey.shade200),
          // Card Bottom Section - Status and Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    statusLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                ),
                // Action Buttons
                Row(
                  children: [
                    // Detail Button (Eye Icon)
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          '/booking-detail',
                          arguments: booking.id,
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.visibility,
                          size: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    // ✅ Employee cannot approve/reject - removed these buttons
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BookingSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  BookingSearchDelegate({required this.onSearch});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
          onSearch('');
        },
        icon: const Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: const Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    onSearch(query);
    return const SizedBox.shrink();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Cari berdasarkan kode booking atau tujuan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    onSearch(query);
    return const SizedBox.shrink();
  }
}

