# 🧪 TEST SCRIPT UNTUK WINDOWS POWERSHELL

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  TEST BACKEND CONNECTION" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# TEST 1: Check Backend Running
Write-Host "TEST 1: Cek apakah backend running..." -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://10.0.2.2:8000/api" -ErrorAction Stop
    Write-Host "✅ Backend accessible" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ Backend tidak accessible!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Solusi: Jalankan di terminal backend:" -ForegroundColor Yellow
    Write-Host "  php artisan serve --host=0.0.0.0 --port=8000" -ForegroundColor White
    Write-Host ""
    exit 1
}

# TEST 2: Test Login Endpoint
Write-Host "TEST 2: Test login endpoint..." -ForegroundColor Yellow

$loginBody = @{
    email = "dimashendripamungkas45@gmail.com"
    password = "password123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "http://10.0.2.2:8000/api/login" `
        -Method POST `
        -Headers @{"Content-Type" = "application/json"} `
        -Body $loginBody `
        -ErrorAction Stop

    $loginData = $loginResponse.Content | ConvertFrom-Json

    if ($loginData.token) {
        Write-Host "✅ Login berhasil! Token diterima" -ForegroundColor Green
        Write-Host "Token: $($loginData.token.Substring(0, 20))..." -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "⚠️ Login response tidak ada token" -ForegroundColor Yellow
        Write-Host "Response: $($loginResponse.Content)" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host "❌ Login gagal!" -ForegroundColor Red
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Response: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
    Write-Host ""
    Write-Host "Kemungkinan penyebab:" -ForegroundColor Yellow
    Write-Host "  1. User tidak ada atau password salah" -ForegroundColor White
    Write-Host "  2. Routes API tidak terdaftar" -ForegroundColor White
    Write-Host "  3. Backend error" -ForegroundColor White
    Write-Host ""
}

# TEST 3: Check User di Database
Write-Host "TEST 3: Check user di database..." -ForegroundColor Yellow

try {
    $userCheck = mysql -u root bookingappdb -e "SELECT id, email, name FROM users WHERE email = 'dimashendripamungkas45@gmail.com';" 2>&1

    if ($userCheck -like "*dimashendripamungkas45*") {
        Write-Host "✅ User ada di database" -ForegroundColor Green
        Write-Host "$userCheck" -ForegroundColor White
        Write-Host ""
    } else {
        Write-Host "❌ User tidak ditemukan di database" -ForegroundColor Red
        Write-Host ""
        Write-Host "Solusi: Buat user baru dengan tinker:" -ForegroundColor Yellow
        Write-Host "  php artisan tinker" -ForegroundColor White
        Write-Host ""
    }
} catch {
    Write-Host "⚠️ Database check error: $($_.Exception.Message)" -ForegroundColor Yellow
}

# SUMMARY
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  SUMMARY" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Jika semua test ✅:" -ForegroundColor Green
Write-Host "  1. Backend sudah siap" -ForegroundColor White
Write-Host "  2. Database sudah siap" -ForegroundColor White
Write-Host "  3. User sudah ada" -ForegroundColor White
Write-Host "  4. Coba login di Flutter app" -ForegroundColor White
Write-Host ""
Write-Host "Jika ada ❌:" -ForegroundColor Red
Write-Host "  Lihat error message di atas dan ikuti solusinya" -ForegroundColor White
Write-Host ""

