import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/user_provider.dart';
import '../../models/booking_model.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    print('🔵 [AdminDashboard] Widget initialized');
    Future.microtask(() {
      print('📊 [AdminDashboard] Loading bookings from database...');
      _loadBookings();
    });
  }

  Future<void> _loadBookings() async {
    final provider = Provider.of<BookingProvider>(context, listen: false);
    print('🔄 [AdminDashboard._loadBookings] Calling fetchBookings()...');
    try {
      await provider.fetchBookings();
      print('✅ [AdminDashboard._loadBookings] Completed. Total bookings: ${provider.bookings.length}');

      // Debug: Print semua bookings dengan statusnya
      for (var booking in provider.bookings) {
        print('   📌 ${booking.bookingCode}: ${booking.status}');
      }
    } catch (e) {
      print('❌ [AdminDashboard._loadBookings] Error: $e');
      // Error will be shown via provider's error field
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
        return const Color(0xFF2196F3);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected_ga':
      case 'rejected':
        return const Color(0xFFf44336);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
        return 'Menunggu Final Approval GA';
      case 'approved':
        return 'Disetujui';
      case 'rejected_ga':
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
        return '🔵';
      case 'approved':
        return '🟢';
      case 'rejected_ga':
      case 'rejected':
        return '🔴';
      default:
        return '⚫';
    }
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.grey.shade100,
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF333333),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF999999),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<RoleProvider, BookingProvider>(
      builder: (context, roleProvider, bookingProvider, _) {
        final user = roleProvider.currentUser;

        // ✅ Debug logging
        print('🎨 [AdminDashboard.build] Rebuilding...');
        print('   isLoading: ${bookingProvider.isLoading}');
        print('   total bookings: ${bookingProvider.bookings.length}');
        print('   error: ${bookingProvider.error}');

        // ✅ Filter pending_ga bookings using helper method (Real-time)
        var pendingGABookings = bookingProvider.bookings
            .where((b) => b.isPendingGA)
            .toList();

        print('   pending_ga: ${pendingGABookings.length}');
        for (var b in pendingGABookings) {
          print('      - ${b.bookingCode}: ${b.status}');
        }

        // ✅ Calculate stats using helper methods (Real-time)
        int totalPending = pendingGABookings.length;
        int totalApproved = bookingProvider.bookings
            .where((b) => b.isApproved)
            .length;
        int totalRejected = bookingProvider.bookings
            .where((b) => b.isRejected)
            .length;
        int totalBookings = bookingProvider.bookings.length;

        print('   stats: pending=$totalPending, approved=$totalApproved, rejected=$totalRejected, total=$totalBookings');

        // ✅ Show error if exists
        if (bookingProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Data',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    bookingProvider.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadBookings(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [const Color(0xff00b477), const Color(0xff09a473)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xff00b477).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Selamat Datang,\n${user?.name ?? 'User'}!',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '⚙️ Administrator DIVUM (Final Approval)',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.admin_panel_settings,
                      color: Colors.white.withValues(alpha: 0.3),
                      size: 60,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Statistics Section
              const Text(
                'Statistik Pemesanan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.hourglass_bottom,
                      color: const Color(0xFFFFC107),
                      label: 'Menunggu Final Approval',
                      value: totalPending.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.check_circle,
                      color: const Color(0xFF4CAF50),
                      label: 'Total Disetujui',
                      value: totalApproved.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.cancel,
                      color: const Color(0xFFf44336),
                      label: 'Total Ditolak',
                      value: totalRejected.toString(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.list_alt,
                      color: const Color(0xFF2196F3),
                      label: 'Total Pemesanan',
                      value: totalBookings.toString(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Quick Actions
              const Text(
                'Aksi Cepat',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.approval,
                      label: 'Final Approvals',
                      color: const Color(0xFFFFC107),
                      onTap: () {
                        print('✅ [AdminDashboard] Navigating to PendingApprovalsScreen');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const PendingApprovalsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.list_alt,
                      label: 'Semua Pemesanan',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        print('✅ [AdminDashboard] Navigating to AllBookingsScreen');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AllBookingsScreen(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.meeting_room,
                      label: 'Ruangan',
                      color: const Color(0xFF00BCD4),
                      onTap: () {
                        Navigator.of(context).pushNamed('/rooms');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuickAction(
                      icon: Icons.directions_car,
                      label: 'Kendaraan',
                      color: const Color(0xFF607D8B),
                      onTap: () {
                        Navigator.of(context).pushNamed('/vehicles');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }


}

// ============================================================================
// PENDING APPROVALS SCREEN - For Final Approval (Admin Only)
// ============================================================================

class PendingApprovalsScreen extends StatefulWidget {
  const PendingApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<PendingApprovalsScreen> createState() => _PendingApprovalsScreenState();
}

class _PendingApprovalsScreenState extends State<PendingApprovalsScreen> {
  String _selectedFilter = 'pending';

  @override
  void initState() {
    super.initState();
    print('🔵 [PendingApprovalsScreen] Initialized');
    Future.microtask(() {
      print('🔄 [PendingApprovalsScreen] Loading bookings...');
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
        return const Color(0xFF2196F3);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected_ga':
      case 'rejected':
        return const Color(0xFFf44336);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
        return 'Menunggu Final Approval';
      case 'approved':
        return 'Disetujui';
      case 'rejected_ga':
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
        return '🔵';
      case 'approved':
        return '🟢';
      case 'rejected_ga':
      case 'rejected':
        return '🔴';
      default:
        return '⚫';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff00b477),
        elevation: 0,
        title: const Text(
          'Daftar Pemesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          print('🎨 [PendingApprovalsScreen.build] Rebuilding...');
          print('   Total bookings: ${bookingProvider.bookings.length}');
          print('   isLoading: ${bookingProvider.isLoading}');

          // Get pending GA bookings
          List<Booking> pendingGABookings = bookingProvider.bookings
              .where((b) => b.isPendingGA)
              .toList();

          print('   Pending GA bookings: ${pendingGABookings.length}');
          for (var b in pendingGABookings) {
            print('      - ${b.bookingCode}: ${b.status}');
          }

          // Filter based on selected filter
          List<Booking> filteredBookings = [];
          if (_selectedFilter == 'pending') {
            filteredBookings = pendingGABookings;
          } else if (_selectedFilter == 'approved') {
            filteredBookings = bookingProvider.bookings
                .where((b) => b.isApproved)
                .toList();
          } else if (_selectedFilter == 'rejected') {
            filteredBookings = bookingProvider.bookings
                .where((b) => b.isRejected)
                .toList();
          } else {
            filteredBookings = bookingProvider.bookings;
          }

          print('   Filtered bookings (${_selectedFilter}): ${filteredBookings.length}');

          return RefreshIndicator(
            onRefresh: () =>
                Provider.of<BookingProvider>(context, listen: false)
                    .fetchBookings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Menunggu Approval',
                          isSelected: _selectedFilter == 'pending',
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'pending';
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
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Semua',
                          isSelected: _selectedFilter == 'all',
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'all';
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Booking List
                  if (bookingProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (filteredBookings.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 64,
                            color: Colors.green.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak Ada Pemesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildBookingCard(booking),
                        );
                      },
                    ),
                ],
              ),
            ),
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

  Widget _buildBookingCard(Booking booking) {
    final statusLabel = _getStatusLabel(booking.status ?? '');
    final statusColor = _getStatusColor(booking.status ?? '');
    final statusEmoji = _getStatusEmoji(booking.status ?? '');
    final canApprove = booking.status?.toLowerCase() == 'pending_ga';

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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      booking.bookingCode ?? '',
                      style: const TextStyle(
                        fontSize: 15,
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
                Row(
                  children: [
                    Text(
                      booking.bookingType?.toLowerCase() == 'room'
                          ? '🏢'
                          : '🚗',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        booking.purpose ?? '',
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
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(statusEmoji, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                // Action Buttons - wrapped with SingleChildScrollView
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Detail Button
                      GestureDetector(
                        onTap: () {
                          _showBookingDetailDialog(booking);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.visibility,
                            size: 18,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Approve Button (if pending)
                      if (canApprove)
                        GestureDetector(
                          onTap: () {
                            _showApprovalDialog(booking, true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check, size: 12, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'Approve',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (canApprove) const SizedBox(width: 6),
                      // Reject Button (if pending)
                      if (canApprove)
                        GestureDetector(
                          onTap: () {
                            _showApprovalDialog(booking, false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.close, size: 12, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'Reject',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Kode Pemesanan',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(booking.bookingCode ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tanggal & Waktu',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '${booking.bookingDate} • ${booking.startTime}-${booking.endTime}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                      booking.bookingType?.toLowerCase() == 'room'
                          ? '🏢'
                          : '🚗',
                      style: const TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Ruangan/Kendaraan',
                            style:
                                TextStyle(fontSize: 10, color: Colors.grey)),
                        Text(booking.purpose ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Keperluan',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
              const SizedBox(height: 4),
              Text(booking.purpose ?? '', style: const TextStyle(fontSize: 12)),
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
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isApprove
                    ? 'Setujui Pemesanan?'
                    : 'Tolak Pemesanan?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isApprove ? Colors.green : Colors.red).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: (isApprove ? Colors.green : Colors.red).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                isApprove
                    ? '✅ Booking akan DISETUJUI secara FINAL.'
                    : '❌ Booking akan DITOLAK. Tindakan ini tidak dapat dibatalkan.',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isApprove ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Booking Code: ${booking.bookingCode}',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tujuan: ${booking.purpose}',
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF999999),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: isApprove
                    ? 'Catatan persetujuan (opsional)'
                    : 'Alasan penolakan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: isApprove ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
              ),
              maxLines: 3,
              maxLength: 500,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              notesController.dispose();
              Navigator.pop(context);
            },
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Get action string (ensure it's lowercase)
              final actionStr = isApprove ? 'approve' : 'reject';

              print('📋 [Approval Dialog] User confirmed action');
              print('   Booking ID: ${booking.id}');
              print('   Booking Code: ${booking.bookingCode}');
              print('   Action: $actionStr');
              print('   Notes: ${notesController.text.trim()}');

              // Close dialog first
              if (mounted) {
                Navigator.pop(context);
              }

              try {
                final bookingProvider =
                    Provider.of<BookingProvider>(context, listen: false);

                print('📤 [Approval Dialog] Sending $actionStr request...');

                // Validate booking ID
                if (booking.id == null || booking.id! <= 0) {
                  print('❌ [Approval Dialog] Invalid booking ID: ${booking.id}');
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Error: Invalid booking ID'),
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 3),
                    ),
                  );
                  return;
                }

                // Call API to approve/reject
                bool success = await bookingProvider.approveDivum(
                  bookingId: booking.id!,
                  action: actionStr, // ensure lowercase
                  notes: notesController.text.trim(),
                );

                print('📥 [Approval Dialog] Response: success=$success');

                if (!mounted) return;

                if (success) {
                  print('✅ [Approval Dialog] Action successful!');

                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        isApprove
                            ? '✅ Pemesanan Disetujui!'
                            : '❌ Pemesanan Ditolak!',
                      ),
                      backgroundColor: isApprove ? Colors.green : Colors.red,
                      duration: const Duration(seconds: 2),
                    ),
                  );

                  // Refresh bookings
                  print('🔄 [Approval Dialog] Refreshing bookings...');
                  await bookingProvider.fetchBookings();

                  // Trigger rebuild
                  if (mounted) {
                    setState(() {});
                  }

                  print('✅ [Approval Dialog] Complete');
                } else {
                  print('❌ [Approval Dialog] Failed: ${bookingProvider.error}');

                  if (!mounted) return;

                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Error: ${bookingProvider.error ?? 'Terjadi kesalahan'}',
                      ),
                      backgroundColor: Colors.red,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e, stackTrace) {
                print('❌ [Approval Dialog] Exception: $e');
                print('   Stack: $stackTrace');

                if (!mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Error: ${e.toString()}',
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } finally {
                notesController.dispose();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// ALL BOOKINGS SCREEN
// ============================================================================

class AllBookingsScreen extends StatefulWidget {
  const AllBookingsScreen({Key? key}) : super(key: key);

  @override
  State<AllBookingsScreen> createState() => _AllBookingsScreenState();
}

class _AllBookingsScreenState extends State<AllBookingsScreen> {
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
      case 'pending_division':
        return const Color(0xFF2196F3);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected_ga':
      case 'rejected_division':
      case 'rejected':
        return const Color(0xFFf44336);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_ga':
        return 'Menunggu GA';
      case 'pending_division':
        return 'Menunggu Divisi';
      case 'approved':
        return 'Disetujui';
      case 'rejected_ga':
        return 'Ditolak GA';
      case 'rejected_division':
        return 'Ditolak Divisi';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff00b477),
        elevation: 0,
        title: const Text(
          'Semua Pemesanan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<BookingProvider>(
        builder: (context, bookingProvider, _) {
          print('🎨 [AllBookingsScreen.build] Rebuilding...');
          print('   Total bookings: ${bookingProvider.bookings.length}');
          print('   isLoading: ${bookingProvider.isLoading}');

          List<Booking> filteredBookings = bookingProvider.bookings;

          if (_selectedFilter == 'pending') {
            filteredBookings = bookingProvider.bookings
                .where((b) => b.isPendingDivision || b.isPendingGA)
                .toList();
          } else if (_selectedFilter == 'approved') {
            filteredBookings = bookingProvider.bookings
                .where((b) => b.isApproved)
                .toList();
          } else if (_selectedFilter == 'rejected') {
            filteredBookings = bookingProvider.bookings
                .where((b) => b.isRejected)
                .toList();
          }

          print('   Filtered bookings (${_selectedFilter}): ${filteredBookings.length}');

          return RefreshIndicator(
            onRefresh: () =>
                Provider.of<BookingProvider>(context, listen: false)
                    .fetchBookings(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
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
                          label: 'Menunggu',
                          isSelected: _selectedFilter == 'pending',
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'pending';
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
                  const SizedBox(height: 20),

                  // Booking List
                  if (bookingProvider.isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (filteredBookings.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.info,
                            size: 64,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Tidak Ada Pemesanan',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildBookingCard(booking),
                        );
                      },
                    ),
                ],
              ),
            ),
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

  Widget _buildBookingCard(Booking booking) {
    final statusLabel = _getStatusLabel(booking.status ?? '');
    final statusColor = _getStatusColor(booking.status ?? '');

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  booking.bookingCode ?? '',
                  style: const TextStyle(
                    fontSize: 15,
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
            Row(
              children: [
                Text(
                  booking.bookingType?.toLowerCase() == 'room' ? '🏢' : '🚗',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.purpose ?? '',
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
