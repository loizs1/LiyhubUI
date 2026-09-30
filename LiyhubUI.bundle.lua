-- ============================================================================
-- LiyhubUI Framework (Powered by SmoothFluent Engine)
-- Repository: https://github.com/loizs1/LiyhubUI
-- Core Engine: SmoothFluent (https://github.com/taithedev/SmoothFluent)
-- Features: Topbar Logo Image + Neverlose Profile + Top-Right Controls + Config Suite
-- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local g = (typeof(getgenv) == "function" and getgenv()) or _G

local Fluent = {
    Version = "0.5.0-Liyhub",
    Flags = {},
    Options = {},
    Themes = {},
    _windows = {},
    _connections = {},
    _destroyed = false,
}

-- Built-in Theme Suite
Fluent.Themes = {
    Liyhub = {
        Accent = Color3.fromRGB(0, 132, 255),
        Background = Color3.fromRGB(10, 11, 15),
        Surface = Color3.fromRGB(16, 18, 24),
        Surface2 = Color3.fromRGB(24, 27, 36),
        Border = Color3.fromRGB(255, 255, 255),
        Text = Color3.fromRGB(245, 248, 255),
        SubText = Color3.fromRGB(145, 155, 175),
        Hover = Color3.fromRGB(32, 36, 48),
        Success = Color3.fromRGB(0, 230, 118),
        Warning = Color3.fromRGB(250, 204, 21),
        Error = Color3.fromRGB(248, 113, 113),
        Info = Color3.fromRGB(0, 162, 255),
    },
    Dark = {
        Accent = Color3.fromRGB(139, 92, 246),
        Background = Color3.fromRGB(12, 12, 16),
        Surface = Color3.fromRGB(20, 20, 27),
        Surface2 = Color3.fromRGB(28, 28, 37),
        Border = Color3.fromRGB(54, 54, 68),
        Text = Color3.fromRGB(245, 245, 250),
        SubText = Color3.fromRGB(165, 165, 180),
        Hover = Color3.fromRGB(39, 39, 51),
        Success = Color3.fromRGB(74, 222, 128),
        Warning = Color3.fromRGB(250, 204, 21),
        Error = Color3.fromRGB(248, 113, 113),
        Info = Color3.fromRGB(96, 165, 250),
    },
    Cyber = {
        Accent = Color3.fromRGB(34, 211, 238),
        Background = Color3.fromRGB(5, 10, 14),
        Surface = Color3.fromRGB(10, 20, 26),
        Surface2 = Color3.fromRGB(15, 31, 39),
        Border = Color3.fromRGB(28, 74, 86),
        Text = Color3.fromRGB(235, 254, 255),
        SubText = Color3.fromRGB(137, 190, 198),
        Hover = Color3.fromRGB(21, 49, 59),
        Success = Color3.fromRGB(52, 211, 153),
        Warning = Color3.fromRGB(250, 204, 21),
        Error = Color3.fromRGB(248, 113, 113),
        Info = Color3.fromRGB(96, 165, 250),
    }
}
Fluent.CurrentTheme = Fluent.Themes.Liyhub
Fluent._errorHandler = function() end

local function safe(fn, ...)
    if not fn then return end
    local ok, res = xpcall(fn, debug.traceback, ...)
    if not ok then pcall(Fluent._errorHandler, res, res) end
    return res
end

local function tween(o, t, p)
    local x = TweenService:Create(o, TweenInfo.new(t or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p)
    x:Play()
    return x
end

local function corner(p, r)
    local x = Instance.new("UICorner")
    x.CornerRadius = UDim.new(0, r or 8)
    x.Parent = p
    return x
end

local function stroke(p, c, tr)
    local x = Instance.new("UIStroke")
    x.Color = c or Fluent.CurrentTheme.Border
    local trans = tr or 0
    if x.Color == Color3.fromRGB(255, 255, 255) and trans < 0.6 then
        trans = 0.85
    end
    x.Transparency = trans
    x.Parent = p
    return x
end

local function pad(p, n)
    local x = Instance.new("UIPadding")
    x.PaddingTop = UDim.new(0, n or 8)
    x.PaddingBottom = UDim.new(0, n or 8)
    x.PaddingLeft = UDim.new(0, n or 8)
    x.PaddingRight = UDim.new(0, n or 8)
    x.Parent = p
    return x
end

local function text(p, s, z, c)
    local x = Instance.new("TextLabel")
    x.BackgroundTransparency = 1
    x.Text = s or ""
    x.TextColor3 = c or Fluent.CurrentTheme.Text
    x.TextSize = z or 13
    x.Font = Enum.Font.GothamBold
    x.TextXAlignment = Enum.TextXAlignment.Left
    x.TextWrapped = true
    x.Parent = p
    return x
end

local function button(p, s, h)
    local x = Instance.new("TextButton")
    x.AutoButtonColor = false
    x.Text = s or ""
    x.TextColor3 = Fluent.CurrentTheme.Text
    x.TextSize = 12
    x.Font = Enum.Font.GothamBold
    x.BackgroundColor3 = Fluent.CurrentTheme.Surface2
    x.Size = UDim2.new(1, 0, 0, h or 34)
    x.Parent = p
    corner(x, 8)
    stroke(x, Fluent.CurrentTheme.Border, 0.25)
    x.MouseEnter:Connect(function() tween(x, 0.1, { BackgroundColor3 = Fluent.CurrentTheme.Hover }) end)
    x.MouseLeave:Connect(function() tween(x, 0.1, { BackgroundColor3 = Fluent.CurrentTheme.Surface2 }) end)
    return x
end

local function parentGui()
    local ok, h = pcall(function() return gethui and gethui() end)
    if ok and h then return h end
    local lp = Players.LocalPlayer
    if lp and lp:FindFirstChild("PlayerGui") then
        return lp.PlayerGui
    end
    local okCg, cg = pcall(function() return CoreGui end)
    return (okCg and cg) or game:GetService("StarterGui")
end

local function drag(handle, target)
    local active, start, pos
    handle.InputBegan:Connect(function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
            active = true
            start = i.Position
            pos = target.Position
            i.Changed:Connect(function()
                if i.UserInputState == Enum.UserInputState.End then
                    active = false
                end
            end)
        end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if active and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
            local d = i.Position - start
            target.Position = UDim2.new(pos.X.Scale, pos.X.Offset + d.X, pos.Y.Scale, pos.Y.Offset + d.Y)
        end
    end)
end

local function resolveLogoAsset()
    local logoAsset = "rbxasset://textures/liyhub_logo.png"
    if typeof(getcustomasset) == "function" then
        pcall(function()
            if typeof(isfile) == "function" and isfile("liyhub_logo.png") then
                logoAsset = getcustomasset("liyhub_logo.png")
            end
        end)
    end
    return logoAsset
end

local LucideIcons = {
    ["paw"] = "rbxassetid://10709810810",
    ["utensils"] = "rbxassetid://10709819149",
    ["egg"] = "rbxassetid://10709798085",
    ["sparkles"] = "rbxassetid://10709817727",
    ["sparkle"] = "rbxassetid://10709817727",
    ["eye"] = "rbxassetid://10709798433",
    ["settings"] = "rbxassetid://10734950309",
    ["setting"] = "rbxassetid://10734950309",
    ["sliders"] = "rbxassetid://10709817543",
    ["slider"] = "rbxassetid://10709817543",
    ["target"] = "rbxassetid://10709818868",
    ["crosshair"] = "rbxassetid://10709818868",
    ["sword"] = "rbxassetid://10709818765",
    ["swords"] = "rbxassetid://10709818765",
    ["shield"] = "rbxassetid://10709817444",
    ["user"] = "rbxassetid://10709818887",
    ["users"] = "rbxassetid://10709818887",
    ["zap"] = "rbxassetid://10709819177",
    ["bolt"] = "rbxassetid://10709819177",
    ["flame"] = "rbxassetid://10709798534",
    ["fire"] = "rbxassetid://10709798534",
    ["heart"] = "rbxassetid://10709798682",
    ["star"] = "rbxassetid://10709818249",
    ["folder"] = "rbxassetid://10709798620",
    ["bell"] = "rbxassetid://10709797442",
    ["check"] = "rbxassetid://10709790644",
    ["search"] = "rbxassetid://121018724060431",
    ["list"] = "rbxassetid://10709798837",
    ["compass"] = "rbxassetid://10709791864",
    ["map"] = "rbxassetid://10709798939",
    ["wrench"] = "rbxassetid://10709819119",
    ["hammer"] = "rbxassetid://10709798651",
    ["cpu"] = "rbxassetid://10709791963",
    ["activity"] = "rbxassetid://10709790074",
    ["gauge"] = "rbxassetid://10709798579",
    ["box"] = "rbxassetid://10709797532",
    ["package"] = "rbxassetid://10709810775",
    ["code"] = "rbxassetid://10709791757",
    ["terminal"] = "rbxassetid://10709818955",
    ["info"] = "rbxassetid://10709798792",
    ["help"] = "rbxassetid://10709798708",
    ["alert"] = "rbxassetid://10709790158",
    ["lock"] = "rbxassetid://10709798880",
    ["unlock"] = "rbxassetid://10709818834",
    ["key"] = "rbxassetid://10709798808",
    ["palette"] = "rbxassetid://10709810793",
    ["image"] = "rbxassetid://10709798754",
    ["file"] = "rbxassetid://10709798485",
    ["save"] = "rbxassetid://10709817349",
    ["download"] = "rbxassetid://10709798034",
    ["upload"] = "rbxassetid://10709818855",
    ["refresh"] = "rbxassetid://10709817313",
    ["rotate"] = "rbxassetid://10709817313",
    ["trash"] = "rbxassetid://10709818987",
    ["minus"] = "rbxassetid://10734896206",
    ["plus"] = "rbxassetid://10709810948",
    ["x"] = "rbxassetid://10747384394",
    ["close"] = "rbxassetid://10747384394",
    ["chevron-down"] = "rbxassetid://10709790948",
    ["chevron-up"] = "rbxassetid://10709791599",
    ["chevron-right"] = "rbxassetid://10709791523",
    ["chevron-left"] = "rbxassetid://10709791437",
    ["play"] = "rbxassetid://10709810875",
    ["pause"] = "rbxassetid://10709810834",
}

local function resolveIcon(raw)
    if not raw or raw == "" then return nil, nil end
    if type(raw) ~= "string" then return nil, nil end
    local lower = string.lower(raw)
    if LucideIcons[lower] then
        return "image", LucideIcons[lower]
    end
    if string.sub(raw, 1, 13) == "rbxassetid://" or string.sub(raw, 1, 11) == "rbxasset://" or string.find(raw, "://") then
        return "image", raw
    end
    if tonumber(raw) then
        return "image", "rbxassetid://" .. raw
    end
    return "text", raw
end

local function makeElement(parent, titleText, descText, h, iconOptional, orderOptional)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = Fluent.CurrentTheme.Surface2
    f.BackgroundTransparency = 0.45
    f.Size = UDim2.new(1, 0, 0, h or 48)
    f.LayoutOrder = orderOptional or (#parent:GetChildren() + 2)
    f.Parent = parent
    corner(f, 8)
    stroke(f, Fluent.CurrentTheme.Border, 0.3)

    local iconType, iconVal = resolveIcon(iconOptional)
    local xOffset = 12
    if iconType == "image" then
        local img = Instance.new("ImageLabel")
        img.Name = "ElementIcon"
        img.Size = UDim2.fromOffset(16, 16)
        img.Position = UDim2.new(0, 12, 0.5, -8)
        img.BackgroundTransparency = 1
        img.Image = iconVal
        img.ImageColor3 = Fluent.CurrentTheme.Accent
        img.ScaleType = Enum.ScaleType.Fit
        img.ZIndex = 4
        img.Parent = f
        xOffset = 36
    elseif iconType == "text" then
        local em = Instance.new("TextLabel")
        em.Name = "ElementIcon"
        em.Size = UDim2.fromOffset(18, 18)
        em.Position = UDim2.new(0, 11, 0.5, -9)
        em.BackgroundTransparency = 1
        em.Text = iconVal
        em.TextSize = 13
        em.TextColor3 = Fluent.CurrentTheme.Text
        em.Font = Enum.Font.GothamMedium
        em.ZIndex = 4
        em.Parent = f
        xOffset = 36
    end

    local title = text(f, titleText, 13, Fluent.CurrentTheme.Text)
    title.Position = UDim2.fromOffset(xOffset, descText and 8 or 0)
    title.Size = UDim2.new(1, -190 - (xOffset - 12), 0, descText and 18 or (h or 48))
    title.Font = Enum.Font.GothamBold

    if descText then
        local desc = text(f, descText, 11, Fluent.CurrentTheme.SubText)
        desc.Position = UDim2.fromOffset(xOffset, 26)
        desc.Size = UDim2.new(1, -190 - (xOffset - 12), 0, 16)
    end
    return f
end

local function addSection(tab, titleText, iconOptional)
    local sec = { Tab = tab, Elements = {} }
    local secTitle = titleText or ""
    local secIcon = iconOptional
    if type(titleText) == "table" then
        secTitle = titleText.Name or titleText.Title or ""
        secIcon = titleText.Icon or iconOptional
    end

    local holder = Instance.new("Frame")
    holder.BackgroundColor3 = Fluent.CurrentTheme.Surface
    holder.Size = UDim2.new(1, 0, 0, 45)
    holder.Parent = tab.Page
    corner(holder, 10)
    stroke(holder, Fluent.CurrentTheme.Border, 0.3)
    pad(holder, 8)

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 7)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = holder

    local headHolder = Instance.new("Frame")
    headHolder.Name = "SectionHeader"
    headHolder.BackgroundTransparency = 1
    headHolder.Size = UDim2.new(1, 0, 0, 22)
    headHolder.LayoutOrder = 1
    headHolder.Parent = holder

    local sIconType, sIconVal = resolveIcon(secIcon)
    local sHeadOffset = 0
    if sIconType == "image" then
        local sImg = Instance.new("ImageLabel")
        sImg.Name = "SectionIcon"
        sImg.Size = UDim2.fromOffset(14, 14)
        sImg.Position = UDim2.new(0, 2, 0.5, -7)
        sImg.BackgroundTransparency = 1
        sImg.Image = sIconVal
        sImg.ImageColor3 = Fluent.CurrentTheme.Accent
        sImg.ScaleType = Enum.ScaleType.Fit
        sImg.Parent = headHolder
        sHeadOffset = 22
    elseif sIconType == "text" then
        local sEm = Instance.new("TextLabel")
        sEm.Name = "SectionIcon"
        sEm.Size = UDim2.fromOffset(16, 16)
        sEm.Position = UDim2.new(0, 2, 0.5, -8)
        sEm.BackgroundTransparency = 1
        sEm.Text = sIconVal
        sEm.TextSize = 13
        sEm.TextColor3 = Fluent.CurrentTheme.Text
        sEm.Font = Enum.Font.GothamMedium
        sEm.Parent = headHolder
        sHeadOffset = 22
    end

    local head = text(headHolder, secTitle, 12, Fluent.CurrentTheme.SubText)
    head.Position = UDim2.fromOffset(sHeadOffset, 0)
    head.Size = UDim2.new(1, -sHeadOffset, 1, 0)
    head.Font = Enum.Font.GothamBold

    local function resize()
        holder.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 16)
    end
    list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)

    function sec:SetSearch(q)
        for _, e in ipairs(self.Elements) do
            if e.SetSearch then e:SetSearch(q) end
        end
    end

    function sec:AddButton(o)
        o = o or {}
        local f = makeElement(holder, o.Title or o.Name or "Button", o.Description or o.Desc, 48, o.Icon)
        local b = button(f, "Run", 30)
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Position = UDim2.new(1, -10, 0.5, 0)
        b.Size = UDim2.fromOffset(85, 30)
        b.MouseButton1Click:Connect(function() safe(o.Callback) end)
        local e = {
            Frame = f,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(o.Title or o.Name or ""), q, 1, true) ~= nil
            end,
        }
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddToggle(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Name or cfg.Title or "Toggle"
        end

        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, 48, cfg.Icon)
        local state = cfg.Default == true
        local b = button(f, state and "ON" or "OFF", 30)
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Position = UDim2.new(1, -10, 0.5, 0)
        b.Size = UDim2.fromOffset(62, 30)
        b.BackgroundColor3 = state and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface2
        Fluent.Flags[flag] = state

        local function set(v, fire)
            state = not not v
            Fluent.Flags[flag] = state
            b.Text = state and "ON" or "OFF"
            b.BackgroundColor3 = state and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface2
            if fire then safe(cfg.Callback, state) end
        end

        b.MouseButton1Click:Connect(function() set(not state, true) end)

        local e = {
            Frame = f,
            SetValue = function(_, v) set(v, true) end,
            GetValue = function() return state end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddSlider(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Name or cfg.Title or "Slider"
        end

        local hasDesc = (cfg.Description or cfg.Desc) ~= nil
        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, hasDesc and 66 or 54, cfg.Icon)

        local min, max = cfg.Min or 0, cfg.Max or 100
        local step = cfg.Step or 1
        local current = math.clamp(cfg.Default or min, min, max)
        Fluent.Flags[flag] = current

        -- Value Badge on top-right (WindUI Pill Style)
        local valBadge = Instance.new("Frame")
        valBadge.Name = "ValueBadge"
        valBadge.BackgroundColor3 = Fluent.CurrentTheme.Surface
        valBadge.BackgroundTransparency = 0.25
        valBadge.AnchorPoint = Vector2.new(1, 0)
        valBadge.Position = UDim2.new(1, -12, 0, hasDesc and 8 or 9)
        valBadge.Size = UDim2.fromOffset(54, 20)
        valBadge.Parent = f
        corner(valBadge, 6)
        stroke(valBadge, Fluent.CurrentTheme.Border, 0.35)

        local valLabel = text(valBadge, tostring(current) .. (cfg.Suffix or ""), 11, Fluent.CurrentTheme.Accent)
        valLabel.Size = UDim2.fromScale(1, 1)
        valLabel.TextXAlignment = Enum.TextXAlignment.Center
        valLabel.Font = Enum.Font.GothamBold

        -- Slider Track (WindUI Rail)
        local rail = Instance.new("Frame")
        rail.Name = "SliderTrack"
        rail.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
        rail.Position = UDim2.new(0, 14, 0, hasDesc and 48 or 36)
        rail.Size = UDim2.new(1, -28, 0, 5)
        rail.Parent = f
        corner(rail, 3)
        stroke(rail, Fluent.CurrentTheme.Border, 0.45)

        -- Blue Line Fill
        local fill = Instance.new("Frame")
        fill.Name = "SliderFill"
        fill.BackgroundColor3 = Fluent.CurrentTheme.Accent
        fill.Size = UDim2.fromScale(math.clamp((current - min) / math.max(1, max - min), 0, 1), 1)
        fill.Parent = rail
        corner(fill, 3)

        -- Circular Draggable Knob / Thumb
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.Size = UDim2.fromOffset(13, 13)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(1, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(250, 252, 255)
        knob.ZIndex = 5
        knob.Parent = fill
        corner(knob, 7)
        stroke(knob, Fluent.CurrentTheme.Accent, 0.1)

        local function set(v, fire)
            current = math.clamp(v, min, max)
            if step > 0 then
                current = math.floor((current - min) / step + 0.5) * step + min
                current = math.clamp(current, min, max)
            end
            current = cfg.Rounding and tonumber(string.format("%." .. cfg.Rounding .. "f", current)) or (step < 1 and tonumber(string.format("%.2f", current)) or math.floor(current + 0.5))
            Fluent.Flags[flag] = current
            valLabel.Text = tostring(current) .. (cfg.Suffix or "")
            local alpha = math.clamp((current - min) / math.max(1, max - min), 0, 1)
            fill.Size = UDim2.fromScale(alpha, 1)
            if fire then safe(cfg.Callback, current) end
        end

        local dragging = false
        local function updateDrag(input)
            local rel = (input.Position.X - rail.AbsolutePosition.X) / rail.AbsoluteSize.X
            local alpha = math.clamp(rel, 0, 1)
            set(min + (max - min) * alpha, true)
        end

        rail.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                tween(knob, 0.1, { Size = UDim2.fromOffset(16, 16) })
                updateDrag(i)
            end
        end)

        UserInputService.InputChanged:Connect(function(i)
            if dragging and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                updateDrag(i)
            end
        end)

        UserInputService.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                if dragging then
                    dragging = false
                    tween(knob, 0.1, { Size = UDim2.fromOffset(13, 13) })
                end
            end
        end)

        set(current, false)

        local e = {
            Frame = f,
            SetValue = function(_, v) set(v, true) end,
            GetValue = function() return current end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddDropdown(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Name or cfg.Title or "Dropdown"
        end

        local isMulti = cfg.Multi == true
        local hasDesc = (cfg.Description or cfg.Desc) ~= nil
        local headerH = hasDesc and 50 or 44

        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, headerH, cfg.Icon)
        f.ClipsDescendants = true

        local values = cfg.Values or cfg.Options or {}
        local current = cfg.Default or (isMulti and {} or values[1])
        local selected = {}

        if isMulti then
            if type(current) == "table" then
                for k, v in pairs(current) do
                    if type(k) == "number" then selected[v] = true else selected[k] = v == true end
                end
            elseif current then
                selected[current] = true
            end
            Fluent.Flags[flag] = selected
        else
            Fluent.Flags[flag] = current
        end

        -- Trigger Pill Button (WindUI Header Pill)
        local pill = Instance.new("TextButton")
        pill.Name = "TriggerPill"
        pill.AutoButtonColor = false
        pill.Text = ""
        pill.BackgroundColor3 = Fluent.CurrentTheme.Surface
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, -10, 0, headerH / 2)
        pill.Size = UDim2.fromOffset(165, 28)
        pill.Parent = f
        corner(pill, 7)
        stroke(pill, Fluent.CurrentTheme.Border, 0.35)

        local pillLabel = text(pill, "", 11, Fluent.CurrentTheme.Text)
        pillLabel.Position = UDim2.fromOffset(10, 0)
        pillLabel.Size = UDim2.new(1, -30, 1, 0)
        pillLabel.Font = Enum.Font.GothamBold
        pillLabel.TextTruncate = Enum.TextTruncate.AtEnd
        pillLabel.Active = false

        local chevron = Instance.new("ImageLabel")
        chevron.Name = "Chevron"
        chevron.Size = UDim2.fromOffset(12, 12)
        chevron.Position = UDim2.new(1, -18, 0.5, -6)
        chevron.BackgroundTransparency = 1
        chevron.Image = "rbxassetid://10709790948"
        chevron.ImageColor3 = Color3.fromRGB(190, 205, 225)
        chevron.Active = false
        chevron.Parent = pill

        local function getSummary()
            if isMulti then
                local list = {}
                for _, v in ipairs(values) do
                    if selected[v] then table.insert(list, tostring(v)) end
                end
                if #list == 0 then return "Select..." end
                if #list == 1 then return list[1] end
                if #list == 2 then return list[1] .. ", " .. list[2] end
                return tostring(#list) .. " Selected"
            else
                return tostring(current or "Select...")
            end
        end

        pillLabel.Text = getSummary()

        -- Expandable Options Container
        local optHeight = math.min(180, #values * 32 + 8)
        local optionsContainer = Instance.new("Frame")
        optionsContainer.Name = "OptionsContainer"
        optionsContainer.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        optionsContainer.Position = UDim2.new(0, 10, 0, headerH + 2)
        optionsContainer.Size = UDim2.new(1, -20, 0, optHeight)
        optionsContainer.Visible = false
        optionsContainer.Parent = f
        corner(optionsContainer, 7)
        stroke(optionsContainer, Fluent.CurrentTheme.Border, 0.4)

        local sc = Instance.new("ScrollingFrame")
        sc.BackgroundTransparency = 1
        sc.BorderSizePixel = 0
        sc.Size = UDim2.fromScale(1, 1)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.Y
        sc.ScrollBarThickness = 2
        sc.ScrollBarImageTransparency = 0.5
        sc.Parent = optionsContainer
        pad(sc, 5)

        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0, 3)
        lay.Parent = sc

        local optionRows = {}

        local function buildOptions()
            for _, r in ipairs(optionRows) do r:Destroy() end
            optionRows = {}

            for _, v in ipairs(values) do
                local valStr = tostring(v)
                local isChecked = isMulti and selected[v] == true or (not isMulti and current == v)

                local row = Instance.new("TextButton")
                row.Name = "Option_" .. valStr
                row.AutoButtonColor = false
                row.Text = ""
                row.BackgroundColor3 = isChecked and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface2
                row.BackgroundTransparency = isChecked and 0.75 or 0.6
                row.Size = UDim2.new(1, 0, 0, 28)
                row.Parent = sc
                corner(row, 6)

                local rowLabel = text(row, valStr, 11, isChecked and Fluent.CurrentTheme.Text or Fluent.CurrentTheme.SubText)
                rowLabel.Position = UDim2.fromOffset(10, 0)
                rowLabel.Size = UDim2.new(1, -40, 1, 0)
                rowLabel.Font = Enum.Font.GothamBold

                if isMulti then
                    -- Checkbox square
                    local checkSquare = Instance.new("Frame")
                    checkSquare.Name = "Checkbox"
                    checkSquare.Size = UDim2.fromOffset(16, 16)
                    checkSquare.Position = UDim2.new(1, -22, 0.5, -8)
                    checkSquare.BackgroundColor3 = isChecked and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface
                    checkSquare.BackgroundTransparency = isChecked and 0.2 or 0.5
                    checkSquare.Parent = row
                    corner(checkSquare, 4)
                    stroke(checkSquare, Fluent.CurrentTheme.Accent, isChecked and 0.2 or 0.6)

                    local checkIco = Instance.new("ImageLabel")
                    checkIco.Size = UDim2.fromOffset(11, 11)
                    checkIco.Position = UDim2.fromOffset(2, 2)
                    checkIco.BackgroundTransparency = 1
                    checkIco.Image = "rbxassetid://10709790644"
                    checkIco.ImageColor3 = Color3.fromRGB(255, 255, 255)
                    checkIco.Visible = isChecked
                    checkIco.Parent = checkSquare

                    row.MouseButton1Click:Connect(function()
                        selected[v] = not selected[v]
                        local chk = selected[v]
                        checkSquare.BackgroundColor3 = chk and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface
                        checkSquare.BackgroundTransparency = chk and 0.2 or 0.5
                        checkIco.Visible = chk
                        row.BackgroundColor3 = chk and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface2
                        row.BackgroundTransparency = chk and 0.75 or 0.6
                        rowLabel.TextColor3 = chk and Fluent.CurrentTheme.Text or Fluent.CurrentTheme.SubText

                        pillLabel.Text = getSummary()
                        Fluent.Flags[flag] = selected

                        local outList = {}
                        for _, item in ipairs(values) do
                            if selected[item] then table.insert(outList, item) end
                        end
                        safe(cfg.Callback, outList)
                    end)
                else
                    -- Single select checkmark icon
                    local checkIco = Instance.new("ImageLabel")
                    checkIco.Size = UDim2.fromOffset(13, 13)
                    checkIco.Position = UDim2.new(1, -22, 0.5, -6)
                    checkIco.BackgroundTransparency = 1
                    checkIco.Image = "rbxassetid://10709790644"
                    checkIco.ImageColor3 = Fluent.CurrentTheme.Accent
                    checkIco.Visible = isChecked
                    checkIco.Parent = row

                    row.MouseButton1Click:Connect(function()
                        current = v
                        Fluent.Flags[flag] = v
                        pillLabel.Text = getSummary()
                        safe(cfg.Callback, v)

                        -- Close after selection
                        optionsContainer.Visible = false
                        tween(chevron, 0.15, { Rotation = 0 })
                        f.Size = UDim2.new(1, 0, 0, headerH)
                        buildOptions()
                    end)
                end

                row.MouseEnter:Connect(function()
                    if not (isMulti and selected[v] or (not isMulti and current == v)) then
                        tween(row, 0.1, { BackgroundColor3 = Fluent.CurrentTheme.Hover, BackgroundTransparency = 0.3 })
                    end
                end)
                row.MouseLeave:Connect(function()
                    local chk = isMulti and selected[v] or (not isMulti and current == v)
                    tween(row, 0.1, {
                        BackgroundColor3 = chk and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface2,
                        BackgroundTransparency = chk and 0.75 or 0.6
                    })
                end)

                table.insert(optionRows, row)
            end
        end

        local function toggleOpen(forceState)
            if forceState ~= nil then
                isOpen = forceState
            else
                isOpen = not isOpen
            end
            if isOpen then
                buildOptions()
                optionsContainer.Visible = true
                tween(chevron, 0.15, { Rotation = 180 })
                f.Size = UDim2.new(1, 0, 0, headerH + optHeight + 8)
            else
                tween(chevron, 0.15, { Rotation = 0 })
                f.Size = UDim2.new(1, 0, 0, headerH)
                optionsContainer.Visible = false
            end
        end

        pill.MouseButton1Click:Connect(function()
            toggleOpen()
        end)

        local e = {
            Frame = f,
            Open = function() toggleOpen(true) end,
            Close = function() toggleOpen(false) end,
            Toggle = function() toggleOpen() end,
            SetValue = function(_, v)
                if isMulti then
                    selected = {}
                    if type(v) == "table" then
                        for _, item in ipairs(v) do selected[item] = true end
                    end
                    Fluent.Flags[flag] = selected
                else
                    current = v
                    Fluent.Flags[flag] = v
                end
                pillLabel.Text = getSummary()
                if isOpen then buildOptions() end
            end,
            SetValues = function(_, newVals)
                values = newVals or {}
                optHeight = math.min(180, #values * 32 + 8)
                optionsContainer.Size = UDim2.new(1, -20, 0, optHeight)
                if isOpen then
                    buildOptions()
                    f.Size = UDim2.new(1, 0, 0, headerH + optHeight + 8)
                end
            end,
            GetValue = function() return isMulti and selected or current end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddMultiDropdown(flagOrCfg, o)
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
        else
            cfg.Name = flagOrCfg
        end
        cfg.Multi = true
        return sec:AddDropdown(cfg)
    end

    function sec:AddTextbox(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Name or cfg.Title or "Textbox"
        end

        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, 48, cfg.Icon)
        local box = Instance.new("TextBox")
        box.Text = cfg.Default or ""
        box.PlaceholderText = cfg.Placeholder or "Enter value..."
        box.ClearTextOnFocus = false
        box.TextColor3 = Fluent.CurrentTheme.Text
        box.PlaceholderColor3 = Fluent.CurrentTheme.SubText
        box.TextSize = 11
        box.Font = Enum.Font.GothamBold
        box.BackgroundColor3 = Fluent.CurrentTheme.Surface2
        box.Position = UDim2.new(1, -10, 0.5, 0)
        box.AnchorPoint = Vector2.new(1, 0.5)
        box.Size = UDim2.fromOffset(180, 30)
        box.Parent = f
        corner(box, 7)
        stroke(box, Fluent.CurrentTheme.Border, 0.25)
        Fluent.Flags[flag] = box.Text

        box.FocusLost:Connect(function()
            Fluent.Flags[flag] = box.Text
            safe(cfg.Callback, box.Text)
        end)

        local e = {
            Frame = f,
            SetValue = function(_, v)
                box.Text = tostring(v)
                Fluent.Flags[flag] = box.Text
            end,
            GetValue = function() return box.Text end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        table.insert(sec.Elements, e)
        return e
    end
    sec.AddInput = sec.AddTextbox

    function sec:AddKeybind(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Name or cfg.Title or "Keybind"
        end

        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, 48, cfg.Icon)
        local defaultKey = cfg.Default or "RightControl"
        if typeof(defaultKey) == "EnumItem" then defaultKey = defaultKey.Name end
        local key = tostring(defaultKey)
        Fluent.Flags[flag] = Enum.KeyCode[key] or Enum.KeyCode.RightControl

        local b = button(f, "[ " .. key .. " ]", 30)
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Position = UDim2.new(1, -10, 0.5, 0)
        b.Size = UDim2.fromOffset(115, 30)
        b.Font = Enum.Font.GothamBold

        local listening = false
        local connection, listenerConn

        local function bind(k)
            if connection then connection:Disconnect() end
            if k and k ~= Enum.KeyCode.Unknown then
                connection = UserInputService.InputBegan:Connect(function(i, gProc)
                    if not gProc and i.KeyCode == k then
                        safe(cfg.Callback, k)
                    end
                end)
            end
        end
        bind(Enum.KeyCode[key] or Enum.KeyCode.RightControl)

        b.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            b.Text = "[ ... ]"
            b.TextColor3 = Fluent.CurrentTheme.Accent
            tween(b, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Hover })

            if listenerConn then listenerConn:Disconnect() end
            listenerConn = UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    if i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Backspace then
                        key = "None"
                        b.Text = "[ None ]"
                        b.TextColor3 = Fluent.CurrentTheme.SubText
                        bind(nil)
                        Fluent.Flags[flag] = nil
                    elseif i.KeyCode ~= Enum.KeyCode.Unknown then
                        key = i.KeyCode.Name
                        b.Text = "[ " .. key .. " ]"
                        b.TextColor3 = Fluent.CurrentTheme.Text
                        bind(i.KeyCode)
                        Fluent.Flags[flag] = i.KeyCode
                        safe(cfg.Callback, i.KeyCode)
                    end
                    listening = false
                    tween(b, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Surface2 })
                    if listenerConn then listenerConn:Disconnect() listenerConn = nil end
                end
            end)
        end)

        local e = {
            Frame = f,
            SetValue = function(_, v)
                local name = typeof(v) == "EnumItem" and v.Name or tostring(v)
                key = name
                b.Text = "[ " .. name .. " ]"
                bind(Enum.KeyCode[name])
                Fluent.Flags[flag] = Enum.KeyCode[name]
            end,
            GetValue = function() return key end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddColorPicker(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Name or cfg.Title or "ColorPicker"
        end

        local hasDesc = (cfg.Description or cfg.Desc) ~= nil
        local headerH = hasDesc and 50 or 44
        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, headerH, cfg.Icon)
        f.ClipsDescendants = true

        local col = cfg.Default or Color3.fromRGB(0, 162, 255)
        Fluent.Flags[flag] = col

        -- Right Pill with Color Box + Hex
        local pill = Instance.new("TextButton")
        pill.Name = "ColorPill"
        pill.AutoButtonColor = false
        pill.Text = ""
        pill.BackgroundColor3 = Fluent.CurrentTheme.Surface
        pill.AnchorPoint = Vector2.new(1, 0.5)
        pill.Position = UDim2.new(1, -10, 0, headerH / 2)
        pill.Size = UDim2.fromOffset(130, 28)
        pill.Parent = f
        corner(pill, 7)
        stroke(pill, Fluent.CurrentTheme.Border, 0.35)

        local previewBox = Instance.new("Frame")
        previewBox.Name = "Preview"
        previewBox.Size = UDim2.fromOffset(16, 16)
        previewBox.Position = UDim2.new(0, 8, 0.5, -8)
        previewBox.BackgroundColor3 = col
        previewBox.Parent = pill
        corner(previewBox, 4)
        stroke(previewBox, Fluent.CurrentTheme.Border, 0.3)

        local hexLabel = text(pill, string.format("#%02X%02X%02X", math.floor(col.R * 255), math.floor(col.G * 255), math.floor(col.B * 255)), 11, Fluent.CurrentTheme.Text)
        hexLabel.Position = UDim2.fromOffset(30, 0)
        hexLabel.Size = UDim2.new(1, -50, 1, 0)
        hexLabel.Font = Enum.Font.GothamBold
        hexLabel.Active = false

        local chevron = Instance.new("ImageLabel")
        chevron.Name = "Chevron"
        chevron.Size = UDim2.fromOffset(12, 12)
        chevron.Position = UDim2.new(1, -18, 0.5, -6)
        chevron.BackgroundTransparency = 1
        chevron.Image = "rbxassetid://10709790948"
        chevron.ImageColor3 = Color3.fromRGB(190, 205, 225)
        chevron.Active = false
        chevron.Parent = pill

        -- Inline Accordion Palette Container
        local paletteH = 115
        local palette = Instance.new("Frame")
        palette.Name = "ColorPalette"
        palette.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        palette.Position = UDim2.new(0, 10, 0, headerH + 2)
        palette.Size = UDim2.new(1, -20, 0, paletteH)
        palette.Visible = false
        palette.Parent = f
        corner(palette, 7)
        stroke(palette, Fluent.CurrentTheme.Border, 0.4)
        pad(palette, 8)

        local function updateColor(newCol, fire)
            col = newCol
            Fluent.Flags[flag] = col
            previewBox.BackgroundColor3 = col
            hexLabel.Text = string.format("#%02X%02X%02X", math.floor(col.R * 255), math.floor(col.G * 255), math.floor(col.B * 255))
            if fire then safe(cfg.Callback, col) end
        end

        -- RGB Quick Sliders
        local channels = {
            { Name = "R", Color = Color3.fromRGB(255, 80, 80), Get = function() return math.floor(col.R * 255) end, Set = function(v) return Color3.fromRGB(v, math.floor(col.G * 255), math.floor(col.B * 255)) end },
            { Name = "G", Color = Color3.fromRGB(80, 255, 120), Get = function() return math.floor(col.G * 255) end, Set = function(v) return Color3.fromRGB(math.floor(col.R * 255), v, math.floor(col.B * 255)) end },
            { Name = "B", Color = Color3.fromRGB(80, 160, 255), Get = function() return math.floor(col.B * 255) end, Set = function(v) return Color3.fromRGB(math.floor(col.R * 255), math.floor(col.G * 255), v) end },
        }

        local sliderTracks = {}
        for idx, ch in ipairs(channels) do
            local chRow = Instance.new("Frame")
            chRow.BackgroundTransparency = 1
            chRow.Size = UDim2.new(1, 0, 0, 18)
            chRow.Position = UDim2.fromOffset(0, (idx - 1) * 22)
            chRow.Parent = palette

            local chName = text(chRow, ch.Name, 10, ch.Color)
            chName.Position = UDim2.fromOffset(2, 0)
            chName.Size = UDim2.fromOffset(14, 18)
            chName.Font = Enum.Font.GothamBold

            local chTrack = Instance.new("Frame")
            chTrack.BackgroundColor3 = Color3.fromRGB(28, 34, 48)
            chTrack.Position = UDim2.new(0, 22, 0.5, -3)
            chTrack.Size = UDim2.new(1, -64, 0, 6)
            chTrack.Parent = chRow
            corner(chTrack, 3)

            local chFill = Instance.new("Frame")
            chFill.BackgroundColor3 = ch.Color
            chFill.Size = UDim2.fromScale(ch.Get() / 255, 1)
            chFill.Parent = chTrack
            corner(chFill, 3)

            local chVal = text(chRow, tostring(ch.Get()), 10, Fluent.CurrentTheme.Text)
            chVal.Position = UDim2.new(1, -34, 0, 0)
            chVal.Size = UDim2.fromOffset(34, 18)
            chVal.TextXAlignment = Enum.TextXAlignment.Right

            local chDrag = false
            chTrack.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    chDrag = true
                    local alpha = math.clamp((i.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1)
                    local v = math.floor(alpha * 255)
                    chFill.Size = UDim2.fromScale(alpha, 1)
                    chVal.Text = tostring(v)
                    updateColor(ch.Set(v), true)
                end
            end)
            UserInputService.InputChanged:Connect(function(i)
                if chDrag and (i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch) then
                    local alpha = math.clamp((i.Position.X - chTrack.AbsolutePosition.X) / chTrack.AbsoluteSize.X, 0, 1)
                    local v = math.floor(alpha * 255)
                    chFill.Size = UDim2.fromScale(alpha, 1)
                    chVal.Text = tostring(v)
                    updateColor(ch.Set(v), true)
                end
            end)
            UserInputService.InputEnded:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    chDrag = false
                end
            end)
            sliderTracks[ch.Name] = { Fill = chFill, Val = chVal, Channel = ch }
        end

        -- Preset Color Palette Swatches (WindUI Swatches)
        local presetsFrame = Instance.new("Frame")
        presetsFrame.BackgroundTransparency = 1
        presetsFrame.Position = UDim2.new(0, 0, 0, 72)
        presetsFrame.Size = UDim2.new(1, 0, 0, 24)
        presetsFrame.Parent = palette

        local presetCols = {
            Color3.fromRGB(0, 162, 255),
            Color3.fromRGB(0, 255, 170),
            Color3.fromRGB(255, 75, 75),
            Color3.fromRGB(180, 80, 255),
            Color3.fromRGB(255, 200, 50),
            Color3.fromRGB(255, 120, 50),
            Color3.fromRGB(255, 255, 255),
        }

        local pLayout = Instance.new("UIListLayout")
        pLayout.FillDirection = Enum.FillDirection.Horizontal
        pLayout.Padding = UDim.new(0, 7)
        pLayout.Parent = presetsFrame

        for _, pc in ipairs(presetCols) do
            local dot = Instance.new("TextButton")
            dot.Text = ""
            dot.AutoButtonColor = false
            dot.BackgroundColor3 = pc
            dot.Size = UDim2.fromOffset(22, 22)
            dot.Parent = presetsFrame
            corner(dot, 5)
            stroke(dot, Fluent.CurrentTheme.Border, 0.4)
            dot.MouseButton1Click:Connect(function()
                updateColor(pc, true)
                for _, st in pairs(sliderTracks) do
                    local a = math.clamp(st.Channel.Get() / 255, 0, 1)
                    st.Fill.Size = UDim2.fromScale(a, 1)
                    st.Val.Text = tostring(st.Channel.Get())
                end
            end)
        end

        local isOpen = false
        pill.MouseButton1Click:Connect(function()
            isOpen = not isOpen
            if isOpen then
                palette.Visible = true
                tween(chevron, 0.15, { Rotation = 180 })
                f.Size = UDim2.new(1, 0, 0, headerH + paletteH + 10)
            else
                tween(chevron, 0.15, { Rotation = 0 })
                f.Size = UDim2.new(1, 0, 0, headerH)
                palette.Visible = false
            end
        end)

        local e = {
            Frame = f,
            SetValue = function(_, v)
                updateColor(v, true)
                for _, st in pairs(sliderTracks) do
                    local a = math.clamp(st.Channel.Get() / 255, 0, 1)
                    st.Fill.Size = UDim2.fromScale(a, 1)
                    st.Val.Text = tostring(st.Channel.Get())
                end
            end,
            GetValue = function() return col end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddParagraph(o)
        o = o or {}
        local f = makeElement(holder, o.Title or "", nil, math.max(56, TextService:GetTextSize(o.Content or "", 11, Enum.Font.Gotham, Vector2.new(500, 1000)).Y + 43))
        local c = text(f, o.Content or "", 11, Fluent.CurrentTheme.SubText)
        c.Position = UDim2.fromOffset(12, 30)
        c.Size = UDim2.new(1, -24, 0, f.Size.Y.Offset - 35)
        local e = {
            Frame = f,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower((o.Title or "") .. " " .. (o.Content or "")), q, 1, true) ~= nil
            end,
        }
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddLabel(o)
        local title = type(o) == "string" and o or (o and (o.Text or o.Title) or "")
        local f = makeElement(holder, title, nil, 36)
        local e = {
            Frame = f,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(title), q, 1, true) ~= nil
            end,
        }
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddRow()
        local rowFrame = Instance.new("Frame")
        rowFrame.BackgroundTransparency = 1
        rowFrame.Size = UDim2.new(1, 0, 0, 44)
        rowFrame.LayoutOrder = #holder:GetChildren() + 2
        rowFrame.Parent = holder

        local rowLayout = Instance.new("UIListLayout")
        rowLayout.FillDirection = Enum.FillDirection.Horizontal
        rowLayout.Padding = UDim.new(0, 8)
        rowLayout.Parent = rowFrame

        local rowObj = { Frame = rowFrame }
        function rowObj:AddButton(btnCfg)
            btnCfg = btnCfg or {}
            local btn = button(rowFrame, btnCfg.Name or btnCfg.Title or "Button", 40)
            btn.Size = UDim2.new(0.5, -4, 0, 40)
            btn.MouseButton1Click:Connect(function() safe(btnCfg.Callback) end)
            return btn
        end

        function rowObj:AddToggle(toggleCfg)
            toggleCfg = toggleCfg or {}
            local card = Instance.new("Frame")
            card.BackgroundColor3 = Fluent.CurrentTheme.Surface2
            card.BackgroundTransparency = 0.45
            card.Size = UDim2.new(0.5, -4, 0, 40)
            card.Parent = rowFrame
            corner(card, 8)
            stroke(card, Fluent.CurrentTheme.Border, 0.3)

            local label = text(card, toggleCfg.Name or toggleCfg.Title or "Toggle", 12, Fluent.CurrentTheme.Text)
            label.Position = UDim2.fromOffset(10, 0)
            label.Size = UDim2.new(1, -62, 1, 0)
            label.Font = Enum.Font.GothamBold

            local state = toggleCfg.Default == true
            local btn = button(card, state and "ON" or "OFF", 26)
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.Position = UDim2.new(1, -6, 0.5, 0)
            btn.Size = UDim2.fromOffset(48, 26)
            btn.BackgroundColor3 = state and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface
            btn.Font = Enum.Font.GothamBold

            btn.MouseButton1Click:Connect(function()
                state = not state
                btn.Text = state and "ON" or "OFF"
                btn.BackgroundColor3 = state and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface
                safe(toggleCfg.Callback, state)
            end)
            return card
        end

        function rowObj:AddKeybind(keyCfg)
            keyCfg = keyCfg or {}
            local card = Instance.new("Frame")
            card.BackgroundColor3 = Fluent.CurrentTheme.Surface2
            card.BackgroundTransparency = 0.45
            card.Size = UDim2.new(0.5, -4, 0, 40)
            card.Parent = rowFrame
            corner(card, 8)
            stroke(card, Fluent.CurrentTheme.Border, 0.3)

            local label = text(card, keyCfg.Name or keyCfg.Title or "Keybind", 12, Fluent.CurrentTheme.Text)
            label.Position = UDim2.fromOffset(10, 0)
            label.Size = UDim2.new(1, -74, 1, 0)
            label.Font = Enum.Font.GothamBold

            local defKey = keyCfg.Default or "F"
            if typeof(defKey) == "EnumItem" then defKey = defKey.Name end
            local btn = button(card, "[ " .. tostring(defKey) .. " ]", 26)
            btn.AnchorPoint = Vector2.new(1, 0.5)
            btn.Position = UDim2.new(1, -6, 0.5, 0)
            btn.Size = UDim2.fromOffset(64, 26)
            btn.Font = Enum.Font.GothamBold
            return card
        end

        return rowObj
    end

    resize()
    return sec
