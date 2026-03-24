const csv = require('csv-parser');
const { Readable } = require('stream');
const { validateEmail } = require('../middleware/validate');

const parseCSVFile = (fileBuffer) => {
  return new Promise((resolve, reject) => {
    const results = [];
    const errors = [];
    let rowNumber = 0;
    
    const stream = Readable.from(fileBuffer.toString());
    
    stream
      .pipe(csv())
      .on('data', (data) => {
        rowNumber++;
        
        if (!data.name || !data.email) {
          errors.push({ row: rowNumber, error: 'Missing name or email' });
          return;
        }
        
        if (!validateEmail(data.email)) {
          errors.push({ row: rowNumber, error: 'Invalid email format' });
          return;
        }
        
        results.push({
          name: data.name.trim(),
          real_email: data.email.trim().toLowerCase()
        });
      })
      .on('end', () => {
        resolve({ participants: results, errors, total: results.length });
      })
      .on('error', (error) => {
        reject(error);
      });
  });
};

const generatePassword = (length = 10) => {
  const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%';
  let password = '';
  for (let i = 0; i < length; i++) {
    password += chars.charAt(Math.floor(Math.random() * chars.length));
  }
  return password;
};

const generateSystemEmail = (name, role, index, organizationName) => {
  const nameParts = name.toLowerCase().split(' ');
  const firstName = nameParts[0] || 'user';
  const lastName = nameParts[nameParts.length - 1] || 'name';
  const orgSlug = organizationName.toLowerCase().replace(/\s+/g, '');
  
  return `${firstName}.${lastName}.${role}.${index}@${orgSlug}.electrox.com`;
};

module.exports = {
  parseCSVFile,
  generatePassword,
  generateSystemEmail
};
