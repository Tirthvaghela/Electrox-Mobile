const cron = require('node-cron');
const Election = require('../models/Election');
const Notification = require('../models/Notification');
const { logActivity, ACTIONS } = require('../utils/auditLogger');

// ── helpers ──────────────────────────────────────────────────────────────────

const notifyAll = async (emails, title, message, type, relatedId) => {
  const docs = emails.map(email => ({ user_email: email, title, message, type, related_id: relatedId }));
  if (docs.length) await Notification.insertMany(docs);
};

// ── auto-start elections whose start_date has passed ─────────────────────────

const checkAndStartElections = async () => {
  try {
    const now = new Date();

    const toStart = await Election.find({
      status: 'draft',
      start_date: { $lte: now },
      end_date:   { $gt:  now },   // only if not already past end
    });

    for (const election of toStart) {
      election.status = 'active';
      await election.save();

      const allEmails = [
        election.organizer_email,
        ...election.voters.map(v => v.email),
        ...election.candidates.map(c => c.email),
      ];

      // Organizer
      await Notification.create({
        user_email: election.organizer_email,
        title: '🗳️ Election Started',
        message: `Your election "${election.title}" has automatically started.`,
        type: 'success',
        related_id: election._id.toString(),
      });

      // Voters
      for (const voter of election.voters) {
        await Notification.create({
          user_email: voter.email,
          title: '🗳️ Election Started',
          message: `The election "${election.title}" is now open. Cast your vote!`,
          type: 'info',
          related_id: election._id.toString(),
        });
      }

      // Candidates
      for (const candidate of election.candidates) {
        await Notification.create({
          user_email: candidate.email,
          title: '🗳️ Election Started',
          message: `The election "${election.title}" you are participating in has started.`,
          type: 'info',
          related_id: election._id.toString(),
        });
      }

      await logActivity('system', ACTIONS.ELECTION_STATUS_CHANGED, {
        election_id: election._id,
        election_title: election.title,
        old_status: 'draft',
        new_status: 'active',
        reason: 'auto_start',
      });

      console.log(`▶️  Auto-started election: ${election.title}`);
    }
  } catch (error) {
    console.error('Auto-start scheduler error:', error);
  }
};

// ── auto-close elections whose end_date has passed ────────────────────────────

const checkAndCloseElections = async () => {
  try {
    const now = new Date();

    const toClose = await Election.find({
      status: 'active',
      end_date: { $lt: now },
    });

    for (const election of toClose) {
      election.status = 'closed';
      election.closed_at = now;
      await election.save();

      // Organizer
      await Notification.create({
        user_email: election.organizer_email,
        title: '🔒 Election Closed',
        message: `The election "${election.title}" has been automatically closed. ${election.total_votes} votes were cast.`,
        type: 'info',
        related_id: election._id.toString(),
      });

      // Voters
      for (const voter of election.voters) {
        await Notification.create({
          user_email: voter.email,
          title: '🔒 Election Closed',
          message: `The election "${election.title}" has ended. Results will be announced soon.`,
          type: 'info',
          related_id: election._id.toString(),
        });
      }

      // Candidates
      for (const candidate of election.candidates) {
        await Notification.create({
          user_email: candidate.email,
          title: '🔒 Election Closed',
          message: `The election "${election.title}" has ended.`,
          type: 'info',
          related_id: election._id.toString(),
        });
      }

      await logActivity('system', ACTIONS.ELECTION_STATUS_CHANGED, {
        election_id: election._id,
        election_title: election.title,
        old_status: 'active',
        new_status: 'closed',
        reason: 'auto_close',
      });

      console.log(`🔒 Auto-closed election: ${election.title}`);
    }
  } catch (error) {
    console.error('Auto-close scheduler error:', error);
  }
};

// ── 10-minute warning before election starts ──────────────────────────────────

const checkUpcomingElections = async () => {
  try {
    const now = new Date();
    const in10 = new Date(now.getTime() + 10 * 60 * 1000);
    const in11 = new Date(now.getTime() + 11 * 60 * 1000);

    // Elections starting in the next 10–11 min window (to avoid duplicate notifications)
    const upcoming = await Election.find({
      status: 'draft',
      start_date: { $gte: in10, $lt: in11 },
    });

    for (const election of upcoming) {
      await Notification.create({
        user_email: election.organizer_email,
        title: '⏰ Election Starting Soon',
        message: `Your election "${election.title}" starts in 10 minutes.`,
        type: 'warning',
        related_id: election._id.toString(),
      });

      for (const voter of election.voters) {
        await Notification.create({
          user_email: voter.email,
          title: '⏰ Election Starting Soon',
          message: `The election "${election.title}" starts in 10 minutes. Get ready to vote!`,
          type: 'warning',
          related_id: election._id.toString(),
        });
      }

      console.log(`⏰ Sent 10-min warning for: ${election.title}`);
    }
  } catch (error) {
    console.error('Upcoming election check error:', error);
  }
};

// ── 10-minute warning before election ends ────────────────────────────────────

const checkEndingElections = async () => {
  try {
    const now = new Date();
    const in10 = new Date(now.getTime() + 10 * 60 * 1000);
    const in11 = new Date(now.getTime() + 11 * 60 * 1000);

    const ending = await Election.find({
      status: 'active',
      end_date: { $gte: in10, $lt: in11 },
    });

    for (const election of ending) {
      await Notification.create({
        user_email: election.organizer_email,
        title: '⚠️ Election Ending Soon',
        message: `Your election "${election.title}" ends in 10 minutes.`,
        type: 'warning',
        related_id: election._id.toString(),
      });

      // Notify voters who haven't voted yet
      const votedEmails = new Set(election.votes.map(v => v.voter_email));
      for (const voter of election.voters) {
        if (!votedEmails.has(voter.email)) {
          await Notification.create({
            user_email: voter.email,
            title: '⚠️ Last Chance to Vote!',
            message: `The election "${election.title}" ends in 10 minutes. Don't miss your chance!`,
            type: 'warning',
            related_id: election._id.toString(),
          });
        }
      }

      console.log(`⚠️  Sent 10-min end warning for: ${election.title}`);
    }
  } catch (error) {
    console.error('Ending election check error:', error);
  }
};

// ── start all schedulers ──────────────────────────────────────────────────────

const startScheduler = () => {
  // Every minute: auto-start, auto-close, check warnings
  cron.schedule('* * * * *', async () => {
    await checkAndStartElections();
    await checkAndCloseElections();
    await checkUpcomingElections();
    await checkEndingElections();
  });

  console.log('⏰ Election scheduler started (auto-start + auto-close + warnings)');
};

module.exports = { startScheduler, checkAndCloseElections, checkAndStartElections };
