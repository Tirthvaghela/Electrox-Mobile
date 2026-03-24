# 🔐 Login Instructions

## Current Status
✅ Backend running on port 5000
✅ Flutter app running in Chrome with disabled web security
✅ Admin user created in database

## Login Credentials

**Email:** `admin@electrox.com`
**Password:** `admin123`

## Steps to Login

1. Open the Flutter app in Chrome (should be open automatically)
2. You should see the Electrox login screen
3. Enter the credentials above
4. Click "Login" button
5. If successful, you'll be redirected to the admin dashboard

## What to Expect

### On Success:
- You'll see a welcome message
- The app will navigate to the admin dashboard
- A JWT token will be stored securely

### If Login Fails:
Check the console logs:
- Backend logs (Terminal 4): Should show `POST /api/auth/login 200`
- Flutter logs (Terminal 5): Should show successful response

## Troubleshooting

### Still Getting Connection Error?
1. Make sure backend is running: Check terminal 4
2. Make sure Flutter app is running: Check terminal 5
3. Try refreshing the browser page
4. Check if Chrome opened with the security flag (you should see a warning banner)

### Backend Not Responding?
```bash
# Test backend directly
curl -X POST http://localhost:5000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"admin@electrox.com","password":"admin123"}'
```

### Need to Restart?
```bash
# Stop Flutter (press 'q' in terminal 5)
# Then restart:
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

## Next Steps After Login

Once logged in as admin, you can:
1. View system statistics
2. Create organizations
3. Manage users
4. View audit logs
5. Monitor elections

---

**Note:** The `--disable-web-security` flag is only for development. In production, proper CORS configuration will be used.
