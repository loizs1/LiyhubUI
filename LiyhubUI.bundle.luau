-- ============================================================================
-- LiyhubUI Framework
-- Repository: https://github.com/loizs1/LiyhubUI
-- Features: Topbar Logo Image + Neverlose Profile + Universal Config Suite
-- ============================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
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
    _unload = {},
}

-- Maid: every long-lived connection goes through track() so a reload can wipe it.
local function track(c)
    table.insert(Fluent._connections, c)
    return c
end

function Fluent:OnUnload(fn)
    table.insert(self._unload, fn)
end

function Fluent:Unload()
    -- Not one-shot: the same module instance is reused when CreateWindow replaces an old window.
    for _, fn in ipairs(self._unload) do pcall(fn) end
    for _, c in ipairs(self._connections) do pcall(function() c:Disconnect() end) end
    table.clear(self._unload)
    table.clear(self._connections)
end

-- A previous load of this library is still alive: kill its connections and loops first.
if g._LiyhubFluent and g._LiyhubFluent ~= Fluent and typeof(g._LiyhubFluent.Unload) == "function" then
    pcall(function() g._LiyhubFluent:Unload() end)
end
g._LiyhubFluent = Fluent

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

-- Returns the call's result, or nil if it errored (never the error message).
local function tryCall(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, res = pcall(fn, ...)
    if ok then return res end
    return nil
end

local function tween(o, t, p)
    local ok, x = pcall(function()
        local tw = TweenService:Create(o, TweenInfo.new(t or 0.16, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), p)
        tw:Play()
        return tw
    end)
    return (ok and x) or nil
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
    -- On text objects a UIStroke outlines the glyphs by default (glow look); outline the box instead.
    if p:IsA("TextLabel") or p:IsA("TextButton") or p:IsA("TextBox") then
        x.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    end
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
    local st = stroke(x, Fluent.CurrentTheme.Border, 0.25)
    local baseStrokeT = st.Transparency
    -- Press feedback: shrink slightly while held, spring back on release.
    local sc = Instance.new("UIScale")
    sc.Parent = x
    x.MouseEnter:Connect(function()
        tween(st, 0.12, { Transparency = math.max(0, baseStrokeT - 0.25) })
        if x:GetAttribute("NoHover") then return end
        tween(x, 0.12, { BackgroundColor3 = x:GetAttribute("HoverColor") or Fluent.CurrentTheme.Hover })
    end)
    x.MouseLeave:Connect(function()
        tween(st, 0.12, { Transparency = baseStrokeT })
        tween(sc, 0.12, { Scale = 1 })
        if x:GetAttribute("NoHover") then return end
        tween(x, 0.12, { BackgroundColor3 = x:GetAttribute("BaseColor") or Fluent.CurrentTheme.Surface2 })
    end)
    x.MouseButton1Down:Connect(function() tween(sc, 0.08, { Scale = 0.95 }) end)
    x.MouseButton1Up:Connect(function() tween(sc, 0.14, { Scale = 1 }) end)
    return x
end

local function parentGui()
    local okH, h = pcall(function() return gethui and gethui() end)
    if okH and h then return h end
    local okCg, cg = pcall(function() return CoreGui end)
    if okCg and cg then
        local test = Instance.new("Folder")
        local pOk = pcall(function()
            test.Parent = cg
            test:Destroy()
        end)
        if pOk then return cg end
    end
    local lp = Players.LocalPlayer or LocalPlayer
    if lp then
        local pg = lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
        if pg then return pg end
    end
    return game:GetService("StarterGui")
end

local function drag(handle, target)
    local moveConn, endConn
    pcall(function()
        handle.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                if moveConn then moveConn:Disconnect() moveConn = nil end
                if endConn then endConn:Disconnect() endConn = nil end

                local start = i.Position
                local pos = target.Position

                moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        pcall(function()
                            local d = moveInput.Position - start
                            local nx = pos.X.Offset + d.X
                            local ny = pos.Y.Offset + d.Y
                            local cam = workspace.CurrentCamera
                            if cam then
                                local vpOk, vp = pcall(function() return cam.ViewportSize end)
                                if vpOk and vp and vp.X > 0 and vp.Y > 0 then
                                    local ax = 0.5
                                    local ay = 0.5
                                    local sx = 680
                                    local sy = 440
                                    pcall(function()
                                        ax = target.AnchorPoint.X
                                        ay = target.AnchorPoint.Y
                                        sx = target.AbsoluteSize.X
                                        sy = target.AbsoluteSize.Y
                                    end)
                                    local curScreenX = math.clamp(vp.X * pos.X.Scale + nx, ax * sx - sx + 40, vp.X - 40 + ax * sx)
                                    local curScreenY = math.clamp(vp.Y * pos.Y.Scale + ny, ay * sy, vp.Y - 40 + ay * sy)
                                    nx = curScreenX - vp.X * pos.X.Scale
                                    ny = curScreenY - vp.Y * pos.Y.Scale
                                end
                            end
                            target.Position = UDim2.new(pos.X.Scale, nx, pos.Y.Scale, ny)
                        end)
                    end
                end)

                endConn = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        if moveConn then moveConn:Disconnect() moveConn = nil end
                        if endConn then endConn:Disconnect() endConn = nil end
                    end
                end)
            end
        end)
    end)
end

local function resolveLogoAsset()
    local logoAsset = nil

    -- 1. Executor environment: auto-download from GitHub raw & load via getcustomasset
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

    if logoAsset and logoAsset ~= "" then
        return logoAsset
    end

    -- 2. Guaranteed Roblox Cloud Asset ID (Always valid in Studio & executors)
    return "rbxassetid://79284224001788"
end

local function resolveExecutorName()
    local name = nil

    -- 1. Standard UNC API: identifyexecutor()
    if typeof(identifyexecutor) == "function" then
        local ok, n, v = pcall(identifyexecutor)
        if ok and n and tostring(n) ~= "" then
            name = tostring(n)
            if v and tostring(v) ~= "" and not string.find(string.lower(name), string.lower(tostring(v)), 1, true) then
                name = name .. " " .. tostring(v)
            end
        end
    end

    -- 2. Alternative UNC API: getexecutorname()
    if not name and typeof(getexecutorname) == "function" then
        local ok, n = pcall(getexecutorname)
        if ok and n and tostring(n) ~= "" then
            name = tostring(n)
        end
    end

    -- 3. Environment signature checks & hybrid detection (e.g. Delta / Potassium)
    pcall(function()
        if typeof(getgenv) == "function" then
            local g = getgenv()
            local isDelta = (name and string.find(string.lower(name), "delta", 1, true) ~= nil) or g.DELTA_LOADED or g.Delta
            local isPotassium = g.POTASSIUM or g.Potassium or (name and string.find(string.lower(name), "potassium", 1, true) ~= nil)

            if isDelta and isPotassium then
                name = "Delta/Potassium"
            elseif isPotassium and not name then
                name = "Potassium"
            elseif isDelta and not name then
                name = "Delta"
            elseif not name then
                if g.CODEX_LOADED or g.Codex then
                    name = "Codex"
                elseif g.WAVE_LOADED or g.Wave then
                    name = "Wave"
                elseif g.ARCEUS_LOADED or g.ArceusX then
                    name = "Arceus X"
                elseif g.HYDROGEN_LOADED or g.Hydrogen then
                    name = "Hydrogen"
                end
            end
        end
    end)

    -- 4. Studio / test runtime fallback
    if not name and game:GetService("RunService"):IsStudio() then
        name = "Studio"
    end

    return name or "Native"
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
    ["home"] = "rbxassetid://10709798730",
    ["bot"] = "rbxassetid://10709791963",
    ["paw"] = "rbxassetid://10709810842",
    ["egg"] = "rbxassetid://10709798485",
    ["sparkles"] = "rbxassetid://10709818249",
    ["utensils"] = "rbxassetid://10709819119",
    ["shopping-cart"] = "rbxassetid://10709818177",
    ["cart"] = "rbxassetid://10709818177",
    ["building-store"] = "rbxassetid://10709818177",
    ["store"] = "rbxassetid://10709818177",
    ["shop"] = "rbxassetid://10709818177",
    ["chart-line"] = "rbxassetid://10709790074",
    ["chart"] = "rbxassetid://10709790074",
    ["shield-check"] = "rbxassetid://10709818785",
    ["shield"] = "rbxassetid://10709818785",
    ["cube-vertexes"] = "rbxassetid://10709797532",
    ["chart-four-vertical-bars"] = "rbxassetid://10709790074",
}

local function resolveIcon(raw)
    if not raw or raw == "" then return nil, nil end
    if type(raw) ~= "string" then return nil, nil end

    local lower = string.lower(raw):gsub("^%s+", ""):gsub("%s+$", "")

    if LucideIcons[lower] then
        return "image", LucideIcons[lower]
    end

    -- Keyword fallbacks for compound names
    if lower:find("home") or lower:find("plot") or lower:find("house") then
        return "image", LucideIcons["home"]
    elseif lower:find("bot") or lower:find("robot") or lower:find("kaitun") then
        return "image", LucideIcons["bot"]
    elseif lower:find("cart") or lower:find("shop") or lower:find("auto") or lower:find("buy") then
        return "image", LucideIcons["shopping-cart"]
    elseif lower:find("paw") or lower:find("pet") then
        return "image", LucideIcons["paw"]
    elseif lower:find("egg") then
        return "image", LucideIcons["egg"]
    elseif lower:find("sparkle") or lower:find("hatch") then
        return "image", LucideIcons["sparkles"]
    elseif lower:find("chart") or lower:find("stat") or lower:find("bar") or lower:find("graph") then
        return "image", LucideIcons["chart-line"]
    elseif lower:find("shield") or lower:find("protect") or lower:find("util") or lower:find("afk") then
        return "image", LucideIcons["shield-check"]
    elseif lower:find("eye") or lower:find("esp") or lower:find("visual") then
        return "image", LucideIcons["eye"]
    elseif lower:find("search") or lower:find("track") then
        return "image", LucideIcons["search"]
    elseif lower:find("utensil") or lower:find("feed") or lower:find("food") or lower:find("fork") then
        return "image", LucideIcons["utensils"]
    elseif lower:find("cube") or lower:find("box") or lower:find("liyhub") then
        return "image", LucideIcons["cube-vertexes"]
    end

    if string.sub(raw, 1, 13) == "rbxassetid://" or string.sub(raw, 1, 11) == "rbxasset://" or string.find(raw, "://") then
        return "image", raw
    end
    if tonumber(raw) then
        return "image", "rbxassetid://" .. raw
    end

    -- Only return as text if it's an actual emoji (length <= 2)
    if utf8.len(raw) and utf8.len(raw) <= 2 then
        return "text", raw
    end

    -- Default fallback icon for unknown words
    return "image", LucideIcons["package"] or "rbxassetid://10709797532"
end

