# 🔧 TIMEOUT CONNECTION ERROR - COMPLETE TROUBLESHOOTING GUIDE

## ❌ ERROR ANALYSIS
```
💥 TimeoutException after 0:00:10.000000: Future not completed
🔌 Connection error: TimeoutException after 0:00:10.000000: Future not completed
```

**What this means:** Flutter app is trying to connect to backend API but not getting response within 10 seconds.

---

## 🔍 ROOT CAUSES (In order of likelihood)

### 1. **BACKEND SERVER NOT RUNNING** ⚠️ MOST COMMON
- Laravel server (`php artisan serve`) is not running
- Backend is not accessible at `http://10.0.2.2:8000`

### 2. **WRONG BACKEND URL**
- API endpoint mismatch
- Network connectivity issue
- Firewall blocking connections

### 3. **SLOW BACKEND RESPONSE**
- Database queries too slow
- Backend processing taking >10 seconds
- Memory/CPU issues

### 4. **EMULATOR NETWORK CONFIGURATION**
- Emulator can't reach host machine
- Network settings issue

---

## ✅ SOLUTION STEPS (FOLLOW IN ORDER)

### STEP 1: VERIFY BACKEND IS RUNNING

#### On Windows PowerShell:

**Check if Laravel is running:**
```powershell
# In a terminal, navigate to your Laravel project
cd C:\path\to\your\laravel\project

# Check if port 8000 is in use
netstat -ano | findstr :8000
```

**If nothing shows up = Laravel NOT running**

**Start Laravel Server:**
```powershell
cd C:\path\to\your\laravel\project
php artisan serve
```

**Expected output:**
```
Laravel development server started: http://127.0.0.1:8000
```

