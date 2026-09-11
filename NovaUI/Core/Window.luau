-- language: luau, file: NovaUI/Core/Window.luau
local Players = game:GetService("Players")
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local State = require(script.Parent.Parent.Core.State)
local Maid = require(script.Parent.Parent.Core.Maid)
local Animation = require(script.Parent.Parent.Services.Animation)
local Input = require(script.Parent.Parent.Services.Input)
local Types = require(script.Parent.Parent.Utils.Types)

local Sidebar = require(script.Parent.Parent.UI.Sidebar)
local Settings = require(script.Parent.Parent.UI.Settings)
local Tab = require(script.Parent.Tab)

local Window = {}
Window.__index = Window

function Window.new(config: Types.WindowConfig)
    local self = setmetatable({}, Window)
    self._maid = Maid.new()
    self._tabs = {}
    self._activeTab = nil
    self._inSettings = false

    if config.Theme then
        Theme.SetTheme(config.Theme)
    end
    local theme = Theme.GetTheme()

    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    self.ScreenGui = Utility.Create("ScreenGui", {
        Name = "NovaUI_ScreenGui",
        ResetOnSpawn = false,
        DisplayOrder = 100,
        Parent = playerGui,
    }) :: ScreenGui

    self.UIScale = Utility.Create("UIScale", {
        Scale = State.Scale,
        Parent = self.ScreenGui,
    }) :: UIScale

    self._maid:GiveTask(State.Subscribe("Scale", function(scale)
        self.UIScale.Scale = scale
    end))

    -- Main Container Frame
    local initSize = config.Size or UDim2.fromOffset(720, 480)
    self.MainFrame = Utility.Create("Frame", {
        Name = "MainFrame",
        Size = initSize,
        Position = UDim2.new(0.5, -initSize.X.Offset / 2, 0.5, -initSize.Y.Offset / 2),
        BackgroundColor3 = theme.Background,
        ClipsDescendants = true,
        Parent = self.ScreenGui,
    }) :: Frame

    Utility.AddCorner(self.MainFrame, 10)
    local mainStroke = Utility.AddStroke(self.MainFrame, theme.Border, 1)

    -- Top bar controls
    self.TopBar = Utility.Create("Frame", {
        Name = "TopBar",
        Size = UDim2.new(1, 0, 0, 32),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.MainFrame,
    })

    local ctrlContainer = Utility.Create("Frame", {
        Size = UDim2.new(0, 60, 1, 0),
        Position = UDim2.new(1, -60, 0, 0),
        BackgroundTransparency = 1,
        Parent = self.TopBar,
    })
    Utility.Create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 6),
        Parent = ctrlContainer,
    })

    local closeBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(235, 87, 87),
        Text = "",
        Parent = ctrlContainer,
    }) :: TextButton
    Utility.AddCorner(closeBtn, 7)

    local minBtn = Utility.Create("TextButton", {
        Size = UDim2.new(0, 14, 0, 14),
        BackgroundColor3 = Color3.fromRGB(242, 201, 76),
        Text = "",
        Parent = ctrlContainer,
    }) :: TextButton
    Utility.AddCorner(minBtn, 7)

    closeBtn.MouseButton1Click:Connect(function()
        self:Destroy()
    end)

    minBtn.MouseButton1Click:Connect(function()
        self.MainFrame.Visible = not self.MainFrame.Visible
    end)

    if config.Draggable ~= false then
        Input.MakeDraggable(self.MainFrame, self.TopBar)
    end

    if config.Resizable ~= false then
        local resizeHandle = Utility.Create("Frame", {
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(1, -14, 1, -14),
            BackgroundTransparency = 1,
            Parent = self.MainFrame,
        })
        Input.MakeResizable(self.MainFrame, resizeHandle, Vector2.new(550, 360))
    end

    -- Sidebar
    self.Sidebar = Sidebar.new(self.MainFrame, function()
        self:ToggleSettings()
    end)

    if config.Title then
        self.Sidebar.TitleLabel.Text = config.Title
    end
    if config.Subtitle then
        self.Sidebar.SubtitleLabel.Text = config.Subtitle
    end

    -- Main Content Area
    self.ContentArea = Utility.Create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(0.76, -1, 1, -32),
        Position = UDim2.new(0.24, 1, 0, 32),
        BackgroundColor3 = theme.Background,
        BorderSizePixel = 0,
        Parent = self.MainFrame,
    }) :: Frame

    -- Settings Page
    self.SettingsView = Settings.new(self.ContentArea)

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.MainFrame.BackgroundColor3 = t.Background
        mainStroke.Color = t.Border
        self.ContentArea.BackgroundColor3 = t.Background
    end))

    -- Entrance Animation
    self.MainFrame.Size = UDim2.new(0, 0, 0, 0)
    Animation.Spring(self.MainFrame, { Size = initSize }, 0.3)

    return self
end

function Window:AddTab(name: string, icon: string?): Tab
    local newTab = Tab.new(self.ContentArea, name)
    table.insert(self._tabs, newTab)

    self.Sidebar:AddTabButton(name, icon, function()
        self:SelectTab(newTab)
    end)

    if #self._tabs == 1 then
        self:SelectTab(newTab)
    end

    return newTab
end

function Window:SelectTab(targetTab)
    self._inSettings = false
    self.SettingsView:SetVisible(false)
    for _, tab in ipairs(self._tabs) do
        if tab == targetTab then
            tab:SetVisible(true)
        else
            tab:SetVisible(false)
        end
    end
    self._activeTab = targetTab
end

function Window:ToggleSettings()
    self._inSettings = not self._inSettings
    if self._inSettings then
        for _, tab in ipairs(self._tabs) do
            tab:SetVisible(false)
        end
        self.SettingsView:SetVisible(true)
    else
        if self._activeTab then
            self:SelectTab(self._activeTab)
        end
    end
end

function Window:OpenSettings()
    if not self._inSettings then
        self:ToggleSettings()
    end
end

function Window:CloseSettings()
    if self._inSettings then
        self:ToggleSettings()
    end
end

function Window:SetProfileVisible(visible: boolean)
    self.Sidebar:SetProfileVisible(visible)
end

function Window:Destroy()
    self._maid:Destroy()
    self.Sidebar:Destroy()
    self.SettingsView:Destroy()
    for _, tab in ipairs(self._tabs) do
        tab:Destroy()
    end
    if self.ScreenGui then self.ScreenGui:Destroy() end
end

return Window
