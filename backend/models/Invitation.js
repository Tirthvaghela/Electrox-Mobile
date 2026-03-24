const mongoose = require('mongoose');

const invitationSchema = new mongoose.Schema({
  organization_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: true
  },
  email: {
    type: String,
    required: true,
    lowercase: true
  },
  organizer_name: {
    type: String,
    required: true
  },
  token: {
    type: String,
    required: true,
    unique: true
  },
  status: {
    type: String,
    enum: ['pending', 'accepted', 'expired'],
    default: 'pending'
  },
  expires_at: {
    type: Date,
    required: true
  },
  accepted_at: Date
}, {
  timestamps: { createdAt: 'created_at', updatedAt: false }
});

// Indexes
invitationSchema.index({ token: 1 }, { unique: true });
invitationSchema.index({ email: 1 });
invitationSchema.index({ status: 1, expires_at: 1 });

module.exports = mongoose.model('Invitation', invitationSchema);
