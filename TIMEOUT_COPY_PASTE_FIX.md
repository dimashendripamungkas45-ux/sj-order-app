# ⚡ COPY-PASTE SOLUTION - TIMEOUT ERROR

## 🎯 FASTEST WAY TO FIX

Just copy-paste these commands in order. No thinking needed.

---

## 📋 STEP 1: Find Your Laravel Project

Look for a folder with these files/folders:
```
artisan
app/
config/
database/
routes/
storage/
.env
```

**Common locations:**
- `C:\laravel-project\sj-order-api`
- `C:\Users\YourName\Documents\Laravel\sj-order-api`
- `C:\xampp\htdocs\sj-order-api`

Once you find it, note the path.

---

## 🚀 STEP 2: OPEN TERMINAL 1 - START BACKEND

**Windows PowerShell or Command Prompt:**

```powershell
# Replace with your actual Laravel path
cd C:\laravel-project\sj-order-api

# Start the server
php artisan serve
```

**You should see:**
```
Laravel development server started: http://127.0.0.1:8000
[2024-04-10 14:32:15] Local:   http://127.0.0.1:8000

Press Ctrl+C to quit
```

✅ **LEAVE THIS TERMINAL OPEN!** DO NOT CLOSE IT!

---

## ✅ STEP 3: OPEN TERMINAL 2 - TEST BACKEND

**Open NEW PowerShell or Command Prompt window**

**Test if API is responding:**

```powershell
# For PowerShell:
$response = Invoke-WebRequest -Uri "http://localhost:8000/api/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"test@test.com","password":"test"}' `
    -SkipHttpErrorCheck

$response.StatusCode
$response.Content
```

**OR using curl (if you have it):**
```powershell
curl http://localhost:8000/api/login -X POST `
  -H "Content-Type: application/json" `
  -d '{"email":"test@test.com","password":"test"}'
```

**Expected output (JSON):**
```json
{"message":"The provided credentials are incorrect."}
```

**Or:**
```json
{"success":true,"message":"Login successful","token":"..."}
```

✅ **If you see JSON = Backend working!**

❌ **If you see timeout = Check Terminal 1 for errors**

---

## 🎮 STEP 4: OPEN TERMINAL 3 - RUN FLUTTER

**Open THIRD PowerShell or Command Prompt window**

**Keep both Terminal 1 and 2 open!**

Navigate to Flutter project:
```powershell
cd C:\Users\dimas\AndroidStudioProjects\sj_order_app
```

Run Flutter:
```bash
flutter run
```

**Wait for app to load on emulator...**

✅ **App should load**

**Now login with test credentials**

---

## 📝 TEST CREDENTIALS

Use these to test (or whatever credentials are in your database):

```
Email:    mirzawargajakarta@gmail.com
          or admin@test.com
          or any user in database
          
Password: password
          or check your database
```

---

## 🆘 TROUBLESHOOTING - COPY PASTE FIXES

### Issue 1: "php is not recognized"

**Solution:**
```powershell
# Check if PHP installed
php --version

# If not installed, download from:
# https://www.php.net/downloads
```

---

### Issue 2: "Port 8000 already in use"

**Solution:**
```powershell
# Find what's using port 8000
netstat -ano | findstr :8000

# You'll see something like:
# TCP    127.0.0.1:8000    LISTENING    12345

# Kill it (replace 12345):
taskkill /PID 12345 /F

# Then start Laravel again:
cd C:\laravel-project\sj-order-api
php artisan serve
```

---

### Issue 3: "Laravel returns error 500"

**Solution:**
```powershell
# Clear Laravel cache
cd C:\laravel-project\sj-order-api

php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan optimize:clear

# Then try again
php artisan serve
```

---

### Issue 4: "Database connection error"

**Solution:**
```powershell
# Check .env file
cd C:\laravel-project\sj-order-api

# Look for these (should match your database):
# DB_HOST=localhost
# DB_PORT=3306
# DB_DATABASE=sj_order_api
# DB_USERNAME=root
# DB_PASSWORD=

# If MySQL not running, start it
# (depends on your setup - XAMPP, Docker, etc.)

# Then migrate database
php artisan migrate

# Then start server
php artisan serve
```

