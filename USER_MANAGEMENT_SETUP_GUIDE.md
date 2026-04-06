# 📋 Setup Lengkap: Fitur Manajemen Pengguna

## ✅ Yang Sudah Ditambahkan di Frontend (Flutter)

### 1. File-file Flutter Baru:
- ✅ `lib/screens/user_management_screen.dart` - Screen utama manajemen pengguna
- ✅ `lib/providers/user_management_provider.dart` - State management
- ✅ Update `lib/main.dart` - Routes dan providers
- ✅ Update `lib/widgets/role_based_drawer.dart` - Menu hamburger

### 2. Fitur:
- ✅ Tampilkan daftar pengguna dalam card view yang responsif
- ✅ Tambah pengguna baru dengan form dialog
- ✅ Edit detail pengguna
- ✅ Hapus pengguna dengan konfirmasi
- ✅ Swipe refresh untuk update data
- ✅ Loading state dan error handling
- ✅ Menu hanya untuk Admin DIVUM

---

## 🔧 Setup Backend (Laravel) - WAJIB DILAKUKAN

### Step 1: Copy Controller File

Salin file `LARAVEL_UserManagementController.php` ke:
```
app/Http/Controllers/UserManagementController.php
```

### Step 2: Update User Model

Edit file `app/Models/User.php`:

```php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'password',
        'role',
        'status',
        'phone_number',
        'division',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'password' => 'hashed',
    ];
}
```

### Step 3: Buat Migration

1. Buat file migrasi baru:
```bash
php artisan make:migration add_user_management_fields_to_users_table
```

2. Salin isi dari `MIGRATION_ADD_USER_MANAGEMENT_FIELDS.php` ke dalam file migration yang baru dibuat

3. Jalankan migration:
```bash
php artisan migrate
```

### Step 4: Update Routes

Edit file `routes/api.php` dan salin routes yang sesuai dari `LARAVEL_ROUTES_API_WITH_USER_MANAGEMENT.php`

Atau lebih simple, tambahkan ini ke dalam `routes/api.php`:

```php
// User Management (Admin Only)
Route::middleware(['auth:sanctum'])->group(function () {
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::post('/users', [UserManagementController::class, 'store']);
    Route::get('/users/{id}', [UserManagementController::class, 'show']);
    Route::put('/users/{id}', [UserManagementController::class, 'update']);
    Route::delete('/users/{id}', [UserManagementController::class, 'destroy']);
    Route::get('/users/search', [UserManagementController::class, 'search']);
    Route::post('/users/batch-update-status', [UserManagementController::class, 'batchUpdateStatus']);
});
```

**PENTING**: Jika menggunakan middleware authorization, pastikan controller memiliki pengecekan role admin.

### Step 5: Buat Authorization Policy (Opsional)

Jika ingin lebih aman dengan authorization policy:

```bash
php artisan make:policy UserPolicy --model=User
```

Edit `app/Policies/UserPolicy.php`:

```php
<?php

namespace App\Policies;

use App\Models\User;

class UserPolicy
{
    public function manageUsers(User $user): bool
    {
        return $user->role === 'admin';
    }

    public function delete(User $user, User $targetUser): bool
    {
        // Admin dapat delete user lain, tapi tidak user sendiri
        return $user->role === 'admin' && $user->id !== $targetUser->id;
    }
}
```

Kemudian di AuthServiceProvider:

```php
protected $policies = [
    User::class => UserPolicy::class,
];
```

### Step 6: Test API Endpoints

Gunakan Postman atau Thunder Client:

#### Test 1: GET All Users
```
GET http://localhost:8000/api/users
Authorization: Bearer {your_admin_token}
```

#### Test 2: POST Create User
```
POST http://localhost:8000/api/users
Authorization: Bearer {your_admin_token}
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "employee",
  "status": "active",
  "phone_number": "081234567890"
}
```

#### Test 3: PUT Update User
```
PUT http://localhost:8000/api/users/2
Authorization: Bearer {your_admin_token}
Content-Type: application/json

{
  "name": "John Updated",
  "role": "leader"
}
```

#### Test 4: DELETE User
```
DELETE http://localhost:8000/api/users/2
Authorization: Bearer {your_admin_token}
```

---

## 🚀 Testing di Frontend

### 1. Restart App
```bash
flutter clean
flutter pub get
flutter run
```

