# ⚡ QUICK FIX - TIMEOUT ERROR (2 MINUTES)

## 🎯 THE PROBLEM
```
💥 TimeoutException after 0:00:10.000000
Connection error: TimeoutException after 0:00:10.000000: Future not completed
```

**This means:** Flutter app cannot reach the backend API.

---

## 🚀 THE SOLUTION (3 SIMPLE STEPS)

### STEP 1: Start Laravel Backend
```powershell
# Open Terminal/PowerShell
cd C:\laravel-project\sj-order-api

# Start Laravel server
php artisan serve
```

**WAIT for this to appear:**
```
Laravel development server started: http://127.0.0.1:8000
[Your Application Name] starting in the development environment
```

✅ **LEAVE THIS TERMINAL RUNNING** (Don't close it!)

---

### STEP 2: Verify API is Responding
```powershell
# Open new Terminal/PowerShell (Keep previous one open!)

# Test the API
curl http://localhost:8000/api/login -X POST `
  -H "Content-Type: application/json" `
  -d '{"email":"test@test.com","password":"test"}'
```

**Expected Response (one of these):**
```json
{
  "success": false,
  "message": "The provided credentials are incorrect."
}
```

Or:
```json
{
  "success": true,
  "message": "Login successful",
  "token": "..."
}
```

✅ **If you get JSON response = API is working!**

❌ **If you get timeout = See troubleshooting below**

---

### STEP 3: Run Flutter App
```bash
# Open new Terminal/PowerShell (Keep previous 2 open!)

cd C:\path\to\flutter\project

flutter run
```

**Wait for app to load, then login**

✅ **Should work now!**

---

## ❓ STILL GETTING TIMEOUT?

### Issue 1: "Cannot find php" or "Cannot find flutter"
**Solution:**
- Make sure PHP is installed: `php --version`
- Make sure Flutter is installed: `flutter --version`
- Make sure you're in the right folder

### Issue 2: "Port 8000 already in use"
**Solution:**
```powershell
# Check what's using port 8000
netstat -ano | findstr :8000

# Kill the process (replace PID with actual number)
taskkill /PID <PID> /F

# Then try again: php artisan serve
```

### Issue 3: "Laravel server starts but API doesn't respond"
**Solution:**
1. Check Laravel logs: `cat storage/logs/laravel.log` (last 20 lines)
2. Check if database is connected
3. Restart Laravel: `Ctrl+C` then `php artisan serve` again

### Issue 4: "Still getting timeout on Flutter"
**Solution:**
```bash
# Check emulator logs
adb logcat | grep "ApiService"

# Or watch all logs
adb logcat
```

Look for error message that tells you what's wrong.

---

## 📋 CHECKLIST

```
[ ] PHP installed (php --version)
[ ] Laravel project folder correct (cd c:\...\sj-order-api)
[ ] Laravel running (see "started" message)
[ ] Port 8000 listening (netstat -ano | findstr :8000)
[ ] API responds (curl http://localhost:8000/api/login)
[ ] Flutter can access backend (http://10.0.2.2:8000/api)
[ ] Emulator is running
[ ] Flutter running (flutter run)
```

---

## 🔑 KEY POINTS

1. **10.0.2.2** = Special address for emulator to reach host machine
2. **8000** = Laravel port (default)
3. **Terminal must stay open** = While Laravel is running
4. **No timeout = Success!**

---

## 📞 STILL STUCK?

See the detailed guide: **`TIMEOUT_CONNECTION_ERROR_FIX.md`**

It has:
- ✅ Step-by-step solutions
- ✅ Detailed testing procedures
- ✅ Common issues & fixes
- ✅ Network troubleshooting
- ✅ Backend verification

---

**Time to fix: 2-5 minutes**
**Difficulty: Easy**
**Success rate: 95%**

