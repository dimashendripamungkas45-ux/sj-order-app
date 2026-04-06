# 📋 EXECUTION CHECKLIST & VISUAL GUIDE

**Panduan visual step-by-step dengan checklist untuk tracking progress.**

---

## 🎯 OVERVIEW: Apa yang akan kita lakukan

```
┌─────────────────────────────────────────────────────────────┐
│  MIGRATION: Local Storage → Server Database                │
│                                                             │
│  BEFORE (Offline)           →    AFTER (Online)            │
│  • Data di SharedPreferences  →  Data di MySQL Server       │
│  • Single device only         →  Multi-user support         │
│  • Manual sync                →  Auto sync via API          │
│  • No real-time updates       →  Real-time updates          │
└─────────────────────────────────────────────────────────────┘
```

---

## ⏱️ TIMELINE

```
Total Duration: 30-45 minutes

Phase 1: Backend Prep      → 5 minutes  ✓
Phase 2: App Config        → 5 minutes  ✓
Phase 3: Testing           → 10 minutes ✓
Phase 4: Data Migration    → 10 minutes ✓
Phase 5: Validation        → 5 minutes  ✓
                           ─────────────
                    Total: 35 minutes
```

---

# PHASE 1: BACKEND PREPARATION (5 min)

## ☐ STEP 1.1: Start Backend Server

**Terminal Window 1 (Backend):**

```bash
# Navigate to backend folder
cd C:\path\to\laravel\backend

# Start server
php artisan serve --host=0.0.0.0 --port=8000
```

**Expected Output:**
```
  Laravel development server started: http://0.0.0.0:8000
  Listening on http://0.0.0.0:8000
```

**Verification:**
```bash
# In another terminal/browser:
curl http://localhost:8000/api/health

# Should return:
{"status":"ok"}
```

✅ **Step Complete** when you see: `Listening on http://0.0.0.0:8000`

---

## ☐ STEP 1.2: Verify Database

**Check Database Connection:**

```bash
# Open MySQL/command line
php artisan tinker

# Test connection
>>> DB::connection()->getPdo();
# If no error, database is connected ✓

# List all tables
>>> DB::select('SHOW TABLES');
# Should show: bookings, users, rooms, vehicles, divisions, etc.

# Check users table has test user
>>> DB::table('users')->where('email', 'admin@example.com')->first();
# Should return user object

# Exit tinker
>>> exit
```

**If user doesn't exist, create:**

```bash
php artisan tinker
>>> use App\Models\User;
>>> use Illuminate\Support\Facades\Hash;
>>> User::create([
    'name' => 'Admin',
    'email' => 'admin@example.com',
    'password' => Hash::make('password'),
    'role' => 'admin',
    'status' => 'active'
]);
>>> exit
```

✅ **Step Complete** when you have a test user account

---

## ☐ STEP 1.3: Test API Endpoints

**Test Login Endpoint (Postman or curl):**

```bash
curl -X POST http://localhost:8000/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password"
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "data": {
    "id": 1,
    "name": "Admin",
    "email": "admin@example.com",
    "role": "admin"
  }
}
```

✅ **Step Complete** when login returns token

---

# PHASE 2: FLUTTER APP CONFIGURATION (5 min)

## ☐ STEP 2.1: Update API Base URL

**File: `lib/utils/constants.dart` or `lib/services/api_service.dart`**

### ⚠️ CHOOSE YOUR SETUP:

#### OPTION A: Android Emulator (DEFAULT)
Use this if running from Android emulator:

```dart
// File: lib/utils/constants.dart

class AppConstants {
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api';
  //                                    ^^^^^^^^^ Virtual IP for emulator
  static const String apiTimeout = '30'; // Increased from 10 to 30
}

// OR in lib/services/api_service.dart:
class ApiService {
  static const String baseUrl = 'http://10.0.2.2:8000/api';
}
```

#### OPTION B: Physical Device
Use this if testing on real Android phone:

