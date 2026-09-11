-- language: luau, file: LiyhubUI.bundle.luau
-- LiyhubUI / NovaUI Standalone Single-File Bundle
-- Loadstring entrypoint for Roblox / Executor compatibility

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ============================================================================
-- UTILS & TYPES
-- ============================================================================
local Utility = {}

function Utility.Create(className: string, properties: { [string]: any }, children: { Instance }?): Instance
    local instance = Instance.new(className)
    for prop, val in pairs(properties or {}) do
        (instance :: any)[prop] = val
    end
    if children then
        for _, child in ipairs(children) do
            child.Parent = instance
        end
    end
    return instance
end

function Utility.AddCorner(instance: Instance, radius: number?): UICorner
    return Utility.Create("UICorner", {
        CornerRadius = UDim.new(0, radius or 6),
        Parent = instance,
    }) :: UICorner
end

function Utility.AddStroke(instance: Instance, color: Color3?, thickness: number?, transparency: number?): UIStroke
    return Utility.Create("UIStroke", {
        Color = color or Color3.fromRGB(60, 60, 70),
        Thickness = thickness or 1,
        Transparency = transparency or 0,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = instance,
    }) :: UIStroke
end

function Utility.AddPadding(instance: Instance, top: number?, bottom: number?, left: number?, right: number?): UIPadding
    return Utility.Create("UIPadding", {
        PaddingTop = UDim.new(0, top or 8),
        PaddingBottom = UDim.new(0, bottom or 8),
        PaddingLeft = UDim.new(0, left or 8),
        PaddingRight = UDim.new(0, right or 8),
        Parent = instance,
    }) :: UIPadding
end

local Maid = {}
Maid.__index = Maid
function Maid.new()
    local self = setmetatable({}, Maid)
    self._tasks = {}
    return self
end
function Maid:GiveTask(task)
    if not task then return task end
    table.insert(self._tasks, task)
    return task
end
function Maid:DoCleaning()
    local tasks = self._tasks
    self._tasks = {}
    for _, task in ipairs(tasks) do
        if typeof(task) == "RBXScriptConnection" then
            task:Disconnect()
        elseif typeof(task) == "Instance" then
            task:Destroy()
        elseif typeof(task) == "function" then
            task()
        elseif typeof(task) == "table" and typeof(task.Destroy) == "function" then
            task:Destroy()
        end
    end
end
function Maid:Destroy() self:DoCleaning() end

-- ============================================================================
-- CONSTANTS & THEMES
-- ============================================================================
local Constants = {
    SizePresets = { Small = 0.85, Normal = 1.00, Large = 1.15 },
    DevicePresets = { PC = 1.00, Tablet = 1.05, Android = 1.10 },
    Themes = {
        Midnight = {
            Background = Color3.fromRGB(15, 18, 26),
            Surface = Color3.fromRGB(24, 28, 40),
            SurfaceSecondary = Color3.fromRGB(32, 38, 54),
            Border = Color3.fromRGB(44, 52, 74),
            Text = Color3.fromRGB(240, 243, 250),
            TextSecondary = Color3.fromRGB(140, 150, 175),
            Accent = Color3.fromRGB(110, 95, 245),
            Success = Color3.fromRGB(46, 204, 113),
            Warning = Color3.fromRGB(241, 196, 15),
            Error = Color3.fromRGB(231, 76, 60),
        },
        Graphite = {
            Background = Color3.fromRGB(20, 20, 22),
            Surface = Color3.fromRGB(30, 30, 34),
            SurfaceSecondary = Color3.fromRGB(42, 42, 48),
            Border = Color3.fromRGB(58, 58, 66),
            Text = Color3.fromRGB(245, 245, 245),
            TextSecondary = Color3.fromRGB(150, 150, 160),
            Accent = Color3.fromRGB(0, 168, 204),
            Success = Color3.fromRGB(40, 180, 110),
            Warning = Color3.fromRGB(230, 160, 40),
            Error = Color3.fromRGB(220, 60, 60),
        },
        Slate = {
            Background = Color3.fromRGB(22, 27, 34),
            Surface = Color3.fromRGB(33, 40, 50),
            SurfaceSecondary = Color3.fromRGB(45, 54, 68),
            Border = Color3.fromRGB(60, 72, 90),
            Text = Color3.fromRGB(235, 240, 248),
            TextSecondary = Color3.fromRGB(145, 158, 175),
            Accent = Color3.fromRGB(56, 139, 253),
            Success = Color3.fromRGB(57, 211, 83),
            Warning = Color3.fromRGB(210, 153, 34),
            Error = Color3.fromRGB(248, 81, 73),
        },
    }
}

