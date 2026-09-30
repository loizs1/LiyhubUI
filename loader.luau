-- ============================================================================
-- Liyhub | UNIVERSAL GAME LOADER (WindUI Powered)
-- Official Single-Loadstring Entrypoint (https://github.com/loizs1/LiyhubUI)
-- ============================================================================
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
if not Liyhub then return end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

local gameTitle = "Universal"
pcall(function()
    local MarketplaceService = game:GetService("MarketplaceService")
    local info = MarketplaceService:GetProductInfo(PlaceId)
    if info and info.Name then
        gameTitle = info.Name
    end
end)

-- ============================================================================
-- 1. JAILBREAK (PlaceId: 6068496214)
-- ============================================================================
if PlaceId == 6068496214 then
    local Window = Liyhub:CreateWindow({
        Title = "Liyhub | Jailbreak",
        Icon = "solar:shield-bold-duotone",
        Folder = "Liyhub_Jailbreak",
        Size = UDim2.fromOffset(740, 490)
    })

    local MainTab = Window:AddTab("Main", "solar:car-bold-duotone")
    local Sec = MainTab:AddSection("Automation")
    Sec:AddToggle({
        Name = "Auto Arrest Criminals",
        Desc = "Automatically targets and cuffs criminals in range",
        Default = false,
        Callback = function(v)
            -- Jailbreak arrest logic
        end
    })

-- ============================================================================
-- 2. BLOX FRUITS (PlaceIds: 2753915549, 4442272183, 7449423635)
-- ============================================================================
elseif PlaceId == 2753915549 or PlaceId == 4442272183 or PlaceId == 7449423635 then
    local Window = Liyhub:CreateWindow({
        Title = "Liyhub | Blox Fruits",
        Icon = "solar:sword-bold-duotone",
        Folder = "Liyhub_BloxFruits",
        Size = UDim2.fromOffset(740, 490)
    })

    local FarmTab = Window:AddTab("Auto Farm", "solar:flame-bold-duotone")
    local FarmSec = FarmTab:AddSection("Level Farming")
    FarmSec:AddToggle({
        Name = "Auto Farm Level",
        Desc = "Auto accepts quests and attacks targeted mobs",
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
        Title = "Liyhub | Arsenal",
        Icon = "solar:target-bold-duotone",
        Folder = "Liyhub_Arsenal",
        Size = UDim2.fromOffset(740, 490)
    })

    local CombatTab = Window:AddTab("Combat", "solar:crosshair-bold-duotone")
    local AimSec = CombatTab:AddSection("Targeting")
    AimSec:AddToggle({
        Name = "Silent Aim",
        Desc = "Redirects bullet rays directly to enemy head hitbox",
        Default = false,
        Callback = function(v)
            -- Arsenal logic
        end
    })

-- ============================================================================
-- 4. RIDE A PET (PlaceId: 124216119978534)
-- ============================================================================
elseif PlaceId == 124216119978534 or gameTitle:find("Ride a Pet") or gameTitle:find("Ride A Pet") then
    local Window = Liyhub:CreateWindow({
        Title = "Liyhub | Ride a Pet",
        Icon = "paw",
        Folder = "Liyhub_RideAPet",
        Size = UDim2.fromOffset(740, 490),
        HideFullscreen = true,
        Topbar = {
            Height = 44,
            ButtonsType = "Default",
        }
    })

    local RideTab = Window:AddTab("Ride a Pet", "paw")
    local RideSec = RideTab:AddSection("Pet Riding Engine")

    RideSec:AddToggle({
        Name = "Auto Ride Nearest",
        Desc = "Automatically mounts closest pet in your plot/world",
        Default = false,
        Callback = function(v) end
    })

    RideSec:AddToggle({
        Name = "Ride Speed Boost",
        Desc = "Enhances ride velocity",
        Default = false,
        Callback = function(v) end
    })

    RideSec:AddSlider({
        Name = "Riding Speed",
        Min = 16,
        Max = 150,
        Default = 45,
        Callback = function(v) end
    })

    local FarmTab = Window:AddTab("Pet Farm", "utensils")
    local FeedSec = FarmTab:AddSection("Pet Feeding")

    FeedSec:AddToggle({
        Name = "Auto Feed Pets",
        Desc = "Feeds pets automatically with highest XP food",
        Default = false,
        Callback = function(v) end
    })

    local StealTab = Window:AddTab("Egg & Steal", "egg")
    local StealSec = StealTab:AddSection("Egg Automation")

    StealSec:AddToggle({
        Name = "Auto Pickup Eggs",
        Desc = "Steals and collects world eggs",
        Default = false,
        Callback = function(v) end
    })

    StealSec:AddToggle({
        Name = "Auto Hatch Plot Eggs",
        Default = false,
        Callback = function(v) end
    })

-- ============================================================================
-- 5. UNIVERSAL FALLBACK (Any Roblox Game)
-- ============================================================================
else
    local Window = Liyhub:CreateWindow({
        Title = "Liyhub | " .. gameTitle,
        Icon = "solar:box-bold-duotone",
        Folder = "Liyhub_Universal",
        Size = UDim2.fromOffset(740, 490),
        HideFullscreen = true,
        Topbar = {
            Height = 44,
            ButtonsType = "Default",
        }
    })

    local MainTab = Window:AddTab("Movement", "solar:running-bold-duotone")
    local MoveSec = MainTab:AddSection("Speed & Jump")

    MoveSec:AddSlider({
        Name = "WalkSpeed",
        Desc = "Adjust character walking speed",
        Min = 16,
        Max = 250,
        Default = 16,
        Callback = function(v)
            local char = LocalPlayer and LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.WalkSpeed = v
            end
        end
    })

    MoveSec:AddSlider({
        Name = "JumpPower",
        Desc = "Adjust character jump power",
        Min = 50,
        Max = 350,
        Default = 50,
        Callback = function(v)
            local char = LocalPlayer and LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.UseJumpPower = true
                hum.JumpPower = v
            end
        end
    })

    local VisualTab = Window:AddTab("Visuals", "solar:eye-bold-duotone")
    local EspSec = VisualTab:AddSection("Highlights")
    EspSec:AddToggle({
        Name = "Player Box Chams",
        Desc = "Draws highlighted chams over other players",
        Default = false,
        Callback = function(v)
            -- Universal ESP logic
        end
    })
end

-- Notification feedback
Liyhub:Notify({
    Title = "Liyhub Loaded",
    Content = "Connected to " .. gameTitle,
    Duration = 2.5,
    Type = "Success"
})
