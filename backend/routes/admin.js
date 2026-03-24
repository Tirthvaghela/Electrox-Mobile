const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Election = require('../models/Election');
const AuditLog = require('../models/AuditLog');
const { authenticate, authorize } = require('../middleware/auth');

// Get all users
router.get('/users', authenticate, authorize('admin'), async (req, res) => {
  try {
    const { organization_id } = req.query;
    const filter = organization_id ? { organization_id } : {};
    
    const users = await User.find(filter).select('-password');
    res.json({ users });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get system statistics
router.get('/stats', authenticate, authorize('admin'), async (req, res) => {
  try {
    const { organization_id } = req.query;
    const filter = organization_id ? { organization_id } : {};
    
    const total_users = await User.countDocuments(filter);
    const total_elections = await Election.countDocuments(filter);
    const active_elections = await Election.countDocuments({ ...filter, status: 'active' });
    
    const voteAgg = await Election.aggregate([
      { $match: filter },
      { $group: { _id: null, total: { $sum: '$total_votes' } } }
    ]);
    const total_votes = voteAgg[0]?.total || 0;
    
    const usersByRole = await User.aggregate([
      { $match: filter },
      { $group: { _id: '$role', count: { $sum: 1 } } }
    ]);
    
    const users_by_role = {};
    usersByRole.forEach(item => {
      users_by_role[item._id] = item.count;
    });
    
    // Add organization statistics
    const Organization = require('../models/Organization');
    const total_organizations = await Organization.countDocuments();
    const pending_organizations = await Organization.countDocuments({ status: 'pending' });
    const active_organizations = await Organization.countDocuments({ status: 'active' });
    
    // Votes by day (last 7 days)
    const now = new Date();
    const sevenDaysAgo = new Date(now);
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
    sevenDaysAgo.setHours(0, 0, 0, 0);

    const votesByDayAgg = await Election.aggregate([
      { $match: { ...filter, 'votes.voted_at': { $gte: sevenDaysAgo } } },
      { $unwind: '$votes' },
      { $match: { 'votes.voted_at': { $gte: sevenDaysAgo } } },
      {
        $group: {
          _id: {
            $dateToString: { format: '%Y-%m-%d', date: '$votes.voted_at' }
          },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    // Fill in missing days with 0
    const votes_by_day = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now);
      d.setDate(d.getDate() - i);
      const key = d.toISOString().slice(0, 10);
      const found = votesByDayAgg.find(x => x._id === key);
      votes_by_day.push({ date: key, count: found ? found.count : 0 });
    }

    res.json({
      total_users,
      total_elections,
      active_elections,
      total_votes,
      users_by_role,
      total_organizations,
      pending_organizations,
      active_organizations,
      votes_by_day
    });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Get audit logs
router.get('/audit-logs', authenticate, authorize('admin'), async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 50;
    
    const logs = await AuditLog.find()
      .sort({ timestamp: -1 })
      .limit(limit);
    
    res.json({ logs });
  } catch (error) {
    res.status(500).json({ message: error.message });
  }
});

// Delete user
router.delete('/users/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    const userId = req.params.id;
    
    // Check if user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Prevent deleting admin users
    if (user.role === 'admin') {
      return res.status(400).json({ message: 'Cannot delete admin users' });
    }
    
    // Delete the user
    await User.findByIdAndDelete(userId);
    
    // Log the activity
    const { logActivity, ACTIONS } = require('../utils/auditLogger');
    await logActivity(req.user.email, ACTIONS.USER_DELETED, {
      deleted_user_id: userId,
      deleted_user_email: user.email,
      deleted_user_role: user.role
    }, req.ip);
    
    res.json({ message: 'User deleted successfully' });
  } catch (error) {
    console.error('Delete user error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Create user (admin only)
router.post('/users', authenticate, authorize('admin'), async (req, res) => {
  try {
    const { email, name, role, organization_id, password } = req.body;
    
    // Validate required fields
    if (!email || !name || !role) {
      return res.status(400).json({ message: 'Email, name, and role are required' });
    }
    
    // Check if user already exists
    const existingUser = await User.findOne({ email: email.toLowerCase() });
    if (existingUser) {
      return res.status(400).json({ message: 'User with this email already exists' });
    }
    
    // Create user
    const bcrypt = require('bcrypt');
    const hashedPassword = password 
      ? await bcrypt.hash(password, 12)
      : await bcrypt.hash('changeme123', 12); // Default password
    
    const user = await User.create({
      email: email.toLowerCase(),
      name,
      role,
      organization_id: organization_id || null,
      password: hashedPassword,
      is_active: true
    });
    
    // Log the activity
    const { logActivity, ACTIONS } = require('../utils/auditLogger');
    await logActivity(req.user.email, ACTIONS.USER_CREATED, {
      created_user_id: user._id,
      created_user_email: user.email,
      created_user_role: user.role
    }, req.ip);
    
    // Return user without password
    const userResponse = user.toObject();
    delete userResponse.password;
    
    res.status(201).json({
      message: 'User created successfully',
      user: userResponse
    });
  } catch (error) {
    console.error('Create user error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Update user
router.put('/users/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    const userId = req.params.id;
    const { name, role, is_active, organization_id } = req.body;
    
    // Check if user exists
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    
    // Update user fields
    if (name) user.name = name;
    if (role) user.role = role;
    if (typeof is_active === 'boolean') user.is_active = is_active;
    if (organization_id !== undefined) user.organization_id = organization_id;
    
    await user.save();
    
    // Log the activity
    const { logActivity, ACTIONS } = require('../utils/auditLogger');
    await logActivity(req.user.email, ACTIONS.USER_UPDATED, {
      updated_user_id: userId,
      updated_user_email: user.email,
      changes: { name, role, is_active, organization_id }
    }, req.ip);
    
    // Return user without password
    const userResponse = user.toObject();
    delete userResponse.password;
    
    res.json({
      message: 'User updated successfully',
      user: userResponse
    });
  } catch (error) {
    console.error('Update user error:', error);
    res.status(500).json({ message: error.message });
  }
});

// Delete organization with cascade (all users + elections)
router.delete('/organizations/:id', authenticate, authorize('admin'), async (req, res) => {
  try {
    const Organization = require('../models/Organization');
    const org = await Organization.findById(req.params.id);
    if (!org) return res.status(404).json({ message: 'Organization not found' });

    const orgId = req.params.id;

    // Delete all users belonging to this org (except admins)
    const deletedUsers = await User.deleteMany({
      organization_id: orgId,
      role: { $ne: 'admin' }
    });

    // Delete all elections belonging to this org
    const deletedElections = await Election.deleteMany({ organization_id: orgId });

    // Delete the organization itself
    await Organization.findByIdAndDelete(orgId);

    const { logActivity, ACTIONS } = require('../utils/auditLogger');
    await logActivity(req.user.email, 'ORGANIZATION_DELETED', {
      org_id: orgId,
      org_name: org.name,
      deleted_users: deletedUsers.deletedCount,
      deleted_elections: deletedElections.deletedCount,
    }, req.ip);

    res.json({
      message: 'Organization deleted successfully',
      deleted_users: deletedUsers.deletedCount,
      deleted_elections: deletedElections.deletedCount,
    });
  } catch (error) {
    console.error('Delete org error:', error);
    res.status(500).json({ message: error.message });
  }
});

module.exports = router;
