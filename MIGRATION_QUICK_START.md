# 🎯 QUICK START: Migrasi Local → Server (5-10 Menit)

**Untuk yang terburu-buru! Copy-paste friendly guides.**

---

## 🚀 STEP 1: Periksa Backend (2 menit)

### Terminal Backend:
```bash
# Pastikan sudah di folder backend Laravel
cd C:\path\to\laravel\backend

# Run server
php artisan serve --host=0.0.0.0 --port=8000

# Output yang benar:
# Laravel development server started: http://0.0.0.0:8000
# Listening on http://0.0.0.0:8000
```

### Verifikasi dengan Browser:
```
http://localhost:8000/api/health

# Harusnya respond: {"status":"ok"}
```

---

## 🎯 STEP 2: Update Flutter Constants (2 menit)

### File: `lib/utils/constants.dart`

**SEBELUM:**
```dart
class AppConstants {
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api'; // Lokal default
  static const String apiTimeout = '10';
  // ...
}
```

**SESUDAH (pilih salah satu sesuai setup Anda):**

#### Option A: Android Emulator (DEFAULT)
```dart
class AppConstants {
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  static const String apiTimeout = '30'; // 30 detik
  // ...
}
```

#### Option B: Physical Device
```dart
// Cari IP komputer dengan cmd: ipconfig
// Contoh: 192.168.1.100

class AppConstants {
  static const String apiBaseUrl = 'http://192.168.1.100:8000/api';
  static const String apiTimeout = '30';
  // ...
}
```

#### Option C: Cloud Server
```dart
class AppConstants {
  static const String apiBaseUrl = 'https://api.example.com/api';
  static const String apiTimeout = '30';
  // ...
}
```

**Alternatif: Edit langsung di `lib/services/api_service.dart`:**
```dart
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api'; // ← UPDATE INI
```

---

## ✅ STEP 3: Test Connection (1 menit)

### Run Flutter App:
```bash
flutter run
```

### Di debug console, cari:
```
🔄 [ApiService.login] Starting login flow...
```

### Jika ada error "TimeoutException":
- ❌ Backend tidak running → Go back to STEP 1
- ❌ Wrong IP address → Update constants
- ❌ Firewall blocking → Allow port 8000

---

## 🔐 STEP 4: Login Test (1 menit)

### Gunakan credentials:
```
Email: admin@example.com
Password: password
```

### Jika login SUCCESS:
```
✅ [ApiService.login] Login successful
✅ [ApiService.login] Token saved
✅ [ApiService.login] User data saved
```

### Jika login FAILED:
```
❌ Login failed: [error message]
```

**Solusi:**
- Verify user ada di database: `SELECT * FROM users WHERE email = 'admin@example.com';`
- Check password correct: `php artisan tinker` → `Hash::check('password', User::find(1)->password)`

---

## 📊 STEP 5: Verify Data di SharedPreferences

**Tambah ini ke main.dart sementara:**

```dart
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check what's saved
  final prefs = await SharedPreferences.getInstance();
  print('📦 SharedPreferences contents:');
  print('auth_token: ${prefs.getString('auth_token')?.substring(0, 20)}...');
  print('user_data: ${prefs.getString('user_data')}');
  
  runApp(const MyApp());
}
```

**Output yang diharapkan:**
```
auth_token: eyJ0eXAiOiJKV1QiLCJhbGc...
user_data: {"id":1,"name":"Admin","email":"admin@example.com",...}
```

---

## 🧪 STEP 6: Test Data Fetch (2 menit)

**Buat simple test screen:**

