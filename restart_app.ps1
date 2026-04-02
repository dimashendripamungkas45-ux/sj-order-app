# PowerShell script untuk clear app data dan restart
# Jalankan di Windows PowerShell dengan 'Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser' jika perlu

Write-Host "🧹 Clearing app data..." -ForegroundColor Yellow
adb shell pm clear com.example.sj_order_app

Write-Host ""
Write-Host "📱 Restarting app..." -ForegroundColor Yellow
adb shell am start -n com.example.sj_order_app/.MainActivity

Write-Host ""
Write-Host "✅ Done! App restarted with clean data" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "1. Login dengan email: dimashendripamungkas45@gmail.com"
Write-Host "2. Password: password123"
Write-Host "3. Observe console output untuk 'Token saved' message"
Write-Host "4. Dashboard harusnya muncul dengan nama user"
Write-Host ""
Write-Host "🔍 Untuk lihat debug logs:" -ForegroundColor Cyan
Write-Host "   adb logcat | Select-String 'ApiService|UserProvider|AuthService|Dashboard'"

