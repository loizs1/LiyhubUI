-- language: luau, file: NovaUI/Core/Tab.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)
local Section = require(script.Parent.Section)

local Tab = {}
Tab.__index = Tab

function Tab.new(parent: Instance, name: string)
    local self = setmetatable({}, Tab)
    self._maid = Maid.new()
    self.Name = name

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("ScrollingFrame", {
        Name = "Tab_" .. name,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = theme.Border,
        Visible = false,
        Parent = parent,
    }) :: ScrollingFrame

    Utility.AddPadding(self.Frame, 16, 16, 16, 16)

    -- Two-column layout container
    self.ColumnContainer = Utility.Create("Frame", {
        Name = "Columns",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = self.Frame,
    })

    self.LeftColumn = Utility.Create("Frame", {
        Name = "LeftColumn",
        Size = UDim2.new(0.49, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = self.ColumnContainer,
    })

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = self.LeftColumn,
    })

    self.RightColumn = Utility.Create("Frame", {
        Name = "RightColumn",
        Size = UDim2.new(0.49, 0, 0, 0),
        Position = UDim2.new(0.51, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Parent = self.ColumnContainer,
    })

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 12),
        Parent = self.RightColumn,
    })

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.ScrollBarImageColor3 = t.Border
    end))

    return self
end

function Tab:AddSection(name: string, column: ("Left" | "Right")?): Section
    local targetCol = (column == "Right") and self.RightColumn or self.LeftColumn
    return Section.new(targetCol, name)
end

function Tab:SetVisible(visible: boolean)
    self.Frame.Visible = visible
end

function Tab:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return Tab
