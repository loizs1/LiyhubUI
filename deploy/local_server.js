const http = require('http');
const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, '..');

const server = http.createServer((req, res) => {
  const urlPath = req.url.replace(/^\//, '');
  const filePath = path.join(dir, urlPath);

  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    const data = fs.readFileSync(filePath, 'utf8');
    res.writeHead(200, {
      'Content-Type': 'text/plain',
      'Access-Control-Allow-Origin': '*'
    });
    res.end(data);
  } else {
    res.writeHead(404);
    res.end('Not found');
  }
});

server.listen(9876, '127.0.0.1', () => {
  console.log('Local UI server running on http://127.0.0.1:9876');
});
