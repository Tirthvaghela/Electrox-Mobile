const crypto = require('crypto');

const generateToken = (length = 32) => {
  return crypto.randomBytes(length).toString('hex');
};

module.exports = { generateToken };
