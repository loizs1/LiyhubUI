-- language: luau, file: NovaUI/Components/Keybind.luau
local UserInputService = game:GetService("UserInputService")
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local Keybind = {}
Keybind.__index = Keybind

function Keybind.new(parent: Instance, config: { Name: string, Default: Enum.KeyCode?, Callback: (Enum.KeyCode) -> () })
    local self = setmetatable({}, Keybind)
    self._maid = Maid.new()
    self.Key = config.Default or Enum.KeyCode.RightShift
    self._callback = config.Callback
    self.Binding = false

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Keybind",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.SurfaceSecondary,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 6, 6, 10, 10)

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, -90, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Name or "Keybind",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self.BindBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 80, 0, 24),
        Position = UDim2.new(1, -80, 0.5, -12),
        BackgroundColor3 = theme.Surface,
        Font = Enum.Font.GothamBold,
        Text = "[" .. self.Key.Name .. "]",
        TextColor3 = theme.Text,
        TextSize = 11,
        Parent = self.Frame,
    }) :: TextButton

    Utility.AddCorner(self.BindBtn, 4)

    self._maid:GiveTask(self.BindBtn.MouseButton1Click:Connect(function()
        self.Binding = true
        self.BindBtn.Text = "[...]"
    end))

    self._maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
        if self.Binding and input.UserInputType == Enum.UserInputType.Keyboard then
            self.Binding = false
            self.Key = input.KeyCode
            self.BindBtn.Text = "[" .. self.Key.Name .. "]"
            if self._callback then
                self._callback(self.Key)
            end
        end
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
        self.BindBtn.BackgroundColor3 = t.Surface
        self.BindBtn.TextColor3 = t.Text
    end))

    return self
end

function Keybind:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Keybind
