-- ============================================================================
--  LumuHub Notify  --  shared notification UI
--  Any script can send notifications to the same stack.
--
--  local Notify = loadstring(game:HttpGet(".../LumuHubNotify.lua"))()
--  Notify:Send({ Type = "good", Title = "Done", Message = "It works.", Duration = 5 })
--  Notify:Success("Done", "It works.")
--  Notify:Error("Failed", "Something broke.")
--  Notify:Warning("Careful", "Low health")
--  Notify:Info("Note", "Auto farm started")
--
--  Other scripts can reuse it without loading again:
--      getgenv().LumuNotify:Success("Hi", "from another script")
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ACCENT = Color3.fromRGB(0, 153, 235)
local CARD = Color3.fromRGB(26, 26, 30)
local TEXT = Color3.fromRGB(255, 255, 255)
local TEXT_DIM = Color3.fromRGB(160, 160, 168)

local GOOD = Color3.fromRGB(46, 204, 113)
local BAD = Color3.fromRGB(231, 76, 60)
local WARN = Color3.fromRGB(245, 158, 11)
local INFO = ACCENT

local PALETTE = { good = GOOD, bad = BAD, warning = WARN, info = INFO, success = GOOD, error = BAD }

-- ---------------------------------------------------------------------------
-- singleton: reuse an existing stack if one is already running
-- ---------------------------------------------------------------------------
local existing = nil
pcall(function()
	if getgenv then
		local g = getgenv()
		if type(g) == "table" and type(g.LumuNotify) == "table" and type(g.LumuNotify.Send) == "function" then
			existing = g.LumuNotify
		end
	end
end)
if existing then return existing end

local Notify = {}
Notify.Accent = ACCENT
Notify.MaxVisible = 6
Notify.Width = 300

local function round(box, scale)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(scale or 1, 0)
	c.Parent = box
	return c
end

local function newBox(parent, color)
	local b = Instance.new("Frame")
	b.BackgroundColor3 = color
	b.BorderSizePixel = 0
	b.ZIndex = (parent.ZIndex or 1) + 1
	b.Parent = parent
	return b
end

local function makeBar(parent, widthScale, thicknessScale, rot, color, x, y)
	local bar = newBox(parent, color)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(x, y)
	bar.Size = UDim2.new(widthScale, 0, thicknessScale, 0)
	bar.Rotation = rot
	round(bar, 1)
	return bar
end

local function drawCheck(holder, color)
	makeBar(holder, 0.30, 0.13, 45, color, 0.34, 0.64)
	makeBar(holder, 0.54, 0.13, -45, color, 0.60, 0.55)
end

local function drawCross(holder, color)
	makeBar(holder, 0.62, 0.14, 45, color, 0.5, 0.5)
	makeBar(holder, 0.62, 0.14, -45, color, 0.5, 0.5)
end

local function drawBang(holder, color)
	local bar = newBox(holder, color)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.34)
	bar.Size = UDim2.fromScale(0.16, 0.44)
	round(bar, 1)

	local dot = newBox(holder, color)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.fromScale(0.5, 0.78)
	dot.Size = UDim2.fromScale(0.16, 0.16)
	round(dot, 1)
end

local function drawInfo(holder, color)
	local bar = newBox(holder, color)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.62)
	bar.Size = UDim2.fromScale(0.16, 0.44)
	round(bar, 1)

	local dot = newBox(holder, color)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.fromScale(0.5, 0.24)
	dot.Size = UDim2.fromScale(0.16, 0.16)
	round(dot, 1)
end

local MARKS = { good = drawCheck, bad = drawCross, warning = drawBang, info = drawInfo, success = drawCheck, error = drawCross }

-- ---------------------------------------------------------------------------
-- gui
-- ---------------------------------------------------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "LumuNotify"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.DisplayOrder = 999
ScreenGui.Parent = PlayerGui

local Stack = Instance.new("Frame")
Stack.Name = "Stack"
Stack.BackgroundTransparency = 1
Stack.AnchorPoint = Vector2.new(1, 0)
Stack.Position = UDim2.new(1, -18, 0, 18)
Stack.Size = UDim2.new(0, Notify.Width, 0, 0)
Stack.AutomaticSize = Enum.AutomaticSize.Y
Stack.ZIndex = 900
Stack.Parent = ScreenGui

local Layout = Instance.new("UIListLayout")
Layout.FillDirection = Enum.FillDirection.Vertical
Layout.SortOrder = Enum.SortOrder.LayoutOrder
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
Layout.Padding = UDim.new(0, 8)
Layout.Parent = Stack

local order = 0
local live = {}

local POSITIONS = {
	["top-right"] = { Anchor = Vector2.new(1, 0), Pos = UDim2.new(1, -18, 0, 18), Align = Enum.HorizontalAlignment.Right, Dir = -1 },
	["top-left"] = { Anchor = Vector2.new(0, 0), Pos = UDim2.new(0, 18, 0, 18), Align = Enum.HorizontalAlignment.Left, Dir = -1 },
	["bottom-right"] = { Anchor = Vector2.new(1, 1), Pos = UDim2.new(1, -18, 1, -18), Align = Enum.HorizontalAlignment.Right, Dir = 1 },
	["bottom-left"] = { Anchor = Vector2.new(0, 1), Pos = UDim2.new(0, 18, 1, -18), Align = Enum.HorizontalAlignment.Left, Dir = 1 },
	["top-center"] = { Anchor = Vector2.new(0.5, 0), Pos = UDim2.new(0.5, 0, 0, 18), Align = Enum.HorizontalAlignment.Center, Dir = -1 },
	["bottom-center"] = { Anchor = Vector2.new(0.5, 1), Pos = UDim2.new(0.5, 0, 1, -18), Align = Enum.HorizontalAlignment.Center, Dir = 1 },
}

function Notify:SetPosition(where)
	local p = POSITIONS[where]
	if not p then return Notify end
	Stack.AnchorPoint = p.Anchor
	Stack.Position = p.Pos
	Layout.HorizontalAlignment = p.Align
	Layout.VerticalAlignment = (p.Dir == 1) and Enum.VerticalAlignment.Bottom or Enum.VerticalAlignment.Top
	Notify.Side = p.Dir
	return Notify
end
Notify.Side = -1

function Notify:SetAccent(color)
	if typeof(color) == "Color3" then
		Notify.Accent = color
		PALETTE.info = color
	end
	return Notify
end

local function trim()
	while #live > Notify.MaxVisible do
		local oldest = table.remove(live, 1)
		if oldest and oldest.dismiss then pcall(oldest.dismiss) end
	end
end

function Notify:Clear()
	for _, entry in ipairs(live) do
		if entry.dismiss then pcall(entry.dismiss) end
	end
	live = {}
	return Notify
end

