const validator = require('validator');

const validateEmail = (email) => {
  return validator.isEmail(email);
};

const validatePassword = (password) => {
  return password && password.length >= 8;
};

const validateDate = (date) => {
  return !isNaN(Date.parse(date));
};

const validateElectionDates = (startDate, endDate) => {
  const start = new Date(startDate);
  const end = new Date(endDate);
  return end > start;
};

module.exports = {
  validateEmail,
  validatePassword,
  validateDate,
  validateElectionDates
};
