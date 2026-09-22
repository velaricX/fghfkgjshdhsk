-- ============================================================
--  Lumu UI  --  THE test file (always current)
--  HOSTED LOADER (used by queue_on_teleport + the in-UI design switcher)
--  Covers every element + every recent fix.
-- ============================================================
local DESIGN = "Auto"
local RAW = "https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/"

-- remove any previous Lumu UI so re-executing never stacks
do
	local function wipe(container)
		if not container then return end
		for _, g in ipairs(container:GetChildren()) do
			if g:IsA("ScreenGui") and (g.Name:match("^LumuHubMain") or g.Name:match("^LumuHubNotify") or g.Name:match("^LumuHubKey") or g.Name:match("^LumuHubLoading") or g.Name == "ZenUI_ScreenGui") then
				pcall(function() g:Destroy() end)
			end
		end
	end
	pcall(wipe, game:GetService("CoreGui"))
	pcall(function() wipe(game:GetService("Players").LocalPlayer:FindFirstChild("PlayerGui")) end)
end
-- Design preference (written by the in-UI "Load ... UI" button)
local DESIGN_FILE = "lumu_design.json"
local function readDesignPref()
	if not (isfile and readfile) then return nil end
	local okE = false
	pcall(function() okE = isfile(DESIGN_FILE) end)
	if not okE then return nil end
	local okR, raw = pcall(readfile, DESIGN_FILE)
	if not okR or not raw or raw == "" then return nil end
	local okJ, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
	if okJ and type(data) == "table" and type(data.design) == "string" then return data.design end
	local txt = tostring(raw):gsub("%s", "")
	if txt == "Sidebar" or txt == "TopBar" then return txt end
	return nil
end

if DESIGN == "Auto" then
	DESIGN = readDesignPref() or "TopBar"
end

local URL = (DESIGN == "TopBar") and (RAW .. "LumuHubTopbar.lua") or (RAW .. "LumuHubSidebar.lua")

local Astral = loadstring(game:HttpGet(URL))()
local Icons = loadstring(game:HttpGet(RAW .. "icons_sprites.lua"))()
Astral:RegisterIcons(Icons)

local Window = Astral:CreateWindow({ Title = "Lumu", SubTitle = "Test", badge = "TEST", AutoLoad = true, AutoLoadConfig = true, ConfigName = "lumu_autoload.json" })

-- ---------- Game Status ----------
local Status = Window:AddGameStatus({
	Title = "Game Status", Icon = "Chromatic Key1",
	Rows = {
		{ Name = "Design",  Value = DESIGN,   Icon = "Badge Star", Color = "gold"  },
		{ Name = "Players", Value = "12/12",  Icon = "Gun",        Color = "green" },
	},
})
Status:Countdown("Server Uptime", 0, "up")
Status:Countdown("Next Boss Spawn", 5 * 60)
Status:SetRow("Next Boss Spawn", { Icon = "volcano-s1", Color = "orange" })

local Main = Window:MakeTab({ "Main", "Badge Star" })
local Tests = Window:MakeTab({ "Tests", "Trophy1" })

-- ---------- TEXT ----------
Main:AddLabel({ Title = "Plain text", Description = "title 14 + desc 15", Icon = "Money" })
Main:AddLabel({ Title = "No icon text", Description = "no icon" })
Main:AddLabel({ Title = "Big text", Description = "custom", TextSize = 18, DescSize = 14, Icon = "Gun" })
Main:AddParagraph({ Title = "Paragraph icon", Description = "24px icon, 13px text, wraps.", Icon = "Bones1" })
Main:AddParagraph({ Title = "Paragraph image", Description = "banner", Image = "rbxassetid://17160800734" })
Main:AddParagraph({ Title = "Paragraph plain", Description = "no icon." })

