# ⚙️ KONFIGURASI LENGKAP - Migrasi Local ke Server Publik

**Status:** ✅ Production Ready  
**Tanggal:** 2026-04-13  
**Versi:** 1.0

---

## 📋 DAFTAR ISI

1. [Backend Configuration](#backend-configuration)
2. [Frontend Configuration](#frontend-configuration)
3. [Database Configuration](#database-configuration)
4. [API Configuration](#api-configuration)
5. [Security Configuration](#security-configuration)
6. [Environment Variables](#environment-variables)
7. [Quick Setup Checklist](#quick-setup-checklist)

---

## 🔧 BACKEND CONFIGURATION

### 1. Laravel Environment File (.env)

**Lokasi File:** `/var/www/laravel-backend/.env`

```env
# ============================================
# APPLICATION
# ============================================
APP_NAME="SJ Order App"
APP_ENV=production
APP_KEY=base64:YOUR_APP_KEY_HERE
APP_DEBUG=false
APP_URL=https://your-domain.com

# ============================================
# LOGGING
# ============================================
LOG_CHANNEL=stack
LOG_DEPRECATIONS_CHANNEL=null
LOG_LEVEL=debug

# ============================================
# DATABASE - MySQL
# ============================================
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sj_order_app
DB_USERNAME=sjapp
DB_PASSWORD=strong_password_here
DB_CHARSET=utf8mb4
DB_COLLATION=utf8mb4_unicode_ci

# ============================================
# CACHE & SESSION
# ============================================
CACHE_DRIVER=file
CACHE_PREFIX=
SESSION_DRIVER=file
SESSION_LIFETIME=120
SESSION_ENCRYPT=false
SESSION_PATH=/
SESSION_DOMAIN=.your-domain.com

# ============================================
# QUEUE & JOBS
# ============================================
QUEUE_CONNECTION=sync

# ============================================
# MAIL CONFIGURATION
# ============================================
MAIL_DRIVER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=your_email@gmail.com
MAIL_PASSWORD=your_app_password
MAIL_ENCRYPTION=tls
MAIL_FROM_NAME="SJ Order App"
MAIL_FROM_ADDRESS=noreply@your-domain.com

# ============================================
# BROADCAST
# ============================================
BROADCAST_DRIVER=log

# ============================================
# SANCTUM - API Token Auth
# ============================================
SANCTUM_EXPIRATION=10080
SANCTUM_STATEFUL_DOMAINS=your-domain.com,localhost,127.0.0.1,::1
SANCTUM_GUARD=api

# ============================================
# CORS - Cross Origin
# ============================================
CORS_ALLOWED_ORIGINS=https://your-domain.com,http://localhost:3000
CORS_ALLOWED_METHODS=GET,POST,PUT,DELETE,OPTIONS
CORS_ALLOWED_HEADERS=*
CORS_EXPOSE_HEADERS=*
CORS_CREDENTIALS=true
CORS_MAX_AGE=86400

# ============================================
# AWS (Jika menggunakan cloud storage)
# ============================================
AWS_ACCESS_KEY_ID=
AWS_SECRET_ACCESS_KEY=
AWS_DEFAULT_REGION=us-east-1
AWS_BUCKET=
AWS_USE_PATH_STYLE_ENDPOINTS=false

# ============================================
# PUSHER (Real-time notifications - optional)
# ============================================
PUSHER_APP_ID=
PUSHER_APP_KEY=
PUSHER_APP_SECRET=
PUSHER_HOST=
PUSHER_PORT=443
PUSHER_SCHEME=https
PUSHER_APP_CLUSTER=mt1
```

---

### 2. Laravel Configuration Files

#### File: `config/app.php` (Extract penting)

```php
<?php

return [
    'name' => env('APP_NAME', 'SJ Order App'),
    'env' => env('APP_ENV', 'production'),
    'debug' => env('APP_DEBUG', false),
    'url' => env('APP_URL', 'https://your-domain.com'),
    'asset_url' => env('ASSET_URL'),

    'timezone' => 'Asia/Jakarta',
    'locale' => 'id',
    'fallback_locale' => 'en',
    'faker_locale' => 'id_ID',

    'key' => env('APP_KEY'),
    'cipher' => 'AES-256-CBC',

    'providers' => [
        // ...existing code...
        Laravel\Sanctum\SanctumServiceProvider::class,
    ],

    'aliases' => [
        // ...existing code...
    ],
];
```

#### File: `config/database.php` (Extract penting)

```php
<?php

return [
    'default' => env('DB_CONNECTION', 'mysql'),

    'connections' => [
        'mysql' => [
            'driver' => 'mysql',
            'host' => env('DB_HOST', '127.0.0.1'),
            'port' => env('DB_PORT', 3306),
            'database' => env('DB_DATABASE', 'sj_order_app'),
            'username' => env('DB_USERNAME', 'root'),
            'password' => env('DB_PASSWORD', ''),
            'charset' => 'utf8mb4',
            'collation' => 'utf8mb4_unicode_ci',
            'prefix' => '',
            'prefix_indexes' => true,
            'strict' => true,
            'engine' => 'InnoDB',
            'options' => extension_loaded('pdo_mysql') ? array_filter([
                PDO::MYSQL_ATTR_SSL_CA => env('MYSQL_ATTR_SSL_CA'),
            ]) : [],
        ],
    ],

    'migrations' => 'migrations',
];
```

#### File: `config/cors.php` (Extract penting)

```php
<?php

return [
    'paths' => ['api/*', 'sanctum/csrf-cookie'],
    
    'allowed_methods' => ['*'],
    
    'allowed_origins' => [
        'https://your-domain.com',
        'http://localhost:3000',
    ],
    
    'allowed_origins_patterns' => [],
    
    'allowed_headers' => ['*'],
    
    'exposed_headers' => [],
    
    'max_age' => 0,
    
    'supports_credentials' => true,
];
```

#### File: `config/sanctum.php` (Extract penting)

```php
<?php

return [
    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', 'localhost,127.0.0.1,127.0.0.1:8000,::1')),
    
    'guard' => ['web'],
    
    'expiration' => env('SANCTUM_EXPIRATION'),
    
    'token_prefix' => env('SANCTUM_TOKEN_PREFIX', ''),
    
    'middleware' => [
        'verify_csrf_token' => App\Http\Middleware\VerifyCsrfToken::class,
        'encrypt_cookies' => App\Http\Middleware\EncryptCookies::class,
    ],
];
```

---

### 3. Apache Virtual Host Configuration

**Lokasi File:** `/etc/apache2/sites-available/laravel.conf`

```apache
# HTTP Redirect ke HTTPS
<VirtualHost *:80>
    ServerName your-domain.com
    ServerAlias www.your-domain.com
    ServerAdmin admin@your-domain.com

    # Redirect ke HTTPS
    RewriteEngine On
    RewriteCond %{HTTPS} off
    RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
</VirtualHost>

# HTTPS Configuration
<VirtualHost *:443>
    ServerName your-domain.com
    ServerAlias www.your-domain.com
    ServerAdmin admin@your-domain.com

    DocumentRoot /var/www/laravel-backend/public

    # SSL Certificate (dari Certbot)
    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/your-domain.com/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/your-domain.com/privkey.pem
    SSLCertificateChainFile /etc/letsencrypt/live/your-domain.com/chain.pem

    # Security Headers
    Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
    Header always set X-Content-Type-Options "nosniff"
    Header always set X-Frame-Options "SAMEORIGIN"
    Header always set X-XSS-Protection "1; mode=block"
    Header always set Referrer-Policy "no-referrer-when-downgrade"

    # Directory Configuration
    <Directory /var/www/laravel-backend>
        AllowOverride All
        Require all granted

        # Enable mod_rewrite
        <IfModule mod_rewrite.c>
            RewriteEngine On
            RewriteCond %{REQUEST_FILENAME} !-f
            RewriteCond %{REQUEST_FILENAME} !-d
            RewriteRule ^(.*)$ /index.php/$1 [L]
        </IfModule>
    </Directory>

    # Disable access to .env dan hidden files
    <FilesMatch "^\.">
        Require all denied
    </FilesMatch>

    <Files ".env">
        Require all denied
    </Files>

    # Log Configuration
    ErrorLog ${APACHE_LOG_DIR}/laravel-error.log
    CustomLog ${APACHE_LOG_DIR}/laravel-access.log combined

    # Compression
    <IfModule mod_deflate.c>
        AddOutputFilterByType DEFLATE text/html text/plain text/xml text/css text/javascript application/javascript application/json
    </IfModule>

    # Cache Control
    <IfModule mod_expires.c>
        ExpiresActive On
        ExpiresDefault "access plus 2 days"
        ExpiresByType text/html "access plus 2 hours"
        ExpiresByType image/jpeg "access plus 30 days"
        ExpiresByType image/gif "access plus 30 days"
        ExpiresByType image/png "access plus 30 days"
    </IfModule>
</VirtualHost>
```

**Setup:**
```bash
sudo a2enmod ssl
sudo a2enmod rewrite
sudo a2enmod headers
sudo a2enmod expires
sudo a2enmod deflate
sudo a2ensite laravel.conf
sudo a2dissite 000-default.conf
sudo apache2ctl configtest  # Should return "Syntax OK"
sudo systemctl restart apache2
```

---

### 4. Nginx Configuration (Alternative)

**Lokasi File:** `/etc/nginx/sites-available/laravel`

```nginx
# HTTP Redirect ke HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name your-domain.com www.your-domain.com;
    return 301 https://$server_name$request_uri;
}

# HTTPS Configuration
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name your-domain.com www.your-domain.com;

    root /var/www/laravel-backend/public;
    index index.php index.html;

    # SSL Certificates
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;

    # SSL Configuration
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;

    # Deny access to .env and hidden files
    location ~ /\. {
        deny all;
    }

    location ~ /\.env {
        deny all;
    }

    # Laravel routing
    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    # PHP Configuration
    location ~ \.php$ {
        fastcgi_pass unix:/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    # Compression
    gzip on;
    gzip_types text/html text/plain text/xml text/css text/javascript application/javascript application/json;
    gzip_min_length 1000;

    # Logging
    access_log /var/log/nginx/laravel-access.log;
    error_log /var/log/nginx/laravel-error.log;
}
```

**Setup:**
```bash
sudo ln -s /etc/nginx/sites-available/laravel /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t  # Should return "test is successful"
sudo systemctl restart nginx
```

---

## 🎨 FRONTEND CONFIGURATION

### 1. Flutter Constants File

**Lokasi File:** `lib/utils/constants.dart`

```dart
class AppConstants {
  // ============================================
  // 🌐 API CONFIGURATION
  // ============================================
  
  /// Base URL untuk API calls
  /// HARUS diupdate sesuai domain server publik Anda
  static const String apiBaseUrl = 'https://your-domain.com/api';
  
  // Contoh untuk development (jangan gunakan di production):
  // static const String apiBaseUrl = 'http://10.0.2.2:8000/api'; // Android Emulator
  // static const String apiBaseUrl = 'http://192.168.1.100:8000/api'; // Physical Device
  
  /// API Request Timeout (dalam detik)
  static const int apiTimeout = 30;
  
  /// API Retry Configuration
  static const int apiMaxRetries = 3;
  static const int apiRetryDelay = 2; // seconds

  // ============================================
  // 📱 APP INFORMATION
  // ============================================
  
  static const String appName = 'SJ Order App';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';

  // ============================================
  // 💾 LOCAL STORAGE KEYS
  // ============================================
  
  static const String storageKeyToken = 'auth_token';
  static const String storageKeyUser = 'user_data';
  static const String storageKeyUserRole = 'user_role';
  static const String storageKeyBookings = 'bookings_cache';
  static const String storageKeyRooms = 'rooms_cache';
  static const String storageKeyVehicles = 'vehicles_cache';
  static const String storageKeyLastSync = 'last_sync_time';
  static const String storageKeyIsLoggedIn = 'is_logged_in';

  // ============================================
  // 🔐 SECURITY
  // ============================================
  
  /// SSL/TLS Certificate Pinning (optional)
  static const bool enableCertificatePinning = false;
  
  /// Enable encrypted storage (optional)
  static const bool enableEncryptedStorage = true;

  // ============================================
  // 📊 APP CONFIGURATION
  // ============================================
  
  /// Sync interval (dalam menit)
  static const int autoSyncInterval = 5;
  
  /// Cache duration (dalam jam)
  static const int cacheDuration = 24;
  
  /// Maximum items per page untuk pagination
  static const int itemsPerPage = 20;

  // ============================================
  // 🎯 FEATURE FLAGS
  // ============================================
  
  static const bool enableOfflineMode = true;
  static const bool enableNotifications = true;
  static const bool enableDebugLogging = false;
  static const bool enableAnalytics = true;
}
```

### 2. Pubspec.yaml Configuration

**Lokasi File:** `pubspec.yaml`

```yaml
name: sj_order_app
description: SJ Order App - Room & Vehicle Booking System

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: ">=2.18.0 <3.0.0"

dependencies:
  flutter:
    sdk: flutter

  # ============================================
  # HTTP & API
  # ============================================
  http: ^1.1.0
  dio: ^5.0.0  # Alternative ke http (optional)

  # ============================================
  # STATE MANAGEMENT
  # ============================================
  provider: ^6.0.0
  get: ^4.6.0  # Alternative state management (optional)

  # ============================================
  # LOCAL STORAGE
  # ============================================
  shared_preferences: ^2.2.0
  sqflite: ^2.3.0  # For local SQLite (optional)
  path_provider: ^2.1.0

  # ============================================
  # SECURITY
  # ============================================
  flutter_secure_storage: ^9.0.0  # For secure token storage
  encrypt: ^5.0.0  # For encryption (optional)

  # ============================================
  # UI & NAVIGATION
  # ============================================
  cupertino_icons: ^1.0.2
  intl: ^0.19.0
  intl_utils: ^2.8.0

  # ============================================
  # NOTIFICATIONS
  # ============================================
  firebase_core: ^2.24.0  # Firebase (optional)
  firebase_messaging: ^14.6.0  # Push notifications (optional)

  # ============================================
  # LOGGING & MONITORING
  # ============================================
  logger: ^2.0.0
  sentry_flutter: ^7.0.0  # Error monitoring (optional)

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^2.0.0
  test: ^1.24.0

flutter:
  uses-material-design: true

  # Assets
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/

  # Fonts
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
```

### 3. Flutter Android Configuration

**Lokasi File:** `android/app/build.gradle`

```gradle
defaultConfig {
    applicationId "com.sjorderapp.mobile"
    minSdkVersion flutter.minSdkVersion
    targetSdkVersion flutter.targetSdkVersion
    versionCode flutterVersionCode.toInteger()
    versionName flutterVersionName

    // Network Security Configuration
    manifestPlaceholders = [
        'usesCleartextTraffic': false  // Hanya HTTPS di production
    ]
}

buildTypes {
    debug {
        // Debug configuration
        debuggable true
    }
    
    release {
        // Release configuration
        debuggable false
        minifyEnabled true
        shrinkResources true
        
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

**Lokasi File:** `android/app/src/main/AndroidManifest.xml`

```xml
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.sjorderapp.mobile">

    <!-- Internet Permission -->
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

    <!-- Other Permissions -->
    <uses-permission android:name="android.permission.READ_CALENDAR" />
    <uses-permission android:name="android.permission.WRITE_CALENDAR" />

    <application
        android:label="SJ Order App"
        android:icon="@mipmap/ic_launcher"
        android:usesCleartextTraffic="false">
        
        <!-- Network Security Configuration -->
        <domain-config cleartextTrafficPermitted="false">
            <domain includeSubdomains="true">your-domain.com</domain>
        </domain-config>

        <!-- Activity -->
        <activity
            android:name=".MainActivity"
            android:exported="true"
            android:launchMode="singleTop"
            android:theme="@style/LaunchTheme"
            android:configChanges="orientation|keyboardHidden|keyboard|screenSize|smallestScreenSize|locale|layoutDirection|fontScale|screenLayout|density|uiMode"
            android:hardwareAccelerated="true"
            android:windowSoftInputMode="adjustResize">

            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
```

### 4. Flutter iOS Configuration

**Lokasi File:** `ios/Runner/Info.plist`

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <!-- App Info -->
    <key>CFBundleDevelopmentRegion</key>
    <string>id</string>
    <key>CFBundleDisplayName</key>
    <string>SJ Order App</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>sj_order_app</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleSignature</key>
    <string>????</string>
    <key>CFBundleVersion</key>
    <string>1</string>

    <!-- Network Configuration -->
    <key>NSBonjourServices</key>
    <array>
        <string>_http._tcp</string>
        <string>_https._tcp</string>
    </array>

    <!-- Security -->
    <key>NSAllowsArbitraryLoads</key>
    <false/>
    <key>NSAllowsArbitraryLoadsForMedia</key>
    <false/>
    <key>NSAllowsArbitraryLoadsInWebContent</key>
    <false/>

    <!-- Camera & Calendar (if needed) -->
    <key>NSCameraUsageDescription</key>
    <string>Camera is needed to capture photos</string>
    <key>NSCalendarsUsageDescription</key>
    <string>Calendar is needed to manage bookings</string>

    <!-- Other Configuration -->
    <key>UIMainStoryboardFile</key>
    <string>Main</string>
    <key>UISupportedInterfaceOrientations</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UISupportedInterfaceOrientations~ipad</key>
    <array>
        <string>UIInterfaceOrientationPortrait</string>
        <string>UIInterfaceOrientationPortraitUpsideDown</string>
        <string>UIInterfaceOrientationLandscapeLeft</string>
        <string>UIInterfaceOrientationLandscapeRight</string>
    </array>
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
</dict>
</plist>
```

---

## 🗄️ DATABASE CONFIGURATION

### 1. MySQL Database Setup

**Create Database:**
```sql
-- Create database
CREATE DATABASE sj_order_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create user
CREATE USER 'sjapp'@'localhost' IDENTIFIED BY 'strong_password_here';

-- Grant privileges
GRANT ALL PRIVILEGES ON sj_order_app.* TO 'sjapp'@'localhost';
FLUSH PRIVILEGES;

-- Verify
SHOW GRANTS FOR 'sjapp'@'localhost';
```

### 2. Laravel Migration Commands

```bash
# Run all migrations
php artisan migrate

# Specific migration
php artisan migrate --path=database/migrations/2024_01_01_create_users_table.php

# Rollback
php artisan migrate:rollback

# Reset (Warning: Deletes all data!)
php artisan migrate:reset

# Status
php artisan migrate:status

# Seed database (untuk test data)
php artisan db:seed

# Specific seeder
php artisan db:seed --class=UsersSeeder
```

### 3. Database Tables Structure

```sql
-- Users Table
CREATE TABLE users (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    role VARCHAR(50) DEFAULT 'user',
    division_id BIGINT UNSIGNED,
    phone VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    INDEX email_idx (email),
    INDEX role_idx (role)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Bookings Table
CREATE TABLE bookings (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    booking_code VARCHAR(50) UNIQUE NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    booking_type VARCHAR(50) NOT NULL, -- 'room' atau 'vehicle'
    resource_id BIGINT UNSIGNED NOT NULL,
    booking_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    purpose TEXT NOT NULL,
    participants_count INT DEFAULT 1,
    status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX booking_date_idx (booking_date),
    INDEX status_idx (status),
    INDEX user_id_idx (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Rooms Table
CREATE TABLE rooms (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    capacity INT,
    floor INT,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    INDEX name_idx (name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Vehicles Table
CREATE TABLE vehicles (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    license_plate VARCHAR(20) UNIQUE NOT NULL,
    vehicle_type VARCHAR(50),
    capacity INT,
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    INDEX license_plate_idx (license_plate),
    INDEX vehicle_type_idx (vehicle_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Personal Access Tokens (Sanctum)
CREATE TABLE personal_access_tokens (
    id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    tokenable_type VARCHAR(255) NOT NULL,
    tokenable_id BIGINT UNSIGNED NOT NULL,
    name VARCHAR(255) NOT NULL,
    token VARCHAR(80) UNIQUE NOT NULL,
    abilities LONGTEXT,
    last_used_at TIMESTAMP NULL,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    INDEX tokenable_type_tokenable_id_idx (tokenable_type, tokenable_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

## 🔌 API CONFIGURATION

### 1. API Base URLs

```dart
// Production
const String PROD_API_URL = 'https://your-domain.com/api';

// Staging
const String STAGING_API_URL = 'https://staging.your-domain.com/api';

// Development
const String DEV_API_URL = 'http://localhost:8000/api';

// Emulator
const String EMULATOR_API_URL = 'http://10.0.2.2:8000/api';
```

### 2. API Endpoints Documentation

```
# Authentication
POST   /api/login                 # Login
POST   /api/logout                # Logout
GET    /api/user                  # Get current user

# Users Management
GET    /api/users                 # List all users (admin)
GET    /api/users/{id}            # Get user by ID
POST   /api/users                 # Create user (admin)
PUT    /api/users/{id}            # Update user
DELETE /api/users/{id}            # Delete user (admin)

# Bookings
GET    /api/bookings              # List bookings
POST   /api/bookings              # Create booking
GET    /api/bookings/{id}         # Get booking detail
PUT    /api/bookings/{id}         # Update booking
DELETE /api/bookings/{id}         # Cancel booking

# Resources
GET    /api/rooms                 # List rooms
GET    /api/rooms/{id}            # Get room detail
GET    /api/vehicles              # List vehicles
GET    /api/vehicles/{id}         # Get vehicle detail

# Health Check
GET    /api/health                # API health status
GET    /api/version               # API version
```

### 3. Request/Response Headers

**Request Headers:**
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer {token}
User-Agent: SJ-Order-App/1.0.0
Accept-Language: id-ID
```

**Response Headers:**
```
Content-Type: application/json
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 59
X-RateLimit-Reset: 1620000000
Cache-Control: no-cache, private
```

---

## 🔐 SECURITY CONFIGURATION

### 1. API Security Headers

**Backend (Laravel):**
```php
// In middleware or .htaccess
Header always set X-Content-Type-Options "nosniff"
Header always set X-Frame-Options "SAMEORIGIN"
Header always set X-XSS-Protection "1; mode=block"
Header always set Referrer-Policy "no-referrer-when-downgrade"
Header always set Strict-Transport-Security "max-age=31536000; includeSubDomains"
Header always set Content-Security-Policy "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'"
```

### 2. Token Management

**Token Storage (Flutter):**
```dart
class TokenConfig {
  // Token expiration time
  static const Duration tokenExpiration = Duration(hours: 24);
  
  // Token refresh time (refresh sebelum expired)
  static const Duration tokenRefreshBefore = Duration(minutes: 5);
  
  // Max token attempts
  static const int maxTokenRefreshAttempts = 3;
  
  // Token storage type: 'shared_preferences' atau 'secure_storage'
  static const String tokenStorageType = 'secure_storage';
}
```

### 3. Password Policy

**Backend Validation (Laravel):**
```php
'password' => [
    'required',
    'string',
    Password::min(8)
        ->mixedCase()
        ->numbers()
        ->symbols()
        ->uncompromised(),
    'confirmed',
]
```

### 4. Rate Limiting

**Backend Configuration:**
```php
// In routes/api.php
Route::middleware('throttle:60,1')->group(function () {
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/bookings', [BookingController::class, 'store']);
});
```

### 5. HTTPS/SSL Configuration

**Requirements:**
- ✅ SSL Certificate (Let's Encrypt gratis)
- ✅ HTTPS enforced di production
- ✅ HTTP redirect ke HTTPS
- ✅ HSTS enabled
- ✅ Certificate pinning (optional)

---

## 📝 ENVIRONMENT VARIABLES

### 1. Backend Environment Variables

```env
# Core Configuration
APP_NAME="SJ Order App"
APP_ENV=production
APP_KEY=base64:YOUR_KEY_HERE
APP_DEBUG=false
APP_URL=https://your-domain.com

# Database
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=sj_order_app
DB_USERNAME=sjapp
DB_PASSWORD=YOUR_DB_PASSWORD

# API Configuration
SANCTUM_EXPIRATION=10080
API_PREFIX=/api
API_VERSION=1.0

# Mail
MAIL_DRIVER=smtp
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USERNAME=YOUR_EMAIL@gmail.com
MAIL_PASSWORD=YOUR_APP_PASSWORD

# Cache
CACHE_DRIVER=file
SESSION_DRIVER=file

# Security
CORS_ALLOWED_ORIGINS=https://your-domain.com

# Logging
LOG_CHANNEL=stack
LOG_LEVEL=debug
```

### 2. Frontend Environment Variables

**Dart Compile-time Constants:**
```dart
const String API_BASE_URL = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'https://your-domain.com/api',
);

const bool ENABLE_DEBUG = bool.fromEnvironment(
  'DEBUG',
  defaultValue: false,
);

const String APP_VERSION = String.fromEnvironment(
  'APP_VERSION',
  defaultValue: '1.0.0',
);
```

**Build Command:**
```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-domain.com/api \
  --dart-define=DEBUG=false
```

---

## ✅ QUICK SETUP CHECKLIST

### Backend Setup
```
[ ] Server/VPS sudah tersedia
[ ] Domain sudah di-point ke server
[ ] Laravel installed & configured
[ ] Database created dan migrated
[ ] SSL/HTTPS certificate installed
[ ] Environment variables di-setup
[ ] Apache/Nginx configured
[ ] API endpoints tested dengan Postman
[ ] Logs configured
[ ] Backup strategy implemented
```

### Frontend Setup
```
[ ] constants.dart updated dengan server domain
[ ] pubspec.yaml dependencies installed
[ ] API Service implemented
[ ] Auth Service implemented
[ ] AndroidManifest.xml configured
[ ] Info.plist (iOS) configured
[ ] build.gradle (Android) configured
[ ] baseUrl di apiService sesuai domain
```

### Security
```
[ ] HTTPS/SSL enabled
[ ] CORS properly configured
[ ] API rate limiting enabled
[ ] Token management implemented
[ ] Password policy set
[ ] Security headers configured
[ ] .env file protected
[ ] Database credentials secured
```

### Testing
```
[ ] Backend API tested dengan curl
[ ] Login tested
[ ] Booking creation tested
[ ] User data sync tested
[ ] No timeout errors
[ ] Database integrity verified
[ ] Error logging working
[ ] Performance acceptable
```

### Production
```
[ ] Backup automated
[ ] Monitoring setup
[ ] Email notifications configured
[ ] Logging centralized
[ ] Analytics enabled
[ ] Performance optimized
[ ] Security hardened
[ ] Documentation complete
```

---

## 📞 SUPPORT & REFERENCES

### Useful Commands

```bash
# Backend
php artisan migrate
php artisan db:seed
php artisan serve
php artisan cache:clear
php artisan config:clear
php artisan log:tail

# Frontend
flutter pub get
flutter pub upgrade
flutter run --release
flutter build apk --release
flutter build ios

# Server
sudo systemctl restart apache2
sudo systemctl restart nginx
mysql -u sjapp -p sj_order_app
tail -f /var/log/apache2/error.log
```

### Documentation Links
- [Laravel Docs](https://laravel.com/docs)
- [Flutter Docs](https://flutter.dev/docs)
- [MySQL Docs](https://dev.mysql.com/doc/)
- [Apache Docs](https://httpd.apache.org/docs/)

---

**Dibuat:** 2026-04-13  
**Versi:** 1.0  
**Status:** ✅ Production Ready

Semua konfigurasi sudah tersedia dalam satu file ini! 🚀

