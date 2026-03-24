const mongoose = require('mongoose');

const auditLogSchema = new mongoose.Schema({
  user_email: {
    type: String,
    required: true
  },
  action: {
    type: String,
    required: true
  },
  resource: String,
  details: {
    type: mongoose.Schema.Types.Mixed
  },
  ip_address: String,
  timestamp: {
    type: Date,
    default: Date.now
  }
});

// Indexes
auditLogSchema.index({ user_email: 1 });
auditLogSchema.index({ action: 1 });
auditLogSchema.index({ timestamp: -1 });
auditLogSchema.index({ user_email: 1, timestamp: -1 });

module.exports = mongoose.model('AuditLog', auditLogSchema);
