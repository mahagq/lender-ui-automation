/**
 * Replay a recorded session headlessly.
 * Usage: node replay.js [path/to/recording.js]
 *
 * If no path is given, replays the latest recording in recordings/.
 * Env vars set before running are forwarded into the recording script
 * (e.g. MOBILE=9876543210 OTP=9999 node replay.js).
 */

const { execSync } = require('child_process');
const path = require('path');
const fs = require('fs');

const args = process.argv.slice(2);

// If a specific file is passed, use it. Otherwise find the latest recording.
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

console.log(`Replaying: ${scriptPath}`);
console.log('---');

execSync(`node "${scriptPath}"`, { stdio: 'inherit' });
