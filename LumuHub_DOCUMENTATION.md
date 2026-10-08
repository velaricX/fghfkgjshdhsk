# LumuHub UI — Full Documentation (Sidebar + TopBar)

Two libraries, same API. Pick one per script.

| File | Layout |
|---|---|
| `SidebarPlayerBrowser.lua` | Sidebar tabs on the left |
| `TopbarPlayerBrowser.lua` | Top bar tab pills |

`LmIcon.lua` holds the shared icon pack (register it or icons fall back to text).

## 1. Loading

```lua
local RAW = "https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/<branch-or-sha>/"
local function safeLoad(name)
    local src = game:HttpGet(RAW .. name)
    local fn, err = loadstring(src)
    if not fn then error("[LOAD-FAIL] " .. name .. " : " .. tostring(err), 0) end
    return fn()
end

local Lib = safeLoad("SidebarPlayerBrowser.lua") -- or TopbarPlayerBrowser.lua
Lib:RegisterIcons(safeLoad("LmIcon.lua"))

local Win = Lib:CreateWindow({ Title = "My Hub", SubTitle = "v1" }) -- CreateWindow = MakeWindow
local Tab = Win:MakeTab({ "Main", "Home" })
```

Rules: no `queue_on_teleport` / `SetAutoReexecute` anywhere. Kill old `LumuHub*` ScreenGuis before rebuilding on re-execute.

## 2. CreateWindow config

```lua
Lib:CreateWindow({
    Title = "My Hub",        -- default "Astral"
    SubTitle = "v1",         -- default "Hub"
    Logo = "rbxassetid://...", -- logo button image (default built-in)
    Size = UDim2.new(0, 560, 0, 420), -- window size override
    badge = "PREMIUM",       -- header badge text
    badgecolor = "blue",     -- "blue" | "red" | "green" | Color3
    NotifySize = 258,        -- notification card width
    SettingsTab = false,     -- hides the auto settings gear tab
    SearchBar = false,       -- hides global search (default on)
    SearchFlashTime = 5,     -- seconds a search hit flashes
    StopButton = false,      -- disables the auto "Stop Farm" button
    OpenAnimation = false,   -- skips intro animation
})
```

Floating buttons: circular **logo button** (toggles UI, draggable, left side) and **Stop Farm button** (spawns under the logo, draggable, tap-vs-drag so dragging never fires it).

## 3. Tabs

```lua
local Tab = Win:MakeTab({ "Farming", "Home" })  -- { Name, Icon } | { Name=, Icon= } | "Name"
local Sub = Tab:AddSubTab({ "Bosses", "skull" }) -- sub-tab bar; elements added AFTER this call belong to it
```

Icons: any `LmIcon.lua` key (`"Home"`, `"Players"`, `"Checkmark"`, `"star"`, `"chest"`, `"timer"`, ...), an `rbxassetid://...`, or nil.

## 4. Elements (all take `Position = "Left" | "Right"` to force a column)

### Button
```lua
local b = Tab:AddButton({ Title = "Start", Description = "optional", Icon = "Checkmark",
    Locked = false, Callback = function() end })
b:SetLocked(true)  b:IsLocked()
```

### Toggle / Tick
```lua
local t = Tab:AddToggle({ Title = "Auto Farm", Description = "...", Icon = "Home",
    Default = false, Flag = "autofarm", Callback = function(on) end })
t:Set(true)  t:Get()
local k = Tab:AddTick({ Title = "Tick", Default = false, Flag = "tick1", Callback = function(on) end })
k:Set(false)  k:Get()
```
Both register into the stop-farm kill switch. `Flag` (string) opts into `SaveConfig`/`LoadConfig`.

### Slider
```lua
local s = Tab:AddSlider({ Title = "Speed", Min = 1, Max = 100, Increase = 1,
    Default = 16, Icon = "star", Flag = "speed", Callback = function(v) end })
s:Set(50)  s:Get()
```

### Selector (slide-in panel from the right)
```lua
local sel = Tab:AddSelector({ Title = "Sea", Options = { "Sea 1", "Sea 2" }, Default = "Sea 1",
    Search = true, Multi = false, Icon = "star", Flag = "sea", Callback = function(v) end })
sel:Set("Sea 2")  sel:Get()  sel:SetOptions({ "A", "B" }, "A")
```
`Multi = true` + table `Default` for multi-select. Also `TabObject.Addselector` lowercase alias works.

### Textbox
```lua
local tb = Tab:AddTextbox({ Title = "Name", Placeholder = "Type here...", Default = "",
    ClearOnFocus = false, Icon = "Home", Flag = "name", Callback = function(text) end })
tb:Set("x")  tb:Get()
```

### Colorpicker
```lua
local cp = Tab:AddColorpicker({ Title = "Theme", Default = Color3.fromRGB(0,125,255),
    Icon = "star", Flag = "themecolor", Callback = function(c) end })
cp:Set(Color3.new(1,0,0))  cp:Get()
```

