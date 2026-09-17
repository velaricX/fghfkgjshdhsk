-- ============================================================================
--  LumuHub Key System UI
--  Standalone. Matches the Lumu UI design language. NOT draggable.
--
--  local KeyUI = loadstring(game:HttpGet(".../LumuHubKeySystem.lua"))()
--  local Icons = loadstring(game:HttpGet(".../icons_sprites.lua"))()
--  KeyUI:RegisterIcons(Icons)
--
--  local Loading = KeyUI:CreateLoading({ Title = "LumuHub" })
--
--  local Keys = KeyUI:Create({
--      Title = "LumuHub",
--      SubTitle = "Key System",
--      Discord = "https://discord.gg/xxxx",
--      YouTube = "https://youtube.com/@xxxx",
--      GetKeyUrl = "https://...",
--      HowToKeyUrl = "https://...",
--      CheckKey = function(key) return key == "LUMU-TEST" end,
--      OnSuccess = function(key) end,
--      OnFail = function(key) end,
--  })
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ACCENT = Color3.fromRGB(0, 153, 235)
local CARD = Color3.fromRGB(26, 26, 30)
local CARD_HOVER = Color3.fromRGB(38, 38, 44)
local BG = Color3.fromRGB(12, 12, 14)
local BORDER = Color3.fromRGB(50, 50, 55)
local INPUT_BG = Color3.fromRGB(20, 20, 24)
local TEXT = Color3.fromRGB(255, 255, 255)
local TEXT_DIM = Color3.fromRGB(160, 160, 168)

local GOOD = Color3.fromRGB(46, 204, 113)
local BAD = Color3.fromRGB(231, 76, 60)
local WARN = Color3.fromRGB(241, 196, 15)

local DISCORD_COLOR = Color3.fromRGB(88, 101, 242)
local YOUTUBE_COLOR = Color3.fromRGB(255, 0, 0)

local KeySystem = {}
KeySystem.Icons = {}
KeySystem.Accent = ACCENT

function KeySystem:RegisterIcons(dict)
	if type(dict) ~= "table" then return end
	for k, v in pairs(dict) do KeySystem.Icons[k] = v end
end

function KeySystem:SetAccent(color)
	if typeof(color) == "Color3" then KeySystem.Accent = color end
end

-- ============================================================================
-- icon helpers
-- ============================================================================
local function parseIcon(iconInput)
	if not iconInput then return nil end
	if type(iconInput) == "table" then return iconInput end
	if type(iconInput) == "string" then
		if KeySystem.Icons[iconInput] then return KeySystem.Icons[iconInput] end
		if string.match(iconInput, "^%d+$") then return "rbxassetid://" .. iconInput end
		if string.sub(iconInput, 1, 13) == "rbxassetid://" or string.sub(iconInput, 1, 4) == "http" then return iconInput end
	elseif type(iconInput) == "number" then
		return "rbxassetid://" .. tostring(iconInput)
	end
	return nil
end

local function applyIcon(label, icon)
	if type(icon) == "table" then
		label.Image = icon.Image or ""
		label.ImageRectOffset = icon.ImageRectOffset or Vector2.new(0, 0)
		label.ImageRectSize = icon.ImageRectSize or Vector2.new(0, 0)
	else
		label.Image = icon or ""
		label.ImageRectOffset = Vector2.new(0, 0)
		label.ImageRectSize = Vector2.new(0, 0)
	end
end

local function newBox(parent, color)
	local box = Instance.new("Frame")
	box.BackgroundColor3 = color
	box.BorderSizePixel = 0
	box.ZIndex = (parent.ZIndex or 1) + 3
	box.Parent = parent
	return box
end

local function round(box, radiusScale)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(radiusScale or 1, 0)
	c.Parent = box
	return c
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

-- Drawn fallbacks so the UI never depends on a missing asset id.
local Draw = {}

function Draw.check(container, color)
	makeBar(container, 0.30, 0.13, 45, color, 0.34, 0.64)
	makeBar(container, 0.54, 0.13, -45, color, 0.60, 0.55)
end

function Draw.cross(container, color)
	makeBar(container, 0.62, 0.14, 45, color, 0.5, 0.5)
	makeBar(container, 0.62, 0.14, -45, color, 0.5, 0.5)
end

function Draw.bang(container, color)
	local bar = newBox(container, color)
	bar.AnchorPoint = Vector2.new(0.5, 0.5)
	bar.Position = UDim2.fromScale(0.5, 0.34)
	bar.Size = UDim2.fromScale(0.17, 0.44)
	round(bar, 1)

	local dot = newBox(container, color)
	dot.AnchorPoint = Vector2.new(0.5, 0.5)
	dot.Position = UDim2.fromScale(0.5, 0.80)
	dot.Size = UDim2.fromScale(0.17, 0.17)
	round(dot, 1)
end

function Draw.clipboard(container, color)
	local body = newBox(container, color)
	body.BackgroundTransparency = 1
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.Position = UDim2.fromScale(0.5, 0.56)
	body.Size = UDim2.fromScale(0.56, 0.66)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 1.7
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = body
	round(body, 0.16)

	local tab = newBox(container, color)
	tab.AnchorPoint = Vector2.new(0.5, 0.5)
	tab.Position = UDim2.fromScale(0.5, 0.18)
	tab.Size = UDim2.fromScale(0.30, 0.14)
	round(tab, 1)

	local l1 = newBox(container, color)
	l1.AnchorPoint = Vector2.new(0.5, 0.5)
	l1.Position = UDim2.fromScale(0.5, 0.50)
	l1.Size = UDim2.fromScale(0.30, 0.08)
	round(l1, 1)

	local l2 = newBox(container, color)
	l2.AnchorPoint = Vector2.new(0.5, 0.5)
	l2.Position = UDim2.fromScale(0.5, 0.68)
	l2.Size = UDim2.fromScale(0.22, 0.08)
	round(l2, 1)
end

function Draw.play(container, color)
	local clip = newBox(container, color)
	clip.BackgroundTransparency = 1
	clip.AnchorPoint = Vector2.new(0.5, 0.5)
	clip.Position = UDim2.fromScale(0.5, 0.5)
	clip.Size = UDim2.fromScale(0.46, 0.46)
	clip.ClipsDescendants = true

	local tri = newBox(clip, color)
	tri.AnchorPoint = Vector2.new(0.5, 0.5)
	tri.Position = UDim2.fromScale(0.0, 0.5)
	tri.Size = UDim2.fromScale(1, 1)
	tri.Rotation = 45
end

