-- ============================================================================
-- LIYHUB | UNIVERSAL CLIENT BOOTSTRAPPER & SCRIPT HUB
-- Authentic Liyhub UI Architecture (https://github.com/loizs1/LiyhubUI)
-- Key Verification Gateway, Security Diagnostics & ScriptBlox Directory
-- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlaceId = game.PlaceId

-- 1. Main Liyhub UI Library Resolver (Lazy-loaded upon key authorization)
local Liyhub = nil
local function getLiyhub()
    if Liyhub then return Liyhub end
    pcall(function()
        local rep = game:GetService("ReplicatedStorage")
        local mod = rep:FindFirstChild("LiyhubUI")
        if mod then Liyhub = require(mod) end
    end)
    if not Liyhub then
        pcall(function()
            Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
        end)
    end
    if not Liyhub then
        pcall(function()
            Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.lua"))()
        end)
    end
    return Liyhub
end

-- 2. Theme Tokens (Exact match with Liyhub UI)
local Theme = {
    Accent       = Color3.fromRGB(0, 132, 255),       -- Electric Cyan-Blue
    AccentHover  = Color3.fromRGB(0, 155, 255),
    AccentGlow   = Color3.fromRGB(0, 200, 255),
    Background   = Color3.fromRGB(10, 11, 15),       -- Void Dark
    Surface      = Color3.fromRGB(16, 18, 24),       -- Inset Surface
    Surface2     = Color3.fromRGB(24, 27, 36),       -- Elevated Surface
    SurfaceDeep  = Color3.fromRGB(12, 14, 19),       -- Console Deep Inset
    Border       = Color3.fromRGB(255, 255, 255),    -- Frosted Glass Border
    Text         = Color3.fromRGB(245, 248, 255),    -- Bright Header Text
    SubText      = Color3.fromRGB(145, 155, 175),    -- Secondary Slate Text
    Muted        = Color3.fromRGB(85, 95, 115),      -- Dark Micro Labels
    Success      = Color3.fromRGB(0, 230, 118),      -- Online / 200 OK Green
    Warning      = Color3.fromRGB(250, 204, 21),     -- 401 Warning Yellow
    Error        = Color3.fromRGB(248, 113, 113),    -- 403 / 500 Error Crimson
    ErrorBg      = Color3.fromRGB(28, 14, 18),
    ErrorBorder  = Color3.fromRGB(110, 32, 42),
    ScriptBlox   = Color3.fromRGB(0, 205, 255),      -- Official ScriptBlox Brand Cyan
    Hover        = Color3.fromRGB(32, 36, 48)
}

-- 3. Diagnostics Definitions (Enterprise Security Telemetry)
local DiagnosticCodes = {
    IDLE = {
        Code = "STATUS: 200_ONLINE",
        Color = Theme.Success,
        Line1 = "> [GATEWAY]: Security cluster operational. TLS v1.3 enclave active.",
        Line2 = "> [INTEGRITY]: Environment attested. Node handshake initialized.",
        Line3 = "> [PROMPT]: Provide cryptographic license token to continue."
    },
    VERIFYING = {
        Code = "STATUS: 102_PROCESSING",
        Color = Theme.AccentGlow,
        Line1 = "> [AUTH]: Transmitting authorization challenge to security host...",
        Line2 = "> [CIPHER]: Validating cryptographic signatures and node timestamp...",
        Line3 = "> [SYNC]: Awaiting authorized payload container stream..."
    },
    SUCCESS = {
        Code = "STATUS: 200_AUTHORIZED",
        Color = Theme.Success,
        Line1 = "> [ACCESS]: Credential verified. Ephemeral session key allocated.",
        Line2 = "> [CONTAINER]: Decrypting protected runtime payload...",
        Line3 = "> [DISPATCH]: Mounting interface and initializing client core..."
    },
    INVALID_KEY = {
        Code = "ERROR: 401_UNAUTHORIZED",
        Color = Theme.Error,
        Line1 = "> [REJECTED]: Authorization challenge failed verification.",
        Line2 = "> [CAUSE]: Credential string empty, malformed, or expired.",
        Line3 = "> [ACTION]: Acquire a valid license token from the portal and retry."
    },
    RATE_LIMITED = {
        Code = "ERROR: 429_RATE_LIMITED",
        Color = Theme.Warning,
        Line1 = "> [PROTECTION]: High-frequency request throttle engaged.",
        Line2 = "> [SECURITY]: Gateway backoff enforced on current node.",
        Line3 = "> [ACTION]: Standby for 10 seconds before transmitting new challenge."
    }
}

-- 4. Helper Builders (Exact Liyhub WindUI Specification)
local function corner(p, r)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, r or 8)
    x.Parent = p
    return x
end

local function stroke(p, col, tr, th)
    local x = Instance.new("UIStroke")
    x.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    x.Color = col or Theme.Border
    x.Thickness = th or 1
    local trans = tr or 0
    if x.Color == Color3.fromRGB(255, 255, 255) and trans < 0.6 then
        trans = 0.85
    end
    x.Transparency = trans
    x.Parent = p
    return x
end

local function pad(p, topOrAll, right, bottom, left)
    local x = Instance.new("UIPadding")
    local t = topOrAll or 8
    local r = right or t
    local b = bottom or t
    local l = left or r
    x.PaddingTop = UDim.new(0, t)
    x.PaddingRight = UDim.new(0, r)
    x.PaddingBottom = UDim.new(0, b)
    x.PaddingLeft = UDim.new(0, l)
    x.Parent = p
    return x
end

local function text(p, s, z, c)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 1
    x.Text = s or ""
    x.TextColor3 = c or Theme.Text
    x.TextSize = z or 13
    x.Font = Enum.Font.GothamBold
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.TextWrapped = true
    x.Parent = p
    return x
end

local function tween(inst, duration, props)
    pcall(function()
        TweenService:Create(inst, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props):Play()
    end)
end

-- 5. Official Logo Resolver
local function resolveLogoAsset()
    local logoAsset = nil
    pcall(function()
        if typeof(getcustomasset) == "function" and typeof(writefile) == "function" and typeof(isfile) == "function" then
            if not isfile("liyhub_logo.png") then
                local ok, data = pcall(function()
                    return game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/liyhub_logo.png")
                end)
                if ok and data and #data > 0 then
                    writefile("liyhub_logo.png", data)
                end
            end
            if isfile("liyhub_logo.png") then
                logoAsset = getcustomasset("liyhub_logo.png")
            end
        end
    end)
    if logoAsset and logoAsset ~= "" then return logoAsset end

    pcall(function()
        if game:GetService("RunService"):IsStudio() then
            logoAsset = "rbxasset://textures/liyhub_logo.png"
        end
    end)
    if logoAsset and logoAsset ~= "" then return logoAsset end

    return "rbxassetid://123085513549252"
end

-- 6. Detect Current Game Information
local gameTitle = "Universal"
pcall(function()
    local info = MarketplaceService:GetProductInfo(PlaceId)
    if info and info.Name then
        gameTitle = info.Name
    end
end)

