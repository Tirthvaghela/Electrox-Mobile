/**
 * Syncs SERVER_HOST from backend/.env to the Flutter root .env
 * Run: node backend/scripts/syncEnv.js
 */
const fs = require('fs');
const path = require('path');

const backendEnvPath = path.join(__dirname, '../.env');
const flutterEnvPath = path.join(__dirname, '../../.env');

const backendEnv = fs.readFileSync(backendEnvPath, 'utf8');

const match = backendEnv.match(/^SERVER_HOST=(.+)$/m);
if (!match) {
  console.error('❌ SERVER_HOST not found in backend/.env');
  process.exit(1);
}

const serverHost = match[1].trim();

// Read existing Flutter .env and replace or append SERVER_HOST
let flutterEnv = '';
if (fs.existsSync(flutterEnvPath)) {
  flutterEnv = fs.readFileSync(flutterEnvPath, 'utf8');
}

if (/^SERVER_HOST=.*/m.test(flutterEnv)) {
  flutterEnv = flutterEnv.replace(/^SERVER_HOST=.*/m, `SERVER_HOST=${serverHost}`);
} else {
  flutterEnv += `\nSERVER_HOST=${serverHost}\n`;
}

fs.writeFileSync(flutterEnvPath, flutterEnv);
console.log(`✅ Synced SERVER_HOST=${serverHost} → Flutter .env`);
