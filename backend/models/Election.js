const mongoose = require('mongoose');

const candidateSchema = new mongoose.Schema({
  name: String,
  email: String,
  bio: String,
  photo: String
}, { _id: false });

const voterSchema = new mongoose.Schema({
  name: String,
  email: String
}, { _id: false });

const voteSchema = new mongoose.Schema({
  voter_email: String,
  candidate_email: String,
  voted_at: { type: Date, default: Date.now }
}, { _id: false });

const electionSchema = new mongoose.Schema({
  title: {
    type: String,
    required: true
  },
  description: {
    type: String,
    required: true
  },
  organizer_email: {
    type: String,
    required: true
  },
  organization_id: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Organization',
    required: true
  },
  start_date: {
    type: Date,
    required: true
  },
  end_date: {
    type: Date,
    required: true
  },
  election_type: {
    type: String,
    default: 'single_choice'
  },
  status: {
    type: String,
    enum: ['draft', 'active', 'closed'],
    default: 'draft'
  },
  result_visibility: {
    type: String,
    enum: ['hidden', 'live', 'final_only'],
    default: 'hidden'
  },
  candidates: [candidateSchema],
  voters: [voterSchema],
  votes: [voteSchema],
  total_votes: {
    type: Number,
    default: 0
  },
  closed_at: Date
}, {
  timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' }
});

// Indexes
electionSchema.index({ organizer_email: 1 });
electionSchema.index({ organization_id: 1 });
electionSchema.index({ status: 1 });
electionSchema.index({ organization_id: 1, status: 1 });
electionSchema.index({ end_date: 1, status: 1 });

module.exports = mongoose.model('Election', electionSchema);
