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
     * Tampilkan daftar semua pengguna
     * GET /api/users
     */
    public function index()
    {
        try {
            Log::info('[UserManagementController] Fetching all users');

            $users = User::select('id', 'name', 'email', 'role', 'status', 'phone_number', 'division', 'created_at')
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

            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6',
                'role' => 'required|in:employee,leader,admin',
                'status' => 'required|in:active,inactive',
                'phone_number' => 'nullable|string|max:20',
                'division' => 'nullable|string|max:255',
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

            $user = User::select('id', 'name', 'email', 'role', 'status', 'phone_number', 'division', 'created_at')
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

            $user = User::findOrFail($id);

            $validated = $request->validate([
                'name' => 'sometimes|string|max:255',
                'email' => ['sometimes', 'email', Rule::unique('users')->ignore($id)],
                'role' => 'sometimes|in:employee,leader,admin',
                'status' => 'sometimes|in:active,inactive',
                'phone_number' => 'nullable|string|max:20',
                'division' => 'nullable|string|max:255',
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

            if ($request->has('status') && !empty($request->status)) {
                $query->where('status', $request->status);
            }

            $users = $query->select('id', 'name', 'email', 'role', 'status', 'phone_number', 'division')
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

            $validated = $request->validate([
                'user_ids' => 'required|array',
                'user_ids.*' => 'integer',
                'status' => 'required|in:active,inactive',
            ]);

            User::whereIn('id', $validated['user_ids'])->update([
                'status' => $validated['status']
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

