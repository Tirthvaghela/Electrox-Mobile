const mongoose = require('mongoose');

const contactSubmissionSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  email: {
    type: String,
    required: true
  },
  organization: String,
  message: {
    type: String,
    required: true
  },
  status: {
    type: String,
    enum: ['new', 'read', 'resolved'],
    default: 'new'
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: false }
});

// Indexes
contactSubmissionSchema.index({ status: 1 });
contactSubmissionSchema.index({ created_at: -1 });

module.exports = mongoose.model('ContactSubmission', contactSubmissionSchema);
