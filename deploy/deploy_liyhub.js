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
            console.log('Connected to Studio instance:', studioId, studios[0].name);

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
            reject(new Error('No active Studio instances found'));
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
          name: 'liyhub-deployer',
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
  console.log('1. Reading optimized LiyhubUI bundle & test runner...');
  const bundlePath = path.join(__dirname, '..', 'LiyhubUI.bundle.luau');
  const runnerPath = path.join(__dirname, '..', 'test_runner.luau');

  const liyhubCode = fs.readFileSync(bundlePath, 'utf8');
  const runnerCode = fs.readFileSync(runnerPath, 'utf8');

  console.log(`- Bundle size: ${liyhubCode.length} characters`);
  console.log(`- Runner size: ${runnerCode.length} characters`);

  console.log('2. Setting up ReplicatedStorage.LiyhubUI on Server DataModel...');
  const setupModuleCode = `
local rs = game:GetService("ReplicatedStorage")
local old = rs:FindFirstChild("LiyhubUI")
if old then old:Destroy() end
local mod = Instance.new("ModuleScript")
mod.Name = "LiyhubUI"
mod.Source = ${JSON.stringify(liyhubCode)}
mod.Parent = rs
return "ReplicatedStorage.LiyhubUI fresh instance uploaded (" .. tostring(#mod.Source) .. " bytes)"
  `;

  const moduleResult = await callStudioMCP('execute_luau', {
    datamodel_type: 'Server',
    code: setupModuleCode
  });
  console.log('Module deployment result:', moduleResult?.content?.[0]?.text);

  console.log('3. Injecting Liyhub test runner to Client DataModel...');
  const injectClientCode = `
local Players = game:GetService("Players")
local lp = Players.LocalPlayer
if not lp then return "No LocalPlayer found" end

local pg = lp:WaitForChild("PlayerGui", 5)
if not pg then return "No PlayerGui found" end

-- Clean previous instances from PlayerGui and CoreGui
for _, c in ipairs(pg:GetChildren()) do
    if c:IsA("ScreenGui") and (string.find(c.Name, "Liyhub") or string.find(c.Name, "Fluent")) then
        c:Destroy()
    end
end
pcall(function()
    local cg = game:GetService("CoreGui")
    if cg then
        for _, c in ipairs(cg:GetChildren()) do
            if c:IsA("ScreenGui") and (string.find(c.Name, "Liyhub") or string.find(c.Name, "Fluent")) then
                c:Destroy()
            end
        end
    end
end)

local oldRunner = pg:FindFirstChild("LiyhubRunner")
if oldRunner then oldRunner:Destroy() end

local sc = Instance.new("Script")
sc.Name = "LiyhubRunner"
sc.RunContext = Enum.RunContext.Client
sc.Source = ${JSON.stringify(runnerCode)}
sc.Parent = pg
return "LiyhubRunner (RunContext=Client) injected into PlayerGui of " .. lp.Name
  `;

  const clientResult = await callStudioMCP('execute_luau', {
    datamodel_type: 'Client',
    code: injectClientCode
  });
  console.log('Client injection result:', clientResult?.content?.[0]?.text);

  console.log('DEPLOYMENT COMPLETE: LiyhubUI is running inside Studio Client!');
}

main().catch(err => {
  console.error('Deployment error:', err.message);
  process.exit(1);
});
