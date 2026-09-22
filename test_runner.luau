-- LiyhubUI / NovaUI Complete Standalone Integration Runner (Roblox Studio / Executor)
-- Pure Black Modern Theme | Solid White Text | Full 10-Component Suite | Exact Clamped Scrolling

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TeleportService = game:GetService("TeleportService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Anti-AFK Bypass (Prevents 20-minute idle disconnect)
task.spawn(function()
    if LocalPlayer then
        LocalPlayer.Idled:Connect(function()
            local vu = game:GetService("VirtualUser")
            if vu then
                pcall(function()
                    vu:CaptureController()
                    vu:ClickButton2(Vector2.new(0, 0))
                end)
            end
        end)
    end
end)

-- Single-instance anti-spam debounce: unload previous session cleanly
if getgenv and getgenv()._LIYHUB_CLEANUP then
    pcall(getgenv()._LIYHUB_CLEANUP)
    getgenv()._LIYHUB_CLEANUP = nil
end
if getgenv and getgenv()._LIYHUB_DRAWING then
    pcall(function()
        if getgenv()._LIYHUB_DRAWING.FOV then pcall(function() getgenv()._LIYHUB_DRAWING.FOV:Remove() end) end
        if getgenv()._LIYHUB_DRAWING.Watermark then pcall(function() getgenv()._LIYHUB_DRAWING.Watermark:Remove() end) end
        if getgenv()._LIYHUB_DRAWING.Connection then pcall(function() getgenv()._LIYHUB_DRAWING.Connection:Disconnect() end) end
    end)
    getgenv()._LIYHUB_DRAWING = nil
end

-- Stealth container resolution (prevents game DescendantAdded / ChildAdded detection)
local function getSafeGuiContainer(): Instance
    if typeof(gethui) == "function" then
        local ok, hui = pcall(gethui)
        if ok and hui then return hui end
    end
    local hasProtect = (typeof(syn) == "table" and typeof(syn.protect_gui) == "function") or (typeof(protect_gui) == "function") or (typeof(protectgui) == "function")
    if hasProtect then
        return CoreGui
    end
    if LocalPlayer then
        local pgui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
        if pgui then return pgui end
    end
    local rbxGui = CoreGui:FindFirstChild("RobloxGui")
    if rbxGui then return rbxGui end
    return CoreGui
end

local targetParent = getSafeGuiContainer()

-- ============================================================================
-- THEME: PURE BLACK MODERN (Obsidian / Solid White Text / Cyan Accent)
-- ============================================================================
local Theme = {
    Background       = Color3.fromRGB(10, 10, 12),      -- Pure deep obsidian window canvas
    Surface          = Color3.fromRGB(14, 14, 17),      -- Topbar, Sidebar, Section container
    SurfaceSecondary = Color3.fromRGB(18, 18, 22),      -- Card widgets, Profile box, controls
    SurfaceElevated  = Color3.fromRGB(25, 25, 30),      -- Hovered state
    Border           = Color3.fromRGB(28, 28, 33),      -- Crisp unified 1px border
    BorderBright     = Color3.fromRGB(42, 42, 50),      -- Focused / highlighted border
    Text             = Color3.fromRGB(255, 255, 255),  -- Crisp solid white
    TextSecondary    = Color3.fromRGB(150, 150, 165),  -- Neutral subdued text
    Accent           = Color3.fromRGB(0, 162, 255),    -- Vivid Cyan
    AccentDim        = Color3.fromRGB(0, 110, 185),    -- Dim Cyan
}

-- ============================================================================
-- UTILITY HELPERS & MODERN TYPOGRAPHY ENGINE (MONTSERRAT / JETBRAINSMONO)
-- ============================================================================
local Fonts = {
    Heading = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Bold),
    Body    = Font.new("rbxasset://fonts/families/GothamSSm.json", Enum.FontWeight.Medium),
    Mono    = Font.new("rbxasset://fonts/families/JetBrainsMono.json", Enum.FontWeight.SemiBold),
}

local Utility = {}
function Utility.IsMobile()
    if UserInputService.TouchEnabled and (not UserInputService.MouseEnabled or not UserInputService.KeyboardEnabled) then
        return true
    end
    local cam = workspace.CurrentCamera
    if cam and cam.ViewportSize.X > 0 and cam.ViewportSize.X < 760 then
        return true
    end
    return false
end
function Utility.Create(className, props, children)
    local inst = Instance.new(className)
    for k, v in pairs(props or {}) do (inst :: any)[k] = v end
    if children then for _, c in ipairs(children) do c.Parent = inst end end

    if (className == "TextLabel" or className == "TextButton" or className == "TextBox") and not (props and props.FontFace) then
        pcall(function()
            local curFont = (props and props.Font) or inst.Font
            if curFont == Enum.Font.GothamBold then
                inst.FontFace = Fonts.Heading
            elseif curFont == Enum.Font.Code or curFont == Enum.Font.RobotoMono then
                inst.FontFace = Fonts.Mono
            else
                inst.FontFace = Fonts.Body
            end
        end)
    end
    return inst
end
function Utility.AddCorner(inst, r)
    return Utility.Create("UICorner", { CornerRadius = UDim.new(0, r or 6), Parent = inst })
end
function Utility.AddStroke(inst, color, thickness, transparency)
    return Utility.Create("UIStroke", { Color = color or Theme.Border, Thickness = thickness or 1, Transparency = transparency or 0, ApplyStrokeMode = Enum.ApplyStrokeMode.Border, Parent = inst })
end
function Utility.AddPadding(inst, top, bot, left, right)
    return Utility.Create("UIPadding", { PaddingTop = UDim.new(0, top or 8), PaddingBottom = UDim.new(0, bot or 8), PaddingLeft = UDim.new(0, left or 8), PaddingRight = UDim.new(0, right or 8), Parent = inst })
end
function Utility.ApplyCardStyle(inst, radius)
    Utility.AddCorner(inst, radius or 7)
    inst.BackgroundColor3 = Theme.SurfaceSecondary
    local stroke = Utility.AddStroke(inst, Theme.Border, 1, 0)
    local dummyGrad = { Color = nil }
    return stroke, dummyGrad, dummyGrad
end

function Utility.CreateTextGroup(parent, titleText, descText, rightReserveWidth)
    local hasDesc = (descText ~= nil and tostring(descText) ~= "")
    local textGroup = Utility.Create("Frame", {
        Name = "TextGroup",
        Size = UDim2.new(1, -(rightReserveWidth or 52), 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = parent
    })
    Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = textGroup
    })

    local titleLbl = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = titleText or "",
        TextColor3 = Color3.fromRGB(245, 248, 255),
        TextSize = 11.5,
        TextWrapped = true,
        TextTruncate = Enum.TextTruncate.None,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        Parent = textGroup
    })
    Utility.Create("UITextSizeConstraint", { MaxTextSize = 12, MinTextSize = 8.5, Parent = titleLbl })

    local descLbl = nil
    if hasDesc then
        descLbl = Utility.Create("TextLabel", {
            Name = "Desc",
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamMedium,
            Text = tostring(descText),
            TextColor3 = Color3.fromRGB(138, 144, 164),
            TextSize = 10,
            LineHeight = 1.18,
            TextWrapped = true,
            TextTruncate = Enum.TextTruncate.None,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            Parent = textGroup
        })
        Utility.Create("UITextSizeConstraint", { MaxTextSize = 10.5, MinTextSize = 7.5, Parent = descLbl })
    end

    return {
        Frame = textGroup,
        Title = titleLbl,
        Desc = descLbl,
        HasDesc = hasDesc
    }
end
local CachedLogoAsset = nil
local LogoChecked = false

local function ResolveLogoAsset(overrideAsset)
    if overrideAsset and overrideAsset ~= "" and overrideAsset ~= "rbxassetid://0" then
        return overrideAsset
    end
    if LogoChecked then return CachedLogoAsset end
    LogoChecked = true

    pcall(function()
        if typeof(isfile) == "function" and typeof(writefile) == "function" and typeof(getcustomasset) == "function" then
            local path = "Liyhub/logo.png"
            if typeof(isfolder) == "function" and not isfolder("Liyhub") then
                makefolder("Liyhub")
            end
            if not isfile(path) then
                local raw = game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/logo.png")
                if raw and #raw > 100 then
                    writefile(path, raw)
                end
            end
            if isfile(path) then
                local asset = getcustomasset(path)
                if asset then
                    CachedLogoAsset = asset
                end
            end
        end
    end)
    if not CachedLogoAsset then
        CachedLogoAsset = "rbxassetid://123085513549252"
    end
    return CachedLogoAsset
end

function Utility.CreateLiyhubMark(parent, size, posX, posY, overrideLogo)
    local logoAsset = ResolveLogoAsset(overrideLogo)

    local root = Utility.Create("Frame", {
        Name = "LiyhubMark",
        Size = UDim2.fromOffset(size, size),
        Position = UDim2.new(0, posX, 0.5, posY or -math.floor(size/2)),
        BackgroundColor3 = Color3.fromRGB(15, 15, 20),
        BorderSizePixel = 0,
        Parent = parent
    })
    Utility.AddCorner(root, size / 2)
    Utility.AddStroke(root, Theme.Accent, 1, 0.4)

    if logoAsset then
        local img = Utility.Create("ImageLabel", {
            Name = "LogoImage",
            Size = UDim2.fromScale(1, 1),
            BackgroundTransparency = 1,
            Image = logoAsset,
            ScaleType = Enum.ScaleType.Fit,
            Parent = root
        })
        Utility.AddCorner(img, size / 2)
        return root
    end

    local scale = size / 22

    -- Vertical stem of L
    local stemW = math.floor(4 * scale + 0.5)
    local stemH = math.floor(13 * scale + 0.5)
    local stemX = math.floor(5 * scale + 0.5)
    local stemY = math.floor(4 * scale + 0.5)

    local stem = Utility.Create("Frame", {
        Name = "Stem",
        Size = UDim2.fromOffset(stemW, stemH),
        Position = UDim2.fromOffset(stemX, stemY),
        BackgroundColor3 = Color3.fromRGB(255, 150, 30),
        BorderSizePixel = 0,
        Parent = root
    })
    Utility.AddCorner(stem, 2)
    Utility.Create("UIGradient", {
        Rotation = 90,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 155, 35)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 175, 255)),
        }),
        Parent = stem
    })

    -- Horizontal foot of L
    local footW = math.floor(11 * scale + 0.5)
    local footH = math.floor(4 * scale + 0.5)
    local footX = math.floor(5 * scale + 0.5)
    local footY = math.floor((4 + 13 - 4) * scale + 0.5)

    local foot = Utility.Create("Frame", {
        Name = "Foot",
        Size = UDim2.fromOffset(footW, footH),
        Position = UDim2.fromOffset(footX, footY),
        BackgroundColor3 = Color3.fromRGB(0, 170, 255),
        BorderSizePixel = 0,
        Parent = root
    })
    Utility.AddCorner(foot, 2)
    Utility.Create("UIGradient", {
        Rotation = 0,
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(220, 145, 60)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 175, 255)),
        }),
        Parent = foot
    })

    -- Celestial Orb (Sun/Moon accent inside L angle)
    local orbSize = math.floor(4 * scale + 0.5)
    local orbX = math.floor(12 * scale + 0.5)
    local orbY = math.floor(6 * scale + 0.5)

    local orb = Utility.Create("Frame", {
        Name = "CelestialOrb",
        Size = UDim2.fromOffset(orbSize, orbSize),
        Position = UDim2.fromOffset(orbX, orbY),
        BackgroundColor3 = Color3.fromRGB(255, 215, 65),
        BorderSizePixel = 0,
        Parent = root
    })
    Utility.AddCorner(orb, orbSize / 2)
    return root
end
function Utility.GetViewportSize()
    local camera = workspace.CurrentCamera
    if camera and camera.ViewportSize.X > 0 and camera.ViewportSize.Y > 0 then
        return camera.ViewportSize
    end
    return Vector2.new(1920, 1080)
end

local function getGuiScale(g)
    local cur = g
    while cur do
        local scaleObj = cur:FindFirstChildOfClass("UIScale")
        if scaleObj and scaleObj.Scale > 0 then
            return scaleObj.Scale
        end
        cur = cur.Parent
    end
    return 1
end

function Utility.MakeDraggable(gui, dragPart, ignoreElement)
    local activeInput = nil
    local dragStart = nil
    local startPos = nil
    local isDragging = false
    local moveConn = nil
    local endConn = nil
    local cancelConn = nil
    local dragThreshold = 8

    local function cleanup()
        if moveConn then moveConn:Disconnect(); moveConn = nil end
        if endConn then endConn:Disconnect(); endConn = nil end
        if cancelConn then cancelConn:Disconnect(); cancelConn = nil end
        activeInput = nil
        dragStart = nil
        startPos = nil
        isDragging = false
    end

    local inputConn = dragPart.InputBegan:Connect(function(input)
        if activeInput then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if ignoreElement and ignoreElement.Parent then
                local p = input.Position
                local igPos = ignoreElement.AbsolutePosition
                local igSize = ignoreElement.AbsoluteSize
                if p.X >= igPos.X - 4 and p.X <= igPos.X + igSize.X + 4 and
                   p.Y >= igPos.Y - 4 and p.Y <= igPos.Y + igSize.Y + 4 then
                    return
                end
            end

            activeInput = input
            dragStart = input.Position
            startPos = gui.Position
            isDragging = false

            moveConn = UserInputService.InputChanged:Connect(function(inp)
                local isMatch = (activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and (inp == activeInput or inp.Position == activeInput.Position))
                    or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseMovement)
                if isMatch and dragStart and startPos then
                    local delta = inp.Position - dragStart
                    if not isDragging and (math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold) then
                        isDragging = true
                    end
                    if isDragging then
                        local vp = Utility.GetViewportSize()
                        local scale = getGuiScale(gui)
                        local guiSize = gui.AbsoluteSize
                        local deltaLocalX = delta.X / scale
                        local deltaLocalY = delta.Y / scale

                        local curAbsX = (startPos.X.Scale * (vp.X / scale) + startPos.X.Offset + deltaLocalX) * scale
                        local curAbsY = (startPos.Y.Scale * (vp.Y / scale) + startPos.Y.Offset + deltaLocalY) * scale

                        local maxScreenX = math.max(8, vp.X - guiSize.X - 8)
                        local maxScreenY = math.max(8, vp.Y - guiSize.Y - 8)

                        local clampedScreenX = math.clamp(curAbsX, 8, maxScreenX)
                        local clampedScreenY = math.clamp(curAbsY, 8, maxScreenY)

                        gui.Position = UDim2.new(0, math.round(clampedScreenX / scale), 0, math.round(clampedScreenY / scale))
                    end
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(inp)
                local isMatch = (activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and (inp == activeInput or inp.Position == activeInput.Position))
                    or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseButton1)
                if isMatch then
                    cleanup()
                end
            end)

            cancelConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Cancel then
                    cleanup()
                end
            end)
        end
    end)

    return function()
        cleanup()
        if inputConn then inputConn:Disconnect() end
    end
end

