#!/bin/bash
# Clear app data dan restart emulator

echo "🧹 Clearing app data..."
adb shell pm clear com.example.sj_order_app

echo "📱 Restarting emulator..."
adb shell am start -n com.example.sj_order_app/.MainActivity

echo "✅ Done! App restarted with clean data"
echo ""
echo "📋 Next steps:"
echo "1. Login dengan email: dimashendripamungkas45@gmail.com"
echo "2. Password: password123"
echo "3. Observe console output untuk token saved message"
echo "4. Dashboard harusnya muncul dengan nama user"

