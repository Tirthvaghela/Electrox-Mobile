const mongoose = require('mongoose');
const Invitation = require('./models/Invitation');
const Organization = require('./models/Organization');
require('dotenv').config();

async function checkInvitations() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get all invitations
    const invitations = await Invitation.find({}).populate('organization_id');
    
    console.log(`\n📧 Found ${invitations.length} invitations:`);
    
    for (const inv of invitations) {
      console.log(`\n📨 Invitation: ${inv._id}`);
      console.log(`   Email: ${inv.email}`);
      console.log(`   Organization: ${inv.organization_id?.name || 'Unknown'}`);
      console.log(`   Status: ${inv.status}`);
      console.log(`   Token: ${inv.token}`);
      console.log(`   Created: ${inv.created_at}`);
      console.log(`   Expires: ${inv.expires_at}`);
      console.log(`   Setup URL: ${process.env.FRONTEND_URL}/setup-account?token=${inv.token}`);
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkInvitations();