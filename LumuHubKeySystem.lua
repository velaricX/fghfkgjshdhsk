-- ============================================================================
--  LumuHub Key System UI
--  Standalone, matches the Lumu UI design language.
--
--  local KeyUI = loadstring(game:HttpGet(".../LumuHubKeySystem.lua"))()
--  local Icons = loadstring(game:HttpGet(".../icons_sprites.lua"))()
--  KeyUI:RegisterIcons(Icons)
--
--  local Keys = KeyUI:Create({
--      Title = "LumuHub",
--      SubTitle = "Key System",
--      Badge = "v1.0",
--      Discord = "https://discord.gg/xxxx",
--      YouTube = "https://youtube.com/@xxxx",
--      GetKeyUrl = "https://...",          -- "Get Key" opens this
--      HowToKeyUrl = "https://...",        -- "How to get key" opens this
--      CheckKey = function(key)            -- return true if the key is valid
--          return key == "LUMU-TEST"
--      end,
--      OnSuccess = function(key) print("unlocked", key) end,
--      OnFail = function(key) end,
--  })
-- ============================================================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local ACCENT = Color3.fromRGB(0, 153, 235)
local CARD = Color3.fromRGB(26, 26, 30)
local CARD_HOVER = Color3.fromRGB(36, 36, 40)
local BG = Color3.fromRGB(12, 12, 14)
local BORDER = Color3.fromRGB(50, 50, 55)
local BORDER_HOVER = Color3.fromRGB(70, 70, 75)
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

