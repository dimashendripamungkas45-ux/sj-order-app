import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/role_provider.dart';
import '../../providers/booking_provider.dart';

class EmployeeDashboard extends StatefulWidget {
  const EmployeeDashboard({Key? key}) : super(key: key);

  @override
  State<EmployeeDashboard> createState() => _EmployeeDashboardState();
}

class _EmployeeDashboardState extends State<EmployeeDashboard> {
  @override
  void initState() {
    super.initState();
    // ✅ Fetch bookings when dashboard loads
    Future.microtask(() {
      print('📊 [EmployeeDashboard] Fetching bookings...');
      Provider.of<BookingProvider>(context, listen: false).fetchBookings();
    });
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
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        final user = roleProvider.currentUser;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Welcome Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xff00b477), const Color(0xff00b477)],
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
                            'Karyawan',
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
                    Icons.person,
                    color: Colors.white.withValues(alpha: 0.3),
                    size: 60,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Stats Section
            const Text(
              'Status Pemesanan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
            const SizedBox(height: 16),

            // Dynamic stats from database
            Consumer<BookingProvider>(
              builder: (context, bookingProvider, _) {
                // Calculate stats based on current user's bookings
                final allBookings = bookingProvider.bookings;
                final roleProvider = Provider.of<RoleProvider>(context, listen: false);
                final currentUserId = roleProvider.currentUser?.id ?? 0;

                // ✅ ULTRA DETAILED DEBUG LOGGING
                print('═' * 80);
                print('📊 [Dashboard Stats] ULTRA DETAILED DEBUG');
                print('═' * 80);
                print('Current User Info:');
                print('   ID: $currentUserId');
                print('   Name: ${roleProvider.currentUser?.name}');
                print('   Role: ${roleProvider.currentUser?.role}');
                print('');
                print('API Bookings Data:');
                print('   Total count: ${allBookings.length}');

                if (allBookings.isEmpty) {
                  print('   ⚠️ NO BOOKINGS FROM API!');
                } else {
                  print('   Bookings detail:');
                  for (int i = 0; i < allBookings.length; i++) {
                    final b = allBookings[i];
                    final match = b.userId == currentUserId ? '✅ MATCH' : '❌ NO MATCH';
                    print('   [$i] Code: ${b.bookingCode}, userId: ${b.userId} $match, status: ${b.status}');
                  }
                }
                print('');
                print('Filter Logic:');
                print('   Looking for: userId == $currentUserId');

                // Guard: if currentUserId is 0 (not set), show empty stats
                if (currentUserId == 0) {
                  print('   ⚠️ currentUserId is 0 - User not properly loaded!');
                  print('═' * 80);
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.hourglass_bottom,
                              color: const Color(0xFFFFC107),
                              label: 'Menunggu Approval',
                              value: '0',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.check_circle,
                              color: const Color(0xFF4CAF50),
                              label: 'Disetujui',
                              value: '0',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.list_alt,
                              color: const Color(0xFF2196F3),
                              label: 'Total Pemesanan',
                              value: '0',
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.cancel,
                              color: const Color(0xFFf44336),
                              label: 'Ditolak',
                              value: '0',
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                }

                // Filter bookings for current user only
                final userBookings = allBookings.where((b) => b.userId == currentUserId).toList();

                // ✅ MORE DEBUG LOGGING
                print('   Matching result: ${userBookings.length} bookings found');
                if (userBookings.isNotEmpty) {
                  print('   Matched bookings:');
                  for (var b in userBookings) {
                    print('      - ${b.bookingCode}: ${b.status}');
                  }
                }
                print('');

                // Count by status
                final pending = userBookings.where((b) =>
                  b.status.toLowerCase().contains('pending')).length;
                final approved = userBookings.where((b) =>
                  b.status.toLowerCase() == 'approved').length;
                final rejected = userBookings.where((b) =>
                  b.status.toLowerCase().contains('rejected')).length;
                final total = userBookings.length;

                print('Status Count:');
                print('   Pending: $pending');
                print('   Approved: $approved');
                print('   Rejected: $rejected');
                print('   Total: $total');
                print('═' * 80);
                print('');

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.hourglass_bottom,
                            color: const Color(0xFFFFC107),
                            label: 'Menunggu Approval',
                            value: pending.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.check_circle,
                            color: const Color(0xFF4CAF50),
                            label: 'Disetujui',
                            value: approved.toString(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.list_alt,
                            color: const Color(0xFF2196F3),
                            label: 'Total Pemesanan',
                            value: total.toString(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.cancel,
                            color: const Color(0xFFf44336),
                            label: 'Ditolak',
                            value: rejected.toString(),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),

            // Quick Actions Section
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
                    icon: Icons.add_circle_outline,
                    label: 'Buat Pemesanan',
                    color: const Color(0xFF4CAF50),
                    onTap: () {
                      Navigator.of(context).pushNamed('/create-booking');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                    child: _buildQuickAction(
                      icon: Icons.list_alt,
                      label: 'Daftar Pemesanan',
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.of(context).pushNamed('/daftar-pemesanan');
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
                    icon: Icons.calendar_month,
                    label: 'Kalender',
                    color: const Color(0xFF9C27B0),
                    onTap: () {
                      Navigator.of(context).pushNamed('/calendar');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.info,
                    label: 'Bantuan',
                    color: const Color(0xFF607D8B),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Hubungi Admin untuk bantuan lebih lanjut',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}




