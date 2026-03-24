const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  user_email: {
    type: String,
    required: true
  },
  title: {
    type: String,
    required: true
  },
  message: {
    type: String,
    required: true
  },
  type: {
    type: String,
    enum: ['info', 'success', 'warning', 'error'],
    default: 'info'
  },
  related_id: String,
  read: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: false }
});

// Indexes
notificationSchema.index({ user_email: 1 });
notificationSchema.index({ user_email: 1, read: 1 });
notificationSchema.index({ created_at: -1 });

module.exports = mongoose.model('Notification', notificationSchema);
