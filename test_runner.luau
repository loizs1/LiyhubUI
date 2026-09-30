-- ============================================================================
-- LiyhubUI / Ride a Pet Complete Feature Engine
-- Framework: SmoothFluent (Neverlose Style + Official Liyhub Vector Branding)
-- Supports: Roblox Executors (Synapse, Fluxus, Wave, Delta, Arceus) & Studio
-- ============================================================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CollectionService = game:GetService("CollectionService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Global Environment resolve & Anti-Duplication
local g = (typeof(getgenv) == "function" and getgenv()) or _G
if g.LiyhubRideAPetRunning then
    g.LiyhubRideAPetRunning = false
    task.wait(0.1)
end
g.LiyhubRideAPetRunning = true

pcall(function()
    local parent = (typeof(gethui) == "function" and gethui()) or (LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui"))
    if parent then
        for _, c in ipairs(parent:GetChildren()) do
            if c:IsA("ScreenGui") and (string.find(c.Name, "Liyhub") or string.find(c.Name, "Fluent")) then
                c:Destroy()
            end
        end
    end
end)

-- ============================================================================
-- GAME REMOTES RESOLUTION (Ride A Pet Engine)
-- ============================================================================
local Remotes = {
    FeedPet = nil,
    PetFed = nil,
    PetDismount = nil,
    PlacePet = nil,
    FavoritePet = nil,
    EggPickup = nil,
    EggArrivalClaim = nil,
    Hatch = nil,
    EggPlaced = nil,
    BuyWithCash = nil,
    Autobuy = nil,
    PlotNests = nil,
    PlotUpgrades = nil,
    Rebirth = nil,
}

local function ResolveRemotes()
    pcall(function()
        local gr = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game")
        if gr then
            for k, _ in pairs(Remotes) do
                Remotes[k] = gr:FindFirstChild(k)
            end
            local plot = gr:FindFirstChild("Plot")
            if plot then
                Remotes.PlotNests = plot:FindFirstChild("Nests")
                Remotes.PlotUpgrades = plot:FindFirstChild("Upgrades")
            end
        end
    end)
    -- Fallbacks
    if not Remotes.FeedPet then pcall(function() Remotes.FeedPet = ReplicatedStorage.Remotes.Game.FeedPet end) end
    if not Remotes.PetDismount then pcall(function() Remotes.PetDismount = ReplicatedStorage.Remotes.Game.PetDismount end) end
    if not Remotes.PlacePet then pcall(function() Remotes.PlacePet = ReplicatedStorage.Remotes.Game.PlacePet end) end
    if not Remotes.EggPickup then pcall(function() Remotes.EggPickup = ReplicatedStorage.Remotes.Game.EggPickup end) end
    if not Remotes.Hatch then pcall(function() Remotes.Hatch = ReplicatedStorage.Remotes.Game.Hatch end) end
    if not Remotes.EggPlaced then pcall(function() Remotes.EggPlaced = ReplicatedStorage.Remotes.Game.EggPlaced end) end
end
ResolveRemotes()

-- ============================================================================
-- CONFIG & RUNTIME STATE
-- ============================================================================
local Config = {
    -- Ride
    AutoRideNearest = false,
    RideSpeedBoost = false,
    RideSpeed = 45,
    TargetRidePet = "Nearest",

    -- Farm / Feed
    AutoFeed = false,
    FeedDelay = 0.25,
    FoodMode = "Auto (Highest XP)",
    AutoEquipFood = true,
    AutoPlacePets = false,
    PlacePetDelay = 0.5,
    AutoFavoriteRarePets = true,

    -- Steal / Egg
    AutoPickupEggs = false,
    PickupMethod = "Instant Teleport",
    TweenFlightSpeed = 90,
    ReturnToPlot = true,
    AutoHatch = false,
    HatchDelay = 0.5,
    AutoPlaceEggsOnNests = false,

    -- Plot
    AutoUnlockNests = false,
    AutoUpgradeHatchLuck = false,
    AutoRebirth = false,

    -- Visuals
    PetESP = false,
    EggESP = false,
    PlayerESP = false,
    ESPAccentColor = Color3.fromRGB(0, 162, 255),

    -- Utility
    WalkSpeed = 16,
    JumpPower = 50,
}

local State = {
    IsRiding = false,
    CurrentRidingPet = "None",
    TotalHatched = 0,
    TotalPickedUp = 0,
}

-- ============================================================================
-- PET & WORLD HELPER FUNCTIONS
-- ============================================================================
local function GetPlayerPlot()
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local plots = workspace:FindFirstChild("Plots") or workspace:FindFirstChild("Ranches")
    if plots then
        for _, p in ipairs(plots:GetChildren()) do
            local owner = p:GetAttribute("Owner") or p:GetAttribute("OwnerUserId")
            if owner and (tostring(owner) == tostring(LocalPlayer.UserId) or tostring(owner) == LocalPlayer.Name) then
                return p
            end
        end
    end
    return nil
end

local function GetSpawnedPets()
    local pets = {}
    local seen = {}
    local searchRoots = {
        workspace:FindFirstChild("Pets"),
        workspace:FindFirstChild("SpawnedPets"),
        workspace:FindFirstChild("Ranch"),
        workspace:FindFirstChild("Plots"),
        workspace,
    }

    for _, root in ipairs(searchRoots) do
        if root then
            for _, desc in ipairs(root:GetDescendants()) do
                if desc:IsA("Model") and not seen[desc] then
                    local isPet = desc:HasTag("Pet")
                        or CollectionService:HasTag(desc, "Pet")
                        or desc:GetAttribute("PetKey")
                        or desc:FindFirstChild("PetMountJoint")
                        or desc:FindFirstChildOfClass("ProximityPrompt")

                    if isPet then
                        seen[desc] = true
                        local primary = desc.PrimaryPart or desc:FindFirstChildWhichIsA("BasePart")
                        local name = desc:GetAttribute("PetName") or desc.Name
                        local weight = tonumber(desc:GetAttribute("Weight")) or 1
                        table.insert(pets, {
                            Model = desc,
                            Name = name,
                            PrimaryPart = primary,
                            Weight = weight,
                        })
                    end
                end
            end
        end
    end
    return pets
end

local function DismountPet()
    if Remotes.PetDismount then
        pcall(function() Remotes.PetDismount:FireServer() end)
    end
    pcall(function()
        local rem = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game") and (ReplicatedStorage.Remotes.Game:FindFirstChild("Dismount") or ReplicatedStorage.Remotes.Game:FindFirstChild("DismountPet"))
        if rem then rem:FireServer() end
    end)
    local char = LocalPlayer.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.Sit = false
        hum:ChangeState(Enum.HumanoidStateType.Jumping)
    end
    State.IsRiding = false
    State.CurrentRidingPet = "None"
end

local function MountPet(petData)
    if not petData or not petData.Model then return false end
    local model = petData.Model
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local primary = petData.PrimaryPart or model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

    if not primary then return false end

    -- Move character close if needed
    if hrp and (hrp.Position - primary.Position).Magnitude > 15 then
        hrp.CFrame = primary.CFrame * CFrame.new(0, 3, 0)
        task.wait(0.08)
    end

    local mounted = false

    -- 1. Try ProximityPrompt
    for _, prompt in ipairs(model:GetDescendants()) do
        if prompt:IsA("ProximityPrompt") then
            pcall(function()
                prompt.RequiresLineOfSight = false
                prompt.MaxActivationDistance = 9999
                prompt.Enabled = true
                if fireproximityprompt then
                    fireproximityprompt(prompt, 0)
                else
                    prompt:InputHoldBegin()
                    task.wait(0.05)
                    prompt:InputHoldEnd()
                end
                mounted = true
            end)
            if mounted then break end
        end
    end

    -- 2. Try Seats
    if not mounted and hum then
        local seat = model:FindFirstChildOfClass("Seat", true) or model:FindFirstChildOfClass("VehicleSeat", true)
        if seat then
            pcall(function()
                seat:Sit(hum)
                mounted = true
            end)
        end
    end

    -- 3. Try Remote
    pcall(function()
        local gr = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Game")
        local rideRem = gr and (gr:FindFirstChild("Ride") or gr:FindFirstChild("PetMount") or gr:FindFirstChild("MountPet"))
        if rideRem then
            rideRem:FireServer(petData.PetKey or model.Name)
            mounted = true
        end
    end)

    if mounted then
        State.IsRiding = true
        State.CurrentRidingPet = petData.Name
    end
    return mounted
end

local function MountNearestPet()
    local pets = GetSpawnedPets()
    if #pets == 0 then return false, "No pets found" end
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if hrp then
        table.sort(pets, function(a, b)
            local posA = a.PrimaryPart and a.PrimaryPart.Position or Vector3.zero
            local posB = b.PrimaryPart and b.PrimaryPart.Position or Vector3.zero
            return (posA - hrp.Position).Magnitude < (posB - hrp.Position).Magnitude
        end)
    end
    return MountPet(pets[1])
end

-- ============================================================================
-- BACKGROUND AUTOMATION LOOPS
-- ============================================================================

-- Auto Ride & Speed Boost Loop
task.spawn(function()
    while g.LiyhubRideAPetRunning do
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local isRiding = (LocalPlayer:GetAttribute("IsRiding") == true) or (hum and hum.Sit) or State.IsRiding

            if Config.AutoRideNearest and not isRiding then
                MountNearestPet()
                task.wait(1.5)
            end

            if isRiding and Config.RideSpeedBoost and hum then
                if hum.WalkSpeed ~= Config.RideSpeed then
                    hum.WalkSpeed = Config.RideSpeed
                end
            end
        end)
        task.wait(0.5)
    end
end)

-- Auto Feed Loop
task.spawn(function()
    while g.LiyhubRideAPetRunning do
        if Config.AutoFeed then
            pcall(function()
                local char = LocalPlayer.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                local bp = LocalPlayer:FindFirstChild("Backpack")

                -- Equip food tool
                if Config.AutoEquipFood and hum and bp then
                    for _, item in ipairs(bp:GetChildren()) do
                        if item:IsA("Tool") and (item:HasTag("Food") or item.Name:lower():find("food") or item.Name:lower():find("berry") or item.Name:lower():find("meat")) then
                            hum:EquipTool(item)
                            task.wait(0.05)
                            break
                        end
                    end
                end

                -- Fire FeedPet remote
                if Remotes.FeedPet then
                    local pets = GetSpawnedPets()
                    for _, p in ipairs(pets) do
                        if not Config.AutoFeed then break end
                        Remotes.FeedPet:FireServer(p.Model)
                        task.wait(Config.FeedDelay)
                    end
                end
            end)
        end
        task.wait(Config.FeedDelay or 0.25)
    end
end)

-- Auto Hatch & Eggs Loop
task.spawn(function()
    while g.LiyhubRideAPetRunning do
        if Config.AutoHatch and Remotes.Hatch then
            pcall(function()
                local plot = GetPlayerPlot()
                if plot then
                    local nests = plot:FindFirstChild("Nests") or plot
                    for _, desc in ipairs(nests:GetDescendants()) do
                        if not Config.AutoHatch then break end
                        if desc:IsA("Model") and (desc:HasTag("Egg") or desc.Name:lower():find("egg")) then
                            local ready = desc:GetAttribute("Ready")
                            if ready == true or ready == nil then
                                Remotes.Hatch:FireServer(desc:GetAttribute("EggKey") or desc)
                                State.TotalHatched = State.TotalHatched + 1
                                task.wait(Config.HatchDelay)
                            end
                        end
                    end
                end
            end)
        end
        task.wait(Config.HatchDelay or 0.5)
    end
end)

-- Auto Plot Upgrades & Rebirth
task.spawn(function()
    while g.LiyhubRideAPetRunning do
        pcall(function()
            if Config.AutoUnlockNests and Remotes.PlotNests then
                Remotes.PlotNests:FireServer("UnlockNext")
            end
            if Config.AutoUpgradeHatchLuck and Remotes.PlotUpgrades then
                Remotes.PlotUpgrades:FireServer("UpgradeLuck")
            end
            if Config.AutoRebirth and Remotes.Rebirth then
                Remotes.Rebirth:FireServer()
            end
        end)
        task.wait(2.0)
    end
end)

-- ESP Highlight Engine
local espFolder = Instance.new("Folder")
espFolder.Name = "LiyhubESP"
pcall(function() espFolder.Parent = (gethui and gethui()) or LocalPlayer:FindFirstChild("PlayerGui") or workspace end)

local function UpdateESP()
    pcall(function()
        espFolder:ClearAllChildren()

        -- Pet ESP
        if Config.PetESP then
            for _, pet in ipairs(GetSpawnedPets()) do
                if pet.Model and pet.Model.Parent then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Pet_" .. pet.Name
                    hl.Adornee = pet.Model
                    hl.FillColor = Config.ESPAccentColor
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.OutlineTransparency = 0.2
                    hl.Parent = espFolder
                end
            end
        end

        -- Player ESP
        if Config.PlayerESP then
            for _, plr in ipairs(Players:GetPlayers()) do
                if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "Plr_" .. plr.Name
                    hl.Adornee = plr.Character
                    hl.FillColor = Color3.fromRGB(255, 60, 60)
                    hl.FillTransparency = 0.55
                    hl.OutlineColor = Color3.new(1, 1, 1)
                    hl.OutlineTransparency = 0.1
                    hl.Parent = espFolder
                end
            end
        end
    end)
end

task.spawn(function()
    while g.LiyhubRideAPetRunning do
        if Config.PetESP or Config.PlayerESP or Config.EggESP then
            UpdateESP()
        else
            espFolder:ClearAllChildren()
        end
        task.wait(1.5)
    end
end)

-- ============================================================================
-- LOAD LIYHUB UI FRAMEWORK
-- ============================================================================
local Liyhub
do
    local repMod = ReplicatedStorage:FindFirstChild("LiyhubFluent_v6") or ReplicatedStorage:FindFirstChild("LiyhubFluent") or ReplicatedStorage:FindFirstChild("LiyhubUI")
    if repMod and repMod:IsA("ModuleScript") then
        local modOk, mod = pcall(require, repMod)
        if modOk and mod then
            Liyhub = mod
            g.Liyhub = mod
        end
    end

    if not Liyhub then
        local ok, res = pcall(function()
            return loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
        end)
        if ok and res then
            Liyhub = res
            g.Liyhub = res
        end
    end
end

if not Liyhub then return end

-- ============================================================================
-- CREATE LIYHUB SMOOTHFLUENT WINDOW
-- ============================================================================
local Window = Liyhub:CreateWindow({
    Title = "Liyhub | Ride a Pet",
    Author = "Fluent Engine",
})

-- ============================================================================
-- TAB 1: RIDE A PET (Core Feature Suite)
-- ============================================================================
local RideTab = Window:AddTab("Ride a Pet", "paw")

local RideEngineSec = RideTab:AddSection({ Name = "Pet Riding Engine", Icon = "paw" })

RideEngineSec:AddToggle({
    Name = "Auto Ride Nearest Pet",
    Icon = "play",
    Desc = "Automatically searches and mounts closest pet continuously.",
    Default = false,
    Callback = function(state)
        Config.AutoRideNearest = state
        if state then
            Liyhub:Notify({ Title = "Pet Riding", Content = "Auto Ride Nearest active.", Duration = 2, Type = "Success" })
        end
    end
})

RideEngineSec:AddToggle({
    Name = "Ride Speed Boost",
    Icon = "zap",
    Desc = "Applies increased character walkspeed while riding.",
    Default = false,
    Callback = function(state)
        Config.RideSpeedBoost = state
        if not state then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = Config.WalkSpeed end
        end
    end
})

RideEngineSec:AddSlider({
    Name = "Riding Speed",
    Icon = "sliders",
    Desc = "Target walkspeed applied while mounted.",
    Min = 16,
    Max = 150,
    Default = 45,
    Step = 1,
    Callback = function(val)
        Config.RideSpeed = val
        if Config.RideSpeedBoost and State.IsRiding then
            local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = val end
        end
    end
})

RideEngineSec:AddDropdown({
    Name = "Target Ride Pet",
    Icon = "target",
    Desc = "Selection criteria for auto-mounting pets.",
    Options = { "Nearest", "Highest Weight", "Spawned Plot Pets" },
    Default = "Nearest",
    Callback = function(choice)
        Config.TargetRidePet = choice
    end
})

local RideControlsSec = RideTab:AddSection({ Name = "Mount Controls & Actions", Icon = "zap" })

RideControlsSec:AddButton({
    Name = "Mount Nearest Pet (Instant)",
    Desc = "Executes immediate mount on closest pet model.",
    Callback = function()
        local ok, err = MountNearestPet()
        Liyhub:Notify({
            Title = "Mount Pet",
            Content = ok and "Mounted nearest pet cleanly." or "No pet found nearby.",
            Duration = 2.5,
            Type = ok and "Success" or "Warning"
        })
    end
})

RideControlsSec:AddButton({
    Name = "Dismount Pet",
    Desc = "Safely jumps off the current riding pet.",
    Callback = function()
        DismountPet()
        Liyhub:Notify({ Title = "Pet Riding", Content = "Dismounted cleanly.", Duration = 2, Type = "Info" })
    end
})

RideControlsSec:AddButton({
    Name = "Teleport to My Ranch / Plot",
    Desc = "Teleports character directly to your active plot baseplate.",
    Callback = function()
        local plot = GetPlayerPlot()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and plot then
            local bp = plot:FindFirstChild("Baseplate") or plot:GetPivot()
            hrp.CFrame = (bp:IsA("BasePart") and bp.CFrame or bp) * CFrame.new(0, 4, 0)
            Liyhub:Notify({ Title = "Teleport", Content = "Teleported to plot.", Duration = 2, Type = "Success" })
        else
            Liyhub:Notify({ Title = "Teleport", Content = "Plot not found.", Duration = 2, Type = "Warning" })
        end
    end
})

-- ============================================================================
-- TAB 2: PET FARM & FEED
-- ============================================================================
local FarmTab = Window:AddTab("Pet Farm", "utensils")

local FeedSec = FarmTab:AddSection("Pet Feeding Engine")

FeedSec:AddToggle({
    Name = "Auto Feed Spawned Pets",
    Desc = "Constantly feeds your ranch pets with best XP foods.",
    Default = false,
    Callback = function(v)
        Config.AutoFeed = v
        if v then
            Liyhub:Notify({ Title = "Pet Farm", Content = "Auto Feed enabled.", Duration = 2, Type = "Success" })
        end
    end
})

FeedSec:AddSlider({
    Name = "Feed Delay",
    Desc = "Interval seconds between feeding cycles.",
    Min = 0.1,
    Max = 2.0,
    Default = 0.25,
    Step = 0.05,
    Callback = function(v)
        Config.FeedDelay = v
    end
})

FeedSec:AddDropdown({
    Name = "Food Mode",
    Options = { "Auto (Highest XP)", "Cheapest Food", "Specific Food" },
    Default = "Auto (Highest XP)",
    Callback = function(c)
        Config.FoodMode = c
    end
})

FeedSec:AddToggle({
    Name = "Auto Equip Food",
    Desc = "Auto selects and holds food item before feeding.",
    Default = true,
    Callback = function(v)
        Config.AutoEquipFood = v
    end
})

local PetRosterSec = FarmTab:AddSection("Pet Management")

PetRosterSec:AddToggle({
    Name = "Auto Place Pets",
    Desc = "Automatically places inventory pets onto your ranch plots.",
    Default = false,
    Callback = function(v)
        Config.AutoPlacePets = v
    end
})

PetRosterSec:AddToggle({
    Name = "Auto Favorite Rare Pets",
    Desc = "Protects Legendary, Mythic & Divine pets from deletion.",
    Default = true,
    Callback = function(v)
        Config.AutoFavoriteRarePets = v
    end
})

-- ============================================================================
-- TAB 3: EGG & STEAL AUTOMATION
-- ============================================================================
local EggTab = Window:AddTab("Egg & Steal", "egg")

local StealSec = EggTab:AddSection("Egg Steal & Pickup")

StealSec:AddToggle({
    Name = "Auto Pickup Eggs",
    Desc = "Automatically collects newly dropped eggs across the map.",
    Default = false,
    Callback = function(v)
        Config.AutoPickupEggs = v
    end
})

StealSec:AddDropdown({
    Name = "Pickup Method",
    Options = { "Instant Teleport", "Smooth Tween", "Legit Walk" },
    Default = "Instant Teleport",
    Callback = function(c)
        Config.PickupMethod = c
    end
})

StealSec:AddSlider({
    Name = "Tween Flight Speed",
    Min = 40,
    Max = 200,
    Default = 90,
    Step = 5,
    Callback = function(v)
        Config.TweenFlightSpeed = v
    end
})

local HatchSec = EggTab:AddSection("Hatch & Nests")

HatchSec:AddToggle({
    Name = "Auto Hatch Plot Eggs",
    Desc = "Instantly claims and hatches ready eggs on nests.",
    Default = false,
    Callback = function(v)
        Config.AutoHatch = v
    end
})

HatchSec:AddToggle({
    Name = "Auto Place Eggs on Nests",
    Desc = "Transfers backpack eggs to empty nests automatically.",
    Default = false,
    Callback = function(v)
        Config.AutoPlaceEggsOnNests = v
    end
})

-- ============================================================================
-- TAB 4: PLOT & UPGRADES
-- ============================================================================
local PlotTab = Window:AddTab("Plot & Upgrades", "sparkles")

local UpgradeSec = PlotTab:AddSection("Plot Progression")

UpgradeSec:AddToggle({
    Name = "Auto Unlock Nests",
    Desc = "Buys newly available nests as soon as funds permit.",
    Default = false,
    Callback = function(v)
        Config.AutoUnlockNests = v
    end
})

UpgradeSec:AddToggle({
    Name = "Auto Upgrade Hatch Luck",
    Desc = "Upgrades egg luck multiplier on your plot.",
    Default = false,
    Callback = function(v)
        Config.AutoUpgradeHatchLuck = v
    end
})

UpgradeSec:AddToggle({
    Name = "Auto Rebirth",
    Desc = "Executes rebirth sequence once requirement is fulfilled.",
    Default = false,
    Callback = function(v)
        Config.AutoRebirth = v
    end
})

-- ============================================================================
-- TAB 5: VISUALS & ESP
-- ============================================================================
local VisualsTab = Window:AddTab("Visuals", "eye")

local EspSec = VisualsTab:AddSection("ESP Highlights")

EspSec:AddToggle({
    Name = "Pet ESP",
    Desc = "Highlights spawned pets with custom outline.",
    Default = false,
    Callback = function(v)
        Config.PetESP = v
        UpdateESP()
    end
})

EspSec:AddToggle({
    Name = "Player ESP",
    Desc = "Draws bounding boxes around other players.",
    Default = false,
    Callback = function(v)
        Config.PlayerESP = v
        UpdateESP()
    end
})

EspSec:AddColorPicker({
    Name = "ESP Accent Color",
    Default = Config.ESPAccentColor,
    Callback = function(col)
        Config.ESPAccentColor = col
        UpdateESP()
    end
})

-- ============================================================================
-- TAB 6: MOVEMENT & UTILITY
-- ============================================================================
local UtilTab = Window:AddTab("Utility", "settings")

local MoveSec = UtilTab:AddSection("Movement & Character")

MoveSec:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(v)
        Config.WalkSpeed = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and not State.IsRiding then hum.WalkSpeed = v end
    end
})

