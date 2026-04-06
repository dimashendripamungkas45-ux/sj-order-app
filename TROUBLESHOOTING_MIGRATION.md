# 🔧 TROUBLESHOOTING & VERIFICATION GUIDE

**Untuk membedakan antara masalah lokal vs server, dan solusinya.**

---

## 📊 DIAGNOSIS FLOWCHART

```
App muncul error atau tidak bisa login?
    │
    ├─→ Timeout Error (10 detik tidak ada response)
    │   └─→ Go to: SECTION A - Timeout Issues
    │
    ├─→ Connection Refused (TCP connection reject)
    │   └─→ Go to: SECTION B - Connection Issues
    │
    ├─→ 401 Unauthorized
    │   └─→ Go to: SECTION C - Authentication Issues
    │
    ├─→ 500 Internal Server Error
    │   └─→ Go to: SECTION D - Backend Issues
    │
    └─→ 404 Not Found
        └─→ Go to: SECTION E - Endpoint Issues
```

---

# SECTION A: TIMEOUT ISSUES

## ⏱️ Problem: TimeoutException after 0:00:10

**Error yang Anda lihat:**
```
I/flutter (11886): 💥 [ApiService.login] Exception: TimeoutException after 0:00:10.000000: Future not completed
I/flutter (11886): ❌ Login failed: Connection error: TimeoutException...
```

### Diagnosis Checklist:

```bash
□ Step 1: Backend server running?
   Command: ps aux | grep "php artisan serve"
   Expected: Process visible
   
□ Step 2: Backend accessible from Windows?
   Command: ping 127.0.0.1
   Expected: Reply from 127.0.0.1
   
□ Step 3: Port 8000 listening?
   Command: netstat -ano | findstr :8000
   Expected: LISTENING
   
□ Step 4: Correct API URL in app?
   Check: lib/utils/constants.dart or lib/services/api_service.dart
   For emulator: http://10.0.2.2:8000/api
   For device: http://192.168.x.x:8000/api
   
□ Step 5: Network connectivity?
   Test: adb shell ping 10.0.2.2 (for emulator)
   Expected: Replies received
```

### Solutions (in priority order):

#### ✅ Solution 1: Start Backend (Most Common)
```bash
# Terminal 1: Backend
cd C:\path\to\laravel\backend
php artisan serve --host=0.0.0.0 --port=8000

# Should see:
# Laravel development server started: http://0.0.0.0:8000
```

#### ✅ Solution 2: Check & Fix API URL

**For Android Emulator:**
```dart
// File: lib/services/api_service.dart
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
  //                                   ^^^^^^^^^ (this is correct for emulator)
}
```

**For Physical Device (Find your PC IP):**
```bash
# Windows Command Prompt:
ipconfig

# Look for: IPv4 Address: 192.168.x.x
# Then in app:
static const String baseUrl = 'http://192.168.x.x:8000/api';
```

**For Cloud Server:**
```dart
static const String baseUrl = 'https://yourdomain.com/api';
```

#### ✅ Solution 3: Increase Timeout
```dart
// File: lib/services/api_service.dart
class ApiService {
  // Change from 10 seconds to 30 seconds
  static Future<Map<String, dynamic>> login(...) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        // ...
      ).timeout(const Duration(seconds: 30)); // ← Changed from 10 to 30
    } catch (e) {
      // ...
    }
  }
}
```

#### ✅ Solution 4: Check Network Connectivity
```dart
// Add this to test network
import 'package:connectivity_plus/connectivity_plus.dart';

void testNetwork() async {
  final connectivity = Connectivity();
  final result = await connectivity.checkConnectivity();
  print('Network status: $result');
  // Should output: ConnectivityResult.mobile or ConnectivityResult.wifi
}
```

#### ✅ Solution 5: Clear Flutter Cache
```bash
flutter clean
flutter pub get
flutter run
```

---

## 🧪 Verification Test untuk Section A