function Draw.discord(container)
	local body = newBox(container, Color3.fromRGB(255, 255, 255))
	body.AnchorPoint = Vector2.new(0.5, 0.5)
	body.Position = UDim2.fromScale(0.5, 0.54)
	body.Size = UDim2.fromScale(0.82, 0.56)
	round(body, 1)

	local eye1 = newBox(container, DISCORD_COLOR)
	eye1.AnchorPoint = Vector2.new(0.5, 0.5)
	eye1.Position = UDim2.fromScale(0.36, 0.54)
	eye1.Size = UDim2.fromScale(0.15, 0.15)
	round(eye1, 1)

	local eye2 = newBox(container, DISCORD_COLOR)
	eye2.AnchorPoint = Vector2.new(0.5, 0.5)
	eye2.Position = UDim2.fromScale(0.64, 0.54)
	eye2.Size = UDim2.fromScale(0.15, 0.15)
	round(eye2, 1)
end

function Draw.key(container, color)
	local ring = newBox(container, color)
	ring.BackgroundTransparency = 1
	ring.AnchorPoint = Vector2.new(0.5, 0.5)
	ring.Position = UDim2.fromScale(0.32, 0.36)
	ring.Size = UDim2.fromScale(0.42, 0.42)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = ring
	round(ring, 1)

	local shaft = newBox(container, color)
	shaft.AnchorPoint = Vector2.new(0.5, 0.5)
	shaft.Position = UDim2.fromScale(0.60, 0.60)
	shaft.Size = UDim2.fromScale(0.44, 0.11)
	shaft.Rotation = 45
	round(shaft, 1)

	local tooth = newBox(container, color)
	tooth.AnchorPoint = Vector2.new(0.5, 0.5)
	tooth.Position = UDim2.fromScale(0.79, 0.78)
	tooth.Size = UDim2.fromScale(0.12, 0.22)
	tooth.Rotation = 45
	round(tooth, 1)
end

-- Renders a real image or the drawn fallback into a holder frame.
-- mode "fill"  -> image covers the whole holder (for app-icon style assets)
-- mode "fit"   -> image is centred and scaled to fit (for glyph assets)
local function renderIcon(holder, sprite, fallbackFn, color, mode)
	holder:ClearAllChildren()
	local asset = parseIcon(sprite)
	if asset then
		local img = Instance.new("ImageLabel")
		img.Name = "Sprite"
		img.BackgroundTransparency = 1
		img.Size = UDim2.fromScale(1, 1)
		img.ScaleType = (mode == "fill") and Enum.ScaleType.Stretch or Enum.ScaleType.Fit
		img.ZIndex = (holder.ZIndex or 1) + 2
		applyIcon(img, asset)
		-- never tint a real brand icon: keep its original colours
		img.ImageColor3 = (mode == "fill") and Color3.fromRGB(255, 255, 255) or (color or Color3.fromRGB(255, 255, 255))
		img.Parent = holder
		return img
	elseif fallbackFn then
		fallbackFn(holder, color or Color3.fromRGB(255, 255, 255))
	end
	return nil
end

local function newScreenGui(name)
	local gui = Instance.new("ScreenGui")
	gui.Name = name
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = PlayerGui
	return gui
end

