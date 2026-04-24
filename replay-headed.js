/**
 * Replay a recorded session in headed mode (visible browser).
 * Usage: node replay-headed.js [path/to/recording.js]
 *
 * If no path is given, replays the latest recording in recordings/.
 * This patches the recorded script to run headed + slow-mo so you can watch it.
 * Env vars set before running are forwarded into the recording script
 * (e.g. MOBILE=9876543210 OTP=9999 node replay-headed.js).
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');
const os = require('os');

const args = process.argv.slice(2);
let scriptPath;

if (args[0]) {
  scriptPath = path.resolve(args[0]);
} else {
  const recordingsDir = path.join(__dirname, 'recordings');
  if (!fs.existsSync(recordingsDir)) {
    console.error('No recordings directory found. Run record.sh first.');
    process.exit(1);
  }
  const files = fs.readdirSync(recordingsDir)
    .filter(f => f.endsWith('.js'))
    .sort()
    .reverse();

  if (files.length === 0) {
    console.error('No recordings found. Run record.sh first.');
    process.exit(1);
  }
  scriptPath = path.join(recordingsDir, files[0]);
  console.log(`No file specified. Using latest: ${files[0]}`);
}

if (!fs.existsSync(scriptPath)) {
  console.error(`File not found: ${scriptPath}`);
  process.exit(1);
}

// Read the recorded script and patch it to run headed with slowMo
let code = fs.readFileSync(scriptPath, 'utf-8');

// Replace headless launch with headed + slowMo
code = code.replace(
  /chromium\.launch\(\)/g,
  "chromium.launch({ headless: false, slowMo: 500 })"
);

// Also handle the case where headless is already set to false but slowMo is missing
code = code.replace(
  /chromium\.launch\(\{\s*headless:\s*false\s*\}\)/g,
  "chromium.launch({ headless: false, slowMo: 500 })"
);

// Write to a temp file and execute
const tmpFile = path.join(os.tmpdir(), `replay_headed_${Date.now()}.js`);
fs.writeFileSync(tmpFile, code);

console.log(`Replaying (headed, slowMo=500ms): ${scriptPath}`);
console.log('---');

try {
  execSync(`node "${tmpFile}"`, { stdio: 'inherit' });
} finally {
  fs.unlinkSync(tmpFile);
}
