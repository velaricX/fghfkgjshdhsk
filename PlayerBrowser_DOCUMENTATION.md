# Lumu PlayerBrowser + GameStatus (`NewUiBeta`)

Standalone copies: `SidebarPlayerBrowser.lua`, `TopbarPlayerBrowser.lua`
(+ `icons_sprites.lua`, call `:RegisterIcons(icons)`). Beta-only — test here
before anything merges to `main`.

## Sections (two flavors)

```lua
Tab:AddSection({ Title = "Farming", Icon = "Home" })          -- gradient bars + centered title
Tab:AddContentSection({ Title = "Farming & Combat" })         -- classic left title + underline
```

Both return `:SetTitle(t)` (`:SetText` alias); `AddSection` also has `:SetIcon`.

## Floating STOP button

```lua
local stop = Window:AddStopButton({
  Text = "STOP",
  ToggleList = { myToggle }, -- turned off via :Set(false) on press
  Callback = function() print("stopped") end,
})
stop:SetText("HOLD") -- stop:Destroy() removes it
```

Circular, draggable, accent ring, press bounce. ToggleList entries need
a `:Set` method (all Lumu toggles/ticks have it).

## Skill selector (dropdown + per-skill numbers)

```lua
local sk = Tab:AddSkillSelector({
  Title = "Skill",
  Skills = {
    { Key = "Z", Hold = 0.5, Cooldown = 3 },
    { Key = "X", Hold = 0.5, Cooldown = 5 },
  },
  Callback = function(key, hold)
    print("fire", key, "hold", hold)
  end,
})
sk:GetSelected()       -- "X"
sk:SetSelected("Z")
sk:GetSkills()         -- { Z = { Hold = 0.5, Cooldown = 3 }, ... }
sk:SetHold("Z", 1)     -- sk:SetCooldown("Z", 4)
sk:Trigger("X")        -- fire from code (mobile buttons)
```

- Pick the skill in the slide-in dropdown, type its Cooldown/Hold in
  the small boxes. Press the key (or tap via `:Trigger`) to fire.
- Firing starts that skill's cooldown; early presses are ignored.

## Player browser

```lua
local pb = Tab:AddPlayerBrowser({
    Title = "Players",      -- header title
    Mode = "Grid",          -- "Grid" or "Row"
    Search = true,          -- search box on/off
    Multi = false,          -- true = tick several players, false = pick 1
    Callback = function(plr) print(plr.DisplayName, "@" .. plr.Name) end,
    -- Optional per-player tag (level, role, team...). Return nil to hide it.
    Extra = function(plr)
      local ls = plr:FindFirstChild("leaderstats")
      local lv = ls and (ls:FindFirstChild("Level") or ls:FindFirstChild("Lvl"))
      if lv then return "LV " .. tostring(lv.Value) end
      return nil
    end,
})
pb:SetMode("Row") -- switch Grid <-> Row live
pb:Refresh()      -- rebuild list (players joined/left)
pb:GetSelected()  -- single mode: Player or nil | multi mode: {Player, ...}
pb:ClearSelected() -- untick everything
```

- Transparent rows: small pfp + ring, green online dot, Display + @username.
- Click a player to select it (accent outline + tint). `Callback` fires.
- Header: live search, Grid/Row toggle, `N / MaxPlayers` count pill.
- Avatars cached; list auto-refreshes on join/leave if you wire
  `PlayerAdded`/`PlayerRemoving` to `pb:Refresh()`.

## Single-player picker (teleport pattern)

```lua
local sel = Tab:AddSelector({
    Title = "Teleport to player", Search = true,
    Options = { "Name (@user)", ... },
})
sel:Get()               -- picked string or nil
sel:SetOptions(newList) -- refresh when players join/leave
```

## Game Status overlay

```lua
local S = Window:AddGameStatus({
    Title = "Game Status",
    Width = 300,      -- default 240 PC / 150 mobile
    RowHeight = 32,   -- default 30 / 24
    MaxHeight = 360,  -- scrolls past this (default 300 / 220)
    Rows = {
        { "Server Uptime", "56h 12m" },
        { "Next Boss", { Value = "5m 00s", Icon = "timer", Color = "gold" } },
    },
})
S:Set("Kills", 12)
S:SetRow("Boss", { Value = "alive", Color = "green", Icon = "timer" })
S:Countdown("Full Moon", 1380) -- down; ("Uptime", s, "up") counts up
S:SetColor("Boss", "red")  S:SetIcon("Boss", "timer")
S:Get("Kills")  S:Remove("Kills")  S:Clear()
S:SetTitle("Status")  S:SetPosition(UDim2.new(0, 100, 0, 100))
S:Show()  S:Hide()  S:Toggle()  S:StopCountdown("Full Moon")
```

- Rows **auto-grow**: long names/values wrap, never cut to `...`
  (re-measures on every text change, incl. countdowns + translations).
- Draggable by header, `-`/`+` minimize button, live countdown pills.

Full runnable test: `LumuExample_Players.lua` (tester scripts folder).

## Themes

```lua
Window:SetTheme("Midnight") -- Dark, Midnight, Purple, Crimson, Forest,
                            -- Ocean, Sunset, Rose, Slate, Coffee
Window:GetTheme() -- current name (each theme also sets a matching accent)
Window:SetCustomTheme({
  Background = Color3.fromRGB(10, 10, 14),
  Card = Color3.fromRGB(20, 22, 34),
  Text = Color3.fromRGB(255, 255, 255),
  SubText = Color3.fromRGB(170, 170, 180),
  Border = Color3.fromRGB(60, 60, 72),
  Accent = Color3.fromRGB(0, 153, 235),
})
```

- Recolors the whole UI live: cards, text, borders, gradients, scrollbars.
- Your accent color is never touched by themes.
- Every element built afterwards also follows the active theme.

## Built-in Settings (top-right gear, summons panel)

Every window gets a gear button top-right (disable with
`CreateWindow({ SettingsTab = false })`). Clicking it opens a hidden
Settings tab (no sidebar entry) with sub-tabs: **About** (version,
reset positions, refresh), **Themes** (all presets + accent picker +
custom theme), **Background** (images, dim, reset), **Status**
(show/hide + reset positions + panel size), **Display** (UI size,
grid 1/2/Auto columns, transparency, replay intro), **Configs**
(save/load named json configs + file picker).

Extra window APIs used by it (all callable yourself too):
`Window:SetUIScale(0.7-1.3)`, `Window:SetLayoutMode("Auto"/"OneColumn"/"TwoColumn")`,
`Window:SetStatusScale(0.7-1.3)`, `Window:PlayIntro()`,
`Window:SaveConfig(name)`, `Window:LoadConfig(name)`,
`Window:SaveUIPositions()/ResetUIPositions()`,
`AddDiscordCard({ FullWidth = true, ... })` for full-width cards.