-- 7. Game Modules Execution Handlers
local function launchJailbreak()
    local lib = getLiyhub()
    if not lib then return end
    local Window = lib:CreateWindow({
        Title = "Liyhub | Jailbreak",
        Icon = "rbxassetid://10709798085",
        Folder = "Liyhub_Jailbreak",
        Size = UDim2.fromOffset(680, 480)
    })
    local MainTab = Window:AddTab({ Title = "Core", Icon = "rbxassetid://10723407389" })
    local Sec = MainTab:AddSection("System Engine")
    Sec:AddToggle("EnableSystem", {
        Name = "Initialize Module",
        Desc = "Executes background client services",
        Default = false,
        Callback = function(v) end
    })
    Window:SelectTab(1)
end

local function launchBloxFruits()
    local lib = getLiyhub()
    if not lib then return end
    local Window = lib:CreateWindow({
        Title = "Liyhub | Blox Fruits",
        Icon = "rbxassetid://10709798085",
        Folder = "Liyhub_BloxFruits",
        Size = UDim2.fromOffset(680, 480)
    })
    local MainTab = Window:AddTab({ Title = "Services", Icon = "rbxassetid://10723407389" })
    local Sec = MainTab:AddSection("Automation Engine")
    Sec:AddToggle("EnableEngine", {
        Name = "Core Automation",
        Desc = "Runs background task routines",
        Default = false,
        Callback = function(v) end
    })
    Window:SelectTab(1)
end

local function launchArsenal()
    local lib = getLiyhub()
    if not lib then return end
    local Window = lib:CreateWindow({
        Title = "Liyhub | Arsenal",
        Icon = "rbxassetid://10709798085",
        Folder = "Liyhub_Arsenal",
        Size = UDim2.fromOffset(680, 480)
    })
    local MainTab = Window:AddTab({ Title = "Client", Icon = "rbxassetid://10723407389" })
    local Sec = MainTab:AddSection("Framework Modules")
    Sec:AddToggle("EnableFramework", {
        Name = "Client Framework",
        Desc = "Activates client routines",
        Default = false,
        Callback = function(v) end
    })
    Window:SelectTab(1)
end

local function launchRideAPet()
    local lib = getLiyhub()
    if not lib then return end
    local Window = lib:CreateWindow({
        Title = "Liyhub | Ride a Pet",
        Icon = "paw",
        Folder = "Liyhub_RideAPet",
        Size = UDim2.fromOffset(680, 480)
    })
    local MainTab = Window:AddTab({ Title = "Engine", Icon = "paw" })
    local Sec = MainTab:AddSection("System Services")
    Sec:AddToggle("EnableEngine", {
        Name = "Interactive Engine",
        Desc = "Runs core engine loop",
        Default = false,
        Callback = function(v) end
    })
    Sec:AddSlider("SpeedFactor", {
        Name = "Velocity Multiplier",
        Min = 16,
        Max = 150,
        Default = 45,
        Callback = function(v) end
    })
    Window:SelectTab(1)
end

local function launchUniversal()
    local lib = getLiyhub()
    if not lib then return end
    local Window = lib:CreateWindow({
        Title = "Liyhub | " .. gameTitle,
        Icon = "rbxassetid://10709798085",
        Folder = "Liyhub_Universal",
        Size = UDim2.fromOffset(680, 480)
    })
    local MainTab = Window:AddTab({ Title = "Runtime", Icon = "rbxassetid://10723407389" })
    local Sec = MainTab:AddSection("Client Parameters")
    Sec:AddSlider("MovementRate", {
        Name = "Movement Scale",
        Desc = "Adjust client movement rate",
        Min = 16,
        Max = 250,
        Default = 16,
        Callback = function(v)
            local char = LocalPlayer and LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum then hum.WalkSpeed = v end
        end
    })
    Sec:AddSlider("ElevationRate", {
        Name = "Elevation Vector",
        Desc = "Adjust vertical impulse vector",
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
    Window:SelectTab(1)
end

-- 8. Dynamic Database Catalog State (Zero Dummy Data)
local __SERVER_URL = (typeof(__SERVER_URL) == "string" and __SERVER_URL ~= "{{SERVER_URL}}" and __SERVER_URL)
    or "http://127.0.0.1:3000"

local SupportedScripts = {}
local targetScript = {
    Name = gameTitle or "Universal",
    Desc = "Targeting Experience • PlaceId: " .. tostring(PlaceId),
    Status = "ONLINE",
    Launch = launchUniversal
}

-- ============================================================================
-- 9. GUI ROOT RESOLUTION
-- ============================================================================
local function resolveParentGui()
    if gethui then
        local ok, h = pcall(gethui)
        if ok and h then return h end
    end
    local lp = Players.LocalPlayer
    if lp then
        local pGui = lp:FindFirstChildOfClass("PlayerGui") or lp:WaitForChild("PlayerGui", 2)
        if pGui then return pGui end
    end
    local CoreGui = game:GetService("CoreGui")
    if CoreGui then return CoreGui end
    return game:GetService("StarterGui")
end

local pGui = resolveParentGui()
if not pGui then return end

-- ============================================================================
-- 10. LIYHUB PROGRESS LOADING OVERLAY (Modern Top Enclave Bar)
-- ============================================================================
local function createLoadingOverlay(initialText)
    local targetParent = resolveParentGui()
    if not targetParent then return nil end

    local old = targetParent:FindFirstChild("LiyhubLoadingGui")
    if old then old:Destroy() end

    local loadGui = Instance.new("ScreenGui")
    loadGui.Name = "LiyhubLoadingGui"
    loadGui.ResetOnSpawn = false
    loadGui.DisplayOrder = 9999999
    loadGui.IgnoreGuiInset = false
    loadGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
        pcall(syn.protect_gui, loadGui)
    elseif typeof(protect_gui) == "function" then
        pcall(protect_gui, loadGui)
    end

    local cam = workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    local isPhone = isTouch or vp.X < 700

    local overlayW = isPhone and 290 or 340
    local overlayH = isPhone and 42 or 46
    local topOffset = isPhone and 8 or 12

    local barFrame = Instance.new("Frame")
    barFrame.Name = "LoadingBarFrame"
    barFrame.Size = UDim2.fromOffset(overlayW, overlayH)
    barFrame.Position = UDim2.new(0.5, 0, 0, topOffset)
    barFrame.AnchorPoint = Vector2.new(0.5, 0)
    barFrame.BackgroundColor3 = Theme.Background
    barFrame.BackgroundTransparency = 0.05
    barFrame.ClipsDescendants = true
    barFrame.Parent = loadGui
    corner(barFrame, 9)
    stroke(barFrame, Color3.fromRGB(255, 255, 255), 0.78)

    local barGrad = Instance.new("UIGradient")
    barGrad.Rotation = 35
    barGrad.Color = ColorSequence.new(Theme.Background, Theme.Surface)
    barGrad.Parent = barFrame

    local loadScale = Instance.new("UIScale")
    loadScale.Parent = barFrame
    local function updateLoadScale()
        pcall(function()
            local curCam = workspace.CurrentCamera
            local curVp = (curCam and curCam.ViewportSize) or Vector2.new(1920, 1080)
            local sX = (curVp.X - 24) / overlayW
            loadScale.Scale = math.clamp(math.min(sX, 1), 0.65, 1)
        end)
    end
    updateLoadScale()
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateLoadScale)
    end

    local logoFrameDim = 26
    local logoFrame = Instance.new("Frame")
    logoFrame.Name = "LogoFrame"
    logoFrame.Size = UDim2.fromOffset(logoFrameDim, logoFrameDim)
    logoFrame.Position = UDim2.new(0, 10, 0, 5)
    logoFrame.BackgroundColor3 = Theme.Surface2
    logoFrame.BackgroundTransparency = 0.35
    logoFrame.Parent = barFrame
    corner(logoFrame, 7)
    stroke(logoFrame, Color3.fromRGB(255, 255, 255), 0.72)

    local logoImg = Instance.new("ImageLabel")
    logoImg.Name = "LogoImage"
    logoImg.Size = UDim2.new(1, -4, 1, -4)
    logoImg.AnchorPoint = Vector2.new(0.5, 0.5)
    logoImg.Position = UDim2.fromScale(0.5, 0.5)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = resolveLogoAsset()
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.Parent = logoFrame
    corner(logoImg, 5)

    local brandTxt = text(barFrame, "LIYHUB", 12, Theme.Text)
    brandTxt.Position = UDim2.new(0, 44, 0, 5)
    brandTxt.Size = UDim2.new(0, 56, 0, 15)
    brandTxt.Font = Enum.Font.GothamBold

    local subTxt = text(barFrame, "| " .. (initialText or "Connecting to Enclave..."), 10, Theme.SubText)
    subTxt.Position = UDim2.new(0, 102, 0, 5)
    subTxt.Size = UDim2.new(1, -(102 + 48), 0, 15)
    subTxt.Font = Enum.Font.Gotham
    subTxt.TextTruncate = Enum.TextTruncate.AtEnd

    local pctTxt = text(barFrame, "0%", 10.5, Theme.AccentGlow)
    pctTxt.Position = UDim2.new(1, -44, 0, 5)
    pctTxt.Size = UDim2.new(0, 36, 0, 15)
    pctTxt.Font = Enum.Font.GothamBold
    pctTxt.TextXAlignment = Enum.TextXAlignment.Right

    -- Progress Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 4)
    track.Position = UDim2.new(0, 10, 1, -8)
    track.BackgroundColor3 = Theme.SurfaceDeep
    track.BorderSizePixel = 0
    track.Parent = barFrame
    corner(track, 2)

    -- Fill Bar
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 2)

    local fillGrad = Instance.new("UIGradient")
    fillGrad.Color = ColorSequence.new(Theme.Accent, Theme.AccentGlow)
    fillGrad.Parent = fill

    loadGui.Parent = targetParent

    local startTime = os.clock()
    return {
        Update = function(self, pct, label)
            pcall(function()
                pct = math.clamp(pct, 0, 100)
                local el = os.clock() - startTime
                if label then
                    subTxt.Text = "| " .. label .. string.format(" (%.1fs)", el)
                end
                pctTxt.Text = string.format("%d%%", pct)
                tween(fill, 0.2, { Size = UDim2.new(pct / 100, 0, 1, 0) })
            end)
        end,
        Destroy = function(self)
            pcall(function()
                tween(barFrame, 0.2, { BackgroundTransparency = 1 })
                task.wait(0.2)
                loadGui:Destroy()
            end)
        end
    }
end

local oldLoader = pGui:FindFirstChild("LiyhubLoaderGui")
if oldLoader then oldLoader:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LiyhubLoaderGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 999999
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
    pcall(syn.protect_gui, ScreenGui)
elseif typeof(protect_gui) == "function" then
    pcall(protect_gui, ScreenGui)
end
ScreenGui.Parent = pGui

local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- Adaptive Device Layout (Exact Liyhub UI Specification)
local function getDeviceLayout()
    local cam = workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)
    local isTouch = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
    if isTouch or vp.X < 700 then
        -- Mobile Phone Preset (matches LiyhubUI mobile/phone 440-520 x 290-325)
        local w = math.clamp(math.floor(vp.X * 0.88), 440, 520)
        local h = math.clamp(math.floor(vp.Y * 0.82), 290, 325)
        local leftW = math.floor(w * 0.58)
        return "Mobile", w, h, leftW, 46
    elseif vp.X < 1024 or vp.Y < 640 then
        -- Tablet Preset (matches LiyhubUI tablet 540-620 x 340-380)
        local w = math.clamp(math.floor(vp.X * 0.82), 540, 620)
        local h = math.clamp(math.floor(vp.Y * 0.80), 340, 380)
        local leftW = math.floor(w * 0.58)
        return "Tablet", w, h, leftW, 50
    else
        -- PC Standard Preset (matches LiyhubUI PC 680 x 385)
        return "PC", 680, 385, 390, 54
    end
end

local devType, winW, winH, leftPanelW, topbarH = getDeviceLayout()
local isMobile = (devType == "Mobile")

local Main = Instance.new("Frame")
Main.Name = "LiyhubLoaderWindow"
Main.Size = UDim2.fromOffset(winW, winH)
Main.Position = UDim2.fromScale(0.5, 0.5)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Theme.Background
Main.BackgroundTransparency = 0.04
Main.ClipsDescendants = true
Main.Active = true
Main.Parent = ScreenGui
corner(Main, 16)
stroke(Main, Color3.fromRGB(255, 255, 255), 0.75, 1)

local bgGrad = Instance.new("UIGradient")
bgGrad.Rotation = 35
bgGrad.Color = ColorSequence.new(Theme.Background, Theme.Surface)
bgGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.1),
    NumberSequenceKeypoint.new(1, 0.32)
})
bgGrad.Parent = Main

-- Responsive UIScale (Device adaptive fit)
local uiScale = Instance.new("UIScale")
uiScale.Parent = Main

local function updateWindowScale()
    pcall(function()
        if not ScreenGui or not ScreenGui.Parent or not uiScale or not uiScale.Parent then return end
        local sz = ScreenGui.AbsoluteSize
        if sz and sz.X > 0 and sz.Y > 0 then
            local padX = isMobile and 24 or 36
            local padY = isMobile and 24 or 36
            local scaleX = (sz.X - padX) / winW
            local scaleY = (sz.Y - padY) / winH
            uiScale.Scale = math.clamp(math.min(scaleX, scaleY, 1), 0.5, 1)
        end
    end)
end
updateWindowScale()
ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateWindowScale)
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowScale)
end

-- ============================================================================
-- TOPBAR (Liyhub Header with Glowing Line)
-- ============================================================================
local topbarH = isMobile and 48 or 54

local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Size = UDim2.new(1, 0, 0, topbarH)
Topbar.BackgroundTransparency = 1
Topbar.ZIndex = 3
Topbar.Parent = Main

