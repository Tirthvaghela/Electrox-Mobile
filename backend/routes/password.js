const express = require('express');
const router = express.Router();
const User = require('../models/User');
const PasswordReset = require('../models/PasswordReset');
const { generateToken } = require('../utils/tokenGenerator');
const { sendPasswordResetEmail } = require('../utils/emailSender');
const { logActivity, ACTIONS } = require('../utils/auditLogger');

// Request password reset
router.post('/forgot', async (req, res) => {
  try {
    const { email } = req.body;
    
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) {
      return res.json({ message: 'Password reset email sent' });
    }
    
    const token = generateToken();
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 1);
    
    await PasswordReset.create({
      email: user.email,
      token,
      expires_at: expiresAt
    });
    
    await sendPasswordResetEmail(user.real_email || user.email, user.name, token);
    
    res.json({ message: 'Password reset email sent' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Reset password
router.post('/reset', async (req, res) => {
  try {
    const { token, new_password } = req.body;
    
    const resetRequest = await PasswordReset.findOne({ token, used: false });
    
    if (!resetRequest) {
      return res.status(400).json({ message: 'Invalid or expired token' });
    }
    
    if (new Date() > resetRequest.expires_at) {
      return res.status(400).json({ message: 'Token has expired' });
    }
    
    const user = await User.findOne({ email: resetRequest.email });
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    user.password = new_password;
    await user.save();
    
    resetRequest.used = true;
    await resetRequest.save();
    
    await logActivity(user.email, ACTIONS.PASSWORD_RESET, {});
    
    res.json({ message: 'Password reset successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Verify reset token
router.get('/verify-token/:token', async (req, res) => {
  try {
    const { token } = req.params;
    
    const resetRequest = await PasswordReset.findOne({ token, used: false });
    
    if (!resetRequest || new Date() > resetRequest.expires_at) {
      return res.json({ valid: false });
    }
    
    res.json({ valid: true });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Change password (authenticated user)
router.post('/change', async (req, res) => {
  try {
    const { email, old_password, new_password } = req.body;
    if (!email || !old_password || !new_password) {
      return res.status(400).json({ message: 'All fields are required' });
    }
    if (new_password.length < 8) {
      return res.status(400).json({ message: 'New password must be at least 8 characters' });
    }
    const user = await User.findOne({ email: email.toLowerCase() });
    if (!user) return res.status(404).json({ message: 'User not found' });
    const match = await user.comparePassword(old_password);
    if (!match) return res.status(401).json({ message: 'Current password is incorrect' });
    user.password = new_password;
    await user.save();
    res.json({ message: 'Password changed successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
