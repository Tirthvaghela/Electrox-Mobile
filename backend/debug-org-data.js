const mongoose = require('mongoose');
const Organization = require('./models/Organization');
const User = require('./models/User');
const Election = require('./models/Election');
const Invitation = require('./models/Invitation');
require('dotenv').config();

async function debugOrganizationData() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get all organizations
    const organizations = await Organization.find({});
    
    for (const org of organizations) {
      console.log(`\n📊 Organization: ${org.name} (${org._id})`);
      console.log(`   Status: ${org.status}`);
      
      // Count users
      const userCount = await User.countDocuments({ organization_id: org._id });
      console.log(`   Users: ${userCount}`);
      
      // Debug: Check user organization_id types
      const users = await User.find({ organization_id: org._id }, 'email organization_id');
      if (users.length > 0) {
        console.log(`   User org_id types:`, users.map(u => ({ email: u.email, org_id: u.organization_id, type: typeof u.organization_id })));
      }
      
      // Also check with string conversion
      const userCountStr = await User.countDocuments({ organization_id: org._id.toString() });
      if (userCountStr !== userCount) {
        console.log(`   Users (string match): ${userCountStr}`);
      }
      
      // Count elections
      const electionCount = await Election.countDocuments({ organization_id: org._id });
      console.log(`   Elections: ${electionCount}`);
      
      // Count invitations
      const invitationCount = await Invitation.countDocuments({ organization_id: org._id });
      console.log(`   Invitations: ${invitationCount}`);
      
      // List users
      if (userCount > 0) {
        const users = await User.find({ organization_id: org._id }, 'email name role');
        console.log(`   User details:`, users);
      }
      
      // List elections
      if (electionCount > 0) {
        const elections = await Election.find({ organization_id: org._id }, 'title status');
        console.log(`   Election details:`, elections);
      }
      
      // List invitations
      if (invitationCount > 0) {
        const invitations = await Invitation.find({ organization_id: org._id }, 'email status');
        console.log(`   Invitation details:`, invitations);
      }
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

debugOrganizationData();