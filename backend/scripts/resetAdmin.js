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

async function resetAdmin() {
  try {
    // Delete existing admin
    await User.deleteOne({ email: 'admin@electrox.com' });
    console.log('🗑️  Deleted existing admin user');

    // Hash password
    const hashedPassword = await bcrypt.hash('admin123', 12);

    // Create new admin user
    const admin = await User.create({
      email: 'admin@electrox.com',
      password: hashedPassword,
      name: 'System Admin',
      role: 'admin',
      is_active: true
    });

    console.log('✅ Admin user created successfully!');
    console.log('📧 Email: admin@electrox.com');
    console.log('🔑 Password: admin123');
    console.log('\n✨ You can now login with these credentials!');
    
    process.exit(0);
  } catch (error) {
    console.error('❌ Error resetting admin:', error);
    process.exit(1);
  }
}

resetAdmin();
