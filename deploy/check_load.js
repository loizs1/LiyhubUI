const fs = require('fs');
const content = fs.readFileSync('d:/vscode/roblox/ui/WindUI.bundle.luau', 'utf8');

const terms = ['dog', 'cat', 'footprints', 'bone', 'heart', 'rabbit', 'paw', 'smile'];
for (const t of terms) {
  const regex = new RegExp(`\\b${t}\\s*=\\s*"([^"]+)"`, 'g');
  let m;
  while ((m = regex.exec(content)) !== null) {
    console.log(t, '=>', m[1]);
  }
}
