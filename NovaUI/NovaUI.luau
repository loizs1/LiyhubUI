-- language: luau, file: NovaUI/NovaUI.luau
local Window = require(script.Core.Window)
local Theme = require(script.Core.Theme)
local State = require(script.Core.State)
local Notification = require(script.Services.Notification)
local Types = require(script.Utils.Types)

local NovaUI = {}

function NovaUI:CreateWindow(config: Types.WindowConfig)
    return Window.new(config)
end

function NovaUI:RegisterTheme(name: string, themeColors: Types.Theme)
    Theme.RegisterTheme(name, themeColors)
end

function NovaUI:SetTheme(name: string)
    Theme.SetTheme(name)
end

function NovaUI:SetScale(scale: number)
    State.SetScale(scale)
end

function NovaUI:SetSizePreset(preset: Types.SizePreset)
    State.SetSizePreset(preset)
end

function NovaUI:SetDevicePreset(preset: Types.DevicePreset)
    State.SetDevicePreset(preset)
end

function NovaUI:SetAnimationsEnabled(enabled: boolean)
    State.SetAnimationsEnabled(enabled)
end

function NovaUI:SetReduceMotion(enabled: boolean)
    State.SetReduceMotion(enabled)
end

function NovaUI:Notify(config: Types.NotificationConfig)
    Notification.Notify(config)
end

return NovaUI