function Utility.MakeDraggableWithClick(gui, dragPart, onClick, onDragEnd)
    local activeInput = nil
    local dragStart = nil
    local startPos = nil
    local isDragging = false
    local moveConn = nil
    local endConn = nil
    local cancelConn = nil
    local dragThreshold = 8

    local function cleanup()
        if moveConn then moveConn:Disconnect(); moveConn = nil end
        if endConn then endConn:Disconnect(); endConn = nil end
        if cancelConn then cancelConn:Disconnect(); cancelConn = nil end
        activeInput = nil
        dragStart = nil
        startPos = nil
        isDragging = false
    end

    local inputConn = dragPart.InputBegan:Connect(function(input)
        if activeInput then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeInput = input
            dragStart = input.Position
            startPos = gui.Position
            isDragging = false

            moveConn = UserInputService.InputChanged:Connect(function(inp)
                local isMatch = (activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and (inp == activeInput or inp.Position == activeInput.Position))
                    or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseMovement)
                if isMatch and dragStart and startPos then
                    local delta = inp.Position - dragStart
                    if not isDragging and (math.abs(delta.X) > dragThreshold or math.abs(delta.Y) > dragThreshold) then
                        isDragging = true
                    end
                    if isDragging then
                        local vp = Utility.GetViewportSize()
                        local scale = getGuiScale(gui)
                        local guiSize = gui.AbsoluteSize
                        local deltaLocalX = delta.X / scale
                        local deltaLocalY = delta.Y / scale

                        local curAbsX = (startPos.X.Scale * (vp.X / scale) + startPos.X.Offset + deltaLocalX) * scale
                        local curAbsY = (startPos.Y.Scale * (vp.Y / scale) + startPos.Y.Offset + deltaLocalY) * scale

                        local maxScreenX = math.max(8, vp.X - guiSize.X - 8)
                        local maxScreenY = math.max(8, vp.Y - guiSize.Y - 8)

                        local clampedScreenX = math.clamp(curAbsX, 8, maxScreenX)
                        local clampedScreenY = math.clamp(curAbsY, 8, maxScreenY)

                        gui.Position = UDim2.new(0, math.round(clampedScreenX / scale), 0, math.round(clampedScreenY / scale))
                    end
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(inp)
                local isMatch = (activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and (inp == activeInput or inp.Position == activeInput.Position))
                    or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseButton1)
                if isMatch then
                    local wasDragging = isDragging
                    local finalPos = gui.Position
                    cleanup()
                    if wasDragging then
                        if onDragEnd then onDragEnd(finalPos) end
                    else
                        if onClick then onClick() end
                    end
                end
            end)

            cancelConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Cancel then
                    cleanup()
                end
            end)
        end
    end)

    return function()
        cleanup()
        if inputConn then inputConn:Disconnect() end
    end
end

-- ============================================================================
-- HIGH-PERFORMANCE ANIMATION ENGINE (Zero-Lag / FPS Auto-Throttled)
-- ============================================================================
local AnimationEngine = {
    FPS = 60,
    LowPerformance = false,
    _activeTweens = setmetatable({}, { __mode = "k" })
}

local TWEEN_QUICK = TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_SMOOTH = TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_BOUNCE = TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_TAB    = TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

local lastFpsTick = os.clock()
local frameCount = 0
RunService.Heartbeat:Connect(function()
    frameCount += 1
    local now = os.clock()
    if now - lastFpsTick >= 0.5 then
        AnimationEngine.FPS = math.floor(frameCount / (now - lastFpsTick))
        AnimationEngine.LowPerformance = (AnimationEngine.FPS < 35)
        frameCount = 0
        lastFpsTick = now
    end
end)

function AnimationEngine.Tween(inst, info, props)
    if not inst then return nil end
    if AnimationEngine._activeTweens[inst] then
        pcall(function() AnimationEngine._activeTweens[inst]:Cancel() end)
        AnimationEngine._activeTweens[inst] = nil
    end
    if AnimationEngine.LowPerformance then
        for k, v in pairs(props) do
            pcall(function() inst[k] = v end)
        end
        return nil
    end
    local t = TweenService:Create(inst, info, props)
    AnimationEngine._activeTweens[inst] = t
    t:Play()
    return t
end

-- ============================================================================
-- CONFIGURATION PERSISTENCE SYSTEM (SPEEDHUB / CHLOE X ARCHITECTURE)
-- ============================================================================
local ConfigEnv = (typeof(getgenv) == "function" and getgenv()) or {}
ConfigEnv.ConfigData = ConfigEnv.ConfigData or {}
local ConfigData = ConfigEnv.ConfigData
if typeof(getgenv) ~= "function" then _G.ConfigData = ConfigData end

local ConfigSystem = {
    Folder = "Liyhub/Configs",
    FileName = "Default.json",
    Version = 1,
    CurrentProfile = "Default",
    Profiles = { "Default" },
    _elements = {},
    _savePending = false
}

function ConfigSystem.GetConfigPath(name)
    local target = (name and tostring(name) ~= "" and tostring(name)) or ConfigSystem.CurrentProfile or "Default"
    local clean = target:gsub("[^%w_%-]", "")
    if clean == "" then clean = "Default" end
    return ConfigSystem.Folder .. "/" .. clean .. ".json", clean
end

function ConfigSystem.SaveProfilesList()
    pcall(function()
        if typeof(writefile) == "function" then
            local pPath = ConfigSystem.Folder .. "/_profiles.json"
            writefile(pPath, HttpService:JSONEncode(ConfigSystem.Profiles))
        end
    end)
end

function ConfigSystem.Init(version, customFile, shouldAutoLoad)
    ConfigSystem.Version = version or ConfigSystem.Version or 1
    ConfigSystem._elements = {}
    ConfigSystem._savePending = false

    pcall(function()
        if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
            if not isfolder("Liyhub") then makefolder("Liyhub") end
            if not isfolder(ConfigSystem.Folder) then makefolder(ConfigSystem.Folder) end
        end
    end)
    -- Load saved profile list if available
    pcall(function()
        if typeof(readfile) == "function" and typeof(isfile) == "function" then
            local pPath = ConfigSystem.Folder .. "/_profiles.json"
            if isfile(pPath) then
                local list = HttpService:JSONDecode(readfile(pPath))
                if typeof(list) == "table" then
                    for _, p in ipairs(list) do
                        if typeof(p) == "string" and not table.find(ConfigSystem.Profiles, p) then
                            table.insert(ConfigSystem.Profiles, p)
                        end
                    end
                end
            end
        end
    end)
    local startProf = customFile or ConfigSystem.CurrentProfile or "Default"
    if shouldAutoLoad == true then
        ConfigSystem.Load(startProf)
    else
        ConfigSystem.CurrentProfile = startProf
    end
end

function ConfigSystem.Register(id, getter, setter)
    if not id then return end
    ConfigSystem._elements[id] = { Get = getter, Set = setter }
end

function ConfigSystem.Save(profileName)
    local path, cleanName = ConfigSystem.GetConfigPath(profileName)
    ConfigSystem.CurrentProfile = cleanName
    if not table.find(ConfigSystem.Profiles, cleanName) then
        table.insert(ConfigSystem.Profiles, cleanName)
        ConfigSystem.SaveProfilesList()
    end

    -- Pull fresh live values from all registered UI elements
    for id, elem in pairs(ConfigSystem._elements) do
        if elem and elem.Get then
            pcall(function()
                local val = elem.Get()
                if typeof(val) == "Color3" then
                    ConfigData[id] = { __type = "Color3", r = val.R, g = val.G, b = val.B }
                elseif typeof(val) == "EnumItem" then
                    ConfigData[id] = { __type = "EnumItem", enum = tostring(val.EnumType), name = val.Name }
                elseif val ~= nil then
                    ConfigData[id] = val
                end
            end)
        end
    end

    if typeof(writefile) ~= "function" then return false, cleanName end
    local ok = pcall(function()
        local savePayload = {
            Version = ConfigSystem.Version,
            Profile = cleanName,
            Data = ConfigData
        }
        writefile(path, HttpService:JSONEncode(savePayload))
    end)
    return ok, cleanName
end

function ConfigSystem.QueueSave()
    if ConfigSystem._savePending then return end
    ConfigSystem._savePending = true
    task.delay(0.25, function()
        ConfigSystem._savePending = false
        ConfigSystem.Save(ConfigSystem.CurrentProfile)
    end)
end

function ConfigSystem.Load(profileName)
    local path, cleanName = ConfigSystem.GetConfigPath(profileName)
    ConfigSystem.CurrentProfile = cleanName
    if typeof(readfile) ~= "function" or typeof(isfile) ~= "function" then return false, cleanName end
    local ok, res = pcall(function()
        if not isfile(path) then return false end
        local content = readfile(path)
        local okDecode, parsed = pcall(HttpService.JSONDecode, HttpService, content)
        if not okDecode or typeof(parsed) ~= "table" then return false end

        -- Version Check (SpeedHub / ChloeX pattern): Auto-reset if version differs
        if parsed.Version and parsed.Version ~= ConfigSystem.Version then
            table.clear(ConfigData)
            ConfigSystem.Save(cleanName)
            return true
        end

        local storedData = parsed.Data or parsed
        for k, v in pairs(storedData) do
            ConfigData[k] = v
            local elem = ConfigSystem._elements[k]
            if elem and elem.Set then
                pcall(function()
                    if typeof(v) == "table" and v.__type == "Color3" then
                        elem.Set(Color3.new(v.r, v.g, v.b))
                    elseif typeof(v) == "table" and v.__type == "EnumItem" then
                        local enumGroup = Enum[v.enum]
                        if enumGroup and enumGroup[v.name] then
                            elem.Set(enumGroup[v.name])
                        end
                    else
                        elem.Set(v)
                    end
                end)
            end
        end
        return true
    end)
    return ok and res, cleanName
end

function ConfigSystem.Delete(profileName)
    local path, cleanName = ConfigSystem.GetConfigPath(profileName)
    if cleanName == "Default" then return false, "Cannot delete Default" end
    pcall(function()
        if typeof(delfile) == "function" and typeof(isfile) == "function" and isfile(path) then
            delfile(path)
        end
    end)
    local idx = table.find(ConfigSystem.Profiles, cleanName)
    if idx then
        table.remove(ConfigSystem.Profiles, idx)
        ConfigSystem.SaveProfilesList()
    end
    if ConfigSystem.CurrentProfile == cleanName then
        ConfigSystem.CurrentProfile = "Default"
        ConfigSystem.Load("Default")
    end
    return true, cleanName
end

function ConfigSystem.Refresh()
    pcall(function()
        if typeof(listfiles) == "function" and typeof(isfolder) == "function" and isfolder(ConfigSystem.Folder) then
            for _, f in ipairs(listfiles(ConfigSystem.Folder)) do
                if f:sub(-5) == ".json" then
                    local name = f:match("([^/\\]+)%.json$")
                    if name and name ~= "_profiles" and not table.find(ConfigSystem.Profiles, name) then
                        table.insert(ConfigSystem.Profiles, name)
                    end
                end
            end
            ConfigSystem.SaveProfilesList()
        end
    end)
    return ConfigSystem.Profiles
end

-- Global shorthand helpers (exact ChloeX / SpeedHub syntax)
local function SaveConfig(name)
    return ConfigSystem.Save(name)
end
local function LoadConfig(name)
    return ConfigSystem.Load(name)
end

ConfigEnv.SaveConfig = SaveConfig
ConfigEnv.LoadConfig = LoadConfig
if typeof(getgenv) ~= "function" then
    _G.SaveConfig = SaveConfig
    _G.LoadConfig = LoadConfig
end

-- ============================================================================
-- HARDWARE OVERLAY ENGINE (DRAWING API FOV RING & WATERMARK)
-- ============================================================================
local DrawingOverlay = {
    FOV = nil,
    Watermark = nil
}

function DrawingOverlay.Init()
    pcall(function()
        if typeof(Drawing) ~= "table" and typeof(Drawing) ~= "function" then return end

        -- 1. Dynamic FOV Ring
        local circle = Drawing.new("Circle")
        circle.Visible = false
        circle.Thickness = 1.5
        circle.Radius = 120
        circle.Filled = false
        circle.Color = Color3.fromRGB(0, 162, 255)
        circle.Transparency = 0.75
        DrawingOverlay.FOV = circle

        -- 2. Watermark Corner Text
        local text = Drawing.new("Text")
        text.Visible = true
        text.Size = 13
        text.Position = Vector2.new(14, 14)
        text.Color = Color3.fromRGB(225, 225, 240)
        text.Outline = true
        text.OutlineColor = Color3.fromRGB(10, 10, 14)
        text.Text = "Liyhub v2.4 | ACTIVE"
        DrawingOverlay.Watermark = text

        local lastWm = 0
        local rsConn = RunService.RenderStepped:Connect(function()
            local mousePos = UserInputService:GetMouseLocation()
            if circle and circle.Visible then
                circle.Position = mousePos
            end
            local now = os.clock()
            if now - lastWm >= 0.5 and text and text.Visible then
                lastWm = now
                local pingVal = 0
                pcall(function()
                    local stats = game:GetService("Stats")
                    pingVal = math.floor(stats.Network.ServerStatsItem["Data Ping"]:GetValue() or 0)
                end)
                text.Text = string.format("Liyhub v2.4 | FPS: %d | PING: %dms", AnimationEngine.FPS, pingVal)
            end
        end)
        if getgenv then
            getgenv()._LIYHUB_DRAWING = {
                FOV = circle,
                Watermark = text,
                Connection = rsConn
            }
        end
    end)
end
DrawingOverlay.Init()

-- ============================================================================
-- NOTIFICATION TOAST SYSTEM
-- ============================================================================
local Notification = { Container = nil }
function Notification.Notify(config)
    if not Notification.Container or not Notification.Container.Parent then return end
    local toast = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = Theme.Surface,
        Parent = Notification.Container
    })
    Utility.AddCorner(toast, 6); Utility.AddStroke(toast, Theme.Border, 1); Utility.AddPadding(toast, 8, 8, 14, 14)
    local stripe = Utility.Create("Frame", { Size = UDim2.new(0, 3, 1, 0), Position = UDim2.new(0, -14, 0, -8), BackgroundColor3 = Theme.Accent, BorderSizePixel = 0, Parent = toast })
    Utility.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = config.Title or "Notification", TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = toast })
    Utility.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 18), Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = config.Content or "", TextColor3 = Theme.TextSecondary, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = toast })
    local dismissBtn = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = toast
    })
    dismissBtn.Activated:Connect(function()
        if toast and toast.Parent then toast:Destroy() end
    end)
    task.delay(config.Duration or 3.5, function()
        if toast and toast.Parent then toast:Destroy() end
    end)
end

local function chloexNotif(message)
    Notification.Notify({ Title = "Liyhub", Content = tostring(message), Duration = 2.5 })
end
ConfigEnv.chloex = chloexNotif
ConfigEnv.than = chloexNotif
if typeof(getgenv) ~= "function" then
    _G.chloex = chloexNotif
    _G.than = chloexNotif
end

-- ============================================================================
-- COMPONENTS (ALL 10 WIDGETS INTEGRATED)
-- ============================================================================

-- 1. BUTTON
local Button = {}
function Button.new(parent, config)
    local btn = Utility.Create("TextButton", {
        Name = "Component_Button",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        AutoButtonColor = false,
        Text = "",
        Parent = parent
    })
    local stroke, strokeGrad, bgGrad = Utility.ApplyCardStyle(btn, 8)
    Utility.AddPadding(btn, 8, 8, 12, 12)

    local txtGroup = Utility.CreateTextGroup(btn, config.Name or "Button", config.Desc or config.Description, 36)

    local actionBadge = Utility.Create("Frame", {
        Size = UDim2.new(0, 22, 0, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        BorderSizePixel = 0,
        Parent = btn
    })
    Utility.AddCorner(actionBadge, 5)
    Utility.AddStroke(actionBadge, Theme.Border, 1, 0.5)

    local chevron = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = ">",
        TextColor3 = Color3.fromRGB(140, 150, 175),
        TextSize = 13,
        Parent = actionBadge
    })

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = Theme.SurfaceElevated
        stroke.Color = Theme.BorderBright
        chevron.TextColor3 = Theme.Text
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = Theme.SurfaceSecondary
        stroke.Color = Theme.Border
        chevron.TextColor3 = Theme.TextSecondary
    end)
    btn.MouseButton1Down:Connect(function()
        btn.BackgroundColor3 = Theme.Surface
    end)
    btn.MouseButton1Up:Connect(function()
        btn.BackgroundColor3 = Theme.SurfaceElevated
    end)
    btn.Activated:Connect(function()
        if config.Callback then task.spawn(config.Callback) end
    end)
    return btn
end

