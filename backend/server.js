const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const rateLimit = require('express-rate-limit');
require('dotenv').config();

const connectDB = require('./config/database');
const errorHandler = require('./middleware/errorHandler');
const { startScheduler } = require('./services/electionScheduler');

const app = express();

// Trust proxy — required when running behind ngrok or any reverse proxy
// so that express-rate-limit can correctly read the client IP
app.set('trust proxy', 1);

// Connect to MongoDB
connectDB();

// Middleware
// CORS must be before helmet
app.use(cors({
  origin: true, // Allow all origins in development
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Requested-With'],
  exposedHeaders: ['Content-Range', 'X-Content-Range']
}));

app.use(helmet({
  crossOriginEmbedderPolicy: false,
  crossOriginResourcePolicy: { policy: "cross-origin" },
  contentSecurityPolicy: false
}));

app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

// Rate limiting
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100
});
app.use('/api/', limiter);

// Routes
app.use('/api/auth', require('./routes/auth'));
app.use('/api/election', require('./routes/election'));
app.use('/api/organization', require('./routes/organization'));
app.use('/api/admin', require('./routes/admin'));
app.use('/api/user', require('./routes/user'));
app.use('/api/bulk', require('./routes/bulk'));
app.use('/api/templates', require('./routes/template'));
app.use('/api/notifications', require('./routes/notification'));
app.use('/api/password', require('./routes/password'));
app.use('/api/contact', require('./routes/contact'));

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date() });
});

// Log all unmatched routes
app.use((req, res, next) => {
  console.log(`❌ 404 - ${req.method} ${req.originalUrl}`);
  console.log('Headers:', req.headers);
  res.status(404).json({ 
    message: 'Route not found',
    path: req.originalUrl,
    method: req.method
  });
});

// Error handler
app.use(errorHandler);

// Start election scheduler
startScheduler();

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Environment: ${process.env.NODE_ENV}`);
});

module.exports = app;
