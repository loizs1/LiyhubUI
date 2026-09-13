-- ============================================================================
-- LIYHUB.CC | UNIVERSAL GAME LOADER
-- Official Single-Loadstring Entrypoint (Chloe X / Neverlose Architecture)
-- ============================================================================
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- Game name is automatically resolved by Liyhub via MarketplaceService (or "Universal" fallback)
local gameTitle = Liyhub.GameName or "Universal"

-- ============================================================================
-- 1. JAILBREAK (PlaceId: 6068496214)
-- ============================================================================
if PlaceId == 6068496214 then
    local Window = Liyhub:CreateWindow({
        Title = "LiyHub | Jailbreak",
        Size = UDim2.fromOffset(740, 490)
    })
    local MainTab = Window:AddTab("Main", "🚗")
    local Sec = MainTab:AddSection("Automation", "Left")
    Sec:AddToggle({
        Name = "Auto Arrest Criminals",
        Default = false,
        Callback = function(v)
            -- Jailbreak logic
        end
    })

-- ============================================================================
-- 2. BLOX FRUITS (PlaceIds: 2753915549, 4442272183, 7449423635)
-- ============================================================================
elseif PlaceId == 2753915549 or PlaceId == 4442272183 or PlaceId == 7449423635 then
    local Window = Liyhub:CreateWindow({
        Title = "LiyHub | Blox Fruits",
        Size = UDim2.fromOffset(740, 490)
    })
    local FarmTab = Window:AddTab("Auto Farm", "⚔️")
    local FarmSec = FarmTab:AddSection("Level Farming", "Left")
    FarmSec:AddToggle({
        Name = "Auto Farm Level",
        Default = false,
        Callback = function(v)
            -- Blox Fruits logic
        end
    })

-- ============================================================================
-- 3. ARSENAL (PlaceId: 286090424)
-- ============================================================================
elseif PlaceId == 286090424 then
    local Window = Liyhub:CreateWindow({
        Title = "LiyHub | Arsenal",
        Size = UDim2.fromOffset(740, 490)
    })
    local CombatTab = Window:AddTab("Combat", "🎯")
    local AimSec = CombatTab:AddSection("Targeting", "Left")
    AimSec:AddToggle({
        Name = "Silent Aim",
        Default = false,
        Callback = function(v)
            -- Arsenal logic
        end
    })

-- ============================================================================
-- 4. UNIVERSAL FALLBACK (Any Roblox Game)
-- ============================================================================
else
    local Window = Liyhub:CreateWindow({
        Title = "LiyHub | " .. gameTitle,
        Size = UDim2.fromOffset(740, 490)
    })

    local MainTab = Window:AddTab("Movement", "🏃")
    local MoveSec = MainTab:AddSection("Character Speed", "Left")
    local JumpSec = MainTab:AddSection("Jump & Physics", "Right")

    MoveSec:AddSlider({
        Name = "WalkSpeed",
        Min = 16,
        Max = 250,
        Default = 16,
        Callback = function(v)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = v
            end
        end
    })

    JumpSec:AddSlider({
        Name = "JumpPower",
        Min = 50,
        Max = 350,
        Default = 50,
        Callback = function(v)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.UseJumpPower = true
                char.Humanoid.JumpPower = v
            end
        end
    })

    local VisualTab = Window:AddTab("Visuals", "👁")
    local EspSec = VisualTab:AddSection("Highlights", "Left")
    EspSec:AddToggle({
        Name = "Player Box Chams",
        Default = false,
        Callback = function(v)
            -- Universal ESP
        end
    })
end

-- Notification feedback
Liyhub:Notify({
    Title = "LiyHub",
    Content = "Connected to " .. gameTitle,
    Duration = 2.5,
    Type = "Success"
})