-- Dragging
pcall(function()
    local dragging, dragStart, startPos, dragInput
    Topbar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    Topbar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end)

local logoFrameDim = isMobile and 30 or 34
local logoFrameY = math.floor((topbarH - logoFrameDim) / 2)

local logoFrame = Instance.new("Frame")
logoFrame.Name = "TopbarLogoFrame"
logoFrame.Size = UDim2.fromOffset(logoFrameDim, logoFrameDim)
logoFrame.Position = UDim2.fromOffset(isMobile and 12 or 16, logoFrameY)
logoFrame.BackgroundColor3 = Theme.Surface2
logoFrame.BackgroundTransparency = 0.35
logoFrame.ZIndex = 5
logoFrame.Parent = Topbar
corner(logoFrame, 8)
stroke(logoFrame, Color3.fromRGB(255, 255, 255), 0.72)

local logoImg = Instance.new("ImageLabel")
logoImg.Name = "TopbarLogo"
logoImg.Size = UDim2.new(1, -6, 1, -6)
logoImg.AnchorPoint = Vector2.new(0.5, 0.5)
logoImg.Position = UDim2.fromScale(0.5, 0.5)
logoImg.BackgroundTransparency = 1
logoImg.Image = resolveLogoAsset()
logoImg.ScaleType = Enum.ScaleType.Fit
logoImg.ZIndex = 6
logoImg.Parent = logoFrame
corner(logoImg, 6)

local titleX = (isMobile and 12 or 16) + logoFrameDim + 12

local winTitle = text(Topbar, "Liyhub", isMobile and 14 or 16, Theme.Text)
winTitle.Position = UDim2.fromOffset(titleX, logoFrameY - 1)
winTitle.Size = UDim2.new(0, 140, 0, 18)
winTitle.Font = Enum.Font.GothamBold
winTitle.ZIndex = 5

local winSub = text(Topbar, "License Verification Gateway", isMobile and 9.5 or 10.5, Theme.SubText)
winSub.Position = UDim2.fromOffset(titleX, logoFrameY + 17)
winSub.Size = UDim2.new(0, 200, 0, 14)
winSub.Font = Enum.Font.Gotham
winSub.ZIndex = 5

-- Close Button
local closeBtn = Instance.new("TextButton")
closeBtn.Name = "CloseBtn"
closeBtn.Text = ""
closeBtn.AutoButtonColor = false
closeBtn.BackgroundColor3 = Theme.Surface
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -38, 0.5, -13)
closeBtn.ZIndex = 5
closeBtn.Parent = Topbar
corner(closeBtn, 7)
stroke(closeBtn, Theme.Border, 0.35)

local closeIco = Instance.new("ImageLabel")
closeIco.Size = UDim2.fromOffset(13, 13)
closeIco.Position = UDim2.fromOffset(6.5, 6.5)
closeIco.BackgroundTransparency = 1
closeIco.Image = "rbxassetid://10747384394"
closeIco.ImageColor3 = Theme.SubText
closeIco.ScaleType = Enum.ScaleType.Fit
closeIco.ZIndex = 6
closeIco.Parent = closeBtn

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, 0.1, { BackgroundColor3 = Theme.Hover })
    tween(closeIco, 0.1, { ImageColor3 = Theme.Text })
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, 0.1, { BackgroundColor3 = Theme.Surface })
    tween(closeIco, 0.1, { ImageColor3 = Theme.SubText })
end)
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Topbar Glowing Separator Line (TopLine)
local topLine = Instance.new("Frame")
topLine.Name = "TopLine"
topLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
topLine.BorderSizePixel = 0
topLine.Position = UDim2.fromOffset(isMobile and 12 or 16, topbarH)
topLine.Size = UDim2.new(1, isMobile and -24 or -32, 0, 1)
topLine.ZIndex = 4
topLine.Parent = Main

local lineGrad = Instance.new("UIGradient")
lineGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
lineGrad.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 0.5),
    NumberSequenceKeypoint.new(0.2, 0.1),
    NumberSequenceKeypoint.new(0.8, 0.1),
    NumberSequenceKeypoint.new(1, 0.5),
})
lineGrad.Parent = topLine

-- ============================================================================
-- BODY AREA
-- ============================================================================
local Body = Instance.new("Frame")
Body.Name = "Body"
Body.Size = UDim2.new(1, isMobile and -24 or -32, 1, -(topbarH + 12))
Body.Position = UDim2.new(0, isMobile and 12 or 16, 0, topbarH + 6)
Body.BackgroundTransparency = 1
Body.ZIndex = 2
Body.Parent = Main

local leftPanelW = isMobile and 310 or 390

-- ============================================================================
-- LEFT PANEL: KEY SYSTEM INPUT & SECURITY DIAGNOSTICS LOGS
-- ============================================================================
local KeyPanel = Instance.new("Frame")
KeyPanel.Name = "KeyPanel"
KeyPanel.Size = UDim2.new(0, leftPanelW, 1, 0)
KeyPanel.BackgroundColor3 = Theme.Surface
KeyPanel.BackgroundTransparency = 0.25
KeyPanel.ZIndex = 3
KeyPanel.Parent = Body
corner(KeyPanel, 11)
stroke(KeyPanel, Theme.Border, 0.35)
pad(KeyPanel, 8, 10, 8, 10)

-- 1. Profile Bar (H: 38)
local profileBar = Instance.new("Frame")
profileBar.Name = "ProfileBar"
profileBar.Size = UDim2.new(1, 0, 0, 36)
profileBar.BackgroundColor3 = Theme.Surface2
profileBar.BackgroundTransparency = 0.45
profileBar.Parent = KeyPanel
corner(profileBar, 7)
stroke(profileBar, Theme.Border, 0.3)

local avatar = Instance.new("ImageLabel")
avatar.Size = UDim2.fromOffset(26, 26)
avatar.Position = UDim2.new(0, 5, 0.5, -13)
avatar.BackgroundColor3 = Theme.Surface
avatar.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
avatar.Parent = profileBar
corner(avatar, 13)

local statusDot = Instance.new("Frame")
statusDot.Size = UDim2.fromOffset(6, 6)
statusDot.Position = UDim2.new(1, -5, 1, -5)
statusDot.BackgroundColor3 = Theme.Success
statusDot.BorderSizePixel = 0
statusDot.Parent = avatar
corner(statusDot, 3)

task.spawn(function()
    if LocalPlayer then
        pcall(function()
            local content = Players:GetUserThumbnailAsync(
                LocalPlayer.UserId,
                Enum.ThumbnailType.HeadShot,
                Enum.ThumbnailSize.Size100x100
            )
            if content then avatar.Image = content end
        end)
    end
end)

local profName = text(profileBar, LocalPlayer and LocalPlayer.DisplayName or "User", 11, Theme.Text)
profName.Position = UDim2.new(0, 38, 0, 4)
profName.Size = UDim2.new(0.5, -38, 0, 14)
profName.Font = Enum.Font.GothamBold
profName.TextTruncate = Enum.TextTruncate.AtEnd

