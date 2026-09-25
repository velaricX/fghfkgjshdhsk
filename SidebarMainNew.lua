-- Client Script (Place in StarterPlayerScripts or StarterGui)
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
while not LocalPlayer do
	task.wait()
	LocalPlayer = Players.LocalPlayer
end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Dynamic Device Detection
local IsMobile = false
-- Emulator / cloud phone: touch but no accelerometer (phones have one, PCs/laptops don't have touch)
local IsEmulator = false
local Camera = workspace.CurrentCamera or workspace:WaitForChild("Camera")
if UserInputService.TouchEnabled and (not UserInputService.KeyboardEnabled or Camera.ViewportSize.X < 900) then
	IsMobile = true
end
pcall(function()
	if UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled and not UserInputService.AccelerometerEnabled then
		IsEmulator = true
	end
end)

-- Mobile text scaler: call mTS(label, normalSize) to auto-shrink on mobile
local function mTS(label, normalSize)
	if IsMobile then
		label.TextSize = math.max(8, normalSize - 2)
	else
		label.TextSize = normalSize
	end
end

-- Define the Astral Library
local Astral = {}
Astral.Registry = {} -- Global registry to track all toggle/tick controllers for easy resetting

-- =========================================================================
-- LANGUAGE / TRANSLATION SYSTEM
-- Titles registered with tr() swap instantly via Astral:SetLanguage().
-- Add your own: Astral:AddTranslations("Italiano", { ["Settings"] = "Impostazioni" })
-- =========================================================================
Astral.Languages = { English = {} }
Astral.CurrentLanguage = "English"
local translatableLabels = {}
local languageRefreshers = {} -- fn() list re-run on SetLanguage (dynamic texts)

local function translateText(key)
	local lang = Astral.Languages[Astral.CurrentLanguage]
	if lang and lang[key] ~= nil then
		return lang[key]
	end
	return key
end

-- GET with fallbacks: some executors block game:HttpGet for certain hosts,
-- so try the executor request functions and HttpService before giving up.
local function webGet(url)
	local ok, res = pcall(function() return game:HttpGet(url) end)
	if ok and type(res) == "string" and res ~= "" then return res end
	local req = (typeof(request) == "function" and request)
		or (typeof(http_request) == "function" and http_request)
		or (syn and type(syn.request) == "function" and syn.request)
		or nil
	if req then
		local ok2, r = pcall(function() return req({Url = url, Method = "GET"}) end)
		if ok2 then
			if type(r) == "table" then
				local body = r.Body or r.body
				if type(body) == "string" and body ~= "" then return body end
			elseif type(r) == "string" and r ~= "" then
				return r
			end
		end
	end
	local ok3, res3 = pcall(function() return HttpService:GetAsync(url) end)
	if ok3 and type(res3) == "string" and res3 ~= "" then return res3 end
	return nil
end

function Astral:AddTranslations(langName, dict)
	if type(langName) ~= "string" or type(dict) ~= "table" then return end
	Astral.Languages[langName] = Astral.Languages[langName] or {}
	for k, v in pairs(dict) do
		Astral.Languages[langName][k] = v
	end
	if Astral.CurrentLanguage == langName then
		Astral:SetLanguage(langName)
	end
end

function Astral:SetLanguage(langName)
	if not Astral.Languages[langName] then return end
	Astral.CurrentLanguage = langName
	for _, item in ipairs(translatableLabels) do
		pcall(function()
			if item.Label and item.Label.Parent then
				item.Label[item.Prop or "Text"] = translateText(item.Key)
			end
		end)
	end
	for _, fn in ipairs(languageRefreshers) do
		pcall(fn)
	end
	pcall(function()
		if Astral._OpenSelectorRefresh then Astral._OpenSelectorRefresh() end
	end)
end

-- Register a label's English text for live translation.
-- Optional prop lets inputs translate other string props too:
-- tr(SearchInput, "Search...", "PlaceholderText")
local function tr(label, englishText, prop)
	table.insert(translatableLabels, {Label = label, Key = englishText, Prop = prop})
	label[prop or "Text"] = translateText(englishText)
	return label
end


-- Starter language packs (titles swap live; add your own words anytime)
Astral:AddTranslations("Español", {
	["Settings"] = "Ajustes",
	["Tests"] = "Pruebas",
	["Farming"] = "Farmeo",
	["Combat"] = "Combate",
	["Dungeons"] = "Mazmorras",
	["Islands"] = "Islas",
	["Players"] = "Jugadores",
	["ESP"] = "ESP",
	["Shop"] = "Tienda",
	["Layout Columns"] = "Columnas",
	["Accent Theme"] = "Tema de acento",
	["Background Image"] = "Imagen de fondo",
	["Load Background"] = "Cargar fondo",
	["Reset Background"] = "Restablecer fondo",
	["Spam Notifications"] = "Notificaciones spam",
	["Spam With Actions"] = "Spam con acciones",
	["Menu Keybind"] = "Tecla de menú",
	["Status Label"] = "Etiqueta de estado",
	["Select..."] = "Seleccionar...",
	["None"] = "Ninguno",
	["Search..."] = "Buscar...",
	["Select Option"] = "Seleccionar opción",
	["(+%d more)"] = "(+%d más)",
})
Astral:AddTranslations("Français", {
	["Settings"] = "Paramètres",
	["Tests"] = "Tests",
	["Farming"] = "Farm",
	["Combat"] = "Combat",
	["Dungeons"] = "Donjons",
	["Islands"] = "Îles",
	["Players"] = "Joueurs",
	["ESP"] = "ESP",
	["Shop"] = "Boutique",
	["Layout Columns"] = "Colonnes",
	["Accent Theme"] = "Couleur d'accent",
	["Background Image"] = "Image de fond",
	["Load Background"] = "Charger le fond",
	["Reset Background"] = "Réinitialiser le fond",
	["Spam Notifications"] = "Notifications spam",
	["Spam With Actions"] = "Spam avec actions",
	["Menu Keybind"] = "Touche du menu",
	["Status Label"] = "Étiquette de statut",
	["Select..."] = "Sélectionner...",
	["None"] = "Aucun",
	["Search..."] = "Rechercher...",
	["Select Option"] = "Choisir une option",
	["(+%d more)"] = "(+%d autres)",
})
Astral:AddTranslations("Deutsch", {
	["Settings"] = "Einstellungen",
	["Tests"] = "Tests",
	["Farming"] = "Farmen",
	["Combat"] = "Kampf",
	["Dungeons"] = "Dungeons",
	["Islands"] = "Inseln",
	["Players"] = "Spieler",
	["ESP"] = "ESP",
	["Shop"] = "Shop",
	["Layout Columns"] = "Spalten",
	["Accent Theme"] = "Akzentfarbe",
	["Background Image"] = "Hintergrundbild",
	["Load Background"] = "Hintergrund laden",
	["Reset Background"] = "Hintergrund zurücksetzen",
	["Spam Notifications"] = "Spam-Benachrichtigungen",
	["Spam With Actions"] = "Spam mit Aktionen",
	["Menu Keybind"] = "Menütaste",
	["Status Label"] = "Statusanzeige",
	["Select..."] = "Auswählen...",
	["None"] = "Keine",
	["Search..."] = "Suchen...",
	["Select Option"] = "Option wählen",
	["(+%d more)"] = "(+%d weitere)",
})


-- Comprehensive Icon Dictionary
Astral.Icons = {
	Heart = "rbxassetid://10747374161", -- Globe/Home
	Item2 = "rbxassetid://83885110042385",
	Item3 = "rbxassetid://121905143697738",
	Item1 = "rbxassetid://122773160656447",
	SecondRewardIcon = "rbxassetid://80697366195466",
	Icon1 = "rbxassetid://106987676739927", -- Updated to requested custom logo ID
	Icon2 = "rbxassetid://116815022926368",
	CornerIcon = "rbxassetid://79361588247465",
	Icon3 = "rbxassetid://82358876994773",
	Sharingan1 = "rbxassetid://94044166423780",
	Image1 = "rbxassetid://119695090236661",
	Checkmark = "rbxassetid://12690727184", -- Updated to requested high-contrast checkmark ID
	Image2 = "rbxassetid://122758809551453",
	Close = "rbxassetid://9545003266",
	ImageLabel1 = "rbxassetid://102323672270607",
	ImageLabel2 = "rbxassetid://95040139882837",
	Icon4 = "rbxassetid://85596845927296",
	Icon5 = "rbxassetid://82328117903546",
	Icon6 = "rbxassetid://135148380892747",
	Icon7 = "rbxassetid://5642383285",
	CheckMark2 = "rbxassetid://72382658",
	QuestionMark = "rbxassetid://11961524728",
	htobar = "rbxassetid://75920759124629",
	timer = "rbxassetid://85881110920588",
	Left = "rbxassetid://96304569438872",
	Right = "rbxassetid://86166619745789",
	clock = "rbxassetid://85874026506238",
	lock = "rbxassetid://9191129676",
	Warning = "rbxassetid://7020209324",
	limit_timer = "rbxassetid://103916574484749",
	setting_ImageLabel = "rbxassetid://91616785719644",
	steering = "rbxassetid://110862082646630",
	loop_ImageLabel = "rbxassetid://82533346971856",
	hotbar_MenuButton = "rbxassetid://15481302234",
	menu_ImageLabel = "rbxassetid://107573955108045",
	ArrowOnly1 = "rbxassetid://2418686949",
	bookImageLabel = "rbxassetid://17583283314",
	chest = "rbxassetid://122154715897842",
	dungeonIcon = "rbxassetid://116834446841692",
	search = "rbxassetid://127006564692803",
	fishing = "rbxassetid://120325871278964",
	brush = "rbxassetid://138999635884744",
	wood = "rbxassetid://17218778623",
	fragment_chest = "rbxassetid://112630312321366",
	guide_icon = "rbxassetid://80151381605349",
	map_background = "rbxassetid://91526381633533",
	up_arrow = "rbxassetid://124289284437143",
	red_key = "rbxassetid://17284014170",
	white_key = "rbxassetid://17284010749",
	yellow_key = "rbxassetid://17284012231",
	green_key = "rbxassetid://17284010015",
	blue_key = "rbxassetid://17284013433",
	eye = "rbxassetid://94513760125394",
	CrewLabel = "rbxassetid://15432293683",
	star = "rbxassetid://9117240799",
	CoinImage = "rbxassetid://119281955127934",
	GemImage = "rbxassetid://107516022193931",
	down_arrow = "rbxassetid://104073699674984",
	redo = "rbxassetid://112477956812302",
	dungeonPlaceholder = "rbxassetid://120906706443458",
	clickImageLabel = "rbxassetid://7553620727",
	right_arrow = "rbxassetid://121627513213989",
	tick = "rbxassetid://12690727184",
	InletTexture = "rbxassetid://103642499084798",
	expand = "rbxassetid://112339867431014",
	WheelFrame = "rbxassetid://79705976294216",
	ARROW_down_IMAGE = "rbxassetid://103256317191387",
	big_arrow_down = "rbxassetid://119090403860693",
	left_arrow = "rbxassetid://16734567969",
	arrow_down_button = "rbxassetid://79129710719196",
	bag_of_gold = "rbxassetid://75914651028344",
	chest_of_coin = "rbxassetid://78240658157818",
	EggBasket = "rbxassetid://97411136647622",
	egg_blue_pink = "rbxassetid://77129460699853",
	egg_yellow_skyblue = "rbxassetid://95450973493720",
	purple_blue_egg = "rbxassetid://90597623492830",
	keyboard = "rbxassetid://11385220720",
	rain = "rbxassetid://105238830795121",
	volcano = "rbxassetid://119080201393061",
	meteor = "rbxassetid://71134947880058",
	x_ImageLabel = "rbxassetid://14219436180",
	quest = "rbxassetid://18838050505",
	MarkImage = "rbxassetid://18838050505",
	Money = "rbxassetid://86689630920385",
	candy = "rbxassetid://96106029532916",
	EXP = "rbxassetid://116312601353770",
	fish = "rbxassetid://106871355874368",
	click_icon = "rbxassetid://9468220156",
	shopping = "rbxassetid://11699823846"
}

-- Helper function to parse icons safely (strings AND sprite tables pass through)
local function parseIcon(iconInput)
	if not iconInput then return nil end
	if type(iconInput) == "table" then
		return iconInput
	end
	if type(iconInput) == "string" then
		if Astral.Icons[iconInput] then
			return Astral.Icons[iconInput]
		elseif string.match(iconInput, "^%d+$") then
			return "rbxassetid://" .. iconInput
		elseif string.sub(iconInput, 1, 13) == "rbxassetid://" or string.sub(iconInput, 1, 4) == "http" then
			return iconInput
		end
	elseif type(iconInput) == "number" then
		return "rbxassetid://" .. tostring(iconInput)
	end
	return nil
end

-- Icon module hookup: merge an external table (icons_sprites.lua).
-- Built-ins above keep working standalone; registered sprites override/add.
function Astral:RegisterIcons(dict)
	if type(dict) ~= "table" then return end
	for k, v in pairs(dict) do Astral.Icons[k] = v end
end

-- Applies a plain asset string OR a sprite table {Image, ImageRectOffset, ImageRectSize}
function Astral.ApplyIcon(label, icon)
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

-- High-Performance, Lag-Free Dragging Utility
local function makeElementDraggable(guiObject, dragHandle)
	dragHandle = dragHandle or guiObject
	local dragging = false
	local dragInput, dragStart, startPos

	local function update(input)
		local delta = input.Position - dragStart
		guiObject.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end

	dragHandle.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			-- yield if the Game Status panel grabbed this same press (it sits above)
			local okS, sT = pcall(function() return guiObject:GetAttribute("StatusDragT") end)
			if okS and sT and os.clock() - sT < 0.3 then return end
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position
			pcall(function() guiObject:SetAttribute("MainDragT", os.clock()) end)

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	dragHandle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			-- abort mid-press if the status panel grabbed after us
			local okS, sT = pcall(function() return guiObject:GetAttribute("StatusDragT") end)
			local okM, mT = pcall(function() return guiObject:GetAttribute("MainDragT") end)
			if okS and okM and sT and mT and sT > mT then dragging = false; return end
			update(input)
		end
	end)
end

-- Helper to register clean clicks on draggable buttons
-- Touch gets a bigger drag allowance so scrolling never misfires as taps
local function registerClick(button, callback)
	local startPos
	local startType
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			startPos = UserInputService:GetMouseLocation()
			startType = input.UserInputType
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			if startPos then
				local endPos = UserInputService:GetMouseLocation()
				local slop = (startType == Enum.UserInputType.Touch) and 24 or 8
				if (endPos - startPos).Magnitude < slop then
					callback()
				end
			end
			startPos = nil
		end
	end)
end

-- Helper to calculate relative position inside a GUI element
local function getRelativePosition(guiObject, input)
	local absPos = guiObject.AbsolutePosition
	local absSize = guiObject.AbsoluteSize
	local inputPos = input.Position
	local relX = (inputPos.X - absPos.X) / absSize.X
	local relY = (inputPos.Y - absPos.Y) / absSize.Y
	return math.clamp(relX, 0, 1), math.clamp(relY, 0, 1)
end

-- ============================================================================
-- ============================================================================
-- THEMES: Dark (default build) / Light / Midnight.
-- Window:SetTheme(name) recolors every surface + text by value.
-- Anything currently bound to the accent color is left untouched.
-- Index: 1 = Light, 2 = Midnight (0 = Dark = the source keys themselves).
-- ============================================================================
local THEME_SWAP = {
	["100,100,105"] = { "118,130,163", "150,140,175", "165,145,145", "145,165,145", "140,165,180", "170,155,140", "170,150,165", "150,160,185", "165,150,130" },
	["110,110,118"] = { "118,130,163", "150,140,175", "165,145,145", "145,165,145", "140,165,180", "170,155,140", "170,150,165", "150,160,185", "165,150,130" },
	["12,12,14"] = { "5,7,15", "14,8,22", "18,8,10", "7,17,9", "6,15,19", "19,12,6", "19,8,15", "11,13,19", "15,11,7" },
	["120,120,125"] = { "118,130,163", "150,140,175", "165,145,145", "145,165,145", "140,165,180", "170,155,140", "170,150,165", "150,160,185", "165,150,130" },
	["15,15,15"] = { "8,11,20", "16,10,26", "20,9,10", "8,19,9", "7,17,21", "21,14,7", "22,9,17", "13,15,22", "17,12,8" },
	["150,150,158"] = { "146,158,188", "180,170,205", "205,175,175", "175,205,175", "170,200,210", "210,190,170", "210,180,200", "180,190,210", "205,185,165" },
	["16,16,18"] = { "8,11,21", "18,11,28", "27,13,15", "12,26,13", "10,25,29", "29,20,11", "29,13,22", "22,25,35", "24,18,12" },
	["160,160,165"] = { "146,158,188", "180,170,205", "205,175,175", "175,205,175", "170,200,210", "210,190,170", "210,180,200", "180,190,210", "205,185,165" },
	["162,162,172"] = { "146,158,188", "180,170,205", "205,175,175", "175,205,175", "170,200,210", "210,190,170", "210,180,200", "180,190,210", "205,185,165" },
	["165,165,176"] = { "146,158,188", "180,170,205", "205,175,175", "175,205,175", "170,200,210", "210,190,170", "210,180,200", "180,190,210", "205,185,165" },
	["170,170,178"] = { "158,170,200", "190,180,215", "215,185,185", "185,215,185", "180,210,220", "220,200,180", "220,190,210", "190,200,220", "215,195,175" },
	["175,175,182"] = { "146,158,188", "180,170,205", "205,175,175", "175,205,175", "170,200,210", "210,190,170", "210,180,200", "180,190,210", "205,185,165" },
	["18,18,22"] = { "9,12,23", "17,11,27", "25,12,14", "10,24,12", "9,23,27", "27,18,10", "27,12,20", "20,23,32", "22,16,11" },
	["180,180,185"] = { "148,160,190", "185,175,210", "210,180,180", "180,210,180", "175,205,215", "215,195,175", "215,185,205", "185,195,215", "210,190,170" },
	["20,20,24"] = { "11,15,27", "20,13,32", "29,14,16", "13,28,14", "11,27,31", "31,22,12", "31,15,24", "24,27,38", "26,19,13" },
	["22,22,26"] = { "13,18,32", "23,15,37", "32,16,18", "15,31,16", "13,30,34", "34,24,14", "34,17,27", "27,30,42", "29,21,15" },
	["255,255,255"] = { "231,237,255", "245,235,255", "255,242,242", "242,255,242", "236,250,255", "255,246,236", "255,242,250", "242,246,254", "253,246,237" },
	["26,26,30"] = { "12,16,29", "22,14,34", "32,15,17", "13,30,15", "11,29,33", "34,23,12", "34,15,25", "25,29,39", "28,20,14" },
	["28,28,34"] = { "19,25,43", "32,20,50", "44,21,23", "19,43,21", "17,41,45", "46,31,17", "48,21,35", "37,43,57", "40,29,20" },
	["30,30,36"] = { "19,25,43", "32,20,50", "44,21,23", "19,43,21", "17,41,45", "46,31,17", "48,21,35", "37,43,57", "40,29,20" },
	["32,32,36"] = { "17,23,39", "30,19,46", "42,20,22", "18,40,20", "16,39,43", "44,30,16", "46,20,33", "35,41,55", "38,28,19" },
	["35,35,40"] = { "29,39,63", "48,32,74", "68,33,35", "31,68,34", "28,65,71", "74,50,26", "78,35,59", "60,70,86", "64,47,31" },
	["36,36,40"] = { "25,33,55", "40,26,62", "54,27,29", "24,53,26", "22,51,57", "58,39,23", "60,27,45", "47,55,71", "50,37,25" },
	["38,38,44"] = { "28,38,60", "46,32,72", "66,33,35", "30,66,33", "27,63,69", "72,48,26", "76,34,57", "59,68,83", "63,46,31" },
	["45,45,50"] = { "31,43,69", "52,36,80", "72,36,38", "33,72,36", "30,70,76", "78,53,28", "82,37,62", "64,74,90", "68,50,33" },
	["50,50,55"] = { "39,53,83", "64,44,98", "88,44,46", "41,88,44", "37,86,94", "96,65,34", "100,46,76", "80,92,112", "84,62,41" },
	["52,52,60"] = { "36,48,76", "58,40,90", "80,40,42", "37,80,40", "33,77,85", "88,59,32", "92,42,69", "71,82,101", "77,56,38" },
	["54,54,62"] = { "36,48,76", "58,40,90", "80,40,42", "37,80,40", "33,77,85", "88,59,32", "92,42,69", "71,82,101", "77,56,38" },
	["70,70,75"] = { "55,70,105", "85,60,130", "115,58,60", "52,108,56", "46,106,118", "122,82,44", "128,58,96", "99,114,141", "107,78,52" },
	["205,205,214"] = { "148,160,190", "185,175,210", "210,180,180", "180,210,180", "175,205,215", "215,195,175", "215,185,205", "185,195,215", "210,190,170" },
	["70,70,80"] = { "55,70,105", "85,60,130", "115,58,60", "52,108,56", "46,106,118", "122,82,44", "128,58,96", "99,114,141", "107,78,52" },	["33,33,39"] = { "12,16,29", "22,14,34", "32,15,17", "13,30,15", "11,29,33", "34,23,12", "34,15,25", "25,29,39", "28,20,14" },
}
local THEME_INDEX = { Dark = 0, Midnight = 1, Purple = 2, Crimson = 3, Forest = 4, Ocean = 5, Sunset = 6, Rose = 7, Slate = 8, Coffee = 9, Custom = -1 }
local CustomThemeValues = nil -- darkKey -> "r,g,b" string, built by SetCustomTheme
local CurrentThemeName = "Dark"

local function parseThemeRGB(s)
	-- accepts both "r,g,b" strings and raw Color3 values (CustomThemeValues stores Color3)
	if typeof(s) == "Color3" then return s end
	local str = tostring(s or "")
	local r, g, b = string.match(str, "^(%d+),(%d+),(%d+)$")
	return Color3.fromRGB(tonumber(r) or 0, tonumber(g) or 0, tonumber(b) or 0)
end

local function themeKeyOf(c)
	return math.floor(c.R * 255 + 0.5) .. "," .. math.floor(c.G * 255 + 0.5) .. "," .. math.floor(c.B * 255 + 0.5)
end

-- File-scope theme applier (kept out of MakeWindow to respect the 200-local limit).
-- Returns the new theme name on success, nil on failure.
local function applyThemeToGui(screenGui, accentColor, fromName, toName)
	local target = THEME_INDEX[toName]
	if target == nil then return nil end
	local current = THEME_INDEX[fromName] or 0
	if target == current then return toName end

	local function valFor(srcKey, idx)
		if idx == 0 then return parseThemeRGB(srcKey) end
		if idx == -1 then
			if CustomThemeValues and CustomThemeValues[srcKey] then return parseThemeRGB(CustomThemeValues[srcKey]) end
			return parseThemeRGB(srcKey)
		end
		local pair = THEME_SWAP[srcKey]
		if not pair then return nil end
		return parseThemeRGB(pair[idx])
	end

	local remap = {}
	for srcKey in pairs(THEME_SWAP) do
		local oldC = valFor(srcKey, current)
		local newC = valFor(srcKey, target)
		if oldC and newC then remap[themeKeyOf(oldC)] = newC end
	end

	local accentKey = themeKeyOf(accentColor)

	local function swapProp(obj, prop, allowWhite)
		local ok, val = pcall(function() return obj[prop] end)
		if not ok or typeof(val) ~= "Color3" then return end
		local key = themeKeyOf(val)
		if key == accentKey then return end
		if not allowWhite and key == "255,255,255" then return end
		local to = remap[key]
		if to then pcall(function() obj[prop] = to end) end
	end

	for _, d in ipairs(screenGui:GetDescendants()) do
		if d:IsA("GuiObject") then
			swapProp(d, "BackgroundColor3", false)
			if d:IsA("TextLabel") or d:IsA("TextButton") or d:IsA("TextBox") then
				swapProp(d, "TextColor3", true)
				swapProp(d, "PlaceholderColor3", true)
			elseif d:IsA("ImageLabel") or d:IsA("ImageButton") then
				swapProp(d, "ImageColor3", false)
			end
		elseif d:IsA("UIStroke") then
			swapProp(d, "Color", true)
		end
	end

	return toName
end

-- Live hover helpers: evaluated when a hover FIRES, so they always match
-- the current theme. Use these instead of hardcoded dark literals.
local function themeColorFor(darkKey, t)
	if t == "Dark" or not t then return parseThemeRGB(darkKey) end
	local idx = THEME_INDEX[t]
	if idx == -1 then
		if CustomThemeValues and CustomThemeValues[darkKey] then
			return parseThemeRGB(CustomThemeValues[darkKey])
		end
		return parseThemeRGB(darkKey)
	end
	if not idx or idx == 0 then return parseThemeRGB(darkKey) end
	local pair = THEME_SWAP[darkKey]
	if not pair then return parseThemeRGB(darkKey) end
	return parseThemeRGB(pair[idx])
end

local function themeCardBG(t) return themeColorFor("26,26,30", t) end
local function themeHoverBG(t) return themeColorFor("36,36,40", t) end
local function themeStroke(t) return themeColorFor("50,50,55", t) end
local function themeStrokeHover(t) return themeColorFor("70,70,75", t) end

local function getGuiParent()
	-- executors: hidden UI container (CoreGui area); otherwise PlayerGui
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	return PlayerGui
end

local function makeGuiName(base)
	local suffix = ""
	pcall(function() suffix = "_" .. tostring(math.random(100000000, 999999999)) end)
	return base .. suffix
end

local UIPOS_FILE = "lumu_ui_pos.json"

local function saveUIPosFile(name, data)
	if not writefile then return false end
	local ok, json = pcall(function() return game:GetService("HttpService"):JSONEncode(data) end)
	if not ok then return false end
	local okW = pcall(writefile, name or UIPOS_FILE, json)
	return okW
end

local function loadUIPosFile(name)
	if not (readfile and isfile) then return nil end
	local fname = name or UIPOS_FILE
	local okE = false
	pcall(function() okE = isfile(fname) end)
	if not okE then return nil end
	local okR, raw = pcall(readfile, fname)
	if not okR or not raw or raw == "" then return nil end
	local okJ, data = pcall(function() return game:GetService("HttpService"):JSONDecode(raw) end)
	if not okJ or type(data) ~= "table" then return nil end
	return data
end

local function udimToTable(u)
	if typeof(u) ~= "UDim2" and (not u or not u.X) then return nil end
	return { sX = u.X.Scale, oX = u.X.Offset, sY = u.Y.Scale, oY = u.Y.Offset }
end

local function tableToUdim(t)
	if type(t) ~= "table" then return nil end
	return UDim2.new(tonumber(t.sX) or 0, tonumber(t.oX) or 0, tonumber(t.sY) or 0, tonumber(t.oY) or 0)
end

local function clampPanelOnScreen(pos, w, hEst)
	local cam = workspace.CurrentCamera
	if not cam then return pos end
	local vp = cam.ViewportSize
	if not vp or vp.X < 10 then return pos end
	local x = pos.X.Offset
	local y = pos.Y.Offset
	x = math.clamp(x, 8, math.max(8, vp.X - (w or 280) - 8))
	y = math.clamp(y, 8, math.max(8, vp.Y - (hEst or 220) - 8))
	return UDim2.new(pos.X.Scale, x, pos.Y.Scale, y)
end
local LUMU_RAW = "https://raw.githubusercontent.com/velaricX/fghfkgjshdhsk/main/"
local DESIGN_URLS = {
		TopBar = LUMU_RAW .. "TopbarMainNew.lua",
		Sidebar = LUMU_RAW .. "SidebarMainNew.lua",
}
local DESIGN_FILE = "lumu_design.json"
local function readDesignPref()
	if not (readfile and isfile) then return nil end
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

local function writeDesignPref(design)
	if not writefile then return false end
	local ok = pcall(function()
		writefile(DESIGN_FILE, game:GetService("HttpService"):JSONEncode({ design = design }))
	end)
	return ok
end

function Astral.GetSavedDesign()
	return readDesignPref()
end

function Astral.SetSavedDesign(design)
	if design ~= "Sidebar" and design ~= "TopBar" then return false end
	return writeDesignPref(design)
end

Astral._DesignCache = {}

