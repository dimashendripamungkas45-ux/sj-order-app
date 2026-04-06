# ⚠️ SOLUSI ERROR 500 - User Management API

Error 500 muncul karena **UserManagementController belum ada atau Route belum terdaftar**.

---

## 🚨 ERROR LOG:
```
Response status: 500
Failed to fetch users
```

---

## ✅ SOLUSI STEP-BY-STEP

### STEP 1: Buka Terminal di Folder Laravel Backend
```bash
cd C:\laravel-project\sj-order-api
```

---

### STEP 2: Buat UserManagementController

Jalankan command:
```bash
php artisan make:controller UserManagementController
```

**Expected Output:**
```
Controller created successfully.
```

---

### STEP 3: Copy Controller Content

Buka file yang baru dibuat:
```
app/Http/Controllers/UserManagementController.php
```

**DELETE semua isinya**, REPLACE dengan kode di bawah:

```php
<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

class UserManagementController extends Controller
{
    /**
     * Display a listing of the resource.
     * GET /api/users
     */
    public function index()
    {
        try {
            Log::info('[UserManagementController.index] Fetching all users');

            $users = User::all();

            Log::info("[UserManagementController.index] Retrieved " . count($users) . " users");

            return response()->json([
                'success' => true,
                'data' => $users,
                'message' => 'Users fetched successfully'
            ], 200);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.index] Error: ' . $e->getMessage());
            Log::error('[UserManagementController.index] Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     * POST /api/users
     */
    public function store(Request $request)
    {
        try {
            Log::info('[UserManagementController.store] Creating new user: ' . $request->email);

            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6',
                'role' => 'required|string',
                'phone' => 'nullable|string',
                'employee_id' => 'nullable|string',
                'division_id' => 'nullable|integer',
                'is_active' => 'nullable|boolean'
            ]);

            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role' => $validated['role'],
                'phone' => $validated['phone'] ?? null,
                'employee_id' => $validated['employee_id'] ?? null,
                'division_id' => $validated['division_id'] ?? null,
                'is_active' => $validated['is_active'] ?? true,
            ]);

            Log::info('[UserManagementController.store] User created successfully: ' . $user->id);

            return response()->json([
                'success' => true,
                'data' => $user,
                'message' => 'User created successfully'
            ], 201);
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::warning('[UserManagementController.store] Validation error: ' . json_encode($e->errors()));
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.store] Error: ' . $e->getMessage());
            Log::error('[UserManagementController.store] Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Display the specified resource.
     * GET /api/users/{id}
     */
    public function show($id)
    {
        try {
            Log::info("[UserManagementController.show] Fetching user: $id");

            $user = User::findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $user,
                'message' => 'User fetched successfully'
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            Log::warning("[UserManagementController.show] User not found: $id");
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.show] Error: ' . $e->getMessage());
            Log::error('[UserManagementController.show] Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update the specified resource in storage.
     * PUT /api/users/{id}
     */
    public function update(Request $request, $id)
    {
        try {
            Log::info("[UserManagementController.update] Updating user: $id");

            $user = User::findOrFail($id);

            $validated = $request->validate([
                'name' => 'sometimes|string|max:255',
                'email' => ['sometimes', 'email', Rule::unique('users')->ignore($id)],
                'password' => 'sometimes|string|min:6',
                'role' => 'sometimes|string',
                'phone' => 'nullable|string',
                'employee_id' => 'nullable|string',
                'division_id' => 'nullable|integer',
                'is_active' => 'nullable|boolean'
            ]);

            if (isset($validated['password'])) {
                $validated['password'] = Hash::make($validated['password']);
            }

            $user->update($validated);

            Log::info("[UserManagementController.update] User updated successfully: $id");

            return response()->json([
                'success' => true,
                'data' => $user,
                'message' => 'User updated successfully'
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            Log::warning("[UserManagementController.update] User not found: $id");
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::warning('[UserManagementController.update] Validation error: ' . json_encode($e->errors()));
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.update] Error: ' . $e->getMessage());
            Log::error('[UserManagementController.update] Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Remove the specified resource from storage.
     * DELETE /api/users/{id}
     */
    public function destroy($id)
    {
        try {
            Log::info("[UserManagementController.destroy] Deleting user: $id");

            $user = User::findOrFail($id);

            // Prevent deleting own account
            if (auth()->check() && auth()->id() == $id) {
                Log::warning("[UserManagementController.destroy] User tried to delete own account: $id");
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot delete your own account'
                ], 400);
            }

            $userName = $user->name;
            $user->delete();

            Log::info("[UserManagementController.destroy] User deleted successfully: $id ($userName)");

            return response()->json([
                'success' => true,
                'message' => 'User deleted successfully'
            ], 200);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            Log::warning("[UserManagementController.destroy] User not found: $id");
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.destroy] Error: ' . $e->getMessage());
            Log::error('[UserManagementController.destroy] Stack trace: ' . $e->getTraceAsString());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}
```

