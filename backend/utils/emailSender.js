const transporter = require('../config/email');

const sendEmail = async (toEmail, subject, htmlBody) => {
  try {
    await transporter.sendMail({
      from: `"Electrox" <${process.env.SMTP_USER}>`,
      to: toEmail,
      subject,
      html: htmlBody
    });
    return { success: true };
  } catch (error) {
    console.error('Email sending error:', error);
    return { success: false, error: error.message };
  }
};

const sendCredentialsEmail = async (toEmail, name, systemEmail, password, electionTitle, role) => {
  const subject = `Your Electrox Credentials - ${electionTitle}`;
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #14213D; color: white; padding: 20px; text-align: center; }
        .content { background: #f8f9fa; padding: 30px; }
        .credentials { background: white; padding: 20px; border-left: 4px solid #FCA311; margin: 20px 0; }
        .button { background: #FCA311; color: white; padding: 12px 30px; text-decoration: none; display: inline-block; border-radius: 5px; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🗳️ Electrox Voting Platform</h1>
        </div>
        <div class="content">
          <h2>Hello ${name},</h2>
          <p>You have been registered as a <strong>${role}</strong> for the election: <strong>${electionTitle}</strong></p>
          
          <div class="credentials">
            <h3>Your Login Credentials:</h3>
            <p><strong>Email:</strong> ${systemEmail}</p>
            <p><strong>Password:</strong> ${password}</p>
          </div>
          
          <p>Please keep these credentials secure. You can change your password after logging in.</p>
          
          <p style="text-align: center; margin: 30px 0;">
            <a href="${process.env.SERVER_HOST}/api/auth/app-redirect?path=login" class="button">Login to Electrox</a>
          </p>
          
          <p><strong>Security Notice:</strong> Never share your credentials with anyone. Electrox staff will never ask for your password.</p>
        </div>
        <div class="footer">
          <p>© 2025 Electrox. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;
  
  return await sendEmail(toEmail, subject, html);
};

const sendOrganizationInvitation = async (toEmail, organizerName, organizationName, token) => {
  const setupLink = `${process.env.SERVER_HOST}/api/auth/setup-account?token=${token}`;

  const subject = `Invitation to Manage ${organizationName} on Electrox`;
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #14213D; color: white; padding: 20px; text-align: center; }
        .content { background: #f8f9fa; padding: 30px; }
        .button { background: #FCA311; color: white; padding: 12px 30px; text-decoration: none; display: inline-block; border-radius: 5px; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🗳️ Electrox Invitation</h1>
        </div>
        <div class="content">
          <h2>Hello ${organizerName},</h2>
          <p>You have been invited to manage elections for <strong>${organizationName}</strong> on the Electrox platform.</p>
          
          <p>As an organizer, you will be able to:</p>
          <ul>
            <li>Create and manage elections</li>
            <li>Add candidates and voters</li>
            <li>Monitor election progress</li>
            <li>View results and analytics</li>
          </ul>
          
          <p style="text-align: center; margin: 30px 0;">
            <a href="${setupLink}" class="button">Setup Your Account</a>
          </p>
          
          <p><strong>Note:</strong> This invitation expires in 48 hours.</p>
          
          <p style="font-size: 13px; color: #666;">
            If the button above doesn't work, copy and paste this link into your browser or phone:<br>
            <span style="word-break: break-all; color: #14213D; font-family: monospace; font-size: 12px;">${setupLink}</span>
          </p>
        </div>
        <div class="footer">
          <p>© 2025 Electrox. All rights reserved.</p>
        </div>
      </div>
    </body>
    </html>
  `;
  
  return await sendEmail(toEmail, subject, html);
};

const sendElectionNotification = async (toEmail, name, electionTitle, notificationType, details = {}) => {
  let subject, message;
  
  switch (notificationType) {
    case 'election_started':
      subject = `Election Started: ${electionTitle}`;
      message = `The election "${electionTitle}" is now active. You can cast your vote now.`;
      break;
    case 'election_closed':
      subject = `Election Closed: ${electionTitle}`;
      message = `The election "${electionTitle}" has been closed. Results are being compiled.`;
      break;
    case 'vote_confirmed':
      subject = `Vote Confirmed: ${electionTitle}`;
      message = `Your vote in "${electionTitle}" has been recorded successfully.`;
      break;
    case 'election_reminder':
      subject = `Reminder: Vote in ${electionTitle}`;
      message = `You haven't voted yet in "${electionTitle}". The election ends on ${details.endDate}.`;
      break;
    default:
      subject = `Notification: ${electionTitle}`;
      message = details.message || 'You have a new notification.';
  }
  
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #14213D; color: white; padding: 20px; text-align: center; }
        .content { background: #f8f9fa; padding: 30px; }
        .button { background: #FCA311; color: white; padding: 12px 30px; text-decoration: none; display: inline-block; border-radius: 5px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🗳️ Electrox</h1>
        </div>
        <div class="content">
          <h2>Hello ${name},</h2>
          <p>${message}</p>
          <p style="text-align: center; margin: 30px 0;">
            <a href="${process.env.FRONTEND_URL}/login" class="button">Go to Electrox</a>
          </p>
        </div>
      </div>
    </body>
    </html>
  `;
  
  return await sendEmail(toEmail, subject, html);
};

const sendPasswordResetEmail = async (toEmail, name, resetToken) => {
  const resetLink = `${process.env.FRONTEND_URL}/reset-password?token=${resetToken}`;
  const subject = 'Password Reset Request - Electrox';
  const html = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
        .container { max-width: 600px; margin: 0 auto; padding: 20px; }
        .header { background: #14213D; color: white; padding: 20px; text-align: center; }
        .content { background: #f8f9fa; padding: 30px; }
        .button { background: #FCA311; color: white; padding: 12px 30px; text-decoration: none; display: inline-block; border-radius: 5px; }
        .warning { background: #fff3cd; padding: 15px; border-left: 4px solid #ffc107; margin: 20px 0; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <h1>🗳️ Electrox</h1>
        </div>
        <div class="content">
          <h2>Hello ${name},</h2>
          <p>We received a request to reset your password. Click the button below to create a new password:</p>
          
          <p style="text-align: center; margin: 30px 0;">
            <a href="${resetLink}" class="button">Reset Password</a>
          </p>
          
          <div class="warning">
            <strong>Security Notice:</strong>
            <ul>
              <li>This link expires in 1 hour</li>
              <li>If you didn't request this, please ignore this email</li>
              <li>Never share this link with anyone</li>
            </ul>
          </div>
        </div>
      </div>
    </body>
    </html>
  `;
  
  return await sendEmail(toEmail, subject, html);
};

module.exports = {
  sendEmail,
  sendCredentialsEmail,
  sendOrganizationInvitation,
  sendElectionNotification,
  sendPasswordResetEmail
};
