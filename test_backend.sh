#!/bin/bash

# 🧪 TEST SCRIPT UNTUK VERIFY SETUP

echo "================================================"
echo "  TEST KONEKSI BACKEND - LARAVEL API"
echo "================================================"
echo ""

# TEST 1: Check if backend is running
echo "❓ TEST 1: Checking if backend is running..."
echo "Command: curl http://10.0.2.2:8000/api"
echo ""

response=$(curl -s http://10.0.2.2:8000/api 2>&1)

if [[ $response == *"error"* ]] || [[ $response == *"404"* ]]; then
    echo "❌ ERROR: Backend tidak running atau tidak bisa diakses!"
    echo "Response: $response"
    echo ""
    echo "💡 Solusi: Pastikan backend sudah dijalankan dengan:"
    echo "   cd C:\laravel-project\sj-order-api"
    echo "   php artisan serve --host=0.0.0.0 --port=8000"
    echo ""
    exit 1
else
    echo "✅ Backend accessible"
    echo ""
fi

# TEST 2: Test login endpoint
echo "❓ TEST 2: Testing login endpoint..."
echo "Command: curl -X POST http://10.0.2.2:8000/api/login"
echo ""

login_response=$(curl -s -X POST http://10.0.2.2:8000/api/login \
  -H "Content-Type: application/json" \
  -d '{"email":"dimashendripamungkas45@gmail.com","password":"password123"}')

echo "Response: $login_response"
echo ""

if [[ $login_response == *"token"* ]]; then
    echo "✅ Login berhasil! Token diterima"
    echo ""
elif [[ $login_response == *"success"* ]]; then
    echo "✅ Login endpoint accessible"
    echo ""
else
    echo "❌ Login gagal. Kemungkinan:"
    echo "   1. User tidak ada di database"
    echo "   2. Password salah"
    echo "   3. Routes tidak terdaftar"
    echo ""
    echo "💡 Solusi: Jalankan di terminal:"
    echo "   php artisan tinker"
    echo "   kemudian buat user baru dengan password yang benar"
    echo ""
fi

# TEST 3: Check database
echo "❓ TEST 3: Checking database..."
echo "Command: mysql -u root bookingappdb -e 'SELECT COUNT(*) as user_count FROM users;'"
echo ""

user_count=$(mysql -u root bookingappdb -e "SELECT COUNT(*) as user_count FROM users;" 2>&1 | tail -1)

if [[ $user_count == *"[0-9]"* ]]; then
    echo "✅ Database connected. Users: $user_count"
    echo ""
else
    echo "❌ Database tidak accessible"
    echo "Response: $user_count"
    echo ""
fi

# SUMMARY
echo "================================================"
echo "  SUMMARY"
echo "================================================"
echo ""
echo "✅ Semua test selesai!"
echo ""
echo "Jika semua ✅, maka:"
echo "1. Backend sudah running dengan benar"
echo "2. Database sudah connect"
echo "3. User sudah ada"
echo ""
echo "Sekarang coba login di Flutter app!"
echo ""

