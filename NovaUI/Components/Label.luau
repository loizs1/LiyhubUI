-- language: luau, file: NovaUI/Components/Label.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local Label = {}
Label.__index = Label

function Label.new(parent: Instance, text: string)
    local self = setmetatable({}, Label)
    self._maid = Maid.new()

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Label",
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Parent = parent,
    }) :: Frame

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = text or "Label",
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.TextLabel.TextColor3 = t.TextSecondary
    end))

    return self
end

function Label:Set(text: string)
    self.TextLabel.Text = text
end

function Label:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Label