```dart
// First, find your PC IP:
// Windows Command Prompt: ipconfig
// Look for IPv4 Address (e.g., 192.168.1.100)

// Then update:
class AppConstants {
  static const String apiBaseUrl = 'http://192.168.1.100:8000/api';
  //                                    ^^^^^^^^^^^^^^^ Your PC IP
}
```

#### OPTION C: Cloud/VPS Server
Use this if backend on cloud server:

```dart
class AppConstants {
  static const String apiBaseUrl = 'https://yourdomain.com/api';
  //                                    ^^^^^^^^^^^^^^^^^ Your domain
}
```

**Verify the change:**
```bash
# Check file was updated
grep -n "apiBaseUrl\|baseUrl" lib/utils/constants.dart lib/services/api_service.dart
```

✅ **Step Complete** when URL updated correctly

---

## ☐ STEP 2.2: Check Dependencies

**File: `pubspec.yaml`**

Ensure these packages present:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP Requests
  http: ^1.1.0              # For API calls
  
  # Local Storage  
  shared_preferences: ^2.2.0  # For token/user caching
  
  # State Management
  provider: ^6.0.0          # For state management
  
  # JSON Parsing
  # (Built-in with dart:convert)
```

**If packages missing:**
```bash
flutter pub add http shared_preferences provider
```

**Install:**
```bash
flutter pub get
```

✅ **Step Complete** when all dependencies installed

---

## ☐ STEP 2.3: Flutter Clean & Build

```bash
# Clean project
flutter clean

# Get dependencies
flutter pub get

# Run app
flutter run
```

✅ **Step Complete** when app runs without compilation errors

---

# PHASE 3: TESTING (10 min)

## ☐ STEP 3.1: Test Login

**In Flutter App:**

1. Open Login Screen
2. Enter credentials:
   - Email: `admin@example.com`
   - Password: `password`
3. Press Login button

**Expected Result:**
```
✅ Login successful (no timeout)
✅ Navigates to dashboard
✅ No error messages
```

**Check Debug Console:**
```
🔄 [ApiService.login] Starting login flow...
✅ [ApiService.login] Token saved
✅ [ApiService.login] User data saved
✅ [ApiService.login] Login successful
```

**If Error:**
See [TROUBLESHOOTING_MIGRATION.md](./TROUBLESHOOTING_MIGRATION.md)

✅ **Step Complete** when login succeeds without timeout

---

## ☐ STEP 3.2: Verify Token Saved

**Add temporary debug code to main.dart:**

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Check storage after login
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  final userData = prefs.getString('user_data');
  
  print('📦 STORAGE CHECK:');
  print('Token: ${token != null ? '✅ SAVED' : '❌ NOT FOUND'}');
  print('Token preview: ${token?.substring(0, 30)}...');
  print('User data: ${userData != null ? '✅ SAVED' : '❌ NOT FOUND'}');
  
  runApp(const MyApp());
}
```

**Expected Output:**
```
📦 STORAGE CHECK:
Token: ✅ SAVED
Token preview: eyJ0eXAiOiJKV1QiLCJhbGc...
User data: ✅ SAVED
```

✅ **Step Complete** when token and user data saved

---

## ☐ STEP 3.3: Test User Data Fetch

**Create test button (add to dashboard):**

```dart
ElevatedButton(
  onPressed: () async {
    final result = await ApiService.getCurrentUser();
    print('User fetch result: ${result['success']}');
    print('User data: ${result['user']}');
  },
  child: Text('Test Fetch User'),
)
```

**Expected Result:**
```
User fetch result: true
User data: {id: 1, name: Admin, email: admin@example.com, ...}
```

✅ **Step Complete** when user data fetched successfully

---

# PHASE 4: DATA MIGRATION (10 min)

## ☐ STEP 4.1: Backup Local Data (IMPORTANT!)

**Create backup (add to app temporarily):**

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

