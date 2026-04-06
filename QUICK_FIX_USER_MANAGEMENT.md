# QUICK FIX: Implementasi Backend User Management API

Ikuti langkah ini untuk membuat API bekerja. Estimasi waktu: **15 menit**

---

## 🔧 STEP 1: UPDATE User Model (1 menit)

Edit file `app/Models/User.php` dan update bagian `$fillable`:

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

## 🔧 STEP 2: Buat Controller (5 menit)

Jalankan command:
```bash
php artisan make:controller UserManagementController
```

Kemudian copy-paste isi dari file `LARAVEL_UserManagementController.php` yang sudah disiapkan.

---

## 🔧 STEP 3: Update Routes (2 menit)

Edit file `routes/api.php` dan tambahkan routes ini **SEBELUM closing brace** di dalam middleware `auth:sanctum`:

```php
Route::middleware('auth:sanctum')->group(function () {
    // Existing routes...
    
    // ===== USER MANAGEMENT ROUTES (TAMBAHKAN INI) =====
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::post('/users', [UserManagementController::class, 'store']);
    Route::get('/users/{id}', [UserManagementController::class, 'show']);
    Route::put('/users/{id}', [UserManagementController::class, 'update']);
    Route::delete('/users/{id}', [UserManagementController::class, 'destroy']);
});
```

Di atas baris routes ini, tambahkan import:
```php
use App\Http\Controllers\UserManagementController;
```

---

## 🔧 STEP 4: Buat Database Migration (3 menit)

Jalankan:
```bash
php artisan make:migration add_user_management_fields_to_users_table
```

Salin isi dari file `MIGRATION_ADD_USER_MANAGEMENT_FIELDS.php` ke dalam migration yang baru dibuat.

Kemudian jalankan migration:
```bash
php artisan migrate
```

---

## 🔧 STEP 5: Test API (4 menit)

### Test dengan Postman:

**1. Login first untuk get token:**
```
POST http://localhost:8000/api/login
Content-Type: application/json

{
  "email": "admin@example.com",
  "password": "password"
}
```

Copy token dari response.

**2. Test GET /api/users:**
```
GET http://localhost:8000/api/users
Authorization: Bearer YOUR_TOKEN_HERE
Content-Type: application/json
```

Harus return 200 OK dengan list users.

---

## ✅ VERIFY SETUP:

Jalankan command:
```bash
php artisan route:list | grep users
```

Harus muncul routes seperti:
```
GET    /api/users
POST   /api/users
PUT    /api/users/{id}
DELETE /api/users/{id}
```

---

## 🧪 TEST DI FLUTTER:

1. Jika error "Failed to fetch users", cek:
   - ✓ Backend sudah running: `php artisan serve`
   - ✓ Routes sudah ditambah (jalankan `php artisan route:list`)
   - ✓ Migration sudah dijalankan
   - ✓ Token valid (lihat Postman test)

2. Kalau masih error, lihat console log:
   - Backend: `storage/logs/laravel.log`
   - Flutter: `flutter run -v`

---

## 📝 QUICK CHECKLIST:

- [ ] User Model updated dengan $fillable
- [ ] UserManagementController dibuat & isi dikopy
- [ ] Routes ditambahkan di routes/api.php
- [ ] Migration dibuat & isinya dikopy
- [ ] `php artisan migrate` sudah dijalankan
- [ ] Backend running: `php artisan serve`
- [ ] Test GET /api/users di Postman → 200 OK
- [ ] Flutter app running
- [ ] Login sebagai admin
- [ ] Buka Menu → Administrasi → Manajemen Pengguna
- [ ] Tidak ada error → SUKSES! ✅

---

**Done! Sekarang harusnya User Management menu sudah berfungsi dengan sempurna.**

Jika masih ada error, bagikan screenshot error-nya!

