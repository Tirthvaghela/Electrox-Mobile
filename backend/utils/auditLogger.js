const AuditLog = require('../models/AuditLog');

const ACTIONS = {
  LOGIN: 'user_login',
  LOGOUT: 'user_logout',
  USER_CREATED: 'user_created',
  ELECTION_CREATED: 'election_created',
  VOTE_CAST: 'vote_cast',
  ORGANIZATION_CREATED: 'organization_created',
  INVITATION_SENT: 'invitation_sent',
  ACCOUNT_SETUP: 'account_setup_completed',
  ELECTION_STATUS_CHANGED: 'election_status_changed',
  PASSWORD_RESET: 'password_reset'
};

const logActivity = async (userEmail, action, details = {}, ipAddress = null) => {
  try {
    await AuditLog.create({
      user_email: userEmail,
      action,
      details,
      ip_address: ipAddress,
      timestamp: new Date()
    });
  } catch (error) {
    console.error('Audit logging error:', error);
  }
};

module.exports = { logActivity, ACTIONS };
