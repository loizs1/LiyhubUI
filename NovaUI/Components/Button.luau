-- language: luau, file: NovaUI/Components/Button.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Animation = require(script.Parent.Parent.Services.Animation)
local Maid = require(script.Parent.Parent.Core.Maid)

local Button = {}
Button.__index = Button

function Button.new(parent: Instance, config: { Name: string, Description: string?, Callback: () -> () })
    local self = setmetatable({}, Button)
    self._maid = Maid.new()

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Button",
        Size = UDim2.new(1, 0, 0, config.Description and 46 or 36),
        BackgroundColor3 = theme.SurfaceSecondary,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 6, 6, 10, 10)

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18),
        Position = UDim2.new(0, 0, 0, config.Description and 2 or 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Name or "Button",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    if config.Description then
        self.DescLabel = Utility.Create("TextLabel", {
            Size = UDim2.new(1, -60, 0, 14),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundTransparency = 1,
            Font = Enum.Font.Gotham,
            Text = config.Description,
            TextColor3 = theme.TextSecondary,
            TextSize = 11,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.Frame,
        })
    end

    self.ActionButton = Utility.Create("TextButton", {
        Size = UDim2.new(0, 60, 0, 24),
        Position = UDim2.new(1, -60, 0.5, -12),
        BackgroundColor3 = theme.Accent,
        Font = Enum.Font.GothamBold,
        Text = "Click",
        TextColor3 = Color3.new(1, 1, 1),
        TextSize = 11,
        Parent = self.Frame,
    }) :: TextButton

    Utility.AddCorner(self.ActionButton, 4)

    self._maid:GiveTask(self.ActionButton.MouseButton1Click:Connect(function()
        Animation.Spring(self.ActionButton, { Size = UDim2.new(0, 56, 0, 22), Position = UDim2.new(1, -58, 0.5, -11) }, 0.1)
        task.delay(0.1, function()
            Animation.Spring(self.ActionButton, { Size = UDim2.new(0, 60, 0, 24), Position = UDim2.new(1, -60, 0.5, -12) }, 0.1)
        end)
        if config.Callback then
            config.Callback()
        end
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
        if self.DescLabel then self.DescLabel.TextColor3 = t.TextSecondary end
        self.ActionButton.BackgroundColor3 = t.Accent
    end))

    return self
end

function Button:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Button