-- ---------------------------------------------------------------------------
-- send
-- ---------------------------------------------------------------------------
function Notify:Send(config)
	config = config or {}
	local kind = tostring(config.Type or "info"):lower()
	local color = PALETTE[kind] or config.Color or INFO
	local title = tostring(config.Title or "")
	local message = tostring(config.Message or "")
	local duration = tonumber(config.Duration) or 5
	if duration <= 0 then duration = 1 end
	local actions = config.Actions or {}

	local hasActions = type(actions) == "table" and #actions > 0
	local height = hasActions and 104 or (message ~= "" and 66 or 50)

	local function mix(base, col, amount)
		return Color3.fromRGB(
			math.floor(base.R * 255 * (1 - amount) + col.R * 255 * amount),
			math.floor(base.G * 255 * (1 - amount) + col.G * 255 * amount),
			math.floor(base.B * 255 * (1 - amount) + col.B * 255 * amount)
		)
	end

	local card = Instance.new("Frame")
	card.Name = "Toast"
	card.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	card.BorderSizePixel = 0
	card.Size = UDim2.new(0, Notify.Width, 0, height)
	card.ZIndex = 901
	card.Parent = Stack
	round(card, 0.18)

	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Transparency = 0.35
	stroke.Thickness = 1.4
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = card

	local accentBar = newBox(card, color)
	accentBar.Position = UDim2.new(0, 0, 0, 12)
	accentBar.Size = UDim2.new(0, 3, 1, -24)
	round(accentBar, 1)

	-- icon slot: real image if given, otherwise a drawn mark
	local holder = Instance.new("Frame")
	holder.Name = "Mark"
	holder.BackgroundTransparency = 1
	holder.AnchorPoint = Vector2.new(0, 0.5)
	holder.Position = UDim2.new(0, 16, 0, height / 2 - (hasActions and 14 or 0))
	holder.Size = UDim2.new(0, 28, 0, 28)
	holder.ZIndex = 902
	holder.Parent = card

	local sprite = config.Icon
	if sprite then
		local img = Instance.new("ImageLabel")
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromScale(1, 1)
		img.ScaleType = Enum.ScaleType.Fit
		img.ImageColor3 = color
		img.ZIndex = 903
		if type(sprite) == "table" then
			img.Image = sprite.Image or ""
			img.ImageRectOffset = sprite.ImageRectOffset or Vector2.new(0, 0)
			img.ImageRectSize = sprite.ImageRectSize or Vector2.new(0, 0)
		elseif type(sprite) == "number" then
			img.Image = "rbxassetid://" .. tostring(sprite)
		else
			img.Image = tostring(sprite)
		end
		img.Parent = holder
	else
		local fn = MARKS[kind] or drawInfo
		fn(holder, color)
	end

	local titleLabel = Instance.new("TextLabel")
	titleLabel.BackgroundTransparency = 1
	titleLabel.Position = UDim2.new(0, 48, 0, 13)
	titleLabel.Size = UDim2.new(1, -62, 0, 17)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = title
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = TEXT
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	titleLabel.ZIndex = 902
	titleLabel.Parent = card

	if message ~= "" then
		local msgLabel = Instance.new("TextLabel")
		msgLabel.BackgroundTransparency = 1
		msgLabel.Position = UDim2.new(0, 48, 0, 32)
		msgLabel.Size = UDim2.new(1, -62, 0, 24)
		msgLabel.Font = Enum.Font.Gotham
		msgLabel.Text = message
		msgLabel.TextSize = 11
		msgLabel.TextColor3 = TEXT_DIM
		msgLabel.TextXAlignment = Enum.TextXAlignment.Left
		msgLabel.TextYAlignment = Enum.TextYAlignment.Top
		msgLabel.TextWrapped = true
		msgLabel.TextTruncate = Enum.TextTruncate.AtEnd
		msgLabel.ZIndex = 902
		msgLabel.Parent = card
	end

	-- progress
	local track = newBox(card, Color3.fromRGB(38, 38, 44))
	track.AnchorPoint = Vector2.new(0.5, 1)
	track.Position = UDim2.new(0.5, 0, 1, -1)
	track.Size = UDim2.new(1, -16, 0, 5)
	round(track, 1)

	local fill = newBox(track, color)
	fill.Size = UDim2.new(1, 0, 1, 0)
	round(fill, 1)

	-- action buttons
	local buttons = {}
	if hasActions then
		local row = Instance.new("Frame")
		row.Name = "Actions"
		row.BackgroundTransparency = 1
		row.Position = UDim2.new(0, 48, 1, -40)
		row.Size = UDim2.new(1, -62, 0, 26)
		row.ZIndex = 902
		row.Parent = card

		local rowLayout = Instance.new("UIListLayout")
		rowLayout.FillDirection = Enum.FillDirection.Horizontal
		rowLayout.SortOrder = Enum.SortOrder.LayoutOrder
		rowLayout.Padding = UDim.new(0, 6)
		rowLayout.Parent = row

		local count = #actions
		for i, action in ipairs(actions) do
			local btn = Instance.new("TextButton")
			btn.Name = "Action" .. i
			btn.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
			btn.BorderSizePixel = 0
			btn.Size = UDim2.new(1 / count, -4, 1, 0)
			btn.Font = Enum.Font.GothamBold
			btn.Text = tostring(action.Text or "OK")
			btn.TextSize = 11
			btn.TextColor3 = TEXT
			btn.AutoButtonColor = false
			btn.LayoutOrder = i
			btn.ZIndex = 903
			btn.Parent = row
			round(btn, 0.3)
			buttons[#buttons + 1] = btn
		end
	end

	-- animate in
	local side = Notify.Side or -1
	card.Position = UDim2.new(side, 44 * -side, 0, 0)
	card.BackgroundTransparency = 1
	stroke.Transparency = 1
	TweenService:Create(card, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 0,
	}):Play()
	TweenService:Create(stroke, TweenInfo.new(0.24), { Transparency = 0.6 }):Play()

	local entry = {}
	local closed = false

	entry.dismiss = function()
		if closed then return end
		closed = true
		TweenService:Create(card, TweenInfo.new(0.2), {
			Position = UDim2.new(side, 44 * -side, 0, 0),
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.2), { Transparency = 1 }):Play()
		task.delay(0.24, function()
			pcall(function() card:Destroy() end)
			for i, e in ipairs(live) do
				if e == entry then table.remove(live, i) break end
			end
		end)
	end

	entry.card = card
	entry.buttons = buttons
	entry.color = color
	live[#live + 1] = entry
	trim()

	-- progress drain + auto dismiss
	task.spawn(function()
		TweenService:Create(fill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0),
		}):Play()
		local elapsed = 0
		while elapsed < duration do
			if closed or not card.Parent then return end
			task.wait(0.1)
			elapsed = elapsed + 0.1
		end
		entry.dismiss()
	end)

	for i, btn in ipairs(buttons) do
		local action = actions[i]
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(50, 50, 58) }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.12), { BackgroundColor3 = Color3.fromRGB(38, 38, 44) }):Play()
		end)
		btn.MouseButton1Click:Connect(function()
			if type(action) == "table" and type(action.Callback) == "function" then
				task.spawn(action.Callback)
			end
			entry.dismiss()
		end)
	end

	return entry
end

Notify.Notify = Notify.Send

function Notify:Success(title, message, duration) return Notify:Send({ Type = "good", Title = title, Message = message, Duration = duration }) end
function Notify:Error(title, message, duration)   return Notify:Send({ Type = "bad", Title = title, Message = message, Duration = duration }) end
function Notify:Warning(title, message, duration) return Notify:Send({ Type = "warning", Title = title, Message = message, Duration = duration }) end
function Notify:Info(title, message, duration)    return Notify:Send({ Type = "info", Title = title, Message = message, Duration = duration }) end

Notify.Destroy = function()
	Notify:Clear()
	pcall(function() ScreenGui:Destroy() end)
end

pcall(function()
	if getgenv then getgenv().LumuNotify = Notify end
end)

return Notify
