# Phone Setup Guide - IMPORTANT!

## ✅ Backend is Running!
Your backend server is now running on: `http://192.168.0.102:5000`

## 🔄 Update Your App

The app needs to be reloaded with the new IP address. Here's how:

### Option 1: Hot Reload (Fastest)
If your app is still running on your phone:
1. Press `r` in the terminal where Flutter is running
2. Or press the hot reload button (⚡) in your IDE

### Option 2: Hot Restart
If hot reload doesn't work:
1. Press `R` (capital R) in the terminal
2. Or press the hot restart button (🔄) in your IDE

### Option 3: Full Restart
If the above don't work:
1. Stop the app (press `q` in terminal or stop button in IDE)
2. Run: `flutter run`

## 📱 Now Try Logging In

Use these credentials:
- **Email**: admin@electrox.com
- **Password**: admin123

## 🔥 Firewall Note

If login still doesn't work, you may need to allow the connection through Windows Firewall:

1. Open Windows Defender Firewall
2. Click "Allow an app through firewall"
3. Find "Node.js" and make sure both Private and Public are checked
4. Or temporarily disable firewall to test

## 🌐 Make Sure Both Devices Are on Same Network

Your phone and computer must be on the same WiFi network:
- Computer IP: 192.168.0.102
- Phone: Should be on same 192.168.0.x network

To check on your phone:
1. Go to WiFi settings
2. Tap on connected network
3. Check IP address (should be 192.168.0.xxx)

## 🐛 Troubleshooting

### "Connection refused" or "Network error"
1. Check if backend is running: Look for "Server running on port 5000" message
2. Check firewall settings
3. Make sure both devices are on same WiFi

### "Invalid credentials"
1. Backend is working! ✅
2. Check if you're using correct email/password
3. Try creating a new admin user (see below)

### Create Fresh Admin User
If you need to create a new admin:
```bash
cd backend
node scripts/createAdmin.js
```

## 📊 Backend Status

✅ MongoDB: Running
✅ Backend Server: Running on port 5000
✅ IP Address: 192.168.0.102
✅ Admin Account: admin@electrox.com / admin123

## 🎯 Next Steps

1. Hot reload your app (press `r`)
2. Try logging in with admin@electrox.com / admin123
3. If it works, you're all set! 🎉
4. If not, check firewall and network settings above