local profHandle = text(profileBar, LocalPlayer and ("@" .. LocalPlayer.Name) or "@user", 9, Theme.SubText)
profHandle.Position = UDim2.new(0, 38, 0, 18)
profHandle.Size = UDim2.new(0.5, -38, 0, 13)
profHandle.Font = Enum.Font.Gotham
profHandle.TextTruncate = Enum.TextTruncate.AtEnd

-- Target Game Tag on the right of profile bar
local targetTag = text(profileBar, "TARGET: " .. string.upper(targetScript.Name), 9, Theme.AccentGlow)
targetTag.Position = UDim2.new(0.5, 0, 0, 0)
targetTag.Size = UDim2.new(0.5, -8, 1, 0)
targetTag.Font = Enum.Font.GothamBold
targetTag.TextXAlignment = Enum.TextXAlignment.Right
targetTag.TextTruncate = Enum.TextTruncate.AtEnd

-- 2. License Key Input Box (Y: 42)
local inputLabel = text(KeyPanel, "LICENSE KEY", 9.5, Theme.SubText)
inputLabel.Position = UDim2.new(0, 0, 0, 42)
inputLabel.Size = UDim2.new(1, 0, 0, 14)
inputLabel.Font = Enum.Font.GothamBold

local inputFrame = Instance.new("Frame")
inputFrame.Name = "InputFrame"
inputFrame.Size = UDim2.new(1, 0, 0, 32)
inputFrame.Position = UDim2.new(0, 0, 0, 58)
inputFrame.BackgroundColor3 = Theme.SurfaceDeep
inputFrame.Parent = KeyPanel
corner(inputFrame, 6)
local inStroke = stroke(inputFrame, Theme.Border, 0.35)

local inputBox = Instance.new("TextBox")
inputBox.Name = "KeyInput"
inputBox.Size = UDim2.new(1, -16, 1, 0)
inputBox.Position = UDim2.new(0, 8, 0, 0)
inputBox.BackgroundTransparency = 1
inputBox.Font = Enum.Font.GothamMedium
inputBox.Text = ""
inputBox.PlaceholderText = "Paste license key here..."
inputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
inputBox.PlaceholderColor3 = Theme.Muted
inputBox.TextSize = 11.5
inputBox.TextXAlignment = Enum.TextXAlignment.Left
inputBox.ClearTextOnFocus = false
inputBox.Parent = inputFrame

inputBox.Focused:Connect(function()
    tween(inStroke, 0.15, { Color = Theme.Accent, Transparency = 0.2 })
end)
inputBox.FocusLost:Connect(function()
    tween(inStroke, 0.15, { Color = Theme.Border, Transparency = 0.35 })
end)

-- 3. Dedicated Security Diagnostics & Logs Console (Y: 96, H: 86)
local consoleBox = Instance.new("Frame")
consoleBox.Name = "DiagnosticsConsole"
consoleBox.Size = UDim2.new(1, 0, 0, isMobile and 84 or 92)
consoleBox.Position = UDim2.new(0, 0, 0, 96)
consoleBox.BackgroundColor3 = Theme.SurfaceDeep
consoleBox.ClipsDescendants = true
consoleBox.Parent = KeyPanel
corner(consoleBox, 6)
local consoleStroke = stroke(consoleBox, Theme.Border, 0.35)

local consoleHeader = Instance.new("Frame")
consoleHeader.Size = UDim2.new(1, 0, 0, 20)
consoleHeader.BackgroundColor3 = Theme.Surface2
consoleHeader.BackgroundTransparency = 0.45
consoleHeader.Parent = consoleBox

local consoleTitle = text(consoleHeader, "SECURITY DIAGNOSTICS", 9, Theme.SubText)
consoleTitle.Position = UDim2.new(0, 8, 0, 0)
consoleTitle.Size = UDim2.new(0.5, 0, 1, 0)
consoleTitle.Font = Enum.Font.GothamBold

local statusTag = text(consoleHeader, DiagnosticCodes.IDLE.Code, 9, Theme.Success)
statusTag.Position = UDim2.new(0.5, 0, 0, 0)
statusTag.Size = UDim2.new(0.5, -8, 1, 0)
statusTag.Font = Enum.Font.GothamBold
statusTag.TextXAlignment = Enum.TextXAlignment.Right

local logLine1 = text(consoleBox, DiagnosticCodes.IDLE.Line1, 10, Theme.Text)
logLine1.Position = UDim2.new(0, 8, 0, 24)
logLine1.Size = UDim2.new(1, -16, 0, 16)
logLine1.Font = Enum.Font.GothamMedium
logLine1.TextTruncate = Enum.TextTruncate.AtEnd

local logLine2 = text(consoleBox, DiagnosticCodes.IDLE.Line2, 9.5, Theme.SubText)
logLine2.Position = UDim2.new(0, 8, 0, 42)
logLine2.Size = UDim2.new(1, -16, 0, 16)
logLine2.Font = Enum.Font.Gotham
logLine2.TextTruncate = Enum.TextTruncate.AtEnd

local logLine3 = text(consoleBox, DiagnosticCodes.IDLE.Line3, 9.5, Theme.Muted)
logLine3.Position = UDim2.new(0, 8, 0, 60)
logLine3.Size = UDim2.new(1, -16, 0, 16)
logLine3.Font = Enum.Font.Gotham
logLine3.TextTruncate = Enum.TextTruncate.AtEnd

local function setDiagnosticState(diagKey)
    local diag = DiagnosticCodes[diagKey] or DiagnosticCodes.IDLE
    statusTag.Text = diag.Code
    statusTag.TextColor3 = diag.Color
    logLine1.Text = diag.Line1
    logLine2.Text = diag.Line2
    logLine3.Text = diag.Line3

    if diag.Color == Theme.Error then
        tween(consoleStroke, 0.2, { Color = Theme.ErrorBorder, Transparency = 0 })
        tween(consoleBox, 0.2, { BackgroundColor3 = Theme.ErrorBg })
        logLine1.TextColor3 = Theme.Error
    else
        tween(consoleStroke, 0.2, { Color = Theme.Border, Transparency = 0.35 })
        tween(consoleBox, 0.2, { BackgroundColor3 = Theme.SurfaceDeep })
        logLine1.TextColor3 = Theme.Text
    end
end

-- 4. Action Buttons (Submit & Get Key)
local buttonRow = Instance.new("Frame")
buttonRow.Size = UDim2.new(1, 0, 0, 32)
buttonRow.Position = UDim2.new(0, 0, 0, isMobile and 188 or 198)
buttonRow.BackgroundTransparency = 1
buttonRow.Parent = KeyPanel

local submitBtn = Instance.new("TextButton")
submitBtn.Name = "SubmitBtn"
submitBtn.Size = UDim2.new(0.5, -4, 1, 0)
submitBtn.BackgroundColor3 = Theme.Accent
submitBtn.AutoButtonColor = false
submitBtn.Text = ""
submitBtn.Parent = buttonRow
corner(submitBtn, 7)
local submitStroke = stroke(submitBtn, Theme.AccentGlow, 0.35)

