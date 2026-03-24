# Electrox - Complete Setup Guide

## 🎯 Project Overview

Electrox is a comprehensive digital voting platform with:
- **Backend**: Node.js + Express + MongoDB
- **Frontend**: Flutter (Web + Mobile)
- **Features**: Multi-tenant, role-based access, real-time voting, automated notifications

---

## 📁 Project Structure

```
electrox_flutter/
├── backend/                 # Node.js + Express API
│   ├── config/             # Database, email, constants
│   ├── models/             # Mongoose schemas
│   ├── routes/             # API endpoints
│   ├── middleware/         # Auth, validation, upload
│   ├── utils/              # CSV, email, PDF, audit
│   ├── services/           # Background jobs
│   ├── server.js           # Entry point
│   └── package.json
│
├── lib/                    # Flutter application
│   ├── config/             # Theme, constants, routes
│   ├── models/             # Data models
│   ├── services/           # API, auth, storage
│   ├── providers/          # State management
│   ├── screens/            # UI screens
│   ├── widgets/            # Reusable components
│   └── main.dart
│
└── pubspec.yaml            # Flutter dependencies
```

---

## 🚀 Backend Setup

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

Create `.env` file:

```bash
cp .env.example .env
```

Edit `.env` with your configuration:

```env
# Server
PORT=5000
NODE_ENV=development

# Database
MONGODB_URI=mongodb://localhost:27017/electrox_db_f

# JWT
JWT_SECRET=your-secret-key-here
JWT_EXPIRES_IN=24h

# Email (Gmail)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password

# Frontend
FRONTEND_URL=http://localhost:5173
```

### 3. Setup MongoDB

**Option A: Local MongoDB**
```bash
# Install MongoDB
# Windows: Download from mongodb.com
# Mac: brew install mongodb-community
# Linux: sudo apt-get install mongodb

# Start MongoDB
mongod
```

**Option B: MongoDB Atlas (Cloud)**
1. Create account at mongodb.com/cloud/atlas
2. Create cluster (free tier available)
3. Get connection string
4. Update MONGODB_URI in .env

### 4. Start Backend Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

Server will run on: http://localhost:5000

### 5. Test API

```bash
# Health check
curl http://localhost:5000/health
```

---

## 📱 Flutter Setup

### 1. Install Flutter

Download from: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter doctor
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Update API URL

Edit `lib/config/constants.dart`:

```dart
static const String baseUrl = 'http://localhost:5000/api';
// For Android emulator: 'http://10.0.2.2:5000/api'
// For iOS simulator: 'http://localhost:5000/api'
// For physical device: 'http://YOUR_IP:5000/api'
```

### 4. Run Flutter App

```bash
# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS (Mac only)
flutter run -d ios

# Windows
flutter run -d windows
```

---

## 🔑 Initial Setup & Testing

### 1. Create Admin User (MongoDB)

```javascript
// Connect to MongoDB
mongosh

// Use electrox_db_f database
use electrox_db_f

// Create admin user
db.users.insertOne({
  email: "admin@electrox.com",
  password: "$2b$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyVBq/ybg76i", // password: admin123
  name: "System Admin",
  role: "admin",
  is_active: true,
  created_at: new Date(),
  updated_at: new Date()
})
```

### 2. Login as Admin

1. Open Flutter app
2. Login with:
   - Email: admin@electrox.com
   - Password: admin123

### 3. Create Organization

Use API or admin dashboard to create organization:

```bash
curl -X POST http://localhost:5000/api/organization/create \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{
    "name": "Test University",
    "type": "university",
    "organizer_name": "John Doe",
    "organizer_email": "organizer@test.com",
    "created_by": "admin@electrox.com"
  }'
```

---

## 📧 Email Configuration (Gmail)

### 1. Enable 2-Factor Authentication

1. Go to Google Account settings
2. Enable 2-Factor Authentication

### 2. Generate App Password

