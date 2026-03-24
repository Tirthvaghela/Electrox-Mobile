const mongoose = require('mongoose');

const electionTemplateSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true
  },
  description: String,
  organizer_email: {
    type: String,
    required: true
  },
  organization_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: true
  },
  template_data: {
    type: mongoose.Schema.Types.Mixed,
    required: true
  },
  usage_count: {
    type: Number,
    default: 0
  }
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Indexes
electionTemplateSchema.index({ organizer_email: 1 });
electionTemplateSchema.index({ organization_id: 1 });

module.exports = mongoose.model('ElectionTemplate', electionTemplateSchema);