### Keybind
```lua
local kb = Tab:AddKeybind({ Title = "Toggle UI", Default = Enum.KeyCode.RightControl,
    Icon = "Home", Flag = "uikey", Callback = function(key) end })
kb:Set(Enum.KeyCode.F)  kb:Get()
```

### Label / Paragraph / Section
```lua
local L = Tab:AddLabel({ Title = "Info", Description = "...", Icon = "Home" })
L:SetText("...")  L:SetDescription("...")  L:SetIcon("star")
L:SetStatus("good", "Online")            -- good | warning | bad pill
L:SetCountdown(90)                       -- mm:ss ticker, L:StopCountdown()

Tab:AddParagraph({ Title = "Head", Description = "Body", Icon = "Home", Image = "star" })
-- also: Tab:AddParagraph({ "Head", "Body" })
local sec = Tab:AddSection({ Title = "Farming", Icon = "Home" })   -- gradient bar header
sec:SetTitle("v2")  sec:SetIcon("star")
local cs = Tab:AddContentSection({ Title = "Combat" })             -- classic underline header
cs:SetTitle("v2")
```

### MultiButton (grid of buttons)
```lua
Tab:AddMultiButton({ Title = "Teleports", Description = "...", Icon = "star",
    Columns = 2, ButtonColor = "blue", -- named color or Color3, optional
    Buttons = {
        { Title = "Sea 1", Callback = function() end },
        { Title = "Sea 2", Icon = "star", Color = "red", Callback = function() end },
        { Icon = "chest", Callback = function() end }, -- no titles = big icon tiles
    }})
```
Named colors: red green blue cyan purple pink orange gold white dark.

### MultiColorPicker (every tile is a mini picker)
```lua
Tab:AddMultiColorPicker({ Title = "Skins", Columns = 2,
    Buttons = {
        { Title = "Kill", Icon = "Gun", Color = "red", Callback = function(i, c) end },
    }})
```

### SkillSelector (dropdown + per-skill cooldown box in the panel)
```lua
local sk = Tab:AddSkillSelector({ Title = "Skill", Default = "X",
    Skills = {
        { Key = "Z", Hold = 0.5, Cooldown = 3 },
        { Key = "X", Hold = 1,   Cooldown = 0.78 }, -- decimals fine
    },
    Callback = function(key, hold) end })
sk:GetSelected()  sk:SetSelected("Z")  sk:GetSkills()
sk:SetHold("Z", 1)  sk:SetCooldown("Z", 4)  sk:Trigger("X") -- fire from code (mobile)
```
Pressing the skill key fires `Callback(key, hold)`; presses inside cooldown are ignored. Typing a number in a panel row box updates that skill and the card (`X · 0.78s`).

### PlayerBrowser
```lua
local pb = Tab:AddPlayerBrowser({ Title = "Players", Mode = "Row", -- "Row" | "Grid"
    Search = true, Multi = false,
    Extra = function(plr) return "Lv " .. (plr.leaderstats.Level.Value) end, -- pill per row
    Callback = function(plr) end,          -- fires on select
    OptionsCallback = function(plr) end })
pb:Refresh()  pb:SetMode("Grid")  pb:GetSelected()  pb:ClearSelected()
```
Click a selected row again to deselect. `#1` rank + halo on top player.

### DiscordCard
```lua
Tab:AddDiscordCard({ FullWidth = true, -- single column, big banner
    ServerData = { InviteCode = "your-code", -- part after discord.gg/
        ServerName = "Name",               -- auto from API if nil
        ServerIconId = "...",              -- auto from API if nil
        Description = "...", OnlineCount = 46, MemberCount = 120 } })
```
Live online/member counts load from Discord's public invite API; Join button copies the invite and turns green (`Copied!`).

## 5. Window methods

