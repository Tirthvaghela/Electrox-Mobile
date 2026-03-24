const mongoose = require('mongoose');
const Organization = require('./models/Organization');
const Invitation = require('./models/Invitation');
const { sendOrganizationInvitation } = require('./utils/emailSender');
require('dotenv').config();

async function createFreshOrganization() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Create a new organization
    const organization = await Organization.create({
      name: 'Test Organization ' + Date.now(),
      description: 'A test organization for setup account testing',
      status: 'pending',
      created_by: 'admin@test.com',
      created_at: new Date(),
      updated_at: new Date()
    });

    console.log('✅ Created organization:', organization.name);

    // Create an invitation
    const invitation = await Invitation.create({
      email: 'test@example.com',
      organizer_name: 'Test Organizer',
      organization_id: organization._id,
      token: require('crypto').randomBytes(32).toString('hex'),
      status: 'pending',
      created_at: new Date(),
      expires_at: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000) // 7 days
    });

    console.log('✅ Created invitation with token:', invitation.token);
    console.log('🔗 Setup URL:', `${process.env.FRONTEND_URL || 'http://localhost:3000'}/setup-account?token=${invitation.token}`);

    // Optionally send email (uncomment if you want to test email sending)
    // await sendOrganizationInvitation(
    //   invitation.email,
    //   invitation.organizer_name,
    //   organization.name,
    //   invitation.token
    // );
    // console.log('✅ Invitation email sent');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

createFreshOrganization();