---

### Issue 5: "Still getting TimeoutException on Flutter"

**Solution - Collect more info:**

```bash
# Terminal with emulator open

# Check emulator can reach host
adb shell ping 10.0.2.2

# Check with curl from emulator
adb shell curl http://10.0.2.2:8000/api/login

# Watch Flutter logs
adb logcat | grep "ApiService"
```

---

### Issue 6: ".env file not found"

**Solution:**
```powershell
cd C:\laravel-project\sj-order-api

# Copy the example
copy .env.example .env

# Generate key
php artisan key:generate

# Configure database in .env
# Then try again
php artisan serve
```

---

## 🧪 VERIFICATION TESTS

### Quick Verification (do all 3):

**Test 1: Can you reach localhost:8000?**
```powershell
curl http://localhost:8000
# Should see HTML or error, not timeout
```

**Test 2: Does API endpoint work?**
```powershell
curl http://localhost:8000/api/login -X POST `
  -H "Content-Type: application/json" `
  -d '{"email":"test@test.com","password":"test"}'
# Should see JSON, not timeout
```

**Test 3: Can emulator reach host?**
```bash
adb shell ping 10.0.2.2
# Should show response, not timeout
```

---

## 📊 CHECKLIST - DO THIS IN ORDER

```
[ ] Step 1: Find Laravel folder
    Location: ___________________________

[ ] Step 2: Terminal 1 - Start Laravel
    Command: php artisan serve
    Result: See "server started" message
    Status: ✅ Running

[ ] Step 3: Terminal 2 - Test API
    Command: curl localhost:8000/api/login ...
    Result: Got JSON response
    Status: ✅ Responding

[ ] Step 4: Terminal 3 - Run Flutter
    Command: flutter run
    Result: App loaded on emulator
    Status: ✅ Running

[ ] Try Login
    Email: [test credentials]
    Password: [test credentials]
    Result: No timeout error
    Status: ✅ Success!

[ ] Verify Dashboard
    See booking list
    No errors
    Status: ✅ All good!
```

---

## 🚀 YOU'RE DONE!

If you see the dashboard without timeout error, you're done! 🎉

**Next steps:**
1. Test other features (create booking, view bookings, etc.)
2. Test user management (if needed)
3. Deploy to production

---

## 📞 IF SOMETHING GOES WRONG

**Copy-paste and run this diagnostic:**

```powershell
# Check if Laravel is running
Write-Host "Checking Laravel..."
$process = Get-Process -Name "php" -ErrorAction SilentlyContinue | Where-Object {$_.CommandLine -like "*serve*"}
if ($process) {
    Write-Host "✅ Laravel is running (PID: $($process.Id))"
} else {
    Write-Host "❌ Laravel is NOT running - Start it with: php artisan serve"
}

Write-Host ""
Write-Host "Checking port 8000..."
$port = netstat -ano | Select-String ":8000"
if ($port) {
    Write-Host "✅ Port 8000 is listening:"
    Write-Host $port
} else {
    Write-Host "❌ Port 8000 is NOT listening"
}

Write-Host ""
Write-Host "Checking API..."
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8000/api/login" `
        -Method POST `
        -ContentType "application/json" `
        -Body '{"email":"test@test.com","password":"test"}' `
        -TimeoutSec 5 `
        -SkipHttpErrorCheck
    
    Write-Host "✅ API responded: $($response.StatusCode)"
} catch {
    Write-Host "❌ API error: $($_.Exception.Message)"
}
```

**Share the output with your team for help.**

---

## 🎓 WHY THIS WORKS

```
1. Terminal 1: Backend must be running
   → Otherwise, emulator can't connect
   → Results in timeout
   
2. Terminal 2: Verify backend works
   → Test from your computer first
   → Makes sure it's not emulator issue
   
3. Terminal 3: Run Flutter
   → With backend running
   → Emulator can reach it via 10.0.2.2
   → Login works! ✅
```

---

**Time to fix: 5 minutes**
**Difficulty: Very Easy**
**Success: 99%**

**Last updated: 2024**