-- 2. TOGGLE
local Toggle = {}
function Toggle.new(parent, config)
    local keyName = config.Name or "Toggle"
    local initial = (ConfigData[keyName] ~= nil and ConfigData[keyName])
    if initial == nil then initial = (config.Default or false) end
    local state = initial
    ConfigData[keyName] = state

    local frame = Utility.Create("Frame", {
        Name = "Component_Toggle",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.SurfaceSecondary,
        Parent = parent
    })
    local stroke = Utility.ApplyCardStyle(frame, 7)
    Utility.AddPadding(frame, 8, 8, 12, 12)

    local txtGroup = Utility.CreateTextGroup(frame, keyName, config.Desc or config.Description, 44)

    -- Switch track (Exact Reference style: OFF = dark slate/grey knob, ON = solid white/black knob)
    local switch = Utility.Create("Frame", {
        Size = UDim2.new(0, 42, 0, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(32, 32, 38),
        BorderSizePixel = 0,
        Parent = frame
    })
    Utility.AddCorner(switch, 11)
    local switchStroke = Utility.AddStroke(switch, state and Color3.fromRGB(230, 230, 235) or Color3.fromRGB(45, 45, 54), 1, 0.2)

    local knob = Utility.Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
        BackgroundColor3 = state and Color3.fromRGB(14, 14, 17) or Color3.fromRGB(120, 120, 135),
        BorderSizePixel = 0,
        Parent = switch
    })
    Utility.AddCorner(knob, 8)

    local function applyVisual(s)
        if s then
            frame.BackgroundColor3 = Theme.SurfaceSecondary
            stroke.Color = Theme.BorderBright
            txtGroup.Title.TextColor3 = Theme.Text
            switch.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            switchStroke.Color = Color3.fromRGB(230, 230, 235)
            knob.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
        else
            frame.BackgroundColor3 = Theme.SurfaceSecondary
            stroke.Color = Theme.Border
            txtGroup.Title.TextColor3 = Color3.fromRGB(215, 215, 225)
            switch.BackgroundColor3 = Color3.fromRGB(32, 32, 38)
            switchStroke.Color = Color3.fromRGB(45, 45, 54)
            knob.BackgroundColor3 = Color3.fromRGB(120, 120, 135)
        end
    end


    if state then applyVisual(true) end

    local function setState(newState)
        state = newState
        ConfigData[keyName] = state
        applyVisual(state)
        AnimationEngine.Tween(knob, TWEEN_QUICK, { Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8) })
        ConfigSystem.QueueSave()
        if config.Callback then task.spawn(config.Callback, state) end
    end

    ConfigSystem.Register(keyName, function() return state end, function(v) setState(v) end)

    local rowBtn = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        Parent = frame
    })
    rowBtn.Activated:Connect(function()
        setState(not state)
    end)

    return {
        Frame = frame,
        SetState = setState,
        GetState = function() return state end
    }
end


-- 3. SLIDER
local Slider = {}
function Slider.new(parent, config)
    local keyName = config.Name or "Slider"
    local min, max, default = config.Min or 0, config.Max or 100, config.Default or 50
    local initial = (ConfigData[keyName] ~= nil and tonumber(ConfigData[keyName])) or default
    local val = math.clamp(initial, min, max)
    ConfigData[keyName] = val

    local frame = Utility.Create("Frame", {
        Name = "Component_Slider",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = parent
    })
    local stroke, strokeGrad, bgGrad = Utility.ApplyCardStyle(frame, 8)
    Utility.AddPadding(frame, 10, 10, 12, 12)

    local contentLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = frame
    })

    local topRow = Utility.Create("Frame", {
        Name = "TopRow",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = frame
    })

    local txtGroup = Utility.CreateTextGroup(topRow, keyName, config.Desc or config.Description, 46)

    local valBadge = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 42, 0, 22),
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        Font = Enum.Font.GothamBold,
        Text = tostring(val),
        TextColor3 = Theme.Accent,
        TextSize = 10.5,
        Parent = topRow
    })
    Utility.AddCorner(valBadge, 4)
    Utility.AddStroke(valBadge, Theme.Border, 1, 0.3)

    local trackHitArea = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 2,
        Parent = frame
    })

    local track = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0.5, -3),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        BorderSizePixel = 0,
        Active = false,
        Parent = trackHitArea
    })
    Utility.AddCorner(track, 3)
    Utility.AddStroke(track, Theme.Border, 1)

    local initialP = math.clamp((val - min) / (max - min), 0, 1)
    local fill = Utility.Create("Frame", {
        Size = UDim2.new(initialP, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 185, 255),
        BorderSizePixel = 0,
        Parent = track
    })
    Utility.AddCorner(fill, 3)
    Utility.Create("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 220, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(0, 140, 240)),
        }),
        Parent = fill
    })

    local knob = Utility.Create("Frame", {
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -7, 0.5, -7),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 5,
        Parent = fill
    })
    Utility.AddCorner(knob, 8)
    Utility.AddStroke(knob, Theme.Accent, 2)

    local dragging = false
    local moveConn = nil
    local endConn = nil
    local cancelConn = nil
    local activeInput = nil

    local function stopDrag()
        if moveConn then moveConn:Disconnect(); moveConn = nil end
        if endConn then endConn:Disconnect(); endConn = nil end
        if cancelConn then cancelConn:Disconnect(); cancelConn = nil end
        activeInput = nil
        if dragging then
            dragging = false
            ConfigData[keyName] = val
            ConfigSystem.QueueSave()
        end
    end
    frame.Destroying:Connect(stopDrag)

    local function updateVal(x)
        local rel = math.clamp(x - track.AbsolutePosition.X, 0, track.AbsoluteSize.X)
        local p = rel / math.max(track.AbsoluteSize.X, 1)
        val = math.floor(min + (max - min) * p + 0.5)
        valBadge.Text = tostring(val)
        fill.Size = UDim2.new(p, 0, 1, 0)
        ConfigData[keyName] = val
        if config.Callback then task.spawn(config.Callback, val) end
    end

    trackHitArea.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 or inp.UserInputType == Enum.UserInputType.Touch then
            activeInput = inp
            dragging = true
            updateVal(inp.Position.X)
            if not moveConn then
                moveConn = UserInputService.InputChanged:Connect(function(moveInp)
                    local isMatch = (activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and (moveInp == activeInput or moveInp.Position == activeInput.Position))
                        or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and moveInp.UserInputType == Enum.UserInputType.MouseMovement)
                    if dragging and isMatch then
                        updateVal(moveInp.Position.X)
                    end
                end)
            end
            if not endConn then
                endConn = UserInputService.InputEnded:Connect(function(endInp)
                    local isMatch = (activeInput and activeInput.UserInputType == Enum.UserInputType.Touch and (endInp == activeInput or endInp.Position == activeInput.Position))
                        or (activeInput and activeInput.UserInputType == Enum.UserInputType.MouseButton1 and endInp.UserInputType == Enum.UserInputType.MouseButton1)
                    if isMatch then
                        stopDrag()
                    end
                end)
            end
            if not cancelConn then
                cancelConn = inp.Changed:Connect(function()
                    if inp.UserInputState == Enum.UserInputState.Cancel then
                        stopDrag()
                    end
                end)
            end
        end
    end)

    local function setValExplicit(newVal)
        val = math.clamp(newVal, min, max)
        valBadge.Text = tostring(val)
        local p = (val - min) / (max - min)
        AnimationEngine.Tween(fill, TWEEN_QUICK, { Size = UDim2.new(p, 0, 1, 0) })
        ConfigData[keyName] = val
        ConfigSystem.QueueSave()
        if config.Callback then task.spawn(config.Callback, val) end
    end

    ConfigSystem.Register(keyName, function() return val end, function(v) setValExplicit(v) end)

    return {
        Frame = frame,
        GetValue = function() return val end,
        SetValue = setValExplicit
    }
end


-- 4. DROPDOWN (SINGLE-SELECT)

local ActiveDropdownCloser = nil



local Dropdown = {}
function Dropdown.new(parent, config)
    local keyName = config.Name or "Dropdown"
    local options = config.Options or {}
    local initial = (ConfigData[keyName] ~= nil and tostring(ConfigData[keyName])) or (config.Default or (options[1] or ""))
    local selected = initial
    ConfigData[keyName] = selected
    local isOpen = false

    local frame = Utility.Create("Frame", {
        Name = "Component_Dropdown",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ClipsDescendants = true,
        Parent = parent
    })
    local stroke, strokeGrad, bgGrad = Utility.ApplyCardStyle(frame, 8)
    Utility.AddPadding(frame, 8, 8, 12, 12)

    local frameLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = frame
    })

    local header = Utility.Create("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 1,
        Parent = frame
    })

    local txtGroup = Utility.CreateTextGroup(header, keyName, config.Desc or config.Description, 100)

    local valPill = Utility.Create("Frame", {
        Size = UDim2.new(0, 92, 0, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        Active = false,
        Parent = header
    })
    Utility.AddCorner(valPill, 5)
    local valPillStroke = Utility.AddStroke(valPill, Theme.Border, 1, 0.3)

    local valueLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -6, 1, 0),
        Position = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = selected .. "  v",
        TextColor3 = Color3.fromRGB(215, 220, 235),
        TextSize = 10,
        TextScaled = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Center,
        Active = false,
        Parent = valPill
    })
    Utility.Create("UITextSizeConstraint", { MaxTextSize = 11, MinTextSize = 8, Parent = valueLabel })

    local optContainer = Utility.Create("ScrollingFrame", {
        Name = "OptionsList",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 0,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        Visible = false,
        LayoutOrder = 2,
        Parent = frame
    })
    Utility.AddCorner(optContainer, 5)
    Utility.AddStroke(optContainer, Theme.BorderBright, 1)
    Utility.AddPadding(optContainer, 4, 4, 4, 4)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = optContainer })

    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        optContainer.Visible = false
        optContainer.Size = UDim2.new(1, 0, 0, 0)
        valueLabel.Text = selected .. "  v"
        valPillStroke.Color = Theme.Border
        if ActiveDropdownCloser == closeDropdown then
            ActiveDropdownCloser = nil
        end
    end


    local function updateContainerHeight()
        local count = #options
        local maxVisible = 5
        local itemHeight = 26
        local padding = 3
        local totalH = count * itemHeight + math.max(0, count - 1) * padding + 8
        local clampedH = math.min(totalH, maxVisible * itemHeight + (maxVisible - 1) * padding + 8)
        optContainer.Size = UDim2.new(1, 0, 0, isOpen and clampedH or 0)
        optContainer.CanvasSize = UDim2.new(0, 0, 0, totalH)
        return clampedH
    end

    local function openDropdown()
        if isOpen then return end
        if ActiveDropdownCloser and ActiveDropdownCloser ~= closeDropdown then
            pcall(ActiveDropdownCloser)
        end
        ActiveDropdownCloser = closeDropdown
        isOpen = true
        local clampedH = updateContainerHeight()
        optContainer.Size = UDim2.new(1, 0, 0, clampedH)
        optContainer.Visible = true
        valueLabel.Text = selected .. "  ^"
        stroke.Color = Theme.BorderBright
        valPillStroke.Color = Theme.Accent

        if Utility.IsMobile() then
            task.defer(function()
                if not isOpen or not frame or not frame.Parent then return end
                local scrollParent = frame:FindFirstAncestorWhichIsA("ScrollingFrame")
                if scrollParent then
                    local vp = Utility.GetViewportSize()
                    local framePos = frame.AbsolutePosition
                    local frameH = frame.AbsoluteSize.Y
                    local bottomY = framePos.Y + frameH
                    if bottomY > vp.Y - 16 then
                        local overflow = bottomY - (vp.Y - 16)
                        local curCanvasY = scrollParent.CanvasPosition.Y
                        scrollParent.CanvasPosition = Vector2.new(scrollParent.CanvasPosition.X, curCanvasY + overflow)
                    end
                end
            end)
        end
    end



    local function renderOptions()

        for _, c in ipairs(optContainer:GetChildren()) do

            if c:IsA("TextButton") then c:Destroy() end

        end

        updateContainerHeight()

        for _, opt in ipairs(options) do

            local isCurrent = (opt == selected)

            local itemBtn = Utility.Create("TextButton", {

                Size = UDim2.new(1, 0, 0, 26),

                BackgroundColor3 = isCurrent and Theme.Accent or Theme.SurfaceElevated,

                BackgroundTransparency = isCurrent and 0.15 or 0.75,

                Font = isCurrent and Enum.Font.GothamBold or Enum.Font.GothamMedium,

                Text = (isCurrent and "  *  " or "     ") .. opt,

                TextColor3 = isCurrent and Color3.fromRGB(255, 255, 255) or Theme.Text,

                TextSize = 11,

                TextXAlignment = Enum.TextXAlignment.Left,

                AutoButtonColor = false,

                Parent = optContainer

            })

            Utility.AddCorner(itemBtn, 4)



            itemBtn.MouseEnter:Connect(function()

                if opt ~= selected then

                    itemBtn.BackgroundTransparency = 0.35

                    itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

                end

            end)

            itemBtn.MouseLeave:Connect(function()

                if opt ~= selected then

                    itemBtn.BackgroundTransparency = 0.75

                    itemBtn.TextColor3 = Theme.Text

                end

            end)



            local selectDebounce = false

            local function handleSelect()

                if selectDebounce then return end

                selectDebounce = true

                task.delay(0.18, function() selectDebounce = false end)

                selected = opt

                ConfigData[keyName] = selected

                ConfigSystem.QueueSave()

                closeDropdown()

                renderOptions()

                if config.Callback then task.spawn(config.Callback, selected) end

            end

            itemBtn.Activated:Connect(handleSelect)

        end

    end



    local toggleDebounce = false

    local function toggleDropdown()

        if toggleDebounce then return end

        toggleDebounce = true

        task.delay(0.18, function() toggleDebounce = false end)

        if isOpen then

            closeDropdown()

        else

            openDropdown()

        end

    end



    header.Activated:Connect(toggleDropdown)



    renderOptions()



    local function setDropdownVal(newVal)

        selected = newVal

        ConfigData[keyName] = selected

        ConfigSystem.QueueSave()

        valueLabel.Text = selected .. (isOpen and "  ^" or "  v")

        renderOptions()

        if config.Callback then task.spawn(config.Callback, selected) end

    end



    ConfigSystem.Register(keyName, function() return selected end, function(v) setDropdownVal(v) end)



    return {

        GetValue = function() return selected end,

        SetValue = setDropdownVal,

        SetValues = function(self, newOpts, newDefault)

            options = newOpts or {}

            if newDefault then

                selected = newDefault

            elseif not table.find(options, selected) then

                selected = options[1] or ""

            end

            ConfigData[keyName] = selected

            ConfigSystem.QueueSave()

            valueLabel.Text = selected .. (isOpen and "  ^" or "  v")

            renderOptions()

        end

    }

end



-- 5. MULTI-DROPDOWN