✅ **Leave this terminal window running** (don't close it!)

---

### STEP 2: VERIFY BACKEND IS RESPONDING

**Test from your machine (not emulator yet):**

```powershell
# Test with curl or PowerShell
$response = Invoke-WebRequest -Uri "http://localhost:8000/api/login" -Method POST `
    -ContentType "application/json" `
    -Body '{"email":"test@test.com","password":"password"}'

$response.StatusCode
$response.Content
```

**Expected:** Status 200 or 422 (not timeout)

---

### STEP 3: VERIFY EMULATOR CAN REACH BACKEND

**From Android Emulator Terminal:**

```bash
# Open emulator terminal (Android Studio → Emulator → ...)
# Or use:
adb shell

# Test connectivity
ping 10.0.2.2
# Should respond with "PONG" or similar
```

**If ping fails = Network issue**

---

### STEP 4: CHECK FLUTTER API CONFIGURATION

**File:** `lib/services/api_service.dart`

**Current setting:**
```dart
static const String baseUrl = 'http://10.0.2.2:8000/api';
```

**This is CORRECT for Android Emulator:**
- `10.0.2.2` = Host machine IP (from emulator's perspective)
- `8000` = Laravel port
- `/api` = API prefix

✅ **Don't change this** (it's already correct)

---

### STEP 5: INCREASE TIMEOUT (TEMPORARY FIX)

If backend is slow, increase timeout:

**File:** `lib/services/api_service.dart`

**Current:**
```dart
.timeout(const Duration(seconds: 10));
```

**Change to (temporary):**
```dart
.timeout(const Duration(seconds: 30));
```

**Do this for ALL .timeout() calls:**
- Line ~29 (login)
- Line ~82 (register)
- Line ~145 (getBookings)
- Line ~210 (getCurrentUser)
- etc.

---

## 🚀 QUICK START - COMPLETE WORKFLOW

### Terminal 1 (Backend):
```powershell
cd C:\path\to\laravel\project
php artisan serve
```

**WAIT until you see:**
```
Laravel development server started: http://127.0.0.1:8000
```

### Terminal 2 (Test Backend):
```powershell
# Verify API is responding
curl http://localhost:8000/api/login -X POST -H "Content-Type: application/json" -d "{\"email\":\"admin@test.com\",\"password\":\"password\"}"
```

**WAIT until you get a response (not timeout)**

### Terminal 3 (Flutter):
```bash
cd C:\path\to\flutter\project
flutter run
```

**WAIT for app to load, then login**

---

## 🧪 DETAILED TESTING CHECKLIST

### ✅ Test 1: Backend Server Status
```powershell
# Should show Laravel running
netstat -ano | findstr :8000
```
**Expected:** See process PID using port 8000

---

### ✅ Test 2: API Login Endpoint
```powershell
# Test login endpoint
curl http://localhost:8000/api/login -X POST `
  -H "Content-Type: application/json" `
  -d '{"email":"mirzawargajakarta@gmail.com","password":"password"}'
```

**Expected Response (not timeout):**
```json
{
  "success": true,
  "message": "Login successful",
  "token": "...",
  "data": {...}
}
```

Or:
```json
{
  "message": "The provided credentials are incorrect."
}
```

**NOT Expected (timeout):**
```
TimeoutException...
```

---

### ✅ Test 3: Emulator Connectivity
```bash
# From emulator terminal
ping 10.0.2.2 -c 4
```

**Expected:** Response received, 0% packet loss

---

### ✅ Test 4: Flutter App Test
```
1. Run app: flutter run
2. Wait for app to load
3. Enter credentials
4. Tap login
5. Watch logcat:
```

```bash
# Open new terminal
adb logcat | grep "ApiService"
```

**Expected Logs:**
```
🔄 [ApiService.login] Starting login flow...
📤 [ApiService.login] Sending request to: http://10.0.2.2:8000/api/login
✅ [ApiService.login] Login successful
```

**Not Expected Logs:**
```
💥 [ApiService.login] Exception: TimeoutException
```

---

## 🆘 COMMON ISSUES & FIXES

### Issue 1: "Cannot reach 10.0.2.2"
**Solution:**
```bash
# Restart emulator
adb emu kill
# Or restart Android Studio emulator
```

---

### Issue 2: "Laravel server not responding"
**Solution:**
1. Check Laravel is running: `netstat -ano | findstr :8000`
2. Check for errors in Laravel terminal
3. Restart Laravel: `Ctrl+C` then `php artisan serve`

---

### Issue 3: "Port 8000 already in use"
**Solution:**
```powershell
# Find process using port 8000
netstat -ano | findstr :8000

# Kill it (replace PID with actual PID)
taskkill /PID <PID> /F

# Or use different port
php artisan serve --port=8001
# Then update API_URL in Flutter: http://10.0.2.2:8001/api
```

---

### Issue 4: "Timeout still happening after all fixes"
**Solution:**
1. Check Laravel logs: `storage/logs/laravel.log`
2. Check database connection: `php artisan tinker` → `DB::connection()->getPdo()`
3. Check network with: `ping google.com` from emulator
4. Increase timeout more: `Duration(seconds: 60)`

---

## 📋 FINAL CHECKLIST

```
[ ] Laravel server running (Terminal 1)
    Command: php artisan serve
    Port: 8000
    
[ ] API responding to tests (Terminal 2)
    Command: curl http://localhost:8000/api/login
    Response: JSON (not timeout)
    
[ ] Emulator can reach host (adb shell)
    Command: ping 10.0.2.2
    Response: PONG
    
[ ] Flutter API config correct
    File: lib/services/api_service.dart
    URL: http://10.0.2.2:8000/api
    
[ ] Timeout increased (if needed)
    File: lib/services/api_service.dart
    Duration: increased to 30s
    
[ ] Flutter app running
    Command: flutter run
    Status: App loaded, ready for login
    
[ ] Login test successful
    Credentials: Check database/readme
    Status: No timeout error
```

---

## 🎓 UNDERSTANDING THE ERROR

### Why does the error happen?

1. **Flutter sends request** → `http://10.0.2.2:8000/api/login`
2. **Emulator tries to reach backend** → `10.0.2.2:8000`
3. **If backend not responding:**
   - No response received
   - Flutter waits for 10 seconds
   - Request times out
   - Error thrown: `TimeoutException`

### Why 10.0.2.2?

- `10.0.2.2` is special address for Android Emulator
- It means "host machine" from emulator's perspective
- On real phone, use actual IP: `192.168.x.x` or `localhost`

---

## 🚀 NEXT STEPS AFTER FIX

1. ✅ Get past login screen
2. ✅ See dashboard
3. ✅ Test all API calls (bookings, users, etc.)
4. ✅ Deploy to production

---

## 📞 STILL STUCK?

**Provide these details:**
1. Laravel terminal output (last 10 lines)
2. Flutter logcat output (ApiService logs)
3. Result of: `netstat -ano | findstr :8000`
4. Result of: `curl http://localhost:8000/api/login`

---

**Last Updated:** 2024
**Status:** ✅ Ready to use

