-- language: luau, file: NovaUI/Core/Section.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local Button = require(script.Parent.Parent.Components.Button)
local Toggle = require(script.Parent.Parent.Components.Toggle)
local Slider = require(script.Parent.Parent.Components.Slider)
local Dropdown = require(script.Parent.Parent.Components.Dropdown)
local MultiDropdown = require(script.Parent.Parent.Components.MultiDropdown)
local Keybind = require(script.Parent.Parent.Components.Keybind)
local Textbox = require(script.Parent.Parent.Components.Textbox)
local ColorPicker = require(script.Parent.Parent.Components.ColorPicker)
local Label = require(script.Parent.Parent.Components.Label)
local Paragraph = require(script.Parent.Parent.Components.Paragraph)

local Section = {}
Section.__index = Section

function Section.new(parent: Instance, name: string)
    local self = setmetatable({}, Section)
    self._maid = Maid.new()

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Section_" .. name,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Surface,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 8)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 12, 12, 12, 12)

    self.Layout = Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 8),
        Parent = self.Frame,
    })

    self.TitleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = string.upper(name),
        TextColor3 = theme.Text,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.Surface
        stroke.Color = t.Border
        self.TitleLabel.TextColor3 = t.Text
    end))

    return self
end

function Section:AddButton(config)
    return Button.new(self.Frame, config)
end

function Section:AddToggle(config)
    return Toggle.new(self.Frame, config)
end

function Section:AddSlider(config)
    return Slider.new(self.Frame, config)
end

function Section:AddDropdown(config)
    return Dropdown.new(self.Frame, config)
end

function Section:AddMultiDropdown(config)
    return MultiDropdown.new(self.Frame, config)
end

function Section:AddKeybind(config)
    return Keybind.new(self.Frame, config)
end

function Section:AddTextbox(config)
    return Textbox.new(self.Frame, config)
end

function Section:AddColorPicker(config)
    return ColorPicker.new(self.Frame, config)
end

function Section:AddLabel(text: string)
    return Label.new(self.Frame, text)
end

function Section:AddParagraph(config)
    return Paragraph.new(self.Frame, config)
end

function Section:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Section