### 2. Login sebagai Admin DIVUM
- Email: admin@example.com (atau sesuai database Anda)
- Password: password

### 3. Buka Hamburger Menu
- Klik icon hamburger (≡) di dashboard
- Scroll ke bawah ke "Administrasi"
- Klik "Manajemen Pengguna"

### 4. Test Fitur
- ✅ Lihat daftar pengguna
- ✅ Klik "+ Tambah Pengguna" untuk menambah user baru
- ✅ Klik card pengguna untuk edit
- ✅ Klik menu (⋮) untuk edit/hapus
- ✅ Swipe down untuk refresh

---

## 📊 Data Flow Diagram

```
┌─────────────────┐
│  Admin DIVUM    │
│   (Flutter)     │
└────────┬────────┘
         │
         ↓
┌─────────────────────────────────┐
│  UserManagementScreen           │
│  - Form Tambah/Edit             │
│  - List View                    │
└────────┬────────────────────────┘
         │
         ↓
┌─────────────────────────────────┐
│  UserManagementProvider         │
│  - fetchUsers()                 │
│  - createUser()                 │
│  - updateUser()                 │
│  - deleteUser()                 │
└────────┬────────────────────────┘
         │
         ↓
┌─────────────────────────────────┐
│  ApiService                     │
│  - getUsers()                   │
│  - createUser()                 │
│  - updateUser()                 │
│  - deleteUser()                 │
└────────┬────────────────────────┘
         │
         ↓ HTTP/Bearer Token
┌─────────────────────────────────┐
│  Laravel API                    │
│  POST /api/users                │
│  GET /api/users                 │
│  PUT /api/users/{id}            │
│  DELETE /api/users/{id}         │
└────────┬────────────────────────┘
         │
         ↓
┌─────────────────────────────────┐
│  UserManagementController       │
│  - index()                      │
│  - store()                      │
│  - update()                     │
│  - destroy()                    │
└────────┬────────────────────────┘
         │
         ↓
┌─────────────────────────────────┐
│  Database                       │
│  - users table                  │
│    * id                         │
│    * name                       │
│    * email                      │
│    * password                   │
│    * role                       │
│    * status                     │
│    * phone_number               │
│    * division                   │
└─────────────────────────────────┘
```

---

## 🔒 Keamanan

### Implemented:
- ✅ Bearer token authentication
- ✅ Email unique validation
- ✅ Password min 6 characters
- ✅ Server-side validation
- ✅ Role-based access control
- ✅ Cannot delete own account
- ✅ CSRF protection (Laravel default)
- ✅ Password hashing dengan bcrypt

### Recommendations:
1. Gunakan HTTPS di production
2. Implement rate limiting pada API
3. Add logging untuk semua operasi user management
4. Implement activity logs di database
5. Add approval workflow untuk sensitive operations

---

## 🐛 Troubleshooting

### Error: "Session expired"
- Pastikan token masih valid
- Re-login dengan akun admin

### Error: "Failed to fetch users"
- Cek backend sedang running
- Cek URL API di ApiService (baseUrl)
- Verify token di Postman

### Error: "User not found"
- Pastikan user ID valid
- Refresh halaman

### Error: "Validation error"
- Cek email sudah ada di database
- Pastikan password minimal 6 karakter

### UI tidak menampilkan menu "Manajemen Pengguna"
- Pastikan sudah login sebagai Admin DIVUM
- Cek `isDivumAdmin` di RoleProvider

---

## 📝 Database Schema

```sql
-- Kolom yang akan ditambahkan ke tabel users
ALTER TABLE users ADD COLUMN role VARCHAR(255) DEFAULT 'employee' AFTER email;
ALTER TABLE users ADD COLUMN status ENUM('active', 'inactive') DEFAULT 'active' AFTER role;
ALTER TABLE users ADD COLUMN phone_number VARCHAR(20) NULLABLE AFTER status;
ALTER TABLE users ADD COLUMN division VARCHAR(255) NULLABLE AFTER phone_number;

-- Index untuk performa
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(status);
```

---

## 📞 Support

Jika ada pertanyaan atau error:
1. Cek log backend: `storage/logs/laravel.log`
2. Cek console Flutter: `flutter run`
3. Gunakan Postman untuk test API
4. Verify database structure dengan `php artisan tinker`

---

**Status**: ✅ Implementasi Selesai dan Siap Digunakan!

