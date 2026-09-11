# NovaUI Framework

NovaUI is a polished, modular, and responsive UI framework written in Luau for Roblox.

## Features

- **Navigation Sidebar**: Left sidebar featuring scrollable tab selection and anchored footer.
- **Player Profile**: Automatic client profile detection (`Players.LocalPlayer`) displaying DisplayName, Username, and Avatar thumbnail via `GetUserThumbnailAsync`.
- **Built-in Settings Panel**: Easy scaling adjustments, device presets (PC, Tablet, Android), size presets (Small, Normal, Large), and live theme switches.
- **Global UIScale**: Smooth, uniform interface scaling bounded between `0.75` and `1.30`.
- **Themes**: Midnight, Graphite, Slate built-in themes with runtime live updating.
- **Responsive Layout**: Two-column layout per tab with `UIListLayout` automatic Y sizing.
- **Complete Component Suite**:
  - Button
  - Toggle
  - Slider
  - Dropdown
  - MultiDropdown
  - Keybind
  - Textbox
  - ColorPicker
  - Label
  - Paragraph
- **Toast Notifications**: Built-in notification service with customizable types (`Info`, `Success`, `Warning`, `Error`) and animations.
- **Clean Lifecycle**: Maid-driven signal cleanup and instance destruction without memory leaks.

---

## Directory Structure

```text
NovaUI/
├── NovaUI.luau
├── Core/
│   ├── Window.luau
│   ├── Tab.luau
│   ├── Section.luau
│   ├── Theme.luau
│   ├── State.luau
│   └── Maid.luau
├── Components/
│   ├── Button.luau
│   ├── Toggle.luau
│   ├── Slider.luau
│   ├── Dropdown.luau
│   ├── MultiDropdown.luau
│   ├── Keybind.luau
│   ├── Textbox.luau
│   ├── ColorPicker.luau
│   ├── Label.luau
│   └── Paragraph.luau
├── Services/
│   ├── Animation.luau
│   ├── Input.luau
│   └── Notification.luau
├── UI/
│   ├── Sidebar.luau
│   ├── PlayerProfile.luau
│   └── Settings.luau
└── Utils/
    ├── Types.luau
    ├── Constants.luau
    └── Utility.luau
```

---

## Quick Start Example

```lua
local NovaUI = require(game:GetService("ReplicatedStorage"):WaitForChild("NovaUI"))

local Window = NovaUI:CreateWindow({
    Title = "NovaUI",
    Subtitle = "Developer Toolkit",
    Size = UDim2.fromOffset(750, 500),
    Theme = "Midnight",
    Resizable = true,
    Draggable = true
})

local Dashboard = Window:AddTab("Dashboard", "◉")
local Section = Dashboard:AddSection("General Options", "Left")

Section:AddToggle({
    Name = "Enable Feature",
    Default = true,
    Callback = function(enabled)
        print("Feature state:", enabled)
    end
})

NovaUI:Notify({
    Title = "Welcome",
    Content = "NovaUI initialized!",
    Type = "Success",
    Duration = 3
})
```

---

## API Summary

### Window
- `Window:AddTab(name: string, icon: string?): Tab`
- `Window:SetProfileVisible(visible: boolean)`
- `Window:OpenSettings()`
- `Window:CloseSettings()`
- `Window:Destroy()`

### Components
- `Section:AddButton(config)`
- `Section:AddToggle(config)`
- `Section:AddSlider(config)`
- `Section:AddDropdown(config)`
- `Section:AddMultiDropdown(config)`
- `Section:AddKeybind(config)`
- `Section:AddTextbox(config)`
- `Section:AddColorPicker(config)`
- `Section:AddLabel(text)`
- `Section:AddParagraph(config)`

### Global Settings & Presets
- `NovaUI:SetScale(scale)`
- `NovaUI:SetSizePreset("Small" | "Normal" | "Large")`
- `NovaUI:SetDevicePreset("PC" | "Tablet" | "Android")`
- `NovaUI:SetTheme("Midnight" | "Graphite" | "Slate")`
- `NovaUI:Notify(config)`
