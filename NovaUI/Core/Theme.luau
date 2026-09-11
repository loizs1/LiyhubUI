-- language: luau, file: NovaUI/Core/Theme.luau
local Constants = require(script.Parent.Parent.Utils.Constants)
local Types = require(script.Parent.Parent.Utils.Types)

local Theme = {}
Theme._themes = {}
Theme._currentThemeName = "Midnight"
Theme._listeners = {}

for name, colors in pairs(Constants.Themes) do
    Theme._themes[name] = colors
end

function Theme.RegisterTheme(name: string, themeColors: Types.Theme)
    Theme._themes[name] = themeColors
end

function Theme.GetTheme(name: string?): Types.Theme
    local targetName = name or Theme._currentThemeName
    return Theme._themes[targetName] or Theme._themes.Midnight
end

function Theme.SetTheme(name: string)
    if not Theme._themes[name] then return end
    Theme._currentThemeName = name
    local theme = Theme._themes[name]
    for _, callback in ipairs(Theme._listeners) do
        task.spawn(callback, theme, name)
    end
end

function Theme.OnThemeChanged(callback: (Types.Theme, string) -> ()): () -> ()
    table.insert(Theme._listeners, callback)
    return function()
        local idx = table.find(Theme._listeners, callback)
        if idx then
            table.remove(Theme._listeners, idx)
        end
    end
end

function Theme.GetCurrentThemeName(): string
    return Theme._currentThemeName
end

return Theme
