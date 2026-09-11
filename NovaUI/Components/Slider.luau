-- language: luau, file: NovaUI/Components/Slider.luau
local UserInputService = game:GetService("UserInputService")
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Animation = require(script.Parent.Parent.Services.Animation)
local Maid = require(script.Parent.Parent.Core.Maid)

local Slider = {}
Slider.__index = Slider

function Slider.new(parent: Instance, config: { Name: string, Min: number, Max: number, Default: number?, Increment: number?, Callback: (number) -> () })
    local self = setmetatable({}, Slider)
    self._maid = Maid.new()
    self.Min = config.Min or 0
    self.Max = config.Max or 100
    self.Increment = config.Increment or 1
    self.Value = math.clamp(config.Default or self.Min, self.Min, self.Max)
    self._callback = config.Callback

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Slider",
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = theme.SurfaceSecondary,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 6, 6, 10, 10)

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -60, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Name or "Slider",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self.ValueLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0, 50, 0, 18),
        Position = UDim2.new(1, -50, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = tostring(self.Value),
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        Parent = self.Frame,
    })

    self.Track = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 6),
        Position = UDim2.new(0, 0, 0, 26),
        BackgroundColor3 = theme.Surface,
        Parent = self.Frame,
    })
    Utility.AddCorner(self.Track, 3)

    local percent = (self.Value - self.Min) / (self.Max - self.Min)

    self.Fill = Utility.Create("Frame", {
        Size = UDim2.new(percent, 0, 1, 0),
        BackgroundColor3 = theme.Accent,
        Parent = self.Track,
    })
    Utility.AddCorner(self.Fill, 3)

    self.Knob = Utility.Create("Frame", {
        Size = UDim2.new(0, 12, 0, 12),
        Position = UDim2.new(percent, -6, 0.5, -6),
        BackgroundColor3 = Color3.new(1, 1, 1),
        Parent = self.Track,
    })
    Utility.AddCorner(self.Knob, 6)

    local dragging = false

    local function updateValue(inputPosition: Vector3)
        local trackAbsPos = self.Track.AbsolutePosition.X
        local trackAbsSize = self.Track.AbsoluteSize.X
        local rel = math.clamp((inputPosition.X - trackAbsPos) / trackAbsSize, 0, 1)
        local rawVal = self.Min + rel * (self.Max - self.Min)
        local steppedVal = math.floor(rawVal / self.Increment + 0.5) * self.Increment
        steppedVal = math.clamp(steppedVal, self.Min, self.Max)

        self:Set(steppedVal)
    end

    self._maid:GiveTask(self.Track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateValue(input.Position)
        end
    end))

    self._maid:GiveTask(UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end))

    self._maid:GiveTask(UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateValue(input.Position)
        end
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
        self.ValueLabel.TextColor3 = t.TextSecondary
        self.Track.BackgroundColor3 = t.Surface
        self.Fill.BackgroundColor3 = t.Accent
    end))

    return self
end

function Slider:Set(val: number)
    self.Value = val
    local percent = (self.Value - self.Min) / (self.Max - self.Min)
    self.Fill.Size = UDim2.new(percent, 0, 1, 0)
    self.Knob.Position = UDim2.new(percent, -6, 0.5, -6)
    self.ValueLabel.Text = tostring(self.Value)

    if self._callback then
        self._callback(self.Value)
    end
end

function Slider:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Slider
