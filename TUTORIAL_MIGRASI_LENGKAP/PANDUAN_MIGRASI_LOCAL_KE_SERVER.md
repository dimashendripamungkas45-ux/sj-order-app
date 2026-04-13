# 📦 PANDUAN LENGKAP MIGRASI: Local Data → Server Publik

**Tanggal:** 2026-04-13  
**Status:** ✅ Siap Implementasi  
**Durasi:** 30-45 menit setup + testing  
**Target:** Perpindahan sempurna dari local storage ke server publik

---

## 📚 DAFTAR ISI

1. [Ringkasan Migrasi](#ringkasan-migrasi)
2. [Persiapan Backend](#persiapan-backend)
3. [Konfigurasi Frontend](#konfigurasi-frontend)
4. [Implementasi API Service](#implementasi-api-service)
5. [Testing & Verification](#testing--verification)
6. [Troubleshooting](#troubleshooting)
7. [Checklist Akhir](#checklist-akhir)

---

## 🎯 RINGKASAN MIGRASI

### Situasi Saat Ini (LOCAL)

```
┌─────────────────────────────────┐
│   FLUTTER APP (Mobile)          │
├─────────────────────────────────┤
│                                 │
│  SharedPreferences (Local)      │
│  ├─ auth_token                  │
│  ├─ user_data                   │
│  ├─ bookings                    │
│  └─ cached data                 │
│                                 │
│  SQLite (Local Database)        │
│  ├─ users table                 │
│  ├─ bookings table              │
│  └─ local data lainnya          │
│                                 │
└─────────────────────────────────┘
         ❌ OFFLINE MODE
```

**Karakteristik:**
- Data hanya tersimpan di device lokal
- Tidak bisa sharing antar pengguna
- Tidak ada real-time sync
- Risk data loss jika device rusak
- Tidak scalable untuk multi-user

---

### Target Akhir (SERVER PUBLIK)

```
┌─────────────────────────────────┐
│   FLUTTER APP (Mobile)          │
├─────────────────────────────────┤
│                                 │
│  SharedPreferences (Cache Only) │
│  ├─ auth_token                  │
│  ├─ user_data (from server)     │
│  └─ bookings (from server)      │
│                                 │
└──────────────┬──────────────────┘
               │ HTTPS/HTTP
               │ API Calls
               ▼
┌──────────────────────────────────────────┐
│   LARAVEL BACKEND (Public Server)        │
├──────────────────────────────────────────┤
│                                          │
│  MySQL Database (Centralized):           │
│  ├─ users table                          │
│  ├─ bookings table                       │
│  ├─ rooms table                          │
│  ├─ vehicles table                       │
│  ├─ divisions table                      │
│  ├─ booking_approvals table              │
│  ├─ personal_access_tokens               │
│  └─ audit_logs table                     │
│                                          │
└──────────────────────────────────────────┘
         ✅ ONLINE MODE
```

**Keuntungan:**
- ✅ Data terpusat di server
- ✅ Multi-user real-time sharing
- ✅ Automatic backup & security
- ✅ Scalable & reliable
- ✅ Approval workflow terintegrasi
- ✅ Audit trail lengkap

---

### Tabel Perbandingan

| Aspek | Local Storage | Server Publik |
|-------|---------------|---------------|
| **Lokasi Data** | Device lokal | Server remote |
| **Multi-user** | ❌ No | ✅ Yes |
| **Real-time** | ❌ No | ✅ Yes |
| **Backup** | Manual | Automatic |
| **Security** | Rendah | Tinggi (HTTPS) |
| **Scalability** | Terbatas | Unlimited |
| **Approval** | Manual | Automated |
| **Mobile** | ✅ Works offline | ⚠️ Butuh internet |

---

## 🔧 PERSIAPAN BACKEND (Server Publik)

### Step 1.1: Deploy Laravel Backend ke Server Publik

**Pilihan Hosting:**
- **Cloud:** AWS, Google Cloud, Azure, DigitalOcean, Heroku
- **VPS:** Linode, Contabo, Vultr
- **Shared Hosting:** Hostinger, Niagahoster (kurang recommended)

**Contoh Deploy di DigitalOcean:**

```bash
# 1. Create droplet (Ubuntu 22.04)
# 2. SSH ke server
ssh root@YOUR_SERVER_IP

# 3. Install dependencies
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 php php-curl php-json php-mysql mysql-server

# 4. Install Composer
curl -fsSL https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# 5. Clone repository
cd /var/www
git clone https://github.com/your-repo/laravel-backend.git
cd laravel-backend

# 6. Setup Laravel
composer install
cp .env.example .env
php artisan key:generate

# 7. Setup Database
mysql -u root -p
CREATE DATABASE sj_order_app;
CREATE USER 'sjapp'@'localhost' IDENTIFIED BY 'strong_password';
GRANT ALL PRIVILEGES ON sj_order_app.* TO 'sjapp'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 8. Update .env dengan database credentials
nano .env
# DB_CONNECTION=mysql
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_DATABASE=sj_order_app
# DB_USERNAME=sjapp
# DB_PASSWORD=strong_password

# 9. Run migrations
php artisan migrate

# 10. Setup web server
sudo chown -R www-data:www-data /var/www/laravel-backend
sudo chmod -R 755 /var/www/laravel-backend/storage
sudo chmod -R 755 /var/www/laravel-backend/bootstrap/cache

# 11. Configure Apache virtual host
sudo nano /etc/apache2/sites-available/laravel.conf
```

**Apache Virtual Host Config:**
```apache
<VirtualHost *:80>
    ServerName your-domain.com
    ServerAdmin admin@your-domain.com
    DocumentRoot /var/www/laravel-backend/public

    <Directory /var/www/laravel-backend>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined

    # Enable rewrite module
    <IfModule mod_rewrite.c>
        RewriteEngine On
        RewriteCond %{REQUEST_FILENAME} !-f
        RewriteCond %{REQUEST_FILENAME} !-d
        RewriteRule ^(.*)$ /index.php/$1 [L]
    </IfModule>
</VirtualHost>
```

**Aktifkan:**
```bash
sudo a2enmod rewrite
sudo a2ensite laravel.conf
sudo systemctl restart apache2
```

### Step 1.2: Setup SSL/HTTPS (PENTING!)

```bash
# Install Certbot
sudo apt install certbot python3-certbot-apache -y

# Generate certificate
sudo certbot certonly --apache -d your-domain.com

# Auto-renew
sudo systemctl enable certbot.timer
```

### Step 1.3: Verifikasi Backend Berjalan

**Test Endpoint:**
```bash
# Cek health endpoint
curl -X GET https://your-domain.com/api/health
# Expected: 200 OK

# Test login
curl -X POST https://your-domain.com/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password"
  }'

# Expected response:
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

### Step 1.4: Setup Environment Variables Backend

**File:** `.env` di server

```env
APP_NAME="SJ Order App"
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY
APP_DEBUG=false
APP_URL=https://your-domain.com

LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sj_order_app
DB_USERNAME=sjapp
DB_PASSWORD=strong_password

CACHE_DRIVER=file
QUEUE_CONNECTION=sync

MAIL_DRIVER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=465
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_FROM_ADDRESS=noreply@your-domain.com

SANCTUM_STATEFUL_DOMAINS=your-domain.com
SESSION_DOMAIN=.your-domain.com
CORS_ALLOWED_ORIGINS=your-domain.com
```

---

## 🎨 KONFIGURASI FRONTEND (Flutter App)

### Step 2.1: Update API Base URL

**File:** `lib/utils/constants.dart`

```dart
class AppConstants {
  // 🔄 UPDATE INI DENGAN SERVER PUBLIK ANDA
  static const String apiBaseUrl = 'https://your-domain.com/api';
  
  // Contoh (jangan gunakan):
  // static const String apiBaseUrl = 'https://api.example.com/api';
  // static const String apiBaseUrl = 'https://192.168.1.100:8000/api';

  static const int apiTimeout = 30; // seconds
  static const String appName = 'SJ Order App';
  static const String appVersion = '1.0.0';

  // Storage Keys
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyBookings = 'bookings_cache';
}
```

### Step 2.2: Verifikasi Dependencies

**File:** `pubspec.yaml`

```yaml
dependencies:
  flutter:
    sdk: flutter

  # HTTP untuk API calls
  http: ^1.1.0

  # Local storage untuk token & cache
  shared_preferences: ^2.2.0

  # State management
  provider: ^6.0.0

  # JSON serialization
  # (sudah built-in)

dev_dependencies:
  flutter_test:
    sdk: flutter

flutter:
  uses-material-design: true
```

**Run:**
```bash
flutter pub get
```

---

## 🔌 IMPLEMENTASI API SERVICE

### Step 3.1: Create/Update API Service

**File:** `lib/services/api_service.dart`

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'auth_service.dart';

class ApiService {
  // 🔄 UPDATE INI DENGAN DOMAIN ANDA
  static const String baseUrl = 'https://your-domain.com/api';
  static const Duration timeout = Duration(seconds: 30);

  // ============================================
  // 🔐 AUTHENTICATION ENDPOINTS
  // ============================================

  /// Login dengan email & password
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('🔄 [ApiService.login] Attempting login to $baseUrl/login');

      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(timeout);

      print('📨 Response Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          // Simpan token dari server
          final token = data['token'];
          await AuthService.saveToken(token);

          // Simpan user data
          final userData = data['data'];
          await AuthService.saveUserData(jsonEncode(userData));

          print('✅ [ApiService.login] Login successful');
          return {
            'success': true,
            'message': 'Login successful',
            'token': token,
            'user': userData,
          };
        }
      }

      print('❌ [ApiService.login] Status: ${response.statusCode}');
      return {
        'success': false,
        'message': 'Login failed: ${response.statusCode}',
        'statusCode': response.statusCode,
      };
    } on TimeoutException catch (e) {
      print('⏱️ [ApiService.login] Timeout: $e');
      return {
        'success': false,
        'message': 'Server timeout. Check internet connection.',
      };
    } on http.ClientException catch (e) {
      print('❌ [ApiService.login] Client error: $e');
      return {
        'success': false,
        'message': 'Connection error: $e',
      };
    } catch (e) {
      print('❌ [ApiService.login] Unexpected error: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  /// Logout
  static Future<Map<String, dynamic>> logout() async {
    try {
      print('🔄 [ApiService.logout] Attempting logout...');

      final token = await AuthService.getToken();
      if (token == null) {
        // Token tidak ada, langsung clear
        await AuthService.clearAuthData();
        return {'success': true, 'message': 'Logged out'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/logout'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      // Clear local data regardless of response
      await AuthService.clearAuthData();

      print('✅ [ApiService.logout] Logged out');
      return {'success': true, 'message': 'Logged out successfully'};
    } catch (e) {
      print('❌ [ApiService.logout] Error: $e');
      // Still clear local data
      await AuthService.clearAuthData();
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ============================================
  // 👤 USER ENDPOINTS
  // ============================================

  /// Get current user data
  static Future<Map<String, dynamic>> getCurrentUser() async {
    try {
      print('🔄 [ApiService.getCurrentUser] Fetching user data...');

      final token = await AuthService.getToken();
      if (token == null) {
        return {
          'success': false,
          'message': 'No token. Please login first.',
        };
      }

      final response = await http.get(
        Uri.parse('$baseUrl/user'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      print('📨 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print('✅ [ApiService.getCurrentUser] User data fetched');
          return {
            'success': true,
            'user': data['data'],
          };
        }
      }

      if (response.statusCode == 401) {
        // Token expired
        await AuthService.clearAuthData();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      return {
        'success': false,
        'message': 'Failed to fetch user',
      };
    } catch (e) {
      print('❌ [ApiService.getCurrentUser] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get all users (admin only)
  static Future<Map<String, dynamic>> getAllUsers() async {
    try {
      print('🔄 [ApiService.getAllUsers] Fetching all users...');

      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'users': data['data'] ?? [],
        };
      }

      return {'success': false, 'message': 'Failed to fetch users'};
    } catch (e) {
      print('❌ [ApiService.getAllUsers] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ============================================
  // 📅 BOOKING ENDPOINTS
  // ============================================

  /// Get all bookings
  static Future<Map<String, dynamic>> getBookings() async {
    try {
      print('🔄 [ApiService.getBookings] Fetching bookings...');

      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      print('📨 Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print(
              '✅ [ApiService.getBookings] Bookings fetched: ${(data["data"] as List?)?.length ?? 0}');
          return {
            'success': true,
            'bookings': data['data'] ?? [],
          };
        }
      }

      return {'success': false, 'message': 'Failed to fetch bookings'};
    } catch (e) {
      print('❌ [ApiService.getBookings] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Create new booking
  static Future<Map<String, dynamic>> createBooking({
    required String bookingType,
    required int resourceId,
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String purpose,
    int? participantsCount,
  }) async {
    try {
      print('🔄 [ApiService.createBooking] Creating booking...');

      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token'};
      }

      final response = await http.post(
        Uri.parse('$baseUrl/bookings'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'booking_type': bookingType,
          'resource_id': resourceId,
          'booking_date': bookingDate,
          'start_time': startTime,
          'end_time': endTime,
          'purpose': purpose,
          'participants_count': participantsCount ?? 1,
        }),
      ).timeout(timeout);

      print('📨 Response: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          print('✅ [ApiService.createBooking] Booking created');
          return {
            'success': true,
            'booking': data['data'],
            'message': data['message'],
          };
        }
      }

      return {
        'success': false,
        'message': 'Failed to create booking',
      };
    } catch (e) {
      print('❌ [ApiService.createBooking] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Update booking
  static Future<Map<String, dynamic>> updateBooking(
    int id, {
    required String bookingDate,
    required String startTime,
    required String endTime,
    required String purpose,
  }) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token'};
      }

      final response = await http.put(
        Uri.parse('$baseUrl/bookings/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'booking_date': bookingDate,
          'start_time': startTime,
          'end_time': endTime,
          'purpose': purpose,
        }),
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'booking': data['data'],
        };
      }

      return {'success': false, 'message': 'Failed to update booking'};
    } catch (e) {
      print('❌ [ApiService.updateBooking] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Cancel booking
  static Future<Map<String, dynamic>> cancelBooking(int id) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'success': false, 'message': 'No token'};
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/bookings/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'message': data['message'],
        };
      }

      return {'success': false, 'message': 'Failed to cancel booking'};
    } catch (e) {
      print('❌ [ApiService.cancelBooking] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // ============================================
  // 🏢 RESOURCE ENDPOINTS
  // ============================================

  /// Get all rooms
  static Future<Map<String, dynamic>> getRooms() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/rooms'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'rooms': data['data'] ?? [],
        };
      }

      return {'success': false, 'message': 'Failed to fetch rooms'};
    } catch (e) {
      print('❌ [ApiService.getRooms] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  /// Get all vehicles
  static Future<Map<String, dynamic>> getVehicles() async {
    try {
      final token = await AuthService.getToken();

      final response = await http.get(
        Uri.parse('$baseUrl/vehicles'),
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ).timeout(timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': data['success'] == true,
          'vehicles': data['data'] ?? [],
        };
      }

      return {'success': false, 'message': 'Failed to fetch vehicles'};
    } catch (e) {
      print('❌ [ApiService.getVehicles] Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
```

### Step 3.2: Create/Update Auth Service

**File:** `lib/services/auth_service.dart`

```dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _isLoggedInKey = 'is_logged_in';

  // ============================================
  // 💾 TOKEN MANAGEMENT
  // ============================================

  /// Simpan token dari server
  static Future<void> saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setBool(_isLoggedInKey, true);
      print('✅ [AuthService] Token saved');
    } catch (e) {
      print('❌ [AuthService] Error saving token: $e');
      rethrow;
    }
  }

  /// Ambil token untuk API requests
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('❌ [AuthService] Error getting token: $e');
      return null;
    }
  }

  // ============================================
  // 👤 USER DATA MANAGEMENT
  // ============================================

  /// Simpan user data
  static Future<void> saveUserData(String userData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, userData);
      print('✅ [AuthService] User data saved');
    } catch (e) {
      print('❌ [AuthService] Error saving user data: $e');
      rethrow;
    }
  }

  /// Ambil user data
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);

      if (userData != null) {
        return jsonDecode(userData);
      }
      return null;
    } catch (e) {
      print('❌ [AuthService] Error getting user data: $e');
      return null;
    }
  }

  // ============================================
  // 🔐 LOGIN/LOGOUT
  // ============================================

  /// Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      print('❌ [AuthService] Error checking login status: $e');
      return false;
    }
  }

  /// Clear semua auth data
  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_isLoggedInKey);
      print('✅ [AuthService] Auth data cleared');
    } catch (e) {
      print('❌ [AuthService] Error clearing auth data: $e');
      rethrow;
    }
  }
}
```

### Step 3.3: Create Sync Service

**File:** `lib/services/sync_service.dart`

```dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import 'auth_service.dart';

class SyncService {
  /// Sinkronisasi data lokal dengan server
  static Future<bool> syncData() async {
    try {
      print('🔄 [SyncService] Starting data sync...');

      final token = await AuthService.getToken();
      if (token == null) {
        print('❌ [SyncService] No token, cannot sync');
        return false;
      }

      // Sync user data
      print('📥 [SyncService] Syncing user data...');
      final userResult = await ApiService.getCurrentUser();
      if (userResult['success']) {
        final userData = userResult['user'];
        await AuthService.saveUserData(jsonEncode(userData));
        print('✅ [SyncService] User data synced');
      }

      // Sync bookings
      print('📥 [SyncService] Syncing bookings...');
      final bookingsResult = await ApiService.getBookings();
      if (bookingsResult['success']) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(
          'bookings_cache',
          jsonEncode(bookingsResult['bookings']),
        );
        print('✅ [SyncService] Bookings synced');
      }

      print('✅ [SyncService] Data sync completed');
      return true;
    } catch (e) {
      print('❌ [SyncService] Sync failed: $e');
      return false;
    }
  }

  /// Force refresh dari server
  static Future<void> forceRefresh() async {
    final token = await AuthService.getToken();
    if (token != null) {
      await syncData();
    }
  }
}
```

---

## 🧪 TESTING & VERIFICATION

### Test 1: Backend Connectivity

**Test dengan cURL:**
```bash
# Test health endpoint
curl -X GET https://your-domain.com/api/health

# Expected: 200 OK
```

### Test 2: Login Test

**Test login endpoint:**
```bash
curl -X POST https://your-domain.com/api/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@example.com",
    "password": "password"
  }'

# Expected response:
{
  "success": true,
  "message": "Login successful",
  "token": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "data": {
    "id": 1,
    "name": "Admin",
    "email": "admin@example.com"
  }
}
```

### Test 3: Flutter App Login

**Langkah:**
1. Update `baseUrl` di `api_service.dart` dengan domain server publik
2. Run app: `flutter run`
3. Input: `admin@example.com` / `password`
4. Expected: Navigate to dashboard tanpa timeout

### Test 4: Create Booking via API

**Test:**
```bash
ADMIN_TOKEN="your_token_from_login"

curl -X POST https://your-domain.com/api/bookings \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "booking_type": "room",
    "resource_id": 1,
    "booking_date": "2026-04-20",
    "start_time": "09:00",
    "end_time": "11:00",
    "purpose": "Meeting",
    "participants_count": 5
  }'
```

### Test 5: Database Verification

**Check data di server:**
```bash
# SSH ke server
ssh user@your-domain.com

# Login MySQL
mysql -u sjapp -p sj_order_app

# Check users
SELECT * FROM users;

# Check bookings
SELECT * FROM bookings;

# Check count
SELECT COUNT(*) as total_users FROM users;
SELECT COUNT(*) as total_bookings FROM bookings;
```

---

## ⚠️ TROUBLESHOOTING

### Problem 1: TimeoutException

**Error:**
```
TimeoutException after 0:00:30.000000: Future not completed
```

**Penyebab & Solusi:**
```dart
// 1. Check baseUrl dengan benar
static const String baseUrl = 'https://your-domain.com/api'; // Harus HTTPS

// 2. Verifikasi server running
// Di server: curl https://your-domain.com/api/health

// 3. Increase timeout jika network lambat
static const Duration timeout = Duration(seconds: 60);

// 4. Check firewall
// Pastikan port 443 (HTTPS) terbuka di server
```

### Problem 2: 401 Unauthorized

**Error:** Token invalid atau expired

**Solusi:**
```dart
// Logout dan login ulang
if (response.statusCode == 401) {
  await AuthService.clearAuthData();
  // Redirect ke login screen
  Navigator.pushReplacementNamed(context, '/login');
}
```

### Problem 3: Connection Refused

**Error:** Cannot connect ke server

**Solusi:**
```bash
# 1. Check server status
ssh user@your-domain.com
systemctl status apache2  # or nginx

# 2. Check Laravel running
cd /var/www/laravel-backend
php artisan serve  # untuk testing

# 3. Check logs
tail -f /var/log/apache2/error.log
tail -f /var/www/laravel-backend/storage/logs/laravel.log
```

### Problem 4: CORS Error

**Error:** Blocked by CORS policy

**Solusi (Backend):**
```php
// File: config/cors.php
return [
    'paths' => ['api/*'],
    'allowed_methods' => ['*'],
    'allowed_origins' => ['*'],
    'allowed_headers' => ['*'],
];
```

**Atau run migration:**
```bash
php artisan config:cache
php artisan config:clear
```

### Problem 5: Database Connection Error

**Error:** Cannot connect to database

**Solusi:**
```bash
# Check MySQL running
sudo systemctl status mysql

# Check credentials di .env
cat /var/www/laravel-backend/.env | grep DB_

# Test connection
php artisan tinker
>>> DB::connection()->getPdo();
```

---

## ✅ CHECKLIST IMPLEMENTASI

### Persiapan Backend
- [ ] Server publik sudah setup (AWS/DigitalOcean/VPS)
- [ ] Laravel backend sudah di-deploy
- [ ] Database sudah migrated
- [ ] SSL/HTTPS sudah aktif
- [ ] Test user sudah dibuat
- [ ] API endpoints sudah tested dengan Postman
- [ ] Environment variables sudah configured

### Konfigurasi Frontend
- [ ] `baseUrl` sudah update ke server publik
- [ ] Dependencies (`http`, `shared_preferences`) sudah installed
- [ ] `pubspec.yaml` sudah updated
- [ ] API Service sudah implemented
- [ ] Auth Service sudah implemented
- [ ] Sync Service sudah implemented

### Testing
- [ ] Backend connectivity tested (curl)
- [ ] Login API tested (Postman)
- [ ] App login tested (Flutter)
- [ ] Booking creation tested
- [ ] User data sync tested
- [ ] No timeout errors
- [ ] Database data verified

### Production
- [ ] HTTPS enabled
- [ ] Database backups configured
- [ ] Logging enabled
- [ ] Error monitoring setup (Sentry/Firebase)
- [ ] Performance optimized
- [ ] Security hardened

---

## 🎉 SELESAI!

Aplikasi Anda sekarang sudah **100% migrate dari Local Storage ke Server Publik!**

### Fitur yang Sekarang Tersedia:
✅ Multi-user access  
✅ Real-time data sync  
✅ Centralized database  
✅ Automatic backup  
✅ Approval workflow  
✅ Audit trail  
✅ Scalable & reliable  

### Next Steps:
1. Monitor server performance
2. Setup automated backups
3. Configure email notifications
4. Setup monitoring & alerts
5. Regular security updates
6. User training

---

## 📞 QUICK REFERENCE

| Task | Command |
|------|---------|
| Check server status | `curl https://your-domain.com/api/health` |
| Login | `POST https://your-domain.com/api/login` |
| Get user | `GET https://your-domain.com/api/user` |
| Create booking | `POST https://your-domain.com/api/bookings` |
| View logs | `tail -f storage/logs/laravel.log` |
| Database backup | `mysqldump -u sjapp -p sj_order_app > backup.sql` |
| Restart server | `sudo systemctl restart apache2` |

---

## 📚 Dokumentasi Tambahan

- [Laravel Documentation](https://laravel.com/docs)
- [Flutter HTTP Package](https://pub.dev/packages/http)
- [MySQL Documentation](https://dev.mysql.com/doc/)
- [DigitalOcean Guides](https://www.digitalocean.com/docs/)

---

**Dibuat:** 2026-04-13  
**Last Updated:** 2026-04-13  
**Versi:** 1.0  
**Status:** ✅ Production Ready

Selamat! Aplikasi Anda sudah siap untuk production dengan server publik! 🚀