end

-- Window Constructor (SmoothFluent Engine + Liyhub Polish)
function Fluent:CreateWindow(o)
    o = o or {}

    -- Strict Anti-Duplication: Wipe any previous Liyhub GUIs
    local function cleanGuis(container)
        if not container then return end
        pcall(function()
            for _, child in ipairs(container:GetChildren()) do
                if child:IsA("ScreenGui") and (string.find(child.Name, "Liyhub") or string.find(child.Name, "LiyhubFluent")) then
                    child:Destroy()
                end
            end
        end)
    end

    pcall(function()
        if typeof(gethui) == "function" then cleanGuis(gethui()) end
        if CoreGui then cleanGuis(CoreGui) end
        if LocalPlayer and LocalPlayer:FindFirstChild("PlayerGui") then cleanGuis(LocalPlayer.PlayerGui) end
    end)

    if g._LiyhubCurrentWindow and typeof(g._LiyhubCurrentWindow.Destroy) == "function" then
        pcall(function() g._LiyhubCurrentWindow:Destroy() end)
    end

    local isTouch = UserInputService.TouchEnabled
    local isKeyboard = UserInputService.KeyboardEnabled
    local isMouse = UserInputService.MouseEnabled
    local isMobile = isTouch and (not isKeyboard or not isMouse)

    local cam = workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)

    -- Auto Size Standard from Old UI (PC: 680x490 / 720x500; Mobile: 580x430 clamped to viewport)
    local defaultSize
    local defaultTabWidth
    if isMobile or vp.X < 850 then
        local targetW = math.clamp(math.floor(vp.X * 0.88), 460, 580)
        local targetH = math.clamp(math.floor(vp.Y * 0.85), 330, 430)
        defaultSize = UDim2.fromOffset(targetW, targetH)
        defaultTabWidth = 145
    else
        defaultSize = UDim2.fromOffset(680, 490)
        defaultTabWidth = 180
    end

    local size = o.Size or defaultSize
    if isMobile and cam then
        local maxW = math.max(vp.X - 24, 400)
        local maxH = math.max(vp.Y - 24, 300)
        if size.X.Offset > maxW or size.Y.Offset > maxH then
            size = UDim2.fromOffset(math.min(size.X.Offset, maxW), math.min(size.Y.Offset, maxH))
        end
    end

    local w = {
        Title = o.Title or "Liyhub",
        SubTitle = o.Author or o.SubTitle or "SmoothFluent Edition",
        Size = size,
        Tabs = {},
        _tabs = {},
        _visible = true,
        TabWidth = o.TabWidth or defaultTabWidth,
    }
    table.insert(self._windows, w)
    g._LiyhubCurrentWindow = w

    local gui = Instance.new("ScreenGui")
    gui.Name = "LiyhubFluent_Main"
    gui.ResetOnSpawn = false
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = parentGui()
    w.Gui = gui

    local main = Instance.new("Frame")
    main.Name = "Window"
    main.Size = size
    main.Position = o.Position or UDim2.new(0.5, -size.X.Offset / 2, 0.5, -size.Y.Offset / 2)
    main.BackgroundColor3 = self.CurrentTheme.Background
    main.BackgroundTransparency = 0.04
    main.ClipsDescendants = true
    main.ZIndex = 1
    main.Parent = gui
    corner(main, 16)
    stroke(main, Color3.fromRGB(255, 255, 255), 0.72)
    w.Main = main

    local gradient = Instance.new("UIGradient")
    gradient.Rotation = 35
    gradient.Color = ColorSequence.new(self.CurrentTheme.Background, self.CurrentTheme.Surface)
    gradient.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.1),
        NumberSequenceKeypoint.new(1, 0.32),
    })
    gradient.Parent = main

    -- Topbar Separator: Clean White with Soft Edge Fade
    local topLine = Instance.new("Frame")
    topLine.Name = "TopLine"
    topLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    topLine.BorderSizePixel = 0
    topLine.Position = UDim2.fromOffset(18, 58)
    topLine.Size = UDim2.new(1, -36, 0, 1)
    topLine.ZIndex = 4
    topLine.Parent = main

    local lineGrad = Instance.new("UIGradient")
    lineGrad.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
    lineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.5),
        NumberSequenceKeypoint.new(0.2, 0.1),
        NumberSequenceKeypoint.new(0.8, 0.1),
        NumberSequenceKeypoint.new(1, 0.5),
    })
    lineGrad.Parent = topLine

    -- WindUI Interactive Corner Resize Grip (Bottom-Right)
    local resizeGrip = Instance.new("TextButton")
    resizeGrip.Name = "ResizeGrip"
    resizeGrip.Text = ""
    resizeGrip.AutoButtonColor = false
    resizeGrip.BackgroundTransparency = 1
    resizeGrip.Size = UDim2.fromOffset(24, 24)
    resizeGrip.AnchorPoint = Vector2.new(1, 1)
    resizeGrip.Position = UDim2.new(1, -2, 1, -2)
    resizeGrip.ZIndex = 30
    resizeGrip.Parent = main

    local gripIcon = Instance.new("ImageLabel")
    gripIcon.Name = "GripIcon"
    gripIcon.Size = UDim2.fromOffset(13, 13)
    gripIcon.AnchorPoint = Vector2.new(1, 1)
    gripIcon.Position = UDim2.new(1, -4, 1, -4)
    gripIcon.BackgroundTransparency = 1
    gripIcon.Image = "rbxassetid://10709791523" -- Diagonal chevron pointing corner
    gripIcon.Rotation = 45
    gripIcon.ImageColor3 = Color3.fromRGB(140, 155, 180)
    gripIcon.ImageTransparency = 0.45
    gripIcon.ZIndex = 31
    gripIcon.Active = false
    gripIcon.Parent = resizeGrip

    local isResizing = false
    local resizeStartMouse = Vector2.zero
    local resizeStartSize = Vector2.zero

    resizeGrip.MouseEnter:Connect(function()
        tween(gripIcon, 0.15, { ImageColor3 = Color3.fromRGB(0, 132, 255), ImageTransparency = 0 })
    end)
    resizeGrip.MouseLeave:Connect(function()
        if not isResizing then
            tween(gripIcon, 0.15, { ImageColor3 = Color3.fromRGB(140, 155, 180), ImageTransparency = 0.45 })
        end
    end)

    resizeGrip.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isResizing = true
            resizeStartMouse = Vector2.new(input.Position.X, input.Position.Y)
            resizeStartSize = Vector2.new(main.AbsoluteSize.X, main.AbsoluteSize.Y)
            tween(gripIcon, 0.1, { ImageColor3 = Color3.fromRGB(0, 132, 255), ImageTransparency = 0 })

            local moveConn, endConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if not isResizing then return end
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    local delta = Vector2.new(moveInput.Position.X, moveInput.Position.Y) - resizeStartMouse
                    local curCam = workspace.CurrentCamera
                    local curVp = (curCam and curCam.ViewportSize) or Vector2.new(1920, 1080)
                    local minW = 450
                    local minH = 320
                    local maxW = math.max(curVp.X - 20, 600)
                    local maxH = math.max(curVp.Y - 20, 400)
                    local newW = math.clamp(math.floor(resizeStartSize.X + delta.X), minW, maxW)
                    local newH = math.clamp(math.floor(resizeStartSize.Y + delta.Y), minH, maxH)
                    main.Size = UDim2.fromOffset(newW, newH)
                    w.Size = main.Size
                end
            end)

            endConn = UserInputService.InputEnded:Connect(function(endInput)
                if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                    isResizing = false
                    if moveConn then moveConn:Disconnect() end
                    if endConn then endConn:Disconnect() end
                    tween(gripIcon, 0.2, { ImageColor3 = Color3.fromRGB(140, 155, 180), ImageTransparency = 0.45 })
                end
            end)
        end
    end)

    -- Dynamic Screen Viewport Adaptor
    if cam then
        cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
            if not main or not main.Parent then return end
            local newVp = cam.ViewportSize
            if isMobile and (main.AbsoluteSize.X > newVp.X - 20 or main.AbsoluteSize.Y > newVp.Y - 20) then
                local nw = math.clamp(main.AbsoluteSize.X, 420, math.max(newVp.X - 24, 420))
                local nh = math.clamp(main.AbsoluteSize.Y, 300, math.max(newVp.Y - 24, 300))
                main.Size = UDim2.fromOffset(nw, nh)
                w.Size = main.Size
            end
        end)
    end

    local bar = Instance.new("Frame")
    bar.Name = "Topbar"
    bar.BackgroundTransparency = 1
    bar.Size = UDim2.new(1, 0, 0, 58)
    bar.ZIndex = 3
    bar.Parent = main
    drag(bar, main)

    -- Topbar Logo Image (dj's exact logo image)
    local logoImg = Instance.new("ImageLabel")
    logoImg.Name = "TopbarLogo"
    logoImg.Size = UDim2.fromOffset(36, 36)
    logoImg.Position = UDim2.fromOffset(18, 11)
    logoImg.BackgroundTransparency = 1
    logoImg.Image = resolveLogoAsset()
    logoImg.ScaleType = Enum.ScaleType.Fit
    logoImg.ZIndex = 5
    logoImg.Parent = bar
    corner(logoImg, 8)

    local logoStroke = Instance.new("UIStroke")
    logoStroke.Color = Color3.fromRGB(255, 255, 255)
    logoStroke.Transparency = 0.65
    logoStroke.Thickness = 1
    logoStroke.Parent = logoImg

    local title = text(bar, w.Title, 16)
    title.Position = UDim2.fromOffset(62, 10)
    title.Size = UDim2.new(1, -340, 0, 20)
    title.Font = Enum.Font.GothamBold

    local sub = text(bar, w.SubTitle, 11, self.CurrentTheme.SubText)
    sub.Position = UDim2.fromOffset(63, 30)
    sub.Size = UDim2.new(1, -340, 0, 16)

    -- Top-Right Controls: Search Box, Minimize [-], Close [X]
    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.BackgroundColor3 = self.CurrentTheme.Surface
    searchFrame.Size = UDim2.fromOffset(150, 30)
    searchFrame.Position = UDim2.new(1, -240, 0, 14)
    searchFrame.ZIndex = 5
    searchFrame.Parent = bar
    corner(searchFrame, 8)
    stroke(searchFrame, self.CurrentTheme.Border, 0.3)

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.fromOffset(14, 14)
    searchIcon.Position = UDim2.new(0, 9, 0.5, -7)
    searchIcon.BackgroundTransparency = 1
    searchIcon.Image = "rbxassetid://121018724060431"
    searchIcon.ImageColor3 = Color3.fromRGB(245, 248, 255)
    searchIcon.ZIndex = 6
    searchIcon.Parent = searchFrame

    local search = Instance.new("TextBox")
    search.Text = ""
    search.PlaceholderText = "Search..."
    search.ClearTextOnFocus = false
    search.TextColor3 = self.CurrentTheme.Text
    search.PlaceholderColor3 = self.CurrentTheme.SubText
    search.TextSize = 11
    search.Font = Enum.Font.GothamBold
    search.BackgroundTransparency = 1
    search.Size = UDim2.new(1, -30, 1, 0)
    search.Position = UDim2.fromOffset(28, 0)
    search.ZIndex = 6
    search.Parent = searchFrame
    w.SearchBox = search

    local function createIconButton(iconAsset, xOffset, callback)
        local b = Instance.new("TextButton")
        b.Text = ""
        b.AutoButtonColor = false
        b.BackgroundColor3 = self.CurrentTheme.Surface
        b.Size = UDim2.fromOffset(30, 30)
        b.Position = UDim2.new(1, xOffset, 0, 14)
        b.ZIndex = 5
        b.Parent = bar
        corner(b, 8)
        stroke(b, self.CurrentTheme.Border, 0.3)

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.fromOffset(15, 15)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = iconAsset
        icon.ImageColor3 = Color3.fromRGB(245, 248, 255)
        icon.ZIndex = 6
        icon.Parent = b

        b.MouseEnter:Connect(function()
            tween(b, 0.1, { BackgroundColor3 = Fluent.CurrentTheme.Hover })
            tween(icon, 0.1, { ImageColor3 = Fluent.CurrentTheme.Accent })
        end)
        b.MouseLeave:Connect(function()
            tween(b, 0.1, { BackgroundColor3 = Fluent.CurrentTheme.Surface })
            tween(icon, 0.1, { ImageColor3 = Color3.fromRGB(245, 248, 255) })
        end)
        b.MouseButton1Click:Connect(callback)
        return b, icon
    end

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(14, 66)
    body.Size = UDim2.new(1, -28, 1, -78)
    body.ZIndex = 2
    body.Parent = main

    local minimized = false
    local minBtn, minIcon
    minBtn, minIcon = createIconButton("rbxassetid://10734896206", -82, function()
        w:Minimize()
    end)
    local closeBtn = createIconButton("rbxassetid://10747384394", -44, function() w:Destroy() end)

    -- Left Sidebar Container
    local sidebarContainer = Instance.new("Frame")
    sidebarContainer.Name = "SidebarContainer"
    sidebarContainer.BackgroundTransparency = 1
    sidebarContainer.Size = UDim2.new(0, w.TabWidth, 1, 0)
    sidebarContainer.ZIndex = 3
    sidebarContainer.Parent = body

    -- Scrollable Tab Navigation
    local sidebar = Instance.new("ScrollingFrame")
    sidebar.Name = "Sidebar"
    sidebar.BackgroundColor3 = self.CurrentTheme.Surface
    sidebar.BackgroundTransparency = 0.2
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(1, 0, 1, -56)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
    sidebar.ScrollBarThickness = 2
    sidebar.ScrollBarImageTransparency = 0.55
    sidebar.ZIndex = 3
    sidebar.Parent = sidebarContainer
    corner(sidebar, 11)
    stroke(sidebar, self.CurrentTheme.Border, 0.35)
    pad(sidebar, 7)

    local sl = Instance.new("UIListLayout")
    sl.Padding = UDim.new(0, 5)
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    sl.Parent = sidebar

    -- Bottom-Left Neverlose User Profile Card
    local profileCard = Instance.new("Frame")
    profileCard.Name = "NeverloseProfile"
    profileCard.Size = UDim2.new(1, 0, 0, 50)
    profileCard.Position = UDim2.new(0, 0, 1, -50)
    profileCard.BackgroundColor3 = self.CurrentTheme.Surface
    profileCard.BackgroundTransparency = 0.2
    profileCard.ZIndex = 4
    profileCard.Parent = sidebarContainer
    corner(profileCard, 10)
    stroke(profileCard, self.CurrentTheme.Border, 0.35)

    -- Avatar Headshot
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.fromOffset(36, 36)
    avatarImg.Position = UDim2.new(0, 7, 0.5, -18)
    avatarImg.BackgroundColor3 = self.CurrentTheme.Surface2
    avatarImg.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatarImg.ZIndex = 5
    avatarImg.Parent = profileCard
    corner(avatarImg, 18)

    -- Green Online / Active Status Dot
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.fromOffset(8, 8)
    statusDot.Position = UDim2.new(1, -7, 1, -7)
    statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 118)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 6
    statusDot.Parent = avatarImg
    corner(statusDot, 4)

    local dotStroke = Instance.new("UIStroke")
    dotStroke.Thickness = 1.5
    dotStroke.Color = Color3.fromRGB(15, 16, 20)
    dotStroke.Parent = statusDot

    -- Load Headshot Thumbnail Safely in non-blocking task
    if LocalPlayer then
        task.spawn(function()
            pcall(function()
                local content = Players:GetUserThumbnailAsync(
                    LocalPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
                if content then avatarImg.Image = content end
            end)
        end)
    end

    -- DisplayName & @Username
    local dispName = text(profileCard, LocalPlayer and LocalPlayer.DisplayName or "User", 12, self.CurrentTheme.Text)
    dispName.Position = UDim2.new(0, 48, 0, 8)
    dispName.Size = UDim2.new(1, -95, 0, 16)
    dispName.Font = Enum.Font.GothamBold
    dispName.TextTruncate = Enum.TextTruncate.AtEnd
    dispName.ZIndex = 5

    local userName = text(profileCard, LocalPlayer and ("@" .. LocalPlayer.Name) or "@user", 10, self.CurrentTheme.SubText)
    userName.Position = UDim2.new(0, 48, 0, 24)
    userName.Size = UDim2.new(1, -95, 0, 14)
    userName.Font = Enum.Font.GothamBold
    userName.TextTruncate = Enum.TextTruncate.AtEnd
    userName.ZIndex = 5

    -- Neverlose Role Tag ("USER")
    local rolePill = Instance.new("Frame")
    rolePill.Name = "RolePill"
    rolePill.Size = UDim2.fromOffset(42, 17)
    rolePill.Position = UDim2.new(1, -48, 0.5, -8)
    rolePill.BackgroundColor3 = self.CurrentTheme.Accent
    rolePill.BackgroundTransparency = 0.82
    rolePill.BorderSizePixel = 0
    rolePill.ZIndex = 5
    rolePill.Parent = profileCard
    corner(rolePill, 4)

    local roleStroke = Instance.new("UIStroke")
    roleStroke.Thickness = 1
    roleStroke.Color = self.CurrentTheme.Accent
    roleStroke.Transparency = 0.5
    roleStroke.Parent = rolePill

    local roleText = text(rolePill, "USER", 9, self.CurrentTheme.Accent)
    roleText.Size = UDim2.fromScale(1, 1)
    roleText.Font = Enum.Font.GothamBold
    roleText.TextXAlignment = Enum.TextXAlignment.Center
    roleText.ZIndex = 6

    -- Pages Area
    local pages = Instance.new("Frame")
    pages.Name = "Pages"
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.fromOffset(w.TabWidth + 10, 0)
    pages.Size = UDim2.new(1, -w.TabWidth - 10, 1, 0)
    pages.ZIndex = 2
    pages.Parent = body
    w.Sidebar = sidebar
    w.Pages = pages

    function w:SelectTab(i)
        local t
        if type(i) == "number" then
            t = self._tabs[i]
        elseif type(i) == "string" then
            t = self.Tabs[i] or self.Tabs[i:gsub("%W", "")]
        end
        if t then t:Select() end
        return t
    end

    -- Android Floating Pin Tab Widget (Square rounded like UI cards, logo fully fills size)
    local floatingPill = Instance.new("TextButton")
    floatingPill.Name = "LiyhubAndroidPinTab"
    floatingPill.Text = ""
    floatingPill.AutoButtonColor = false
    floatingPill.Size = UDim2.fromOffset(42, 42)
    floatingPill.Position = UDim2.new(0, 20, 0.5, -21)
    floatingPill.BackgroundColor3 = self.CurrentTheme.Surface
    floatingPill.BackgroundTransparency = 0.05
    floatingPill.ClipsDescendants = true
    floatingPill.Visible = false
    floatingPill.ZIndex = 100
    floatingPill.Parent = gui
    corner(floatingPill, 10)
    local pillStroke = stroke(floatingPill, Color3.fromRGB(255, 255, 255), 0.7)
    pillStroke.Thickness = 1
    drag(floatingPill, floatingPill)

    local pillLogo = Instance.new("ImageLabel")
    pillLogo.Name = "LogoImage"
    pillLogo.Size = UDim2.fromScale(1, 1)
    pillLogo.Position = UDim2.fromScale(0, 0)
    pillLogo.AnchorPoint = Vector2.new(0, 0)
    pillLogo.BackgroundTransparency = 1
    pillLogo.Image = resolveLogoAsset()
    pillLogo.ScaleType = Enum.ScaleType.Fit
    pillLogo.ZIndex = 101
    pillLogo.Active = false
    pillLogo.Parent = floatingPill
    corner(pillLogo, 10)

    floatingPill.MouseEnter:Connect(function()
        tween(floatingPill, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Hover })
        tween(pillStroke, 0.15, { Transparency = 0.1, Color = Color3.fromRGB(255, 255, 255) })
    end)
    floatingPill.MouseLeave:Connect(function()
        tween(floatingPill, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Surface })
        tween(pillStroke, 0.15, { Transparency = 0.7, Color = Color3.fromRGB(255, 255, 255) })
    end)

    floatingPill.MouseButton1Click:Connect(function()
        w:Open()
    end)
    w.FloatingPill = floatingPill
    w.AndroidPinTab = floatingPill

    function w:Destroy()
        if self.Gui then self.Gui:Destroy() end
    end
    w.Close = w.Destroy

    function w:Minimize()
        self._visible = false
        main.Visible = false
        floatingPill.Visible = true
    end

    function w:Open()
        self._visible = true
        main.Visible = true
        floatingPill.Visible = false
    end

    function w:Toggle()
        if self._visible then
            self:Minimize()
        else
            self:Open()
        end
    end

    function w:SetDevicePreset(preset)
        local vp = (workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize) or Vector2.new(1280, 720)
        local targetSize, targetTabW
        if preset == "Android" or preset == "Mobile" then
            targetSize = UDim2.fromOffset(math.clamp(math.floor(vp.X * 0.88), 460, 580), math.clamp(math.floor(vp.Y * 0.85), 330, 430))
            targetTabW = 145
        elseif preset == "Tablet" then
            targetSize = UDim2.fromOffset(math.clamp(math.floor(vp.X * 0.85), 580, 680), math.clamp(math.floor(vp.Y * 0.82), 400, 490))
            targetTabW = 160
        elseif preset == "Compact" or preset == "Mini" then
            targetSize = UDim2.fromOffset(480, 360)
            targetTabW = 135
        else
            -- PC / Standard
            targetSize = UDim2.fromOffset(680, 490)
            targetTabW = 180
        end

        w.Size = targetSize
        w.TabWidth = targetTabW
        tween(main, 0.2, { Size = targetSize })
        if sidebarContainer then
            tween(sidebarContainer, 0.2, { Size = UDim2.new(0, targetTabW, 1, 0) })
        end
        if pages then
            tween(pages, 0.2, { Position = UDim2.fromOffset(targetTabW + 10, 0), Size = UDim2.new(1, -targetTabW - 10, 1, 0) })
        end
    end

    -- Tab Instantiation
    function w:AddTab(to, iconOptional)
        local titleText = "Main"
        local iconAsset = nil
        if type(to) == "table" then
            titleText = to.Title or to.Name or "Main"
            iconAsset = to.Icon
        elseif type(to) == "string" then
            titleText = to
            iconAsset = iconOptional
        end

        local t = { Window = self, Title = titleText, Icon = iconAsset, Elements = {} }
        table.insert(self._tabs, t)
        self.Tabs[t.Title:gsub("%W", "")] = t

        local tb = Instance.new("TextButton")
        tb.AutoButtonColor = false
        tb.Text = ""
        tb.BackgroundColor3 = Fluent.CurrentTheme.Surface2
        tb.BackgroundTransparency = 0.45
        tb.Size = UDim2.new(1, 0, 0, 38)
        tb.ZIndex = 4
        tb.LayoutOrder = #self._tabs
        tb.Parent = sidebar
        corner(tb, 8)

        local accent = Instance.new("Frame")
        accent.BackgroundColor3 = Fluent.CurrentTheme.Accent
        accent.BackgroundTransparency = 1
        accent.Size = UDim2.fromOffset(3, 20)
        accent.AnchorPoint = Vector2.new(0, 0.5)
        accent.Position = UDim2.new(0, 2, 0.5, 0)
        accent.ZIndex = 5
        accent.Parent = tb
        corner(accent, 2)

        local iconType, iconVal = resolveIcon(t.Icon)
        local iconElement = nil

        if iconType == "image" then
            local img = Instance.new("ImageLabel")
            img.Name = "TabIcon"
            img.Size = UDim2.fromOffset(16, 16)
            img.Position = UDim2.new(0, 14, 0.5, -8)
            img.BackgroundTransparency = 1
            img.Image = iconVal
            img.ImageColor3 = Fluent.CurrentTheme.SubText
            img.ScaleType = Enum.ScaleType.Fit
            img.ZIndex = 5
            img.Parent = tb
            iconElement = img
        elseif iconType == "text" then
            local em = Instance.new("TextLabel")
            em.Name = "TabIcon"
            em.Size = UDim2.fromOffset(18, 18)
            em.Position = UDim2.new(0, 13, 0.5, -9)
            em.BackgroundTransparency = 1
            em.Text = iconVal
            em.TextSize = 14
            em.TextColor3 = Fluent.CurrentTheme.Text
            em.Font = Enum.Font.GothamMedium
            em.ZIndex = 5
            em.Parent = tb
            iconElement = em
        end

        local textOffset = (iconType ~= nil) and 36 or 14
        local label = text(tb, t.Title, 12, Fluent.CurrentTheme.SubText)
        label.Position = UDim2.fromOffset(textOffset, 0)
        label.Size = UDim2.new(1, -textOffset - 10, 1, 0)
        label.ZIndex = 5
        label.Font = Enum.Font.GothamBold

        local page = Instance.new("ScrollingFrame")
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.fromScale(1, 1)
        page.ScrollBarThickness = 3
        page.ScrollBarImageTransparency = 0.55
        page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        page.Visible = false
        page.ZIndex = 2
        page.Parent = pages
        pad(page, 4)

        local pl = Instance.new("UIListLayout")
        pl.Padding = UDim.new(0, 8)
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl.Parent = page
        t.Page = page
        t.Button = tb
        t.Accent = accent
        t.Label = label
        t.IconElement = iconElement

        tb.MouseEnter:Connect(function()
            if self.ActiveTab ~= t then
                tween(tb, 0.1, { BackgroundTransparency = 0.1, BackgroundColor3 = Fluent.CurrentTheme.Hover })
                if iconElement and iconElement:IsA("ImageLabel") then
                    tween(iconElement, 0.1, { ImageColor3 = Fluent.CurrentTheme.Text })
                end
            end
        end)
        tb.MouseLeave:Connect(function()
            if self.ActiveTab ~= t then
                tween(tb, 0.1, { BackgroundTransparency = 0.45, BackgroundColor3 = Fluent.CurrentTheme.Surface2 })
                if iconElement and iconElement:IsA("ImageLabel") then
                    tween(iconElement, 0.1, { ImageColor3 = Fluent.CurrentTheme.SubText })
                end
            end
        end)
        tb.MouseButton1Click:Connect(function()
            t:Select()
        end)

        function t:Select()
            for _, x in ipairs(self.Window._tabs) do
                x.Page.Visible = false
                x.Button.BackgroundColor3 = Fluent.CurrentTheme.Surface2
                x.Button.BackgroundTransparency = 0.45
                x.Accent.BackgroundTransparency = 1
                x.Label.TextColor3 = Fluent.CurrentTheme.SubText
                if x.IconElement and x.IconElement:IsA("ImageLabel") then
                    x.IconElement.ImageColor3 = Fluent.CurrentTheme.SubText
                end
            end
            self.Page.Visible = true
            self.Button.BackgroundColor3 = Fluent.CurrentTheme.Accent
            self.Button.BackgroundTransparency = 0.78
            self.Accent.BackgroundTransparency = 0
            self.Label.TextColor3 = Fluent.CurrentTheme.Text
            if self.IconElement and self.IconElement:IsA("ImageLabel") then
                self.IconElement.ImageColor3 = Fluent.CurrentTheme.Accent
            end
            self.Window.ActiveTab = self
        end

        function t:AddSection(secNameOrCfg, iconOptional)
            local s = addSection(self, secNameOrCfg, iconOptional)
            table.insert(self.Elements, s)
            return s
        end

        if #self._tabs == 1 then t:Select() end
        return t
    end

    -- Real-time Search Binding (Debounced 120ms for Zero-Lag on Mobile & PC)
    if search then
        local searchThread
        search:GetPropertyChangedSignal("Text"):Connect(function()
            if searchThread then task.cancel(searchThread) end
            searchThread = task.delay(0.12, function()
                local q = string.lower(search.Text)
                for _, t in ipairs(w._tabs) do
                    for _, e in ipairs(t.Elements) do
                        if e.SetSearch then e:SetSearch(q) end
                    end
                end
            end)
        end)
    end

    -- Hotkey Toggle Binding
    UserInputService.InputBegan:Connect(function(i, gProc)
        if not gProc and i.KeyCode == (o.MinimizeKey or Enum.KeyCode.RightControl) then
            w:Toggle()
        end
    end)

    return w
