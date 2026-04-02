import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../providers/role_provider.dart';
import '../services/api_service.dart';
import 'dashboards/employee_dashboard.dart';
import 'dashboards/leader_dashboard.dart';
import 'dashboards/admin_dashboard.dart';
import '../widgets/role_based_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isLoggingOut = false; // Flag to prevent rebuild during logout

  @override
  void initState() {
    super.initState();
    // Fetch user data when screen loads
    Future.microtask(() {
      print('📍 [Dashboard] initState - Fetching user data...');
      Provider.of<UserProvider>(context, listen: false).fetchUser();

      // Only initialize RoleProvider if user not already set (from login)
      final roleProvider = Provider.of<RoleProvider>(context, listen: false);
      if (roleProvider.currentUser == null) {
        print('📍 [Dashboard] User not set, initializing from storage...');
        roleProvider.initializeUser();
      } else {
        print('📍 [Dashboard] User already set from login, skipping initialize');
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // ...existing code...

  // ...existing code...

  Future<void> _handleLogout() async {
    // Prevent double logout if already logging out
    if (_isLoggingOut) {
      print('⚠️ [Dashboard] Already logging out, ignoring duplicate request');
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);

              // Set flag to prevent rebuilds
              _isLoggingOut = true;

              try {
                print('🚪 [Dashboard] Logout button clicked');

                // Get providers using PARENT context (not dialog context)
                final roleProvider = context.read<RoleProvider>();
                final userProvider = context.read<UserProvider>();

                // 1. Call API logout
                print('📤 [Dashboard] Calling API logout...');
                await ApiService.logout();
                print('✅ [Dashboard] API logout complete');

                // 2. Clear RoleProvider state
                print('🗑️ [Dashboard] Clearing RoleProvider...');
                await roleProvider.logout();
                print('✅ [Dashboard] RoleProvider cleared');

                // 3. Clear UserProvider state
                print('🗑️ [Dashboard] Clearing UserProvider...');
                userProvider.clearUser();
                print('✅ [Dashboard] UserProvider cleared');

                // 4. Navigate to login - use pushNamedAndRemoveUntil to ensure clean navigation
                if (mounted) {
                  print('➡️ [Dashboard] Navigating to login screen...');
                  // This removes all routes below /login from stack
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
              } catch (e) {
                print('❌ [Dashboard] Logout error: $e');
                _isLoggingOut = false;
                _showError('Logout failed: $e');
                // Still try to navigate even if there's an error
                if (mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login',
                    (route) => false,
                  );
                }
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
        // Determine AppBar color based on role
        Color appBarColor = Colors.blue;
        String roleLabel = 'Dashboard';

        if (roleProvider.isDivumAdmin) {
          appBarColor = const Color(0xff00b477);
          roleLabel = 'Dashboard Admin';
        } else if (roleProvider.isDivisionalLeader) {
          appBarColor = const Color(0xFF00B477);
          roleLabel = 'Dashboard Pimpinan';
        } else {
          appBarColor = const Color(0xff00b477);
          roleLabel = 'Dashboard Karyawan';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(roleLabel),
            backgroundColor: appBarColor,
            elevation: 0,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roleProvider.isDivumAdmin
                          ? '⚙️ Admin'
                          : roleProvider.isDivisionalLeader
                              ? '👔 Leader'
                              : '👤 Employee',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: _handleLogout,
              ),
            ],
              ),
              drawer: const RoleBasedDrawer(),
              body: Consumer<UserProvider>(
                builder: (context, userProvider, _) {
                  // If logging out, show empty container to prevent rebuild issues
                  if (_isLoggingOut) {
                    return Container(
                      color: Colors.white,
                      child: const Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  if (userProvider.isLoading || roleProvider.currentUser == null) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (userProvider.error != null && roleProvider.currentUser == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red, width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red.shade700,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Error Loading User',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userProvider.error ?? 'Unknown error',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.red.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print('🔄 [Dashboard] Retry button pressed');
                              userProvider.fetchUser();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton(
                            onPressed: () async {
                              print('🚪 [Dashboard] Logout button pressed');
                              await _handleLogout();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 12,
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }

              // Role-based Dashboard Display
              print('🎯 [Dashboard] Role Check:');
              print('   isDivumAdmin: ${roleProvider.isDivumAdmin}');
              print('   isDivisionalLeader: ${roleProvider.isDivisionalLeader}');
              print('   isEmployee: ${roleProvider.isEmployee}');
              print('   currentRole: ${roleProvider.currentRole}');
              print('   User: ${roleProvider.currentUser?.name} (${roleProvider.currentUser?.role})');

              if (roleProvider.isDivumAdmin) {
                print('📊 → Displaying AdminDashboard');
                return const AdminDashboard();
              } else if (roleProvider.isDivisionalLeader) {
                print('📊 → Displaying LeaderDashboard');
                return const LeaderDashboard();
              } else {
                print('📊 → Displaying EmployeeDashboard');
                return const EmployeeDashboard();
              }
            },
          ),
        );
      },
    );
  }
}

