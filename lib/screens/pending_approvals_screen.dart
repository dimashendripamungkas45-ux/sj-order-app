import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';
import '../models/booking_model.dart';

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  String _selectedFilter = 'pending_division';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    print('📱 [PendingApprovalsScreen] initState called');

    // Fetch bookings when screen loads
    Future.microtask(() {
      print('🔄 [PendingApprovalsScreen] Microtask - fetching bookings...');
      final provider = Provider.of<BookingProvider>(context, listen: false);
      print('📊 [PendingApprovalsScreen] Current bookings in provider: ${provider.bookings.length}');
      provider.fetchBookings();
      print('✅ [PendingApprovalsScreen] fetchBookings() called');
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

              // Search Box
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari pemesanan...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
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
                                  Icons.inbox,
                                  size: 64,
                                  color: Colors.grey.shade300,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  bookingProvider.bookings.isEmpty
                                      ? 'Belum Ada Pemesanan'
                                      : 'Tidak Ada Pemesanan Menunggu Approval',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                                if (bookingProvider.error != null) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Error: ${bookingProvider.error}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.red.shade500,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ]
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            itemCount: filteredBookings.length,
                            itemBuilder: (context, index) {
                              final booking = filteredBookings[index];
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildBookingCard(booking, roleProvider),
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
            children: [
              // Detail Button
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      '/booking-detail',
                      arguments: booking.id,
                    );
                  },
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text(
                    'Detail',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade200,
                    foregroundColor: Colors.grey.shade700,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Approve Button (if can approve)
              if (canApprove) ...[
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showApprovalDialog(booking, true);
                    },
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text(
                      'Setujui',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Reject Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showApprovalDialog(booking, false);
                    },
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text(
                      'Tolak',
                      style: TextStyle(fontSize: 12),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
                            ? '✅ Disetujui'
                            : '❌ Ditolak',
                      ),
                      backgroundColor: isApprove ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );
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

    // Filter by role
    if (roleProvider.isDivisionalLeader) {
      bookings = bookingProvider.bookings
          .where((b) => b.isDivisionId(roleProvider.currentUser?.divisionId ?? 0))
          .toList();
    } else if (roleProvider.isDivumAdmin) {
      bookings = bookingProvider.bookings.toList();
    }

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

