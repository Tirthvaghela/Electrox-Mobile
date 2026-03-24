const express = require('express');
const router = express.Router();
const Election = require('../models/Election');
const { authenticate, authorize } = require('../middleware/auth');
const { sendElectionNotification } = require('../utils/emailSender');

// Send reminders to non-voters
router.post('/send-reminders/:election_id', authenticate, authorize('organizer', 'admin'), async (req, res) => {
  try {
    const { election_id } = req.params;
    
    const election = await Election.findById(election_id);
    if (!election) {
      return res.status(404).json({ message: 'Election not found' });
    }
    
    const votedEmails = new Set(election.votes.map(v => v.voter_email));
    const nonVoters = election.voters.filter(v => !votedEmails.has(v.email));
    
    let sent = 0;
    let failed = 0;
    
    for (const voter of nonVoters) {
      const result = await sendElectionNotification(
        voter.email,
        voter.name,
        election.title,
        'election_reminder',
        { endDate: election.end_date.toLocaleDateString() }
      );
      
      if (result.success) sent++;
      else failed++;
    }
    
    res.json({
      message: `Reminders sent to ${sent} voters`,
      sent,
      failed,
      total_non_voters: nonVoters.length
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Export voters as CSV
router.get('/export-voters/:election_id', authenticate, async (req, res) => {
  try {
    const { election_id } = req.params;
    
    const election = await Election.findById(election_id);
    if (!election) {
      return res.status(404).json({ message: 'Election not found' });
    }
    
    const votedEmails = new Set(election.votes.map(v => v.voter_email));
    
    let csv = 'name,email,has_voted,voted_at\n';
    election.voters.forEach(voter => {
      const vote = election.votes.find(v => v.voter_email === voter.email);
      csv += `${voter.name},${voter.email},${votedEmails.has(voter.email)},${vote?.voted_at || ''}\n`;
    });
    
    res.json({
      csv,
      filename: `voters_election_${election_id}.csv`,
      total_voters: election.voters.length,
      voted: election.total_votes,
      not_voted: election.voters.length - election.total_votes
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
