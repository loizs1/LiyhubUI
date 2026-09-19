# LiyhubUI Framework

LiyhubUI (NovaUI) is a high-performance, dark-modern UI framework and universal cheat hub engine designed for Roblox executors and Studio.

## 🚀 Instant Loadstring (Standalone)

You can load and use LiyhubUI in any script with a single line:

```luau
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
```

---

## 📖 Cara Kerja 1: Universal Script Library

Gunakan template ini untuk membuat script cheat pada game apa saja tanpa mengubah link UI:

```luau
-- 1. Import UI Library
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()

-- 2. Inisialisasi Window
local Window = Liyhub:CreateWindow({
    Title = "Liyhub | Jailbreak",
    Size = UDim2.fromOffset(740, 490)
})

-- 3. Tambah Tab & Section
local Combat = Window:AddTab("Combat", "🎯")
local TargetSection = Combat:AddSection("Aimbot", "Left")

-- 4. Tambah Komponen & Callback
TargetSection:AddToggle({
    Name = "Silent Aim",
    Default = true,
    Callback = function(state)
        -- Masukkan logika fitur
    end
})

TargetSection:AddSlider({
    Name = "Hit Chance %",
    Min = 1,
    Max = 100,
    Default = 85,
    Callback = function(value)
        -- Masukkan logika fitur
    end
})
```

---

## 🌐 Cara Kerja 2: Multi-Game Auto-Selector Hub

Jalankan satu loadstring yang otomatis mendeteksi game yang sedang dimainkan:

```luau
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
local PlaceId = game.PlaceId

if PlaceId == 6068496214 then
    -- JAILBREAK
    local Window = Liyhub:CreateWindow({ Title = "Liyhub | Jailbreak" })
    local Tab = Window:AddTab("Auto Rob", "💰")
    -- Script Jailbreak...

elseif PlaceId == 2753915549 or PlaceId == 4442272183 then
    -- BLOX FRUITS
    local Window = Liyhub:CreateWindow({ Title = "Liyhub | Blox Fruits" })
    local Tab = Window:AddTab("Auto Farm", "⚔️")
    -- Script Blox Fruits...

else
    -- UNIVERSAL FALLBACK
    local Window = Liyhub:CreateWindow({ Title = "Liyhub | Universal" })
    local Tab = Window:AddTab("Movement", "⚡")
    -- Script Universal...
end
```

---

## 🛠️ Complete 10-Component Suite

| Komponen | Sintaks Panggilan |
|---|---|
| **Toggle** | `Section:AddToggle({ Name = "...", Default = false, Callback = function(v) end })` |
| **Slider** | `Section:AddSlider({ Name = "...", Min = 0, Max = 100, Default = 50, Callback = function(v) end })` |
| **Button** | `Section:AddButton({ Name = "...", Callback = function() end })` |
| **Dropdown** | `Section:AddDropdown({ Name = "...", Options = {...}, Default = "...", Callback = function(opt) end })` |
| **MultiDropdown** | `Section:AddMultiDropdown({ Name = "...", Options = {...}, Default = {...}, Callback = function(list) end })` |
| **ColorPicker** | `Section:AddColorPicker({ Name = "...", Default = Color3.fromRGB(...), Callback = function(c) end })` |
| **Keybind** | `Section:AddKeybind({ Name = "...", Default = Enum.KeyCode.RightControl, Callback = function(k) end })` |
| **Textbox / Input** | `Section:AddTextbox({ Name = "...", Placeholder = "...", Callback = function(t) end })` (atau `AddInput`) |
| **Label** | `Section:AddLabel("Status: Active")` |
| **Paragraph** | `Section:AddParagraph({ Title = "...", Content = "..." })` |
| **Divider** | `Section:AddDivider()` |
| **SubSection** | `Section:AddSubSection("Combat Settings")` |
| **Toast Notify**| `Liyhub:Notify({ Title = "...", Content = "...", Duration = 2, Type = "Success" })` |

---

## 📱 Mobile Pin Tab (Floating Toggle)

Khusus pengguna mobile atau touch screen (dan desktop):
- **Top Center Dynamic Island**: Posisi default berada di bagian atas tengah layar (`UDim2.new(0.5, -67, 0, 14)`), bebas 100% dari benturan dengan Roblox Unibar, Logo Roblox, Chat bubble, menu hamburger, joystick analog, atau tombol lompat.
- **Position Presets di Settings**: Tersedia pilihan posisi 1-klik di tab Settings:
  - `Top Center (Default)` (`0.5, -67, 0, 14`)
  - `Left Middle` (`0, 14, 0.45, -17`)
  - `Right Middle` (`1, -148, 0.45, -17`)
  - `Bottom Center` (`0.5, -67, 1, -48`)
