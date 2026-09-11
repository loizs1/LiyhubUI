-- language: luau, file: NovaUI/Core/State.luau
local Constants = require(script.Parent.Parent.Utils.Constants)
local Types = require(script.Parent.Parent.Utils.Types)

local State = {
    Scale = 1.0,
    SizePreset = "Normal" :: Types.SizePreset,
    DevicePreset = "PC" :: Types.DevicePreset,
    AnimationsEnabled = true,
    ReduceMotion = false,
    _listeners = {}
}

function State.SetScale(scale: number)
    scale = math.clamp(scale, 0.75, 1.30)
    State.Scale = scale
    State._notify("Scale", scale)
end

function State.SetSizePreset(preset: Types.SizePreset)
    if Constants.SizePresets[preset] then
        State.SizePreset = preset
        State.SetScale(Constants.SizePresets[preset])
    end
end

function State.SetDevicePreset(preset: Types.DevicePreset)
    if Constants.DevicePresets[preset] then
        State.DevicePreset = preset
        State.SetScale(Constants.DevicePresets[preset])
    end
end

function State.SetAnimationsEnabled(enabled: boolean)
    State.AnimationsEnabled = enabled
    State._notify("AnimationsEnabled", enabled)
end

function State.SetReduceMotion(enabled: boolean)
    State.ReduceMotion = enabled
    State._notify("ReduceMotion", enabled)
end

function State.Subscribe(key: string, callback: (any) -> ())
    if not State._listeners[key] then
        State._listeners[key] = {}
    end
    table.insert(State._listeners[key], callback)
    return function()
        local idx = table.find(State._listeners[key], callback)
        if idx then
            table.remove(State._listeners[key], idx)
        end
    end
end

function State._notify(key: string, value: any)
    if State._listeners[key] then
        for _, cb in ipairs(State._listeners[key]) do
            task.spawn(cb, value)
        end
    end
end

return State