local Theme = {
    _themes = Constants.Themes,
    _currentThemeName = "Midnight",
    _listeners = {}
}
function Theme.GetTheme() return Theme._themes[Theme._currentThemeName] or Theme._themes.Midnight end
function Theme.SetTheme(name)
    if not Theme._themes[name] then return end
    Theme._currentThemeName = name
    for _, cb in ipairs(Theme._listeners) do task.spawn(cb, Theme.GetTheme(), name) end
end
function Theme.OnThemeChanged(cb)
    table.insert(Theme._listeners, cb)
    return function()
        local idx = table.find(Theme._listeners, cb)
        if idx then table.remove(Theme._listeners, idx) end
    end
end
function Theme.GetCurrentThemeName() return Theme._currentThemeName end

local State = {
    Scale = 1.0,
    SizePreset = "Normal",
    DevicePreset = "PC",
    AnimationsEnabled = true,
    ReduceMotion = false,
    _listeners = {}
}
function State.SetScale(scale)
    State.Scale = math.clamp(scale, 0.75, 1.30)
    State._notify("Scale", State.Scale)
end
function State.SetSizePreset(preset)
    if Constants.SizePresets[preset] then State.SizePreset = preset; State.SetScale(Constants.SizePresets[preset]) end
end
function State.SetDevicePreset(preset)
    if Constants.DevicePresets[preset] then State.DevicePreset = preset; State.SetScale(Constants.DevicePresets[preset]) end
end
function State.Subscribe(key, cb)
    if not State._listeners[key] then State._listeners[key] = {} end
    table.insert(State._listeners[key], cb)
    return function()
        local idx = table.find(State._listeners[key], cb)
        if idx then table.remove(State._listeners[key], idx) end
    end
end
function State._notify(key, val)
    if State._listeners[key] then
        for _, cb in ipairs(State._listeners[key]) do task.spawn(cb, val) end
    end
end

local Animation = {}
function Animation.Tween(instance, duration, properties, style, direction)
    if not State.AnimationsEnabled or State.ReduceMotion then
        for p, v in pairs(properties) do (instance :: any)[p] = v end
        return nil
    end
    local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end
function Animation.Spring(instance, properties, speed)
    return Animation.Tween(instance, speed or 0.25, properties, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

-- ============================================================================
-- INPUT & DRAG
-- ============================================================================
local Input = {}
function Input.MakeDraggable(frame, handle)
    local dragHandle = handle or frame
    local dragging, dragInput, dragStart, startPos
    dragHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    dragHandle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
function Input.MakeResizable(frame, handle, minSize)
    local resizing, dragInput, dragStart, startSize
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; dragStart = input.Position; startSize = frame.AbsoluteSize
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and resizing then
            local delta = input.Position - dragStart
            local nw = math.max(minSize.X, startSize.X + delta.X)
            local nh = math.max(minSize.Y, startSize.Y + delta.Y)
            frame.Size = UDim2.fromOffset(nw, nh)
        end
    end)
end

-- ============================================================================
-- NOTIFICATION SYSTEM
-- ============================================================================
local Notification = {}
local notifContainer = nil
local function getNotifContainer()
    if notifContainer and notifContainer.Parent then return notifContainer end
    local parent = LocalPlayer:WaitForChild("PlayerGui")
    local sg = parent:FindFirstChild("NovaUINotifications") or Utility.Create("ScreenGui", { Name = "NovaUINotifications", ResetOnSpawn = false, DisplayOrder = 999, Parent = parent })
    notifContainer = Utility.Create("Frame", { Name = "Container", Size = UDim2.new(0, 300, 1, -40), Position = UDim2.new(1, -320, 0, 20), BackgroundTransparency = 1, Parent = sg }) :: Frame
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, VerticalAlignment = Enum.VerticalAlignment.Bottom, Padding = UDim.new(0, 10), Parent = notifContainer })
    return notifContainer
