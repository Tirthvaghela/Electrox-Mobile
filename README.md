# Electrox — Digital Voting System

A full-stack mobile voting platform built with **Flutter** (Android) and a **Node.js/Express** backend, backed by **MongoDB**. Supports multi-organization elections with role-based access for admins, organizers, candidates, and voters.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile App | Flutter (Dart) |
| Backend API | Node.js + Express |
| Database | MongoDB (Mongoose) |
| Auth | JWT |
| Email | Nodemailer (Gmail SMTP) |
| Tunneling (dev) | ngrok |
| State Management | Provider |
| Notifications | flutter_local_notifications |

---

## Project Structure

```
electrox_flutter/
├── lib/
│   ├── config/          # Theme, constants, dotenv
│   ├── models/          # Dart data models
│   ├── providers/       # Auth state (Provider)
│   ├── screens/
│   │   ├── admin/       # Admin dashboard, users, orgs, audit logs
│   │   ├── auth/        # Login, setup account
│   │   ├── candidate/   # Dashboard, election results
│   │   ├── organizer/   # Dashboard, create/edit/view elections
│   │   └── voter/       # Dashboard, voting screen
│   ├── services/        # API, auth, election, notification, storage
│   └── widgets/         # Reusable UI components
├── backend/
│   ├── models/          # Mongoose schemas
│   ├── routes/          # Express route handlers
│   ├── services/        # Election scheduler (cron)
│   ├── utils/           # Email sender, audit logger, CSV handler
│   ├── scripts/         # Dev tooling (ngrok sync, admin create)
│   └── server.js        # Entry point
├── android/             # Android native config
├── .env                 # Flutter dotenv (SERVER_HOST)
└── pubspec.yaml
```

---

## Roles

| Role | Capabilities |
|---|---|
| **Admin** | Manage organizations, users, view audit logs, system stats |
| **Organizer** | Create/edit elections, manage candidates & voters, view results |
| **Candidate** | View assigned elections, see live/final results, export PDF |
| **Voter** | View elections, cast votes, receive notifications |

---

## Features

- JWT authentication with secure token storage
- Invitation-based account setup via email deep link (`electrox://app/setup-account`)
- Election lifecycle: scheduled auto-start and auto-close via cron jobs
- Live vote count polling (30s interval) during active elections
- Push-style local notifications for election events
- PDF result export (share sheet)
- Paginated user and organization management
- Offline connectivity banner
- Audit logging for all key actions
- CSV bulk import for voters/candidates
- Pull-to-refresh on all dashboards
- Dark navy theme (`#14213D`) with orange accent (`#FCA311`)

---

## Prerequisites

- Flutter SDK `^3.10.4`
- Node.js `>=18`
- MongoDB (local or Atlas)
- Gmail account with App Password enabled
- [ngrok](https://ngrok.com) for mobile device testing

---

## Setup

### 1. Clone & install

```bash
git clone <repo-url>
cd electrox_flutter
flutter pub get
cd backend && npm install
```

### 2. Backend environment

Copy `.env.example` and fill in your values:

```bash
cp backend/.env.example backend/.env
```

```env
PORT=5000
NODE_ENV=development
MONGODB_URI=mongodb://localhost:27017/electrox_db_f
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=24h
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-gmail-app-password
ADMIN_EMAIL=admin@electrox.com
SERVER_HOST=https://your-ngrok-url.ngrok-free.app
```

### 3. Flutter environment

Create `.env` in the project root:

```env
SERVER_HOST=https://your-ngrok-url.ngrok-free.app
```

### 4. Create the first admin

```bash
cd backend
node scripts/createAdmin.js
```

---

## Running (Development)

### Terminal 1 — Start ngrok

```bash
ngrok http 5000
```

Copy the `https://` forwarding URL.

### Terminal 2 — Start backend (auto-syncs ngrok URL to .env)

```bash
cd backend
npm run start-dev
```

This runs `scripts/startDev.js` which reads the active ngrok tunnel, writes `SERVER_HOST` to `backend/.env` and the root `.env`, then starts the server.

### Terminal 3 — Run Flutter app

```bash
flutter run
```

---

## API Overview

Base URL: `http://localhost:5000/api` (or your ngrok URL)

| Route | Description |
|---|---|
| `POST /auth/login` | Login, returns JWT |
| `POST /auth/setup-account` | Complete account setup from invitation |
| `GET /auth/setup-account?token=` | Deep link redirect page |
| `GET /auth/app-redirect?path=` | Credential email app redirect |
| `GET /election/voter-elections` | Elections for a voter |
| `GET /election/organizer-elections` | Elections for an organizer |
| `POST /election` | Create election |
| `PUT /election/:id` | Edit election |
| `POST /election/:id/vote` | Cast vote |
| `GET /election/:id/results` | Get results |
| `GET /notification/my-notifications` | User notifications |
| `GET /notification/unread-count` | Unread count |
| `GET /admin/stats` | System stats (admin only) |
| `GET /admin/users` | All users (paginated) |
| `GET /admin/organizations` | All organizations (paginated) |
| `GET /admin/audit-logs` | Audit log entries |
| `POST /organization` | Create organization + send invite |
| `POST /bulk/import` | CSV bulk import voters/candidates |

---

## Deep Links

The app handles `electrox://app/*` deep links:

| Link | Action |
|---|---|
| `electrox://app/setup-account?token=<token>` | Opens account setup screen |
| `electrox://app/login` | Opens login screen |

---

## Scripts

| Script | Command | Description |
|---|---|---|
| Start dev server | `npm run start-dev` | Syncs ngrok + starts server |
| Sync env only | `npm run sync-env` | Writes ngrok URL to .env files |
| Create admin | `node scripts/createAdmin.js` | Seeds first admin user |
| Reset admin | `node scripts/resetAdmin.js` | Resets admin password |
| Generate app icons | `flutter pub run flutter_launcher_icons:main` | Regenerates Android icons |
| Generate splash | `dart run flutter_native_splash:create` | Regenerates native splash |

---

## Environment Variables Reference

| Variable | Description |
|---|---|
| `PORT` | Backend server port (default: 5000) |
| `MONGODB_URI` | MongoDB connection string |
| `JWT_SECRET` | Secret key for signing JWTs |
| `JWT_EXPIRES_IN` | Token expiry (e.g. `24h`) |
| `SMTP_HOST` | Email SMTP host |
| `SMTP_PORT` | Email SMTP port |
| `SMTP_USER` | Gmail address |
| `SMTP_PASS` | Gmail App Password |
| `ADMIN_EMAIL` | Default admin email |
| `SERVER_HOST` | Public server URL (ngrok in dev, domain in prod) |

---

## Notes

- All election dates are stored and transmitted as **UTC**, displayed in device local time
- The backend uses `app.set('trust proxy', 1)` for correct IP detection behind ngrok
- `flutter_native_splash` is configured with a transparent icon to suppress the Android 12 system splash icon
- Java 8 deprecation warnings during build come from third-party Flutter plugins and are harmless
