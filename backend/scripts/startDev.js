/**
 * Dev startup script:
 * 1. Starts ngrok on port 5000 (or reads from already-running ngrok)
 * 2. Grabs the live tunnel URL from ngrok's local API
 * 3. Updates backend/.env and Flutter .env with the new SERVER_HOST
 * 4. Starts the backend server
 *
 * Run: node backend/scripts/startDev.js
 */

const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');
const http = require('http');

const BACKEND_ENV = path.join(__dirname, '../.env');
const FLUTTER_ENV = path.join(__dirname, '../../.env');
const NGROK_API = 'http://127.0.0.1:4040/api/tunnels';

function updateEnvFile(filePath, key, value) {
  let content = fs.existsSync(filePath) ? fs.readFileSync(filePath, 'utf8') : '';
  const regex = new RegExp(`^${key}=.*$`, 'm');
  if (regex.test(content)) {
    content = content.replace(regex, `${key}=${value}`);
  } else {
    content += `\n${key}=${value}\n`;
  }
  fs.writeFileSync(filePath, content);
}

function getNgrokUrl(retries = 15) {
  return new Promise((resolve, reject) => {
    let attempts = 0;

    const tryFetch = () => {
      http.get(NGROK_API, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const tunnels = JSON.parse(data).tunnels;
            const https = tunnels.find(t => t.proto === 'https');
            if (https) return resolve(https.public_url);
            // tunnels exist but no https yet, retry
            if (++attempts < retries) {
              setTimeout(tryFetch, 1000);
            } else {
              reject(new Error('No HTTPS tunnel found. Make sure ngrok is running: ngrok http 5000'));
            }
          } catch {
            reject(new Error('Failed to parse ngrok response'));
          }
        });
      }).on('error', () => {
        // ngrok not running yet, try to start it
        if (attempts === 0) {
          console.log('🔄 ngrok not detected, starting it...');
          const ngrok = spawn('ngrok', ['http', '5000'], {
            detached: true,
            stdio: 'ignore',
            shell: true,
          });
          ngrok.unref();
        }
        if (++attempts < retries) {
          console.log(`⏳ Waiting for ngrok... (${attempts}/${retries})`);
          setTimeout(tryFetch, 2000);
        } else {
          reject(new Error('ngrok did not start. Run manually: ngrok http 5000'));
        }
      });
    };

    tryFetch();
  });
}

async function main() {
  console.log('🔍 Checking for ngrok tunnel...');

  try {
    const url = await getNgrokUrl();
    console.log(`✅ ngrok URL: ${url}`);

    updateEnvFile(BACKEND_ENV, 'SERVER_HOST', url);
    console.log(`📝 Updated backend/.env`);

    updateEnvFile(FLUTTER_ENV, 'SERVER_HOST', url);
    console.log(`📝 Updated Flutter .env`);

    console.log('\n🚀 Starting backend server...\n');

    // Start nodemon
    const server = spawn('npx', ['nodemon', 'server.js'], {
      cwd: path.join(__dirname, '..'),
      stdio: 'inherit',
      shell: true,
    });

    server.on('close', (code) => {
      console.log(`\nBackend exited with code ${code}`);
    });

  } catch (err) {
    console.error('❌ Error:', err.message);
    process.exit(1);
  }
}

main();