local MultiDropdown = {}
function MultiDropdown.new(parent, config)
    local keyName = config.Name or "MultiDropdown"
    local options = config.Options or {}
    local selected = {}
    if ConfigData[keyName] and typeof(ConfigData[keyName]) == "table" then
        for _, item in ipairs(ConfigData[keyName]) do selected[item] = true end
    else
        for _, item in ipairs(config.Default or {}) do selected[item] = true end
    end
    local isOpen = false

    local frame = Utility.Create("Frame", {
        Name = "Component_MultiDropdown",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        ClipsDescendants = true,
        Parent = parent
    })
    local stroke, strokeGrad, bgGrad = Utility.ApplyCardStyle(frame, 8)
    Utility.AddPadding(frame, 8, 8, 12, 12)

    local frameLayout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = frame
    })

    local header = Utility.Create("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 1,
        Parent = frame
    })

    local txtGroup = Utility.CreateTextGroup(header, keyName, config.Desc or config.Description, 100)

    local valPill = Utility.Create("Frame", {
        Size = UDim2.new(0, 92, 0, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        Active = false,
        Parent = header
    })
    Utility.AddCorner(valPill, 5)
    local valPillStroke = Utility.AddStroke(valPill, Theme.Border, 1, 0.3)

    local function getSummary()
        local count = 0
        for _ in pairs(selected) do count = count + 1 end
        return tostring(count) .. " selected"
    end

    local valueLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -6, 1, 0),
        Position = UDim2.new(0, 3, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = getSummary() .. "  v",
        TextColor3 = Color3.fromRGB(215, 220, 235),
        TextSize = 10,
        TextScaled = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Center,
        Active = false,
        Parent = valPill
    })
    Utility.Create("UITextSizeConstraint", { MaxTextSize = 11, MinTextSize = 8, Parent = valueLabel })

    local optContainer = Utility.Create("ScrollingFrame", {
        Name = "OptionsList",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = Theme.Surface,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        TopImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        BottomImage = "rbxasset://textures/ui/Scroll/scroll-middle.png",
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.None,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        Visible = false,
        LayoutOrder = 2,
        Parent = frame
    })
    Utility.AddCorner(optContainer, 5)
    Utility.AddStroke(optContainer, Theme.BorderBright, 1)
    Utility.AddPadding(optContainer, 4, 4, 4, 4)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 3), Parent = optContainer })

    local function closeDropdown()
        if not isOpen then return end
        isOpen = false
        optContainer.Visible = false
        optContainer.Size = UDim2.new(1, 0, 0, 0)
        valueLabel.Text = getSummary() .. "  v"
        valPillStroke.Color = Theme.Border
        if ActiveDropdownCloser == closeDropdown then
            ActiveDropdownCloser = nil
        end
    end

    local function updateContainerHeight()
        local count = #options
        local maxVisible = 5
        local itemHeight = 26
        local padding = 3
        local totalH = count * itemHeight + math.max(0, count - 1) * padding + 8
        local clampedH = math.min(totalH, maxVisible * itemHeight + (maxVisible - 1) * padding + 8)
        optContainer.Size = UDim2.new(1, 0, 0, isOpen and clampedH or 0)
        optContainer.CanvasSize = UDim2.new(0, 0, 0, totalH)
        return clampedH
    end

    local function openDropdown()
        if isOpen then return end
        if ActiveDropdownCloser and ActiveDropdownCloser ~= closeDropdown then
            pcall(ActiveDropdownCloser)
        end
        ActiveDropdownCloser = closeDropdown
        isOpen = true
        local clampedH = updateContainerHeight()
        optContainer.Size = UDim2.new(1, 0, 0, clampedH)
        optContainer.Visible = true
        valueLabel.Text = getSummary() .. "  ^"
        stroke.Color = Theme.BorderBright
        valPillStroke.Color = Theme.Accent
    end



    local function syncState()

        local list = {}

        for k, v in pairs(selected) do if v then table.insert(list, k) end end

        ConfigData[keyName] = list

        ConfigSystem.QueueSave()

        return list

    end



    local function renderOptions()

        for _, c in ipairs(optContainer:GetChildren()) do

            if c:IsA("TextButton") then c:Destroy() end

        end

        updateContainerHeight()

        for _, opt in ipairs(options) do

            local isSel = (selected[opt] == true)

            local itemBtn = Utility.Create("TextButton", {

                Size = UDim2.new(1, 0, 0, 26),

                BackgroundColor3 = isSel and Theme.SurfaceElevated or Color3.fromRGB(20, 20, 25),

                BackgroundTransparency = isSel and 0.2 or 0.75,

                Font = isSel and Enum.Font.GothamBold or Enum.Font.GothamMedium,

                Text = (isSel and " [x] " or " [ ] ") .. opt,

                TextColor3 = isSel and Theme.Accent or Theme.Text,

                TextSize = 11,

                TextXAlignment = Enum.TextXAlignment.Left,

                AutoButtonColor = false,

                Parent = optContainer

            })

            Utility.AddCorner(itemBtn, 4)



            itemBtn.MouseEnter:Connect(function()

                if not selected[opt] then

                    itemBtn.BackgroundTransparency = 0.4

                    itemBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

                end

            end)

            itemBtn.MouseLeave:Connect(function()

                if not selected[opt] then

                    itemBtn.BackgroundTransparency = 0.75

                    itemBtn.TextColor3 = Theme.Text

                end

            end)



            local selectDebounce = false

            local function handleToggle()

                if selectDebounce then return end

                selectDebounce = true

                task.delay(0.18, function() selectDebounce = false end)

                selected[opt] = not selected[opt]

                valueLabel.Text = getSummary() .. (isOpen and "  ^" or "  v")

                local list = syncState()

                renderOptions()

                if config.Callback then task.spawn(config.Callback, list) end

            end

            itemBtn.Activated:Connect(handleToggle)

        end

    end



    local toggleDebounce = false

    local function toggleDropdown()

        if toggleDebounce then return end

        toggleDebounce = true

        task.delay(0.18, function() toggleDebounce = false end)

        if isOpen then

            closeDropdown()

        else

            openDropdown()

        end

    end



    header.Activated:Connect(toggleDropdown)



    renderOptions()

    syncState()



    ConfigSystem.Register(keyName, function()

        local list = {}

        for k, v in pairs(selected) do if v then table.insert(list, k) end end

        return list

    end, function(arr)

        selected = {}

        if typeof(arr) == "table" then for _, item in ipairs(arr) do selected[item] = true end end

        valueLabel.Text = getSummary() .. (isOpen and "  ^" or "  v")

        renderOptions()

        local list = syncState()

        if config.Callback then task.spawn(config.Callback, list) end

    end)



    return {

        GetSelected = function()

            local list = {}

            for k, v in pairs(selected) do if v then table.insert(list, k) end end

            return list

        end

    }

end



-- 6. COLOR PICKER
local ColorPicker = {}
function ColorPicker.new(parent, config)
    local keyName = config.Name or "Color Picker"
    local curColor = config.Default or Theme.Accent
    if ConfigData[keyName] and typeof(ConfigData[keyName]) == "table" and ConfigData[keyName].__type == "Color3" then
        curColor = Color3.new(ConfigData[keyName].r, ConfigData[keyName].g, ConfigData[keyName].b)
    end
    ConfigData[keyName] = { __type = "Color3", r = curColor.R, g = curColor.G, b = curColor.B }

    local presets = {
        Color3.fromRGB(0, 162, 255),  -- Cyan
        Color3.fromRGB(235, 75, 75),   -- Red
        Color3.fromRGB(50, 205, 110),  -- Green
        Color3.fromRGB(245, 190, 35),  -- Gold
        Color3.fromRGB(160, 90, 240),  -- Purple
        Color3.fromRGB(255, 255, 255), -- Solid White
    }
    local pIdx = 1

    local frame = Utility.Create("Frame", {
        Name = "Component_ColorPicker",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = parent
    })
    local stroke, strokeGrad, bgGrad = Utility.ApplyCardStyle(frame, 8)
    Utility.AddPadding(frame, 8, 8, 12, 12)

    local txtGroup = Utility.CreateTextGroup(frame, keyName, config.Desc or config.Description, 46)

    local preview = Utility.Create("TextButton", {
        Size = UDim2.new(0, 36, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = curColor,
        Text = "",
        AutoButtonColor = false,
        Parent = frame
    })
    Utility.AddCorner(preview, 4)
    Utility.AddStroke(preview, Theme.Border, 1)

    local function applyColor(c)
        curColor = c
        preview.BackgroundColor3 = curColor
        ConfigData[keyName] = { __type = "Color3", r = curColor.R, g = curColor.G, b = curColor.B }
        ConfigSystem.QueueSave()
        if config.Callback then task.spawn(config.Callback, curColor) end
    end

    preview.Activated:Connect(function()
        pIdx = (pIdx % #presets) + 1
        applyColor(presets[pIdx])
    end)

    ConfigSystem.Register(keyName, function() return curColor end, function(c) applyColor(c) end)

    return {
        Frame = frame,
        GetColor = function() return curColor end,
        SetColor = applyColor
    }
end

-- 7. KEYBIND
local Keybind = {}
function Keybind.new(parent, config)
    local keyName = config.Name or "Keybind"
    local curKey = config.Default or Enum.KeyCode.RightControl
    if ConfigData[keyName] and typeof(ConfigData[keyName]) == "table" and ConfigData[keyName].__type == "EnumItem" then
        pcall(function() curKey = Enum.KeyCode[ConfigData[keyName].name] end)
    end
    ConfigData[keyName] = { __type = "EnumItem", enum = "KeyCode", name = curKey.Name }
    local listening = false

    local frame = Utility.Create("Frame", {
        Name = "Component_Keybind",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = parent
    })
    local stroke, strokeGrad, bgGrad = Utility.ApplyCardStyle(frame, 8)
    Utility.AddPadding(frame, 8, 8, 12, 12)

    local keyText = "[" .. curKey.Name .. "]"
    local btnW = math.clamp(#keyText * 7 + 12, 28, 56)

    local txtGroup = Utility.CreateTextGroup(frame, keyName, config.Desc or config.Description, btnW + 6)

    -- Keycap button
    local bindBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, btnW, 0, 20),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        Font = Enum.Font.GothamBold,
        Text = keyText,
        TextColor3 = Theme.Accent,
        TextSize = 10,
        AutoButtonColor = false,
        Parent = frame
    })
    Utility.AddCorner(bindBtn, 4)
    local bindStroke = Utility.AddStroke(bindBtn, Theme.Border, 1)

    local keyConn = nil
    local function stopListening()
        listening = false
        bindStroke.Color = Theme.Border
        if keyConn then keyConn:Disconnect(); keyConn = nil end
    end

    local function applyKey(k)
        curKey = k
        local newStr = "[" .. curKey.Name .. "]"
        local newW = math.clamp(#newStr * 7 + 12, 28, 56)
        bindBtn.Size = UDim2.new(0, newW, 0, 20)
        txtGroup.Frame.Size = UDim2.new(1, -(newW + 6), 0, 0)
        bindBtn.Text = newStr
        bindBtn.TextColor3 = Theme.Accent
        bindStroke.Color = Theme.Border
        ConfigData[keyName] = { __type = "EnumItem", enum = "KeyCode", name = curKey.Name }
        ConfigSystem.QueueSave()
        if config.Callback then task.spawn(config.Callback, curKey) end
    end


    bindBtn.Activated:Connect(function()
        if listening then return end
        listening = true
        bindBtn.Text = "[...]"
        bindBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        bindStroke.Color = Theme.Accent
        if keyConn then keyConn:Disconnect() end
        keyConn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                stopListening()
                applyKey(input.KeyCode)
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                stopListening()
                bindBtn.Text = "[" .. curKey.Name .. "]"
                bindBtn.TextColor3 = Theme.Accent
                bindStroke.Color = Theme.Border
            end
        end)
    end)

    ConfigSystem.Register(keyName, function() return curKey end, function(k) applyKey(k) end)

    return {
        Frame = frame,
        GetKey = function() return curKey end,
        SetKey = applyKey
    }
end

-- 8. TEXTBOX
local Textbox = {}
function Textbox.new(parent, config)
    local keyName = config.Name or "Textbox"
    local initial = (ConfigData[keyName] ~= nil and tostring(ConfigData[keyName])) or (config.Default or "")
    local curText = initial
    ConfigData[keyName] = curText

    local frame = Utility.Create("Frame", {
        Name = "Component_Textbox",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        Parent = parent
    })
    local stroke, strokeGrad, bgGrad = Utility.ApplyCardStyle(frame, 8)
    Utility.AddPadding(frame, 8, 8, 12, 12)

    local txtGroup = Utility.CreateTextGroup(frame, keyName, config.Desc or config.Description, 94)

    local input = Utility.Create("TextBox", {
        Size = UDim2.new(0, 88, 0, 22),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        Font = Enum.Font.Gotham,
        Text = curText,
        PlaceholderText = config.Placeholder or "Type...",
        PlaceholderColor3 = Theme.TextSecondary,
        TextColor3 = Theme.Text,
        TextSize = 10,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = frame
    })
    Utility.AddCorner(input, 4)
    Utility.AddStroke(input, Theme.Border, 1)
    Utility.AddPadding(input, 0, 0, 6, 6)

    local function applyText(t, enterPressed)
        curText = t
        input.Text = t
        ConfigData[keyName] = curText
        ConfigSystem.QueueSave()
        if config.Callback then task.spawn(config.Callback, curText, enterPressed or false) end
    end

    input.FocusLost:Connect(function(enterPressed)
        applyText(input.Text, enterPressed)
    end)

    ConfigSystem.Register(keyName, function() return curText end, function(t) applyText(t, false) end)

    return {
        Frame = frame,
        GetText = function() return curText end,
        SetText = function(t) applyText(t, false) end
    }
end

-- 9. LABEL
local Label = {}
function Label.new(parent, text)
    local frame = Utility.Create("Frame", {
        Name = "Component_Label",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = parent
    })
    local lbl = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = text or "Label",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        TextScaled = true,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    Utility.Create("UITextSizeConstraint", { MaxTextSize = 12, MinTextSize = 9, Parent = lbl })
    return {
        Set = function(newText) lbl.Text = newText end
    }
end

-- 10. PARAGRAPH
local Paragraph = {}
function Paragraph.new(parent, config)
    local frame = Utility.Create("Frame", {
        Name = "Component_Paragraph",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.SurfaceSecondary,
        Parent = parent
    })
    Utility.AddCorner(frame, 6); Utility.AddStroke(frame, Theme.Border, 1); Utility.AddPadding(frame, 10, 10, 12, 12)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 4), Parent = frame })

    Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Notice",
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })

    Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = config.Content or "",
        TextColor3 = Theme.TextSecondary,
        TextSize = 11,
        LineHeight = 1.25,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = frame
    })
    return frame
end

-- ============================================================================
-- ROW CONTAINER (DUAL / MULTI-WIDGET 2-COLUMN LAYOUT)
-- ============================================================================
local Row = {}
Row.__index = Row

function Row.new(parent)
    local self = setmetatable({}, Row)
    self.Items = {}
    self.Frame = Utility.Create("Frame", {
        Name = "Component_Row",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = parent
    })
    self.Layout = Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Parent = self.Frame
    })
    return self
end

function Row:_Register(handle)
    local children = self.Frame:GetChildren()
    local itemFrame = nil
    for _, child in ipairs(children) do
        if child:IsA("GuiObject") and not table.find(self.Items, child) then
            itemFrame = child
            break
        end
    end
    if itemFrame then
        table.insert(self.Items, itemFrame)
        if typeof(handle) == "table" and not handle.Frame then
            handle.Frame = itemFrame
        end
        local n = #self.Items
        local gap = 8
        local totalGaps = gap * (n - 1)
        local fraction = 1 / n
        local offsetPerItem = totalGaps / n
        for _, f in ipairs(self.Items) do
            f.Size = UDim2.new(fraction, -math.floor(offsetPerItem), f.Size.Y.Scale, f.Size.Y.Offset)
        end
    end
    return handle
end

function Row:AddButton(config)
    local btn = Button.new(self.Frame, config)
    return self:_Register(btn)
end

function Row:AddToggle(config)
    local toggle = Toggle.new(self.Frame, config)
    return self:_Register(toggle)
end

function Row:AddSlider(config)
    local slider = Slider.new(self.Frame, config)
    return self:_Register(slider)
end

function Row:AddDropdown(config)
    local drop = Dropdown.new(self.Frame, config)
    return self:_Register(drop)
end

function Row:AddMultiDropdown(config)
    local drop = MultiDropdown.new(self.Frame, config)
    return self:_Register(drop)
end

function Row:AddKeybind(config)
    local kb = Keybind.new(self.Frame, config)
    return self:_Register(kb)
end

function Row:AddColorPicker(config)
    local cp = ColorPicker.new(self.Frame, config)
    return self:_Register(cp)
end

function Row:AddTextbox(config)
    local tb = Textbox.new(self.Frame, config)
    return self:_Register(tb)
end

function Row:AddInput(config)
    return self:AddTextbox(config)
end

function Row:AddLabel(text)
    local lbl = Label.new(self.Frame, text)
    return self:_Register(lbl)
end

-- ============================================================================
-- SECTION CONTAINER
-- ============================================================================
local Section = {}
Section.__index = Section
function Section.new(parent, config)
    local name = (typeof(config) == "table" and (config.Name or config.Title)) or tostring(config or "Section")
    local rawIcon = (typeof(config) == "table" and config.Icon)
    local hasIcon = (rawIcon ~= nil and tostring(rawIcon) ~= "" and tostring(rawIcon) ~= "⛶")
    local defaultCollapsed = (typeof(config) == "table" and config.Collapsed == true)

    local self = setmetatable({}, Section)
    self.IsCollapsed = defaultCollapsed

    self.Frame = Utility.Create("Frame", {
        Name = "Section_" .. name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Parent = parent
    }) :: Frame
    Utility.AddCorner(self.Frame, 8)
    local secStroke = Utility.AddStroke(self.Frame, Theme.Border, 1, 0)
    Utility.AddPadding(self.Frame, 12, 12, 12, 12)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = self.Frame })

    -- Header (Interactive collapse toggle)
    local headerBtn = Utility.Create("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        LayoutOrder = 1,
        Parent = self.Frame
    })

    local iconLbl = nil
    if hasIcon then
        iconLbl = Utility.Create("TextLabel", {
            Size = UDim2.new(0, 18, 1, 0),
            Position = UDim2.new(0, 0, 0, 0),
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = tostring(rawIcon),
            TextColor3 = Theme.TextSecondary,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = headerBtn
        })
    end

    local titleLbl = Utility.Create("TextLabel", {
        Size = UDim2.new(1, hasIcon and -44 or -24, 1, 0),
        Position = UDim2.new(0, hasIcon and 20 or 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = Color3.fromRGB(245, 248, 255),
        TextSize = 12.5,
        TextTruncate = Enum.TextTruncate.None,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = headerBtn
    })

    local chevron = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 20, 1, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, 0, 0.5, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = self.IsCollapsed and ">" or "v",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = headerBtn
    })

    -- Content items container
    self.ContentFrame = Utility.Create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible = not self.IsCollapsed,
        LayoutOrder = 2,
        Parent = self.Frame
    })
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = self.ContentFrame })

    headerBtn.Activated:Connect(function()
        self.IsCollapsed = not self.IsCollapsed
        self.ContentFrame.Visible = not self.IsCollapsed
        chevron.Text = self.IsCollapsed and ">" or "v"
        chevron.TextColor3 = self.IsCollapsed and Theme.BorderBright or Color3.fromRGB(130, 138, 160)
    end)

    return self