**Simpan file tersebut!**

---

### STEP 4: Update User Model

Buka file:
```
app/Models/User.php
```

Cari bagian `$fillable` dan pastikan sudah include semua field:

```php
protected $fillable = [
    'name',
    'email',
    'password',
    'role',
    'phone',
    'employee_id',
    'division_id',
    'is_active',
    'remember_token',
];
```

---

### STEP 5: Add Routes

Buka file:
```
routes/api.php
```

**Cari bagian atas file (imports), tambahkan:**
```php
use App\Http\Controllers\UserManagementController;
```

**Cari block middleware `auth:sanctum` dan tambahkan routes ini di dalam block:**

```php
Route::middleware('auth:sanctum')->group(function () {
    // ... existing routes ...

    // USER MANAGEMENT ROUTES
    Route::get('/users', [UserManagementController::class, 'index']);
    Route::post('/users', [UserManagementController::class, 'store']);
    Route::get('/users/{id}', [UserManagementController::class, 'show']);
    Route::put('/users/{id}', [UserManagementController::class, 'update']);
    Route::delete('/users/{id}', [UserManagementController::class, 'destroy']);
});
```

**Simpan file!**

---

### STEP 6: Verify Routes

Di terminal, jalankan:
```bash
php artisan route:list | grep users
```

**Expected output:**
```
GET       /api/users .......................... UserManagementController@index
POST      /api/users .......................... UserManagementController@store
GET       /api/users/{id} ..................... UserManagementController@show
PUT       /api/users/{id} ..................... UserManagementController@update
DELETE    /api/users/{id} ..................... UserManagementController@destroy
```

Jika ada 5 routes muncul → ✅ SUKSES!

---

### STEP 7: Clear Cache (Penting!)

Jalankan di terminal:
```bash
php artisan route:clear
php artisan cache:clear
php artisan config:clear
```

---

### STEP 8: Restart Laravel Server

Tutup terminal yang menjalankan `php artisan serve`, kemudian jalankan lagi:
```bash
php artisan serve
```

**Expected output:**
```
Laravel development server started: http://127.0.0.1:8000
```

---

### STEP 9: Test di Postman

**1. Login untuk get token:**
```
POST http://localhost:8000/api/login
Content-Type: application/json

{
  "email": "mirzawargajakarta@gmail.com",
  "password": "password"
}
```

Copy `token` dari response.

**2. Test GET Users:**
```
GET http://localhost:8000/api/users
Authorization: Bearer YOUR_TOKEN
Content-Type: application/json
```

**Expected Response Status:** 200 OK
**Expected Response Body:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "name": "Admin DIVUM",
      "email": "mirzawargajakarta@gmail.com",
      "role": "admin_ga",
      ...
    },
    ...
  ],
  "message": "Users fetched successfully"
}
```

---

### STEP 10: Restart Flutter App

Di terminal Flutter:
```bash
flutter run
```

Atau jika sudah running, tekan `r` untuk reload.

---

## 🔍 DEBUGGING JIKA MASIH ERROR:

**Error masih 500?**

1. **Check Laravel logs:**
```bash
tail -f storage/logs/laravel.log
```

2. **Pastikan UserManagementController.php ada di:**
```
app/Http/Controllers/UserManagementController.php
```

3. **Pastikan routes sudah terupdate di `routes/api.php`**

4. **Run clear cache commands lagi:**
```bash
php artisan route:clear
php artisan cache:clear
```

5. **Restart Laravel server**

---

## ✅ CHECKLIST FINAL:

- [x] Create UserManagementController
- [x] Copy controller code
- [x] Update User Model fillable
- [x] Add routes to routes/api.php
- [x] php artisan route:clear
- [x] php artisan cache:clear
- [x] Restart Laravel server
- [x] Test Postman (login → get users)
- [x] Restart Flutter app

Setelah semua done, error 500 harus hilang dan users akan muncul di menu "Manajemen Pengguna"! 🎉


