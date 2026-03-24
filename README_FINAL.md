# 🗳️ Electrox - Digital Voting Platform

## 📋 Project Summary

A comprehensive, role-based digital voting platform built with:
- **Backend:** Node.js + Express + MongoDB
- **Frontend:** Flutter (Web + Mobile)
- **Features:** Multi-tenant, RBAC, real-time voting, automated notifications

---

## ✅ Current Status: ~40% Complete

### What's Working:
- ✅ Complete backend API (85% done)
- ✅ Database with all models
- ✅ Authentication system
- ✅ Login screen
- ✅ Admin dashboard (basic)
- ✅ Backend-Frontend communication

### What's Next:
- ⏳ Complete dashboard navigation
- ⏳ Organization management
- ⏳ Election creation
- ⏳ Voting interface

---

## 🚀 Quick Start

### 1. Start Backend
```bash
cd backend
npm install
npm run dev
```
Backend runs on: http://localhost:5000

### 2. Start Frontend
```bash
flutter pub get
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### 3. Login
- **Email:** admin@electrox.com
- **Password:** admin123

---

## 📁 Project Structure

```
electrox_flutter/
├── backend/                    # Node.js + Express API
│   ├── models/                # 9 MongoDB models
│   ├── routes/                # 10 API route files
│   ├── middleware/            # Auth, validation, upload
│   ├── utils/                 # CSV, email, PDF, audit
│   ├── services/              # Background jobs
│   └── server.js              # Entry point
│
├── lib/                       # Flutter application
│   ├── config/                # Theme, constants
│   ├── models/                # Data models
│   ├── services/              # API, auth, storage
│   ├── providers/             # State management
│   ├── screens/               # UI screens
│   │   ├── auth/             # Login, forgot password
│   │   └── admin/            # Admin dashboard
│   └── main.dart
│
└── Documentation/
    ├── PROJECT_SETUP.md       # Detailed setup guide
    ├── IMPLEMENTATION_STATUS.md
    ├── CURRENT_STATUS.md
    └── QUICK_FIX_LOGIN.md
```

---

## 🔑 Key Features Implemented

### Backend (85%)
- ✅ User authentication (JWT + bcrypt)
- ✅ Role-based access control
- ✅ Election management API
- ✅ Organization management API
- ✅ CSV parsing for bulk import
- ✅ Email system (Nodemailer)
- ✅ Audit logging
- ✅ Election auto-close scheduler
- ✅ Password reset flow
- ✅ Notification system
- ✅ Template system
- ✅ Bulk operations

### Frontend (20%)
- ✅ Flutter project setup
- ✅ Professional UI theme
- ✅ Login screen
- ✅ Admin dashboard (basic)
- ✅ State management (Provider)
- ✅ API integration
- ✅ Secure storage

---

## 🎯 Roles & Permissions

### Admin
- Create/manage organizations
- Manage all users
- View audit logs
- System statistics

### Organizer
- Create/manage elections
- Add candidates & voters
- View results
- Export data

### Candidate
- View assigned elections
- Track vote counts
- View results (when allowed)

### Voter
- View assigned elections
- Cast votes
- View results (when allowed)

---

## 📊 Database Collections

1. **users** - All system users
2. **elections** - Election data with votes
3. **organizations** - Multi-tenant organizations
4. **invitations** - Organization invites
5. **notifications** - User notifications
6. **election_templates** - Reusable templates
7. **audit_logs** - Activity tracking
8. **password_resets** - Password reset tokens
9. **contact_submissions** - Contact form data

---

## 🔧 Development Commands

### Backend
```bash
# Start server
npm run dev

# Create admin user
node scripts/createAdmin.js

# Test API
node test-api.js
```

### Frontend
```bash
# Install dependencies
flutter pub get

# Run on Chrome
flutter run -d chrome --web-browser-flag "--disable-web-security"

# Hot reload
Press 'r' in terminal

# Hot restart
Press 'R' in terminal

# Build for web
flutter build web --release
```

---

## 🐛 Known Issues & Solutions

### Issue: Login doesn't navigate
**Solution:** App is being updated. After Flutter finishes launching, try:
1. Login with admin credentials
2. If nothing happens, press 'R' for hot restart
3. Try login again

### Issue: CORS errors
**Solution:** Run Flutter with disabled web security:
```bash
flutter run -d chrome --web-browser-flag "--disable-web-security"
```

### Issue: Backend not responding
**Solution:** Check if MongoDB is running and restart backend:
```bash
cd backend
npm run dev
```

---

## 📝 API Endpoints

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/setup-account` - Complete account setup

### Elections
- `POST /api/election/create` - Create election
- `POST /api/election/vote` - Cast vote
- `GET /api/election/results/:id` - Get results
- `GET /api/election/my-elections` - Get organizer's elections

### Organizations
- `POST /api/organization/create` - Create organization
- `GET /api/organization/all` - Get all organizations

### Admin
- `GET /api/admin/users` - Get all users
- `GET /api/admin/stats` - Get system statistics
- `GET /api/admin/audit-logs` - Get audit logs

See migration guide for complete API documentation.

---

## 🚀 Deployment

### Backend
- **Recommended:** Heroku, DigitalOcean, AWS EC2
- **Database:** MongoDB Atlas (free tier available)

### Frontend
- **Web:** Vercel, Netlify
- **Mobile:** Build APK/IPA for app stores

---

## 📚 Documentation

- **Setup Guide:** PROJECT_SETUP.md
- **Migration Guide:** Original specification document
- **Implementation Status:** IMPLEMENTATION_STATUS.md
- **Current Status:** CURRENT_STATUS.md
- **Login Fix:** QUICK_FIX_LOGIN.md

---

## 🎯 Next Development Steps

### Phase 1 (Current)
1. ✅ Fix login navigation
2. ⏳ Test admin dashboard
3. ⏳ Add organization creation
4. ⏳ Add user management

### Phase 2
1. Build organizer dashboard
2. Create election creation flow
3. Implement CSV upload UI
4. Add election list view

### Phase 3
1. Build voter dashboard
2. Implement voting interface
3. Build candidate dashboard
4. Add results viewing

### Phase 4
1. Add notifications UI
2. Implement templates
3. Add analytics
4. Testing & deployment

---

## 💡 Tips

1. **Hot Reload:** Press 'r' in Flutter terminal for quick updates
2. **Hot Restart:** Press 'R' for full app restart
3. **Backend Logs:** Watch terminal for API requests
4. **DevTools:** Available at the URL shown in Flutter terminal
5. **Database:** Use MongoDB Compass to view data

---

## 📞 Support

### Check Status
```bash
# Backend
curl http://localhost:5000/health

# Database
mongosh
use electrox_db_f
db.users.find()
```

### Common Issues
1. **Port in use:** Change PORT in backend/.env
2. **MongoDB not running:** Start MongoDB service
3. **Flutter errors:** Run `flutter clean && flutter pub get`

---

## ✨ Features to Come

- [ ] Real-time results with WebSockets
- [ ] Push notifications
- [ ] QR code voting
- [ ] Biometric authentication
- [ ] Advanced analytics
- [ ] Multi-language support
- [ ] Offline voting
- [ ] Blockchain integration

---

## 📄 License

MIT License

---

**Built with ❤️ using Flutter & Node.js**

**Last Updated:** January 2025
**Version:** 1.0.0-alpha
**Status:** 🚧 In Development (40% complete)
