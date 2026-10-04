# 🛡️ Panduan Standar Integrasi LiyhubUI (AI & Developer Guidelines)

Dokumen ini adalah aturan arsitektur resmi untuk semua script di dalam folder `liyhubasset/`. Setiap AI atau developer yang membuat, mengedit, atau merefaktor script game **WAJIB** mengikuti struktur dan penempatan di bawah ini agar tidak terjadi kesalahan baca, tabrakan sintaks (NeverLose vs Fluent/WindUI), atau kegagalan eksekusi.

---

## 📌 1. Urutan Struktur Script (Strict Hierarchy)

Setiap script game LiyHub **HARUS** disusun dengan urutan hierarki berikut secara ketat:

```text
[1] Game Loaded Check (repeat task.wait() until game:IsLoaded())
[2] Anti-Reexecution & Cleanup Old Window
[3] Universal Robust UI Loader (LiyhubUI -> neverloseRemake -> 4lpaca-pin -> Global)
[4] UI Fail-Safe Alert (StarterGui:SetCore)
[5] Compatibility Polyfill Layer (AddTextInput, pingBlock.Set, lbl.Set)
[6] Window Creation (Liyhub:CreateWindow)
[7] Watermark & UI Toggle Input
[8] Notification Helper (SendNotification)
[9] Tab Creation (Window:AddTab)
[10] Section Creation (Tab:AddSection)
[11] Roblox Services & Game State Variables
[12] Logic & Core Farming Functions
[13] UI Elements Binding (Toggles, Sliders, Dropdowns, Buttons)
[14] Active Loops & Heartbeat Connections
```

---

## 🚀 2. Template Header & Loader Standar (Copy-Paste Ready)

```lua
repeat task.wait() until game:IsLoaded()

local g = getgenv and getgenv() or _G

-- 1. Anti Re-execution
if g.Liyhub_GameName_Running then
    g.Liyhub_GameName_Running = false
    task.wait(0.3)
end
g.Liyhub_GameName_Running = true

-- 2. Cleanup Old Window
local oldWindow = g.Liyhub_GameName_Window
if oldWindow and type(oldWindow.Destroy) == "function" then
    pcall(function() oldWindow:Destroy() end)
end

-- 3. Multi-tier Robust UI Loader
local Liyhub = nil

pcall(function()
    local raw = game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau")
    if raw and #raw > 100 then
        Liyhub = loadstring(raw)()
    end
end)

if not Liyhub or type(Liyhub.CreateWindow) ~= "function" then
    pcall(function()
        local raw = game:HttpGet("https://raw.githubusercontent.com/thantzy/DummyUI/refs/heads/main/neverloseRemake.lua")
        if raw and #raw > 100 then
            Liyhub = loadstring(raw)()
        end
    end)
end

if not Liyhub or type(Liyhub.CreateWindow) ~= "function" then
    pcall(function()
        local raw = game:HttpGet("https://raw.githubusercontent.com/4lpaca-pin/NeverLose/refs/heads/main/source.luau")
        if raw and #raw > 100 then
            Liyhub = loadstring(raw)()
        end
    end)
end

if not Liyhub or type(Liyhub.CreateWindow) ~= "function" then
    Liyhub = (getgenv and (getgenv().Liyhub or getgenv().NeverLose)) or _G.Liyhub or _G.NeverLose or (shared and (shared.Liyhub or shared.NeverLose))
end

-- 4. Fail-Safe Alert (No Silent Exit!)
if not Liyhub or type(Liyhub.CreateWindow) ~= "function" then
    warn("[LIYHUB] Failed to load UI Library!")
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "LIYHUB Error",
            Text = "Failed to load UI Library. Check network / executor HTTP.",
            Duration = 6
        })
    end)
    return
end

-- 5. Compatibility Polyfill (NeverLose <-> LiyhubUI Bridge)
if not Liyhub._LiyhubCompatApplied then
    Liyhub._LiyhubCompatApplied = true
    local origCreateWindow = Liyhub.CreateWindow
    Liyhub.CreateWindow = function(self, opt)
        local win = origCreateWindow(self, opt)
        if win and win.AddTab then
            local origAddTab = win.AddTab
            win.AddTab = function(wSelf, to, iconOpt)
                local tab = origAddTab(wSelf, to, iconOpt)
                if tab and tab.AddSection then
                    local origAddSection = tab.AddSection
                    tab.AddSection = function(tSelf, secOpt, sIcon)
                        local sec = origAddSection(tSelf, secOpt, sIcon)
                        if sec then
                            if not sec.AddTextInput and sec.AddTextbox then
                                sec.AddTextInput = function(s, cfg, ...) return s:AddTextbox(cfg, ...) end
                            end
                            if sec.AddLabel then
                                local origAddLabel = sec.AddLabel
                                sec.AddLabel = function(s, lOpt, ...)
                                    local lbl = origAddLabel(s, lOpt, ...)
                                    if lbl and type(lbl) == "table" then
                                        if not lbl.AddTextInput and lbl.AddTextbox then
                                            lbl.AddTextInput = function(lSelf, cfg) return lSelf:AddTextbox(cfg) end
                                        end
                                        if not lbl.Set and lbl.SetText then
                                            lbl.Set = function(lSelf, val) return lSelf:SetText(val) end
                                        end
                                    end
                                    return lbl
                                end
                            end
                        end
                        return sec
                    end
                end
                return tab
            end
        end
        if win and win.Watermark then
            local origWatermark = win.Watermark
            win.Watermark = function(wSelf, wOpt)
                local wm = origWatermark(wSelf, wOpt)
                if wm and wm.AddBlock then
                    local origAddBlock = wm.AddBlock
                    wm.AddBlock = function(wmSelf, icon, text)
                        local blk = origAddBlock(wmSelf, icon, text)
                        if blk and type(blk) == "table" then
                            if not blk.Set and blk.SetText then
                                blk.Set = function(bSelf, val) return bSelf:SetText(val) end
                            end
                            if not blk.Input then
                                blk.Input = function() end
                            end
                        end
                        return blk
                    end
                end
                return wm
            end
        end
        return win
    end
end
```

