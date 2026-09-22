# Lumu UI — TopBar Design (`LumuHubTopbar.lua`)

**This file is the TOPBAR design only** (horizontal tab pills across the top,
wider content area, no sidebar). For the left-sidebar design use
`LumuHubSidebar.lua` — **same API**, see the other doc. You do **not** pass a
`Design` flag; the file itself is the design.

Two files work together:

| File | What |
|---|---|
| `LumuHubTopbar.lua` | UI library only (no demo). Ends with `return Astral`. |
| `icons_sprites.lua` | Icon module: ~1800 game sprites + 92 classic UI icons. Ends with `return SPI`. |

```lua
local Astral = loadstring(game:HttpGet("https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/LumuHubTopbar.lua"))()
local Icons  = loadstring(game:HttpGet("https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/icons_sprites.lua"))()
Astral:RegisterIcons(Icons)   -- after loading the lib, before building
```

Without the icons file the UI still runs (6 built-in fallbacks cover its own
arrows/checks), but element icons stay blank.

Build order: **Window → Category → Tab → Elements**.

**Tab strip:** no lines above or below it - just pills on the window. Tabs
auto-size to their text (40px tall) so long names never overlap. More tabs
than fit? Hold left-click and drag - it travels 4.5x your cursor - plus
touch-drag and fast wheel. A chevron box on the right collapses/expands
the strip. 12px gap under the header, 20px above the content.

---

## 1. Window (name, size)

```lua
local Window = Astral:CreateWindow({
  Title = "Lumu",             -- main name in the header
  SubTitle = "by Velaric",    -- smaller text next to it (optional)
  badge = "Premium",          -- badge pill text (optional)
  Theme = "Dark",              -- Dark | Midnight | Purple | Crimson | Forest | Ocean | Sunset | Rose | Slate | Coffee
  badgecolor = "blue",        -- "blue" | "red" | "green" or a Color3
  Logo = "rbxassetid://...",  -- floating hide-UI button image (optional, has default)
  BackgroundImage = "rbxassetid://...", -- custom backdrop (optional)
  NotifySize = 300,           -- notification width in px (optional)
})
-- Astral.MakeWindow is the same (alias).
```

### Window size (auto + manual)

Default, no config needed:

- PC / laptop → **880×600**
- Mobile → **550×400**
- Emulator / cloud phone (touch, no accelerometer) → **500×370**
- Never shrinks below readability; only clamps if the screen is smaller.

```lua
Window:SetWindowSize(880, 600)   -- PC size
Window:SetWindowSize(550, 400)   -- mobile size
```

## 1b. Save / Load Config (survives server hop)

Give any element a `Flag = "unique-id"` (toggle, tick, slider, textbox,
selector, colorpicker, keybind all support it):

```lua
Tab:AddToggle({ Title = "Auto Farm", Flag = "autofarm", ... })
Tab:AddSlider({ Title = "Range", Flag = "range", ... })
```

```lua
Window:SaveConfig()             -- writes lumu_config.json
Window:LoadConfig()             -- restores everything, fires callbacks to resume
Window:SaveConfig("mine.json")  -- custom file name works too
```

Auto-load on every execute (best for server hops — nothing to press):

```lua
local Window = Astral:CreateWindow({
  Title = "Lumu",
  AutoLoad       = true,                  -- load saved flags ~1s after building
  AutoLoadConfig = true,                  -- same as AutoLoad (either works)
  ConfigName     = "lumu_autoload.json",  -- which file to read (default lumu_config.json)
})
```

## 1c. Design Switcher — Sidebar <-> TopBar (LIVE, no rejoin)

Both libraries carry the other design's URL, so you can switch at runtime.
The choice is saved to `lumu_design.json` and used on the next execute too.

```lua
print(Window:GetDesign())            -- "TopBar" or "Sidebar"

Window:SwitchDesign("Sidebar")       -- wipes this UI and rebuilds as the sidebar design
Window:SetDesign("TopBar")           -- alias of SwitchDesign
```

`SwitchDesign` tries, in order:

1. `getgenv().LumuHubReload(design)` — if your loader defines it, this rebuilds your
   **whole script** (all your tabs/elements) in the other design. Best result.