```dart
// Create: lib/screens/diagnostic_screen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class DiagnosticScreen extends StatefulWidget {
  @override
  State<DiagnosticScreen> createState() => _DiagnosticScreenState();
}

class _DiagnosticScreenState extends State<DiagnosticScreen> {
  String log = 'Diagnostic Log:\n\n';

  void addLog(String message) {
    setState(() => log += '$message\n');
    print(message);
  }

  void runDiagnostics() async {
    addLog('🧪 Starting diagnostics...\n');

    // Test 1: Simple HTTP connectivity
    addLog('Test 1: Testing HTTP connectivity to 10.0.2.2:8000');
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/api/health'),
      ).timeout(Duration(seconds: 5));
      addLog('✅ Got response: ${response.statusCode}');
    } catch (e) {
      addLog('❌ Failed: $e');
    }

    // Test 2: Login endpoint
    addLog('\nTest 2: Testing login endpoint');
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:8000/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: '{"email":"admin@example.com","password":"password"}',
      ).timeout(Duration(seconds: 10));
      addLog('✅ Login endpoint responds: ${response.statusCode}');
      if (response.statusCode == 200) {
        addLog('✅ Login successful!');
      } else {
        addLog('⚠️ Status: ${response.statusCode}');
        addLog('Response: ${response.body}');
      }
    } catch (e) {
      addLog('❌ Failed: $e');
    }

    addLog('\n✅ Diagnostics complete');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Diagnostic Tool')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.bug_report),
              label: Text('Run Diagnostics'),
              onPressed: () {
                setState(() => log = '');
                runDiagnostics();
              },
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(
                log,
                style: TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

**Usage dalam main.dart:**
```dart
// For testing, navigate to diagnostic screen
// home: DiagnosticScreen(),  // Uncomment to test
```

---

# SECTION B: CONNECTION REFUSED

## 🔌 Problem: Connection refused / Unable to connect

**Error yang Anda lihat:**
```
Failed to connect to 10.0.2.2:8000
Connection refused
```

### Checklist:

```bash
□ Backend running?
  Command: php artisan serve --host=0.0.0.0 --port=8000
  
□ Port 8000 listening?
  Command: netstat -ano | findstr :8000
  
□ Firewall allowing port 8000?
  Windows Firewall might block it
  
□ Using correct IP for device type?
  Emulator: 10.0.2.2
  Device: Your PC's local IP (from ipconfig)
```

### Solutions:

#### ✅ Solution 1: Restart Backend
```bash
# Stop current process
Ctrl+C

# Clear any stuck processes
taskkill /F /IM php.exe

# Start fresh
php artisan serve --host=0.0.0.0 --port=8000
```

#### ✅ Solution 2: Check Firewall
```bash
# Windows: Allow PHP through firewall
# Settings → Windows Defender Firewall → Allow app through firewall
# Find: php.exe → Allow
```

#### ✅ Solution 3: Use Different Port
```bash
# Try port 8001 if 8000 busy
php artisan serve --host=0.0.0.0 --port=8001

# Update in app:
static const String baseUrl = 'http://10.0.2.2:8001/api';
```

#### ✅ Solution 4: Verify with curl/Postman
```bash
# Test endpoint directly
curl http://10.0.2.2:8000/api/health

# Or use Postman:
# Method: GET
# URL: http://10.0.2.2:8000/api/health
# Should return: {"status":"ok"}
```

---

# SECTION C: AUTHENTICATION ISSUES

## 🔐 Problem: 401 Unauthorized

**Error yang Anda lihat:**
```
Status: 401
Message: Unauthenticated
```

### Checklist:

```bash
□ Token being sent?
  Check: Authorization header with "Bearer TOKEN"
  
□ Token valid?
  Check: Token not expired
  
□ User exists?
  Check: SELECT * FROM users WHERE email='admin@example.com'
  
□ Password correct?
  Check: php artisan tinker → Hash::check('password', ...)