---

## 📱 3. Setup Window, Watermark, & Notifier

```lua
local uis = game:GetService("UserInputService")
local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

local Window = Liyhub:CreateWindow({
    Title = "LIYHUB | Game Name",
    Name = "LIYHUB | Game Name",
    Content = "Game Name Automation By LIYHUB",
    Size = isMobile and UDim2.fromOffset(580, 430) or UDim2.fromOffset(740, 490),
    ConfigFolder = "LIYHUB_GameName_Config",
    AutoConfig = true,
    Keybind = "Insert"
})
g.Liyhub_GameName_Window = Window

-- Watermark Setup
local Watermark = nil
local pingBlock = { Set = function() end }
local uiToggleBlock = { Input = function() end }

pcall(function()
    if Window and type(Window.Watermark) == "function" then
        Watermark = Window:Watermark()
        if Watermark and type(Watermark.AddBlock) == "function" then
            pingBlock = Watermark:AddBlock("chart-four-vertical-bars", "0MS")
            uiToggleBlock = Watermark:AddBlock("cube-vertexes", "LIYHUB")
            uiToggleBlock:Input(function()
                if Window and type(Window.ToggleInterface) == "function" then
                    Window:ToggleInterface()
                end
            end)
        end
    end
end)

-- Notifier Setup (Compatible with both .new and :Notify)
local Notifier = nil
pcall(function()
    Notifier = Liyhub:CreateNotification()
end)

local function SendNotification(title, content, duration)
    duration = duration or 3
    pcall(function()
        if Notifier and type(Notifier.new) == "function" then
            Notifier.new({
                Title = title or "LIYHUB",
                Content = tostring(content or ""),
                Duration = duration
            })
        elseif Notifier and type(Notifier.Notify) == "function" then
            Notifier:Notify({
                Title = title or "LIYHUB",
                Content = tostring(content or ""),
                Duration = duration
            })
        else
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = title or "LIYHUB",
                Text = tostring(content or ""),
                Duration = duration
            })
        end
    end)
end
```

---

## 🎛️ 4. Cara Penggunaan Komponen UI (LiyhubUI vs NeverLose)

