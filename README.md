# 🛡️ LiyhubUI Framework

**LiyhubUI** adalah framework GUI Roblox / Luau modern, ultra-responsif, dan berkinerja tinggi yang dirancang untuk script executor (PC & Mobile touch devices) serta Roblox Studio. Framework ini menggabungkan estetika **Liyhub Obsidian Palette**, floating draggable pin widget untuk mobile, isolasi stealth (`gethui` / `CoreGui`), serta dukungan **Universal API Compatibility** (Fluent & NeverLose syntax native).

---

## 🚀 Quickstart & Cara Pakai

### 1. Bootstrap Loader Resmi
Muat LiyhubUI langsung ke dalam script executor Anda menggunakan URL raw resmi:

```luau
local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()
```

### 2. Boilerplate Skrip Standar

```luau
repeat task.wait() until game:IsLoaded()

local g = (typeof(getgenv) == "function" and getgenv()) or _G
if g.Liyhub_Game_Running then
    g.Liyhub_Game_Running = false
    task.wait(0.3)
end
g.Liyhub_Game_Running = true

local Liyhub = loadstring(game:HttpGet("https://raw.githubusercontent.com/loizs1/LiyhubUI/main/LiyhubUI.bundle.luau"))()

local Window = Liyhub:CreateWindow({
    Title = "Liyhub | Game Title",
    SubTitle = "by Liyhub Team",
    Size = UDim2.fromOffset(740, 490),
    ConfigFolder = "Liyhub_GameConfig",
    AutoConfig = true,
    MinimizeKey = Enum.KeyCode.RightControl
})

local MainTab = Window:AddTab("Combat", "🎯")
local Sec = MainTab:AddSection({ Name = "Main Features", Icon = "⚡" })

Sec:AddToggle({
    Name = "Auto Attack",
    Desc = "Menyerang musuh terdekat secara otomatis.",
    Default = false,
    Callback = function(state: boolean)
        -- Logika fitur (Zero print di callback)
    end
})

Liyhub:Notify({
    Title = "Liyhub",
    Content = "Script loaded successfully!",
    Duration = 3,
    Type = "Success"
})
```

---

## 🎨 Liyhub Obsidian Theme & Fitur Utama

- **Procedural Monogram Logo**: Logo kurva L-gradient dengan celestial orb cyan procedural (tidak memerlukan external `rbxassetid` yang rentan terhapus).
- **Mobile Floating Draggable Pin Widget**: Otomatis aktif saat window di-minimize `[-]` atau pin `[📌]`. Dapat digeser bebas di layar dan posisi tersimpan otomatis.
- **Stealth & Universal Capability Compatibility**:
  - GUI memprioritaskan `PlayerGui` $\rightarrow$ `gethui()` $\rightarrow$ `CoreGui` untuk menghindari crash security bypass Roblox terbaru (`cannot access 'Instance' (lacking capability Plugin)`).
  - Terproteksi dari pemindaian skrip game lokal (`ScreenGui` tidak dapat diinspeksi oleh skrip game biasa).
  - Standar **Zero `print()`** di dalam callback widget untuk menghindari deteksi via `LogService.MessageOut`.
- **Search System Cepat**: Filter pencarian elemen real-time terintegrasi dengan debounce 120ms (bebas stutter di mobile).
- **Built-in Profile Manager (Config System)**: Sistem konfigurasi otomatis berbasis JSON di `Liyhub/Configs` (Create, Save, Load, Delete).

---

## 📦 Kelengkapan UI & API Reference Lengkap

### 1. Window (`Liyhub:CreateWindow`)
Membuat window utama framework.

```luau
local Window = Liyhub:CreateWindow({
    Title = "Liyhub | Universal",     -- Judul utama window
    SubTitle = "v2.5",                 -- Sub-judul / author
    Size = UDim2.fromOffset(740, 490), -- Ukuran default (otomatis diklem jika mobile)
    TabWidth = 160,                    -- Lebar panel navigasi tab (default: 145-180)
    ConfigFolder = "Liyhub_MyGame",    -- Folder penyimpan file konfigurasi
    AutoConfig = true,                 -- Otomatis load profile default saat start
    MinimizeKey = Enum.KeyCode.RightControl -- Tombol keyboard toggle UI
})
```

