#!/usr/bin/env powershell
# Quick Timeout Diagnostic Script
# This script helps identify why the Flutter app can't connect to the backend

Write-Host "🔍 TIMEOUT CONNECTION DIAGNOSTIC TOOL" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if Laravel is running
Write-Host "TEST 1: Checking if Laravel server is running..." -ForegroundColor Yellow
$laravel = Get-Process -Name "php" -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*artisan*serve*"}

if ($laravel) {
    Write-Host "✅ Laravel is running (PID: $($laravel.Id))" -ForegroundColor Green
} else {
    Write-Host "❌ Laravel is NOT running" -ForegroundColor Red
    Write-Host "   FIX: Run 'php artisan serve' in your Laravel project" -ForegroundColor Yellow
}

Write-Host ""

# Test 2: Check if port 8000 is listening
Write-Host "TEST 2: Checking if port 8000 is listening..." -ForegroundColor Yellow
$port = netstat -ano | Select-String ":8000"

if ($port) {
    Write-Host "✅ Port 8000 is listening:" -ForegroundColor Green
    Write-Host $port -ForegroundColor Green
} else {
    Write-Host "❌ Port 8000 is NOT listening" -ForegroundColor Red
    Write-Host "   FIX: Start Laravel with 'php artisan serve'" -ForegroundColor Yellow
}

Write-Host ""

# Test 3: Check if API endpoint responds
Write-Host "TEST 3: Testing API endpoint (http://localhost:8000/api/login)..." -ForegroundColor Yellow
try {
    $timeout = 5
    $response = $null

    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"test@test.com","password":"test"}' `
        -TimeoutSec $timeout `
        -SkipHttpErrorCheck `
        -ErrorAction Stop

    Write-Host "✅ API responded with status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "   Response preview: $($response.Content.Substring(0, [Math]::Min(100, $response.Content.Length)))" -ForegroundColor Green
} catch {
    Write-Host "❌ API endpoint not responding: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   FIX: Check if Laravel server is running and accessible" -ForegroundColor Yellow
}

Write-Host ""

# Test 4: Check network connectivity (simulated for localhost)
Write-Host "TEST 4: Checking localhost connectivity..." -ForegroundColor Yellow
try {
    $test = Test-Connection -ComputerName "localhost" -Count 1 -Quiet
    if ($test) {
        Write-Host "✅ Localhost is reachable" -ForegroundColor Green
    } else {
        Write-Host "❌ Localhost is not reachable" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️  Could not test localhost: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""

# Test 5: Check if Firebase/database is accessible (optional)
Write-Host "TEST 5: Checking Laravel environment..." -ForegroundColor Yellow
$envFile = "C:\laravel-project\sj-order-api\.env"
if (Test-Path $envFile) {
    Write-Host "✅ .env file found" -ForegroundColor Green

    $appUrl = Select-String -Path $envFile -Pattern "^APP_URL" | Select-Object -First 1
    if ($appUrl) {
        Write-Host "   APP_URL: $appUrl" -ForegroundColor Green
    }

    $dbHost = Select-String -Path $envFile -Pattern "^DB_HOST" | Select-Object -First 1
    if ($dbHost) {
        Write-Host "   DB_HOST: $dbHost" -ForegroundColor Green
    }
} else {
    Write-Host "⚠️  .env file not found at $envFile" -ForegroundColor Yellow
    Write-Host "   You might need to create one" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================" -ForegroundColor Cyan
Write-Host "📋 NEXT STEPS:" -ForegroundColor Cyan
Write-Host "================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. If Laravel is NOT running:"
Write-Host "   → Open Terminal"
Write-Host "   → cd C:\laravel-project\sj-order-api" -ForegroundColor White
Write-Host "   → php artisan serve" -ForegroundColor White
Write-Host ""
Write-Host "2. If API is not responding:"
Write-Host "   → Check Laravel error logs: storage/logs/laravel.log" -ForegroundColor White
Write-Host "   → Check database connection" -ForegroundColor White
Write-Host ""
Write-Host "3. Then start Flutter app:"
Write-Host "   → flutter run" -ForegroundColor White
Write-Host ""
Write-Host "4. Check Flutter logs:"
Write-Host "   → adb logcat | grep ApiService" -ForegroundColor White
Write-Host ""

Write-Host "For detailed guide, see: TIMEOUT_CONNECTION_ERROR_FIX.md" -ForegroundColor Cyan
Write-Host ""

