import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/role_provider.dart';
import '../providers/user_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _showPassword = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _clearError() {
    if (mounted) {
      setState(() {
        _errorMessage = null;
      });
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    _clearError();

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 LOGIN ATTEMPT');
      print('📧 Email: ${_emailController.text.trim()}');
      print('🔐 Password length: ${_passwordController.text.length}');
      print('🌐 Connecting to: http://10.0.2.2:8000/api/login');

      // Clear any previous session data first
      print('🗑️ Clearing previous session data...');
      final roleProvider = context.read<RoleProvider>();
      final userProvider = context.read<UserProvider>();
      await roleProvider.logout(); // This clears _currentUser
      userProvider.clearUser(); // This clears cached user
      print('✅ Previous session cleared');

      final result = await ApiService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      print('📨 API Response received:');
      print('   Success: ${result['success']}');
      print('   Message: ${result['message']}');
      print('   Token: ${result['token']?.toString().substring(0, 30) ?? 'none'}...');
      print('   User: ${result['user']}');

      if (result['success']) {
        _showSuccess(result['message']);

        // Set user role data with fresh credentials
        print('🔐 Setting new user credentials...');
        await roleProvider.setUserFromLogin(result['user']);
        print('✅ New user credentials set');

        // Navigate to Dashboard
        if (mounted) {
          print('✅ Login successful, navigating to dashboard...');
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } else {
        print('❌ Login failed: ${result['message']}');
        _showError(result['message']);
      }
    } catch (e) {
      print('💥 EXCEPTION in login:');
      print('   Type: ${e.runtimeType}');
      print('   Message: $e');
      print('   Stack: ${StackTrace.current}');
      _showError('Connection error: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen size for responsive design
    final screenSize = MediaQuery.of(context).size;
    final isSmallDevice = screenSize.height < 600;
    final isMobilePortrait = screenSize.width < 600;

    // Responsive sizing
    final headerPadding = isSmallDevice ? 24.0 : 40.0;
    final iconSize = isSmallDevice ? 60.0 : 80.0;
    final iconBgSize = isSmallDevice ? 24.0 : 40.0;
    final titleFontSize = isSmallDevice ? 24.0 : 28.0;
    final subtitleFontSize = isSmallDevice ? 12.0 : 14.0;
    final labelFontSize = isSmallDevice ? 12.0 : 14.0;
    final inputPadding = isSmallDevice ? 12.0 : 14.0;
    final formPadding = isMobilePortrait ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                children: [
                  // Green Header with Calendar Icon
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: headerPadding),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF1ABC9C),
                          Color(0xFF16A085),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(30),
                        bottomRight: Radius.circular(30),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1ABC9C).withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Calendar Icon in Circle
                        Container(
                          width: iconSize,
                          height: iconSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.calendar_today,
                            size: iconBgSize,
                            color: const Color(0xFF1ABC9C),
                          ),
                        ),
                        SizedBox(height: isSmallDevice ? 14 : 16),
                        // Title
                        Text(
                          'SJ Booking',
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: isSmallDevice ? 8 : 10),
                        // Subtitle
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            'Sistem Pemesanan Ruangan & Kendaraan',
                            style: TextStyle(
                              fontSize: subtitleFontSize,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w400,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Login Form
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(formPadding),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: isSmallDevice ? 12 : 24),

                          // Error Message Alert (if any)
                          if (_errorMessage != null)
                            AnimatedOpacity(
                              opacity: _errorMessage != null ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                margin: const EdgeInsets.only(bottom: 24),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE5E5),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFEF5350),
                                    width: 1.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFEF5350).withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEF5350),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFFD32F2F),
                                          fontWeight: FontWeight.w500,
                                          height: 1.4,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Label
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    'Email',
                                    style: TextStyle(
                                      fontSize: labelFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF333333),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                // Email Input
                                Focus(
                                  onFocusChange: (isFocused) {
                                    setState(() {
                                      _isEmailFocused = isFocused;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _isEmailFocused ? Colors.white : Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isEmailFocused
                                            ? const Color(0xFF1ABC9C)
                                            : Colors.grey.shade200,
                                        width: _isEmailFocused ? 2 : 1.5,
                                      ),
                                      boxShadow: _isEmailFocused
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF1ABC9C).withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: TextFormField(
                                      controller: _emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      decoration: InputDecoration(
                                        hintText: 'nama@sarana-jaya.co.id',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: labelFontSize,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(left: 14, right: 12),
                                          child: Icon(
                                            Icons.email_outlined,
                                            color: _isEmailFocused
                                                ? const Color(0xFF1ABC9C)
                                                : Colors.grey.shade400,
                                            size: 22,
                                          ),
                                        ),
                                        prefixIconConstraints: const BoxConstraints(
                                          minWidth: 0,
                                          minHeight: 0,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                              vertical: inputPadding + 2,
                                              horizontal: 0,
                                            ),
                                      ),
                                      style: TextStyle(
                                        fontSize: labelFontSize,
                                        color: const Color(0xFF333333),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      cursorColor: const Color(0xFF1ABC9C),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Email is required';
                                        }
                                        if (!value.contains('@')) {
                                          return 'Please enter a valid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: isSmallDevice ? 16 : 24),

                                // Password Label
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: labelFontSize,
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF333333),
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                                // Password Input
                                Focus(
                                  onFocusChange: (isFocused) {
                                    setState(() {
                                      _isPasswordFocused = isFocused;
                                    });
                                  },
                                  child: AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    decoration: BoxDecoration(
                                      color: _isPasswordFocused ? Colors.white : Color(0xFFF8F9FA),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: _isPasswordFocused
                                            ? const Color(0xFF1ABC9C)
                                            : Colors.grey.shade200,
                                        width: _isPasswordFocused ? 2 : 1.5,
                                      ),
                                      boxShadow: _isPasswordFocused
                                          ? [
                                              BoxShadow(
                                                color: const Color(0xFF1ABC9C).withValues(alpha: 0.1),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ]
                                          : [],
                                    ),
                                    child: TextFormField(
                                      controller: _passwordController,
                                      obscureText: !_showPassword,
                                      decoration: InputDecoration(
                                        hintText: 'Masukkan password',
                                        hintStyle: TextStyle(
                                          color: Colors.grey.shade400,
                                          fontSize: labelFontSize,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        prefixIcon: Padding(
                                          padding: const EdgeInsets.only(left: 14, right: 12),
                                          child: Icon(
                                            Icons.lock_outline,
                                            color: _isPasswordFocused
                                                ? const Color(0xFF1ABC9C)
                                                : Colors.grey.shade400,
                                            size: 22,
                                          ),
                                        ),
                                        prefixIconConstraints: const BoxConstraints(
                                          minWidth: 0,
                                          minHeight: 0,
                                        ),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _showPassword = !_showPassword;
                                            });
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: 14),
                                            child: Icon(
                                              _showPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: Colors.grey.shade400,
                                              size: 22,
                                            ),
                                          ),
                                        ),
                                        suffixIconConstraints: const BoxConstraints(
                                          minWidth: 0,
                                          minHeight: 0,
                                        ),
                                        border: InputBorder.none,
                                        contentPadding:
                                            EdgeInsets.symmetric(
                                              vertical: inputPadding + 2,
                                              horizontal: 0,
                                            ),
                                      ),
                                      style: TextStyle(
                                        fontSize: labelFontSize,
                                        color: const Color(0xFF333333),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      cursorColor: const Color(0xFF1ABC9C),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Password is required';
                                        }
                                        if (value.length < 6) {
                                          return 'Password must be at least 6 characters';
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                SizedBox(height: isSmallDevice ? 20 : 28),

                                // Login Button
                                SizedBox(
                                  width: double.infinity,
                                  height: isSmallDevice ? 48 : 54,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1ABC9C),
                                      disabledBackgroundColor: Colors.grey.shade300,
                                      elevation: _isLoading ? 2 : 4,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2.5,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(Icons.login, size: 20),
                                              const SizedBox(width: 10),
                                              Text(
                                                'Masuk',
                                                style: TextStyle(
                                                  fontSize: isSmallDevice ? 15 : 17,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),

                                SizedBox(height: isSmallDevice ? 14 : 18),

                                // Register Link
                                Center(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFF0F9F8),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: const Color(0xFF1ABC9C).withValues(alpha: 0.2),
                                        width: 1,
                                      ),
                                    ),
                                    child: RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Belum punya akun? ',
                                            style: TextStyle(
                                              fontSize: isSmallDevice ? 12 : 13,
                                              color: const Color(0xFF666666),
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          WidgetSpan(
                                            child: GestureDetector(
                                              onTap: () {
                                                Navigator.of(context)
                                                    .pushNamed('/register');
                                              },
                                              child: Text(
                                                'Daftar di sini',
                                                style: TextStyle(
                                                  fontSize: isSmallDevice ? 12 : 13,
                                                  color: const Color(0xFF1ABC9C),
                                                  fontWeight: FontWeight.w700,
                                                  decoration: TextDecoration.underline,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Footer
                  Padding(
                    padding: EdgeInsets.all(isSmallDevice ? 12 : 20),
                    child: Text(
                      '© 2026 Sarana Jaya Booking System. All rights reserved.',
                      style: TextStyle(
                        fontSize: isSmallDevice ? 10 : 12,
                        color: Colors.grey.shade500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


