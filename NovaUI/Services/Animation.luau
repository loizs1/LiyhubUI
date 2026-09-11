-- language: luau, file: NovaUI/Services/Animation.luau
local TweenService = game:GetService("TweenService")
local State = require(script.Parent.Parent.Core.State)

local Animation = {}

function Animation.Tween(instance: Instance, duration: number, properties: { [string]: any }, style: Enum.EasingStyle?, direction: Enum.EasingDirection?): Tween?
    if not State.AnimationsEnabled or State.ReduceMotion then
        for prop, val in pairs(properties) do
            (instance :: any)[prop] = val
        end
        return nil
    end

    local info = TweenInfo.new(
        duration,
        style or Enum.EasingStyle.Quart,
        direction or Enum.EasingDirection.Out
    )
    local tween = TweenService:Create(instance, info, properties)
    tween:Play()
    return tween
end

function Animation.Spring(instance: Instance, properties: { [string]: any }, speed: number?): Tween?
    return Animation.Tween(instance, speed or 0.25, properties, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
end

return Animation
