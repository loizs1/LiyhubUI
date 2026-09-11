-- language: luau, file: Demo/Demo.client.luau
local NovaUI = require(game:GetService("ReplicatedStorage"):WaitForChild("NovaUI"))

local Window = NovaUI:CreateWindow({
    Title = "NovaUI",
    Subtitle = "Developer Toolkit",
    Size = UDim2.fromOffset(750, 500),
    Theme = "Midnight",
    Resizable = true,
    Draggable = true,
})

-- Notification on load
NovaUI:Notify({
    Title = "NovaUI Framework",
    Content = "Library loaded successfully!",
    Type = "Success",
    Duration = 4,
})

-- 1. Dashboard Tab
local Dashboard = Window:AddTab("Dashboard", "◉")

local GeneralSec = Dashboard:AddSection("General Options", "Left")
GeneralSec:AddToggle({
    Name = "Framework Active",
    Default = true,
    Callback = function(val)
        NovaUI:Notify({ Title = "Toggle", Content = "Framework Active: " .. tostring(val), Type = "Info" })
    end,
})

GeneralSec:AddSlider({
    Name = "Target Frame Rate",
    Min = 30,
    Max = 240,
    Default = 60,
    Increment = 5,
    Callback = function(val)
        print("Frame rate set to:", val)
    end,
})

GeneralSec:AddButton({
    Name = "Send Notification",
    Description = "Triggers a test notification toast",
    Callback = function()
        NovaUI:Notify({ Title = "Action Triggered", Content = "Button click registered!", Type = "Success" })
    end,
})

local PresetSec = Dashboard:AddSection("Configuration", "Right")
PresetSec:AddDropdown({
    Name = "Graphics Quality",
    Options = { "Performance", "Balanced", "Ultra" },
    Default = "Balanced",
    Callback = function(val)
        print("Graphics mode:", val)
    end,
})

PresetSec:AddMultiDropdown({
    Name = "Active Modules",
    Options = { "Anti-Aliasing", "Bloom", "Shadows", "Raytracing" },
    Default = { "Shadows" },
    Callback = function(vals)
        print("Modules active:", table.concat(vals, ", "))
    end,
})

PresetSec:AddKeybind({
    Name = "Menu Toggle Key",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        NovaUI:Notify({ Title = "Keybind Updated", Content = "New key: " .. key.Name, Type = "Warning" })
    end,
})

-- 2. Player Tab
local Player = Window:AddTab("Player", "●")
local MovementSec = Player:AddSection("Movement", "Left")
MovementSec:AddSlider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 100,
    Default = 16,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.WalkSpeed = v
        end
    end,
})

MovementSec:AddSlider({
    Name = "JumpPower",
    Min = 50,
    Max = 200,
    Default = 50,
    Callback = function(v)
        local char = game.Players.LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") then
            char.Humanoid.JumpPower = v
        end
    end,
})

local ProfileSec = Player:AddSection("Profile Options", "Right")
ProfileSec:AddToggle({
    Name = "Show Bottom Profile",
    Default = true,
    Callback = function(visible)
        Window:SetProfileVisible(visible)
    end,
})

-- 3. Visuals Tab
local Visuals = Window:AddTab("Visuals", "◈")
local LightingSec = Visuals:AddSection("Lighting Adjustments", "Left")
LightingSec:AddColorPicker({
    Name = "Accent Color Swatch",
    Default = Color3.fromRGB(110, 95, 245),
    Callback = function(col)
        print("Selected accent:", col)
    end,
})

LightingSec:AddTextbox({
    Name = "Custom Tag",
    Placeholder = "Enter custom label...",
    Callback = function(txt)
        print("Custom tag set:", txt)
    end,
})

-- 4. Interface Tab
local Interface = Window:AddTab("Interface", "⚙")
local ScaleSec = Interface:AddSection("Scale & Scaling", "Left")
ScaleSec:AddSlider({
    Name = "Global Scale",
    Min = 75,
    Max = 130,
    Default = 100,
    Increment = 5,
    Callback = function(scalePercent)
        NovaUI:SetScale(scalePercent / 100)
    end,
})

ScaleSec:AddParagraph({
    Title = "Responsive Info",
    Content = "NovaUI supports UI scaling via UIScale without breaking position math or text bounds.",
})

return {}