end
function Section:AddRow() return Row.new(self.ContentFrame) end
function Section:AddButton(config) return Button.new(self.ContentFrame, config) end
function Section:AddToggle(config) return Toggle.new(self.ContentFrame, config) end
function Section:AddSlider(config) return Slider.new(self.ContentFrame, config) end
function Section:AddDropdown(config) return Dropdown.new(self.ContentFrame, config) end
function Section:AddMultiDropdown(config) return MultiDropdown.new(self.ContentFrame, config) end
function Section:AddColorPicker(config) return ColorPicker.new(self.ContentFrame, config) end
function Section:AddKeybind(config) return Keybind.new(self.ContentFrame, config) end
function Section:AddTextbox(config) return Textbox.new(self.ContentFrame, config) end
function Section:AddInput(config) return Textbox.new(self.ContentFrame, config) end
function Section:AddLabel(text) return Label.new(self.ContentFrame, text) end
function Section:AddParagraph(config) return Paragraph.new(self.ContentFrame, config) end
function Section:AddDivider()
    local div = Utility.Create("Frame", {
        Name = "Divider",
        Size = UDim2.new(1, 0, 0, 1),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = self.ContentFrame
    })
    return div
end
function Section:AddSubSection(name)
    local sub = Utility.Create("TextLabel", {
        Name = "SubSection_" .. (name or ""),
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "- " .. string.upper(name or "") .. " -",
        TextColor3 = Theme.Accent,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = self.ContentFrame
    })
    return sub
end

-- ============================================================================
-- TAB CONTAINER WITH TRUE DUAL-COLUMN WIDGET ARCHITECTURE
-- ============================================================================
local Tab = {}
Tab.__index = Tab
function Tab.new(parent, name)
    local self = setmetatable({}, Tab)
    self.Sections = {}
    self.LeftCount = 0
    self.RightCount = 0

    self.Frame = Utility.Create("ScrollingFrame", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.BorderBright,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = parent
    }) :: ScrollingFrame
    Utility.AddPadding(self.Frame, 14, 14, 14, 14)

    -- Container for dual column layout
    self.ColumnsContainer = Utility.Create("Frame", {
        Name = "ColumnsContainer",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = self.Frame
    })

    self.LeftColumn = Utility.Create("Frame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.5, -6, 0, 0),
        Position = UDim2.new(0, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Parent = self.ColumnsContainer
    })
    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.LeftColumn
    })

    self.RightColumn = Utility.Create("Frame", {
        Name = "RightColumn",
        Size = UDim2.new(0.5, -6, 0, 0),
        Position = UDim2.new(0.5, 6, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Parent = self.ColumnsContainer
    })
    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.RightColumn
    })

    self.ColumnsLayout = Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        Padding = UDim.new(0, 10),
        Parent = self.ColumnsContainer
    })

    -- Full width container (bisa di bawah columns)
    self.FullContainer = Utility.Create("Frame", {
        Name = "FullContainer",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        LayoutOrder = 3,
        Parent = self.Frame
    })
    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.FullContainer
    })

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.Frame
    })

    -- Responsive 2-column (Desktop) to 1-column (Mobile / iOS) stacker
    local function updateResponsiveColumns()
        if not self.Frame or not self.Frame.Parent then return end
        local areaW = self.Frame.AbsoluteSize.X
        local isStacked = (areaW > 0 and areaW < 540) or Utility.IsMobile()
        if isStacked then
            self.ColumnsLayout.FillDirection = Enum.FillDirection.Vertical
            self.LeftColumn.Size = UDim2.new(1, 0, 0, 0)
            self.RightColumn.Size = UDim2.new(1, 0, 0, 0)
        else
            self.ColumnsLayout.FillDirection = Enum.FillDirection.Horizontal
            self.LeftColumn.Size = UDim2.new(0.5, -5, 0, 0)
            self.RightColumn.Size = UDim2.new(0.5, -5, 0, 0)
        end
    end

    self.Frame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateResponsiveColumns)
    task.defer(updateResponsiveColumns)

    -- Aliases for backward compatibility
    self.Container = self.ColumnsContainer
    self.ColumnContainer = self.ColumnsContainer

    return self
end

function Tab:AddSection(configOrName, side)
    local cfg = (typeof(configOrName) == "table" and configOrName) or { Name = tostring(configOrName or "Section") }
    local targetSide = side or cfg.Side

    local targetCol = self.LeftColumn
    if targetSide == "Right" or targetSide == "right" or targetSide == 2 then
        targetCol = self.RightColumn
        self.RightCount = self.RightCount + 1
    elseif targetSide == "Left" or targetSide == "left" or targetSide == 1 then
        targetCol = self.LeftColumn
        self.LeftCount = self.LeftCount + 1
    elseif targetSide == "Full" or targetSide == "full" then
        targetCol = self.FullContainer
    else
        -- Default: Auto-distribute across 2 columns (Widget 1 Left, Widget 2 Right)
        if self.LeftCount <= self.RightCount then
            targetCol = self.LeftColumn
            self.LeftCount = self.LeftCount + 1
        else
            targetCol = self.RightColumn
            self.RightCount = self.RightCount + 1
        end
    end

    local sec = Section.new(targetCol, cfg)
    table.insert(self.Sections, sec)
    return sec
end

function Tab:SetVisible(v)
    if v then
        self.Frame.Position = UDim2.new(0, 8, 0, 0)
        self.Frame.Visible = true
        AnimationEngine.Tween(self.Frame, TWEEN_TAB, { Position = UDim2.new(0, 0, 0, 0) })
    else
        self.Frame.Visible = false
    end
end


-- ============================================================================
-- AUTOMATIC GAME DETECTION
-- ============================================================================
local DetectedGameName = "Universal"
pcall(function()
    local MarketplaceService = game:GetService("MarketplaceService")
    if game.PlaceId > 0 then
        local info = MarketplaceService:GetProductInfo(game.PlaceId)
        if info and info.Name and info.Name ~= "" then
            DetectedGameName = info.Name
        end
    end
end)
if DetectedGameName == "Universal" then
    pcall(function()
        local name = game:GetService("MarketplaceService"):GetProductInfo(game.PlaceId, Enum.InfoType.Asset).Name
        if name and name ~= "" then DetectedGameName = name end
    end)
    if DetectedGameName == "Universal" and game.Name and game.Name ~= "" and game.Name ~= "Place1" and game.Name ~= "Game" then
        DetectedGameName = game.Name
    end
end

-- ============================================================================
-- MAIN WINDOW CREATION
-- ============================================================================
local NovaUI = {
    GameName = DetectedGameName,
    PlaceId = game.PlaceId,
    GameId = game.GameId
}
function NovaUI:GetGameName()
    return DetectedGameName
end