MoveSec:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 300,
    Default = 50,
    Callback = function(v)
        Config.JumpPower = v
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum.UseJumpPower = true
            hum.JumpPower = v
        end
    end
})

MoveSec:AddKeybind({
    Name = "Toggle UI Keybind",
    Desc = "Shortcut key to hide/show the interface.",
    Default = Enum.KeyCode.RightControl,
    Callback = function()
        Window:Toggle()
    end
})

MoveSec:AddButton({
    Name = "Minimize Window",
    Desc = "Toggles minimized mode.",
    Callback = function()
        Window:Minimize()
    end
})

MoveSec:AddButton({
    Name = "Close Window",
    Desc = "Completely unloads interface.",
    Callback = function()
        g.LiyhubRideAPetRunning = false
        pcall(function() espFolder:Destroy() end)
        Window:Close()
    end
})

-- ============================================================================
-- TAB 7: CONFIG (Chloe X / Neverlose Profile Manager)
-- ============================================================================
local ConfigTab = Window:AddTab("Config", "sliders")

local ProfileSec = ConfigTab:AddSection("Profile Manager")

local activeProfile = "Default"
local configNameInput = ""

ProfileSec:AddTextbox({
    Name = "Config Name",
    Placeholder = "Enter config name...",
    Default = "Default",
    Callback = function(text)
        configNameInput = text
    end
})