2. The hosted `LumuLoader.lua` — rebuilds the demo UI in the other design.
3. Last resort — rebuilds just this window's chrome in the other design.

To get path 1 (recommended), add this to your loader **before** you build the UI:

```lua
local RAW = "https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/"
getgenv().LumuHubReload = function(design)
  local url = (design == "TopBar") and (RAW .. "LumuHubTopbar.lua") or (RAW .. "LumuHubSidebar.lua")
  -- destroy the old GUI first (the lib names it LumuHubMain_<random>)
  for _, g in ipairs(game:GetService("CoreGui"):GetChildren()) do
    if g:IsA("ScreenGui") and g.Name:match("^LumuHubMain") then g:Destroy() end
  end
  local Astral = loadstring(game:HttpGet(url))()
  Astral:RegisterIcons(loadstring(game:HttpGet(RAW .. "icons_sprites.lua"))())
  buildMyUI(Astral)   -- your own builder function
end
```

There is also a **"Load Sidebar UI" / "Load TopBar UI"** button in the window header,
and the same thing on the **Design** tab of the demo loader.
## 2. Categories & Tabs

In TopBar, categories render as small inline chips in the tab strip.

```lua
Window:AddCategory("Main Features")          -- inline label in the strip

local FarmingTab = Window:MakeTab({"Farming", "wood"})
-- Format: {"Tab Name", "Icon"}  -- icon name, asset id, or digits
-- MakeTab("Name") works too (shows first-letter fallback icon)
```

Active tab shows a blue gradient + blue border + white flash.

## 3. Columns (Left / Right)

Every element accepts an optional `Position` field:

| Value | Effect |
|---|---|
| `"Left"` | pinned to the left column |
| `"Right"` | pinned to the right column |
| omitted | auto-balances by count |

```lua
Tab:AddButton({ Title = "A", Position = "Left", Callback = function() end })
```

Force the whole window to 1 or 2 columns (auto = 2 columns, drops to 1 under 380px):

```lua
Window:SetLayoutMode("OneColumn")  -- everything stacks left
Window:SetLayoutMode("TwoColumn")  -- restore 2-column grid
Window:SetLayoutMode("Auto")       -- default
```

## 4. Elements

Heights are desktop (mobile is slightly more compact).

### Button (64px)

```lua
Tab:AddButton({
  Title = "Admin Panel",        -- string
  Description = "Click this to execute code.", -- optional
  Icon = "Item1",               -- icon name | asset id | digits, optional
  Position = "Left",            -- "Left" | "Right" | nil
  Callback = function()         -- runs on click
    print("Button was clicked!")
  end,
  Locked = true,                -- optional: starts locked (gray + lock icon, clicks dead)
})
local btn = Tab:AddButton({ Title = "Farm" })  -- all buttons return a controller
btn:SetLocked(true)    -- lock it (e.g. feature broken by game patch)
btn:SetLocked(false)   -- unlock it
print(btn:IsLocked())  -- check state
```

### Toggle (64px card, 68x32 squircle switch, 28px knob)

```lua
local t = Tab:AddToggle({
  Title = "Auto Farm",
  Description = "Farms for you.", -- optional
  Default = false,              -- boolean
  Icon = "wood",                -- optional
  Position = "Left",            -- optional
  Callback = function(state)    -- true/false on every flip
    print(state)
  end
})
t:Set(true)   -- force on/off from code
```

### Tick / Checkbox (60px card, 44px box)

```lua
local c = Tab:AddTick({
  Title = "Fast Mode",
  Description = "Faster.",      -- optional
  Default = false,
  Icon = "star",                -- optional
  Position = "Right",           -- optional
  Callback = function(state) print(state) end
})
c:Set(false)
```

### Slider (64px card, 20px track, 20x28 thumb)

```lua
local s = Tab:AddSlider({
  Title = "Attack Range",
  Min = 1,                      -- number
  Max = 100,                    -- number
  Increase = 1,                 -- step size
  Default = 56,                 -- number
  Icon = "eye",                 -- optional
  Position = "Left",            -- optional
  Callback = function(value)    -- number, fires on drag + typing
    print(value)
  end
})
s:Set(80)   -- set from code (clamped + stepped)
```

