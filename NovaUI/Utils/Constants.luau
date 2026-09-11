-- language: luau, file: NovaUI/Utils/Constants.luau
local Types = require(script.Parent.Types)

local Constants = {}

Constants.SizePresets = {
    Small = 0.85,
    Normal = 1.00,
    Large = 1.15,
}

Constants.DevicePresets = {
    PC = 1.00,
    Tablet = 1.05,
    Android = 1.10,
}

Constants.Themes = {
    Midnight = {
        Background = Color3.fromRGB(15, 18, 26),
        Surface = Color3.fromRGB(24, 28, 40),
        SurfaceSecondary = Color3.fromRGB(32, 38, 54),
        Border = Color3.fromRGB(44, 52, 74),
        Text = Color3.fromRGB(240, 243, 250),
        TextSecondary = Color3.fromRGB(140, 150, 175),
        Accent = Color3.fromRGB(110, 95, 245),
        AccentHover = Color3.fromRGB(130, 118, 255),
        Success = Color3.fromRGB(46, 204, 113),
        Warning = Color3.fromRGB(241, 196, 15),
        Error = Color3.fromRGB(231, 76, 60),
    },
    Graphite = {
        Background = Color3.fromRGB(20, 20, 22),
        Surface = Color3.fromRGB(30, 30, 34),
        SurfaceSecondary = Color3.fromRGB(42, 42, 48),
        Border = Color3.fromRGB(58, 58, 66),
        Text = Color3.fromRGB(245, 245, 245),
        TextSecondary = Color3.fromRGB(150, 150, 160),
        Accent = Color3.fromRGB(0, 168, 204),
        AccentHover = Color3.fromRGB(40, 190, 225),
        Success = Color3.fromRGB(40, 180, 110),
        Warning = Color3.fromRGB(230, 160, 40),
        Error = Color3.fromRGB(220, 60, 60),
    },
    Slate = {
        Background = Color3.fromRGB(22, 27, 34),
        Surface = Color3.fromRGB(33, 40, 50),
        SurfaceSecondary = Color3.fromRGB(45, 54, 68),
        Border = Color3.fromRGB(60, 72, 90),
        Text = Color3.fromRGB(235, 240, 248),
        TextSecondary = Color3.fromRGB(145, 158, 175),
        Accent = Color3.fromRGB(56, 139, 253),
        AccentHover = Color3.fromRGB(88, 160, 255),
        Success = Color3.fromRGB(57, 211, 83),
        Warning = Color3.fromRGB(210, 153, 34),
        Error = Color3.fromRGB(248, 81, 73),
    },
}

return Constants