**Window Methods**:
- `Window:Toggle()` / `Window:ToggleInterface()`: Menampilkan / menyembunyikan window.
- `Window:Minimize()`: Menyembunyikan window dan menampilkan floating pill widget.
- `Window:Open()`: Membuka kembali window dari status minimize.
- `Window:Destroy()` / `Window:Close()`: Menghapus GUI dari memori.
- `Window:SetDevicePreset(preset)`: Mengubah ukuran preset (`"PC"`, `"Mobile"`, `"Tablet"`, `"Mini"`).
- `Window:SetToggleKey(keyCode)`: Mengubah hotkey toggle window saat runtime.
- `Window:CreateSection(opt)`: Alias kompatibilitas universal ke `Window:AddTab`.
- `Window:Watermark()`: Membuat objek watermark (FPS, Ping, dsb.).

---

### 2. Tab (`Window:AddTab`)
Menambahkan tab navigasi ke sidebar.

```luau
-- Format 1: Table Config
local Tab = Window:AddTab({
    Name = "Farming",
    Icon = "wheat", -- Nama ikon Lucide atau teks emoji
    Type = "Double" -- Layout kolom
})

-- Format 2: Shorthand
local Tab = Window:AddTab("Farming", "🌾")
```

**Tab Methods**:
- `Tab:AddSection(cfg)`: Menambahkan kartu section ke dalam tab.
- `Tab:AddGroup(cfg)`: Alias universal untuk `AddSection`.
- `Tab:Select()`: Membuka tab ini secara terprogram.

---

### 3. Section (`Tab:AddSection`)
Section adalah container kartu untuk mengelompokkan elemen UI.

```luau
local Sec = Tab:AddSection({
    Name = "Targeting & Aim",
    Icon = "crosshair", -- Opsional
    Position = "left"   -- "left" | "right"
})
```

---

### 4. Elemen & Widget Suite

#### A. Toggle (`Sec:AddToggle`)
Saklar on/off modern dengan indikator cyan berkontras tinggi.

```luau
local myToggle = Sec:AddToggle({
    Name = "Silent Aim",
    Desc = "Mengarahkan tembakan otomatis ke target.", -- Opsional
    Default = false,
    Flag = "SilentAimFlag", -- Key simpanan konfigurasi
    Callback = function(state: boolean)
        -- logic saat state true / false
    end
})

-- Update nilai secara dinamis:
myToggle:SetValue(true)
```

#### B. Slider (`Sec:AddSlider`)
Slider presisi dengan dragging halus dan dukungan desimal.

```luau
local mySlider = Sec:AddSlider({
    Name = "Hit Chance",
    Desc = "Persentase akurasi tembakan",
    Min = 0,
    Max = 100,
    Default = 85,
    Decimals = 1, -- Jumlah angka di belakang koma (opsional)
    Flag = "HitChanceFlag",
    Callback = function(value: number)
        -- logic
    end
})

-- Update nilai slider:
mySlider:SetValue(90)
```

#### C. Dropdown Single-Select (`Sec:AddDropdown`)
Menu pilihan tunggal dengan pop-up list pencarian.

```luau
local myDropdown = Sec:AddDropdown({
    Name = "Target Bone",
    Options = { "Head", "HumanoidRootPart", "UpperTorso", "Random" },
    Default = "Head",
    Flag = "TargetBoneFlag",
    Callback = function(selected: string)
        -- logic
    end
})

-- Update pilihan atau list opsi:
myDropdown:SetValue("HumanoidRootPart")
myDropdown:SetValues({ "Head", "Torso", "Random" })
```

#### D. MultiDropdown (`Sec:AddMultiDropdown`)
Menu pilihan ganda (multi-selection).

```luau
local multiDrop = Sec:AddMultiDropdown({
    Name = "Target Filter",
    Options = { "Players", "NPCs", "Friends", "Guards" },
    Default = { "Players", "NPCs" },
    Flag = "TargetFilterFlag",
    Callback = function(selectedTable: { [string]: boolean })
        -- logic
    end
})
```

#### E. Textbox / TextInput (`Sec:AddTextbox` / `Sec:AddTextInput`)
Kotak input teks pengguna.

```luau
local myInput = Sec:AddTextbox({
    Name = "Player Username",
    Placeholder = "Ketik username target...",
    Default = "",
    Flag = "TargetPlayerFlag",
    Callback = function(text: string)
        -- logic
    end
})

-- Alias: Sec:AddTextInput didukung secara native.
```