### Textbox (auto height, returns controller)

```lua
local box = Tab:AddTextbox({
  Title = "Textbox Title",
  Description = "Text stays until you delete it.", -- optional, card grows if long
  Placeholder = "Enter text...",
  Default = "",                 -- starting text
  ClearOnFocus = false,         -- true = wipe on click (default false = persists)
  Icon = "search",              -- optional
  Position = "Left",            -- optional
  Callback = function(text)     -- fires ONLY when text actually changed
    print("User typed:", text)
  end
})
box:Set("hello")   -- set text (fires callback)
print(box:Get())   -- read text
```

### Selector / Dropdown (84px, returns controller)

**Has a built-in search bar — just pass `Search = true`.**
Multi-select shows a 22px rounded-square count badge (caps at `9+`).
`sel:SetOptions({...})` live-refreshes an open panel and drops dead selections.

```lua
local sel = Tab:AddSelector({
  Title = "Select Boss",
  Description = "Pick targets.",-- optional
  Options = {"Dragon", "Yeti", "Kraken"},
  Default = "Dragon",           -- string, or table for Multi
  Search = true,                -- shows a search/filter bar at the top
  Multi = true,                 -- multi-select (boolean)
  Icon = "chest",               -- optional
  Position = "Left",            -- optional
  Callback = function(value)    -- string (single) or table (multi)
    print(value)
  end
})
sel:Set("Yeti")                        -- pick from code
sel:SetOptions({"A", "B"}, "A")        -- replace option list live
-- Search bar filters options live as you type (case-insensitive).
-- Single: tap = pick + panel closes. Multi: tap toggles checkmarks,
-- count badge shows on the button, click anywhere outside to close.
```

### ColorPicker (64px row + slide-in panel, returns controller)

```lua
local cp = Tab:AddColorpicker({
  Title = "Accent Color",
  Description = "Customize the UI theme", -- optional
  Default = Color3.fromRGB(0, 153, 235),  -- Color3
  Icon = "brush",               -- optional
  Position = "Left",            -- optional
  Callback = function(color)    -- Color3, fires LIVE while dragging
    print(color)
  end
})
cp:Set(Color3.fromRGB(255, 0, 0))
-- Each colorpicker keeps its OWN value (:Get() never leaks from another).
-- Panel: SV color square + hue slider + CURRENT vs NEW preview +
-- R/G/B number boxes + labeled HEX box + Apply / Cancel.
```

### Keybind (64px, returns controller)

```lua
local kb = Tab:AddKeybind({
  Title = "Menu Keybind",
  Default = Enum.KeyCode.RightControl,
  Icon = "keyboard",            -- optional
  Position = "Left",            -- optional
  Callback = function(key)      -- KeyCode, fires when bound
    print("New Bind:", key.Name)
  end
})
kb:Set(Enum.KeyCode.F)   -- rebind from code
print(kb:Get())          -- read current key
```

Bright bordered key box (easy to see); turns accent colour while listening.
Click again while listening to cancel.

### Label / Status Label (64px, returns controller)

A read-only info card. Bigger title by default, optional description, and a
right-hand **status badge** so you can show ✅ / ❌ / ⏳ — perfect for
"is this boss spawned?" or countdowns.

