import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';
import '../models/booking_model.dart';

class DaftarPemesananScreen extends StatefulWidget {
  const DaftarPemesananScreen({Key? key}) : super(key: key);

  @override
  State<DaftarPemesananScreen> createState() => _DaftarPemesananScreenState();
}

class _DaftarPemesananScreenState extends State<DaftarPemesananScreen> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    print('📱 [DaftarPemesananScreen] initState called');

    // Fetch bookings when screen loads
    Future.microtask(() {
      print('🔄 [DaftarPemesananScreen] Microtask - fetching bookings...');
      final provider = Provider.of<BookingProvider>(context, listen: false);
      print('📊 [DaftarPemesananScreen] Current bookings in provider: ${provider.bookings.length}');
      provider.fetchBookings();
      print('✅ [DaftarPemesananScreen] fetchBookings() called');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff00b477),
        title: const Text('Daftar Pemesanan'),
        elevation: 0,
      ),
      body: Consumer2<BookingProvider, RoleProvider>(
        builder: (context, bookingProvider, roleProvider, _) {
          // Filter bookings based on role and status
          List<Booking> filteredBookings = _getFilteredBookings(
            bookingProvider,
            roleProvider,
          );

          return Column(
            children: [
              // Filter Status (Horizontal Scroll)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildFilterChip(
                      label: 'Semua',
                      isSelected: _selectedFilter == 'all',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'all';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Divisi',
                      isSelected: _selectedFilter == 'pending_division',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'pending_division';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'GA',
                      isSelected: _selectedFilter == 'pending_ga',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'pending_ga';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Disetujui',
                      isSelected: _selectedFilter == 'approved',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'approved';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      label: 'Ditolak',
                      isSelected: _selectedFilter == 'rejected',
                      onTap: () {
                        setState(() {
                          _selectedFilter = 'rejected';
                        });
                      },
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Cari pemesanan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),

              // Booking List
              Expanded(
                child: bookingProvider.isLoading
                    ? const Center(
                  child: CircularProgressIndicator(),
                )
                    : filteredBookings.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info,
                        size: 48,
                        color: Colors.orange.shade300,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum Ada Pemesanan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF666666),
                        ),
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredBookings.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildBookingCard(
                        filteredBookings[index],
                        roleProvider,
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFFFFC107),
      side: BorderSide(
        color: isSelected ? const Color(0xFFFFC107) : Colors.grey.shade300,
      ),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.grey.shade700,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, RoleProvider roleProvider) {
    final isDivisionalLeader = roleProvider.isDivisionalLeader;
    final isDivumAdmin = roleProvider.isDivumAdmin;

    // Check if user can approve this booking
    bool canApprove = false;
    if (isDivisionalLeader && booking.isPendingDivision) {
      canApprove = true;
    } else if (isDivumAdmin && booking.isPendingGA) {
      canApprove = true;
    }

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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Booking Code & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                booking.bookingCode,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              Text(
                '${booking.bookingDate} • ${booking.startTime}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),

          // Room/Vehicle Name (Purpose)
          Row(
            children: [
              Text(
                booking.bookingType.toLowerCase() == 'room'
                    ? '🏢'
                    : '🚗',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  booking.purpose,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Divider
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 12),

          // Status Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: booking.getStatusColor().withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  booking.getStatusEmoji(),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 4),
                Text(
                  booking.getStatusLabelIndonesian(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: booking.getStatusColor(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Divider
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),

          // Action Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Detail Button (Icon Eye)
              GestureDetector(
                onTap: () {
                  _showBookingDetailDialog(booking);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(
                    Icons.visibility,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Approve Button (if can approve)
              if (canApprove) ...[
                GestureDetector(
                  onTap: () {
                    _showApprovalDialog(booking, true);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Setujui',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reject Button
                GestureDetector(
                  onTap: () {
                    _showApprovalDialog(booking, false);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.close, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Tolak',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ✅ NEW: Detail Dialog
  void _showBookingDetailDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Detail Pemesanan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Booking Code - using Column instead of Row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kode Pemesanan',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    booking.bookingCode,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date & Time - using Column instead of Row
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tanggal & Waktu',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.bookingDate} • ${booking.startTime} - ${booking.endTime}',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              const Divider(),
              const SizedBox(height: 12),

              // Resource Type & Name
              Row(
                children: [
                  Text(
                    booking.bookingType.toLowerCase() == 'room' ? '🏢' : '🚗',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ruangan/Kendaraan',
                          style: TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                        Text(
                          booking.purpose,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Purpose
              const Text(
                'Keperluan',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
              const SizedBox(height: 4),
              Text(
                booking.purpose,
                style: const TextStyle(fontSize: 12),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
              const SizedBox(height: 12),

              // Participants
              if (booking.participantsCount != null && booking.participantsCount! > 0)
                Row(
                  children: [
                    const Text(
                      '👤 Peserta: ',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    Text(
                      '${booking.participantsCount} orang',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),

              // Destination
              if (booking.destination != null && booking.destination!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text(
                      '📍 Tujuan: ',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    Expanded(
                      child: Text(
                        booking.destination!,
                        style: const TextStyle(fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Status
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: booking.getStatusColor().withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      booking.getStatusLabelIndonesian(),
                      style: TextStyle(
                        color: booking.getStatusColor(),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              // Approval Notes (if available)
              if (booking.divisionApprovalNotes != null &&
                  booking.divisionApprovalNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Catatan Divisi',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.divisionApprovalNotes!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],

              if (booking.gaApprovalNotes != null &&
                  booking.gaApprovalNotes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Catatan GA',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    booking.gaApprovalNotes!,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(Booking booking, bool isApprove) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle : Icons.cancel,
              color: isApprove ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 12),
            Text(
              isApprove ? 'Setujui Pemesanan?' : 'Tolak Pemesanan?',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApprove
                  ? 'Pemesanan akan diteruskan ke tahap berikutnya'
                  : 'Pemesanan akan ditolak',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              try {
                final bookingProvider =
                Provider.of<BookingProvider>(context, listen: false);
                final roleProvider =
                Provider.of<RoleProvider>(context, listen: false);

                bool success = false;
                if (roleProvider.isDivisionalLeader) {
                  success = await bookingProvider.approveDivision(
                    bookingId: booking.id,
                    action: isApprove ? 'approve' : 'reject',
                    notes: notesController.text,
                  );
                } else if (roleProvider.isDivumAdmin) {
                  success = await bookingProvider.approveDivum(
                    bookingId: booking.id,
                    action: isApprove ? 'approve' : 'reject',
                    notes: notesController.text,
                  );
                }

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isApprove
                            ? '✅ Pemesanan Disetujui'
                            : '❌ Pemesanan Ditolak',
                      ),
                      backgroundColor: isApprove ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  // Refresh bookings
                  await bookingProvider.fetchBookings();
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${bookingProvider.error}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  List<Booking> _getFilteredBookings(
      BookingProvider bookingProvider,
      RoleProvider roleProvider,
      ) {
    List<Booking> bookings = [];

    // Get all bookings
    bookings = bookingProvider.bookings.toList();

    // Filter by status
    if (_selectedFilter == 'pending_division') {
      bookings = bookings.where((b) => b.isPendingDivision).toList();
    } else if (_selectedFilter == 'pending_ga') {
      bookings = bookings.where((b) => b.isPendingGA).toList();
    } else if (_selectedFilter == 'approved') {
      bookings = bookings.where((b) => b.isApproved).toList();
    } else if (_selectedFilter == 'rejected') {
      bookings = bookings.where((b) => b.isRejected).toList();
    }

    // Filter by search
    if (_searchQuery.isNotEmpty) {
      bookings = bookings
          .where((b) =>
      b.bookingCode.toLowerCase().contains(_searchQuery) ||
          b.purpose.toLowerCase().contains(_searchQuery))
          .toList();
    }

    return bookings;
  }
}

