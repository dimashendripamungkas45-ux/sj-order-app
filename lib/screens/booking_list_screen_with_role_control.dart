import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';

class BookingListScreenWithRoleControl extends StatefulWidget {
  const BookingListScreenWithRoleControl({Key? key}) : super(key: key);

  @override
  State<BookingListScreenWithRoleControl> createState() =>
      _BookingListScreenWithRoleControlState();
}

class _BookingListScreenWithRoleControlState
    extends State<BookingListScreenWithRoleControl>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ FIX: Will be recreated in build based on role
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

  /// Check if user can approve/reject this booking
  bool _canApproveBooking(dynamic booking, RoleProvider roleProvider) {
    final status = booking.status.toLowerCase();

    // Only division leaders can approve pending_division bookings
    if (roleProvider.isDivisionalLeader) {
      return status == 'pending_division';
    }
    // Only DIVUM admins can approve pending_divum bookings
    else if (roleProvider.isDivumAdmin) {
      return status == 'pending_divum';
    }
    // Regular staff cannot approve
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        // ✅ FIX: Check role dengan benar
        final isDivisionalLeader = roleProvider.isDivisionalLeader;
        final isDivumAdmin = roleProvider.isDivumAdmin;
        final isStaff = !isDivisionalLeader && !isDivumAdmin;

        // Debug logging
        print('🔍 [BookingList] Role Check:');
        print('   isDivisionalLeader: $isDivisionalLeader');
        print('   isDivumAdmin: $isDivumAdmin');
        print('   isStaff: $isStaff');

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
              tabs: isStaff
                  ? const [
                      Tab(text: 'Semua'),
                      Tab(text: 'Ditolak'),
                    ]
                  : const [
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

              // For staff: only show their own bookings
              if (isStaff) {
                return TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Semua
                    _buildStaffView(allBookings),
                    // Tab 2: Ditolak
                    _buildStaffView(
                      allBookings
                          .where((b) =>
                              b.status.toLowerCase().contains('rejected'))
                          .toList(),
                    ),
                  ],
                );
              }

              // For division leaders and DIVUM admins: show approval-based tabs
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
                  // ✅ FIX: Check if user can access approval
                  if (isStaff) {
                    print('❌ Staff cannot access approval dashboard');
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Anda tidak memiliki akses ke dashboard approval',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  } else {
                    Navigator.pushNamed(context, '/approval');
                  }
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

  /// Build view for staff (only see their own bookings and status)
  Widget _buildStaffView(List<dynamic> allBookings) {
    if (allBookings.isEmpty) {
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
              'Anda belum memiliki pemesanan apapun',
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
          itemCount: allBookings.length,
          itemBuilder: (context, index) {
            final booking = allBookings[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildStaffBookingCard(booking),
            );
          },
        ),
      ),
    );
  }

  /// Build booking card for staff (view only - no approval buttons)
  Widget _buildStaffBookingCard(dynamic booking) {
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
          // Card Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.bookingCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
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
          const Divider(height: 1),
          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                Row(
                  children: [
                    Icon(Icons.person,
                        size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Anda (Staff)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Card Footer - STATUS ONLY (No approval buttons for staff)
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
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        statusEmoji,
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
                // View Details Button Only
                OutlinedButton.icon(
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
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build booking list for division leaders and DIVUM admins
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
              child: _buildApprovalBookingCard(booking, roleProvider),
            );
          },
        ),
      ),
    );
  }

  /// Build booking card for approval (with approve/reject buttons)
  Widget _buildApprovalBookingCard(
      dynamic booking, RoleProvider roleProvider) {
    final statusLabel = _getStatusLabel(booking.status);
    final statusColor = _getStatusColor(booking.status);
    final statusEmoji = _getStatusEmoji(booking.status);
    final canApprove = _canApproveBooking(booking, roleProvider);

    print(
        '🔍 [ApprovalCard] Booking: ${booking.bookingCode}, Status: ${booking.status}, CanApprove: $canApprove');

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
          // Card Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.bookingCode,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 8),
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
          const Divider(height: 1),
          // Card Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
              ],
            ),
          ),
          const Divider(height: 1),
          // Card Footer - STATUS & APPROVAL BUTTONS
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
                        statusEmoji,
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
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    // Approval buttons only if user can approve
                    if (canApprove) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showApprovalDialog(booking, true, roleProvider),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Setujui'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _showApprovalDialog(booking, false, roleProvider),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Tolak'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFf44336),
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

  void _showApprovalDialog(
      dynamic booking, bool isApprove, RoleProvider roleProvider) {
    final isDivisionLeader = roleProvider.isDivisionalLeader;

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
            const SizedBox(width: 10),
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
                  ? 'Apakah Anda yakin ingin menyetujui pemesanan ini?'
                  : 'Apakah Anda yakin ingin menolak pemesanan ini?',
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                hintText: 'Catatan (opsional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              _processApproval(booking, isApprove, isDivisionLeader);
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

  void _processApproval(
      dynamic booking, bool isApprove, bool isDivisionLeader) {
    // TODO: Call API to approve/reject
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isDivisionLeader
              ? (isApprove
                  ? 'Pemesanan diteruskan ke GA'
                  : 'Pemesanan ditolak')
              : (isApprove
                  ? 'Pemesanan disetujui'
                  : 'Pemesanan ditolak'),
        ),
        backgroundColor: isApprove ? Colors.green : Colors.red,
      ),
    );

    // Refresh bookings
    Provider.of<BookingProvider>(context, listen: false).refreshBookings();
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







