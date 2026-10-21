-- Studio UI test harness for LiyhubUI.
-- Setup: put LiyhubUI.bundle.lua as a ModuleScript named "LiyhubUI" in ReplicatedStorage,
-- then paste this file into a LocalScript under StarterPlayer > StarterPlayerScripts and press Play.
-- ponytail: hardcoded module path, no asset pipeline. Change the require below if you nest it elsewhere.

local Fluent = require(game:GetService("ReplicatedStorage"):WaitForChild("LiyhubUI"))

local Window = Fluent:CreateWindow({
    Title = "Liyhub",
    SubTitle = "UI Test",
})

local tab = Window:AddTab("Main", "home")

local sec = tab:AddSection("Toggles", "sliders")

sec:AddToggle("TestOff", {
    Title = "Auto Farm",
    Description = "Row is clickable anywhere",
    Default = false,
    Callback = function(v) print("AutoFarm", v) end,
})

sec:AddToggle("TestOn", {
    Title = "Auto Collect",
    Default = true,
    Callback = function(v) print("AutoCollect", v) end,
})

sec:AddButton({
    Title = "Run Action",
    Description = "Click the row or the button",
    ButtonText = "Run",
    Callback = function() print("button fired") end,
})

local sec2 = tab:AddSection("Other Elements", "settings")
sec2:AddSlider("TestSlider", { Title = "Speed", Min = 0, Max = 100, Default = 40, Callback = print })
sec2:AddDropdown("TestDrop", { Title = "Mode", Values = { "A", "B", "C" }, Default = "A", Callback = print })
sec2:AddDropdown("TestMulti", { Title = "Targets", Multi = true, Values = { "X", "Y", "Z" }, Callback = print })
sec2:AddTextbox("TestInput", { Title = "Name", Placeholder = "type...", Callback = print })
sec2:AddKeybind("TestKey", { Title = "Panic Key", Default = "RightControl" })
sec2:AddColorPicker("TestColor", { Title = "ESP Color", Default = Color3.fromRGB(0, 162, 255) })
sec2:AddParagraph({ Title = "Info", Content = "Verify toggle badge reads Turn On / Turn Off and row hover works." })

-- Self-check: toggle state round-trips through the new badge path.
assert(Fluent.Flags.TestOff == false, "TestOff should default false")
assert(Fluent.Flags.TestOn == true, "TestOn should default true")
Fluent.Options.TestOff:SetValue(true)
assert(Fluent.Flags.TestOff == true, "SetValue(true) did not update flag")
Fluent.Options.TestOff:SetValue(false)
assert(Fluent.Flags.TestOff == false, "SetValue(false) did not update flag")
assert(Fluent.Options.TestOn.Value == true, "Options.TestOn.Value should mirror the toggle")
print("[studio_test] toggle self-check passed")

-- Reload-safe loop pattern: stops by itself when the window is destroyed or the script is re-run.
local alive = true
Window:OnUnload(function() alive = false print("[studio_test] old loop stopped") end)
task.spawn(function()
    while alive and task.wait(1) do
        if Fluent.Options.TestOff.Value then print("[studio_test] auto farm tick") end
    end
end)