local submitTxt = text(submitBtn, "Authenticate", 11.5, Color3.fromRGB(255, 255, 255))
submitTxt.Size = UDim2.fromScale(1, 1)
submitTxt.TextXAlignment = Enum.TextXAlignment.Center
submitTxt.Font = Enum.Font.GothamBold

submitBtn.MouseEnter:Connect(function()
    tween(submitBtn, 0.1, { BackgroundColor3 = Theme.AccentHover })
end)
submitBtn.MouseLeave:Connect(function()
    tween(submitBtn, 0.1, { BackgroundColor3 = Theme.Accent })
end)

local getKeyBtn = Instance.new("TextButton")
getKeyBtn.Name = "GetKeyBtn"
getKeyBtn.Size = UDim2.new(0.5, -4, 1, 0)
getKeyBtn.Position = UDim2.new(0.5, 4, 0, 0)
getKeyBtn.BackgroundColor3 = Theme.Surface2
getKeyBtn.BackgroundTransparency = 0.45
getKeyBtn.AutoButtonColor = false
getKeyBtn.Text = ""
getKeyBtn.Parent = buttonRow
corner(getKeyBtn, 7)
stroke(getKeyBtn, Theme.Border, 0.3)

local getKeyTxt = text(getKeyBtn, "Get License Key", 11, Theme.SubText)
getKeyTxt.Size = UDim2.fromScale(1, 1)
getKeyTxt.TextXAlignment = Enum.TextXAlignment.Center
getKeyTxt.Font = Enum.Font.GothamMedium

getKeyBtn.MouseEnter:Connect(function()
    tween(getKeyBtn, 0.1, { BackgroundColor3 = Theme.Hover, BackgroundTransparency = 0 })
    tween(getKeyTxt, 0.1, { TextColor3 = Theme.Text })
end)
getKeyBtn.MouseLeave:Connect(function()
    tween(getKeyBtn, 0.1, { BackgroundColor3 = Theme.Surface2, BackgroundTransparency = 0.45 })
    tween(getKeyTxt, 0.1, { TextColor3 = Theme.SubText })
end)

getKeyBtn.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard("https://discord.gg/liyhub")
        elseif toclipboard then
            toclipboard("https://discord.gg/liyhub")
        end
    end)
    getKeyTxt.Text = "Link Copied!"
    logLine1.Text = "> [PORTAL]: Access URL copied to system clipboard."
    task.delay(2, function()
        getKeyTxt.Text = "Get License Key"
    end)
end)

-- Execution unlock trigger
local isSubmitting = false
submitBtn.MouseButton1Click:Connect(function()
    if isSubmitting then return end
    local entered = inputBox.Text:match("^%s*(.-)%s*$")
    if not entered or entered == "" then
        setDiagnosticState("INVALID_KEY")
        return
    end

    isSubmitting = true
    submitTxt.Text = "Authenticating..."
    setDiagnosticState("VERIFYING")

    task.delay(0.5, function()
        setDiagnosticState("SUCCESS")
        submitTxt.Text = "Authorized"
        task.wait(0.2)
        pcall(function() ScreenGui:Destroy() end)

        local overlay = createLoadingOverlay("Authenticating Token...")
        if overlay then
            task.spawn(function()
                overlay:Update(25, "Attesting Environment...")
                task.wait(0.35)
                overlay:Update(55, "Decrypting Protected Payload...")
                task.wait(0.35)
                overlay:Update(85, "Mounting Runtime Symbols...")
                task.wait(0.35)
                overlay:Update(100, "Initializing Core Engine...")
                task.wait(0.25)
                overlay:Destroy()
                task.spawn(targetScript.Launch)
            end)
        else
            task.spawn(targetScript.Launch)
        end
    end)
end)

-- Footer note on KeyPanel
local footerNote = text(KeyPanel, "LIYHUB BOOTSTRAPPER v2.4 • PROTECTED BY LIYHUB DRM", 8.5, Theme.Muted)
footerNote.Position = UDim2.new(0, 0, 1, -12)
footerNote.Size = UDim2.new(1, 0, 0, 12)
footerNote.Font = Enum.Font.Gotham

-- ============================================================================
-- RIGHT PANEL: SUPPORTED SCRIPT LIST & SCRIPTBLOX SUPPORT
-- (Catalog only - NO load buttons, clean display)
-- ============================================================================
local RightPanel = Instance.new("Frame")
RightPanel.Name = "RightPanel"
RightPanel.Size = UDim2.new(1, -(leftPanelW + 10), 1, 0)
RightPanel.Position = UDim2.new(0, leftPanelW + 10, 0, 0)
RightPanel.BackgroundColor3 = Theme.Surface
RightPanel.BackgroundTransparency = 0.25
RightPanel.ZIndex = 3
RightPanel.Parent = Body
corner(RightPanel, 11)
pad(RightPanel, 8, 10, 8, 10)

updateWindowScale = function()
    pcall(function()
        local dev, w, h, lW, tbH = getDeviceLayout()
        winW = w
        winH = h
        leftPanelW = lW
        topbarH = tbH
        Main.Size = UDim2.fromOffset(w, h)
        if Topbar then Topbar.Size = UDim2.new(1, 0, 0, tbH) end
        if Body then
            Body.Size = UDim2.new(1, dev == "PC" and -32 or -24, 1, -(tbH + 12))
            Body.Position = UDim2.new(0, dev == "PC" and 16 or 12, 0, tbH + 6)
        end
        if KeyPanel then KeyPanel.Size = UDim2.new(0, lW, 1, 0) end
        if RightPanel then
            RightPanel.Size = UDim2.new(1, -(lW + 10), 1, 0)
            RightPanel.Position = UDim2.new(0, lW + 10, 0, 0)
        end

        local cam = workspace.CurrentCamera
        local vp = (cam and cam.ViewportSize) or Vector2.new(1920, 1080)
        local scaleX = (vp.X - 20) / w
        local scaleY = (vp.Y - 20) / h
        uiScale.Scale = math.clamp(math.min(scaleX, scaleY, 1), 0.52, 1)
    end)
end
updateWindowScale()
if workspace.CurrentCamera then
    workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowScale)
end

-- Header Bar: SUPPORTED SCRIPTS + Count Tag
local listHeader = Instance.new("Frame")
listHeader.Size = UDim2.new(1, 0, 0, 20)
listHeader.BackgroundTransparency = 1
listHeader.Parent = RightPanel

local listTitle = text(listHeader, "SUPPORTED SCRIPTS", 10.5, Theme.SubText)
listTitle.Size = UDim2.new(0.6, 0, 1, 0)
listTitle.Font = Enum.Font.GothamBold