function Astral:MakeWindow(config)
	config = config or {}
	-- Accent engine FIRST: panels and elements below hook into it during build
	local AccentColor = Color3.fromRGB(0, 153, 235)
	local accentAppliers = {}
	local function onAccentChange(fn)
		table.insert(accentAppliers, fn)
		pcall(fn, AccentColor)
	end

	local titleText = config.Title or "Astral"
	local subTitleText = config.SubTitle or "Hub"
	local badgeText = config.badge or "PREMIUM"
	
	-- Parse Badge Color
	local badgeColor = Color3.fromRGB(30, 110, 230)
	if config.badgecolor then
		if type(config.badgecolor) == "string" then
			if config.badgecolor:lower() == "blue" then
				badgeColor = Color3.fromRGB(30, 110, 230)
			elseif config.badgecolor:lower() == "red" then
				badgeColor = Color3.fromRGB(230, 50, 50)
			elseif config.badgecolor:lower() == "green" then
				badgeColor = Color3.fromRGB(50, 230, 50)
			end
		elseif typeof(config.badgecolor) == "Color3" then
			badgeColor = config.badgecolor
		end
	end

	-- Kill orphaned LumuHub GUIs first (re-execute / design-switch leftovers).
	-- gethui() is invisible to normal wipe code, so without this the old
	-- GameStatus panel stays alive UNDER the new one and its gray edges
	-- stick out at the corners.
	pcall(function()
		local parent = getGuiParent()
		if parent then
			for _, g in ipairs(parent:GetChildren()) do
				if g:IsA("ScreenGui") and g.Name:match("^LumuHubMain") then
					pcall(function() g:Destroy() end)
				end
			end
		end
	end)

	-- Create ScreenGui
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = makeGuiName("LumuHubMain")
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = getGuiParent()

	-- Notification Container (Bottom-Right of Screen, copied from main UI)
	local notifW = config.NotifySize or (IsMobile
		and math.min(170, math.floor((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 760) * 0.42))
		or math.min(258, math.floor((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 760) * 0.28)))

	local NotificationContainer = Instance.new("Frame")
	NotificationContainer.Name = "NotificationContainer"
	NotificationContainer.Size = UDim2.new(0, notifW + 20, 0, 0)
	NotificationContainer.Position = UDim2.new(1, -12, 1, -12)
	NotificationContainer.AnchorPoint = Vector2.new(1, 1)
	NotificationContainer.BackgroundTransparency = 1
	NotificationContainer.ZIndex = 200
	NotificationContainer.Parent = ScreenGui

	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.Padding = UDim.new(0, 8)
	NotifLayout.Parent = NotificationContainer

	-- Main Frame (Responsive Sizing for Mobile & PC)
	local MainFrame = Instance.new("Frame")
	local statusPanels = {}
	local defaultMainPos = UDim2.new(0.5, 15, 0.5, -4)
	local defaultLogoPos = nil
	MainFrame.Name = "MainFrame"
	MainFrame.Active = true
	MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true -- Fixes corner clipping perfectly
	
	-- Fixed sizes: big on PC (880x600), 550x400 on mobile. Never scaled down,
	-- only clamped to the viewport so nothing clips. Text stays full-size = readable.
	local refW, refH = 880, 600
	if IsMobile then refW, refH = 480, 360 end
	if IsEmulator then refW, refH = 440, 340 end -- emulator/cloud phone: bit smaller than mobile
	if config.Size then
		refW, refH = config.Size.X.Offset, config.Size.Y.Offset
	end
	-- Compact text for narrow windows: titles/descs shrink 1px so full names fit
	local compactTexts = {}
	local function regText(label, normalSize)
		table.insert(compactTexts, {Label = label, Base = normalSize})
		label.TextSize = normalSize
	end
	local function applyTextSize()
		local w = MainFrame.AbsoluteSize.X
		local compact = false -- full-size text everywhere (shrinking hurt readability)
		for _, item in ipairs(compactTexts) do
			pcall(function()
				if item.Label and item.Label.Parent then
					item.Label.TextSize = compact and math.max(8, item.Base - 1) or item.Base
				end
			end)
		end
	end
	local function updateWindowSize()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local vps = cam.ViewportSize
		if vps.X < 10 or vps.Y < 10 then return end
		local w = math.min(refW, vps.X - 16)
		local h = math.min(refH, vps.Y - 16)
		if w < 200 or h < 140 then return end
		MainFrame.Size = UDim2.new(0, w, 0, h)
		MainFrame.Position = UDim2.new(0.5, 15, 0.5, -4)
		applyTextSize()
	end
	MainFrame.Size = UDim2.new(0, refW, 0, refH)
	MainFrame.Position = UDim2.new(0.5, 15, 0.5, -4)
	MainFrame.Parent = ScreenGui
	task.spawn(function()
		local cam = workspace.CurrentCamera
		if cam then updateWindowSize(); cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowSize)
		else local conn; conn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function() cam=workspace.CurrentCamera; if cam then conn:Disconnect(); updateWindowSize(); cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowSize) end end) end
	end)

	-- Background Image (like other UI) - supports paste link or file astral_bg.jpg
	local BackgroundImage = Instance.new("ImageLabel")
	BackgroundImage.Name = "BackgroundImage"
	BackgroundImage.Size = UDim2.fromScale(1, 1)
	BackgroundImage.Position = UDim2.fromScale(0, 0)
	BackgroundImage.BackgroundTransparency = 1
	BackgroundImage.Image = config.BackgroundImage or ""
	BackgroundImage.ScaleType = Enum.ScaleType.Crop
	BackgroundImage.ImageColor3 = Color3.fromRGB(58, 58, 64)
	BackgroundImage.ZIndex = 0
	BackgroundImage.Parent = MainFrame
	-- no default background: nothing is applied unless you call Window:SetBackground(...) yourself
	local function GetIconOnWeb(url)
		if not url or url == "" then return url end
		local ext = url:match("%.(%w+)$") or "png"
		ext = ext:lower()
		local safe = url:gsub("https?://",""):gsub("[^%w%-_%.]","_")
		local file = safe .. "." .. ext
		if isfile and isfile(file) and getcustomasset then
			local ok, asset = pcall(getcustomasset, file)
			if ok and asset ~= "" then return asset end
		end
		local data=nil
		pcall(function()
			if syn and syn.request then local r=syn.request({Url=url,Method="GET"}); if r.StatusCode==200 then data=r.Body end
			elseif http_request then local r=http_request({Url=url,Method="GET"}); if r.StatusCode==200 then data=r.Body end
			else data=game:HttpGet(url) end
		end)
		if data and #data>0 and writefile then pcall(function() writefile(file,data) end); if isfile(file) and getcustomasset then local ok,a=pcall(getcustomasset,file); if ok and a~="" then return a end end end
		return url
	end
	-- expose for Window API
	local bgFunc = GetIconOnWeb

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = MainFrame
	local BgCorner = Instance.new("UICorner")
	BgCorner.CornerRadius = UDim.new(0, 10)
	BgCorner.Parent = BackgroundImage

	-- Dim overlay so text stays readable over bright photos (image still shows through)
	local BgDim = Instance.new("Frame")
	BgDim.Name = "BackgroundDim"
	BgDim.Size = UDim2.fromScale(1, 1)
	BgDim.Position = UDim2.fromScale(0, 0)
	BgDim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	BgDim.BackgroundTransparency = tonumber(config.BackgroundDim) or 0.35
	BgDim.BorderSizePixel = 0
	BgDim.ZIndex = 1
	BgDim.Parent = MainFrame

	local BgDimCorner = Instance.new("UICorner")
	BgDimCorner.CornerRadius = UDim.new(0, 10)
	BgDimCorner.Parent = BgDim

	local UIStroke = Instance.new("UIStroke")
	UIStroke.Color = Color3.fromRGB(32, 32, 36)
	UIStroke.Thickness = 1.5
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.Parent = MainFrame

	-- TopBar Frame
	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.BackgroundTransparency = 1
	TopBar.BorderSizePixel = 0
	TopBar.Position = UDim2.new(0, 0, 0, 0)
	TopBar.Size = UDim2.new(1, 0, 0, 50)
	TopBar.Parent = MainFrame



	-- Horizontal Layout for TopBar Elements
	local HeaderLayoutContainer = Instance.new("Frame")
	HeaderLayoutContainer.Name = "HeaderLayoutContainer"
	HeaderLayoutContainer.BackgroundTransparency = 1
	HeaderLayoutContainer.AnchorPoint = Vector2.new(0, 0.5)
	HeaderLayoutContainer.Position = UDim2.new(0, 12, 0.5, 0)
	HeaderLayoutContainer.Size = UDim2.new(1, -24, 0, 36)
	HeaderLayoutContainer.Parent = TopBar

	local HeaderListLayout = Instance.new("UIListLayout")
	HeaderListLayout.FillDirection = Enum.FillDirection.Horizontal
	HeaderListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	HeaderListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	HeaderListLayout.Padding = UDim.new(0, 10)
	HeaderListLayout.Parent = HeaderLayoutContainer

	-- Title Label (FIXED: Added TextWrapped = false to prevent layout wrapping bugs)
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Size = UDim2.new(0, 0, 1, 0)
	TitleLabel.AutomaticSize = Enum.AutomaticSize.X
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.RichText = true
	TitleLabel.Text = titleText .. ' <font color="#1E6EE6">' .. subTitleText .. '</font>'
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 18
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextYAlignment = Enum.TextYAlignment.Center
	TitleLabel.TextWrapped = false
	TitleLabel.LayoutOrder = 1
	TitleLabel.Parent = HeaderLayoutContainer

	-- Premium Badge
	local PremiumBadge = Instance.new("Frame")
	PremiumBadge.Name = "PremiumBadge"
	PremiumBadge.BackgroundColor3 = badgeColor
	PremiumBadge.BorderSizePixel = 0
	PremiumBadge.Size = UDim2.new(0, 0, 0, 20)
	PremiumBadge.AutomaticSize = Enum.AutomaticSize.X
	PremiumBadge.LayoutOrder = 2
	PremiumBadge.Parent = HeaderLayoutContainer

	local PremiumCorner = Instance.new("UICorner")
	PremiumCorner.CornerRadius = UDim.new(0, 5)
	PremiumCorner.Parent = PremiumBadge

	local PremiumPadding = Instance.new("UIPadding")
	PremiumPadding.PaddingLeft = UDim.new(0, 8)
	PremiumPadding.PaddingRight = UDim.new(0, 8)
	PremiumPadding.Parent = PremiumBadge

	local PremiumLabel = Instance.new("TextLabel")
	PremiumLabel.Name = "PremiumLabel"
	PremiumLabel.BackgroundTransparency = 1
	PremiumLabel.Size = UDim2.new(1, 0, 1, 0)
	PremiumLabel.Font = Enum.Font.GothamBold
	PremiumLabel.Text = tostring(badgeText):upper()
		PremiumLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	PremiumLabel.TextSize = 9
	PremiumLabel.TextXAlignment = Enum.TextXAlignment.Center
	PremiumLabel.TextYAlignment = Enum.TextYAlignment.Center
	PremiumLabel.Parent = PremiumBadge

	-- Badge follows the accent color unless an explicit badgecolor was given
	if not config.badgecolor then
		onAccentChange(function(c)
			PremiumBadge.BackgroundColor3 = c
		end)
	end

	-- Decorative Alternating Arrows (FIXED: Added TextWrapped = false)
	local DecoArrows = Instance.new("TextLabel")
	DecoArrows.Name = "DecoArrows"
	DecoArrows.BackgroundTransparency = 1
	DecoArrows.Size = UDim2.new(0, 0, 1, 0)
	DecoArrows.AutomaticSize = Enum.AutomaticSize.X
	DecoArrows.Font = Enum.Font.GothamBold
	DecoArrows.RichText = true
	DecoArrows.Text = '<font color="#FFFFFF">&gt;&gt;</font> <font color="#1E6EE6">&gt;&gt;</font> <font color="#FFFFFF">&gt;&gt;</font> <font color="#1E6EE6">&gt;&gt;</font>'
	DecoArrows.TextSize = 13
	DecoArrows.TextXAlignment = Enum.TextXAlignment.Left
	DecoArrows.TextYAlignment = Enum.TextYAlignment.Center
	DecoArrows.TextWrapped = false
	DecoArrows.LayoutOrder = 3
	if IsMobile then DecoArrows.Visible = false end
	DecoArrows.Parent = HeaderLayoutContainer

	-- Horizontal Separator Line
	local HorizontalSeparator = Instance.new("Frame")
	HorizontalSeparator.Name = "HorizontalSeparator"
	HorizontalSeparator.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	HorizontalSeparator.BorderSizePixel = 0
	HorizontalSeparator.Position = UDim2.new(0, 0, 0, 50)
	HorizontalSeparator.Size = UDim2.new(1, 0, 0, 1)
	HorizontalSeparator.ZIndex = 3
	HorizontalSeparator.Parent = MainFrame

	-- Sidebar Width Configuration
	local SidebarWidth = IsMobile and 140 or 165
	local CollapsedSidebarWidth = IsMobile and 44 or 50

	-- Sidebar Frame
	local Sidebar = Instance.new("Frame")
	Sidebar.Name = "Sidebar"
	Sidebar.BackgroundColor3 = Color3.fromRGB(14, 14, 16)
	Sidebar.BackgroundTransparency = 0.12 -- lets background image show through
	Sidebar.BorderSizePixel = 0
	Sidebar.Position = UDim2.new(0, 0, 0, 51)
	Sidebar.Size = UDim2.new(0, SidebarWidth, 1, -51)
	Sidebar.ClipsDescendants = true -- Set to true to prevent tab overflow on mobile
	Sidebar.ZIndex = 2
	Sidebar.Parent = MainFrame

	-- FIXED: Sidebar Corner Alignment System (Prevents sticking out of MainFrame)
	local SidebarCorner = Instance.new("UICorner")
	SidebarCorner.CornerRadius = UDim.new(0, 10) -- Matches MainFrame perfectly
	SidebarCorner.Parent = Sidebar

	-- Seamless Filler Frames to selectively un-round top-left, top-right, and bottom-right corners
	local SidebarFillerTop = Instance.new("Frame")
	SidebarFillerTop.Name = "SidebarFillerTop"
	SidebarFillerTop.BackgroundColor3 = Sidebar.BackgroundColor3
	SidebarFillerTop.BackgroundTransparency = 0.12
	SidebarFillerTop.BorderSizePixel = 0
	SidebarFillerTop.Position = UDim2.new(0, 0, 0, 0)
	SidebarFillerTop.Size = UDim2.new(1, 0, 0, 15) -- Covers top-left and top-right rounded corners
	SidebarFillerTop.ZIndex = 2
	SidebarFillerTop.Parent = Sidebar

	local SidebarFillerRight = Instance.new("Frame")
	SidebarFillerRight.Name = "SidebarFillerRight"
	SidebarFillerRight.BackgroundColor3 = Sidebar.BackgroundColor3
	SidebarFillerRight.BackgroundTransparency = 0.12
	SidebarFillerRight.BorderSizePixel = 0
	SidebarFillerRight.Position = UDim2.new(1, -15, 0, 0)
	SidebarFillerRight.Size = UDim2.new(0, 15, 1, 0) -- Covers top-right and bottom-right rounded corners
	SidebarFillerRight.ZIndex = 2
	SidebarFillerRight.Parent = Sidebar

	-- Tab Buttons Container
	local TabContainer = Instance.new("ScrollingFrame")
	TabContainer.Name = "TabContainer"
	TabContainer.BackgroundTransparency = 1
	TabContainer.BorderSizePixel = 0
	TabContainer.Position = UDim2.new(0, 0, 0, 6)
	TabContainer.Size = UDim2.new(1, 0, 1, -60)
	TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabContainer.ScrollBarThickness = 0
	TabContainer.ClipsDescendants = true -- Set to true to prevent tab overflow on mobile
	TabContainer.ZIndex = 3
	TabContainer.Parent = Sidebar

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.Parent = TabContainer
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 5)
	TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center

	TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y + 20)
	end)

	local TabPadding = Instance.new("UIPadding")
	TabPadding.PaddingTop = UDim.new(0, 2)
	TabPadding.PaddingBottom = UDim.new(0, 4)
	TabPadding.PaddingLeft = UDim.new(0, 6)
	TabPadding.PaddingRight = UDim.new(0, 6)
	TabPadding.Parent = TabContainer

	-- Vertical Separator Line
	local Separator = Instance.new("Frame")
	Separator.Name = "Separator"
	Separator.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	Separator.BorderSizePixel = 0
	Separator.Position = UDim2.new(0, SidebarWidth, 0, 51)
	Separator.Size = UDim2.new(0, 1, 1, -51)
	Separator.ZIndex = 3
	Separator.Parent = MainFrame

	-- Content Container
	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.BackgroundColor3 = Color3.fromRGB(16, 16, 18)
	ContentContainer.BackgroundTransparency = 0.25 -- lets background image show through
	ContentContainer.BorderSizePixel = 0
	ContentContainer.ClipsDescendants = true
	ContentContainer.Position = UDim2.new(0, SidebarWidth + 1, 0, 51)
	ContentContainer.Size = UDim2.new(1, -SidebarWidth - 9, 1, -59)
	ContentContainer.Parent = MainFrame

	local ContentCorner = Instance.new("UICorner")
	ContentCorner.CornerRadius = UDim.new(0, 8) -- Optimized corner radius (not too curved)
	ContentCorner.Parent = ContentContainer

	-- Apply Lag-Free Dragging
	makeElementDraggable(MainFrame, TopBar)

	-- =========================================================================
	-- PIXEL-PERFECT COLOR PICKER PANEL (SLIDES INSIDE FROM RIGHT SIDE)
	-- =========================================================================
	local cpWidth = 280
	-- Panels shrink on small windows so they never cover everything / overlap
	local function curPanelWidth()
		local w = MainFrame.AbsoluteSize.X
		if w < 10 then w = refW end
		return math.min(280, math.max(200, w - 120))
	end
	local cpHeight = IsMobile and 335 or 499
	local canvasHeight = IsMobile and 95 or 190
	local sliderHeight = IsMobile and 12 or 16
	local previewHeight = IsMobile and 22 or 36
	local inputHeight = IsMobile and 22 or 32
	local buttonHeight = IsMobile and 30 or 36
	local padding = IsMobile and 5 or 12

	local ColorPickerPanel = Instance.new("Frame")
	ColorPickerPanel.Name = "ColorPickerPanel"
	ColorPickerPanel.BackgroundColor3 = Color3.fromRGB(26, 26, 30) -- lightened
	ColorPickerPanel.BorderSizePixel = 0
	ColorPickerPanel.Size = UDim2.new(0, cpWidth, 1, -51)
	ColorPickerPanel.Position = UDim2.new(1, 0, 0, 51) -- Hidden off-screen to the right (inside MainFrame)
	ColorPickerPanel.ZIndex = 200
	ColorPickerPanel.Active = true -- Block clicks from passing through
	ColorPickerPanel.Parent = MainFrame -- Parented to MainFrame to stay inside the UI

	-- Input Sinker to completely block click-throughs to elements behind the panel
	local CPInputSinker = Instance.new("TextButton")
	CPInputSinker.Name = "InputSinker"
	CPInputSinker.Size = UDim2.new(1, 0, 1, 0)
	CPInputSinker.BackgroundTransparency = 1
	CPInputSinker.Text = ""
	CPInputSinker.AutoButtonColor = false
	CPInputSinker.ZIndex = 200
	CPInputSinker.Parent = ColorPickerPanel

	local PanelSeparator = Instance.new("Frame")
	PanelSeparator.Name = "PanelSeparator"
	-- layout clean for side panels
	PanelSeparator.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	PanelSeparator.BorderSizePixel = 0
	PanelSeparator.Position = UDim2.new(0, 0, 0, 0)
	PanelSeparator.Size = UDim2.new(0, 1, 1, 0)
	PanelSeparator.ZIndex = 201
	PanelSeparator.Parent = ColorPickerPanel

	-- Saturation/Value canvas: hue base + white (sat) + black (val) gradients,
	-- so every shade is reachable and colors are easy to match
	local Canvas = Instance.new("Frame")
	Canvas.Name = "Canvas"
	Canvas.Size = UDim2.new(1, -24, 0, canvasHeight)
	Canvas.Position = UDim2.new(0, 12, 0, padding)
	Canvas.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
	Canvas.BorderSizePixel = 0
	Canvas.ClipsDescendants = true
	Canvas.ZIndex = 202
	Canvas.Parent = ColorPickerPanel

	local CanvasCorner = Instance.new("UICorner")
	CanvasCorner.CornerRadius = UDim.new(0, 8)
	CanvasCorner.Parent = Canvas

	-- White overlay, transparent on the right = saturation axis
	local SatOverlay = Instance.new("Frame")
	SatOverlay.Name = "SatOverlay"
	SatOverlay.Size = UDim2.fromScale(1, 1)
	SatOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SatOverlay.BorderSizePixel = 0
	SatOverlay.ZIndex = 203
	SatOverlay.Parent = Canvas

	local SatOverlayCorner = Instance.new("UICorner")
	SatOverlayCorner.CornerRadius = UDim.new(0, 8)
	SatOverlayCorner.Parent = SatOverlay

	local SatGradient = Instance.new("UIGradient")
	SatGradient.Rotation = 0
	SatGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1)
	})
	SatGradient.Parent = SatOverlay

	-- Black overlay, transparent on top = value axis
	local ValOverlay = Instance.new("Frame")
	ValOverlay.Name = "ValOverlay"
	ValOverlay.Size = UDim2.fromScale(1, 1)
	ValOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	ValOverlay.BorderSizePixel = 0
	ValOverlay.ZIndex = 204
	ValOverlay.Parent = Canvas

	local ValOverlayCorner = Instance.new("UICorner")
	ValOverlayCorner.CornerRadius = UDim.new(0, 8)
	ValOverlayCorner.Parent = ValOverlay

	local ValGradient = Instance.new("UIGradient")
	ValGradient.Rotation = 90
	ValGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(1, 0)
	})
	ValGradient.Parent = ValOverlay

	local CanvasHandle = Instance.new("Frame")
	CanvasHandle.Name = "CanvasHandle"
	CanvasHandle.Size = UDim2.new(0, 16, 0, 16)
	CanvasHandle.AnchorPoint = Vector2.new(0.5, 0.5)
	CanvasHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	CanvasHandle.ZIndex = 205
	CanvasHandle.Parent = Canvas

	local HandleCorner = Instance.new("UICorner")
	HandleCorner.CornerRadius = UDim.new(1, 0)
	HandleCorner.Parent = CanvasHandle

	local HandleStroke = Instance.new("UIStroke")
	HandleStroke.Color = Color3.fromRGB(0, 0, 0)
	HandleStroke.Thickness = 1.5
	HandleStroke.Parent = CanvasHandle

	-- Hue Slider (FIXED: Subtle curve, not too curved)
	local HueSlider = Instance.new("Frame")
	HueSlider.Name = "HueSlider"
	HueSlider.Size = UDim2.new(1, -24, 0, sliderHeight)
	HueSlider.Position = UDim2.new(0, 12, 0, padding + canvasHeight + padding)
	HueSlider.ZIndex = 202
	HueSlider.Parent = ColorPickerPanel

	local HueCorner = Instance.new("UICorner")
	HueCorner.CornerRadius = UDim.new(0, 3) -- FIXED: Subtle curve, not too curved
	HueCorner.Parent = HueSlider

	local HueGradient = Instance.new("UIGradient")
	HueGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
		ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
		ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
		ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
		ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
	})
	HueGradient.Parent = HueSlider

	local HueHandle = Instance.new("Frame")
	HueHandle.Name = "HueHandle"
	HueHandle.Size = UDim2.new(0, 12, 1, 6) -- Vertical pill wrapping the slider
	HueHandle.AnchorPoint = Vector2.new(0.5, 0.5)
	HueHandle.Position = UDim2.new(0, 0, 0.5, 0)
	HueHandle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	HueHandle.ZIndex = 203
	HueHandle.Parent = HueSlider

	local HueHandleCorner = Instance.new("UICorner")
	HueHandleCorner.CornerRadius = UDim.new(0, 4)
	HueHandleCorner.Parent = HueHandle

	local HueHandleStroke = Instance.new("UIStroke")
	HueHandleStroke.Color = Color3.fromRGB(0, 0, 0)
	HueHandleStroke.Thickness = 1
	HueHandleStroke.Parent = HueHandle

	-- Current / New Preview Buttons
	local PreviewContainer = Instance.new("Frame")
	PreviewContainer.Name = "PreviewContainer"
	PreviewContainer.BackgroundTransparency = 1
	PreviewContainer.Size = UDim2.new(1, -24, 0, previewHeight)
	PreviewContainer.Position = UDim2.new(0, 12, 0, padding + canvasHeight + padding + sliderHeight + padding)
	PreviewContainer.ZIndex = 202
	PreviewContainer.Parent = ColorPickerPanel

	local CurrentPreview = Instance.new("Frame")
	CurrentPreview.Name = "CurrentPreview"
	CurrentPreview.Size = UDim2.new(0.5, -6, 1, 0)
	CurrentPreview.BackgroundColor3 = Color3.fromRGB(34, 255, 34)
	CurrentPreview.ZIndex = 203
	CurrentPreview.Parent = PreviewContainer
	-- LAYOUT AROUND BOX (copied from good UI)
	local PreviewPadding = Instance.new("UIPadding", PreviewContainer)
	PreviewPadding.PaddingLeft = UDim.new(0, 0)
	PreviewPadding.PaddingRight = UDim.new(0, 0)

	local CurrentCorner = Instance.new("UICorner")
	CurrentCorner.CornerRadius = UDim.new(0, 6)
	CurrentCorner.Parent = CurrentPreview

	local CurrentLabel = Instance.new("TextLabel")
	CurrentLabel.Size = UDim2.new(1, 0, 1, 0)
	CurrentLabel.BackgroundTransparency = 1
	CurrentLabel.Font = Enum.Font.GothamBold
	CurrentLabel.Text = "CURRENT"
	CurrentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	CurrentLabel.			TextSize = 11
	CurrentLabel.ZIndex = 204
	CurrentLabel.Parent = CurrentPreview

	local NewPreview = Instance.new("Frame")
	NewPreview.Name = "NewPreview"
	NewPreview.Size = UDim2.new(0.5, -6, 1, 0)
	NewPreview.Position = UDim2.new(0.5, 6, 0, 0)
	NewPreview.BackgroundColor3 = Color3.fromRGB(58, 49, 255)
	NewPreview.ZIndex = 203
	NewPreview.Parent = PreviewContainer

	local NewCorner = Instance.new("UICorner")
	NewCorner.CornerRadius = UDim.new(0, 6)
	NewCorner.Parent = NewPreview

	local NewLabel = Instance.new("TextLabel")
	NewLabel.Size = UDim2.new(1, 0, 1, 0)
	NewLabel.BackgroundTransparency = 1
	NewLabel.Font = Enum.Font.GothamBold
	NewLabel.Text = "NEW"
	NewLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	NewLabel.			TextSize = 11
	NewLabel.ZIndex = 204
	NewLabel.Parent = NewPreview

	-- RGB Inputs
	local RGBContainer = Instance.new("Frame")
	RGBContainer.Name = "RGBContainer"
	RGBContainer.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	RGBContainer.BackgroundTransparency = 0
	RGBContainer.BorderSizePixel = 0
	RGBContainer.Size = UDim2.new(1, -24, 0, inputHeight + 10)
	RGBContainer.Position = UDim2.new(0, 12, 0, padding + canvasHeight + padding + sliderHeight + padding + previewHeight + padding - 5)
	RGBContainer.ZIndex = 202
	RGBContainer.Parent = ColorPickerPanel

	local RGBCorner = Instance.new("UICorner")
	RGBCorner.CornerRadius = UDim.new(0, 8)
	RGBCorner.Parent = RGBContainer

	local RGBStroke = Instance.new("UIStroke")
	RGBStroke.Color = Color3.fromRGB(52, 52, 60)
	RGBStroke.Thickness = 1
	RGBStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	RGBStroke.Parent = RGBContainer

	local RGBPad = Instance.new("UIPadding")
	RGBPad.PaddingLeft = UDim.new(0, 6)
	RGBPad.PaddingRight = UDim.new(0, 6)
	RGBPad.PaddingTop = UDim.new(0, 5)
	RGBPad.PaddingBottom = UDim.new(0, 5)
	RGBPad.Parent = RGBContainer

	-- RGB Inputs: one real horizontal layout (no manual math, no dup padding)
	local RGBLayout = Instance.new("UIListLayout")
	RGBLayout.FillDirection = Enum.FillDirection.Horizontal
	RGBLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	RGBLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	RGBLayout.SortOrder = Enum.SortOrder.LayoutOrder
	RGBLayout.Padding = UDim.new(0, 8)
	RGBLayout.Parent = RGBContainer

	local function createRGBInput(name, placeholder, order)
		local Box = Instance.new("TextBox")
		Box.Name = name
		Box.Size = UDim2.new(0.333, -6, 1, 0)
		Box.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
		Box.BorderSizePixel = 0
		Box.Font = Enum.Font.GothamBold
		Box.Text = "255"
		Box.PlaceholderText = placeholder
		Box.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
		Box.TextColor3 = Color3.fromRGB(255, 255, 255)
		Box.			TextSize = 12
		Box.ClearTextOnFocus = false
		Box.ClipsDescendants = true
		Box.TextTruncate = Enum.TextTruncate.AtEnd
		Box.TextXAlignment = Enum.TextXAlignment.Center
		Box.ZIndex = 203
		Box.LayoutOrder = order
		Box.Parent = RGBContainer

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 6)
		Corner.Parent = Box

		local Stroke = Instance.new("UIStroke")
		Stroke.Color = Color3.fromRGB(35, 35, 40)
		Stroke.Thickness = 1
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.Parent = Box

		Box.Focused:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = AccentColor}):Play()
		end)
		Box.FocusLost:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 40)}):Play()
		end)

		return Box
	end

	local RInput = createRGBInput("RInput", "R", 1)
	local GInput = createRGBInput("GInput", "G", 2)
	local BInput = createRGBInput("BInput", "B", 3)

	-- Hex row: caption + input aligned on one clean line
	local HexRow = Instance.new("Frame")
	HexRow.Name = "HexRow"
	HexRow.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
	HexRow.BackgroundTransparency = 0
	HexRow.BorderSizePixel = 0
	HexRow.Size = UDim2.new(1, -24, 0, inputHeight + 10)
	HexRow.Position = UDim2.new(0, 12, 0, padding + canvasHeight + padding + sliderHeight + padding + previewHeight + padding - 5 + inputHeight + 10 + 6)
	HexRow.ZIndex = 202
	HexRow.Parent = ColorPickerPanel

	local HexCardCorner = Instance.new("UICorner")
	HexCardCorner.CornerRadius = UDim.new(0, 8)
	HexCardCorner.Parent = HexRow

	local HexCardStroke = Instance.new("UIStroke")
	HexCardStroke.Color = Color3.fromRGB(52, 52, 60)
	HexCardStroke.Thickness = 1
	HexCardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HexCardStroke.Parent = HexRow

	local HexCardPad = Instance.new("UIPadding")
	HexCardPad.PaddingLeft = UDim.new(0, 6)
	HexCardPad.PaddingRight = UDim.new(0, 6)
	HexCardPad.PaddingTop = UDim.new(0, 5)
	HexCardPad.PaddingBottom = UDim.new(0, 5)
	HexCardPad.Parent = HexRow

	local HexRowLayout = Instance.new("UIListLayout")
	HexRowLayout.FillDirection = Enum.FillDirection.Horizontal
	HexRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	HexRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
	HexRowLayout.Padding = UDim.new(0, 8)
	HexRowLayout.Parent = HexRow

	local HexCaption = Instance.new("TextLabel")
	HexCaption.Name = "HexCaption"
	HexCaption.BackgroundTransparency = 1
	HexCaption.Size = UDim2.new(0, 36, 1, 0)
	HexCaption.Font = Enum.Font.GothamBold
	HexCaption.Text = "HEX"
	HexCaption.TextColor3 = Color3.fromRGB(160, 160, 165)
	HexCaption.			TextSize = 10
	HexCaption.TextXAlignment = Enum.TextXAlignment.Left
	HexCaption.LayoutOrder = 1
	HexCaption.ZIndex = 203
	HexCaption.Parent = HexRow

	-- Hex Input
	local HexInput = Instance.new("TextBox")
	HexInput.Name = "HexInput"
	HexInput.Size = UDim2.new(1, -44, 1, 0)
	HexInput.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
	HexInput.BorderSizePixel = 0
	HexInput.Font = Enum.Font.GothamBold
	HexInput.Text = "#FFFFFF"
	HexInput.PlaceholderText = "#843447"
	HexInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
	HexInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	HexInput.			TextSize = 12
	HexInput.ClearTextOnFocus = false
	HexInput.ClipsDescendants = true
	HexInput.TextTruncate = Enum.TextTruncate.AtEnd
	HexInput.TextXAlignment = Enum.TextXAlignment.Center
	HexInput.ZIndex = 203
	HexInput.LayoutOrder = 2
	HexInput.Parent = HexRow
	local HexInnerPadding = Instance.new("UIPadding")
	HexInnerPadding.PaddingLeft = UDim.new(0, 8)
	HexInnerPadding.PaddingRight = UDim.new(0, 8)
	HexInnerPadding.Parent = HexInput

	local HexCorner = Instance.new("UICorner")
	HexCorner.CornerRadius = UDim.new(0, 6)
	HexCorner.Parent = HexInput

	local HexStroke = Instance.new("UIStroke")
	HexStroke.Color = Color3.fromRGB(35, 35, 40)
	HexStroke.Thickness = 1
	HexStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	HexStroke.Parent = HexInput

	HexInput.Focused:Connect(function()
		TweenService:Create(HexStroke, TweenInfo.new(0.15), {Color = AccentColor}):Play()
	end)
	HexInput.FocusLost:Connect(function()
		TweenService:Create(HexStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 40)}):Play()
	end)

	-- Apply & Cancel Buttons
	local ApplyButton = Instance.new("TextButton")
	ApplyButton.Name = "ApplyButton"
	ApplyButton.Size = UDim2.new(1, -24, 0, buttonHeight)
	ApplyButton.Position = UDim2.new(0, 12, 1, -buttonHeight - buttonHeight - padding - 8)
	ApplyButton.BackgroundColor3 = AccentColor
	ApplyButton.Font = Enum.Font.GothamBold
	ApplyButton.Text = "Apply"
			ApplyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	ApplyButton.			TextSize = 14
	ApplyButton.ZIndex = 203
	ApplyButton.Parent = ColorPickerPanel

	local ApplyCorner = Instance.new("UICorner")
	ApplyCorner.CornerRadius = UDim.new(0, 8)
	ApplyCorner.Parent = ApplyButton

	-- Apply button follows theme accent
	onAccentChange(function(c)
		ApplyButton.BackgroundColor3 = c
	end)

	local CancelButton = Instance.new("TextButton")
	CancelButton.Name = "CancelButton"
	CancelButton.Size = UDim2.new(1, -24, 0, buttonHeight)
	CancelButton.Position = UDim2.new(0, 12, 1, -buttonHeight - 8)
		CancelButton.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
	CancelButton.Font = Enum.Font.GothamBold
	CancelButton.Text = "Cancel"
	CancelButton.TextColor3 = Color3.fromRGB(255, 255, 255)
	CancelButton.			TextSize = 14
	CancelButton.ZIndex = 203
	CancelButton.Parent = ColorPickerPanel -- FIXED: Corrected parent from CancelButton to ColorPickerPanel to prevent crash

	local CancelCorner = Instance.new("UICorner")
	CancelCorner.CornerRadius = UDim.new(0, 8)
	CancelCorner.Parent = CancelButton

	-- Color Picker State & Math Logic
	local currentHue, currentSat, currentValue = 0, 1, 1
	local originalColor = Color3.fromRGB(255, 255, 255)
	local selectedColor = Color3.fromRGB(255, 255, 255)
	local activeCallback = nil
	local activePreviewBox = nil
	local pickerOpen = false

	local function updateColorPickerUI()
		local color = Color3.fromHSV(currentHue, currentSat, currentValue)
		selectedColor = color
		
		-- Base shows the pure hue; overlays shape saturation (white) and value (black)
		Canvas.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)
		
		CanvasHandle.Position = UDim2.new(currentSat, 0, 1 - currentValue, 0)
		HueHandle.Position = UDim2.new(currentHue, 0, 0.5, 0)
		NewPreview.BackgroundColor3 = color
		
		local r, g, b = math.round(color.R * 255), math.round(color.G * 255), math.round(color.B * 255)
		RInput.Text = tostring(r)
		GInput.Text = tostring(g)
		BInput.Text = tostring(b)
		HexInput.Text = string.format("#%02X%02X%02X", r, g, b)
	end

	-- Hue Slider Dragging
	local hueDragging = false
	local function updateHueFromInput(input)
		local relX, _ = getRelativePosition(HueSlider, input)
		currentHue = relX
		updateColorPickerUI()
	end

	HueSlider.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			hueDragging = true
			updateHueFromInput(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateHueFromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			hueDragging = false
		end
	end)

	-- Canvas Dragging
	local canvasDragging = false
	local function updateCanvasFromInput(input)
		local relX, relY = getRelativePosition(Canvas, input)
		currentSat = relX
		currentValue = 1 - relY
		updateColorPickerUI()
	end

	Canvas.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			canvasDragging = true
			updateCanvasFromInput(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if canvasDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateCanvasFromInput(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			canvasDragging = false
		end
	end)

	-- Manual Inputs
	local function updateFromRGB()
		local r = tonumber(RInput.Text) or 0
		local g = tonumber(GInput.Text) or 0
		local b = tonumber(BInput.Text) or 0
		r = math.clamp(r, 0, 255)
		g = math.clamp(g, 0, 255)
		b = math.clamp(b, 0, 255)
		
		local color = Color3.fromRGB(r, g, b)
		currentHue, currentSat, currentValue = Color3.toHSV(color)
		updateColorPickerUI()
	end

	RInput.FocusLost:Connect(updateFromRGB)
	GInput.FocusLost:Connect(updateFromRGB)
	BInput.FocusLost:Connect(updateFromRGB)

	HexInput.FocusLost:Connect(function()
		local hex = HexInput.Text:gsub("#", "")
		if #hex == 6 then
			local r = tonumber(hex:sub(1, 2), 16)
			local g = tonumber(hex:sub(3, 4), 16)
			local b = tonumber(hex:sub(5, 6), 16)
			if r and g and b then
				local color = Color3.fromRGB(r, g, b)
				currentHue, currentSat, currentValue = Color3.toHSV(color)
				updateColorPickerUI()
			end
		end
	end)

	-- Forward declaration of closeSelector to prevent scope errors
	local closeSelector

	-- Lay out picker rows from the REAL panel height every open,
	-- so short windows (XS/mobile) can never overlap rows and buttons
	local function layoutPickerPanel()
		local H = ColorPickerPanel.AbsoluteSize.Y
		if H < 10 then H = (refH or 550) - 51 end
		ColorPickerPanel.Size = UDim2.new(0, curPanelWidth(), 1, -51)
		local compact = H < 380
		local pad = compact and 4 or 12
		local ch = compact and 80 or 190
		local sh = compact and 10 or 16
		local ph = compact and 18 or 36
		local ih = compact and 22 or 32
		local bh = compact and 26 or 36
		Canvas.Size = UDim2.new(1, -24, 0, ch)
		Canvas.Position = UDim2.new(0, 12, 0, pad)
		HueSlider.Size = UDim2.new(1, -24, 0, sh)
		HueSlider.Position = UDim2.new(0, 12, 0, pad + ch + pad)
		PreviewContainer.Size = UDim2.new(1, -24, 0, ph)
		PreviewContainer.Position = UDim2.new(0, 12, 0, pad + ch + pad + sh + pad)
		RGBContainer.Size = UDim2.new(1, -24, 0, ih)
		RGBContainer.Position = UDim2.new(0, 12, 0, pad + ch + pad + sh + pad + ph + pad)
		HexRow.Size = UDim2.new(1, -24, 0, ih)
		HexRow.Position = UDim2.new(0, 12, 0, pad + ch + pad + sh + pad + ph + pad + ih + pad)
		ApplyButton.Size = UDim2.new(1, -24, 0, bh)
		ApplyButton.Position = UDim2.new(0, 12, 1, -bh - bh - pad - 8)
		CancelButton.Size = UDim2.new(1, -24, 0, bh)
		CancelButton.Position = UDim2.new(0, 12, 1, -bh - 8)
	end

	-- Slide Animations (Slides inside MainFrame from the right edge)
	local function openColorPicker(defaultColor, callback, previewBox)
		if closeSelector then closeSelector() end
		originalColor = defaultColor
		selectedColor = defaultColor
		currentHue, currentSat, currentValue = Color3.toHSV(defaultColor)
		
		CurrentPreview.BackgroundColor3 = defaultColor
		activeCallback = callback
		activePreviewBox = previewBox
		
		updateColorPickerUI()
		
		pickerOpen = true
		layoutPickerPanel()
		TweenService:Create(ColorPickerPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -curPanelWidth(), 0, 51)
		}):Play()
	end

	local function closeColorPicker()
		pickerOpen = false
		TweenService:Create(ColorPickerPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 0, 0, 51)
		}):Play()
	end

	ApplyButton.MouseButton1Click:Connect(function()
		if activeCallback then
			task.spawn(activeCallback, selectedColor)
		end
		if activePreviewBox then
			activePreviewBox.BackgroundColor3 = selectedColor
		end
		closeColorPicker()
	end)

	CancelButton.MouseButton1Click:Connect(function()
		closeColorPicker()
	end)

	-- =========================================================================
	-- PIXEL-PERFECT SELECTOR PANEL (SLIDES INSIDE FROM RIGHT SIDE)
	-- =========================================================================
	local SelectorPanel = Instance.new("Frame")
	SelectorPanel.Name = "SelectorPanel"
	SelectorPanel.BackgroundColor3 = Color3.fromRGB(26, 26, 30) -- FIXED: lightened from 14,14,16 for clean visibility
	SelectorPanel.BorderSizePixel = 0
	SelectorPanel.Size = UDim2.new(0, cpWidth, 1, -51)
	SelectorPanel.Position = UDim2.new(1, 0, 0, 51) -- Hidden off-screen to the right
	SelectorPanel.ZIndex = 200
	SelectorPanel.Active = true -- Block clicks from passing through
	SelectorPanel.Parent = MainFrame

	-- FIXED: Clean, matching border stroke for the Selector Panel (No mismatched colors)
	local SelectorPanelStroke = Instance.new("UIStroke")
	SelectorPanelStroke.Color = Color3.fromRGB(32, 32, 36) -- Matches MainFrame border exactly
	SelectorPanelStroke.Thickness = 1.5
	local SelectorPadding = Instance.new("UIPadding", SelectorPanel)
	SelectorPadding.PaddingTop = UDim.new(0, 4)
	SelectorPadding.PaddingBottom = UDim.new(0, 4)
	SelectorPanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	SelectorPanelStroke.Parent = SelectorPanel

	-- Input Sinker to completely block click-throughs to elements behind the panel
	local SelectorInputSinker = Instance.new("TextButton")
	SelectorInputSinker.Name = "InputSinker"
	SelectorInputSinker.Size = UDim2.new(1, 0, 1, 0)
	SelectorInputSinker.BackgroundTransparency = 1
	SelectorInputSinker.Text = ""
	SelectorInputSinker.AutoButtonColor = false
	SelectorInputSinker.ZIndex = 200
	SelectorInputSinker.Parent = SelectorPanel

	-- Outside-click catcher: click anywhere outside the panel to close (no close button)
	local SelectorCatcher = Instance.new("TextButton")
	SelectorCatcher.Name = "SelectorCatcher"
	SelectorCatcher.BackgroundTransparency = 1
	SelectorCatcher.Text = ""
	SelectorCatcher.AutoButtonColor = false
	SelectorCatcher.Position = UDim2.new(0, 0, 0, 51)
	SelectorCatcher.Size = UDim2.new(1, 0, 1, -51)
	SelectorCatcher.ZIndex = 150
	SelectorCatcher.Visible = false
	SelectorCatcher.Parent = MainFrame

	local SelectorPanelSeparator = Instance.new("Frame")
	SelectorPanelSeparator.Name = "SelectorPanelSeparator"
	SelectorPanelSeparator.BackgroundColor3 = Color3.fromRGB(38, 38, 44)
	SelectorPanelSeparator.BorderSizePixel = 0
	SelectorPanelSeparator.Position = UDim2.new(0, 0, 0, 0)
	SelectorPanelSeparator.Size = UDim2.new(0, 1, 1, 0)
	SelectorPanelSeparator.ZIndex = 201
	SelectorPanelSeparator.Parent = SelectorPanel

	local SelectorPanelTitle = Instance.new("TextLabel")
	SelectorPanelTitle.Name = "SelectorPanelTitle"
	SelectorPanelTitle.Size = UDim2.new(1, -24, 0, 30)
	SelectorPanelTitle.Position = UDim2.new(0, 8, 0, 6) -- FIXED: Moved slightly left and higher
	SelectorPanelTitle.BackgroundTransparency = 1
	SelectorPanelTitle.Font = Enum.Font.GothamBold
	SelectorPanelTitle.Text = "Select Option"
	SelectorPanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
	mTS(SelectorPanelTitle, 14)
	SelectorPanelTitle.ZIndex = 202
	SelectorPanelTitle.Parent = SelectorPanel

	-- Search Container (Modernized & High-Contrast)
	local SearchContainer = Instance.new("Frame")
	SearchContainer.Name = "SearchContainer"
	SearchContainer.BackgroundColor3 = Color3.fromRGB(28, 28, 34) -- Higher contrast
	SearchContainer.Size = UDim2.new(1, -24, 0, 32)
	SearchContainer.Position = UDim2.new(0, 12, 0, 38) -- FIXED: Improved spacing relative to title
	SearchContainer.ZIndex = 202
	SearchContainer.Parent = SelectorPanel

	local SearchCorner = Instance.new("UICorner")
	SearchCorner.CornerRadius = UDim.new(0, 6)
	SearchCorner.Parent = SearchContainer

	local SearchStroke = Instance.new("UIStroke")
	SearchStroke.Color = Color3.fromRGB(55, 55, 65) -- Higher contrast border
	SearchStroke.Thickness = 1
	SearchStroke.Parent = SearchContainer

	local SearchIcon = Instance.new("ImageLabel")
	SearchIcon.Size = UDim2.new(0, 16, 0, 16)
	SearchIcon.Position = UDim2.new(0, 8, 0.5, -8)
	SearchIcon.BackgroundTransparency = 1
	SearchIcon.Image = Astral.Icons.search
	SearchIcon.ImageColor3 = Color3.fromRGB(180, 180, 185)
	SearchIcon.ZIndex = 203
	SearchIcon.Parent = SearchContainer

	local SearchInput = Instance.new("TextBox")
	SearchInput.Size = UDim2.new(1, -54, 1, 0)
	SearchInput.Position = UDim2.new(0, 30, 0, 0)
	SearchInput.BackgroundTransparency = 1
	SearchInput.Font = Enum.Font.Gotham
	tr(SearchInput, "Search...", "PlaceholderText")
	SearchInput.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
	SearchInput.Text = ""
	SearchInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	mTS(SearchInput, 12)
	SearchInput.TextXAlignment = Enum.TextXAlignment.Left
	SearchInput.ZIndex = 203
	SearchInput.Parent = SearchContainer

	-- Clear Search Button
	local ClearSearchBtn = Instance.new("ImageButton")
	ClearSearchBtn.Name = "ClearSearchBtn"
	ClearSearchBtn.Size = UDim2.new(0, 14, 0, 14)
	ClearSearchBtn.Position = UDim2.new(1, -24, 0.5, -7)
	ClearSearchBtn.BackgroundTransparency = 1
	ClearSearchBtn.Image = Astral.Icons.Close
	ClearSearchBtn.ImageColor3 = Color3.fromRGB(140, 140, 145)
	ClearSearchBtn.Visible = false
	ClearSearchBtn.ZIndex = 204
	ClearSearchBtn.Parent = SearchContainer

	ClearSearchBtn.MouseButton1Click:Connect(function()
		SearchInput.Text = ""
	end)

	SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
		ClearSearchBtn.Visible = (SearchInput.Text ~= "")
	end)

	-- Options Scroll Frame
	local OptionsScroll = Instance.new("ScrollingFrame")
	OptionsScroll.Name = "OptionsScroll"
	OptionsScroll.BackgroundTransparency = 1
	OptionsScroll.BorderSizePixel = 0
	OptionsScroll.ScrollBarThickness = 2
	OptionsScroll.ScrollBarImageColor3 = Color3.fromRGB(70, 70, 75)
	OptionsScroll.ZIndex = 202
	OptionsScroll.Parent = SelectorPanel

	local OptionsPadding = Instance.new("UIPadding")
	OptionsPadding.PaddingLeft = UDim.new(0, 4)
	OptionsPadding.PaddingRight = UDim.new(0, 4)
	OptionsPadding.PaddingTop = UDim.new(0, 4)
	OptionsPadding.PaddingBottom = UDim.new(0, 4)
	OptionsPadding.Parent = OptionsScroll

	local OptionsList = Instance.new("UIListLayout")
	OptionsList.SortOrder = Enum.SortOrder.LayoutOrder
	OptionsList.Padding = UDim.new(0, 8)
	OptionsList.Parent = OptionsScroll

	local selectorOpen = false
	local activeSelectorCallback = nil
	local activeSelectorButtonText = nil
	local activeSelectorOptions = {}
	local activeSelectorSearch = false
	local searchConn = nil
	local activeSelectorRefresh = nil

	local function openSelector(title, options, current, searchEnabled, callback, buttonTextLabel, isMulti)
		if pickerOpen then closeColorPicker() end
		
		SelectorPanelTitle.Text = translateText(title)
		activeSelectorCallback = callback
		activeSelectorButtonText = buttonTextLabel
		activeSelectorOptions = options
		activeSelectorSearch = searchEnabled
		SearchInput.Text = ""

		SearchContainer.Visible = searchEnabled
		if searchEnabled then
			OptionsScroll.Position = UDim2.new(0, 12, 0, 76)
			OptionsScroll.Size = UDim2.new(1, -24, 1, -88)
		else
			OptionsScroll.Position = UDim2.new(0, 12, 0, 42)
			OptionsScroll.Size = UDim2.new(1, -24, 1, -54)
		end

		-- Parse current selection for multi-select
		local selectedSet = {}
		if isMulti and current and current ~= "None" then
			for item in string.gmatch(current, "([^,]+)") do
				local trimmed = string.match(item, "^%s*(.-)%s*$")
				if trimmed and trimmed ~= "" then
					selectedSet[trimmed] = true
				end
			end
		end

		local function populate(filter)
			for _, child in ipairs(OptionsScroll:GetChildren()) do
				if child:IsA("TextButton") then
					child:Destroy()
				end
			end

			for _, option in ipairs(options) do
				local optionStr = tostring(option)
				if filter and filter ~= "" and not string.find(string.lower(optionStr), string.lower(filter), 1, true) then
					continue
				end

				local isSelected = false
				if isMulti then
					isSelected = not not selectedSet[optionStr]
				else
					isSelected = (current == optionStr)
				end

				-- COPIED FROM GOOD UI: Indicator + horizontal layout + hover
				local OptionBtn = Instance.new("TextButton")
				OptionBtn.Name = optionStr .. "_Option"
				OptionBtn.Size = UDim2.new(1, 0, 0, 38)
				OptionBtn.BackgroundColor3 = isSelected and Color3.new(AccentColor.R * 0.25, AccentColor.G * 0.25, AccentColor.B * 0.25) or Color3.fromRGB(18, 18, 22)
				OptionBtn.BorderSizePixel = 0
				OptionBtn.Text = ""
				OptionBtn.AutoButtonColor = false
				OptionBtn.ZIndex = 203
				OptionBtn.Parent = OptionsScroll

				local OptionCorner = Instance.new("UICorner")
				OptionCorner.CornerRadius = UDim.new(0, 6)
				OptionCorner.Parent = OptionBtn

				local OptionStroke = Instance.new("UIStroke")
				OptionStroke.Color = isSelected and AccentColor or Color3.fromRGB(50, 50, 55)
				OptionStroke.Thickness = 1
				OptionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				OptionStroke.Parent = OptionBtn

				local OptLayout = Instance.new("UIListLayout")
				OptLayout.FillDirection = Enum.FillDirection.Horizontal
				OptLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
				OptLayout.Padding = UDim.new(0, 10)
				OptLayout.Parent = OptionBtn
				local OptPadding = Instance.new("UIPadding")
				OptPadding.PaddingLeft = UDim.new(0, 12)
				OptPadding.PaddingRight = UDim.new(0, 12)
				OptPadding.Parent = OptionBtn

				local Indicator = Instance.new("Frame")
				Indicator.Name = "Indicator"
				Indicator.Size = UDim2.fromOffset(16, 16)
				Indicator.BackgroundColor3 = isSelected and AccentColor or Color3.fromRGB(36, 36, 40)
				Indicator.BorderSizePixel = 0
				Indicator.LayoutOrder = 1
				Indicator.ZIndex = 204
				Indicator.Parent = OptionBtn
				local IndicatorCorner = Instance.new("UICorner")
				IndicatorCorner.CornerRadius = UDim.new(1, 0)
				IndicatorCorner.Parent = Indicator
				local IndicatorStroke = Instance.new("UIStroke")
				IndicatorStroke.Thickness = 1
				IndicatorStroke.Color = isSelected and AccentColor or Color3.fromRGB(50, 50, 55)
				IndicatorStroke.Parent = Indicator
				if isSelected then
					local Check = Instance.new("ImageLabel")
					Check.Size = UDim2.fromScale(0.8, 0.8)
					Check.AnchorPoint = Vector2.new(0.5, 0.5)
					Check.Position = UDim2.fromScale(0.5, 0.5)
					Check.BackgroundTransparency = 1
					Astral.ApplyIcon(Check, Astral.Icons.Checkmark)
					Check.ImageColor3 = Color3.fromRGB(255, 255, 255)
					Check.ZIndex = 204
					Check.Parent = Indicator
				end

				local OptionLabel = Instance.new("TextLabel")
				OptionLabel.Name = "OptLabel"
				OptionLabel.Size = UDim2.new(1, -26, 1, 0)
				OptionLabel.BackgroundTransparency = 1
				OptionLabel.Font = Enum.Font.GothamBold
				OptionLabel.Text = optionStr
				OptionLabel.TextColor3 = isSelected and AccentColor or Color3.fromRGB(232, 232, 237)
				mTS(OptionLabel, 12)
				OptionLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptionLabel.TextTruncate = Enum.TextTruncate.AtEnd
				OptionLabel.LayoutOrder = 2
				OptionLabel.ZIndex = 204
				OptionLabel.Parent = OptionBtn

				OptionBtn.MouseButton1Click:Connect(function()
					-- FIXED: High-performance subtle flash blue effect on click
					OptionBtn.BackgroundColor3 = Color3.new(AccentColor.R * 0.4, AccentColor.G * 0.4, AccentColor.B * 0.4)
					OptionStroke.Color = AccentColor
					
					task.delay(0.08, function()
						if isMulti then
							selectedSet[optionStr] = not selectedSet[optionStr]
							local selectedList = {}
							for _, opt in ipairs(options) do
								local optStr = tostring(opt)
								if selectedSet[optStr] then
									table.insert(selectedList, optStr)
								end
							end
						local newText = #selectedList > 0 and table.concat(selectedList, ", ") or translateText("None")
						buttonTextLabel.Text = newText
						SelectorPanelTitle.Text = #selectedList > 0 and (translateText(title) .. " (" .. #selectedList .. ")") or translateText(title)
							if callback then
								task.spawn(callback, selectedList)
							end
							populate(SearchInput.Text)
						else
							buttonTextLabel.Text = optionStr
							if callback then
								task.spawn(callback, option)
							end
							closeSelector()
						end
					end)
				end)

				OptionBtn.MouseEnter:Connect(function()
					if pickerOpen or selectorOpen then return end
					if not isSelected then
						TweenService:Create(OptionBtn, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(CurrentThemeName)}):Play()
					end
				end)
				OptionBtn.MouseLeave:Connect(function()
					if not isSelected then
						TweenService:Create(OptionBtn, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(CurrentThemeName)}):Play()
					end
				end)
			end
			OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, OptionsList.AbsoluteContentSize.Y + 10)
			-- keep option rows themed if a non-dark theme is active
			if CurrentThemeName and CurrentThemeName ~= "Dark" then
				applyThemeToGui(ScreenGui, AccentColor, "Dark", CurrentThemeName)
			end
		end

		activeSelectorRefresh = function()
			populate(SearchInput.Text)
		end
		Astral._OpenSelectorRefresh = function()
			SelectorPanelTitle.Text = translateText(title)
			populate(SearchInput.Text)
		end
		populate("")

		if searchConn then searchConn:Disconnect() end
		searchConn = SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
			populate(SearchInput.Text)
		end)

		selectorOpen = true
		SelectorCatcher.Visible = true
		SelectorPanel.Size = UDim2.new(0, curPanelWidth(), 1, -51)
		TweenService:Create(SelectorPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, -curPanelWidth(), 0, 51)
		}):Play()
	end

	closeSelector = function()
		selectorOpen = false
		SelectorCatcher.Visible = false
		Astral._OpenSelectorRefresh = nil
		if searchConn then
			searchConn:Disconnect()
			searchConn = nil
		end
		TweenService:Create(SelectorPanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Position = UDim2.new(1, 0, 0, 51)
		}):Play()
	end

	-- Click anywhere outside the panel to close it
	SelectorCatcher.MouseButton1Click:Connect(function()
		if closeSelector then closeSelector() end
	end)

	-- Tab Management System
	local tabs = {}
	local layoutMode = "Auto" -- "Auto" | "OneColumn" | "TwoColumn" (Settings grid picker)
	-- (Accent engine lives at the top of MakeWindow so panels can hook in during build)
	-- Saved flags: every element with Flag = "id" registers Get/Set here
	local configFlags = {}
	local categoryHeaders = {}
	local currentTab = nil
	local isCollapsed = IsMobile
	local layoutOrderCounter = 0

	local function switchTab(targetTab)
		if pickerOpen or selectorOpen then return end -- FIXED: Lock tab switching when panels are open
		if currentTab == targetTab then return end

		local directionUp = false
		if currentTab then
			if targetTab.Index < currentTab.Index then
				directionUp = true
			end
		end

		local oldTab = currentTab
		currentTab = targetTab

		-- Update Tab Button Visuals
		for _, tab in ipairs(tabs) do
			local isActive = (tab == targetTab)
			
			if isActive then
				-- match the topbar: solid accent pill, no gradient
				tab.Gradient.Enabled = false
				TweenService:Create(tab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = AccentColor,
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(tab.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Color = AccentColor,
					Transparency = 0
				}):Play()
				TweenService:Create(tab.ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
				if tab.IconLabel then
					TweenService:Create(tab.IconLabel, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end
				if tab.FallbackLabel then
					TweenService:Create(tab.FallbackLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
				end
			else
				tab.Gradient.Enabled = false

				TweenService:Create(tab.Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = Color3.fromRGB(26, 26, 30),
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(tab.Stroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Color = Color3.fromRGB(42, 42, 46),
					Transparency = 0
				}):Play()
				TweenService:Create(tab.ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = Color3.fromRGB(180, 180, 185)
				}):Play()
				if tab.IconLabel then
					TweenService:Create(tab.IconLabel, TweenInfo.new(0.2), {ImageColor3 = Color3.fromRGB(180, 180, 185)}):Play()
				end
				if tab.FallbackLabel then
					TweenService:Create(tab.FallbackLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(180, 180, 185)}):Play()
				end
			end
		end

		-- Perform Directional Slide Animations
		if oldTab then
			local oldTargetPos = directionUp and UDim2.new(0, 0, 1, 0) or UDim2.new(0, 0, -1, 0)
			local newStartPos = directionUp and UDim2.new(0, 0, -1, 0) or UDim2.new(0, 0, 1, 0)

			targetTab.Page.Position = newStartPos
			targetTab.Page.Visible = true
			-- Force full refresh once visible so right-column controls always show
			task.defer(function()
				pcall(function()
					if targetTab.Refresh then targetTab.Refresh() end
				end)
			end)

			local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			
			local oldTween = TweenService:Create(oldTab.Page, tweenInfo, {Position = oldTargetPos})
			local newTween = TweenService:Create(targetTab.Page, tweenInfo, {Position = UDim2.new(0, 0, 0, 0)})

			oldTween:Play()
			newTween:Play()

			task.delay(0.3, function()
				if currentTab ~= oldTab then
					oldTab.Page.Visible = false
				end
			end)
		else
			targetTab.Page.Position = UDim2.new(0, 0, 0, 0)
			targetTab.Page.Visible = true
			-- Force full refresh once visible so right-column controls always show
			task.defer(function()
				pcall(function()
					if targetTab.Refresh then targetTab.Refresh() end
				end)
			end)
		end
	end

	-- Window Methods
	local Window = {}

	function Window:AddCategory(name)
		name = tostring(name or "Category")
		layoutOrderCounter = layoutOrderCounter + 1

		local CategoryHeader = Instance.new("TextLabel")
		CategoryHeader.Name = name .. "_Header"
		CategoryHeader.BackgroundTransparency = 1
		CategoryHeader.Size = UDim2.new(1, 0, 0, 20)
		CategoryHeader.Font = Enum.Font.GothamBold
		CategoryHeader.Text = string.upper(name)
		CategoryHeader.TextColor3 = Color3.fromRGB(160, 160, 165)
		CategoryHeader.TextSize = 10
		CategoryHeader.TextXAlignment = Enum.TextXAlignment.Left
		CategoryHeader.TextYAlignment = Enum.TextYAlignment.Center
		CategoryHeader.LayoutOrder = layoutOrderCounter
		CategoryHeader.ZIndex = 4
		CategoryHeader.Parent = TabContainer

		table.insert(categoryHeaders, CategoryHeader)
		return CategoryHeader
	end

	function Window:MakeTab(tabConfig)
		local tabName = "Tab"
		local tabIcon = nil

		if type(tabConfig) == "table" then
			tabName = tabConfig[1] or tabConfig.Name or "Tab"
			tabIcon = parseIcon(tabConfig[2] or tabConfig.Icon)
		elseif type(tabConfig) == "string" then
			tabName = tabConfig
		end

		layoutOrderCounter = layoutOrderCounter + 1
		local tabIndex = #tabs + 1

		-- Create Tab Button
		local TabButton = Instance.new("TextButton")
		TabButton.Name = tabName .. "_TabButton"
		TabButton.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
		TabButton.BackgroundTransparency = 0
		TabButton.BorderSizePixel = 0
		TabButton.Size = UDim2.new(1, 0, 0, IsMobile and 30 or 36)
		TabButton.AutoButtonColor = false
		TabButton.Text = ""
		TabButton.ClipsDescendants = true
		TabButton.LayoutOrder = layoutOrderCounter
		TabButton.ZIndex = 10
		
		local selectionFrame = Instance.new("Frame")
		selectionFrame.BackgroundTransparency = 1
		TabButton.SelectionImageObject = selectionFrame
		TabButton.Parent = TabContainer

		local ButtonCorner = Instance.new("UICorner")
		ButtonCorner.CornerRadius = UDim.new(0, 6)
		ButtonCorner.Parent = TabButton

		local TabStroke = Instance.new("UIStroke")
		TabStroke.Name = "TabStroke"
		TabStroke.Thickness = 1
		TabStroke.Color = Color3.fromRGB(42, 42, 46)
		TabStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		TabStroke.ZIndex = 10
		TabStroke.Parent = TabButton

		local TabGradient = Instance.new("UIGradient")
		TabGradient.Name = "TabGradient"
		TabGradient.Enabled = false
		TabGradient.Parent = TabButton

		local Indicator = Instance.new("Frame")
		Indicator.Name = "Indicator"
		Indicator.Size = UDim2.new(0, 0, 0, 0)
		Indicator.Visible = false
		Indicator.Parent = TabButton

		local IconLabel = nil
		local FallbackLabel = nil

		if tabIcon then
			IconLabel = Instance.new("ImageLabel")
			IconLabel.Name = "TabIcon"
			IconLabel.BackgroundTransparency = 1
			IconLabel.AnchorPoint = Vector2.new(0, 0.5)
			IconLabel.Position = UDim2.new(0, 6, 0.5, 0)
			IconLabel.Size = UDim2.new(0, IsMobile and 18 or 26, 0, IsMobile and 18 or 26)
			Astral.ApplyIcon(IconLabel, tabIcon)
			IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			IconLabel.ScaleType = Enum.ScaleType.Fit
			IconLabel.ZIndex = 11
			IconLabel.Parent = TabButton
		else
			FallbackLabel = Instance.new("TextLabel")
			FallbackLabel.Name = "FallbackIcon"
			FallbackLabel.BackgroundTransparency = 1
			FallbackLabel.AnchorPoint = Vector2.new(0, 0.5)
			FallbackLabel.Position = UDim2.new(0, 6, 0.5, 0)
			FallbackLabel.Size = UDim2.new(0, IsMobile and 16 or 22, 0, IsMobile and 16 or 22)
			FallbackLabel.Font = Enum.Font.GothamBold
			FallbackLabel.Text = string.sub(tabName, 1, 1)
			FallbackLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
			FallbackLabel.TextSize = IsMobile and 11 or 14
			FallbackLabel.TextTransparency = isCollapsed and 0 or 1
			FallbackLabel.ZIndex = 11
			FallbackLabel.Parent = TabButton
		end

		local ButtonText = Instance.new("TextLabel")
		ButtonText.Name = "ButtonText"
		ButtonText.BackgroundTransparency = 1
		
		local hasIcon = not not (tabIcon or FallbackLabel)
		ButtonText.Position = UDim2.new(0, hasIcon and (IsMobile and 30 or 40) or 8, 0, 0)
		ButtonText.Size = UDim2.new(1, hasIcon and (IsMobile and -38 or -48) or -16, 1, 0)
		ButtonText.Font = Enum.Font.GothamBold
		tr(ButtonText, tabName)
		ButtonText.TextColor3 = Color3.fromRGB(180, 180, 185)
		mTS(ButtonText, 12)
		ButtonText.TextXAlignment = Enum.TextXAlignment.Left
		ButtonText.TextYAlignment = Enum.TextYAlignment.Center
		ButtonText.TextTruncate = Enum.TextTruncate.AtEnd
		ButtonText.TextTransparency = isCollapsed and 1 or 0
		ButtonText.ZIndex = 11
		ButtonText.Parent = TabButton

		-- Create Tab Page Frame
		local TabPage = Instance.new("Frame")
		TabPage.Name = tabName .. "_Page"
		TabPage.BackgroundTransparency = 1
		TabPage.BorderSizePixel = 0
		TabPage.Position = UDim2.new(0, 0, 1, 0)
		TabPage.Size = UDim2.new(1, 0, 1, 0)
		TabPage.Visible = false
		TabPage.Parent = ContentContainer
		-- 横向 sub-tab 栏，首次调用 MakeSubTab 时才显示
		local SubTabBarHeight = IsMobile and 46 or 56
		local SubTabBtnHeight = IsMobile and 30 or 36
		local SubTabBar = Instance.new("Frame")
		SubTabBar.Name = "SubTabBar"
		SubTabBar.BackgroundColor3 = Color3.fromRGB(24, 24, 30)
		SubTabBar.BackgroundTransparency = 0
		SubTabBar.BorderSizePixel = 0
		SubTabBar.Size = UDim2.new(1, -24, 0, SubTabBarHeight)
		SubTabBar.Position = UDim2.new(0, 12, 0, 6)
		SubTabBar.ClipsDescendants = true
		SubTabBar.Visible = false
		SubTabBar.ZIndex = 5
		SubTabBar.Parent = TabPage

		local SubTabBarCorner = Instance.new("UICorner")
		SubTabBarCorner.CornerRadius = UDim.new(0, 10)
		SubTabBarCorner.Parent = SubTabBar

		local SubTabBarStroke = Instance.new("UIStroke")
		SubTabBarStroke.Color = Color3.fromRGB(60, 60, 70)
		SubTabBarStroke.Thickness = 1
		SubTabBarStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		SubTabBarStroke.Parent = SubTabBar

		-- (rounded floating card needs no separator line)

		local SubTabScroll = Instance.new("ScrollingFrame")
		SubTabScroll.Name = "SubTabScroll"
		SubTabScroll.BackgroundTransparency = 1
		SubTabScroll.BorderSizePixel = 0
		SubTabScroll.Size = UDim2.new(1, 0, 1, 0)
		SubTabScroll.Position = UDim2.new(0, 0, 0, 0)
		SubTabScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		SubTabScroll.ScrollBarThickness = 0
		SubTabScroll.ScrollingDirection = Enum.ScrollingDirection.X
		SubTabScroll.ZIndex = 6
		SubTabScroll.Parent = SubTabBar

		local SubTabScrollLayout = Instance.new("UIListLayout")
		SubTabScrollLayout.FillDirection = Enum.FillDirection.Horizontal
		SubTabScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
		SubTabScrollLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		SubTabScrollLayout.Padding = UDim.new(0, 6)
		SubTabScrollLayout.Parent = SubTabScroll

		local SubTabScrollPad = Instance.new("UIPadding")
		SubTabScrollPad.PaddingLeft = UDim.new(0, 12)
		SubTabScrollPad.PaddingRight = UDim.new(0, 12)
		SubTabScrollPad.Parent = SubTabScroll

		SubTabScrollLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			SubTabScroll.CanvasSize = UDim2.new(0, SubTabScrollLayout.AbsoluteContentSize.X + 16, 0, 0)
		end)

		local subTabs = {}
		local currentSubTab = nil
		local subTabBarShown = false
		local currentBuildSubTab = 0

		-- Create Scrolling Container inside TabPage (FIXED: Changed from PageScroll to ScrollingFrame)
		local PageScroll = Instance.new("ScrollingFrame")
		PageScroll.Name = "PageScroll"
		PageScroll.BackgroundTransparency = 1
		PageScroll.BorderSizePixel = 0
		PageScroll.Size = UDim2.new(1, 0, 1, 0)
		PageScroll.Position = UDim2.new(0, 0, 0, 0)
		PageScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		PageScroll.ScrollBarThickness = 3
		PageScroll.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 55)
		PageScroll.Parent = TabPage

		local PagePadding = Instance.new("UIPadding")
		PagePadding.PaddingLeft = UDim.new(0, 12)
		PagePadding.PaddingRight = UDim.new(0, 12)
		PagePadding.PaddingTop = UDim.new(0, 12)
		PagePadding.PaddingBottom = UDim.new(0, 12)
		PagePadding.Parent = PageScroll

		-- =========================================================================
		-- HIGH-PERFORMANCE MASONRY (2-COLUMN) LAYOUT ENGINE
		-- =========================================================================
		local LeftColumn = Instance.new("Frame")
		LeftColumn.Name = "LeftColumn"
		LeftColumn.BackgroundTransparency = 1
		LeftColumn.Size = UDim2.new(0.5, -5, 0, 0)
		LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
		LeftColumn.Parent = PageScroll

		local LeftLayout = Instance.new("UIListLayout")
		LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		LeftLayout.Padding = UDim.new(0, 10)
		LeftLayout.Parent = LeftColumn

		local RightColumn = Instance.new("Frame")
		RightColumn.Name = "RightColumn"
		RightColumn.BackgroundTransparency = 1
		RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
		RightColumn.Size = UDim2.new(0.5, -5, 0, 0)
		RightColumn.AutomaticSize = Enum.AutomaticSize.Y
		RightColumn.Parent = PageScroll

		local RightLayout = Instance.new("UIListLayout")
		RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		RightLayout.Padding = UDim.new(0, 10)
		RightLayout.Parent = RightColumn

		local elements = {}
		-- Forced layout mode: "Auto" follows width, "OneColumn"/"TwoColumn" force it
		local function isSingleColumnNow()
			if layoutMode == "OneColumn" then return true end
			if layoutMode == "TwoColumn" then return false end
			-- Invisible tabs report 0 width during build: fall back to the real
			-- window width so columns never collapse to zero and hide content.
			local w = PageScroll.AbsoluteSize.X
			if w < 10 then w = refW end
			return w < 380
		end
		local function GetTargetColumn()
			local lc, rc = 0, 0
			for _, c in ipairs(LeftColumn:GetChildren()) do if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then lc += 1 end end
			for _, c in ipairs(RightColumn:GetChildren()) do if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then rc += 1 end end
			return lc <= rc and LeftColumn or RightColumn
		end

		local function distributeElements()
			local isSingleColumn = isSingleColumnNow()

			local leftHeight = 0
			local rightHeight = 0

			for _, item in ipairs(elements) do
				if isSingleColumn then
					item.Frame.Parent = LeftColumn
					item.Frame.Size = UDim2.new(1, 0, 0, item.Height)
				else
					-- Explicit Left/Right choice wins over auto-balancing
					local forced = item.ForcedColumn
					if forced == LeftColumn then
						item.Frame.Parent = LeftColumn
						item.Frame.Size = UDim2.new(1, 0, 0, item.Height)
						leftHeight = leftHeight + item.Height + 10
					elseif forced == RightColumn then
						item.Frame.Parent = RightColumn
						item.Frame.Size = UDim2.new(1, 0, 0, item.Height)
						rightHeight = rightHeight + item.Height + 10
					elseif leftHeight <= rightHeight then
						item.Frame.Parent = LeftColumn
						item.Frame.Size = UDim2.new(1, 0, 0, item.Height)
						leftHeight = leftHeight + item.Height + 10
					else
						item.Frame.Parent = RightColumn
						item.Frame.Size = UDim2.new(1, 0, 0, item.Height)
						rightHeight = rightHeight + item.Height + 10
					end
				end
			end
		end

		local canvasDebounce = false
		local function updateCanvas()
			if canvasDebounce then return end
			canvasDebounce = true
			task.defer(function()
				local isSingleColumn = isSingleColumnNow()
				local maxHeight = isSingleColumn and LeftLayout.AbsoluteContentSize.Y or math.max(LeftLayout.AbsoluteContentSize.Y, RightLayout.AbsoluteContentSize.Y)
				PageScroll.CanvasSize = UDim2.new(0, 0, 0, maxHeight + 24)
				canvasDebounce = false
			end)
		end

		-- Full refresh: column visibility + distribution + canvas.
		-- Called on tab show, resize and mode switch so right-column
		-- controls can never stay invisible.
		local function refreshTabColumns()
			if isSingleColumnNow() then
				LeftColumn.Size = UDim2.new(1, 0, 0, 0)
				RightColumn.Visible = false
			else
				LeftColumn.Size = UDim2.new(0.5, -5, 0, 0)
				RightColumn.Size = UDim2.new(0.5, -5, 0, 0)
				RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
				RightColumn.Visible = true
			end
		end

		LeftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
		RightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas)
		PageScroll:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
			refreshTabColumns()
			distributeElements()
		end)

		-- sub-tab 过滤：只显示当前 sub-tab 注册的元素，SubTabIdx = 0 的常驻
		local function applySubTabFilter()
			for _, item in ipairs(elements) do
				local idx = item.SubTabIdx or 0
				item.Frame.Visible = (idx == 0) or (idx == currentSubTab)
			end
			updateCanvas()
		end

		-- sub-tab 切换：按钮高亮 + 重排可见元素
		local function switchSubTab(idx)
			if currentSubTab == idx then return end
			currentSubTab = idx
			for _, st in ipairs(subTabs) do
				local on = (st.Index == idx)
				TweenService:Create(st.Button, TweenInfo.new(0.18), {
					BackgroundColor3 = on and AccentColor or Color3.fromRGB(32, 32, 40),
					BackgroundTransparency = 0
				}):Play()
				TweenService:Create(st.BStroke, TweenInfo.new(0.18), {
					Color = Color3.fromRGB(70, 70, 80),
					Transparency = 0.5
				}):Play()
				TweenService:Create(st.BText, TweenInfo.new(0.18), {
					TextColor3 = on and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 168)
				}):Play()
			end
			applySubTabFilter()
			task.defer(function()
				pcall(function()
					refreshTabColumns()
					distributeElements()
					updateCanvas()
				end)
			end)
		end

		local tabData = {
			Button = TabButton,
			Corner = ButtonCorner,
			Stroke = TabStroke,
			Gradient = TabGradient,
			ButtonText = ButtonText,
			Indicator = Indicator,
			IconLabel = IconLabel,
			FallbackLabel = FallbackLabel,
			Page = TabPage,
			Index = tabIndex,
			Elements = {},
			PageScroll = PageScroll,
			LeftColumn = LeftColumn,
			RightColumn = RightColumn,
			LeftLayout = LeftLayout,
			RightLayout = RightLayout,
			Refresh = function()
				refreshTabColumns()
				distributeElements()
				updateCanvas()
				task.delay(0.35, function() pcall(updateCanvas) end)
			end
		}

		table.insert(tabs, tabData)

		-- Hover Effects
		TabButton.MouseEnter:Connect(function()
			if pickerOpen or selectorOpen then return end -- FIXED: Disable hover effects when panels are open
			if currentTab ~= tabData then
				TweenService:Create(TabButton, TweenInfo.new(0.15), {
					BackgroundColor3 = Color3.fromRGB(32, 32, 34)
				}):Play()
				TweenService:Create(TabStroke, TweenInfo.new(0.15), {
					Color = Color3.fromRGB(52, 52, 56)
				}):Play()
				TweenService:Create(ButtonText, TweenInfo.new(0.15), {
					TextColor3 = Color3.fromRGB(255, 255, 255)
				}):Play()
			end
		end)

		TabButton.MouseLeave:Connect(function()
			if pickerOpen or selectorOpen then return end -- FIXED: Disable hover effects when panels are open
			if currentTab ~= tabData then
				TweenService:Create(TabButton, TweenInfo.new(0.15), {
					BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")
				}):Play()
				TweenService:Create(TabStroke, TweenInfo.new(0.15), {
					Color = Color3.fromRGB(42, 42, 46)
				}):Play()
				TweenService:Create(ButtonText, TweenInfo.new(0.15), {
					TextColor3 = Color3.fromRGB(180, 180, 185)
				}):Play()
			end
		end)

		TabButton.MouseButton1Click:Connect(function()
			if not pickerOpen and not selectorOpen then -- FIXED: Prevent tab switching when panels are open
				switchTab(tabData)
			end
		end)

		if tabIndex == 1 then
			-- Never let a tab-switch error abort the whole UI build
			local okSwitch, errSwitch = pcall(switchTab, tabData)
			if not okSwitch then
				warn("[Astral] first tab switch failed: " .. tostring(errSwitch))
			end
		end

		-- Tab Object API
		local TabObject = {}
		local elementCounter = 0

		local function registerElement(frame, height, position)
			elementCounter = elementCounter + 1
			frame.LayoutOrder = elementCounter
			-- Explicit "Left"/"Right" wins, otherwise auto-balance by count
			local forced = nil
			if position == "Left" then
				forced = LeftColumn
			elseif position == "Right" then
				forced = RightColumn
			end
			local col = forced or GetTargetColumn()
			frame.Parent = col
			frame.Size = UDim2.new(1,0,0,height)
			-- 记下所属 sub-tab，切换时按 idx 决定显隐
			frame:SetAttribute("SubTabIdx", currentBuildSubTab)
			table.insert(elements, {Frame = frame, Height = height, OriginalColumn = col, ForcedColumn = forced, SubTabIdx = currentBuildSubTab})
			table.insert(tabData.Elements, elements[#elements])
			-- if a non-dark theme is active, theme this new element too (idempotent)
			if CurrentThemeName and CurrentThemeName ~= "Dark" then
				applyThemeToGui(ScreenGui, AccentColor, "Dark", CurrentThemeName)
			end
			applySubTabFilter()
		end

		-- AddButton: COPIED FROM GOOD UI (Script_with_Example) - right_arrow + hover, no click_icon
		function TabObject:AddButton(buttonConfig)
			buttonConfig = buttonConfig or {}
			local title = buttonConfig.Title or "Button"
			local description = buttonConfig.Description
			local callback = buttonConfig.Callback or function() end
			local icon = parseIcon(buttonConfig.Icon)
			local hasDesc = description and description ~= ""
			local calculatedHeight = IsMobile and 50 or 64

			local ButtonFrame = Instance.new("TextButton")
			ButtonFrame.Name = title .. "_Button"
			ButtonFrame.BackgroundColor3 = Color3.fromRGB(33, 33, 39)
			ButtonFrame.BorderSizePixel = 0
			ButtonFrame.Size = UDim2.new(1, 0, 0, calculatedHeight)
			ButtonFrame.Text = ""
			ButtonFrame.AutoButtonColor = false
			ButtonFrame.Parent = nil

			local ButtonCorner = Instance.new("UICorner")
			ButtonCorner.CornerRadius = UDim.new(0, 8)
			ButtonCorner.Parent = ButtonFrame

			local ButtonStroke = Instance.new("UIStroke")
			ButtonStroke.Thickness = 1
			ButtonStroke.Color = Color3.fromRGB(50, 50, 55)
			ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ButtonStroke.Parent = ButtonFrame

			local ButtonScale = Instance.new("UIScale")
			ButtonScale.Scale = 1
			ButtonScale.Parent = ButtonFrame

			if icon then
				local IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, 10, 0.5, IsMobile and -16 or -21)
				IconContainer.Size = UDim2.new(0, IsMobile and 32 or 42, 0, IsMobile and 32 or 42)
				IconContainer.Parent = ButtonFrame
				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 6)
				IconCorner.Parent = IconContainer
				local IconStroke = Instance.new("UIStroke")
				IconStroke.Thickness = 1.5
				IconStroke.Color = Color3.fromRGB(255, 255, 255)
				IconStroke.Transparency = 0.3
				IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconStroke.Parent = IconContainer
				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, IsMobile and 20 or 26, 0, IsMobile and 20 or 26)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = icon and UDim2.new(0, 62, 0, 0) or UDim2.new(0, 14, 0, 0)
			TextContainer.Size = icon and UDim2.new(1, -116, 1, 0) or UDim2.new(1, -76, 1, 0)
			TextContainer.Parent = ButtonFrame
			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TextListLayout.Padding = UDim.new(0, 1)
			TextListLayout.Parent = TextContainer
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 16)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 11)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextWrapped = false
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.Parent = TextContainer
			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, 14)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, 10)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextWrapped = true
				DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
				DescLabel.Parent = TextContainer
			end

			-- Good UI right_arrow (not click_icon) with hover
			local ActionArrow = Instance.new("ImageLabel")
			ActionArrow.Name = "ActionArrow"
			ActionArrow.BackgroundTransparency = 1
			ActionArrow.Position = UDim2.new(1, -34, 0.5, -10)
			ActionArrow.Size = UDim2.new(0, 20, 0, 20)
			ActionArrow.Image = Astral.Icons.right_arrow
			ActionArrow.ImageColor3 = Color3.fromRGB(160, 160, 165)
			ActionArrow.ScaleType = Enum.ScaleType.Fit
			ActionArrow.Parent = ButtonFrame

			-- Lock state: gray overlay + lock icon, clicks + hover disabled
			local locked = buttonConfig.Locked or false
			local LockOverlay = Instance.new("Frame")
			LockOverlay.Name = "LockOverlay"
			LockOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
			LockOverlay.BackgroundTransparency = 0.55
			LockOverlay.BorderSizePixel = 0
			LockOverlay.Size = UDim2.new(1, 0, 1, 0)
			LockOverlay.Visible = locked
			LockOverlay.ZIndex = 12
			LockOverlay.Active = true
			LockOverlay.Parent = ButtonFrame

			local LockOverlayCorner = Instance.new("UICorner")
			LockOverlayCorner.CornerRadius = UDim.new(0, 8)
			LockOverlayCorner.Parent = LockOverlay

			local LockIcon = Instance.new("ImageLabel")
			LockIcon.Name = "LockIcon"
			LockIcon.BackgroundTransparency = 1
			LockIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			LockIcon.Position = UDim2.new(1, -24, 0.5, 0)
			LockIcon.Size = UDim2.new(0, 20, 0, 20)
			LockIcon.Image = "rbxassetid://15117261700"
			LockIcon.ImageColor3 = Color3.fromRGB(180, 180, 185)
			LockIcon.ScaleType = Enum.ScaleType.Fit
			LockIcon.Visible = locked
			LockIcon.ZIndex = 13
			LockIcon.Parent = ButtonFrame

			local function applyLock()
				LockOverlay.Visible = locked
				LockIcon.Visible = locked
				ActionArrow.Visible = not locked
			end
			applyLock()

			ButtonFrame.MouseButton1Click:Connect(function()
				if locked then return end
				task.spawn(callback)
			end)
			ButtonFrame.InputBegan:Connect(function(input)
				if locked then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					TweenService:Create(ButtonScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
				end
			end)
			ButtonFrame.InputEnded:Connect(function(input)
				if locked then return end
				if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
					TweenService:Create(ButtonScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
				end
			end)
			ButtonFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				if locked then return end
				TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ActionArrow, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			end)
			ButtonFrame.MouseLeave:Connect(function()
				if locked then return end
				TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = themeStroke(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ActionArrow, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(160, 160, 165)}):Play()
			end)

			registerElement(ButtonFrame, calculatedHeight, buttonConfig.Position)

			local ButtonController = {}
			function ButtonController:SetLocked(state)
				locked = not not state
				applyLock()
			end
			function ButtonController:IsLocked()
				return locked
			end
			return ButtonController
		end

		-- AddToggle creates an interactive toggle card.
		function TabObject:AddToggle(toggleConfig)
			toggleConfig = toggleConfig or {}
			local title = toggleConfig.Title or "Toggle"
			local description = toggleConfig.Description
			local default = toggleConfig.Default or false
			local callback = toggleConfig.Callback or function() end
			local icon = parseIcon(toggleConfig.Icon)
			local hasDesc = description and description ~= ""
			local calculatedHeight = IsMobile and (hasDesc and 72 or 48) or 64
			local switchTrackWidth = IsMobile and 44 or 68
			local switchTrackHeight = IsMobile and 26 or 32
			local switchThumbSize = IsMobile and 20 or 28
			local switchInset = IsMobile and 2 or 3
			local switchThumbOffPosition = UDim2.new(0, switchInset, 0.5, -switchThumbSize / 2)
			local switchThumbOnPosition = UDim2.new(1, -switchThumbSize - switchInset, 0.5, -switchThumbSize / 2)
			local TargetColumn = GetTargetColumn()
			local ToggleFrame = Instance.new("TextButton")
			ToggleFrame.Name = title .. "_Toggle"
			ToggleFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			ToggleFrame.BorderSizePixel = 0
			ToggleFrame.Text = ""
			ToggleFrame.AutoButtonColor = false
			ToggleFrame.LayoutOrder = elementCounter + 1
			local ToggleCorner = Instance.new("UICorner")
			ToggleCorner.CornerRadius = UDim.new(0, 8)
			ToggleCorner.Parent = ToggleFrame
			local ToggleStroke = Instance.new("UIStroke")
			ToggleStroke.Thickness = 1
			ToggleStroke.Color = Color3.fromRGB(50, 50, 55)
			ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ToggleStroke.Parent = ToggleFrame
			if icon then
				local IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, IsMobile and 8 or 10, 0.5, IsMobile and -13 or -21)
				IconContainer.Size = UDim2.new(0, IsMobile and 26 or 42, 0, IsMobile and 26 or 42)
				IconContainer.Parent = ToggleFrame
				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 6)
				IconCorner.Parent = IconContainer
				local IconStroke = Instance.new("UIStroke")
				IconStroke.Thickness = 1.5
				IconStroke.Color = Color3.fromRGB(255, 255, 255)
				IconStroke.Transparency = 0.3
				IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconStroke.Parent = IconContainer
				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, IsMobile and 16 or 26, 0, IsMobile and 16 or 26)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end
			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = icon and UDim2.new(0, IsMobile and 40 or 62, 0, 0) or UDim2.new(0, IsMobile and 12 or 14, 0, 0)
			TextContainer.Size = icon and UDim2.new(1, IsMobile and -104 or -146, 1, 0) or UDim2.new(1, IsMobile and -76 or -96, 1, 0)
			TextContainer.Parent = ToggleFrame
			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TextListLayout.Padding = UDim.new(0, 1)
			TextListLayout.Parent = TextContainer
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, IsMobile and 28 or 16)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 11)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextWrapped = IsMobile
			TitleLabel.TextTruncate = IsMobile and Enum.TextTruncate.None or Enum.TextTruncate.AtEnd
			TitleLabel.Parent = TextContainer
			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 24)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, 10)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextWrapped = true
				DescLabel.Parent = TextContainer
			end

			local SwitchTrack = Instance.new("Frame")
			SwitchTrack.Name = "SwitchTrack"
			SwitchTrack.BackgroundColor3 = default and AccentColor or Color3.fromRGB(45, 45, 50)
			SwitchTrack.BorderSizePixel = 0
			SwitchTrack.Position = UDim2.new(1, -switchTrackWidth - 10, 0.5, -switchTrackHeight / 2)
			SwitchTrack.Size = UDim2.new(0, switchTrackWidth, 0, switchTrackHeight)
			SwitchTrack.Parent = ToggleFrame
			local TrackCorner = Instance.new("UICorner")
			TrackCorner.CornerRadius = UDim.new(0, 8)
			TrackCorner.Parent = SwitchTrack

			local TrackStroke = Instance.new("UIStroke")
			TrackStroke.Color = Color3.fromRGB(62, 62, 72)
			TrackStroke.Thickness = 1.2
			TrackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			TrackStroke.Parent = SwitchTrack
			local SwitchThumb = Instance.new("Frame")
			SwitchThumb.Name = "SwitchThumb"
			SwitchThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SwitchThumb.BorderSizePixel = 0
			SwitchThumb.Position = default and switchThumbOnPosition or switchThumbOffPosition
			SwitchThumb.Size = UDim2.new(0, switchThumbSize, 0, switchThumbSize)
			SwitchThumb.Parent = SwitchTrack
			local ThumbCorner = Instance.new("UICorner")
			ThumbCorner.CornerRadius = UDim.new(0, 6)
			ThumbCorner.Parent = SwitchThumb
			local enabled = default
			local function toggle(state)
				if state == nil then enabled = not enabled else enabled = state end
				local targetTrackColor = enabled and AccentColor or Color3.fromRGB(45, 45, 50)
				local targetThumbPos = enabled and switchThumbOnPosition or switchThumbOffPosition
				TweenService:Create(SwitchTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetTrackColor}):Play()
				TweenService:Create(SwitchThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetThumbPos}):Play()
				task.spawn(callback, enabled)
			end
			ToggleFrame.MouseButton1Click:Connect(function() toggle() end)
			ToggleFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
			end)
			ToggleFrame.MouseLeave:Connect(function()
				TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = themeStroke(Window.ThemeName or "Dark")}):Play()
			end)
			registerElement(ToggleFrame, calculatedHeight, toggleConfig.Position)

			-- Follow theme accent while ON
			onAccentChange(function(c)
				if enabled then
					SwitchTrack.BackgroundColor3 = c
				end
			end)
			local ToggleController = {}
			function ToggleController:Set(state) toggle(state) end
			function ToggleController:Get() return enabled end
			if toggleConfig.Flag and toggleConfig.Flag ~= "" then
				table.insert(configFlags, {Flag = toggleConfig.Flag, Kind = "toggle",
					Get = function() return enabled end,
					Set = function(v) ToggleController:Set(v) end})
			end
			table.insert(Astral.Registry, ToggleController)
			return ToggleController
		end

		-- AddTick Implementation (FIXED: Standardized to exactly 60px height)
		function TabObject:AddTick(tickConfig)
			tickConfig = tickConfig or {}
			local title = tickConfig.Title or "Tick"
			local description = tickConfig.Description
			local default = tickConfig.Default or false
			local callback = tickConfig.Callback or function() end
			local icon = parseIcon(tickConfig.Icon)

			local hasDesc = description and description ~= ""
			local calculatedHeight = 60 -- FIXED: Standardized to exactly 60px height

			local TickFrame = Instance.new("TextButton")
			TickFrame.Name = title .. "_Tick"
			TickFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			TickFrame.BorderSizePixel = 0
			TickFrame.Text = ""
			TickFrame.AutoButtonColor = false

			local TickCorner = Instance.new("UICorner")
			TickCorner.CornerRadius = UDim.new(0, 12) -- Made corner radius bigger
			TickCorner.Parent = TickFrame

			local TickStroke = Instance.new("UIStroke")
			TickStroke.Color = Color3.fromRGB(50, 50, 55)
			TickStroke.Thickness = 1.2
			TickStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			TickStroke.Parent = TickFrame

			-- Left Icon Container (Enlarged with High-Contrast Outline) - OPTIONAL
			local IconContainer = nil
			if icon then
				IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, 8, 0.5, IsMobile and -17 or -22)
				IconContainer.Size = UDim2.new(0, IsMobile and 34 or 44, 0, IsMobile and 34 or 44)
				IconContainer.Parent = TickFrame

				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 8)
				IconCorner.Parent = IconContainer

				local IconContainerStroke = Instance.new("UIStroke")
				IconContainerStroke.Color = Color3.fromRGB(70, 70, 75) -- FIXED: Light gray outline instead of black
				IconContainerStroke.Thickness = 1.5
				IconContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconContainerStroke.Parent = IconContainer

				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, IsMobile and 22 or 30, 0, IsMobile and 22 or 30)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			-- Text Container (Title & Description)
			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = icon and UDim2.new(0, 62, 0, 0) or UDim2.new(0, 14, 0, 0)
			TextContainer.Size = icon and UDim2.new(1, -120, 1, 0) or UDim2.new(1, -80, 1, 0)
			TextContainer.Parent = TickFrame

			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TextListLayout.Padding = UDim.new(0, 2)
			TextListLayout.Parent = TextContainer

			-- Title Label
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 16)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 11)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.TextWrapped = false -- Prevents text overflow
			TitleLabel.Parent = TextContainer

			-- Description Label (Optional) - FIXED: Parented to TextContainer instead of TickFrame to prevent overlap
			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, 14)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, 10)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
				DescLabel.Parent = TextContainer -- FIXED: Corrected parent to TextContainer
			end


			-- Checkbox Container (Enlarged & Moved Left to avoid border)
			local Checkbox = Instance.new("Frame")
			Checkbox.Name = "Checkbox"
			Checkbox.BackgroundColor3 = default and AccentColor or Color3.fromRGB(22, 22, 26) -- Fills with accent Color
			Checkbox.BorderSizePixel = 0
			Checkbox.Position = UDim2.new(1, -52, 0.5, -22) -- FIXED: Centered perfectly in 60px height
			Checkbox.Size = UDim2.new(0, 44, 0, 44) -- FIXED: Sized perfectly for 60px height
			Checkbox.ZIndex = 11
			Checkbox.Parent = TickFrame

			local CheckboxCorner = Instance.new("UICorner")
			CheckboxCorner.CornerRadius = UDim.new(0, 8) -- Squircle look matching image
			CheckboxCorner.Parent = Checkbox

			local CheckboxStroke = Instance.new("UIStroke")
			CheckboxStroke.Name = "CheckboxStroke"
			CheckboxStroke.Thickness = 1.5
			CheckboxStroke.Color = default and AccentColor or Color3.fromRGB(55, 55, 60) -- Accent stroke when active
			CheckboxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			CheckboxStroke.Parent = Checkbox

			-- Checkmark Icon (Enlarged to 24x24 inside the checkbox)
			local Checkmark = Instance.new("ImageLabel")
			Checkmark.Name = "Checkmark"
			Checkmark.BackgroundTransparency = 1
			Checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
			Checkmark.Position = UDim2.new(0.5, 0, 0.5, 0)
			Checkmark.Size = UDim2.new(0, 30, 0, 30) -- FIXED: Sized perfectly inside checkbox
			Checkmark.Image = Astral.Icons.Checkmark -- Uses requested ID 12690727184
			Checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
			Checkmark.ImageTransparency = default and 0 or 1
			Checkmark.ScaleType = Enum.ScaleType.Fit
			Checkmark.ZIndex = 12
			Checkmark.Parent = Checkbox

			local CheckmarkScale = Instance.new("UIScale")
			CheckmarkScale.Scale = default and 1 or 0
			CheckmarkScale.Parent = Checkmark

			local enabled = default

			local function toggle(state)
				if state == nil then
					enabled = not enabled
				else
					enabled = state
				end

				local targetBoxColor = enabled and AccentColor or Color3.fromRGB(22, 22, 26) -- Fills with accent Color
				local targetStrokeColor = enabled and AccentColor or Color3.fromRGB(45, 45, 52) -- Accent stroke when active
				local targetCheckScale = enabled and 1 or 0
				local targetCheckTransparency = enabled and 0 or 1

				TweenService:Create(Checkbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundColor3 = targetBoxColor
				}):Play()

				TweenService:Create(CheckboxStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Color = targetStrokeColor
				}):Play()

				TweenService:Create(CheckmarkScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Scale = targetCheckScale
				}):Play()

				TweenService:Create(Checkmark, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageTransparency = targetCheckTransparency
				}):Play()

				task.spawn(callback, enabled)
			end

			TickFrame.MouseButton1Click:Connect(function()
				toggle()
			end)

			TickFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(TickFrame, TweenInfo.new(0.15), {
					BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")
				}):Play()
				TweenService:Create(TickStroke, TweenInfo.new(0.15), {
					Color = themeStrokeHover(Window.ThemeName or "Dark")
				}):Play()
			end)

			TickFrame.MouseLeave:Connect(function()
				TweenService:Create(TickFrame, TweenInfo.new(0.15), {
					BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")
				}):Play()
				TweenService:Create(TickStroke, TweenInfo.new(0.15), {
					Color = themeStroke(Window.ThemeName or "Dark")
				}):Play()
			end)

			registerElement(TickFrame, calculatedHeight, tickConfig.Position)

			-- Follow theme accent while ON
			onAccentChange(function(c)
				if enabled then
					Checkbox.BackgroundColor3 = c
					CheckboxStroke.Color = c
				end
			end)

			local TickController = {}
			function TickController:Set(state)
				toggle(state)
			end
			function TickController:Get() return enabled end
			if tickConfig.Flag and tickConfig.Flag ~= "" then
				table.insert(configFlags, {Flag = tickConfig.Flag, Kind = "tick",
					Get = function() return enabled end,
					Set = function(v) TickController:Set(v) end})
			end
			
			-- Register controller to allow global reset
			table.insert(Astral.Registry, TickController)
			
			return TickController
		end

		-- AddColorpicker Implementation (FIXED: Standardized to exactly 60px height)
		function TabObject:AddColorpicker(pickerConfig)
			pickerConfig = pickerConfig or {}
			local title = pickerConfig.Title or "Colorpicker"
			local description = pickerConfig.Description or "Customize the UI theme"
			local default = pickerConfig.Default or Color3.fromRGB(0, 125, 255)
			local callback = pickerConfig.Callback or function() end
			local icon = parseIcon(pickerConfig.Icon)

			local hasDesc = description and description ~= ""
			local calculatedHeight = 60 -- FIXED: Standardized to exactly 60px height

			local PickerFrame = Instance.new("TextButton")
			PickerFrame.Name = title .. "_Colorpicker"
			PickerFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			PickerFrame.BorderSizePixel = 0
			PickerFrame.Text = ""
			PickerFrame.AutoButtonColor = false

			local PickerCorner = Instance.new("UICorner")
			PickerCorner.CornerRadius = UDim.new(0, 12)
			PickerCorner.Parent = PickerFrame

			local PickerStroke = Instance.new("UIStroke")
			PickerStroke.Color = Color3.fromRGB(50, 50, 55)
			PickerStroke.Thickness = 1.2
			PickerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			PickerStroke.Parent = PickerFrame

			-- Left Icon Container (Enlarged with High-Contrast Outline) - OPTIONAL
			local IconContainer = nil
			if icon then
				IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, 8, 0.5, IsMobile and -17 or -22)
				IconContainer.Size = UDim2.new(0, IsMobile and 34 or 44, 0, IsMobile and 34 or 44)
				IconContainer.Parent = PickerFrame

				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 8)
				IconCorner.Parent = IconContainer

				local IconContainerStroke = Instance.new("UIStroke")
				IconContainerStroke.Color = Color3.fromRGB(70, 70, 75) -- FIXED: Light gray outline instead of black
				IconContainerStroke.Thickness = 1.5
				IconContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconContainerStroke.Parent = IconContainer

				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, IsMobile and 22 or 30, 0, IsMobile and 22 or 30)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			-- Text Container (Title & Description)
			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = icon and UDim2.new(0, 60, 0, 0) or UDim2.new(0, 12, 0, 0) -- FIXED: Adjusted offset
			TextContainer.Size = icon and UDim2.new(1, -146, 1, 0) or UDim2.new(1, -90, 1, 0) -- FIXED: Adjusted size
			TextContainer.Parent = PickerFrame

			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TextListLayout.Padding = UDim.new(0, 2)
			TextListLayout.Parent = TextContainer

			-- Title Label
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 16)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 14)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.Parent = TextContainer

			-- Description Label (Matches image reference)
			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, 14)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, 10)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
				DescLabel.Parent = TextContainer
			end

			-- Color Preview Box (Right Side) - FIXED: Made into a wide rounded rectangle matching image reference
			local ColorPreview = Instance.new("Frame")
			ColorPreview.Name = "ColorPreview"
			ColorPreview.Size = UDim2.new(0, 64, 0, 30) -- FIXED: Sized perfectly for 60px height
			ColorPreview.Position = UDim2.new(1, -76, 0.5, -15) -- FIXED: Centered perfectly in 60px height
			ColorPreview.BackgroundColor3 = default
			ColorPreview.ZIndex = 11
			ColorPreview.Parent = PickerFrame

			local PreviewCorner = Instance.new("UICorner")
			PreviewCorner.CornerRadius = UDim.new(0, 8) -- Rounded corners matching image reference
			PreviewCorner.Parent = ColorPreview

			local PreviewStroke = Instance.new("UIStroke")
			PreviewStroke.Color = Color3.fromRGB(50, 50, 55)
			PreviewStroke.Thickness = 1.2
			PreviewStroke.Parent = ColorPreview

			local myColor = default

			PickerFrame.MouseButton1Click:Connect(function()
				openColorPicker(myColor, function(c)
					myColor = c
					ColorPreview.BackgroundColor3 = c
					task.spawn(callback, c)
				end, ColorPreview)
			end)

			PickerFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(PickerFrame, TweenInfo.new(0.15), {
					BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")
				}):Play()
				TweenService:Create(PickerStroke, TweenInfo.new(0.15), {
					Color = themeStrokeHover(Window.ThemeName or "Dark")
				}):Play()
			end)

			PickerFrame.MouseLeave:Connect(function()
				TweenService:Create(PickerFrame, TweenInfo.new(0.15), {
					BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")
				}):Play()
				TweenService:Create(PickerStroke, TweenInfo.new(0.15), {
					Color = themeStroke(Window.ThemeName or "Dark")
				}):Play()
			end)

			registerElement(PickerFrame, calculatedHeight, pickerConfig.Position)

			local ColorpickerController = {}
			function ColorpickerController:Set(color)
				local isColor = (typeof(color) == "Color3") or (type(color) == "table" and color.R ~= nil and color.G ~= nil and color.B ~= nil)
				if not isColor then return end
				myColor = color
				ColorPreview.BackgroundColor3 = color
				task.spawn(callback, color)
			end
			function ColorpickerController:Get() return myColor end
			if pickerConfig.Flag and pickerConfig.Flag ~= "" then
				table.insert(configFlags, {Flag = pickerConfig.Flag, Kind = "color",
					Get = function() return myColor end,
					Set = function(v) ColorpickerController:Set(v) end})
			end

			return ColorpickerController
		end

		-- AddSlider Implementation (FIXED: Standardized to exactly 60px height)
		function TabObject:AddSlider(sliderConfig)
			sliderConfig = sliderConfig or {}
			local title = sliderConfig.Title or "Slider"
			local min = sliderConfig.Min or 1
			local max = sliderConfig.Max or 100
			local increase = sliderConfig.Increase or 1
			local default = sliderConfig.Default or min
			local callback = sliderConfig.Callback or function() end
			local icon = parseIcon(sliderConfig.Icon)
			local calculatedHeight = IsMobile and 56 or 64
			local icoSz = IsMobile and 32 or 42
			local icoOff = IsMobile and -16 or -21
			local icoInner = IsMobile and 20 or 26
			local textLeft = icon and (IsMobile and 48 or 62) or (IsMobile and 8 or 12)
			local titleTop = IsMobile and 6 or 10
			local SliderFrame = Instance.new("Frame")
			SliderFrame.Name = title .. "_Slider"
			SliderFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			SliderFrame.BorderSizePixel = 0
			SliderFrame.ClipsDescendants = true
			local SliderCorner = Instance.new("UICorner")
			SliderCorner.CornerRadius = UDim.new(0, 8)
			SliderCorner.Parent = SliderFrame
			local SliderStroke = Instance.new("UIStroke")
			SliderStroke.Color = Color3.fromRGB(50, 50, 55)
			SliderStroke.Thickness = 1
			SliderStroke.Parent = SliderFrame
			if icon then
				local IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.Position = UDim2.new(0, 10, 0.5, icoOff)
				IconContainer.Size = UDim2.new(0, icoSz, 0, icoSz)
				IconContainer.Parent = SliderFrame
				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 6)
				IconCorner.Parent = IconContainer
				local IconStroke = Instance.new("UIStroke")
				IconStroke.Thickness = 1.5
				IconStroke.Color = Color3.fromRGB(255, 255, 255)
				IconStroke.Transparency = 0.3
				IconStroke.Parent = IconContainer
				local IconLabel = Instance.new("ImageLabel")
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, icoInner, 0, icoInner)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Position = icon and UDim2.new(0, textLeft, 0, titleTop) or UDim2.new(0, 12, 0, titleTop)
			TitleLabel.Size = icon and UDim2.new(1, -(textLeft + 72), 0, 16) or UDim2.new(1, -80, 0, 16)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 12)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.Parent = SliderFrame
			local ValueBox = Instance.new("Frame")
			ValueBox.Name = "ValueBox"
			ValueBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
			ValueBox.Position = UDim2.new(1, IsMobile and -52 or -64, 0, titleTop)
			ValueBox.Size = UDim2.new(0, IsMobile and 40 or 48, 0, IsMobile and 18 or 20)
			ValueBox.Parent = SliderFrame
			local ValueCorner = Instance.new("UICorner")
			ValueCorner.CornerRadius = UDim.new(0, 4)
			ValueCorner.Parent = ValueBox
			local ValueStroke = Instance.new("UIStroke")
			ValueStroke.Color = Color3.fromRGB(50, 50, 55)
			ValueStroke.Parent = ValueBox
			local ValueInput = Instance.new("TextBox")
			ValueInput.Name = "ValueInput"
			ValueInput.BackgroundTransparency = 1
			ValueInput.Size = UDim2.new(1, 0, 1, 0)
			ValueInput.Font = Enum.Font.GothamBold
			ValueInput.Text = tostring(default)
			ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
			ValueInput.TextSize = IsMobile and 9 or 10
			ValueInput.Parent = ValueBox
			local trackLeft = icon and textLeft or 12
			local trackRightPad = icon and (IsMobile and 58 or 82) or (IsMobile and 28 or 32)
			local trackTop = IsMobile and 28 or 34
			local trackH = IsMobile and 14 or 16
			local thumbW = IsMobile and 16 or 20
			local thumbH = IsMobile and 16 or 22
			local SliderTrack = Instance.new("TextButton")
			SliderTrack.Name = "SliderTrack"
			SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
			SliderTrack.Position = UDim2.new(0, trackLeft, 0, trackTop)
			SliderTrack.Size = UDim2.new(1, -trackLeft - trackRightPad, 0, trackH)
			SliderTrack.Text = ""
			SliderTrack.AutoButtonColor = false
			SliderTrack.Parent = SliderFrame
			local TrackCorner = Instance.new("UICorner")
			TrackCorner.CornerRadius = UDim.new(0, 4)
			TrackCorner.Parent = SliderTrack
			local SliderFill = Instance.new("Frame")
			SliderFill.Name = "SliderFill"
			SliderFill.BackgroundColor3 = AccentColor
			SliderFill.Size = UDim2.new((default - min)/math.max(1,max-min),0,1,0)
			SliderFill.Parent = SliderTrack
			local FillCorner = Instance.new("UICorner")
			FillCorner.CornerRadius = UDim.new(0, 4)
			FillCorner.Parent = SliderFill
			local SliderThumb = Instance.new("Frame")
			SliderThumb.Name = "SliderThumb"
			SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
			SliderThumb.AnchorPoint = Vector2.new(0.5,0.5)
			SliderThumb.Position = UDim2.new((default - min)/math.max(1,max-min),0,0.5,0)
			SliderThumb.Size = UDim2.fromOffset(thumbW, thumbH)
			SliderThumb.Parent = SliderTrack
			local ThumbCorner = Instance.new("UICorner")
			ThumbCorner.CornerRadius = UDim.new(0, 3)
			ThumbCorner.Parent = SliderThumb
			local ThumbStroke = Instance.new("UIStroke")
			ThumbStroke.Color = Color3.fromRGB(0,0,0)
			ThumbStroke.Thickness = 1
			ThumbStroke.Parent = SliderThumb
			local dragging=false; local cur=default
			local function upd(p) TweenService:Create(SliderFill,TweenInfo.new(0.08),{Size=UDim2.new(p,0,1,0)}):Play(); TweenService:Create(SliderThumb,TweenInfo.new(0.08),{Position=UDim2.new(p,0,0.5,0)}):Play() end
			local function setFromInput(input)
				local rel=math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X)/SliderTrack.AbsoluteSize.X,0,1)
				local raw=min+(max-min)*rel; local stepped=math.round(raw/increase)*increase; stepped=math.clamp(stepped,min,max); cur=stepped; ValueInput.Text=tostring(cur); upd((cur-min)/math.max(1,max-min)); task.spawn(callback,cur)
			end
			SliderTrack.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=true; setFromInput(i) end end)
			UserInputService.InputChanged:Connect(function(i) if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then setFromInput(i) end end)
			UserInputService.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dragging=false end end)
			ValueInput.FocusLost:Connect(function() local n=tonumber(ValueInput.Text); if n then n=math.clamp(math.round(n/increase)*increase,min,max); cur=n; upd((cur-min)/math.max(1,max-min)); task.spawn(callback,cur) end; ValueInput.Text=tostring(cur) end)
			SliderFrame.MouseEnter:Connect(function() TweenService:Create(SliderFrame,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(36,36,40)}):Play(); TweenService:Create(SliderStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(70,70,75)}):Play() end)

			-- Follow theme accent
			onAccentChange(function(c)
				SliderFill.BackgroundColor3 = c
			end)
			SliderFrame.MouseLeave:Connect(function() TweenService:Create(SliderFrame,TweenInfo.new(0.15),{BackgroundColor3=Color3.fromRGB(26,26,30)}):Play(); TweenService:Create(SliderStroke,TweenInfo.new(0.15),{Color=Color3.fromRGB(50,50,55)}):Play() end)
			registerElement(SliderFrame, calculatedHeight, sliderConfig.Position)
			local C={}; function C:Set(v) v=math.clamp(v,min,max); cur=v; ValueInput.Text=tostring(v); upd((v-min)/math.max(1,max-min)); task.spawn(callback,v) end; function C:Get() return cur end; if sliderConfig.Flag and sliderConfig.Flag ~= "" then table.insert(configFlags, {Flag = sliderConfig.Flag, Kind = "slider", Get = function() return cur end, Set = function(v) C:Set(v) end}) end; return C
		end


		-- AddSelector: tall card (title + value box), clear selected state, mobile-compact
		function TabObject:AddSelector(selectorConfig)
			selectorConfig = selectorConfig or {}
			local title = selectorConfig.Title or "Selector"
			local description = selectorConfig.Description
			local options = selectorConfig.Options or {}
			local default = selectorConfig.Default
			local callback = selectorConfig.Callback or function() end
			local icon = parseIcon(selectorConfig.Icon)
			local searchEnabled = selectorConfig.Search or false
			local multi = selectorConfig.Multi or false
			local hasDesc = description and description ~= "" or false

			local calculatedHeight = IsMobile and 76 or 84
			local titleSize = 11
			local descSize = 11
			local textY = IsMobile and 6 or 8
			local valueY = calculatedHeight - 38
			local valueH = 28

			local selectedOptions = {}
			local function applyDefault(def)
				table.clear(selectedOptions)
				if multi then
					if type(def) == "table" then
						for _, val in ipairs(def) do selectedOptions[tostring(val)] = true end
					elseif def ~= nil and tostring(def) ~= "" then
						selectedOptions[tostring(def)] = true
					end
				else
					if def ~= nil and tostring(def) ~= "" then
						selectedOptions[tostring(def)] = true
					end
				end
			end
			applyDefault(default)

			local SelectorFrame = Instance.new("Frame")
			SelectorFrame.Name = title .. "_Selector"
			SelectorFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			SelectorFrame.BorderSizePixel = 0
			SelectorFrame.Size = UDim2.new(1, 0, 0, calculatedHeight)

			local SelectorCorner = Instance.new("UICorner")
			SelectorCorner.CornerRadius = UDim.new(0, 8)
			SelectorCorner.Parent = SelectorFrame

			local SelectorStroke = Instance.new("UIStroke")
			SelectorStroke.Color = Color3.fromRGB(50, 50, 55)
			SelectorStroke.Thickness = 1
			SelectorStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			SelectorStroke.Parent = SelectorFrame

			if icon then
				local IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, 10, 0.5, IsMobile and -16 or -21)
				IconContainer.Size = UDim2.new(0, IsMobile and 32 or 42, 0, IsMobile and 32 or 42)
				IconContainer.Parent = SelectorFrame

				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 6)
				IconCorner.Parent = IconContainer

				local IconContainerStroke = Instance.new("UIStroke")
				IconContainerStroke.Color = Color3.fromRGB(255, 255, 255)
				IconContainerStroke.Transparency = 0.3
				IconContainerStroke.Thickness = 1.5
				IconContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconContainerStroke.Parent = IconContainer

				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, IsMobile and 20 or 26, 0, IsMobile and 20 or 26)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = icon and UDim2.new(0, 62, 0, textY) or UDim2.new(0, 12, 0, textY)
			TextContainer.Size = icon and UDim2.new(1, -72, 0, 34) or UDim2.new(1, -24, 0, 34)
			TextContainer.Parent = SelectorFrame

			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TextListLayout.Padding = UDim.new(0, 1)
			TextListLayout.Parent = TextContainer

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 16)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, titleSize)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.Parent = TextContainer

			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, 16)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, descSize)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
				DescLabel.Parent = TextContainer
			end

			-- Value box: bright selected text + count badge + arrow, clear at a glance
			local ValueBox = Instance.new("TextButton")
			ValueBox.Name = "ValueBox"
			ValueBox.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
			ValueBox.BorderSizePixel = 0
			ValueBox.Position = icon and UDim2.new(0, 62, 0, valueY) or UDim2.new(0, 12, 0, valueY)
			ValueBox.Size = icon and UDim2.new(1, -72, 0, valueH) or UDim2.new(1, -24, 0, valueH)
			ValueBox.Text = ""
			ValueBox.AutoButtonColor = false
			ValueBox.Parent = SelectorFrame

			local ValueCorner = Instance.new("UICorner")
			ValueCorner.CornerRadius = UDim.new(0, 6)
			ValueCorner.Parent = ValueBox

			local ValueStroke = Instance.new("UIStroke")
			ValueStroke.Color = Color3.fromRGB(50, 50, 55)
			ValueStroke.Thickness = 1
			ValueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ValueStroke.Parent = ValueBox

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Name = "ValueLabel"
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.Size = UDim2.new(1, -76, 1, 0)
			ValueLabel.Position = UDim2.new(0, 10, 0, 0)
			ValueLabel.Font = Enum.Font.GothamBold
			ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			mTS(ValueLabel, 11)
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
			ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
			ValueLabel.Parent = ValueBox

			-- Multi-select count badge (perfect circle, like the toggle knob)
			local CountBadge = Instance.new("Frame")
			CountBadge.Name = "CountBadge"
			CountBadge.BackgroundColor3 = AccentColor
			CountBadge.BorderSizePixel = 0
			CountBadge.AnchorPoint = Vector2.new(1, 0.5)
			CountBadge.Position = UDim2.new(1, -36, 0.5, 0)
			CountBadge.Size = UDim2.new(0, 22, 0, 22)
			CountBadge.Visible = false
			CountBadge.ZIndex = 12
			CountBadge.Parent = ValueBox

			local BadgeCorner = Instance.new("UICorner")
			BadgeCorner.CornerRadius = UDim.new(0, 7)
			BadgeCorner.Parent = CountBadge

			local BadgeLabel = Instance.new("TextLabel")
			BadgeLabel.BackgroundTransparency = 1
			BadgeLabel.Size = UDim2.new(1, 0, 1, 0)
			BadgeLabel.Font = Enum.Font.GothamBold
			BadgeLabel.Text = ""
			BadgeLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			mTS(BadgeLabel, 12)
			BadgeLabel.TextXAlignment = Enum.TextXAlignment.Center
			BadgeLabel.ZIndex = 13
			BadgeLabel.Parent = CountBadge

			local function selectedList()
				local list = {}
				for _, opt in ipairs(options) do
					local s = tostring(opt)
					if selectedOptions[s] then table.insert(list, s) end
				end
				return list
			end

			local function updateValueLabel()
				local list = selectedList()
				if #list == 0 then
					ValueLabel.Text = translateText("Select...")
					ValueLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				elseif #list > 2 then
					ValueLabel.Text = string.format("%s, %s " .. translateText("(+%d more)"), list[1], list[2], #list - 2)
					ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				else
					ValueLabel.Text = table.concat(list, ", ")
					ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
				end
				if multi then
					CountBadge.Visible = #list > 0
					BadgeLabel.Text = (#list > 9) and "9+" or tostring(#list)
				else
					CountBadge.Visible = false
				end
			end
			table.insert(languageRefreshers, updateValueLabel)
			updateValueLabel()

			local DropIcon = Instance.new("ImageLabel")
			DropIcon.Name = "DropIcon"
			DropIcon.BackgroundTransparency = 1
			DropIcon.AnchorPoint = Vector2.new(0.5, 0.5)
			DropIcon.Position = UDim2.new(1, -16, 0.5, 0)
			DropIcon.Size = UDim2.new(0, 12, 0, 12)
			DropIcon.Image = Astral.Icons.down_arrow
			DropIcon.ImageColor3 = Color3.fromRGB(160, 160, 165)
			DropIcon.Parent = ValueBox

			local function currentText()
				local list = selectedList()
				if multi then
					return #list > 0 and table.concat(list, ", ") or "None"
				end
				return list[1]
			end

			local function openPanel()
				openSelector(title, options, currentText(), searchEnabled, function(pick)
					table.clear(selectedOptions)
					if multi and type(pick) == "table" then
						for _, v in ipairs(pick) do selectedOptions[tostring(v)] = true end
					elseif pick ~= nil and tostring(pick) ~= "" and tostring(pick) ~= "None" then
						selectedOptions[tostring(pick)] = true
					end
					updateValueLabel()
					task.spawn(callback, pick)
				end, ValueLabel, multi)
			end

			ValueBox.MouseButton1Click:Connect(openPanel)
			-- Mobile: only open on tap, not on scroll/drag
			do
				local touchStartPos = nil
				SelectorFrame.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						touchStartPos = input.Position
					end
				end)
				SelectorFrame.InputEnded:Connect(function(input)
					if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and touchStartPos then
						local delta = (input.Position - touchStartPos).Magnitude
						if delta < 10 then
							openPanel()
						end
						touchStartPos = nil
					end
				end)
			end

			ValueBox.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(SelectorFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(SelectorStroke, TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
			end)
			ValueBox.MouseLeave:Connect(function()
				TweenService:Create(SelectorFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(SelectorStroke, TweenInfo.new(0.15), {Color = themeStroke(Window.ThemeName or "Dark")}):Play()
			end)

			registerElement(SelectorFrame, calculatedHeight, selectorConfig.Position)

			-- Count badge follows the accent color
			onAccentChange(function(c)
				CountBadge.BackgroundColor3 = c
			end)

			local SelectorController = {}
			function SelectorController:Set(value)
				applyDefault(value)
				updateValueLabel()
				task.spawn(callback, value)
			end
			function SelectorController:SetOptions(newOptions, newDefault)
				table.clear(options)
				if type(newOptions) == "table" then
					for _, v in ipairs(newOptions) do table.insert(options, v) end
				end
				for s in pairs(selectedOptions) do
					local stillThere = false
					for _, opt in ipairs(options) do
						if tostring(opt) == s then stillThere = true; break end
					end
					if not stillThere then selectedOptions[s] = nil end
				end
				if newDefault ~= nil then applyDefault(newDefault) end
				updateValueLabel()
				if selectorOpen and activeSelectorRefresh then
					pcall(activeSelectorRefresh)
				end
			end
			function SelectorController:Get()
				if multi then
					local list = {}
					for _, opt in ipairs(options) do
						local s = tostring(opt)
						if selectedOptions[s] then table.insert(list, s) end
					end
					return list
				end
				for s in pairs(selectedOptions) do return s end
				return nil
			end
			if selectorConfig.Flag and selectorConfig.Flag ~= "" then
				table.insert(configFlags, {Flag = selectorConfig.Flag, Kind = "select",
					Get = function()
						if multi then
							local list = {}
							for _, opt in ipairs(options) do
								local s = tostring(opt)
								if selectedOptions[s] then table.insert(list, s) end
							end
							return list
						end
						for s in pairs(selectedOptions) do return s end
						return nil
					end,
					Set = function(v) SelectorController:Set(v) end})
			end

			return SelectorController
		end
		TabObject.Addselector = TabObject.AddSelector -- Alias to support lowercase calls


		-- =========================================================================
		-- TEXTBOX (icon + title on top, big box under)
		-- =========================================================================
		function TabObject:AddTextbox(textboxConfig)
			textboxConfig = textboxConfig or {}
			local title = textboxConfig.Title or "Textbox"
			local description = textboxConfig.Description
			local placeholder = textboxConfig.Placeholder or "Type here..."
			local default = textboxConfig.Default or ""
			local clearOnFocus = textboxConfig.ClearOnFocus
			if clearOnFocus == nil then clearOnFocus = textboxConfig.ClearOnTextFocus end
			if clearOnFocus == nil then clearOnFocus = false end
			local callback = textboxConfig.Callback or function() end
			local icon = parseIcon(textboxConfig.Icon)
			local hasDesc = description and description ~= "" or false

			local boxSize = IsMobile and 44 or 48
			local titleSize = 13
			local descSize = 11
			local pad = IsMobile and 6 or 8
			local inputH = IsMobile and 46 or 52

			-- Auto height: measure the description so long text grows the card, short text keeps it small
			local textH = 18
			if hasDesc then
				local measureW = IsMobile and 180 or 260
				local ok, ts = pcall(function()
					return game:GetService("TextService"):GetTextSize(description, descSize, Enum.Font.Gotham, Vector2.new(measureW, 10000))
				end)
				if ok and ts then
					textH = 18 + 1 + math.clamp(math.ceil(ts.Y), 12, 110)
				else
					textH = 18 + 1 + 14
				end
			end
			local topH = math.max(boxSize, textH)
			local inputY = pad + topH + pad
			local calculatedHeight = inputY + inputH + 10

			local TextboxFrame = Instance.new("Frame")
			TextboxFrame.Name = title .. "_Textbox"
			TextboxFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			TextboxFrame.BorderSizePixel = 0
			TextboxFrame.Size = UDim2.new(1, 0, 0, calculatedHeight)

			local FrameCorner = Instance.new("UICorner")
			FrameCorner.CornerRadius = UDim.new(0, 8)
			FrameCorner.Parent = TextboxFrame

			local TextboxStroke = Instance.new("UIStroke")
			TextboxStroke.Thickness = 1
			TextboxStroke.Color = Color3.fromRGB(50, 50, 55)
			TextboxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			TextboxStroke.Parent = TextboxFrame

			-- Top row: icon + title (+ description), one aligned grid (12px margins, 10px gaps)
			if icon then
				local IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, 12, 0, pad)
				IconContainer.Size = UDim2.new(0, boxSize, 0, boxSize)
				IconContainer.Parent = TextboxFrame

				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 8)
				IconCorner.Parent = IconContainer

				local IconStroke = Instance.new("UIStroke")
				IconStroke.Thickness = 1.5
				IconStroke.Color = Color3.fromRGB(255, 255, 255)
				IconStroke.Transparency = 0.3
				IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconStroke.Parent = IconContainer

				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, boxSize - 18, 0, boxSize - 18)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			local textX = icon and (22 + boxSize) or 12
			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = UDim2.new(0, textX, 0, pad)
			TextContainer.Size = UDim2.new(1, -textX - 12, 0, textH)
			TextContainer.Parent = TextboxFrame

			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Top
			TextListLayout.Padding = UDim.new(0, 1)
			TextListLayout.Parent = TextContainer

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 18)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, titleSize)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.Parent = TextContainer

			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, 16)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, descSize)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
				DescLabel.Parent = TextContainer
			end

			-- Big input box under them, full width
			local InputBox = Instance.new("TextBox")
			InputBox.Name = "InputBox"
			InputBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36)
			InputBox.BorderSizePixel = 0
			InputBox.Position = UDim2.new(0, 12, 0, inputY)
			InputBox.Size = UDim2.new(1, -24, 0, inputH)
			InputBox.Font = Enum.Font.Gotham
			InputBox.PlaceholderText = placeholder
			InputBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
			InputBox.Text = default
			InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
			mTS(InputBox, 12)
			InputBox.TextXAlignment = Enum.TextXAlignment.Left
			InputBox.TextTruncate = Enum.TextTruncate.AtEnd
			InputBox.ClearTextOnFocus = clearOnFocus
			InputBox.ClipsDescendants = true
			InputBox.Parent = TextboxFrame

			local InputCorner = Instance.new("UICorner")
			InputCorner.CornerRadius = UDim.new(0, 6)
			InputCorner.Parent = InputBox

			local InputStroke = Instance.new("UIStroke")
			InputStroke.Thickness = 1.5
			InputStroke.Color = Color3.fromRGB(100, 100, 105)
			InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			InputStroke.Parent = InputBox

			local InputPadding = Instance.new("UIPadding")
			InputPadding.PaddingLeft = UDim.new(0, 12)
			InputPadding.PaddingRight = UDim.new(0, 12)
			InputPadding.Parent = InputBox

			InputBox.Focused:Connect(function()
				TweenService:Create(InputBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}):Play()
				TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(100, 100, 105)}):Play()
			end)

			InputBox.FocusLost:Connect(function()
				TweenService:Create(InputBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 36)}):Play()
				TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(100, 100, 105)}):Play()
				-- Only fire when the text actually changed (clicking in/out does nothing)
				if InputBox.Text ~= lastText then
					lastText = InputBox.Text
					task.spawn(callback, InputBox.Text)
				end
			end)

			TextboxFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(TextboxFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(TextboxStroke, TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(130, 130, 135)}):Play()
			end)

			TextboxFrame.MouseLeave:Connect(function()
				TweenService:Create(TextboxFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(TextboxStroke, TweenInfo.new(0.15), {Color = themeStroke(Window.ThemeName or "Dark")}):Play()
				if not InputBox:IsFocused() then
					TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(100, 100, 105)}):Play()
				end
			end)

			registerElement(TextboxFrame, calculatedHeight, textboxConfig.Position)

			local lastText = default

			-- Correction pass: after render, fix height from the REAL wrapped text
			-- (measurement can be off on narrow columns; long desc grows downward)
			if hasDesc then
				task.spawn(function()
					RunService.RenderStepped:Wait()
					RunService.RenderStepped:Wait()
					local ok, bounds = pcall(function() return DescLabel.TextBounds.Y end)
					if not ok or not bounds then return end
					local need = 18 + 1 + math.ceil(bounds) + 6
					if math.abs(need - textH) > 4 then
						textH = need
						local topH2 = math.max(boxSize, textH)
						local inputY2 = pad + topH2 + pad
						local h2 = inputY2 + inputH + 10
						TextContainer.Size = UDim2.new(1, -textX - 12, 0, textH)
						DescLabel.Size = UDim2.new(1, 0, 0, textH - 19)
						InputBox.Position = UDim2.new(0, 12, 0, inputY2)
						TextboxFrame.Size = UDim2.new(1, 0, 0, h2)
						for _, item in ipairs(elements) do
							if item.Frame == TextboxFrame then
								item.Height = h2
								break
							end
						end
						distributeElements()
					end
				end)
			end

			local TextboxController = {}
			function TextboxController:Set(text)
				InputBox.Text = tostring(text)
				lastText = InputBox.Text
				task.spawn(callback, InputBox.Text)
			end
			function TextboxController:Get()
				return InputBox.Text
			end
			if textboxConfig.Flag and textboxConfig.Flag ~= "" then
				table.insert(configFlags, {Flag = textboxConfig.Flag, Kind = "text",
					Get = function() return InputBox.Text end,
					Set = function(v) TextboxController:Set(v) end})
			end

			return TextboxController
		end

		-- =========================================================================
		-- NEW LABEL IMPLEMENTATION (STATIC DISPLAY ELEMENT WITH OPTIONAL ICONS)
		-- =========================================================================
		function TabObject:AddLabel(labelConfig)
			labelConfig = labelConfig or {}
			local title = labelConfig.Title or "Label"
			local description = labelConfig.Description
			local icon = parseIcon(labelConfig.Icon)
			local callback = labelConfig.Callback or function() end
			local titleSize = tonumber(labelConfig.TextSize) or 14
			local descSize = tonumber(labelConfig.DescSize) or 15

			local hasDesc = description and description ~= ""
			local calculatedHeight = IsMobile and 50 or 64

			local LabelFrame = Instance.new("Frame")
			LabelFrame.Name = title .. "_Label"
			LabelFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			LabelFrame.BorderSizePixel = 0

			local LabelCorner = Instance.new("UICorner")
			LabelCorner.CornerRadius = UDim.new(0, 12)
			LabelCorner.Parent = LabelFrame

			local LabelStroke = Instance.new("UIStroke")
			LabelStroke.Color = Color3.fromRGB(50, 50, 55)
			LabelStroke.Thickness = 1.2
			LabelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			LabelStroke.Parent = LabelFrame

			-- Left Icon Container (Enlarged with High-Contrast Outline) - OPTIONAL
			local IconContainer = nil
			if icon then
				IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, 8, 0.5, IsMobile and -17 or -22)
				IconContainer.Size = UDim2.new(0, IsMobile and 34 or 44, 0, IsMobile and 34 or 44)
				IconContainer.Parent = LabelFrame

				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 8)
				IconCorner.Parent = IconContainer

				local IconContainerStroke = Instance.new("UIStroke")
				IconContainerStroke.Color = Color3.fromRGB(70, 70, 75)
				IconContainerStroke.Thickness = 1.5
				IconContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconContainerStroke.Parent = IconContainer

				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, IsMobile and 22 or 30, 0, IsMobile and 22 or 30)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			local leftInset = icon and 60 or 12

			-- Right-hand STATUS BADGE (hidden until SetStatus is called)
			local StatusBadge = Instance.new("Frame")
			StatusBadge.Name = "StatusBadge"
			StatusBadge.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
			StatusBadge.BorderSizePixel = 0
			StatusBadge.AnchorPoint = Vector2.new(1, 0.5)
			StatusBadge.Position = UDim2.new(1, -12, 0.5, 0)
			StatusBadge.Size = UDim2.new(0, 0, 0, 30)
			StatusBadge.AutomaticSize = Enum.AutomaticSize.X
			StatusBadge.Visible = false
			StatusBadge.Parent = LabelFrame

			local StatusCorner = Instance.new("UICorner")
			StatusCorner.CornerRadius = UDim.new(0, 8)
			StatusCorner.Parent = StatusBadge

			local StatusStroke = Instance.new("UIStroke")
			StatusStroke.Color = Color3.fromRGB(70, 70, 75)
			StatusStroke.Thickness = 1.2
			StatusStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			StatusStroke.Parent = StatusBadge

			local StatusPad = Instance.new("UIPadding")
			StatusPad.PaddingLeft = UDim.new(0, 8)
			StatusPad.PaddingRight = UDim.new(0, 9)
			StatusPad.Parent = StatusBadge

			local StatusLayout = Instance.new("UIListLayout")
			StatusLayout.FillDirection = Enum.FillDirection.Horizontal
			StatusLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			StatusLayout.SortOrder = Enum.SortOrder.LayoutOrder
			StatusLayout.Padding = UDim.new(0, 5)
			StatusLayout.Parent = StatusBadge

			local StatusIcon = Instance.new("ImageLabel")
			StatusIcon.Name = "StatusIcon"
			StatusIcon.BackgroundTransparency = 1
			StatusIcon.Size = UDim2.new(0, 18, 0, 18)
			StatusIcon.LayoutOrder = 1
			StatusIcon.ScaleType = Enum.ScaleType.Fit
			StatusIcon.ImageColor3 = Color3.fromRGB(46, 204, 113)
			StatusIcon.Parent = StatusBadge

			local StatusText = Instance.new("TextLabel")
			StatusText.Name = "StatusText"
			StatusText.BackgroundTransparency = 1
			StatusText.AutomaticSize = Enum.AutomaticSize.X
			StatusText.Size = UDim2.new(0, 0, 1, 0)
			StatusText.LayoutOrder = 2
			StatusText.Font = Enum.Font.GothamBold
			StatusText.Text = ""
			StatusText.TextColor3 = Color3.fromRGB(46, 204, 113)
			regText(StatusText, 13)
			StatusText.TextXAlignment = Enum.TextXAlignment.Left
			StatusText.Parent = StatusBadge

			-- Text Container (Title & Description)
			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = UDim2.new(0, leftInset, 0, 0)
			TextContainer.Size = UDim2.new(1, -(leftInset + 12), 1, 0)
			TextContainer.Parent = LabelFrame

			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TextListLayout.Padding = UDim.new(0, 2)
			TextListLayout.Parent = TextContainer

			-- Title Label (bigger by default, override with TextSize =)
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, titleSize + 5)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, titleSize)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.TextWrapped = false
			TitleLabel.Parent = TextContainer

			-- Description Label (created on demand, cached in a local)
			local DescLabel = nil
			local function ensureDesc(text)
				if not DescLabel then
					DescLabel = Instance.new("TextLabel")
					DescLabel.Name = "Description"
					DescLabel.BackgroundTransparency = 1
					DescLabel.Size = UDim2.new(1, 0, 0, descSize + 4)
					DescLabel.Font = Enum.Font.Gotham
					DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
					regText(DescLabel, descSize)
					DescLabel.TextXAlignment = Enum.TextXAlignment.Left
					DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
					DescLabel.Parent = TextContainer
				end
				DescLabel.Text = tostring(text)
			end
			if hasDesc then ensureDesc(description) end

			-- Keep the text clear of the status badge whenever it is visible
			local function applyStatusLayout()
				local rightInset = 12
				if StatusBadge.Visible then
					rightInset = 12 + StatusBadge.AbsoluteSize.X + 10
				end
				TextContainer.Size = UDim2.new(1, -(leftInset + rightInset), 1, 0)
			end
			StatusBadge:GetPropertyChangedSignal("AbsoluteSize"):Connect(applyStatusLayout)

			-- Hover white effect like toggle (good UI)
			LabelFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(LabelFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(LabelStroke, TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
				pcall(function() local s = IconContainer and IconContainer:FindFirstChild("UIStroke"); if s then TweenService:Create(s, TweenInfo.new(0.15), {Transparency = 0}):Play() end end)
			end)
			LabelFrame.MouseLeave:Connect(function()
				TweenService:Create(LabelFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(LabelStroke, TweenInfo.new(0.15), {Color = themeStroke(Window.ThemeName or "Dark")}):Play()
				pcall(function() local s = IconContainer and IconContainer:FindFirstChild("UIStroke"); if s then TweenService:Create(s, TweenInfo.new(0.15), {Transparency = 0.3}):Play() end end)
			end)

			registerElement(LabelFrame, calculatedHeight, labelConfig.Position)

			local LabelController = {}

			local STATUS_DEFS = {
				good    = { Icon = "Checkmark", Color = Color3.fromRGB(46, 204, 113),  Text = "SPAWNED" },
				bad     = { Icon = "Close",     Color = Color3.fromRGB(231, 76, 60),   Text = "NOT SPAWNED" },
				waiting = { Icon = "timer",     Color = Color3.fromRGB(255, 196, 40),  Text = "WAITING" },
			}
			local function tint(c, f)
				return Color3.fromRGB(math.floor(c.R * 255 * f), math.floor(c.G * 255 * f), math.floor(c.B * 255 * f))
			end

			function LabelController:SetText(newText)
				TitleLabel.Text = tostring(newText)
			end
			LabelController.SetTitle = LabelController.SetText

			function LabelController:SetDescription(newDesc)
				ensureDesc(newDesc)
			end

			function LabelController:SetIcon(newIcon)
				if IconContainer and IconContainer:FindFirstChild("Icon") then
					Astral.ApplyIcon(IconContainer.Icon, parseIcon(newIcon))
				end
			end

			-- Status: "good" (green check) | "bad" (red cross) | "waiting" (timer) | "none"
			function LabelController:SetStatus(status, text)
				local def = STATUS_DEFS[status]
				if not def then
					StatusBadge.Visible = false
					applyStatusLayout()
					return
				end
				StatusBadge.Visible = true
				Astral.ApplyIcon(StatusIcon, parseIcon(def.Icon))
				StatusIcon.ImageColor3 = def.Color
				StatusStroke.Color = def.Color
				StatusBadge.BackgroundColor3 = tint(def.Color, 0.16)
				StatusText.Text = (text ~= nil) and tostring(text) or def.Text
				StatusText.TextColor3 = def.Color
				applyStatusLayout()
			end

			-- Live countdown written into the description.
			--   :SetCountdown(300)                  -> counts DOWN 05:00 -> 00:00
			--   :SetCountdown(300, "down")          -> same, explicit
			--   :SetCountdown(0, "up")              -> counts UP 00:00 -> ...
			--   :SetCountdown(300, function() end)  -> down, callback at zero
			--   :SetCountdown(0, "up", function() end)
			local countdownToken = 0
			local function fmtTime(sec)
				sec = math.max(0, math.floor(sec))
				if sec >= 3600 then
					return string.format("%02d:%02d:%02d", math.floor(sec / 3600), math.floor((sec % 3600) / 60), sec % 60)
				end
				return string.format("%02d:%02d", math.floor(sec / 60), sec % 60)
			end
			-- Options table form lets you control the wording + where it shows:
			--   label:SetCountdown(300, { Prefix = "Respawns in ", Suffix = "", Where = "description" })
			--   Where = "description" (default) or "badge"
			function LabelController:SetCountdown(seconds, modeOrOpts, onDone)
				local mode, done, prefix, suffix, where = "down", nil, "", "", "description"
				if type(modeOrOpts) == "function" then
					done = modeOrOpts
				elseif type(modeOrOpts) == "string" then
					mode = modeOrOpts
					done = onDone
				elseif type(modeOrOpts) == "table" then
					mode = modeOrOpts.Mode or "down"
					done = modeOrOpts.OnDone or onDone
					prefix = modeOrOpts.Prefix or ""
					suffix = modeOrOpts.Suffix or ""
					where = modeOrOpts.Where or "description"
				end
				countdownToken = countdownToken + 1
				local myToken = countdownToken
				local value = math.max(0, math.floor(tonumber(seconds) or 0))
				local function write(txt)
					if where == "badge" then
						LabelController:SetStatus("waiting", prefix .. txt .. suffix)
					else
						LabelController:SetDescription(prefix .. txt .. suffix)
					end
				end
				task.spawn(function()
					while true do
						if countdownToken ~= myToken then return end
						write(fmtTime(value))
						if mode == "up" then
							task.wait(1)
							value = value + 1
						else
							if value <= 0 then break end
							task.wait(1)
							value = value - 1
						end
					end
					if mode ~= "up" and countdownToken == myToken then
						if where == "badge" then
							LabelController:SetStatus("good", "SPAWNED")
						end
						if done then task.spawn(done) end
					end
				end)
			end

			function LabelController:StopCountdown()
				countdownToken = countdownToken + 1
			end

			if labelConfig.Status then
				LabelController:SetStatus(labelConfig.Status, labelConfig.StatusText)
			end

			-- Fire callback on load
			task.spawn(callback)

			return LabelController
		end
		-- =========================================================================
		-- NEW PARAGRAPH IMPLEMENTATION (PIXEL-PERFECT IMAGE & TEXT CARD)
		-- =========================================================================
		function TabObject:AddParagraph(paraConfig)
			paraConfig = paraConfig or {}
			-- Handle nested array structure if passed as { { ... } }
			if paraConfig[1] and type(paraConfig[1]) == "table" then
				paraConfig = paraConfig[1]
			end

			local title = paraConfig.Title or "Paragraph"
			local description = paraConfig.Description or ""
			local image = parseIcon(paraConfig.Image)
			local icon = parseIcon(paraConfig.Icon)

			local hasImage = not not image
			local calculatedHeight = hasImage and 200 or 75

			local ParaFrame = Instance.new("Frame")
			ParaFrame.Name = title .. "_Paragraph"
			ParaFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30) -- FIXED: match other buttons (was 14,14,16 too dark)
			ParaFrame.BorderSizePixel = 0

			local ParaCorner = Instance.new("UICorner")
			ParaCorner.CornerRadius = UDim.new(0, 10)
			ParaCorner.Parent = ParaFrame

			local ParaStroke = Instance.new("UIStroke")
			ParaStroke.Color = Color3.fromRGB(32, 32, 36)
			ParaStroke.Thickness = 1.2
			ParaStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ParaStroke.Parent = ParaFrame

			-- Layout
			local ParaLayout = Instance.new("UIListLayout")
			ParaLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ParaLayout.Padding = UDim.new(0, 8)
			ParaLayout.Parent = ParaFrame

			local ParaPad = Instance.new("UIPadding")
			ParaPad.PaddingLeft = UDim.new(0, 12)
			ParaPad.PaddingRight = UDim.new(0, 12)
			ParaPad.PaddingTop = UDim.new(0, 12)
			ParaPad.PaddingBottom = UDim.new(0, 12)
			ParaPad.Parent = ParaFrame

			-- Image (if provided)
			if hasImage then
				local ImageContainer = Instance.new("Frame")
				ImageContainer.Name = "ImageContainer"
				ImageContainer.BackgroundTransparency = 1
				ImageContainer.Size = UDim2.new(1, 0, 0, 130)
				ImageContainer.LayoutOrder = 1
				ImageContainer.Parent = ParaFrame

				local ImageLabel = Instance.new("ImageLabel")
				ImageLabel.Name = "Image"
				ImageLabel.BackgroundTransparency = 1
				ImageLabel.Size = UDim2.new(1, 0, 1, 0)
				ImageLabel.Image = image
				ImageLabel.ScaleType = Enum.ScaleType.Crop
				ImageLabel.Parent = ImageContainer

				local ImageCorner = Instance.new("UICorner")
				ImageCorner.CornerRadius = UDim.new(0, 10)
				ImageCorner.Parent = ImageLabel
			end

			-- Text Content Container
			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Size = UDim2.new(1, 0, 0, 0)
			TextContainer.AutomaticSize = Enum.AutomaticSize.Y
			TextContainer.LayoutOrder = 2
			TextContainer.Parent = ParaFrame

			local TextLayout = Instance.new("UIListLayout")
			TextLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextLayout.Padding = UDim.new(0, 6)
			TextLayout.Parent = TextContainer

			-- Title row (optional icon + title on one line)
			local TitleRow = Instance.new("Frame")
			TitleRow.Name = "TitleRow"
			TitleRow.BackgroundTransparency = 1
			TitleRow.Size = UDim2.new(1, 0, 0, 26)
			TitleRow.LayoutOrder = 1
			TitleRow.Parent = TextContainer

			local TitleRowLayout = Instance.new("UIListLayout")
			TitleRowLayout.FillDirection = Enum.FillDirection.Horizontal
			TitleRowLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TitleRowLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TitleRowLayout.Padding = UDim.new(0, 8)
			TitleRowLayout.Parent = TitleRow

			if icon then
				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.Size = UDim2.new(0, 24, 0, 24)
				IconLabel.LayoutOrder = 1
				IconLabel.ScaleType = Enum.ScaleType.Fit
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.Parent = TitleRow
			end

			-- Title
			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, (icon and -34 or 0), 1, 0)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 16)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.LayoutOrder = 2
			TitleLabel.Parent = TitleRow

			-- Description
			local DescLabel = Instance.new("TextLabel")
			DescLabel.Name = "Description"
			DescLabel.BackgroundTransparency = 1
			DescLabel.Size = UDim2.new(1, 0, 0, 0)
			DescLabel.AutomaticSize = Enum.AutomaticSize.Y
			DescLabel.Font = Enum.Font.Gotham
			tr(DescLabel, description)
			DescLabel.TextColor3 = Color3.fromRGB(175, 175, 182)
			regText(DescLabel, 13)
			DescLabel.TextXAlignment = Enum.TextXAlignment.Left
			DescLabel.TextYAlignment = Enum.TextYAlignment.Top
			DescLabel.TextWrapped = true
			DescLabel.LineHeight = 1.18
			DescLabel.LayoutOrder = 2
			DescLabel.Parent = TextContainer

			-- Adjust frame height dynamically based on text size
			local function adjustHeight()
				local textHeight = TextLayout.AbsoluteContentSize.Y
				local imageOffset = hasImage and 162 or 24
				local totalHeight = imageOffset + textHeight
				ParaFrame.Size = UDim2.new(1, 0, 0, totalHeight)
				-- Update masonry layout height
				for _, item in ipairs(elements) do
					if item.Frame == ParaFrame then
						item.Height = totalHeight
						break
					end
				end
				distributeElements()
			end

			TextLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(adjustHeight)
			task.spawn(adjustHeight)

			-- hover white effect like toggle (good UI)
			ParaFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(ParaFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ParaFrame:FindFirstChild("UIStroke") or ParaFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
				pcall(function() local ic=ParaFrame:FindFirstChild("IconContainer",true); if ic then local s=ic:FindFirstChild("UIStroke"); if s then TweenService:Create(s,TweenInfo.new(0.15),{Transparency=0}):Play() end end end)
			end)
			ParaFrame.MouseLeave:Connect(function()
				TweenService:Create(ParaFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ParaFrame:FindFirstChild("UIStroke") or ParaFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.15), {Color = themeCardBG(Window.ThemeName or "Dark")}):Play()
				pcall(function() local ic=ParaFrame:FindFirstChild("IconContainer",true); if ic then local s=ic:FindFirstChild("UIStroke"); if s then TweenService:Create(s,TweenInfo.new(0.15),{Transparency=0.3}):Play() end end end)
			end)

			registerElement(ParaFrame, calculatedHeight, paraConfig.Position)

			local ParaController = {}
			function ParaController:SetTitle(newTitle)
				TitleLabel.Text = tostring(newTitle)
				adjustHeight()
			end
			function ParaController:SetDescription(newDesc)
				DescLabel.Text = tostring(newDesc)
				adjustHeight()
			end

			return ParaController
		end


		-- =========================================================================
		-- DISCORD INVITE CARD (FROM MAIN UI)
		-- =========================================================================
		function TabObject:AddDiscordCard(config)
			local data = config.ServerData or {}
			local inviteCode = data.InviteCode or "RhQa6kZu9A"



			local MainFrame = Instance.new("Frame")
			MainFrame.Name = "DiscordInvite"
			MainFrame.Size = UDim2.new(1, 0, 0, 260)
			MainFrame.BackgroundColor3 = Color3.fromHex("#1e1f22")
			MainFrame.BorderSizePixel = 0
			MainFrame.ClipsDescendants = true

			local MainCorner = Instance.new("UICorner")
			MainCorner.CornerRadius = UDim.new(0, 16)
			MainCorner.Parent = MainFrame

			local BgHighlight = Instance.new("Frame")
			BgHighlight.Name = "BgHighlight"
			BgHighlight.Size = UDim2.new(1, 0, 1, 0)
			BgHighlight.BackgroundColor3 = Color3.fromHex("#ffffff")
			BgHighlight.BackgroundTransparency = 1
			BgHighlight.ZIndex = 0
			BgHighlight.Parent = MainFrame

			local BgHLCorner = Instance.new("UICorner")
			BgHLCorner.CornerRadius = UDim.new(0, 16)
			BgHLCorner.Parent = BgHighlight

			local Banner = Instance.new("ImageLabel")
			Banner.Name = "Banner"
			Banner.Size = UDim2.new(1, 0, 0, 60)
			Banner.Position = UDim2.new(0, 0, 0, 0)
			Banner.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			Banner.Image = data.BackgroundBannerId or "rbxassetid://127861212431489"
			Banner.ScaleType = Enum.ScaleType.Crop
			Banner.BorderSizePixel = 0
			Banner.Parent = MainFrame

			local BannerCorner = Instance.new("UICorner")
			BannerCorner.CornerRadius = UDim.new(0, 16)
			BannerCorner.Parent = Banner

			local BannerGradient = Instance.new("UIGradient")
			BannerGradient.Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromHex("#3da5ff")),
				ColorSequenceKeypoint.new(1, Color3.fromHex("#0084ff"))
			})
			BannerGradient.Rotation = 90
			BannerGradient.Parent = Banner

			local ServerIcon = Instance.new("ImageLabel")
			ServerIcon.Name = "ServerIcon"
			ServerIcon.Size = UDim2.new(0, 56, 0, 56)
			ServerIcon.Position = UDim2.new(0, 14, 0, 28)
			ServerIcon.Image = data.ServerIconId or "rbxassetid://106987676739927"
			ServerIcon.BackgroundColor3 = Color3.fromHex("#1e1f22")
			ServerIcon.BorderSizePixel = 0
			ServerIcon.ZIndex = 2
			ServerIcon.Parent = MainFrame

			local IconCorner = Instance.new("UICorner")
			IconCorner.CornerRadius = UDim.new(0, 14)
			IconCorner.Parent = ServerIcon

			local IconStroke = Instance.new("UIStroke")
			IconStroke.Color = Color3.fromHex("#1e1f22")
			IconStroke.Thickness = 3
			IconStroke.Parent = ServerIcon

			local InfoHolder = Instance.new("Frame")
			InfoHolder.Name = "InfoHolder"
			InfoHolder.Size = UDim2.new(1, -28, 0, 95)
			InfoHolder.Position = UDim2.new(0, 14, 0, 92)
			InfoHolder.BackgroundTransparency = 1
			InfoHolder.Parent = MainFrame

			local ListLayout = Instance.new("UIListLayout")
			ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			ListLayout.Padding = UDim.new(0, 3)
			ListLayout.Parent = InfoHolder

			local NameFrame = Instance.new("Frame")
			NameFrame.Name = "NameFrame"
			NameFrame.Size = UDim2.new(1, 0, 0, 22)
			NameFrame.BackgroundTransparency = 1
			NameFrame.LayoutOrder = 1
			NameFrame.Parent = InfoHolder

			local NameListLayout = Instance.new("UIListLayout")
			NameListLayout.FillDirection = Enum.FillDirection.Horizontal
			NameListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			NameListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			NameListLayout.Padding = UDim.new(0, 6)
			NameListLayout.Parent = NameFrame

			local ServerName = Instance.new("TextLabel")
			ServerName.Size = UDim2.new(0, 0, 1, 0)
			ServerName.AutomaticSize = Enum.AutomaticSize.X
			ServerName.Text = data.ServerName or "LumuHub"
			ServerName.Font = Enum.Font.GothamBold
			mTS(ServerName, 16)
			ServerName.TextColor3 = Color3.fromHex("#ffffff")
			ServerName.TextXAlignment = Enum.TextXAlignment.Left
			ServerName.BackgroundTransparency = 1
			ServerName.LayoutOrder = 1
			ServerName.Parent = NameFrame

			local BadgeIcon = Instance.new("ImageLabel")
			BadgeIcon.Size = UDim2.new(0, 14, 0, 14)
			BadgeIcon.Image = "rbxassetid://75143132170494"
			BadgeIcon.ImageColor3 = Color3.fromHex("#ffffff")
			BadgeIcon.BackgroundTransparency = 1
			BadgeIcon.LayoutOrder = 2
			BadgeIcon.Parent = NameFrame

			local MetricsFrame = Instance.new("Frame")
			MetricsFrame.Size = UDim2.new(1, 0, 0, 16)
			MetricsFrame.BackgroundTransparency = 1
			MetricsFrame.LayoutOrder = 2
			MetricsFrame.Parent = InfoHolder

			local MetricsLayout = Instance.new("UIListLayout")
			MetricsLayout.FillDirection = Enum.FillDirection.Horizontal
			MetricsLayout.SortOrder = Enum.SortOrder.LayoutOrder
			MetricsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			MetricsLayout.Padding = UDim.new(0, 5)
			MetricsLayout.Parent = MetricsFrame

			local OnlineDot = Instance.new("Frame")
			OnlineDot.Name = "OnlineDot"
			OnlineDot.Size = UDim2.new(0, 7, 0, 7)
			OnlineDot.BackgroundColor3 = Color3.fromRGB(35, 165, 90)
			OnlineDot.BorderSizePixel = 0
			OnlineDot.LayoutOrder = 1
			OnlineDot.Parent = MetricsFrame

			local OnlineDotCorner = Instance.new("UICorner")
			OnlineDotCorner.CornerRadius = UDim.new(1, 0)
			OnlineDotCorner.Parent = OnlineDot

			local OnlineLabel = Instance.new("TextLabel")
			OnlineLabel.Size = UDim2.new(0, 0, 1, 0)
			OnlineLabel.AutomaticSize = Enum.AutomaticSize.X
			OnlineLabel.Text = tostring(data.OnlineCount or 46) .. " Online"
			OnlineLabel.Font = Enum.Font.GothamMedium
			mTS(OnlineLabel, 12)
			OnlineLabel.TextColor3 = Color3.fromHex("#949ba4")
			OnlineLabel.BackgroundTransparency = 1
			OnlineLabel.LayoutOrder = 2
			OnlineLabel.Parent = MetricsFrame

			local MetricSpace = Instance.new("Frame")
			MetricSpace.Size = UDim2.new(0, 4, 1, 0)
			MetricSpace.BackgroundTransparency = 1
			MetricSpace.LayoutOrder = 3
			MetricSpace.Parent = MetricsFrame

			local MemberDot = Instance.new("Frame")
			MemberDot.Name = "MemberDot"
			MemberDot.Size = UDim2.new(0, 7, 0, 7)
			MemberDot.BackgroundColor3 = Color3.fromRGB(128, 132, 142)
			MemberDot.BorderSizePixel = 0
			MemberDot.LayoutOrder = 4
			MemberDot.Parent = MetricsFrame

			local MemberDotCorner = Instance.new("UICorner")
			MemberDotCorner.CornerRadius = UDim.new(1, 0)
			MemberDotCorner.Parent = MemberDot

			local MemberLabel = Instance.new("TextLabel")
			MemberLabel.Size = UDim2.new(0, 0, 1, 0)
			MemberLabel.AutomaticSize = Enum.AutomaticSize.X
			MemberLabel.Text = tostring(data.MemberCount or 593) .. " Members"
			MemberLabel.Font = Enum.Font.GothamMedium
			mTS(MemberLabel, 12)
			MemberLabel.TextColor3 = Color3.fromHex("#949ba4")
			MemberLabel.BackgroundTransparency = 1
			MemberLabel.LayoutOrder = 5
			MemberLabel.Parent = MetricsFrame

			-- Live Discord counts: no bot token needed. Just set
			-- ServerData.InviteCode = "your-code" (the part after discord.gg/)
			-- and real online/member numbers load from Discord's public
			-- invite API. Falls back to OnlineCount/MemberCount if offline.
			task.spawn(function()
				local res = webGet("https://discord.com/api/v9/invites/" .. inviteCode .. "?with_counts=true")
				if type(res) ~= "string" or res == "" then return end
				local ok2, js = pcall(function() return HttpService:JSONDecode(res) end)
				if not ok2 or type(js) ~= "table" then return end
				pcall(function()
					local online = tonumber(js.approximate_presence_count)
					local members = tonumber(js.approximate_member_count)
					if online then OnlineLabel.Text = tostring(online) .. " Online" end
					if members then MemberLabel.Text = tostring(members) .. " Members" end
					local guild = js.guild
					if type(guild) == "table" then
						if data.ServerName == nil and type(guild.name) == "string" and guild.name ~= "" then
							ServerName.Text = guild.name
						end
						if data.ServerIconId == nil and type(guild.id) == "string" and type(guild.icon) == "string" and guild.icon ~= "" then
							ServerIcon.Image = "https://cdn.discordapp.com/icons/" .. guild.id .. "/" .. guild.icon .. ".png?size=128"
						end
					end
				end)
			end)

			local EstLabel = Instance.new("TextLabel")
			EstLabel.Name = "EstLabel"
			EstLabel.Size = UDim2.new(1, 0, 0, 14)
			EstLabel.Text = data.EstablishedDate or "Est. Jun 2025"
			EstLabel.Font = Enum.Font.GothamMedium
			mTS(EstLabel, 12)
			EstLabel.TextColor3 = Color3.fromHex("#949ba4")
			EstLabel.TextXAlignment = Enum.TextXAlignment.Left
			EstLabel.BackgroundTransparency = 1
			EstLabel.LayoutOrder = 3
			EstLabel.Parent = InfoHolder

			local DescLabel = Instance.new("TextLabel")
			DescLabel.Name = "DescLabel"
			DescLabel.Size = UDim2.new(1, 0, 0, 18)
			DescLabel.Text = data.Description or "Official LumuHub Community"
			DescLabel.Font = Enum.Font.GothamMedium
			regText(DescLabel, 12)
			DescLabel.TextColor3 = Color3.fromHex("#dbdee1")
			DescLabel.TextXAlignment = Enum.TextXAlignment.Left
			DescLabel.TextYAlignment = Enum.TextYAlignment.Top
			DescLabel.TextWrapped = true
			DescLabel.BackgroundTransparency = 1
			DescLabel.LayoutOrder = 4
			DescLabel.Parent = InfoHolder

			local GameActivityFrame = Instance.new("Frame")
			GameActivityFrame.Size = UDim2.new(1, -28, 0, 26)
			GameActivityFrame.Position = UDim2.new(0, 14, 1, -70)
			GameActivityFrame.BackgroundTransparency = 1
			GameActivityFrame.Parent = MainFrame

			local GameIcon = Instance.new("ImageLabel")
			GameIcon.Size = UDim2.new(0, 22, 0, 22)
			GameIcon.Position = UDim2.new(0, 0, 0.5, -11)
			GameIcon.Image = "rbxassetid://104079816442680"
			GameIcon.BackgroundTransparency = 1
			GameIcon.Parent = GameActivityFrame

			local FlameBadge = Instance.new("ImageLabel")
			FlameBadge.Size = UDim2.new(0, 10, 0, 10)
			FlameBadge.Position = UDim2.new(1, -5, 0, -3)
			FlameBadge.Image = "rbxassetid://10841141110"
			FlameBadge.ImageColor3 = Color3.fromHex("#ff7324")
			FlameBadge.BackgroundTransparency = 1
			FlameBadge.Parent = GameIcon

			local GameLabel = Instance.new("TextLabel")
			GameLabel.Size = UDim2.new(1, -28, 1, 0)
			GameLabel.Position = UDim2.new(0, 28, 0, 0)
			GameLabel.Text = data.GameLabel or "ROBLOX"
			GameLabel.Font = Enum.Font.GothamBold
			mTS(GameLabel, 12)
			GameLabel.TextColor3 = Color3.fromHex("#ffffff")
			GameLabel.TextXAlignment = Enum.TextXAlignment.Left
			GameLabel.BackgroundTransparency = 1
			GameLabel.Parent = GameActivityFrame

			local ActionButton = Instance.new("TextButton")
			ActionButton.Name = "JoinButton"
			ActionButton.Size = UDim2.new(1, -28, 0, 34)
			ActionButton.Position = UDim2.new(0, 14, 1, -40)
			ActionButton.BackgroundColor3 = Color3.fromHex("#248046")
			ActionButton.BorderSizePixel = 0
			ActionButton.Text = "Join Server"
			ActionButton.Font = Enum.Font.GothamBold
			mTS(ActionButton, 13)
			ActionButton.TextColor3 = Color3.fromHex("#ffffff")
			ActionButton.AutoButtonColor = false
			ActionButton.Parent = MainFrame

			local ButtonCorner = Instance.new("UICorner")
			ButtonCorner.CornerRadius = UDim.new(0, 8)
			ButtonCorner.Parent = ActionButton

			local baseColor = Color3.fromHex("#248046")
			local hoverColor = baseColor:Lerp(Color3.new(1, 1, 1), 0.1)
			local pressColor = baseColor:Lerp(Color3.new(0, 0, 0), 0.15)

			ActionButton.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(ActionButton, TweenInfo.new(0.12), {BackgroundColor3 = hoverColor}):Play()
			end)
			ActionButton.MouseLeave:Connect(function()
				TweenService:Create(ActionButton, TweenInfo.new(0.12), {BackgroundColor3 = baseColor}):Play()
			end)
			ActionButton.MouseButton1Down:Connect(function()
				TweenService:Create(ActionButton, TweenInfo.new(0.05), {BackgroundColor3 = pressColor}):Play()
			end)

			ActionButton.MouseButton1Click:Connect(function()
				local inviteLink = "https://discord.gg/" .. inviteCode

				pcall(function() if setclipboard then setclipboard(inviteLink) end end)

				Window:Notify({
					Type = "good",
					Title = "Invite copied",
					Message = "discord.gg/" .. tostring(inviteCode) .. " is on your clipboard.",
					Duration = 6,
				})

				pcall(function()
					if httpRequest then
						httpRequest({
							Url = "http://127.0.0.1:6463/rpc?v=1",
							Method = "POST",
							Headers = {
								["Content-Type"] = "application/json",
								["Origin"] = "https://discord.com"
							},
							Body = HttpService:JSONEncode({
								cmd = "INVITE_BROWSER",
								args = { code = inviteCode },
								nonce = tostring(math.random(100000, 999999))
							})
						})
					end
				end)

				ActionButton.Text = "Opened!"
				ActionButton.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
				task.wait(2)
				ActionButton.Text = "Join Server"
				ActionButton.BackgroundColor3 = baseColor
			end)

			MainFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(BgHighlight, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
			end)
			MainFrame.MouseLeave:Connect(function()
				TweenService:Create(BgHighlight, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
			end)

			registerElement(MainFrame, 260, config.Position)

		end
		-- =========================================================================
		-- NEW KEYBIND IMPLEMENTATION (MATCHES REFERENCE IMAGE PERFECTLY)
		-- =========================================================================
		function TabObject:AddKeybind(keybindConfig)
			keybindConfig = keybindConfig or {}
			local title = keybindConfig.Title or "Keybind"
			local default = keybindConfig.Default or Enum.KeyCode.RightControl
			local callback = keybindConfig.Callback or function() end
			local icon = parseIcon(keybindConfig.Icon)

			local calculatedHeight = IsMobile and 50 or 64

			local KeybindFrame = Instance.new("Frame")
			KeybindFrame.Name = title .. "_Keybind"
			KeybindFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			KeybindFrame.BorderSizePixel = 0

			local KeybindCorner = Instance.new("UICorner")
			KeybindCorner.CornerRadius = UDim.new(0, 12)
			KeybindCorner.Parent = KeybindFrame

			local KeybindStroke = Instance.new("UIStroke")
			KeybindStroke.Color = Color3.fromRGB(50, 50, 55)
			KeybindStroke.Thickness = 1
			KeybindStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			KeybindStroke.Parent = KeybindFrame

			-- Left Icon Container (Optional, same as toggle rows)
			local IconContainer = nil
			if icon then
				IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, 10, 0.5, IsMobile and -16 or -21)
				IconContainer.Size = UDim2.new(0, IsMobile and 32 or 42, 0, IsMobile and 32 or 42)
				IconContainer.Parent = KeybindFrame

				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 6)
				IconCorner.Parent = IconContainer

				local IconContainerStroke = Instance.new("UIStroke")
				IconContainerStroke.Color = Color3.fromRGB(255, 255, 255)
				IconContainerStroke.Transparency = 0.3
				IconContainerStroke.Thickness = 1.5
				IconContainerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconContainerStroke.Parent = IconContainer

				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, IsMobile and 22 or 30, 0, IsMobile and 22 or 30)
				Astral.ApplyIcon(IconLabel, icon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			-- Text Container
			local TextContainer = Instance.new("Frame")
			TextContainer.Name = "TextContainer"
			TextContainer.BackgroundTransparency = 1
			TextContainer.Position = icon and UDim2.new(0, 60, 0, 0) or UDim2.new(0, 12, 0, 0)
			TextContainer.Size = icon and UDim2.new(1, -180, 1, 0) or UDim2.new(1, -130, 1, 0)
			TextContainer.Parent = KeybindFrame

			local TextListLayout = Instance.new("UIListLayout")
			TextListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			TextListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			TextListLayout.Padding = UDim.new(0, 2)
			TextListLayout.Parent = TextContainer

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 16)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 11)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.TextWrapped = false
			TitleLabel.Parent = TextContainer

			-- Keybind Button (Right Side)

			local KeybindButton = Instance.new("TextButton")
			KeybindButton.Name = "KeybindButton"
			KeybindButton.BackgroundColor3 = Color3.fromRGB(42, 42, 50)
			KeybindButton.BorderSizePixel = 0
			KeybindButton.AnchorPoint = Vector2.new(1, 0.5)
			KeybindButton.Position = UDim2.new(1, -12, 0.5, 0)
			KeybindButton.Size = UDim2.new(0, 0, 0, 34) -- Dynamic width
			KeybindButton.AutomaticSize = Enum.AutomaticSize.X
			KeybindButton.Font = Enum.Font.GothamBold
			KeybindButton.Text = default.Name
			KeybindButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			mTS(KeybindButton, 13)
			KeybindButton.AutoButtonColor = false
			KeybindButton.Parent = KeybindFrame

			local ButtonCorner = Instance.new("UICorner")
			ButtonCorner.CornerRadius = UDim.new(0, 8)
			ButtonCorner.Parent = KeybindButton

			-- Clear outline so the key box is easy to see on the dark card
			local ButtonStroke = Instance.new("UIStroke")
			ButtonStroke.Color = Color3.fromRGB(70, 70, 80)
			ButtonStroke.Thickness = 1.2
			ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			ButtonStroke.Parent = KeybindButton

			local ButtonPadding = Instance.new("UIPadding")
			ButtonPadding.PaddingLeft = UDim.new(0, 18)
			ButtonPadding.PaddingRight = UDim.new(0, 18)
			ButtonPadding.Parent = KeybindButton


			local currentKey = default
			local listening = false
			local inputConnection

			-- Sink game input while binding so e.g. pressing S binds it without walking
			local sinkName = "AstralKeybindSink_" .. tostring(math.random(100000, 999999))
			local function sinkGameInput()
				local CAS = game:GetService("ContextActionService")
				local keys = {}
				for _, item in ipairs(Enum.KeyCode:GetEnumItems()) do
					if item ~= Enum.KeyCode.Unknown then
						table.insert(keys, item)
					end
				end
				pcall(function()
					CAS:UnbindAction(sinkName)
					CAS:BindActionAtPriority(sinkName, function()
						return Enum.ContextActionResult.Sink
					end, false, Enum.ContextActionPriority.High.Value, unpack(keys))
				end)
			end
			local function unsinkGameInput()
				pcall(function()
					game:GetService("ContextActionService"):UnbindAction(sinkName)
				end)
			end

			local function stopListeningVisual()
				TweenService:Create(KeybindButton, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(34, 34, 40)}):Play()
				TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 80)}):Play()
			end

			local function startListening()
				if listening then return end
				listening = true
				KeybindButton.Text = "..."
				TweenService:Create(KeybindButton, TweenInfo.new(0.15), {BackgroundColor3 = AccentColor}):Play()
				TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = AccentColor}):Play()
				sinkGameInput()

				if inputConnection then inputConnection:Disconnect() end

				inputConnection = UserInputService.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.Keyboard then
						local key = input.KeyCode
						if key ~= Enum.KeyCode.Unknown then
							inputConnection:Disconnect()
							inputConnection = nil
							currentKey = key
							KeybindButton.Text = key.Name
							listening = false
							unsinkGameInput()
							stopListeningVisual()
							task.spawn(callback, key)
						end
					end
				end)
			end

			KeybindButton.MouseButton1Click:Connect(function()
				-- Click again while binding = cancel (never trap movement)
				if listening then
					listening = false
					if inputConnection then
						inputConnection:Disconnect()
						inputConnection = nil
					end
					unsinkGameInput()
					KeybindButton.Text = currentKey.Name
					stopListeningVisual()
					return
				end
				startListening()
			end)

			-- Hover effects (identical to toggle/button rows)
			KeybindFrame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(KeybindFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(KeybindStroke, TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
			end)
			KeybindFrame.MouseLeave:Connect(function()
				TweenService:Create(KeybindFrame, TweenInfo.new(0.15), {BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(KeybindStroke, TweenInfo.new(0.15), {Color = themeStroke(Window.ThemeName or "Dark")}):Play()
			end)

			-- Key box hover: accent outline so it reads as clickable
			KeybindButton.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				if listening then return end
				TweenService:Create(KeybindButton, TweenInfo.new(0.15), {BackgroundColor3 = themeHoverBG(Window.ThemeName or "Dark")}):Play()
				TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = AccentColor}):Play()
			end)
			KeybindButton.MouseLeave:Connect(function()
				if listening then return end
				stopListeningVisual()
			end)

			registerElement(KeybindFrame, calculatedHeight, keybindConfig.Position)

			local KeybindController = {}
			function KeybindController:Set(key)
				if typeof(key) == "EnumItem" and key.EnumType == Enum.KeyCode then
					currentKey = key
					KeybindButton.Text = key.Name
					task.spawn(callback, key)
				end
			end
			function KeybindController:Get()
				return currentKey
			end
			if keybindConfig.Flag and keybindConfig.Flag ~= "" then
				table.insert(configFlags, {Flag = keybindConfig.Flag, Kind = "key",
					Get = function() return currentKey end,
					Set = function(v) KeybindController:Set(v) end})
			end

			return KeybindController
		end

		-- =========================================================================
		-- MULTIBUTTON: card with a grid of clickable buttons.
		-- Buttons can be text only, icon only, or icon + text.
		--   Tab:AddMultiButton({
		--     Title = "Quick Teleports",
		--     Columns = 2,               -- optional (default 2)
		--     Buttons = {
		--       {Title = "sea 1", Callback = function() end},
		--       {Title = "sea 2", Icon = "star", Callback = function() end},
		--       {Icon = "chest", Callback = function() end},  -- icon only
		--     },
		--   })
		-- =========================================================================
		-- =========================================================================
		-- MULTIBUTTON: card with a grid of clickable buttons.
		-- Buttons can be text only, icon only, or icon + text.
		--   Tab:AddMultiButton({
		--     Title = "Quick Teleports",
		--     Columns = 2,                     -- optional (default 2)
		--     ButtonColor = Color3.fromRGB(..),-- optional: all buttons this color
		--     Buttons = {
		--       {Title = "sea 1", Callback = function() end},
		--       {Title = "sea 2", Icon = "star", Callback = function() end},
		--       {Icon = "chest", Color = "red", Callback = function() end},  -- icon only
		--     },
		--   })
		-- If EVERY button is icon-only they render as big square icon tiles.
		-- =========================================================================
		local function parseButtonColor(v)
			if typeof(v) == "Color3" then return v end
			if type(v) == "string" then
				local named = {
					red = Color3.fromRGB(231, 76, 60),
					green = Color3.fromRGB(46, 204, 113),
					blue = Color3.fromRGB(0, 153, 235),
					cyan = Color3.fromRGB(0, 210, 255),
					purple = Color3.fromRGB(138, 90, 255),
					pink = Color3.fromRGB(255, 90, 180),
					orange = Color3.fromRGB(243, 156, 18),
					gold = Color3.fromRGB(255, 196, 40),
					white = Color3.fromRGB(240, 240, 245),
					dark = Color3.fromRGB(40, 40, 46),
				}
				return named[v:lower()]
			end
			return nil
		end

		function TabObject:AddMultiButton(cfg)
			cfg = cfg or {}
			local title = cfg.Title or "Multi Button"
			local description = cfg.Description
			local cardIcon = parseIcon(cfg.Icon)
			local items = cfg.Buttons or {}
			local columns = math.max(1, math.floor(cfg.Columns or 2))
			if IsMobile and columns > 2 then columns = 2 end
			local hasDesc = description and description ~= ""
			local cardButtonColor = parseButtonColor(cfg.ButtonColor)

			-- icon-only mode: every button has no title -> big square tiles
			local iconOnlyMode = #items > 0
			for _, it in ipairs(items) do
				if it and it.Title and it.Title ~= "" then iconOnlyMode = false; break end
			end

			local pad = IsMobile and 6 or 10
			local gap = IsMobile and 6 or 10
			local btnH = iconOnlyMode and (IsMobile and 48 or 64) or (IsMobile and 28 or 34)
			local headerH = hasDesc and (IsMobile and 30 or 36) or (IsMobile and 18 or 22)
			local rows = math.max(1, math.ceil(#items / columns))
			local gridH = rows * btnH + (rows - 1) * gap
			local calculatedHeight = pad + headerH + 10 + gridH + pad

			local Card = Instance.new("Frame")
			Card.Name = title .. "_MultiButton"
			Card.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			Card.BorderSizePixel = 0
			Card.Size = UDim2.new(1, 0, 0, calculatedHeight)

			local CardCorner = Instance.new("UICorner")
			CardCorner.CornerRadius = UDim.new(0, 8)
			CardCorner.Parent = Card

			local CardStroke = Instance.new("UIStroke")
			CardStroke.Color = Color3.fromRGB(50, 50, 55)
			CardStroke.Thickness = 1
			CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			CardStroke.Parent = Card

			-- Optional card icon
			if cardIcon then
				local IconContainer = Instance.new("Frame")
				IconContainer.Name = "IconContainer"
				IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				IconContainer.BorderSizePixel = 0
				IconContainer.Position = UDim2.new(0, pad, 0, pad)
				IconContainer.Size = UDim2.new(0, 30, 0, 30)
				IconContainer.Parent = Card

				local IconCorner = Instance.new("UICorner")
				IconCorner.CornerRadius = UDim.new(0, 6)
				IconCorner.Parent = IconContainer

				local IconStroke = Instance.new("UIStroke")
				IconStroke.Color = Color3.fromRGB(255, 255, 255)
				IconStroke.Transparency = 0.3
				IconStroke.Thickness = 1.5
				IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				IconStroke.Parent = IconContainer

				local IconLabel = Instance.new("ImageLabel")
				IconLabel.Name = "Icon"
				IconLabel.BackgroundTransparency = 1
				IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				IconLabel.Size = UDim2.new(0, 18, 0, 18)
				Astral.ApplyIcon(IconLabel, cardIcon)
				IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
				IconLabel.ScaleType = Enum.ScaleType.Fit
				IconLabel.Parent = IconContainer
			end

			local textX = cardIcon and (pad + 38) or pad
			local Header = Instance.new("Frame")
			Header.Name = "Header"
			Header.BackgroundTransparency = 1
			Header.Position = UDim2.new(0, textX, 0, pad)
			Header.Size = UDim2.new(1, -textX - pad, 0, headerH)
			Header.Parent = Card

			local HeaderLayout = Instance.new("UIListLayout")
			HeaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
			HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			HeaderLayout.Padding = UDim.new(0, 1)
			HeaderLayout.Parent = Header

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 18)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 12)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.Parent = Header

			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, 16)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, 10)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
				DescLabel.Parent = Header
			end

			-- Button grid
			local Grid = Instance.new("Frame")
			Grid.Name = "ButtonGrid"
			Grid.BackgroundTransparency = 1
			Grid.Position = UDim2.new(0, pad, 0, pad + headerH + 10)
			Grid.Size = UDim2.new(1, -pad * 2, 0, gridH)
			Grid.Parent = Card

			local GridLayout = Instance.new("UIGridLayout")
			if columns <= 1 then
				GridLayout.CellSize = UDim2.new(1, 0, 0, btnH)
				GridLayout.CellPadding = UDim2.new(0, 0, 0, gap)
			else
				local shrink = math.ceil((columns - 1) * gap / columns)
				GridLayout.CellSize = UDim2.new(1 / columns, -shrink, 0, btnH)
				GridLayout.CellPadding = UDim2.new(0, gap, 0, gap)
			end
			GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			GridLayout.FillDirectionMaxCells = columns
			GridLayout.Parent = Grid

			local accentButtons = {}

			for i, item in ipairs(items) do
				item = item or {}
				local bTitle = item.Title
				local bIcon = parseIcon(item.Icon)
				local bCallback = item.Callback or function() end
				local bColor = parseButtonColor(item.Color) or cardButtonColor

				local Btn = Instance.new("TextButton")
				Btn.Name = (bTitle or "icon") .. "_MultiBtn"
				Btn.BackgroundColor3 = bColor or AccentColor
				Btn.BorderSizePixel = 0
				Btn.Text = ""
				Btn.AutoButtonColor = false
				Btn.ClipsDescendants = true
				Btn.LayoutOrder = i
				Btn.Parent = Grid

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, iconOnlyMode and 10 or 6)
				BtnCorner.Parent = Btn

				local BtnScale = Instance.new("UIScale")
				BtnScale.Scale = 1
				BtnScale.Parent = Btn

				-- Centered content row: icon and/or text
				local Content = Instance.new("Frame")
				Content.Name = "Content"
				Content.BackgroundTransparency = 1
				Content.ClipsDescendants = true
				Content.Size = UDim2.new(1, -12, 1, 0)
				Content.Position = UDim2.new(0, 6, 0, 0)
				Content.Parent = Btn

				local ContentLayout = Instance.new("UIListLayout")
				ContentLayout.FillDirection = Enum.FillDirection.Horizontal
				ContentLayout.HorizontalAlignment = iconOnlyMode and Enum.HorizontalAlignment.Center or Enum.HorizontalAlignment.Left
				ContentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
				ContentLayout.Padding = UDim.new(0, 6)
				ContentLayout.Parent = Content

				if bIcon then
					local BIcon = Instance.new("ImageLabel")
					BIcon.Name = "Icon"
					BIcon.BackgroundTransparency = 1
					local iSize = iconOnlyMode and (IsMobile and 28 or 34) or (IsMobile and 14 or 18)
					BIcon.Size = UDim2.new(0, iSize, 0, iSize)
					BIcon.LayoutOrder = 1
					Astral.ApplyIcon(BIcon, bIcon)
					BIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
					BIcon.ScaleType = Enum.ScaleType.Fit
					BIcon.Parent = Content
				end

				if not iconOnlyMode and bTitle and bTitle ~= "" then
					local BLabel = Instance.new("TextLabel")
					BLabel.Name = "Label"
					BLabel.BackgroundTransparency = 1
					BLabel.Size = UDim2.new(1, bIcon and -20 or 0, 1, 0)
					BLabel.Font = Enum.Font.GothamBold
					BLabel.Text = bTitle
					BLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					BLabel.TextSize = IsMobile and 10 or 12
					BLabel.TextXAlignment = Enum.TextXAlignment.Center
					BLabel.TextTruncate = Enum.TextTruncate.AtEnd
					BLabel.LayoutOrder = 2
					BLabel.Parent = Content
				end

				Btn.MouseButton1Click:Connect(function()
					task.spawn(bCallback)
				end)
				Btn.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(BtnScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
					end
				end)
				Btn.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						TweenService:Create(BtnScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
					end
				end)
				Btn.MouseEnter:Connect(function()
					if pickerOpen or selectorOpen then return end
					TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = (bColor or AccentColor):Lerp(Color3.new(1, 1, 1), 0.15)}):Play()
				end)
				Btn.MouseLeave:Connect(function()
					TweenService:Create(Btn, TweenInfo.new(0.15), {BackgroundColor3 = bColor or AccentColor}):Play()
				end)

				-- only buttons without an explicit color follow the accent
				if not bColor then
					table.insert(accentButtons, Btn)
					onAccentChange(function(c)
						Btn.BackgroundColor3 = c
					end)
				end
			end

			registerElement(Card, calculatedHeight, cfg.Position)

			-- Icon-only tiles: make the cells square once the real width is known
			if iconOnlyMode then
				GridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
				local function squareUp()
					local w = Grid.AbsoluteSize.X
					if w < 10 then return end
					-- fit the row, but keep tiles a sane size (44..72px)
					local fit = math.floor((w - (columns - 1) * gap) / columns)
					local cell = math.clamp(fit, 44, 72)
					local cellSize = UDim2.new(0, cell, 0, cell)
					if GridLayout.CellSize ~= cellSize then
						GridLayout.CellSize = cellSize
						local newRows = math.max(1, math.ceil(#items / columns))
						local newGridH = newRows * cell + (newRows - 1) * gap
						Grid.Size = UDim2.new(1, -pad * 2, 0, newGridH)
						local newCardH = pad + headerH + 10 + newGridH + pad
						Card.Size = UDim2.new(1, 0, 0, newCardH)
						for _, el in ipairs(elements) do
							if el.Frame == Card then
								el.Height = newCardH
								break
							end
						end
						distributeElements()
					end
				end
				Grid:GetPropertyChangedSignal("AbsoluteSize"):Connect(squareUp)
				task.defer(squareUp)
			end

			local MultiController = {}
			function MultiController:SetAccent(color)
				for _, b in ipairs(accentButtons) do
					pcall(function() b.BackgroundColor3 = color end)
				end
			end
			return MultiController
		end


		-- MultiColorPicker: MultiButton-style buttons where every tile is a
		-- mini color picker. Tap a tile to open the picker; confirming recolors
		-- the tile and fires Callback(index, color).
		-- Usage: tab:AddMultiColorPicker({ Title = "Skins", Columns = 2, Buttons = {
		--   { Title = "Kill", Icon = "Gun", Color = "red",
		--     Callback = function(i, c) print(i, c) end },
		-- }})
		function TabObject:AddMultiColorPicker(cfg)
			cfg = cfg or {}
			local title = cfg.Title or "Colors"
			local description = cfg.Description
			local items = cfg.Buttons or {}
			local columns = math.max(1, math.floor(cfg.Columns or 2))
			if IsMobile and columns > 2 then columns = 2 end
			local hasDesc = description and description ~= "" or false

			local iconOnlyMode = #items > 0
			for _, it in ipairs(items) do
				if it and it.Title and it.Title ~= "" then iconOnlyMode = false; break end
			end

			local pad = IsMobile and 6 or 10
			local gap = IsMobile and 6 or 10
			local btnH = iconOnlyMode and (IsMobile and 48 or 64) or (IsMobile and 40 or 48)
			local headerH = hasDesc and (IsMobile and 30 or 36) or (IsMobile and 18 or 22)
			local rows = math.max(1, math.ceil(math.max(1, #items) / columns))
			local gridH = rows * btnH + (rows - 1) * gap
			local calculatedHeight = pad + headerH + 10 + gridH + pad

			local Card = Instance.new("Frame")
			Card.Name = title .. "_MultiColorPicker"
			Card.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			Card.BorderSizePixel = 0
			Card.Size = UDim2.new(1, 0, 0, calculatedHeight)

			local CardCorner = Instance.new("UICorner")
			CardCorner.CornerRadius = UDim.new(0, 8)
			CardCorner.Parent = Card

			local CardStroke = Instance.new("UIStroke")
			CardStroke.Color = Color3.fromRGB(50, 50, 55)
			CardStroke.Thickness = 1
			CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			CardStroke.Parent = Card

			local Header = Instance.new("Frame")
			Header.Name = "Header"
			Header.BackgroundTransparency = 1
			Header.Position = UDim2.new(0, pad, 0, pad)
			Header.Size = UDim2.new(1, -pad * 2, 0, headerH)
			Header.Parent = Card

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Name = "Title"
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Size = UDim2.new(1, 0, 0, 18)
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, 12)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.Parent = Header

			if hasDesc then
				local DescLabel = Instance.new("TextLabel")
				DescLabel.Name = "Description"
				DescLabel.BackgroundTransparency = 1
				DescLabel.Size = UDim2.new(1, 0, 0, 16)
				DescLabel.Font = Enum.Font.Gotham
				tr(DescLabel, description)
				DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
				regText(DescLabel, 10)
				DescLabel.TextXAlignment = Enum.TextXAlignment.Left
				DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
				DescLabel.Parent = Header
			end

			local Grid = Instance.new("Frame")
			Grid.Name = "ButtonGrid"
			Grid.BackgroundTransparency = 1
			Grid.Position = UDim2.new(0, pad, 0, pad + headerH + 10)
			Grid.Size = UDim2.new(1, -pad * 2, 0, gridH)
			Grid.Parent = Card

			local GridLayout = Instance.new("UIGridLayout")
			local shrink = math.ceil((columns - 1) * gap / columns)
			GridLayout.CellSize = UDim2.new(1 / columns, -shrink, 0, btnH)
			GridLayout.CellPadding = UDim2.new(0, gap, 0, gap)
			GridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			GridLayout.FillDirectionMaxCells = columns
			GridLayout.Parent = Grid

			local tiles = {}
			for i, item in ipairs(items) do
				item = item or {}
				local bTitle = item.Title
				local bIcon = parseIcon(item.Icon)
				local bCallback = item.Callback or function() end
				local bColor = parseButtonColor(item.Color) or Color3.fromRGB(40, 40, 48)
				local baseName = (bTitle and bTitle ~= "") and bTitle or ("Color " .. i)

				local Btn = Instance.new("TextButton")
				Btn.Name = baseName .. "_MultiColorBtn"
				Btn.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
				Btn.BorderSizePixel = 0
				Btn.Text = ""
				Btn.AutoButtonColor = false
				Btn.ClipsDescendants = true
				Btn.LayoutOrder = i
				Btn.Parent = Grid

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, iconOnlyMode and 10 or 6)
				BtnCorner.Parent = Btn

				local BtnStroke = Instance.new("UIStroke")
				BtnStroke.Color = Color3.fromRGB(50, 50, 55)
				BtnStroke.Thickness = 1
				BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				BtnStroke.Parent = Btn

				local TilePreview = nil
				if not iconOnlyMode then
					TilePreview = Instance.new("TextButton")
					TilePreview.Name = "ColorBox"
					TilePreview.AnchorPoint = Vector2.new(1, 0.5)
					TilePreview.Position = UDim2.new(1, -10, 0.5, 0)
					TilePreview.Size = UDim2.new(0, IsMobile and 48 or 56, 0, IsMobile and 22 or 26)
					TilePreview.BackgroundColor3 = bColor
					TilePreview.BorderSizePixel = 0
					TilePreview.Text = ""
					TilePreview.AutoButtonColor = false
					TilePreview.ZIndex = 2
					TilePreview.Parent = Btn

					local PreviewCorner = Instance.new("UICorner")
					PreviewCorner.CornerRadius = UDim.new(0, 8)
					PreviewCorner.Parent = TilePreview

					local PreviewStroke = Instance.new("UIStroke")
					PreviewStroke.Color = Color3.fromRGB(50, 50, 55)
					PreviewStroke.Thickness = 1.2
					PreviewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					PreviewStroke.Parent = TilePreview
				end

				if bIcon then
					local BIcon = Instance.new("ImageLabel")
					BIcon.Name = "Icon"
					BIcon.BackgroundTransparency = 1
					if iconOnlyMode then
						BIcon.AnchorPoint = Vector2.new(0.5, 0.5)
						BIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
					else
						BIcon.AnchorPoint = Vector2.new(0, 0.5)
						BIcon.Position = UDim2.new(0, 10, 0.5, 0)
					end
					BIcon.Size = UDim2.new(0, iconOnlyMode and (IsMobile and 28 or 34) or (IsMobile and 18 or 22), 0, iconOnlyMode and (IsMobile and 28 or 34) or (IsMobile and 18 or 22))
					Astral.ApplyIcon(BIcon, bIcon)
					BIcon.ImageColor3 = iconOnlyMode and bColor or Color3.fromRGB(255, 255, 255)
					BIcon.ScaleType = Enum.ScaleType.Fit
					BIcon.Parent = Btn
				end

				if not iconOnlyMode and bTitle and bTitle ~= "" then
					local BLabel = Instance.new("TextLabel")
					BLabel.Name = "Label"
					BLabel.BackgroundTransparency = 1
					BLabel.Position = UDim2.new(0, bIcon and 38 or 10, 0, 0)
					BLabel.Size = UDim2.new(1, -(bIcon and 38 or 10) - (IsMobile and 68 or 76), 1, 0)
					BLabel.Font = Enum.Font.GothamBold
					tr(BLabel, bTitle)
					BLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
					BLabel.TextSize = IsMobile and 10 or 12
					BLabel.TextXAlignment = Enum.TextXAlignment.Left
					BLabel.TextTruncate = Enum.TextTruncate.AtEnd
					BLabel.Parent = Btn
				end

				tiles[i] = {Btn = Btn, Preview = TilePreview, Color = bColor, Callback = bCallback}
				local tileIndex = i
				Btn.MouseButton1Click:Connect(function()
					if pickerOpen or selectorOpen then return end
					local t = tiles[tileIndex]
					if not t then return end
					openColorPicker(t.Color, function(c)
						t.Color = c
						if t.Preview then
							t.Preview.BackgroundColor3 = c
						else
							local ic = t.Btn:FindFirstChild("Icon")
							if ic then ic.ImageColor3 = c end
						end
						task.spawn(t.Callback, tileIndex, c)
					end)
				end)
				if TilePreview then
					TilePreview.MouseButton1Click:Connect(function()
						if pickerOpen or selectorOpen then return end
						local t = tiles[tileIndex]
						if not t then return end
						openColorPicker(t.Color, function(c)
							t.Color = c
							if t.Preview then t.Preview.BackgroundColor3 = c end
							task.spawn(t.Callback, tileIndex, c)
						end)
					end)
				end
				Btn.MouseEnter:Connect(function()
					if pickerOpen or selectorOpen then return end
					TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(36, 36, 40)}):Play()
				end)
				Btn.MouseLeave:Connect(function()
					TweenService:Create(Btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
				end)
			end

			registerElement(Card, calculatedHeight, cfg.Position)

			local MultiColorController = {}
			function MultiColorController:GetColor(index)
				local t = tiles[index or 1]
				if t then return t.Color end
				return nil
			end
			function MultiColorController:GetAllColors()
				local out = {}
				for i, t in ipairs(tiles) do out[i] = t.Color end
				return out
			end
			function MultiColorController:SetColor(index, color)
				if typeof(color) ~= "Color3" then return end
				local t = tiles[index]
				if not t then return end
				t.Color = color
				if t.Preview then
					t.Preview.BackgroundColor3 = color
				else
					local ic = t.Btn:FindFirstChild("Icon")
					if ic then ic.ImageColor3 = color end
				end
			end
			function MultiColorController:Click(index)
				local t = tiles[index]
				if t and t.Callback then task.spawn(t.Callback, index, t.Color) end
			end
			return MultiColorController
		end
		TabObject.Addmulticolorpicker = TabObject.AddMultiColorPicker

		-- Fault tolerance: one bad element can never kill the whole UI build.
		-- Any failing Add* call is skipped and reported instead of aborting.
		do
			local addNames = {"AddButton", "AddToggle", "AddTick", "AddSlider", "AddTextbox",
				"AddSelector", "AddColorpicker", "AddLabel", "AddParagraph", "AddKeybind", "AddDiscordCard", "AddMultiButton", "AddMultiColorPicker"}
			for _, addName in ipairs(addNames) do
				local orig = TabObject[addName]
				if type(orig) == "function" then
					TabObject[addName] = function(self, ...)
						local ok, res = pcall(orig, self, ...)
						if not ok then
							warn("[Astral] " .. addName .. " failed: " .. tostring(res))
							return nil
						end
						return res
					end
				end
			end
		end

		-- if a non-dark theme is active, theme the new tab too (idempotent)

		-- MakeSubTab：在内容区顶部加一个横向 sub-tab 按钮；返回的代理把后续 AddXxx 归到该 sub-tab
		function TabObject:AddSubTab(stCfg)
			local stName = "SubTab"
			local stIcon = nil
			if type(stCfg) == "table" then
				stName = stCfg[1] or stCfg.Name or "SubTab"
				stIcon = parseIcon(stCfg[2] or stCfg.Icon)
			elseif type(stCfg) == "string" then
				stName = stCfg
			end

			-- 首次调用才显示 sub-tab 栏，原 PageScroll 下移让位
			if not subTabBarShown then
				subTabBarShown = true
			SubTabBar.Visible = true
			PageScroll.Position = UDim2.new(0, 0, 0, SubTabBarHeight + 6)
			PageScroll.Size = UDim2.new(1, 0, 1, -(SubTabBarHeight + 6))
			end

			local stIdx = #subTabs + 1

			local StBtn = Instance.new("TextButton")
			StBtn.Name = stName .. "_SubTabBtn"
			StBtn.BackgroundColor3 = Color3.fromRGB(32, 32, 40)
			StBtn.BackgroundTransparency = 0
			StBtn.BorderSizePixel = 0
			StBtn.Size = UDim2.new(0, 0, 0, SubTabBtnHeight)
			StBtn.AutomaticSize = Enum.AutomaticSize.X
			StBtn.AutoButtonColor = false
			StBtn.Text = ""
			StBtn.ClipsDescendants = true
			StBtn.LayoutOrder = stIdx
			StBtn.ZIndex = 7
			StBtn.Parent = SubTabScroll

			local StBtnCorner = Instance.new("UICorner")
			StBtnCorner.CornerRadius = UDim.new(0, 8)
			StBtnCorner.Parent = StBtn

			local StBtnStroke = Instance.new("UIStroke")
			StBtnStroke.Color = Color3.fromRGB(70, 70, 80)
			StBtnStroke.Thickness = 1
			StBtnStroke.Transparency = 0.5
			StBtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			StBtnStroke.Parent = StBtn

			local StBtnLayout = Instance.new("UIListLayout")
			StBtnLayout.FillDirection = Enum.FillDirection.Horizontal
			StBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			StBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
			StBtnLayout.Padding = UDim.new(0, 8)
			StBtnLayout.Parent = StBtn

			local StBtnPad = Instance.new("UIPadding")
			StBtnPad.PaddingLeft = UDim.new(0, 14)
			StBtnPad.PaddingRight = UDim.new(0, 14)
			StBtnPad.Parent = StBtn

			if stIcon then
				local StBtnIco = Instance.new("ImageLabel")
				StBtnIco.BackgroundTransparency = 1
				StBtnIco.Size = UDim2.fromOffset(IsMobile and 16 or 18, IsMobile and 16 or 18)
				StBtnIco.LayoutOrder = 1
				StBtnIco.ZIndex = 8
				Astral.ApplyIcon(StBtnIco, stIcon)
				StBtnIco.ImageColor3 = Color3.fromRGB(160, 160, 168)
				StBtnIco.Parent = StBtn
			end

			local StBtnText = Instance.new("TextLabel")
			StBtnText.Name = "SubTabText"
			StBtnText.BackgroundTransparency = 1
			StBtnText.Size = UDim2.new(0, 0, 1, 0)
			StBtnText.AutomaticSize = Enum.AutomaticSize.X
			StBtnText.Font = Enum.Font.GothamBold
			tr(StBtnText, stName)
			StBtnText.TextColor3 = Color3.fromRGB(160, 160, 168)
			mTS(StBtnText, 15)
			StBtnText.TextXAlignment = Enum.TextXAlignment.Center
			StBtnText.TextYAlignment = Enum.TextYAlignment.Center
			StBtnText.TextTruncate = Enum.TextTruncate.None
			StBtnText.LayoutOrder = 2
			StBtnText.ZIndex = 8
			StBtnText.Parent = StBtn

			local stData = {Button = StBtn, BStroke = StBtnStroke, BText = StBtnText, Index = stIdx}
			table.insert(subTabs, stData)

			StBtn.MouseEnter:Connect(function()
				if currentSubTab ~= stIdx then
					TweenService:Create(StBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.55}):Play()
					TweenService:Create(StBtnText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(220, 220, 228)}):Play()
				end
			end)
			StBtn.MouseLeave:Connect(function()
				if currentSubTab ~= stIdx then
					TweenService:Create(StBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0}):Play()
					TweenService:Create(StBtnText, TweenInfo.new(0.15), {TextColor3 = Color3.fromRGB(160, 160, 168)}):Play()
				end
			end)
			StBtn.MouseButton1Click:Connect(function()
				switchSubTab(stIdx)
			end)

			if stIdx == 1 then switchSubTab(stIdx) end

			-- 代理：借用 TabObject 的全部 AddXxx，注册期间把 currentBuildSubTab 指向本 sub-tab
			local proxy = {Name = stName, Index = stIdx}
			return setmetatable(proxy, {
				__index = function(_, key)
					local fn = TabObject[key]
					if type(fn) == "function" then
						return function(_, ...)
							local prev = currentBuildSubTab
							currentBuildSubTab = stIdx
							local ok, res = pcall(fn, TabObject, ...)
							currentBuildSubTab = prev
							if not ok then
								warn("[Astral] SubTab " .. stName .. ":" .. tostring(key) .. " failed: " .. tostring(res))
							end
							return res
						end
					end
					return fn
				end
			})
		end
		TabObject.Addsubtab = TabObject.AddSubTab

		return TabObject
	end

	-- Create Minimize Button at the bottom of the Sidebar
	local MinimizeButton = Instance.new("TextButton")
	MinimizeButton.Name = "MinimizeButton"
	MinimizeButton.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	MinimizeButton.BorderSizePixel = 0
	MinimizeButton.Position = IsMobile and UDim2.new(0.5, -18, 1, -42) or UDim2.new(0, 6, 1, -42)
	MinimizeButton.Size = IsMobile and UDim2.new(0, 36, 0, 36) or UDim2.new(1, -12, 0, 36)
	MinimizeButton.AutoButtonColor = false
	MinimizeButton.Text = ""
	MinimizeButton.ZIndex = 10
	MinimizeButton.Parent = Sidebar

	local MinimizeCorner = Instance.new("UICorner")
	MinimizeCorner.CornerRadius = UDim.new(0, 6)
	MinimizeCorner.Parent = MinimizeButton

	local MinimizeStroke = Instance.new("UIStroke")
	MinimizeStroke.Thickness = 1
	MinimizeStroke.Color = Color3.fromRGB(42, 42, 46)
	MinimizeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MinimizeStroke.ZIndex = 10
	MinimizeStroke.Parent = MinimizeButton

	local MinimizeIcon = Instance.new("ImageLabel")
	MinimizeIcon.Name = "MinimizeIcon"
	MinimizeIcon.BackgroundTransparency = 1
	MinimizeIcon.AnchorPoint = IsMobile and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5)
	MinimizeIcon.Position = IsMobile and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
	MinimizeIcon.Size = IsMobile and UDim2.new(0, 28, 0, 28) or UDim2.new(0, 24, 0, 24)
	MinimizeIcon.Rotation = IsMobile and 180 or 0
	MinimizeIcon.Image = "rbxassetid://96304569438872"
	MinimizeIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	MinimizeIcon.ScaleType = Enum.ScaleType.Fit
	MinimizeIcon.ZIndex = 11
	MinimizeIcon.Parent = MinimizeButton

	local MinimizeText = Instance.new("TextLabel")
	MinimizeText.Name = "MinimizeText"
	MinimizeText.BackgroundTransparency = 1
	MinimizeText.Position = UDim2.new(0, 34, 0, 0)
	MinimizeText.Size = UDim2.new(1, -42, 1, 0)
	MinimizeText.Font = Enum.Font.GothamSemibold
	MinimizeText.Text = "Minimize"
	MinimizeText.TextColor3 = Color3.fromRGB(180, 180, 185)
	mTS(MinimizeText, 11)
	MinimizeText.TextXAlignment = Enum.TextXAlignment.Left
	MinimizeText.TextYAlignment = Enum.TextYAlignment.Center
	MinimizeText.TextTransparency = IsMobile and 1 or 0
	MinimizeText.ZIndex = 11
	MinimizeText.Parent = MinimizeButton

	-- Unified Sidebar Toggle Function
	local function toggleSidebar()
		isCollapsed = not isCollapsed
		
		local targetSidebarWidth = isCollapsed and CollapsedSidebarWidth or SidebarWidth
		local targetContentOffset = targetSidebarWidth + 1
		local textTransparency = isCollapsed and 1 or 0

		TweenService:Create(Sidebar, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, targetSidebarWidth, 1, -51)
		}):Play()

		TweenService:Create(Separator, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, targetSidebarWidth, 0, 51)
		}):Play()

		TweenService:Create(ContentContainer, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, targetContentOffset, 0, 51),
			Size = UDim2.new(1, -targetContentOffset - 8, 1, -59)
		}):Play()

		for _, header in ipairs(categoryHeaders) do
			header.Visible = not isCollapsed
		end

		local targetMinButtonSize = isCollapsed and UDim2.new(0, 36, 0, 36) or UDim2.new(1, -12, 0, 36)
		local targetMinButtonPos = isCollapsed and UDim2.new(0.5, -18, 1, -42) or UDim2.new(0, 6, 1, -42)
		local targetMinCornerRadius = isCollapsed and UDim.new(0, 8) or UDim.new(0, 6)
		local targetMinIconPos = isCollapsed and UDim2.new(0.5, 0, 0.5, 0) or UDim2.new(0, 8, 0.5, 0)
		local targetMinIconAnchor = isCollapsed and Vector2.new(0.5, 0.5) or Vector2.new(0, 0.5)
		local targetMinIconRotation = isCollapsed and 180 or 0
		local targetMinIconSize = isCollapsed and UDim2.new(0, 24, 0, 24) or UDim2.new(0, 20, 0, 20)

		TweenService:Create(MinimizeButton, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = targetMinButtonSize,
			Position = targetMinButtonPos
		}):Play()

		TweenService:Create(MinimizeCorner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			CornerRadius = targetMinCornerRadius
		}):Play()

		TweenService:Create(MinimizeText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextTransparency = textTransparency
		}):Play()

		TweenService:Create(MinimizeIcon, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Position = targetMinIconPos,
			AnchorPoint = targetMinIconAnchor,
			Rotation = targetMinIconRotation,
			Size = targetMinIconSize
		}):Play()

		for _, tab in ipairs(tabs) do
			local targetButtonSize = isCollapsed and UDim2.new(0, 36, 0, 36) or UDim2.new(1, 0, 0, 36)
			local targetCornerRadius = isCollapsed and UDim.new(0, 8) or UDim.new(0, 6)

			TweenService:Create(tab.Button, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = targetButtonSize
			}):Play()

			TweenService:Create(tab.Corner, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CornerRadius = targetCornerRadius
			}):Play()

			TweenService:Create(tab.ButtonText, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = textTransparency
			}):Play()

			if isCollapsed then
				if tab.IconLabel then
					TweenService:Create(tab.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.new(0, 26, 0, 26)
					}):Play()
				elseif tab.FallbackLabel then
					tab.FallbackLabel.Visible = true
					TweenService:Create(tab.FallbackLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(0.5, 0, 0.5, 0),
						AnchorPoint = Vector2.new(0.5, 0.5),
						TextTransparency = 0,
						Size = UDim2.new(0, 26, 0, 26)
					}):Play()
				end
			else
				if tab.IconLabel then
					TweenService:Create(tab.IconLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(0, 10, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						Size = UDim2.new(0, 22, 0, 22)
					}):Play()
				elseif tab.FallbackLabel then
					TweenService:Create(tab.FallbackLabel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(0, 10, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						TextTransparency = 1,
						Size = UDim2.new(0, 22, 0, 22)
					}):Play()
				end
			end
		end
	end

	-- Apply collapsed state immediately if mobile (no animation)
	if isCollapsed then
		Sidebar.Size = UDim2.new(0, CollapsedSidebarWidth, 1, -51)
		Separator.Position = UDim2.new(0, CollapsedSidebarWidth, 0, 51)
		ContentContainer.Position = UDim2.new(0, CollapsedSidebarWidth + 1, 0, 51)
		ContentContainer.Size = UDim2.new(1, -CollapsedSidebarWidth - 9, 1, -59)
		for _, header in ipairs(categoryHeaders) do header.Visible = false end
		for _, tab in ipairs(tabs) do
			tab.Button.Size = UDim2.new(0, 36, 0, 36)
			tab.ButtonText.TextTransparency = 1
			if tab.Corner then tab.Corner.CornerRadius = UDim.new(0, 8) end
			if tab.IconLabel then
				tab.IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				tab.IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				tab.IconLabel.Size = UDim2.new(0, 26, 0, 26)
			elseif tab.FallbackLabel then
				tab.FallbackLabel.Visible = true
				tab.FallbackLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
				tab.FallbackLabel.AnchorPoint = Vector2.new(0.5, 0.5)
				tab.FallbackLabel.TextTransparency = 0
				tab.FallbackLabel.Size = UDim2.new(0, 26, 0, 26)
			end
		end
	end

	MinimizeButton.MouseButton1Click:Connect(function()
		toggleSidebar()
	end)

	MinimizeButton.MouseEnter:Connect(function()
		if pickerOpen or selectorOpen then return end
		TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {
			BackgroundColor3 = Color3.fromRGB(32, 32, 34)
		}):Play()
		TweenService:Create(MinimizeStroke, TweenInfo.new(0.15), {
			Color = Color3.fromRGB(52, 52, 56)
		}):Play()
	end)

	MinimizeButton.MouseLeave:Connect(function()
		TweenService:Create(MinimizeButton, TweenInfo.new(0.15), {
			BackgroundColor3 = themeCardBG(Window.ThemeName or "Dark")
		}):Play()
		TweenService:Create(MinimizeStroke, TweenInfo.new(0.15), {
			Color = Color3.fromRGB(42, 42, 46)
		}):Play()
	end)

	-- =========================================================================
	-- FIXED FEATURE: SEPARATED, ENLARGED, INDEPENDENTLY DRAGGABLE LOGO BUTTON
	-- =========================================================================

	-- LOGO TOGGLE BUTTON (Completely Independent ScreenGui Element)
	-- Smaller footprint (was oversized), slightly bigger on mobile for touch
	local logoSize = IsMobile and 54 or 72
	-- Default logo, change per window with Logo = "rbxassetid://..." in CreateWindow config
	local logoAsset = config.Logo or "rbxassetid://134909842242325"
	local LogoButton = Instance.new("TextButton")
	LogoButton.Name = "LogoButton"
	LogoButton.Size = UDim2.new(0, logoSize, 0, logoSize)
	
	-- Apply Responsive Position for Logo Button
	if IsMobile then
		LogoButton.Position = UDim2.new(0.05, -2, 0.32, -90)
	else
		LogoButton.Position = UDim2.new(0.05, -2, 0.32, -90)
	end
	defaultLogoPos = LogoButton.Position
	
	LogoButton.BackgroundColor3 = Color3.fromRGB(15, 15, 15) -- Dark black base matching image reference
	LogoButton.BorderSizePixel = 0
	LogoButton.Text = ""
	LogoButton.AutoButtonColor = false
	LogoButton.Active = true
	LogoButton.ClipsDescendants = true -- FIXED: Clips any overflowing square elements perfectly
	LogoButton.ZIndex = 101
	LogoButton.Parent = ScreenGui

	local LogoCorner = Instance.new("UICorner")
	LogoCorner.CornerRadius = UDim.new(1, 0) -- Perfect Circle
	LogoCorner.Parent = LogoButton

	local LogoStroke = Instance.new("UIStroke")
	LogoStroke.Color = Color3.fromRGB(58, 58, 66) -- Neutral ring (no accent)
	LogoStroke.Thickness = 1.5
	LogoStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	LogoStroke.Parent = LogoButton

	-- Logo Icon (Sized perfectly to fit snugly inside the button)
	local LogoIcon = Instance.new("ImageLabel")
	LogoIcon.Name = "LogoIcon"
	LogoIcon.BackgroundTransparency = 1
	LogoIcon.AnchorPoint = Vector2.new(0.5, 0.5)
	LogoIcon.Position = UDim2.new(0.5, 0, 0.5, 0)
	LogoIcon.Size = UDim2.new(1, -6, 1, -6) -- FIXED: Sized to sit perfectly inside the green border stroke
		LogoIcon.Image = logoAsset
	LogoIcon.ScaleType = Enum.ScaleType.Crop -- FIXED: Crop to fill circular frame perfectly without stretching
	LogoIcon.ZIndex = 103
	LogoIcon.Parent = LogoButton

	local LogoIconCorner = Instance.new("UICorner") -- FIXED: Rounds the square image asset itself into a perfect circle
	LogoIconCorner.CornerRadius = UDim.new(1, 0)
	LogoIconCorner.Parent = LogoIcon

	-- Logo Button Drop Shadow Frame
	local LogoShadow = Instance.new("Frame")
	LogoShadow.Name = "LogoShadow"
	LogoShadow.Size = LogoButton.Size
	LogoShadow.Position = LogoButton.Position + UDim2.new(0, 2, 0, 2)
	LogoShadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	LogoShadow.BackgroundTransparency = 0.4
	LogoShadow.ZIndex = 100
	LogoShadow.Parent = ScreenGui

	local LogoShadowCorner = Instance.new("UICorner")
	LogoShadowCorner.CornerRadius = UDim.new(1, 0)
	LogoShadowCorner.Parent = LogoShadow

	-- Sync Shadow Position with Dragging
	LogoButton:GetPropertyChangedSignal("Position"):Connect(function()
		LogoShadow.Position = LogoButton.Position + UDim2.new(0, 2, 0, 2)
	end)

	-- Apply Lag-Free Dragging to the logo button
	makeElementDraggable(LogoButton)

	-- Logo Button Click Action (Toggles Main UI Visibility)
	local uiVisible = true
	registerClick(LogoButton, function()
		uiVisible = not uiVisible
		MainFrame.Visible = uiVisible
		
		-- Smooth pop animation for the logo button
		TweenService:Create(LogoButton, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = uiVisible and UDim2.new(0, logoSize, 0, logoSize) or UDim2.new(0, logoSize - 10, 0, logoSize - 10)
		}):Play()
		TweenService:Create(LogoShadow, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = uiVisible and UDim2.new(0, logoSize, 0, logoSize) or UDim2.new(0, logoSize - 10, 0, logoSize - 10)
		}):Play()
	end)

	-- Stop Farm Callback Registry
	Astral.OnStopFarm = function()
		print("[Astral]: Stop Farm triggered! Resetting all features...")
		for _, controller in ipairs(Astral.Registry) do
			pcall(function()
				controller:Set(false)
			end)
		end
	end

	function Window:SetBackground(urlOrId)
		if type(urlOrId) ~= "string" or urlOrId == "" then return end
		if urlOrId:match("^https?://") then
			BackgroundImage.Image = bgFunc(urlOrId)
			BackgroundImage.ImageColor3 = Color3.fromRGB(255,255,255)
		else
			BackgroundImage.Image = urlOrId
			BackgroundImage.ImageColor3 = Color3.fromRGB(255,255,255)
		end
	end
	-- alias kept for old scripts: downloads the URL then applies it
	function Window:LoadBackgroundFromUrl(url)
		return Window:SetBackground(url)
	end
	function Window:SetBackgroundDim(transparency)
		local t = tonumber(transparency)
		if not t then return end
		BgDim.BackgroundTransparency = math.clamp(t, 0, 1)
	end

	function Window:ResetBackground()
		BackgroundImage.Image = ""
		BackgroundImage.ImageColor3 = Color3.fromRGB(58,58,64)
	end
	-- Manual window size override (preview PC vs mobile sizes live)
	function Window:SetWindowSize(w, h)
		if type(w) == "number" and w >= 200 then refW = w end
		if type(h) == "number" and h >= 140 then refH = h end
		-- Close popups first so they re-open sized to the new window
		if closeSelector then closeSelector() end
		if pickerOpen then closeColorPicker() end
		updateWindowSize()
	end
	-- Diagnostic: prints tab + element counts (paste console output when reporting bugs)
	function Window:DebugInfo()
		print("[Astral] tabs built: " .. #tabs)
		for _, t in ipairs(tabs) do
			local n = 0
			if t.Elements then n = #t.Elements end
			local gui = 0
			if t.Page then gui = #t.Page:GetDescendants() end
			print("[Astral] tab '" .. tostring(t.Button and t.Button.Name) .. "' elements: " .. n .. " gui: " .. gui)
		end
	end
	-- Re-run column layout on every tab (fixes anything built while hidden)
	function Window:RefreshAll()
		for _, td in ipairs(tabs) do
			pcall(function()
				if td.Refresh then td.Refresh() end
			end)
		end
	end
	function Window:SetLayoutMode(mode)
		if mode ~= "OneColumn" and mode ~= "TwoColumn" then
			mode = "Auto"
		end
		layoutMode = mode
		for _, td in ipairs(tabs) do
			pcall(function()
				if td.Refresh then td.Refresh() end
			end)
		end
	end

	local CONFIG_FILE = "lumu_config.json"
	local function encodeValue(kind, v)
		if kind == "color" and typeof(v) == "Color3" then
			return {r = math.floor(v.R * 255), g = math.floor(v.G * 255), b = math.floor(v.B * 255)}
		elseif kind == "key" and typeof(v) == "EnumItem" then
			return v.Name
		end
		return v
	end
	local function decodeValue(kind, v)
		if kind == "color" and type(v) == "table" then
			return Color3.fromRGB(tonumber(v.r) or 255, tonumber(v.g) or 255, tonumber(v.b) or 255)
		elseif kind == "key" and type(v) == "string" then
			local ok, kc = pcall(function() return Enum.KeyCode[v] end)
			if ok and kc then return kc end
			return nil
		end
		return v
	end
	-- Save all Flagged element states to file (survives server hop: Load on next run)
	function Window:SaveConfig(name)
		local data = {}
		for _, item in ipairs(configFlags) do
			local ok, v = pcall(item.Get)
			if ok then
				data[item.Flag] = encodeValue(item.Kind, v)
			end
		end
		local ok, json = pcall(function()
			return game:GetService("HttpService"):JSONEncode(data)
		end)
		if ok and writefile then
			pcall(writefile, name or CONFIG_FILE, json)
			return true
		end
		return false
	end
	-- Load saved states back (call after building UI; fires each callback to resume)
	function Window:LoadConfig(name)
		if not (readfile and isfile) then return false end
		local fname = name or CONFIG_FILE
		local okExists = false
		pcall(function() okExists = isfile(fname) end)
		if not okExists then return false end
		local okRead, raw = pcall(readfile, fname)
		if not okRead or not raw or raw == "" then return false end
		local okJson, data = pcall(function()
			return game:GetService("HttpService"):JSONDecode(raw)
		end)
		if not okJson or type(data) ~= "table" then return false end
		for _, item in ipairs(configFlags) do
			if data[item.Flag] ~= nil then
				local v = decodeValue(item.Kind, data[item.Flag])
				if v ~= nil then
					pcall(item.Set, v)
				end
			end
		end
		return true
	end

	-- UI positions: save / load / reset (main window, logo button, status panels)
	function Window:SaveUIPositions(name)
		local data = {}
		pcall(function() data.main = udimToTable(MainFrame.Position) end)
		pcall(function() data.logo = udimToTable(LogoButton.Position) end)
		data.status = {}
		pcall(function()
			for _, p in ipairs(statusPanels) do
				if p.Panel and p.Panel.Parent then
					table.insert(data.status, udimToTable(p.Panel.Position))
				end
			end
		end)
		return saveUIPosFile(name, data)
	end

	function Window:LoadUIPositions(name)
		local data = loadUIPosFile(name)
		if not data then return false end
		pcall(function()
			local pos = tableToUdim(data.main)
			if pos then MainFrame.Position = clampPanelOnScreen(pos, 880, 600) end
		end)
		pcall(function()
			local pos = tableToUdim(data.logo)
			if pos then LogoButton.Position = pos end
		end)
		pcall(function()
			if type(data.status) == "table" then
				for i, p in ipairs(statusPanels) do
					local pos = tableToUdim(data.status[i])
					if pos and p.Panel then
						p.Panel.Position = clampPanelOnScreen(pos, 276, 220)
					end
				end
			end
		end)
		return true
	end

	function Window:ResetUIPositions(name)
		pcall(function()
			local fname = name or UIPOS_FILE
			if delfile and isfile and isfile(fname) then
				pcall(delfile, fname)
			elseif writefile then
				pcall(writefile, fname, "")
			end
		end)
		pcall(function() MainFrame.Position = defaultMainPos end)
		pcall(function() LogoButton.Position = defaultLogoPos end)
		pcall(function()
			for _, p in ipairs(statusPanels) do
				if p.Panel and p.DefaultPos then
					p.Panel.Position = p.DefaultPos
				end
			end
		end)
		return true
	end
	function Window:SetAccent(color)
		if typeof(color) ~= "Color3" then return end
		AccentColor = color
		for _, fn in ipairs(accentAppliers) do
			pcall(fn, color)
		end
		-- recolor tab strokes + logo ring (not registered, direct refs)
		for _, td in ipairs(tabs) do pcall(function() if td.Stroke then td.Stroke.Color = color end end) end
		pcall(function() end) -- ring stays neutral
		-- re-apply the ACTIVE tab pill with the new accent (solid pill style)
		for _, td in ipairs(tabs) do
			if td == currentTab then
				pcall(function() td.Button.BackgroundColor3 = color; td.Button.BackgroundTransparency = 0 end)
				pcall(function() td.Stroke.Color = color; td.Stroke.Transparency = 0 end)
				if td.Gradient then td.Gradient.Enabled = false end
			else
				pcall(function() td.Stroke.Color = Color3.fromRGB(42, 42, 46) end)
			end
		end
	end

	function Window:SetTheme(name)
		local result = applyThemeToGui(ScreenGui, AccentColor, Window.ThemeName or "Dark", name)
		if result then
			Window.ThemeName = result
			CurrentThemeName = result
			return true
		end
		return false
	end

	function Window:GetTheme()
		return Window.ThemeName or "Dark"
	end

	-- Custom theme: pick your own colours for the main parts.
	--   Window:SetCustomTheme({
	--     Background = Color3.fromRGB(20, 20, 26),
	--     Card = Color3.fromRGB(30, 30, 38),
	--     Text = Color3.fromRGB(255, 255, 255),
	--     SubText = Color3.fromRGB(170, 170, 180),
	--     Border = Color3.fromRGB(60, 60, 72),
	--     Accent = Color3.fromRGB(0, 153, 235),
	--   })
	function Window:SetCustomTheme(opts)
		opts = opts or {}
		local function pick(c, fallbackKey)
			if typeof(c) == "Color3" then
				return math.floor(c.R * 255 + 0.5) .. "," .. math.floor(c.G * 255 + 0.5) .. "," .. math.floor(c.B * 255 + 0.5)
			end
			return fallbackKey
		end
		local bg = pick(opts.Background, "12,12,14")
		local card = pick(opts.Card, "26,26,30")
		local text = pick(opts.Text, "255,255,255")
		local sub = pick(opts.SubText, "160,160,165")
		local border = pick(opts.Border, "50,50,55")

		if opts.Accent and typeof(opts.Accent) == "Color3" then
			Window:SetAccent(opts.Accent)
		end

		CustomThemeValues = {
			["12,12,14"] = bg, ["15,15,15"] = bg,
			["26,26,30"] = card, ["18,18,22"] = card, ["16,16,18"] = card,
			["20,20,24"] = card, ["22,22,26"] = card, ["30,30,36"] = card,
			["28,28,34"] = card, ["36,36,40"] = card, ["32,32,36"] = card,
			["35,35,40"] = border, ["45,45,50"] = border, ["50,50,55"] = border,
			["38,38,44"] = border, ["52,52,60"] = border, ["54,54,62"] = border,
			["70,70,75"] = border,
			["255,255,255"] = text,
			["160,160,165"] = sub, ["150,150,158"] = sub, ["162,162,172"] = sub,
			["165,165,176"] = sub, ["175,175,182"] = sub, ["170,170,178"] = sub,
			["180,180,185"] = sub, ["120,120,125"] = sub, ["110,110,118"] = sub,
			["100,100,105"] = sub,
		}

		local result = applyThemeToGui(ScreenGui, AccentColor, Window.ThemeName or "Dark", "Custom")
		if result then
			Window.ThemeName = result
			CurrentThemeName = result
			return true
		end
		return false
	end
	
		-- ==========================================
		-- NOTIFICATION SYSTEM
		-- ==========================================
		local notifTypeColors = {
			good = {bg = Color3.fromRGB(46, 204, 113)},
			warning = {bg = Color3.fromRGB(255, 196, 40)},
			bad = {bg = Color3.fromRGB(231, 76, 60)}
		}
		local notifTypeIcons = {
			good = Astral.Icons.Checkmark,
			warning = Astral.Icons.Warning,
			bad = Astral.Icons.Close
		}

		function Window:Notify(config)
			config = config or {}
			local nType = config.Type or "good"
			local title = tostring(config.Title or "")
			local message = tostring(config.Message or "")
			local duration = tonumber(config.Duration) or 10
			if duration <= 0 then duration = 1 end
			local actions = config.Actions or {}
			local hasActions = #actions > 0
			local tColor = notifTypeColors[nType] or notifTypeColors.good
			local tIcon = notifTypeIcons[nType] or notifTypeIcons.good
			local notifH = (IsMobile and (hasActions and 90 or 56) or (hasActions and 88 or 62))

			-- type colour drives the whole card so good/warning/bad read instantly
			local tc = tColor.bg
			local function mix(base, color, amount)
				return Color3.fromRGB(
					math.floor(base.R * 255 * (1 - amount) + color.R * 255 * amount),
					math.floor(base.G * 255 * (1 - amount) + color.G * 255 * amount),
					math.floor(base.B * 255 * (1 - amount) + color.B * 255 * amount)
				)
			end

			local Frame = Instance.new("Frame")
			Frame.Size = UDim2.new(0, notifW, 0, notifH)
			Frame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			Frame.BorderSizePixel = 0
			Frame.ZIndex = 200
			Frame.ClipsDescendants = true
			Frame.Parent = NotificationContainer

			local Corner = Instance.new("UICorner")
			Corner.CornerRadius = UDim.new(0, 10)
			Corner.Parent = Frame

			local Stroke = Instance.new("UIStroke")
			Stroke.Thickness = 1.4
			Stroke.Color = Color3.fromRGB(50, 50, 55)
			Stroke.Transparency = 0.5
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Stroke.Parent = Frame


			-- Icon (matches UI IconContainer style)
			local IconFrame = Instance.new("Frame")
			IconFrame.Size = UDim2.fromOffset(IsMobile and 26 or 34, IsMobile and 26 or 34)
			IconFrame.Position = UDim2.new(0, 10, 0, hasActions and 10 or 12)
			IconFrame.BackgroundColor3 = mix(Color3.fromRGB(30, 30, 36), tc, 0.28)
			IconFrame.BorderSizePixel = 0
			IconFrame.ZIndex = 200
			IconFrame.Parent = Frame

			local IconCorner = Instance.new("UICorner")
			IconCorner.CornerRadius = UDim.new(0, IsMobile and 6 or 8)
			IconCorner.Parent = IconFrame

			local IconStroke = Instance.new("UIStroke")
			IconStroke.Thickness = 1.2
			IconStroke.Color = tc
			IconStroke.Transparency = 0.4
			IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			IconStroke.Parent = IconFrame

			local Icon = Instance.new("ImageLabel")
			Icon.Size = UDim2.fromOffset(IsMobile and 17 or 22, IsMobile and 17 or 22)
			Icon.AnchorPoint = Vector2.new(0.5, 0.5)
			Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
			Icon.BackgroundTransparency = 1
			Astral.ApplyIcon(Icon, tIcon)
			Icon.ImageColor3 = tc
			Icon.ZIndex = 200
			Icon.Parent = IconFrame

			-- Text
			local TextFrame = Instance.new("Frame")
			TextFrame.Size = UDim2.new(1, IsMobile and -60 or -68, 0, hasActions and 38 or 34)
			TextFrame.Position = UDim2.new(0, IsMobile and 42 or 50, 0, hasActions and 6 or 8)
			TextFrame.BackgroundTransparency = 1
			TextFrame.ZIndex = 200
			TextFrame.Parent = Frame

			local TitleLabel = Instance.new("TextLabel")
			TitleLabel.Size = UDim2.new(1, -6, 0, 18)
			TitleLabel.BackgroundTransparency = 1
			TitleLabel.Font = Enum.Font.GothamBold
			tr(TitleLabel, title)
			TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
			regText(TitleLabel, IsMobile and 10 or 12)
			TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
			TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
			TitleLabel.ZIndex = 200
			TitleLabel.Parent = TextFrame

			local DescLabel = Instance.new("TextLabel")
			DescLabel.Size = UDim2.new(1, -6, 0, hasActions and 20 or 24)
			DescLabel.Position = UDim2.new(0, 0, 0, 19)
			DescLabel.BackgroundTransparency = 1
			DescLabel.Font = Enum.Font.Gotham
			DescLabel.Text = message
			DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
			regText(DescLabel, IsMobile and 9 or 11)
			DescLabel.TextXAlignment = Enum.TextXAlignment.Left
			DescLabel.TextYAlignment = Enum.TextYAlignment.Top
			DescLabel.TextWrapped = true
			DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
			DescLabel.ZIndex = 200
			DescLabel.Parent = TextFrame

			-- countdown seconds (top-right)
			local CountPill = Instance.new("Frame")
			CountPill.Name = "CountdownPill"
			CountPill.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
			CountPill.BorderSizePixel = 0
			CountPill.AnchorPoint = Vector2.new(1, 0)
			CountPill.Position = UDim2.new(1, -12, 0, 11)
			CountPill.Size = UDim2.new(0, IsMobile and 24 or 34, 0, IsMobile and 14 or 18)
			CountPill.ZIndex = 202
			CountPill.Parent = Frame

			local CountPillCorner = Instance.new("UICorner")
			CountPillCorner.CornerRadius = UDim.new(0, 6)
			CountPillCorner.Parent = CountPill

			local CountPillStroke = Instance.new("UIStroke")
			CountPillStroke.Color = Color3.fromRGB(50, 50, 55)
			CountPillStroke.Transparency = 0.5
			CountPillStroke.Thickness = 1
			CountPillStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			CountPillStroke.Parent = CountPill

			local CountLabel = Instance.new("TextLabel")
			CountLabel.Name = "Countdown"
			CountLabel.BackgroundTransparency = 1
			CountLabel.Size = UDim2.new(1, 0, 1, 0)
			CountLabel.Font = Enum.Font.GothamBold
			CountLabel.Text = tostring(math.ceil(duration)) .. "s"
			CountLabel.TextSize = IsMobile and 10 or 11
			CountLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
			CountLabel.TextXAlignment = Enum.TextXAlignment.Center
			CountLabel.ZIndex = 203
			CountLabel.Parent = CountPill

			-- Bottom progress bar (neutral, matches UI - no type colors)
			local ProgressTrack = Instance.new("Frame")
			ProgressTrack.Name = "ProgressTrack"
			ProgressTrack.Size = UDim2.new(1, -24, 0, 3)
			ProgressTrack.Position = UDim2.new(0, 12, 1, -6)
			ProgressTrack.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
			ProgressTrack.BorderSizePixel = 0
			ProgressTrack.ZIndex = 201
			ProgressTrack.Parent = Frame

			local TrackCorner = Instance.new("UICorner")
			TrackCorner.CornerRadius = UDim.new(1, 0)
			TrackCorner.Parent = ProgressTrack

			local ProgressFill = Instance.new("Frame")
			ProgressFill.Name = "ProgressFill"
			ProgressFill.Size = UDim2.new(1, 0, 1, 0)
			ProgressFill.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
			ProgressFill.BorderSizePixel = 0
			ProgressFill.ZIndex = 202
			ProgressFill.Parent = ProgressTrack

			local FillCorner = Instance.new("UICorner")
			FillCorner.CornerRadius = UDim.new(1, 0)
			FillCorner.Parent = ProgressFill

			-- Action Buttons (premium: primary = type color, others = dark UI style)
			local dismiss
			local btnRow
			if hasActions then
				btnRow = Instance.new("Frame")
				btnRow.Size = UDim2.new(1, -56, 0, IsMobile and 24 or 26)
				btnRow.Position = UDim2.new(0, 42, 0, IsMobile and 56 or 58)
				btnRow.BackgroundTransparency = 1
				btnRow.ZIndex = 200
				btnRow.Parent = Frame

				local BtnLayout = Instance.new("UIListLayout")
				BtnLayout.FillDirection = Enum.FillDirection.Horizontal
				BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
				BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				BtnLayout.Padding = UDim.new(0, 8)
				BtnLayout.Parent = btnRow

				for i, action in ipairs(actions) do
					local aType = action.Type or nType
					local aColor = (notifTypeColors[aType] or tColor).bg
					local isPrimary = (i == 1)
					local Btn = Instance.new("TextButton")
					Btn.Size = UDim2.new(0, IsMobile and 44 or 72, 0, IsMobile and 22 or 26)
					Btn.BackgroundColor3 = isPrimary and aColor or Color3.fromRGB(36, 36, 40)
					Btn.BorderSizePixel = 0
					Btn.Font = Enum.Font.GothamBold
					Btn.Text = action.Text or ""
					Btn.TextColor3 = isPrimary and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(255, 255, 255)
					Btn.TextSize = IsMobile and 10 or 11
					Btn.AutoButtonColor = false
					Btn.ZIndex = 200
					Btn.Parent = btnRow

					local BtnCorner = Instance.new("UICorner")
					BtnCorner.CornerRadius = UDim.new(0, 6)
					BtnCorner.Parent = Btn

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
						if pickerOpen or selectorOpen then return end
						TweenService:Create(BtnScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1.04}):Play()
					end)
					Btn.MouseLeave:Connect(function()
						TweenService:Create(BtnScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 1}):Play()
					end)
					Btn.MouseButton1Down:Connect(function()
						TweenService:Create(BtnScale, TweenInfo.new(0.08), {Scale = 0.96}):Play()
					end)
					Btn.MouseButton1Up:Connect(function()
						TweenService:Create(BtnScale, TweenInfo.new(0.12), {Scale = 1.04}):Play()
					end)
					Btn.MouseButton1Click:Connect(function()
						if action.Callback then
							task.spawn(action.Callback)
						end
						dismiss()
					end)
				end
			end

			-- Hover highlight like UI cards
			Frame.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = themeStrokeHover(Window.ThemeName or "Dark")}):Play()
			end)
			Frame.MouseLeave:Connect(function()
				TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = themeStroke(Window.ThemeName or "Dark")}):Play()
			end)

			-- Slide in from right side
			Frame.Position = UDim2.new(1, 60, 0, 0)
			Frame.BackgroundTransparency = 1
			local NotifScale = Instance.new("UIScale")
			NotifScale.Scale = 0.96
			NotifScale.Parent = Frame
			TweenService:Create(Frame, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 0, 0),
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(NotifScale, TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()

			-- Auto-Dismiss with progress bar
			local elapsed = 0
			local running = true
			local conn

			dismiss = function()
				if not running then return end
				running = false
				if conn then conn:Disconnect() end
				TweenService:Create(Frame, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Position = UDim2.new(1, 60, 0, 0),
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(NotifScale, TweenInfo.new(0.28, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Scale = 0.96
				}):Play()
				task.delay(0.3, function()
					pcall(function() Frame:Destroy() end)
				end)
			end

			conn = game:GetService("RunService").Heartbeat:Connect(function(dt)
				if not running then return end
				elapsed = elapsed + dt
				local remain = math.clamp(1 - (elapsed / duration), 0, 1)
				pcall(function()
					ProgressFill.Size = UDim2.new(remain, 0, 1, 0)
					CountLabel.Text = tostring(math.max(0, math.ceil(duration - elapsed))) .. "s"
				end)
				if elapsed >= duration then
					dismiss()
				end
			end)
		end

	-- =========================================================================
	-- GAME STATUS -- small draggable overlay panel outside the window
	--   local S = Window:AddGameStatus({ Title = "Game Status" })
	--   S:Set("Server Uptime", "56h")
	--   S:Countdown("Next Boss", 300)            -- 5m 0s -> 0s
	--   S:Countdown("Full Moon", 1380, "down")
	--   S:Countdown("Uptime", 56*3600, "up")
	-- =========================================================================
	-- =========================================================================
	-- GAME STATUS -- small draggable overlay panel outside the window
	--   local S = Window:AddGameStatus({ Title = "Game Status" })
	--   S:Set("Server Uptime", "56h")
	--   S:SetRow("Next Boss", { Value = "5m", Icon = "timer", Color = "gold" })
	--   S:Countdown("Next Full Moon", 1380)
	-- =========================================================================
	-- =========================================================================
	-- GAME STATUS -- small draggable overlay panel outside the window
	--   local S = Window:AddGameStatus({ Title = "Game Status" })
	--   S:Set("Server Uptime", "56h")
	--   S:SetRow("Next Boss", { Value = "5m", Icon = "timer", Color = "gold" })
	--   S:Countdown("Next Full Moon", 1380)
	-- =========================================================================
	function Window:AddGameStatus(config)
		config = config or {}
		local title = config.Title or "Game Status"
		local icon = parseIcon(config.Icon or "timer")
		local panelW = tonumber(config.Width) or (IsMobile and 150 or 240)
		local rowH = tonumber(config.RowHeight) or (IsMobile and 24 or 30)
		local enabled = config.Enabled
		if enabled == nil then enabled = true end
		local rows = {}

		local NAMED = {
			red = Color3.fromRGB(231, 76, 60),
			green = Color3.fromRGB(46, 204, 113),
			blue = Color3.fromRGB(0, 153, 235),
			cyan = Color3.fromRGB(0, 210, 255),
			purple = Color3.fromRGB(138, 90, 255),
			pink = Color3.fromRGB(255, 90, 180),
			orange = Color3.fromRGB(243, 156, 18),
			gold = Color3.fromRGB(255, 196, 40),
			white = Color3.fromRGB(240, 240, 245),
			gray = Color3.fromRGB(160, 160, 168),
		}
		local function parseColor(v)
			if typeof(v) == "Color3" then return v end
			if type(v) == "string" then return NAMED[v:lower()] end
			return nil
		end

		local gsHeaderH = IsMobile and 36 or 44
		local gsMaxPanelH = IsMobile and 220 or 300

		local Panel = Instance.new("Frame")
		Panel.Name = "GameStatus"
		Panel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		Panel.BorderSizePixel = 0
		Panel.Size = UDim2.new(0, panelW, 0, gsHeaderH)
		Panel.Position = config.Position or UDim2.new(0, 1254, 0, 64)
		Panel.ZIndex = 500
		Panel.Active = true
		Panel.Visible = enabled
		Panel.ClipsDescendants = true
		Panel.Parent = ScreenGui
		do
			Panel.Position = clampPanelOnScreen(Panel.Position, panelW, 220)
			table.insert(statusPanels, { Panel = Panel, DefaultPos = Panel.Position })
		end

		local gsCornerR = IsMobile and 8 or 12
		local PanelCorner = Instance.new("UICorner")
		PanelCorner.CornerRadius = UDim.new(0, gsCornerR)
		PanelCorner.Parent = Panel

		local PanelStroke = Instance.new("UIStroke")
		PanelStroke.Color = Color3.fromRGB(54, 54, 64)
		PanelStroke.Thickness = 1.2
		PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		PanelStroke.Parent = Panel

		local PanelGrad = Instance.new("UIGradient")
		PanelGrad.Rotation = 90
		PanelGrad.Color = ColorSequence.new(Color3.fromRGB(30, 30, 38), Color3.fromRGB(16, 16, 20))
		PanelGrad.Parent = Panel

		local PanelLayout = Instance.new("UIListLayout")
		PanelLayout.FillDirection = Enum.FillDirection.Vertical
		PanelLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PanelLayout.Padding = UDim.new(0, 0)
		PanelLayout.Parent = Panel

		-- Header doubles as the drag handle
		local Header = Instance.new("Frame")
		Header.Name = "Header"
		Header.BackgroundColor3 = Color3.fromRGB(28, 28, 35)
		Header.BackgroundTransparency = 0.35
		Header.BorderSizePixel = 0
		Header.Size = UDim2.new(1, 0, 0, IsMobile and 36 or 44)
		Header.LayoutOrder = 1
		Header.ZIndex = 501
		Header.Active = true
		Header.Parent = Panel

		-- NOTE: no UICorner on the header on purpose. The panel clips children
		-- to its own rounded shape, so header corners are always perfect.
		local HeaderIcon = Instance.new("ImageLabel")
		HeaderIcon.Name = "Icon"
		HeaderIcon.BackgroundTransparency = 1
		HeaderIcon.AnchorPoint = Vector2.new(0, 0.5)
		HeaderIcon.Position = UDim2.new(0, 12, 0.5, 0)
		HeaderIcon.Size = UDim2.new(0, IsMobile and 15 or 19, 0, IsMobile and 15 or 19)
		HeaderIcon.ZIndex = 502
		HeaderIcon.ScaleType = Enum.ScaleType.Fit
		HeaderIcon.ImageColor3 = AccentColor
		if icon then Astral.ApplyIcon(HeaderIcon, icon) end
		HeaderIcon.Parent = Header
		onAccentChange(function(c) HeaderIcon.ImageColor3 = c end)

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Name = "Title"
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.AnchorPoint = Vector2.new(0, 0.5)
		TitleLabel.Position = UDim2.new(0, 39, 0.5, 0)
		TitleLabel.Size = UDim2.new(0, math.max(40, panelW - 39 - 66), 1, 0)
		TitleLabel.Font = Enum.Font.GothamBold
		tr(TitleLabel, title)
		TitleLabel.TextSize = IsMobile and 13 or 15
		TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextTruncate = Enum.TextTruncate.AtEnd
		TitleLabel.ZIndex = 502
		TitleLabel.Parent = Header

		-- Minimize/Expand "-" button
		local gsMinimized = false
		local MinBtn = Instance.new("TextButton")
		MinBtn.Name = "MinimizeBtn"
		MinBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
		MinBtn.Size = UDim2.new(0, IsMobile and 22 or 26, 0, IsMobile and 22 or 26)
		MinBtn.AnchorPoint = Vector2.new(1, 0.5)
		MinBtn.Position = UDim2.new(1, -10, 0.5, 0)
		MinBtn.Text = "-"
		MinBtn.TextColor3 = Color3.fromRGB(180, 180, 185)
		MinBtn.Font = Enum.Font.GothamBold
		MinBtn.TextSize = IsMobile and 14 or 16
		MinBtn.AutoButtonColor = false
		MinBtn.ZIndex = 503
		MinBtn.Parent = Header

		local MinBtnCorner = Instance.new("UICorner")
		MinBtnCorner.CornerRadius = UDim.new(0, 5)
		MinBtnCorner.Parent = MinBtn

		local RowsContainer
		local RowsLayout
		local function resizePanel(animate)
			if not RowsContainer or not RowsLayout then return end
			local rowsH = RowsLayout.AbsoluteContentSize.Y + 14
			local contentH = gsHeaderH + rowsH
			local targetH = math.min(contentH, gsMaxPanelH)
			targetH = math.max(targetH, gsHeaderH)
			if animate then
				TweenService:Create(Panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, panelW, 0, targetH)
				}):Play()
			else
				Panel.Size = UDim2.new(0, panelW, 0, targetH)
			end
		end

		MinBtn.MouseButton1Click:Connect(function()
			gsMinimized = not gsMinimized
			if gsMinimized then
				MinBtn.Text = "+"
				RowsContainer.Visible = false
				TweenService:Create(Panel, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.new(0, panelW, 0, gsHeaderH)
				}):Play()
			else
				MinBtn.Text = "-"
				RowsContainer.Visible = true
				resizePanel(true)
			end
		end)

		MinBtn.MouseEnter:Connect(function()
			TweenService:Create(MinBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(55, 55, 65)}):Play()
		end)
		MinBtn.MouseLeave:Connect(function()
			TweenService:Create(MinBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(40, 40, 48)}):Play()
		end)

		local Sep = Instance.new("Frame")
		Sep.Name = "Separator"
		Sep.BackgroundColor3 = Color3.fromRGB(48, 48, 58)
		Sep.BorderSizePixel = 0
		Sep.AnchorPoint = Vector2.new(0.5, 1)
		Sep.Position = UDim2.new(0.5, 0, 1, 0)
		Sep.Size = UDim2.new(1, -20, 0, 1)
		Sep.ZIndex = 502
		Sep.Parent = Header

		local maxRowsH = IsMobile and 180 or 260
		RowsContainer = Instance.new("ScrollingFrame")
		RowsContainer.Name = "Rows"
		RowsContainer.BackgroundTransparency = 1
		RowsContainer.Size = UDim2.new(1, 0, 1, -(gsHeaderH + 2))
		RowsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
		RowsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
		RowsContainer.ScrollBarThickness = 3
		RowsContainer.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 90)
		RowsContainer.ScrollBarImageTransparency = 0.4
		RowsContainer.LayoutOrder = 2
		RowsContainer.ZIndex = 501
		RowsContainer.Parent = Panel

		RowsLayout = Instance.new("UIListLayout")
		RowsLayout.FillDirection = Enum.FillDirection.Vertical
		RowsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		RowsLayout.Padding = UDim.new(0, 3)
		RowsLayout.Parent = RowsContainer

		local RowsPad = Instance.new("UIPadding")
		RowsPad.PaddingLeft = UDim.new(0, 12)
		RowsPad.PaddingRight = UDim.new(0, 12)
		RowsPad.PaddingTop = UDim.new(0, 7)
		RowsPad.PaddingBottom = UDim.new(0, 12)
		RowsPad.Parent = RowsContainer

		-- Auto-fit the panel whenever rows change. AbsoluteContentSize only
		-- updates after layout runs, so this also fixes initial sizing where
		-- a synchronous read still sees 0.
		RowsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			if not gsMinimized then resizePanel(false) end
		end)

		local ICON_GAP = 25

		local function makeRow(name, value, iconAsset, colorOverride)
			local Row = Instance.new("Frame")
			Row.Name = "Row"
			Row.BackgroundTransparency = 1
			Row.Size = UDim2.new(1, 0, 0, rowH)
			Row.ZIndex = 501
			Row.Parent = RowsContainer

			-- Rounded hover highlight behind the text
			local RowHover = Instance.new("Frame")
			RowHover.Name = "Hover"
			RowHover.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
			RowHover.BackgroundTransparency = 1
			RowHover.BorderSizePixel = 0
			RowHover.Position = UDim2.new(0, -6, 0, 0)
			RowHover.Size = UDim2.new(1, 12, 1, 0)
			RowHover.ZIndex = 500
			RowHover.Parent = Row

			local RowHoverCorner = Instance.new("UICorner")
			RowHoverCorner.CornerRadius = UDim.new(0, 6)
			RowHoverCorner.Parent = RowHover

			local IconLabel = Instance.new("ImageLabel")
			IconLabel.Name = "Icon"
			IconLabel.BackgroundTransparency = 1
			IconLabel.AnchorPoint = Vector2.new(0, 0.5)
			IconLabel.Position = UDim2.new(0, 2, 0.5, 0)
			IconLabel.Size = UDim2.new(0, IsMobile and 14 or 17, 0, IsMobile and 14 or 17)
			IconLabel.Visible = false
			IconLabel.ScaleType = Enum.ScaleType.Fit
			IconLabel.ImageColor3 = colorOverride or Color3.fromRGB(205, 205, 214)
			IconLabel.ZIndex = 502
			IconLabel.Parent = Row

			local NameLabel = Instance.new("TextLabel")
			NameLabel.Name = "Name"
			NameLabel.BackgroundTransparency = 1
			NameLabel.AnchorPoint = Vector2.new(0, 0.5)
			NameLabel.Position = UDim2.new(0, 0, 0.5, 0)
			NameLabel.Size = UDim2.new(0.58, 0, 1, 0)
			NameLabel.Font = Enum.Font.Gotham
			tr(NameLabel, tostring(name))
			NameLabel.TextSize = IsMobile and 12 or 14
			NameLabel.TextColor3 = Color3.fromRGB(165, 165, 176)
			NameLabel.TextXAlignment = Enum.TextXAlignment.Left
			NameLabel.TextTruncate = Enum.TextTruncate.AtEnd
			NameLabel.ZIndex = 502
			NameLabel.Parent = Row

			local ValueLabel = Instance.new("TextLabel")
			ValueLabel.Name = "Value"
			ValueLabel.BackgroundTransparency = 1
			ValueLabel.AnchorPoint = Vector2.new(1, 0.5)
			ValueLabel.Position = UDim2.new(1, -2, 0.5, 0)
			ValueLabel.Size = UDim2.new(0.42, 0, 1, 0)
			ValueLabel.Font = Enum.Font.GothamBold
			ValueLabel.Text = tostring(value or "--")
			ValueLabel.TextSize = IsMobile and 12 or 14
			ValueLabel.TextColor3 = colorOverride or AccentColor
			ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
			ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
			ValueLabel.ZIndex = 502
			ValueLabel.Parent = Row

			Row.MouseEnter:Connect(function()
				if pickerOpen or selectorOpen then return end
				TweenService:Create(RowHover, TweenInfo.new(0.15), {BackgroundTransparency = 0.15}):Play()
			end)
			Row.MouseLeave:Connect(function()
				TweenService:Create(RowHover, TweenInfo.new(0.15), {BackgroundTransparency = 1}):Play()
			end)

			local row = { Frame = Row, Name = NameLabel, Value = ValueLabel, Icon = IconLabel, Hover = RowHover, color = colorOverride, token = 0 }
			onAccentChange(function(c)
				if not row.color then row.Value.TextColor3 = c end
			end)
			return row
		end

		local function applyRow(row, opts)
			opts = opts or {}
			if opts.Icon ~= nil then
				local asset = parseIcon(opts.Icon)
				if asset then
					Astral.ApplyIcon(row.Icon, asset)
					row.Icon.Visible = true
					row.Name.Position = UDim2.new(0, ICON_GAP, 0.5, 0)
					row.Name.Size = UDim2.new(0.58, -ICON_GAP, 1, 0)
				else
					row.Icon.Visible = false
					row.Name.Position = UDim2.new(0, 0, 0.5, 0)
					row.Name.Size = UDim2.new(0.58, 0, 1, 0)
				end
			end
			if opts.Color ~= nil then
				row.color = parseColor(opts.Color)
				row.Value.TextColor3 = row.color or AccentColor
				row.Icon.ImageColor3 = row.color or Color3.fromRGB(205, 205, 214)
			end
			if opts.Value ~= nil then
				row.Value.Text = tostring(opts.Value)
			end
			if opts.Name ~= nil then
				tr(row.Name, tostring(opts.Name))
			end
		end

		-- Drag the whole panel by its header
		local dragging, dragStart, startPos = false, nil, nil
		Header.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				pcall(function() MainFrame:SetAttribute("StatusDragT", os.clock()) end)
				dragging = true
				dragStart = input.Position
				startPos = Panel.Position
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
				local nextPos = UDim2.new(startPos.X.Scale, startPos.X.Offset + dx, startPos.Y.Scale, startPos.Y.Offset + dy)
				Panel.Position = clampPanelOnScreen(nextPos, panelW, 220)
			end
		end)

		local function fmtDuration(sec)
			sec = math.max(0, math.floor(sec))
			local h = math.floor(sec / 3600)
			local m = math.floor((sec % 3600) / 60)
			local s = sec % 60
			if h > 0 then return h .. "h " .. m .. "m" end
			if m > 0 then return m .. "m " .. s .. "s" end
			return s .. "s"
		end

		local GameStatus = {}

		function GameStatus:SetRow(name, opts)
			name = tostring(name)
			opts = opts or {}
			local row = rows[name]
			if not row then
				row = makeRow(name, opts.Value, nil, parseColor(opts.Color))
				rows[name] = row
			end
			row.token = (row.token or 0) + 1
			applyRow(row, opts)
			if not gsMinimized then task.defer(function() resizePanel(false) end) end

		return GameStatus
		end

		function GameStatus:Set(name, value)
			if type(value) == "table" then return GameStatus:SetRow(name, value) end

		return GameStatus:SetRow(name, { Value = value })
		end
		GameStatus.SetValue = GameStatus.Set

		function GameStatus:SetColor(name, color)
			local r = rows[tostring(name)]
			if r then applyRow(r, { Color = color }) end

		return GameStatus
		end

		function GameStatus:SetIcon(name, iconInput)
			local r = rows[tostring(name)]
			if r then applyRow(r, { Icon = iconInput }) end

		return GameStatus
		end

		function GameStatus:Get(name)
			local r = rows[tostring(name)]
			return r and r.Value.Text or nil
		end

		function GameStatus:Remove(name)
			name = tostring(name)
			local r = rows[name]
			if r then pcall(function() r.Frame:Destroy() end); rows[name] = nil end
			if not gsMinimized then task.defer(function() resizePanel(false) end) end

		return GameStatus
		end

		function GameStatus:Clear()
			for _, r in pairs(rows) do pcall(function() r.Frame:Destroy() end) end
			rows = {}
			if not gsMinimized then task.defer(function() resizePanel(false) end) end

		return GameStatus
		end

		function GameStatus:SetRows(list)
			GameStatus:Clear()
			for _, r in ipairs(list or {}) do
				if type(r) == "table" then
					local nm = r.Name or r[1]
					if type(r[2]) == "table" then
						GameStatus:SetRow(nm, r[2])
					else
						GameStatus:SetRow(nm, { Value = r.Value or r[2], Icon = r.Icon, Color = r.Color })
					end
				end
			end

		return GameStatus
		end

		-- Live row timer: GameStatus:Countdown("Next Boss", 300) / (..., "up")
		function GameStatus:Countdown(name, seconds, mode, onDone)
			if type(mode) == "function" then onDone = mode; mode = "down" end
			mode = mode or "down"
			name = tostring(name)
			if not rows[name] then GameStatus:Set(name, "") end
			local row = rows[name]
			row.token = (row.token or 0) + 1
			local myToken = row.token
			local value = math.max(0, math.floor(tonumber(seconds) or 0))
			task.spawn(function()
				while true do
					if row.token ~= myToken then return end
					row.Value.Text = fmtDuration(value)
					if mode == "up" then
						task.wait(1)
						value = value + 1
					else
						if value <= 0 then break end
						task.wait(1)
						value = value - 1
					end
				end
				if row.token == myToken and mode ~= "up" and onDone then task.spawn(onDone) end
			end)

		return GameStatus
		end

		function GameStatus:StopCountdown(name)
			local r = rows[tostring(name)]
			if r then r.token = (r.token or 0) + 1 end

		return GameStatus
		end

		function GameStatus:SetTitle(t) TitleLabel.Text = tostring(t); return GameStatus end
		function GameStatus:SetTitleIcon(iconInput)
			local asset = parseIcon(iconInput)
			if asset then Astral.ApplyIcon(HeaderIcon, asset) end

		return GameStatus
		end
		function GameStatus:SetPosition(pos) Panel.Position = pos; return GameStatus end
		function GameStatus:Show() enabled = true; Panel.Visible = true; return GameStatus end
		function GameStatus:Hide() enabled = false; Panel.Visible = false; return GameStatus end
		function GameStatus:SetEnabled(v)
			if v then return GameStatus:Show() end

		return GameStatus:Hide()
		end
		function GameStatus:Toggle() return GameStatus:SetEnabled(not enabled) end
		function GameStatus:IsEnabled() return enabled end
		function GameStatus:Destroy() pcall(function() Panel:Destroy() end) end

		if config.Rows then GameStatus:SetRows(config.Rows) end

		if Window.ThemeName and Window.ThemeName ~= "Dark" then
			applyThemeToGui(ScreenGui, AccentColor, "Dark", Window.ThemeName)
		end

		return GameStatus
	end



	Window.ThemeName = "Dark"
	if config.Theme and type(config.Theme) == "string" then
		local initial = applyThemeToGui(ScreenGui, AccentColor, "Dark", config.Theme)
		if initial then Window.ThemeName = initial; CurrentThemeName = initial end
	end

	-- restore saved UI positions (main, logo, status panels)
	pcall(function() Window:LoadUIPositions() end)

	-- auto-load saved element states so a server hop resumes itself
	if config.AutoLoad or config.AutoLoadConfig then
		local cfgName = config.ConfigName
		task.delay(1, function()
			pcall(Window.LoadConfig, Window, cfgName)
		end)
	end

	-- design identity + LIVE switcher (no rejoin needed; choice is persisted)
	Window.DesignName = "Sidebar"
	Window._Config = config

	function Window:GetDesign()
		return Window.DesignName
	end

	-- register this lib in the design cache so SwitchDesign can swap instantly
	Astral._DesignCache["Sidebar"] = Astral

	-- Switch design right now: wipes this UI, rebuilds in the other design instantly.
	-- Priority: LumuHubReload hook (rebuilds your full app) > cached lib > HTTP fallback.
	function Window:SwitchDesign(design)
		if design ~= "Sidebar" and design ~= "TopBar" then return false end
		writeDesignPref(design)
		-- 1) app-provided reload hook (rebuilds the whole script, keeps your tabs)
		if type(getgenv().LumuHubReload) == "function" then
			local ok = pcall(getgenv().LumuHubReload, design)
			if ok then return true end
		end
		-- 2) cached lib (instant, no network -- loader must cache both libs at startup)
		local cached = Astral._DesignCache and Astral._DesignCache[design]
		if cached then
			local ok = pcall(function()
				if cached.RegisterIcons and Astral.Icons then pcall(cached.RegisterIcons, cached, Astral.Icons) end
				local cfg = Window._Config or { Title = "Lumu" }
				pcall(function() ScreenGui:Destroy() end)
				cached:CreateWindow(cfg)
			end)
			if ok then return true end
		end
		-- 3) last resort: HTTP fallback (slow)
		local ok3 = pcall(function()
			local lib = loadstring(game:HttpGet(DESIGN_URLS[design]))()
			if lib and lib.RegisterIcons and Astral.Icons then pcall(lib.RegisterIcons, lib, Astral.Icons) end
			local cfg = Window._Config or { Title = "Lumu" }
			pcall(function() ScreenGui:Destroy() end)
			lib:CreateWindow(cfg)
		end)
		return ok3
	end

	-- SetDesign is an alias of SwitchDesign (persist + switch live)
	function Window:SetDesign(design)
		return Window:SwitchDesign(design)
	end


	return Window
end

-- Alias to support CreateWindow calls
Astral.CreateWindow = Astral.MakeWindow

return Astral
