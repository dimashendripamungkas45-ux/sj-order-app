# 🐛 DEBUGGING: Error "Failed to fetch users"

Error ini muncul karena **Backend API endpoint belum diimplementasikan**.

Mari kita debug step-by-step:

---

## 📱 ERROR YANG MUNCUL:

```
Manajemen Pengguna
⚠️ Error
Failed to fetch users
[Coba Lagi]
```

**Penyebab**: API GET `/api/users` tidak ada atau tidak terkoneksi.

---

## 🔍 STEP 1: Verifikasi Backend Running

Buka terminal dan jalankan:
```bash
php artisan serve
```

Harus muncul:
```
Laravel development server started: http://127.0.0.1:8000
```

Kalau tidak ada, start terlebih dahulu!

---

## 🔍 STEP 2: Test API dengan Postman

### A. Login & Get Token:

**Request:**
```
POST http://localhost:8000/api/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password"
}
```

**Response Should Be:**
```json
{
  "success": true,
  "token": "abc123xyz...",
  "data": {
    "id": 1,
    "name": "Admin DIVUM",
    "email": "admin@example.com"
  }
}
```

Copy nilai `token`.

### B. Test GET Users Endpoint:

**Request:**
```
GET http://localhost:8000/api/users
Authorization: Bearer abc123xyz...
Content-Type: application/json
```

**Expected Response:**
- ✅ Status: 200 OK
- ✅ Body: `{"success": true, "data": [...]}`

**If Not Working:**
- ❌ Status 404: Endpoint tidak ada → tambahkan routes
- ❌ Status 401: Token invalid → re-login
- ❌ Status 500: Server error → check logs
- ❌ Timeout: Backend tidak running → jalankan `php artisan serve`

---

## 🔍 STEP 3: Check Laravel Routes

Jalankan:
```bash
php artisan route:list | grep users
```

Harus muncul:
```
GET    /api/users
POST   /api/users
PUT    /api/users/{id}
DELETE /api/users/{id}
```

**Jika TIDAK muncul:**
- Routes belum ditambahkan ke `routes/api.php`
- Ikuti STEP 4 di bawah

---

## 🔍 STEP 4: Check Backend Logs

Buka terminal dan lihat logs:
```bash
tail -f storage/logs/laravel.log
```

Atau di Windows:
```bash
Get-Content storage/logs/laravel.log -Tail 50
```

Cari error messages.

---

## 🔧 FIX 1: Routes Belum Ditambah

Edit `routes/api.php` dan pastikan ada section seperti ini:

```php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\UserManagementController; // ← TAMBAH INI

Route::post('/login', [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'getUser']);
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // ← TAMBAHKAN ROUTES INI:
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::post('/users', [UserManagementController::class, 'store']);
    Route::get('/users/{id}', [UserManagementController::class, 'show']);
    Route::put('/users/{id}', [UserManagementController::class, 'update']);
    Route::delete('/users/{id}', [UserManagementController::class, 'destroy']);
});
```

Kemudian test lagi di Postman.

---

## 🔧 FIX 2: Controller Belum Ada

Check apakah file `app/Http/Controllers/UserManagementController.php` sudah ada.

Jika tidak ada, buat dengan command:
```bash
php artisan make:controller UserManagementController
```

Kemudian copy-paste isi dari file `LARAVEL_UserManagementController.php` yang sudah disiapkan.

---

## 🔧 FIX 3: Database Migration Belum Dijalankan

Check database apakah kolom `role`, `status`, `phone_number`, `division` sudah ada.

Jalankan:
```bash
php artisan migrate
```

Jika belum ada migration, buat:
```bash
php artisan make:migration add_user_management_fields_to_users_table
```

Copy isi dari `MIGRATION_ADD_USER_MANAGEMENT_FIELDS.php` dan run migrate lagi.

---

## 🔧 FIX 4: User Model $fillable Tidak Updated

Edit `app/Models/User.php` dan pastikan `$fillable` memiliki:

```php
protected $fillable = [
    'name',
    'email',
    'password',
    'role',
    'status',
    'phone_number',
    'division',
];
```

---

## 📋 DEBUGGING CHECKLIST:

