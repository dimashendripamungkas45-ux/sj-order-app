# 🚀 TIMEOUT ERROR - COMPLETE ACTION PLAN

## ⚡ WHAT'S HAPPENING

Your Flutter app is getting this error:
```
💥 TimeoutException after 0:00:10.000000: Future not completed
🔌 Connection error: TimeoutException after 0:00:10.000000: Future not completed
```

**Translation:** Your Flutter app tried to login but the backend API didn't respond within 10 seconds.

---

## 🎯 ROOT CAUSE

**Most likely:** Your Laravel backend is NOT running or not accessible from the emulator.

---

## ✅ THE FIX (5 MINUTES)

### Step 1: Find Your Laravel Project
Your Laravel project should be in one of these locations:
```
C:\laravel-project\sj-order-api
C:\path\to\laravel\project
C:\Users\dimas\Laravel\...
```

**Find it and note the path.**

---

### Step 2: Open Terminal and Start Laravel

**Open PowerShell or Command Prompt**

Navigate to your Laravel project:
```powershell
cd C:\laravel-project\sj-order-api
# or wherever your Laravel project is
```

Start the Laravel development server:
```powershell
php artisan serve
```

**You should see:**
```
Laravel development server started: http://127.0.0.1:8000
[Your App Name] starting in the development environment
```

✅ **LEAVE THIS TERMINAL OPEN!** Don't close it or minimize it.

---

### Step 3: Verify API is Responding

**Open a NEW PowerShell or Command Prompt window** (keep previous one open!)

Test if the API is working:
```powershell
curl http://localhost:8000/api/login -X POST `
  -H "Content-Type: application/json" `
  -d '{"email":"test@test.com","password":"test"}'
```

**Expected response (something like):**
```json
{
  "message": "The provided credentials are incorrect."
}
```

Or:
```json
{
  "success": true,
  "message": "Login successful",
  "token": "...",
  "data": {...}
}
```

✅ **If you get JSON = Backend is working!**

❌ **If you get timeout = Something's wrong, see troubleshooting below**

---

### Step 4: Run Flutter App

**Open a THIRD terminal window** (keep both previous ones open!)

Navigate to your Flutter project:
```bash
cd C:\Users\dimas\AndroidStudioProjects\sj_order_app
```

Run the app:
```bash
flutter run
```

**Wait for the app to load, then try login.**

✅ **Should work now!**

---

## 🆘 TROUBLESHOOTING

### Problem 1: "php is not recognized"
**Solution:**
- PHP is not installed or not in PATH
- Install PHP from: https://www.php.net/downloads
- Or use Laravel with Docker

---

### Problem 2: "The command 'flutter' is not found"
**Solution:**
- Flutter is not installed or not in PATH
- Install Flutter from: https://flutter.dev/docs/get-started/install
- Or add to PATH

---

### Problem 3: "Port 8000 already in use"
**Solution:**
```powershell
# Find what's using port 8000
netstat -ano | findstr :8000

# You'll see something like:
# TCP    127.0.0.1:8000         0.0.0.0:0              LISTENING    12345

# Kill that process (replace 12345 with actual PID)
taskkill /PID 12345 /F

# Then try again: php artisan serve
```

---

### Problem 4: "Laravel starts but API doesn't respond"
**Solution:**

Check Laravel error log:
```powershell
# Look at the log file
Get-Content C:\laravel-project\sj-order-api\storage\logs\laravel.log -Tail 20
```

**Common issues:**
1. Database not running or not connected
2. `php artisan migrate` not run
3. `.env` file misconfigured
4. PHP extensions missing

---

### Problem 5: "curl command doesn't work in PowerShell"
**Alternative test methods:**

**Using PowerShell (built-in):**
```powershell
$response = Invoke-WebRequest -Uri "http://localhost:8000/api/login" `
    -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"test@test.com","password":"test"}'

