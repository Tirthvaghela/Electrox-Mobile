# Quick Fix for Login Issue

## Problem
Flutter web app cannot connect to the backend API due to network/CORS issues.

## Solution Options

### Option 1: Use Chrome with Disabled Security (Quick Test)
```bash
# Close all Chrome instances first
# Then run Flutter with:
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Option 2: Run Backend on Different Port
The issue might be port conflict. Try:

1. Stop current backend
2. Change PORT in backend/.env to 5001
3. Update lib/config/constants.dart baseUrl to 'http://localhost:5001/api'
4. Restart backend and Flutter app

### Option 3: Use Proxy (Recommended for Development)

Add to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/
```

Create `web/index.html` proxy configuration or use a proxy server.

### Option 4: Test Backend Directly

Open `backend/test-cors.html` in browser:
```bash
# Navigate to:
file:///C:/Users/Tirth/AndroidStudioProjects/electrox_flutter/backend/test-cors.html

# Click "Test Login" button
# If this works, backend is fine and issue is Flutter-specific
```

## Current Status

- ✅ Backend running on port 5000
- ✅ MongoDB connected
- ✅ Admin user exists
- ✅ API tested with Node.js (works)
- ❌ Flutter web cannot connect

## Immediate Action

Try running Flutter with disabled web security:

```bash
# Stop current Flutter app (press 'q' in terminal or Ctrl+C)
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

This will allow the app to make cross-origin requests during development.

## Alternative: Test with Postman/Thunder Client

1. Open Postman or VS Code Thunder Client
2. POST to http://localhost:5000/api/auth/login
3. Body (JSON):
```json
{
  "email": "admin@electrox.com",
  "password": "admin123"
}
```
4. Should return token and user info

## Long-term Solution

For production, you'll need:
1. Deploy backend and frontend to same domain
2. Or configure proper CORS with specific origins
3. Or use a reverse proxy (nginx)