#### F. Dual-Widget Row (`Sec:AddRow`)
Menyusun dua widget berdampingan 50/50 secara simetris (anti-potong layar mobile).

```luau
local row = Sec:AddRow()

row:AddToggle({
    Name = "Auto Parry",
    Default = false,
    Callback = function(state: boolean) end
})

row:AddKeybind({
    Name = "Shortcut",
    Default = Enum.KeyCode.F,
    Callback = function(key: Enum.KeyCode) end
})
```

#### G. Button (`Sec:AddButton`)
Tombol interaktif dengan efek micro-animation hover & click.

```luau
Sec:AddButton({
    Name = "Teleport to Safezone",
    Callback = function()
        -- logic teleportasi
    end
})
```

#### H. Keybind (`Sec:AddKeybind`)
Input pengikatan shortcut keyboard.

```luau
local myKey = Sec:AddKeybind({
    Name = "Panic Keybind",
    Default = Enum.KeyCode.X,
    Callback = function(key: Enum.KeyCode)
        -- logic saat tombol ditekan
    end
})
```

#### I. ColorPicker (`Sec:AddColorPicker`)
Color picker visual RGB dengan selector slider.

```luau
local myColor = Sec:AddColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(0, 162, 255),
    Callback = function(col: Color3)
        -- logic update warna
    end
})
```

#### J. Label (`Sec:AddLabel`)
Label teks informatif yang juga mendukung chaining method gaya NeverLose.

```luau
local myLabel = Sec:AddLabel("Status: Running")

-- Ubah teks saat runtime:
myLabel:SetText("Status: Paused")
myLabel:Set("Status: Paused") -- Alias native

-- Chaining Sub-widgets di bawah Label (Native Polyfill):
myLabel:AddToggle({ Default = false, Callback = function(s) end })
myLabel:AddSlider({ Min = 1, Max = 10, Default = 5, Callback = function(v) end })
myLabel:AddTextbox({ Placeholder = "Value...", Callback = function(t) end })
myLabel:AddDropdown({ Options = { "A", "B" }, Callback = function(o) end })
```

#### K. Paragraph (`Sec:AddParagraph`)
Blok kartu deskripsi dengan auto-wrap teks panjang.

```luau
Sec:AddParagraph({
    Title = "Security Protocol",
    Content = "Script ini menggunakan proteksi bypass packet tingkat lanjut. Jangan menyalakan fitur teleportasi saat berada di area PvP publik."
})
```

#### L. Divider (`Sec:AddDivider`)
Garis pemisah elegan di dalam section untuk merapikan layout.

```luau
Sec:AddDivider()
```

---

### 5. Notification System (`Liyhub:Notify`)
Toast notification floating di sudut layar dengan ikon dan warna jenis alert.

```luau
Liyhub:Notify({
    Title = "Teleport",
    Content = "Berhasil berpindah ke Area 5.",
    Duration = 3,       -- Durasi tampil (detik)
    Type = "Success"    -- "Success" | "Info" | "Warning"
})
```

Dukungan format instansiasi objek juga tersedia:
```luau
local Notifier = Liyhub:CreateNotification()
Notifier:Notify({ Title = "Alert", Content = "Pesan masuk", Duration = 2.5 })
```

---

## 🔄 Universal Cross-Library Compatibility

LiyhubUI dirancang agar skrip-skrip legacy (baik yang awalnya ditulis untuk **NeverLose**, **Rayfield**, maupun **Fluent**) dapat langsung berjalan tanpa perlu menulis adapter tambahan di skrip game Anda.

| Metode Asal | Alias Native di LiyhubUI | Fungsi |
|---|---|---|
| `sec:AddTextInput(...)` | `sec:AddTextbox(...)` | Input text box |
| `lbl:AddTextInput(...)` | `sec:AddTextbox(...)` | Chained text input |
| `lbl:Set("teks")` | `lbl:SetText("teks")` | Update string label |
| `tab:AddGroup(...)` | `tab:AddSection(...)` | Membuat grouping container |
| `win:CreateSection(...)` | `win:AddTab(...)` | Membuat tab/section utama |
| `win:SetToggleKey(...)` | `win._toggleKey = k` | Mengatur shortcut toggle |
| `sec:AddDivider()` | Native line separator | Garis pemisah elemen |
| `dummyBlock:Set(...)` | `dummyBlock:SetText(...)` | Sinkronisasi watermark |