```lua
local boss = Tab:AddLabel({
  Title = "Lumu Boss",           -- main text (default 14px, bigger than before)
  Description = "Checking...",   -- optional second line
  Icon = "star",                 -- optional left icon
  TextSize = 16,                 -- optional: title size (default 14)
  DescSize = 14,                 -- optional: description size (default 13)
  Status = "bad",                -- optional: "good" ✅ | "bad" ❌ | "waiting" ⏳ | "none"
  StatusText = "NOT SPAWNED",    -- optional: custom text next to the badge icon
  Position = "Left",             -- optional
  Callback = function() end,     -- optional, runs once on creation
})

-- Live updates from your loop:
boss:SetStatus("good")                    -- ✅ green  "SPAWNED"
boss:SetStatus("bad")                     -- ❌ red    "NOT SPAWNED"
boss:SetStatus("waiting", "SPAWNING...")  -- ⏳ yellow, custom text
boss:SetStatus("none")                    -- hide the badge

boss:SetText("Lumu Boss (Lv. 3000)")      -- change title (SetTitle is an alias)
boss:SetDescription("Respawns in 12 min") -- change / create the description
boss:SetIcon("chest")                     -- swap icon (card needs an icon at creation)

boss:SetCountdown(300)                    -- counts DOWN: 05:00 -> 00:00
boss:SetCountdown(0, "up")                -- counts UP:   00:00 -> ...
boss:SetCountdown(300, "down")            -- explicit down
boss:SetCountdown(300, function()         -- down + callback at zero
  boss:SetStatus("good")
end)
boss:SetCountdown(0, "up", function() end)-- up (callback only fires for down)
boss:StopCountdown()                      -- cancel any running countdown

-- Control the wording + where the timer shows (options table):
boss:SetCountdown(300, { Prefix = "Respawns in " })            -- "Respawns in 05:00"
boss:SetCountdown(300, { Suffix = " left" })                   -- "05:00 left"
boss:SetCountdown(300, { Where = "badge", Suffix = " left" })  -- timer in the badge; flips to SPAWNED at 0
boss:SetCountdown(300, { Mode = "down", Prefix = "in ", OnDone = function() end })
```

**Default badge text:** `good` → `SPAWNED`, `bad` → `NOT SPAWNED`,
`waiting` → `WAITING`. Override with `StatusText =` or the 2nd arg of `SetStatus`.

**Typical spawn-checker pattern:**

```lua
local label = Tab:AddLabel({ Title = "Kraken", Icon = "eye", Status = "waiting" })

task.spawn(function()
  while true do
    if workspace:FindFirstChild("Kraken") then
      label:SetStatus("good", "SPAWNED")
      label:SetDescription("Kill it now!")
    else
      label:SetStatus("bad", "NOT SPAWNED")
      label:SetCountdown(300)
    end
    task.wait(1)
  end
end)
```

### Paragraph (auto height, returns controller)

```lua
local p = Tab:AddParagraph({
  Title = "News",
  Description = "Long text wraps, card grows.",
  Image = "rbxassetid://...",   -- big banner image, optional
  Icon = "star",                -- 24px icon next to the title, optional
})
p:SetTitle("v2")
p:SetDescription("Updated.")
```

### MultiButton — several buttons, **each with its own action**

A card with a title and a grid of buttons. **Every button has its own
`Callback`, so each one does a different thing.** Example — 4 buttons that
Kill / Respawn / Rejoin / ServerHop:

```lua
Tab:AddMultiButton({
  Title = "Player Actions",
  Description = "Each button does something different.",
  Icon = "star",
  Columns = 2,                        -- buttons per row (default 2)
  Position = "Left",                  -- optional, like other elements
  Buttons = {
    { Title = "Kill",      Icon = "Sharingan1", Color = "red",    Callback = function() print("kill")      end },
    { Title = "Respawn",   Icon = "Heart",      Color = "green",  Callback = function() print("respawn")   end },
    { Title = "Rejoin",    Icon = "redo",       Color = "blue",   Callback = function() print("rejoin")    end },
    { Title = "ServerHop", Icon = "steering",   Color = "purple", Callback = function() print("serverhop") end },
  },
})
```

Each button can be **text only**, **icon only**, or **icon + text**:

```lua
Tab:AddMultiButton({
  Title = "Quick Teleports",
  Columns = 2,
  ButtonColor = "green",              -- default color for all buttons
  Buttons = {
    {Title = "sea 1", Callback = function() end},                -- text only
    {Title = "sea 2", Icon = "star", Callback = function() end}, -- icon + text
    {Icon = "chest", Callback = function() end},                 -- icon only
    {Title = "sea 3", Color = "red", Callback = function() end}, -- custom color
  },
})
```

**Colors:** each button takes `Color =` (a `Color3` or a name: `red, green, blue,
cyan, purple, pink, orange, gold, white, dark`). No `Color` = follows the accent
color, so themes recolor it.

**Icon-only mode:** if *every* button has no `Title`, they render as big square
icon tiles (44–72px, centered) instead of bars — great for teleport/shortcut pads.

### Discord Invite Card (260px)

