import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/role_provider.dart';

/// ADMIN DIVUM - FINAL APPROVALS SCREEN
/// Menampilkan booking list untuk final approval
class AdminFinalApprovalsScreen extends StatefulWidget {
  const AdminFinalApprovalsScreen({Key? key}) : super(key: key);

  @override
  State<AdminFinalApprovalsScreen> createState() =>
      _AdminFinalApprovalsScreenState();
}

class _AdminFinalApprovalsScreenState extends State<AdminFinalApprovalsScreen> {
  String _selectedFilter = 'pending';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending_divum':
      case 'pending_ga':
        return const Color(0xFF2196F3);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected':
      case 'rejected_divum':
        return const Color(0xFFf44336);
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'pending_divum':
      case 'pending_ga':
        return 'Menunggu GA/DIVUM';
      case 'approved':
        return 'Disetujui';
      case 'rejected_divum':
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }

  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'pending_divum':
      case 'pending_ga':
        return '🔵';
      case 'approved':
        return '🟢';
      case 'rejected_divum':
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
        title: const Text('Final Approvals'),
        backgroundColor: const Color(0xFFE74C3C),
        foregroundColor: Colors.white,
        elevation: 1,
      ),
      body: Consumer2<BookingProvider, RoleProvider>(
        builder: (context, bookingProvider, roleProvider, _) {
          var pendingBookings = bookingProvider.bookings
              .where((b) =>
          b.status.toLowerCase().contains('pending_divum') ||
              b.status.toLowerCase().contains('pending_ga'))
              .toList();

          var allBookings = bookingProvider.bookings.toList();

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header
                Container(
                  color: const Color(0xFFE74C3C),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Final Approval Pemesanan',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Admin DIVUM/GA - Approval Akhir',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Pending',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    pendingBookings.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  const Text(
                                    'Total',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  Text(
                                    allBookings.length.toString(),
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // Filter Chips
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip(
                          label: 'Pending Final Approval',
                          isSelected: _selectedFilter == 'pending',
                          onTap: () {
                            setState(() {
                              _selectedFilter = 'pending';
                            });
                          },
                        ),
                        const SizedBox(width: 8),
                        _buildFilterChip(
                          label: 'Semua Booking',
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
                ),
                // Booking List
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedFilter == 'pending'
                            ? 'Menunggu Final Approval'
                            : 'Semua Booking',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
                if (bookingProvider.isLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: CircularProgressIndicator(),
                  )
                else if (allBookings.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.info,
                            size: 48,
                            color: Colors.orange.shade300,
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Belum Ada Data Pemesanan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (_selectedFilter == 'pending' &&
                      pendingBookings.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 64,
                              color: Colors.green.shade300,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Tidak Ada Booking Menunggu',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF666666),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _selectedFilter == 'pending'
                            ? pendingBookings.length
                            : allBookings.length,
                        itemBuilder: (context, index) {
                          final booking = _selectedFilter == 'pending'
                              ? pendingBookings[index]
                              : allBookings[index];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildBookingCard(booking),
                          );
                        },
                      ),
                    ),
                const SizedBox(height: 24),
              ],
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
      selectedColor: const Color(0xFFE74C3C),
      side: BorderSide(
        color: isSelected
            ? const Color(0xFFE74C3C)
            : Colors.grey.shade300,
      ),
    );
  }

  Widget _buildBookingCard(dynamic booking) {
    final statusLabel = _getStatusLabel(booking.status);
    final statusColor = _getStatusColor(booking.status);
    final statusEmoji = _getStatusEmoji(booking.status);

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
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.bookingCode,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 13, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.bookingDate} • ${booking.startTime}-${booking.endTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Text(
                  booking.bookingType.toLowerCase() == 'room'
                      ? '🏢'
                      : '🚗',
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    booking.purpose,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
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
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    if (booking.status.toLowerCase().contains('pending_divum') ||
                        booking.status.toLowerCase().contains('pending_ga')) ...[
                      ElevatedButton.icon(
                        onPressed: () {
                          _showApprovalDialog(booking, true);
                        },
                        icon: const Icon(Icons.check, size: 14),
                        label: const Text('Setujui',
                            style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      ElevatedButton.icon(
                        onPressed: () {
                          _showApprovalDialog(booking, false);
                        },
                        icon: const Icon(Icons.close, size: 14),
                        label: const Text('Tolak',
                            style: TextStyle(fontSize: 11)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showApprovalDialog(dynamic booking, bool isApprove) {
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
              isApprove ? 'Final Approve?' : 'Reject?',
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isApprove
                  ? 'Ini adalah FINAL APPROVAL.'
                  : 'Apakah Anda yakin ingin menolak?',
            ),
            const SizedBox(height: 16),
            TextField(
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
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isApprove
                        ? 'Pemesanan disetujui (FINAL)'
                        : 'Pemesanan ditolak',
                  ),
                  backgroundColor: isApprove ? Colors.green : Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(
              isApprove ? 'Final Approve' : 'Reject',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

