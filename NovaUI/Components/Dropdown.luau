-- language: luau, file: NovaUI/Components/Dropdown.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Animation = require(script.Parent.Parent.Services.Animation)
local Maid = require(script.Parent.Parent.Core.Maid)

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent: Instance, config: { Name: string, Options: { string }, Default: string?, Callback: (string) -> () })
    local self = setmetatable({}, Dropdown)
    self._maid = Maid.new()
    self.Options = config.Options or {}
    self.Value = config.Default or (self.Options[1] or "")
    self._callback = config.Callback
    self.Open = false

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Dropdown",
        Size = UDim2.new(1, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.SurfaceSecondary,
        ClipsDescendants = true,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 6, 6, 10, 10)

    self.HeaderBtn = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "",
        Parent = self.Frame,
    }) :: TextButton

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Name or "Dropdown",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.HeaderBtn,
    })

    self.ValueLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0.5, -20, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = self.Value .. "  ▼",
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = self.HeaderBtn,
    })

    self.OptionContainer = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Frame,
    })

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = self.OptionContainer,
    })

    self:_renderOptions()

    self._maid:GiveTask(self.HeaderBtn.MouseButton1Click:Connect(function()
        self:ToggleOpen()
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
        self.ValueLabel.TextColor3 = t.TextSecondary
    end))

    return self
end

function Dropdown:_renderOptions()
    for _, child in ipairs(self.OptionContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local theme = Theme.GetTheme()
    for _, option in ipairs(self.Options) do
        local optBtn = Utility.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = (option == self.Value) and theme.Accent or theme.Surface,
            Font = Enum.Font.Gotham,
            Text = option,
            TextColor3 = theme.Text,
            TextSize = 12,
            Parent = self.OptionContainer,
        })
        Utility.AddCorner(optBtn, 4)

        optBtn.MouseButton1Click:Connect(function()
            self:Set(option)
            self:ToggleOpen(false)
        end)
    end
end

function Dropdown:ToggleOpen(state: boolean?)
    self.Open = (state ~= nil) and state or not self.Open
    self.OptionContainer.Visible = self.Open
    self.ValueLabel.Text = self.Value .. (self.Open and "  ▲" or "  ▼")
end

function Dropdown:Set(val: string)
    self.Value = val
    self:_renderOptions()
    self.ValueLabel.Text = self.Value .. (self.Open and "  ▲" or "  ▼")
    if self._callback then
        self._callback(self.Value)
    end
end

function Dropdown:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Dropdown
