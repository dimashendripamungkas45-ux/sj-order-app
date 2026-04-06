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
     * Returns all users with their details
     */
    public function index()
    {
        try {
            Log::info('[UserManagementController.index] Fetching all users');

            // Get all users from database
            $users = User::select(
                'id',
                'name',
                'email',
                'employee_id',
                'division_id',
                'role',
                'phone',
                'is_active',
                'created_at',
                'updated_at'
            )->orderBy('created_at', 'desc')->get();

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
                'message' => 'Error fetching users: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Store a newly created resource in storage.
     * POST /api/users
     * Creates a new user
     */
    public function store(Request $request)
    {
        try {
            Log::info('[UserManagementController.store] Creating new user for email: ' . $request->email);

            // Validate input
            $validated = $request->validate([
                'name' => 'required|string|max:255',
                'email' => 'required|email|unique:users,email',
                'password' => 'required|string|min:6',
                'employee_id' => 'required|string|unique:users,employee_id',
                'division_id' => 'required|integer',
                'role' => 'required|string',
                'phone' => 'nullable|string|max:20',
                'is_active' => 'nullable|boolean',
            ]);

            // Create new user
            $user = User::create([
                'name' => $validated['name'],
                'email' => $validated['email'],
                'password' => Hash::make($validated['password']),
                'employee_id' => $validated['employee_id'],
                'division_id' => $validated['division_id'],
                'role' => $validated['role'],
                'phone' => $validated['phone'] ?? null,
                'is_active' => $validated['is_active'] ?? true,
            ]);

            Log::info('[UserManagementController.store] User created successfully with ID: ' . $user->id);

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
                'message' => 'Error creating user: ' . $e->getMessage()
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
            Log::info("[UserManagementController.show] Fetching user with ID: $id");

            $user = User::select(
                'id',
                'name',
                'email',
                'employee_id',
                'division_id',
                'role',
                'phone',
                'is_active',
                'created_at',
                'updated_at'
            )->findOrFail($id);

            return response()->json([
                'success' => true,
                'data' => $user,
                'message' => 'User fetched successfully'
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            Log::warning("[UserManagementController.show] User not found with ID: $id");
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);

        } catch (\Exception $e) {
            Log::error('[UserManagementController.show] Error: ' . $e->getMessage());
            Log::error('[UserManagementController.show] Stack trace: ' . $e->getTraceAsString());

            return response()->json([
                'success' => false,
                'message' => 'Error fetching user: ' . $e->getMessage()
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
            Log::info("[UserManagementController.update] Updating user with ID: $id");

            $user = User::findOrFail($id);

            $validated = $request->validate([
                'name' => 'sometimes|string|max:255',
                'email' => ['sometimes', 'email', Rule::unique('users')->ignore($id)],
                'password' => 'sometimes|string|min:6',
                'employee_id' => ['sometimes', 'string', Rule::unique('users')->ignore($id)],
                'division_id' => 'sometimes|integer',
                'role' => 'sometimes|string',
                'phone' => 'nullable|string|max:20',
                'is_active' => 'sometimes|boolean',
            ]);

            // Hash password if provided
            if (isset($validated['password'])) {
                $validated['password'] = Hash::make($validated['password']);
            }

            $user->update($validated);

            Log::info("[UserManagementController.update] User updated successfully with ID: $id");

            return response()->json([
                'success' => true,
                'data' => $user,
                'message' => 'User updated successfully'
            ], 200);

        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            Log::warning("[UserManagementController.update] User not found with ID: $id");
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
                'message' => 'Error updating user: ' . $e->getMessage()
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
            Log::info("[UserManagementController.destroy] Deleting user with ID: $id");

            $user = User::findOrFail($id);

            // Prevent deleting own account
            if (auth()->check() && auth()->id() == $id) {
                Log::warning("[UserManagementController.destroy] User tried to delete own account with ID: $id");
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
            Log::warning("[UserManagementController.destroy] User not found with ID: $id");
            return response()->json([
                'success' => false,
                'message' => 'User not found'
            ], 404);

        } catch (\Exception $e) {
            Log::error('[UserManagementController.destroy] Error: ' . $e->getMessage());
            Log::error('[UserManagementController.destroy] Stack trace: ' . $e->getTraceAsString());

            return response()->json([
                'success' => false,
                'message' => 'Error deleting user: ' . $e->getMessage()
            ], 500);
        }
    }
}

