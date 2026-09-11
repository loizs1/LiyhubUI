-- language: luau, file: NovaUI/Components/Textbox.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local Textbox = {}
Textbox.__index = Textbox

function Textbox.new(parent: Instance, config: { Name: string, Placeholder: string?, Default: string?, Callback: (string) -> () })
    local self = setmetatable({}, Textbox)
    self._maid = Maid.new()
    self.Value = config.Default or ""
    self._callback = config.Callback

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Textbox",
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundColor3 = theme.SurfaceSecondary,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 6, 6, 10, 10)

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Name or "Textbox",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self.InputBox = Utility.Create("TextBox", {
        Size = UDim2.new(0.5, 0, 0, 24),
        Position = UDim2.new(0.5, 0, 0.5, -12),
        BackgroundColor3 = theme.Surface,
        Font = Enum.Font.Gotham,
        Text = self.Value,
        PlaceholderText = config.Placeholder or "Enter text...",
        PlaceholderColor3 = theme.TextSecondary,
        TextColor3 = theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = self.Frame,
    }) :: TextBox

    Utility.AddCorner(self.InputBox, 4)
    Utility.AddPadding(self.InputBox, 0, 0, 6, 6)

    self._maid:GiveTask(self.InputBox.FocusLost:Connect(function(enterPressed)
        self.Value = self.InputBox.Text
        if self._callback then
            self._callback(self.Value)
        end
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
        self.InputBox.BackgroundColor3 = t.Surface
        self.InputBox.TextColor3 = t.Text
        self.InputBox.PlaceholderColor3 = t.TextSecondary
    end))

    return self
end

function Textbox:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Textbox