```
Backend Running?
  [ ] php artisan serve sudah dijalankan
  [ ] Terminal menampilkan: "Laravel development server started"
  
Routes Ada?
  [ ] php artisan route:list | grep users muncul 4 routes
  [ ] Import UserManagementController di routes/api.php
  
Controller Ada?
  [ ] File: app/Http/Controllers/UserManagementController.php exists
  [ ] Isinya lengkap (copy dari template)
  
Database Updated?
  [ ] php artisan migrate sudah dijalankan
  [ ] Kolom role, status, phone_number, division ada di users table
  
Postman Test?
  [ ] Login endpoint: POST /login → 200 OK, dapat token
  [ ] Users endpoint: GET /users → 200 OK, dapat data
  
Token Valid?
  [ ] Token dari login response tidak expired
  [ ] Paste token di Authorization header di Postman
  
Flutter App?
  [ ] flutter run sedang berjalan
  [ ] Login sebagai admin
  [ ] Buka Menu → Administrasi → Manajemen Pengguna
```

---

## 🧪 TROUBLESHOOTING DETAILS:

### Error: 404 Not Found

**Penyebab:** Endpoint `/api/users` tidak ada di routes.

**Solusi:**
```bash
# 1. Check routes
php artisan route:list | grep api/users

# 2. Jika tidak ada, tambahkan ke routes/api.php
# 3. Clear cache:
php artisan route:clear
php artisan config:clear

# 4. Run lagi
php artisan serve
```

### Error: 401 Unauthorized

**Penyebab:** Token invalid atau middleware `auth:sanctum` gagal.

**Solusi:**
```bash
# 1. Re-login di Postman atau app
# 2. Copy token baru
# 3. Paste di Authorization header

# 4. Check middleware di route:
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/users', ...);  // ← Harus inside middleware block
});
```

### Error: 500 Internal Server Error

**Penyebab:** Exception di controller atau database error.

**Solusi:**
```bash
# 1. Lihat logs:
tail -f storage/logs/laravel.log

# 2. Check database columns:
php artisan tinker
>>> DB::select('DESCRIBE users')

# 3. Check controller method:
# - Pastikan method index(), store(), dll ada
# - Pastikan syntax PHP benar (error handling)

# 4. Test di Postman dengan berbagai payloads
```

### Error: Timeout / Connection Refused

**Penyebab:** Backend tidak running atau API URL salah.

**Solusi:**
```bash
# 1. Start backend:
php artisan serve

# 2. Check API URL di Flutter:
# lib/services/api_service.dart
# static const String baseUrl = 'http://10.0.2.2:8000/api';
# ↑ Untuk Android emulator
# Untuk device, ganti dengan IP actual

# 3. Check firewall (jika using VPN/proxy)
```

---

## 💡 QUICK DEBUG COMMANDS:

```bash
# Check routes
php artisan route:list | grep users

# Check logs (real-time)
tail -f storage/logs/laravel.log

# PHP tinker (interactive shell)
php artisan tinker
>>> User::all()
>>> exit

# Check model fillable
>>> User::$fillable
>>> exit

# Clear all caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear

# Restart development server
# (Stop current with Ctrl+C, then)
php artisan serve
```

---

## 📞 FINAL CHECKLIST SEBELUM TEST:

✅ **Backend:**
- [ ] `php artisan serve` running
- [ ] Routes added to `routes/api.php`
- [ ] UserManagementController exists & complete
- [ ] Database migration ran: `php artisan migrate`
- [ ] User model $fillable updated

✅ **Frontend:**
- [ ] `flutter run` running
- [ ] Login as admin successful
- [ ] Token valid (check in Postman)

✅ **Postman Test:**
- [ ] POST /login → 200 OK
- [ ] GET /users → 200 OK

✅ **App Test:**
- [ ] Menu → Administrasi → Manajemen Pengguna
- [ ] Should see list of users (not error)

---

**Kalau masih error setelah ikuti semua langkah ini, screenshot error-nya dan bagikan!** 📸

---

Biasanya 90% masalah adalah karena:
1. Routes belum ditambah ← **FIX 1**
2. Backend belum dijalankan ← Run `php artisan serve`
3. Migration belum dijalankan ← Run `php artisan migrate`
4. Token expired ← Re-login

Mari kita fix! 💪