```dart
import 'package:flutter/material.dart';
import 'services/api_service.dart';

class TestScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('API Test')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final result = await ApiService.getCurrentUser();
                print('Result: $result');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${result['success'] ? '✅' : '❌'} ${result['message']}')),
                );
              },
              child: Text('Test Fetch User'),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final result = await ApiService.getBookings();
                print('Result: $result');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${result['success'] ? '✅' : '❌'} ${result['message']}')),
                );
              },
              child: Text('Test Fetch Bookings'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 🎯 STEP 7: Sync Data (Optional tapi Recommended)

**Update `main.dart` untuk auto-sync saat startup:**

```dart
import 'services/sync_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if already logged in
  final isLoggedIn = await AuthService.isLoggedIn();
  
  if (isLoggedIn) {
    print('🔄 User logged in, syncing data...');
    await SyncService.syncData();
    print('✅ Data synced');
  }

  runApp(const MyApp());
}
```

**Buat `lib/services/sync_service.dart`:**

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'auth_service.dart';

class SyncService {
  static Future<bool> syncData() async {
    try {
      print('🔄 [SyncService] Starting sync...');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No token');
        return false;
      }

      // Fetch user
      final userResult = await ApiService.getCurrentUser();
      if (userResult['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', jsonEncode(userResult['user']));
        print('✅ User synced');
      }

      // Fetch bookings
      final bookingsResult = await ApiService.getBookings();
      if (bookingsResult['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bookings', jsonEncode(bookingsResult['data']));
        print('✅ Bookings synced: ${bookingsResult['data'].length} items');
      }

      return true;
    } catch (e) {
      print('❌ Sync error: $e');
      return false;
    }
  }
}
```

---

## ⚠️ COMMON ERRORS & QUICK FIXES

### Error 1: TimeoutException after 0:00:10
```
Problem: Backend not responding
Solution: 
  1. Check if php artisan serve running
  2. Check if correct IP in constants
  3. Increase timeout in api_service.dart to 30 seconds
```

### Error 2: Connection refused
```
Problem: Cannot connect to backend
Solution:
  1. php artisan serve --host=0.0.0.0 --port=8000
  2. Check firewall allows port 8000
  3. Verify IP address correct
```

### Error 3: 401 Unauthorized
```
Problem: Invalid token
Solution:
  1. Login ulang
  2. Clear cache: await AuthService.clearAuthData()
  3. Check token not expired in database
```

### Error 4: 500 Internal Server Error
```
Problem: Backend error
Solution:
  1. Check Laravel logs: storage/logs/laravel.log
  2. Run migrations: php artisan migrate
  3. Check database connection
```

---

## 🧠 UNDERSTANDING THE FLOW

```
┌──────────────────┐
│  User Login      │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────────────┐
│ ApiService.login(email, password)│
└────────┬──────────────────────────┘
         │ HTTP POST to /api/login
         ▼
┌──────────────────────────────────┐
│  Laravel Backend                 │
│  ├─ Validate credentials         │
│  ├─ Generate token               │
│  └─ Return token + user data     │
└────────┬──────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Parse Response                   │
│ ├─ Extract token                 │
│ └─ Extract user data             │
└────────┬──────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Save to SharedPreferences        │
│ ├─ auth_token (for future API)   │
│ └─ user_data (for cache)         │
└────────┬──────────────────────────┘
         │
         ▼
┌──────────────────────────────────┐
│ Navigate to Dashboard            │
│ ✅ User can now use app          │
└──────────────────────────────────┘
```

---

## ✨ SUCCESS INDICATORS

Kalau sudah melihat ini, migrasi sudah berhasil:

```
✅ Login successful (no timeout)
✅ Token saved in SharedPreferences
✅ User data cached locally
✅ Can fetch user from API
✅ Can create bookings via API
✅ Approval system working
✅ No connection errors
```

---

## 📝 CHECKLIST

- [ ] Backend running on http://0.0.0.0:8000
- [ ] Flutter constants updated
- [ ] Can successfully login
- [ ] Token saved to cache
- [ ] Can fetch user from API
- [ ] App not showing timeout errors
- [ ] Data syncing on app startup
- [ ] Ready for production

---

**Time to complete:** 5-10 minutes  
**Difficulty:** ⭐⭐ Easy  
**Status:** ✅ Ready to implement