```lua
Tab:AddDiscordCard({
  Position = "Left",   -- optional, like other elements
  ServerData = {
    ServerName = "Lumu Hub",            -- card title
    Description = "Official Lumu Hub Community",
    EstablishedDate = "Est. Jun 2025",  -- small gray line
    InviteCode = "RhQa6kZu9A",          -- the part after discord.gg/
    ServerIconId = "rbxassetid://...",  -- round server logo
    BackgroundBannerId = "rbxassetid://...", -- top banner image
    GameLabel = "ROBLOX",               -- game tag row
    OnlineCount = 46,                   -- "46 Online"
    MemberCount = 593,                  -- "593 Members"
  }
})
-- Minimal: Tab:AddDiscordCard({ ServerData = { InviteCode = "RhQa6kZu9A" } })
-- LIVE COUNTS: OnlineCount / MemberCount are fallback-only. The card fetches
-- real online + member numbers from Discord's public invite API using just
-- InviteCode (no bot token). Server name + icon also auto-fill from the
-- invite unless you set ServerName / ServerIconId yourself. If the request
-- fails (offline), the fallback numbers stay.
```

## 4b. Game Status — small draggable overlay (BETA)

A small panel **outside** the main window that shows live game info (server
uptime, next boss spawn, next full moon, boss island, ...). Drag it anywhere by
its header. Each row is a `Name` + a `Value` you update from code.

```lua
local Status = Window:AddGameStatus({
  Title = "Game Status",          -- header text
  Icon = "timer",                 -- optional header icon
  Width = 232,                    -- optional panel width in px
  Position = UDim2.new(0, 20, 0, 130), -- optional start position
  Enabled = true,                 -- start shown (default true)
  Beta = true,                    -- shows the BETA pill (default true)
  Width = 268,                    -- optional panel width (default 268)
  RowHeight = 28,                 -- optional row height (default 28)
  Rows = {                        -- optional starting rows
    { Name = "Script",  Value = "Lumu Hub v1.0", Icon = "star",  Color = "gold"  },
    { Name = "Players", Value = "12 / 12",       Icon = "Heart", Color = "green" },
  },
})
```

```lua
-- Set / create a row (creates it if it doesn't exist)
Status:Set("Boss Island", "X: 1234, Z: -567")
Status:SetValue("Players", "11 / 12")     -- alias of Set

-- Rows can have their own icon + colour:
Status:SetRow("Next Boss", { Value = "5m", Icon = "timer", Color = "orange" })
Status:Set("Next Boss", { Value = "2m", Icon = "timer", Color = "red" })  -- table works with Set too
Status:SetColor("Next Boss", "gold")      -- named colour or Color3
Status:SetIcon("Next Boss", "chest")
Status:SetIcon("Next Boss", nil)          -- remove the icon

-- SetRows also accepts the short form:
Status:SetRows({
  { Name = "A", Value = "1", Icon = "star", Color = "gold" },
  { "B", "2" },                           -- plain {name, value}
})

-- Colours: red green blue cyan purple pink orange gold white gray  (or a Color3)
-- No colour = follows Window:SetAccent().

Status:Get("Boss Island")                 -- read a value
Status:Remove("Boss Island")              -- delete one row
Status:SetRows({ {Name="A", Value="1"} }) -- replace every row
Status:Clear()                            -- remove every row

-- Live row timers (nice text: 56h 3m / 5m 0s / 42s)
Status:Countdown("Next Boss Spawn", 5 * 60)          -- counts DOWN to 0
Status:Countdown("Server Uptime", 56 * 3600, "up")   -- counts UP forever
Status:Countdown("Full Moon", 23 * 60, function()    -- callback at zero
  Window:Notify({ Type = "good", Title = "Full Moon!", Message = "It's up." })
end)
Status:StopCountdown("Server Uptime")                -- cancel a row timer
```

```lua
Status:Show()          Status:Hide()      Status:Toggle()
Status:SetEnabled(true)
Status:IsEnabled()     -- boolean
Status:SetTitle("Live Status")
Status:SetTitleIcon("star")
Status:Destroy()                  -- remove the panel entirely
Status:SetPosition(UDim2.new(0, 20, 0, 200))
Status:Destroy()
```

