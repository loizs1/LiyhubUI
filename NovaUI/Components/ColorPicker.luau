-- language: luau, file: NovaUI/Components/ColorPicker.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local ColorPicker = {}
ColorPicker.__index = ColorPicker

function ColorPicker.new(parent: Instance, config: { Name: string, Default: Color3?, Callback: (Color3) -> () })
    local self = setmetatable({}, ColorPicker)
    self._maid = Maid.new()
    self.Color = config.Default or Color3.fromRGB(120, 100, 255)
    self._callback = config.Callback

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_ColorPicker",
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
        Text = config.Name or "Color Picker",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self.ColorPreview = Utility.Create("TextButton", {
        Size = UDim2.new(0, 36, 0, 20),
        Position = UDim2.new(1, -36, 0.5, -10),
        BackgroundColor3 = self.Color,
        Text = "",
        Parent = self.Frame,
    }) :: TextButton

    Utility.AddCorner(self.ColorPreview, 4)
    Utility.AddStroke(self.ColorPreview, theme.Border, 1)

    -- Preset color swatches cycling on click for compact framework demo
    local presets = {
        Color3.fromRGB(110, 95, 245),
        Color3.fromRGB(231, 76, 60),
        Color3.fromRGB(46, 204, 113),
        Color3.fromRGB(241, 196, 15),
        Color3.fromRGB(56, 139, 253),
        Color3.fromRGB(155, 89, 182),
    }
    local presetIdx = 1

    self._maid:GiveTask(self.ColorPreview.MouseButton1Click:Connect(function()
        presetIdx = (presetIdx % #presets) + 1
        self:Set(presets[presetIdx])
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
    end))

    return self
end

function ColorPicker:Set(color: Color3)
    self.Color = color
    self.ColorPreview.BackgroundColor3 = color
    if self._callback then
        self._callback(color)
    end
end

function ColorPicker:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return ColorPicker
