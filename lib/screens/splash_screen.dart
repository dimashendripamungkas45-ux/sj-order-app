import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    try {
      print('🔍 [SplashScreen] Checking login status...');

      final isLoggedIn = await AuthService.isLoggedIn();
      print('🔐 [SplashScreen] isLoggedIn: $isLoggedIn');

      if (mounted) {
        if (isLoggedIn) {
          // Double-check: token exists but validate consistency
          final token = await AuthService.getToken();
          final userData = await AuthService.getUserData();

          print('🔐 [SplashScreen] Token exists: ${token != null}');
          print('🔐 [SplashScreen] UserData exists: ${userData != null}');

          if (token != null && userData != null) {
            // Token valid, proceed to dashboard
            print('✅ [SplashScreen] Login valid, navigating to dashboard');
            Navigator.of(context).pushReplacementNamed('/dashboard');
          } else {
            // Token exists but no user data - inconsistent state
            // Clear everything and go to login
            print('⚠️ [SplashScreen] Inconsistent state: token without user data');
            print('🔄 [SplashScreen] Clearing invalid session...');
            await AuthService.clearAuthData();
            Navigator.of(context).pushReplacementNamed('/login');
          }
        } else {
          print('❌ [SplashScreen] Not logged in, navigating to login');
          Navigator.of(context).pushReplacementNamed('/login');
        }
      }
    } catch (e) {
      print('💥 [SplashScreen] Error checking login: $e');
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.blue.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  size: 64,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'SJ Order App',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your Service Booking Platform',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              const CircularProgressIndicator(
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

