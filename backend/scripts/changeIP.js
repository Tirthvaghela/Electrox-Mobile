/**
 * Usage: node backend/scripts/changeIP.js 192.168.1.50
 * Updates the IP in backend/.env and lib/config/constants.dart
 */
const fs = require('fs');
const path = require('path');

const newIP = process.argv[2];
if (!newIP || !/^\d+\.\d+\.\d+\.\d+$/.test(newIP)) {
  console.error('Usage: node backend/scripts/changeIP.js <new-ip>');
  console.error('Example: node backend/scripts/changeIP.js 192.168.1.50');
  process.exit(1);
}

// Update backend/.env
const envPath = path.join(__dirname, '../.env');
let env = fs.readFileSync(envPath, 'utf8');
env = env.replace(/SERVER_HOST=.*/,  `SERVER_HOST=${newIP}`);
fs.writeFileSync(envPath, env);
console.log(`✅ backend/.env → SERVER_HOST=${newIP}`);

// Update lib/config/constants.dart
const dartPath = path.join(__dirname, '../../lib/config/constants.dart');
let dart = fs.readFileSync(dartPath, 'utf8');
dart = dart.replace(/static const String baseUrl = 'http:\/\/[\d.]+:5000\/api'/, 
  `static const String baseUrl = 'http://${newIP}:5000/api'`);
fs.writeFileSync(dartPath, dart);
console.log(`✅ lib/config/constants.dart → baseUrl=http://${newIP}:5000/api`);

console.log('\n🔁 Now restart your backend and rebuild the Flutter app.');