Future<void> backupLocalData() async {
  final prefs = await SharedPreferences.getInstance();
  
  final backup = {
    'timestamp': DateTime.now().toIso8601String(),
    'auth_token': prefs.getString('auth_token'),
    'user_data': prefs.getString('user_data'),
    'all_keys': prefs.getKeys().toList(),
  };
  
  final backupJson = jsonEncode(backup);
  print('📦 BACKUP:\n$backupJson');
  
  // Save to file or log for reference
}
```

✅ **Step Complete** when backup created and logged

---

## ☐ STEP 4.2: Create Sync Service

**Create file: `lib/services/sync_service.dart`**

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'auth_service.dart';

class SyncService {
  /// Sinkronisasi data dari server
  static Future<bool> syncData() async {
    try {
      print('🔄 [SyncService] Starting sync...');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ No token, cannot sync');
        return false;
      }

      // Sync user data
      print('📥 Syncing user data...');
      final userResult = await ApiService.getCurrentUser();
      if (userResult['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', 
          jsonEncode(userResult['user']));
        print('✅ User synced');
      }

      // Sync bookings
      print('📥 Syncing bookings...');
      final bookingsResult = await ApiService.getBookings();
      if (bookingsResult['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('bookings', 
          jsonEncode(bookingsResult['data']));
        print('✅ Bookings synced: ${bookingsResult['data'].length} items');
      }

      print('✅ Sync completed');
      return true;
    } catch (e) {
      print('❌ Sync error: $e');
      return false;
    }
  }
}
```

✅ **Step Complete** when sync service created

---

## ☐ STEP 4.3: Call Sync on App Start

**Update `main.dart`:**

```dart
import 'services/sync_service.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check if user logged in, then sync
  final isLoggedIn = await AuthService.isLoggedIn();
  
  if (isLoggedIn) {
    print('🔄 User logged in, syncing data...');
    await SyncService.syncData();
    print('✅ Data synced');
  }

  runApp(const MyApp());
}
```

**Expected Output:**
```
🔄 User logged in, syncing data...
🔄 [SyncService] Starting sync...
📥 Syncing user data...
✅ User synced
📥 Syncing bookings...
✅ Bookings synced: 5 items
✅ Sync completed
```

✅ **Step Complete** when sync runs on app startup

---

## ☐ STEP 4.4: Migrate Existing Bookings (If Any)

**Option A: No existing bookings**
- Skip to Step 5

**Option B: Have local bookings to migrate**

```bash
# Via API, create bookings on server:
curl -X POST http://10.0.2.2:8000/api/bookings \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "booking_type": "room",
    "room_id": 1,
    "booking_date": "2026-04-15",
    "start_time": "09:00",
    "end_time": "11:00",
    "purpose": "Meeting",
    "participants_count": 5
  }'
```

✅ **Step Complete** when historical data migrated (or none to migrate)

---

# PHASE 5: VALIDATION (5 min)

## ☐ STEP 5.1: Full Flow Test

**Complete workflow test:**

```
1. ✅ Restart app
   └─ Should sync automatically
   
2. ✅ Check dashboard loads
   └─ Should show user info from server
   
3. ✅ Create new booking via app
   └─ Should POST to API
   └─ Should appear in list immediately
   
4. ✅ View booking history
   └─ Should show all bookings from server
   
5. ✅ Check approval flow
   └─ If admin, should see approval panel
   └─ Should be able to approve/reject
   
6. ✅ No errors in debug console
   └─ No 401, 404, 500, or timeout
```

✅ **Step Complete** when all tests pass

---

## ☐ STEP 5.2: Performance Check

**Measure response times:**

```dart
// Add to dashboard screen temporarily:

Future<void> checkPerformance() async {
  Stopwatch stopwatch;

  // Test 1: Get User
  stopwatch = Stopwatch()..start();
  await ApiService.getCurrentUser();
  stopwatch.stop();
  print('Get User: ${stopwatch.elapsedMilliseconds}ms');

  // Test 2: Get Bookings
  stopwatch = Stopwatch()..start();
  await ApiService.getBookings();
  stopwatch.stop();
  print('Get Bookings: ${stopwatch.elapsedMilliseconds}ms');

  // Expected:
  // Get User: 100-300ms ✓
  // Get Bookings: 200-800ms ✓
}
```

