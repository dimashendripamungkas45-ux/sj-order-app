# ⚡ FIX ERROR "Failed to fetch users" - 10 LANGKAH MUDAH

**Waktu: ~15 menit | Kesulitan: Mudah**

---

## LANGKAH 1️⃣: Buat Controller

Buka Terminal, ketik:
```
php artisan make:controller UserManagementController
```

---

## LANGKAH 2️⃣: Copy Code Controller

1. Buka file yang baru dibuat: `app/Http/Controllers/UserManagementController.php`
2. **DELETE SEMUA ISI NYA**
3. Copy-paste seluruh isi dari file: `LARAVEL_UserManagementController.php` (di folder project)
4. **SAVE file**

---

## LANGKAH 3️⃣: Update Routes

Edit file: `routes/api.php`

**STEP A: Cari bagian atas file (section `use ...`), tambahkan:**
```php
use App\Http\Controllers\UserManagementController;
```

**STEP B: Cari bagian yang ada:**
```php
Route::middleware('auth:sanctum')->group(function () {
    Route::get('/user', [AuthController::class, 'getUser']);
    Route::post('/logout', [AuthController::class, 'logout']);
});
```

**Tambahkan routes ini SEBELUM closing `});`:**
```php
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::post('/users', [UserManagementController::class, 'store']);
    Route::get('/users/{id}', [UserManagementController::class, 'show']);
    Route::put('/users/{id}', [UserManagementController::class, 'update']);
    Route::delete('/users/{id}', [UserManagementController::class, 'destroy']);
```

**SAVE file**

---

## LANGKAH 4️⃣: Buat Migration

Buka Terminal, ketik:
```
php artisan make:migration add_user_management_fields_to_users_table
```

---

## LANGKAH 5️⃣: Copy Code Migration

1. Buka file migration yang baru dibuat (di folder: `database/migrations/`)
2. Nama filenya akan seperti: `2026_04_07_XXXXXX_add_user_management_fields_to_users_table.php`
3. **DELETE SEMUA ISI NYA**
4. Copy-paste seluruh isi dari file: `MIGRATION_ADD_USER_MANAGEMENT_FIELDS.php`
5. **SAVE file**

---

## LANGKAH 6️⃣: Jalankan Migration

Buka Terminal, ketik:
```
php artisan migrate
```

**Harus muncul:**
```
Migrating: 2026_04_07_XXXXXX_add_user_management_fields_to_users_table
Migrated:  2026_04_07_XXXXXX_add_user_management_fields_to_users_table
```

---

## LANGKAH 7️⃣: Update User Model

Edit file: `app/Models/User.php`

Cari bagian:
```php
protected $fillable = [
    'name',
    'email',
    'password',
];
```

**Ganti dengan:**
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

**SAVE file**

---

## LANGKAH 8️⃣: Verify Routes Berhasil Ditambah

Buka Terminal, ketik:
```
php artisan route:list | grep users
```

**Harus muncul 5 routes (kira-kira seperti ini):**
```
GET    /api/users
POST   /api/users
GET    /api/users/{id}
PUT    /api/users/{id}
DELETE /api/users/{id}
```

Jika muncul → OK, lanjut ke step 9
Jika tidak muncul → Ulangi LANGKAH 3

---

## LANGKAH 9️⃣: Test di Postman

**A. Login (untuk dapat token):**

1. Buka Postman
2. Buat request baru: `POST` method
3. URL: `http://localhost:8000/api/login`
4. Tab "Body" → pilih "raw" → pilih "JSON"
5. Paste:
```json
{
  "email": "admin@example.com",
  "password": "password"
}
```
6. **SEND**
7. Copy nilai `token` dari response

**B. Test GET Users:**

1. Buat request baru: `GET` method
2. URL: `http://localhost:8000/api/users`
3. Tab "Headers" → tambahkan:
   - Key: `Authorization`
   - Value: `Bearer [TOKEN_DARI_STEP_A]` (replace [TOKEN_DARI_STEP_A] dengan token actual)
4. **SEND**
5. Harus dapat response 200 OK dengan list users

Jika 200 OK → SUCCESS! Lanjut ke step 10
Jika error → Lihat TROUBLESHOOTING di bawah

---

## LANGKAH 🔟: Test di Flutter App

1. Jika belum ada, jalankan: `flutter run`
2. Atau reload app: Tekan `r` di terminal
3. **Login sebagai admin**
4. Buka hamburger menu ≡ (icon 3 garis)
5. Scroll ke bawah
6. Klik "Manajemen Pengguna" (di bagian "Administrasi")

**Harus muncul: LIST OF USERS (tidak ada error)**

Jika berhasil → 🎉 ERROR FIXED!
Jika masih error → Lihat TROUBLESHOOTING

---

## 🚨 TROUBLESHOOTING QUICK HELP:

**Error: "Table ... doesn't exist"**
```bash
php artisan migrate:refresh
# atau coba sekali lagi:
php artisan migrate
```

**Error: 404 Not Found (di Postman)**
→ Routes tidak ditambah dengan benar
→ Ulangi LANGKAH 3 dengan teliti
→ Pastikan import UserManagementController sudah ditambah

**Error: 401 Unauthorized (di Postman)**
→ Token invalid
→ Ulangi LANGKAH 9A untuk dapat token baru

**Error: 500 Internal Server Error (di Postman)**
→ Server error
→ Buka terminal Laravel, cek log

**Masih error setelah semua step?**
→ Screenshot error message
→ Check file: DEBUGGING_FAILED_TO_FETCH.md

---

## ✅ CHECKLIST SEBELUM MULAI:

- [ ] Terminal 1: `php artisan serve` sudah berjalan
- [ ] Terminal 2: Siap untuk menjalankan commands
- [ ] VS Code: Siap untuk edit files
- [ ] Postman: Siap (atau install jika belum)
- [ ] Flutter: Sudah running atau siap untuk `flutter run`

---

## ✨ EXPECTED RESULT:

**SEBELUM FIX:**
```
Error
Failed to fetch users
[Coba Lagi]
```

**SESUDAH FIX:**
```
[User Card 1]
👤 John Doe
john@example.com
⋮

[User Card 2]
👤 Jane Smith
jane@example.com
⋮

[+ Tambah Pengguna]
```

---

## ⏱️ TIMELINE:

```
Step 1:  5 detik
Step 2:  1 menit (copy-paste)
Step 3:  2 menit (edit file)
Step 4:  5 detik
Step 5:  1 menit (copy-paste)
Step 6:  10 detik
Step 7:  1 menit (edit file)
Step 8:  10 detik
Step 9:  2 menit (Postman test)
Step 10: 30 detik (Flutter reload)
───────────────────
TOTAL:  ~15 menit!
```

---

## 🎯 SEKARANG MULAI!

Buka Terminal, ketik Step 1 command, tekan Enter.

Lalu ikuti step 2-10 secara berurutan.

**Mari kita fix error ini! 💪**

Good luck! 🚀

