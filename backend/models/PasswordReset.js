const mongoose = require('mongoose');

const passwordResetSchema = new mongoose.Schema({
  email: {
    type: String,
    required: true
  },
  token: {
    type: String,
    required: true,
    unique: true
  },
  expires_at: {
    type: Date,
    required: true
  },
  used: {
    type: Boolean,
    default: false
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: false }
});

// Indexes
passwordResetSchema.index({ token: 1 }, { unique: true });
passwordResetSchema.index({ email: 1 });
passwordResetSchema.index({ email: 1, used: 1, expires_at: 1 });

module.exports = mongoose.model('PasswordReset', passwordResetSchema);
