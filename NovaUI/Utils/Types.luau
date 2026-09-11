-- language: luau, file: NovaUI/Utils/Types.luau
export type Theme = {
    Background: Color3,
    Surface: Color3,
    SurfaceSecondary: Color3,
    Border: Color3,
    Text: Color3,
    TextSecondary: Color3,
    Accent: Color3,
    AccentHover: Color3,
    Success: Color3,
    Warning: Color3,
    Error: Color3,
}

export type ThemeName = "Midnight" | "Graphite" | "Slate"
export type SizePreset = "Small" | "Normal" | "Large"
export type DevicePreset = "PC" | "Tablet" | "Android"
export type NotificationType = "Info" | "Success" | "Warning" | "Error"

export type WindowConfig = {
    Title: string?,
    Subtitle: string?,
    Size: UDim2?,
    Theme: ThemeName?,
    Resizable: boolean?,
    Draggable: boolean?,
}

export type NotificationConfig = {
    Title: string,
    Content: string,
    Type: NotificationType?,
    Duration: number?,
}

return {}