---

## 🛡️ Anti-Patterns & Best Practices
 
1. ❌ **Hindari `print()` di Callback**: Jangan letakkan perintah `print()` di dalam callback tombol/toggle/slider agar tidak tertangkap oleh `LogService` anticheat game.
2. ❌ **Jangan gunakan `_G`**: Gunakan `getgenv()` secara konsisten untuk menyimpan state global antar eksekusi.
3. ❌ **Jangan hardcode `rbxassetid://` untuk Logo**: LiyhubUI menggunakan monogram vektor procedural. Jangan menambahkan logo eksternal yang membebani memori.
4. ✅ **Bungkus Loop dengan `task.spawn`**: Pastikan looping otomasi berjalan asinkron dan selalu berikan delay `task.wait()` yang wajar agar FPS pemain tetap stabil.

---

## ⚠️ PENTING: Panduan Pengembang & Kontributor (Developer Checklist)

> [!CAUTION]
> **JANGAN LEWATKAN BAGIAN INI SAAT MENGEMBANGKAN FITUR ATAU MEMBUAT UI DENGAN LIYHUBUI!**
> Roblox secara berkala memperketat sistem kapabilitas thread (`Capabilities` / `Security Context`) di engine Luau. Kelalaian pada poin di bawah ini akan menyebabkan script crash instan dengan error merah:
> `The current thread cannot access 'Instance' (lacking capability Plugin)`.

### 1. 🚨 Prioritas Parent GUI: Selalu Dahulukan `PlayerGui`
- **JANGAN** pernah memaksakan `CoreGui` atau `gethui()` sebagai prioritas pertama tanpa memeriksa `PlayerGui`.
- Di Roblox versi modern, thread callback sinyal engine yang mengakses instance di dalam `CoreGui` akan kehilangan privilege dan meledak menjadi error `lacking capability Plugin`.
- **Wajib gunakan urutan ini**:
  ```luau
  local function parentGui()
      local lp = game:GetService("Players").LocalPlayer
      if lp then
          local pg = lp:FindFirstChild("PlayerGui") or lp:WaitForChild("PlayerGui", 5)
          if pg then return pg end
      end
      local ok, h = pcall(function() return gethui and gethui() end)
      if ok and h then return h end
      local okCg, cg = pcall(function() return game:GetService("CoreGui") end)
      if okCg and cg then return cg end
      return game:GetService("StarterGui")
  end
  ```

### 2. 🚨 Hindari Listen Langsung ke `workspace.CurrentCamera`
- **JANGAN** menghubungkan sinyal `workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize")` secara telanjang tanpa pembersihan:
  - Sinyal ini dijalankan langsung oleh renderer engine C++ Roblox.
  - Sinyal pada `workspace.CurrentCamera` **TIDAK AKAN PUTUS** meskipun GUI dihancurkan (`ScreenGui:Destroy()`), menyebabkan kebocoran memori (memory leak) dan error berulang di game.
- **Solusi yang Benar**:
  - Gunakan `ScreenGui:GetPropertyChangedSignal("AbsoluteSize")` karena sinyal pada `ScreenGui` otomatis terputus saat GUI di-destroy.
  - Jika tetap memerlukan kamera, **WAJIB** simpan koneksinya ke variabel lokal dan panggil `:Disconnect()` saat GUI ditutup, serta bungkus callback di dalam `pcall()`.

### 3. 🚨 Selalu Bungkus Callback Deferred / Resize dengan `pcall`
- Saat menggunakan `task.defer` atau `task.spawn` untuk menghitung ulang ukuran list (`AbsoluteContentSize`), selalu validasi keberadaan instance parent:
  ```luau
  task.defer(function()
      pcall(function()
          if not holder or not holder.Parent or not list or not list.Parent then return end
          holder.Size = UDim2.new(1, 0, 0, list.AbsoluteContentSize.Y + 16)
      end)
  end)
  ```

### 4. 🚨 DisplayOrder Tinggi & Draggable Pada Modal/Dialog Penting
- Dialog penting seperti **Key Gateway**, **Loading Screen**, atau **Prompt Konfirmasi** wajib memiliki `DisplayOrder = 999999` agar tidak tenggelam di balik popup update bawaan game.
- Berikan fitur drag pada `TitleBar` agar pemain di mobile/PC dapat menggeser dialog jika menutupi tombol penting dalam game.
