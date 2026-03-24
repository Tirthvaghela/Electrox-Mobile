# Login Debug Guide

## ✅ Backend Status
- **Server**: Running on port 5000
- **Database**: MongoDB connected
- **Admin User**: Fresh credentials created
- **Test**: Login endpoint works perfectly ✅

## 🔑 Credentials (Confirmed Working)
- **Email**: admin@electrox.com
- **Password**: admin123

## 📱 App Configuration
- **API URL**: http://192.168.0.102:5000/api
- **Login Endpoint**: /auth/login
- **Full URL**: http://192.168.0.102:5000/api/auth/login

## 🐛 Debugging Steps

### Step 1: Check Flutter Console Logs
When you try to login, you should see logs like:
```
🚀 POST http://192.168.0.102:5000/api/auth/login
📤 Request data: {email: admin@electrox.com, password: admin123}
✅ 200 http://192.168.0.102:5000/api/auth/login
📥 Response data: {...}
```

If you DON'T see these logs, the app might not be using the updated IP address.

### Step 2: Force Rebuild
If hot reload didn't work, do a full rebuild:
```bash
flutter clean
flutter run
```

### Step 3: Check Network
Make sure:
1. Your phone and computer are on the same WiFi
2. Windows Firewall allows Node.js connections
3. Your phone can ping your computer's IP

### Step 4: Test from Phone Browser
Open your phone's browser and go to:
```
http://192.168.0.102:5000/api/auth/login
```

You should see an error (because it's a POST endpoint), but if you see "Cannot GET", that means the server is reachable!

## 🔥 Quick Fixes

### Fix 1: Restart Backend
```bash
# Stop the backend (Ctrl+C in the terminal)
# Then restart:
cd backend
npm start
```

### Fix 2: Check Firewall
```powershell
# Allow Node.js through firewall
netsh advfirewall firewall add rule name="Node.js Server" dir=in action=allow program="C:\Program Files\nodejs\node.exe" enable=yes
```

### Fix 3: Use Alternative IP
If 192.168.0.102 doesn't work, try:
- 192.168.56.1 (your other IP)
- Or find your main WiFi IP with: `ipconfig`

## 📊 What Should Happen

1. You enter email/password
2. App sends POST request to backend
3. Backend validates credentials
4. Backend returns JWT token
5. App saves token and navigates to dashboard

## 🎯 Current Status

✅ Backend is running and tested
✅ Admin user exists with correct password
✅ Login endpoint works (tested with curl)
⏳ Waiting for app to connect

## 💡 Most Likely Issue

The app might still be using the old `localhost:5000` URL. Solutions:

1. **Hot Restart** (not just reload): Press `R` (capital R) in terminal
2. **Full Rebuild**: `flutter clean && flutter run`
3. **Check constants.dart**: Verify it shows `192.168.0.102:5000`

## 📞 Next Steps

1. Try logging in again
2. Check the Flutter console for logs
3. If you see network errors, check firewall
4. If you see "invalid credentials", check backend logs
5. If nothing happens, do a full rebuild

## 🔍 Backend Logs Location

Backend logs are in the terminal where you ran `npm start`. Look for:
- `POST /api/auth/login` - means request received
- `401` - means wrong credentials
- `200` - means success!
