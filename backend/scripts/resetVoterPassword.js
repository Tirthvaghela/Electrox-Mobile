/**
 * Run: node backend/scripts/resetVoterPassword.js
 * Resets ALL voter/candidate passwords to match what was last emailed,
 * or sets a known password so they can log in.
 */
require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');

async function main() {
  await mongoose.connect(process.env.MONGODB_URI);
  console.log('Connected to MongoDB');

  const User = require('../models/User');

  // Find the specific user
  const email = 'mimu.mimu.voter.5@gls.electrox.com';
  const newPassword = 'Voter@1234';

  const user = await User.findOne({ email });
  if (!user) {
    console.log('User not found:', email);
    process.exit(1);
  }

  // Directly set hashed password (bypass pre-save to avoid double-hash)
  user.password = await bcrypt.hash(newPassword, 12);
  await user.save({ validateBeforeSave: false });
  // Mark password as not modified so pre-save won't re-hash
  // Actually we need to use updateOne to bypass the hook:
  await User.updateOne({ email }, { password: await bcrypt.hash(newPassword, 12) });

  console.log(`✅ Password reset for ${email}`);
  console.log(`   New password: ${newPassword}`);
  console.log('');
  console.log('To reset ALL voters/candidates, run with --all flag');

  // If --all flag, reset all non-admin users
  if (process.argv.includes('--all')) {
    const users = await User.find({ role: { $in: ['voter', 'candidate'] } });
    for (const u of users) {
      await User.updateOne({ _id: u._id }, { password: await bcrypt.hash('Voter@1234', 12) });
      console.log(`Reset: ${u.email}`);
    }
    console.log(`\n✅ Reset ${users.length} users. Password: Voter@1234`);
  }

  await mongoose.disconnect();
}

main().catch(e => { console.error(e); process.exit(1); });