-- ---------- BUTTONS ----------
Main:AddButton({ Title = "Text button", Icon = "Gun", Callback = function() print("text") end })
Main:AddButton({ Title = "Button + desc", Description = "second line", Icon = "Money", Callback = function() end })
Main:AddButton({ Title = "No icon", Callback = function() end })
Main:AddButton({ Title = "Locked", Description = "grey", Icon = "Badge Lock", Locked = true, Callback = function() end })
Main:AddButton({ Title = "Left", Position = "Left", Icon = "Gun", Callback = function() end })
Main:AddButton({ Title = "Right", Position = "Right", Icon = "Gun", Callback = function() end })
Main:AddMultiButton({ Title = "Tiles (icon only)", Columns = 4, Buttons = {
	{ Icon = "Money" }, { Icon = "Gun", Color = "red" }, { Icon = "Fruit", Color = "green" },
	{ Icon = "Bones1", Color = "blue" }, { Icon = "volcano-s1", Color = "purple" },
	{ Icon = "Blessed Chest1", Color = "gold" }, { Icon = "Badge Star", Color = "pink" },
	{ Icon = "Skull Guitar1", Color = "cyan" },
}})
Main:AddMultiButton({ Title = "Icon + text", Columns = 2, Buttons = {
	{ Title = "Kill",      Icon = "Gun",               Color = "red",    Callback = function() print("kill") end },
	{ Title = "Respawn",   Icon = "Blue Egg1",         Color = "green",  Callback = function() print("respawn") end },
	{ Title = "Rejoin",    Icon = "Faster Ships1",     Color = "blue",   Callback = function() print("rejoin") end },
	{ Title = "ServerHop", Icon = "starter-island-s1", Color = "purple", Callback = function() print("hop") end },
}})
Main:AddMultiButton({ Title = "All colours", Columns = 4, Buttons = {
	{ Title = "Red", Color = "red" }, { Title = "Green", Color = "green" },
	{ Title = "Blue", Color = "blue" }, { Title = "Purple", Color = "purple" },
	{ Title = "Orange", Color = "orange" }, { Title = "Gold", Color = "gold" },
	{ Title = "Cyan", Color = "cyan" }, { Title = "Pink", Color = "pink" },
}})

-- ---------- TOGGLE / TICK (68x32 switch, 28px knob, 44px box) ----------
Main:AddToggle({ Title = "Toggle", Icon = "Faster Ships1", Callback = function(s) print("toggle:", s) end })
Main:AddToggle({ Title = "Toggle on", Default = true, Icon = "Faster Ships1" })
Main:AddToggle({ Title = "Toggle no icon" })
Main:AddTick({ Title = "Tick", Icon = "Checkmark", Callback = function(s) print("tick:", s) end })
Main:AddTick({ Title = "Tick on", Default = true, Icon = "Checkmark" })
Main:AddTick({ Title = "Tick no icon" })

-- ---------- INPUTS ----------
Main:AddSlider({ Title = "Slider", Min = 1, Max = 100, Increase = 1, Default = 50, Icon = "Gun", Callback = function(v) print("slider:", v) end })
Main:AddSlider({ Title = "Slider step 10", Min = 0, Max = 200, Increase = 10, Default = 100, Icon = "Money" })
Main:AddSlider({ Title = "Slider no icon", Min = 1, Max = 10, Default = 5 })
Main:AddTextbox({ Title = "Textbox", Description = "type", Placeholder = "Enter text...", Icon = "Fishing Rod1", Callback = function(t) print("typed:", t) end })
Main:AddTextbox({ Title = "Textbox clear", Placeholder = "wipes", ClearOnFocus = true })
Main:AddKeybind({ Title = "Keybind", Default = Enum.KeyCode.RightControl, Icon = "Badge Gear", Callback = function(k) print("key:", k.Name) end })
Main:AddKeybind({ Title = "Keybind no icon", Default = Enum.KeyCode.F })
Main:AddColorpicker({ Title = "Color", Icon = "Money", Callback = function() end })
Main:AddColorpicker({ Title = "Color no icon" })