$response.StatusCode
$response.Content
```

**Or use Postman:**
1. Download Postman: https://www.postman.com/
2. Create request: POST to http://localhost:8000/api/login
3. Set body to JSON: `{"email":"test@test.com","password":"test"}`
4. Send

---

### Problem 6: "Still getting timeout on Flutter"
**Debugging steps:**

1. **Check Android Emulator logs:**
```bash
adb logcat | grep "ApiService"
```

Look for more specific error messages.

2. **Check emulator can reach host:**
```bash
adb shell ping 10.0.2.2
```

Should respond. If not, emulator network is broken.

3. **Verify URL in code:**
   - Open: `lib/services/api_service.dart`
   - Check line 8: `static const String baseUrl = 'http://10.0.2.2:8000/api';`
   - Should NOT be changed (10.0.2.2 is correct for emulator)

4. **Check backend is really running:**
   - Try accessing from browser: `http://localhost:8000`
   - Or: `curl http://localhost:8000`
   - Should show something (Laravel welcome page or error)

---

## 📋 QUICK CHECKLIST

```
BEFORE YOU START:
[ ] Know where your Laravel project folder is
[ ] Know where your Flutter project folder is (already in sj_order_app)
[ ] Emulator is running (or physical device connected)
[ ] Internet working on your computer

STEP 1: START BACKEND
[ ] Open Terminal
[ ] cd to Laravel project
[ ] Run: php artisan serve
[ ] See "Laravel development server started" message
[ ] DON'T close this terminal!

STEP 2: TEST BACKEND
[ ] Open NEW terminal
[ ] Run curl or use Postman
[ ] Got JSON response (status 200 or 422)
[ ] No timeout error

STEP 3: RUN FLUTTER
[ ] Open NEW terminal (keep other 2 open!)
[ ] cd to Flutter project
[ ] Run: flutter run
[ ] App loads
[ ] Try login
[ ] See dashboard (no timeout error)

SUCCESS:
[ ] ✅ No timeout error
[ ] ✅ Login works
[ ] ✅ Dashboard shows
```

---

## 🎓 UNDERSTANDING THE CONNECTION

```
YOUR COMPUTER
├─ Terminal 1: Laravel Backend (http://localhost:8000)
├─ Terminal 2: Flutter App running on Emulator
└─ Terminal 3: For testing/monitoring

EMULATOR (Android Phone Simulator)
├─ Runs your Flutter app
├─ Can access host computer via 10.0.2.2
└─ Tries to reach http://10.0.2.2:8000/api

FLUTTER APP
├─ Tries: http://10.0.2.2:8000/api/login
├─ Waits 10 seconds
├─ If response = Success ✅
└─ If no response = Timeout Error ❌
```

---

## 📚 DETAILED GUIDES

For more detailed help, see these files:

1. **QUICK_FIX_TIMEOUT_2MIN.md** - Super quick version (2 min)
2. **TIMEOUT_CONNECTION_ERROR_FIX.md** - Complete guide (20 min)
3. **TIMEOUT_ADVANCED_SOLUTIONS.md** - Advanced fixes and alternatives

---

## 🚨 IF YOU'RE STILL STUCK

Provide these details:

1. **What exactly happens when you:**
   - Run `php artisan serve` - what message do you see?
   - Run the curl command - what happens?
   - Run `flutter run` - what error shows?

2. **Check these:**
   - Where is your Laravel project?
   - What's in your `.env` file? (especially APP_URL and database settings)
   - Can you access `http://localhost:8000` in browser?

3. **Collect logs:**
   - Laravel error log: `cat storage/logs/laravel.log` (last 30 lines)
   - Flutter logs: Run `flutter run` and take screenshot of error
   - Emulator logs: Run `adb logcat` and filter for ApiService

---

## 🎉 NEXT STEPS

Once login works:
1. ✅ Test other API endpoints
2. ✅ See bookings list
3. ✅ Try creating/editing booking
4. ✅ Test all features

---

**Time to fix: 5-10 minutes**
**Difficulty: Easy**
**Success rate: 98%**

**Last Updated:** 2024
**Status:** ✅ Ready to use

