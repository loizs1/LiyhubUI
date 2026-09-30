# LiyhubUI Framework (WindUI Integration)

LiyhubUI 2.0 is a dark-modern, high-performance UI framework powered by the **WindUI** engine ([Footagesus/WindUI](https://github.com/Footagesus/WindUI)). It provides deep procedural styling, smooth animations, native draggable mobile floating buttons, Lucide/Solar icons, and multi-game execution compatibility for both Roblox Studio and Executors.

---

## 🚀 Instant Loadstring

Load LiyhubUI into any script with a single line:

```luau
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
```

---

## 🎨 Liyhub Obsidian Theme

LiyhubUI automatically injects and activates the **`Liyhub`** obsidian palette:
- **Canvas / Background**: `#0A0A0D` (Pure deep obsidian)
- **Primary / Accent**: `#00A2FF` (Electric Liyhub Cyan)
- **Active Toggle**: `#00E5FF` (Neon Cyan)
- **Cards & Dialogs**: `#101015` / `#121217`
- **Text**: `#FFFFFF` (Crisp solid white) & `#8C91A5` (Subdued labels)

You can also use any standard WindUI theme (`Dark`, `Light`, `Rose`, `Plant`, `Midnight`, `Cyberpunk`) via `Window:SetTheme("Dark")` or `Liyhub:SetTheme("Liyhub")`.

---

## 🛠️ Complete Component API Reference

LiyhubUI supports **both** classic Liyhub component calls and native WindUI calls:

### 1. Creating the Window
```luau
local Window = Liyhub:CreateWindow({
    Title = "Liyhub | Game Name",
    Author = "Liyhub Team",
    Folder = "Liyhub_GameConfig",
    Icon = "solar:box-bold-duotone", -- Solar or Lucide icon
    Theme = "Liyhub",                -- Default is Liyhub
    Size = UDim2.fromOffset(740, 490),
    OpenButton = {                   -- Built-in Draggable Mobile Floating Button
        Enabled = true,
        OnlyMobile = false,
        Scale = 0.5,
    }
})
```

### 2. Tabs & Sections
```luau
-- Add Tab (Accepts Name and Icon)
local CombatTab = Window:AddTab("Combat", "solar:target-bold-duotone")

-- Add Section
local AimSec = CombatTab:AddSection("Targeting")
```

### 3. Component Suite
```luau
-- Toggle
AimSec:AddToggle({
    Name = "Silent Aim",
    Desc = "Redirects projectile trajectory directly to enemy hitbox.",
    Default = false,
    Callback = function(state: boolean)
        -- logic
    end
})

-- Slider
AimSec:AddSlider({
    Name = "Hit Chance %",
    Desc = "Targeting probability calculation.",
    Min = 0,
    Max = 100,
    Default = 85,
    Step = 1,
    Callback = function(val: number)
        -- logic
    end
})

-- Dropdown (Single Select)
AimSec:AddDropdown({
    Name = "Target Hitbox",
    Options = { "Head", "HumanoidRootPart", "Torso", "Random" },
    Default = "Head",
    Callback = function(choice: string)
        -- logic
    end
})

-- MultiDropdown (Multi Select)
AimSec:AddMultiDropdown({
    Name = "Target Filter",
    Options = { "Enemies", "NPCs", "Friends", "Downed" },
    Default = { "Enemies" },
    Callback = function(selectedList: {string})
        -- logic
    end
})

-- ColorPicker
AimSec:AddColorPicker({
    Name = "Chams Accent Color",
    Default = Color3.fromRGB(0, 162, 255),
    Callback = function(col: Color3)
        -- logic
    end
})

-- Keybind
AimSec:AddKeybind({
    Name = "Trigger Keybind",
    Default = Enum.KeyCode.RightControl,
    Callback = function(key: Enum.KeyCode)
        -- logic
    end
})

-- Textbox / Input
AimSec:AddTextbox({
    Name = "Target Player",
    Placeholder = "Enter username...",
    Default = "",
    Callback = function(text: string)
        -- logic
    end
})

-- Button
AimSec:AddButton({
    Name = "Refresh Pool",
    Desc = "Instantly clears and resets all targeting caches.",
    Callback = function()
        -- logic
    end
})

-- Paragraph & Labels
AimSec:AddParagraph({
    Title = "Notice",
    Content = "All features run asynchronously without lag spikes."
})
AimSec:AddLabel("Status: Active")

-- Divider
AimSec:AddDivider()

-- Dual-Widget Row (Side-by-side grouped elements)
local row = AimSec:AddRow()
row:AddToggle({ Name = "Auto Parry", Default = false, Callback = function(s) end })
row:AddKeybind({ Name = "Parry Key", Default = Enum.KeyCode.F, Callback = function(k) end })
```

### 4. Notifications & Toasts
```luau
Liyhub:Notify({
    Title = "Liyhub",
    Content = "Script loaded cleanly.",
    Duration = 3,
    Type = "Success" -- "Success" | "Info" | "Warning"
})
```

---

## ⚡ Direct WindUI Engine Access

You can also bypass the wrapper and directly interact with raw WindUI features anytime:

```luau
local WindUI = Liyhub.WindUI

-- Native Popup
WindUI:Popup({
    Title = "Welcome",
    Content = "Enjoying LiyhubUI with WindUI engine!",
    Buttons = {
        { Title = "Got it", Variant = "Primary" }
    }
})
```

---

## 📱 Mobile Support & Draggable Pin Button

- Built into WindUI via `OpenButton`.
- Fully draggable floating pill widget.
- Automatically handles touch vs mouse inputs without accidental clicks.