end
function Notification.Notify(config)
    local parent = getNotifContainer()
    local theme = Theme.GetTheme()
    local col = theme.Accent
    if config.Type == "Success" then col = theme.Success elseif config.Type == "Warning" then col = theme.Warning elseif config.Type == "Error" then col = theme.Error end

    local card = Utility.Create("Frame", { Name = "Notif", Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Surface, BackgroundTransparency = 0.1, ClipsDescendants = true, Parent = parent }) :: Frame
    Utility.AddCorner(card, 8); local stroke = Utility.AddStroke(card, theme.Border, 1); Utility.AddPadding(card, 12, 12, 14, 14)
    Utility.Create("Frame", { Size = UDim2.new(0, 4, 1, 0), Position = UDim2.new(0, -14, 0, 0), BackgroundColor3 = col, BorderSizePixel = 0, Parent = card })
    local tLbl = Utility.Create("TextLabel", { Size = UDim2.new(1, -10, 0, 18), Position = UDim2.new(0, 4, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = config.Title or "Notification", TextColor3 = theme.Text, TextSize = 14, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })
    local cLbl = Utility.Create("TextLabel", { Size = UDim2.new(1, -10, 0, 0), Position = UDim2.new(0, 4, 0, 20), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = config.Content or "", TextColor3 = theme.TextSecondary, TextSize = 12, TextWrapped = true, TextXAlignment = Enum.TextXAlignment.Left, Parent = card })

    Theme.OnThemeChanged(function(t) card.BackgroundColor3 = t.Surface; stroke.Color = t.Border; tLbl.TextColor3 = t.Text; cLbl.TextColor3 = t.TextSecondary end)
    card.Position = UDim2.new(1, 300, 0, 0)
    Animation.Tween(card, 0.3, { Position = UDim2.new(0, 0, 0, 0) })
    task.delay(config.Duration or 3, function()
        if card and card.Parent then
            local tw = Animation.Tween(card, 0.3, { Position = UDim2.new(1, 300, 0, 0) })
            if tw then tw.Completed:Connect(function() card:Destroy() end) else card:Destroy() end
        end
    end)
end

-- ============================================================================
-- COMPONENTS
-- ============================================================================
local Button = {}
function Button.new(parent, config)
    local maid = Maid.new()
    local theme = Theme.GetTheme()
    local frame = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, config.Description and 46 or 36), BackgroundColor3 = theme.SurfaceSecondary, Parent = parent }) :: Frame
    Utility.AddCorner(frame, 6); local stroke = Utility.AddStroke(frame, theme.Border, 1); Utility.AddPadding(frame, 6, 6, 10, 10)
    local tLbl = Utility.Create("TextLabel", { Size = UDim2.new(1, -60, 0, 18), Position = UDim2.new(0, 0, 0, config.Description and 2 or 4), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = config.Name or "Button", TextColor3 = theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
    local dLbl
    if config.Description then
        dLbl = Utility.Create("TextLabel", { Size = UDim2.new(1, -60, 0, 14), Position = UDim2.new(0, 0, 0, 20), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = config.Description, TextColor3 = theme.TextSecondary, TextSize = 11, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
    end
    local btn = Utility.Create("TextButton", { Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -60, 0.5, -12), BackgroundColor3 = theme.Accent, Font = Enum.Font.GothamBold, Text = "Click", TextColor3 = Color3.new(1, 1, 1), TextSize = 11, Parent = frame }) :: TextButton
    Utility.AddCorner(btn, 4)
    maid:GiveTask(btn.MouseButton1Click:Connect(function()
        Animation.Spring(btn, { Size = UDim2.new(0, 56, 0, 22), Position = UDim2.new(1, -58, 0.5, -11) }, 0.1)
        task.delay(0.1, function() Animation.Spring(btn, { Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -60, 0.5, -12) }, 0.1) end)
        if config.Callback then config.Callback() end
    end))
    maid:GiveTask(Theme.OnThemeChanged(function(t) frame.BackgroundColor3 = t.SurfaceSecondary; stroke.Color = t.Border; tLbl.TextColor3 = t.Text; if dLbl then dLbl.TextColor3 = t.TextSecondary end; btn.BackgroundColor3 = t.Accent end))
    return { Frame = frame, Destroy = function() maid:Destroy(); frame:Destroy() end }
end

local Toggle = {}
function Toggle.new(parent, config)
    local maid = Maid.new()
    local val = config.Default or false
    local theme = Theme.GetTheme()
    local frame = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 36), BackgroundColor3 = theme.SurfaceSecondary, Parent = parent }) :: Frame
    Utility.AddCorner(frame, 6); local stroke = Utility.AddStroke(frame, theme.Border, 1); Utility.AddPadding(frame, 6, 6, 10, 10)
    local tLbl = Utility.Create("TextLabel", { Size = UDim2.new(1, -50, 1, 0), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = config.Name or "Toggle", TextColor3 = theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
    local track = Utility.Create("TextButton", { Size = UDim2.new(0, 38, 0, 20), Position = UDim2.new(1, -38, 0.5, -10), BackgroundColor3 = val and theme.Accent or theme.Surface, AutoButtonColor = false, Text = "", Parent = frame }) :: TextButton
    Utility.AddCorner(track, 10)
    local knob = Utility.Create("Frame", { Size = UDim2.new(0, 14, 0, 14), Position = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track })
    Utility.AddCorner(knob, 7)

    local function setVal(nVal)
        val = nVal
        local t = Theme.GetTheme()
        Animation.Tween(track, 0.2, { BackgroundColor3 = val and t.Accent or t.Surface })
        Animation.Spring(knob, { Position = val and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.2)
        if config.Callback then config.Callback(val) end
    end
    maid:GiveTask(track.MouseButton1Click:Connect(function() setVal(not val) end))
    maid:GiveTask(Theme.OnThemeChanged(function(t) frame.BackgroundColor3 = t.SurfaceSecondary; stroke.Color = t.Border; tLbl.TextColor3 = t.Text; track.BackgroundColor3 = val and t.Accent or t.Surface end))
    return { Set = setVal, Get = function() return val end, Destroy = function() maid:Destroy(); frame:Destroy() end }
end

local Slider = {}
function Slider.new(parent, config)
    local maid = Maid.new()
    local sMin, sMax, sInc = config.Min or 0, config.Max or 100, config.Increment or 1
    local val = math.clamp(config.Default or sMin, sMin, sMax)
    local theme = Theme.GetTheme()
    local frame = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 48), BackgroundColor3 = theme.SurfaceSecondary, Parent = parent }) :: Frame
    Utility.AddCorner(frame, 6); local stroke = Utility.AddStroke(frame, theme.Border, 1); Utility.AddPadding(frame, 6, 6, 10, 10)
    local tLbl = Utility.Create("TextLabel", { Size = UDim2.new(1, -60, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = config.Name or "Slider", TextColor3 = theme.Text, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = frame })
    local vLbl = Utility.Create("TextLabel", { Size = UDim2.new(0, 50, 0, 18), Position = UDim2.new(1, -50, 0, 0), BackgroundTransparency = 1, Font = Enum.Font.Gotham, Text = tostring(val), TextColor3 = theme.TextSecondary, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Right, Parent = frame })
    local track = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 6), Position = UDim2.new(0, 0, 0, 26), BackgroundColor3 = theme.Surface, Parent = frame }); Utility.AddCorner(track, 3)
    local pct = (val - sMin) / (sMax - sMin)
    local fill = Utility.Create("Frame", { Size = UDim2.new(pct, 0, 1, 0), BackgroundColor3 = theme.Accent, Parent = track }); Utility.AddCorner(fill, 3)
    local knob = Utility.Create("Frame", { Size = UDim2.new(0, 12, 0, 12), Position = UDim2.new(pct, -6, 0.5, -6), BackgroundColor3 = Color3.new(1, 1, 1), Parent = track }); Utility.AddCorner(knob, 6)

    local function setVal(nVal)
        val = nVal
        local p = (val - sMin) / (sMax - sMin)
        fill.Size = UDim2.new(p, 0, 1, 0); knob.Position = UDim2.new(p, -6, 0.5, -6); vLbl.Text = tostring(val)
        if config.Callback then config.Callback(val) end
    end
    local dragging = false
    local function updatePos(inputPos)
        local rel = math.clamp((inputPos.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
        local step = math.floor((sMin + rel * (sMax - sMin)) / sInc + 0.5) * sInc
        setVal(math.clamp(step, sMin, sMax))
    end
    maid:GiveTask(track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = true; updatePos(input.Position) end
    end))
    maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end))
    maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updatePos(input.Position) end
    end))
    maid:GiveTask(Theme.OnThemeChanged(function(t) frame.BackgroundColor3 = t.SurfaceSecondary; stroke.Color = t.Border; tLbl.TextColor3 = t.Text; vLbl.TextColor3 = t.TextSecondary; track.BackgroundColor3 = t.Surface; fill.BackgroundColor3 = t.Accent end))
    return { Set = setVal, Destroy = function() maid:Destroy(); frame:Destroy() end }
