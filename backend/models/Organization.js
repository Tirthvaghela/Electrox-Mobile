const mongoose = require('mongoose');

const organizationSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  type: {
    type: String,
    default: 'organization'
  },
  status: {
    type: String,
    enum: ['pending', 'active', 'inactive'],
    default: 'pending'
  },
  created_by: {
    type: String,
    required: true
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Indexes
organizationSchema.index({ name: 1 }, { unique: true });
organizationSchema.index({ status: 1 });

module.exports = mongoose.model('Organization', organizationSchema);