Look:
- Header icon + the BETA pill follow the accent colour (`Window:SetAccent()`).
- The panel has a soft vertical gradient and rows get a rounded hover highlight.
- The header has fully rounded corners; the `-` button (top-right) shrinks the
  panel to a header-only pill, `+` expands it back. The panel auto-sizes to its
  rows (max 220px mobile / 300px PC) and extra rows scroll inside.

Notes:
- The panel lives on its own, so it stays visible when the main window is
  hidden with the logo button. There is **no close button** — show/hide it from
  code only: `:SetEnabled(false)`, `:Hide()`, `:Toggle()`, or a toggle in your UI.
- Row values follow the accent colour unless the row sets its own `Color`.
- `:Set` on a row that is counting down stops that row's timer.
- `:SetRow` / `:Remove` / `:Clear` re-size the panel automatically (unless minimized).

## 5. Languages

Tab names, element titles **and descriptions** translate live. Selector chrome
(`Select...`, `None`, `Search...`, `(+N more)`, dropdown title) translates too —
option values stay as written on purpose (they're data passed to callbacks).

```lua
Astral:AddTranslations("Italiano", {
  ["Settings"] = "Impostazioni",
  ["Shop"] = "Negozio",
})
Astral:SetLanguage("Italiano")   -- English | Español | Français | Deutsch | yours
```

Ships with English, Español, Français, Deutsch starter packs.

### Auto-translate (Google, no API key)

```lua
tab:AddAutoTranslations({
  Title = "Language",      -- optional (default "Language")
  Icon = "Badge Gear",     -- optional
  Description = "...",     -- optional
  -- Search = true,        -- on by default (109 languages)
  -- Default = "English",  -- optional
  -- Flag = "lang",        -- optional, like AddSelector
  -- Callback = function(lang) print("picked", lang) end,  -- optional
})
-- Returns the inner AddSelector controller (Set/Get/SetOptions all work).
```

A normal selector pre-filled with every Google Translate language. Picking one
machine-translates every registered UI string and applies it live (source
language auto-detected, so Chinese-key hubs work too). Manual
`AddTranslations()` packs are separate and untouched — auto-fill only adds keys
missing from that language, so hand-written entries always win. Picking
`English` resets instantly.

`Astral.GoogleLanguages` holds the `{Name, Code}` list — read it if you want
your own picker UI.

Troubleshooting:
- Picked a language and nothing changed? You loaded a cached lib from before
  `AddAutoTranslations` existed — re-execute the script for a fresh copy.
- Red `Translate failed` notice = Google blocked the request (offline or rate
  limit). Wait a bit and try again; your current language is untouched.

## 6. Themes & Background

```lua
-- 10 built-in themes (Dark is the default build)
Window:SetTheme("Dark")
Window:SetTheme("Midnight")   -- navy
Window:SetTheme("Purple")     -- dark purple
Window:SetTheme("Crimson")    -- dark red
Window:SetTheme("Forest")     -- dark green
Window:SetTheme("Ocean")      -- dark teal
Window:SetTheme("Sunset")     -- dark orange
Window:SetTheme("Rose")       -- dark pink
Window:SetTheme("Slate")      -- blue-grey
Window:SetTheme("Coffee")     -- dark brown
print(Window:GetTheme())

-- Custom theme: pick your own colours (use colour pickers)
Window:SetCustomTheme({
  Background = Color3.fromRGB(20, 20, 26),
  Card = Color3.fromRGB(30, 30, 38),
  Text = Color3.fromRGB(255, 255, 255),
  SubText = Color3.fromRGB(170, 170, 180),
  Border = Color3.fromRGB(60, 60, 72),
  Accent = Color3.fromRGB(0, 153, 235),
})

Window:SetAccent(Color3.fromRGB(0, 153, 235))  -- recolors toggles, sliders, active tab + logo ring

-- The background image is OFF by default. Nothing shows until you call one of these.
Window:SetBackground("rbxassetid://123456")        -- asset id
Window:SetBackground("https://example.com/a.png")  -- direct image URL (downloaded + cached)
Window:LoadBackgroundFromUrl("https://...png")     -- alias of SetBackground (kept for old scripts)
Window:SetBackgroundDim(0.35)                      -- 0 = image fully visible, 1 = fully hidden
Window:ResetBackground()                           -- remove the image (plain dark again)

-- or set it at build time:
local Window = Astral:CreateWindow({
  BackgroundImage = "rbxassetid://123456",  -- optional
  BackgroundDim   = 0.35,                   -- optional, default 0.35
})
```

## 7. Notifications

```lua
Window:Notify({ Type = "good", Title = "Done", Message = "It works.", Duration = 6 })
-- Type: "good" (green) | "warning" (amber) | "bad" (red).
-- Black card, coloured icon + border + progress, seconds in a pill (top-right).
-- Slides in from the right, fully off-screen on dismiss. 258px PC / 160px mobile.

Window:Notify({
  Type = "warning", Title = "Reset?", Message = "Restore defaults?",
  Duration = 10,
  Actions = {
    {Text = "Yes", Type = "good", Callback = function() print("yes") end},
    {Text = "No",  Type = "bad",  Callback = function() print("no")  end},
  }
})
-- Action buttons take their own Type colour: Yes = green, No = red.
```

## 8. Utilities

```lua
Window:DebugInfo()   -- prints tab + element counts (paste output when reporting bugs)
Astral.Registry      -- all toggle/tick controllers (call :Set(false) to reset all)
```

## 9. Icons

```lua
Astral:RegisterIcons(Icons)
```

Then use names, raw `"rbxassetid://..."`, or digits in any `Icon` field.
Sprite entries apply their rects automatically. 6 built-ins always work even
without the module: `Checkmark, Close, Warning, search, down_arrow, right_arrow`.
Add your own: `Astral.Icons.myIcon = "rbxassetid://YOUR_ID"`.

## 10. Debugging

### First thing to run when something looks wrong

```lua
Window:DebugInfo()
-- prints: theme, tab count, element count, UI name, position, executor
```

Paste that output when reporting a bug.

### Check the console

Every error is printed to the executor console. On mobile use your executor's
console tab. Common things you will see:

| Message | Meaning |
|---|---|
| `[Astral] AddX failed: ...` | one element failed to build; the rest of the UI still loads |
| `attempt to index nil` | you called a method on a controller that returned `nil` (the element failed to build) |
| `reload failed: ...` | design switch could not re-fetch the other library |

### Isolate a broken element

One bad element never kills the build — it is skipped and warned. Add elements
one at a time and watch the console to find the culprit. Wrap your own callbacks
so their errors do not look like UI errors:

```lua
Tab:AddButton({ Title = "Risky", Callback = function()
  local ok, err = pcall(function() ... end)
  if not ok then warn("my callback: " .. tostring(err)) end
end})
```

### Check icons

```lua
print(Astral.Icons.Money)   -- should be an rbxassetid:// or an asset URL
```
Blank icon = the name is not in `icons_sprites.lua`. Use
`Astral:RegisterIcons(Icons)` **before** building the window.

### Check saved files

```lua
print(isfile("lumu_config.json"), readfile("lumu_config.json"))
print(isfile("lumu_ui_pos.json"), readfile("lumu_ui_pos.json"))
print(isfile("lumu_design.json"), readfile("lumu_design.json"))
```

Delete a file to reset that feature:
`delfile("lumu_ui_pos.json")` (window position), `delfile("lumu_design.json")` (design),
`delfile("lumu_config.json")` (saved flags).

### Reset the window position

```lua
Window:ResetUIPositions()   -- back to default main / logo / status positions
```

### Common fixes

- **Custom theme "does nothing"** — fixed: `SetCustomTheme` now accepts `Color3`
  values directly. Make sure every key is a `Color3` (Background, Card, Text,
  SubText, Border, Accent).
- **Background "comes back" by itself** — it does not any more; nothing is
  applied unless you call `SetBackground`. Call `ResetBackground()` to clear.
- **Design switch does nothing** — define `getgenv().LumuHubReload` in your
  loader (see 1c), or make sure `LumuLoader.lua` is reachable.
- **UI behind the game's own UI** — the lib parents to `gethui()` (CoreGui area)
  automatically when the executor supports it.
