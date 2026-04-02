import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';
import '../services/api_service.dart';

class RoleBasedDrawer extends StatelessWidget {
  const RoleBasedDrawer({Key? key}) : super(key: key);

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Apakah Anda yakin ingin logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await ApiService.logout();
                if (context.mounted) {
                  Navigator.of(context).pushReplacementNamed('/login');
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Logout gagal: $e')),
                );
              }
            },
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<RoleProvider>(
      builder: (context, roleProvider, _) {
        final user = roleProvider.currentUser;
        final isDivumAdmin = roleProvider.isDivumAdmin;
        final isDivisionalLeader = roleProvider.isDivisionalLeader;

        return Drawer(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDivumAdmin
                          ? [const Color(0xff00b477), const Color(0xff00b477)]
                          : isDivisionalLeader
                              ? [const Color(0xFF00B477), const Color(0xFF00B477)]
                              : [const Color(0xff00b477), const Color(0xff00b477)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Top - Icon role
                      Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isDivumAdmin
                                ? '⚙️ Admin'
                                : isDivisionalLeader
                                    ? '👔 Leader'
                                    : '👤 Employee',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      // Bottom - User info
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.white.withValues(alpha: 0.25),
                            child: Icon(
                              isDivumAdmin
                                  ? Icons.admin_panel_settings
                                  : isDivisionalLeader
                                      ? Icons.manage_accounts
                                      : Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user?.name ?? 'User',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user?.email ?? 'No email',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Dashboard Menu
                ListTile(
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushReplacementNamed('/dashboard');
                  },
                ),

                // Booking Menu (Semua Role)
                ListTile(
                  leading: const Icon(Icons.list_alt),
                  title: const Text('Daftar Pemesanan'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/bookings');
                  },
                ),

                // Calendar Menu (Semua Role)
                ListTile(
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Kalender'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushNamed('/calendar');
                  },
                ),

                const Divider(),

                // Approval Menu (Leader & Admin)
                if (isDivisionalLeader || isDivumAdmin) ...[
                  ListTile(
                    leading: const Icon(Icons.approval),
                    title: const Text('Persetujuan Pending'),
                    subtitle: const Text('Perlu disetujui'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/bookings');
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Filter diterapkan: Perlu Approval'),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                ],

                // Facility Management (Admin Only)
                if (isDivumAdmin) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Manajemen Fasilitas',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.meeting_room),
                    title: const Text('Kelola Ruangan'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/rooms');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.directions_car),
                    title: const Text('Kelola Kendaraan'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/vehicles');
                    },
                  ),
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Administrasi',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Laporan & Statistik'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur laporan akan segera hadir'),
                        ),
                      );
                    },
                  ),
                ],

                // Division Leader Menu Items
                if (isDivisionalLeader) ...[
                  const Divider(),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Monitoring',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.analytics),
                    title: const Text('Laporan Divisi'),
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur laporan divisi akan segera hadir'),
                        ),
                      );
                    },
                  ),
                ],

                const Divider(),

                // Help Menu
                ListTile(
                  leading: const Icon(Icons.help_outline),
                  title: const Text('Bantuan'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Hubungi Admin untuk bantuan'),
                      ),
                    );
                  },
                ),

                // Logout Menu
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(color: Colors.red),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogoutDialog(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}


