const express = require('express');
const router = express.Router();
const Notification = require('../models/Notification');
const { authenticate } = require('../middleware/auth');

// Get user notifications
router.get('/my-notifications', authenticate, async (req, res) => {
  try {
    const { email } = req.query;
    
    const notifications = await Notification.find({ user_email: email })
      .sort({ created_at: -1 })
      .limit(50);
    
    const unread_count = await Notification.countDocuments({
      user_email: email,
      read: false
    });
    
    res.json({ notifications, unread_count });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get unread count
router.get('/unread-count', authenticate, async (req, res) => {
  try {
    const { email } = req.query;
    
    const count = await Notification.countDocuments({
      user_email: email,
      read: false
    });
    
    res.json({ unread_count: count });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Mark as read
router.put('/mark-read/:notification_id', authenticate, async (req, res) => {
  try {
    const { notification_id } = req.params;
    
    await Notification.findByIdAndUpdate(notification_id, { read: true });
    
    res.json({ message: 'Notification marked as read' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Mark all as read
router.put('/mark-all-read', authenticate, async (req, res) => {
  try {
    const { email } = req.body;
    
    await Notification.updateMany(
      { user_email: email, read: false },
      { read: true }
    );
    
    res.json({ message: 'All notifications marked as read' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Clear all notifications for a user  (must be BEFORE /:notification_id)
router.delete('/clear-all/:email', authenticate, async (req, res) => {
  try {
    await Notification.deleteMany({ user_email: req.params.email });
    res.json({ message: 'All notifications cleared' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete a single notification
router.delete('/:notification_id', authenticate, async (req, res) => {
  try {
    await Notification.findByIdAndDelete(req.params.notification_id);
    res.json({ message: 'Notification deleted' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
