const { spawn } = require('child_process');
const readline = require('readline');
const path = require('path');
const fs = require('fs');

async function callStudioMCP(toolName, args) {
  return new Promise((resolve, reject) => {
    const wrapperPath = path.join(__dirname, '..', 'studio-mcp-wrapper.js');
    const child = spawn('node', [wrapperPath], {
      stdio: ['pipe', 'pipe', 'inherit']
    });

    const rl = readline.createInterface({
      input: child.stdout,
      terminal: false
    });

    let studioId = null;

    rl.on('line', (line) => {
      try {
        const msg = JSON.parse(line);
        if (msg.id === 1) {
          // Initialize response, send notifications/initialized then list studios
          child.stdin.write(JSON.stringify({
            jsonrpc: '2.0',
            method: 'notifications/initialized',
            params: {}
          }) + '\n');

          child.stdin.write(JSON.stringify({
            jsonrpc: '2.0',
            id: 2,
            method: 'tools/call',
            params: {
              name: 'list_roblox_studios',
              arguments: {}
            }
          }) + '\n');
        } else if (msg.id === 2) {
          // list_roblox_studios response
          const studios = msg.result?.content?.[0]?.text ? JSON.parse(msg.result.content[0].text).studios : null;
          if (studios && studios.length > 0) {
            studioId = studios[0].id;
            console.log('Connected to Studio:', studioId, studios[0].name);

            // Call requested tool
            const req = {
              jsonrpc: '2.0',
              id: 3,
              method: 'tools/call',
              params: {
                name: toolName,
                arguments: {
                  studio_id: studioId,
                  ...args
                }
              }
            };
            child.stdin.write(JSON.stringify(req) + '\n');
          } else {
            reject(new Error('No studio instances found'));
            child.kill();
          }
        } else if (msg.id === 3) {
          resolve(msg.result);
          child.kill();
        }
      } catch (err) {
        console.error('Parse error:', err, 'Line:', line);
      }
    });

    // Step 0: initialize handshake
    const initReq = {
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '2024-11-05',
        capabilities: {},
        clientInfo: {
          name: 'studio-wrapper-client',
          version: '1.0.0'
        }
      }
    };
    child.stdin.write(JSON.stringify(initReq) + '\n');

    setTimeout(() => {
      reject(new Error('Timeout waiting for Studio MCP'));
      child.kill();
    }, 15000);
  });
}

// Test call
callStudioMCP('execute_luau', {
  datamodel_type: 'Client',
  code: 'return "STUDIO MCP WRAPPER FULLY CONNECTED: " .. tostring(game:GetService("Players").LocalPlayer.Name)'
}).then(res => {
  console.log('StudioMCP Result:', JSON.stringify(res, null, 2));
}).catch(err => {
  console.error('StudioMCP Error:', err);
});