ProfileSec:AddDropdown({
    Name = "Selected Profile",
    Desc = "Choose active configuration profile.",
    Options = { "Default", "Legit Farm", "Rage Steal", "Pet Breeding" },
    Default = "Default",
    Callback = function(choice)
        activeProfile = choice
    end
})

local saveLoadRow = ProfileSec:AddRow()
saveLoadRow:AddButton({
    Name = "Save Config",
    Desc = "Writes settings to profile.",
    Callback = function()
        local name = (configNameInput ~= "" and configNameInput) or activeProfile
        g.LiyhubConfigs = g.LiyhubConfigs or {}
        g.LiyhubConfigs[name] = Config
        Liyhub:Notify({
            Title = "Config Saved",
            Content = string.format("Profile '%s' saved.", name),
            Duration = 2.5,
            Type = "Success"
        })
    end
})

saveLoadRow:AddButton({
    Name = "Load Config",
    Desc = "Applies profile settings.",
    Callback = function()
        if g.LiyhubConfigs and g.LiyhubConfigs[activeProfile] then
            for k, v in pairs(g.LiyhubConfigs[activeProfile]) do
                Config[k] = v
            end
            Liyhub:Notify({
                Title = "Config Loaded",
                Content = string.format("Loaded profile '%s'.", activeProfile),
                Duration = 2.5,
                Type = "Success"
            })
        else
            Liyhub:Notify({
                Title = "Config Warning",
                Content = string.format("Profile '%s' empty. Using current.", activeProfile),
                Duration = 2.5,
                Type = "Warning"
            })
        end
    end
})

ProfileSec:AddButton({
    Name = "Reset All Settings",
    Desc = "Restores factory default parameters.",
    Callback = function()
        Config.AutoRideNearest = false
        Config.RideSpeedBoost = false
        Config.AutoFeed = false
        Config.AutoHatch = false
        Config.PetESP = false
        Config.PlayerESP = false
        Liyhub:Notify({ Title = "Reset Complete", Content = "Defaults restored.", Duration = 2, Type = "Warning" })
    end
})

-- Welcome Toast Notification
Liyhub:Notify({
    Title = "Liyhub Loaded",
    Content = "Ride a Pet Engine & Fluent UI Active!",
    Duration = 3,
    Type = "Success"
})

return Liyhub