local function makeElement(parent, titleText, descText, h, iconOptional, orderOptional, reserveOptional)
    local f = Instance.new("Frame")
    f.BackgroundColor3 = Fluent.CurrentTheme.Surface2
    f.BackgroundTransparency = 0.45
    f.Size = UDim2.new(1, 0, 0, h or 48)
    f.LayoutOrder = orderOptional or (#parent:GetChildren() + 2)
    f.Parent = parent
    corner(f, 10)
    local rowStroke = stroke(f, Fluent.CurrentTheme.Border, 0.3)
    local rowStrokeT = rowStroke.Transparency
    f.MouseEnter:Connect(function()
        tween(f, 0.15, { BackgroundTransparency = 0.25 })
        tween(rowStroke, 0.15, { Color = Fluent.CurrentTheme.Accent, Transparency = 0.6 })
    end)
    f.MouseLeave:Connect(function()
        tween(f, 0.15, { BackgroundTransparency = 0.45 })
        tween(rowStroke, 0.15, { Color = Fluent.CurrentTheme.Border, Transparency = rowStrokeT })
    end)

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

    local isMob = Fluent.IsMobile == true
    local title = text(f, titleText, isMob and 12 or 13, Fluent.CurrentTheme.Text)
    title.Position = UDim2.fromOffset(xOffset, descText and (isMob and 6 or 8) or 0)
    -- Title width follows the row width so it fits both 1- and 2-column layouts.
    local titleW = reserveOptional and UDim.new(1, -(reserveOptional + xOffset)) or UDim.new(0.56, -(xOffset - 12))
    title.Size = UDim2.new(titleW.Scale, titleW.Offset, 0, descText and (isMob and 16 or 18) or (h or 48))
    title.Font = Enum.Font.GothamBold
    title.TextTruncate = Enum.TextTruncate.AtEnd

    if descText then
        local desc = text(f, descText, isMob and 10 or 11, Fluent.CurrentTheme.SubText)
        desc.Position = UDim2.fromOffset(xOffset, isMob and 23 or 26)
        desc.Size = UDim2.new(titleW.Scale, titleW.Offset, 0, isMob and 14 or 16)
        desc.TextTruncate = Enum.TextTruncate.AtEnd
    end
    return f
end

local function addSection(tab, titleText, iconOptional, sideOptional)
    local sec = { Tab = tab, Elements = {} }
    local secTitle = titleText or ""
    local secIcon = iconOptional
    local secSide = sideOptional
    if type(titleText) == "table" then
        secTitle = titleText.Name or titleText.Title or ""
        secIcon = titleText.Icon or iconOptional
        secSide = titleText.Side or titleText.Column or sideOptional
    end

    local isMob = Fluent.IsMobile == true
    local holder = Instance.new("Frame")
    holder.BackgroundColor3 = Fluent.CurrentTheme.Surface
    holder.Size = UDim2.new(1, 0, 0, isMob and 38 or 45)
    holder.AutomaticSize = Enum.AutomaticSize.Y
    -- Column placement is optional: on any failure the section still lands on the page.
    local placed = tab._placeSection and pcall(tab._placeSection, tab, holder, secSide)
    if not placed or not holder.Parent then holder.Parent = tab.Page end
    corner(holder, 10)
    stroke(holder, Fluent.CurrentTheme.Border, 0.3)
    pad(holder, isMob and 6 or 8)

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, isMob and 5 or 7)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = holder

    local headHolder = Instance.new("Frame")
    headHolder.Name = "SectionHeader"
    headHolder.BackgroundTransparency = 1
    headHolder.Size = UDim2.new(1, 0, 0, isMob and 18 or 22)
    headHolder.LayoutOrder = 1
    headHolder.Parent = holder

    local sIconType, sIconVal = resolveIcon(secIcon)
    local sHeadOffset = 0
    local sIconDim = isMob and 12 or 14
    if sIconType == "image" then
        local sImg = Instance.new("ImageLabel")
        sImg.Name = "SectionIcon"
        sImg.Size = UDim2.fromOffset(sIconDim, sIconDim)
        sImg.Position = UDim2.new(0, 2, 0.5, -sIconDim / 2)
        sImg.BackgroundTransparency = 1
        sImg.Image = sIconVal
        sImg.ImageColor3 = Fluent.CurrentTheme.Accent
        sImg.ScaleType = Enum.ScaleType.Fit
        sImg.Parent = headHolder
        sHeadOffset = isMob and 18 or 22
    elseif sIconType == "text" then
        local sEm = Instance.new("TextLabel")
        sEm.Name = "SectionIcon"
        sEm.Size = UDim2.fromOffset(16, 16)
        sEm.Position = UDim2.new(0, 2, 0.5, -8)
        sEm.BackgroundTransparency = 1
        sEm.Text = sIconVal
        sEm.TextSize = isMob and 11 or 13
        sEm.TextColor3 = Fluent.CurrentTheme.Text
        sEm.Font = Enum.Font.GothamMedium
        sEm.Parent = headHolder
        sHeadOffset = isMob and 18 or 22
    end

    local head = text(headHolder, secTitle, isMob and 11 or 12, Fluent.CurrentTheme.SubText)
    head.Position = UDim2.fromOffset(sHeadOffset, 0)
    head.Size = UDim2.new(1, -sHeadOffset, 1, 0)
    head.Font = Enum.Font.GothamBold

    -- Broken icon asset: drop it so the title is not left indented next to an empty gap.
    local sImgInst = headHolder:FindFirstChild("SectionIcon")
    if sImgInst and sImgInst:IsA("ImageLabel") then
        task.spawn(function()
            pcall(function()
                game:GetService("ContentProvider"):PreloadAsync({ sImgInst }, function(_, status)
                    if status ~= Enum.AssetFetchStatus.Success and sImgInst.Parent then
                        sImgInst:Destroy()
                        head.Position = UDim2.fromOffset(0, 0)
                        head.Size = UDim2.new(1, 0, 1, 0)
                    end
                end)
            end)
        end)
    end

    local function resize()
        task.defer(function()
            pcall(function()
                if not holder or not holder.Parent or not list or not list.Parent then return end
                holder.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 16)
                if tab and tab.Page and tab.Page.Parent then
                    local pl = tab.Page:FindFirstChildOfClass("UIListLayout")
                    if pl then
                        tab.Page.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 36)
                    end
                end
            end)
        end)
    end
    pcall(function()
        list:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(resize)
    end)
    sec.Resize = resize

    local function wrapElement(e, f)
        e = e or {}
        e.Frame = f or e.Frame
        e.Instance = (f and f:FindFirstChildOfClass("TextLabel")) or f or e.Instance
        local mt = {
            __index = function(tbl, key)
                if type(key) ~= "string" then return rawget(tbl, key) end
                if string.sub(key, 1, 1) == "_" or key == "Frame" or key == "Instance" or key == "Value" or key == "State" then
                    return rawget(tbl, key)
                end
                local lk = string.lower(key)
                if lk == "settext" or lk == "settitle" or lk == "set" or lk == "text" then
                    return function(self, val)
                        if rawget(tbl, "SetValue") then tbl:SetValue(val) end
                        if rawget(tbl, "SetText") then tbl:SetText(val) end
                        pcall(function()
                            if tbl.Instance and tbl.Instance:IsA("TextLabel") then
                                tbl.Instance.Text = tostring(val or "")
                            end
                        end)
                        return self
                    end
                elseif lk == "setvalue" or lk == "setstate" or lk == "update" then
                    return function(self, val)
                        if rawget(tbl, "SetValue") then return tbl:SetValue(val) end
                        return self
                    end
                elseif lk == "getvalue" or lk == "getstate" or lk == "get" then
                    return function(self)
                        if rawget(tbl, "GetValue") then return tbl:GetValue() end
                        return tbl.Value or tbl.State
                    end
                elseif lk == "setvisible" or lk == "visible" then
                    return function(self, val)
                        if tbl.Frame then tbl.Frame.Visible = val ~= false end
                        return self
                    end
                elseif lk == "tooltip" then
                    return function(self, ...) return self end
                elseif lk == "destroy" then
                    return function(self)
                        pcall(function() if tbl.Frame then tbl.Frame:Destroy() end end)
                    end
                elseif sec and sec[key] then
                    return function(self, ...)
                        return sec[key](sec, ...)
                    end
                end
                return rawget(tbl, key)
            end
        }
        setmetatable(e, mt)
        return e
    end

    function sec:SetSearch(q)
        for _, e in ipairs(self.Elements) do
            if e.SetSearch then e:SetSearch(q) end
        end
    end

    function sec:AddButton(o)
        o = o or {}
        local isMob = Fluent.IsMobile == true
        local btnW = isMob and 70 or 85
        local f = makeElement(holder, o.Title or o.Name or "Button", o.Description or o.Desc, isMob and (o.Desc and 44 or 40) or 48, o.Icon, nil, btnW + 22)
        local btnH = isMob and 26 or 30
        local b = button(f, o.ButtonText or "Run", btnH)
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Position = UDim2.new(1, -10, 0.5, 0)
        b.Size = UDim2.fromOffset(btnW, btnH)
        b.TextSize = isMob and 11 or 12
        local accent = Fluent.CurrentTheme.Accent
        b.BackgroundColor3 = accent
        b.TextColor3 = Color3.new(1, 1, 1)
        b:SetAttribute("BaseColor", accent)
        b:SetAttribute("HoverColor", accent:Lerp(Color3.new(1, 1, 1), 0.15))
        b:FindFirstChildOfClass("UIStroke").Color = accent:Lerp(Color3.new(1, 1, 1), 0.35)
        local sheen = Instance.new("UIGradient")
        sheen.Rotation = 90
        sheen.Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.fromRGB(190, 190, 200))
        sheen.Parent = b
        b.MouseButton1Click:Connect(function() safe(o.Callback) end)
        -- Whole row acts as the button; skip when the press landed on the button itself.
        local btnHit = false
        b.MouseButton1Down:Connect(function() btnHit = true end)
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                task.defer(function()
                    if not btnHit then safe(o.Callback) end
                    btnHit = false
                end)
            end
        end)
        local e = {
            Frame = f,
            Button = b,
            Click = function() safe(o.Callback) end,
            Fire = function() safe(o.Callback) end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(o.Title or o.Name or ""), q, 1, true) ~= nil
            end,
        }
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddToggle(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Flag or cfg.Name or cfg.Title or "Toggle"
        elseif type(o) == "table" and o.Flag then
            flag = o.Flag
        end

        local isMob = Fluent.IsMobile == true
        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, isMob and (cfg.Desc and 44 or 40) or 48, cfg.Icon, nil, isMob and 56 or 64)
        local state = cfg.Default == true
        -- Pill switch instead of an ON/OFF text button
        local btnW = isMob and 36 or 42
        local btnH = isMob and 20 or 22
        local knobD = btnH - 6
        local b = button(f, "", btnH)
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Position = UDim2.new(1, -12, 0.5, 0)
        b.Size = UDim2.fromOffset(btnW, btnH)
        b:FindFirstChildOfClass("UICorner").CornerRadius = UDim.new(1, 0)
        b:SetAttribute("NoHover", true)
        local track_ = b:FindFirstChildOfClass("UIStroke")
        local offColor = Color3.fromRGB(40, 45, 58)
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.AnchorPoint = Vector2.new(0, 0.5)
        knob.Size = UDim2.fromOffset(knobD, knobD)
        knob.BackgroundColor3 = Color3.new(1, 1, 1)
        knob.ZIndex = 3
        knob.Parent = b
        corner(knob, knobD)
        -- Thin dark ring instead of a child shadow frame (children draw over their parent).
        local knobRing = Instance.new("UIStroke")
        knobRing.Color = Color3.new(0, 0, 0)
        knobRing.Transparency = 0.75
        knobRing.Parent = knob
        local function knobPos(on) return UDim2.new(0, on and (btnW - knobD - 3) or 3, 0.5, 0) end
        local function paint(on, t)
            local bg = on and Fluent.CurrentTheme.Accent or offColor
            local sc = on and Fluent.CurrentTheme.Accent:Lerp(Color3.new(1, 1, 1), 0.3) or Fluent.CurrentTheme.Border
            if t then
                tween(b, t, { BackgroundColor3 = bg })
                tween(track_, t, { Color = sc, Transparency = on and 0.4 or 0.85 })
                tween(knob, t, { BackgroundColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(200, 206, 220) })
            else
                b.BackgroundColor3 = bg
                track_.Color = sc
                track_.Transparency = on and 0.4 or 0.85
                knob.BackgroundColor3 = on and Color3.new(1, 1, 1) or Color3.fromRGB(200, 206, 220)
            end
        end
        knob.Position = knobPos(state)
        paint(state)
        Fluent.Flags[flag] = state

        local e
        local function set(v, fire)
            state = not not v
            Fluent.Flags[flag] = state
            if e then e.Value = state end
            tween(knob, 0.2, { Position = knobPos(state) })
            paint(state, 0.2)
            if fire then safe(cfg.Callback, state) end
        end

        b.MouseButton1Click:Connect(function() set(not state, true) end)
        -- Whole row toggles; skip when the press landed on the switch itself.
        local switchHit = false
        b.MouseButton1Down:Connect(function() switchHit = true end)
        f.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                task.defer(function()
                    if not switchHit then set(not state, true) end
                    switchHit = false
                end)
            end
        end)

        e = {
            Frame = f,
            Value = state,
            SetValue = function(_, v) set(v, true) end,
            GetValue = function() return state end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddSlider(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Flag or cfg.Name or cfg.Title or "Slider"
        elseif type(o) == "table" and o.Flag then
            flag = o.Flag
        end

        local isMob = Fluent.IsMobile == true
        local hasDesc = (cfg.Description or cfg.Desc) ~= nil
        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, hasDesc and (isMob and 60 or 66) or (isMob and 48 or 54), cfg.Icon, nil, isMob and 64 or 72)

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
        valBadge.Position = UDim2.new(1, -12, 0, hasDesc and (isMob and 7 or 8) or (isMob and 8 or 9))
        valBadge.Size = UDim2.fromOffset(isMob and 46 or 54, isMob and 18 or 20)
        valBadge.Parent = f
        corner(valBadge, 6)
        stroke(valBadge, Fluent.CurrentTheme.Border, 0.35)

        local valLabel = text(valBadge, tostring(current) .. (cfg.Suffix or ""), isMob and 10 or 11, Fluent.CurrentTheme.Accent)
        valLabel.Size = UDim2.fromScale(1, 1)
        valLabel.TextXAlignment = Enum.TextXAlignment.Center
        valLabel.Font = Enum.Font.GothamBold

        -- Slider Track (WindUI Rail)
        local rail = Instance.new("Frame")
        rail.Name = "SliderTrack"
        rail.BackgroundColor3 = Color3.fromRGB(24, 30, 42)
        rail.Position = UDim2.new(0, 14, 0, hasDesc and (isMob and 42 or 48) or (isMob and 32 or 36))
        rail.Size = UDim2.new(1, -28, 0, 6)
        rail.Parent = f
        corner(rail, 3)
        stroke(rail, Fluent.CurrentTheme.Border, 0.45)
        -- Larger invisible hit area so the thin rail is easy to grab.
        local hit = Instance.new("Frame")
        hit.Name = "HitArea"
        hit.BackgroundTransparency = 1
        hit.AnchorPoint = Vector2.new(0, 0.5)
        hit.Position = UDim2.new(0, 0, 0.5, 0)
        hit.Size = UDim2.new(1, 0, 0, 22)
        hit.Parent = rail

        -- Blue Line Fill
        local fill = Instance.new("Frame")
        fill.Name = "SliderFill"
        fill.BackgroundColor3 = Fluent.CurrentTheme.Accent
        fill.Size = UDim2.fromScale(math.clamp((current - min) / math.max(1, max - min), 0, 1), 1)
        fill.Parent = rail
        corner(fill, 3)
        local fillGrad = Instance.new("UIGradient")
        fillGrad.Color = ColorSequence.new(Fluent.CurrentTheme.Accent:Lerp(Color3.new(0, 0, 0), 0.25), Fluent.CurrentTheme.Accent:Lerp(Color3.new(1, 1, 1), 0.2))
        fillGrad.Parent = fill

        -- Circular Draggable Knob / Thumb
        local knob = Instance.new("Frame")
        knob.Name = "Knob"
        knob.Size = UDim2.fromOffset(14, 14)
        knob.AnchorPoint = Vector2.new(0.5, 0.5)
        knob.Position = UDim2.new(1, 0, 0.5, 0)
        knob.BackgroundColor3 = Color3.fromRGB(250, 252, 255)
        knob.ZIndex = 5
        knob.Parent = fill
        corner(knob, 8)
        stroke(knob, Fluent.CurrentTheme.Accent, 0).Thickness = 2

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
            pcall(function()
                local railW = 0
                pcall(function() railW = rail.AbsoluteSize.X end)
                if railW > 0 then
                    local railX = 0
                    pcall(function() railX = rail.AbsolutePosition.X end)
                    local rel = (input.Position.X - railX) / railW
                    local alpha = math.clamp(rel, 0, 1)
                    set(min + (max - min) * alpha, true)
                end
            end)
        end

        local moveConn, endConn
        hit.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                if moveConn then moveConn:Disconnect() moveConn = nil end
                if endConn then endConn:Disconnect() endConn = nil end

                tween(knob, 0.1, { Size = UDim2.fromOffset(18, 18) })
                updateDrag(i)

                moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                    if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                        updateDrag(moveInput)
                    end
                end)

                endConn = UserInputService.InputEnded:Connect(function(endInput)
                    if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                        if moveConn then moveConn:Disconnect() moveConn = nil end
                        if endConn then endConn:Disconnect() endConn = nil end
                        tween(knob, 0.1, { Size = UDim2.fromOffset(14, 14) })
                    end
                end)
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
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddDropdown(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Flag or cfg.Name or cfg.Title or "Dropdown"
        elseif type(o) == "table" and o.Flag then
            flag = o.Flag
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
        pill.Size = UDim2.new(0.42, 0, 0, Fluent.IsMobile and 26 or 28)
        pill.Parent = f
        local pillCap = Instance.new("UISizeConstraint")
        pillCap.MaxSize = Vector2.new(Fluent.IsMobile and 125 or 165, 40)
        pillCap.Parent = pill
        corner(pill, 8)
        local pillStroke = stroke(pill, Fluent.CurrentTheme.Border, 0.35)
        local pillStrokeT = pillStroke.Transparency
        pill.MouseEnter:Connect(function()
            tween(pill, 0.12, { BackgroundColor3 = Fluent.CurrentTheme.Hover })
            tween(pillStroke, 0.12, { Color = Fluent.CurrentTheme.Accent, Transparency = 0.45 })
        end)
        pill.MouseLeave:Connect(function()
            tween(pill, 0.12, { BackgroundColor3 = Fluent.CurrentTheme.Surface })
            tween(pillStroke, 0.12, { Color = Fluent.CurrentTheme.Border, Transparency = pillStrokeT })
        end)

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
        local optHeight = math.clamp(#values * 32 + 8, 36, 180)
        local optionsContainer = Instance.new("Frame")
        optionsContainer.Name = "OptionsContainer"
        optionsContainer.BackgroundColor3 = Color3.fromRGB(18, 22, 32)
        optionsContainer.Position = UDim2.new(0, 10, 0, headerH + 2)
        optionsContainer.Size = UDim2.new(1, -20, 0, optHeight)
        optionsContainer.Visible = false
        optionsContainer.ClipsDescendants = true
        optionsContainer.ZIndex = 10
        optionsContainer.Parent = f
        corner(optionsContainer, 7)
        stroke(optionsContainer, Fluent.CurrentTheme.Border, 0.4)

        local sc = Instance.new("ScrollingFrame")
        sc.Name = "DropdownScroll"
        sc.BackgroundTransparency = 1
        sc.BorderSizePixel = 0
        sc.Size = UDim2.fromScale(1, 1)
        sc.CanvasSize = UDim2.new(0, 0, 0, 0)
        sc.AutomaticCanvasSize = Enum.AutomaticSize.None
        sc.ScrollingDirection = Enum.ScrollingDirection.Y
        sc.ScrollBarThickness = 4
        sc.ScrollBarImageTransparency = 0.35
        sc.ElasticBehavior = Enum.ElasticBehavior.Always
        sc.ZIndex = 11
        sc.Parent = optionsContainer
        pad(sc, 5, 6, 8, 5)

        local lay = Instance.new("UIListLayout")
        lay.Padding = UDim.new(0, 3)
        lay.Parent = sc

        local function updateScCanvas()
            pcall(function()
                local layY = 0
                pcall(function()
                    if lay and lay.AbsoluteContentSize then
                        layY = lay.AbsoluteContentSize.Y
                    end
                end)
                sc.CanvasSize = UDim2.new(0, 0, 0, layY + 12)
            end)
        end
        pcall(function()
            lay:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScCanvas)
        end)

        local optionRows = {}
        local isOpen = false

        local function buildOptions()
            for _, r in ipairs(optionRows) do pcall(function() r:Destroy() end) end
            optionRows = {}

            if #values == 0 then
                local emptyRow = Instance.new("Frame")
                emptyRow.BackgroundTransparency = 1
                emptyRow.Size = UDim2.new(1, 0, 0, 26)
                emptyRow.ZIndex = 12
                emptyRow.Parent = sc
                local emptyLbl = text(emptyRow, "None available", 11, Fluent.CurrentTheme.SubText)
                emptyLbl.Size = UDim2.fromScale(1, 1)
                emptyLbl.Position = UDim2.fromOffset(8, 0)
                emptyLbl.ZIndex = 13
                table.insert(optionRows, emptyRow)
                updateScCanvas()
                return
            end

            for _, v in ipairs(values) do
                local valStr = tostring(v)
                local isChecked = isMulti and selected[v] == true or (not isMulti and tostring(current) == valStr)

                local row = Instance.new("TextButton")
                row.Name = "Option_" .. valStr
                row.AutoButtonColor = false
                row.Text = ""
                row.BackgroundColor3 = isChecked and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface2
                row.BackgroundTransparency = isChecked and 0.75 or 0.6
                row.Size = UDim2.new(1, 0, 0, 28)
                row.ZIndex = 12
                row.Parent = sc
                corner(row, 6)

                local rowLabel = text(row, valStr, 11, isChecked and Fluent.CurrentTheme.Text or Fluent.CurrentTheme.SubText)
                rowLabel.Position = UDim2.fromOffset(10, 0)
                rowLabel.Size = UDim2.new(1, -40, 1, 0)
                rowLabel.Font = Enum.Font.GothamBold
                rowLabel.ZIndex = 13

                if isMulti then
                    -- Checkbox square
                    local checkSquare = Instance.new("Frame")
                    checkSquare.Name = "Checkbox"
                    checkSquare.Size = UDim2.fromOffset(16, 16)
                    checkSquare.Position = UDim2.new(1, -22, 0.5, -8)
                    checkSquare.BackgroundColor3 = isChecked and Fluent.CurrentTheme.Accent or Fluent.CurrentTheme.Surface
                    checkSquare.BackgroundTransparency = isChecked and 0.2 or 0.5
                    checkSquare.ZIndex = 13
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
                    checkIco.ZIndex = 14
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
                    checkIco.ZIndex = 13
                    checkIco.Parent = row

                    row.MouseButton1Click:Connect(function()
                        current = v
                        Fluent.Flags[flag] = v
                        pillLabel.Text = getSummary()
                        safe(cfg.Callback, v)

                        -- Close after selection
                        optionsContainer.Visible = false
                        isOpen = false
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
            updateScCanvas()
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
            SetValue = function(_, v, fire)
                if isMulti then
                    selected = {}
                    if type(v) == "table" then
                        for k, item in pairs(v) do
                            if type(k) == "number" then
                                selected[item] = true
                            else
                                selected[k] = (item == true)
                            end
                        end
                    elseif v ~= nil then
                        selected[v] = true
                    end
                    Fluent.Flags[flag] = selected
                    if fire ~= false then
                        local outList = {}
                        for _, item in ipairs(values) do
                            if selected[item] then table.insert(outList, item) end
                        end
                        safe(cfg.Callback, outList)
                    end
                else
                    current = v
                    Fluent.Flags[flag] = v
                    if fire ~= false then
                        safe(cfg.Callback, v)
                    end
                end
                pillLabel.Text = getSummary()
                buildOptions()
            end,
            SetValues = function(self, newVals)
                values = newVals or {}
                optHeight = math.clamp(#values * 32 + 8, 36, 180)
                optionsContainer.Size = UDim2.new(1, -20, 0, optHeight)
                buildOptions()
                if isOpen then
                    f.Size = UDim2.new(1, 0, 0, headerH + optHeight + 8)
                else
                    f.Size = UDim2.new(1, 0, 0, headerH)
                end
            end,
            SetOptions = function(self, newVals, selectVal)
                self:SetValues(newVals)
                if selectVal ~= nil then
                    self:SetValue(selectVal)
                elseif #values > 0 then
                    self:SetValue(values[1])
                end
            end,
            Set = function(self, v) self:SetValue(v) end,
            GetValue = function() return isMulti and selected or current end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        wrapElement(e, f)
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
            flag = cfg.Flag or cfg.Name or cfg.Title or "Textbox"
        elseif type(o) == "table" and o.Flag then
            flag = o.Flag
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
        box.Size = UDim2.new(0.42, 0, 0, Fluent.IsMobile and 26 or 30)
        box.Parent = f
        local boxCap = Instance.new("UISizeConstraint")
        boxCap.MaxSize = Vector2.new(Fluent.IsMobile and 125 or 180, 40)
        boxCap.Parent = box
        corner(box, 8)
        local boxStroke = stroke(box, Fluent.CurrentTheme.Border, 0.25)
        local boxStrokeT = boxStroke.Transparency
        pad(box, 0, 10, 0, 10)
        box.TextXAlignment = Enum.TextXAlignment.Left
        box.TextTruncate = Enum.TextTruncate.AtEnd
        Fluent.Flags[flag] = box.Text

        box.Focused:Connect(function()
            tween(boxStroke, 0.15, { Color = Fluent.CurrentTheme.Accent, Transparency = 0.1 })
            tween(box, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Surface })
        end)
        box.FocusLost:Connect(function()
            tween(boxStroke, 0.15, { Color = Fluent.CurrentTheme.Border, Transparency = boxStrokeT })
            tween(box, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Surface2 })
            Fluent.Flags[flag] = box.Text
            safe(cfg.Callback, box.Text)
        end)

        local e = {
            Frame = f,
            SetValue = function(_, v, fire)
                box.Text = tostring(v or "")
                Fluent.Flags[flag] = box.Text
                if fire ~= false then
                    safe(cfg.Callback, box.Text)
                end
            end,
            GetValue = function() return box.Text end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end
    sec.AddInput = sec.AddTextbox

    function sec:AddKeybind(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Flag or cfg.Name or cfg.Title or "Keybind"
        elseif type(o) == "table" and o.Flag then
            flag = o.Flag
        end

        local f = makeElement(holder, cfg.Title or cfg.Name or flag, cfg.Description or cfg.Desc, 48, cfg.Icon)
        local defaultKey = cfg.Default or "RightControl"
        if typeof(defaultKey) == "EnumItem" then defaultKey = defaultKey.Name end
        local key = tostring(defaultKey)
        Fluent.Flags[flag] = Enum.KeyCode[key] or Enum.KeyCode.RightControl

        local b = button(f, key, 28)
        b.AnchorPoint = Vector2.new(1, 0.5)
        b.Position = UDim2.new(1, -10, 0.5, 0)
        b.Size = UDim2.fromOffset(0, 28)
        b.AutomaticSize = Enum.AutomaticSize.X
        b.Font = Enum.Font.GothamBold
        b.TextSize = 11
        b.BackgroundColor3 = Fluent.CurrentTheme.Surface
        b:SetAttribute("BaseColor", Fluent.CurrentTheme.Surface)
        pad(b, 0, 12, 0, 12)
        local minW = Instance.new("UISizeConstraint")
        minW.MinSize = Vector2.new(64, 28)
        minW.Parent = b
        -- Keycap bottom edge for a physical-key look.
        local cap = Instance.new("Frame")
        cap.Name = "KeycapEdge"
        cap.AnchorPoint = Vector2.new(0.5, 1)
        cap.Position = UDim2.new(0.5, 0, 1, 0)
        cap.Size = UDim2.new(1, -8, 0, 2)
        cap.BackgroundColor3 = Fluent.CurrentTheme.Accent
        cap.BackgroundTransparency = 0.5
        cap.BorderSizePixel = 0
        cap.Parent = b
        corner(cap, 1)

        local listening = false
        local connection, listenerConn

        local function bind(k)
            if connection then connection:Disconnect() end
            if k and k ~= Enum.KeyCode.Unknown then
                connection = track(UserInputService.InputBegan:Connect(function(i, gProc)
                    if not gProc and i.KeyCode == k then
                        safe(cfg.Callback, k)
                    end
                end))
            end
        end
        bind(Enum.KeyCode[key] or Enum.KeyCode.RightControl)

        b.MouseButton1Click:Connect(function()
            if listening then return end
            listening = true
            b.Text = "Press a key..."
            b.TextColor3 = Fluent.CurrentTheme.Accent
            tween(b, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Hover })

            if listenerConn then listenerConn:Disconnect() end
            listenerConn = UserInputService.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.Keyboard then
                    if i.KeyCode == Enum.KeyCode.Escape or i.KeyCode == Enum.KeyCode.Backspace then
                        key = "None"
                        b.Text = "None"
                        b.TextColor3 = Fluent.CurrentTheme.SubText
                        bind(nil)
                        Fluent.Flags[flag] = nil
                    elseif i.KeyCode ~= Enum.KeyCode.Unknown then
                        key = i.KeyCode.Name
                        b.Text = key
                        b.TextColor3 = Fluent.CurrentTheme.Text
                        bind(i.KeyCode)
                        Fluent.Flags[flag] = i.KeyCode
                        safe(cfg.Callback, i.KeyCode)
                    end
                    listening = false
                    tween(b, 0.15, { BackgroundColor3 = Fluent.CurrentTheme.Surface })
                    if listenerConn then listenerConn:Disconnect() listenerConn = nil end
                end
            end)
        end)

        local e = {
            Frame = f,
            SetValue = function(_, v)
                local name = typeof(v) == "EnumItem" and v.Name or tostring(v)
                key = name
                b.Text = name
                bind(Enum.KeyCode[name])
                Fluent.Flags[flag] = Enum.KeyCode[name]
            end,
            GetValue = function() return key end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(cfg.Title or cfg.Name or flag), q, 1, true) ~= nil
            end,
        }
        Fluent.Options[flag] = e
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddColorPicker(flagOrCfg, o)
        local flag = flagOrCfg
        local cfg = o or {}
        if type(flagOrCfg) == "table" then
            cfg = flagOrCfg
            flag = cfg.Flag or cfg.Name or cfg.Title or "ColorPicker"
        elseif type(o) == "table" and o.Flag then
            flag = o.Flag
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
        pill.Size = UDim2.new(0.4, 0, 0, 28)
        pill.Parent = f
        local colorCap = Instance.new("UISizeConstraint")
        colorCap.MaxSize = Vector2.new(130, 40)
        colorCap.Parent = pill
        corner(pill, 8)
        local pillStroke = stroke(pill, Fluent.CurrentTheme.Border, 0.35)
        local pillStrokeT = pillStroke.Transparency
        pill.MouseEnter:Connect(function()
            tween(pill, 0.12, { BackgroundColor3 = Fluent.CurrentTheme.Hover })
            tween(pillStroke, 0.12, { Color = Fluent.CurrentTheme.Accent, Transparency = 0.45 })
        end)
        pill.MouseLeave:Connect(function()
            tween(pill, 0.12, { BackgroundColor3 = Fluent.CurrentTheme.Surface })
            tween(pillStroke, 0.12, { Color = Fluent.CurrentTheme.Border, Transparency = pillStrokeT })
        end)

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

            local chMoveConn, chEndConn
            chTrack.InputBegan:Connect(function(i)
                if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
                    if chMoveConn then chMoveConn:Disconnect() chMoveConn = nil end
                    if chEndConn then chEndConn:Disconnect() chEndConn = nil end

                    local function updateChannel(input)
                        pcall(function()
                            local trackWidth = 100
                            local trackX = 0
                            pcall(function()
                                trackWidth = math.max(chTrack.AbsoluteSize.X, 1)
                                trackX = chTrack.AbsolutePosition.X
                            end)
                            local alpha = math.clamp((input.Position.X - trackX) / trackWidth, 0, 1)
                            local v = math.floor(alpha * 255)
                            chFill.Size = UDim2.fromScale(alpha, 1)
                            chVal.Text = tostring(v)
                            updateColor(ch.Set(v), true)
                        end)
                    end
                    updateChannel(i)

                    chMoveConn = UserInputService.InputChanged:Connect(function(moveInput)
                        if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                            updateChannel(moveInput)
                        end
                    end)

                    chEndConn = UserInputService.InputEnded:Connect(function(endInput)
                        if endInput.UserInputType == Enum.UserInputType.MouseButton1 or endInput.UserInputType == Enum.UserInputType.Touch then
                            if chMoveConn then chMoveConn:Disconnect() chMoveConn = nil end
                            if chEndConn then chEndConn:Disconnect() chEndConn = nil end
                        end
                    end)
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
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddParagraph(o)
        o = o or {}
        local pTitle = o.Title or ""
        local pContent = o.Content or ""

        local f = Instance.new("Frame")
        f.BackgroundColor3 = Fluent.CurrentTheme.Surface2
        f.BackgroundTransparency = 0.45
        f.LayoutOrder = #holder:GetChildren() + 2
        f.Parent = holder
        corner(f, 8)
        stroke(f, Fluent.CurrentTheme.Border, 0.3)

        local tLbl = text(f, pTitle, 13, Fluent.CurrentTheme.Text)
        tLbl.Position = UDim2.fromOffset(12, 10)
        tLbl.Size = UDim2.new(1, -24, 0, 18)
        tLbl.Font = Enum.Font.GothamBold

        local cLbl = text(f, pContent, 11, Fluent.CurrentTheme.SubText)
        cLbl.Position = UDim2.fromOffset(12, 34)
        cLbl.Size = UDim2.new(1, -24, 0, 10)
        cLbl.Font = Enum.Font.Gotham
        cLbl.TextYAlignment = Enum.TextYAlignment.Top

        local function updateSize()
            local w = math.max(280, f.AbsoluteSize.X > 30 and (f.AbsoluteSize.X - 24) or 380)
            local measured = TextService:GetTextSize(pContent, 11, Enum.Font.Gotham, Vector2.new(w, 2000))
            local totalH = math.max(65, measured.Y + 46)
            f.Size = UDim2.new(1, 0, 0, totalH)
            cLbl.Size = UDim2.new(1, -24, 0, measured.Y + 6)
            resize()
        end

        task.defer(updateSize)
        pcall(function()
            f:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                pcall(function()
                    if f.AbsoluteSize.X > 50 then
                        updateSize()
                    end
                end)
            end)
        end)

        local e = {
            Frame = f,
            SetTitle = function(_, newTitle)
                pTitle = newTitle or ""
                tLbl.Text = pTitle
            end,
            SetContent = function(_, newContent)
                pContent = newContent or ""
                cLbl.Text = pContent
                updateSize()
            end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(pTitle .. " " .. pContent), q, 1, true) ~= nil
            end,
        }
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddLabel(o)
        local title = type(o) == "string" and o or (o and (o.Text or o.Title) or "")
        local f = makeElement(holder, title, nil, 36)
        local lbl = f:FindFirstChildOfClass("TextLabel")
        local e = {
            Instance = lbl,
            Frame = f,
            Title = title,
            SetText = function(_, newText)
                if lbl then lbl.Text = tostring(newText or "") end
            end,
            Text = function(self, newText) self:SetText(newText) end,
            SetSearch = function(_, q)
                f.Visible = q == "" or string.find(string.lower(title), q, 1, true) ~= nil
            end,
            AddDropdown = function(_, cfg)
                pcall(function() f:Destroy() end)
                cfg = cfg or {}
                cfg.Name = cfg.Name or cfg.Title or title
                cfg.Flag = cfg.Flag or cfg.Name
                return sec:AddDropdown(cfg)
            end,
            AddToggle = function(_, cfg)
                pcall(function() f:Destroy() end)
                cfg = cfg or {}
                cfg.Name = cfg.Name or cfg.Title or title
                cfg.Flag = cfg.Flag or cfg.Name
                return sec:AddToggle(cfg)
            end,
            AddSlider = function(_, cfg)
                pcall(function() f:Destroy() end)
                cfg = cfg or {}
                cfg.Name = cfg.Name or cfg.Title or title
                cfg.Flag = cfg.Flag or cfg.Name
                return sec:AddSlider(cfg)
            end,
            AddTextbox = function(_, cfg)
                pcall(function() f:Destroy() end)
                cfg = cfg or {}
                cfg.Name = cfg.Name or cfg.Title or title
                cfg.Flag = cfg.Flag or cfg.Name
                return sec:AddTextbox(cfg)
            end,
            AddTextInput = function(self, cfg)
                return self:AddTextbox(cfg)
            end,
            Set = function(self, newText)
                self:SetText(newText)
            end,
        }
        wrapElement(e, f)
        table.insert(sec.Elements, e)
        return e
    end

    function sec:AddRow()
        local rowFrame = Instance.new("Frame")
        rowFrame.BackgroundTransparency = 1
        rowFrame.Size = UDim2.new(1, 0, 0, 44)
        rowFrame.AutomaticSize = Enum.AutomaticSize.Y
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

    sec.AddTextInput = function(self, cfg, ...)
        return self:AddTextbox(cfg, ...)
    end

    sec.Label = function(self, ...) return self:AddLabel(...) end
    sec.CreateLabel = function(self, ...) return self:AddLabel(...) end
    sec.Toggle = function(self, ...) return self:AddToggle(...) end
    sec.CreateToggle = function(self, ...) return self:AddToggle(...) end
    sec.Slider = function(self, ...) return self:AddSlider(...) end
    sec.CreateSlider = function(self, ...) return self:AddSlider(...) end
    sec.Dropdown = function(self, ...) return self:AddDropdown(...) end
    sec.CreateDropdown = function(self, ...) return self:AddDropdown(...) end
    sec.Button = function(self, ...) return self:AddButton(...) end
    sec.CreateButton = function(self, ...) return self:AddButton(...) end
    sec.Paragraph = function(self, ...) return self:AddParagraph(...) end
    sec.CreateParagraph = function(self, ...) return self:AddParagraph(...) end
    sec.Keybind = function(self, ...) return self:AddKeybind(...) end
    sec.CreateKeybind = function(self, ...) return self:AddKeybind(...) end
    sec.ColorPicker = function(self, ...) return self:AddColorPicker(...) end
    sec.CreateColorPicker = function(self, ...) return self:AddColorPicker(...) end
    sec.Colorpicker = function(self, ...) return self:AddColorPicker(...) end
    sec.CreateColorpicker = function(self, ...) return self:AddColorPicker(...) end
    sec.TextBox = function(self, ...) return self:AddTextbox(...) end
    sec.CreateTextBox = function(self, ...) return self:AddTextbox(...) end
    sec.Textbox = function(self, ...) return self:AddTextbox(...) end
    sec.CreateTextbox = function(self, ...) return self:AddTextbox(...) end

    sec.AddDivider = function(self)
        local d = Instance.new("Frame")
        d.Name = "Divider"
        d.Size = UDim2.new(1, 0, 0, 1)
        d.BackgroundColor3 = Fluent.CurrentTheme.Border
        d.BackgroundTransparency = 0.7
        d.BorderSizePixel = 0
        d.LayoutOrder = #holder:GetChildren() + 2
        d.Parent = holder
        resize()
        return d
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

    local isAndroid = false
    local isIOS = false
    pcall(function()
        local platform = UserInputService:GetPlatform()
        if platform == Enum.Platform.Android then
            isAndroid = true
        elseif platform == Enum.Platform.IOS then
            isIOS = true
        end
    end)

    if o.Device or o.Platform then
        local devLower = string.lower(tostring(o.Device or o.Platform))
        if devLower == "android" then
            isAndroid = true
        elseif devLower == "ios" or devLower == "iphone" or devLower == "ipad" then
            isIOS = true
        end
    end

    local isTouch = UserInputService.TouchEnabled
    local isKeyboard = UserInputService.KeyboardEnabled
    local isMouse = UserInputService.MouseEnabled
    local isMobile = isAndroid or isIOS or (isTouch and (not isKeyboard or not isMouse))
    if o.Device or o.Platform then
        local devLower = string.lower(tostring(o.Device or o.Platform))
        if devLower == "mobile" or devLower == "phone" then
            isMobile = true
        elseif devLower == "pc" or devLower == "windows" then
            isMobile = false
            isAndroid = false
            isIOS = false
        end
    end

    local cam = workspace.CurrentCamera
    local vp = (cam and cam.ViewportSize) or Vector2.new(1280, 720)

    if vp.X < 850 and isTouch then
        isMobile = true
    end

    Fluent.IsMobile = isMobile
    Fluent.IsAndroid = isAndroid
    Fluent.IsIOS = isIOS

    local deviceName = (isAndroid and "Android") or (isIOS and "iOS") or (isMobile and "Mobile") or "PC"
    if o.Device then
        deviceName = tostring(o.Device)
    end

    -- Auto Size Standard (PC: 680x480, TabWidth: 165; Mobile/Android/iOS: 480x310, TabWidth: 125)
    local defaultSize
    local defaultTabWidth
    if isMobile then
        local targetW = math.clamp(math.floor(vp.X * 0.72), 440, 510)
        local targetH = math.clamp(math.floor(vp.Y * 0.78), 280, 325)
        defaultSize = UDim2.fromOffset(targetW, targetH)
        defaultTabWidth = 125
    else
        defaultSize = UDim2.fromOffset(820, 540)
        defaultTabWidth = 150
    end

    local size = o.Size or defaultSize
    if isMobile and cam then
        local maxW = math.clamp(math.floor(vp.X * 0.78), 440, 520)
        local maxH = math.clamp(math.floor(vp.Y * 0.82), 280, 335)
        if not o.Size or size.X.Offset > maxW or size.Y.Offset > maxH then
            size = UDim2.fromOffset(math.min(size.X.Offset, maxW), math.min(size.Y.Offset, maxH))
        end
    end

    if o.ConfigFolder or o.Folder then
        self.ConfigFolder = tostring(o.ConfigFolder or o.Folder)
    end

    local w = {
        Title = o.Title or o.Name or "Liyhub",
        SubTitle = o.Author or o.SubTitle or "",
        Size = size,
        Tabs = {},
        _tabs = {},
        _sortTabs = (o.SortTabs ~= false) and (o.AutoSortTabs ~= false),
        _visible = true,
        TabWidth = (isMobile and (o.TabWidth and math.min(o.TabWidth, 135) or defaultTabWidth)) or (o.TabWidth or defaultTabWidth),
        Device = deviceName,
        Columns = o.Columns, -- nil = auto (2 when wide enough), 1 = always single, 2 = prefer two
        IsMobile = isMobile,
        IsAndroid = isAndroid,
        IsIOS = isIOS,
    }
    table.insert(self._windows, w)
    g._LiyhubCurrentWindow = w

    local gui = Instance.new("ScreenGui")
    gui.Name = "LiyhubFluent_Main"
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 2147483647
    gui.IgnoreGuiInset = true
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
        pcall(syn.protect_gui, gui)
    elseif typeof(protect_gui) == "function" then
        pcall(protect_gui, gui)
    elseif typeof(protectgui) == "function" then
        pcall(protectgui, gui)
    end

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
    topLine.Position = UDim2.fromOffset(isMobile and 12 or 18, isMobile and 50 or 58)
    topLine.Size = UDim2.new(1, isMobile and -24 or -36, 0, 1)
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
            local initW, initH = 680, 440
            pcall(function()
                initW = main.AbsoluteSize.X
                initH = main.AbsoluteSize.Y
            end)
            resizeStartSize = Vector2.new(initW, initH)
            tween(gripIcon, 0.1, { ImageColor3 = Color3.fromRGB(0, 132, 255), ImageTransparency = 0 })

            local moveConn, endConn
            moveConn = UserInputService.InputChanged:Connect(function(moveInput)
                if not isResizing then return end
                if moveInput.UserInputType == Enum.UserInputType.MouseMovement or moveInput.UserInputType == Enum.UserInputType.Touch then
                    pcall(function()
                        local delta = Vector2.new(moveInput.Position.X, moveInput.Position.Y) - resizeStartMouse
                        local curCam = workspace.CurrentCamera
                        local curVp = Vector2.new(1920, 1080)
                        pcall(function()
                            if curCam and curCam.ViewportSize.X > 0 then
                                curVp = curCam.ViewportSize
                            end
                        end)
                        local minW = 450
                        local minH = 320
                        local maxW = math.max(curVp.X - 20, 600)
                        local maxH = math.max(curVp.Y - 20, 400)
                        local newW = math.clamp(math.floor(resizeStartSize.X + delta.X), minW, maxW)
                        local newH = math.clamp(math.floor(resizeStartSize.Y + delta.Y), minH, maxH)
                        main.Size = UDim2.fromOffset(newW, newH)
                        w.Size = main.Size
                    end)
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
    if cam and gui then
        pcall(function()
            cam:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                pcall(function()
                    if not gui or not gui.Parent or not main or not main.Parent then return end
                    local newVp = cam.ViewportSize
                    local mainW, mainH = 680, 440
                    pcall(function()
                        mainW = main.AbsoluteSize.X
                        mainH = main.AbsoluteSize.Y
                    end)
                    if isMobile and (mainW > newVp.X - 20 or mainH > newVp.Y - 20) then
                        local nw = math.clamp(mainW, 420, math.max(newVp.X - 24, 420))
                        local nh = math.clamp(mainH, 300, math.max(newVp.Y - 24, 300))
                        main.Size = UDim2.fromOffset(nw, nh)
                        w.Size = main.Size
                    end
                end)
            end)
        end)
    end

    local bar = Instance.new("Frame")
    bar.Name = "Topbar"
    bar.BackgroundTransparency = 1
    bar.Size = UDim2.new(1, 0, 0, isMobile and 50 or 58)
    bar.ZIndex = 3
    bar.Parent = main
    drag(bar, main)

    -- Topbar Logo Image (dj's exact logo image)
    local logoImg = Instance.new("ImageLabel")
    logoImg.Name = "TopbarLogo"
    local logoDim = isMobile and 30 or 36
    logoImg.Size = UDim2.fromOffset(logoDim, logoDim)
    logoImg.Position = UDim2.fromOffset(isMobile and 12 or 18, isMobile and 10 or 11)
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

    local titleX = isMobile and 48 or 62
    local rightReserved = isMobile and -205 or -340

    local titleContainer = Instance.new("Frame")
    titleContainer.Name = "TitleContainer"
    titleContainer.BackgroundTransparency = 1
    titleContainer.Size = UDim2.new(1, rightReserved, 0, isMobile and 18 or 20)
    titleContainer.Position = UDim2.fromOffset(titleX, (w.SubTitle and w.SubTitle ~= "") and (isMobile and 8 or 10) or (isMobile and 15 or 19))
    titleContainer.ClipsDescendants = false
    titleContainer.ZIndex = 5
    titleContainer.Parent = bar

    local titleLayout = Instance.new("UIListLayout")
    titleLayout.FillDirection = Enum.FillDirection.Horizontal
    titleLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    titleLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    titleLayout.SortOrder = Enum.SortOrder.LayoutOrder
    titleLayout.Padding = UDim.new(0, 12)
    titleLayout.Parent = titleContainer

    local title = Instance.new("TextLabel")
    title.Name = "TitleLabel"
    title.Text = w.Title
    title.Font = Enum.Font.GothamBold
    title.TextSize = isMobile and 14 or 16
    title.TextColor3 = Color3.fromRGB(245, 248, 255)
    title.BackgroundTransparency = 1
    title.AutomaticSize = Enum.AutomaticSize.X
    title.Size = UDim2.new(0, 0, 1, 0)
    title.TextTruncate = Enum.TextTruncate.AtEnd
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.LayoutOrder = 1
    title.ZIndex = 5
    title.Parent = titleContainer


    local sub = text(bar, w.SubTitle or "", isMobile and 10 or 11, self.CurrentTheme.SubText)
    sub.TextTruncate = Enum.TextTruncate.AtEnd
    if w.SubTitle and w.SubTitle ~= "" then
        sub.Position = UDim2.fromOffset(titleX + 1, isMobile and 28 or 31)
        sub.Size = UDim2.new(1, rightReserved, 0, isMobile and 14 or 16)
        sub.Visible = true
    else
        sub.Visible = false
    end

    -- Top-Right Controls: Search Box, Minimize [-], Close [X]
    local sfWidth = isMobile and 110 or 150
    local sfHeight = isMobile and 26 or 30
    local sfY = isMobile and 12 or 14

    local searchFrame = Instance.new("Frame")
    searchFrame.Name = "SearchFrame"
    searchFrame.BackgroundColor3 = self.CurrentTheme.Surface
    searchFrame.Size = UDim2.fromOffset(sfWidth, sfHeight)
    searchFrame.Position = UDim2.new(1, isMobile and -175 or -240, 0, sfY)
    searchFrame.ZIndex = 5
    searchFrame.Parent = bar
    corner(searchFrame, 8)
    stroke(searchFrame, self.CurrentTheme.Border, 0.3)

    local searchIcon = Instance.new("ImageLabel")
    searchIcon.Name = "SearchIcon"
    searchIcon.Size = UDim2.fromOffset(isMobile and 12 or 14, isMobile and 12 or 14)
    searchIcon.Position = UDim2.new(0, isMobile and 7 or 9, 0.5, isMobile and -6 or -7)
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
    search.TextSize = isMobile and 10 or 11
    search.Font = Enum.Font.GothamBold
    search.BackgroundTransparency = 1
    search.Size = UDim2.new(1, isMobile and -24 or -30, 1, 0)
    search.Position = UDim2.fromOffset(isMobile and 23 or 28, 0)
    search.ZIndex = 6
    search.Parent = searchFrame
    w.SearchBox = search

    local function createIconButton(iconAsset, xOffset, callback)
        local btnDim = isMobile and 26 or 30
        local b = Instance.new("TextButton")
        b.Text = ""
        b.AutoButtonColor = false
        b.BackgroundColor3 = self.CurrentTheme.Surface
        b.Size = UDim2.fromOffset(btnDim, btnDim)
        b.Position = UDim2.new(1, xOffset, 0, sfY)
        b.ZIndex = 5
        b.Parent = bar
        corner(b, 7)
        stroke(b, self.CurrentTheme.Border, 0.3)

        local icon = Instance.new("ImageLabel")
        icon.Size = UDim2.fromOffset(isMobile and 13 or 15, isMobile and 13 or 15)
        icon.AnchorPoint = Vector2.new(0.5, 0.5)
        icon.Position = UDim2.fromScale(0.5, 0.5)
        icon.BackgroundTransparency = 1
        icon.Image = iconAsset
        icon.ImageColor3 = Color3.fromRGB(245, 248, 255)
        icon.ZIndex = 6
        icon.Active = false
        icon.Parent = b

        b.MouseEnter:Connect(function()
            pcall(function()
                tween(b, 0.1, { BackgroundColor3 = Fluent.CurrentTheme.Hover })
                tween(icon, 0.1, { ImageColor3 = Fluent.CurrentTheme.Accent })
            end)
        end)
        b.MouseLeave:Connect(function()
            pcall(function()
                tween(b, 0.1, { BackgroundColor3 = Fluent.CurrentTheme.Surface })
                tween(icon, 0.1, { ImageColor3 = Color3.fromRGB(245, 248, 255) })
            end)
        end)
        b.MouseButton1Click:Connect(callback)
        return b, icon
    end

    local body = Instance.new("Frame")
    body.Name = "Body"
    body.BackgroundTransparency = 1
    body.Position = UDim2.fromOffset(isMobile and 10 or 14, isMobile and 56 or 66)
    body.Size = UDim2.new(1, isMobile and -20 or -28, 1, isMobile and -66 or -78)
    body.ZIndex = 2
    body.Parent = main

    local minimized = false
    local minBtn, minIcon
    minBtn, minIcon = createIconButton("rbxassetid://10734896206", isMobile and -60 or -82, function()
        w:Minimize()
    end)
    local closeBtn = createIconButton("rbxassetid://10747384394", isMobile and -30 or -44, function() w:Destroy() end)

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
    sidebar.BackgroundTransparency = 1
    sidebar.BorderSizePixel = 0
    sidebar.Size = UDim2.new(1, 0, 1, isMobile and -86 or -98)
    sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
    sidebar.AutomaticCanvasSize = Enum.AutomaticSize.None
    sidebar.ScrollingDirection = Enum.ScrollingDirection.Y
    sidebar.ScrollBarThickness = 3
    sidebar.ScrollBarImageTransparency = 0.5
    sidebar.ElasticBehavior = Enum.ElasticBehavior.Always
    sidebar.ZIndex = 3
    sidebar.Parent = sidebarContainer
    pad(sidebar, isMobile and 2 or 4, isMobile and 6 or 8, isMobile and 8 or 12, 0)

    -- Thin divider between menu and content instead of a boxed sidebar.
    local sideDivider = Instance.new("Frame")
    sideDivider.Name = "SidebarDivider"
    sideDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    sideDivider.BackgroundTransparency = 0.92
    sideDivider.BorderSizePixel = 0
    sideDivider.AnchorPoint = Vector2.new(1, 0)
    sideDivider.Position = UDim2.new(1, 5, 0, 2)
    sideDivider.Size = UDim2.new(0, 1, 1, -4)
    sideDivider.ZIndex = 3
    sideDivider.Parent = sidebarContainer

    local sl = Instance.new("UIListLayout")
    sl.Padding = UDim.new(0, 2)
    sl.SortOrder = Enum.SortOrder.LayoutOrder
    sl.Parent = sidebar

    local function updateSidebarCanvas()
        pcall(function()
            sidebar.CanvasSize = UDim2.new(0, 0, 0, sl.AbsoluteContentSize.Y + 14)
        end)
    end
    pcall(function()
        sl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateSidebarCanvas)
    end)

    local function getTabSortKey(str)
        local s = string.lower(tostring(str or ""))
        local alpha = string.match(s, "%w.*")
        return alpha or s
    end

    local function sortSidebarTabs()
        if w._sortTabs == false then return end
        local normalTabs = {}
        for _, tab in ipairs(w._tabs) do
            if not tab.IsBottomTab and tab.Button and tab.Button.Parent == sidebar then
                table.insert(normalTabs, tab)
            end
        end
        table.sort(normalTabs, function(a, b)
            local ordA = a.Order or (type(a._config) == "table" and (a._config.Order or a._config.LayoutOrder))
            local ordB = b.Order or (type(b._config) == "table" and (b._config.Order or b._config.LayoutOrder))
            if ordA and ordB then
                if ordA ~= ordB then return ordA < ordB end
            elseif ordA then
                return true
            elseif ordB then
                return false
            end
            return getTabSortKey(a.Title) < getTabSortKey(b.Title)
        end)
        for orderIdx, tab in ipairs(normalTabs) do
            tab.Button.LayoutOrder = orderIdx
        end
    end
    w.SortTabs = sortSidebarTabs
    w.ResortTabs = sortSidebarTabs

    -- Pinned Bottom Tabs Container (Directly above Profile Card, full width)
    local bottomTabs = Instance.new("Frame")
    bottomTabs.Name = "BottomTabs"
    bottomTabs.BackgroundTransparency = 1
    bottomTabs.Size = UDim2.new(1, 0, 0, isMobile and 34 or 40)
    bottomTabs.Position = UDim2.new(0, 0, 1, isMobile and -80 or -92)
    bottomTabs.ZIndex = 4
    bottomTabs.Parent = sidebarContainer

    local btl = Instance.new("UIListLayout")
    btl.Padding = UDim.new(0, 4)
    btl.SortOrder = Enum.SortOrder.LayoutOrder
    btl.Parent = bottomTabs

    -- Bottom-Left Neverlose User Profile Card
    local profileCard = Instance.new("Frame")
    profileCard.Name = "NeverloseProfile"
    profileCard.Size = UDim2.new(1, 0, 0, isMobile and 44 or 50)
    profileCard.Position = UDim2.new(0, 0, 1, isMobile and -44 or -50)
    profileCard.BackgroundColor3 = self.CurrentTheme.Surface2
    profileCard.BackgroundTransparency = 0.55
    profileCard.ZIndex = 4
    profileCard.Parent = sidebarContainer
    corner(profileCard, 10)

    -- Avatar Headshot
    -- Avatar Headshot
    local avDim = isMobile and 28 or 36
    local avatarImg = Instance.new("ImageLabel")
    avatarImg.Name = "Avatar"
    avatarImg.Size = UDim2.fromOffset(avDim, avDim)
    avatarImg.Position = UDim2.new(0, isMobile and 6 or 7, 0.5, -avDim / 2)
    avatarImg.BackgroundColor3 = self.CurrentTheme.Surface2
    avatarImg.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    avatarImg.ZIndex = 5
    avatarImg.Parent = profileCard
    corner(avatarImg, avDim / 2)

    -- Green Online / Active Status Dot
    local statusDot = Instance.new("Frame")
    statusDot.Name = "StatusDot"
    statusDot.Size = UDim2.fromOffset(isMobile and 6 or 7, isMobile and 6 or 7)
    statusDot.Position = UDim2.new(1, -5, 1, -5)
    statusDot.BackgroundColor3 = Color3.fromRGB(0, 230, 118)
    statusDot.BorderSizePixel = 0
    statusDot.ZIndex = 6
    statusDot.Parent = avatarImg
    corner(statusDot, 4)

    local dotStroke = Instance.new("UIStroke")
    dotStroke.Thickness = 1.2
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

    local textLeft = isMobile and 38 or 48

    -- DisplayName & @Username
    local dispName = text(profileCard, LocalPlayer and LocalPlayer.DisplayName or "User", isMobile and 11 or 12, self.CurrentTheme.Text)
    dispName.Font = Enum.Font.GothamBold
    dispName.TextTruncate = Enum.TextTruncate.AtEnd
    dispName.ZIndex = 5

    local userName = text(profileCard, LocalPlayer and ("@" .. LocalPlayer.Name) or "@user", isMobile and 9 or 10, self.CurrentTheme.SubText)
    userName.Font = Enum.Font.GothamBold
    userName.TextTruncate = Enum.TextTruncate.AtEnd
    userName.ZIndex = 5

    -- Neverlose Role Tag / Device Tag (e.g. "ANDROID", "IOS", "PC")
    local rolePill = Instance.new("Frame")
    rolePill.Name = "RolePill"
    rolePill.AutomaticSize = Enum.AutomaticSize.X
    rolePill.Size = UDim2.new(0, 0, 0, isMobile and 15 or 17)
    rolePill.AnchorPoint = Vector2.new(1, 0.5)
    rolePill.Position = UDim2.new(1, isMobile and -6 or -8, 0.5, 0)
    rolePill.BackgroundColor3 = isAndroid and Color3.fromRGB(0, 200, 115) or (isIOS and Color3.fromRGB(0, 160, 255) or self.CurrentTheme.Accent)
    rolePill.BackgroundTransparency = 0.82
    rolePill.BorderSizePixel = 0
    rolePill.ZIndex = 5
    rolePill.Parent = profileCard
    corner(rolePill, 4)
    pad(rolePill, 1, isMobile and 4 or 5, 1, isMobile and 4 or 5)

    local roleStroke = Instance.new("UIStroke")
    roleStroke.Thickness = 1
    roleStroke.Color = isAndroid and Color3.fromRGB(0, 200, 115) or (isIOS and Color3.fromRGB(0, 160, 255) or self.CurrentTheme.Accent)
    roleStroke.Transparency = 0.5
    roleStroke.Parent = rolePill

    local badgeTag = string.upper(tostring(o.Device or o.Role or o.Tier or deviceName))
    local roleText = text(rolePill, badgeTag, isMobile and 8 or 9, isAndroid and Color3.fromRGB(0, 230, 120) or (isIOS and Color3.fromRGB(60, 180, 255) or self.CurrentTheme.Accent))
    roleText.AutomaticSize = Enum.AutomaticSize.X
    roleText.Size = UDim2.new(0, 0, 1, 0)
    roleText.Font = Enum.Font.GothamBold
    roleText.TextXAlignment = Enum.TextXAlignment.Center
    roleText.ZIndex = 6
    w.RolePill = rolePill
    w.RoleText = roleText

    local function updateProfileLayout()
        local isMob = Fluent.IsMobile or (w.TabWidth and w.TabWidth < 140)
        local upper = string.upper(tostring(w.Device or o.Device or o.Role or o.Tier or deviceName))

        rolePill.AnchorPoint = Vector2.new(1, 0.5)
        rolePill.Position = UDim2.new(1, isMob and -5 or -8, 0.5, 0)
        rolePill.Size = UDim2.new(0, 0, 0, isMob and 14 or 17)
        roleText.TextSize = isMob and 7.5 or 9
        rolePill.Visible = true

        local badgeW = (upper == "ANDROID" and (isMob and 40 or 52))
            or (upper == "TABLET" and (isMob and 38 or 46))
            or (upper == "IOS" and (isMob and 22 or 30))
            or (isMob and 20 or 28)
        local rightMargin = badgeW + (isMob and 7 or 10)

        dispName.Position = UDim2.new(0, textLeft, 0, isMob and 6 or 8)
        dispName.Size = UDim2.new(1, -(textLeft + rightMargin), 0, isMob and 14 or 16)
        dispName.TextSize = isMob and 11 or 12

        userName.Position = UDim2.new(0, textLeft, 0, isMob and 20 or 24)
        userName.Size = UDim2.new(1, -(textLeft + rightMargin), 0, isMob and 12 or 14)
        userName.TextSize = isMob and 9 or 10
        userName.Visible = true
    end
    pcall(updateProfileLayout)

    -- Pages Area (leaves space for balanced bottom footer)
    local footerH = isMobile and 22 or 24
    local pages = Instance.new("Frame")
    pages.Name = "Pages"
    pages.BackgroundTransparency = 1
    pages.Position = UDim2.fromOffset(w.TabWidth + 10, 0)
    pages.Size = UDim2.new(1, -w.TabWidth - 10, 1, -footerH - 4)
    pages.ZIndex = 2
    pages.Parent = body
    w.Sidebar = sidebar
    w.Pages = pages

    -- Seamless Bottom Footer Bar (Flat, integrated directly on UI background, no box/tab/nest)
    local footerBar = Instance.new("Frame")
    footerBar.Name = "BottomFooterBar"
    footerBar.BackgroundTransparency = 1
    footerBar.BorderSizePixel = 0
    footerBar.Position = UDim2.new(0, w.TabWidth + 10, 1, -footerH)
    footerBar.Size = UDim2.new(1, -w.TabWidth - 10, 0, footerH)
    footerBar.ZIndex = 4
    footerBar.Parent = body
    w.FooterBar = footerBar

    -- Left Telemetry
    local isMob = Fluent.IsMobile or (w.TabWidth and w.TabWidth < 140)
    local statsLabel = Instance.new("TextLabel")
    statsLabel.Name = "TelemetryStats"
    statsLabel.Font = Enum.Font.GothamMedium
    statsLabel.TextSize = isMob and 9.5 or 11
    statsLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
    statsLabel.BackgroundTransparency = 1
    statsLabel.BorderSizePixel = 0
    statsLabel.Position = UDim2.new(0, 4, 0, 0)
    statsLabel.Size = UDim2.new(1, isMob and -85 or -195, 1, 0)
    statsLabel.TextXAlignment = Enum.TextXAlignment.Left
    statsLabel.TextYAlignment = Enum.TextYAlignment.Center
    statsLabel.TextTruncate = Enum.TextTruncate.AtEnd
    statsLabel.RichText = true
    statsLabel.ZIndex = 4
    statsLabel.Parent = footerBar

    -- Right Filler Info (Clock & Framework Build Tag - Anchored from right edge)
    local rightInfoLabel = Instance.new("TextLabel")
    rightInfoLabel.Name = "FooterRightInfo"
    rightInfoLabel.Font = Enum.Font.GothamMedium
    rightInfoLabel.TextSize = isMob and 9.5 or 11
    rightInfoLabel.TextColor3 = Color3.fromRGB(148, 163, 184)
    rightInfoLabel.BackgroundTransparency = 1
    rightInfoLabel.BorderSizePixel = 0
    rightInfoLabel.AnchorPoint = Vector2.new(1, 0)
    rightInfoLabel.Position = UDim2.new(1, -6, 0, 0)
    rightInfoLabel.Size = UDim2.new(0, isMob and 75 or 185, 1, 0)
    rightInfoLabel.TextXAlignment = Enum.TextXAlignment.Right
    rightInfoLabel.TextYAlignment = Enum.TextYAlignment.Center
    rightInfoLabel.RichText = true
    rightInfoLabel.ZIndex = 4
    rightInfoLabel.Parent = footerBar
    w.StatsLabel = statsLabel
    w.RightInfoLabel = rightInfoLabel

    -- Server Key Validation & Tier Type Resolver
    local keyType = "Freemium"
    if o.Type or o.Tier then
        keyType = tostring(o.Type or o.Tier)
    elseif g.LiyHubIsPremium or (g.LiyHubTier and string.lower(tostring(g.LiyHubTier)) == "premium") then
        keyType = "Premium"
    elseif g.LiyHubTier then
        keyType = tostring(g.LiyHubTier)
    end
    keyType = keyType:sub(1,1):upper() .. keyType:sub(2):lower()

    local execName = resolveExecutorName()
    local curFps = 60
    local curPing = 0
    local frameCount = 0
    local lastStatsTime = os.clock()

    local function updateStatsText()
        pcall(function()
            local winW = 680
            pcall(function()
                if main and main.AbsoluteSize and main.AbsoluteSize.X > 0 then
                    winW = main.AbsoluteSize.X
                elseif w.Size and w.Size.X then
                    winW = w.Size.X.Offset
                end
            end)
            local pingColor = curPing < 80 and "#4ade80" or (curPing < 160 and "#facc15" or "#f87171")
            local fpsColor = curFps >= 45 and "#38bdf8" or (curFps >= 25 and "#facc15" or "#f87171")
            local footerBrand = tostring(o.FooterTag or o.Brand or "Liyhub Client")

            if winW < 430 then
                -- 1. Ultra-Compact / Small Phone (< 430px)
                statsLabel.TextSize = 8.5
                rightInfoLabel.TextSize = 8.5
                statsLabel.Size = UDim2.new(1, -55, 1, 0)
                rightInfoLabel.Size = UDim2.new(0, 50, 1, 0)
                statsLabel.Text = string.format(
                    "<font color=\"#ffffff\"><b>%s</b></font> <font color=\"#475569\">|</font> <font color=\"%s\">%dms</font> <font color=\"#475569\">|</font> <font color=\"%s\">%dFPS</font>",
                    keyType, pingColor, curPing, fpsColor, curFps
                )
                rightInfoLabel.Text = string.format(
                    "<font color=\"#ffffff\"><b>%s</b></font>",
                    os.date("%I:%M %p")
                )
            elseif winW < 490 then
                -- 2. Mobile Phone (430 - 489px: Android / iOS Standard)
                statsLabel.TextSize = 9
                rightInfoLabel.TextSize = 9
                statsLabel.Size = UDim2.new(1, -75, 1, 0)
                rightInfoLabel.Size = UDim2.new(0, 68, 1, 0)
                statsLabel.Text = string.format(
                    "<font color=\"#ffffff\"><b>%s</b></font> <font color=\"#475569\">|</font> <font color=\"%s\">%dms</font> <font color=\"#475569\">|</font> <font color=\"%s\">%d FPS</font>",
                    keyType, pingColor, curPing, fpsColor, curFps
                )
                rightInfoLabel.Text = string.format(
                    "<font color=\"#ffffff\"><b>%s</b></font>",
                    os.date("%I:%M %p")
                )
            elseif winW < 570 then
                -- 3. Compact / Mini (490 - 569px)
                statsLabel.TextSize = 9.5
                rightInfoLabel.TextSize = 9.5
                statsLabel.Size = UDim2.new(1, -100, 1, 0)
                rightInfoLabel.Size = UDim2.new(0, 92, 1, 0)
                statsLabel.Text = string.format(
                    "<font color=\"#ffffff\"><b>%s</b></font> <font color=\"#475569\">|</font> <font color=\"#ffffff\"><b>%s</b></font> <font color=\"#475569\">|</font> <font color=\"%s\">%dms</font> <font color=\"#475569\">|</font> <font color=\"%s\">%d FPS</font>",
                    keyType, execName, pingColor, curPing, fpsColor, curFps
                )
                rightInfoLabel.Text = string.format(
                    "<font color=\"#64748b\">Liyhub</font> <font color=\"#475569\">|</font> <font color=\"#ffffff\"><b>%s</b></font>",
                    os.date("%I:%M %p")
                )
            elseif winW < 670 then
                -- 4. Tablet / Medium (570 - 669px)
                statsLabel.TextSize = 10
                rightInfoLabel.TextSize = 10
                statsLabel.Size = UDim2.new(1, -145, 1, 0)
                rightInfoLabel.Size = UDim2.new(0, 135, 1, 0)
                statsLabel.Text = string.format(
                    "Type: <font color=\"#ffffff\"><b>%s</b></font> <font color=\"#475569\">|</font> <font color=\"#ffffff\"><b>%s</b></font> <font color=\"#475569\">|</font> <font color=\"%s\">%dms</font> <font color=\"#475569\">|</font> <font color=\"%s\">%d FPS</font>",
                    keyType, execName, pingColor, curPing, fpsColor, curFps
                )
                rightInfoLabel.Text = string.format(
                    "<font color=\"#64748b\">%s</font> <font color=\"#475569\">|</font> <font color=\"#ffffff\"><b>%s</b></font>",
                    footerBrand, os.date("%I:%M %p")
                )
            else
                -- 5. PC / Standard (>= 670px)
                statsLabel.TextSize = 11
                rightInfoLabel.TextSize = 11
                statsLabel.Size = UDim2.new(1, -195, 1, 0)
                rightInfoLabel.Size = UDim2.new(0, 185, 1, 0)
                statsLabel.Text = string.format(
                    "Type: <font color=\"#ffffff\"><b>%s</b></font>   <font color=\"#475569\">|</font>   <font color=\"#ffffff\"><b>%s</b></font>   <font color=\"#475569\">|</font>   <font color=\"%s\">%dms</font>   <font color=\"#475569\">|</font>   <font color=\"%s\">%d FPS</font>",
                    keyType, execName, pingColor, curPing, fpsColor, curFps
                )
                rightInfoLabel.Text = string.format(
                    "<font color=\"#64748b\">%s</font>   <font color=\"#475569\">|</font>   <font color=\"#ffffff\"><b>%s</b></font>",
                    footerBrand, os.date("%I:%M:%S %p")
                )
            end
        end)
    end
    pcall(updateStatsText)
    w.UpdateStatsText = updateStatsText

    if main then
        pcall(function()
            main:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
                pcall(updateStatsText)
            end)
        end)
    end

    local statsRunning = true
    task.spawn(function()
        while statsRunning do
            task.wait(0.8)
            if not statsRunning then break end

            pcall(function()
                local wsFps = nil
                pcall(function()
                    if workspace and workspace.GetRealPhysicsFPS then
                        wsFps = math.floor(workspace:GetRealPhysicsFPS())
                    end
                end)
                if wsFps and wsFps > 0 then
                    curFps = wsFps
                end

                local stats = game:GetService("Stats")
                local net = stats and stats:FindFirstChild("Network")
                local ssi = net and net:FindFirstChild("ServerStatsItem")
                local dataPing = ssi and ssi:FindFirstChild("Data Ping")
                if dataPing then
                    curPing = math.floor(dataPing:GetValue())
                else
                    local perf = stats and stats:FindFirstChild("PerformanceStats")
                    local pingItem = perf and perf:FindFirstChild("Ping")
                    if pingItem then
                        curPing = math.floor(pingItem:GetValue())
                    end
                end
            end)

            pcall(updateStatsText)
        end
    end)

    pcall(function()
        gui.Destroying:Connect(function()
            statsRunning = false
        end)
    end)

    function w:SelectTab(i)
        local t
        if type(i) == "number" then
            for _, tab in ipairs(self._tabs) do
                if not tab.IsBottomTab and tab.Button and tab.Button.LayoutOrder == i then
                    t = tab
                    break
                end
            end
            if not t then t = self._tabs[i] end
        elseif type(i) == "string" then
            t = self.Tabs[i] or self.Tabs[i:gsub("%W", "")]
        end
        if t then t:Select() end
        return t
    end

    function w:SetDevice(dev)
        if not dev then return end
        self.Device = tostring(dev)
        local upper = string.upper(tostring(dev))
        if roleText then
            roleText.Text = upper
            local c = (upper == "ANDROID" and Color3.fromRGB(0, 230, 120)) or (upper == "IOS" and Color3.fromRGB(60, 180, 255)) or Fluent.CurrentTheme.Accent
            roleText.TextColor3 = c
            if roleStroke then roleStroke.Color = c end
            if rolePill then rolePill.BackgroundColor3 = c end
        end
        pcall(updateProfileLayout)
    end

    -- Android Floating Pin Tab Widget (Always on Top of Game UIs)
    local pillDim = isMobile and 38 or 42
    local floatingPill = Instance.new("TextButton")
    floatingPill.Name = "LiyhubAndroidPinTab"
    floatingPill.Text = ""
    floatingPill.AutoButtonColor = false
    floatingPill.Size = UDim2.fromOffset(pillDim, pillDim)
    floatingPill.Position = UDim2.new(0, 16, 0.5, -pillDim / 2)
    floatingPill.BackgroundColor3 = self.CurrentTheme.Surface
    floatingPill.BackgroundTransparency = 0.05
    floatingPill.ClipsDescendants = true
    floatingPill.Visible = false
    floatingPill.ZIndex = 999999
    floatingPill.Parent = gui
    corner(floatingPill, 10)
    local pillStroke = stroke(floatingPill, Color3.fromRGB(255, 255, 255), 0.7)
    pillStroke.Thickness = 1
    pillStroke.ZIndex = 999999
    drag(floatingPill, floatingPill)

    local pillLogo = Instance.new("ImageLabel")
    pillLogo.Name = "LogoImage"
    pillLogo.Size = UDim2.fromScale(1, 1)
    pillLogo.Position = UDim2.fromScale(0, 0)
    pillLogo.AnchorPoint = Vector2.new(0, 0)
    pillLogo.BackgroundTransparency = 1
    pillLogo.Image = resolveLogoAsset()
    pillLogo.ScaleType = Enum.ScaleType.Fit
    pillLogo.ZIndex = 1000000
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

    local wasDragged = false
    local pillStartPos = nil
    floatingPill.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            wasDragged = false
            pillStartPos = input.Position
        end
    end)
    floatingPill.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and pillStartPos then
            if (input.Position - pillStartPos).Magnitude > 8 then
                wasDragged = true
            end
        end
    end)

    local lastPinClick = 0
    local function handlePinClick()
        local now = os.clock()
        if now - lastPinClick < 0.15 then return end
        lastPinClick = now
        if wasDragged then
            wasDragged = false
            return
        end
        w:Open()
    end
    floatingPill.MouseButton1Click:Connect(handlePinClick)
    pcall(function()
        floatingPill.Activated:Connect(handlePinClick)
    end)
    w.FloatingPill = floatingPill
    w.AndroidPinTab = floatingPill

    function w:Destroy()
        statsRunning = false
        Fluent:Unload()
        if self.Gui then self.Gui:Destroy() end
    end
    w.OnUnload = function(_, fn) Fluent:OnUnload(fn) end
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
        local pLower = string.lower(tostring(preset or ""))
        if pLower == "android" or pLower == "ios" or pLower == "mobile" or pLower == "phone" then
            targetSize = UDim2.fromOffset(math.clamp(math.floor(vp.X * 0.72), 440, 510), math.clamp(math.floor(vp.Y * 0.78), 280, 325))
            targetTabW = 125
            if pLower == "android" then
                w:SetDevice("Android")
            elseif pLower == "ios" then
                w:SetDevice("iOS")
            else
                w:SetDevice("Mobile")
            end
        elseif pLower == "tablet" or pLower == "ipad" then
            targetSize = UDim2.fromOffset(math.clamp(math.floor(vp.X * 0.80), 540, 640), math.clamp(math.floor(vp.Y * 0.80), 360, 440))
            targetTabW = 145
            w:SetDevice("Tablet")
        elseif pLower == "compact" or pLower == "mini" then
            targetSize = UDim2.fromOffset(450, 280)
            targetTabW = 120
            w:SetDevice("Compact")
        else
            -- PC / Standard
            targetSize = UDim2.fromOffset(680, 520)
            targetTabW = 150
            w:SetDevice("PC")
        end

        w.Size = targetSize
        w.TabWidth = targetTabW
        tween(main, 0.2, { Size = targetSize })
        if sidebarContainer then
            tween(sidebarContainer, 0.2, { Size = UDim2.new(0, targetTabW, 1, 0) })
        end
        local fH = (isMobile or (targetTabW < 140)) and 22 or 24
        local isM = (targetTabW < 140) or (targetSize.X.Offset < 540)
        if pages then
            tween(pages, 0.2, { Position = UDim2.fromOffset(targetTabW + 10, 0), Size = UDim2.new(1, -targetTabW - 10, 1, -fH - 4) })
        end
        if footerBar then
            footerBar.Position = UDim2.new(0, targetTabW + 10, 1, -fH)
            footerBar.Size = UDim2.new(1, -targetTabW - 10, 0, fH)
        end
        pcall(updateProfileLayout)
        pcall(updateStatsText)
        task.delay(0.22, function()
            pcall(updateStatsText)
        end)
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

        local isBottomTab = (type(to) == "table" and to.PinnedBottom)
            or string.find(string.lower(titleText), "ui setting")
            or string.find(string.lower(titleText), "setting")
            or string.lower(titleText) == "config"

        local t = {
            Window = self,
            Title = titleText,
            Icon = iconAsset,
            Elements = {},
            IsBottomTab = isBottomTab,
            _config = (type(to) == "table" and to) or {},
            Order = type(to) == "table" and (to.Order or to.LayoutOrder)
        }

        local tb = Instance.new("TextButton")
        tb.Name = "Tab_" .. titleText
        tb.AutoButtonColor = false
        tb.Text = ""
        tb.BackgroundColor3 = Fluent.CurrentTheme.Hover
        tb.BackgroundTransparency = 1
        tb.Size = UDim2.new(1, -6, 0, isMobile and 32 or 36)
        tb.ZIndex = 4
        tb.LayoutOrder = isBottomTab and 1 or (#self._tabs + 1)
        tb.Parent = isBottomTab and bottomTabs or sidebar
        corner(tb, 8)

        local accent = Instance.new("Frame")
        accent.BackgroundColor3 = Fluent.CurrentTheme.Accent
        accent.BackgroundTransparency = 1
        accent.Size = UDim2.fromOffset(3, isMobile and 16 or 20)
        accent.AnchorPoint = Vector2.new(0, 0.5)
        accent.Position = UDim2.new(0, 2, 0.5, 0)
        accent.ZIndex = 5
        accent.Parent = tb
        corner(accent, 2)

        local iconType, iconVal = resolveIcon(t.Icon)
        local iconElement = nil
        local iconDim = isMobile and 14 or 16

        if iconType == "image" then
            local img = Instance.new("ImageLabel")
            img.Name = "TabIcon"
            img.Size = UDim2.fromOffset(iconDim, iconDim)
            img.Position = UDim2.new(0, isMobile and 10 or 14, 0.5, -iconDim / 2)
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
            em.Size = UDim2.fromOffset(isMobile and 16 or 18, isMobile and 16 or 18)
            em.Position = UDim2.new(0, isMobile and 10 or 13, 0.5, isMobile and -8 or -9)
            em.BackgroundTransparency = 1
            em.Text = iconVal
            em.TextSize = isMobile and 12 or 14
            em.TextColor3 = Fluent.CurrentTheme.Text
            em.Font = Enum.Font.GothamMedium
            em.ZIndex = 5
            em.Parent = tb
            iconElement = em
        end

        local textOffset = (iconType ~= nil) and (isMobile and 30 or 36) or 12
        local label = text(tb, t.Title, isMobile and 11 or 12, Fluent.CurrentTheme.SubText)
        label.Position = UDim2.fromOffset(textOffset, 0)
        label.Size = UDim2.new(1, -textOffset - 8, 1, 0)
        label.ZIndex = 5
        label.Font = Enum.Font.GothamBold
        label.TextTruncate = Enum.TextTruncate.AtEnd

        local page = Instance.new("ScrollingFrame")
        page.Name = "Tab_" .. t.Title
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.Size = UDim2.fromScale(1, 1)
        page.CanvasSize = UDim2.new(0, 0, 0, 0)
        page.AutomaticCanvasSize = Enum.AutomaticSize.None
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ScrollBarThickness = 4
        page.ScrollBarImageTransparency = 0.4
        page.ElasticBehavior = Enum.ElasticBehavior.Always
        page.Visible = false
        page.ZIndex = 2
        page.Parent = pages
        pad(page, 4, 6, 28, 4)

        -- Page holds two columns side by side; the row height is the taller column.
        local pl = Instance.new("UIListLayout")
        pl.FillDirection = Enum.FillDirection.Horizontal
        pl.Padding = UDim.new(0, 8)
        pl.SortOrder = Enum.SortOrder.LayoutOrder
        pl.Parent = page
        local cols = {}
        for i = 1, 2 do
            local c = Instance.new("Frame")
            c.Name = i == 1 and "ColumnLeft" or "ColumnRight"
            c.BackgroundTransparency = 1
            c.AutomaticSize = Enum.AutomaticSize.Y
            c.Size = UDim2.new(1, 0, 0, 0)
            c.LayoutOrder = i
            c.Visible = i == 1
            c.ZIndex = 2
            c.Parent = page
            local cl = Instance.new("UIListLayout")
            cl.Padding = UDim.new(0, 8)
            cl.SortOrder = Enum.SortOrder.LayoutOrder
            cl.Parent = c
            cols[i] = c
        end
        t.Columns = cols
        t._holders = {}
        t.Page = page
        t.Button = tb
        t.Accent = accent
        t.Label = label
        t.IconElement = iconElement
        -- Register only once the button and page exist, so Select never sees a half-built tab.
        table.insert(self._tabs, t)
        self.Tabs[(t.Title:gsub("%W", ""))] = t
        sortSidebarTabs()

        local function updatePageCanvas()
            pcall(function()
                page.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 36)
            end)
        end
        pcall(function()
            pl:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updatePageCanvas)
        end)

        -- Two columns when the page is wide enough (PC), one column on phones or narrow windows.
        local win = self
        local colMode = 0
        local function relayout()
            local pw = page.AbsoluteSize.X
            local minW = (win.Columns == 2) and 400 or 560
            local want = (win.Columns ~= 1 and pw >= minW) and 2 or 1
            for _, h in ipairs(t._holders) do
                local target = (want == 2 and h:GetAttribute("Side") == "Right") and cols[2] or cols[1]
                if h.Parent ~= target then h.Parent = target end
            end
            if want ~= colMode then
                colMode = want
                cols[2].Visible = want == 2
                cols[1].Size = want == 2 and UDim2.new(0.5, -4, 0, 0) or UDim2.new(1, 0, 0, 0)
                cols[2].Size = UDim2.new(0.5, -4, 0, 0)
            end
            updatePageCanvas()
        end
        pcall(function()
            page:GetPropertyChangedSignal("AbsoluteSize"):Connect(function() task.defer(relayout) end)
        end)

        function t:_placeSection(holder, side)
            local sd = side and string.lower(tostring(side)) or nil
            if sd == "right" or sd == "r" or sd == "2" then
                sd = "Right"
            elseif sd == "left" or sd == "l" or sd == "1" then
                sd = "Left"
            else
                sd = (#self._holders % 2 == 0) and "Left" or "Right"
            end
            holder:SetAttribute("Side", sd)
            table.insert(self._holders, holder)
            -- Global order keeps the original sequence when collapsed to one column.
            holder.LayoutOrder = #self._holders
            holder.Parent = cols[1]
            relayout()
        end

        tb.MouseEnter:Connect(function()
            if self.ActiveTab ~= t then
                tween(tb, 0.12, { BackgroundTransparency = 0.55, BackgroundColor3 = Fluent.CurrentTheme.Hover })
                tween(label, 0.12, { TextColor3 = Fluent.CurrentTheme.Text })
                if iconElement and iconElement:IsA("ImageLabel") then
                    tween(iconElement, 0.1, { ImageColor3 = Fluent.CurrentTheme.Text })
                end
            end
        end)
        tb.MouseLeave:Connect(function()
            if self.ActiveTab ~= t then
                tween(tb, 0.12, { BackgroundTransparency = 1 })
                tween(label, 0.12, { TextColor3 = Fluent.CurrentTheme.SubText })
                if iconElement and iconElement:IsA("ImageLabel") then
                    tween(iconElement, 0.1, { ImageColor3 = Fluent.CurrentTheme.SubText })
                end
            end
        end)
        tb.MouseButton1Click:Connect(function()
            t:Select()
        end)

        function t:Select()
            -- Each tab is reset in its own pcall so one destroyed or foreign tab can't break selection.
            for _, x in ipairs(self.Window._tabs) do
                if type(x) == "table" and x ~= self then
                    for _, el in ipairs(x.Elements or {}) do
                        if type(el) == "table" and type(el.Close) == "function" then
                            pcall(el.Close)
                        end
                    end
                    pcall(function()
                        if x.Page then x.Page.Visible = false end
                        if x.Button then
                            x.Button.BackgroundColor3 = Fluent.CurrentTheme.Hover
                            x.Button.BackgroundTransparency = 1
                        end
                        if x.Accent then x.Accent.BackgroundTransparency = 1 end
                        if x.Label then x.Label.TextColor3 = Fluent.CurrentTheme.SubText end
                        if x.IconElement and x.IconElement:IsA("ImageLabel") then
                            x.IconElement.ImageColor3 = Fluent.CurrentTheme.SubText
                        end
                    end)
                end
            end
            for _, el in ipairs(self.Elements or {}) do
                if type(el) == "table" and type(el.Close) == "function" then
                    pcall(el.Close)
                end
            end
            if not self.Page or not self.Page.Parent then return end
            self.Page.Visible = true
            self.Button.BackgroundColor3 = Fluent.CurrentTheme.Accent
            self.Button.BackgroundTransparency = 0.86
            self.Accent.BackgroundTransparency = 0
            self.Label.TextColor3 = Fluent.CurrentTheme.Text
            if self.IconElement and self.IconElement:IsA("ImageLabel") then
                self.IconElement.ImageColor3 = Fluent.CurrentTheme.Accent
            end
            self.Window.ActiveTab = self
            for _, el in ipairs(self.Elements or {}) do
                if type(el) == "table" and type(el.Resize) == "function" then
                    pcall(el.Resize)
                end
            end
            if (string.lower(self.Title) == "settings" or string.lower(self.Title) == "ui setting") then
                local activeProf = self.Window.ActiveConfigProfile or Fluent.ActiveConfigProfile
                if activeProf and activeProf ~= "" then
                    if type(self.Window._profileInput) == "table" and type(self.Window._profileInput.SetValue) == "function" then
                        pcall(function() self.Window._profileInput:SetValue(activeProf, false) end)
                    end
                    if type(self.Window._profileDropdown) == "table" and type(self.Window._profileDropdown.SetValue) == "function" then
                        pcall(function() self.Window._profileDropdown:SetValue(activeProf, false) end)
                    end
                end
            end
        end

        function t:AddSection(secNameOrCfg, iconOptional, sideOptional)
            local s = addSection(self, secNameOrCfg, iconOptional, sideOptional)
            table.insert(self.Elements, s)
            return s
        end
        t.AddGroup = function(self, gopts)
            return self:AddSection(gopts)
        end

        if #self._tabs == 1 then t:Select() end
        return t
    end

    -- Real-time Search Binding (Debounced 120ms for Zero-Lag on Mobile & PC)
    if search then
        local searchThread
        pcall(function()
            search:GetPropertyChangedSignal("Text"):Connect(function()
                if searchThread then task.cancel(searchThread) end
                searchThread = task.delay(0.12, function()
                    pcall(function()
                        local q = string.lower(search.Text or "")
                        for _, t in ipairs(w._tabs or {}) do
                            for _, e in ipairs(t.Elements or {}) do
                                if e.SetSearch then e:SetSearch(q) end
                            end
                        end
                    end)
                end)
            end)
        end)
    end

    -- Hotkey Toggle Binding
    local initialKey = o.MinimizeKey or o.Keybind or o.ToggleKey
    if type(initialKey) == "string" then initialKey = Enum.KeyCode[initialKey] end
    w._toggleKey = (typeof(initialKey) == "EnumItem" and initialKey) or Enum.KeyCode.RightControl
    track(UserInputService.InputBegan:Connect(function(i, gProc)
        local toggleK = w._toggleKey or Enum.KeyCode.RightControl
        if not gProc and i.KeyCode == toggleK then
            w:Toggle()
        end
    end))

    -- Universal Script Compatibility Shims
    function w:CreateSection(secOpt)
        return self:AddTab(secOpt)
    end
    function w:AddTabLabel(label)
        -- No-op visual category shim
    end
    function w:SetToggleKey(k)
        if typeof(k) == "EnumItem" then
            self._toggleKey = k
        elseif type(k) == "string" and Enum.KeyCode[k] then
            self._toggleKey = Enum.KeyCode[k]
        end
    end

    -- Universal Window Method Aliases
    w.CreateTab = function(self, ...) return self:AddTab(...) end
    w.Tab = function(self, ...) return self:AddTab(...) end
    w.AddSection = function(self, ...) return self:AddTab(...) end
    w.Section = function(self, ...) return self:AddTab(...) end
    w.Group = function(self, ...) return self:AddTab(...) end
    w.AddGroup = function(self, ...) return self:AddTab(...) end
    w.CreateNotification = function(self, ...) return Fluent:CreateNotification(...) end
    w.Notification = function(self, ...) return Fluent:Notify(...) end

    local winMT = {
        __index = function(tbl, key)
            if type(key) ~= "string" then return rawget(tbl, key) end
            if string.sub(key, 1, 1) == "_" or key == "ActiveTab" or key == "ActiveConfigProfile" or key == "CurrentProfile" or key == "Tabs" then
                return rawget(tbl, key)
            end
            local lk = string.lower(key)
            if lk == "createtab" or lk == "tab" or lk == "newtab" or lk == "addtab" then
                return function(self, ...) return self:AddTab(...) end
            elseif lk == "createsection" or lk == "section" or lk == "addsection" or lk == "group" or lk == "addgroup" then
                return function(self, ...) return self:AddTab(...) end
            elseif lk == "notify" or lk == "createnotification" or lk == "makenotify" or lk == "notification" then
                return function(self, ...) return Fluent:Notify(...) end
            end
            return rawget(tbl, key)
        end
    }
    setmetatable(w, winMT)

    -- Compatibility Aliases for Notifications
    w.Notify = function(_, opt) return Fluent:Notify(opt) end
    w.MakeNotify = function(_, opt) return Fluent:Notify(opt) end
    function w:ToggleInterface() self:Toggle() end

    function w:Watermark(watermarkCfg)
        local dummyBlock = {
            SetText = function() end,
            Set = function() end,
            Text = function() end,
            Input = function() end,
            SetVisible = function() end,
        }
        return {
            Holder = nil,
            AddBlock = function() return dummyBlock end,
            SetRender = function() end,
        }
    end

    -- Universal Config Manager API
    function w:SaveConfig(name) return Fluent:SaveConfig(name) end
    function w:LoadConfig(name) return Fluent:LoadConfig(name) end
    function w:DeleteConfig(name) return Fluent:DeleteConfig(name) end
    function w:GetConfigs() return Fluent:GetConfigs() end

    function w:BuildConfigSection(targetSecOrTab)
        local sec
        if targetSecOrTab and (targetSecOrTab.AddTextbox or targetSecOrTab.AddToggle or targetSecOrTab.AddButton) then
            sec = targetSecOrTab
        elseif targetSecOrTab and targetSecOrTab.AddSection then
            sec = targetSecOrTab:AddSection({ Name = "Config", Icon = "save" })
        else
            local tab = self.Tabs["Settings"] or self.Tabs["settings"] or self:AddTab("Settings", "settings")
            sec = tab:AddSection({ Name = "Config", Icon = "save" })
        end

        local configsList = Fluent:GetConfigs()
        local currentProfile = self.ActiveConfigProfile or Fluent.ActiveConfigProfile or tryCall(Fluent.GetAutoLoad, Fluent) or configsList[1] or "default"
        self.ActiveConfigProfile = currentProfile
        Fluent.ActiveConfigProfile = currentProfile

        local profileInput, profileDropdown
        local function setCurrent(name)
            if not name or name == "" then return end
            currentProfile = name
            self.ActiveConfigProfile = name
            Fluent.ActiveConfigProfile = name
        end
        local function syncWidgets(list)
            if profileDropdown and profileDropdown.SetOptions then
                profileDropdown:SetOptions(list or Fluent:GetConfigs(), currentProfile)
                profileDropdown:Close()
            end
            if profileInput and profileInput.SetValue then
                profileInput:SetValue(currentProfile, false)
            end
        end

        profileInput = sec:AddTextbox({
            Name = "Profile Name",
            Placeholder = "default",
            Default = currentProfile,
            Flag = "__Liyhub_ProfileName",
            Callback = function(txt) setCurrent(txt) end
        })

        profileDropdown = sec:AddDropdown({
            Name = "Saved Profiles",
            Options = configsList,
            Default = currentProfile,
            Flag = "__Liyhub_ProfileSelect",
            Callback = function(choice)
                setCurrent(choice)
                if profileInput and profileInput.SetValue then
                    profileInput:SetValue(choice, false)
                end
            end
        })

        self._profileInput = profileInput
        self._profileDropdown = profileDropdown
        Fluent._profileInput = profileInput
        Fluent._profileDropdown = profileDropdown

        local row1 = sec:AddRow()
        row1:AddButton({
            Name = "Save",
            Callback = function()
                Fluent:SaveConfig(currentProfile)
                syncWidgets()
            end
        })
        row1:AddButton({
            Name = "Load",
            Callback = function()
                Fluent:LoadConfig(currentProfile)
                syncWidgets()
            end
        })

        local row2 = sec:AddRow()
        row2:AddButton({
            Name = "Delete",
            Callback = function()
                Fluent:DeleteConfig(currentProfile)
                local updated = Fluent:GetConfigs()
                setCurrent(updated[1] or "default")
                syncWidgets(updated)
            end
        })
        row2:AddButton({
            Name = "Refresh",
            Callback = function()
                local updated = Fluent:GetConfigs()
                if not table.find(updated, currentProfile) then
                    setCurrent(updated[1] or "default")
                end
                syncWidgets(updated)
                Fluent:Notify({ Title = "Config", Content = "Profile list refreshed.", Type = "Info", Duration = 1.5 })
            end
        })

        sec:AddToggle("__Liyhub_AutoLoad", {
            Title = "Auto Load",
            Description = "Load last used profile on start",
            Default = tryCall(Fluent.IsAutoLoadEnabled, Fluent) ~= false,
            Callback = function(on) Fluent:SetAutoLoadEnabled(on, currentProfile) end
        })

        sec:AddParagraph({
            Title = "Note",
            Content = "After a script update, save a new profile and delete old ones to avoid flag conflicts."
        })

        return sec
    end

    -- Universal UI controls every script gets in its Settings tab.
    function w:BuildUISection(targetTab)
        local tab = targetTab or self.Tabs["Settings"] or self.Tabs["settings"] or self:AddTab("Settings", "settings")
        local uiSec = tab:AddSection({ Name = "Interface", Icon = "settings" })
        uiSec:AddKeybind("__Liyhub_MenuKey", {
            Title = "Menu Keybind",
            Default = (typeof(self._toggleKey) == "EnumItem" and self._toggleKey.Name) or "RightControl",
            Callback = function(k)
                self:SetToggleKey(k)
                o.MinimizeKey = k
            end
        })

        local row = uiSec:AddRow()
        row:AddButton({
            Name = "Rejoin",
            Callback = function()
                pcall(function()
                    local TeleportService = game:GetService("TeleportService")
                    if #Players:GetPlayers() <= 1 then
                        TeleportService:Teleport(game.PlaceId, LocalPlayer)
                    else
                        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
                    end
                end)
            end
        })
        row:AddButton({
            Name = "Copy Job ID",
            Callback = function()
                local clip = (typeof(setclipboard) == "function" and setclipboard) or (typeof(toclipboard) == "function" and toclipboard)
                if clip then
                    pcall(clip, tostring(game.JobId))
                    Fluent:Notify({ Title = "Copied", Content = "Job ID copied to clipboard.", Type = "Info", Duration = 1.5 })
                else
                    Fluent:Notify({ Title = "Unavailable", Content = "Clipboard is not supported here.", Type = "Warning", Duration = 2 })
                end
            end
        })

        uiSec:AddButton({
            Title = "Unload UI",
            Description = "Close menu and stop loops",
            ButtonText = "Unload",
            Callback = function() self:Destroy() end
        })
        return uiSec
    end

    function w:AddSettingsTab()
        local tab = self.Tabs["Settings"] or self.Tabs["settings"] or self:AddTab("Settings", "settings")
        self:BuildConfigSection(tab)
        pcall(self.BuildUISection, self, tab)
        return tab
    end

    task.defer(function()
        if o.SaveConfig or o.AutoConfig then
            if not w.Tabs["Settings"] and not w.Tabs["settings"] then
                w:AddSettingsTab()
            end
        end

        -- Auto load: wait until the script stops adding elements, then apply the remembered profile.
        local okAuto, autoName = pcall(Fluent.GetAutoLoad, Fluent)
        if not okAuto then autoName = nil end
        if not autoName and o.AutoConfig then autoName = w.ActiveConfigProfile or Fluent.ActiveConfigProfile or "default" end
        if autoName then
            task.spawn(function()
                local function optionCount()
                    local n = 0
                    for _ in pairs(Fluent.Options) do n += 1 end
                    return n
                end
                local last, stableFor, waited = optionCount(), 0, 0
                while stableFor < 0.6 and waited < 6 do
                    task.wait(0.2)
                    waited += 0.2
                    local now = optionCount()
                    if now == last then stableFor += 0.2 else stableFor, last = 0, now end
                end
                if Fluent._destroyed or not gui.Parent then return end
                pcall(function() Fluent:LoadConfig(autoName, { Silent = true }) end)
            end)
        end

        for _, t in ipairs(w._tabs) do
            if t.Page then
                local pl = t.Page:FindFirstChildOfClass("UIListLayout")
                if pl then
                    t.Page.CanvasSize = UDim2.new(0, 0, 0, pl.AbsoluteContentSize.Y + 36)
                end
            end
            for _, el in ipairs(t.Elements) do
                if type(el) == "table" and type(el.Resize) == "function" then
                    el:Resize()
                end
            end
        end

        sortSidebarTabs()
        if not w.ActiveTab and #w._tabs > 0 then
            local topTab = nil
            local minOrder = math.huge
            for _, tab in ipairs(w._tabs) do
                if not tab.IsBottomTab and tab.Button and tab.Button.Parent == sidebar then
                    local ord = tab.Button.LayoutOrder or 0
                    if ord < minOrder then
                        minOrder = ord
                        topTab = tab
                    end
                end
            end
            if topTab then
                topTab:Select()
            else
                w._tabs[1]:Select()
            end
        elseif w.ActiveTab then
            w.ActiveTab:Select()
        end
    end)

    return w
end

-- ============================================================================
-- Universal Config Serialization & Storage System
-- ============================================================================
local HttpService = game:GetService("HttpService")
local _memoryConfigs = {}

local function getConfigDir()
    return Fluent.ConfigFolder or "Liyhub/Configs"
end

local function ensureConfigDir()
    local folder = getConfigDir()
    if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
        pcall(function()
            local parts = folder:split("/")
            local curr = ""
            for _, part in ipairs(parts) do
                if part ~= "" then
                    curr = (curr == "" and part or (curr .. "/" .. part))
                    if not isfolder(curr) then makefolder(curr) end
                end
            end
        end)
    end
end

local function getProfilePath(name)
    local dir = getConfigDir()
    local cleanName = tostring(name or "default"):gsub("[^%w%-_%s]", "")
    if cleanName == "" then cleanName = "default" end
    return dir .. "/" .. cleanName .. ".json"
end

-- Auto-load pointer: "<profile>" = enabled, "-<profile>" = disabled but remembered.
local function autoLoadPath()
    return getConfigDir() .. "/_autoload.txt"
end

local function readAutoLoad()
    local raw = Fluent._autoLoadMemory
    if typeof(isfile) == "function" and typeof(readfile) == "function" then
        pcall(function()
            if isfile(autoLoadPath()) then raw = readfile(autoLoadPath()) end
        end)
    end
    raw = raw and tostring(raw):gsub("^%s+", ""):gsub("%s+$", "") or nil
    if not raw or raw == "" then return nil, true end
    if string.sub(raw, 1, 1) == "-" then return string.sub(raw, 2), false end
    return raw, true
end

local function writeAutoLoad(name, enabled)
    local raw = (enabled and "" or "-") .. tostring(name or "")
    Fluent._autoLoadMemory = raw
    ensureConfigDir()
    if typeof(writefile) == "function" then pcall(writefile, autoLoadPath(), raw) end
end

-- Profile to load on start, or nil when auto load is off / nothing remembered.
function Fluent:GetAutoLoad()
    local name, enabled = readAutoLoad()
    if enabled and name and name ~= "" then return name end
    return nil
end

function Fluent:IsAutoLoadEnabled()
    local _, enabled = readAutoLoad()
    return enabled ~= false
end

function Fluent:SetAutoLoadEnabled(on, name)
    local remembered = readAutoLoad()
    writeAutoLoad(remembered or name or self.ActiveConfigProfile or "default", on ~= false)
end

-- Remember the last used profile unless the user turned auto load off.
local function rememberProfile(name)
    if Fluent:IsAutoLoadEnabled() then writeAutoLoad(name, true) end
end

local function serializeValue(v)
    if typeof(v) == "Color3" then
        return { __type = "Color3", R = v.R, G = v.G, B = v.B }
    elseif typeof(v) == "EnumItem" then
        return { __type = "EnumItem", EnumType = tostring(v.EnumType), Name = v.Name }
    elseif type(v) == "table" then
        local t = {}
        for k, subV in pairs(v) do
            t[tostring(k)] = serializeValue(subV)
        end
        return t
    else
        return v
    end
end

local function deserializeValue(v)
    if type(v) == "table" and v.__type then
        if v.__type == "Color3" then
            return Color3.new(v.R or 1, v.G or 1, v.B or 1)
        elseif v.__type == "EnumItem" then
            if v.EnumType == "KeyCode" and Enum.KeyCode[v.Name] then
                return Enum.KeyCode[v.Name]
            end
        end
    elseif type(v) == "table" then
        local t = {}
        for k, subV in pairs(v) do
            t[k] = deserializeValue(subV)
        end
        return t
    end
    return v
end

function Fluent:GetConfigs()
    ensureConfigDir()
    local list = {}
    local seen = {}
    local dir = getConfigDir()

    if typeof(listfiles) == "function" and typeof(isfolder) == "function" and isfolder(dir) then
        local s, files = pcall(listfiles, dir)
        if s and type(files) == "table" then
            for _, f in ipairs(files) do
                local name = f:match("([^/\\]+)%.json$")
                if name and not seen[name] then
                    seen[name] = true
                    table.insert(list, name)
                end
            end
        end
    end

    for k, _ in pairs(_memoryConfigs) do
        if not seen[k] then
            seen[k] = true
            table.insert(list, k)
        end
    end

    if #list == 0 then
        table.insert(list, "default")
    end
    table.sort(list)
    return list
end

function Fluent:SaveConfig(name)
    name = (name and name ~= "") and name or "default"
    self.ActiveConfigProfile = name
    self.CurrentProfile = name
    if self._profileInput and self._profileInput.SetValue then
        self._profileInput:SetValue(name, false)
    end
    if self._profileDropdown and self._profileDropdown.SetValue then
        self._profileDropdown:SetValue(name, false)
    end

    ensureConfigDir()
    local data = {
        _version = 1,
        _placeId = game.PlaceId,
        _timestamp = os.time(),
        _profile = name,
        Flags = {}
    }
    local ignoredFlags = {
        ["Profile Name"] = true,
        ["Select Saved Profile"] = true,
        ["__Liyhub_ProfileName"] = true,
        ["__Liyhub_ProfileSelect"] = true,
        ["Menu Keybind"] = true,
    }
    for flag, val in pairs(self.Flags) do
        local fStr = tostring(flag)
        if not ignoredFlags[fStr] and not fStr:match("^__Liyhub_") then
            data.Flags[flag] = serializeValue(val)
        end
    end
    for flag, opt in pairs(self.Options) do
        local fStr = tostring(flag)
        if not ignoredFlags[fStr] and not fStr:match("^__Liyhub_") and data.Flags[flag] == nil and opt and type(opt.GetValue) == "function" then
            local val = opt:GetValue()
            if val ~= nil then
                data.Flags[flag] = serializeValue(val)
            end
        end
    end

    local encoded = HttpService:JSONEncode(data)
    _memoryConfigs[name] = encoded

    local path = getProfilePath(name)
    if typeof(writefile) == "function" then
        pcall(writefile, path, encoded)
    end
    rememberProfile(name)

    self:Notify({
        Title = "Config Saved",
        Content = "Profile '" .. name .. "' saved successfully.",
        Type = "Success",
        Duration = 2.5
    })
    return true
end

function Fluent:LoadConfig(name, opts)
    name = (name and name ~= "") and name or "default"
    local silent = type(opts) == "table" and opts.Silent == true
    self.ActiveConfigProfile = name
    self.CurrentProfile = name
    ensureConfigDir()
    local raw = nil
    local path = getProfilePath(name)

    if typeof(isfile) == "function" and typeof(readfile) == "function" and isfile(path) then
        pcall(function() raw = readfile(path) end)
    end

    if not raw then
        raw = _memoryConfigs[name]
    end

    if not raw then
        if silent then return false end
        self:Notify({
            Title = "Config Not Found",
            Content = "Profile '" .. name .. "' does not exist.",
            Type = "Warning",
            Duration = 2.5
        })
        return false
    end

    local s, data = pcall(function() return HttpService:JSONDecode(raw) end)
    if not s or type(data) ~= "table" or type(data.Flags) ~= "table" then
        if silent then return false end
        self:Notify({
            Title = "Config Error",
            Content = "Invalid config format for '" .. name .. "'.",
            Type = "Warning",
            Duration = 2.5
        })
        return false
    end

    local ignoredFlags = {
        ["Profile Name"] = true,
        ["Select Saved Profile"] = true,
        ["__Liyhub_ProfileName"] = true,
        ["__Liyhub_ProfileSelect"] = true,
        ["Menu Keybind"] = true,
    }

    rememberProfile(name)
    for flag, rawVal in pairs(data.Flags) do
        local fStr = tostring(flag)
        if not ignoredFlags[fStr] and not fStr:match("^__Liyhub_") then
            local val = deserializeValue(rawVal)
            self.Flags[flag] = val
            local opt = self.Options[flag]
            if opt and opt.SetValue then
                pcall(function() opt:SetValue(val, true) end)
            elseif opt and opt.Set then
                pcall(function() opt:Set(val, true) end)
            end
        end
    end

    if self._profileInput and self._profileInput.SetValue then
        self._profileInput:SetValue(name, false)
    end
    if self._profileDropdown and self._profileDropdown.SetValue then
        self._profileDropdown:SetValue(name, false)
    end

    self:Notify({
        Title = silent and "Config Auto Loaded" or "Config Loaded",
        Content = "Profile '" .. name .. "' applied.",
        Type = "Success",
        Duration = 2.5
    })
    return true
end

function Fluent:DeleteConfig(name)
    name = (name and name ~= "") and name or "default"
    ensureConfigDir()
    _memoryConfigs[name] = nil
    local path = getProfilePath(name)
    if typeof(isfile) == "function" and typeof(delfile) == "function" and isfile(path) then
        pcall(delfile, path)
    end
    self:Notify({
        Title = "Config Deleted",
        Content = "Profile '" .. name .. "' removed.",
        Type = "Info",
        Duration = 2
    })
    return true
end

-- Notification System (Compatible with Old UI MakeNotify & Modern Fluent Toast)
function Fluent:Notify(o)
    o = o or {}
    local holder = self._notifyHolder
    if not holder or not holder.Parent then
        local pGui = parentGui()
        local notifyGui = pGui:FindFirstChild("LiyhubNotifyGui")
        if not notifyGui then
            notifyGui = Instance.new("ScreenGui")
            notifyGui.Name = "LiyhubNotifyGui"
            notifyGui.ResetOnSpawn = false
            notifyGui.DisplayOrder = 2147483647
            notifyGui.IgnoreGuiInset = true
            notifyGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

            if typeof(syn) == "table" and typeof(syn.protect_gui) == "function" then
                pcall(syn.protect_gui, notifyGui)
            elseif typeof(protect_gui) == "function" then
                pcall(protect_gui, notifyGui)
            elseif typeof(protectgui) == "function" then
                pcall(protectgui, notifyGui)
            end
            notifyGui.Parent = pGui
        end

        holder = Instance.new("Frame")
        holder.Name = "LiyhubNotifyHolder"
        holder.BackgroundTransparency = 1
        holder.AnchorPoint = Fluent.IsMobile and Vector2.new(1, 0) or Vector2.new(1, 1)
        holder.Position = Fluent.IsMobile and UDim2.new(1, -16, 0, 50) or UDim2.new(1, -20, 1, -20)
        holder.Size = Fluent.IsMobile and UDim2.fromOffset(280, 400) or UDim2.fromOffset(320, 480)
        holder.ZIndex = 1000
        holder.Parent = notifyGui

        local l = Instance.new("UIListLayout")
        l.VerticalAlignment = Fluent.IsMobile and Enum.VerticalAlignment.Top or Enum.VerticalAlignment.Bottom
        l.HorizontalAlignment = Enum.HorizontalAlignment.Right
        l.Padding = UDim.new(0, 8)
        l.SortOrder = Enum.SortOrder.LayoutOrder
        l.Parent = holder
        self._notifyHolder = holder
    end

    local titleStr = o.Title or "Liyhub"
    local descStr = o.Content or o.Description or o.Desc or o.Text or o.SubTitle or ""
    local duration = o.Duration or o.Delay or o.Time or 3.5
    local c = o.Color or self.CurrentTheme[o.Type or "Info"] or self.CurrentTheme.Info or self.CurrentTheme.Accent

    local f = Instance.new("Frame")
    f.Name = "Toast"
    f.BackgroundColor3 = Color3.fromRGB(15, 17, 24)
    f.BackgroundTransparency = 0.05
    f.Size = UDim2.new(1, 0, 0, 68)
    f.ClipsDescendants = true
    f.ZIndex = 1001
    f.Parent = holder
    corner(f, 10)
    stroke(f, c, 0.45)

    -- Left Accent Indicator Bar
    local bar = Instance.new("Frame")
    bar.Name = "AccentBar"
    bar.Size = UDim2.new(0, 4, 1, -16)
    bar.Position = UDim2.fromOffset(8, 8)
    bar.BackgroundColor3 = c
    bar.BorderSizePixel = 0
    bar.ZIndex = 1002
    bar.Parent = f
    corner(bar, 2)

    local t = text(f, titleStr, 13, self.CurrentTheme.Text)
    t.Position = UDim2.fromOffset(20, 8)
    t.Size = UDim2.new(1, -28, 0, 18)
    t.Font = Enum.Font.GothamBold
    t.ZIndex = 1002

    local b = text(f, descStr, 11, self.CurrentTheme.SubText)
    b.Position = UDim2.fromOffset(20, 28)
    b.Size = UDim2.new(1, -28, 0, 32)
    b.TextTruncate = Enum.TextTruncate.AtEnd
    b.ZIndex = 1002

    -- Slide-in animation
    f.Position = UDim2.new(0, 40, 0, 0)
    tween(f, 0.22, { Position = UDim2.new(0, 0, 0, 0) })

    task.delay(duration, function()
        if f and f.Parent then
            tween(f, 0.22, { BackgroundTransparency = 1, Position = UDim2.new(0, 50, 0, 0) })
            task.wait(0.22)
            if f and f.Parent then f:Destroy() end
        end
    end)
    return f
end

Fluent.CreateWindow = Fluent.CreateWindow
Fluent.Create = Fluent.CreateWindow
Fluent.Window = Fluent.CreateWindow
Fluent.New = Fluent.CreateWindow
Fluent.Init = Fluent.CreateWindow
Fluent.MakeWindow = Fluent.CreateWindow
Fluent.Notify = Fluent.Notify
Fluent.MakeNotify = Fluent.Notify
Fluent.Notification = Fluent.Notify
Fluent.CreateNotification = function(self)
    return {
        new = function(opt) return Fluent:Notify(opt) end,
        New = function(opt) return Fluent:Notify(opt) end,
        Notify = function(opt) return Fluent:Notify(opt) end
    }
end


function Fluent:CreateNotification()
    return {
        new = function(opt)
            return Fluent:Notify(opt)
        end
    }
end

function Fluent:SetTheme(name)
    if self.Themes[name] then
        self.CurrentTheme = self.Themes[name]
    end
end

pcall(function()
    g.Liyhub = Fluent
    g.NeverLose = Fluent
end)
return Fluent
