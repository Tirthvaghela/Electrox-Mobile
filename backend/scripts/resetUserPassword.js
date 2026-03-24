const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
require('dotenv').config();

// Connect to MongoDB
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('✅ Connected to MongoDB'))
  .catch(err => {
    console.error('❌ MongoDB connection error:', err);
    process.exit(1);
  });

// User Schema
const userSchema = new mongoose.Schema({
  email: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  name: { type: String, required: true },
  role: { type: String, required: true },
  is_active: { type: Boolean, default: true }
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

const User = mongoose.model('User', userSchema);

async function resetPassword() {
  try {
    // Get email and new password from command line arguments
    const email = process.argv[2];
    const newPassword = process.argv[3];

    if (!email || !newPassword) {
      console.log('Usage: node resetUserPassword.js <email> <new-password>');
      console.log('Example: node resetUserPassword.js user@example.com newpass123');
      process.exit(1);
    }

    // Find user
    const user = await User.findOne({ email: email.toLowerCase() });
    
    if (!user) {
      console.log(`❌ User with email ${email} not found`);
      process.exit(1);
    }

    // Hash new password
    const hashedPassword = await bcrypt.hash(newPassword, 12);

    // Update password
    user.password = hashedPassword;
    await user.save();

    console.log('✅ Password reset successfully!');
    console.log(`📧 Email: ${email}`);
    console.log(`🔑 New Password: ${newPassword}`);
    console.log('\n✨ You can now login with the new password!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error resetting password:', error);
    process.exit(1);
  }
}

resetPassword();
