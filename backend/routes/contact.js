const express = require('express');
const router = express.Router();
const ContactSubmission = require('../models/ContactSubmission');
const { authenticate, authorize } = require('../middleware/auth');

// Submit contact form
router.post('/submit', async (req, res) => {
  try {
    const { name, email, organization, message } = req.body;
    
    await ContactSubmission.create({
      name,
      email,
      organization,
      message
    });
    
    res.status(201).json({ message: 'Contact form submitted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get all submissions (admin only)
router.get('/submissions', authenticate, authorize('admin'), async (req, res) => {
  try {
    const submissions = await ContactSubmission.find().sort({ created_at: -1 });
    res.json({ submissions });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
