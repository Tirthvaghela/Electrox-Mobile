const express = require('express');
const router = express.Router();
const Organization = require('../models/Organization');
const Invitation = require('../models/Invitation');
const User = require('../models/User');
const Election = require('../models/Election');
const { authenticate, authorize } = require('../middleware/auth');
const { generateToken } = require('../utils/tokenGenerator');
const { sendOrganizationInvitation } = require('../utils/emailSender');
const { logActivity, ACTIONS } = require('../utils/auditLogger');

// Create organization
router.post('/create', authenticate, authorize('admin'), async (req, res) => {
  try {
    const { name, type, organizer_name, organizer_email, created_by } = req.body;
    
    const organization = await Organization.create({
      name,
      type: type || 'organization',
      created_by,
      status: 'pending' // Start as pending until organizer sets up account
    });
    
    const token = generateToken();
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 48);
    
    await Invitation.create({
      organization_id: organization._id,
      email: organizer_email.toLowerCase(),
      organizer_name,
      token,
      expires_at: expiresAt
    });
    
    // Try to send email
    let emailSent = false;
    let emailError = null;
    
    try {
      const emailResult = await sendOrganizationInvitation(organizer_email, organizer_name, name, token);
      emailSent = emailResult.success;
      if (!emailResult.success) {
        emailError = emailResult.error;
      }
    } catch (error) {
      emailError = error.message;
    }
    
    // Always log the setup link so it can be used even if email fails
    console.log('\n========================================');
    console.log('✅ INVITATION CREATED');
    console.log(`📧 For: ${organizer_email}`);
    console.log(`🔗 Setup Link: ${process.env.SERVER_HOST}/api/auth/setup-account?token=${token}`);
    console.log('========================================\n');
    
    await logActivity(created_by, ACTIONS.ORGANIZATION_CREATED, {
      organization_id: organization._id,
      organization_name: name
    }, req.ip);
    
    await logActivity(created_by, ACTIONS.INVITATION_SENT, {
      organization_id: organization._id,
      organizer_email,
      email_sent: emailSent,
      email_error: emailError
    }, req.ip);
    
    res.status(201).json({
      message: 'Organization created successfully',
      organization_id: organization._id,
      invitation_token: token,
      email_sent: emailSent,
      email_error: emailError
    });
  } catch (error) {
    console.error('Create organization error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Get all organizations
router.get('/all', authenticate, authorize('admin'), async (req, res) => {
  try {
    const organizations = await Organization.find();
    
    const organizationsWithStats = await Promise.all(
      organizations.map(async (org) => {
        const users = await User.countDocuments({ organization_id: org._id });
        const elections = await Election.countDocuments({ organization_id: org._id });
        const votes = await Election.aggregate([
          { $match: { organization_id: org._id } },
          { $group: { _id: null, total: { $sum: '$total_votes' } } }
        ]);
        
        return {
          ...org.toObject(),
          stats: {
            users,
            elections,
            votes: votes[0]?.total || 0
          }
        };
      })
    );
    
    res.json({ organizations: organizationsWithStats });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get organization by ID
router.get('/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    const organization = await Organization.findById(req.params.id);
    
    if (!organization) {
      return res.status(404).json({ message: 'Organization not found' });
    }
    
    const users = await User.countDocuments({ organization_id: organization._id });
    const elections = await Election.countDocuments({ organization_id: organization._id });
    const votes = await Election.aggregate([
      { $match: { organization_id: organization._id } },
      { $group: { _id: null, total: { $sum: '$total_votes' } } }
    ]);
    
    res.json({
      ...organization.toObject(),
      stats: {
        users,
        elections,
        votes: votes[0]?.total || 0
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Update organization
router.put('/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    const { name, type, status } = req.body;
    
    const organization = await Organization.findByIdAndUpdate(
      req.params.id,
      { name, type, status, updated_at: new Date() },
      { new: true }
    );
    
    if (!organization) {
      return res.status(404).json({ message: 'Organization not found' });
    }
    
    await logActivity(req.user.email, 'organization_updated', {
      organization_id: organization._id,
      organization_name: name
    }, req.ip);
    
    res.json({
      message: 'Organization updated successfully',
      organization
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete organization
router.delete('/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    const organizationId = req.params.id;
    
    // Check if organization exists
    const organization = await Organization.findById(organizationId);
    if (!organization) {
      return res.status(404).json({ message: 'Organization not found' });
    }
    
    // Check if organization has users (optional - you might want to prevent deletion)
    const userCount = await User.countDocuments({ organization_id: organizationId });
    const electionCount = await Election.countDocuments({ organization_id: organizationId });
    
    if (userCount > 0 || electionCount > 0) {
      return res.status(400).json({ 
        message: `Cannot delete organization. It has ${userCount} users and ${electionCount} elections. Please remove them first.` 
      });
    }
    
    // Delete related invitations
    await Invitation.deleteMany({ organization_id: organizationId });
    
    // Delete the organization
    await Organization.findByIdAndDelete(organizationId);
    
    await logActivity(req.user.email, 'organization_deleted', {
      organization_id: organizationId,
      organization_name: organization.name
    }, req.ip);
    
    res.json({ message: 'Organization deleted successfully' });
  } catch (error) {
    console.error('Delete organization error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Verify invitation token
router.post('/invitation/verify', async (req, res) => {
  try {
    const { token } = req.body;
    
    const invitation = await Invitation.findOne({ token }).populate('organization_id');
    
    if (!invitation) {
      return res.status(400).json({ valid: false, message: 'Invalid token' });
    }
    
    if (invitation.status === 'accepted') {
      return res.status(400).json({ valid: false, message: 'Invitation already used' });
    }
    
    if (new Date() > invitation.expires_at) {
      return res.status(400).json({ valid: false, message: 'Invitation expired' });
    }
    
    res.json({
      valid: true,
      invitation: {
        email: invitation.email,
        organizer_name: invitation.organizer_name,
        organization_id: invitation.organization_id._id,
        organization: {
          name: invitation.organization_id.name
        }
      }
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get invitation token for organization
router.get('/:id/invitation', authenticate, authorize('admin'), async (req, res) => {
  try {
    const organizationId = req.params.id;
    
    // Find the invitation for this organization
    const invitation = await Invitation.findOne({ 
      organization_id: organizationId,
      status: 'pending' 
    }).populate('organization_id');
    
    if (!invitation) {
      return res.status(404).json({ message: 'No pending invitation found for this organization' });
    }
    
    // Check if invitation is expired
    const isExpired = new Date() > invitation.expires_at;
    
    res.json({
      invitation: {
        token: invitation.token,
        email: invitation.email,
        organizer_name: invitation.organizer_name,
        expires_at: invitation.expires_at,
        is_expired: isExpired,
        setup_link: `${process.env.FRONTEND_URL}/setup-account?token=${invitation.token}`
      }
    });
  } catch (error) {
    console.error('Get invitation error:', error);
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
