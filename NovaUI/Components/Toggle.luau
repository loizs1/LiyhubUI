-- language: luau, file: NovaUI/Components/Toggle.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Animation = require(script.Parent.Parent.Services.Animation)
local Maid = require(script.Parent.Parent.Core.Maid)

local Toggle = {}
Toggle.__index = Toggle

function Toggle.new(parent: Instance, config: { Name: string, Default: boolean?, Callback: (boolean) -> () })
    local self = setmetatable({}, Toggle)
    self._maid = Maid.new()
    self.Value = config.Default or false
    self._callback = config.Callback

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Toggle",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.SurfaceSecondary,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 6, 6, 10, 10)

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Name or "Toggle",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self.Track = Utility.Create("TextButton", {
        Size = UDim2.new(0, 38, 0, 20),
        Position = UDim2.new(1, -38, 0.5, -10),
        BackgroundColor3 = self.Value and theme.Accent or theme.Surface,
        AutoButtonColor = false,
        Text = "",
        Parent = self.Frame,
    }) :: TextButton

    Utility.AddCorner(self.Track, 10)

    self.Knob = Utility.Create("Frame", {
        Size = UDim2.new(0, 14, 0, 14),
        Position = self.Value and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = self.Track,
    })
    Utility.AddCorner(self.Knob, 7)

    self._maid:GiveTask(self.Track.MouseButton1Click:Connect(function()
        self:Set(not self.Value)
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
        self.Track.BackgroundColor3 = self.Value and t.Accent or t.Surface
    end))

    return self
end

function Toggle:Set(value: boolean)
    self.Value = value
    local theme = Theme.GetTheme()

    Animation.Tween(self.Track, 0.2, { BackgroundColor3 = self.Value and theme.Accent or theme.Surface })
    Animation.Spring(self.Knob, { Position = self.Value and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7) }, 0.2)

    if self._callback then
        self._callback(self.Value)
    end
end

function Toggle:Get(): boolean
    return self.Value
end

function Toggle:SetVisible(visible: boolean)
    self.Frame.Visible = visible
end

function Toggle:SetDisabled(disabled: boolean)
    self.Track.Active = not disabled
    self.Frame.BackgroundTransparency = disabled and 0.5 or 0
end

function Toggle:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Toggle
