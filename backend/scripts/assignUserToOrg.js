const mongoose = require('mongoose');
const User = require('../models/User');
const Organization = require('../models/Organization');
require('dotenv').config();

async function assignUserToOrg(userEmail) {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');
    
    // Find user
    const user = await User.findOne({ email: userEmail });
    if (!user) {
      console.log(`❌ User not found: ${userEmail}`);
      return;
    }
    
    console.log('\n=== USER BEFORE ===');
    console.log('Email:', user.email);
    console.log('Name:', user.name);
    console.log('Role:', user.role);
    console.log('Organization ID:', user.organization_id);
    
    // Find an active organization
    let organization = await Organization.findOne({ status: 'active' });
    
    // If no active org, find any org
    if (!organization) {
      organization = await Organization.findOne();
    }
    
    // If still no org, create one
    if (!organization) {
      console.log('\n📝 No organization found, creating one...');
      organization = await Organization.create({
        name: 'Default Organization',
        domain: 'default.org',
        admin_email: userEmail,
        status: 'active',
        settings: {
          max_elections: 100,
          max_voters_per_election: 10000,
          allow_anonymous_voting: false,
          require_email_verification: true
        }
      });
      console.log('✅ Created organization:', organization.name);
    }
    
    // Assign user to organization
    user.organization_id = organization._id;
    await user.save();
    
    console.log('\n=== USER AFTER ===');
    console.log('Email:', user.email);
    console.log('Name:', user.name);
    console.log('Role:', user.role);
    console.log('Organization ID:', user.organization_id);
    console.log('Organization Name:', organization.name);
    
    console.log('\n✅ User successfully assigned to organization!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
  }
}

const email = process.argv[2] || 'vaghelatirth719@gmail.com';
assignUserToOrg(email);
