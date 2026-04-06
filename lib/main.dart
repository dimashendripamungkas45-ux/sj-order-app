import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/booking_list_screen.dart';
import 'screens/booking_detail_screen.dart';
import 'screens/create_booking_screen.dart';
import 'screens/approval_dashboard_screen.dart';
import 'screens/rooms_screen.dart';
import 'screens/vehicles_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/dashboards/admin_final_approvals_screen.dart';
import 'screens/pending_approvals_screen.dart';
import 'screens/daftar_pemesanan_screen.dart';
import 'screens/user_management_screen.dart';
import 'providers/user_provider.dart';
import 'providers/booking_provider.dart';
import 'providers/role_provider.dart';
import 'providers/user_management_provider.dart';
import 'models/booking_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => BookingProvider()),
        ChangeNotifierProvider(create: (_) => RoleProvider()),
        ChangeNotifierProvider(create: (_) => UserManagementProvider()),
      ],
      child: MaterialApp(
        title: 'SJ Order App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/splash': (context) => const SplashScreen(),
          '/login': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/bookings': (context) => const BookingListScreen(),
          '/approval': (context) => const ApprovalDashboardScreen(),
          '/create-booking': (context) => const CreateBookingScreen(),
          '/rooms': (context) => const RoomsScreen(),
          '/vehicles': (context) => const VehiclesScreen(),
          '/calendar': (context) => const CalendarScreen(),
          '/admin-final-approvals': (context) => const AdminFinalApprovalsScreen(),
          '/pending-approvals': (context) => const PendingApprovalsScreen(),
          '/daftar-pemesanan': (context) => const DaftarPemesananScreen(),
          '/user-management': (context) => const UserManagementScreen(),
        },
        onGenerateRoute: (settings) {
          if (settings.name == '/booking-detail') {
            final booking = settings.arguments as Booking;
            return MaterialPageRoute(
              builder: (context) => BookingDetailScreen(booking: booking),
            );
          }
          return null;
        },
      ),
    );
  }
}