- **Drag & Auto-Save**: Pengguna bebas menggeser floating pill ke koordinat mana pun di layar. Saat dilepas, koordinat langsung otomatis disimpan ke `ConfigData["_Liyhub_PinPos"]` dan diingat saat script dieksekusi ulang.
- **Drag & Tap Separation**: Menggeser layar tidak akan memicu klik (threshold > 8px), sehingga aman digeser ke mana saja tanpa membuka/menutup menu secara tidak sengaja.
- **Viewport Clamped**: Tombol dibatasi secara otomatis agar tidak pernah terlempar keluar dari batas layar.
- **TopBar Pin Button (📌)**: Tekan tombol pin di header untuk mem-pin floating pill di layar secara permanen, atau biarkan floating pill muncul saat jendela diminimalkan.
- **API Methods**:
  ```luau
  Window:SetPinPosition(UDim2.new(0.5, -67, 0, 14)) -- Ubah posisi pin tab via script
  local pos = Window:GetPinPosition()                -- Ambil posisi pin tab saat ini
  ```

---

## ⌨️ Customizable UI Toggle (Show / Hide)

Pengguna dapat menentukan sendiri tombol atau cara yang ingin digunakan untuk membuka dan menutup menu:

1. **Inisialisasi Custom Toggle Key**:
   ```luau
   local Window = Liyhub:CreateWindow({
       Title = "Liyhub",
       ToggleKey = Enum.KeyCode.RightControl, -- Default key (bisa RightShift, Insert, F4, dll)
   })
   ```

2. **Pengaturan Interaktif di Tab Settings**:
   - Di tab **Settings**, buka kartu **UI Show / Hide Keybind**.
   - Klik tombol keybind (misal `[RightControl]`), teks akan berubah menjadi `[Press Any Key]`.
   - Tekan sembarang tombol di keyboard (misal `Insert`, `RightShift`, `V`, `F3`, `LeftAlt`, dll).
   - Tombol toggle baru langsung aktif dan **otomatis tersimpan ke config** (`ConfigData["_Liyhub_ToggleKey"]`).
   - Terdapat tombol preset instan: `RightControl`, `RightShift`, `Insert`, `LeftAlt`, `F4`.

3. **Programmatic API Control**:
   ```luau
   Window:SetToggleKey(Enum.KeyCode.Insert) -- Ganti keybind via script
   local currentKey = Window:GetToggleKey() -- Ambil KeyCode yang sedang aktif
   Window:Toggle()                          -- Buka/tutup UI secara manual
   Window:SetPinVisible(true)               -- Munculkan floating pin pill
   ```

---

## 💾 SpeedHub / Chloe X Configuration System

Sistem penyimpanan konfigurasi otomatis ke file `.json`:

1. **Auto-Save & Auto-Load Komponen**:
   - Setiap Toggle, Slider, Dropdown, MultiDropdown, Textbox/Input, ColorPicker, dan Keybind otomatis tersimpan ke `ConfigData` saat nilainya diubah oleh user.
   - Saat script dieksekusi ulang, nilai yang tersimpan akan otomatis dimuat ke komponen UI.

2. **Version Control & Auto-Reset**:
   - Tentukan versi konfigurasi di `CreateWindow`:
     ```luau
     local Window = Liyhub:CreateWindow({
         Title = "Liyhub |",
         Footer = "Auto Farm",
         Version = 1,
     })
     ```
   - Jika `Version` dinaikkan (misal dari `1` ke `2`), konfigurasi lama akan di-reset otomatis untuk mencegah konflik data.

3. **Custom Global Data & Shorthand**:
   - Akses tabel `ConfigData` kapan saja dari mana saja:
     ```luau
     ConfigData.WebhookURL = "https://discord.com/api/webhooks/..."
     ConfigData.PlayerName = "User123"
     SaveConfig() -- Simpan manual ke file lokal
     ```
   - Shorthand notifikasi cepat:
     ```luau
     chloex("Window loaded!")
     than("Farming started!")
     ```

---

## 🛡️ Anti-Detection & Security Features
- **Stealth Container**: Otomatis mendeteksi `gethui()`, `syn.protect_gui`, dan `protectgui` agar GUI tidak terdeteksi oleh `DescendantAdded` game.
- **Randomized GUID Naming**: Menghindari pemindaian nama UI statis oleh anticheat.
- **Single-Instance Debounce**: Otomatis membersihkan sesi sebelumnya (`_LIYHUB_CLEANUP`) agar tidak terjadi duplikasi GUI saat dieksekusi berkali-kali.
- **Procedural Vector Mark**: Logo Liyhub digambar tajam via Luau primitives (`Frame`, `UICorner`, `UIGradient`) tanpa aset eksternal dan bebas moderasi Roblox.