end

-- Notification System
function Fluent:Notify(o)
    o = o or {}
    local holder = self._notifyHolder
    if not holder or not holder.Parent then
        holder = Instance.new("Frame")
        holder.Name = "LiyhubNotifyHolder"
        holder.BackgroundTransparency = 1
        holder.AnchorPoint = Vector2.new(1, 1)
        holder.Position = UDim2.new(1, -18, 1, -18)
        holder.Size = UDim2.fromOffset(330, 450)
        holder.Parent = parentGui()

        local l = Instance.new("UIListLayout")
        l.VerticalAlignment = Enum.VerticalAlignment.Bottom
        l.Padding = UDim.new(0, 8)
        l.Parent = holder
        self._notifyHolder = holder
    end

    local c = self.CurrentTheme[o.Type or "Info"] or self.CurrentTheme.Info
    local f = Instance.new("Frame")
    f.BackgroundColor3 = self.CurrentTheme.Surface
    f.Size = UDim2.new(1, 0, 0, 75)
    f.Parent = holder
    corner(f, 10)
    stroke(f, c, 0.15)

    local t = text(f, o.Title or "Liyhub", 14)
    t.Position = UDim2.fromOffset(14, 9)
    t.Size = UDim2.new(1, -25, 0, 20)
    t.Font = Enum.Font.GothamBold

    local b = text(f, o.Content or "", 11, Fluent.CurrentTheme.SubText)
    b.Position = UDim2.fromOffset(14, 32)
    b.Size = UDim2.new(1, -25, 0, 35)

    task.delay(o.Duration or 3.5, function()
        if f.Parent then
            tween(f, 0.18, { BackgroundTransparency = 1 })
            task.wait(0.2)
            f:Destroy()
        end
    end)
    return f
end

function Fluent:SetTheme(name)
    if self.Themes[name] then
        self.CurrentTheme = self.Themes[name]
    end
end

g.Liyhub = Fluent
return Fluent
