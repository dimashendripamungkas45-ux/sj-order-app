import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/booking_provider.dart';
import '../providers/role_provider.dart';

/// APPROVAL DASHBOARD - HANYA UNTUK PIMPINAN DIVISI DAN ADMIN DIVUM
/// Staff TIDAK bisa akses halaman ini
class ApprovalDashboardScreenWithRoleCheck extends StatefulWidget {
  const ApprovalDashboardScreenWithRoleCheck({Key? key}) : super(key: key);

  @override
  State<ApprovalDashboardScreenWithRoleCheck> createState() =>
      _ApprovalDashboardScreenWithRoleCheckState();
}

class _ApprovalDashboardScreenWithRoleCheckState
    extends State<ApprovalDashboardScreenWithRoleCheck>
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
        return const Color(0xFFFFC107);
      case 'pending_divum':
        return const Color(0xFF2196F3);
      case 'approved':
        return const Color(0xFF4CAF50);
      case 'rejected_division':
      case 'rejected_divum':
      case 'rejected':
        return const Color(0xFFf44336);
      default:
        return const Color(0xFF999999);
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

  bool _canApproveBooking(dynamic booking, RoleProvider roleProvider) {
    final status = booking.status.toLowerCase();

    if (roleProvider.isDivisionalLeader) {
      return status == 'pending_division';
    } else if (roleProvider.isDivumAdmin) {
      return status == 'pending_divum';
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        // ✅ FIX: Check role dengan benar
        final isDivisionalLeader = roleProvider.isDivisionalLeader;
        final isDivumAdmin = roleProvider.isDivumAdmin;
        final hasApprovalAccess = isDivisionalLeader || isDivumAdmin;

        // Debug logging
        print('🔍 [ApprovalDashboard] Role Check:');
        print('   isDivisionalLeader: $isDivisionalLeader');
        print('   isDivumAdmin: $isDivumAdmin');
        print('   hasApprovalAccess: $hasApprovalAccess');

        // CHECK: Only Division Leader and DIVUM Admin can access this page
        if (!hasApprovalAccess) {
          print('❌ [ApprovalDashboard] Access denied for user');
          // Redirect unauthorized users
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Akses Ditolak',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dashboard approval hanya dapat diakses oleh\nPimpinan Divisi atau Admin DIVUM',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/dashboard');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                    child: const Text(
                      'Kembali ke Dashboard',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        print('✅ [ApprovalDashboard] Access granted');
        // User has access to approval dashboard
        return Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard Approval'),
            backgroundColor: Colors.white,
            elevation: 1,
            foregroundColor: Colors.black,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.blue,
              labelColor: Colors.blue,
              unselectedLabelColor: Colors.grey,
              tabs: [
                const Tab(text: 'Semua'),
                const Tab(text: 'Pending'),
                const Tab(text: 'Disetujui'),
                const Tab(text: 'Ditolak'),
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
                  // Tab 1: Semua
                  _buildBookingsList(allBookings, roleProvider),
                  // Tab 2: Pending
                  _buildBookingsList(
                    allBookings
                        .where((b) =>
                            b.status.toLowerCase().contains('pending'))
                        .toList(),
                    roleProvider,
                  ),
                  // Tab 3: Disetujui
                  _buildBookingsList(
                    allBookings
                        .where((b) =>
                            b.status.toLowerCase() == 'approved')
                        .toList(),
                    roleProvider,
                  ),
                  // Tab 4: Ditolak
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
            currentIndex: 2,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.pushNamed(context, '/dashboard');
                  break;
                case 1:
                  Navigator.pushNamed(context, '/bookings');
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
    final statusEmoji = _getStatusEmoji(booking.status);
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                    if (canApprove) ...[
                      const SizedBox(width: 8),
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
                      const SizedBox(width: 8),
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
              _processApproval(booking, isApprove);
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

  void _processApproval(dynamic booking, bool isApprove) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isApprove
              ? 'Pemesanan disetujui'
              : 'Pemesanan ditolak',
        ),
        backgroundColor: isApprove ? Colors.green : Colors.red,
      ),
    );

    Provider.of<BookingProvider>(context, listen: false).refreshBookings();
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