-- ---------- SELECTORS (search bar + 22px rounded-square count badge) ----------
local selLive = Main:AddSelector({ Title = "Selector (live options)", Options = { "One", "Two", "Three" }, Default = "One", Icon = "Fruit", Callback = function(v) print("sel:", v) end })
local cpA = Main:AddColorpicker({ Title = "Color A (own value)", Icon = "Money", Callback = function() end })
local cpB = Main:AddColorpicker({ Title = "Color B (own value)", Icon = "Money", Callback = function() end })
Main:AddButton({ Title = "Swap selector options", Description = "open the panel first, then press", Icon = "Fruit", Callback = function()
	local sets = {
		{ "Alpha", "Beta", "Gamma" },
		{ "One", "Two", "Three" },
		{ "Dragon", "Yeti", "Kraken" },
	}
	selLive:SetOptions(sets[math.random(1, #sets)])
end})
Main:AddButton({ Title = "Color A -> red", Icon = "Money", Callback = function() cpA:Set(Color3.fromRGB(255, 0, 0)) end })
Main:AddButton({ Title = "Color B -> green", Icon = "Money", Callback = function() cpB:Set(Color3.fromRGB(0, 255, 0)) end })
Main:AddButton({ Title = "Print both colors", Icon = "question-mark", Callback = function()
	local a, b = cpA:Get(), cpB:Get()
	Window:Notify({ Type = "info", Title = "Colors", Message = "A and B are independent (see console).", Duration = 5 })
	print("A:", a, "B:", b)
end})
Main:AddSelector({ Title = "Selector + SEARCH", Description = "type to filter", Options = { "Dragon", "Yeti", "Kraken", "Leopard" }, Search = true, Icon = "Fruit" })
Main:AddSelector({ Title = "Multi count", Description = "badge shows number picked", Options = { "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L" }, Multi = true, Default = { "A", "B" }, Icon = "Fruit" })
Main:AddSelector({ Title = "Multi + SEARCH", Options = { "Sword", "Gun", "Fruit" }, Multi = true, Search = true, Icon = "Fruit" })
Main:AddSelector({ Title = "Selector no icon", Options = { "x", "y", "z" } })
Main:AddDiscordCard({ ServerData = {
	ServerName = "LumuHub Community",
	Description = "Test the Join button",
	InviteCode = "xUKZJBXM",
	OnlineCount = 29,
	MemberCount = 29,
}})

-- ---------- LABELS (status badges + countdowns) ----------
local boss = Main:AddLabel({ Title = "Boss (bad)", Description = "press the buttons", Icon = "Bones1", Status = "bad" })
Main:AddLabel({ Title = "Boss (waiting)", Icon = "Fruit", Status = "waiting" })
Main:AddLabel({ Title = "Boss (good)", Icon = "Blue Egg1", Status = "good", StatusText = "ALIVE" })
local t1 = Main:AddLabel({ Title = "Badge timer", Icon = "Money", Status = "waiting" })
t1:SetCountdown(12, { Where = "badge", Suffix = "s" })
local t2 = Main:AddLabel({ Title = "Desc timer", Icon = "Bronze Trophy1" })
t2:SetCountdown(12, { Prefix = "Respawns in " })
local auto = Main:AddLabel({ Title = "Auto count 10", Description = "counts by itself, flips to SPAWNED", Icon = "Blessed Chest1", Status = "waiting" })
auto:SetCountdown(10, { Where = "badge", Suffix = "s" })
local loop = Main:AddLabel({ Title = "Looping timer", Description = "restarts by itself", Icon = "Trophy1", Status = "waiting" })
local function startLoop()
	loop:SetCountdown(10, { Where = "badge", Suffix = "s", OnDone = function() task.wait(1); startLoop() end })
end
startLoop()

-- ---------- TESTS TAB ----------
Tests:AddButton({ Title = "SPAWN (green)", Icon = "Checkmark", Callback = function() boss:SetStatus("good", "SPAWNED") end })
Tests:AddButton({ Title = "DESPAWN (red)", Icon = "Close", Callback = function() boss:SetStatus("bad") end })
Tests:AddButton({ Title = "WAITING (yellow)", Icon = "question-mark", Callback = function() boss:SetStatus("waiting") end })
Tests:AddButton({ Title = "Hide badge", Icon = "Close", Callback = function() boss:SetStatus("none") end })
Tests:AddButton({ Title = "Restart timers", Icon = "Trophy1", Callback = function()
	t1:SetCountdown(12, { Where = "badge", Suffix = "s" })
	t2:SetCountdown(12, { Prefix = "Respawns in " })
end})
Tests:AddButton({ Title = "Reset loop", Icon = "Trophy1", Callback = function() startLoop() end })
Tests:AddButton({ Title = "Timer UP", Icon = "Trophy1", Callback = function() t2:SetCountdown(0, "up") end })
Tests:AddButton({ Title = "Stop timers", Icon = "Close", Callback = function() t1:StopCountdown(); t2:StopCountdown() end })

-- notifications: black cards, coloured icon/border/countdown/progress
Tests:AddButton({ Title = "Notify green", Icon = "Checkmark", Callback = function()
	Window:Notify({ Type = "good", Title = "Success", Message = "It worked.", Duration = 5 })
end})
Tests:AddButton({ Title = "Notify yellow", Icon = "question-mark", Callback = function()
	Window:Notify({ Type = "warning", Title = "Warning", Message = "Be careful.", Duration = 5 })
end})
Tests:AddButton({ Title = "Notify red", Icon = "Close", Callback = function()
	Window:Notify({ Type = "bad", Title = "Failed", Message = "It broke.", Duration = 5 })
end})
Tests:AddButton({ Title = "Notify + buttons", Icon = "Trophy1", Callback = function()
	Window:Notify({ Type = "warning", Title = "Reset?", Message = "Yes = green, No = red.", Duration = 10, Actions = {
		{ Text = "Yes", Type = "good", Callback = function() Window:Notify({ Type = "good", Title = "Yes", Message = "You pressed Yes.", Duration = 3 }) end },
		{ Text = "No",  Type = "bad",  Callback = function() Window:Notify({ Type = "bad",  Title = "No",  Message = "You pressed No.",  Duration = 3 }) end },
	}})
end})
Tests:AddButton({ Title = "Spam all", Icon = "question-mark", Callback = function()
	Window:Notify({ Type = "good", Title = "One", Message = "green", Duration = 4 })
	task.wait(0.35)
	Window:Notify({ Type = "warning", Title = "Two", Message = "yellow", Duration = 4 })
	task.wait(0.35)
	Window:Notify({ Type = "bad", Title = "Three", Message = "red", Duration = 4 })
end})

-- window: themes (Dark/Midnight/Purple) + accent + layout + sizes
Tests:AddSelector({ Title = "Theme (10)", Options = { "Dark", "Midnight", "Purple", "Crimson", "Forest", "Ocean", "Sunset", "Rose", "Slate", "Coffee" }, Default = "Dark", Icon = "Badge Star", Callback = function(v)
	Window:SetTheme(v)
	Window:Notify({ Type = "info", Title = "Theme", Message = "Switched to " .. tostring(v), Duration = 4 })
end})
Tests:AddSelector({ Title = "Accent", Options = { "Blue", "Red", "Purple", "Emerald", "Gold" }, Default = "Blue", Icon = "Money", Callback = function(v)
	local c = { Blue = Color3.fromRGB(0,153,235), Red = Color3.fromRGB(231,76,60), Purple = Color3.fromRGB(138,90,255),
	            Emerald = Color3.fromRGB(46,204,113), Gold = Color3.fromRGB(241,196,15) }
	Window:SetAccent(c[v] or c.Blue)
end})
Tests:AddSelector({ Title = "Layout", Options = { "1 Column", "2 Columns" }, Default = "2 Columns", Icon = "Badge Gear", Callback = function(v)
	Window:SetLayoutMode(v == "1 Column" and "OneColumn" or "TwoColumn")
end})
Tests:AddButton({ Title = "PC size", Icon = "Badge Gear", Callback = function() Window:SetWindowSize(880, 600) end })
Tests:AddButton({ Title = "Mobile size", Icon = "Badge Gear", Callback = function() Window:SetWindowSize(550, 400) end })
Tests:AddButton({ Title = "Status on/off", Icon = "Chromatic Key1", Callback = function() Status:Toggle() end })
Tests:AddButton({ Title = "Debug info", Icon = "question-mark", Callback = function() Window:DebugInfo() end })
Tests:AddButton({ Title = "Background: show", Description = "brighter custom bg", Icon = "Money", Callback = function()
	Window:SetBackground("rbxassetid://17160800734")
	Window:SetBackgroundDim(0.15)
	Window:Notify({ Type = "good", Title = "Background", Message = "Set + dim 0.15 (bright)", Duration = 4 })
end})
Tests:AddButton({ Title = "Background: dimmer", Icon = "Money", Callback = function()
	Window:SetBackgroundDim(0.6)
end})
Tests:AddButton({ Title = "Background: reset", Icon = "Close", Callback = function()
	Window:ResetBackground()
	Window:SetBackgroundDim(0.35)
end})
local postCount = 0
Tests:AddButton({ Title = "Add tab AFTER theme", Description = "proves post-switch elements come out themed", Icon = "Badge Star", Callback = function()
	postCount = postCount + 1
	local tb = Window:MakeTab({ "Post " .. postCount, "Gun" })
	tb:AddButton({ Title = "New button", Icon = "Money", Callback = function() end })
	tb:AddToggle({ Title = "New toggle", Icon = "Faster Ships1", Callback = function() end })
	tb:AddLabel({ Title = "New label", Description = "should match the theme", Icon = "Trophy1", Status = "good" })
	Window:Notify({ Type = "good", Title = "Tab added", Message = "Check it matches " .. tostring(Window:GetTheme()), Duration = 4 })
end})


-- ================= CUSTOM THEME (color pickers) =================
local CustomTab = Window:MakeTab({ "Custom", "Money" })
local customColors = {
	Background = Color3.fromRGB(20, 20, 26),
	Card = Color3.fromRGB(30, 30, 38),
	Text = Color3.fromRGB(255, 255, 255),
	SubText = Color3.fromRGB(170, 170, 180),
	Border = Color3.fromRGB(60, 60, 72),
	Accent = Color3.fromRGB(0, 153, 235),
}
CustomTab:AddLabel({ Title = "Custom theme", Description = "pick colours, then press Apply", Icon = "Money" })
for _, part in ipairs({ "Background", "Card", "Text", "SubText", "Border", "Accent" }) do
	CustomTab:AddColorpicker({ Title = part, Default = customColors[part], Icon = "Money", Callback = function(c)
		customColors[part] = c
	end})
end
CustomTab:AddButton({ Title = "Apply custom theme", Icon = "Checkmark", Callback = function()
	Window:SetCustomTheme(customColors)
	Window:Notify({ Type = "good", Title = "Custom theme", Message = "Applied your colours.", Duration = 4 })
end})
CustomTab:AddButton({ Title = "Back to Dark", Icon = "Close", Callback = function()
	Window:SetTheme("Dark")
end})
-- ================= DESIGN SWITCHER (persisted) =================
local DesignTab = Window:MakeTab({ "Design", "Badge Gear" })
local otherDesign = (DESIGN == "Sidebar") and "TopBar" or "Sidebar"
DesignTab:AddLabel({ Title = "Current design", Description = DESIGN .. "  (saved to " .. DESIGN_FILE .. ")", Icon = "Badge Star" })
DesignTab:AddButton({ Title = "Load " .. otherDesign .. " UI", Description = "saves your choice + reloads", Icon = "Faster Ships1", Callback = function()
	Window:SetDesign(otherDesign)
	if type(getgenv().LumuHubReload) == "function" then
		getgenv().LumuHubReload(otherDesign)
	else
		Window:Notify({ Type = "warning", Title = "Saved", Message = "Re-execute to load " .. otherDesign .. ".", Duration = 5 })
	end
end})
DesignTab:AddButton({ Title = "Save UI positions", Description = "window + status panels", Icon = "Checkmark", Callback = function()
	Window:SaveUIPositions()
	Window:Notify({ Type = "good", Title = "Saved", Message = "UI positions stored.", Duration = 4 })
end})
DesignTab:AddButton({ Title = "Reset UI positions", Icon = "Close", Callback = function()
	Window:ResetUIPositions()
	Window:Notify({ Type = "warning", Title = "Reset", Message = "Back to default position.", Duration = 4 })
end})
DesignTab:AddButton({ Title = "Save config", Description = "toggles/flags auto-load", Icon = "Money", Callback = function()
	Window:SaveConfig("lumu_autoload.json")
	Window:Notify({ Type = "good", Title = "Config saved", Message = "Auto-loads next execute.", Duration = 4 })
end})
DesignTab:AddButton({ Title = "Load config", Icon = "Money", Callback = function()
	local ok = Window:LoadConfig("lumu_autoload.json")
	Window:Notify({ Type = ok and "good" or "warning", Title = "Config", Message = ok and "Loaded." or "Nothing saved yet.", Duration = 4 })
end})

-- ================= DESIGN RELOAD + TELEPORT PERSISTENCE =================
getgenv().LumuHubReload = function(design)
	design = design or "Sidebar"
	pcall(function() Window:Notify({ Type = "good", Title = "Switching", Message = "Loading " .. design .. " UI...", Duration = 3 }) end)
	task.wait(0.5)
	local ok, err = pcall(function()
		loadstring(game:HttpGet(RAW .. "LumuLoader.lua"))()
	end)
	if not ok then
		print("[Lumu] reload failed: " .. tostring(err))
	end
end

if type(queue_on_teleport) == "function" then
	local okq = pcall(queue_on_teleport, 'loadstring(game:HttpGet("' .. RAW .. 'LumuLoader.lua"))()')
	print("[Lumu] queue_on_teleport " .. (okq and "armed" or "failed"))
end
Window:Notify({ Type = "good", Title = "Ready", Message = DESIGN .. " test loaded.", Duration = 6 })
print("[Lumu] " .. DESIGN .. " test loaded")
