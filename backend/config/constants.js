module.exports = {
  ROLES: {
    ADMIN: 'admin',
    ORGANIZER: 'organizer',
    CANDIDATE: 'candidate',
    VOTER: 'voter'
  },
  
  ELECTION_STATUS: {
    DRAFT: 'draft',
    ACTIVE: 'active',
    CLOSED: 'closed'
  },
  
  RESULT_VISIBILITY: {
    HIDDEN: 'hidden',
    LIVE: 'live',
    FINAL_ONLY: 'final_only'
  },
  
  NOTIFICATION_TYPES: {
    INFO: 'info',
    SUCCESS: 'success',
    WARNING: 'warning',
    ERROR: 'error'
  },
  
  INVITATION_STATUS: {
    PENDING: 'pending',
    ACCEPTED: 'accepted',
    EXPIRED: 'expired'
  }
};
