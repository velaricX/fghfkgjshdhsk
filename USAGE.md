# Astral UI — Usage Guide

Load the library (pure UI only, no demo content):

```lua
local Astral = loadstring(game:HttpGet("https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/Script.lua"))()
```

## 1. Window → Section → Page → Tab

```lua
local Window = Astral:CreateWindow({
  Title = "My Hub",
  SubTitle = "by velaricX",      -- optional
  badge = "FREE",                -- small badge text
  badgecolor = Color3.fromRGB(0, 153, 235),
  Size = UDim2.fromOffset(750, 500),
})

-- Top-right nav pills. Format: {name, icon}
local Main = Window:MakeSection({"Main", "Home"})
local Settings = Window:MakeSection({"Settings", "settings"})

-- Cards inside a section
local Farm = Main:MakePage({
  Name = "Auto Farm",
  Description = "Farming features.",
  Icon = "shopping",             -- icon name, asset id, or digits
})

-- Tabs inside a page
local Tab = Farm:MakeTab({
  Name = "General",
  Icon = "timer",
  Description = "Main toggles.",
})
```

## 2. Elements (all go on the Tab)

```lua
-- BUTTON (click runs callback)
Tab:AddButton({
  Title = "Kill All", Description = "Kills everything.",
  Icon = "click_icon", Position = "Left",   -- "Left" / "Right" / nil = auto
  Callback = function() print("clicked") end
})

-- TOGGLE (on/off switch, returns controller)
local t = Tab:AddToggle({
  Title = "Auto Farm", Description = "...",
  Default = false, Icon = "timer",
  Callback = function(state) print(state) end
})
t:Set(true)   -- force on/off from code

-- TICK (checkbox, same pattern)
local c = Tab:AddTick({
  Title = "Loot", Default = true,
  Callback = function(s) end
})
c:Set(false)

-- SLIDER (returns controller)
local s = Tab:AddSlider({
  Title = "Range", Min = 1, Max = 100,
  Increase = 1, Default = 50,
  Callback = function(val) print(val) end
})
s:Set(80)

-- TEXTBOX (fires on focus lost / enter)
Tab:AddTextbox({
  Title = "Tag", Placeholder = "Type...",
  Default = "", ClearOnFocus = false,
  Callback = function(text) print(text) end
})

-- SELECTOR (dropdown side-panel, returns controller)
local sel = Tab:AddSelector({
  Title = "Theme", Options = {"Cyan", "Ruby", "Gold"},
  Default = "Cyan", Search = true, Multi = false,
  Callback = function(pick) print(pick) end  -- table if Multi = true
})
sel:SetOptions({"A", "B", "C"}, "A")   -- refresh list live

-- COLOR PICKER (side-panel picker)
Tab:AddColorPicker({
  Title = "Accent", Default = Color3.fromRGB(0, 255, 0),
  Callback = function(color) print(color) end
})

-- KEYBIND (click box, press a key to bind; pressing it later fires callback)
Tab:AddKeybind({
  Title = "Toggle UI", Default = Enum.KeyCode.RightControl,
  Callback = function(key) print(key.Name) end
})

-- LABEL / PARAGRAPH (info only; Label with Callback acts as a button)
Tab:AddLabel({ Title = "Status", Description = "Online", Icon = "timer" })
Tab:AddParagraph({ Title = "News", Description = "...", Image = "rbxassetid://..." })
```

## 3. Extras

```lua
-- Simple notification (no X button, auto-dismiss, gray progress bar)
Window:Notify({
  Type = "good",                 -- "good" / "warning" / "bad"
  Title = "Done", Message = "Farm started.", Duration = 6
})

-- Notification with action buttons
Window:Notify({
  Type = "warning", Title = "Sure?",
  Message = "...", Duration = 8,
  Actions = {
    { Text = "Yes", Type = "bad", Callback = function() end },
    { Text = "No",  Type = "good", Callback = function() end },
  }
})

Astral:SetLayoutMode("OneColumn")   -- or "TwoColumn"
Astral:SetLanguage("Spanish (Español)")
Window:Destroy()
```

## Icons

Any key from `Astral.Icons` (`Home, Settings, Heart, shopping, palette,
keyboard, timer, clock, profile, click_icon, star, quest, ...`),
a plain `"rbxassetid://..."`, or just digits like `"10747384361"`.

## Pattern

**Load lib → CreateWindow → MakeSection → MakePage → MakeTab → Add\***