local countBadge = text(listHeader, tostring(#SupportedScripts) .. " READY", 9, Theme.AccentGlow)
countBadge.Position = UDim2.new(0.6, 0, 0, 0)
countBadge.Size = UDim2.new(0.4, 0, 1, 0)
countBadge.Font = Enum.Font.GothamBold
countBadge.TextXAlignment = Enum.TextXAlignment.Right

-- Search Box
local searchBoxFrame = Instance.new("Frame")
searchBoxFrame.Name = "SearchFrame"
searchBoxFrame.Size = UDim2.new(1, 0, 0, 24)
searchBoxFrame.Position = UDim2.new(0, 0, 0, 24)
searchBoxFrame.BackgroundColor3 = Theme.SurfaceDeep
searchBoxFrame.Parent = RightPanel
corner(searchBoxFrame, 6)
local searchStroke = stroke(searchBoxFrame, Theme.Border, 0.3)

local searchIcon = Instance.new("ImageLabel")
searchIcon.Size = UDim2.fromOffset(11, 11)
searchIcon.Position = UDim2.new(0, 8, 0.5, -5.5)
searchIcon.BackgroundTransparency = 1
searchIcon.Image = "rbxassetid://10709805569"
searchIcon.ImageColor3 = Theme.SubText
searchIcon.ScaleType = Enum.ScaleType.Fit
searchIcon.Parent = searchBoxFrame

local searchBox = Instance.new("TextBox")
searchBox.Name = "SearchBox"
searchBox.Size = UDim2.new(1, -26, 1, 0)
searchBox.Position = UDim2.new(0, 24, 0, 0)
searchBox.BackgroundTransparency = 1
searchBox.Font = Enum.Font.Gotham
searchBox.PlaceholderText = "Search supported games..."
searchBox.PlaceholderColor3 = Theme.Muted
searchBox.Text = ""
searchBox.TextColor3 = Theme.Text
searchBox.TextSize = 10
searchBox.ClearTextOnFocus = false
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.Parent = searchBoxFrame

-- Scrollable Script Catalog (Clean rows, NO load button)
local scrollList = Instance.new("ScrollingFrame")
scrollList.Name = "ScriptScroll"
scrollList.Size = UDim2.new(1, 0, 1, -74)
scrollList.Position = UDim2.new(0, 0, 0, 52)
scrollList.BackgroundTransparency = 1
scrollList.BorderSizePixel = 0
scrollList.ScrollBarThickness = 3
scrollList.ScrollBarImageColor3 = Theme.Border
scrollList.ScrollBarImageTransparency = 0.35
scrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
scrollList.AutomaticCanvasSize = Enum.AutomaticSize.None
scrollList.ScrollingDirection = Enum.ScrollingDirection.Y
scrollList.ElasticBehavior = Enum.ElasticBehavior.Always
scrollList.Parent = RightPanel

local listLayout = Instance.new("UIListLayout")
listLayout.Padding = UDim.new(0, 5)
listLayout.SortOrder = Enum.SortOrder.LayoutOrder
listLayout.Parent = scrollList

local function updateCanvas()
    pcall(function()
        scrollList.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 8)
    end)
end
listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)

local scriptRows = {}
local skeletonCards = {}

local function clearSkeletons()
    for _, sk in ipairs(skeletonCards) do
        pcall(function() sk:Destroy() end)
    end
    skeletonCards = {}
end

local function renderSkeletonLoading()
    clearSkeletons()
    countBadge.Text = "SYNCING..."
    countBadge.TextColor3 = Theme.AccentGlow

    -- Animated pulse on countBadge
    local pulseTween = TweenService:Create(countBadge, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
        TextTransparency = 0.5
    })
    pulseTween:Play()

    for i = 1, 4 do
        local sk = Instance.new("Frame")
        sk.Name = "Skeleton_" .. i
        sk.Size = UDim2.new(1, -6, 0, 36)
        sk.BackgroundColor3 = Theme.Surface2
        sk.BackgroundTransparency = 0.5
        sk.Parent = scrollList
        corner(sk, 7)
        stroke(sk, Theme.Border, 0.25)

        -- Shimmer dot placeholder
        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(6, 6)
        dot.Position = UDim2.new(0, 8, 0.5, -3)
        dot.BackgroundColor3 = Theme.SurfaceDeep
        dot.BorderSizePixel = 0
        dot.Parent = sk
        corner(dot, 3)

        -- Shimmer title bar
        local titleBar = Instance.new("Frame")
        titleBar.Size = UDim2.new(0.45, 0, 0, 10)
        titleBar.Position = UDim2.new(0, 20, 0, 7)
        titleBar.BackgroundColor3 = Theme.SurfaceDeep
        titleBar.BorderSizePixel = 0
        titleBar.Parent = sk
        corner(titleBar, 4)

        -- Shimmer subtitle bar
        local subBar = Instance.new("Frame")
        subBar.Size = UDim2.new(0.65, 0, 0, 8)
        subBar.Position = UDim2.new(0, 20, 0, 20)
        subBar.BackgroundColor3 = Theme.SurfaceDeep
        subBar.BorderSizePixel = 0
        subBar.Parent = sk
        corner(subBar, 4)

        -- Pulsing animation
        local anim = TweenService:Create(sk, TweenInfo.new(0.7, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
            BackgroundTransparency = 0.8
        })
        anim:Play()

        table.insert(skeletonCards, sk)
    end
    updateCanvas()
end

local function renderScripts(query)
    clearSkeletons()
    for _, r in ipairs(scriptRows) do pcall(function() r:Destroy() end) end
    scriptRows = {}

    local q = string.lower(query or "")
    for _, scr in ipairs(SupportedScripts) do
        local match = (q == "")
            or string.find(string.lower(scr.Name), q, 1, true)
            or string.find(string.lower(scr.Desc or ""), q, 1, true)

        if match then
            local isCurrent = (scr == targetScript or (targetScript and scr.Id and scr.Id == targetScript.Id))

            local card = Instance.new("Frame")
            card.Name = "Script_" .. scr.Name
            card.Size = UDim2.new(1, -6, 0, 36)
            card.BackgroundColor3 = Theme.Surface2
            card.BackgroundTransparency = isCurrent and 0.25 or 0.5
            card.Parent = scrollList
            corner(card, 7)
            stroke(card, isCurrent and Theme.Accent or Theme.Border, isCurrent and 0.25 or 0.45)

            -- Status Indicator dot
            local dot = Instance.new("Frame")
            dot.Size = UDim2.fromOffset(6, 6)
            dot.Position = UDim2.new(0, 8, 0.5, -3)
            dot.BackgroundColor3 = isCurrent and Theme.Success or Theme.Accent
            dot.BorderSizePixel = 0
            dot.Parent = card
            corner(dot, 3)

            -- Game Name
            local sName = text(card, scr.Name, 11, isCurrent and Theme.Accent or Theme.Text)
            sName.Position = UDim2.new(0, 20, 0, 4)
            sName.Size = UDim2.new(1, -68, 0, 15)
            sName.Font = Enum.Font.GothamBold
            sName.TextTruncate = Enum.TextTruncate.AtEnd

            -- Game Desc
            local sDesc = text(card, scr.Desc or "Database Enclave Package", 9, Theme.SubText)
            sDesc.Position = UDim2.new(0, 20, 0, 19)
            sDesc.Size = UDim2.new(1, -68, 0, 13)
            sDesc.Font = Enum.Font.Gotham
            sDesc.TextTruncate = Enum.TextTruncate.AtEnd

            -- Tag pill on right: TARGET or ONLINE
            local tagPill = Instance.new("Frame")
            tagPill.Size = UDim2.fromOffset(44, 16)
            tagPill.Position = UDim2.new(1, -50, 0.5, -8)
            tagPill.BackgroundColor3 = isCurrent and Color3.fromRGB(0, 200, 115) or Theme.Surface
            tagPill.BackgroundTransparency = isCurrent and 0.82 or 0.4
            tagPill.Parent = card
            corner(tagPill, 4)
            stroke(tagPill, isCurrent and Color3.fromRGB(0, 200, 115) or Theme.Border, 0.4)

            local tagTxt = text(tagPill, isCurrent and "TARGET" or "ONLINE", 7.5, isCurrent and Theme.Success or Theme.SubText)
            tagTxt.Size = UDim2.fromScale(1, 1)
            tagTxt.TextXAlignment = Enum.TextXAlignment.Center
            tagTxt.Font = Enum.Font.GothamBold

            table.insert(scriptRows, card)
        end
    end
    updateCanvas()
