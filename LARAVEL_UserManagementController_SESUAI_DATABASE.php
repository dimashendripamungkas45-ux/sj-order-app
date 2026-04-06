<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;

/**
 * UserManagementController
 *
 * Controller untuk mengelola user di aplikasi
 * SESUAI DENGAN STRUKTUR DATABASE YANG SUDAH ADA:
 * - id, division_id, employee_id, name, email, password, role, phone, is_active
 *
 * Role yang tersedia:
 * - admin_ga: Admin GA (DIVUM)
 * - head_division: Kepala Divisi
 * - employee: Karyawan
 */
class UserManagementController extends Controller
{
    /**
     * Tampilkan daftar semua pengguna
     * GET /api/users
     */
    public function index()
    {
        try {
            Log::info('[UserManagementController] Fetching all users');

            $users = User::select(
                'id', 'division_id', 'employee_id', 'name', 'email',
                'role', 'phone', 'is_active', 'created_at'
            )
                ->orderBy('created_at', 'desc')
                ->get();

            Log::info("[UserManagementController] Retrieved " . count($users) . " users");

            return response()->json([
                'success' => true,
                'data' => $users,
                'message' => 'Users fetched successfully'
            ], 200);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.index] Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Simpan pengguna baru
     * POST /api/users
     */
    public function store(Request $request)
    {
        try {
            Log::info('[UserManagementController.store] Creating new user: ' . $request->email);

            // Check if user is admin
            if (auth()->user()->role !== 'admin_ga') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Only admin can create users'
                ], 403);
            }

            $validated = $request->validate([
                'division_id' => 'required|integer|exists:divisions,id',
                'employee_id' => 'required|string|unique:users,employee_id',
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6',
                'role' => 'required|in:employee,head_division,admin_ga',
                'phone' => 'nullable|string|max:20',
                'is_active' => 'sometimes|boolean',
            ]);

            $user = User::create([
                'division_id' => $validated['division_id'],
                'employee_id' => $validated['employee_id'],
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'role' => $validated['role'],
                'phone' => $validated['phone'] ?? null,
                'is_active' => $validated['is_active'] ?? true,
            ]);

            Log::info('[UserManagementController.store] User created successfully: ' . $user->id);

            return response()->json([
                'success' => true,
                'data' => $user->makeHidden(['password']),
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
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Tampilkan detail pengguna tertentu
     * GET /api/users/{id}
     */
    public function show($id)
    {
        try {
            Log::info("[UserManagementController.show] Fetching user: $id");

            $user = User::select(
                'id', 'division_id', 'employee_id', 'name', 'email',
                'role', 'phone', 'is_active', 'created_at'
            )
                ->findOrFail($id);

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
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Update pengguna
     * PUT /api/users/{id}
     */
    public function update(Request $request, $id)
    {
        try {
            Log::info("[UserManagementController.update] Updating user: $id");

            // Check if user is admin
            if (auth()->user()->role !== 'admin_ga') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Only admin can update users'
                ], 403);
            }

            $user = User::findOrFail($id);

            $validated = $request->validate([
                'division_id' => 'sometimes|integer|exists:divisions,id',
                'name' => 'sometimes|string|max:255',
                'email' => ['sometimes', 'email', Rule::unique('users')->ignore($id)],
                'role' => 'sometimes|in:employee,head_division,admin_ga',
                'phone' => 'nullable|string|max:20',
                'is_active' => 'sometimes|boolean',
            ]);

            // Hash password jika ada password baru
            if ($request->has('password') && !empty($request->password)) {
                $request->validate(['password' => 'string|min:6']);
                $validated['password'] = Hash::make($request->password);
            }

            $user->update($validated);

            Log::info("[UserManagementController.update] User updated successfully: $id");

            return response()->json([
                'success' => true,
                'data' => $user->makeHidden(['password']),
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
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Hapus pengguna
     * DELETE /api/users/{id}
     */
    public function destroy($id)
    {
        try {
            Log::info("[UserManagementController.destroy] Deleting user: $id");

            // Check if user is admin
            if (auth()->user()->role !== 'admin_ga') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Only admin can delete users'
                ], 403);
            }

            $user = User::findOrFail($id);

            // Prevent deleting own account
            if (auth()->id() == $id) {
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
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Cari pengguna berdasarkan kriteria
     * GET /api/users/search?name=...&email=...&role=...
     */
    public function search(Request $request)
    {
        try {
            Log::info('[UserManagementController.search] Searching users');

            $query = User::query();

            if ($request->has('name') && !empty($request->name)) {
                $query->where('name', 'like', '%' . $request->name . '%');
            }

            if ($request->has('email') && !empty($request->email)) {
                $query->where('email', 'like', '%' . $request->email . '%');
            }

            if ($request->has('role') && !empty($request->role)) {
                $query->where('role', $request->role);
            }

            if ($request->has('is_active') && $request->has('is_active')) {
                $query->where('is_active', $request->is_active);
            }

            $users = $query->select(
                'id', 'division_id', 'employee_id', 'name', 'email',
                'role', 'phone', 'is_active'
            )
                ->get();

            Log::info('[UserManagementController.search] Found ' . count($users) . ' users');

            return response()->json([
                'success' => true,
                'data' => $users,
                'message' => 'Search completed'
            ], 200);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.search] Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Batch update status pengguna
     * POST /api/users/batch-update-status
     */
    public function batchUpdateStatus(Request $request)
    {
        try {
            Log::info('[UserManagementController.batchUpdateStatus] Batch updating status');

            // Check if user is admin
            if (auth()->user()->role !== 'admin_ga') {
                return response()->json([
                    'success' => false,
                    'message' => 'Unauthorized. Only admin can update status'
                ], 403);
            }

            $validated = $request->validate([
                'user_ids' => 'required|array',
                'user_ids.*' => 'integer',
                'is_active' => 'required|boolean',
            ]);

            User::whereIn('id', $validated['user_ids'])->update([
                'is_active' => $validated['is_active']
            ]);

            Log::info('[UserManagementController.batchUpdateStatus] Updated ' . count($validated['user_ids']) . ' users');

            return response()->json([
                'success' => true,
                'message' => 'Status updated for ' . count($validated['user_ids']) . ' users'
            ], 200);
        } catch (\Exception $e) {
            Log::error('[UserManagementController.batchUpdateStatus] Error: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 400);
        }
    }
}

