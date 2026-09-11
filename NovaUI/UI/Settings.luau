-- language: luau, file: NovaUI/UI/Settings.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local State = require(script.Parent.Parent.Core.State)
local Maid = require(script.Parent.Parent.Core.Maid)
local Types = require(script.Parent.Parent.Utils.Types)

local Settings = {}
Settings.__index = Settings

function Settings.new(parent: Instance)
    local self = setmetatable({}, Settings)
    self._maid = Maid.new()

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("ScrollingFrame", {
        Name = "SettingsView",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        Visible = false,
        Parent = parent,
    }) :: ScrollingFrame

    Utility.AddPadding(self.Frame, 16, 16, 16, 16)

    self.Layout = Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 14),
        Parent = self.Frame,
    })

    -- Title
    local title = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "Interface & Library Settings",
        TextColor3 = theme.Text,
        TextSize = 18,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self:_createSection("UI Size Presets", function(sec)
        local btnContainer = Utility.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            Parent = sec,
        })
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            Parent = btnContainer,
        })

        local presets: { Types.SizePreset } = { "Small", "Normal", "Large" }
        for _, p in ipairs(presets) do
            local btn = Utility.Create("TextButton", {
                Size = UDim2.new(0.31, 0, 1, 0),
                BackgroundColor3 = (State.SizePreset == p) and theme.Accent or theme.SurfaceSecondary,
                Font = Enum.Font.GothamMedium,
                Text = p,
                TextColor3 = theme.Text,
                TextSize = 12,
                Parent = btnContainer,
            }) :: TextButton
            Utility.AddCorner(btn, 6)

            btn.MouseButton1Click:Connect(function()
                State.SetSizePreset(p)
            end)

            State.Subscribe("Scale", function()
                btn.BackgroundColor3 = (State.SizePreset == p) and Theme.GetTheme().Accent or Theme.GetTheme().SurfaceSecondary
            end)
        end
    end)

    self:_createSection("Device Layout Presets", function(sec)
        local btnContainer = Utility.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            Parent = sec,
        })
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            Parent = btnContainer,
        })

        local devices: { Types.DevicePreset } = { "PC", "Tablet", "Android" }
        for _, d in ipairs(devices) do
            local btn = Utility.Create("TextButton", {
                Size = UDim2.new(0.31, 0, 1, 0),
                BackgroundColor3 = (State.DevicePreset == d) and theme.Accent or theme.SurfaceSecondary,
                Font = Enum.Font.GothamMedium,
                Text = d,
                TextColor3 = theme.Text,
                TextSize = 12,
                Parent = btnContainer,
            }) :: TextButton
            Utility.AddCorner(btn, 6)

            btn.MouseButton1Click:Connect(function()
                State.SetDevicePreset(d)
            end)

            State.Subscribe("Scale", function()
                btn.BackgroundColor3 = (State.DevicePreset == d) and Theme.GetTheme().Accent or Theme.GetTheme().SurfaceSecondary
            end)
        end
    end)

    self:_createSection("Theme Selection", function(sec)
        local btnContainer = Utility.Create("Frame", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundTransparency = 1,
            Parent = sec,
        })
        Utility.Create("UIListLayout", {
            FillDirection = Enum.FillDirection.Horizontal,
            Padding = UDim.new(0, 8),
            Parent = btnContainer,
        })

        local themes = { "Midnight", "Graphite", "Slate" }
        for _, tName in ipairs(themes) do
            local btn = Utility.Create("TextButton", {
                Size = UDim2.new(0.31, 0, 1, 0),
                BackgroundColor3 = (Theme.GetCurrentThemeName() == tName) and theme.Accent or theme.SurfaceSecondary,
                Font = Enum.Font.GothamMedium,
                Text = tName,
                TextColor3 = theme.Text,
                TextSize = 12,
                Parent = btnContainer,
            }) :: TextButton
            Utility.AddCorner(btn, 6)

            btn.MouseButton1Click:Connect(function()
                Theme.SetTheme(tName)
            end)

            Theme.OnThemeChanged(function(_, cur)
                btn.BackgroundColor3 = (cur == tName) and Theme.GetTheme().Accent or Theme.GetTheme().SurfaceSecondary
            end)
        end
    end)

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        title.TextColor3 = t.Text
    end))

    return self
end

function Settings:_createSection(name: string, populate: (Frame) -> ())
    local theme = Theme.GetTheme()

    local card = Utility.Create("Frame", {
        Name = "SectionCard",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Surface,
        Parent = self.Frame,
    })
    Utility.AddCorner(card, 8)
    Utility.AddStroke(card, theme.Border, 1)
    Utility.AddPadding(card, 12, 12, 12, 12)

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = card,
    })

    local secTitle = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = name,
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    populate(card)
end

function Settings:SetVisible(visible: boolean)
    self.Frame.Visible = visible
end

function Settings:Destroy()
    self._maid:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

return Settings
