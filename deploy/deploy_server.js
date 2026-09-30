const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = 8924;
const server = http.createServer((req, res) => {
  const filename = path.basename(req.url);
  const filePath = path.join(__dirname, filename);
  if (fs.existsSync(filePath)) {
    const data = fs.readFileSync(filePath, 'utf8');
    res.writeHead(200, { 'Content-Type': 'text/plain; charset=utf-8' });
    res.end(data);
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(PORT, '127.0.0.1', () => {
  console.log(`Deploy server running on http://127.0.0.1:${PORT}`);
});