-- ============================================================================
-- Notifications (toasts with a drawn status mark)
-- ============================================================================
-- Notification system -- copied from the main Lumu UI
-- (bottom-right stack, icon box, title + message, progress bar, action buttons)
-- ============================================================================
-- Shared notification UI (LumuHubNotify) -- loaded once, used by every file.
-- No duplicate notification code lives in here.
-- ============================================================================
-- ============================================================================
-- Notification system -- copied from the main Lumu UI (Window:Notify).
-- Same stack, same cards, same slide-in, same progress, same actions.
-- ============================================================================
local function createMainNotify(screenGui, getAccent)
	local viewportX = 1280
	pcall(function()
		local cam = workspace.CurrentCamera
		if cam then viewportX = cam.ViewportSize.X end
	end)
	local notifW = math.min(300, math.floor(viewportX * 0.3))
	if notifW < 150 then notifW = 150 end

	local Container = Instance.new("Frame")
	Container.Name = "NotificationContainer"
	Container.Size = UDim2.new(0, notifW + 20, 0, 0)
	Container.Position = UDim2.new(1, -12, 1, -12)
	Container.AnchorPoint = Vector2.new(1, 1)
	Container.BackgroundTransparency = 1
	Container.AutomaticSize = Enum.AutomaticSize.Y
	Container.ZIndex = 200
	Container.Parent = screenGui

	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	NotifLayout.Padding = UDim.new(0, 8)
	NotifLayout.Parent = Container

	local TYPE_COLORS = {
		good = Color3.fromRGB(46, 204, 113),
		warning = Color3.fromRGB(241, 196, 15),
		bad = Color3.fromRGB(231, 76, 60),
		info = nil,
	}
	local TYPE_MARKS = { good = Draw.check, warning = Draw.bang, bad = Draw.cross, info = Draw.bang }

	local function mix(base, color, amount)
		return Color3.fromRGB(
			math.floor(base.R * 255 * (1 - amount) + color.R * 255 * amount),
			math.floor(base.G * 255 * (1 - amount) + color.G * 255 * amount),
			math.floor(base.B * 255 * (1 - amount) + color.B * 255 * amount)
		)
	end

	return function(config)
		config = config or {}
		local kind = tostring(config.Type or "info"):lower()
		local accent = getAccent()
		local tc = TYPE_COLORS[kind] or accent
		local hasActions = type(config.Actions) == "table" and #config.Actions > 0
		local notifH = hasActions and 100 or 76
		local duration = tonumber(config.Duration) or 5
		if duration <= 0 then duration = 1 end

		local Frame = Instance.new("Frame")
		Frame.Size = UDim2.new(0, notifW, 0, notifH)
		Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
		Frame.BorderSizePixel = 0
		Frame.ZIndex = 200
		Frame.ClipsDescendants = true
		Frame.Parent = Container

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 10)
		Corner.Parent = Frame

		local Stroke = Instance.new("UIStroke")
		Stroke.Thickness = 1.4
		Stroke.Color = tc
		Stroke.Transparency = 0.35
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.Parent = Frame


		-- icon box
		local IconFrame = Instance.new("Frame")
		IconFrame.Size = UDim2.fromOffset(38, 38)
		IconFrame.Position = UDim2.new(0, 22, 0, hasActions and 12 or 19)
		IconFrame.BackgroundColor3 = mix(Color3.fromRGB(30, 30, 36), tc, 0.28)
		IconFrame.BorderSizePixel = 0
		IconFrame.ZIndex = 200
		IconFrame.Parent = Frame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 8)
		IconCorner.Parent = IconFrame

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.2
		IconStroke.Color = tc
		IconStroke.Transparency = 0.4
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconFrame

		local IconHolder = Instance.new("Frame")
		IconHolder.BackgroundTransparency = 1
		IconHolder.AnchorPoint = Vector2.new(0.5, 0.5)
		IconHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconHolder.Size = UDim2.fromOffset(26, 26)
		IconHolder.ZIndex = 201
		IconHolder.Parent = IconFrame
		local customIcon = config.Icon and parseIcon(config.Icon) or nil
		if customIcon then
			renderIcon(IconHolder, customIcon, nil, tc, "fit")
		else
			local markFn = TYPE_MARKS[kind] or Draw.bang
			markFn(IconHolder, tc)
		end

		-- text
		local TextFrame = Instance.new("Frame")
		TextFrame.Size = UDim2.new(1, -108, 0, hasActions and 40 or 44)
		TextFrame.Position = UDim2.new(0, 70, 0, hasActions and 10 or 12)
		TextFrame.BackgroundTransparency = 1
		TextFrame.ZIndex = 200
		TextFrame.Parent = Frame

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Size = UDim2.new(1, -6, 0, 18)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.GothamBold
		TitleLabel.Text = tostring(config.Title or "")
		TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TitleLabel.TextSize = 12
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		TitleLabel.ZIndex = 200
		TitleLabel.Parent = TextFrame

		local DescLabel = Instance.new("TextLabel")
		DescLabel.Size = UDim2.new(1, -6, 0, hasActions and 20 or 24)
		DescLabel.Position = UDim2.new(0, 0, 0, 19)
		DescLabel.BackgroundTransparency = 1
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = tostring(config.Message or "")
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 11
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextYAlignment = Enum.TextYAlignment.Top
		DescLabel.TextWrapped = true
		DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
		DescLabel.ZIndex = 200
		DescLabel.Parent = TextFrame

		-- bottom progress bar
		local ProgressTrack = Instance.new("Frame")
		ProgressTrack.Name = "ProgressTrack"
		ProgressTrack.Size = UDim2.new(1, -32, 0, 4)
		ProgressTrack.Position = UDim2.new(0, 16, 1, -8)
		ProgressTrack.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		ProgressTrack.BorderSizePixel = 0
		ProgressTrack.ZIndex = 201
		ProgressTrack.Parent = Frame
		round(ProgressTrack, 1)

		local ProgressFill = Instance.new("Frame")
		ProgressFill.Name = "ProgressFill"
		ProgressFill.Size = UDim2.new(1, 0, 1, 0)
		ProgressFill.BackgroundColor3 = tc
		ProgressFill.BorderSizePixel = 0
		ProgressFill.ZIndex = 202
		ProgressFill.Parent = ProgressTrack
		round(ProgressFill, 1)

		local dismiss

		if hasActions then
			local btnRow = Instance.new("Frame")
			btnRow.Size = UDim2.new(1, -86, 0, 26)
			btnRow.Position = UDim2.new(0, 70, 0, 58)
			btnRow.BackgroundTransparency = 1
			btnRow.ZIndex = 200
			btnRow.Parent = Frame

			local BtnLayout = Instance.new("UIListLayout")
			BtnLayout.FillDirection = Enum.FillDirection.Horizontal
			BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
			BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			BtnLayout.Padding = UDim.new(0, 8)
			BtnLayout.Parent = btnRow

			for i, action in ipairs(config.Actions) do
				local aType = tostring(action.Type or kind):lower()
				local aColor = TYPE_COLORS[aType] or tc
				local isPrimary = (i == 1)

				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(0, 72, 0, 26)
				Btn.BackgroundColor3 = isPrimary and aColor or Color3.fromRGB(36, 36, 40)
				Btn.BorderSizePixel = 0
				Btn.Font = Enum.Font.GothamBold
				Btn.Text = tostring(action.Text or "")
				Btn.TextColor3 = isPrimary and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(255, 255, 255)
				Btn.TextSize = 11
				Btn.AutoButtonColor = false
				Btn.ZIndex = 200
				Btn.Parent = btnRow
				round(Btn, 0.23)

				if not isPrimary then
					local BtnStroke = Instance.new("UIStroke")
					BtnStroke.Thickness = 1
					BtnStroke.Color = Color3.fromRGB(50, 50, 55)
					BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					BtnStroke.Parent = Btn
				end

				local BtnScale = Instance.new("UIScale")
				BtnScale.Scale = 1
				BtnScale.Parent = Btn

				Btn.MouseEnter:Connect(function()
					TweenService:Create(BtnScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1.04 }):Play()
				end)
				Btn.MouseLeave:Connect(function()
					TweenService:Create(BtnScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Scale = 1 }):Play()
				end)
				Btn.MouseButton1Down:Connect(function()
					TweenService:Create(BtnScale, TweenInfo.new(0.08), { Scale = 0.96 }):Play()
				end)
				Btn.MouseButton1Up:Connect(function()
					TweenService:Create(BtnScale, TweenInfo.new(0.12), { Scale = 1.04 }):Play()
				end)
				Btn.MouseButton1Click:Connect(function()
					if type(action) == "table" and type(action.Callback) == "function" then
						task.spawn(action.Callback)
					end
					dismiss()
				end)
			end
		end

		-- hover highlight like UI cards
		Frame.MouseEnter:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 75) }):Play()
		end)
		Frame.MouseLeave:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.15), { Transparency = 0.35 }):Play()
		end)

		-- slide in from the right with a pop
		Frame.Position = UDim2.new(0, notifW + 24, 0, 0)
		Frame.BackgroundTransparency = 1
		local NotifScale = Instance.new("UIScale")
		NotifScale.Scale = 0.96
		NotifScale.Parent = Frame
		TweenService:Create(Frame, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0,
		}):Play()
		TweenService:Create(NotifScale, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1,
		}):Play()

		local closed = false
		dismiss = function()
			if closed then return end
			closed = true
			TweenService:Create(Frame, TweenInfo.new(0.24, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.new(0, notifW + 24, 0, 0),
				BackgroundTransparency = 1,
			}):Play()
			task.delay(0.28, function()
				pcall(function() Frame:Destroy() end)
			end)
		end

		TweenService:Create(ProgressFill, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
			Size = UDim2.new(0, 0, 1, 0),
		}):Play()

		task.spawn(function()
			local elapsed = 0
			while elapsed < duration do
				if closed or not Frame.Parent then return end
				task.wait(0.1)
				elapsed = elapsed + 0.1
			end
			dismiss()
		end)
	end
end

