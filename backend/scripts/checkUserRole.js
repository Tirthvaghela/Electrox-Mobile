const mongoose = require('mongoose');
const User = require('../models/User');
require('dotenv').config();

async function checkUserRole(email) {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');
    
    const user = await User.findOne({ email });
    
    if (!user) {
      console.log(`❌ User not found: ${email}`);
      return;
    }
    
    console.log('\n=== USER DETAILS ===');
    console.log('Email:', user.email);
    console.log('Name:', user.name);
    console.log('Role:', user.role);
    console.log('Organization ID:', user.organization_id);
    console.log('Account Status:', user.account_status);
    console.log('Created:', user.created_at);
    
  } catch (error) {
    console.error('Error:', error.message);
  } finally {
    await mongoose.disconnect();
  }
}

const email = process.argv[2];
if (!email) {
  console.log('Usage: node checkUserRole.js <email>');
  process.exit(1);
}

checkUserRole(email);
