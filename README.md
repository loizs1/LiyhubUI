# 🛡️ LiyhubUI Framework

**LiyhubUI** adalah framework UI Roblox / Luau modern, berkinerja tinggi, dan ramah mobile yang dirancang untuk script executor (PC & Mobile) serta Roblox Studio. Menggabungkan estetika **Liyhub Obsidian Palette**, floating draggable pin button untuk mobile, dan kompatibilitas ganda (**Fluent & NeverLose API**).

---

## 🚀 Instant Loadstring

Muat LiyhubUI ke dalam script Anda dengan URL resmi:

```luau
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
```

---

## 🎨 Liyhub Obsidian Theme

Palet tema default yang diinjeksi secara otomatis:
- **Canvas / Background**: `#0A0A0D` (Deep Obsidian)
- **Primary / Accent**: `#00A2FF` (Electric Liyhub Cyan)
- **Active Toggle**: `#00E5FF` (Neon Cyan)
- **Cards & Dialogs**: `#101015` / `#121217`
- **Text**: `#FFFFFF` (Solid White) & `#8C91A5` (Secondary Muted)

---

## 🔒 Arsitektur Keamanan & Proteksi GUI (Capability Safe)

LiyhubUI secara internal menerapkan standar isolasi GUI yang aman dari error Roblox:
1. **Prioritas PlayerGui & Executor Protection**:
   - `ScreenGui` diposisikan di `Players.LocalPlayer.PlayerGui` dengan memanggil fungsi proteksi bawaan executor (`syn.protect_gui` / `protectgui`).
   - Mencegah error crash `The current thread cannot access 'Instance' (lacking capability Plugin)` yang terjadi bila GUI dipaksa masuk ke `CoreGui` / `gethui` pada executor dengan thread capability terbatas.
2. **Safe Event Listeners**:
   - Seluruh listener `AbsoluteContentSize`, `MouseEnter`, `MouseLeave`, dan `TweenService:Create` dibungkus dalam `pcall` agar tidak pernah memicu runtime error yang menghentikan loop script.

---

## 🤖 PANDUAN INTEGRASI KHUSUS AI (AI AGENT & DEVELOPER GUIDELINES)

> [!IMPORTANT]
> Setiap AI assistant atau developer yang membuat, mengedit, atau merefaktor script game yang menggunakan LiyhubUI **WAJIB** mengikuti hierarki dan aturan penempatan berikut agar tidak terjadi salah baca atau error runtime.

### 1. Urutan Hierarki Script yang Benar (Strict Execution Order)

Script game **HARUS** disusun dari atas ke bawah dengan urutan berikut:

```text
[1] Game Loaded Check       --> repeat task.wait() until game:IsLoaded()
[2] Anti-Reexecution Guard  --> Cek flag running di getgenv, delay 0.3s, pcall destroy old window
[3] Multi-tier UI Loader    --> Load LiyhubUI bundle -> fallback neverloseRemake -> fallback 4lpaca -> global
[4] Fail-Safe Alert         --> Jika gagal load, kirim notifikasi StarterGui (JANGAN silent return!)
[5] Compatibility Bridge    --> Pasang alias AddTextInput, pingBlock.Set, lbl.Set
[6] Window Instantiation    --> Liyhub:CreateWindow({...})
[7] Watermark & Mobile PIN  --> Setup watermark, FPS/Ping counter, dan toggle interface input
[8] Notifier Setup          --> Liyhub:CreateNotification() & function SendNotification
[9] Tab Creation            --> Window:AddTab({...})
[10] Section Creation       --> Tab:AddSection({...})
[11] Roblox Game Services   --> Players, RunService, TweenService, Workspace, dll.
[12] Game State & Configs   --> Tabel konfigurasi (Config) & variabel status lokal
[13] Core Functions & Logic --> Fungsi farming, combat, teleport, exploit loop
[14] UI Controls Binding    --> Hubungkan AddToggle / AddSlider / AddDropdown ke fungsi logic
[15] Active Event Loops     --> Heartbeat / RenderStepped / Task Loops
```

---

### 2. Template Header & Multi-tier Loader Standar (Copy-Paste Ready)

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

-- 4. Fail-Safe Alert (No Silent Return!)
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

-- 5. Universal Compatibility Bridge (NeverLose <-> Fluent Polyfill)
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