function NovaUI:CreateWindow(config)
    config = config or {}
    local configVersion = config.Version or 1
    local autoLoad = (config.AutoLoad == true)
    ConfigSystem.Init(configVersion, config.ConfigName, autoLoad)

    local stealthTag = "RobloxGui_" .. string.sub(HttpService:GenerateGUID(false):gsub("-", ""), 1, 10)
    local sg = Utility.Create("ScreenGui", {
        Name = stealthTag,
        ResetOnSpawn = false,
        DisplayOrder = 100,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = targetParent
    }) :: ScreenGui

    if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
        pcall(syn.protect_gui, sg)
    elseif typeof(protect_gui) == "function" then
        pcall(protect_gui, sg)
    elseif typeof(protectgui) == "function" then
        pcall(protectgui, sg)
    end

    if getgenv then
        getgenv()._LIYHUB_CLEANUP = function()
            pcall(function() sg:Destroy() end)
        end
    end

    -- Mobile Touch Detection & Pin Tab State (Centralized safe detection)
    local isMobile = Utility.IsMobile()
    local isPinned = isMobile -- Default pinned on touch/mobile devices

    -- Device Screen & Frame Size Presets
    local DevicePresets = {
        ["PC"] = { Name = "PC (Standard)", Size = UDim2.fromOffset(740, 490), Scale = 1.0 },
        ["Android"] = { Name = "Android / Mobile", Size = UDim2.fromOffset(550, 315), Scale = 0.84 },
        ["Tablet"] = { Name = "Tablet / iPad", Size = UDim2.fromOffset(660, 420), Scale = 0.95 },
        ["Compact"] = { Name = "Compact / Mini", Size = UDim2.fromOffset(510, 290), Scale = 0.80 }
    }

    local savedPresetKey = ConfigData["_Liyhub_DevicePreset"]
    local defaultPresetKey = isMobile and "Android" or "PC"
    local activePresetKey = (config.Device and DevicePresets[config.Device] and config.Device)
        or (isMobile and "Android")
        or (savedPresetKey and DevicePresets[savedPresetKey] and savedPresetKey)
        or defaultPresetKey
    local activePreset = DevicePresets[activePresetKey] or DevicePresets["PC"]

    local sgScale = Utility.Create("UIScale", { Scale = activePreset.Scale, Parent = sg })

    local overlayFrame = Utility.Create("Frame", {
        Name = "PopupOverlayFrame",
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ZIndex = 50000,
        Parent = sg
    })
    ActiveOverlayContainer = overlayFrame

    local function getAdaptiveWindowSize(presetSize)
        local vp = Utility.GetViewportSize()
        local scale = (sgScale and sgScale.Scale) or 1
        local maxW = math.max(320, math.floor((vp.X - 16) / scale))
        local maxH = math.max(240, math.floor((vp.Y - 16) / scale))
        local targetW = math.clamp(presetSize.X.Offset, 320, maxW)
        local targetH = math.clamp(presetSize.Y.Offset, 240, maxH)
        return UDim2.fromOffset(targetW, targetH)
    end

    local targetInitSize = (config.Device and DevicePresets[config.Device] and DevicePresets[config.Device].Size)
        or (isMobile and activePreset.Size)
        or (config.Size or activePreset.Size)
    local initSize = getAdaptiveWindowSize(targetInitSize)
    local logoAsset = config.Logo or "rbxassetid://0"

    local mainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Size = initSize,
        Position = UDim2.new(0.5, -initSize.X.Offset/2, 0.5, -initSize.Y.Offset/2),
        BackgroundColor3 = Theme.Background,
        ClipsDescendants = true,
        Parent = sg
    }) :: Frame
    Utility.AddCorner(mainFrame, 10); Utility.AddStroke(mainFrame, Theme.Border, 1)

    local windowConnections = {}
    local isDestroyed = false
    local function destroyWindow()
        if isDestroyed then return end
        isDestroyed = true
                if getgenv and getgenv()._LIYHUB_CLEANUP then
            getgenv()._LIYHUB_CLEANUP = nil
        end
        if ActiveDropdownCloser then
            pcall(ActiveDropdownCloser)
        end
        for _, conn in ipairs(windowConnections) do
            if typeof(conn) == "RBXScriptConnection" then
                pcall(function() conn:Disconnect() end)
            elseif typeof(conn) == "table" and type(conn.Disconnect) == "function" then
                pcall(function() conn:Disconnect() end)
            end
        end
        windowConnections = {}
        pcall(function() sg:Destroy() end)
    end
    if getgenv then
        getgenv()._LIYHUB_CLEANUP = destroyWindow
    end

    -- Pin clamping helper: ensures floating pin stays 100% visible on any screen resolution
    local function clampPinPosition(pos)
        local vp = Utility.GetViewportSize()
        local scale = (sgScale and sgScale.Scale) or 1
        local actualW = (pinWidget and pinWidget.AbsoluteSize.X > 0 and pinWidget.AbsoluteSize.X) or (110 * scale)
        local actualH = (pinWidget and pinWidget.AbsoluteSize.Y > 0 and pinWidget.AbsoluteSize.Y) or (32 * scale)
        local minScreenX = 8
        local maxScreenX = math.max(minScreenX, vp.X - actualW - 8)
        local minScreenY = 28
        local maxScreenY = math.max(minScreenY, vp.Y - actualH - 8)

        local screenX = (pos.X.Scale * (vp.X / scale) + pos.X.Offset) * scale
        local screenY = (pos.Y.Scale * (vp.Y / scale) + pos.Y.Offset) * scale

        local clampedScreenX = math.clamp(screenX, minScreenX, maxScreenX)
        local clampedScreenY = math.clamp(screenY, minScreenY, maxScreenY)

        return UDim2.new(0, math.round(clampedScreenX / scale), 0, math.round(clampedScreenY / scale))
    end

    -- Default pin position: Top Center Dynamic Island (UDim2.new(0.5, -58, 0, 50)) avoids Roblox topbar/chat/menu collision
    local defaultPinPos = config.PinPosition or UDim2.new(0.5, -58, 0, 50)
    local savedPinPos = ConfigData["_Liyhub_PinPos"]
    if savedPinPos and typeof(savedPinPos) == "table" and savedPinPos.X and savedPinPos.Y then
        pcall(function()
            defaultPinPos = UDim2.new(savedPinPos.X[1] or 0.5, savedPinPos.X[2] or -58, savedPinPos.Y[1] or 0, savedPinPos.Y[2] or 50)
        end)
    end
    defaultPinPos = clampPinPosition(defaultPinPos)

    local titleText = config.Title
    if not titleText or titleText == "" then
        titleText = "Liyhub | " .. DetectedGameName
    elseif titleText == "Liyhub" or titleText == "LIYHUB.CC" or titleText == "LIYHUB" or titleText == "LiyHub" then
        titleText = "Liyhub | " .. DetectedGameName
    elseif titleText:find("{game}") then
        titleText = titleText:gsub("{game}", DetectedGameName)
    end
    if config.Footer and config.Footer ~= "" then
        titleText = titleText .. " " .. config.Footer
    end

    local cleanPinTitle = (titleText or "Liyhub"):gsub("%s*|%s*$", ""):gsub("%s+$", "")

    -- Floating Mobile Pin Tab (SpeedHub / ChloeX pattern)
    local pinWidget = Utility.Create("TextButton", {
        Name = "FloatingPinWidget",
        Size = UDim2.new(0, 0, 0, 32),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = defaultPinPos,
        BackgroundColor3 = Theme.Surface,
        Text = "",
        Visible = false,
        AutoButtonColor = false,
        ZIndex = 100,
        Parent = sg
    })
    Utility.AddCorner(pinWidget, 16)
    local pinStroke = Utility.AddStroke(pinWidget, Theme.Accent, 1, 0.3)
    Utility.AddPadding(pinWidget, 0, 0, 8, 16)
    local pinLogo = Utility.CreateLiyhubMark(pinWidget, 18, 8, -9, logoAsset)
    pinLogo.ZIndex = 102
    for _, desc in ipairs(pinLogo:GetDescendants()) do
        if desc:IsA("GuiObject") then desc.ZIndex = 102 end
    end
    local pinLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        Position = UDim2.new(0, 34, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = cleanPinTitle,
        TextColor3 = Theme.Text,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Active = false,
        Selectable = false,
        ZIndex = 102,
        Parent = pinWidget
    })
    pinWidget.MouseEnter:Connect(function()
        AnimationEngine.Tween(pinWidget, TWEEN_QUICK, { BackgroundColor3 = Theme.SurfaceElevated })
        pinStroke.Transparency = 0
    end)
    pinWidget.MouseLeave:Connect(function()
        AnimationEngine.Tween(pinWidget, TWEEN_QUICK, { BackgroundColor3 = Theme.Surface })
        pinStroke.Transparency = 0.3
    end)

    -- Dynamic viewport listener: keep pin and mainFrame clamped if screen orientation/size changes
    local function clampWindowToBounds()
        if not mainFrame or not mainFrame.Parent then return end
        local vp = Utility.GetViewportSize()
        local scale = (sgScale and sgScale.Scale) or 1
        local maxLocalW = math.max(320, math.floor((vp.X - 16) / scale))
        local maxLocalH = math.max(240, math.floor((vp.Y - 16) / scale))
        local curW = math.min(mainFrame.Size.X.Offset, maxLocalW)
        local curH = math.min(mainFrame.Size.Y.Offset, maxLocalH)
        mainFrame.Size = UDim2.fromOffset(curW, curH)

        local actualW = mainFrame.AbsoluteSize.X
        local actualH = mainFrame.AbsoluteSize.Y
        if actualW <= 0 or actualH <= 0 then
            actualW = curW * scale
            actualH = curH * scale
        end
        local maxScreenX = math.max(8, vp.X - actualW - 8)
        local maxScreenY = math.max(8, vp.Y - actualH - 8)
        local screenX = (mainFrame.Position.X.Scale * (vp.X / scale) + mainFrame.Position.X.Offset) * scale
        local screenY = (mainFrame.Position.Y.Scale * (vp.Y / scale) + mainFrame.Position.Y.Offset) * scale
        local clampedScreenX = math.clamp(screenX, 8, maxScreenX)
        local clampedScreenY = math.clamp(screenY, 8, maxScreenY)
        mainFrame.Position = UDim2.new(0, math.round(clampedScreenX / scale), 0, math.round(clampedScreenY / scale))
    end

    local updateNotifAreaLayout = nil

    local function onViewportChanged()
        if pinWidget and pinWidget.Parent then
            pinWidget.Position = clampPinPosition(pinWidget.Position)
        end
        clampWindowToBounds()
        if updateNotifAreaLayout then
            updateNotifAreaLayout()
        end
            end
    local cam = workspace.CurrentCamera
    if cam then
        table.insert(windowConnections, cam:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged))
    end
    table.insert(windowConnections, workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
        local newCam = workspace.CurrentCamera
        if newCam then
            table.insert(windowConnections, newCam:GetPropertyChangedSignal("ViewportSize"):Connect(onViewportChanged))
            onViewportChanged()
        end
    end))
    table.insert(windowConnections, mainFrame:GetPropertyChangedSignal("AbsolutePosition"):Connect(function()
            end))
    table.insert(windowConnections, mainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
            end))

    -- Window Toggle Engine: Predictable state transitions, single execution, no race conditions
    local isToggling = false
    local function toggleWindow(forceState)
        if isToggling then return end
        isToggling = true

        local targetVisible = (forceState ~= nil) and forceState or (not mainFrame.Visible)
        if targetVisible then
            clampWindowToBounds()
            mainFrame.Visible = true
            pinWidget.Visible = false
        else
            mainFrame.Visible = false
            pinWidget.Position = clampPinPosition(pinWidget.Position)
            pinWidget.Visible = true
        end

        task.defer(function()
            isToggling = false
        end)
    end

    local function onPinWidgetToggle()
        toggleWindow()
    end

    local pinTouchHit = Utility.Create("TextButton", {
        Name = "PinTouchHit",
        Size = UDim2.new(1, 12, 1, 12),
        Position = UDim2.new(0, -6, 0, -6),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 101,
        Parent = pinWidget
    })

    -- Draggable with click: single input state machine handles tap to toggle and drag to relocate
    local cleanupPinDrag = Utility.MakeDraggableWithClick(pinWidget, pinTouchHit, onPinWidgetToggle, function(finalPos)
        local clamped = clampPinPosition(finalPos)
        pinWidget.Position = clamped
        ConfigData["_Liyhub_PinPos"] = {
            X = { clamped.X.Scale, clamped.X.Offset },
            Y = { clamped.Y.Scale, clamped.Y.Offset }
        }
        ConfigSystem.QueueSave()
    end)
    table.insert(windowConnections, { Disconnect = cleanupPinDrag })

    -- Customizable UI Toggle Keybind Engine (SpeedHub / Custom Preference)
    local defaultToggleKey = config.ToggleKey or Enum.KeyCode.RightControl
    if typeof(defaultToggleKey) == "string" then
        pcall(function() defaultToggleKey = Enum.KeyCode[defaultToggleKey] or Enum.KeyCode.RightControl end)
    end
    local currentToggleKey = defaultToggleKey
    if ConfigData["_Liyhub_ToggleKey"] and typeof(ConfigData["_Liyhub_ToggleKey"]) == "string" then
        pcall(function()
            local saved = Enum.KeyCode[ConfigData["_Liyhub_ToggleKey"]]
            if saved then currentToggleKey = saved end
        end)
    end

    local onKeybindChangedCallbacks = {}
    local function setToggleKey(newKey)
        if not newKey then return end
        currentToggleKey = newKey
        ConfigData["_Liyhub_ToggleKey"] = newKey.Name
        ConfigSystem.QueueSave()
        for _, cb in ipairs(onKeybindChangedCallbacks) do
            pcall(cb, newKey)
        end
    end

    local toggleKeyConn = UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if UserInputService:GetFocusedTextBox() then return end
        if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == currentToggleKey then
            toggleWindow()
        end
    end)
    table.insert(windowConnections, toggleKeyConn)

    -- Top Header Bar (Rounded top corners matching mainFrame)
    local topBar = Utility.Create("Frame", { Name = "TopBar", Size = UDim2.new(1, 0, 0, 38), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = mainFrame })
    Utility.AddCorner(topBar, 10)
    Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 1, -10), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = topBar })
    Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, ZIndex = 2, Parent = topBar })

    Utility.CreateLiyhubMark(topBar, 22, 12, -11, logoAsset)

    local leftHeader = Utility.Create("Frame", {
        Name = "LeftHeader",
        Size = UDim2.new(1, -150, 1, 0),
        Position = UDim2.new(0, 44, 0, 0),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        Parent = topBar
    })
    Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = leftHeader
    })

    Utility.Create("TextLabel", {
        Name = "TitleLabel",
        LayoutOrder = 1,
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = titleText,
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = leftHeader
    })

    -- Live Status Indicator Badge
    local statusBadge = Utility.Create("Frame", {
        Name = "StatusBadge",
        LayoutOrder = 2,
        Size = UDim2.new(0, 72, 0, 20),
        BackgroundColor3 = Theme.SurfaceSecondary,
        BorderSizePixel = 0,
        Parent = leftHeader
    })
    Utility.AddCorner(statusBadge, 10)
    Utility.AddStroke(statusBadge, Theme.Border, 1)

    local ledDot = Utility.Create("Frame", {
        Size = UDim2.new(0, 6, 0, 6),
        Position = UDim2.new(0, 8, 0.5, -3),
        BackgroundColor3 = Color3.fromRGB(0, 230, 118),
        BorderSizePixel = 0,
        Parent = statusBadge
    })
    Utility.AddCorner(ledDot, 3)

    Utility.Create("TextLabel", {
        Size = UDim2.new(1, -18, 1, 0),
        Position = UDim2.new(0, 18, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "ONLINE",
        TextColor3 = Color3.fromRGB(0, 230, 118),
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = statusBadge
    })

    local verBadge = Utility.Create("Frame", {
        Name = "VerBadge",
        LayoutOrder = 3,
        Size = UDim2.new(0, 36, 0, 20),
        BackgroundColor3 = Theme.SurfaceSecondary,
        BorderSizePixel = 0,
        Parent = leftHeader
    })
    Utility.AddCorner(verBadge, 10)
    Utility.AddStroke(verBadge, Theme.Border, 1)
    Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "v" .. tostring(configVersion),
        TextColor3 = Theme.TextSecondary,
        TextSize = 9,
        Parent = verBadge
    })
    local ctrlW = isMobile and 108 or 96
    local ctrlH = isMobile and 28 or 26
    local btnW = isMobile and 30 or 26
    local btnH = isMobile and 28 or 26

    -- Window Controls (📌 Pin on Left, - Minimize in Middle, X Close on Right)
    local controls = Utility.Create("Frame", {
        Name = "WindowControls",
        Size = UDim2.new(0, ctrlW, 0, ctrlH),
        Position = UDim2.new(1, -(ctrlW + 10), 0.5, -ctrlH / 2),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 50,
        Parent = topBar
    })
    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = controls
    })

    -- Make topBar draggable while protecting controls from drag interception
    local cleanupTopDrag = Utility.MakeDraggable(mainFrame, topBar, controls)
    table.insert(windowConnections, { Disconnect = cleanupTopDrag })

    -- 1. Pin Tab Button (📌) on LEFT (LayoutOrder = 1)
    local pinBtn = Utility.Create("TextButton", {
        Name = "PinButton",
        LayoutOrder = 1,
        Size = UDim2.new(0, btnW, 0, btnH),
        BackgroundColor3 = isPinned and Theme.SurfaceElevated or Theme.SurfaceSecondary,
        Font = Enum.Font.GothamBold,
        Text = "📌",
        TextColor3 = isPinned and Theme.Accent or Theme.TextSecondary,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 51,
        Parent = controls
    })
    Utility.AddCorner(pinBtn, 6)
    local pinBtnStroke = Utility.AddStroke(pinBtn, isPinned and Theme.Accent or Theme.Border, 1)

    pinBtn.Activated:Connect(function()
        toggleWindow(false)
        Notification.Notify({
            Title = "Pinned to Screen",
            Content = "UI collapsed to floating pin tab. Tap floating pin to reopen.",
            Duration = 2.0
        })
    end)

    -- 2. Minimize Button (-) in MIDDLE (LayoutOrder = 2)
    local minBtn = Utility.Create("TextButton", {
        Name = "MinimizeButton",
        LayoutOrder = 2,
        Size = UDim2.new(0, btnW, 0, btnH),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 51,
        Parent = controls
    })
    Utility.AddCorner(minBtn, 6)
    local minStroke = Utility.AddStroke(minBtn, Theme.Border, 1)
    local minBar = Utility.Create("Frame", {
        Size = UDim2.new(0, 12, 0, 2),
        Position = UDim2.new(0.5, -6, 0.5, -1),
        BackgroundColor3 = Theme.Text,
        BorderSizePixel = 0,
        Active = false,
        Parent = minBtn
    })

    minBtn.MouseEnter:Connect(function()
        minBtn.BackgroundColor3 = Theme.SurfaceElevated
        minStroke.Color = Theme.BorderBright
    end)
    minBtn.MouseLeave:Connect(function()
        minBtn.BackgroundColor3 = Theme.SurfaceSecondary
        minStroke.Color = Theme.Border
    end)

    minBtn.Activated:Connect(function()
        toggleWindow(false)
        Notification.Notify({ Title = "Minimized", Content = "Tap floating pin tab or press toggle key to restore", Duration = 2.0 })
    end)

    -- 3. Close Button (X) on RIGHT (LayoutOrder = 3)
    local closeBtn = Utility.Create("TextButton", {
        Name = "CloseButton",
        LayoutOrder = 3,
        Size = UDim2.new(0, btnW, 0, btnH),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        ZIndex = 51,
        Parent = controls
    })
    Utility.AddCorner(closeBtn, 6)
    local closeStroke = Utility.AddStroke(closeBtn, Theme.Border, 1)

    closeBtn.MouseEnter:Connect(function()
        closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        closeStroke.Color = Color3.fromRGB(255, 80, 80)
        closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end)
    closeBtn.MouseLeave:Connect(function()
        closeBtn.BackgroundColor3 = Theme.SurfaceSecondary
        closeStroke.Color = Theme.Border
        closeBtn.TextColor3 = Theme.Text
    end)

    closeBtn.Activated:Connect(function()
        destroyWindow()
    end)

    -- Window Resize Handle (Touch Hit Area with bottom-right visual grip)
    local gripHitSize = isMobile and 44 or 36
    local resizeGripHit = Utility.Create("TextButton", {
        Name = "ResizeGripHit",
        Size = UDim2.new(0, gripHitSize, 0, gripHitSize),
        Position = UDim2.new(1, -gripHitSize, 1, -gripHitSize),
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 60,
        Parent = mainFrame
    })

    local resizeGripVisual = Utility.Create("Frame", {
        Name = "ResizeGripVisual",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -16, 1, -16),
        BackgroundTransparency = 1,
        Active = false,
        Parent = resizeGripHit
    })
    -- Three clean diagonal grip lines (Neverlose/Sleek design) that cleanly contour the rounded bottom-right corner
    local gripLine1 = Utility.Create("Frame", {
        Size = UDim2.new(0, 3, 0, 3),
        Position = UDim2.new(1, -4, 1, -4),
        BackgroundColor3 = Theme.BorderBright,
        BorderSizePixel = 0,
        Active = false,
        Parent = resizeGripVisual
    })
    Utility.AddCorner(gripLine1, 1)
    local gripLine2 = Utility.Create("Frame", {
        Size = UDim2.new(0, 7, 0, 2),
        Position = UDim2.new(1, -8, 1, -8),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Active = false,
        Parent = resizeGripVisual
    })
    Utility.AddCorner(gripLine2, 1)
    local gripLine3 = Utility.Create("Frame", {
        Size = UDim2.new(0, 11, 0, 2),
        Position = UDim2.new(1, -12, 1, -12),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Active = false,
        Parent = resizeGripVisual
    })
    Utility.AddCorner(gripLine3, 1)

    local isResizing = false
    local resizeStart = nil
    local resizeStartSize = nil
    local resizeMoveConn = nil
    local resizeEndConn = nil
    local resizeCancelConn = nil
    local activeResizeInput = nil

    local function stopResize()
        if resizeMoveConn then resizeMoveConn:Disconnect(); resizeMoveConn = nil end
        if resizeEndConn then resizeEndConn:Disconnect(); resizeEndConn = nil end
        if resizeCancelConn then resizeCancelConn:Disconnect(); resizeCancelConn = nil end
        activeResizeInput = nil
        isResizing = false
    end

    resizeGripHit.InputBegan:Connect(function(input)
        if isResizing or activeResizeInput then return end
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            activeResizeInput = input
            isResizing = true
            resizeStart = input.Position
            resizeStartSize = mainFrame.Size
            local scale = (sgScale and sgScale.Scale) or 1

            resizeMoveConn = UserInputService.InputChanged:Connect(function(inp)
                local isMatch = (activeResizeInput and activeResizeInput.UserInputType == Enum.UserInputType.Touch and (inp == activeResizeInput or inp.Position == activeResizeInput.Position))
                    or (activeResizeInput and activeResizeInput.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseMovement)
                if isResizing and isMatch and resizeStart and resizeStartSize then
                    local vp = Utility.GetViewportSize()
                    local delta = inp.Position - resizeStart
                    local deltaLocalX = delta.X / scale
                    local deltaLocalY = delta.Y / scale
                    local maxLocalW = math.max(320, math.floor((vp.X - 16) / scale))
                    local maxLocalH = math.max(240, math.floor((vp.Y - 16) / scale))
                    local newW = math.clamp(resizeStartSize.X.Offset + deltaLocalX, 320, maxLocalW)
                    local newH = math.clamp(resizeStartSize.Y.Offset + deltaLocalY, 240, maxLocalH)
                    mainFrame.Size = UDim2.fromOffset(math.round(newW), math.round(newH))
                end
            end)

            resizeEndConn = UserInputService.InputEnded:Connect(function(inp)
                local isMatch = (activeResizeInput and activeResizeInput.UserInputType == Enum.UserInputType.Touch and (inp == activeResizeInput or inp.Position == activeResizeInput.Position))
                    or (activeResizeInput and activeResizeInput.UserInputType == Enum.UserInputType.MouseButton1 and inp.UserInputType == Enum.UserInputType.MouseButton1)
                if isMatch then
                    stopResize()
                end
            end)

            resizeCancelConn = input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.Cancel then
                    stopResize()
                end
            end)
        end
    end)

    table.insert(windowConnections, { Disconnect = stopResize })

    -- Notification Stack
    local notifArea = Utility.Create("Frame", { Size = UDim2.new(0, 280, 1, -50), Position = UDim2.new(1, -290, 0, 45), BackgroundTransparency = 1, Parent = sg })
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom, Parent = notifArea })
    Notification.Container = notifArea

    updateNotifAreaLayout = function()
        if not notifArea or not notifArea.Parent then return end
        local vp = Utility.GetViewportSize()
        local scale = (sgScale and sgScale.Scale) or 1
        local notifW = math.min(280, math.max(200, math.floor((vp.X - 32) / scale)))
        notifArea.Size = UDim2.new(0, notifW, 1, -50)
        notifArea.Position = UDim2.new(1, -notifW - 10, 0, 45)
    end
    updateNotifAreaLayout()

    -- Main Content Layout (Sidebar rounded at bottom-left)
    local bodyFrame = Utility.Create("Frame", { Name = "BodyFrame", Size = UDim2.new(1, 0, 1, -38), Position = UDim2.new(0, 0, 0, 38), BackgroundTransparency = 1, Parent = mainFrame })
    local sidebarFrame = Utility.Create("Frame", { Name = "SidebarFrame", Size = UDim2.new(0, 160, 1, 0), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = bodyFrame })
    Utility.AddCorner(sidebarFrame, 10)
    Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 10), Position = UDim2.new(0, 0, 0, 0), BackgroundColor3 = Theme.Surface, BorderSizePixel = 0, Parent = sidebarFrame })
    Utility.Create("Frame", { Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(1, -1, 0, 0), BackgroundColor3 = Theme.Border, BorderSizePixel = 0, ZIndex = 2, Parent = sidebarFrame })

    -- Sidebar Navigation Scroll with Clamped Height & Smooth Scroll
    local navScroll = Utility.Create("ScrollingFrame", {
        Name = "NavScroll",
        Size = UDim2.new(1, -16, 1, -120),
        Position = UDim2.new(0, 8, 0, 10),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = Theme.BorderBright,
        ScrollBarImageTransparency = 0.5,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        ElasticBehavior = Enum.ElasticBehavior.Always,
        ScrollingEnabled = true,
        ClipsDescendants = true,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = sidebarFrame
    })
    Utility.AddPadding(navScroll, 0, 4, 0, 4)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = navScroll })


    -- Divider above Settings
    Utility.Create("Frame", {
        Name = "SidebarDivider",
        Size = UDim2.new(1, -16, 0, 1),
        Position = UDim2.new(0, 8, 1, -106),
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Parent = sidebarFrame
    })

    local settingsBtn = Utility.Create("TextButton", {
        Size = UDim2.new(1, -16, 0, 34),
        Position = UDim2.new(0, 8, 1, -96),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamBold,
        FontFace = Fonts.Heading,
        Text = "  Settings",
        TextColor3 = Theme.Text,
        TextSize = 12.5,
        TextXAlignment = Enum.TextXAlignment.Left,
        AutoButtonColor = false,
        Parent = sidebarFrame
    })
    Utility.AddCorner(settingsBtn, 6); Utility.AddStroke(settingsBtn, Theme.Border, 1); Utility.AddPadding(settingsBtn, 0, 0, 8, 8)

    local profileCard = Utility.Create("Frame", { Size = UDim2.new(1, -16, 0, 48), Position = UDim2.new(0, 8, 1, -56), BackgroundColor3 = Theme.SurfaceSecondary, Parent = sidebarFrame })
    Utility.AddCorner(profileCard, 6); Utility.AddStroke(profileCard, Theme.Border, 1); Utility.AddPadding(profileCard, 6, 6, 8, 8)
    local avatarImg = Utility.Create("ImageLabel", { Size = UDim2.new(0, 32, 0, 32), Position = UDim2.new(0, 0, 0.5, -16), BackgroundColor3 = Theme.Surface, Image = "rbxassetid://0", Parent = profileCard })
    Utility.AddCorner(avatarImg, 16)
    if LocalPlayer then
        task.spawn(function()
            pcall(function()
                local content, _ = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
                if content then avatarImg.Image = content end
            end)
        end)
    end
    Utility.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 18), Position = UDim2.new(0, 38, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = LocalPlayer and LocalPlayer.DisplayName or "Developer", TextColor3 = Theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = profileCard })
    Utility.Create("TextLabel", { Size = UDim2.new(1, -40, 0, 16), Position = UDim2.new(0, 38, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold,
        FontFace = Fonts.Heading,
        Text = "Liyhub - User",
        TextColor3 = Theme.Accent,
        TextSize = 10.5, TextXAlignment = Enum.TextXAlignment.Left, Parent = profileCard })

    local contentArea = Utility.Create("Frame", { Name = "ContentArea", Size = UDim2.new(1, -160, 1, 0), Position = UDim2.new(0, 160, 0, 0), BackgroundTransparency = 1, BorderSizePixel = 0, Parent = bodyFrame })

    local sidebarCollapsed = false
    local function updateSidebarLayout()
        local winW = mainFrame.AbsoluteSize.X
        local isMobileScreen = Utility.IsMobile() or (winW > 0 and winW < 580)
        local sbWidth = 160
        if sidebarCollapsed then
            sbWidth = 0
            sidebarFrame.Visible = false
        else
            sidebarFrame.Visible = true
            if isMobileScreen then
                sbWidth = math.clamp(math.floor(winW * 0.28), 115, 135)
            else
                sbWidth = math.clamp(math.floor(winW * 0.25), 140, 185)
            end
        end
        sidebarFrame.Size = UDim2.new(0, sbWidth, 1, 0)
        contentArea.Size = UDim2.new(1, -sbWidth, 1, 0)
        contentArea.Position = UDim2.new(0, sbWidth, 0, 0)
    end
    table.insert(windowConnections, mainFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSidebarLayout))
    updateSidebarLayout()

    -- Settings Page View with Clamped Height
    local settingsPage = Utility.Create("ScrollingFrame", {
        Name = "SettingsPage",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = Theme.BorderBright,
        ScrollBarImageTransparency = 0.4,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Visible = false,
        Parent = contentArea
    })
    Utility.AddPadding(settingsPage, 16, 16, 16, 16)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 14), Parent = settingsPage })

    Utility.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = "Interface & Library Settings", TextColor3 = Theme.Text, TextSize = 16, TextXAlignment = Enum.TextXAlignment.Left, Parent = settingsPage })

    local function buildSettingsSection(titleText, options, callback)
        local secCard = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = Theme.Surface, Parent = settingsPage })
        Utility.AddCorner(secCard, 8); Utility.AddStroke(secCard, Theme.Border, 1); Utility.AddPadding(secCard, 12, 12, 12, 12)
        Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = secCard })
        Utility.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = titleText, TextColor3 = Theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = secCard })
        local row = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = secCard })
        Utility.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = row })
        local optBtns = {}
        for idx, opt in ipairs(options) do
            local ob = Utility.Create("TextButton", { Size = UDim2.new(1 / #options, -((#options - 1) * 8 / #options), 1, 0), BackgroundColor3 = idx == 2 and Theme.Accent or Theme.SurfaceSecondary, Font = Enum.Font.GothamMedium, Text = opt, TextColor3 = Theme.Text, TextSize = 12, AutoButtonColor = false, Parent = row })
            Utility.AddCorner(ob, 6); table.insert(optBtns, ob)
            ob.Activated:Connect(function()
                for _, b in ipairs(optBtns) do b.BackgroundColor3 = (b == ob) and Theme.Accent or Theme.SurfaceSecondary end
                if callback then callback(opt) end
            end)
        end
    end

    -- Device Screen & Frame Size Presets
    local deviceCard = Utility.Create("Frame", {
        Name = "DeviceCard",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        Parent = settingsPage
    })
    Utility.AddCorner(deviceCard, 8); Utility.AddStroke(deviceCard, Theme.Border, 1); Utility.AddPadding(deviceCard, 12, 12, 12, 12)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = deviceCard })

    Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Device & Screen Presets (Auto: " .. (isMobile and "Android" or "PC") .. ")",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = deviceCard
    })

    local presetRow = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = deviceCard })
    Utility.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = presetRow })

    local presetKeys = { "PC", "Android", "Tablet", "Compact" }
    local presetBtns = {}
    local function applyDevicePreset(pKey)
        local preset = DevicePresets[pKey]
        if not preset then return end
        activePresetKey = pKey
        ConfigData["_Liyhub_DevicePreset"] = pKey
        ConfigSystem.QueueSave()

        local targetSize = preset.Size
        sgScale.Scale = preset.Scale

        local vp = Utility.GetViewportSize()
        local maxW = math.max(320, math.floor((vp.X - 16) / preset.Scale))
        local maxH = math.max(240, math.floor((vp.Y - 16) / preset.Scale))
        local effW = math.min(targetSize.X.Offset, maxW)
        local effH = math.min(targetSize.Y.Offset, maxH)
        local finalSize = UDim2.fromOffset(effW, effH)

        AnimationEngine.Tween(mainFrame, TWEEN_SMOOTH, {
            Size = finalSize,
            Position = UDim2.new(0.5, -effW/2, 0.5, -effH/2)
        })
        for k, b in pairs(presetBtns) do
            b.BackgroundColor3 = (k == pKey) and Theme.Accent or Theme.SurfaceSecondary
        end
        if pinWidget and pinWidget.Parent then
            pinWidget.Position = clampPinPosition(pinWidget.Position)
        end
        updateSidebarLayout()
        Notification.Notify({
            Title = "Device Preset",
            Content = "Applied " .. preset.Name .. " (" .. tostring(finalSize.X.Offset) .. "x" .. tostring(finalSize.Y.Offset) .. ")",
            Type = "Success",
            Duration = 2.0
        })
    end

    for _, pKey in ipairs(presetKeys) do
        local pData = DevicePresets[pKey]
        local isCur = (pKey == activePresetKey)
        local btn = Utility.Create("TextButton", {
            Size = UDim2.new(1 / #presetKeys, -((#presetKeys - 1) * 8 / #presetKeys), 1, 0),
            BackgroundColor3 = isCur and Theme.Accent or Theme.SurfaceSecondary,
            Font = Enum.Font.GothamMedium,
            Text = pKey,
            TextColor3 = Theme.Text,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = presetRow
        })
        Utility.AddCorner(btn, 6)
        presetBtns[pKey] = btn
        btn.Activated:Connect(function()
            applyDevicePreset(pKey)
        end)
    end

    -- Interactive Custom Toggle Keybind Card
    local keybindCard = Utility.Create("Frame", {
        Name = "KeybindCard",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        Parent = settingsPage
    })
    Utility.AddCorner(keybindCard, 8); Utility.AddStroke(keybindCard, Theme.Border, 1); Utility.AddPadding(keybindCard, 12, 12, 12, 12)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = keybindCard })

    local kbHeaderRow = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Parent = keybindCard })
    Utility.Create("TextLabel", {
        Size = UDim2.new(1, -125, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "UI Show / Hide Keybind",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = kbHeaderRow
    })

    local kbInputBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 120, 0, 24),
        Position = UDim2.new(1, -120, 0, 0),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamBold,
        Text = "[" .. currentToggleKey.Name .. "]",
        TextColor3 = Theme.Accent,
        TextSize = 11,
        AutoButtonColor = false,
        Parent = kbHeaderRow
    })
    Utility.AddCorner(kbInputBtn, 4); Utility.AddStroke(kbInputBtn, Theme.Border, 1)

    local isListeningForToggleKey = false
    local kbListenConn = nil
    kbInputBtn.Activated:Connect(function()
        if isListeningForToggleKey then return end
        isListeningForToggleKey = true
        kbInputBtn.Text = "[Press Any Key]"
        kbInputBtn.TextColor3 = Color3.fromRGB(255, 200, 60)
        if kbListenConn then kbListenConn:Disconnect() end
        kbListenConn = UserInputService.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Keyboard then
                isListeningForToggleKey = false
                if kbListenConn then kbListenConn:Disconnect(); kbListenConn = nil end
                setToggleKey(input.KeyCode)
                kbInputBtn.Text = "[" .. input.KeyCode.Name .. "]"
                kbInputBtn.TextColor3 = Theme.Accent
                Notification.Notify({ Title = "Keybind Updated", Content = "UI Toggle Key set to " .. input.KeyCode.Name, Type = "Success" })
            elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                isListeningForToggleKey = false
                if kbListenConn then kbListenConn:Disconnect(); kbListenConn = nil end
                kbInputBtn.Text = "[" .. currentToggleKey.Name .. "]"
                kbInputBtn.TextColor3 = Theme.Accent
            end
        end)
    end)

    table.insert(windowConnections, {
        Disconnect = function()
            if kbListenConn then kbListenConn:Disconnect(); kbListenConn = nil end
        end
    })

    table.insert(onKeybindChangedCallbacks, function(k)
        kbInputBtn.Text = "[" .. k.Name .. "]"
        kbInputBtn.TextColor3 = Theme.Accent
    end)

    -- Quick Presets Row
    local presetRow = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = keybindCard })
    Utility.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = presetRow })

    local presetKeys = { "RightControl", "RightShift", "Insert", "LeftAlt", "F4" }
    for _, kName in ipairs(presetKeys) do
        local pb = Utility.Create("TextButton", {
            Size = UDim2.new(1 / #presetKeys, -5, 1, 0),
            BackgroundColor3 = (currentToggleKey.Name == kName) and Theme.SurfaceElevated or Theme.SurfaceSecondary,
            Font = Enum.Font.GothamMedium,
            Text = kName,
            TextColor3 = (currentToggleKey.Name == kName) and Theme.Accent or Theme.TextSecondary,
            TextSize = 10,
            AutoButtonColor = false,
            Parent = presetRow
        })
        Utility.AddCorner(pb, 4); Utility.AddStroke(pb, Theme.Border, 1)
        pb.Activated:Connect(function()
            local targetCode = Enum.KeyCode[kName]
            if targetCode then
                setToggleKey(targetCode)
                Notification.Notify({ Title = "Keybind Set", Content = "UI Toggle Key set to " .. kName, Type = "Success" })
            end
        end)
        table.insert(onKeybindChangedCallbacks, function(activeK)
            local match = (activeK.Name == kName)
            pb.BackgroundColor3 = match and Theme.SurfaceElevated or Theme.SurfaceSecondary
            pb.TextColor3 = match and Theme.Accent or Theme.TextSecondary
        end)
    end

    -- Pin Tab Screen Position Card (One-click snaps avoiding all Roblox CoreGui overlaps)
    local pinPosPresets = {
        { Name = "Top Center", Pos = UDim2.new(0.5, -58, 0, 50) },
        { Name = "Left Middle", Pos = UDim2.new(0, 14, 0.45, -17) },
        { Name = "Right Middle", Pos = UDim2.new(1, -148, 0.45, -17) },
        { Name = "Bottom Center", Pos = UDim2.new(0.5, -67, 1, -48) }
    }
    local pinPosCard = Utility.Create("Frame", {
        Name = "PinPosCard",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        Parent = settingsPage
    })
    Utility.AddCorner(pinPosCard, 8); Utility.AddStroke(pinPosCard, Theme.Border, 1); Utility.AddPadding(pinPosCard, 12, 12, 12, 12)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = pinPosCard })
    Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Pin Tab Screen Position",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = pinPosCard
    })
    local pinPosRow = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 26), BackgroundTransparency = 1, Parent = pinPosCard })
    Utility.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 6), Parent = pinPosRow })

    for _, pData in ipairs(pinPosPresets) do
        local ppb = Utility.Create("TextButton", {
            Size = UDim2.new(1 / #pinPosPresets, -5, 1, 0),
            BackgroundColor3 = Theme.SurfaceSecondary,
            Font = Enum.Font.GothamMedium,
            Text = pData.Name,
            TextColor3 = Theme.TextSecondary,
            TextSize = 10,
            AutoButtonColor = false,
            Parent = pinPosRow
        })
        Utility.AddCorner(ppb, 4); Utility.AddStroke(ppb, Theme.Border, 1)
        ppb.Activated:Connect(function()
            local clamped = clampPinPosition(pData.Pos)
            pinWidget.Position = clamped
            ConfigData["_Liyhub_PinPos"] = {
                X = { clamped.X.Scale, clamped.X.Offset },
                Y = { clamped.Y.Scale, clamped.Y.Offset }
            }
            ConfigSystem.QueueSave()
            Notification.Notify({ Title = "Pin Relocated", Content = "Floating pin set to " .. pData.Name, Type = "Success" })
        end)
    end

    -- ========================================================================
    -- CONFIGURATION MANAGER (CHLOE X ARCHITECTURE)
    -- ========================================================================
    local configCard = Utility.Create("Frame", {
        Name = "ConfigManagerCard",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = Theme.Surface,
        Parent = settingsPage
    })
    Utility.AddCorner(configCard, 8); Utility.AddStroke(configCard, Theme.Border, 1); Utility.AddPadding(configCard, 14, 14, 14, 14)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 10), Parent = configCard })

    -- Header row with status badge
    local cfgHeader = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 22), BackgroundTransparency = 1, Parent = configCard })
    Utility.Create("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Configuration Manager",
        TextColor3 = Theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = cfgHeader
    })
    local curBadge = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 84, 1, 0),
        Position = UDim2.new(1, -84, 0, 0),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamMedium,
        Text = ConfigSystem.CurrentProfile,
        TextColor3 = Theme.Accent,
        TextSize = 11,
        Parent = cfgHeader
    })
    Utility.AddCorner(curBadge, 4); Utility.AddStroke(curBadge, Theme.Border, 1)

    -- 1. Input Box row: Config Name
    local inputRow = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = Theme.SurfaceSecondary, Parent = configCard })
    Utility.AddCorner(inputRow, 6); Utility.AddStroke(inputRow, Theme.Border, 1); Utility.AddPadding(inputRow, 0, 0, 10, 10)
    Utility.Create("TextLabel", {
        Size = UDim2.new(0, 95, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = "Config Name:",
        TextColor3 = Theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = inputRow
    })
    local configInput = Utility.Create("TextBox", {
        Size = UDim2.new(1, -100, 0, 24),
        Position = UDim2.new(0, 95, 0.5, -12),
        BackgroundColor3 = Theme.Surface,
        Font = Enum.Font.Gotham,
        Text = "",
        PlaceholderText = "Type custom config name...",
        PlaceholderColor3 = Theme.TextSecondary,
        TextColor3 = Theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = inputRow
    })
    Utility.AddCorner(configInput, 4); Utility.AddStroke(configInput, Theme.Border, 1); Utility.AddPadding(configInput, 0, 0, 8, 8)

    -- 2. Dropdown for selecting available configs
    local selectProfile = ConfigSystem.CurrentProfile
    local configDropdown = Dropdown.new(configCard, {
        Name = "Select Config Profile",
        Options = ConfigSystem.Profiles,
        Default = ConfigSystem.CurrentProfile,
        Callback = function(val)
            selectProfile = val
            curBadge.Text = val
        end
    })

    local function refreshDropdown(newActive)
        ConfigSystem.Refresh()
        local active = newActive or ConfigSystem.CurrentProfile
        configDropdown:SetValues(ConfigSystem.Profiles, active)
        selectProfile = active
        curBadge.Text = active
    end

    -- 3. Action Buttons Grid: Save/Create, Load, Delete, Refresh
    local btnRow1 = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = configCard })
    Utility.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = btnRow1 })

    local saveCreateBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0.5, -4, 1, 0),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamMedium,
        Text = "Save / Create",
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = btnRow1
    })
    Utility.AddCorner(saveCreateBtn, 6); Utility.AddStroke(saveCreateBtn, Theme.Border, 1)

    local loadBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0.5, -4, 1, 0),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamMedium,
        Text = "Load Config",
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = btnRow1
    })
    Utility.AddCorner(loadBtn, 6); Utility.AddStroke(loadBtn, Theme.Border, 1)

    local btnRow2 = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = configCard })
    Utility.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, Padding = UDim.new(0, 8), Parent = btnRow2 })

    local deleteBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0.5, -4, 1, 0),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamMedium,
        Text = "Delete Config",
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = btnRow2
    })
    Utility.AddCorner(deleteBtn, 6); Utility.AddStroke(deleteBtn, Theme.Border, 1)

    local refreshBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0.5, -4, 1, 0),
        BackgroundColor3 = Theme.SurfaceSecondary,
        Font = Enum.Font.GothamMedium,
        Text = "Refresh List",
        TextColor3 = Theme.Text,
        TextSize = 12,
        AutoButtonColor = false,
        Parent = btnRow2
    })
    Utility.AddCorner(refreshBtn, 6); Utility.AddStroke(refreshBtn, Theme.Border, 1)

    -- Handlers
    saveCreateBtn.Activated:Connect(function()
        local name = configInput.Text:gsub("^%s*(.-)%s*$", "%1")
        if name == "" then
            name = selectProfile or "Default"
        end
        local _, saved = ConfigSystem.Save(name)
        refreshDropdown(saved)
        configInput.Text = ""
        Notification.Notify({ Title = "Config Saved", Content = "Saved profile '" .. saved .. "' to disk", Type = "Success" })
        if chloexNotif then chloexNotif("Saved config: " .. saved) end
    end)

    loadBtn.Activated:Connect(function()
        local target = selectProfile or ConfigSystem.CurrentProfile or "Default"
        ConfigSystem.Load(target)
        curBadge.Text = target
        Notification.Notify({ Title = "Config Loaded", Content = "Loaded profile '" .. target .. "'", Type = "Success" })
        if chloexNotif then chloexNotif("Loaded config: " .. target) end
    end)

    deleteBtn.Activated:Connect(function()
        local target = selectProfile or ConfigSystem.CurrentProfile or "Default"
        if target == "Default" then
            Notification.Notify({ Title = "Delete Blocked", Content = "Cannot delete 'Default' profile", Type = "Warning" })
            return
        end
        ConfigSystem.Delete(target)
        refreshDropdown("Default")
        Notification.Notify({ Title = "Config Deleted", Content = "Removed profile '" .. target .. "'", Type = "Success" })
        if chloexNotif then chloexNotif("Deleted config: " .. target) end
    end)

    refreshBtn.Activated:Connect(function()
        refreshDropdown()
        Notification.Notify({ Title = "Configs Refreshed", Content = "Refreshed list (" .. #ConfigSystem.Profiles .. " profiles)", Type = "Info" })
    end)

    local tabs, tabButtons = {}, {}

    local function openSettings()
        for _, tData in ipairs(tabButtons) do
            tData.Tab:SetVisible(false)
            if tData._setSelected then tData._setSelected(false) end
            AnimationEngine.Tween(tData.Accent, TWEEN_TAB, { Size = UDim2.new(0, 0, 0.65, 0) })
            AnimationEngine.Tween(tData.Button, TWEEN_TAB, { BackgroundTransparency = 0.88, TextColor3 = Theme.TextSecondary })
            if tData.Stroke then
                tData.Stroke.Transparency = 0.6
                tData.Stroke.Color = Theme.Border
            end
        end
        settingsPage.Visible = true
        settingsBtn.BackgroundColor3 = Theme.SurfaceElevated
        settingsBtn.TextColor3 = Theme.Text
        settingsBtn.Font = Enum.Font.GothamBold
        settingsBtn.FontFace = Fonts.Heading
    end
    settingsBtn.Activated:Connect(openSettings)

    local windowObj = {}
    function windowObj:AddTabSection(title)
        local sec = Utility.Create("Frame", {
            Name = "TabSection_" .. tostring(title),
            Size = UDim2.new(1, 0, 0, 24),
            BackgroundTransparency = 1,
            Parent = navScroll
        })
        local lbl = Utility.Create("TextLabel", {
            Size = UDim2.new(0, 0, 1, 0),
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundTransparency = 1,
            Font = Enum.Font.GothamBold,
            Text = string.upper(tostring(title)),
            TextColor3 = Color3.fromRGB(110, 110, 130),
            TextSize = 10,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = sec
        })
        task.defer(function()
            local w = math.max(lbl.TextBounds.X, 30)
            Utility.Create("Frame", {
                Size = UDim2.new(1, -w - 8, 0, 1),
                Position = UDim2.new(0, w + 8, 0.5, 0),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0,
                Parent = sec
            })
        end)
        return sec
    end

    function windowObj:AddTab(nameOrConfig, icon)
        local name, tabIcon
        if typeof(nameOrConfig) == "table" then
            name = nameOrConfig.Name or "Tab"
            tabIcon = nameOrConfig.Icon or "-"
        else
            name = tostring(nameOrConfig or "Tab")
            tabIcon = icon or "-"
        end
        local newTab = Tab.new(contentArea, name)
        table.insert(tabs, newTab)

        local btnText = (tabIcon and tostring(tabIcon) ~= "" and tostring(tabIcon) ~= "-")
            and ("    " .. tostring(tabIcon) .. "  " .. name)
            or ("    " .. name)

        local btn = Utility.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = Theme.SurfaceSecondary,
            BackgroundTransparency = 0.88,
            Font = Enum.Font.GothamBold,
            FontFace = Fonts.Heading,
            Text = btnText,
            TextColor3 = Theme.TextSecondary,
            TextSize = 12.5,
            TextTruncate = Enum.TextTruncate.AtEnd,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = navScroll
        })
        Utility.AddCorner(btn, 6); Utility.AddPadding(btn, 0, 0, 10, 10)
        local btnStroke = Utility.AddStroke(btn, Theme.Border, 1, 0.6)

        local accentBar = Utility.Create("Frame", {
            Size = UDim2.new(0, 0, 0.65, 0),
            Position = UDim2.new(0, 0, 0.175, 0),
            BackgroundColor3 = Theme.Accent,
            Visible = true,
            Parent = btn
        })
        Utility.AddCorner(accentBar, 2)

        local isSelectedRef = false
        btn.MouseEnter:Connect(function()
            if isSelectedRef then return end
            AnimationEngine.Tween(btn, TWEEN_QUICK, { BackgroundTransparency = 0.5, TextColor3 = Theme.Text })
            AnimationEngine.Tween(accentBar, TWEEN_QUICK, { Size = UDim2.new(0, 2, 0.65, 0) })
            btnStroke.Transparency = 0.2
            btnStroke.Color = Theme.BorderBright
        end)
        btn.MouseLeave:Connect(function()
            if isSelectedRef then return end
            AnimationEngine.Tween(btn, TWEEN_QUICK, { BackgroundTransparency = 0.88, TextColor3 = Theme.TextSecondary })
            AnimationEngine.Tween(accentBar, TWEEN_QUICK, { Size = UDim2.new(0, 0, 0.65, 0) })
            btnStroke.Transparency = 0.6
            btnStroke.Color = Theme.Border
        end)

        table.insert(tabButtons, { Button = btn, Stroke = btnStroke, Accent = accentBar, Tab = newTab, _setSelected = function(v) isSelectedRef = v end })

        local function select()
            settingsPage.Visible = false
            settingsBtn.TextColor3 = Theme.TextSecondary
            settingsBtn.BackgroundColor3 = Theme.SurfaceSecondary
            settingsBtn.Font = Enum.Font.GothamBold
            settingsBtn.FontFace = Fonts.Heading
            for _, tData in ipairs(tabButtons) do
                local isActive = (tData.Tab == newTab)
                if tData._setSelected then tData._setSelected(isActive) end
                tData.Tab:SetVisible(isActive)
                AnimationEngine.Tween(tData.Accent, TWEEN_TAB, {
                    Size = isActive and UDim2.new(0, 3, 0.65, 0) or UDim2.new(0, 0, 0.65, 0)
                })
                AnimationEngine.Tween(tData.Button, TWEEN_TAB, {
                    BackgroundColor3 = Theme.SurfaceSecondary,
                    BackgroundTransparency = isActive and 0 or 0.88,
                    TextColor3 = isActive and Theme.Text or Theme.TextSecondary
                })
                if tData.Stroke then
                    tData.Stroke.Transparency = isActive and 0 or 0.6
                    tData.Stroke.Color = isActive and Theme.BorderBright or Theme.Border
                end
            end
        end
        btn.Activated:Connect(select)

        if #tabs == 1 then select() end
        return newTab
    end

    function windowObj:Toggle(force) toggleWindow(force) end
    function windowObj:SetPinVisible(v)
        isPinned = v
        pinBtn.BackgroundColor3 = isPinned and Theme.SurfaceElevated or Theme.SurfaceSecondary
        pinBtn.TextColor3 = isPinned and Theme.Accent or Theme.TextSecondary
        pinBtnStroke.Color = isPinned and Theme.Accent or Theme.Border
        pinWidget.Visible = isPinned or (not mainFrame.Visible)
    end
    function windowObj:SetToggleKey(newKey)
        if typeof(newKey) == "string" then
            pcall(function() newKey = Enum.KeyCode[newKey] end)
        end
        if newKey and tostring(newKey):find("Enum.KeyCode") then
            setToggleKey(newKey)
        end
    end
    function windowObj:GetToggleKey()
        return currentToggleKey
    end
    function windowObj:SetPinPosition(newPos)
        if typeof(newPos) == "UDim2" then
            local clamped = clampPinPosition(newPos)
            pinWidget.Position = clamped
            ConfigData["_Liyhub_PinPos"] = {
                X = { clamped.X.Scale, clamped.X.Offset },
                Y = { clamped.Y.Scale, clamped.Y.Offset }
            }
            ConfigSystem.QueueSave()
        end
    end
    function windowObj:GetPinPosition()
        return pinWidget.Position
    end
    function windowObj:Minimize() toggleWindow(false) end
    function windowObj:SaveConfig() ConfigSystem.Save() end
    function windowObj:LoadConfig() ConfigSystem.Load() end
    function windowObj:SetDevicePreset(presetKey)
        applyDevicePreset(presetKey)
    end
    function windowObj:GetDevicePreset()
        return activePresetKey
    end
    function windowObj:GetDevicePresets()
        return DevicePresets
    end
    function windowObj:Destroy()
        destroyWindow()
    end
    function windowObj:Notify(config)
        Notification.Notify(config)
    end
    return windowObj
