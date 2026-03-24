const express = require('express');
const router = express.Router();
const User = require('../models/User');
const { authenticate } = require('../middleware/auth');

// Get user profile
router.get('/profile', authenticate, async (req, res) => {
  try {
    const { email } = req.query;
    const user = await User.findOne({ email }).select('-password');
    
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    res.json({ user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update user profile
router.put('/profile', authenticate, async (req, res) => {
  try {
    const { email, name } = req.body;
    
    const user = await User.findOneAndUpdate(
      { email },
      { name },
      { new: true }
    ).select('-password');
    
    res.json({ message: 'Profile updated', user });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
