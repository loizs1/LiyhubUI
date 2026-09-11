-- language: luau, file: NovaUI/UI/Sidebar.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)
local Animation = require(script.Parent.Parent.Services.Animation)
local PlayerProfile = require(script.Parent.PlayerProfile)

local Sidebar = {}
Sidebar.__index = Sidebar

function Sidebar.new(parent: Instance, onSettingsClicked: () -> ())
    local self = setmetatable({}, Sidebar)
    self._maid = Maid.new()
    self._tabs = {}
    self._activeTab = nil
    self._onSettingsClicked = onSettingsClicked

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Sidebar",
        Size = UDim2.new(0.24, 0, 1, 0),
        BackgroundColor3 = theme.Surface,
        BorderSizePixel = 0,
        Parent = parent,
    }) :: Frame

    Utility.AddPadding(self.Frame, 12, 12, 12, 12)

    -- Header / Title
    self.Header = Utility.Create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundTransparency = 1,
        Parent = self.Frame,
    })

    self.TitleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "NOVAUI",
        TextColor3 = theme.Accent,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Header,
    })

    self.SubtitleLabel = Utility.Create("TextLabel", {
        Name = "Subtitle",
        Size = UDim2.new(1, 0, 0, 14),
        Position = UDim2.new(0, 0, 0, 22),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = "Developer Framework",
        TextColor3 = theme.TextSecondary,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Header,
    })

    -- Scrollable Navigation Area
    self.NavScroll = Utility.Create("ScrollingFrame", {
        Name = "NavigationScroll",
        Size = UDim2.new(1, 0, 1, -145),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        ScrollBarImageColor3 = theme.Border,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Frame,
    }) :: ScrollingFrame

    self.NavLayout = Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        Parent = self.NavScroll,
    })

    -- Fixed Footer Area
    self.Footer = Utility.Create("Frame", {
        Name = "Footer",
        Size = UDim2.new(1, 0, 0, 90),
        Position = UDim2.new(0, 0, 1, -90),
        BackgroundTransparency = 1,
        Parent = self.Frame,
    })

    self.FooterLayout = Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 6),
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Parent = self.Footer,
    })

    -- Player Profile
    self.Profile = PlayerProfile.new(self.Footer)

    -- Settings Button
    self.SettingsButton = Utility.Create("TextButton", {
        Name = "SettingsButton",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = theme.SurfaceSecondary,
        BackgroundTransparency = 0.5,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = "  ⚙  Settings",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Footer,
    }) :: TextButton

    Utility.AddCorner(self.SettingsButton, 6)
    Utility.AddPadding(self.SettingsButton, 0, 0, 8, 8)

    self._maid:GiveTask(self.SettingsButton.MouseButton1Click:Connect(function()
        Animation.Spring(self.SettingsButton, { Size = UDim2.new(1, 0, 0, 30) }, 0.1)
        task.delay(0.1, function()
            Animation.Spring(self.SettingsButton, { Size = UDim2.new(1, 0, 0, 32) }, 0.1)
        end)
        if self._onSettingsClicked then
            self._onSettingsClicked()
        end
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.Surface
        self.TitleLabel.TextColor3 = t.Accent
        self.SubtitleLabel.TextColor3 = t.TextSecondary
        self.NavScroll.ScrollBarImageColor3 = t.Border
        self.SettingsButton.BackgroundColor3 = t.SurfaceSecondary
        self.SettingsButton.TextColor3 = t.Text
    end))

    return self
end

function Sidebar:AddTabButton(name: string, icon: string?, callback: () -> ())
    local theme = Theme.GetTheme()

    local tabButton = Utility.Create("TextButton", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.SurfaceSecondary,
        BackgroundTransparency = 1,
        AutoButtonColor = false,
        Font = Enum.Font.GothamMedium,
        Text = "",
        Parent = self.NavScroll,
    }) :: TextButton

    Utility.AddCorner(tabButton, 6)
    Utility.AddPadding(tabButton, 0, 0, 10, 10)

    local iconText = icon or "◈"
    local label = Utility.Create("TextLabel", {
        Name = "Label",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = string.format("%s  %s", iconText, name),
        TextColor3 = theme.TextSecondary,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = tabButton,
    }) :: TextLabel

    local tabData = {
        Button = tabButton,
        Label = label,
        Name = name,
        Callback = callback,
    }

    table.insert(self._tabs, tabData)

    tabButton.MouseEnter:Connect(function()
        if self._activeTab ~= tabData then
            Animation.Tween(tabButton, 0.2, { BackgroundTransparency = 0.7, BackgroundColor3 = theme.SurfaceSecondary })
            Animation.Tween(label, 0.2, { TextColor3 = theme.Text })
        end
    end)

    tabButton.MouseLeave:Connect(function()
        if self._activeTab ~= tabData then
            Animation.Tween(tabButton, 0.2, { BackgroundTransparency = 1 })
            Animation.Tween(label, 0.2, { TextColor3 = theme.TextSecondary })
        end
    end)

    tabButton.MouseButton1Click:Connect(function()
        self:SelectTab(tabData)
    end)

    if #self._tabs == 1 then
        self:SelectTab(tabData)
    end

    return tabData
end

function Sidebar:SelectTab(tabData)
    local theme = Theme.GetTheme()

    for _, t in ipairs(self._tabs) do
        if t == tabData then
            Animation.Tween(t.Button, 0.2, { BackgroundTransparency = 0, BackgroundColor3 = theme.Accent })
            Animation.Tween(t.Label, 0.2, { TextColor3 = Color3.new(1, 1, 1) })
        else
            Animation.Tween(t.Button, 0.2, { BackgroundTransparency = 1 })
            Animation.Tween(t.Label, 0.2, { TextColor3 = theme.TextSecondary })
        end
    end

    self._activeTab = tabData
    if tabData.Callback then
        tabData.Callback()
    end
end

function Sidebar:SetProfileVisible(visible: boolean)
    self.Profile:SetVisible(visible)
    if visible then
        self.Footer.Size = UDim2.new(1, 0, 0, 90)
        self.Footer.Position = UDim2.new(0, 0, 1, -90)
        self.NavScroll.Size = UDim2.new(1, 0, 1, -145)
    else
        self.Footer.Size = UDim2.new(1, 0, 0, 36)
        self.Footer.Position = UDim2.new(0, 0, 1, -36)
        self.NavScroll.Size = UDim2.new(1, 0, 1, -90)
    end
end

function Sidebar:Destroy()
    self._maid:Destroy()
    self.Profile:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

return Sidebar
