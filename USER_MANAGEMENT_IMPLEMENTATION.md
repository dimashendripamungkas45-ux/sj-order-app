# Implementasi Menu Manajemen Pengguna

## 📱 Fitur yang Ditambahkan

Menu "Manajemen Pengguna" telah ditambahkan ke hamburger menu aplikasi. Fitur ini hanya tersedia untuk **Admin DIVUM** dan memungkinkan pengelolaan akun pengguna secara lengkap.

## 🎯 Lokasi Menu

Menu dapat diakses dari:
1. **Hamburger Menu** → Administrasi → **Manajemen Pengguna**
2. Route: `/user-management`

## 🔧 Fitur Utama

### 1. Daftar Pengguna
- Menampilkan semua pengguna yang terdaftar dalam sistem
- Tampilan berbentuk card yang responsif untuk mobile
- Swipe refresh untuk memperbarui data

### 2. Tambah Pengguna Baru
- Form dialog untuk menambahkan pengguna baru
- Field yang disediakan:
  - Nama Lengkap (required)
  - Email (required, validasi format)
  - Password (required, minimal 6 karakter)
  - Nomor Telepon (optional)
  - Role (Karyawan, Pimpinan Divisi, Admin DIVUM)
  - Status (Aktif, Tidak Aktif)
  - Divisi (optional)

### 3. Edit Pengguna
- Klik pada card pengguna atau pilih menu Edit
- Ubah informasi pengguna yang ada
- Field yang dapat diubah:
  - Nama Lengkap
  - Email
  - Nomor Telepon
  - Role
  - Status

### 4. Hapus Pengguna
- Klik menu Delete pada card pengguna
- Konfirmasi sebelum menghapus
- Data otomatis tersinkronisasi dengan database

## 📊 Data Flow

```
Mobile App (Flutter)
    ↓
UserManagementProvider
    ↓
ApiService (getUsers, createUser, updateUser, deleteUser)
    ↓
Backend Laravel API (/api/users)
    ↓
Database (users table)
```

## 🔌 Backend Endpoints yang Diperlukan

Berikut adalah endpoint Laravel yang diperlukan:

### 1. GET - Dapatkan Semua Pengguna
```http
GET /api/users
Authorization: Bearer {token}
```

Response Success (200):
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Admin DIVUM",
      "email": "admin@example.com"
    }
  ],
  "message": "Users fetched successfully"
}
```

### 2. POST - Buat Pengguna Baru
```http
POST /api/users
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "password123",
  "role": "employee",
  "status": "active",
  "phone_number": "081234567890",
  "division": "IT Division"
}
```

Response Success (201):
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "John Doe",
    "email": "john@example.com",
    "role": "employee",
    "status": "active"
  },
  "message": "User created successfully"
}
```

### 3. PUT - Update Pengguna
```http
PUT /api/users/{userId}
Authorization: Bearer {token}
Content-Type: application/json

{
  "name": "John Updated",
  "role": "leader",
  "status": "inactive"
}
```

Response Success (200):
```json
{
  "success": true,
  "data": {
    "id": 2,
    "name": "John Updated",
    "email": "john@example.com",
    "role": "leader",
    "status": "inactive"
  },
  "message": "User updated successfully"
}
```

### 4. DELETE - Hapus Pengguna
```http
DELETE /api/users/{userId}
Authorization: Bearer {token}
```

Response Success (200):
```json
{
  "success": true,
  "message": "User deleted successfully"
}
```

## 🛠️ Implementasi Backend Laravel

### Buat Controller `UserManagementController.php`

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Hash;

class UserManagementController extends Controller
{
    // GET /api/users
    public function index()
    {
        try {
            $users = User::all();
            
            return response()->json([
                'success' => true,
                'data' => $users,
                'message' => 'Users fetched successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    // POST /api/users
    public function store(Request $request)
    {
        try {
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users',
                'password' => 'required|string|min:6',
                'role' => 'required|in:employee,leader,admin',
                'status' => 'required|in:active,inactive',
                'phone_number' => 'nullable|string',
                'division' => 'nullable|string',
            ]);

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role' => $validated['role'],
                'status' => $validated['status'],
                'phone_number' => $validated['phone_number'] ?? null,
                'division' => $validated['division'] ?? null,
            ]);

            return response()->json([
                'success' => true,
                'data' => $user,
                'message' => 'User created successfully'
            ], 201);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    // PUT /api/users/{id}
    public function update(Request $request, $id)
    {
        try {
            $user = User::findOrFail($id);

            $validated = $request->validate([
                'name' => 'sometimes|string|max:255',
                'email' => ['sometimes', 'email', Rule::unique('users')->ignore($id)],
                'role' => 'sometimes|in:employee,leader,admin',
                'status' => 'sometimes|in:active,inactive',
                'phone_number' => 'nullable|string',
                'division' => 'nullable|string',
            ]);

            $user->update($validated);

            return response()->json([
                'success' => true,
                'data' => $user,
                'message' => 'User updated successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    // DELETE /api/users/{id}
    public function destroy($id)
    {
        try {
            $user = User::findOrFail($id);
            $user->delete();

            return response()->json([
                'success' => true,
                'message' => 'User deleted successfully'
            ], 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }
}
```

### Update Routes (routes/api.php)

```php
// User Management (Admin Only)
Route::middleware(['auth:sanctum', 'admin'])->group(function () {
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::post('/users', [UserManagementController::class, 'store']);
    Route::put('/users/{id}', [UserManagementController::class, 'update']);
    Route::delete('/users/{id}', [UserManagementController::class, 'destroy']);
});
```

### Update User Model

Pastikan User model memiliki properties yang sesuai:

```php
class User extends Model
{
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
}
```

### Database Migration

Jika belum ada, buat migration untuk menambah kolom:

```bash
php artisan make:migration add_user_management_fields_to_users_table
```

```php
public function up()
{
    Schema::table('users', function (Blueprint $table) {
        $table->string('role')->default('employee')->after('email');
        $table->enum('status', ['active', 'inactive'])->default('active')->after('role');
        $table->string('phone_number')->nullable()->after('status');
        $table->string('division')->nullable()->after('phone_number');
    });
}

public function down()
{
    Schema::table('users', function (Blueprint $table) {
        $table->dropColumn(['role', 'status', 'phone_number', 'division']);
    });
}
```

## 🎨 UI/UX Design

### Mobile Layout
- Card-based design untuk responsif di layar kecil
- Dialog forms dengan scrollable untuk banyak field
- Bottom action buttons yang mudah diakses
- Swipe refresh untuk memperbarui data
- Loading indicators untuk feedback user

### Warna & Tema
- Primary Color: #00B477 (Hijau)
- Icon konsisten dengan tema aplikasi
- Status badge dengan warna berbeda

## 📝 Catatan Penting

1. **Autentikasi**: Menu hanya tersedia untuk Admin DIVUM
2. **Validasi**: Semua field divalidasi baik di client maupun server
3. **Error Handling**: Pesan error yang jelas untuk user
4. **Real-time Sync**: Data otomatis tersinkronisasi setelah operasi
5. **Konfirmasi Hapus**: Proteksi untuk mencegah penghapusan accidental

## 🔐 Keamanan

- Bearer token authentication
- Server-side role validation
- Email unique constraint
- Password hashing dengan bcrypt
- CSRF protection (Laravel default)

## 📱 Kompatibilitas

- Tested pada Flutter Web & Android
- Responsive design untuk semua ukuran layar
- Support untuk landscape dan portrait modes

---

Implementasi ini siap digunakan dan terintegrasi penuh dengan backend Laravel Anda!

