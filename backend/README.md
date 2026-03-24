# Electrox Backend API

Node.js + Express + MongoDB backend for the Electrox voting platform.

## Setup

1. Install dependencies:
```bash
npm install
```

2. Create `.env` file (copy from `.env.example`):
```bash
cp .env.example .env
```

3. Configure environment variables in `.env`

4. Start MongoDB (local or use MongoDB Atlas)

5. Run the server:
```bash
# Development
npm run dev

# Production
npm start
```

## API Documentation

Base URL: `http://localhost:5000/api`

### Authentication
- `POST /api/auth/login` - User login
- `POST /api/auth/setup-account` - Complete account setup

### Elections
- `POST /api/election/create` - Create election
- `GET /api/election/my-elections` - Get organizer's elections
- `POST /api/election/vote` - Cast vote
- `GET /api/election/results/:id` - Get results

### Organizations
- `POST /api/organization/create` - Create organization
- `GET /api/organization/all` - Get all organizations

### Admin
- `GET /api/admin/users` - Get all users
- `GET /api/admin/stats` - Get system statistics

See the migration guide for complete API documentation.

## Project Structure

```
backend/
├── config/          # Configuration files
├── models/          # Mongoose models
├── routes/          # API routes
├── controllers/     # Route controllers
├── middleware/      # Custom middleware
├── utils/           # Utility functions
├── services/        # Background services
└── server.js        # Entry point
```

## Testing

```bash
npm test
```

## License

MIT