```

### Solutions:

#### ✅ Solution 1: Verify Token is Sent

```dart
// In api_service.dart, add this:
static Future<Map<String, dynamic>> getCurrentUser() async {
  try {
    final token = await AuthService.getToken();
    print('📍 Token available: ${token != null}');
    print('📍 Token: ${token?.substring(0, 20)}...');
    
    if (token == null) {
      return {
        'success': false,
        'message': 'No token found. Please login first.',
      };
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token', // ← Important!
      },
    ).timeout(const Duration(seconds: 10));

    // ... rest of code
  } catch (e) {
    print('❌ Error: $e');
    return {'success': false, 'message': 'Error: $e'};
  }
}
```

#### ✅ Solution 2: Check User Exists

```bash
# In database:
mysql> SELECT id, email, password FROM users;

# Should show admin user:
| 1 | admin@example.com | $2y$10$... | (hashed password)
```

#### ✅ Solution 3: Verify Password Hash

```bash
# Test in tinker
php artisan tinker
>>> use App\Models\User;
>>> $user = User::find(1);
>>> Hash::check('password', $user->password);
# Should return: true (or false if wrong password)
```

#### ✅ Solution 4: Force Re-login

```dart
// In app:
await AuthService.clearAuthData(); // Clear old token
// Then login again
```

---

# SECTION D: BACKEND ERRORS (500)

## 🔴 Problem: 500 Internal Server Error

**Error yang Anda lihat:**
```
Status: 500
Internal Server Error
```

### Checklist:

```bash
□ Check Laravel logs?
  File: storage/logs/laravel.log
  
□ Database migrated?
  Command: php artisan migrate:status
  
□ Database connected?
  Command: php artisan tinker → DB::connection()->getPdo()
  
□ Syntax errors?
  Check: php artisan tinker (syntax check)
```

### Solutions:

#### ✅ Solution 1: Check Laravel Logs

```bash
# View latest errors
cat storage/logs/laravel.log | tail -50

# Or on Windows:
Get-Content storage\logs\laravel.log -Tail 50
```

**Common errors:**
- `SQLSTATE[HY000]: General error` → Database issue
- `Class not found` → Missing controller/model
- `Undefined key` → Array access error

#### ✅ Solution 2: Run Migrations

```bash
# Check status
php artisan migrate:status

# Run all pending migrations
php artisan migrate

# If tables already exist:
php artisan migrate --force
```

#### ✅ Solution 3: Check Database Connection

```bash
# Test connection
php artisan tinker
>>> DB::connection()->getPdo();
# If error, check .env DB_* values

# List tables
>>> DB::select('SHOW TABLES');
```

#### ✅ Solution 4: Common Laravel Fixes

```bash
# Clear cache
php artisan cache:clear
php artisan config:clear

# Regenerate app key
php artisan key:generate

# Optimize
php artisan optimize
```

---

# SECTION E: ENDPOINT ISSUES

## 🚫 Problem: 404 Not Found

**Error yang Anda lihat:**
```
Status: 404
Not Found
```

### Checklist:

```bash
□ API routes defined?
  File: routes/api.php
  Check: Route::post('/login', ...)
  
□ Correct URL?
  Should: http://10.0.2.2:8000/api/login
  NOT: http://10.0.2.2:8000/login
  
□ Routes registered?
  Command: php artisan route:list
```

### Solutions:

#### ✅ Solution 1: List All Routes

```bash
# See all registered routes
php artisan route:list

# Filter API routes
php artisan route:list | grep api

# Should show:
# POST    /api/login
# POST    /api/register
# GET     /api/user
# etc.
```

#### ✅ Solution 2: Verify Route Definition

**File: routes/api.php**

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserManagementController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // User management
    Route::apiResource('users', UserManagementController::class);
});
```

#### ✅ Solution 3: Test Route with Postman

```bash
# Simple route test
GET http://10.0.2.2:8000/api/health

# Should return:
# {"status":"ok"}

# If 404, the issue is routes not registered
```

---

## 🧪 COMPREHENSIVE TEST SUITE