end

function NovaUI:Notify(config) Notification.Notify(config) end

local Liyhub = NovaUI

-- Live Demonstration: 2 Widgets Side-by-Side (Matte Obsidian, Zero AI Slop Glow)
local Window = Liyhub:CreateWindow({
    Title = "Liyhub | Egg Stealer Pro",
    Device = Utility.IsMobile() and "Android" or "PC"
})

local Tab = Window:AddTab("Automation")

-- Widget 1 (Left Column): Filter Telur
local Sec1 = Tab:AddSection({
    Name = "Filter Telur",
    Side = "Left"
})

-- 1. Curi Telur Otomatis (OFF)
Sec1:AddToggle({
    Name = "Curi Telur Otomatis",
    Desc = "Mencuri telur secara otomatis dan menyimpannya di plot kamu.",
    Default = false,
    Callback = function() end
})

-- 2. Anti Hit Guard (ON - White switch with dark knob)
Sec1:AddToggle({
    Name = "Anti Hit Guard",
    Default = true,
    Callback = function() end
})

-- 3. Drop Before Finish Line (OFF - Multi-line description)
Sec1:AddToggle({
    Name = "Drop Before Finish Line",
    Desc = "Instead of banking, every stolen egg is carried to a lane just outside your finish line and released there, so a friend or your main account can pick it up.",
    Default = false,
    Callback = function() end
})

