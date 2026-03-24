const express = require('express');
const router = express.Router();
const Election = require('../models/Election');
const User = require('../models/User');
const Organization = require('../models/Organization');
const Notification = require('../models/Notification');
const upload = require('../middleware/upload');
const { authenticate, authorize } = require('../middleware/auth');
const { parseCSVFile, generatePassword, generateSystemEmail } = require('../utils/csvHandler');
const { sendCredentialsEmail, sendElectionNotification } = require('../utils/emailSender');
const { logActivity, ACTIONS } = require('../utils/auditLogger');
const { generateElectionResultsHTML } = require('../utils/pdfGenerator');

// Upload and parse CSV
router.post('/upload-participants', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }
    
    const result = await parseCSVFile(req.file.buffer);
    
    res.json({
      message: 'CSV parsed successfully',
      participants: result.participants,
      total: result.total,
      errors: result.errors
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Create election
router.post('/create', authenticate, authorize('organizer', 'admin'), async (req, res) => {
  console.log('=== CREATE ELECTION REQUEST ===');
  console.log('Headers:', req.headers);
  console.log('Body:', JSON.stringify(req.body, null, 2));
  console.log('User:', req.user);
  
  try {
    const {
      title,
      description,
      organizer_email,
      start_date,
      end_date,
      result_visibility,
      candidates,
      voters
    } = req.body;
    
    const user = await User.findOne({ email: organizer_email });
    if (!user) {
      return res.status(404).json({ message: 'Organizer not found' });
    }
    
    const organization = await Organization.findById(user.organization_id);
    if (!organization) {
      return res.status(404).json({ message: 'Organization not found' });
    }
    
    const election = await Election.create({
      title,
      description,
      organizer_email,
      organization_id: user.organization_id,
      start_date: new Date(start_date),
      end_date: new Date(end_date),
      result_visibility: result_visibility || 'hidden',
      candidates: [],
      voters: [],
      votes: []
    });
    
    // Create candidate accounts
    let candidateIndex = 1;
    const emailPromises = [];
    for (const candidate of candidates) {
      const systemEmail = generateSystemEmail(candidate.name, 'candidate', candidateIndex++, organization.name);
      const password = generatePassword();
      
      let candidateUser = await User.findOne({ email: systemEmail });
      if (!candidateUser) {
        candidateUser = await User.create({
          email: systemEmail,
          password,
          name: candidate.name,
          role: 'candidate',
          organization_id: user.organization_id,
          real_email: candidate.email
        });
      } else {
        // Update password so it stays in sync with the email we're about to send
        candidateUser.password = password;
        candidateUser.real_email = candidate.email;
        await candidateUser.save();
      }
      
      election.candidates.push({
        name: candidate.name,
        email: systemEmail,
        bio: candidate.bio || '',
        photo: candidate.photo || ''
      });
      
      // Always send credentials so the user has the current password
      emailPromises.push(
        sendCredentialsEmail(candidate.email, candidate.name, systemEmail, password, title, 'candidate')
          .catch(err => console.error('Email failed for candidate', candidate.email, err))
      );
    }
    
    // Create voter accounts
    let voterIndex = 1;
    for (const voter of voters) {
      const systemEmail = generateSystemEmail(voter.name, 'voter', voterIndex++, organization.name);
      const password = generatePassword();
      
      let voterUser = await User.findOne({ email: systemEmail });
      if (!voterUser) {
        voterUser = await User.create({
          email: systemEmail,
          password,
          name: voter.name,
          role: 'voter',
          organization_id: user.organization_id,
          real_email: voter.email
        });
      } else {
        // Update password so it stays in sync with the email we're about to send
        voterUser.password = password;
        voterUser.real_email = voter.email;
        await voterUser.save();
      }
      
      election.voters.push({
        name: voter.name,
        email: systemEmail
      });
      
      // Always send credentials so the user has the current password
      emailPromises.push(
        sendCredentialsEmail(voter.email, voter.name, systemEmail, password, title, 'voter')
          .catch(err => console.error('Email failed for voter', voter.email, err))
      );
    }
    
    await election.save();
    
    // Send all emails in background — don't block the response
    Promise.allSettled(emailPromises).then(results => {
      const failed = results.filter(r => r.status === 'rejected').length;
      if (failed > 0) console.error(`${failed} credential emails failed to send`);
    });
    
    // Notify organizer and log — fire-and-forget
    Notification.create({
      user_email: organizer_email,
      title: 'Election Created',
      message: `Your election "${title}" has been created with ${candidates.length} candidates and ${voters.length} voters.`,
      type: 'success',
      related_id: election._id
    }).catch(err => console.error('Notification failed:', err));

    logActivity(organizer_email, ACTIONS.ELECTION_CREATED, {
      election_id: election._id,
      election_title: title
    }, req.ip).catch(err => console.error('Audit log failed:', err));
    
    res.status(201).json({
      message: 'Election created successfully',
      election: {
        id: election._id,
        title: election.title,
        candidates: election.candidates.length,
        voters: election.voters.length
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get organizer's elections
router.get('/my-elections', authenticate, async (req, res) => {
  try {
    const { email } = req.query;
    const elections = await Election.find({ organizer_email: email });
    res.json({ elections });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get elections by organization (admin view)
router.get('/by-organization/:orgId', authenticate, authorize('admin'), async (req, res) => {
  try {
    const elections = await Election.find({ organization_id: req.params.orgId });
    res.json({ elections });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Cast vote
router.post('/vote', authenticate, async (req, res) => {
  try {
    const { election_id, voter_email, candidate_email } = req.body;
    
    const election = await Election.findById(election_id);
    if (!election) {
      return res.status(404).json({ message: 'Election not found' });
    }
    
    if (election.status !== 'active') {
      return res.status(400).json({ message: 'Election is not active' });
    }
    
    const hasVoted = election.votes.some(v => v.voter_email === voter_email);
    if (hasVoted) {
      return res.status(400).json({ message: 'You have already voted in this election' });
    }
    
    election.votes.push({
      voter_email,
      candidate_email,
      voted_at: new Date()
    });
    election.total_votes += 1;
    await election.save();
    
    await Notification.create({
      user_email: voter_email,
      title: 'Vote Confirmed',
      message: `Your vote in "${election.title}" has been recorded.`,
      type: 'success',
      related_id: election_id
    });
    
    await logActivity(voter_email, ACTIONS.VOTE_CAST, {
      election_id,
      election_title: election.title
    }, req.ip);
    
    res.json({ success: true, message: 'Vote cast successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Export results as CSV  (must be before /results/:election_id to avoid param conflict)
router.get('/results/:election_id/export', authenticate, async (req, res) => {
  try {
    const election = await Election.findById(req.params.election_id);
    if (!election) return res.status(404).json({ message: 'Election not found' });

    const voteCounts = {};
    election.candidates.forEach(c => { voteCounts[c.email] = 0; });
    election.votes.forEach(v => {
      if (voteCounts[v.candidate_email] !== undefined) voteCounts[v.candidate_email]++;
    });

    const results = election.candidates
      .map(c => ({ name: c.name, email: c.email, votes: voteCounts[c.email] || 0 }))
      .sort((a, b) => b.votes - a.votes);

    let csv = 'rank,name,email,votes,percentage\n';
    results.forEach((r, i) => {
      const pct = election.total_votes > 0
        ? ((r.votes / election.total_votes) * 100).toFixed(1)
        : '0.0';
      csv += `${i + 1},${r.name},${r.email},${r.votes},${pct}%\n`;
    });

    res.json({
      csv,
      filename: `results_${election.title.replace(/\s+/g, '_')}.csv`,
      total_votes: election.total_votes,
      election_title: election.title
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get election results
router.get('/results/:election_id', authenticate, async (req, res) => {
  try {
    const { election_id } = req.params;
    const { role, email } = req.query;
    
    const election = await Election.findById(election_id);
    if (!election) {
      return res.status(404).json({ message: 'Election not found' });
    }
    
    const isOrganizer = election.organizer_email === email;
    const isAdmin = role === 'admin';
    const isCandidate = election.candidates.some(c => c.email === email);
    
    let visible = false;
    
    if (election.result_visibility === 'hidden') {
      visible = isOrganizer || isAdmin || (isCandidate && election.status === 'closed');
    } else if (election.result_visibility === 'live') {
      visible = true;
    } else if (election.result_visibility === 'final_only') {
      visible = election.status === 'closed';
    }
    
    const voteCounts = {};
    election.candidates.forEach(c => {
      voteCounts[c.email] = 0;
    });
    
    election.votes.forEach(v => {
      if (voteCounts[v.candidate_email] !== undefined) {
        voteCounts[v.candidate_email]++;
      }
    });
    
    const results = election.candidates.map(c => ({
      name: c.name,
      email: c.email,
      votes: voteCounts[c.email] || 0
    })).sort((a, b) => b.votes - a.votes);
    
    res.json({
      election_id,
      title: election.title,
      total_votes: election.total_votes,
      total_voters: election.voters.length,
      visible,
      result_visibility: election.result_visibility,
      is_candidate: isCandidate,
      results: visible ? results : []
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update election status
router.put('/update-status', authenticate, authorize('organizer', 'admin'), async (req, res) => {
  try {
    const { election_id, status } = req.body;
    
    const election = await Election.findById(election_id);
    if (!election) {
      return res.status(404).json({ message: 'Election not found' });
    }
    
    election.status = status;
    if (status === 'closed') {
      election.closed_at = new Date();
    }
    await election.save();
    
    if (status === 'active') {
      // Notify all voters
      for (const voter of election.voters) {
        await Notification.create({
          user_email: voter.email,
          title: 'Election Started',
          message: `The election "${election.title}" is now active. Cast your vote!`,
          type: 'info',
          related_id: election_id
        });
      }
      // Notify all candidates
      for (const candidate of election.candidates) {
        await Notification.create({
          user_email: candidate.email,
          title: 'Election Started',
          message: `The election "${election.title}" you are participating in is now active.`,
          type: 'info',
          related_id: election_id
        });
      }
      // Notify organizer
      await Notification.create({
        user_email: election.organizer_email,
        title: 'Election Activated',
        message: `Your election "${election.title}" is now live with ${election.voters.length} voters.`,
        type: 'success',
        related_id: election_id
      });
    }

    if (status === 'closed') {
      // Notify organizer
      await Notification.create({
        user_email: election.organizer_email,
        title: 'Election Closed',
        message: `Your election "${election.title}" has been closed. ${election.total_votes} votes were cast.`,
        type: 'info',
        related_id: election_id
      });
    }
    
    res.json({ message: 'Election status updated', election });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get voter's elections
router.get('/voter-elections', authenticate, async (req, res) => {
  try {
    const { email } = req.query;
    
    const elections = await Election.find({
      'voters.email': email
    });
    
    const electionsWithVoteStatus = elections.map(election => ({
      ...election.toObject(),
      has_voted: election.votes.some(v => v.voter_email === email)
    }));
    
    res.json({ elections: electionsWithVoteStatus });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get candidate's elections
router.get('/candidate-elections', authenticate, async (req, res) => {
  try {
    const { email } = req.query;
    
    const elections = await Election.find({
      'candidates.email': email
    });
    
    res.json({ elections });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete election
router.delete('/delete/:election_id', authenticate, authorize('organizer', 'admin'), async (req, res) => {
  try {
    const election = await Election.findById(req.params.election_id);
    if (!election) return res.status(404).json({ message: 'Election not found' });
    await Election.findByIdAndDelete(req.params.election_id);
    await logActivity(req.user.email, ACTIONS.ELECTION_DELETED || 'ELECTION_DELETED', {
      election_id: req.params.election_id,
      election_title: election.title
    }, req.ip);
    res.json({ message: 'Election deleted successfully' });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update election details (title, description, dates, visibility)
router.put('/update/:election_id', authenticate, authorize('organizer', 'admin'), async (req, res) => {
  try {
    const { title, description, start_date, end_date, result_visibility } = req.body;
    const election = await Election.findById(req.params.election_id);
    if (!election) return res.status(404).json({ message: 'Election not found' });
    if (title) election.title = title;
    if (description) election.description = description;
    if (start_date) election.start_date = new Date(start_date);
    if (end_date) election.end_date = new Date(end_date);
    if (result_visibility) election.result_visibility = result_visibility;
    await election.save();
    res.json({ message: 'Election updated', election });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