**Acceptable Times:**
```
✅ < 500ms   = Excellent
✅ 500-1000ms = Good
⚠️  > 1000ms = Needs optimization
```

✅ **Step Complete** when response times acceptable

---

## ☐ STEP 5.3: Data Integrity Check

**Verify data in database:**

```bash
# Check users
mysql> SELECT id, name, email FROM users;
# Should show all user records

# Check bookings
mysql> SELECT id, booking_code, user_id FROM bookings;
# Should show all booking records

# Verify relationships
mysql> SELECT 
  b.booking_code,
  u.name,
  b.status
FROM bookings b
JOIN users u ON b.user_id = u.id
LIMIT 5;
# Should show valid joined data
```

✅ **Step Complete** when data integrity verified

---

## ☐ STEP 5.4: Error Handling Check

**Intentionally cause errors to verify handling:**

```
1. Stop backend server
   └─ App should show: "Server timeout"
   └─ Should use cached data
   
2. Disconnect network
   └─ App should show: "No internet connection"
   └─ Should use cached data
   
3. Try with invalid token
   └─ App should logout user
   └─ Should redirect to login
```

✅ **Step Complete** when error handling works

---

# ✅ FINAL VERIFICATION CHECKLIST

```
Backend Ready:
  ☑ php artisan serve running
  ☑ Database migrated
  ☑ Test user created
  ☑ API endpoints responding
  
App Configuration:
  ☑ API URL updated
  ☑ Dependencies installed
  ☑ Code compiled
  
Testing Complete:
  ☑ Login successful
  ☑ Token saved locally
  ☑ User data fetched from API
  ☑ Bookings loaded from server
  
Performance:
  ☑ Response times < 1 second
  ☑ No timeout errors
  ☑ Smooth data loading
  
Data:
  ☑ Data synced on startup
  ☑ Data integrity verified
  ☑ Historical data migrated
  
Error Handling:
  ☑ Offline mode works
  ☑ Timeout handled gracefully
  ☑ Invalid token handled
```

---

# 🎉 SUCCESS INDICATORS

When you see all these ✅, migration is complete:

```
✅ Login works without timeout
✅ Token saved in SharedPreferences
✅ User data loaded from server
✅ Bookings fetched from database
✅ Can create new bookings via API
✅ Approval system operational
✅ No connection errors
✅ Performance acceptable
✅ Error handling working
✅ Production ready! 🚀
```

---

# 📊 MIGRATION SUMMARY

| Aspect | Local (Before) | Server (After) |
|--------|---|---|
| **Storage** | Device only | Server database |
| **Scale** | Single user | Multi-user |
| **Real-time** | ❌ No | ✅ Yes |
| **Backup** | ❌ Manual | ✅ Server backup |
| **Accessibility** | Device only | Any device |
| **Sync** | ❌ Manual | ✅ Auto |

---

# 🆘 QUICK HELP

**Still having issues?**

1. Check [TROUBLESHOOTING_MIGRATION.md](./TROUBLESHOOTING_MIGRATION.md)
2. Run diagnostic tests
3. Check Laravel logs: `storage/logs/laravel.log`
4. Verify database: `php artisan tinker`

---

## 📞 SUPPORT MATRIX

| Error | Solution File | Time |
|-------|---|---|
| Timeout | TROUBLESHOOTING_MIGRATION.md → Section A | 5 min |
| Connection Refused | TROUBLESHOOTING_MIGRATION.md → Section B | 5 min |
| 401 Unauthorized | TROUBLESHOOTING_MIGRATION.md → Section C | 5 min |
| 500 Server Error | TROUBLESHOOTING_MIGRATION.md → Section D | 10 min |
| 404 Not Found | TROUBLESHOOTING_MIGRATION.md → Section E | 5 min |

---

**Status:** ✅ Ready for Implementation  
**Last Updated:** 2026-04-12  
**Version:** 1.0