```lua
-- Stop button (auto "Stop Farm" unless StopButton = false)
local stop = Win:AddStopButton({ Text = "Stop Farm", Position = UDim2.new(...),
    ToggleList = { myToggle }, Callback = function() end })
stop:SetText("...")  stop:Destroy()  -- stop.Button = the instance
-- Tap kills: every Toggle/Tick with Set(false) (or your ToggleList), then Callback.

-- Notifications
Win:Notify({ Type = "good", Title = "Done", Message = "...", Duration = 10, -- good|warning|bad
    Actions = { { Text = "OK", Callback = function() end } } })

-- Game status overlay (draggable, outside the window)
local S = Win:AddGameStatus({ Title = "Game Status", Icon = "timer",
    Width = 240, RowHeight = 30, MaxHeight = 300, Enabled = true })
S:Set("Uptime", "56h")                                   -- same as SetRow(name, {Value=})
S:SetRow("Boss", { Value = "5m", Icon = "timer", Color = "gold" }) -- named colors + Color3
S:SetColor("Boss", "red")  S:SetIcon("Boss", "star")  S:Get("Boss")
S:Remove("Boss")  S:Clear()  S:SetRows({ {"A","1"}, {"B","2"} })
S:Countdown("Moon", 1380)            -- down; mode "up" counts up; 4th arg onDone
S:StopCountdown("Moon")
S:SetTitle("...")  S:SetTitleIcon("star")  S:SetPosition(UDim2.new(...))
S:Show()  S:Hide()  S:Toggle()  S:IsEnabled()  S:SetEnabled(true)  S:Destroy()

-- Theme / look
Win:SetTheme("Midnight")  Win:GetTheme()  -- Dark Midnight Purple Crimson Forest Ocean Sunset Rose Slate Coffee
Win:SetCustomTheme({ Background = Color3.fromRGB(20,20,26), Card = ..., Text = ...,
    SubText = ..., Border = ..., Accent = ... })
Win:SetAccent(Color3.fromRGB(0,153,235))
Win:SetBackground("rbxassetid://...")  Win:LoadBackgroundFromUrl("https://...")
Win:SetBackgroundDim(0.25)  Win:SetTransparency(20)  Win:ResetBackground()
Win:SetUIScale(100)            -- 70..130 or 0.7..1.3, both accepted
Win:SetLayoutMode("Auto")      -- "Auto" | "1 column" | "2 columns" (also "OneColumn"/"TwoColumn", "1"/"2")
Win:SetStatusScale(1)          -- 0.7..1.3 game-status size
Win:SetWindowSize(560, 420)    -- Win:PlayIntro() replays intro, Win:RefreshAll(), Win:DebugInfo()

-- Configs (needs executor writefile/readfile; files are lumu_*.json)
Win:SaveConfig()  Win:LoadConfig()            -- default lumu_config.json, Flagged elements only
Win:SaveConfig("lumu_farm.json")
Win:SaveUIPositions()  Win:LoadUIPositions()  Win:ResetUIPositions() -- main, logo, status
```

## 6. Built-in Settings tab + search

Gear button (top-right, auto-added unless `SettingsTab = false`) opens a hidden tab with 8 sub-tabs in order: **Info** (about + owners + Discord invite copy button), **Translation** (language picker), **Themes** (presets + accent + custom + BG images + BG dim + transparency + reset), **UI** (Sidebar/TopBar choice — saved only, loads on NEXT execute, never live), **Status**, **Display** (UI size, columns, transparency, stop-button toggle, intro), **Debug** (reset positions, refresh, debug info), **Configs** (`lumu_*.json` save/load/delete/rescan).

Global search (right-side box unless `SearchBar = false`): fuzzy match across every element, Enter jumps + accent-flashes the card for `SearchFlashTime` (default 5s), Esc clears, `Ctrl+K` focuses.

## 7. Translations / icons / mobile

```lua
Lib:AddTranslations("es", { Farm = "Granja" })  Lib:SetLanguage("es") -- tr() titles refresh live
Lib:GetLanguages() -- { "Deutsch", "English", "Español", "Français", ... }
```
Built-ins: English, Español, Français, Deutsch. Translation covers everything including dropdown/panel option text (values stay English internally, so callbacks like `SetTheme` keep working). Add packs BEFORE `CreateWindow` so the settings language list includes them.

**Custom languages (no Google, all manual):** settings → Translation tab: type a name → Create language → pick it → add words via English word + Translation boxes → Add/update word → Save language (writes `lumu_lang_<Name>.json`, auto-loaded next execute). Delete language removes pack + file. Same from code:
```lua
Lib:AddTranslations("Portugues", { Farming = "Agricultura" })
Lib:SetLanguage("Portugues")
Lib:SaveLanguage("Portugues")     -- needs writefile; Lib.CountWords("Portugues")
Lib.DeleteLanguage("Portugues")   -- back to English + deletes file
```
Pack format: `{ ["English text"] = "translation", ... }` — keys must match element titles EXACTLY (spaces count: `"  Auto Ken"` needs its leading spaces). Empty value `""` = not translated yet, English shows. Special key `"TRANSLATOR" = "name"` credits who translated it (shown in the Translation tab). Mobile is auto (`TouchEnabled` + small viewport): compact sizes, 2-column cap, smaller panels. Test with `IsMobile` paths in mind.

**Design pick (sidebar vs topbar) across executes:**
```lua
local design = "Sidebar"
pcall(function()
    local d = Lib.GetSavedDesign and Lib.GetSavedDesign()
    if d == "Sidebar" or d == "TopBar" then design = d end
end)
local Lib2 = (design == "TopBar") and safeLoad("n2_shell.lua") or safeLoad("n1_core.lua")
```

## 8. Minimal full example

```lua
local Lib = safeLoad("SidebarPlayerBrowser.lua")
Lib:RegisterIcons(safeLoad("LmIcon.lua"))
local Win = Lib:CreateWindow({ Title = "My Hub" })
local Tab = Win:MakeTab({ "Farm", "Home" })
local farm = Tab:AddToggle({ Title = "Auto Farm", Default = false, Flag = "farm",
    Callback = function(on) print("farm", on) end })
Tab:AddSlider({ Title = "Speed", Min = 1, Max = 200, Default = 16, Flag = "speed",
    Callback = function(v) print(v) end })
Tab:AddButton({ Title = "Stop now", Callback = function() farm:Set(false) end })
Win:SaveConfig() -- whenever you want to persist Flagged states
```
