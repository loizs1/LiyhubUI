const { spawn } = require('child_process');
const readline = require('readline');
const path = require('path');
const fs = require('fs');

const localAppData = process.env.LOCALAPPDATA || 'C:\\Users\\simlo\\AppData\\Local';
const versionsDir = path.join(localAppData, 'Roblox', 'Versions');
let studioMcpPath = null;

if (fs.existsSync(versionsDir)) {
  const dirs = fs.readdirSync(versionsDir);
  for (const d of dirs) {
    const candidate = path.join(versionsDir, d, 'StudioMCP.exe');
    if (fs.existsSync(candidate)) {
      studioMcpPath = candidate;
      break;
    }
  }
}

if (!studioMcpPath) {
  console.error("StudioMCP.exe not found");
  process.exit(1);
}

const child = spawn(studioMcpPath, process.argv.slice(2), {
  stdio: ['pipe', 'pipe', 'inherit']
});

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout,
  terminal: false
});

rl.on('line', (line) => {
  if (!line.trim()) return;
  try {
    const msg = JSON.parse(line);
    if (msg && msg.method === 'server/discover') {
      process.stdout.write(JSON.stringify({
        jsonrpc: '2.0',
        id: msg.id,
        result: {}
      }) + '\n');
      return;
    }
  } catch (e) {}
  child.stdin.write(line + '\n');
});

child.stdout.on('data', (data) => {
  process.stdout.write(data);
});

child.on('exit', (code) => {
  process.exit(code || 0);
});
