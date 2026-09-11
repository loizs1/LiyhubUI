-- language: luau, file: NovaUI/Components/Paragraph.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local Paragraph = {}
Paragraph.__index = Paragraph

function Paragraph.new(parent: Instance, config: { Title: string, Content: string })
    local self = setmetatable({}, Paragraph)
    self._maid = Maid.new()

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_Paragraph",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.SurfaceSecondary,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 10, 10, 12, 12)

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = self.Frame,
    })

    self.TitleLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Information",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self.ContentLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = config.Content or "",
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    })

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TitleLabel.TextColor3 = t.Text
        self.ContentLabel.TextColor3 = t.TextSecondary
    end))

    return self
end

function Paragraph:Set(title: string, content: string)
    self.TitleLabel.Text = title
    self.ContentLabel.Text = content
end

function Paragraph:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Paragraph