-- Brand icon with a watchdog: if Roblox fails to load the image,
-- automatically swap to the drawn mark instead of leaving a blank box.
-- mode "fill" = square app icons (Discord, YouTube)
-- mode "fit"  = tall/wide glyphs (LumuHub logo)
local function renderBrandIcon(holder, sprite, fallbackFn, color, mode)
	local asset = parseIcon(sprite)
	if not asset then
		renderIcon(holder, nil, fallbackFn, color, "fit")
		return
	end
	holder:ClearAllChildren()
	local img = Instance.new("ImageLabel")
	img.Name = "Sprite"
	img.BackgroundTransparency = 1
	img.Size = UDim2.fromScale(1, 1)
	img.ScaleType = (mode == "fill") and Enum.ScaleType.Stretch or Enum.ScaleType.Fit
	img.ZIndex = (holder.ZIndex or 1) + 2
	applyIcon(img, asset)
	img.ImageColor3 = Color3.fromRGB(255, 255, 255)
	img.Parent = holder

	task.delay(4, function()
		if img.Parent and not img.IsLoaded then
			img:Destroy()
			renderIcon(holder, nil, fallbackFn, color, "fit")
		end
	end)
end

-- ============================================================================
-- Loading screen
-- ============================================================================
function KeySystem:CreateLoading(config)
	config = config or {}
	local accent = config.Accent or KeySystem.Accent
	if typeof(accent) ~= "Color3" then accent = ACCENT end
	local title = config.Title or "LumuHub"
	local subtitle = config.Subtitle or "Loading"

	local gui = newScreenGui("LumuLoading")

	local Backdrop = Instance.new("Frame")
	Backdrop.Name = "Backdrop"
	Backdrop.BackgroundColor3 = Color3.fromRGB(8, 8, 10)
	Backdrop.BackgroundTransparency = 1
	Backdrop.BorderSizePixel = 0
	Backdrop.Size = UDim2.new(1, 0, 1, 0)
	Backdrop.ZIndex = 400
	Backdrop.Parent = gui

	local Card = Instance.new("Frame")
	Card.Name = "Card"
	Card.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
	Card.BackgroundTransparency = 1
	Card.BorderSizePixel = 0
	Card.AnchorPoint = Vector2.new(0.5, 0.5)
	Card.Position = UDim2.new(0.5, 0, 0.5, 0)
	Card.Size = UDim2.new(0, 380, 0, 178)
	Card.ZIndex = 401
	Card.Parent = Backdrop
	round(Card, 0.09)

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = Color3.fromRGB(38, 38, 44)
	cardStroke.Thickness = 1.2
	cardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	cardStroke.Parent = Card

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
	TitleLabel.Position = UDim2.new(0.5, 0, 0, 36)
	TitleLabel.Size = UDim2.new(1, -40, 0, 22)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = tostring(title)
	TitleLabel.TextSize = 18
	TitleLabel.TextColor3 = TEXT
	TitleLabel.ZIndex = 402
	TitleLabel.Parent = Card

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "Status"
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.AnchorPoint = Vector2.new(0.5, 0)
	StatusLabel.Position = UDim2.new(0.5, 0, 0, 64)
	StatusLabel.Size = UDim2.new(1, -40, 0, 18)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = tostring(subtitle)
	StatusLabel.TextSize = 12
	StatusLabel.TextColor3 = TEXT_DIM
	StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	StatusLabel.ZIndex = 402
	StatusLabel.Parent = Card

	local Track = Instance.new("Frame")
	Track.Name = "Track"
	Track.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	Track.BorderSizePixel = 0
	Track.AnchorPoint = Vector2.new(0.5, 0.5)
	Track.Position = UDim2.new(0.5, 0, 0, 108)
	Track.Size = UDim2.new(1, -64, 0, 6)
	Track.ZIndex = 402
	Track.Parent = Card
	round(Track, 1)

	local Fill = Instance.new("Frame")
	Fill.Name = "Fill"
	Fill.BackgroundColor3 = accent
	Fill.BorderSizePixel = 0
	Fill.Size = UDim2.new(0, 0, 1, 0)
	Fill.ZIndex = 403
	Fill.Parent = Track
	round(Fill, 1)

	local Dots = Instance.new("Frame")
	Dots.Name = "Dots"
	Dots.BackgroundTransparency = 1
	Dots.AnchorPoint = Vector2.new(0.5, 0)
	Dots.Position = UDim2.new(0.5, 0, 0, 132)
	Dots.Size = UDim2.new(0, 44, 0, 8)
	Dots.ZIndex = 402
	Dots.Parent = Card

	local dotLayout = Instance.new("UIListLayout")
	dotLayout.FillDirection = Enum.FillDirection.Horizontal
	dotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	dotLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	dotLayout.Padding = UDim.new(0, 6)
	dotLayout.Parent = Dots

	local dotFrames = {}
	for i = 1, 3 do
		local d = Instance.new("Frame")
		d.BackgroundColor3 = accent
		d.BackgroundTransparency = 0.65
		d.BorderSizePixel = 0
		d.Size = UDim2.new(0, 6, 0, 6)
		d.ZIndex = 403
		d.Parent = Dots
		round(d, 1)
		dotFrames[i] = d
	end

	task.spawn(function()
		local i = 1
		while Backdrop.Parent do
			for k, d in ipairs(dotFrames) do
				if d.Parent then
					TweenService:Create(d, TweenInfo.new(0.25), { BackgroundTransparency = (k == i) and 0 or 0.7 }):Play()
				end
			end
			i = (i % #dotFrames) + 1
			task.wait(0.28)
		end
	end)

	local Controller = {}
	Controller.ScreenGui = gui

	function Controller:Show()
		Backdrop.Visible = true
		TweenService:Create(Backdrop, TweenInfo.new(0.25), { BackgroundTransparency = 0.15 }):Play()
		TweenService:Create(Card, TweenInfo.new(0.25), { BackgroundTransparency = 0 }):Play()
		return Controller
	end

	function Controller:Hide()
		TweenService:Create(Backdrop, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(Card, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
		task.delay(0.35, function() Backdrop.Visible = false end)
		return Controller
	end

	function Controller:Destroy()
		pcall(function() gui:Destroy() end)
	end

	function Controller:SetText(text)
		StatusLabel.Text = tostring(text or "")
		return Controller
	end

	function Controller:SetProgress(value)
		local p = tonumber(value) or 0
		if p < 0 then p = 0 elseif p > 1 then p = 1 end
		TweenService:Create(Fill, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(p, 0, 1, 0),
		}):Play()
		return Controller
	end

	function Controller:SetAccent(color)
		if typeof(color) ~= "Color3" then return Controller end
		Fill.BackgroundColor3 = color
		cardStroke.Color = color
		for _, d in ipairs(dotFrames) do d.BackgroundColor3 = color end
		return Controller
	end

	Backdrop.Visible = false
	return Controller
end

-- ============================================================================
-- Key window
-- ============================================================================
function KeySystem:Create(config)
	config = config or {}

	local accent = config.Accent or KeySystem.Accent
	if typeof(accent) ~= "Color3" then accent = ACCENT end

	local title = config.Title or "LumuHub"
	local subTitle = config.SubTitle or "Key System"
	local windowWidth = tonumber(config.Width) or 430
	local unlocked = false
	local busy = false

	-- ---------- server verification ----------
	-- VerifyUrl = "https://lumuhub.top/api/verify"  ->  ...?key=KEY&script=ID
	-- the server must answer "valid" / "invalid" (or JSON {"valid":true})
	local verifyUrl = config.VerifyUrl
	local scriptId = config.ScriptId

	local function verifyOnServer(key)
		local url = tostring(verifyUrl)
		if url == "" then return false end
		local encoded = tostring(key)
		pcall(function() encoded = HttpService:UrlEncode(tostring(key)) end)
		url = url .. (string.find(url, "?", 1, true) and "&" or "?") .. "key=" .. encoded
		if scriptId and tostring(scriptId) ~= "" then
			url = url .. "&script=" .. tostring(scriptId)
		end
		local ok, res = pcall(function() return game:HttpGet(url) end)
		if not ok or res == nil then return false end
		local text = tostring(res):gsub("%s+", "")
		local lower = string.lower(text)
		if lower == "valid" or lower == "true" then return true end
		if lower == "invalid" or lower == "false" then return false end
		if string.sub(text, 1, 1) == "{" then
			local ok2, data = pcall(function() return HttpService:JSONDecode(text) end)
			if ok2 and type(data) == "table" then
				return data.valid == true or data.status == "valid"
			end
		end
		return false
	end

	local checkFn = config.CheckKey
	if type(checkFn) ~= "function" and verifyUrl then checkFn = verifyOnServer end

	local screenGui = newScreenGui("LumuKeySystem")

	-- notification system copied from the main UI (same stack, same cards)
	local mainNotify = createMainNotify(screenGui, function() return accent end)

	local notify = function(kind, titleText, message, duration, actions)
		mainNotify({ Type = kind, Title = titleText, Message = message, Duration = duration or 5, Actions = actions })
	end

	-- ---------- window (fixed, not draggable) ----------
	local Window = Instance.new("Frame")
	Window.Name = "KeyWindow"
	Window.BackgroundColor3 = BG
	Window.BorderSizePixel = 0
	Window.AnchorPoint = Vector2.new(0.5, 0.5)
	Window.Position = UDim2.new(0.5, 0, 0.5, 0)
	Window.Size = UDim2.new(0, windowWidth, 0, 0)
	Window.AutomaticSize = Enum.AutomaticSize.Y
	Window.ZIndex = 100
	Window.Parent = screenGui
	round(Window, 0.033)

	local winStroke = Instance.new("UIStroke")
	winStroke.Color = Color3.fromRGB(40, 40, 46)
	winStroke.Thickness = 1.2
	winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	winStroke.Parent = Window

	local winGradient = Instance.new("UIGradient")
	winGradient.Rotation = 90
	winGradient.Color = ColorSequence.new(Color3.fromRGB(23, 23, 28), Color3.fromRGB(11, 11, 13))
	winGradient.Parent = Window

	local winLayout = Instance.new("UIListLayout")
	winLayout.FillDirection = Enum.FillDirection.Vertical
	winLayout.SortOrder = Enum.SortOrder.LayoutOrder
	winLayout.Padding = UDim.new(0, 0)
	winLayout.Parent = Window

	-- ---------- header ----------
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.BackgroundColor3 = Color3.fromRGB(31, 31, 38)
	Header.BackgroundTransparency = 0.4
	Header.BorderSizePixel = 0
	Header.Size = UDim2.new(1, 0, 0, 76)
	Header.LayoutOrder = 1
	Header.ZIndex = 101
	Header.Parent = Window

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 14)
	headerCorner.Parent = Header

	local headerFill = Instance.new("Frame")
	headerFill.BackgroundColor3 = Header.BackgroundColor3
	headerFill.BackgroundTransparency = Header.BackgroundTransparency
	headerFill.BorderSizePixel = 0
	headerFill.AnchorPoint = Vector2.new(0, 1)
	headerFill.Position = UDim2.new(0, 0, 1, 0)
	headerFill.Size = UDim2.new(1, 0, 0, 16)
	headerFill.ZIndex = 101
	headerFill.Parent = Header

	local headerSep = Instance.new("Frame")
	headerSep.Name = "Separator"
	headerSep.BackgroundColor3 = Color3.fromRGB(42, 42, 48)
	headerSep.BorderSizePixel = 0
	headerSep.AnchorPoint = Vector2.new(0.5, 1)
	headerSep.Position = UDim2.new(0.5, 0, 1, 0)
	headerSep.Size = UDim2.new(1, -32, 0, 1)
	headerSep.ZIndex = 102
	headerSep.Parent = Header

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	TitleLabel.Position = UDim2.new(0.5, 0, 0.5, -10)
	TitleLabel.Size = UDim2.new(1, -40, 0, 22)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = tostring(title)
	TitleLabel.TextSize = 20
	TitleLabel.TextColor3 = TEXT
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
	TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TitleLabel.ZIndex = 103
	TitleLabel.Parent = Header

	local SubTitleLabel = Instance.new("TextLabel")
	SubTitleLabel.Name = "SubTitle"
	SubTitleLabel.BackgroundTransparency = 1
	SubTitleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
	SubTitleLabel.Position = UDim2.new(0.5, 0, 0.5, 10)
	SubTitleLabel.Size = UDim2.new(1, -40, 0, 17)
	SubTitleLabel.Font = Enum.Font.Gotham
	SubTitleLabel.Text = tostring(subTitle)
	SubTitleLabel.TextSize = 12
	SubTitleLabel.TextColor3 = TEXT_DIM
	SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Center
	SubTitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	SubTitleLabel.ZIndex = 103
	SubTitleLabel.Parent = Header

	-- ---------- body ----------
	local Body = Instance.new("Frame")
	Body.Name = "Body"
	Body.BackgroundTransparency = 1
	Body.Size = UDim2.new(1, 0, 0, 0)
	Body.AutomaticSize = Enum.AutomaticSize.Y
	Body.LayoutOrder = 2
	Body.ZIndex = 101
	Body.Parent = Window

	local bodyPad = Instance.new("UIPadding")
	bodyPad.PaddingLeft = UDim.new(0, 20)
	bodyPad.PaddingRight = UDim.new(0, 20)
	bodyPad.PaddingTop = UDim.new(0, 16)
	bodyPad.PaddingBottom = UDim.new(0, 20)
	bodyPad.Parent = Body

	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.FillDirection = Enum.FillDirection.Vertical
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bodyLayout.Padding = UDim.new(0, 12)
	bodyLayout.Parent = Body

	-- status line
	local StatusRow = Instance.new("Frame")
	StatusRow.Name = "StatusRow"
	StatusRow.BackgroundTransparency = 1
	StatusRow.Size = UDim2.new(1, 0, 0, 17)
	StatusRow.LayoutOrder = 1
	StatusRow.ZIndex = 102
	StatusRow.Parent = Body

	local StatusDot = Instance.new("Frame")
	StatusDot.Name = "Dot"
	StatusDot.BackgroundColor3 = TEXT_DIM
	StatusDot.BorderSizePixel = 0
	StatusDot.AnchorPoint = Vector2.new(0, 0.5)
	StatusDot.Position = UDim2.new(0, 0, 0.5, 0)
	StatusDot.Size = UDim2.new(0, 7, 0, 7)
	StatusDot.ZIndex = 103
	StatusDot.Parent = StatusRow
	round(StatusDot, 1)

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "Status"
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.AnchorPoint = Vector2.new(0, 0.5)
	StatusLabel.Position = UDim2.new(0, 16, 0.5, 0)
	StatusLabel.Size = UDim2.new(1, -16, 1, 0)
	StatusLabel.Font = Enum.Font.Gotham
	StatusLabel.Text = "Enter your key to continue"
	StatusLabel.TextSize = 12
	StatusLabel.TextColor3 = TEXT_DIM
	StatusLabel.TextXAlignment = Enum.TextXAlignment.Left
	StatusLabel.TextTruncate = Enum.TextTruncate.AtEnd
	StatusLabel.ZIndex = 103
	StatusLabel.Parent = StatusRow

	local STATUS_COLORS = {
		idle = TEXT_DIM,
		checking = accent,
		valid = GOOD,
		invalid = BAD,
		warn = WARN,
	}

	local function setStatus(kind, text)
		local color = STATUS_COLORS[kind] or TEXT_DIM
		StatusDot.BackgroundColor3 = color
		StatusLabel.TextColor3 = color
		StatusLabel.Text = tostring(text or "")
	end

	-- key input + paste
	local KeyRow = Instance.new("Frame")
	KeyRow.Name = "KeyRow"
	KeyRow.BackgroundTransparency = 1
	KeyRow.Size = UDim2.new(1, 0, 0, 50)
	KeyRow.LayoutOrder = 2
	KeyRow.ZIndex = 102
	KeyRow.Parent = Body

	local keyRowLayout = Instance.new("UIListLayout")
	keyRowLayout.FillDirection = Enum.FillDirection.Horizontal
	keyRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	keyRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	keyRowLayout.Padding = UDim.new(0, 10)
	keyRowLayout.Parent = KeyRow

	local InputCard = Instance.new("Frame")
	InputCard.Name = "InputCard"
	InputCard.BackgroundColor3 = INPUT_BG
	InputCard.BorderSizePixel = 0
	InputCard.Size = UDim2.new(1, -60, 1, 0)
	InputCard.LayoutOrder = 1
	InputCard.ZIndex = 102
	InputCard.Parent = KeyRow
	round(InputCard, 0.2)

	local inputStroke = Instance.new("UIStroke")
	inputStroke.Color = Color3.fromRGB(54, 54, 62)
	inputStroke.Thickness = 1.2
	inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	inputStroke.Parent = InputCard

	local KeyInput = Instance.new("TextBox")
	KeyInput.Name = "KeyInput"
	KeyInput.BackgroundTransparency = 1
	KeyInput.Position = UDim2.new(0, 15, 0, 0)
	KeyInput.Size = UDim2.new(1, -30, 1, 0)
	KeyInput.Font = Enum.Font.GothamBold
	KeyInput.Text = ""
	KeyInput.PlaceholderText = "Paste your key here..."
	KeyInput.PlaceholderColor3 = Color3.fromRGB(110, 110, 118)
	KeyInput.TextColor3 = TEXT
	KeyInput.TextSize = 14
	KeyInput.TextXAlignment = Enum.TextXAlignment.Left
	KeyInput.ClearTextOnFocus = false
	KeyInput.ZIndex = 103
	KeyInput.Parent = InputCard

	-- prefill from the loader (getgenv().LUMU_KEY / _G.LUMU_KEY) if present
	do
		local prefill = nil
		pcall(function()
			if getgenv and getgenv().LUMU_KEY then prefill = getgenv().LUMU_KEY end
			if (prefill == nil or prefill == "") and _G and _G.LUMU_KEY then prefill = _G.LUMU_KEY end
		end)
		if prefill ~= nil and tostring(prefill) ~= "" then
			KeyInput.Text = tostring(prefill)
			setStatus("idle", "Key loaded. Press Submit.")
		end
	end

	local PasteButton = Instance.new("TextButton")
	PasteButton.Name = "PasteButton"
	PasteButton.BackgroundColor3 = CARD
	PasteButton.BorderSizePixel = 0
	PasteButton.Size = UDim2.new(0, 50, 0, 50)
	PasteButton.Text = ""
	PasteButton.AutoButtonColor = false
	PasteButton.LayoutOrder = 2
	PasteButton.ZIndex = 102
	PasteButton.Parent = KeyRow
	round(PasteButton, 0.2)

	local pasteStroke = Instance.new("UIStroke")
	pasteStroke.Color = BORDER
	pasteStroke.Thickness = 1.2
	pasteStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pasteStroke.Parent = PasteButton

	local PasteInner = Instance.new("Frame")
	PasteInner.Name = "Inner"
	PasteInner.BackgroundTransparency = 1
	PasteInner.AnchorPoint = Vector2.new(0.5, 0.5)
	PasteInner.Position = UDim2.new(0.5, 0, 0.5, 0)
	PasteInner.Size = UDim2.new(0, 24, 0, 24)
	PasteInner.ZIndex = 103
	PasteInner.Parent = PasteButton
	Draw.clipboard(PasteInner, Color3.fromRGB(205, 205, 214))

	-- submit
	local SubmitButton = Instance.new("TextButton")
	SubmitButton.Name = "SubmitButton"
	SubmitButton.BackgroundColor3 = accent
	SubmitButton.BorderSizePixel = 0
	SubmitButton.Size = UDim2.new(1, 0, 0, 48)
	SubmitButton.Font = Enum.Font.GothamBold
	SubmitButton.Text = "Submit"
	SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SubmitButton.TextSize = 15
	SubmitButton.AutoButtonColor = false
	SubmitButton.LayoutOrder = 3
	SubmitButton.ZIndex = 102
	SubmitButton.Parent = Body
	round(SubmitButton, 0.21)

	-- secondary row
	local SecondaryRow = Instance.new("Frame")
	SecondaryRow.Name = "SecondaryRow"
	SecondaryRow.BackgroundTransparency = 1
	SecondaryRow.Size = UDim2.new(1, 0, 0, 44)
	SecondaryRow.LayoutOrder = 4
	SecondaryRow.ZIndex = 102
	SecondaryRow.Parent = Body

	local secondaryLayout = Instance.new("UIListLayout")
	secondaryLayout.FillDirection = Enum.FillDirection.Horizontal
	secondaryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	secondaryLayout.Padding = UDim.new(0, 10)
	secondaryLayout.Parent = SecondaryRow

	local function makeSecondaryButton(name, text, sprite, fallbackFn, order)
		local btn = Instance.new("TextButton")
		btn.Name = name
		btn.BackgroundColor3 = CARD
		btn.BorderSizePixel = 0
		btn.Size = UDim2.new(0.5, -5, 1, 0)
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.LayoutOrder = order
		btn.ZIndex = 102
		btn.Parent = SecondaryRow
		round(btn, 0.23)

		local stroke = Instance.new("UIStroke")
		stroke.Color = BORDER
		stroke.Thickness = 1.2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		local inner = Instance.new("Frame")
		inner.BackgroundTransparency = 1
		inner.AnchorPoint = Vector2.new(0.5, 0.5)
		inner.Position = UDim2.new(0.5, 0, 0.5, 0)
		inner.Size = UDim2.new(0, 0, 1, 0)
		inner.AutomaticSize = Enum.AutomaticSize.X
		inner.ZIndex = 103
		inner.Parent = btn

		local innerLayout = Instance.new("UIListLayout")
		innerLayout.FillDirection = Enum.FillDirection.Horizontal
		innerLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		innerLayout.SortOrder = Enum.SortOrder.LayoutOrder
		innerLayout.Padding = UDim.new(0, 8)
		innerLayout.Parent = inner

		local iconHolder = Instance.new("Frame")
		iconHolder.BackgroundTransparency = 1
		iconHolder.Size = UDim2.new(0, 16, 0, 16)
		iconHolder.LayoutOrder = 1
		iconHolder.ZIndex = 104
		iconHolder.Parent = inner
		renderIcon(iconHolder, sprite, fallbackFn, Color3.fromRGB(205, 205, 214))

		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.BackgroundTransparency = 1
		label.Size = UDim2.new(0, 0, 1, 0)
		label.AutomaticSize = Enum.AutomaticSize.X
		label.Font = Enum.Font.GothamBold
		label.Text = text
		label.TextSize = 13
		label.TextColor3 = Color3.fromRGB(235, 235, 240)
		label.LayoutOrder = 2
		label.ZIndex = 104
		label.Parent = inner

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CARD_HOVER }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = accent }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CARD }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = BORDER }):Play()
		end)

		return btn
	end

	local GetKeyButton = makeSecondaryButton("GetKeyButton", "Get Key", config.GetKeyIcon or "Trophy1", Draw.check, 1)
	local HowToButton = makeSecondaryButton("HowToButton", "How to get key", config.HowToIcon or "guide_icon", Draw.check, 2)

	-- divider
	local Divider = Instance.new("Frame")
	Divider.Name = "Divider"
	Divider.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	Divider.BorderSizePixel = 0
	Divider.Size = UDim2.new(1, 0, 0, 1)
	Divider.LayoutOrder = 5
	Divider.ZIndex = 102
	Divider.Parent = Body

	-- social row
	local SocialRow = Instance.new("Frame")
	SocialRow.Name = "SocialRow"
	SocialRow.BackgroundTransparency = 1
	SocialRow.Size = UDim2.new(1, 0, 0, 0)
	SocialRow.AutomaticSize = Enum.AutomaticSize.Y
	SocialRow.LayoutOrder = 6
	SocialRow.ZIndex = 102
	SocialRow.Parent = Body

	local socialLayout = Instance.new("UIListLayout")
	socialLayout.FillDirection = Enum.FillDirection.Horizontal
	socialLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	socialLayout.VerticalAlignment = Enum.VerticalAlignment.Top
	socialLayout.SortOrder = Enum.SortOrder.LayoutOrder
	socialLayout.Padding = UDim.new(0, 40)
	socialLayout.Parent = SocialRow

	local function makeSocial(name, labelText, url, brandColor, sprite, fallbackFn, order)
		local column = Instance.new("Frame")
		column.Name = name .. "Column"
		column.BackgroundTransparency = 1
		column.Size = UDim2.new(0, 80, 0, 0)
		column.AutomaticSize = Enum.AutomaticSize.Y
		column.LayoutOrder = order
		column.ZIndex = 102
		column.Parent = SocialRow

		local columnLayout = Instance.new("UIListLayout")
		columnLayout.FillDirection = Enum.FillDirection.Vertical
		columnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		columnLayout.SortOrder = Enum.SortOrder.LayoutOrder
		columnLayout.Padding = UDim.new(0, 7)
		columnLayout.Parent = column

		local btn = Instance.new("TextButton")
		btn.Name = name .. "Button"
		btn.BackgroundColor3 = CARD
		btn.BorderSizePixel = 0
		btn.Size = UDim2.new(0, 56, 0, 56)
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.ClipsDescendants = true
		btn.LayoutOrder = 1
		btn.ZIndex = 102
		btn.Parent = column
		round(btn, 0.23)

		local btnScale = Instance.new("UIScale")
		btnScale.Scale = 1
		btnScale.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = BORDER
		stroke.Thickness = 1.2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		local iconHolder = Instance.new("Frame")
		iconHolder.Name = "Inner"
		iconHolder.BackgroundTransparency = 1
		iconHolder.AnchorPoint = Vector2.new(0.5, 0.5)
		iconHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
		iconHolder.Size = UDim2.new(1, -18, 1, -18)
		iconHolder.ZIndex = 103
		iconHolder.Parent = btn
		renderBrandIcon(iconHolder, sprite, fallbackFn, brandColor, "fit")

		local caption = Instance.new("TextLabel")
		caption.Name = "Caption"
		caption.BackgroundTransparency = 1
		caption.Size = UDim2.new(1, 0, 0, 16)
		caption.Font = Enum.Font.Gotham
		caption.Text = labelText
		caption.TextSize = 12
		caption.TextColor3 = TEXT_DIM
		caption.LayoutOrder = 2
		caption.ZIndex = 103
		caption.Parent = column

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CARD_HOVER }):Play()
			TweenService:Create(btnScale, TweenInfo.new(0.15), { Scale = 1.07 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = brandColor }):Play()
			TweenService:Create(caption, TweenInfo.new(0.15), { TextColor3 = brandColor }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CARD }):Play()
			TweenService:Create(btnScale, TweenInfo.new(0.15), { Scale = 1 }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = BORDER }):Play()
			TweenService:Create(caption, TweenInfo.new(0.15), { TextColor3 = TEXT_DIM }):Play()
		end)

		btn.MouseButton1Click:Connect(function()
			if url == nil or url == "" then
				notify("warning", "No link set", labelText .. " link is not configured.")
				return
			end
			url = tostring(url)
			if setclipboard then pcall(setclipboard, url) end
			notify("info", labelText, "Link copied to clipboard.")
		end)

		return btn
	end

	makeSocial("Discord", "Discord", config.Discord, DISCORD_COLOR, config.DiscordIcon or 113638305642892, Draw.discord, 1)
	makeSocial("YouTube", "YouTube", config.YouTube, YOUTUBE_COLOR, config.YouTubeIcon or 75220704845772, Draw.play, 2)

	-- ========================================================================
	-- behaviour
	-- ========================================================================
	local function openLink(url, label)
		if url == nil or url == "" then
			notify("warning", "No link set", label .. " link is not configured.")
			return
		end
		url = tostring(url)
		if url == "" then
			notify("warning", "No link set", label .. " link is not configured.")
			return
		end
		if setclipboard then pcall(setclipboard, url) end
		notify("info", label, "Link copied to clipboard.")
	end

	local function shake()
		local origin = Window.Position
		task.spawn(function()
			for i = 1, 4 do
				local offset = (i % 2 == 0) and 9 or -9
				TweenService:Create(Window, TweenInfo.new(0.05), {
					Position = UDim2.new(origin.X.Scale, origin.X.Offset + offset, origin.Y.Scale, origin.Y.Offset),
				}):Play()
				task.wait(0.055)
			end
			TweenService:Create(Window, TweenInfo.new(0.08), { Position = origin }):Play()
		end)
	end

	local function submit()
		if busy or unlocked then return end
		local key = tostring(KeyInput.Text or "")
		key = key:gsub("^%s+", ""):gsub("%s+$", "")
		if key == "" then
			setStatus("warn", "Please enter a key first.")
			notify("warning", "No Key", "Type or paste your key, then press Submit.")
			shake()
			return
		end

		busy = true
		SubmitButton.Text = "Checking..."
		TweenService:Create(SubmitButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.4 }):Play()
		setStatus("checking", "Checking key...")

		task.spawn(function()
			local ok, result = true, false
			if type(checkFn) == "function" then
				ok, result = pcall(checkFn, key)
			else
				result = true
			end
			task.wait(0.2)

			busy = false
			SubmitButton.Text = "Submit"
			TweenService:Create(SubmitButton, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()

			if ok and result then
				unlocked = true
				setStatus("valid", "Key accepted. Loading...")
				notify("good", "Key Valid", "Welcome to " .. title .. ".")
				SubmitButton.Text = "Unlocked"
				SubmitButton.BackgroundColor3 = GOOD
				if config.OnSuccess then pcall(config.OnSuccess, key) end
			else
				setStatus("invalid", "Invalid key, try again.")
				notify("bad", "Invalid Key", "That key is wrong, expired or already used.")
				shake()
				if config.OnFail then pcall(config.OnFail, key) end
			end
		end)
	end

	SubmitButton.MouseButton1Click:Connect(submit)

	KeyInput.Focused:Connect(function()
		TweenService:Create(inputStroke, TweenInfo.new(0.15), { Color = accent }):Play()
	end)
	KeyInput.FocusLost:Connect(function(enterPressed)
		TweenService:Create(inputStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(54, 54, 62) }):Play()
		if enterPressed then submit() end
	end)

	SubmitButton.MouseEnter:Connect(function()
		if unlocked then return end
		TweenService:Create(SubmitButton, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(
			math.floor(accent.R * 255 * 1.18), math.floor(accent.G * 255 * 1.18), math.floor(accent.B * 255 * 1.18)
		) }):Play()
	end)
	SubmitButton.MouseLeave:Connect(function()
		if unlocked then return end
		TweenService:Create(SubmitButton, TweenInfo.new(0.15), { BackgroundColor3 = accent }):Play()
	end)

	PasteButton.MouseEnter:Connect(function()
		TweenService:Create(PasteButton, TweenInfo.new(0.15), { BackgroundColor3 = CARD_HOVER }):Play()
		TweenService:Create(pasteStroke, TweenInfo.new(0.15), { Color = accent }):Play()
	end)
	PasteButton.MouseLeave:Connect(function()
		TweenService:Create(PasteButton, TweenInfo.new(0.15), { BackgroundColor3 = CARD }):Play()
		TweenService:Create(pasteStroke, TweenInfo.new(0.15), { Color = BORDER }):Play()
	end)

	PasteButton.MouseButton1Click:Connect(function()
		local clip = nil
		if getclipboard then pcall(function() clip = getclipboard() end) end
		if (not clip or clip == "") and readclipboard then pcall(function() clip = readclipboard() end) end
		if clip and clip ~= "" then
			KeyInput.Text = clip
			setStatus("idle", "Key pasted from clipboard.")
		else
			setStatus("warn", "Clipboard is empty or unavailable.")
			notify("warning", "Nothing to paste", "Copy your key first, then press paste.")
			shake()
		end
	end)

	GetKeyButton.MouseButton1Click:Connect(function()
		openLink(config.GetKeyUrl, "Get Key")
	end)

	HowToButton.MouseButton1Click:Connect(function()
		openLink(config.HowToKeyUrl, "How to get key")
	end)

	-- ---------- controller ----------
	local Controller = {}
	Controller.Window = Window
	Controller.ScreenGui = screenGui

	function Controller:Show() Window.Visible = true; return Controller end
	function Controller:Hide() Window.Visible = false; return Controller end
	function Controller:Destroy() pcall(function() screenGui:Destroy() end) end
	function Controller:SetStatus(kind, text) setStatus(kind, text); return Controller end
	function Controller:SetKey(text) KeyInput.Text = tostring(text or ""); return Controller end
	function Controller:GetKey() return KeyInput.Text end
	function Controller:IsUnlocked() return unlocked end
	function Controller:Submit() submit(); return Controller end
	function Controller:Notify(kind, titleText, message) notify(kind, titleText, message); return Controller end
	function Controller:SetAccent(color)
		if typeof(color) ~= "Color3" then return Controller end
		accent = color
		SubmitButton.BackgroundColor3 = color
		winStroke.Color = color
		return Controller
	end

	return Controller
end

return KeySystem
