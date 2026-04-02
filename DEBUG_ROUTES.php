<?php

// FILE INI UNTUK DEBUG SAJA - Letakkan di routes/web.php atau buat route terpisah

// Test 1: Check semua users
Route::get('/debug/users', function () {
    $users = \App\Models\User::all();
    return response()->json([
        'users' => $users->map(function($user) {
            return [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'employee_id' => $user->employee_id,
                'role' => $user->role,
                'password_hash' => $user->password,
            ];
        })
    ]);
});

// Test 2: Test password verification
Route::post('/debug/verify-password', function (Request $request) {
    $email = $request->input('email');
    $password = $request->input('password');

    $user = \App\Models\User::where('email', $email)->first();

    if (!$user) {
        return response()->json([
            'success' => false,
            'message' => 'User tidak ditemukan',
        ], 404);
    }

    $isPasswordCorrect = \Illuminate\Support\Facades\Hash::check($password, $user->password);

    return response()->json([
        'success' => true,
        'user' => $user->name,
        'email' => $user->email,
        'password_is_correct' => $isPasswordCorrect,
        'password_hash' => $user->password,
        'message' => $isPasswordCorrect ? 'Password BENAR' : 'Password SALAH'
    ]);
});

// Test 3: Manual login test
Route::post('/debug/test-login', function (Request $request) {
    $email = $request->input('email');
    $password = $request->input('password');

    $credentials = ['email' => $email, 'password' => $password];

    if ($token = auth('api')->attempt($credentials)) {
        $user = auth('api')->user();
        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'token' => $token,
            'user' => $user,
        ]);
    }

    return response()->json([
        'success' => false,
        'message' => 'Login gagal - email atau password salah',
    ], 401);
});

