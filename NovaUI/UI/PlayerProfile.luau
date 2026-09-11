-- language: luau, file: NovaUI/UI/PlayerProfile.luau
local Players = game:GetService("Players")
local Utility = require(script.Parent.Parent.Utils.Utility)
local Theme = require(script.Parent.Parent.Core.Theme)
local Maid = require(script.Parent.Parent.Core.Maid)

local PlayerProfile = {}
PlayerProfile.__index = PlayerProfile

function PlayerProfile.new(parent: Instance)
    local self = setmetatable({}, PlayerProfile)
    self._maid = Maid.new()
    self._visible = true

    local theme = Theme.GetTheme()
    local localPlayer = Players.LocalPlayer

    self.Frame = Utility.Create("Frame", {
        Name = "PlayerProfile",
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = theme.SurfaceSecondary,
        BackgroundTransparency = 0.5,
        Parent = parent,
    }) :: Frame

    Utility.AddCorner(self.Frame, 8)
    Utility.AddPadding(self.Frame, 6, 6, 8, 8)

    self.AvatarImage = Utility.Create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 0, 0.5, -18),
        BackgroundColor3 = theme.Surface,
        Image = "rbxasset://textures/ui/GuiImagePlaceholder.png",
        Parent = self.Frame,
    }) :: ImageLabel
    Utility.AddCorner(self.AvatarImage, 18)

    self.DisplayNameLabel = Utility.Create("TextLabel", {
        Name = "DisplayName",
        Size = UDim2.new(1, -46, 0, 16),
        Position = UDim2.new(0, 44, 0, 4),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = localPlayer and localPlayer.DisplayName or "Player",
        TextColor3 = theme.Text,
        TextSize = 13,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    }) :: TextLabel

    self.UsernameLabel = Utility.Create("TextLabel", {
        Name = "Username",
        Size = UDim2.new(1, -46, 0, 14),
        Position = UDim2.new(0, 44, 0, 20),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = localPlayer and ("@" .. localPlayer.Name) or "@username",
        TextColor3 = theme.TextSecondary,
        TextSize = 11,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Frame,
    }) :: TextLabel

    -- Load thumbnail safely
    if localPlayer then
        task.spawn(function()
            local success, content = pcall(function()
                return Players:GetUserThumbnailAsync(
                    localPlayer.UserId,
                    Enum.ThumbnailType.HeadShot,
                    Enum.ThumbnailSize.Size100x100
                )
            end)
            if success and content then
                self.AvatarImage.Image = content
            end
        end)
    end

    self._maid:GiveTask(Theme.OnThemeChanged(function(t)
        self.Frame.BackgroundColor3 = t.SurfaceSecondary
        self.AvatarImage.BackgroundColor3 = t.Surface
        self.DisplayNameLabel.TextColor3 = t.Text
        self.UsernameLabel.TextColor3 = t.TextSecondary
    end))

    return self
end

function PlayerProfile:SetVisible(visible: boolean)
    self._visible = visible
    self.Frame.Visible = visible
end

function PlayerProfile:Destroy()
    self._maid:Destroy()
    if self.Frame then
        self.Frame:Destroy()
    end
end

return PlayerProfile
