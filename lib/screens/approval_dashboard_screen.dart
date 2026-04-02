import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';

class ApprovalDashboardScreen extends StatefulWidget {
  const ApprovalDashboardScreen({Key? key}) : super(key: key);

  @override
  State<ApprovalDashboardScreen> createState() =>
      _ApprovalDashboardScreenState();
}

class _ApprovalDashboardScreenState extends State<ApprovalDashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    Future.microtask(() {
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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

  String _getBookingTypeIcon(String type) {
    return type.toLowerCase() == 'room' ? '🏢' : '🚗';
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
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: const [
                Tab(text: 'Semua'),
                Tab(text: 'Pending'),
                Tab(text: 'Disetujui'),
                Tab(text: 'Ditolak'),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () {
                  showSearch(
                    context: context,
                    delegate: ApprovalSearchDelegate(
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
              List<dynamic> allBookings = bookingProvider.bookings;

              // Filter by search query
              if (_searchQuery.isNotEmpty) {
                allBookings = allBookings
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

              return TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Semua (All)
                  _buildBookingsList(
                    allBookings,
                    roleProvider,
                  ),
                  // Tab 2: Pending
                  _buildBookingsList(
                    allBookings
                        .where((b) =>
                            b.status.toLowerCase().contains('pending'))
                        .toList(),
                    roleProvider,
                  ),
                  // Tab 3: Disetujui (Approved)
                  _buildBookingsList(
                    allBookings
                        .where((b) =>
                            b.status.toLowerCase() == 'approved')
                        .toList(),
                    roleProvider,
                  ),
                  // Tab 4: Ditolak (Rejected)
                  _buildBookingsList(
                    allBookings
                        .where((b) =>
                            b.status.toLowerCase().contains('rejected'))
                        .toList(),
                    roleProvider,
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.list),
                label: 'Daftar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.check_circle),
                label: 'Approval',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
            currentIndex: 1,
            onTap: (index) {
              // Handle navigation
              switch (index) {
                case 0:
                  Navigator.pushNamed(context, '/dashboard');
                  break;
                case 2:
                  // Already on approval
                  break;
                case 3:
                  Navigator.pushNamed(context, '/profile');
                  break;
              }
            },
          ),
        );
      },
    );
  }

  Widget _buildBookingsList(
    List<dynamic> bookings,
    RoleProvider roleProvider,
  ) {
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
                  : 'Tidak ada pemesanan untuk kategori ini',
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: bookings.length,
          itemBuilder: (context, index) {
            final booking = bookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildApprovalCard(booking, roleProvider),
            );
          },
        ),
      ),
    );
  }

  Widget _buildApprovalCard(dynamic booking, RoleProvider roleProvider) {
    final statusLabel = _getStatusLabel(booking.status);
    final statusColor = _getStatusColor(booking.status);
    final bookingTypeIcon = _getBookingTypeIcon(booking.bookingType);

    // Check if this booking can be approved by current user
    final canApprove = _canApproveBooking(booking, roleProvider);

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
          // Card Header - Booking Code and Time
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Booking Code (Bold)
                Text(
                  booking.bookingCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
                // Date and Time
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${booking.bookingDate} • ${booking.startTime}-${booking.endTime}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          // Card Body - Resource and User Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Resource
                Row(
                  children: [
                    Text(
                      bookingTypeIcon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        booking.purpose,
                        style: const TextStyle(
                          fontSize: 14,
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
                // User and Division Info
                Row(
                  children: [
                    Icon(Icons.person,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Ahmad Mirza • SBU Teknologi',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade200),
          // Card Footer - Status and Actions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getStatusEmoji(booking.status),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Action Buttons
                Row(
                  children: [
                    // View Details Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/booking-detail',
                            arguments: booking.id,
                          );
                        },
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Detail'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side:
                              BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Approve Button
                    if (canApprove)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showApprovalDialog(booking, true),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Setujui'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    if (canApprove) const SizedBox(width: 8),
                    // Reject Button
                    if (canApprove)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showApprovalDialog(booking, false),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Tolak'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf44336),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _canApproveBooking(dynamic booking, RoleProvider roleProvider) {
    final status = booking.status.toLowerCase();

    if (roleProvider.isDivisionalLeader) {
      return status == 'pending_division';
    } else if (roleProvider.isDivumAdmin) {
      return status == 'pending_divum';
    }
    return false;
  }

  String _getStatusEmoji(String status) {
    switch (status.toLowerCase()) {
      case 'pending_division':
        return '🟡';
      case 'pending_divum':
        return '🔵';
      case 'approved':
        return '🟢';
      case 'rejected_division':
      case 'rejected_divum':
      case 'rejected':
        return '🔴';
      default:
        return '⚫';
    }
  }

  void _showApprovalDialog(dynamic booking, bool isApprove) {
    final notesController = TextEditingController();
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final isDivisionLeader = roleProvider.isDivisionalLeader;
    // ✅ Capture provider BEFORE showing dialog
    final bookingProvider = Provider.of<BookingProvider>(context, listen: false);

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
                isApprove ? 'Setujui Pemesanan?' : 'Tolak Pemesanan?',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
              ),
              child: Text(
                isApprove
                    ? '✅ Apakah Anda yakin ingin menyetujui pemesanan ini?'
                    : '❌ Apakah Anda yakin ingin menolak pemesanan ini?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: isApprove ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Booking Code: ${booking.bookingCode}',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Tujuan: ${booking.purpose}',
              style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                hintText: isApprove ? 'Catatan persetujuan (opsional)' : 'Alasan penolakan (opsional)',
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
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              Navigator.pop(context);
              // ✅ Use captured provider and parentContext (not dialog context)
              await _processApproval(
                booking,
                isApprove,
                isDivisionLeader,
                notesController.text.trim(),
                bookingProvider,
              );
              notesController.dispose();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
            ),
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processApproval(
    dynamic booking,
    bool isApprove,
    bool isDivisionLeader,
    String notes,
    BookingProvider bookingProvider, // ✅ Receive provider as parameter
  ) async {
    try {
      print('📋 [ApprovalDialog] Processing approval...');
      print('   Booking ID: ${booking.id}');
      print('   Action: ${isApprove ? 'approve' : 'reject'}');
      print('   Notes: $notes');

      bool success;
      if (isDivisionLeader) {
        print('📤 [ApprovalDialog] Calling approveDivision (Leader)...');
        success = await bookingProvider.approveDivision(
          bookingId: booking.id,
          action: isApprove ? 'approve' : 'reject',
          notes: notes,
        );
      } else {
        print('📤 [ApprovalDialog] Calling approveDivum (Admin)...');
        success = await bookingProvider.approveDivum(
          bookingId: booking.id,
          action: isApprove ? 'approve' : 'reject',
          notes: notes,
        );
      }

      if (!mounted) return; // ✅ Check mounted before using context

      if (success) {
        print('✅ [ApprovalDialog] Success!');

        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isDivisionLeader
                    ? (isApprove
                        ? '✅ Pemesanan disetujui & diteruskan ke GA'
                        : '❌ Pemesanan ditolak')
                    : (isApprove
                        ? '✅ Pemesanan disetujui'
                        : '❌ Pemesanan ditolak'),
              ),
              backgroundColor: isApprove ? Colors.green : Colors.red,
              duration: const Duration(seconds: 2),
            ),
          );
        }

        // Refresh bookings
        print('🔄 [ApprovalDialog] Refreshing bookings...');
        await bookingProvider.refreshBookings();

        // Trigger rebuild
        if (mounted) {
          setState(() {});
        }

        print('✅ [ApprovalDialog] Complete');
      } else {
        print('❌ [ApprovalDialog] Failed: ${bookingProvider.error}');

        if (!mounted) return;

        // Show error message
        if (mounted) {
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
      }
    } catch (e) {
      print('❌ [ApprovalDialog] Exception: $e');

      if (!mounted) return;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class ApprovalSearchDelegate extends SearchDelegate {
  final Function(String) onSearch;

  ApprovalSearchDelegate({required this.onSearch});

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
              'Cari berdasarkan kode booking',
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


