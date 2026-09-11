-- language: luau, file: NovaUI/Services/Notification.luau
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Animation = require(script.Parent.Parent.Services.Animation)
local Types = require(script.Parent.Parent.Utils.Types)

local Notification = {}
local container: Frame? = nil

local function getContainer(): Frame
    if container and container.Parent then
        return container
    end

    local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
    local screenGui = playerGui:FindFirstChild("NovaUINotifications")
    if not screenGui then
        screenGui = Utility.Create("ScreenGui", {
            Name = "NovaUINotifications",
            ResetOnSpawn = false,
            DisplayOrder = 999,
            Parent = playerGui,
        })
    end

    container = Utility.Create("Frame", {
        Name = "Container",
        Size = UDim2.new(0, 300, 1, -40),
        Position = UDim2.new(1, -320, 0, 20),
        BackgroundTransparency = 1,
        Parent = screenGui,
    }) :: Frame

    Utility.Create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
        Padding = UDim.new(0, 10),
        Parent = container,
    })

    return container!
end

function Notification.Notify(config: Types.NotificationConfig)
    local parent = getContainer()
    local theme = Theme.GetTheme()

    local typeColor = theme.Accent
    if config.Type == "Success" then
        typeColor = theme.Success
    elseif config.Type == "Warning" then
        typeColor = theme.Warning
    elseif config.Type == "Error" then
        typeColor = theme.Error
    end

    local notifFrame = Utility.Create("Frame", {
        Name = "Notification",
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundColor3 = theme.Surface,
        BackgroundTransparency = 0.1,
        ClipsDescendants = true,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(notifFrame, 8)
    local stroke = Utility.AddStroke(notifFrame, theme.Border, 1)
    Utility.AddPadding(notifFrame, 12, 12, 14, 14)

    local accentBar = Utility.Create("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(0, 4, 1, 0),
        Position = UDim2.new(0, -14, 0, 0),
        BackgroundColor3 = typeColor,
        BorderSizePixel = 0,
        Parent = notifFrame,
    })

    local titleLabel = Utility.Create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, -10, 0, 18),
        Position = UDim2.new(0, 4, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = config.Title or "Notification",
        TextColor3 = theme.Text,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame,
    })

    local contentLabel = Utility.Create("TextLabel", {
        Name = "Content",
        Size = UDim2.new(1, -10, 0, 0),
        Position = UDim2.new(0, 4, 0, 20),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = config.Content or "",
        TextColor3 = theme.TextSecondary,
        TextSize = 12,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notifFrame,
    })

    Theme.OnThemeChanged(function(t)
        notifFrame.BackgroundColor3 = t.Surface
        stroke.Color = t.Border
        titleLabel.TextColor3 = t.Text
        contentLabel.TextColor3 = t.TextSecondary
    end)

    -- Slide in animation
    notifFrame.Position = UDim2.new(1, 300, 0, 0)
    Animation.Tween(notifFrame, 0.3, { Position = UDim2.new(0, 0, 0, 0) })

    task.delay(config.Duration or 3, function()
        if notifFrame and notifFrame.Parent then
            local tween = Animation.Tween(notifFrame, 0.3, { Position = UDim2.new(1, 300, 0, 0) })
            if tween then
                tween.Completed:Connect(function()
                    notifFrame:Destroy()
                end)
            else
                notifFrame:Destroy()
            end
        end
    end)
end

return Notification