Create file: `lib/services/test_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestService {
  static const String apiUrl = 'http://10.0.2.2:8000/api';

  static Future<void> runAllTests() async {
    print('\n' + '='*60);
    print('🧪 RUNNING COMPREHENSIVE TESTS');
    print('='*60 + '\n');

    await testHealthEndpoint();
    await testLoginEndpoint();
    await testUserEndpoint();
    await testMeasureResponseTime();

    print('\n' + '='*60);
    print('✅ ALL TESTS COMPLETED');
    print('='*60 + '\n');
  }

  static Future<void> testHealthEndpoint() async {
    print('\n📌 TEST 1: Health Check Endpoint');
    print('─' * 50);
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/health'),
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        print('✅ PASS - Server is responding');
        print('Response: ${response.body}');
      } else {
        print('❌ FAIL - Status: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ FAIL - $e');
    }
  }

  static Future<void> testLoginEndpoint() async {
    print('\n📌 TEST 2: Login Endpoint');
    print('─' * 50);
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': 'admin@example.com',
          'password': 'password',
        }),
      ).timeout(Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success']) {
        print('✅ PASS - Login successful');
        print('Token: ${data['token']?.substring(0, 20)}...');
      } else {
        print('❌ FAIL - ${data['message']}');
      }
    } catch (e) {
      print('❌ FAIL - $e');
    }
  }

  static Future<void> testUserEndpoint() async {
    print('\n📌 TEST 3: Get Current User Endpoint');
    print('─' * 50);
    try {
      // First login to get token
      final loginResponse = await http.post(
        Uri.parse('$apiUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': 'admin@example.com',
          'password': 'password',
        }),
      );

      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['token'];

      if (token == null) {
        print('❌ FAIL - Cannot get token from login');
        return;
      }

      // Now test user endpoint
      final response = await http.get(
        Uri.parse('$apiUrl/user'),
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ PASS - User endpoint working');
        print('User: ${data['data']['name']}');
      } else {
        print('❌ FAIL - Status: ${response.statusCode}');
        print('Response: ${response.body}');
      }
    } catch (e) {
      print('❌ FAIL - $e');
    }
  }

  static Future<void> testMeasureResponseTime() async {
    print('\n📌 TEST 4: Response Time Measurement');
    print('─' * 50);

    final stopwatch = Stopwatch();

    // Login response time
    stopwatch.start();
    final loginResponse = await http.post(
      Uri.parse('$apiUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'admin@example.com',
        'password': 'password',
      }),
    );
    stopwatch.stop();
    print('Login: ${stopwatch.elapsedMilliseconds}ms');

    if (loginResponse.statusCode == 200) {
      final loginData = jsonDecode(loginResponse.body);
      final token = loginData['token'];

      // User endpoint response time
      stopwatch.reset();
      stopwatch.start();
      await http.get(
        Uri.parse('$apiUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );
      stopwatch.stop();
      print('Get User: ${stopwatch.elapsedMilliseconds}ms');

      print('\n✅ Response times acceptable' + 
            (stopwatch.elapsedMilliseconds < 500 ? ' ✓' : ' ⚠️'));
    }
  }
}
```

**Gunakan di main.dart:**
```dart
import 'services/test_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Run tests (remove after debugging)
  await TestService.runAllTests();
  
  runApp(const MyApp());
}
```

---

## 📝 FINAL CHECKLIST

```
Backend Verification:
  ✅ php artisan serve running
  ✅ Database migrated
  ✅ API routes defined
  ✅ Test user created
  
Network Verification:
  ✅ Correct IP in constants
  ✅ Port 8000 accessible
  ✅ Firewall allows connection
  ✅ No proxy/VPN blocking
  
API Verification:
  ✅ /api/health responds
  ✅ /api/login works
  ✅ /api/user works with token
  ✅ Response time < 1 second
  
App Verification:
  ✅ Can login
  ✅ Token saved
  ✅ User data cached
  ✅ No timeout errors
  ✅ No 401/404/500 errors
```

---

**Last Updated:** 2026-04-12  
**Version:** 1.0