LiyhubUI mendukung dua gaya penulisan komponen:

### Gaya A: Fluent / Direct Section Method (Direkomendasikan untuk Script Baru)
```lua
local Tab = Window:AddTab({ Name = "Main", Icon = "home", Type = "Double" })
local Sec = Tab:AddSection({ Name = "Farming", Position = "left" })

-- Toggle
Sec:AddToggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(val)
        Config.AutoFarm = val
    end,
    Flag = "AutoFarmToggle"
})

-- Slider
Sec:AddSlider({
    Name = "Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Callback = function(val)
        Config.Speed = val
    end,
    Flag = "SpeedSlider"
})

-- Dropdown
Sec:AddDropdown({
    Name = "Target Mode",
    Values = { "Nearest", "Highest Value", "Lowest Health" },
    Default = "Nearest",
    Callback = function(choice)
        Config.Mode = choice
    end
})

-- Textbox
Sec:AddTextbox({
    Name = "Target Player",
    Placeholder = "Enter name...",
    Default = "",
    Callback = function(txt)
        Config.TargetPlayer = txt
    end
})

-- Button
Sec:AddButton({
    Name = "Teleport Base",
    Callback = function()
        TeleportToBase()
    end
})
```

### Gaya B: NeverLose Chained Label Method (Didukung Penuh oleh Polyfill Liyhub)
```lua
-- Toggle di bawah Label
Sec:AddLabel("Auto Farm Coins"):AddToggle({
    Default = false,
    Callback = function(val) end,
    Flag = "AutoCoinsToggle"
})

-- Slider di bawah Label
Sec:AddLabel("Attack Delay"):AddSlider({
    Min = 0.1,
    Max = 2.0,
    Default = 0.5,
    Callback = function(val) end
})

-- Dropdown di bawah Label
Sec:AddLabel("Select Weapon"):AddDropdown({
    Values = { "Sword", "Gun", "Bow" },
    Default = "Sword",
    Callback = function(v) end
})

-- Text Input di bawah Label (Otomatis dialiaskan ke AddTextbox via Polyfill)
Sec:AddLabel("Promo Code"):AddTextInput({
    Default = "",
    Placeholder = "Enter code...",
    Callback = function(code) end
})
```

---

## 🚫 5. Larangan Keras untuk AI (Anti-Patterns / DO NOT DO)

1. ❌ **JANGAN PERNAH menyuntikkan kode string (`string.sub` / `string.find`) ke `parentGui()`**.
   - `LiyhubUI.bundle.luau` sudah memiliki deteksi `gethui() -> PlayerGui -> CoreGui -> StarterGui` secara bawaan dan aman. String replacement manual merusak sintaks chunk luau.
2. ❌ **JANGAN PERNAH meng-override `getgenv().gethui` secara global**.
   - Ini merusak proteksi GUI executor dan menyebabkan memory leak atau error pada script lain.
3. ❌ **JANGAN PERNAH memasukkan URL `http://127.0.0.1:9876`**.
   - Ini adalah port lokal debug pribadi. Menjalankannya di executor publik akan membuat script hang/timeout bermenit-menit.
4. ❌ **JANGAN PERNAH melakukan `silent return` jika UI gagal dimuat**.
   - Selalu berikan notifikasi melalui `StarterGui:SetCore("SendNotification")` agar pemain tahu mengapa UI tidak muncul.
5. ❌ **JANGAN PERNAH memasang `setfenv(1, ...)` di awal file**.
   - `setfenv` menonaktifkan optimasi JIT/VM Luau dan memutus referensi environment executor.
6. ❌ **JANGAN panggil `pingBlock:Set(...)` tanpa guard atau polyfill**.
   - Pada library LiyhubUI, watermark blok memakai `SetText`. Loader polyfill di atas sudah mengaliaskan `.Set` ke `.SetText`.
7. ❌ **JANGAN merusak gameplay logic saat memperbaiki UI**.
   - Perbaikan UI hanya boleh menyentuh header inisialisasi, pembuatan window, dan pemanggilan komponen. Logika farming/combat/gameplay harus tetap utuh.