end

-- ============================================================================
-- SECTION & TAB
-- ============================================================================
local Section = {}
Section.__index = Section
function Section.new(parent, name)
    local self = setmetatable({}, Section)
    self._maid = Maid.new()
    local theme = Theme.GetTheme()
    self.Frame = Utility.Create("Frame", { Name = "Section_" .. name, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundColor3 = theme.Surface, Parent = parent }) :: Frame
    Utility.AddCorner(self.Frame, 8); local stroke = Utility.AddStroke(self.Frame, theme.Border, 1); Utility.AddPadding(self.Frame, 12, 12, 12, 12)
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), Parent = self.Frame })
    Utility.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 18), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = string.upper(name), TextColor3 = theme.Text, TextSize = 12, TextXAlignment = Enum.TextXAlignment.Left, Parent = self.Frame })
    self._maid:GiveTask(Theme.OnThemeChanged(function(t) self.Frame.BackgroundColor3 = t.Surface; stroke.Color = t.Border end))
    return self
end
function Section:AddButton(config) return Button.new(self.Frame, config) end
function Section:AddToggle(config) return Toggle.new(self.Frame, config) end
function Section:AddSlider(config) return Slider.new(self.Frame, config) end

local Tab = {}
Tab.__index = Tab
function Tab.new(parent, name)
    local self = setmetatable({}, Tab)
    self._maid = Maid.new()
    local theme = Theme.GetTheme()
    self.Frame = Utility.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 4, ScrollBarImageColor3 = theme.Border, Visible = false, Parent = parent }) :: ScrollingFrame
    Utility.AddPadding(self.Frame, 16, 16, 16, 16)
    self.ColumnContainer = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = self.Frame })
    self.LeftColumn = Utility.Create("Frame", { Size = UDim2.new(0.49, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = self.ColumnContainer })
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = self.LeftColumn })
    self.RightColumn = Utility.Create("Frame", { Size = UDim2.new(0.49, 0, 0, 0), Position = UDim2.new(0.51, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1, Parent = self.ColumnContainer })
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 12), Parent = self.RightColumn })
    return self