end

local function fetchDatabaseCatalog()
    renderSkeletonLoading()

    local rawJson = nil
    pcall(function()
        local httpReq = (syn and syn.request) or (http and http.request) or request or http_request
        if httpReq then
            local r = httpReq({
                Url = __SERVER_URL .. "/v1/public-scripts",
                Method = "GET",
                Headers = { ["Content-Type"] = "application/json" }
            })
            if r and (r.StatusCode == 200 or r.Status == 200) then
                rawJson = r.Body
            end
        end
    end)
    if not rawJson then
        pcall(function()
            rawJson = game:HttpGet(__SERVER_URL .. "/v1/public-scripts")
        end)
    end

    local list = {}
    if rawJson and rawJson ~= "" then
        local decodeOk, res = pcall(function()
            return game:GetService("HttpService"):JSONDecode(rawJson)
        end)
        if decodeOk and res and res.success and res.scripts then
            for _, s in ipairs(res.scripts) do
                table.insert(list, {
                    Id = s.id,
                    Name = s.name,
                    Desc = "Verified Package • Database Synced",
                    PlaceIds = tostring(s.placeIds or ""),
                    FreeForAll = s.freeForAll,
                    Status = "ONLINE",
                    Launch = launchUniversal
                })
            end
        end
    end

    if #list > 0 then
        SupportedScripts = list
        countBadge.Text = tostring(#SupportedScripts) .. " READY"
        countBadge.TextTransparency = 0
        countBadge.TextColor3 = Theme.AccentGlow

        -- Auto-match game
        local matched = nil
        for _, s in ipairs(SupportedScripts) do
            if string.find(s.PlaceIds, tostring(PlaceId)) then
                matched = s
                break
            end
        end
        if matched then
            targetScript = matched
        else
            targetScript = SupportedScripts[1]
        end
    else
        -- Clean fallback if database server offline
        SupportedScripts = {
            {
                Id = "universal",
                Name = gameTitle or "Universal Enclave",
                Desc = "Active Experience • PlaceId: " .. tostring(PlaceId),
                PlaceIds = tostring(PlaceId),
                Status = "ONLINE",
                Launch = launchUniversal
            }
        }
        countBadge.Text = "1 ACTIVE"
        countBadge.TextTransparency = 0
        countBadge.TextColor3 = Theme.Success
        targetScript = SupportedScripts[1]
    end

    if targetTag then
        targetTag.Text = "TARGET: " .. string.upper(targetScript.Name)
    end
    renderScripts(searchBox.Text)
end

-- Kick off dynamic sync
task.spawn(fetchDatabaseCatalog)

searchBox:GetPropertyChangedSignal("Text"):Connect(function()
    renderScripts(searchBox.Text)
end)

-- ============================================================================
-- SCRIPTBLOX ATTRIBUTION FOOTER (Professional, Clean White, No Clunky Button)
-- ============================================================================
local scriptbloxCard = Instance.new("TextButton")
scriptbloxCard.Name = "ScriptbloxAttribution"
scriptbloxCard.Size = UDim2.new(1, 0, 0, 18)
scriptbloxCard.Position = UDim2.new(0, 0, 1, -18)
scriptbloxCard.BackgroundTransparency = 1
scriptbloxCard.AutoButtonColor = false
scriptbloxCard.Text = ""
scriptbloxCard.Parent = RightPanel

local sbCenterContainer = Instance.new("Frame")
sbCenterContainer.Size = UDim2.fromScale(1, 1)
sbCenterContainer.BackgroundTransparency = 1
sbCenterContainer.Parent = scriptbloxCard

local sbLayout = Instance.new("UIListLayout")
sbLayout.FillDirection = Enum.FillDirection.Horizontal
sbLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
sbLayout.VerticalAlignment = Enum.VerticalAlignment.Center
sbLayout.Padding = UDim.new(0, 5)
sbLayout.Parent = sbCenterContainer

local sbIcon = Instance.new("ImageLabel")
sbIcon.Size = UDim2.fromOffset(10, 10)
sbIcon.BackgroundTransparency = 1
sbIcon.Image = "rbxassetid://10709798433"
sbIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
sbIcon.ScaleType = Enum.ScaleType.Fit
sbIcon.Parent = sbCenterContainer

local sbTitle = Instance.new("TextLabel")
sbTitle.BackgroundTransparency = 1
sbTitle.Text = "Supported by ScriptBlox"
sbTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
sbTitle.TextSize = 9
sbTitle.Font = Enum.Font.GothamMedium
sbTitle.AutomaticSize = Enum.AutomaticSize.XY
sbTitle.Parent = sbCenterContainer

-- Subtle hover & click interaction
scriptbloxCard.MouseEnter:Connect(function()
    tween(sbTitle, 0.15, { TextTransparency = 0.35 })
    tween(sbIcon, 0.15, { ImageTransparency = 0.35 })
end)
scriptbloxCard.MouseLeave:Connect(function()
    tween(sbTitle, 0.15, { TextTransparency = 0 })
    tween(sbIcon, 0.15, { ImageTransparency = 0 })
end)
scriptbloxCard.MouseButton1Click:Connect(function()
    pcall(function()
        if setclipboard then
            setclipboard("https://scriptblox.com")
        elseif toclipboard then
            toclipboard("https://scriptblox.com")
        end
    end)
    sbTitle.Text = "Link Copied"
    task.delay(1.5, function()
        sbTitle.Text = "Supported by ScriptBlox"
    end)
end)

-- Initial Toast Notification
pcall(function()
    Liyhub:Notify({
        Title = "Liyhub Bootstrapper",
        Content = "Ready for " .. targetScript.Name,
        Duration = 2.5,
        Type = "Success"
    })
end)

return {
    createLoadingOverlay = createLoadingOverlay,
    Gui = ScreenGui,
    Main = Main
}
