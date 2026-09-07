-- Full example hub for the Astral UI library.
-- Run with: loadstring(game:HttpGet("https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/Example.lua"))()

local Astral = loadstring(game:HttpGet("https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/Script.lua"))()

-- ================= WINDOW =================
local Window = Astral:CreateWindow({
	Title = "Example Hub",
	SubTitle = "by velaricX",
	badge = "FREE",
	badgecolor = Color3.fromRGB(0, 153, 235),
	Size = UDim2.fromOffset(750, 500),
})

-- ================= SECTIONS (top-right pills) =================
local Main = Window:MakeSection({"Main", "Home"})
local Settings = Window:MakeSection({"Settings", "settings"})

-- ================= PAGES (cards) =================
local FarmPage = Main:MakePage({
	Name = "Auto Farm",
	Description = "All farming features.",
	Icon = "shopping",
})

local PlayerPage = Main:MakePage({
	Name = "Player",
	Description = "Character tweaks.",
	Icon = "profile",
})

local UIPage = Settings:MakePage({
	Name = "UI Settings",
	Description = "Theme and interface options.",
	Icon = "palette",
})

-- ================= TABS =================
local FarmTab = FarmPage:MakeTab({
	Name = "General",
	Icon = "timer",
	Description = "Main farm toggles.",
})

local CombatTab = FarmPage:MakeTab({
	Name = "Combat",
	Icon = "quest",
	Description = "Fighting options.",
})

local PlayerTab = PlayerPage:MakeTab({
	Name = "Movement",
	Icon = "steering",
	Description = "Speed, jump, fly.",
})

local ThemeTab = UIPage:MakeTab({
	Name = "Theme",
	Icon = "brush",
	Description = "Colors and layout.",
})

-- ================= FARM TAB: every element =================
FarmTab:AddLabel({
	Title = "Status",
	Description = "Farm is idle.",
	Icon = "timer",
})

FarmTab:AddToggle({
	Title = "Auto Farm",
	Description = "Farms automatically.",
	Default = false,
	Icon = "timer",
	Position = "Left",
	Callback = function(state)
		print("Auto Farm:", state)
	end,
})

FarmTab:AddTick({
	Title = "Auto Loot",
	Description = "Picks up drops.",
	Default = true,
	Icon = "chest",
	Position = "Right",
	Callback = function(state)
		print("Auto Loot:", state)
	end,
})

FarmTab:AddSlider({
	Title = "Farm Range",
	Min = 1,
	Max = 100,
	Increase = 1,
	Default = 50,
	Icon = "eye",
	Callback = function(val)
		print("Range:", val)
	end,
})

FarmTab:AddButton({
	Title = "Teleport To Farm",
	Description = "Click to teleport.",
	Icon = "map_background",
	Position = "Left",
	Callback = function()
		Window:Notify({ Type = "good", Title = "Teleported", Message = "Arrived at farm.", Duration = 4 })
	end,
})

FarmTab:AddTextbox({
	Title = "Target Name",
	Description = "Who to farm.",
	Placeholder = "Enter name...",
	Default = "",
	Icon = "search",
	Callback = function(text)
		print("Target:", text)
	end,
})

FarmTab:AddSelector({
	Title = "Farm Mode",
	Description = "Pick a mode.",
	Options = {"Closest", "Strongest", "Boss Only"},
	Default = "Closest",
	Search = true,
	Multi = false,
	Icon = "guide_icon",
	Callback = function(pick)
		print("Mode:", pick)
	end,
})

FarmTab:AddParagraph({
	Title = "Tip",
	Description = "Turn on Auto Loot before farming bosses for best results.",
	Icon = "star",
})

-- ================= COMBAT TAB =================
CombatTab:AddToggle({
	Title = "Kill Aura",
	Default = false,
	Icon = "quest",
	Callback = function(state)
		print("Kill Aura:", state)
	end,
})

CombatTab:AddSlider({
	Title = "Aura Radius",
	Min = 5,
	Max = 50,
	Increase = 1,
	Default = 15,
	Callback = function(val)
		print("Radius:", val)
	end,
})

CombatTab:AddSelector({
	Title = "Targets",
	Description = "Multi-select enemies.",
	Options = {"Bandits", "Bosses", "Players"},
	Default = {"Bandits"},
	Multi = true,
	Callback = function(picks)
		print("Targets:", table.concat(picks, ", "))
	end,
})

-- ================= PLAYER TAB =================
local speedSlider = PlayerTab:AddSlider({
	Title = "WalkSpeed",
	Min = 16,
	Max = 200,
	Increase = 1,
	Default = 16,
	Icon = "steering",
	Callback = function(val)
		local hum = game:GetService("Players").LocalPlayer.Character
			and game:GetService("Players").LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
		if hum then hum.WalkSpeed = val end
	end,
})

PlayerTab:AddButton({
	Title = "Reset Speed",
	Description = "Back to 16.",
	Icon = "redo",
	Callback = function()
		speedSlider:Set(16)
	end,
})

PlayerTab:AddKeybind({
	Title = "Fly Toggle",
	Default = Enum.KeyCode.F,
	Icon = "keyboard",
	Callback = function(key)
		print("Fly key pressed:", key.Name)
	end,
})

-- ================= THEME TAB =================
ThemeTab:AddColorPicker({
	Title = "Custom Color",
	Description = "Pick anything.",
	Default = Color3.fromRGB(0, 153, 235),
	Callback = function(color)
		print("Picked:", color)
	end,
})

ThemeTab:AddSelector({
	Title = "Accent Theme",
	Description = "Recolors the whole UI.",
	Options = {"Cyan", "Crimson", "Emerald", "Gold", "Sapphire"},
	Default = "Sapphire",
	Search = true,
	Callback = function(pick)
		print("Theme:", pick)
	end,
})

ThemeTab:AddButton({
	Title = "One Column Layout",
	Icon = "palette",
	Callback = function()
		Astral:SetLayoutMode("OneColumn")
	end,
})

ThemeTab:AddButton({
	Title = "Two Column Layout",
	Icon = "palette",
	Callback = function()
		Astral:SetLayoutMode("TwoColumn")
	end,
})

-- ================= HELLO =================
Window:Notify({
	Type = "good",
	Title = "Example Hub",
	Message = "Loaded. Open Tests in the full version to spam notifs.",
	Duration = 6,
})