end
function Tab:AddSection(name, col)
    return Section.new(col == "Right" and self.RightColumn or self.LeftColumn, name)
end
function Tab:SetVisible(v) self.Frame.Visible = v end

-- ============================================================================
-- MAIN WINDOW API
-- ============================================================================
local NovaUI = {}
function NovaUI:CreateWindow(config)
    local maid = Maid.new()
    if config.Theme then Theme.SetTheme(config.Theme) end
    local theme = Theme.GetTheme()

    local parent = LocalPlayer:WaitForChild("PlayerGui")
    local sg = Utility.Create("ScreenGui", { Name = "NovaUI_ScreenGui", ResetOnSpawn = false, DisplayOrder = 100, Parent = parent }) :: ScreenGui
    local uiScale = Utility.Create("UIScale", { Scale = State.Scale, Parent = sg }) :: UIScale
    maid:GiveTask(State.Subscribe("Scale", function(s) uiScale.Scale = s end))

    local initSize = config.Size or UDim2.fromOffset(720, 480)
    local mainFrame = Utility.Create("Frame", { Name = "MainFrame", Size = initSize, Position = UDim2.new(0.5, -initSize.X.Offset/2, 0.5, -initSize.Y.Offset/2), BackgroundColor3 = theme.Background, ClipsDescendants = true, Parent = sg }) :: Frame
    Utility.AddCorner(mainFrame, 10); local mStroke = Utility.AddStroke(mainFrame, theme.Border, 1)

    local topBar = Utility.Create("Frame", { Size = UDim2.new(1, 0, 0, 32), BackgroundTransparency = 1, Parent = mainFrame })
    local ctrl = Utility.Create("Frame", { Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(1, -60, 0, 0), BackgroundTransparency = 1, Parent = topBar })
    Utility.Create("UIListLayout", { FillDirection = Enum.FillDirection.Horizontal, HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center, Padding = UDim.new(0, 6), Parent = ctrl })
    local closeBtn = Utility.Create("TextButton", { Size = UDim2.new(0, 14, 0, 14), BackgroundColor3 = Color3.fromRGB(235, 87, 87), Text = "", Parent = ctrl }); Utility.AddCorner(closeBtn, 7)
    closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

    if config.Draggable ~= false then Input.MakeDraggable(mainFrame, topBar) end

    -- Sidebar & Content
    local sidebarFrame = Utility.Create("Frame", { Size = UDim2.new(0.24, 0, 1, 0), BackgroundColor3 = theme.Surface, BorderSizePixel = 0, Parent = mainFrame })
    Utility.AddPadding(sidebarFrame, 12, 12, 12, 12)
    local sTitle = Utility.Create("TextLabel", { Size = UDim2.new(1, 0, 0, 24), BackgroundTransparency = 1, Font = Enum.Font.GothamBold, Text = config.Title or "NOVAUI", TextColor3 = theme.Accent, TextSize = 18, TextXAlignment = Enum.TextXAlignment.Left, Parent = sidebarFrame })

    local navScroll = Utility.Create("ScrollingFrame", { Size = UDim2.new(1, 0, 1, -60), Position = UDim2.new(0, 0, 0, 36), BackgroundTransparency = 1, BorderSizePixel = 0, ScrollBarThickness = 2, Parent = sidebarFrame })
    Utility.Create("UIListLayout", { SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), Parent = navScroll })

    local contentArea = Utility.Create("Frame", { Size = UDim2.new(0.76, -1, 1, -32), Position = UDim2.new(0.24, 1, 0, 32), BackgroundColor3 = theme.Background, BorderSizePixel = 0, Parent = mainFrame })

    local tabs = {}
    local activeTab = nil

    local windowObj = {}
    function windowObj:AddTab(name, icon)
        local newTab = Tab.new(contentArea, name)
        table.insert(tabs, newTab)
        local btn = Utility.Create("TextButton", { Size = UDim2.new(1, 0, 0, 34), BackgroundColor3 = theme.SurfaceSecondary, BackgroundTransparency = 1, Font = Enum.Font.GothamMedium, Text = (icon or "◈") .. "  " .. name, TextColor3 = theme.TextSecondary, TextSize = 13, TextXAlignment = Enum.TextXAlignment.Left, Parent = navScroll })
        Utility.AddCorner(btn, 6); Utility.AddPadding(btn, 0, 0, 10, 10)

        local function select()
            for _, t in ipairs(tabs) do t:SetVisible(t == newTab) end
            activeTab = newTab
        end
        btn.MouseButton1Click:Connect(select)
        if #tabs == 1 then select() end
        return newTab
    end
    function windowObj:Destroy() sg:Destroy() end

    Animation.Spring(mainFrame, { Size = initSize }, 0.3)
    return windowObj
end

function NovaUI:Notify(config) Notification.Notify(config) end
function NovaUI:SetTheme(tName) Theme.SetTheme(tName) end
function NovaUI:SetScale(sc) State.SetScale(sc) end

return NovaUI
