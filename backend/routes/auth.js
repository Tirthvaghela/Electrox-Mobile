const express = require('express');
const router = express.Router();
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const User = require('../models/User');
const Invitation = require('../models/Invitation');
const Organization = require('../models/Organization');
const { logActivity, ACTIONS } = require('../utils/auditLogger');
const { validateEmail, validatePassword } = require('../middleware/validate');

// Login
router.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    
    console.log('=== LOGIN ATTEMPT ===');
    console.log('Email received:', email);
    console.log('Password received:', password ? '***' + password.substring(password.length - 3) : 'EMPTY');
    
    if (!email || !password) {
      console.log('Missing email or password');
      return res.status(400).json({ message: 'Email and password are required' });
    }
    
    const user = await User.findOne({ email: email.toLowerCase() });
    console.log('User found:', user ? 'YES' : 'NO');
    
    if (!user) {
      console.log('User not found in database');
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    const passwordMatch = await user.comparePassword(password);
    console.log('Password match:', passwordMatch);
    
    if (!passwordMatch) {
      console.log('Password does not match');
      return res.status(401).json({ message: 'Invalid credentials' });
    }
    
    if (!user.is_active) {
      console.log('User account is inactive');
      return res.status(401).json({ message: 'Account is inactive' });
    }
    
    const token = jwt.sign(
      {
        userId: user._id,
        email: user.email,
        role: user.role,
        organizationId: user.organization_id
      },
      process.env.JWT_SECRET,
      { expiresIn: process.env.JWT_EXPIRES_IN || '24h' }
    );
    
    await logActivity(user.email, ACTIONS.LOGIN, {}, req.ip);
    
    console.log('Login successful for:', email);
    console.log('===================');
    
    res.json({
      token,
      email: user.email,
      role: user.role,
      name: user.name,
      organization_id: user.organization_id,
      message: `Welcome back, ${user.name}!`
    });
  } catch (error) {
    console.log('Login error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Smart redirect: tries deep link first, falls back to web app
router.get('/setup-account', async (req, res) => {
  const { token } = req.query;
  if (!token) return res.status(400).send('Missing token');

  const deepLink = `electrox://app/setup-account?token=${token}`;
  const webLink = `${process.env.SERVER_HOST}/api/auth/setup-account?token=${token}`;

  res.send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Electrox - Setup Account</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: Arial, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background: #14213D; }
    .card { background: white; border-radius: 16px; padding: 40px; max-width: 400px; width: 90%; text-align: center; }
    h2 { color: #14213D; margin-bottom: 8px; }
    p { color: #666; margin-bottom: 24px; }
    .btn { display: inline-block; background: #FCA311; color: white; padding: 14px 32px; border-radius: 10px; text-decoration: none; font-weight: bold; font-size: 16px; margin: 8px; }
    .btn-secondary { background: #14213D; }
    .spinner { display: none; margin: 16px auto; width: 32px; height: 32px; border: 3px solid #eee; border-top-color: #FCA311; border-radius: 50%; animation: spin 0.8s linear infinite; }
    @keyframes spin { to { transform: rotate(360deg); } }
  </style>
</head>
<body>
  <div class="card">
    <h2>🗳️ Electrox</h2>
    <p>Setup your organizer account</p>
    <div class="spinner" id="spinner"></div>
    <a href="${deepLink}" class="btn" id="appBtn" onclick="tryApp()">Open in App</a>
    <br>
    <a href="${webLink}" class="btn btn-secondary">Open in Browser</a>
  </div>
  <script>
    function tryApp() {
      document.getElementById('spinner').style.display = 'block';
      setTimeout(() => {
        document.getElementById('spinner').style.display = 'none';
      }, 2500);
    }
    // Auto-try deep link on mobile
    if (/Android|iPhone|iPad/i.test(navigator.userAgent)) {
      window.location.href = '${deepLink}';
      setTimeout(() => { window.location.href = '${webLink}'; }, 2000);
    }
  </script>
</body>
</html>`);
});

// App redirect: used in credential emails to open the app's login screen
router.get('/app-redirect', (req, res) => {
  const path = req.query.path || 'login';
  const deepLink = `electrox://app/${path}`;
  res.send(`<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>Electrox</title>
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <style>
    body { font-family: Arial, sans-serif; display: flex; align-items: center; justify-content: center; min-height: 100vh; margin: 0; background: #14213D; }
    .card { background: white; border-radius: 16px; padding: 40px; max-width: 400px; width: 90%; text-align: center; }
    h2 { color: #14213D; margin-bottom: 8px; }
    p { color: #666; margin-bottom: 24px; }
    .btn { display: inline-block; background: #FCA311; color: white; padding: 14px 32px; border-radius: 10px; text-decoration: none; font-weight: bold; font-size: 16px; }
  </style>
</head>
<body>
  <div class="card">
    <h2>🗳️ Electrox</h2>
    <p>Tap below to open the Electrox app</p>
    <a href="${deepLink}" class="btn">Open Electrox App</a>
  </div>
  <script>
    if (/Android|iPhone|iPad/i.test(navigator.userAgent)) {
      window.location.href = '${deepLink}';
    }
  </script>
</body>
</html>`);
});

// Setup account from invitation
router.post('/setup-account', async (req, res) => {
  try {
    const { token, name, password } = req.body;
    
    if (!token || !name || !password) {
      return res.status(400).json({ message: 'All fields are required' });
    }
    
    if (!validatePassword(password)) {
      return res.status(400).json({ message: 'Password must be at least 8 characters' });
    }
    
    const invitation = await Invitation.findOne({ token });
    
    if (!invitation) {
      return res.status(400).json({ message: 'Invalid invitation token' });
    }
    
    if (invitation.status === 'accepted') {
      return res.status(400).json({ message: 'Invitation already used' });
    }
    
    if (new Date() > invitation.expires_at) {
      return res.status(400).json({ message: 'Invitation has expired' });
    }
    
    const existingUser = await User.findOne({ email: invitation.email });
    if (existingUser) {
      return res.status(400).json({ message: 'User already exists' });
    }
    
    const user = await User.create({
      email: invitation.email,
      password,
      name,
      role: 'organizer',
      organization_id: invitation.organization_id,
      real_email: invitation.email
    });
    
    invitation.status = 'accepted';
    invitation.accepted_at = new Date();
    await invitation.save();
    
    // Activate the organization when organizer completes setup
    await Organization.findByIdAndUpdate(
      invitation.organization_id,
      { status: 'active', updated_at: new Date() }
    );
    
    await logActivity(user.email, ACTIONS.ACCOUNT_SETUP, {
      organization_id: invitation.organization_id
    }, req.ip);
    
    res.status(201).json({
      message: 'Account created successfully',
      email: user.email,
      organization_id: user.organization_id
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