1. Go to: https://myaccount.google.com/apppasswords
2. Select "Mail" and "Other"
3. Generate password
4. Copy password to .env file (SMTP_PASS)

### 3. Test Email

```bash
# Send test email via API
curl -X POST http://localhost:5000/api/contact/submit \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "email": "test@example.com",
    "message": "Test message"
  }'
```

---

## 🧪 Testing

### Backend Tests

```bash
cd backend
npm test
```

### Flutter Tests

```bash
flutter test
```

---

## 📊 Database Indexes

Indexes are automatically created by Mongoose schemas. To verify:

```javascript
// Connect to MongoDB
mongosh

use electrox_db_f

// Check indexes
db.users.getIndexes()
db.elections.getIndexes()
db.organizations.getIndexes()
```

---

## 🔧 Common Issues & Solutions

### Issue: MongoDB Connection Failed

**Solution:**
- Check if MongoDB is running: `mongod`
- Verify MONGODB_URI in .env
- Check firewall settings

### Issue: Email Not Sending

**Solution:**
- Verify Gmail app password
- Check SMTP settings in .env
- Enable "Less secure app access" (if not using app password)

### Issue: Flutter Build Failed

**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: CORS Error

**Solution:**
- Update FRONTEND_URL in backend .env
- Check CORS configuration in server.js

### Issue: Token Expired

**Solution:**
- Logout and login again
- Check JWT_EXPIRES_IN in .env

---

## 🚀 Deployment

### Backend Deployment (Heroku)

```bash
# Install Heroku CLI
heroku login

# Create app
heroku create electrox-api

# Set environment variables
heroku config:set MONGODB_URI=your_mongodb_atlas_uri
heroku config:set JWT_SECRET=your_secret
heroku config:set SMTP_USER=your_email
heroku config:set SMTP_PASS=your_password

# Deploy
git push heroku main
```

### Flutter Web Deployment (Vercel)

```bash
# Build for web
flutter build web --release

# Install Vercel CLI
npm install -g vercel

# Deploy
cd build/web
vercel --prod
```

### Flutter Mobile (Android)

```bash
# Build APK
flutter build apk --release

# Output: build/app/outputs/flutter-apk/app-release.apk
```

---

## 📚 API Documentation

### Authentication

**POST /api/auth/login**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**POST /api/auth/setup-account**
```json
{
  "token": "invitation_token",
  "name": "John Doe",
  "password": "newpassword123"
}
```

### Elections

**POST /api/election/create**
```json
{
  "title": "Student Council Election",
  "description": "Annual election",
  "organizer_email": "organizer@example.com",
  "start_date": "2025-03-01T00:00:00Z",
  "end_date": "2025-03-07T23:59:59Z",
  "result_visibility": "hidden",
  "candidates": [...],
  "voters": [...]
}
```

**POST /api/election/vote**
```json
{
  "election_id": "election_id_here",
  "voter_email": "voter@example.com",
  "candidate_email": "candidate@example.com"
}
```

See migration guide for complete API documentation.

---

## 🔐 Security Best Practices

1. **Never commit .env file**
2. **Use strong JWT_SECRET** (32+ characters)
3. **Enable HTTPS in production**
4. **Use MongoDB Atlas with IP whitelist**
5. **Implement rate limiting** (already configured)
6. **Regular security audits**: `npm audit`
7. **Keep dependencies updated**: `npm update`

---

## 📞 Support

For issues or questions:
1. Check this documentation
2. Review migration guide
3. Check API logs: `npm run dev`
4. Check Flutter logs: `flutter run -v`

---

## ✅ Next Steps

1. ✅ Backend setup complete
2. ✅ Flutter setup complete
3. ⏳ Create remaining Flutter screens (dashboards)
4. ⏳ Implement election creation flow
5. ⏳ Add voting functionality
6. ⏳ Implement results display
7. ⏳ Add notifications
8. ⏳ Testing & deployment

---

## 📝 License

MIT License - See LICENSE file for details