### 3. Setup Window, Watermark, & Notifier

```lua
local uis = game:GetService("UserInputService")
local isMobile = uis.TouchEnabled and not uis.KeyboardEnabled

local Window = Liyhub:CreateWindow({
    Title = "LIYHUB | Game Name",
    Name = "LIYHUB | Game Name",
    Content = "Game Automation By LIYHUB",
    Size = isMobile and UDim2.fromOffset(580, 430) or UDim2.fromOffset(740, 490),
    ConfigFolder = "LIYHUB_GameName_Config",
    AutoConfig = true,
    Keybind = "Insert"
})
g.Liyhub_GameName_Window = Window

-- Watermark & Mobile Floating Toggle Button
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

-- Notifier Helper (Mendukung .new dan :Notify)
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

### 4. Contoh Komponen UI

#### Gaya 1: Direct Method (Fluent / Standar)
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
    Name = "WalkSpeed",
    Min = 16,
    Max = 300,
    Default = 16,
    Callback = function(val)
        Config.Speed = val
    end,
    Flag = "SpeedSlider"
})

-- Dropdown
Sec:AddDropdown({
    Name = "Target Mob",
    Values = { "Goblin", "Orc", "Dragon" },
    Default = "Goblin",
    Callback = function(v)
        Config.TargetMob = v
    end
})

-- Textbox
Sec:AddTextbox({
    Name = "Player Target",
    Placeholder = "Enter player name...",
    Default = "",
    Callback = function(txt)
        Config.TargetPlayer = txt
    end
})

-- Button
Sec:AddButton({
    Name = "Teleport Spawn",
    Callback = function()
        TeleportToSpawn()
    end
})
```

#### Gaya 2: NeverLose Chained Label Method (Didukung via Bridge)
```lua
-- Toggle di bawah Label
Sec:AddLabel("Auto Farm Coins"):AddToggle({
    Default = false,
    Callback = function(val) end,
    Flag = "AutoCoinsToggle"
})

-- Slider di bawah Label
Sec:AddLabel("Attack Delay (s)"):AddSlider({
    Min = 0.1,
    Max = 2.0,
    Default = 0.5,
    Callback = function(val) end
})

-- Text Input di bawah Label (Otomatis dialiaskan ke AddTextbox via Bridge)
Sec:AddLabel("Code Input"):AddTextInput({
    Default = "",
    Placeholder = "Enter code...",
    Callback = function(text) end
})
```

---

### 5. DAFTAR LARANGAN KERAS UNTUK AI (CRITICAL ANTI-PATTERNS)

1. ❌ **JANGAN PERNAH menyuntikkan kode string (`string.sub` / `string.find`) ke fungsi `parentGui()`**.
   - `LiyhubUI.bundle.luau` sudah otomatis memprioritaskan `PlayerGui` dan memeriksa executor safety. Monkey-patch string hanya akan merusak parser.
2. ❌ **JANGAN PERNAH menimpa `getgenv().gethui` secara global**.
   - Menimpa `gethui` merusak isolasi GUI executor dan menyebabkan memory leak atau error pada script lain.
3. ❌ **JANGAN PERNAH mencantumkan URL lokal `http://127.0.0.1:9876`**.
   - Port 9876 adalah port lokal pengujian developer. Pemain umum tidak membuka port ini, sehingga menyebabkan HTTP timeout/freeze.
4. ❌ **JANGAN PERNAH melakukan `silent return` tanpa notifikasi**.
   - Jika UI gagal dimuat karena kendala jaringan executor, selalu panggil `StarterGui:SetCore("SendNotification", ...)` agar pemain tahu alasan UI tidak muncul.
5. ❌ **JANGAN PERNAH menambahkan `setfenv(1, ...)` di awal script**.
   - Memutus lingkungan global executor dan mematikan optimasi bytecode Luau.
6. ❌ **JANGAN panggil `pingBlock:Set(...)` tanpa bridge alias**.
   - Di LiyhubUI, watermark menggunakan `.SetText`. Selalu gunakan bridge compatibility yang mengaliaskan `.Set` ke `.SetText`.
7. ❌ **JANGAN merusak gameplay logic saat merefaktor UI**.
   - Pekerjaan UI hanya boleh menyentuh header, inisialisasi window, dan binding elemen. Logika pergerakan, farming, dan combat harus tetap utuh.
