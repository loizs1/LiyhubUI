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
          const studios = msg.result?.content?.[0]?.text ? JSON.parse(msg.result.content[0].text).studios : null;
          if (studios && studios.length > 0) {
            studioId = studios[0].id;
            console.log('Connected to Studio:', studioId);

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

    const initReq = {
      jsonrpc: '2.0',
      id: 1,
      method: 'initialize',
      params: {
        protocolVersion: '2024-11-05',
        capabilities: {},
        clientInfo: {
          name: 'deployer-client',
          version: '1.0.0'
        }
      }
    };
    child.stdin.write(JSON.stringify(initReq) + '\n');

    setTimeout(() => {
      reject(new Error('Timeout waiting for Studio MCP'));
      child.kill();
    }, 45000);
  });
}

async function main() {
  console.log('Reading source files...');
  const mainLuau = fs.readFileSync(path.join(__dirname, 'WindUI_Main.luau'), 'utf8');
  const part1Luau = fs.readFileSync(path.join(__dirname, 'WindUI_Part1.luau'), 'utf8');
  const part2Luau = fs.readFileSync(path.join(__dirname, 'WindUI_Part2.luau'), 'utf8');
  const liyhubLuau = fs.readFileSync(path.join(__dirname, 'LiyhubUI.bundle.luau'), 'utf8');
  const runnerLuau = fs.readFileSync(path.join(__dirname, 'test_runner.luau'), 'utf8');

  console.log('1. Setting up ReplicatedStorage.WindUI and submodules in Server DataModel...');
  const setupCode = `
local rs = game:GetService("ReplicatedStorage")
local w = rs:FindFirstChild("WindUI") or Instance.new("ModuleScript")
w.Name = "WindUI"
w.Parent = rs

local p1 = w:FindFirstChild("Part1") or Instance.new("ModuleScript")
p1.Name = "Part1"
p1.Parent = w

local p2 = w:FindFirstChild("Part2") or Instance.new("ModuleScript")
p2.Name = "Part2"
p2.Parent = w

local l = rs:FindFirstChild("LiyhubUI") or Instance.new("ModuleScript")
l.Name = "LiyhubUI"
l.Parent = rs

return "Containers created"
  `;
  await callStudioMCP('execute_luau', { datamodel_type: 'Server', code: setupCode });

  console.log('2. Uploading WindUI_Main.luau (' + mainLuau.length + ' chars)...');
  await callStudioMCP('execute_luau', {
    datamodel_type: 'Server',
    code: `game:GetService("ReplicatedStorage").WindUI.Source = ${JSON.stringify(mainLuau)} return "Main uploaded"`
  });

  console.log('3. Uploading WindUI_Part1.luau (' + part1Luau.length + ' chars)...');
  await callStudioMCP('execute_luau', {
    datamodel_type: 'Server',
    code: `game:GetService("ReplicatedStorage").WindUI.Part1.Source = ${JSON.stringify(part1Luau)} return "Part1 uploaded"`
  });

  console.log('4. Uploading WindUI_Part2.luau (' + part2Luau.length + ' chars)...');
  await callStudioMCP('execute_luau', {
    datamodel_type: 'Server',
    code: `game:GetService("ReplicatedStorage").WindUI.Part2.Source = ${JSON.stringify(part2Luau)} return "Part2 uploaded"`
  });

  console.log('5. Uploading LiyhubUI.bundle.luau (' + liyhubLuau.length + ' chars)...');
  await callStudioMCP('execute_luau', {
    datamodel_type: 'Server',
    code: `game:GetService("ReplicatedStorage").LiyhubUI.Source = ${JSON.stringify(liyhubLuau)} return "Liyhub uploaded"`
  });

  console.log('6. Deploying test runner to StarterPlayerScripts and LocalPlayer PlayerGui...');
  const deployRunnerCode = `
local sps = game:GetService("StarterPlayer"):FindFirstChild("StarterPlayerScripts")
if sps then
    local old = sps:FindFirstChild("LiyhubRunner")
    if old then old:Destroy() end
    local sc = Instance.new("LocalScript")
    sc.Name = "LiyhubRunner"
    sc.Source = ${JSON.stringify(runnerLuau)}
    sc.Parent = sps
end

local players = game:GetService("Players")
for _, p in ipairs(players:GetPlayers()) do
    local pg = p:FindFirstChild("PlayerGui")
    if pg then
        local old = pg:FindFirstChild("LiyhubRunner")
        if old then old:Destroy() end
        local sc = Instance.new("LocalScript")
        sc.Name = "LiyhubRunner"
        sc.Source = ${JSON.stringify(runnerLuau)}
        sc.Parent = pg
    end
end
return "Runner deployed"
  `;
  await callStudioMCP('execute_luau', {
    datamodel_type: 'Server',
    code: deployRunnerCode
  });

  console.log('ALL MODULES AND RUNNER DEPLOYED CLEANLY TO ROBLOX STUDIO!');
}

main().catch(err => {
  console.error('Deployment failed:', err);
  process.exit(1);
});
