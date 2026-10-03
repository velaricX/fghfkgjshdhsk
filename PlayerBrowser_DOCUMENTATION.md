# Lumu PlayerBrowser + GameStatus (`NewUiBeta`)

Standalone copies: `SidebarPlayerBrowser.lua`, `TopbarPlayerBrowser.lua`
(+ `icons_sprites.lua`, call `:RegisterIcons(icons)`). Beta-only — test here
before anything merges to `main`.

## Player browser

```lua
local pb = Tab:AddPlayerBrowser({
    Title = "Players",      -- header title
    Mode = "Grid",          -- "Grid" or "Row"
    Search = true,          -- search box on/off
    Multi = false,          -- true = tick several players, false = pick 1
    Callback = function(plr) print(plr.DisplayName, "@" .. plr.Name) end,
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
Window:GetTheme() -- current name
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