-- 4. Bat Aura (ON)
Sec1:AddToggle({
    Name = "Bat Aura",
    Default = true,
    Callback = function() end
})

-- 5. Daftar Area (Dropdown)
Sec1:AddDropdown({
    Name = "Daftar Area",
    Desc = "Batas mutlak: cuma area ini. Kosong = semua area.",
    Options = { "Semua Area", "Area A (Red Plot)", "Area B (Blue Plot)", "Area C (Center)" },
    Default = "Semua Area",
    Callback = function() end
})

-- Widget 2 (Right Column): Combat and Security (Berdampingan di samping Widget 1)
local Sec2 = Tab:AddSection({
    Name = "Combat Guard",
    Side = "Right"
})

Sec2:AddToggle({
    Name = "Auto Parry Shield",
    Desc = "Reflect incoming stuns and hits automatically.",
    Default = true,
    Callback = function() end
})

local combatRow = Sec2:AddRow()
combatRow:AddToggle({
    Name = "Fast Dash",
    Desc = "Instant dash boost",
    Default = true,
    Callback = function() end
})
combatRow:AddKeybind({
    Name = "Parry Key",
    Desc = "Shortcut trigger",
    Default = Enum.KeyCode.F,
    Callback = function() end
})

Sec2:AddSlider({
    Name = "Parry Distance",
    Desc = "Maximum radius to detect projectile attacks.",
    Min = 5,
    Max = 50,
    Default = 25,
    Callback = function() end
})

Sec2:AddDropdown({
    Name = "Target Mode",
    Desc = "Prioritize targets based on threat level.",
    Options = { "Closest Player", "Egg Carrier", "Lowest Health" },
    Default = "Closest Player",
    Callback = function() end
})

Sec2:AddButton({
    Name = "Reset Character",
    Desc = "Instantly respawn character back at base plot.",
    Callback = function() end
})

Liyhub:Notify({
    Title = "Liyhub Pro UX",
    Content = "2 Widgets dual-column matte layout active.",
    Duration = 3
})

return Liyhub
