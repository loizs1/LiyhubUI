-- language: luau, file: NovaUI/Components/MultiDropdown.luau
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local MultiDropdown = {}
MultiDropdown.__index = MultiDropdown

function MultiDropdown.new(parent: Instance, config: { Name: string, Options: { string }, Default: { string }?, Callback: ({ string }) -> () })
    local self = setmetatable({}, MultiDropdown)
    self._maid = Maid.new()
    self.Options = config.Options or {}
    self.Selected = {}
    for _, item in ipairs(config.Default or {}) do
        self.Selected[item] = true
    end
    self._callback = config.Callback
    self.Open = false

    local theme = Theme.GetTheme()

    self.Frame = Utility.Create("Frame", {
        Name = "Component_MultiDropdown",
        Size = UDim2.new(1, 0, 0, 36),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.SurfaceSecondary,
        ClipsDescendants = true,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 6)
    local stroke = Utility.AddStroke(self.Frame, theme.Border, 1)
    Utility.AddPadding(self.Frame, 6, 6, 10, 10)

    self.HeaderBtn = Utility.Create("TextButton", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = "",
        Parent = self.Frame,
    }) :: TextButton

    self.TextLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0.5, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamMedium,
        Text = config.Name or "MultiDropdown",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.HeaderBtn,
    })

    self.ValueLabel = Utility.Create("TextLabel", {
        Size = UDim2.new(0.5, -20, 1, 0),
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = self:_getFormattedText() .. "  ▼",
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        Parent = self.HeaderBtn,
    })

    self.OptionContainer = Utility.Create("Frame", {
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, 28),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.Frame,
    })

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 4),
        Parent = self.OptionContainer,
    })

    self:_renderOptions()

    self._maid:GiveTask(self.HeaderBtn.MouseButton1Click:Connect(function()
        self:ToggleOpen()
    end))

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        stroke.Color = t.Border
        self.TextLabel.TextColor3 = t.Text
        self.ValueLabel.TextColor3 = t.TextSecondary
    end))

    return self
end

function MultiDropdown:_getFormattedText(): string
    local list = {}
    for opt, sel in pairs(self.Selected) do
        if sel then table.insert(list, opt) end
    end
    if #list == 0 then return "None" end
    return table.concat(list, ", ")
end

function MultiDropdown:_renderOptions()
    for _, child in ipairs(self.OptionContainer:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end

    local theme = Theme.GetTheme()
    for _, option in ipairs(self.Options) do
        local isSel = self.Selected[option] == true
        local optBtn = Utility.Create("TextButton", {
            Size = UDim2.new(1, 0, 0, 26),
            BackgroundColor3 = isSel and theme.Accent or theme.Surface,
            Font = Enum.Font.Gotham,
            Text = (isSel and "✓ " or "  ") .. option,
            TextColor3 = theme.Text,
            TextSize = 12,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = self.OptionContainer,
        })
        Utility.AddCorner(optBtn, 4)
        Utility.AddPadding(optBtn, 0, 0, 8, 8)

        optBtn.MouseButton1Click:Connect(function()
            self.Selected[option] = not self.Selected[option]
            self:_renderOptions()
            self.ValueLabel.Text = self:_getFormattedText() .. (self.Open and "  ▲" or "  ▼")
            if self._callback then
                local res = {}
                for k, v in pairs(self.Selected) do
                    if v then table.insert(res, k) end
                end
                self._callback(res)
            end
        end)
    end
end

function MultiDropdown:ToggleOpen(state: boolean?)
    self.Open = (state ~= nil) and state or not self.Open
    self.OptionContainer.Visible = self.Open
    self.ValueLabel.Text = self:_getFormattedText() .. (self.Open and "  ▲" or "  ▼")
end

function MultiDropdown:Destroy()
    self._maid:Destroy()
    if self.Frame then self.Frame:Destroy() end
end

return MultiDropdown