local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragStart, startPos = false, nil, nil
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UserInputService.InputChanged:Connect(function(input)
		if not dragging then return end
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			local dx = input.Position.X - dragStart.X
			local dy = input.Position.Y - dragStart.Y
			frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
		end
	end)
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
-- Notifications (small toasts, top-right)
-- ============================================================================
local function createNotifier(screenGui)
	local stack = Instance.new("Frame")
	stack.Name = "Toasts"
	stack.BackgroundTransparency = 1
	stack.AnchorPoint = Vector2.new(1, 0)
	stack.Position = UDim2.new(1, -18, 0, 18)
	stack.Size = UDim2.new(0, 280, 0, 0)
	stack.AutomaticSize = Enum.AutomaticSize.Y
	stack.ZIndex = 900
	stack.Parent = screenGui

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Right
	layout.Padding = UDim.new(0, 8)
	layout.Parent = stack

	local palette = { good = GOOD, bad = BAD, warning = WARN }

	return function(kind, title, message)
		local color = palette[kind] or ACCENT
		local card = Instance.new("Frame")
		card.BackgroundColor3 = CARD
		card.BorderSizePixel = 0
		card.Size = UDim2.new(0, 280, 0, 60)
		card.ZIndex = 901
		card.Parent = stack

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = color
		stroke.Transparency = 0.55
		stroke.Thickness = 1.2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = card

		local bar = Instance.new("Frame")
		bar.BackgroundColor3 = color
		bar.BorderSizePixel = 0
		bar.Position = UDim2.new(0, 0, 0, 10)
		bar.Size = UDim2.new(0, 3, 1, -20)
		bar.ZIndex = 902
		bar.Parent = card

		local barCorner = Instance.new("UICorner")
		barCorner.CornerRadius = UDim.new(1, 0)
		barCorner.Parent = bar

		local titleLabel = Instance.new("TextLabel")
		titleLabel.BackgroundTransparency = 1
		titleLabel.Position = UDim2.new(0, 14, 0, 10)
		titleLabel.Size = UDim2.new(1, -24, 0, 16)
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.Text = tostring(title or "")
		titleLabel.TextSize = 13
		titleLabel.TextColor3 = TEXT
		titleLabel.TextXAlignment = Enum.TextXAlignment.Left
		titleLabel.ZIndex = 902
		titleLabel.Parent = card

		local msgLabel = Instance.new("TextLabel")
		msgLabel.BackgroundTransparency = 1
		msgLabel.Position = UDim2.new(0, 14, 0, 28)
		msgLabel.Size = UDim2.new(1, -24, 0, 22)
		msgLabel.Font = Enum.Font.Gotham
		msgLabel.Text = tostring(message or "")
		msgLabel.TextSize = 11
		msgLabel.TextColor3 = TEXT_DIM
		msgLabel.TextXAlignment = Enum.TextXAlignment.Left
		msgLabel.TextWrapped = true
		msgLabel.TextTruncate = Enum.TextTruncate.AtEnd
		msgLabel.ZIndex = 902
		msgLabel.Parent = card

		card.Position = UDim2.new(1, 40, 0, 0)
		card.BackgroundTransparency = 1
		stroke.Transparency = 1
		TweenService:Create(card, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundTransparency = 0,
		}):Play()
		TweenService:Create(stroke, TweenInfo.new(0.22), { Transparency = 0.55 }):Play()

		task.delay(4, function()
			TweenService:Create(card, TweenInfo.new(0.2), {
				Position = UDim2.new(1, 40, 0, 0),
				BackgroundTransparency = 1,
			}):Play()
			task.wait(0.25)
			card:Destroy()
		end)
	end
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
	local badge = config.Badge
	local logoIcon = parseIcon(config.Icon or "star")
	local windowWidth = tonumber(config.Width) or 420
	local checkFn = config.CheckKey
	local unlocked = false
	local busy = false

	local screenGui = newScreenGui("LumuKeySystem")
	local notify = createNotifier(screenGui)

	-- ---------- window ----------
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

	local winCorner = Instance.new("UICorner")
	winCorner.CornerRadius = UDim.new(0, 14)
	winCorner.Parent = Window

	local winStroke = Instance.new("UIStroke")
	winStroke.Color = Color3.fromRGB(38, 38, 44)
	winStroke.Thickness = 1.2
	winStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	winStroke.Parent = Window

	local winGradient = Instance.new("UIGradient")
	winGradient.Rotation = 90
	winGradient.Color = ColorSequence.new(Color3.fromRGB(22, 22, 27), Color3.fromRGB(11, 11, 13))
	winGradient.Parent = Window

	local winLayout = Instance.new("UIListLayout")
	winLayout.FillDirection = Enum.FillDirection.Vertical
	winLayout.SortOrder = Enum.SortOrder.LayoutOrder
	winLayout.Padding = UDim.new(0, 0)
	winLayout.Parent = Window

	-- ---------- header ----------
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	Header.BackgroundTransparency = 0.45
	Header.BorderSizePixel = 0
	Header.Size = UDim2.new(1, 0, 0, 68)
	Header.LayoutOrder = 1
	Header.ZIndex = 101
	Header.Active = true
	Header.Parent = Window

	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 14)
	headerCorner.Parent = Header

	local headerFix = Instance.new("Frame")
	headerFix.BackgroundColor3 = Header.BackgroundColor3
	headerFix.BackgroundTransparency = Header.BackgroundTransparency
	headerFix.BorderSizePixel = 0
	headerFix.AnchorPoint = Vector2.new(0, 1)
	headerFix.Position = UDim2.new(0, 0, 1, 0)
	headerFix.Size = UDim2.new(1, 0, 0, 14)
	headerFix.ZIndex = 101
	headerFix.Parent = Header

	local headerSep = Instance.new("Frame")
	headerSep.Name = "Separator"
	headerSep.BackgroundColor3 = Color3.fromRGB(40, 40, 46)
	headerSep.BorderSizePixel = 0
	headerSep.AnchorPoint = Vector2.new(0.5, 1)
	headerSep.Position = UDim2.new(0.5, 0, 1, 0)
	headerSep.Size = UDim2.new(1, -28, 0, 1)
	headerSep.ZIndex = 102
	headerSep.Parent = Header

	local LogoBox = Instance.new("Frame")
	LogoBox.Name = "LogoBox"
	LogoBox.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	LogoBox.BorderSizePixel = 0
	LogoBox.AnchorPoint = Vector2.new(0, 0.5)
	LogoBox.Position = UDim2.new(0, 18, 0.5, 0)
	LogoBox.Size = UDim2.new(0, 42, 0, 42)
	LogoBox.ZIndex = 102
	LogoBox.Parent = Header

	local logoCorner = Instance.new("UICorner")
	logoCorner.CornerRadius = UDim.new(0, 10)
	logoCorner.Parent = LogoBox

	local logoStroke = Instance.new("UIStroke")
	logoStroke.Color = accent
	logoStroke.Thickness = 1.4
	logoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	logoStroke.Parent = LogoBox

	local LogoIcon = Instance.new("ImageLabel")
	LogoIcon.Name = "Icon"
	LogoIcon.BackgroundTransparency = 1
	LogoIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	LogoIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	LogoIcon.Size = UDim2.new(0, 24, 0, 24)
	LogoIcon.ScaleType = Enum.ScaleType.Fit
	LogoIcon.ImageColor3 = accent
	LogoIcon.ZIndex = 103
	applyIcon(LogoIcon, logoIcon)
	LogoIcon.Parent = LogoBox

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
	TitleLabel.Position = UDim2.new(0, 72, 0.5, -9)
	TitleLabel.Size = UDim2.new(0, windowWidth - 150, 0, 20)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = tostring(title)
	TitleLabel.TextSize = 18
	TitleLabel.TextColor3 = TEXT
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	TitleLabel.ZIndex = 103
	TitleLabel.Parent = Header

	local SubTitleLabel = Instance.new("TextLabel")
	SubTitleLabel.Name = "SubTitle"
	SubTitleLabel.BackgroundTransparency = 1
	SubTitleLabel.AnchorPoint = Vector2.new(0, 0.5)
	SubTitleLabel.Position = UDim2.new(0, 72, 0.5, 9)
	SubTitleLabel.Size = UDim2.new(0, windowWidth - 150, 0, 16)
	SubTitleLabel.Font = Enum.Font.Gotham
	SubTitleLabel.Text = tostring(subTitle)
	SubTitleLabel.TextSize = 12
	SubTitleLabel.TextColor3 = TEXT_DIM
	SubTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	SubTitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
	SubTitleLabel.ZIndex = 103
	SubTitleLabel.Parent = Header

	if badge and badge ~= "" then
		local BadgePill = Instance.new("Frame")
		BadgePill.Name = "Badge"
		BadgePill.BackgroundColor3 = Color3.fromRGB(30, 34, 44)
		BadgePill.BorderSizePixel = 0
		BadgePill.AnchorPoint = Vector2.new(1, 0.5)
		BadgePill.Position = UDim2.new(1, -18, 0.5, 0)
		BadgePill.Size = UDim2.new(0, 0, 0, 22)
		BadgePill.AutomaticSize = Enum.AutomaticSize.X
		BadgePill.ZIndex = 102
		BadgePill.Parent = Header

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 6)
		badgeCorner.Parent = BadgePill

		local badgeStroke = Instance.new("UIStroke")
		badgeStroke.Color = accent
		badgeStroke.Transparency = 0.4
		badgeStroke.Thickness = 1
		badgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		badgeStroke.Parent = BadgePill

		local badgePad = Instance.new("UIPadding")
		badgePad.PaddingLeft = UDim.new(0, 9)
		badgePad.PaddingRight = UDim.new(0, 9)
		badgePad.Parent = BadgePill

		local badgeText = Instance.new("TextLabel")
		badgeText.BackgroundTransparency = 1
		badgeText.Size = UDim2.new(0, 0, 1, 0)
		badgeText.AutomaticSize = Enum.AutomaticSize.X
		badgeText.Font = Enum.Font.GothamBold
		badgeText.Text = tostring(badge)
		badgeText.TextSize = 10
		badgeText.TextColor3 = accent
		badgeText.ZIndex = 103
		badgeText.Parent = BadgePill
	end

	makeDraggable(Window, Header)

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
	bodyPad.PaddingLeft = UDim.new(0, 18)
	bodyPad.PaddingRight = UDim.new(0, 18)
	bodyPad.PaddingTop = UDim.new(0, 16)
	bodyPad.PaddingBottom = UDim.new(0, 18)
	bodyPad.Parent = Body

	local bodyLayout = Instance.new("UIListLayout")
	bodyLayout.FillDirection = Enum.FillDirection.Vertical
	bodyLayout.SortOrder = Enum.SortOrder.LayoutOrder
	bodyLayout.Padding = UDim.new(0, 12)
	bodyLayout.Parent = Body

	-- ---------- status line ----------
	local StatusRow = Instance.new("Frame")
	StatusRow.Name = "StatusRow"
	StatusRow.BackgroundTransparency = 1
	StatusRow.Size = UDim2.new(1, 0, 0, 16)
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

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = StatusDot

	local StatusLabel = Instance.new("TextLabel")
	StatusLabel.Name = "Status"
	StatusLabel.BackgroundTransparency = 1
	StatusLabel.AnchorPoint = Vector2.new(0, 0.5)
	StatusLabel.Position = UDim2.new(0, 15, 0.5, 0)
	StatusLabel.Size = UDim2.new(1, -15, 1, 0)
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

	-- ---------- key input + paste ----------
	local KeyRow = Instance.new("Frame")
	KeyRow.Name = "KeyRow"
	KeyRow.BackgroundTransparency = 1
	KeyRow.Size = UDim2.new(1, 0, 0, 46)
	KeyRow.LayoutOrder = 2
	KeyRow.ZIndex = 102
	KeyRow.Parent = Body

	local keyRowLayout = Instance.new("UIListLayout")
	keyRowLayout.FillDirection = Enum.FillDirection.Horizontal
	keyRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	keyRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	keyRowLayout.Padding = UDim.new(0, 8)
	keyRowLayout.Parent = KeyRow

	local InputCard = Instance.new("Frame")
	InputCard.Name = "InputCard"
	InputCard.BackgroundColor3 = INPUT_BG
	InputCard.BorderSizePixel = 0
	InputCard.Size = UDim2.new(1, -54, 1, 0)
	InputCard.LayoutOrder = 1
	InputCard.ZIndex = 102
	InputCard.Parent = KeyRow

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 10)
	inputCorner.Parent = InputCard

	local inputStroke = Instance.new("UIStroke")
	inputStroke.Color = Color3.fromRGB(52, 52, 60)
	inputStroke.Thickness = 1.2
	inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	inputStroke.Parent = InputCard

	local KeyInput = Instance.new("TextBox")
	KeyInput.Name = "KeyInput"
	KeyInput.BackgroundTransparency = 1
	KeyInput.Position = UDim2.new(0, 14, 0, 0)
	KeyInput.Size = UDim2.new(1, -28, 1, 0)
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

	local PasteButton = Instance.new("TextButton")
	PasteButton.Name = "PasteButton"
	PasteButton.BackgroundColor3 = CARD
	PasteButton.BorderSizePixel = 0
	PasteButton.Size = UDim2.new(0, 46, 0, 46)
	PasteButton.Text = ""
	PasteButton.AutoButtonColor = false
	PasteButton.LayoutOrder = 2
	PasteButton.ZIndex = 102
	PasteButton.Parent = KeyRow

	local pasteCorner = Instance.new("UICorner")
	pasteCorner.CornerRadius = UDim.new(0, 10)
	pasteCorner.Parent = PasteButton

	local pasteStroke = Instance.new("UIStroke")
	pasteStroke.Color = BORDER
	pasteStroke.Thickness = 1.2
	pasteStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	pasteStroke.Parent = PasteButton

	local PasteIcon = Instance.new("ImageLabel")
	PasteIcon.Name = "Icon"
	PasteIcon.BackgroundTransparency = 1
	PasteIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	PasteIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	PasteIcon.Size = UDim2.new(0, 20, 0, 20)
	PasteIcon.ScaleType = Enum.ScaleType.Fit
	PasteIcon.ImageColor3 = Color3.fromRGB(200, 200, 208)
	applyIcon(PasteIcon, parseIcon(config.PasteIcon or "redo"))
	PasteIcon.ZIndex = 103
	PasteIcon.Parent = PasteButton

	-- ---------- submit ----------
	local SubmitButton = Instance.new("TextButton")
	SubmitButton.Name = "SubmitButton"
	SubmitButton.BackgroundColor3 = accent
	SubmitButton.BorderSizePixel = 0
	SubmitButton.Size = UDim2.new(1, 0, 0, 46)
	SubmitButton.Font = Enum.Font.GothamBold
	SubmitButton.Text = "Submit"
	SubmitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	SubmitButton.TextSize = 15
	SubmitButton.AutoButtonColor = false
	SubmitButton.LayoutOrder = 3
	SubmitButton.ZIndex = 102
	SubmitButton.Parent = Body

	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 10)
	submitCorner.Parent = SubmitButton

	-- ---------- secondary buttons ----------
	local SecondaryRow = Instance.new("Frame")
	SecondaryRow.Name = "SecondaryRow"
	SecondaryRow.BackgroundTransparency = 1
	SecondaryRow.Size = UDim2.new(1, 0, 0, 42)
	SecondaryRow.LayoutOrder = 4
	SecondaryRow.ZIndex = 102
	SecondaryRow.Parent = Body

	local secondaryLayout = Instance.new("UIListLayout")
	secondaryLayout.FillDirection = Enum.FillDirection.Horizontal
	secondaryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	secondaryLayout.Padding = UDim.new(0, 10)
	secondaryLayout.Parent = SecondaryRow

	local function makeSecondaryButton(name, text, iconName, order)
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

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = btn

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
		innerLayout.Padding = UDim.new(0, 7)
		innerLayout.Parent = inner

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.Size = UDim2.new(0, 15, 0, 15)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.ImageColor3 = Color3.fromRGB(210, 210, 218)
		icon.LayoutOrder = 1
		icon.ZIndex = 104
		applyIcon(icon, parseIcon(iconName))
		icon.Parent = inner

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
			TweenService:Create(icon, TweenInfo.new(0.15), { ImageColor3 = TEXT }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CARD }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = BORDER }):Play()
			TweenService:Create(icon, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(210, 210, 218) }):Play()
		end)

		return btn
	end

	local GetKeyButton = makeSecondaryButton("GetKeyButton", "Get Key", config.GetKeyIcon or "redo", 1)
	local HowToButton = makeSecondaryButton("HowToButton", "How to get key", config.HowToIcon or "guide_icon", 2)

	-- ---------- divider ----------
	local Divider = Instance.new("Frame")
	Divider.Name = "Divider"
	Divider.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	Divider.BorderSizePixel = 0
	Divider.Size = UDim2.new(1, 0, 0, 1)
	Divider.LayoutOrder = 5
	Divider.ZIndex = 102
	Divider.Parent = Body

	-- ---------- social links ----------
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
	socialLayout.Padding = UDim.new(0, 28)
	socialLayout.Parent = SocialRow

	local function makeSocial(name, labelText, url, brandColor, iconName, order)
		local column = Instance.new("Frame")
		column.Name = name .. "Column"
		column.BackgroundTransparency = 1
		column.Size = UDim2.new(0, 70, 0, 0)
		column.AutomaticSize = Enum.AutomaticSize.Y
		column.LayoutOrder = order
		column.ZIndex = 102
		column.Parent = SocialRow

		local columnLayout = Instance.new("UIListLayout")
		columnLayout.FillDirection = Enum.FillDirection.Vertical
		columnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		columnLayout.SortOrder = Enum.SortOrder.LayoutOrder
		columnLayout.Padding = UDim.new(0, 6)
		columnLayout.Parent = column

		local btn = Instance.new("TextButton")
		btn.Name = name .. "Button"
		btn.BackgroundColor3 = CARD
		btn.BorderSizePixel = 0
		btn.Size = UDim2.new(0, 46, 0, 46)
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.LayoutOrder = 1
		btn.ZIndex = 102
		btn.Parent = column

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = BORDER
		stroke.Thickness = 1.2
		stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		stroke.Parent = btn

		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.BackgroundTransparency = 1
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.Size = UDim2.new(0, 24, 0, 24)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.ImageColor3 = brandColor
		icon.ZIndex = 103
		applyIcon(icon, parseIcon(iconName))
		icon.Parent = btn

		local caption = Instance.new("TextLabel")
		caption.Name = "Caption"
		caption.BackgroundTransparency = 1
		caption.Size = UDim2.new(1, 0, 0, 14)
		caption.Font = Enum.Font.Gotham
		caption.Text = labelText
		caption.TextSize = 11
		caption.TextColor3 = TEXT_DIM
		caption.LayoutOrder = 2
		caption.ZIndex = 103
		caption.Parent = column

		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CARD_HOVER }):Play()
			TweenService:Create(stroke, TweenInfo.new(0.15), { Color = brandColor }):Play()
			TweenService:Create(caption, TweenInfo.new(0.15), { TextColor3 = brandColor }):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), { BackgroundColor3 = CARD }):Play()
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
			notify("good", labelText, "Link copied: " .. url)
		end)

		return btn
	end

	makeSocial("Discord", "Discord", config.Discord, DISCORD_COLOR, config.DiscordIcon or "Discord", 1)
	makeSocial("YouTube", "YouTube", config.YouTube, YOUTUBE_COLOR, config.YouTubeIcon or "Youtube", 2)

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
		notify("good", label, "Link copied: " .. url)
	end

	local function shake()
		local origin = Window.Position
		task.spawn(function()
			for i = 1, 4 do
				local offset = (i % 2 == 0) and 10 or -10
				TweenService:Create(Window, TweenInfo.new(0.05), { Position = UDim2.new(origin.X.Scale, origin.X.Offset + offset, origin.Y.Scale, origin.Y.Offset) }):Play()
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
			shake()
			return
		end

		busy = true
		SubmitButton.Text = "Checking..."
		TweenService:Create(SubmitButton, TweenInfo.new(0.15), { BackgroundTransparency = 0.35 }):Play()
		setStatus("checking", "Checking key...")

		task.spawn(function()
			local ok, result = true, false
			if type(checkFn) == "function" then
				ok, result = pcall(checkFn, key)
			else
				result = true
			end
			task.wait(0.25)

			busy = false
			SubmitButton.Text = "Submit"
			TweenService:Create(SubmitButton, TweenInfo.new(0.15), { BackgroundTransparency = 0 }):Play()

			if ok and result then
				unlocked = true
				setStatus("valid", "Key accepted. Loading...")
				notify("good", "Success", "Key accepted.")
				SubmitButton.Text = "Unlocked"
				SubmitButton.BackgroundColor3 = GOOD
				if config.OnSuccess then pcall(config.OnSuccess, key) end
				task.wait(0.7)
				Window.Visible = false
			else
				setStatus("invalid", "Invalid key, try again.")
				notify("bad", "Invalid Key", "That key is not valid.")
				shake()
				if config.OnFail then pcall(config.OnFail, key) end
			end
		end)
	end

	SubmitButton.MouseButton1Click:Connect(submit)

	KeyInput.FocusLost:Connect(function(enterPressed)
		if enterPressed then submit() end
	end)

	KeyInput.Focused:Connect(function()
		TweenService:Create(inputStroke, TweenInfo.new(0.15), { Color = accent }):Play()
	end)
	KeyInput.FocusLost:Connect(function()
		TweenService:Create(inputStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(52, 52, 60) }):Play()
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
		TweenService:Create(PasteIcon, TweenInfo.new(0.15), { ImageColor3 = TEXT }):Play()
	end)
	PasteButton.MouseLeave:Connect(function()
		TweenService:Create(PasteButton, TweenInfo.new(0.15), { BackgroundColor3 = CARD }):Play()
		TweenService:Create(pasteStroke, TweenInfo.new(0.15), { Color = BORDER }):Play()
		TweenService:Create(PasteIcon, TweenInfo.new(0.15), { ImageColor3 = Color3.fromRGB(200, 200, 208) }):Play()
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
	function Controller:SetAccent(color)
		if typeof(color) ~= "Color3" then return Controller end
		accent = color
		SubmitButton.BackgroundColor3 = color
		logoStroke.Color = color
		LogoIcon.ImageColor3 = color
		return Controller
	end

	return Controller
end

return KeySystem
