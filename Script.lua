--!strict
-- Services
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

-- Mobile Detection
local isMobile = table.find({Enum.Platform.Android, Enum.Platform.IOS}, UserInputService:GetPlatform())

-- Player GUI Setup
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ==========================================
-- TYPE DEFINITIONS
-- ==========================================
type WindowConfig = {
	Title: string?,
	SubTitle: string?,
	badge: string?,
	badgecolor: (string | Color3)?,
	Size: UDim2?,
	BackgroundImage: string?,
	Logo: string?,
	Acrylic: boolean?,
	Theme: string?,
	NotifySize: number?
}

type CardConfig = {
	Title: string?,
	Description: string?,
	Icon: string?,
	InsideBackgroundColor: Color3?
}

type PageConfig = {
	Name: string,
	Description: string?,
	Icon: string?
}

type TabConfig = {
	Name: string,
	Icon: string?,
	Description: string?
}

type ToggleConfig = {
	Title: string,
	Description: string?,
	Default: boolean?,
	Icon: string?,
	Position: string?, -- "Left" | "Right" | nil (Auto)
	Callback: (boolean) -> ()
}

type ButtonConfig = {
	Title: string,
	Description: string?,
	Icon: string?,
	Position: string?, -- "Left" | "Right" | nil (Auto)
	Callback: () -> ()
}

type LabelConfig = {
	Title: string,
	Description: string?,
	Icon: string?,
	Position: string?, -- "Left" | "Right" | nil (Auto)
	Callback: (() -> ())?
}

type ParagraphConfig = {
	Title: string,
	Description: string?,
	Image: string?,
	Icon: string?,
	Position: string?, -- "Left" | "Right" | nil (Auto)
}

type TextboxConfig = {
	Title: string,
	Description: string?,
	Placeholder: string?,
	Default: string?,
	ClearOnFocus: boolean?,
	Icon: string?,
	Position: string?, -- "Left" | "Right" | nil (Auto)
	Callback: (string) -> ()
}

type SelectorConfig = {
	Title: string,
	Description: string?,
	Options: {string},
	Default: (string | {string})?,
	Icon: string?,
	Search: boolean?,
	Multi: boolean?,
	Position: string?, -- "Left" | "Right" | nil (Auto)
	Callback: (any) -> ()
}

type ColorPickerConfig = {
	Title: string,
	Description: string?,
	Default: Color3?,
	Icon: string?,
	Position: string?, -- "Left" | "Right" | nil (Auto)
	Callback: (Color3) -> ()
}

type ToggleController = {
	Set: (self: ToggleController, state: boolean) -> ()
}

type SelectorController = {
	SetOptions: (self: SelectorController, newOptions: {string}, newDefault: (string | {string})?) -> ()
}

type TabObjectType = {
	Container: ScrollingFrame,
	LeftColumn: Frame,
	RightColumn: Frame,
	Elements: {any},
	AddToggle: (self: TabObjectType, toggleConfig: ToggleConfig) -> ToggleController,
	AddButton: (self: TabObjectType, buttonConfig: ButtonConfig) -> (),
	AddLabel: (self: TabObjectType, labelConfig: LabelConfig) -> (),
	AddParagraph: (self: TabObjectType, paragraphConfig: ParagraphConfig) -> (),
	AddTick: (self: TabObjectType, tickConfig: any) -> any,
	AddSlider: (self: TabObjectType, sliderConfig: any) -> any,
	AddTextbox: (self: TabObjectType, textConfig: TextboxConfig) -> (),
	AddSelector: (self: TabObjectType, selConfig: SelectorConfig) -> SelectorController,
	AddKeybind: (self: TabObjectType, keyConfig: any) -> (),
	AddColorPicker: (self: TabObjectType, cpConfig: ColorPickerConfig) -> ()
}

type PageObjectType = {
	Container: Frame,
	SubPage: CanvasGroup,
	IsTabbed: boolean,
	Tabs: {[string]: TabObjectType},
	TabButtons: {[string]: TextButton},
	ActiveTab: string?,
	TabCardContainer: ScrollingFrame?,
	TabSubPageContainer: Frame?,
	MainTitle: string?,
	GoBackToTabCards: (self: PageObjectType) -> (),
	MakeTab: (self: PageObjectType, tabConfig: TabConfig) -> TabObjectType
}

type SectionType = {
	MakePage: (self: SectionType, pageConfig: PageConfig) -> PageObjectType?
}

type WindowType = {
	Destroy: (self: WindowType) -> (),
	CreateCard: (self: WindowType, pageName: string, cardConfig: CardConfig) -> PageObjectType?,
	MakeSection: (self: WindowType, sectionConfig: {string}) -> SectionType
}

-- ==========================================
-- ASTRAL LIBRARY DEFINITION
-- ==========================================
local Astral = {}

-- Integrated Custom Icons Dictionary
Astral.Icons = {
	Home = "rbxassetid://10747361361",
	Settings = "rbxassetid://10747384361",
	Heart = "rbxassetid://10747374161",
	Item2 = "rbxassetid://83885110042385",
	Item3 = "rbxassetid://121905143697738",
	Item1 = "rbxassetid://122773160656447",
	SecondRewardIcon = "rbxassetid://80697366195466",
	Icon1 = "rbxassetid://106987676739927",
	Icon2 = "rbxassetid://116815022926368",
	CornerIcon = "rbxassetid://79361588247465",
	Icon3 = "rbxassetid://82358876994773",
	Sharingan1 = "rbxassetid://94044166423780",
	Image1 = "rbxassetid://119695090236661",
	Checkmark = "rbxassetid://12690727184",
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
	map_background = "rbxassetid://16255699706",
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
	profile = "rbxassetid://10747373176",
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
	shopping = "rbxassetid://11699823846",
	palette = "rbxassetid://138999635884744",
	keyboard = "rbxassetid://11385220720"
}

-- ==========================================
-- LOCALE / TRANSLATION SYSTEM
-- ==========================================
local _Locale = {
	locale = "en",
	name = "English",
	Window = { Title = "Astral", SubTitle = "by Velaric", Badge = "FREEMIUM" },
	Tabs = { Info = "Info", Image = "Image", General = "General", Colors = "Colors", Borders = "Borders", Styles = "Styles" },
	Sections = { Discord = "Discord", Users = "Users", NameSection = "Name Section", Settings = "Settings" },
	Pages = { ThemeCustomizer = "Theme Customizer", InterfaceSettings = "Interface Settings", UiSettings = "Ui Settings" },
	Discord = { GoToServer = "Go to Server", Online = "Online", Members = "Members", InviteCode = "RhQa6kZu9A", ServerName = "Astral Community", OnlineCount = "2.4K", MemberCount = "12.5K" },
	Users = { DefaultName = "User", Details = "Details", Roles = "Roles:", Joined = "Joined:" },
	ImageLoader = { Title = "Load Image", Load = "Load Image", Reset = "Reset", Placeholder = "Enter image URL...", NotFound = "Image not found", Error = "Failed to load image" },
	Buttons = { StopTween = "STOP\nTWEEN", Test = "Test" },
	Notifications = { Success = "Success", Warning = "Warning", Error = "Error", Dismiss = "Dismiss", DemoTitle = "Notification" },
	Errors = { NoClipboard = "Clipboard API not available", NoHttp = "HTTP request failed" },
	Tooltips = { HideUI = "Hide UI", ShowUI = "Show UI", StopTween = "Stop Tween" },
}
local _LocaleURL = "https://raw.githubusercontent.com/YOUR_USER/YOUR_REPO/main/astral_strings.lua"

local function loadLocale(path)
	local success, result = pcall(function()
		if path and path:match("^https?://") then
			local raw = game:HttpGet(path, true)
			local fn = loadstring("return " .. raw)
			if fn then return fn() end
		end
	end)
	if success and type(result) == "table" then
		for k, v in pairs(result) do
			_Locale[k] = v
		end
		return true
	end
	return false
end

local function fetchLocale(url)
	return loadLocale(url or _LocaleURL)
end

local function setLocale(name)
	local url = _LocaleURL:gsub("astral_strings", "astral_strings_" .. name)
	return loadLocale(url)
end

local function _L(key, fallback)
	local t = _Locale
	for part in key:gmatch("[^.]+") do
		if type(t) ~= "table" then return fallback or key:match("[^.]+$") or key end
		t = t[part]
	end
	return tostring(t or fallback or key:match("[^.]+$") or key)
end

-- ==========================================
-- THEME & ACCENT COLOR REGISTRY (BLUE ACCENT)
-- ==========================================
local currentAccentColor = Color3.fromRGB(0, 153, 235) -- Premium Blue (0099EB)
local themeUpdateCallbacks = {}

local function registerThemeUpdate(callback: (Color3) -> ())
	table.insert(themeUpdateCallbacks, callback)
	callback(currentAccentColor)
end

local function updateAccentColor(newColor: Color3)
	currentAccentColor = newColor
	for _, cb in ipairs(themeUpdateCallbacks) do
		task.spawn(cb, newColor)
	end
end

-- Global reference for active side panel close callback (for Scrim overlay)
local activeCloseCallback: (() -> ())? = nil
local Scrim: TextButton

-- ==========================================
-- LAYOUT ORDER REGISTRY (FOR STRICT 2-COLUMN GRID)
-- ==========================================
local layoutOrderMap = {
	["Accent Color"] = 0, -- Placed at the top
	["Rainbow UI Accent"] = 1,
	["Enable Acrylic Blur"] = 2,
	["Reset Theme Colors"] = 3,
	["Save Configuration"] = 4,
	["Enable Custom Cursor"] = 5,
	["Attack Range"] = 6,
	["Custom Tag Text"] = 7,
	["Accent Theme"] = 8,
	["Toggle UI Keybind"] = 9,
}

-- ==========================================
-- DYNAMIC LAYOUT ENGINE REGISTRY
-- ==========================================
local registeredTabs = {}
local currentLayoutMode = "TwoColumn"

function Astral:SetLayoutMode(mode: string)
	currentLayoutMode = mode
	for _, tabObj in ipairs(registeredTabs) do
		if mode == "OneColumn" then
			tabObj.LeftColumn.Size = UDim2.new(1, 0, 0, 0)
			tabObj.RightColumn.Visible = false
			for _, elem in ipairs(tabObj.Elements) do
				elem.Object.Parent = tabObj.LeftColumn
			end
		else
			tabObj.LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
			tabObj.RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
			tabObj.RightColumn.Visible = true
			for _, elem in ipairs(tabObj.Elements) do
				elem.Object.Parent = elem.OriginalColumn
			end
		end
	end
end

-- ==========================================
-- TRANSLATION / LOCALIZATION ENGINE
-- ==========================================
local currentLanguage = "English"
local translatableElements = {}
local translationCache = {}

local translations = {
	["English"] = {
		["Profile Setup"] = "Profile Setup",
		["Theme Customizer"] = "Theme Customizer",
		["Security & Locks"] = "Security & Locks",
		["Interface Settings"] = "Interface Settings",
		["Performance Booster"] = "Performance Booster",
		["Keybind Config"] = "Keybind Config",
		["Ui Settings"] = "Ui Settings",
		["Colors"] = "Colors",
		["Borders"] = "Borders",
		["Styles"] = "Styles",
		["Language"] = "Language",
		["Select Language"] = "Select Language",
		["General"] = "General",
		["Status Label"] = "Status Label",
		["Rainbow UI Accent"] = "Rainbow UI Accent",
		["Enable Acrylic Blur"] = "Enable Acrylic Blur",
		["Reset Theme Colors"] = "Reset Theme Colors",
		["Save Configuration"] = "Save Configuration",
		["Enable Custom Cursor"] = "Enable Custom Cursor",
		["Attack Range"] = "Attack Range",
		["Custom Tag Text"] = "Custom Tag Text",
		["Accent Theme"] = "Accent Theme",
		["Toggle UI Keybind"] = "Toggle UI Keybind",
		["Show FPS Counter"] = "Show FPS Counter",
		["Show Ping Counter"] = "Show Ping Counter",
		["Toggle Layout"] = "Toggle Layout",
		["Accent Color"] = "Accent Color",
	},
	["Spanish (Español)"] = {
		["Profile Setup"] = "Configurar Perfil",
		["Theme Customizer"] = "Personalizar Tema",
		["Security & Locks"] = "Seguridad y Bloqueos",
		["Interface Settings"] = "Ajustes de Interfaz",
		["Performance Booster"] = "Optimizador de Rendimiento",
		["Keybind Config"] = "Configurar Teclas",
		["Ui Settings"] = "Ajustes de UI",
		["Colors"] = "Colores",
		["Borders"] = "Bordes",
		["Styles"] = "Estilos",
		["Language"] = "Idioma",
		["Select Language"] = "Seleccionar Idioma",
		["General"] = "General",
		["Status Label"] = "Etiqueta de Estado",
		["Rainbow UI Accent"] = "Acento de UI Arcoíris",
		["Enable Acrylic Blur"] = "Habilitar Desenfoque Acrílico",
		["Reset Theme Colors"] = "Restablecer Colores de Tema",
		["Save Configuration"] = "Guardar Configuración",
		["Enable Custom Cursor"] = "Habilitar Cursor Personalizado",
		["Attack Range"] = "Rango de Ataque",
		["Custom Tag Text"] = "Texto de Etiqueta Personalizada",
		["Accent Theme"] = "Tema de Acento",
		["Toggle UI Keybind"] = "Alternar Tecla de UI",
		["Show FPS Counter"] = "Mostrar Contador de FPS",
		["Show Ping Counter"] = "Mostrar Contador de Ping",
		["Toggle Layout"] = "Alternar Diseño",
		["Accent Color"] = "Color de Acento",
	},
	["French (Français)"] = {
		["Profile Setup"] = "Configuration du Profil",
		["Theme Customizer"] = "Personnalisation du Thème",
		["Security & Locks"] = "Sécurité & Verrous",
		["Interface Settings"] = "Paramètres d'Interface",
		["Performance Booster"] = "Booster de Performance",
		["Keybind Config"] = "Configuration des Touches",
		["Ui Settings"] = "Paramètres UI",
		["Colors"] = "Couleurs",
		["Borders"] = "Bordures",
		["Styles"] = "Styles",
		["Language"] = "Langue",
		["Select Language"] = "Choisir la Langue",
		["General"] = "Général",
		["Status Label"] = "Étiquette de Statut",
		["Rainbow UI Accent"] = "Accent UI Arc-en-ciel",
		["Enable Acrylic Blur"] = "Activer le Flou Acrylique",
		["Reset Theme Colors"] = "Réinitialiser les Couleurs",
		["Save Configuration"] = "Enregistrer la Configuration",
		["Enable Custom Cursor"] = "Activer le Curseur Personnalisé",
		["Attack Range"] = "Portée d'Attaque",
		["Custom Tag Text"] = "Texte de Tag Personnalisé",
		["Accent Theme"] = "Thème d'Accent",
		["Toggle UI Keybind"] = "Raccourci UI",
		["Show FPS Counter"] = "Afficher le Compteur FPS",
		["Show Ping Counter"] = "Afficher le Compteur Ping",
		["Toggle Layout"] = "Changer de Disposition",
		["Accent Color"] = "Couleur d'Accent",
	},
	["German (Deutsch)"] = {
		["Profile Setup"] = "Profil-Einrichtung",
		["Theme Customizer"] = "Theme-Anpassung",
		["Security & Locks"] = "Sicherheit & Sperren",
		["Interface Settings"] = "Benutzeroberfläche",
		["Performance Booster"] = "Leistungs-Booster",
		["Keybind Config"] = "Tastenbelegung",
		["Ui Settings"] = "UI-Einstellungen",
		["Colors"] = "Farben",
		["Borders"] = "Ränder",
		["Styles"] = "Stile",
		["Language"] = "Sprache",
		["Select Language"] = "Sprache Auswählen",
		["General"] = "Allgemein",
		["Status Label"] = "Statusanzeige",
		["Rainbow UI Accent"] = "Regenbogen UI-Akzent",
		["Enable Acrylic Blur"] = "Acryl-Unschärfe Aktivieren",
		["Reset Theme Colors"] = "Themenfarben Zurücksetzen",
		["Save Configuration"] = "Konfiguration Speichern",
		["Enable Custom Cursor"] = "Benutzerdefinierten Cursor Aktivieren",
		["Attack Range"] = "Angriffsreichweite",
		["Custom Tag Text"] = "Benutzerdefinierter Tag-Text",
		["Accent Theme"] = "Akzent-Thema",
		["Toggle UI Keybind"] = "UI-Tastenbelegung Umschalten",
		["Show FPS Counter"] = "FPS-Anzeige Einblenden",
		["Show Ping Counter"] = "Ping-Anzeige Einblenden",
		["Toggle Layout"] = "Layout Umschalten",
		["Accent Color"] = "Akzentfarbe",
	},
	["Japanese (日本語)"] = {
		["Profile Setup"] = "プロフィール設定",
		["Theme Customizer"] = "テーマカスタマイザー",
		["Security & Locks"] = "セキュリティとロック",
		["Interface Settings"] = "インターフェース設定",
		["Performance Booster"] = "パフォーマンスブースター",
		["Keybind Config"] = "キーバインド設定",
		["Ui Settings"] = "UI設定",
		["Colors"] = "カラー",
		["Borders"] = "ボーダー",
		["Styles"] = "スタイル",
		["Language"] = "言語",
		["Select Language"] = "言語を選択",
		["General"] = "一般",
		["Status Label"] = "ステータスラベル",
		["Rainbow UI Accent"] = "レインボーUIアクセント",
		["Enable Acrylic Blur"] = "アクリルブラーを有効化",
		["Reset Theme Colors"] = "テーマカラーをリセット",
		["Save Configuration"] = "設定を保存",
		["Enable Custom Cursor"] = "カスタムカーソルを有効化",
		["Attack Range"] = "攻撃範囲",
		["Custom Tag Text"] = "カスタムタグテキスト",
		["Accent Theme"] = "アクセントテーマ",
		["Toggle UI Keybind"] = "UIキーバインド切り替え",
		["Show FPS Counter"] = "FPSカウンターを表示",
		["Show Ping Counter"] = "Pingカウンターを表示",
		["Toggle Layout"] = "レイアウト切り替え",
		["Accent Color"] = "アクセントカラー",
	},
	["Portuguese (Português)"] = {
		["Profile Setup"] = "Configuração de Perfil",
		["Theme Customizer"] = "Personalizador de Tema",
		["Security & Locks"] = "Segurança e Bloqueios",
		["Interface Settings"] = "Configurações de Interface",
		["Performance Booster"] = "Otimizador de Desempenho",
		["Keybind Config"] = "Configuração de Teclas",
		["Ui Settings"] = "Configurações de UI",
		["Colors"] = "Cores",
		["Borders"] = "Bordas",
		["Styles"] = "Estilos",
		["Language"] = "Idioma",
		["Select Language"] = "Selecionar Idioma",
		["General"] = "Geral",
		["Status Label"] = "Etiqueta de Status",
		["Rainbow UI Accent"] = "Acento de UI Arco-Íris",
		["Enable Acrylic Blur"] = "Ativar Desfoque Acrílico",
		["Reset Theme Colors"] = "Redefinir Cores do Tema",
		["Save Configuration"] = "Salvar Configuração",
		["Enable Custom Cursor"] = "Ativar Cursor Personalizado",
		["Attack Range"] = "Alcance de Ataque",
		["Custom Tag Text"] = "Texto de Tag Personalizada",
		["Accent Theme"] = "Tema de Acento",
		["Toggle UI Keybind"] = "Alternar Tecla da UI",
		["Show FPS Counter"] = "Mostrar Contador de FPS",
		["Show Ping Counter"] = "Mostrar Contador de Ping",
		["Toggle Layout"] = "Alternar Layout",
		["Accent Color"] = "Cor de Destaque",
	}
}

-- Dynamic Translation Engine with Automatic Fallback API
local function getTranslation(englishText: string, targetLang: string, label: TextLabel?, formatFn: ((string) -> string)?): string
	local langTable = translations[targetLang]
	if langTable and langTable[englishText] then
		local text = langTable[englishText]
		return formatFn and formatFn(text) or text
	end

	-- Asynchronous Auto-Translation Fallback
	if targetLang ~= "English" then
		if translationCache[targetLang] and translationCache[targetLang][englishText] then
			local text = translationCache[targetLang][englishText]
			return formatFn and formatFn(text) or text
		end

		task.spawn(function()
			local langCodes = {
				["English"] = "en",
				["Spanish (Español)"] = "es",
				["French (Français)"] = "fr",
				["German (Deutsch)"] = "de",
				["Japanese (日本語)"] = "ja",
				["Portuguese (Português)"] = "pt"
			}
			local code = langCodes[targetLang] or "en"
			if code == "en" then return end

			local success, result = pcall(function()
				local url = string.format("https://translate.googleapis.com/translate_a/single?client=gtx&sl=en&tl=%s&dt=t&q=%s", code, HttpService:UrlEncode(englishText))
				local response
				local syn_request = (syn and syn.request) or (http and http.request) or request
				if syn_request then
					local res = syn_request({Url = url, Method = "GET"})
					response = res.Body
				else
					response = game:HttpGet(url)
				end
				if response then
					local data = HttpService:JSONDecode(response)
					if data and data[1] and data[1][1] and data[1][1][1] then
						return data[1][1][1]
					end
				end
			end)

			if success and result then
				translationCache[targetLang] = translationCache[targetLang] or {}
				translationCache[targetLang][englishText] = result
				
				-- Update all active labels matching this key
				for _, item in ipairs(translatableElements) do
					if item.Key == englishText and item.Label and item.Label.Parent then
						local translated = result
						if item.Format then
							translated = item.Format(translated)
						end
						item.Label.Text = translated
					end
				end
			end
		end)
	end

	return formatFn and formatFn(englishText) or englishText
end

local function registerTranslation(label: TextLabel, englishText: string, formatFn: ((string) -> string)?)
	table.insert(translatableElements, {Label = label, Key = englishText, Format = formatFn})
	label.Text = getTranslation(englishText, currentLanguage, label, formatFn)
end

-- Dynamic Language Setter API
function Astral:SetLanguage(targetLang: string)
	currentLanguage = targetLang
	for _, item in ipairs(translatableElements) do
		if item.Label and item.Label.Parent then
			item.Label.Text = getTranslation(item.Key, targetLang, item.Label, item.Format)
		end
	end
end

-- Helper function to resolve icon names to asset IDs
local function resolveIcon(iconName: string?): string?
	if not iconName then return nil end
	if Astral.Icons[iconName] then
		return Astral.Icons[iconName]
	end
	for key, assetId in pairs(Astral.Icons) do
		if key:lower() == iconName:lower() then
			return assetId
		end
	end
	local lowerName = iconName:lower()
	if lowerName == "alertcircle" or lowerName == "warning" then
		return Astral.Icons.Warning
	elseif lowerName == "paintbrush" or lowerName == "brush" or lowerName == "palette" then
		return Astral.Icons.brush
	elseif lowerName == "settings" then
		return Astral.Icons.Settings
	end
	return iconName
end

local function parseIcon(iconInput: string?): string?
	if not iconInput then return nil end
	if type(iconInput) == "string" and string.match(iconInput, "^%d+$") then
		return "rbxassetid://" .. iconInput
	end
	return resolveIcon(iconInput)
end

-- Helper to determine target column based on position preference (Auto-balances dynamically)
local function GetTargetColumn(tabObj: TabObjectType, position: string?): Frame
	if position == "Left" then
		return tabObj.LeftColumn
	elseif position == "Right" then
		return tabObj.RightColumn
	end
	
	-- Auto-balance: count non-layout children
	local leftCount = 0
	for _, c in ipairs(tabObj.LeftColumn:GetChildren()) do
		if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
			leftCount += 1
		end
	end
	local rightCount = 0
	for _, c in ipairs(tabObj.RightColumn:GetChildren()) do
		if c:IsA("GuiObject") and not c:IsA("UIListLayout") and not c:IsA("UIPadding") then
			rightCount += 1
		end
	end
	
	if leftCount <= rightCount then
		return tabObj.LeftColumn
	else
		return tabObj.RightColumn
	end
end

-- Dynamic cell resizing helper to prevent card overlapping/wrapping bugs
local function bindDynamicGrid(gridLayout: UIGridLayout, container: ScrollingFrame)
	local function updateSize()
		local width = container.AbsoluteSize.X - 24 -- subtract padding (12 left, 12 right)
		if width > 0 then
			-- We want exactly 3 columns. Gap is 10px between columns (2 gaps total = 20px)
			local cellWidth = math.floor((width - 20) / 3)
			gridLayout.CellSize = UDim2.new(0, cellWidth, 0, 116) -- Increased height to 116px for premium buttons with category text
		end
	end
	container:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateSize)
	task.spawn(updateSize)
end

-- ==========================================
-- STANDALONE TOGGLE CREATION FUNCTION
-- ==========================================
local function CreateToggle(tabObj: TabObjectType, toggleConfig: ToggleConfig): ToggleController
	toggleConfig = toggleConfig or {} :: ToggleConfig
	local title = toggleConfig.Title or "Toggle"
	local description = toggleConfig.Description
	local default = toggleConfig.Default or false
	local callback = toggleConfig.Callback or function() end
	local icon = parseIcon(toggleConfig.Icon)
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, toggleConfig.Position)

	-- Main Toggle Background (With Stroke) - Uniform 64px Height
	local ToggleFrame = Instance.new("TextButton")
	ToggleFrame.Name = title .. "_Toggle"
	ToggleFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	ToggleFrame.BorderSizePixel = 0
	ToggleFrame.Size = UDim2.new(1, 0, 0, 64)
	ToggleFrame.Text = ""
	ToggleFrame.AutoButtonColor = false
	ToggleFrame.LayoutOrder = layoutOrderMap[title] or 100
	ToggleFrame.Parent = TargetColumn

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 8)
	ToggleCorner.Parent = ToggleFrame

	local ToggleStroke = Instance.new("UIStroke")
	ToggleStroke.Thickness = 1
	ToggleStroke.Color = Color3.fromRGB(50, 50, 55)
	ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ToggleStroke.Parent = ToggleFrame

	-- Optional Icon Container (Upgraded Size & Layout)
	if icon then
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		IconContainer.BorderSizePixel = 0
		IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
		IconContainer.Size = UDim2.new(0, 42, 0, 42)
		IconContainer.Parent = ToggleFrame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Name = "Icon"
		IconLabel.BackgroundTransparency = 1
		IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconLabel.Size = UDim2.new(0, 26, 0, 26)
		IconLabel.Image = icon
		IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		IconLabel.ScaleType = Enum.ScaleType.Fit
		IconLabel.Parent = IconContainer
	end

	-- Text Container (Title & Description) - Adjusted width to prevent overlapping
	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.BackgroundTransparency = 1
	TextContainer.Position = icon and UDim2.new(0, 62, 0, 0) or UDim2.new(0, 14, 0, 0)
	TextContainer.Size = icon and UDim2.new(1, -146, 1, 0) or UDim2.new(1, -96, 1, 0)
	TextContainer.Parent = ToggleFrame

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
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, title)

	if hasDesc then
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 0, 24)
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = description
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 9
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextWrapped = true
		DescLabel.Parent = TextContainer
	end

	-- Modern Rounded Rectangle Toggle Switch Track (No Stroke) - FIXED: Made bigger (54x28)
	local SwitchTrack = Instance.new("Frame")
	SwitchTrack.Name = "SwitchTrack"
	SwitchTrack.BackgroundColor3 = default and currentAccentColor or Color3.fromRGB(45, 45, 50)
	SwitchTrack.BorderSizePixel = 0
	SwitchTrack.Position = UDim2.new(1, -70, 0.5, -14)
	SwitchTrack.Size = UDim2.new(0, 54, 0, 28)
	SwitchTrack.Parent = ToggleFrame

	local TrackCorner = Instance.new("UICorner")
	TrackCorner.CornerRadius = UDim.new(0, 10)
	TrackCorner.Parent = SwitchTrack

	-- The Toggle Thumb - FIXED: Made bigger (22x22)
	local SwitchThumb = Instance.new("Frame")
	SwitchThumb.Name = "SwitchThumb"
	SwitchThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SwitchThumb.BorderSizePixel = 0
	SwitchThumb.Position = default and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)
	SwitchThumb.Size = UDim2.new(0, 22, 0, 22)
	SwitchThumb.Parent = SwitchTrack

	local ThumbCorner = Instance.new("UICorner")
	ThumbCorner.CornerRadius = UDim.new(0, 8)
	ThumbCorner.Parent = SwitchThumb

	-- Logic & Animation
	local enabled = default

	local function toggle(state: boolean?)
		if state == nil then
			enabled = not enabled
		else
			enabled = state
		end

		local targetTrackColor = enabled and currentAccentColor or Color3.fromRGB(45, 45, 50)
		local targetThumbPos = enabled and UDim2.new(1, -25, 0.5, -11) or UDim2.new(0, 3, 0.5, -11)

		TweenService:Create(SwitchTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundColor3 = targetTrackColor}):Play()
		TweenService:Create(SwitchThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = targetThumbPos}):Play()

		task.spawn(callback, enabled)
	end

	ToggleFrame.MouseButton1Click:Connect(function() toggle() end)

	-- Hover Effects
	ToggleFrame.MouseEnter:Connect(function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36, 36, 40)}):Play()
		TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
	end)

	ToggleFrame.MouseLeave:Connect(function()
		TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
		TweenService:Create(ToggleStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(50, 50, 55)}):Play()
	end)

	-- Register for dynamic theme updates
	registerThemeUpdate(function(color)
		if enabled then
			SwitchTrack.BackgroundColor3 = color
		end
	end)

	table.insert(tabObj.Elements, {Object = ToggleFrame, OriginalColumn = TargetColumn})

	local ToggleController = {} :: ToggleController
	function ToggleController:Set(state: boolean)
		toggle(state)
	end
	return ToggleController
end

-- ==========================================
-- STANDALONE BUTTON CREATION FUNCTION
-- ==========================================
local function CreateButton(tabObj: TabObjectType, buttonConfig: ButtonConfig)
	buttonConfig = buttonConfig or {} :: ButtonConfig
	local title = buttonConfig.Title or "Button"
	local description = buttonConfig.Description
	local callback = buttonConfig.Callback or function() end
	local icon = parseIcon(buttonConfig.Icon)
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, buttonConfig.Position)

	-- Main Button Frame (With Stroke) - Uniform 64px Height
	local ButtonFrame = Instance.new("TextButton")
	ButtonFrame.Name = title .. "_Button"
	ButtonFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	ButtonFrame.BorderSizePixel = 0
	ButtonFrame.Size = UDim2.new(1, 0, 0, 64)
	ButtonFrame.Text = ""
	ButtonFrame.AutoButtonColor = false
	ButtonFrame.LayoutOrder = layoutOrderMap[title] or 100
	ButtonFrame.Parent = TargetColumn

	local ButtonCorner = Instance.new("UICorner")
	ButtonCorner.CornerRadius = UDim.new(0, 8)
	ButtonCorner.Parent = ButtonFrame

	local ButtonStroke = Instance.new("UIStroke")
	ButtonStroke.Thickness = 1
	ButtonStroke.Color = Color3.fromRGB(50, 50, 55)
	ButtonStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ButtonStroke.Parent = ButtonFrame

	-- Button Scale for Click Animation
	local ButtonScale = Instance.new("UIScale")
	ButtonScale.Scale = 1
	ButtonScale.Parent = ButtonFrame

	-- Optional Icon Container (Upgraded Size & Layout)
	if icon then
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		IconContainer.BorderSizePixel = 0
		IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
		IconContainer.Size = UDim2.new(0, 42, 0, 42)
		IconContainer.Parent = ButtonFrame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Name = "Icon"
		IconLabel.BackgroundTransparency = 1
		IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconLabel.Size = UDim2.new(0, 26, 0, 26)
		IconLabel.Image = icon
		IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		IconLabel.ScaleType = Enum.ScaleType.Fit
		IconLabel.Parent = IconContainer
	end

	-- Text Container (Title & Description) - Adjusted width to prevent overlapping
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
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, title)

	if hasDesc then
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 0, 24)
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = description
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 9
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextWrapped = true
		DescLabel.Parent = TextContainer
	end

	-- Action Indicator Arrow - Standardized 16px Right Margin
	local ActionArrow = Instance.new("ImageLabel")
	ActionArrow.Name = "ActionArrow"
	ActionArrow.BackgroundTransparency = 1
	ActionArrow.Position = UDim2.new(1, -32, 0.5, -8)
	ActionArrow.Size = UDim2.new(0, 16, 0, 16)
	ActionArrow.Image = Astral.Icons.right_arrow
	ActionArrow.ImageColor3 = Color3.fromRGB(160, 160, 165)
	ActionArrow.Parent = ButtonFrame

	-- Click Event & Animation
	ButtonFrame.MouseButton1Click:Connect(function()
		task.spawn(callback)
	end)

	ButtonFrame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(ButtonScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.95}):Play()
		end
	end)

	ButtonFrame.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			TweenService:Create(ButtonScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
		end
	end)

	-- Hover Transitions
	ButtonFrame.MouseEnter:Connect(function()
		TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36, 36, 40)}):Play()
		TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
		TweenService:Create(ActionArrow, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(255, 255, 255)}):Play()
	end)

	ButtonFrame.MouseLeave:Connect(function()
		TweenService:Create(ButtonFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
		TweenService:Create(ButtonStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(50, 50, 55)}):Play()
		TweenService:Create(ActionArrow, TweenInfo.new(0.15), {ImageColor3 = Color3.fromRGB(160, 160, 165)}):Play()
	end)

	table.insert(tabObj.Elements, {Object = ButtonFrame, OriginalColumn = TargetColumn})
end

-- ==========================================
-- STANDALONE LABEL CREATION FUNCTION
-- ==========================================
local function CreateLabel(tabObj: TabObjectType, labelConfig: LabelConfig)
	labelConfig = labelConfig or {} :: LabelConfig
	local title = labelConfig.Title or "Status Label"
	local description = labelConfig.Description
	local callback = labelConfig.Callback
	local icon = parseIcon(labelConfig.Icon) or Astral.Icons.timer
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, labelConfig.Position)

	-- Main Label Frame (With Stroke) - Uniform 64px Height
	local LabelFrame
	if callback then
		LabelFrame = Instance.new("TextButton")
		LabelFrame.Text = ""
		LabelFrame.AutoButtonColor = false
	else
		LabelFrame = Instance.new("Frame")
	end
	
	LabelFrame.Name = title .. "_Label"
	LabelFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	LabelFrame.BorderSizePixel = 0
	LabelFrame.Size = UDim2.new(1, 0, 0, 64)
	LabelFrame.LayoutOrder = layoutOrderMap[title] or 100
	LabelFrame.Parent = TargetColumn

	local LabelCorner = Instance.new("UICorner")
	LabelCorner.CornerRadius = UDim.new(0, 8)
	LabelCorner.Parent = LabelFrame

	local LabelStroke = Instance.new("UIStroke")
	LabelStroke.Thickness = 1
	LabelStroke.Color = Color3.fromRGB(45, 45, 50)
	LabelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	LabelStroke.Parent = LabelFrame

	-- Premium Icon Container (Upgraded Size & White Outline)
	local IconContainer = Instance.new("Frame")
	IconContainer.Name = "IconContainer"
	IconContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	IconContainer.BorderSizePixel = 0
	IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
	IconContainer.Size = UDim2.new(0, 42, 0, 42)
	IconContainer.Parent = LabelFrame

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
	IconLabel.Size = UDim2.new(0, 28, 0, 28)
	IconLabel.Image = icon
	IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
	IconLabel.ScaleType = Enum.ScaleType.Fit
	IconLabel.Parent = IconContainer

	-- Text Container (Title & Description)
	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.BackgroundTransparency = 1
	TextContainer.Position = UDim2.new(0, 62, 0, 0)
	TextContainer.Size = UDim2.new(1, -72, 1, 0)
	TextContainer.Parent = LabelFrame

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
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 12
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, title)

	if hasDesc then
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 0, 24)
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = description
		DescLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
		DescLabel.TextSize = 10
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextWrapped = true
		DescLabel.Parent = TextContainer
	end

	-- Hover effects for all labels (buttons and static)
	LabelFrame.MouseEnter:Connect(function()
		TweenService:Create(LabelFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
		TweenService:Create(LabelStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(60, 60, 65)}):Play()
	end)

	LabelFrame.MouseLeave:Connect(function()
		TweenService:Create(LabelFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(20, 20, 24)}):Play()
		TweenService:Create(LabelStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(45, 45, 50)}):Play()
	end)

	-- If callback is provided, make it act like a button with click animations
	if callback and LabelFrame:IsA("TextButton") then
		local ButtonScale = Instance.new("UIScale")
		ButtonScale.Scale = 1
		ButtonScale.Parent = LabelFrame

		LabelFrame.MouseButton1Click:Connect(function()
			task.spawn(callback)
		end)

		LabelFrame.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				TweenService:Create(ButtonScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.97}):Play()
			end
		end)

		LabelFrame.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				TweenService:Create(ButtonScale, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
			end
		end)
	end

	table.insert(tabObj.Elements, {Object = LabelFrame, OriginalColumn = TargetColumn})
end

-- ==========================================
-- STANDALONE PARAGRAPH CREATION FUNCTION
-- ==========================================
local function CreateParagraph(tabObj: TabObjectType, paragraphConfig: ParagraphConfig)
	paragraphConfig = paragraphConfig or {} :: ParagraphConfig
	local title = paragraphConfig.Title or "Paragraph"
	local description = paragraphConfig.Description
	local image = parseIcon(paragraphConfig.Image)
	local icon = parseIcon(paragraphConfig.Icon)
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, paragraphConfig.Position)

	-- Determine height based on whether there is a large image
	local height = image and 180 or 64

	local ParagraphFrame = Instance.new("Frame")
	ParagraphFrame.Name = title .. "_Paragraph"
	ParagraphFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	ParagraphFrame.BorderSizePixel = 0
	ParagraphFrame.Size = UDim2.new(1, 0, 0, height)
	ParagraphFrame.LayoutOrder = layoutOrderMap[title] or 100
	ParagraphFrame.ClipsDescendants = true
	ParagraphFrame.Parent = TargetColumn

	local ParagraphCorner = Instance.new("UICorner")
	ParagraphCorner.CornerRadius = UDim.new(0, 8)
	ParagraphCorner.Parent = ParagraphFrame

	local ParagraphStroke = Instance.new("UIStroke")
	ParagraphStroke.Thickness = 1.2
	ParagraphStroke.Color = Color3.fromRGB(55, 55, 60)
	ParagraphStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ParagraphStroke.Parent = ParagraphFrame

	if image then
		-- Large Image Container
		local ImageContainer = Instance.new("Frame")
		ImageContainer.Name = "ImageContainer"
		ImageContainer.Size = UDim2.new(1, 0, 0, 114)
		ImageContainer.Position = UDim2.new(0, 0, 0, 0)
		ImageContainer.BorderSizePixel = 0
		ImageContainer.ClipsDescendants = true
		ImageContainer.BackgroundTransparency = 1
		ImageContainer.Parent = ParagraphFrame

		local ImageCorner = Instance.new("UICorner")
		ImageCorner.CornerRadius = UDim.new(0, 8)
		ImageCorner.Parent = ImageContainer

		local ImageLabel = Instance.new("ImageLabel")
		ImageLabel.Name = "ImageLabel"
		ImageLabel.Size = UDim2.new(1, 0, 1, 0)
		ImageLabel.BackgroundTransparency = 1
		ImageLabel.Image = image
		ImageLabel.ScaleType = Enum.ScaleType.Crop
		ImageLabel.Parent = ImageContainer

		-- Text Container below image
		local TextContainer = Instance.new("Frame")
		TextContainer.Name = "TextContainer"
		TextContainer.BackgroundTransparency = 1
		TextContainer.Position = UDim2.new(0, 12, 0, 120)
		TextContainer.Size = UDim2.new(1, -24, 0, 50)
		TextContainer.Parent = ParagraphFrame

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
		TitleLabel.Text = title
		TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TitleLabel.TextSize = 12
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextWrapped = true
		TitleLabel.Parent = TextContainer
		registerTranslation(TitleLabel, title)

		if hasDesc then
			local DescLabel = Instance.new("TextLabel")
			DescLabel.Name = "Description"
			DescLabel.BackgroundTransparency = 1
			DescLabel.Size = UDim2.new(1, 0, 0, 24)
			DescLabel.Font = Enum.Font.Gotham
			DescLabel.Text = description
			DescLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
			DescLabel.TextSize = 10
			DescLabel.TextXAlignment = Enum.TextXAlignment.Left
			DescLabel.TextWrapped = true
			DescLabel.Parent = TextContainer
		end
	else
		-- Small Icon or Text-Only Layout
		if icon then
			local IconContainer = Instance.new("Frame")
			IconContainer.Name = "IconContainer"
			IconContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			IconContainer.BorderSizePixel = 0
			IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
			IconContainer.Size = UDim2.new(0, 42, 0, 42)
			IconContainer.Parent = ParagraphFrame

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
			IconLabel.Size = UDim2.new(0, 28, 0, 28)
			IconLabel.Image = icon
			IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
			IconLabel.ScaleType = Enum.ScaleType.Fit
			IconLabel.Parent = IconContainer
		end

		local TextContainer = Instance.new("Frame")
		TextContainer.Name = "TextContainer"
		TextContainer.BackgroundTransparency = 1
		TextContainer.Position = icon and UDim2.new(0, 62, 0, 0) or UDim2.new(0, 12, 0, 0)
		TextContainer.Size = icon and UDim2.new(1, -72, 1, 0) or UDim2.new(1, -24, 1, 0)
		TextContainer.Parent = ParagraphFrame

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
		TitleLabel.Text = title
		TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TitleLabel.TextSize = 12
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextWrapped = true
		TitleLabel.Parent = TextContainer
		registerTranslation(TitleLabel, title)

		if hasDesc then
			local DescLabel = Instance.new("TextLabel")
			DescLabel.Name = "Description"
			DescLabel.BackgroundTransparency = 1
			DescLabel.Size = UDim2.new(1, 0, 0, 24)
			DescLabel.Font = Enum.Font.Gotham
			DescLabel.Text = description
			DescLabel.TextColor3 = Color3.fromRGB(140, 140, 145)
			DescLabel.TextSize = 10
			DescLabel.TextXAlignment = Enum.TextXAlignment.Left
			DescLabel.TextWrapped = true
			DescLabel.Parent = TextContainer
		end
	end

	ParagraphFrame.MouseEnter:Connect(function()
		TweenService:Create(ParagraphFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(26, 26, 30) }):Play()
		TweenService:Create(ParagraphStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(75, 75, 80) }):Play()
	end)
	ParagraphFrame.MouseLeave:Connect(function()
		TweenService:Create(ParagraphFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(20, 20, 24) }):Play()
		TweenService:Create(ParagraphStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(55, 55, 60) }):Play()
	end)

	table.insert(tabObj.Elements, {Object = ParagraphFrame, OriginalColumn = TargetColumn})
end

-- ==========================================
-- STANDALONE TICK CREATION FUNCTION
-- ==========================================
local function CreateTick(tabObj: TabObjectType, tickConfig: any)
	tickConfig = tickConfig or {}
	local title = tickConfig.Title or "Tick"
	local description = tickConfig.Description
	local default = tickConfig.Default or false
	local callback = tickConfig.Callback or function() end
	local icon = parseIcon(tickConfig.Icon)
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, tickConfig.Position)

	-- Uniform 64px Height with Stroke
	local TickFrame = Instance.new("TextButton")
	TickFrame.Name = title .. "_Tick"
	TickFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	TickFrame.BorderSizePixel = 0
	TickFrame.Size = UDim2.new(1, 0, 0, 64)
	TickFrame.Text = ""
	TickFrame.AutoButtonColor = false
	TickFrame.LayoutOrder = layoutOrderMap[title] or 100
	TickFrame.Parent = TargetColumn

	local TickCorner = Instance.new("UICorner")
	TickCorner.CornerRadius = UDim.new(0, 8)
	TickCorner.Parent = TickFrame

	local TickStroke = Instance.new("UIStroke")
	TickStroke.Thickness = 1
	TickStroke.Color = Color3.fromRGB(50, 50, 55)
	TickStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	TickStroke.Parent = TickFrame

	-- Optional Icon Container (Upgraded Size & Layout)
	if icon then
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		IconContainer.BorderSizePixel = 0
		IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
		IconContainer.Size = UDim2.new(0, 42, 0, 42)
		IconContainer.Parent = TickFrame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Name = "Icon"
		IconLabel.BackgroundTransparency = 1
		IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconLabel.Size = UDim2.new(0, 26, 0, 26)
		IconLabel.Image = icon
		IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		IconLabel.ScaleType = Enum.ScaleType.Fit
		IconLabel.Parent = IconContainer
	end

	-- Text Container (Title & Description) - Adjusted width to prevent overlapping
	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.BackgroundTransparency = 1
	TextContainer.Position = icon and UDim2.new(0, 62, 0, 0) or UDim2.new(0, 14, 0, 0)
	TextContainer.Size = icon and UDim2.new(1, -120, 1, 0) or UDim2.new(1, -80, 1, 0)
	TextContainer.Parent = TickFrame

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
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, title)

	if hasDesc then
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 0, 24)
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = description
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 9
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextWrapped = true
		DescLabel.Parent = TextContainer
	end

	-- Premium Custom Checkbox Container - FIXED: Made significantly bigger (32x32px)
	local Checkbox = Instance.new("Frame")
	Checkbox.Name = "Checkbox"
	Checkbox.BackgroundColor3 = default and currentAccentColor or Color3.fromRGB(36, 36, 40)
	Checkbox.BorderSizePixel = 0
	Checkbox.Position = UDim2.new(1, -48, 0.5, -16)
	Checkbox.Size = UDim2.new(0, 32, 0, 32)
	Checkbox.Parent = TickFrame

	local CheckboxCorner = Instance.new("UICorner")
	CheckboxCorner.CornerRadius = UDim.new(0, 6)
	CheckboxCorner.Parent = Checkbox

	local CheckboxStroke = Instance.new("UIStroke")
	CheckboxStroke.Thickness = 1.5
	CheckboxStroke.Color = default and currentAccentColor or Color3.fromRGB(55, 55, 60)
	CheckboxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	CheckboxStroke.Parent = Checkbox

	local Checkmark = Instance.new("ImageLabel")
	Checkmark.Name = "Checkmark"
	Checkmark.BackgroundTransparency = 1
	Checkmark.AnchorPoint = Vector2.new(0.5, 0.5)
	Checkmark.Position = UDim2.new(0.5, 0, 0.5, 0)
	Checkmark.Size = default and UDim2.new(0, 22, 0, 22) or UDim2.new(0, 0, 0, 0)
	Checkmark.Image = Astral.Icons.Checkmark
	Checkmark.ImageColor3 = Color3.fromRGB(255, 255, 255)
	Checkmark.Parent = Checkbox

	local enabled = default
	local function toggle(state)
		if state == nil then enabled = not enabled else enabled = state end
		
		local targetColor = enabled and currentAccentColor or Color3.fromRGB(36, 36, 40)
		local strokeColor = enabled and currentAccentColor or Color3.fromRGB(55, 55, 60)
		local targetSize = enabled and UDim2.new(0, 22, 0, 22) or UDim2.new(0, 0, 0, 0)

		TweenService:Create(Checkbox, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = targetColor
		}):Play()
		TweenService:Create(CheckboxStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = strokeColor
		}):Play()
		TweenService:Create(Checkmark, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = targetSize
		}):Play()

		task.spawn(callback, enabled)
	end

	TickFrame.MouseButton1Click:Connect(function() toggle() end)

	TickFrame.MouseEnter:Connect(function()
		TweenService:Create(TickFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40) }):Play()
		TweenService:Create(TickStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 75) }):Play()
		if not enabled then
			TweenService:Create(CheckboxStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 75) }):Play()
		end
	end)

	TickFrame.MouseLeave:Connect(function()
		TweenService:Create(TickFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(26, 26, 30) }):Play()
		TweenService:Create(TickStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(50, 50, 55) }):Play()
		if not enabled then
			TweenService:Create(CheckboxStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(55, 55, 60) }):Play()
		end
	end)

	-- Register for dynamic theme updates
	registerThemeUpdate(function(color)
		if enabled then
			Checkbox.BackgroundColor3 = color
			CheckboxStroke.Color = color
		end
	end)

	table.insert(tabObj.Elements, {Object = TickFrame, OriginalColumn = TargetColumn})

	local TickController = {}
	function TickController:Set(state) toggle(state) end
	return TickController
end

-- ==========================================
-- STANDALONE SLIDER CREATION FUNCTION
-- ==========================================
local function CreateSlider(tabObj: TabObjectType, sliderConfig: any)
	sliderConfig = sliderConfig or {}
	local title = sliderConfig.Title or "Slider"
	local min = sliderConfig.Min or 1
	local max = sliderConfig.Max or 100
	local increase = sliderConfig.Increase or 1
	local default = sliderConfig.Default or min
	local callback = sliderConfig.Callback or function() end
	local icon = parseIcon(sliderConfig.Icon)

	local TargetColumn = GetTargetColumn(tabObj, sliderConfig.Position)

	-- Main Slider Frame (Taller to match image, with subtle border) - Uniform 64px Height
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Name = title .. "_Slider"
	SliderFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	SliderFrame.BorderSizePixel = 0
	SliderFrame.Size = UDim2.new(1, 0, 0, 64)
	SliderFrame.LayoutOrder = layoutOrderMap[title] or 100
	SliderFrame.Parent = TargetColumn

	local SliderCorner = Instance.new("UICorner")
	SliderCorner.CornerRadius = UDim.new(0, 8)
	SliderCorner.Parent = SliderFrame

	local SliderStroke = Instance.new("UIStroke")
	SliderStroke.Thickness = 1
	SliderStroke.Color = Color3.fromRGB(50, 50, 55)
	SliderStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	SliderStroke.Parent = SliderFrame

	-- Optional Icon Container (Upgraded Size & Layout)
	if icon then
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		IconContainer.BorderSizePixel = 0
		IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
		IconContainer.Size = UDim2.new(0, 42, 0, 42)
		IconContainer.Parent = SliderFrame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Name = "Icon"
		IconLabel.BackgroundTransparency = 1
		IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconLabel.Size = UDim2.new(0, 26, 0, 26)
		IconLabel.Image = icon
		IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		IconLabel.ScaleType = Enum.ScaleType.Fit
		IconLabel.Parent = IconContainer
	end

	-- Title Label
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = icon and UDim2.new(0, 62, 0, 10) or UDim2.new(0, 12, 0, 10)
	TitleLabel.Size = icon and UDim2.new(1, -134, 0, 16) or UDim2.new(1, -80, 0, 16)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 12
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = SliderFrame
	registerTranslation(TitleLabel, title)

	-- Value Box (Top Right) - Standardized 16px Right Margin (With Stroke Layout)
	local ValueBox = Instance.new("Frame")
	ValueBox.Name = "ValueBox"
	ValueBox.BackgroundColor3 = Color3.fromRGB(30, 30, 34)
	ValueBox.BorderSizePixel = 0
	ValueBox.Position = UDim2.new(1, -64, 0, 7)
	ValueBox.Size = UDim2.new(0, 48, 0, 20)
	ValueBox.Parent = SliderFrame

	local ValueCorner = Instance.new("UICorner")
	ValueCorner.CornerRadius = UDim.new(0, 4)
	ValueCorner.Parent = ValueBox

	local ValueStroke = Instance.new("UIStroke")
	ValueStroke.Thickness = 1
	ValueStroke.Color = Color3.fromRGB(55, 55, 60)
	ValueStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ValueStroke.Parent = ValueBox

	local ValueInput = Instance.new("TextBox")
	ValueInput.Name = "ValueInput"
	ValueInput.BackgroundTransparency = 1
	ValueInput.Size = UDim2.new(1, 0, 1, 0)
	ValueInput.Font = Enum.Font.GothamBold
	ValueInput.Text = tostring(default)
	ValueInput.TextColor3 = Color3.fromRGB(255, 255, 255)
	ValueInput.TextSize = 10
	ValueInput.Parent = ValueBox

	-- Slider Track (Sleek, fully rounded capsule track) - Standardized 16px Right Margin
	local SliderTrack = Instance.new("TextButton")
	SliderTrack.Name = "SliderTrack"
	SliderTrack.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
	SliderTrack.BorderSizePixel = 0
	SliderTrack.Position = icon and UDim2.new(0, 62, 0, 36) or UDim2.new(0, 12, 0, 36)
	SliderTrack.Size = icon and UDim2.new(1, -82, 0, 14) or UDim2.new(1, -32, 0, 14)
	SliderTrack.Text = ""
	SliderTrack.AutoButtonColor = false
	SliderTrack.Parent = SliderFrame

	local TrackCorner = Instance.new("UICorner")
	TrackCorner.CornerRadius = UDim.new(0, 4)
	TrackCorner.Parent = SliderTrack

	-- Slider Fill (Vibrant Accent matching toggle)
	local SliderFill = Instance.new("Frame")
	SliderFill.Name = "SliderFill"
	SliderFill.BackgroundColor3 = currentAccentColor
	SliderFill.BorderSizePixel = 0
	SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	SliderFill.Parent = SliderTrack

	local FillCorner = Instance.new("UICorner")
	FillCorner.CornerRadius = UDim.new(0, 4)
	FillCorner.Parent = SliderFill

	-- Slider Thumb (Rounded Square, White with Dark Outline - Matches Toggle Thumb Style)
	local SliderThumb = Instance.new("Frame")
	SliderThumb.Name = "SliderThumb"
	SliderThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	SliderThumb.Size = UDim2.fromOffset(14, 20)
	SliderThumb.AnchorPoint = Vector2.new(0.5, 0.5)
	SliderThumb.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	SliderThumb.BorderSizePixel = 0
	SliderThumb.Parent = SliderTrack

	local ThumbCorner = Instance.new("UICorner")
	ThumbCorner.CornerRadius = UDim.new(0, 3)
	ThumbCorner.Parent = SliderThumb

	local ThumbStroke = Instance.new("UIStroke")
	ThumbStroke.Thickness = 1.5
	ThumbStroke.Color = Color3.fromRGB(20, 20, 20)
	ThumbStroke.Parent = SliderThumb

	local dragging = false
	local function updateSlider(input)
		local sizeX = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
		local value = math.floor((((max - min) * sizeX) + min) / increase + 0.5) * increase
		value = math.clamp(value, min, max)
		
		local targetScale = (value - min) / (max - min)
		TweenService:Create(SliderFill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(targetScale, 0, 1, 0) }):Play()
		TweenService:Create(SliderThumb, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(targetScale, 0, 0.5, 0) }):Play()
		
		ValueInput.Text = tostring(value)
		task.spawn(callback, value)
	end

	SliderTrack.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			TweenService:Create(SliderThumb, TweenInfo.new(0.15), { Size = UDim2.fromOffset(16, 22) }):Play()
			updateSlider(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			TweenService:Create(SliderThumb, TweenInfo.new(0.15), { Size = UDim2.fromOffset(14, 20) }):Play()
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateSlider(input)
		end
	end)

	ValueInput.Focused:Connect(function()
		TweenService:Create(ValueStroke, TweenInfo.new(0.15), {Color = currentAccentColor}):Play()
		TweenService:Create(ValueBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36, 36, 42)}):Play()
	end)

	ValueInput.FocusLost:Connect(function()
		TweenService:Create(ValueStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(55, 55, 60)}):Play()
		TweenService:Create(ValueBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(30, 30, 34)}):Play()
		local val = tonumber(ValueInput.Text)
		if val then
			val = math.clamp(math.floor(val / increase + 0.5) * increase, min, max)
			local targetScale = (val - min) / (max - min)
			TweenService:Create(SliderFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(targetScale, 0, 1, 0) }):Play()
			TweenService:Create(SliderThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(targetScale, 0, 0.5, 0) }):Play()
			ValueInput.Text = tostring(val)
			task.spawn(callback, val)
		else
			ValueInput.Text = tostring(default)
		end
	end)

	-- Hover Effects
	SliderFrame.MouseEnter:Connect(function()
		TweenService:Create(SliderFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40) }):Play()
		TweenService:Create(SliderStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 75) }):Play()
	end)
	SliderFrame.MouseLeave:Connect(function()
		TweenService:Create(SliderFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(26, 26, 30) }):Play()
		TweenService:Create(SliderStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(50, 50, 55) }):Play()
	end)

	-- Register for dynamic theme updates
	registerThemeUpdate(function(color)
		SliderFill.BackgroundColor3 = color
	end)

	table.insert(tabObj.Elements, {Object = SliderFrame, OriginalColumn = TargetColumn})

	local SliderController = {}
	function SliderController:Set(value)
		value = math.clamp(math.floor(value / increase + 0.5) * increase, min, max)
		local targetScale = (value - min) / (max - min)
		TweenService:Create(SliderFill, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Size = UDim2.new(targetScale, 0, 1, 0) }):Play()
		TweenService:Create(SliderThumb, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { Position = UDim2.new(targetScale, 0, 0.5, 0) }):Play()
		ValueInput.Text = tostring(value)
		task.spawn(callback, value)
	end
	return SliderController
end

-- ==========================================
-- STANDALONE TEXTBOX CREATION FUNCTION
-- ==========================================
local function CreateTextbox(tabObj: TabObjectType, textConfig: TextboxConfig)
	textConfig = textConfig or {} :: TextboxConfig
	local title = textConfig.Title or "Textbox"
	local description = textConfig.Description
	local placeholder = textConfig.Placeholder or "Type here..."
	local default = textConfig.Default or ""
	local clearOnFocus = textConfig.ClearOnFocus or false
	local callback = textConfig.Callback or function() end
	local icon = parseIcon(textConfig.Icon)
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, textConfig.Position)

	-- Main Textbox Frame (FIXED: Height increased to 96px to prevent overlapping and fit larger box)
	local TextboxFrame = Instance.new("Frame")
	TextboxFrame.Name = title .. "_Textbox"
	TextboxFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	TextboxFrame.BorderSizePixel = 0
	TextboxFrame.Size = UDim2.new(1, 0, 0, 96)
	TextboxFrame.LayoutOrder = layoutOrderMap[title] or 100
	TextboxFrame.Parent = TargetColumn

	local FrameCorner = Instance.new("UICorner")
	FrameCorner.CornerRadius = UDim.new(0, 8)
	FrameCorner.Parent = TextboxFrame

	local TextboxStroke = Instance.new("UIStroke")
	TextboxStroke.Thickness = 1
	TextboxStroke.Color = Color3.fromRGB(50, 50, 55)
	TextboxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	TextboxStroke.Parent = TextboxFrame

	-- Optional Icon Container (Upgraded Size & Layout)
	if icon then
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		IconContainer.BorderSizePixel = 0
		IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
		IconContainer.Size = UDim2.new(0, 42, 0, 42)
		IconContainer.Parent = TextboxFrame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Name = "Icon"
		IconLabel.BackgroundTransparency = 1
		IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconLabel.Size = UDim2.new(0, 26, 0, 26)
		IconLabel.Image = icon
		IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		IconLabel.ScaleType = Enum.ScaleType.Fit
		IconLabel.Parent = IconContainer
	end

	-- Text Container (Title & Description) - Adjusted layout and spacing
	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.BackgroundTransparency = 1
	TextContainer.Position = icon and UDim2.new(0, 62, 0, 8) or UDim2.new(0, 12, 0, 8)
	TextContainer.Size = icon and UDim2.new(1, -72, 0, 36) or UDim2.new(1, -24, 0, 36)
	TextContainer.Parent = TextboxFrame

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
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, title)

	if hasDesc then
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 0, 20)
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = description
		DescLabel.TextColor3 = Color3.fromRGB(180, 180, 185)
		DescLabel.TextSize = 10
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextWrapped = true
		DescLabel.Parent = TextContainer
	end

	-- Input Box (FIXED: Placed at the bottom, made significantly larger, styled like a premium button box with high contrast)
	local InputBox = Instance.new("TextBox")
	InputBox.Name = "InputBox"
	InputBox.BackgroundColor3 = Color3.fromRGB(32, 32, 36) -- FIXED: High contrast dark slate (not pitch black)
	InputBox.BorderSizePixel = 0
	InputBox.Position = icon and UDim2.new(0, 62, 0, 50) or UDim2.new(0, 12, 0, 50)
	InputBox.Size = icon and UDim2.new(1, -72, 0, 34) or UDim2.new(1, -24, 0, 34)
	InputBox.Font = Enum.Font.Gotham
	InputBox.PlaceholderText = placeholder
	InputBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 155) -- FIXED: Brighter placeholder for visibility
	InputBox.Text = default
	InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	InputBox.TextSize = 11
	InputBox.TextWrapped = true
	InputBox.ClearTextOnFocus = clearOnFocus
	InputBox.Parent = TextboxFrame

	local InputCorner = Instance.new("UICorner")
	InputCorner.CornerRadius = UDim.new(0, 6)
	InputCorner.Parent = InputBox

	-- FIXED: Added a highly visible, clean outline around the textbox
	local InputStroke = Instance.new("UIStroke")
	InputStroke.Thickness = 1.5
	InputStroke.Color = Color3.fromRGB(100, 100, 105) -- Highly visible default border
	InputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	InputStroke.Parent = InputBox

	local InputPadding = Instance.new("UIPadding")
	InputPadding.PaddingLeft = UDim.new(0, 10) -- FIXED: Added padding so text doesn't touch the edge
	InputPadding.PaddingRight = UDim.new(0, 10) -- Leave room for edit icon
	InputPadding.Parent = InputBox

	-- Subtle Edit Icon inside the InputBox to indicate interactivity
	InputBox.Focused:Connect(function()
		TweenService:Create(InputBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(38, 38, 44)}):Play()
		TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
	end)

	InputBox.FocusLost:Connect(function()
		TweenService:Create(InputBox, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 36)}):Play()
		TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(100, 100, 105)}):Play()
		task.spawn(callback, InputBox.Text)
	end)

	-- Hover Transitions
	TextboxFrame.MouseEnter:Connect(function()
		TweenService:Create(TextboxFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36, 36, 40)}):Play()
		TweenService:Create(TextboxStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
		TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(130, 130, 135)}):Play()
	end)

	TextboxFrame.MouseLeave:Connect(function()
		TweenService:Create(TextboxFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
		TweenService:Create(TextboxStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(50, 50, 55)}):Play()
		if not InputBox:IsFocused() then
			TweenService:Create(InputStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(100, 100, 105)}):Play()
		end
	end)

	table.insert(tabObj.Elements, {Object = TextboxFrame, OriginalColumn = TargetColumn})
end

-- ==========================================
-- STANDALONE SELECTOR CREATION FUNCTION
-- ==========================================
local function CreateSelector(tabObj: TabObjectType, selConfig: SelectorConfig)
	selConfig = selConfig or {} :: SelectorConfig
	local title = selConfig.Title or "Selector"
	local description = selConfig.Description
	local options = selConfig.Options or {}
	local default = selConfig.Default
	local callback = selConfig.Callback or function() end
	local icon = parseIcon(selConfig.Icon)
	local searchEnabled = if selConfig.Search ~= nil then selConfig.Search else false
	local multiEnabled = if selConfig.Multi ~= nil then selConfig.Multi else false
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, selConfig.Position)

	-- Track selected options
	local selectedOptions = {}
	if multiEnabled then
		if type(default) == "table" then
			for _, val in ipairs(default) do
				selectedOptions[val] = true
			end
		elseif type(default) == "string" and default ~= "" then
			selectedOptions[default] = true
		end
	else
		if type(default) == "string" and default ~= "" then
			selectedOptions[default] = true
		end
	end

	-- Main Selector Frame (FIXED: Height increased to 84px to match Textbox style)
	local SelFrame = Instance.new("Frame")
	SelFrame.Name = title .. "_Selector"
	SelFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	SelFrame.BorderSizePixel = 0
	SelFrame.Size = UDim2.new(1, 0, 0, 84)
	SelFrame.LayoutOrder = layoutOrderMap[title] or 100
	SelFrame.Parent = TargetColumn

	local SelCorner = Instance.new("UICorner")
	SelCorner.CornerRadius = UDim.new(0, 8)
	SelCorner.Parent = SelFrame

	local SelStroke = Instance.new("UIStroke")
	SelStroke.Thickness = 1
	SelStroke.Color = Color3.fromRGB(50, 50, 55)
	SelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	SelStroke.Parent = SelFrame

	-- Header Button (the clickable part)
	local HeaderBtn = Instance.new("TextButton")
	HeaderBtn.Name = "HeaderBtn"
	HeaderBtn.BackgroundTransparency = 1
	HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
	HeaderBtn.Text = ""
	HeaderBtn.Parent = SelFrame

	-- Optional Icon Container (Upgraded Size & Layout)
	if icon then
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		IconContainer.BorderSizePixel = 0
		IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
		IconContainer.Size = UDim2.new(0, 42, 0, 42)
		IconContainer.Parent = HeaderBtn

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Name = "Icon"
		IconLabel.BackgroundTransparency = 1
		IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconLabel.Size = UDim2.new(0, 26, 0, 26)
		IconLabel.Image = icon
		IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		IconLabel.ScaleType = Enum.ScaleType.Fit
		IconLabel.Parent = IconContainer
	end

	-- Text Container (Title & Description) - FIXED: Expanded to full width since ValueBox is moved below
	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.BackgroundTransparency = 1
	TextContainer.Position = icon and UDim2.new(0, 62, 0, 8) or UDim2.new(0, 12, 0, 8)
	TextContainer.Size = icon and UDim2.new(1, -72, 0, 34) or UDim2.new(1, -24, 0, 34)
	TextContainer.Parent = HeaderBtn

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
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, title)

	if hasDesc then
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 0, 18)
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = description
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 9
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextWrapped = true
		DescLabel.Parent = TextContainer
	end

	-- Value Box - FIXED: Positioned directly under the title/description, expanded to full width
	local ValueBox = Instance.new("Frame")
	ValueBox.Name = "ValueBox"
	ValueBox.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
	ValueBox.BorderSizePixel = 0
	ValueBox.Position = icon and UDim2.new(0, 62, 0, 46) or UDim2.new(0, 12, 0, 46)
	ValueBox.Size = icon and UDim2.new(1, -72, 0, 28) or UDim2.new(1, -24, 0, 28)
	ValueBox.Parent = HeaderBtn

	local ValueCorner = Instance.new("UICorner")
	ValueCorner.CornerRadius = UDim.new(0, 6)
	ValueCorner.Parent = ValueBox

	local ValueLabel = Instance.new("TextLabel")
	ValueLabel.Name = "ValueLabel"
	ValueLabel.BackgroundTransparency = 1
	ValueLabel.Size = UDim2.new(1, -30, 1, 0)
	ValueLabel.Position = UDim2.new(0, 10, 0, 0)
	ValueLabel.Font = Enum.Font.GothamBold
	ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	ValueLabel.TextSize = 11
	ValueLabel.TextXAlignment = Enum.TextXAlignment.Left
	ValueLabel.TextTruncate = Enum.TextTruncate.AtEnd
	ValueLabel.Parent = ValueBox

	-- FIXED: Smart truncation for multi-selection to prevent text overflow
	local function updateValueLabel()
		local selectedList = {}
		for opt, _ in pairs(selectedOptions) do
			table.insert(selectedList, opt)
		end
		table.sort(selectedList)
		if #selectedList == 0 then
			ValueLabel.Text = "Select..."
		elseif #selectedList > 2 then
			ValueLabel.Text = string.format("%s, %s (+%d more)", selectedList[1], selectedList[2], #selectedList - 2)
		else
			ValueLabel.Text = table.concat(selectedList, ", ")
		end
	end
	updateValueLabel()

	-- FIXED: Replaced right arrow with down arrow for dropdown selection
	local DropIcon = Instance.new("ImageLabel")
	DropIcon.Name = "DropIcon"
	DropIcon.BackgroundTransparency = 1
	DropIcon.Position = UDim2.new(1, -22, 0.5, -6)
	DropIcon.Size = UDim2.new(0, 12, 0, 12)
	DropIcon.Image = Astral.Icons.down_arrow
	DropIcon.ImageColor3 = Color3.fromRGB(160, 160, 165)
	DropIcon.Parent = ValueBox

	-- Dynamic Slide-In Side Panel Setup
	local MainGen3 = TargetColumn:FindFirstAncestor("MainGen3")
	local SidePanel: TextButton? = nil
	local populateOptions: ((string?) -> ())?

	if MainGen3 then
		SidePanel = Instance.new("TextButton")
		SidePanel.Name = title .. "_SidePanel"
		SidePanel.Size = UDim2.new(0, 260, 1, 0)
		SidePanel.Position = UDim2.new(1, 10, 0, 0)
		SidePanel.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
		SidePanel.BorderSizePixel = 0
		SidePanel.ZIndex = 100
		SidePanel.Active = true
		SidePanel.Text = ""
		SidePanel.AutoButtonColor = false
		SidePanel.Parent = MainGen3

		local PanelCorner = Instance.new("UICorner")
		PanelCorner.CornerRadius = UDim.new(0, 10)
		PanelCorner.Parent = SidePanel

		local PanelStroke = Instance.new("UIStroke")
		PanelStroke.Thickness = 1.5
		PanelStroke.Color = Color3.fromRGB(50, 50, 55)
		PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		PanelStroke.Parent = SidePanel

		-- Side Panel Header
		local PanelHeader = Instance.new("Frame")
		PanelHeader.Name = "PanelHeader"
		PanelHeader.Size = UDim2.new(1, 0, 0, 50)
		PanelHeader.BackgroundTransparency = 1
		PanelHeader.ZIndex = 101
		PanelHeader.Parent = SidePanel

		local PanelTitle = Instance.new("TextLabel")
		PanelTitle.Name = "PanelTitle"
		PanelTitle.Size = UDim2.new(1, -60, 1, 0)
		PanelTitle.Position = UDim2.new(0, 15, 0, 0)
		PanelTitle.BackgroundTransparency = 1
		PanelTitle.Font = Enum.Font.GothamBold
		PanelTitle.Text = title:upper()
		PanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		PanelTitle.TextSize = 13
		PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
		PanelTitle.ZIndex = 101
		PanelTitle.Parent = PanelHeader
		registerTranslation(PanelTitle, title, function(t) return t:upper() end)

		local CloseBtn = Instance.new("TextButton")
		CloseBtn.Name = "CloseBtn"
		CloseBtn.Size = UDim2.fromOffset(24, 24)
		CloseBtn.Position = UDim2.new(1, -34, 0.5, -12)
		CloseBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		CloseBtn.BorderSizePixel = 0
		CloseBtn.Text = "×"
		CloseBtn.Font = Enum.Font.GothamBold
		CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 165)
		CloseBtn.TextSize = 18
		CloseBtn.ZIndex = 101
		CloseBtn.Parent = PanelHeader

		local CloseCorner = Instance.new("UICorner")
		CloseCorner.CornerRadius = UDim.new(0, 6)
		CloseCorner.Parent = CloseBtn

		-- Search Bar inside Side Panel (if searchEnabled is true, with Stroke Layout)
		local PanelSearch: TextBox? = nil
		local searchOffset = 0
		if searchEnabled then
			searchOffset = 44
			PanelSearch = Instance.new("TextBox")
			PanelSearch.Name = "PanelSearch"
			PanelSearch.Size = UDim2.new(1, -30, 0, 36)
			PanelSearch.Position = UDim2.new(0, 15, 0, 50)
			PanelSearch.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
			PanelSearch.BorderSizePixel = 0
			PanelSearch.Font = Enum.Font.Gotham
			PanelSearch.PlaceholderText = "Search options..."
			PanelSearch.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
			PanelSearch.Text = ""
			PanelSearch.TextColor3 = Color3.fromRGB(255, 255, 255)
			PanelSearch.TextSize = 11
			PanelSearch.ZIndex = 101
			PanelSearch.Parent = SidePanel

			local SearchCorner = Instance.new("UICorner")
			SearchCorner.CornerRadius = UDim.new(0, 6)
			SearchCorner.Parent = PanelSearch

			local SearchStroke = Instance.new("UIStroke")
			SearchStroke.Thickness = 1
			SearchStroke.Color = Color3.fromRGB(55, 55, 60)
			SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			SearchStroke.Parent = PanelSearch

			local SearchPadding = Instance.new("UIPadding")
			SearchPadding.PaddingLeft = UDim.new(0, 30) -- FIXED: Left padding for search icon
			SearchPadding.PaddingRight = UDim.new(0, 30) -- FIXED: Right padding for clear button
			SearchPadding.Parent = PanelSearch

			-- FIXED: Added Search Icon inside Selector Search Bar
			local SearchIcon = Instance.new("ImageLabel")
			SearchIcon.Name = "SearchIcon"
			SearchIcon.BackgroundTransparency = 1
			SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
			SearchIcon.Size = UDim2.fromOffset(14, 14)
			SearchIcon.Image = Astral.Icons.search
			SearchIcon.ImageColor3 = Color3.fromRGB(120, 120, 125)
			SearchIcon.ZIndex = 102
			SearchIcon.Parent = PanelSearch

			-- FIXED: Added Clear Button inside Selector Search Bar
			local ClearSearchBtn = Instance.new("TextButton")
			ClearSearchBtn.Name = "ClearSearchBtn"
			ClearSearchBtn.BackgroundTransparency = 1
			ClearSearchBtn.Position = UDim2.new(1, -24, 0.5, -8)
			ClearSearchBtn.Size = UDim2.fromOffset(16, 16)
			ClearSearchBtn.Text = "×"
			ClearSearchBtn.Font = Enum.Font.GothamBold
			ClearSearchBtn.TextColor3 = Color3.fromRGB(120, 120, 125)
			ClearSearchBtn.TextSize = 14
			ClearSearchBtn.Visible = false
			ClearSearchBtn.ZIndex = 102
			ClearSearchBtn.Parent = PanelSearch

			ClearSearchBtn.MouseButton1Click:Connect(function()
				PanelSearch.Text = ""
			end)

			PanelSearch:GetPropertyChangedSignal("Text"):Connect(function()
				ClearSearchBtn.Visible = (PanelSearch.Text ~= "")
			end)

		PanelSearch.Focused:Connect(function()
			TweenService:Create(SearchStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
			TweenService:Create(PanelSearch, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
		end)

			PanelSearch.FocusLost:Connect(function()
				TweenService:Create(SearchStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(55, 55, 60)}):Play()
				TweenService:Create(PanelSearch, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
			end)
		end

		-- Divider
		local PanelDivider = Instance.new("Frame")
		PanelDivider.Name = "PanelDivider"
		PanelDivider.Size = UDim2.new(1, -30, 0, 1)
		PanelDivider.Position = UDim2.new(0, 15, 0, 50 + searchOffset)
		PanelDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
		PanelDivider.BorderSizePixel = 0
		PanelDivider.ZIndex = 101
		PanelDivider.Parent = SidePanel

		-- Options Scrolling Container
		local OptionsScroll = Instance.new("ScrollingFrame")
		OptionsScroll.Name = "OptionsScroll"
		OptionsScroll.Size = UDim2.new(1, 0, 1, -(60 + searchOffset))
		OptionsScroll.Position = UDim2.new(0, 0, 0, 55 + searchOffset)
		OptionsScroll.BackgroundTransparency = 1
		OptionsScroll.BorderSizePixel = 0
		OptionsScroll.ZIndex = 101
		OptionsScroll.ScrollBarThickness = 0
		OptionsScroll.Parent = SidePanel

		local ScrollPadding = Instance.new("UIPadding")
		ScrollPadding.PaddingLeft = UDim.new(0, 15)
		ScrollPadding.PaddingRight = UDim.new(0, 15)
		ScrollPadding.PaddingTop = UDim.new(0, 5)
		ScrollPadding.PaddingBottom = UDim.new(0, 15)
		ScrollPadding.Parent = OptionsScroll

		local ScrollLayout = Instance.new("UIListLayout")
		ScrollLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ScrollLayout.Padding = UDim.new(0, 8)
		ScrollLayout.Parent = OptionsScroll

		local function closePanel()
			if SidePanel then
				TweenService:Create(SidePanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(1, 10, 0, 0)
				}):Play()
			end
			TweenService:Create(Scrim, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.25, function()
				if activeCloseCallback == closePanel then
					Scrim.Visible = false
					activeCloseCallback = nil
				end
			end)
		end

		CloseBtn.MouseButton1Click:Connect(closePanel)

		CloseBtn.MouseEnter:Connect(function()
			TweenService:Create(CloseBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(219, 68, 68), TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end)
		CloseBtn.MouseLeave:Connect(function()
			TweenService:Create(CloseBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40), TextColor3 = Color3.fromRGB(160, 160, 165) }):Play()
		end)

		populateOptions = function(filterText: string?)
			local query = filterText and filterText:lower() or ""
			for _, child in ipairs(OptionsScroll:GetChildren()) do
				if child:IsA("TextButton") then child:Destroy() end
			end

			for _, opt in ipairs(options) do
				if query ~= "" and not string.find(opt:lower(), query, 1, true) then
					continue
				end

				local isSelected = selectedOptions[opt] == true

				local OptBtn = Instance.new("TextButton")
				OptBtn.Name = opt
				OptBtn.Size = UDim2.new(1, 0, 0, 36)
				OptBtn.BackgroundColor3 = isSelected and Color3.fromRGB(36, 36, 40) or Color3.fromRGB(26, 26, 30)
				OptBtn.BorderSizePixel = 0
				OptBtn.Text = ""
				OptBtn.ZIndex = 102
				OptBtn.Parent = OptionsScroll

				local OptCorner = Instance.new("UICorner")
				OptCorner.CornerRadius = UDim.new(0, 6)
				OptCorner.Parent = OptBtn

				local OptStroke = Instance.new("UIStroke")
				OptStroke.Thickness = 1
				OptStroke.Color = isSelected and currentAccentColor or Color3.fromRGB(50, 50, 55)
				OptStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
				OptStroke.Parent = OptBtn

				local OptLayout = Instance.new("UIListLayout")
				OptLayout.FillDirection = Enum.FillDirection.Horizontal
				OptLayout.VerticalAlignment = Enum.VerticalAlignment.Center
				OptLayout.SortOrder = Enum.SortOrder.LayoutOrder
				OptLayout.Padding = UDim.new(0, 10)
				OptLayout.Parent = OptBtn

				local OptPadding = Instance.new("UIPadding")
				OptPadding.PaddingLeft = UDim.new(0, 10)
				OptPadding.PaddingRight = UDim.new(0, 10)
				OptPadding.Parent = OptBtn

				local Indicator = Instance.new("Frame")
				Indicator.Name = "Indicator"
				Indicator.Size = UDim2.fromOffset(16, 16)
				Indicator.BackgroundColor3 = isSelected and currentAccentColor or Color3.fromRGB(36, 36, 40)
				Indicator.BorderSizePixel = 0
				Indicator.LayoutOrder = 1
				Indicator.ZIndex = 103
				Indicator.Parent = OptBtn

				local IndicatorCorner = Instance.new("UICorner")
				IndicatorCorner.CornerRadius = multiEnabled and UDim.new(0, 4) or UDim.new(0, 8)
				IndicatorCorner.Parent = Indicator

				local IndicatorStroke = Instance.new("UIStroke")
				IndicatorStroke.Thickness = 1
				IndicatorStroke.Color = isSelected and currentAccentColor or Color3.fromRGB(50, 50, 55)
				IndicatorStroke.Parent = Indicator

				if isSelected then
					local Check = Instance.new("ImageLabel")
					Check.Name = "Check"
					Check.Size = UDim2.fromScale(0.8, 0.8)
					Check.AnchorPoint = Vector2.new(0.5, 0.5)
					Check.Position = UDim2.fromScale(0.5, 0.5)
					Check.BackgroundTransparency = 1
					Check.Image = Astral.Icons.Checkmark
					Check.ImageColor3 = Color3.fromRGB(255, 255, 255)
					Check.ZIndex = 103
					Check.Parent = Indicator
				end

				local OptLabel = Instance.new("TextLabel")
				OptLabel.Name = "OptLabel"
				OptLabel.Size = UDim2.new(1, -26, 1, 0)
				OptLabel.BackgroundTransparency = 1
				OptLabel.Font = Enum.Font.GothamBold
				OptLabel.Text = opt
				OptLabel.TextColor3 = isSelected and currentAccentColor or Color3.fromRGB(220, 220, 225)
				OptLabel.TextSize = 11
				OptLabel.TextXAlignment = Enum.TextXAlignment.Left
				OptLabel.LayoutOrder = 2
				OptLabel.ZIndex = 103
				OptLabel.Parent = OptBtn

				OptBtn.MouseEnter:Connect(function()
					TweenService:Create(OptBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40) }):Play()
				end)
				OptBtn.MouseLeave:Connect(function()
					TweenService:Create(OptBtn, TweenInfo.new(0.15), { BackgroundColor3 = isSelected and Color3.fromRGB(36, 36, 40) or Color3.fromRGB(26, 26, 30) }):Play()
				end)

				OptBtn.MouseButton1Click:Connect(function()
					if multiEnabled then
						if selectedOptions[opt] then
							selectedOptions[opt] = nil
						else
							selectedOptions[opt] = true
						end
						updateValueLabel()
						populateOptions(PanelSearch and PanelSearch.Text or nil)
						
						local result = {}
						for k, _ in pairs(selectedOptions) do
							table.insert(result, k)
						end
						task.spawn(callback, result)
					else
						table.clear(selectedOptions)
						selectedOptions[opt] = true
						updateValueLabel()
						task.spawn(callback, opt)
						closePanel()
					end
				end)
			end
			OptionsScroll.CanvasSize = UDim2.new(0, 0, 0, ScrollLayout.AbsoluteContentSize.Y + 20)
		end

		if PanelSearch then
			PanelSearch:GetPropertyChangedSignal("Text"):Connect(function()
				populateOptions(PanelSearch.Text)
			end)
		end

		HeaderBtn.MouseButton1Click:Connect(function()
			for _, child in ipairs(MainGen3:GetChildren()) do
				if child:IsA("Frame") and string.match(child.Name, "_SidePanel$") and child ~= SidePanel then
					TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(1, 10, 0, 0)
					}):Play()
				end
			end

			if PanelSearch then PanelSearch.Text = "" end
			populateOptions()

			Scrim.Visible = true
			TweenService:Create(Scrim, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.6
			}):Play()

			activeCloseCallback = closePanel

			TweenService:Create(SidePanel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(1, -260, 0, 0)
			}):Play()
		end)
	end

	HeaderBtn.MouseEnter:Connect(function()
		TweenService:Create(SelFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40) }):Play()
		TweenService:Create(SelStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 75) }):Play()
	end)

	HeaderBtn.MouseLeave:Connect(function()
		TweenService:Create(SelFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(26, 26, 30) }):Play()
		TweenService:Create(SelStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(50, 50, 55) }):Play()
	end)

	table.insert(tabObj.Elements, {Object = SelFrame, OriginalColumn = TargetColumn})

	local controller: SelectorController = {
		SetOptions = function(self, newOptions, newDefault)
			options = newOptions or {}
			table.clear(selectedOptions)
			if newDefault ~= nil then
				if type(newDefault) == "table" then
					for _, val in ipairs(newDefault) do
						selectedOptions[val] = true
					end
				elseif type(newDefault) == "string" and newDefault ~= "" then
					selectedOptions[newDefault] = true
				end
			end
			updateValueLabel()
			if populateOptions then
				populateOptions(PanelSearch and PanelSearch.Text or nil)
			end
		end
	}

	return controller
end

-- ==========================================
-- STANDALONE COLOR PICKER CREATION FUNCTION
-- ==========================================
local function CreateColorPicker(tabObj: TabObjectType, cpConfig: ColorPickerConfig)
	cpConfig = cpConfig or {} :: ColorPickerConfig
	local title = cpConfig.Title or "Color Picker"
	local description = cpConfig.Description
	local defaultColor = cpConfig.Default or Color3.fromRGB(0, 255, 0)
	local callback = cpConfig.Callback or function() end
	local icon = parseIcon(cpConfig.Icon) or Astral.Icons.redo
	local hasDesc = description and description ~= ""

	local TargetColumn = GetTargetColumn(tabObj, cpConfig.Position)

	-- Main Color Picker Frame (Matches Image Reference Layout)
	local ColorPickerFrame = Instance.new("Frame")
	ColorPickerFrame.Name = title .. "_ColorPicker"
	ColorPickerFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	ColorPickerFrame.BorderSizePixel = 0
	ColorPickerFrame.Size = UDim2.new(1, 0, 0, 64)
	ColorPickerFrame.LayoutOrder = layoutOrderMap[title] or 100
	ColorPickerFrame.Parent = TargetColumn

	local FrameCorner = Instance.new("UICorner")
	FrameCorner.CornerRadius = UDim.new(0, 8)
	FrameCorner.Parent = ColorPickerFrame

	local FrameStroke = Instance.new("UIStroke")
	FrameStroke.Thickness = 1
	FrameStroke.Color = Color3.fromRGB(50, 50, 55)
	FrameStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	FrameStroke.Parent = ColorPickerFrame

	-- Header Button (Clickable area)
	local HeaderBtn = Instance.new("TextButton")
	HeaderBtn.Name = "HeaderBtn"
	HeaderBtn.BackgroundTransparency = 1
	HeaderBtn.Size = UDim2.new(1, 0, 1, 0)
	HeaderBtn.Text = ""
	HeaderBtn.Parent = ColorPickerFrame

	-- Icon Container (Matches Image Reference: Rounded Square with White Outline)
	local IconContainer = Instance.new("Frame")
	IconContainer.Name = "IconContainer"
	IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
	IconContainer.BorderSizePixel = 0
	IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
	IconContainer.Size = UDim2.new(0, 42, 0, 42)
	IconContainer.Parent = HeaderBtn

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
	IconLabel.Size = UDim2.new(0, 26, 0, 26)
	IconLabel.Image = icon
	IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
	IconLabel.ScaleType = Enum.ScaleType.Fit
	IconLabel.Parent = IconContainer

	-- Text Container (Title & Description)
	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.BackgroundTransparency = 1
	TextContainer.Position = UDim2.new(0, 62, 0, 0)
	TextContainer.Size = UDim2.new(1, -146, 1, 0)
	TextContainer.Parent = HeaderBtn

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
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, title)

	if hasDesc then
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.BackgroundTransparency = 1
		DescLabel.Size = UDim2.new(1, 0, 0, 24)
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = description
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 9
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextWrapped = true
		DescLabel.Parent = TextContainer
	end

	-- Color Preview Button (Matches Image Reference: Rounded Rectangle)
	local ColorPreview = Instance.new("TextButton")
	ColorPreview.Name = "ColorPreview"
	ColorPreview.BackgroundColor3 = defaultColor
	ColorPreview.BorderSizePixel = 0
	ColorPreview.Position = UDim2.new(1, -70, 0.5, -14)
	ColorPreview.Size = UDim2.new(0, 54, 0, 28)
	ColorPreview.Text = ""
	ColorPreview.AutoButtonColor = false
	ColorPreview.Parent = HeaderBtn

	local PreviewCorner = Instance.new("UICorner")
	PreviewCorner.CornerRadius = UDim.new(0, 10)
	PreviewCorner.Parent = ColorPreview

	local PreviewStroke = Instance.new("UIStroke")
	PreviewStroke.Thickness = 1
	PreviewStroke.Color = Color3.fromRGB(50, 50, 55)
	PreviewStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	PreviewStroke.Parent = ColorPreview

	-- Dynamic Slide-In Side Panel Setup
	local MainGen3 = TargetColumn:FindFirstAncestor("MainGen3")
	local SidePanel: TextButton? = nil

	if MainGen3 then
		SidePanel = Instance.new("TextButton")
		SidePanel.Name = title .. "_SidePanel"
		SidePanel.Size = UDim2.new(0, 260, 1, 0)
		SidePanel.Position = UDim2.new(1, 10, 0, 0)
		SidePanel.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
		SidePanel.BorderSizePixel = 0
		SidePanel.ZIndex = 100
		SidePanel.Active = true
		SidePanel.Text = ""
		SidePanel.AutoButtonColor = false
		SidePanel.Parent = MainGen3

		local PanelCorner = Instance.new("UICorner")
		PanelCorner.CornerRadius = UDim.new(0, 10)
		PanelCorner.Parent = SidePanel

		local PanelStroke = Instance.new("UIStroke")
		PanelStroke.Thickness = 1.5
		PanelStroke.Color = Color3.fromRGB(50, 50, 55)
		PanelStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		PanelStroke.Parent = SidePanel

		-- Side Panel Header
		local PanelHeader = Instance.new("Frame")
		PanelHeader.Name = "PanelHeader"
		PanelHeader.Size = UDim2.new(1, 0, 0, 50)
		PanelHeader.BackgroundTransparency = 1
		PanelHeader.ZIndex = 101
		PanelHeader.Parent = SidePanel

		local PanelTitle = Instance.new("TextLabel")
		PanelTitle.Name = "PanelTitle"
		PanelTitle.Size = UDim2.new(1, -60, 1, 0)
		PanelTitle.Position = UDim2.new(0, 15, 0, 0)
		PanelTitle.BackgroundTransparency = 1
		PanelTitle.Font = Enum.Font.GothamBold
		PanelTitle.Text = title:upper()
		PanelTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		PanelTitle.TextSize = 13
		PanelTitle.TextXAlignment = Enum.TextXAlignment.Left
		PanelTitle.ZIndex = 101
		PanelTitle.Parent = PanelHeader
		registerTranslation(PanelTitle, title, function(t) return t:upper() end)

		local CloseBtn = Instance.new("TextButton")
		CloseBtn.Name = "CloseBtn"
		CloseBtn.Size = UDim2.fromOffset(24, 24)
		CloseBtn.Position = UDim2.new(1, -34, 0.5, -12)
		CloseBtn.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		CloseBtn.BorderSizePixel = 0
		CloseBtn.Text = "×"
		CloseBtn.Font = Enum.Font.GothamBold
		CloseBtn.TextColor3 = Color3.fromRGB(160, 160, 165)
		CloseBtn.TextSize = 18
		CloseBtn.ZIndex = 101
		CloseBtn.Parent = PanelHeader

		local CloseCorner = Instance.new("UICorner")
		CloseCorner.CornerRadius = UDim.new(0, 6)
		CloseCorner.Parent = CloseBtn

		-- Divider
		local PanelDivider = Instance.new("Frame")
		PanelDivider.Name = "PanelDivider"
		PanelDivider.Size = UDim2.new(1, -30, 0, 1)
		PanelDivider.Position = UDim2.new(0, 15, 0, 50)
		PanelDivider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
		PanelDivider.BorderSizePixel = 0
		PanelDivider.ZIndex = 101
		PanelDivider.Parent = SidePanel

		-- Color Picker Content Container
		local PickerContainer = Instance.new("Frame")
		PickerContainer.Name = "PickerContainer"
		PickerContainer.Size = UDim2.new(1, 0, 1, -60)
		PickerContainer.Position = UDim2.new(0, 0, 0, 55)
		PickerContainer.BackgroundTransparency = 1
		PickerContainer.ZIndex = 101
		PickerContainer.Parent = SidePanel

		-- 2D Color Map (HSV Gradient) - Redesigned to match image reference perfectly
		local ColorMap = Instance.new("Frame")
		ColorMap.Name = "ColorMap"
		ColorMap.Size = UDim2.new(1, -30, 0, 150)
		ColorMap.Position = UDim2.new(0, 15, 0, 10)
		ColorMap.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Base Hue
		ColorMap.BorderSizePixel = 0
		ColorMap.ZIndex = 102
		ColorMap.Parent = PickerContainer

		local MapCorner = Instance.new("UICorner")
		MapCorner.CornerRadius = UDim.new(0, 8)
		MapCorner.Parent = ColorMap

		local MapStroke = Instance.new("UIStroke")
		MapStroke.Thickness = 1
		MapStroke.Color = Color3.fromRGB(50, 50, 55)
		MapStroke.Parent = ColorMap

		-- Saturation Gradient (Horizontal White-to-Transparent) - FIXED: Rotation set to 0 so white is on the left, red is on the right
		local SatGradientFrame = Instance.new("Frame")
		SatGradientFrame.Name = "SatGradientFrame"
		SatGradientFrame.Size = UDim2.fromScale(1, 1)
		SatGradientFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		SatGradientFrame.BorderSizePixel = 0
		SatGradientFrame.ZIndex = 103
		SatGradientFrame.Parent = ColorMap

		local SatCorner = Instance.new("UICorner")
		SatCorner.CornerRadius = UDim.new(0, 8)
		SatCorner.Parent = SatGradientFrame

		local SatGradient = Instance.new("UIGradient")
		SatGradient.Rotation = 0
		SatGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 0),
			NumberSequenceKeypoint.new(1, 1)
		})
		SatGradient.Parent = SatGradientFrame

		-- Value Gradient (Vertical Transparent-to-Black)
		local ValGradientFrame = Instance.new("Frame")
		ValGradientFrame.Name = "ValGradientFrame"
		ValGradientFrame.Size = UDim2.fromScale(1, 1)
		ValGradientFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		ValGradientFrame.BorderSizePixel = 0
		ValGradientFrame.ZIndex = 104
		ValGradientFrame.Parent = ColorMap

		local ValCorner = Instance.new("UICorner")
		ValCorner.CornerRadius = UDim.new(0, 8)
		ValCorner.Parent = ValGradientFrame

		local ValGradient = Instance.new("UIGradient")
		ValGradient.Rotation = 90
		ValGradient.Transparency = NumberSequence.new({
			NumberSequenceKeypoint.new(0, 1),
			NumberSequenceKeypoint.new(1, 0)
		})
		ValGradient.Parent = ValGradientFrame

		-- Selector Pin (Circular White Pin matching image)
		local Pin = Instance.new("Frame")
		Pin.Name = "Pin"
		Pin.Size = UDim2.fromOffset(16, 16)
		Pin.AnchorPoint = Vector2.new(0.5, 0.5)
		Pin.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		Pin.ZIndex = 105
		Pin.Parent = ColorMap

		local PinCorner = Instance.new("UICorner")
		PinCorner.CornerRadius = UDim.new(0, 8)
		PinCorner.Parent = Pin

		local PinStroke = Instance.new("UIStroke")
		PinStroke.Thickness = 2
		PinStroke.Color = Color3.fromRGB(0, 0, 0)
		PinStroke.Parent = Pin

		-- Hue Slider Track (Horizontal Rainbow Gradient matching image)
		local HueTrack = Instance.new("TextButton")
		HueTrack.Name = "HueTrack"
		HueTrack.Size = UDim2.new(1, -30, 0, 16)
		HueTrack.Position = UDim2.new(0, 15, 0, 175)
		HueTrack.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Set to white for vivid gradient
		HueTrack.Text = ""
		HueTrack.AutoButtonColor = false
		HueTrack.ZIndex = 102
		HueTrack.Parent = PickerContainer

		local HueCorner = Instance.new("UICorner")
		HueCorner.CornerRadius = UDim.new(0, 4)
		HueCorner.Parent = HueTrack

		local HueStroke = Instance.new("UIStroke")
		HueStroke.Thickness = 1
		HueStroke.Color = Color3.fromRGB(50, 50, 55)
		HueStroke.Parent = HueTrack

		local HueGradient = Instance.new("UIGradient")
		HueGradient.Rotation = 0
		HueGradient.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
			ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
			ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
			ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
			ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
		})
		HueGradient.Parent = HueTrack

		-- Hue Slider Thumb (White rounded vertical bar matching image)
		local HueThumb = Instance.new("Frame")
		HueThumb.Name = "HueThumb"
		HueThumb.Size = UDim2.fromOffset(10, 22)
		HueThumb.AnchorPoint = Vector2.new(0.5, 0.5)
		HueThumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		HueThumb.ZIndex = 103
		HueThumb.Parent = HueTrack

		local ThumbCorner = Instance.new("UICorner")
		ThumbCorner.CornerRadius = UDim.new(0, 4)
		ThumbCorner.Parent = HueThumb

		local ThumbStroke = Instance.new("UIStroke")
		ThumbStroke.Thickness = 1.5
		ThumbStroke.Color = Color3.fromRGB(20, 20, 20)
		ThumbStroke.Parent = HueThumb

		-- Color Comparison Container (CURRENT vs NEW buttons matching image)
		local ColorComparison = Instance.new("Frame")
		ColorComparison.Name = "ColorComparison"
		ColorComparison.Size = UDim2.new(1, -30, 0, 40)
		ColorComparison.Position = UDim2.new(0, 15, 0, 205)
		ColorComparison.BackgroundTransparency = 1
		ColorComparison.ZIndex = 102
		ColorComparison.Parent = PickerContainer

		local CurrentColorSquare = Instance.new("Frame")
		CurrentColorSquare.Name = "CurrentColorSquare"
		CurrentColorSquare.Size = UDim2.new(0.5, -6, 1, 0)
		CurrentColorSquare.Position = UDim2.new(0, 0, 0, 0)
		CurrentColorSquare.BackgroundColor3 = defaultColor
		CurrentColorSquare.BorderSizePixel = 0
		CurrentColorSquare.ZIndex = 103
		CurrentColorSquare.Parent = ColorComparison

		local CurrentCorner = Instance.new("UICorner")
		CurrentCorner.CornerRadius = UDim.new(0, 6)
		CurrentCorner.Parent = CurrentColorSquare

		local CurrentStroke = Instance.new("UIStroke")
		CurrentStroke.Thickness = 1
		CurrentStroke.Color = Color3.fromRGB(50, 50, 55)
		CurrentStroke.Parent = CurrentColorSquare

		local CurrentLabel = Instance.new("TextLabel")
		CurrentLabel.Name = "CurrentLabel"
		CurrentLabel.Size = UDim2.new(1, 0, 1, 0)
		CurrentLabel.BackgroundTransparency = 1
		CurrentLabel.Font = Enum.Font.GothamBold
		CurrentLabel.Text = "CURRENT"
		CurrentLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		CurrentLabel.TextSize = 10
		CurrentLabel.ZIndex = 104
		CurrentLabel.Parent = CurrentColorSquare

		local PickingColorSquare = Instance.new("Frame")
		PickingColorSquare.Name = "PickingColorSquare"
		PickingColorSquare.Size = UDim2.new(0.5, -6, 1, 0)
		PickingColorSquare.Position = UDim2.new(0.5, 6, 0, 0)
		PickingColorSquare.BackgroundColor3 = defaultColor
		PickingColorSquare.BorderSizePixel = 0
		PickingColorSquare.ZIndex = 103
		PickingColorSquare.Parent = ColorComparison

		local PickingCorner = Instance.new("UICorner")
		PickingCorner.CornerRadius = UDim.new(0, 6)
		PickingCorner.Parent = PickingColorSquare

		local PickingStroke = Instance.new("UIStroke")
		PickingStroke.Thickness = 1
		PickingStroke.Color = Color3.fromRGB(50, 50, 55)
		PickingStroke.Parent = PickingColorSquare

		local PickingLabel = Instance.new("TextLabel")
		PickingLabel.Name = "PickingLabel"
		PickingLabel.Size = UDim2.new(1, 0, 1, 0)
		PickingLabel.BackgroundTransparency = 1
		PickingLabel.Font = Enum.Font.GothamBold
		PickingLabel.Text = "NEW"
		PickingLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		PickingLabel.TextSize = 10
		PickingLabel.ZIndex = 104
		PickingLabel.Parent = PickingColorSquare

		-- RGB Inputs Container (Three side-by-side boxes matching image)
		local RGBContainer = Instance.new("Frame")
		RGBContainer.Name = "RGBContainer"
		RGBContainer.Size = UDim2.new(1, -30, 0, 36)
		RGBContainer.Position = UDim2.new(0, 15, 0, 260)
		RGBContainer.BackgroundTransparency = 1
		RGBContainer.ZIndex = 102
		RGBContainer.Parent = PickerContainer

		local RGBLayout = Instance.new("UIListLayout")
		RGBLayout.FillDirection = Enum.FillDirection.Horizontal
		RGBLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		RGBLayout.Padding = UDim.new(0, 8)
		RGBLayout.Parent = RGBContainer

		-- Helper to create RGB TextBoxes
		local function createRGBInput(name: string, defaultVal: string): TextBox
			local Box = Instance.new("TextBox")
			Box.Name = name
			Box.Size = UDim2.new(0.333, -5, 1, 0)
			Box.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
			Box.BorderSizePixel = 0
			Box.Font = Enum.Font.GothamBold
			Box.Text = defaultVal
			Box.TextColor3 = Color3.fromRGB(255, 255, 255)
			Box.TextSize = 11
			Box.ZIndex = 103
			Box.Parent = RGBContainer

			local Corner = Instance.new("UICorner")
			Corner.CornerRadius = UDim.new(0, 6)
			Corner.Parent = Box

			local Stroke = Instance.new("UIStroke")
			Stroke.Thickness = 1
			Stroke.Color = Color3.fromRGB(35, 35, 40)
			Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
			Stroke.Parent = Box

		Box.Focused:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
		end)
		Box.FocusLost:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 40)}):Play()
		end)

		return Box
	end

	local RInput = createRGBInput("RInput", "0")
		local GInput = createRGBInput("GInput", "255")
		local BInput = createRGBInput("BInput", "0")

		-- Hex Input Box (Wide box at the bottom matching image)
		local HexInput = Instance.new("TextBox")
		HexInput.Name = "HexInput"
		HexInput.Size = UDim2.new(1, -30, 0, 36)
		HexInput.Position = UDim2.new(0, 15, 0, 310)
		HexInput.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
		HexInput.BorderSizePixel = 0
		HexInput.Font = Enum.Font.GothamBold
		HexInput.Text = "#00FF00"
		HexInput.TextColor3 = Color3.fromRGB(255, 255, 255)
		HexInput.TextSize = 11
		HexInput.ZIndex = 103
		HexInput.Parent = PickerContainer

		local HexCorner = Instance.new("UICorner")
		HexCorner.CornerRadius = UDim.new(0, 6)
		HexCorner.Parent = HexInput

		local HexStroke = Instance.new("UIStroke")
		HexStroke.Thickness = 1
		HexStroke.Color = Color3.fromRGB(35, 35, 40)
		HexStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		HexStroke.Parent = HexInput

		HexInput.Focused:Connect(function()
			TweenService:Create(HexStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
		end)
		HexInput.FocusLost:Connect(function()
			TweenService:Create(HexStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(35, 35, 40)}):Play()
		end)

		-- Color Picker State Variables
		local currentHue, currentSaturation, currentValue = 0, 1, 1

		local function updateColor(preventTextUpdate: boolean?)
			local finalColor = Color3.fromHSV(currentHue, currentSaturation, currentValue)
			ColorPreview.BackgroundColor3 = finalColor
			PickingColorSquare.BackgroundColor3 = finalColor -- Update real-time picking square
			
			-- Update Color Map Base Color to match current Hue
			ColorMap.BackgroundColor3 = Color3.fromHSV(currentHue, 1, 1)

			if not preventTextUpdate then
				local r = math.round(finalColor.R * 255)
				local g = math.round(finalColor.G * 255)
				local b = math.round(finalColor.B * 255)
				RInput.Text = tostring(r)
				GInput.Text = tostring(g)
				BInput.Text = tostring(b)
				HexInput.Text = string.format("#%02X%02X%02X", r, g, b)
			end

			task.spawn(callback, finalColor)
		end

		-- Initialize State from Default Color
		local function setPickerColor(color: Color3)
			local h, s, v = Color3.toHSV(color)
			currentHue, currentSaturation, currentValue = h, s, v
			Pin.Position = UDim2.new(s, 0, 1 - v, 0)
			HueThumb.Position = UDim2.new(h, 0, 0.5, 0)
			updateColor()
		end

		-- Dragging Logic for Color Map (Saturation & Value)
		local mapDragging = false
		local function updateMapColor(input)
			local mapSize = ColorMap.AbsoluteSize
			local mapPos = ColorMap.AbsolutePosition
			local relX = math.clamp((input.Position.X - mapPos.X) / mapSize.X, 0, 1)
			local relY = math.clamp((input.Position.Y - mapPos.Y) / mapSize.Y, 0, 1)

			Pin.Position = UDim2.new(relX, 0, relY, 0)
			currentSaturation = relX
			currentValue = 1 - relY

			updateColor()
		end

		-- Handle input on Color Map
		local function onMapInput(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				mapDragging = true
				updateMapColor(input)
			end
		end

		SatGradientFrame.InputBegan:Connect(onMapInput)
		ValGradientFrame.InputBegan:Connect(onMapInput)

		-- Dragging Logic for Hue Slider
		local hueDragging = false
		local function updateHue(input)
			local trackSize = HueTrack.AbsoluteSize
			local trackPos = HueTrack.AbsolutePosition
			local relX = math.clamp((input.Position.X - trackPos.X) / trackSize.X, 0, 1)

			HueThumb.Position = UDim2.new(relX, 0, 0.5, 0)
			currentHue = relX

			updateColor()
		end

		HueTrack.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				hueDragging = true
				updateHue(input)
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if mapDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateMapColor(input)
			elseif hueDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				updateHue(input)
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				mapDragging = false
				hueDragging = false
			end
		end)

		-- RGB Text Input Logic
		local function onRGBInput()
			local r = tonumber(RInput.Text) or 0
			local g = tonumber(GInput.Text) or 0
			local b = tonumber(BInput.Text) or 0
			r = math.clamp(r, 0, 255)
			g = math.clamp(g, 0, 255)
			b = math.clamp(b, 0, 255)

			local color = Color3.fromRGB(r, g, b)
			local h, s, v = Color3.toHSV(color)

			currentHue, currentSaturation, currentValue = h, s, v
			Pin.Position = UDim2.new(s, 0, 1 - v, 0)
			HueThumb.Position = UDim2.new(h, 0, 0.5, 0)

			updateColor(true)
			HexInput.Text = string.format("#%02X%02X%02X", r, g, b)
		end

		RInput.FocusLost:Connect(onRGBInput)
		GInput.FocusLost:Connect(onRGBInput)
		BInput.FocusLost:Connect(onRGBInput)

		-- Hex Text Input Logic
		HexInput.FocusLost:Connect(function()
			local hexText = HexInput.Text:gsub("#", "")
			if #hexText == 6 then
				local r = tonumber(hexText:sub(1, 2), 16)
				local g = tonumber(hexText:sub(3, 4), 16)
				local b = tonumber(hexText:sub(5, 6), 16)
				if r and g and b then
					local color = Color3.fromRGB(r, g, b)
					local h, s, v = Color3.toHSV(color)
					currentHue, currentSaturation, currentValue = h, s, v
					Pin.Position = UDim2.new(s, 0, 1 - v, 0)
					HueThumb.Position = UDim2.new(h, 0, 0.5, 0)
					updateColor(true)
					RInput.Text = tostring(r)
					GInput.Text = tostring(g)
					BInput.Text = tostring(b)
					return
				end
			end
			-- Fallback if invalid hex
			updateColor()
		end)

		-- Panel Close Logic
		local function closePanel()
			if SidePanel then
				TweenService:Create(SidePanel, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(1, 10, 0, 0)
				}):Play()
			end
			TweenService:Create(Scrim, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 1
			}):Play()
			task.delay(0.25, function()
				if activeCloseCallback == closePanel then
					Scrim.Visible = false
					activeCloseCallback = nil
				end
			end)
		end

		CloseBtn.MouseButton1Click:Connect(closePanel)

		CloseBtn.MouseEnter:Connect(function()
			TweenService:Create(CloseBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(219, 68, 68), TextColor3 = Color3.fromRGB(255, 255, 255) }):Play()
		end)
		CloseBtn.MouseLeave:Connect(function()
			TweenService:Create(CloseBtn, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40), TextColor3 = Color3.fromRGB(160, 160, 165) }):Play()
		end)

		-- Open Panel Event
		local function openPanel()
			for _, child in ipairs(MainGen3:GetChildren()) do
				if child:IsA("Frame") and string.match(child.Name, "_SidePanel$") and child ~= SidePanel then
					TweenService:Create(child, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Position = UDim2.new(1, 10, 0, 0)
					}):Play()
				end
			end

			-- Set the static current color square to match the active color before editing
			CurrentColorSquare.BackgroundColor3 = ColorPreview.BackgroundColor3

			Scrim.Visible = true
			TweenService:Create(Scrim, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundTransparency = 0.6
			}):Play()

			activeCloseCallback = closePanel

			TweenService:Create(SidePanel, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Position = UDim2.new(1, -260, 0, 0)
			}):Play()
		end

		HeaderBtn.MouseButton1Click:Connect(openPanel)
		ColorPreview.MouseButton1Click:Connect(openPanel)

		-- Initialize Default Color
		setPickerColor(defaultColor)
	end

	-- Hover Transitions
	HeaderBtn.MouseEnter:Connect(function()
		TweenService:Create(ColorPickerFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40) }):Play()
		TweenService:Create(FrameStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 75) }):Play()
	end)

	HeaderBtn.MouseLeave:Connect(function()
		TweenService:Create(ColorPickerFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(26, 26, 30) }):Play()
		TweenService:Create(FrameStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(50, 50, 55) }):Play()
	end)

	table.insert(tabObj.Elements, {Object = ColorPickerFrame, OriginalColumn = TargetColumn})
end

-- ==========================================
-- STANDALONE KEYBIND CREATION FUNCTION
-- ==========================================
local function CreateKeybind(tabObj: TabObjectType, keyConfig: any)
	keyConfig = keyConfig or {}
	local title = keyConfig.Title or "Keybind"
	local default = keyConfig.Default or Enum.KeyCode.Unknown
	local callback = keyConfig.Callback or function() end
	local icon = parseIcon(keyConfig.Icon) or Astral.Icons.keyboard

	local TargetColumn = GetTargetColumn(tabObj, keyConfig.Position)
	local isBinding = false
	local currentKey = default

	-- Uniform 64px Height with Stroke (FIXED: Upgraded from 50px to match other buttons)
	local KeyFrame = Instance.new("TextButton")
	KeyFrame.Name = title .. "_Keybind"
	KeyFrame.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
	KeyFrame.BorderSizePixel = 0
	KeyFrame.Size = UDim2.new(1, 0, 0, 64)
	KeyFrame.Text = ""
	KeyFrame.AutoButtonColor = false
	KeyFrame.LayoutOrder = layoutOrderMap[title] or 100
	KeyFrame.Parent = TargetColumn

	local KeyCorner = Instance.new("UICorner")
	KeyCorner.CornerRadius = UDim.new(0, 8)
	KeyCorner.Parent = KeyFrame

	local KeyStroke = Instance.new("UIStroke")
	KeyStroke.Thickness = 1
	KeyStroke.Color = Color3.fromRGB(50, 50, 55)
	KeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	KeyStroke.Parent = KeyFrame

	-- Optional Icon Container (FIXED: Upgraded Size & Layout to match other buttons)
	if icon then
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		IconContainer.BorderSizePixel = 0
		IconContainer.Position = UDim2.new(0, 10, 0.5, -21)
		IconContainer.Size = UDim2.new(0, 42, 0, 42)
		IconContainer.Parent = KeyFrame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local IconLabel = Instance.new("ImageLabel")
		IconLabel.Name = "Icon"
		IconLabel.BackgroundTransparency = 1
		IconLabel.AnchorPoint = Vector2.new(0.5, 0.5)
		IconLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
		IconLabel.Size = UDim2.new(0, 26, 0, 26) -- FIXED: Upgraded icon size to match other buttons
		IconLabel.Image = icon
		IconLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		IconLabel.ScaleType = Enum.ScaleType.Fit
		IconLabel.Parent = IconContainer
	end

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Position = icon and UDim2.new(0, 62, 0, 0) or UDim2.new(0, 14, 0, 0)
	TitleLabel.Size = icon and UDim2.new(0.6, -50, 1, 0) or UDim2.new(0.6, 0, 1, 0)
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = title
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.Parent = KeyFrame
	registerTranslation(TitleLabel, title)

	-- BindBox - Standardized 16px Right Margin (Styled like a premium keycap, FIXED: Made bigger)
	local BindBox = Instance.new("Frame")
	BindBox.Name = "BindBox"
	BindBox.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
	BindBox.BorderSizePixel = 0
	BindBox.Position = UDim2.new(1, -116, 0.5, -15)
	BindBox.Size = UDim2.new(0, 100, 0, 30)
	BindBox.Parent = KeyFrame

	local BindCorner = Instance.new("UICorner")
	BindCorner.CornerRadius = UDim.new(0, 6)
	BindCorner.Parent = BindBox

	-- FIXED: Added a highly visible, clean outline around the keybind box
	local BindStroke = Instance.new("UIStroke")
	BindStroke.Thickness = 1.5
	BindStroke.Color = Color3.fromRGB(100, 100, 105) -- Highly visible default border
	BindStroke.Parent = BindBox

	local BindLabel = Instance.new("TextLabel")
	BindLabel.Name = "BindLabel"
	BindLabel.BackgroundTransparency = 1
	BindLabel.Size = UDim2.new(1, 0, 1, 0)
	BindLabel.Font = Enum.Font.GothamBold
	BindLabel.Text = currentKey.Name
	BindLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	BindLabel.TextSize = 11
	BindLabel.Parent = BindBox

	KeyFrame.MouseButton1Click:Connect(function()
		isBinding = true
		BindLabel.Text = "..."
		TweenService:Create(BindStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(130, 130, 135)}):Play()
	end)

	UserInputService.InputBegan:Connect(function(input)
		if isBinding and input.UserInputType == Enum.UserInputType.Keyboard then
			isBinding = false
			currentKey = input.KeyCode
			BindLabel.Text = currentKey.Name
			TweenService:Create(BindStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(100, 100, 105)}):Play() -- Revert outline color
			task.spawn(callback, currentKey)
		elseif not isBinding and input.KeyCode == currentKey and currentKey ~= Enum.KeyCode.Unknown then
			task.spawn(callback, currentKey)
		end
	end)

	KeyFrame.MouseEnter:Connect(function()
		TweenService:Create(KeyFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(36, 36, 40) }):Play()
		TweenService:Create(KeyStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(70, 70, 75) }):Play()
		if not isBinding then
			TweenService:Create(BindStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(130, 130, 135) }):Play() -- Highlight outline on hover
		end
	end)

	KeyFrame.MouseLeave:Connect(function()
		TweenService:Create(KeyFrame, TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(26, 26, 30) }):Play()
		TweenService:Create(KeyStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(50, 50, 55) }):Play()
		if not isBinding then
			TweenService:Create(BindStroke, TweenInfo.new(0.15), { Color = Color3.fromRGB(100, 100, 105) }):Play() -- Revert outline on leave
		end
	end)

	table.insert(tabObj.Elements, {Object = KeyFrame, OriginalColumn = TargetColumn})
end

-- ==========================================
-- PAGE OBJECT CLASS (FOR TABS SUPPORT)
-- ==========================================
local PageObject = {}
PageObject.__index = PageObject

function PageObject.new(contentContainer: Frame, subPage: CanvasGroup): PageObjectType
	local self = setmetatable({}, PageObject)
	self.Container = contentContainer
	self.SubPage = subPage
	self.IsTabbed = false
	self.Tabs = {}
	self.TabButtons = {}
	self.ActiveTab = nil
	self.TabCardContainer = nil
	self.TabSubPageContainer = nil
	self.MainTitle = ""
	self._defaultTab = nil
	return (self :: any) :: PageObjectType
end

function PageObject:GoBackToTabCards()
	if not self.IsTabbed then return end
	
	local subHeader = self.SubPage:FindFirstChild("SubHeader")
	local subPageTitle = subHeader and subHeader:FindFirstChild("SubPageTitle") :: TextLabel?
	
	if subPageTitle then
		subPageTitle.Text = self.MainTitle or "SECTION"
	end
	
	if self.ActiveTab then
		local activeTabObj = self.Tabs[self.ActiveTab]
		if activeTabObj then
			activeTabObj.Container.Visible = false
		end
		self.ActiveTab = nil
	end
	
	if self.TabSubPageContainer then
		self.TabSubPageContainer.Visible = false
	end
	if self.TabCardContainer then
		self.TabCardContainer.Visible = true
		self.TabCardContainer.CanvasPosition = Vector2.new(0, 0)
	end
end

function PageObject:MakeTab(tabConfig: TabConfig): TabObjectType
	local tabCfg = tabConfig or {}
	local tabName = tabCfg.Name or "Tab"
	local tabIcon = resolveIcon(tabCfg.Icon)

	-- Initialize Tab Card Grid if this is the first tab
	if not self.IsTabbed then
		self.IsTabbed = true
		self.Container.Visible = false
		
		-- Create Tab Card Container (No Stroke) - Hidden Scrollbar
		local TabCardContainer = Instance.new("ScrollingFrame")
		TabCardContainer.Name = "TabCardContainer"
		TabCardContainer.Size = UDim2.new(1, 0, 1, -45)
		TabCardContainer.Position = UDim2.new(0, 0, 0, 45)
		TabCardContainer.BackgroundTransparency = 1
		TabCardContainer.BorderSizePixel = 0
		TabCardContainer.ScrollBarThickness = 0
		TabCardContainer.ClipsDescendants = true
		TabCardContainer.ZIndex = 2
		TabCardContainer.Parent = self.SubPage
		self.TabCardContainer = TabCardContainer

		local TabContainerPadding = Instance.new("UIPadding")
		TabContainerPadding.PaddingLeft = UDim.new(0, 12)
		TabContainerPadding.PaddingRight = UDim.new(0, 12)
		TabContainerPadding.PaddingTop = UDim.new(0, 12)
		TabContainerPadding.PaddingBottom = UDim.new(0, 12)
		TabContainerPadding.Parent = TabCardContainer

		local TabGridLayout = Instance.new("UIGridLayout")
		TabGridLayout.CellSize = UDim2.new(0, 224, 0, 116)
		TabGridLayout.CellPadding = UDim2.new(0, 16, 0, 16)
		TabGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TabGridLayout.Parent = TabCardContainer
		
		TabCardContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
		
		-- Bind dynamic grid resizing to prevent overlapping/wrapping bugs
		bindDynamicGrid(TabGridLayout, TabCardContainer)

		-- Create Tab SubPage Container
		local TabSubPageContainer = Instance.new("Frame")
		TabSubPageContainer.Name = "TabSubPageContainer"
		TabSubPageContainer.Size = UDim2.new(1, 0, 1, -45)
		TabSubPageContainer.Position = UDim2.new(0, 0, 0, 45)
		TabSubPageContainer.BackgroundTransparency = 1
		TabSubPageContainer.Visible = false
		TabSubPageContainer.ZIndex = 2
		TabSubPageContainer.Parent = self.SubPage
		self.TabSubPageContainer = TabSubPageContainer
	end

	-- Create Tab Card Button (With Stroke & High Contrast Background)
	local TabCard = Instance.new("TextButton")
	TabCard.Name = tabName
	TabCard.Text = ""
	TabCard.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	TabCard.BackgroundTransparency = 0
	TabCard.BorderSizePixel = 0
	TabCard.ZIndex = 3
	TabCard.Parent = self.TabCardContainer

	local TabCardCorner = Instance.new("UICorner")
	TabCardCorner.CornerRadius = UDim.new(0, 8)
	TabCardCorner.Parent = TabCard

	local TabCardStroke = Instance.new("UIStroke")
	TabCardStroke.Thickness = 1.5
	TabCardStroke.Color = Color3.fromRGB(45, 45, 50)
	TabCardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	TabCardStroke.Parent = TabCard

	local TabCardScale = Instance.new("UIScale")
	TabCardScale.Scale = 1
	TabCardScale.Parent = TabCard

	-- Premium Icon Container on the Left (Upgraded Size)
	local IconContainer = Instance.new("Frame")
	IconContainer.Name = "IconContainer"
	IconContainer.Size = UDim2.fromScale(0, 0) -- Set dynamically or keep static
	IconContainer.Size = UDim2.fromOffset(52, 52)
	IconContainer.Position = UDim2.new(0, 12, 0.5, -26)
	IconContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
	IconContainer.BorderSizePixel = 0
	IconContainer.ZIndex = 3
	IconContainer.Parent = TabCard

	local IconCorner = Instance.new("UICorner")
	IconCorner.CornerRadius = UDim.new(0, 6)
	IconCorner.Parent = IconContainer

	local IconStroke = Instance.new("UIStroke")
	IconStroke.Thickness = 1.5
	IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
	IconStroke.Transparency = 0.3
	IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	IconStroke.Parent = IconContainer

	local Icon = Instance.new("ImageLabel")
	Icon.Name = "Icon"
	Icon.Size = UDim2.fromOffset(34, 34)
	Icon.AnchorPoint = Vector2.new(0.5, 0.5)
	Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
	Icon.BackgroundTransparency = 1
	Icon.Image = tabIcon or Astral.Icons.Icon1
	Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
	Icon.ZIndex = 3
	Icon.Parent = IconContainer

	-- Text Container on the Right
	local TextContainer = Instance.new("Frame")
	TextContainer.Name = "TextContainer"
	TextContainer.Position = UDim2.new(0, 76, 0.5, -44)
	TextContainer.Size = UDim2.new(1, -88, 0, 88)
	TextContainer.BackgroundTransparency = 1
	TextContainer.ZIndex = 3
	TextContainer.Parent = TabCard

	local TextLayout = Instance.new("UIListLayout")
	TextLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TextLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	TextLayout.Padding = UDim.new(0, 2)
	TextLayout.Parent = TextContainer

	-- Category Label Frame inside TextContainer (TABS Indicator Badge)
	local CategoryLabelFrame = Instance.new("Frame")
	CategoryLabelFrame.Name = "CategoryLabelFrame"
	CategoryLabelFrame.Size = UDim2.new(0, 42, 0, 16)
	CategoryLabelFrame.BackgroundColor3 = currentAccentColor
	CategoryLabelFrame.BorderSizePixel = 0
	CategoryLabelFrame.ZIndex = 3
	CategoryLabelFrame.LayoutOrder = 1
	CategoryLabelFrame.Parent = TextContainer

	local CategoryLabelCorner = Instance.new("UICorner")
	CategoryLabelCorner.CornerRadius = UDim.new(0, 4)
	CategoryLabelCorner.Parent = CategoryLabelFrame

	local CategoryLabel = Instance.new("TextLabel")
	CategoryLabel.Name = "CategoryLabel"
	CategoryLabel.Size = UDim2.new(1, 0, 1, 0)
	CategoryLabel.BackgroundTransparency = 1
	CategoryLabel.Font = Enum.Font.GothamBold
	CategoryLabel.Text = "TAB"
	CategoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	CategoryLabel.TextSize = 8
	CategoryLabel.TextXAlignment = Enum.TextXAlignment.Center
	CategoryLabel.TextYAlignment = Enum.TextYAlignment.Center
	CategoryLabel.ZIndex = 4
	CategoryLabel.Parent = CategoryLabelFrame

	registerThemeUpdate(function(color)
		CategoryLabelFrame.BackgroundColor3 = color
	end)

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "Title"
	TitleLabel.Size = UDim2.new(1, 0, 0, 16)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.Text = tabName:upper()
	TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	TitleLabel.TextSize = 11
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.TextWrapped = true
	TitleLabel.ZIndex = 3
	TitleLabel.LayoutOrder = 2
	TitleLabel.Parent = TextContainer
	registerTranslation(TitleLabel, tabName, function(t) return t:upper() end)

	-- Added description under the title
	local DescLabel = Instance.new("TextLabel")
	DescLabel.Name = "Description"
	DescLabel.Size = UDim2.new(1, 0, 0, 24)
	DescLabel.BackgroundTransparency = 1
	DescLabel.Font = Enum.Font.Gotham
	DescLabel.Text = tabCfg.Description or "Configure settings inside this tab"
	DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
	DescLabel.TextSize = 9
	DescLabel.TextXAlignment = Enum.TextXAlignment.Left
	DescLabel.TextYAlignment = Enum.TextYAlignment.Top
	DescLabel.TextWrapped = true
	DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
	DescLabel.ZIndex = 3
	DescLabel.LayoutOrder = 3
	DescLabel.Parent = TextContainer

	-- Create Tab Content Container (ScrollingFrame) - Hidden Scrollbar
	local TabContent = Instance.new("ScrollingFrame")
	TabContent.Name = tabName .. "TabContent"
	TabContent.Size = UDim2.new(1, 0, 1, 0)
	TabContent.Position = UDim2.new(0, 0, 0, 0)
	TabContent.BackgroundTransparency = 1
	TabContent.BorderSizePixel = 0
	TabContent.ScrollBarThickness = 0
	TabContent.ClipsDescendants = true
	TabContent.ZIndex = 5
	TabContent.Visible = false
	TabContent.Parent = self.TabSubPageContainer
	
	TabContent.AutomaticCanvasSize = Enum.AutomaticSize.Y

	-- ColumnsContainer to prevent right-side buttons from overlapping or clipping the border
	local ColumnsContainer = Instance.new("Frame")
	ColumnsContainer.Name = "ColumnsContainer"
	ColumnsContainer.Size = UDim2.new(1, -24, 0, 0)
	ColumnsContainer.Position = UDim2.new(0, 12, 0, 12)
	ColumnsContainer.BackgroundTransparency = 1
	ColumnsContainer.AutomaticSize = Enum.AutomaticSize.Y
	ColumnsContainer.Parent = TabContent

	-- Create Left Column
	local LeftColumn = Instance.new("Frame")
	LeftColumn.Name = "LeftColumn"
	LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
	LeftColumn.Position = UDim2.new(0, 0, 0, 0)
	LeftColumn.BackgroundTransparency = 1
	LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
	LeftColumn.Parent = ColumnsContainer

	local LeftLayout = Instance.new("UIListLayout")
	LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
	LeftLayout.Padding = UDim.new(0, 10)
	LeftLayout.Parent = LeftColumn

	-- Create Right Column
	local RightColumn = Instance.new("Frame")
	RightColumn.Name = "RightColumn"
	RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
	RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
	RightColumn.BackgroundTransparency = 1
	RightColumn.AutomaticSize = Enum.AutomaticSize.Y
	RightColumn.Parent = ColumnsContainer

	local RightLayout = Instance.new("UIListLayout")
	RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
	RightLayout.Padding = UDim.new(0, 10)
	RightLayout.Parent = RightColumn

	-- Tab Card Click Event
	TabCard.MouseButton1Click:Connect(function()
		-- Click Animation
		TabCardScale.Scale = 0.92
		TweenService:Create(TabCardScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1.03
		}):Play()

		if self.TabCardContainer then
			self.TabCardContainer.Visible = false
		end
		if self.TabSubPageContainer then
			self.TabSubPageContainer.Visible = true
		end
		
		for name, tabObj in pairs(self.Tabs) do
			tabObj.Container.Visible = (name == tabName)
		end
		
		self.ActiveTab = tabName
		
		local subHeader = self.SubPage:FindFirstChild("SubHeader")
		local subPageTitle = subHeader and subHeader:FindFirstChild("SubPageTitle") :: TextLabel?

		if subPageTitle then
			subPageTitle.Text = (self.MainTitle or "SECTION") .. " > " .. tabName:upper()
		end

		-- Split Slide-In Animation for Tab Columns
		local activeTabObj = self.Tabs[tabName]
		if activeTabObj then
			activeTabObj.LeftColumn.Position = UDim2.new(0, -20, 0, 0)
			activeTabObj.RightColumn.Position = UDim2.new(0.5, 26, 0, 0)
			
			TweenService:Create(activeTabObj.LeftColumn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 0, 0)
			}):Play()
			TweenService:Create(activeTabObj.RightColumn, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0.5, 6, 0, 0)
			}):Play()
		end
	end)

	-- Hover Transitions
	TabCard.MouseEnter:Connect(function()
		TweenService:Create(TabCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(30, 30, 36)
		}):Play()
		TweenService:Create(TabCardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(70, 70, 75)
		}):Play()
		TweenService:Create(TabCardScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Scale = 1.03
		}):Play()
	end)

	TabCard.MouseLeave:Connect(function()
		TweenService:Create(TabCard, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		}):Play()
		TweenService:Create(TabCardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Color = Color3.fromRGB(45, 45, 50)
		}):Play()
		TweenService:Create(TabCardScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Scale = 1
		}):Play()
	end)

	-- Construct Tab Object
	local TabObj: TabObjectType = {
		Container = TabContent,
		LeftColumn = LeftColumn,
		RightColumn = RightColumn,
		Elements = {},
		AddToggle = function(tabSelf, toggleConfig)
			return CreateToggle(tabSelf, toggleConfig)
		end,
		AddButton = function(tabSelf, buttonConfig)
			CreateButton(tabSelf, buttonConfig)
		end,
		AddLabel = function(tabSelf, labelConfig)
			CreateLabel(tabSelf, labelConfig)
		end,
		AddParagraph = function(tabSelf, paragraphConfig)
			CreateParagraph(tabSelf, paragraphConfig)
		end,
		AddTick = function(tabSelf, tickConfig)
			return CreateTick(tabSelf, tickConfig)
		end,
		AddSlider = function(tabSelf, sliderConfig)
			return CreateSlider(tabSelf, sliderConfig)
		end,
		AddTextbox = function(tabSelf, textConfig)
			CreateTextbox(tabSelf, textConfig)
		end,
		AddSelector = function(tabSelf, selConfig)
			return CreateSelector(tabSelf, selConfig)
		end,
		AddKeybind = function(tabSelf, keyConfig)
			CreateKeybind(tabSelf, keyConfig)
		end,
		AddColorPicker = function(tabSelf, cpConfig)
			CreateColorPicker(tabSelf, cpConfig)
		end
	}

	self.Tabs[tabName] = TabObj
	self.TabButtons[tabName] = TabCard

	table.insert(registeredTabs, TabObj)

	return TabObj
end

function PageObject:_EnsureTab(): TabObjectType
	if not self._defaultTab then
		self._defaultTab = self:MakeTab({
			Name = "Main",
			Icon = "Icon1",
			Description = "Main content"
		})
	end
	return self._defaultTab
end

function PageObject:AddToggle(toggleConfig: ToggleConfig): ToggleController
	return self:_EnsureTab():AddToggle(toggleConfig)
end

function PageObject:AddButton(buttonConfig: ButtonConfig)
	self:_EnsureTab():AddButton(buttonConfig)
end

function PageObject:AddLabel(labelConfig: LabelConfig)
	self:_EnsureTab():AddLabel(labelConfig)
end

function PageObject:AddParagraph(paragraphConfig: ParagraphConfig)
	self:_EnsureTab():AddParagraph(paragraphConfig)
end

function PageObject:AddTick(tickConfig: any): any
	return self:_EnsureTab():AddTick(tickConfig)
end

function PageObject:AddSlider(sliderConfig: any): any
	return self:_EnsureTab():AddSlider(sliderConfig)
end

function PageObject:AddTextbox(textConfig: TextboxConfig)
	self:_EnsureTab():AddTextbox(textConfig)
end

function PageObject:AddSelector(selConfig: SelectorConfig): SelectorController
	return self:_EnsureTab():AddSelector(selConfig)
end

function PageObject:AddKeybind(keyConfig: any)
	self:_EnsureTab():AddKeybind(keyConfig)
end

function PageObject:AddColorPicker(cpConfig: ColorPickerConfig)
	self:_EnsureTab():AddColorPicker(cpConfig)
end

-- ==========================================
-- IMAGE LOADER HELPERS
-- ==========================================
local function GetIconOnWeb(url: string)
	if not url or url == "" then return url end
	local ext = url:match("%.(%w+)$")
	if ext then ext = ext:lower() else ext = "png" end
	local safe = url:gsub("https?://", ""):gsub("[^%w%-_%.]", "_")
	local file = safe .. "." .. ext

	-- Try cache first
	if isfile and isfile(file) and getcustomasset then
		local ok, asset = pcall(getcustomasset, file)
		if ok and asset and asset ~= "" then return asset end
	end

	-- Download using any available method
	local data = nil
	pcall(function()
		if syn and syn.request then
			local resp = syn.request({Url = url, Method = "GET"})
			if resp and resp.StatusCode == 200 then data = resp.Body end
		elseif http_request then
			local resp = http_request({Url = url, Method = "GET"})
			if resp and resp.StatusCode == 200 then data = resp.Body end
		elseif http and http.request then
			local ok2, resp = pcall(http.request, "GET", url)
			if ok2 and resp then data = resp end
		else
			data = game:HttpGet(url)
		end
	end)
	if not data then
		pcall(function() data = game:HttpGet(url) end)
	end

	-- Save to cache file and get asset path
	if data and #data > 0 and writefile then
		pcall(function() writefile(file, data) end)
		if isfile and isfile(file) and getcustomasset then
			local ok, asset = pcall(getcustomasset, file)
			if ok and asset and asset ~= "" then return asset end
		end
	end

	return url
end

-- ==========================================
-- WINDOW CREATION FUNCTION
-- ==========================================
function Astral:CreateWindow(config: WindowConfig?): WindowType
	local cfg = config or {}
	
	local badgeText = cfg.badge or _L("Window.Badge")
	local badgeColor = currentAccentColor

	if cfg.badgecolor then
		local bc = cfg.badgecolor
		if type(bc) == "string" then
			if bc:lower() == "blue" then
				badgeColor = Color3.fromRGB(0, 122, 255)
			elseif bc:lower() == "red" then
				badgeColor = Color3.fromRGB(255, 75, 75)
			elseif bc:lower() == "green" then
				badgeColor = Color3.fromRGB(75, 255, 75)
			end
		elseif typeof(bc) == "Color3" then
			badgeColor = bc
		end
	end

	-- ScreenGui Container
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "MainGen3Gui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = PlayerGui

	-- Viewport-Based Resizing Engine
	local refSize = cfg.Size or UDim2.fromOffset(760, 510)
	local refW, refH = refSize.X.Offset, refSize.Y.Offset

	local function updateWindowSize()
		local cam = workspace.CurrentCamera
		if not cam then return end
		local vps = cam.ViewportSize
		if vps.X < 1 or vps.Y < 1 then return end
		local sx, sy = vps.X / refW, vps.Y / refH
		local scale = math.min(sx, sy)
		local pad = math.min(16, vps.X * 0.02)
		if refW * scale > vps.X - pad * 2 then
			scale = (vps.X - pad * 2) / refW
		end
		if refH * scale > vps.Y - pad * 2 then
			scale = math.min(scale, (vps.Y - pad * 2) / refH)
		end
		local fw, fh = refW * scale, refH * scale
		MainGen3.Size = UDim2.new(0, fw, 0, fh)
		MainGen3.Position = UDim2.new(0.5, -fw / 2, 0.5, -fh / 2)
	end

	-- Main Frame (MainGen3) - Premium Dark Theme
	local MainGen3 = Instance.new("Frame")
	MainGen3.Name = "MainGen3"
	MainGen3.Size = refSize
	MainGen3.Position = UDim2.new(0.5, -refW / 2, 0.5, -refH / 2)
	MainGen3.BackgroundColor3 = Color3.fromRGB(12, 12, 14)
	MainGen3.BorderSizePixel = 0
	MainGen3.Active = true
	MainGen3.ZIndex = 1
	MainGen3.ClipsDescendants = true
	MainGen3.Parent = ScreenGui

	task.spawn(function()
		local cam = workspace.CurrentCamera
		if cam then
			updateWindowSize()
			cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowSize)
		else
			local conn
			conn = workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
				cam = workspace.CurrentCamera
				if cam then
					conn:Disconnect()
					updateWindowSize()
					cam:GetPropertyChangedSignal("ViewportSize"):Connect(updateWindowSize)
				end
			end)
		end
	end)

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0, 10)
	UICorner.Parent = MainGen3

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Thickness = 1.5
	MainStroke.Color = Color3.fromRGB(40, 40, 45)
	MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MainStroke.Parent = MainGen3

	-- Shared Scrim Overlay for Selector Side Panels
	Scrim = Instance.new("TextButton")
	Scrim.Name = "SelectorScrim"
	Scrim.Size = UDim2.new(1, 0, 1, 0)
	Scrim.Position = UDim2.new(0, 0, 0, 0)
	Scrim.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	Scrim.BackgroundTransparency = 1
	Scrim.Text = ""
	Scrim.AutoButtonColor = false
	Scrim.ZIndex = 98
	Scrim.Active = true
	Scrim.Visible = false
	Scrim.Parent = MainGen3

	Scrim.MouseButton1Click:Connect(function()
		if activeCloseCallback then
			activeCloseCallback()
		end
	end)

	-- Background Image & Gradient
	local BackgroundImage = Instance.new("ImageLabel")
	BackgroundImage.Name = "BackgroundImage"
	BackgroundImage.Size = UDim2.fromScale(1, 1)
	BackgroundImage.Position = UDim2.fromScale(0, 0)
	BackgroundImage.BackgroundTransparency = 1
	-- Local custom background (astral_bg.jpg in executor workspace) wins over default
	local defaultBg = cfg.BackgroundImage or Astral.Icons.map_background
	local defaultTint = Color3.fromRGB(15, 15, 15)
	pcall(function()
		if getcustomasset and isfile and isfile("astral_bg.jpg") then
			local a = getcustomasset("astral_bg.jpg")
			if a and a ~= "" then
				defaultBg = a
				defaultTint = Color3.fromRGB(255, 255, 255)
			end
		end
	end)
	BackgroundImage.Image = defaultBg
	BackgroundImage.ScaleType = Enum.ScaleType.Crop
	BackgroundImage.ImageColor3 = defaultTint
	BackgroundImage.ZIndex = 1
	BackgroundImage.Parent = MainGen3

	local BackgroundCorner = Instance.new("UICorner")
	BackgroundCorner.CornerRadius = UDim.new(0, 10)
	BackgroundCorner.Parent = BackgroundImage

	local BackgroundGradient = Instance.new("UIGradient")
	BackgroundGradient.Rotation = 45
	BackgroundGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 120))
	})
	BackgroundGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.35),
		NumberSequenceKeypoint.new(1, 0.92)
	})
	BackgroundGradient.Parent = BackgroundImage

	-- Notification Container (Bottom-Right of Screen)
	local notifW = cfg.NotifySize or math.min(300, math.floor((workspace.CurrentCamera and workspace.CurrentCamera.ViewportSize.X or 760) * 0.3))

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

	-- Floating Action Buttons (Top-Left, outside UI)
	local floatBtnPad = 15
	local floatBtnSize = 64

	local selectionOverride = Instance.new("Frame")
	selectionOverride.BackgroundTransparency = 1
	selectionOverride.Size = UDim2.fromScale(1, 1)

	local function makeFloatBtn(cfg)
		local size = cfg.size or floatBtnSize
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(size, size)
		btn.Position = UDim2.new(0, floatBtnPad, 0, cfg.yOff)
		btn.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
		btn.BorderSizePixel = 0
		btn.Text = ""
		btn.AutoButtonColor = false
		btn.SelectionImageObject = selectionOverride
		btn.ZIndex = 300
		btn.Parent = ScreenGui

		local cr = Instance.new("UICorner")
		cr.CornerRadius = UDim.new(1, 0)
		cr.Parent = btn

		local grad = Instance.new("UIGradient")
		grad.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 25)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 10))
		})
		grad.Rotation = 45
		grad.Parent = btn

		local shadow = Instance.new("ImageLabel")
		shadow.Name = "Shadow"
		shadow.AnchorPoint = Vector2.new(0.5, 0.5)
		shadow.Position = UDim2.new(0.5, 0, 0.5, 4)
		shadow.Size = UDim2.new(1, 16, 1, 16)
		shadow.BackgroundTransparency = 1
		shadow.Image = "rbxassetid://5154501493"
		shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
		shadow.ImageTransparency = 0.6
		shadow.ZIndex = 299
		shadow.Parent = btn

		local st = Instance.new("UIStroke")
		st.Thickness = 3
		st.Color = Color3.fromRGB(0, 153, 235)
		st.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		st.Parent = btn

		cfg.content.Parent = btn
		return btn, st
	end

	local function makeDraggable(btn, onClick)
		local state = {}

		btn.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
			state.active = true
			state.moved = false
			state.startPos = input.Position
			state.btnStart = btn.Position

			TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(floatBtnSize - 6, floatBtnSize - 6)
			}):Play()

			local connection
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					state.active = false
					connection:Disconnect()

					TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
						Size = UDim2.fromOffset(floatBtnSize, floatBtnSize)
					}):Play()

					if not state.moved and onClick then
						onClick()
					end
				end
			end)
		end)

		UserInputService.InputChanged:Connect(function(input)
			if state.active and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - state.startPos
				if math.abs(delta.X) > 5 or math.abs(delta.Y) > 5 then
					state.moved = true
				end
				btn.Position = UDim2.new(
					state.btnStart.X.Scale, state.btnStart.X.Offset + delta.X,
					state.btnStart.Y.Scale, state.btnStart.Y.Offset + delta.Y
				)
			end
		end)

		btn.MouseEnter:Connect(function()
			if not state.active then
				TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromOffset(floatBtnSize + 4, floatBtnSize + 4)
				}):Play()
			end
		end)

		btn.MouseLeave:Connect(function()
			if not state.active then
				TweenService:Create(btn, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Size = UDim2.fromOffset(floatBtnSize, floatBtnSize)
				}):Play()
			end
		end)
	end

	local function popAnim(btn)
		local s = floatBtnSize
		TweenService:Create(btn, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(s + 8, s + 8)
		}):Play()
		task.delay(0.1, function()
			TweenService:Create(btn, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(s, s)
			}):Play()
		end)
	end

	-- 1. Icon Button (toggles UI visibility on clean click, drag does nothing)
	do
		local icon = Instance.new("ImageLabel")
		icon.Size = UDim2.fromScale(1, 1)
		icon.AnchorPoint = Vector2.new(0.5, 0.5)
		icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		icon.BackgroundTransparency = 1
		icon.Image = "rbxassetid://106987676739927"
		icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		icon.ScaleType = Enum.ScaleType.Fit
		icon.ZIndex = 300

		local iconCr = Instance.new("UICorner")
		iconCr.CornerRadius = UDim.new(1, 0)
		iconCr.Parent = icon

		local btn, stroke = makeFloatBtn({content = icon, yOff = floatBtnPad, size = floatBtnSize})
		local hidden = false
		makeDraggable(btn, function()
			hidden = not hidden
			MainGen3.Visible = not hidden
			popAnim(btn)
			TweenService:Create(stroke, TweenInfo.new(0.2), {
				Color = hidden and Color3.fromRGB(60, 60, 65) or Color3.fromRGB(0, 153, 235)
			}):Play()
		end)
	end

	-- 2. Stop Tween Button (Matching premium style)
	do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.fromScale(1, 1)
		lbl.AnchorPoint = Vector2.new(0.5, 0.5)
		lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
		lbl.BackgroundTransparency = 1
		lbl.Font = Enum.Font.GothamBold
		lbl.Text = _L("Buttons.StopTween")
		lbl.TextWrapped = true
		lbl.LineHeight = 0.95
		lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		lbl.TextSize = 11
		lbl.TextXAlignment = Enum.TextXAlignment.Center
		lbl.TextYAlignment = Enum.TextYAlignment.Center
		lbl.ZIndex = 300

		local txtStroke = Instance.new("UIStroke")
		txtStroke.Thickness = 1.5
		txtStroke.Color = Color3.fromRGB(0, 0, 0)
		txtStroke.Transparency = 0.5
		txtStroke.Parent = lbl

		local btn, stroke = makeFloatBtn({content = lbl, yOff = floatBtnPad + floatBtnSize + 15, size = floatBtnSize})
		makeDraggable(btn, function()
			popAnim(btn)
			for _, t in ipairs(TweenService:GetChildren()) do
				if t:IsA("Tween") then
					pcall(function() t:Cancel() end)
				end
			end
		end)
	end

	-- Header Frame (Drag Handle)
	local Header = Instance.new("Frame")
	Header.Name = "Header"
	Header.Size = UDim2.new(1, 0, 0, 50)
	Header.BackgroundTransparency = 1
	Header.ZIndex = 3
	Header.Parent = MainGen3

	-- Header Layout Container
	local HeaderLayoutContainer = Instance.new("Frame")
	HeaderLayoutContainer.Name = "HeaderLayoutContainer"
	HeaderLayoutContainer.Position = UDim2.new(0, 15, 0, 0)
	HeaderLayoutContainer.Size = UDim2.new(1, -360, 1, 0)
	HeaderLayoutContainer.BackgroundTransparency = 1
	HeaderLayoutContainer.ZIndex = 3
	HeaderLayoutContainer.Parent = Header

	local HeaderLayout = Instance.new("UIListLayout")
	HeaderLayout.FillDirection = Enum.FillDirection.Horizontal
	HeaderLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	HeaderLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	HeaderLayout.SortOrder = Enum.SortOrder.LayoutOrder
	HeaderLayout.Padding = UDim.new(0, 10)
	HeaderLayout.Parent = HeaderLayoutContainer

	-- Title
	local Title = Instance.new("TextLabel")
	Title.Name = "Title"
	Title.Text = cfg.Title or _L("Window.Title")
	Title.Font = Enum.Font.GothamBold
	Title.TextSize = 20
	Title.TextColor3 = Color3.fromRGB(255, 255, 255)
	Title.Size = UDim2.new(0, 0, 1, 0)
	Title.AutomaticSize = Enum.AutomaticSize.X
	Title.BackgroundTransparency = 1
	Title.LayoutOrder = 1
	Title.ZIndex = 3
	Title.TextTruncate = Enum.TextTruncate.AtEnd
	Title.Parent = HeaderLayoutContainer

	-- SubTitle
	if cfg.SubTitle then
		local SubTitle = Instance.new("TextLabel")
		SubTitle.Name = "SubTitle"
		SubTitle.Text = cfg.SubTitle
		SubTitle.Font = Enum.Font.Gotham
		SubTitle.TextSize = 12
		SubTitle.TextColor3 = Color3.fromRGB(160, 160, 165)
		SubTitle.Size = UDim2.new(0, 0, 1, 0)
		SubTitle.AutomaticSize = Enum.AutomaticSize.X
		SubTitle.BackgroundTransparency = 1
		SubTitle.LayoutOrder = 2
		SubTitle.ZIndex = 3
		SubTitle.TextTruncate = Enum.TextTruncate.AtEnd
		SubTitle.Parent = HeaderLayoutContainer
	end

	-- Premium Badge
	local PremiumBadge = Instance.new("Frame")
	PremiumBadge.Name = "PremiumBadge"
	PremiumBadge.BackgroundColor3 = badgeColor
	PremiumBadge.BorderSizePixel = 0
	PremiumBadge.Size = UDim2.new(0, 0, 0, 20)
	PremiumBadge.AutomaticSize = Enum.AutomaticSize.X
	PremiumBadge.LayoutOrder = 3
	PremiumBadge.ZIndex = 3
	PremiumBadge.Parent = HeaderLayoutContainer

	local PremiumCorner = Instance.new("UICorner")
	PremiumCorner.CornerRadius = UDim.new(0, 6)
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
	PremiumLabel.ZIndex = 3
	PremiumLabel.Parent = PremiumBadge

	-- Navigation Buttons Container (No Stroke)
	local NavContainer = Instance.new("Frame")
	NavContainer.Name = "NavContainer"
	NavContainer.AnchorPoint = Vector2.new(1, 0.5)
	NavContainer.Position = UDim2.new(1, -15, 0.5, 0)
	NavContainer.Size = UDim2.new(0, 0, 0, 44)
	NavContainer.AutomaticSize = Enum.AutomaticSize.X
	NavContainer.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
	NavContainer.BackgroundTransparency = 0
	NavContainer.BorderSizePixel = 0
	NavContainer.ZIndex = 3
	NavContainer.Parent = Header

	local NavCorner = Instance.new("UICorner")
	NavCorner.CornerRadius = UDim.new(0, 10)
	NavCorner.Parent = NavContainer

	local NavStroke = Instance.new("UIStroke")
	NavStroke.Thickness = 1
	NavStroke.Color = Color3.fromRGB(45, 45, 50)
	NavStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	NavStroke.Parent = NavContainer

	local NavPadding = Instance.new("UIPadding")
	NavPadding.PaddingLeft = UDim.new(0, 8)
	NavPadding.PaddingRight = UDim.new(0, 8)
	NavPadding.PaddingTop = UDim.new(0, 6)
	NavPadding.PaddingBottom = UDim.new(0, 6)
	NavPadding.Parent = NavContainer

	local NavLayout = Instance.new("UIListLayout")
	NavLayout.FillDirection = Enum.FillDirection.Horizontal
	NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	NavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	NavLayout.Padding = UDim.new(0, 6)
	NavLayout.Parent = NavContainer

	-- Subtle Divider Line
	local Divider = Instance.new("Frame")
	Divider.Name = "Divider"
	Divider.Position = UDim2.new(0, 15, 0, 50)
	Divider.Size = UDim2.new(1, -30, 0, 1)
	Divider.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
	Divider.BorderSizePixel = 0
	Divider.ZIndex = 2
	Divider.Parent = MainGen3

	-- Pages Container
	local PagesContainer = Instance.new("Frame")
	PagesContainer.Name = "PagesContainer"
	PagesContainer.Position = UDim2.new(0, 15, 0, 60)
	PagesContainer.Size = UDim2.new(1, -30, 1, -75)
	PagesContainer.BackgroundTransparency = 1
	PagesContainer.ZIndex = 2
	PagesContainer.Parent = MainGen3

	-- Navigation Logic Setup
	local pages: {[string]: CanvasGroup} = {}
	local navButtons: {[string]: TextButton} = {}

	local function switchPage(targetName: string)
		for name, page in pairs(pages) do
			local isTarget = (name == targetName)
			local btn = navButtons[name]
			local label = if btn then btn:FindFirstChild("Label") :: TextLabel? else nil
			local navIcon = if btn then btn:FindFirstChild("NavIcon") :: ImageLabel? else nil
			local activeStroke = if btn then btn:FindFirstChild("ActiveStroke") :: UIStroke? else nil

			if isTarget then
				page.Visible = true
				page.GroupTransparency = 0
				
				local pageScale = page:FindFirstChildOfClass("UIScale")
				if pageScale then
					pageScale.Scale = 0.98
					TweenService:Create(pageScale, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Scale = 1
					}):Play()
				end
				
				if btn then
					TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 0,
						BackgroundColor3 = Color3.fromRGB(36, 36, 40)
					}):Play()
				end
				if activeStroke then
					activeStroke.Enabled = true
				end
				if label then
					TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextColor3 = Color3.fromRGB(255, 255, 255)
					}):Play()
				end
				if navIcon then
					TweenService:Create(navIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageColor3 = Color3.fromRGB(255, 255, 255)
					}):Play()
				end
			else
				page.Visible = false
				page.GroupTransparency = 1
				if btn then
					TweenService:Create(btn, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						BackgroundTransparency = 1
					}):Play()
				end
				if activeStroke then
					activeStroke.Enabled = false
				end
				if label then
					TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						TextColor3 = Color3.fromRGB(160, 160, 165)
					}):Play()
				end
				if navIcon then
					TweenService:Create(navIcon, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						ImageColor3 = Color3.fromRGB(160, 160, 165)
					}):Play()
				end
			end

			if isTarget then
				local cardContainer = page:FindFirstChild("CardContainer") :: ScrollingFrame?
				local subPageContainer = page:FindFirstChild("SubPageContainer") :: Frame?
				if cardContainer and subPageContainer then
					cardContainer.Visible = true
					subPageContainer.Visible = false
				end
			end
		end
	end

	local function createNavButton(name: string, iconAsset: string?, isDefault: boolean)
		local Button = Instance.new("TextButton")
		Button.Name = name .. "Btn"
		Button.Text = ""
		Button.Size = UDim2.new(0, 0, 0, 32)
		Button.AutomaticSize = Enum.AutomaticSize.X
		Button.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		Button.BackgroundTransparency = isDefault and 0 or 1
		Button.BorderSizePixel = 0
		Button.ZIndex = 4
		Button.Parent = NavContainer

		local BtnCorner = Instance.new("UICorner")
		BtnCorner.CornerRadius = UDim.new(0, 8)
		BtnCorner.Parent = Button

		local BtnPadding = Instance.new("UIPadding")
		BtnPadding.PaddingLeft = UDim.new(0, 14)
		BtnPadding.PaddingRight = UDim.new(0, 14)
		BtnPadding.Parent = Button

		local BtnLayout = Instance.new("UIListLayout")
		BtnLayout.FillDirection = Enum.FillDirection.Horizontal
		BtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		BtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		BtnLayout.Padding = UDim.new(0, 8)
		BtnLayout.Parent = Button

		-- Section icon (was ignored before)
		local NavIcon = Instance.new("ImageLabel")
		NavIcon.Name = "NavIcon"
		NavIcon.Size = UDim2.fromOffset(16, 16)
		NavIcon.BackgroundTransparency = 1
		NavIcon.Image = iconAsset or Astral.Icons.Icon1
		NavIcon.ImageColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
		NavIcon.ScaleType = Enum.ScaleType.Fit
		NavIcon.ZIndex = 4
		NavIcon.LayoutOrder = 1
		NavIcon.Parent = Button

		local Label = Instance.new("TextLabel")
		Label.Name = "Label"
		Label.Size = UDim2.fromScale(0, 1)
		Label.AutomaticSize = Enum.AutomaticSize.X
		Label.BackgroundTransparency = 1
		Label.Font = Enum.Font.GothamBold
		Label.Text = name
		Label.TextColor3 = isDefault and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 165)
		Label.TextSize = 12
		Label.ZIndex = 4
		Label.LayoutOrder = 2
		Label.Parent = Button
		registerTranslation(Label, name)

		-- Active indicator (accent stroke, follows theme - a Frame would break the auto-layout)
		local ActiveStroke = Instance.new("UIStroke")
		ActiveStroke.Name = "ActiveStroke"
		ActiveStroke.Thickness = 1.5
		ActiveStroke.Color = currentAccentColor
		ActiveStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		ActiveStroke.Enabled = isDefault
		ActiveStroke.Parent = Button

		registerThemeUpdate(function(color)
			ActiveStroke.Color = color
		end)

		-- Hover Transitions
		Button.MouseEnter:Connect(function()
			local page = pages[name]
			if page and not page.Visible then
				TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 0.4,
					BackgroundColor3 = Color3.fromRGB(36, 36, 40)
				}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = Color3.fromRGB(220, 225, 235)
				}):Play()
				TweenService:Create(NavIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = Color3.fromRGB(220, 225, 235)
				}):Play()
			end
		end)

		Button.MouseLeave:Connect(function()
			local page = pages[name]
			if page and not page.Visible then
				TweenService:Create(Button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					BackgroundTransparency = 1
				}):Play()
				TweenService:Create(Label, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					TextColor3 = Color3.fromRGB(160, 160, 165)
				}):Play()
				TweenService:Create(NavIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					ImageColor3 = Color3.fromRGB(160, 160, 165)
				}):Play()
			end
		end)

		Button.MouseButton1Click:Connect(function()
			switchPage(name)
		end)

		navButtons[name] = Button
	end

	-- Smooth Dragging
	local dragging: boolean = false
	local dragInput: InputObject?
	local dragStart: Vector3
	local startPos: UDim2

	local function update(input: InputObject)
		local delta = input.Position - dragStart
		MainGen3.Position = UDim2.new(
			startPos.X.Scale, 
			startPos.X.Offset + delta.X, 
			startPos.Y.Scale, 
			startPos.Y.Offset + delta.Y
		)
	end

	Header.InputBegan:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainGen3.Position

			local connection: RBXScriptConnection?
			connection = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if connection then
						connection:Disconnect()
						connection = nil
					end
				end
			end)
		end
	end)

	MainGen3.InputChanged:Connect(function(input: InputObject)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input: InputObject)
		if input == dragInput and dragging then
			update(input)
		end
	end)

	-- Register Premium Badge for dynamic theme updates
	registerThemeUpdate(function(color)
		PremiumBadge.BackgroundColor3 = color
	end)

	local Window: WindowType = {} :: any
	
	function Window:Destroy()
		ScreenGui:Destroy()
	end

	-- ==========================================
	-- DYNAMIC CARD & SUB-PAGE CREATION API
	-- ==========================================
	function Window:CreateCard(pageName: string, cardConfig: CardConfig): PageObjectType?
		local cardCfg = cardConfig or {}
		local targetPage = pages[pageName]
		if not targetPage then return nil end

		local cardContainer = targetPage:FindFirstChild("CardContainer") :: ScrollingFrame?
		local subPageContainer = targetPage:FindFirstChild("SubPageContainer") :: Frame?

		if not cardContainer then
			cardContainer = Instance.new("ScrollingFrame")
			cardContainer.Name = "CardContainer"
			cardContainer.Size = UDim2.new(1, 0, 1, 0)
			cardContainer.BackgroundTransparency = 1
			cardContainer.BorderSizePixel = 0
			cardContainer.ScrollBarThickness = 0
			cardContainer.ClipsDescendants = true
			cardContainer.ZIndex = 2
			cardContainer.Parent = targetPage

			local ContainerPadding = Instance.new("UIPadding")
			ContainerPadding.PaddingLeft = UDim.new(0, 12)
			ContainerPadding.PaddingRight = UDim.new(0, 12)
			ContainerPadding.PaddingTop = UDim.new(0, 12)
			ContainerPadding.PaddingBottom = UDim.new(0, 12)
			ContainerPadding.Parent = cardContainer

			local gridLayout = Instance.new("UIGridLayout")
			gridLayout.CellSize = UDim2.new(0, 224, 0, 116)
			gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
			gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
			gridLayout.Parent = cardContainer
			
			cardContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
			
			-- Bind dynamic grid resizing to prevent overlapping/wrapping bugs
			bindDynamicGrid(gridLayout, cardContainer)
		end

		if not subPageContainer then
			subPageContainer = Instance.new("Frame")
			subPageContainer.Name = "SubPageContainer"
			subPageContainer.Size = UDim2.new(1, 0, 1, 0)
			subPageContainer.BackgroundTransparency = 1
			subPageContainer.Visible = false
			subPageContainer.ZIndex = 2
			subPageContainer.Parent = targetPage
		end

		-- Create Card Button (With Stroke & High Contrast Background)
		local Card = Instance.new("TextButton")
		Card.Name = cardCfg.Title or "Card"
		Card.Text = ""
		Card.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		Card.BackgroundTransparency = 0
		Card.BorderSizePixel = 0
		Card.ZIndex = 3
		Card.Parent = cardContainer

		local CardCorner = Instance.new("UICorner")
		CardCorner.CornerRadius = UDim.new(0, 8)
		CardCorner.Parent = Card

		local CardStroke = Instance.new("UIStroke")
		CardStroke.Thickness = 1.5
		CardStroke.Color = Color3.fromRGB(45, 45, 50)
		CardStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		CardStroke.Parent = Card

		local CardScale = Instance.new("UIScale")
		CardScale.Scale = 1
		CardScale.Parent = Card

		-- Premium Icon Container on the Left (Upgraded Size)
		local IconContainer = Instance.new("Frame")
		IconContainer.Name = "IconContainer"
		IconContainer.Size = UDim2.fromScale(0, 0) -- Set dynamically or keep static
		IconContainer.Size = UDim2.fromOffset(52, 52)
		IconContainer.Position = UDim2.new(0, 12, 0.5, -26)
		IconContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
		IconContainer.BorderSizePixel = 0
		IconContainer.ZIndex = 3
		IconContainer.Parent = Card

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 6)
		IconCorner.Parent = IconContainer

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1.5
		IconStroke.Color = Color3.fromRGB(255, 255, 255) -- Solid white outline
		IconStroke.Transparency = 0.3
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconContainer

		local Icon = Instance.new("ImageLabel")
		Icon.Name = "Icon"
		Icon.Size = UDim2.fromOffset(34, 34)
		Icon.AnchorPoint = Vector2.new(0.5, 0.5)
		Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		Icon.BackgroundTransparency = 1
		Icon.Image = cardCfg.Icon or Astral.Icons.Icon1
		Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		Icon.ZIndex = 3
		Icon.Parent = IconContainer

		-- Text Container on the Right
		local TextContainer = Instance.new("Frame")
		TextContainer.Name = "TextContainer"
		TextContainer.Position = UDim2.new(0, 76, 0.5, -44)
		TextContainer.Size = UDim2.new(1, -88, 0, 88)
		TextContainer.BackgroundTransparency = 1
		TextContainer.ZIndex = 3
		TextContainer.Parent = Card

		local TextLayout = Instance.new("UIListLayout")
		TextLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TextLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		TextLayout.Padding = UDim.new(0, 2)
		TextLayout.Parent = TextContainer

		-- Category Label Frame inside TextContainer (PAGES Indicator Badge)
		local CategoryLabelFrame = Instance.new("Frame")
		CategoryLabelFrame.Name = "CategoryLabelFrame"
		CategoryLabelFrame.Size = UDim2.new(0, 46, 0, 16)
		CategoryLabelFrame.BackgroundColor3 = currentAccentColor
		CategoryLabelFrame.BorderSizePixel = 0
		CategoryLabelFrame.ZIndex = 3
		CategoryLabelFrame.LayoutOrder = 1
		CategoryLabelFrame.Parent = TextContainer

		local CategoryLabelCorner = Instance.new("UICorner")
		CategoryLabelCorner.CornerRadius = UDim.new(0, 4)
		CategoryLabelCorner.Parent = CategoryLabelFrame

		local CategoryLabel = Instance.new("TextLabel")
		CategoryLabel.Name = "CategoryLabel"
		CategoryLabel.Size = UDim2.new(1, 0, 1, 0)
		CategoryLabel.BackgroundTransparency = 1
		CategoryLabel.Font = Enum.Font.GothamBold
		CategoryLabel.Text = "PAGE"
		CategoryLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		CategoryLabel.TextSize = 8
		CategoryLabel.TextXAlignment = Enum.TextXAlignment.Center
		CategoryLabel.TextYAlignment = Enum.TextYAlignment.Center
		CategoryLabel.ZIndex = 4
		CategoryLabel.Parent = CategoryLabelFrame

		registerThemeUpdate(function(color)
			CategoryLabelFrame.BackgroundColor3 = color
		end)

		local TitleLabel = Instance.new("TextLabel")
		TitleLabel.Name = "Title"
		TitleLabel.Size = UDim2.new(1, 0, 0, 16)
		TitleLabel.BackgroundTransparency = 1
		TitleLabel.Font = Enum.Font.GothamBold
		TitleLabel.Text = (cardCfg.Title or "SECTION"):upper()
		TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		TitleLabel.TextSize = 11
		TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
		TitleLabel.TextWrapped = true
		TitleLabel.ZIndex = 3
		TitleLabel.LayoutOrder = 2
		TitleLabel.Parent = TextContainer
		registerTranslation(TitleLabel, cardCfg.Title or "SECTION", function(t) return t:upper() end)

		-- Added description under the title
		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "Description"
		DescLabel.Size = UDim2.new(1, 0, 0, 24)
		DescLabel.BackgroundTransparency = 1
		DescLabel.Font = Enum.Font.Gotham
		DescLabel.Text = cardCfg.Description or "Configure settings inside this section"
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 9
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextYAlignment = Enum.TextYAlignment.Top
		DescLabel.TextWrapped = true
		DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
		DescLabel.ZIndex = 3
		DescLabel.LayoutOrder = 3
		DescLabel.Parent = TextContainer

		-- Create Sub-Page Frame
		local SubPage = Instance.new("CanvasGroup")
		SubPage.Name = (cardCfg.Title or "SubPage") .. "_Inside"
		SubPage.Size = UDim2.new(1, -4, 1, -4)
		SubPage.Position = UDim2.new(0, 2, 0, 2)
		SubPage.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
		SubPage.BackgroundTransparency = 0.7
		SubPage.BorderSizePixel = 0
		SubPage.GroupTransparency = 1
		SubPage.Visible = false
		SubPage.ZIndex = 4
		SubPage.Parent = subPageContainer

		local SubPageCorner = Instance.new("UICorner")
		SubPageCorner.CornerRadius = UDim.new(0, 8)
		SubPageCorner.Parent = SubPage

		local SubPageStroke = Instance.new("UIStroke")
		SubPageStroke.Thickness = 1
		SubPageStroke.Color = Color3.fromRGB(45, 45, 50)
		SubPageStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		SubPageStroke.Parent = SubPage

		local SubPageScale = Instance.new("UIScale")
		SubPageScale.Scale = 0.95
		SubPageScale.Parent = SubPage

		-- Sub-Page Header
		local SubHeader = Instance.new("Frame")
		SubHeader.Name = "SubHeader"
		SubHeader.Size = UDim2.new(1, 0, 0, 45)
		SubHeader.BackgroundTransparency = 1
		SubHeader.ZIndex = 5
		SubHeader.Parent = SubPage

		local SubPageTitle = Instance.new("TextLabel")
		SubPageTitle.Name = "SubPageTitle"
		SubPageTitle.Size = UDim2.new(1, -340, 1, 0)
		SubPageTitle.Position = UDim2.new(0, 104, 0, 0)
		SubPageTitle.BackgroundTransparency = 1
		SubPageTitle.Font = Enum.Font.GothamBold
		SubPageTitle.Text = (cardCfg.Title or "SECTION"):upper()
		SubPageTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
		SubPageTitle.TextSize = 13
		SubPageTitle.TextXAlignment = Enum.TextXAlignment.Left
		SubPageTitle.TextTruncate = Enum.TextTruncate.AtEnd
		SubPageTitle.ZIndex = 5
		SubPageTitle.Parent = SubHeader
		registerTranslation(SubPageTitle, cardCfg.Title or "SECTION", function(t) return t:upper() end)

		-- Back Button moved to the left side of SubHeader to prevent overlapping (FIXED: Added Stroke & Hover Scale)
		local BackButton = Instance.new("TextButton")
		BackButton.Name = "BackButton"
		BackButton.Size = UDim2.new(0, 80, 0, 28)
		BackButton.Position = UDim2.new(0, 12, 0.5, -14)
		BackButton.BackgroundColor3 = Color3.fromRGB(36, 36, 40)
		BackButton.BackgroundTransparency = 0.1
		BackButton.BorderSizePixel = 0
		BackButton.Text = ""
		BackButton.ZIndex = 5
		BackButton.Parent = SubHeader

		local BackCorner = Instance.new("UICorner")
		BackCorner.CornerRadius = UDim.new(0, 6)
		BackCorner.Parent = BackButton

		local BackStroke = Instance.new("UIStroke")
		BackStroke.Thickness = 1
		BackStroke.Color = Color3.fromRGB(55, 55, 60)
		BackStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		BackStroke.Parent = BackButton

		local BackScale = Instance.new("UIScale")
		BackScale.Scale = 1
		BackScale.Parent = BackButton

		local BackLayout = Instance.new("UIListLayout")
		BackLayout.FillDirection = Enum.FillDirection.Horizontal
		BackLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		BackLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		BackLayout.Padding = UDim.new(0, 6)
		BackLayout.Parent = BackButton

		local BackIcon = Instance.new("ImageLabel")
		BackIcon.Name = "BackIcon"
		BackIcon.Size = UDim2.fromOffset(12, 12)
		BackIcon.BackgroundTransparency = 1
		BackIcon.Image = Astral.Icons.Left
		BackIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		BackIcon.ZIndex = 6
		BackIcon.Parent = BackButton

		local BackLabel = Instance.new("TextLabel")
		BackLabel.Name = "BackLabel"
		BackLabel.BackgroundTransparency = 1
		BackLabel.Size = UDim2.fromScale(0, 1)
		BackLabel.AutomaticSize = Enum.AutomaticSize.X
		BackLabel.Font = Enum.Font.GothamBold
		BackLabel.Text = "BACK"
		BackLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		BackLabel.TextSize = 11
		BackLabel.ZIndex = 6
		BackLabel.Parent = BackButton

		-- Right Controls (Search only now) - Positioned perfectly on the right side
		local RightControls = Instance.new("Frame")
		RightControls.Name = "RightControls"
		RightControls.Size = UDim2.new(0, 220, 0, 36)
		RightControls.Position = UDim2.new(1, -232, 0.5, -18)
		RightControls.BackgroundTransparency = 1
		RightControls.ZIndex = 5
		RightControls.Parent = SubHeader

		local ControlsLayout = Instance.new("UIListLayout")
		ControlsLayout.FillDirection = Enum.FillDirection.Horizontal
		ControlsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
		ControlsLayout.VerticalAlignment = Enum.VerticalAlignment.Center
		ControlsLayout.Padding = UDim.new(0, 10)
		ControlsLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ControlsLayout.Parent = RightControls

		local ControlsPadding = Instance.new("UIPadding")
		ControlsPadding.PaddingRight = UDim.new(0, 10)
		ControlsPadding.Parent = RightControls

		-- Search Bar (FIXED: Added Search Icon, Clear Button, and proper padding)
		local SearchBar = Instance.new("TextBox")
		SearchBar.Name = "SearchBar"
		SearchBar.Size = UDim2.new(1, 0, 1, 0)
		SearchBar.BackgroundColor3 = Color3.fromRGB(26, 26, 30)
		SearchBar.BackgroundTransparency = 0.2
		SearchBar.BorderSizePixel = 0
		SearchBar.Font = Enum.Font.Gotham
		SearchBar.PlaceholderText = "Search options..."
		SearchBar.PlaceholderColor3 = Color3.fromRGB(120, 120, 125)
		SearchBar.Text = ""
		SearchBar.TextColor3 = Color3.fromRGB(255, 255, 255)
		SearchBar.TextSize = 11
		SearchBar.ClearTextOnFocus = false
		SearchBar.LayoutOrder = 1
		SearchBar.ZIndex = 5
		SearchBar.Parent = RightControls

		local SearchCorner = Instance.new("UICorner")
		SearchCorner.CornerRadius = UDim.new(0, 6)
		SearchCorner.Parent = SearchBar

		local SearchStroke = Instance.new("UIStroke")
		SearchStroke.Thickness = 1
		SearchStroke.Color = Color3.fromRGB(55, 55, 60)
		SearchStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		SearchStroke.Parent = SearchBar

		local SearchPadding = Instance.new("UIPadding")
		SearchPadding.PaddingLeft = UDim.new(0, 30) -- FIXED: Left padding to clear search icon
		SearchPadding.PaddingRight = UDim.new(0, 30) -- FIXED: Right padding to clear clear button
		SearchPadding.Parent = SearchBar

		-- FIXED: Added Search Icon inside Search Bar
		local SearchIcon = Instance.new("ImageLabel")
		SearchIcon.Name = "SearchIcon"
		SearchIcon.BackgroundTransparency = 1
		SearchIcon.Position = UDim2.new(0, 10, 0.5, -7)
		SearchIcon.Size = UDim2.fromOffset(14, 14)
		SearchIcon.Image = Astral.Icons.search
		SearchIcon.ImageColor3 = Color3.fromRGB(120, 120, 125)
		SearchIcon.ZIndex = 6
		SearchIcon.Parent = SearchBar

		-- FIXED: Added Clear Button inside Search Bar
		local ClearSearchBtn = Instance.new("TextButton")
		ClearSearchBtn.Name = "ClearSearchBtn"
		ClearSearchBtn.BackgroundTransparency = 1
		ClearSearchBtn.Position = UDim2.new(1, -24, 0.5, -8)
		ClearSearchBtn.Size = UDim2.fromOffset(16, 16)
		ClearSearchBtn.Text = "×"
		ClearSearchBtn.Font = Enum.Font.GothamBold
		ClearSearchBtn.TextColor3 = Color3.fromRGB(120, 120, 125)
		ClearSearchBtn.TextSize = 14
		ClearSearchBtn.Visible = false
		ClearSearchBtn.ZIndex = 6
		ClearSearchBtn.Parent = SearchBar

		ClearSearchBtn.MouseButton1Click:Connect(function()
			SearchBar.Text = ""
		end)

		SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
			ClearSearchBtn.Visible = (SearchBar.Text ~= "")
		end)

		SearchBar.Focused:Connect(function()
			TweenService:Create(SearchStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
			TweenService:Create(SearchBar, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(32, 32, 38)}):Play()
		end)

		SearchBar.FocusLost:Connect(function()
			TweenService:Create(SearchStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(55, 55, 60)}):Play()
			TweenService:Create(SearchBar, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
		end)

		-- Content Container (Used only if page has no tabs)
		local ContentContainer = Instance.new("Frame")
		ContentContainer.Name = "Content"
		ContentContainer.Size = UDim2.new(1, 0, 1, -45)
		ContentContainer.Position = UDim2.new(0, 0, 0, 45)
		ContentContainer.BackgroundTransparency = 1
		ContentContainer.ZIndex = 5
		ContentContainer.Parent = SubPage

		-- Instantiate Page Object
		local PageObj = PageObject.new(ContentContainer, SubPage)
		PageObj.MainTitle = (cardCfg.Title or "SECTION"):upper()

		-- Real-Time Search Filtering
		SearchBar:GetPropertyChangedSignal("Text"):Connect(function()
			local query = SearchBar.Text:lower()
			if PageObj.IsTabbed then
				if PageObj.ActiveTab then
					local activeTabObj = PageObj.Tabs[PageObj.ActiveTab]
					if activeTabObj then
						for _, column in ipairs({activeTabObj.LeftColumn, activeTabObj.RightColumn}) do
							for _, child in ipairs(column:GetChildren()) do
								if child:IsA("GuiObject") and not child:IsA("UIListLayout") and not child:IsA("UIPadding") and not child:IsA("UIGridLayout") then
									local label = child:FindFirstChildOfClass("TextLabel") or child:FindFirstChild("Title", true)
									local textToSearch = child.Name
									if label and label:IsA("TextLabel") then
										textToSearch = label.Text
									end
									child.Visible = (query == "" or string.find(textToSearch:lower(), query, 1, true) ~= nil)
								end
							end
						end
					end
				else
					if PageObj.TabCardContainer then
						for _, child in ipairs(PageObj.TabCardContainer:GetChildren()) do
							if child:IsA("GuiObject") and not child:IsA("UIGridLayout") and not child:IsA("UIPadding") then
								local label = child:FindFirstChildOfClass("TextLabel") or child:FindFirstChild("Title", true)
								local textToSearch = child.Name
								if label and label:IsA("TextLabel") then
									textToSearch = label.Text
								end
								child.Visible = (query == "" or string.find(textToSearch:lower(), query, 1, true) ~= nil)
							end
						end
					end
				end
			end
		end)

		-- Back Button Logic
		BackButton.MouseButton1Click:Connect(function()
			SearchBar.Text = ""
			
			if PageObj.IsTabbed and PageObj.ActiveTab then
				PageObj:GoBackToTabCards()
				return
			end

			SubPage.Visible = false
			SubPage.GroupTransparency = 1
			if subPageContainer then
				subPageContainer.Visible = false
			end
			if cardContainer then
				cardContainer.Visible = true
			end
		end)

		-- Back Button Hover Animations (FIXED: Smooth Icon Slide & Scale)
		BackButton.MouseEnter:Connect(function()
			TweenService:Create(BackButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(50, 50, 55),
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(BackStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(70, 70, 75)
			}):Play()
			TweenService:Create(BackScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1.04
			}):Play()
			TweenService:Create(BackIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, -4, 0, 0) -- Slide icon slightly left
			}):Play()
		end)

		BackButton.MouseLeave:Connect(function()
			TweenService:Create(BackButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(36, 36, 40),
				BackgroundTransparency = 0.1
			}):Play()
			TweenService:Create(BackStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(55, 55, 60)
			}):Play()
			TweenService:Create(BackScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
			TweenService:Create(BackIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 0, 0, 0)
			}):Play()
		end)

		-- Click to enter Sub-Page
		Card.MouseButton1Click:Connect(function()
			-- Click Animation
			CardScale.Scale = 0.92
			TweenService:Create(CardScale, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1.03
			}):Play()

			if cardContainer then
				cardContainer.Visible = false
			end
			if subPageContainer then
				subPageContainer.Visible = true
				for _, child in ipairs(subPageContainer:GetChildren()) do
					if child:IsA("CanvasGroup") or child:IsA("Frame") then
						child.Visible = (child == SubPage)
					end
				end
			end

			SubPage.GroupTransparency = 0
			SubPage.Visible = true
			SubPageScale.Scale = 1
		end)

		-- Hover effects
		Card.MouseEnter:Connect(function()
			TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(30, 30, 36)
			}):Play()
			TweenService:Create(CardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(70, 70, 75)
			}):Play()
			TweenService:Create(CardScale, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Scale = 1.03
			}):Play()
		end)

		Card.MouseLeave:Connect(function()
			TweenService:Create(Card, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = Color3.fromRGB(20, 20, 24)
			}):Play()
			TweenService:Create(CardStroke, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Color = Color3.fromRGB(45, 45, 50)
			}):Play()
			TweenService:Create(CardScale, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Scale = 1
			}):Play()
		end)

		return PageObj
	end

	-- ==========================================
	-- DYNAMIC SECTION CREATION API
	-- ==========================================
	function Window:MakeSection(sectionConfig: {string}): SectionType
		local name = sectionConfig[1]
		local iconName = sectionConfig[2]
		local icon = resolveIcon(iconName)

		-- Create CanvasGroup Page
		local Page = Instance.new("CanvasGroup")
		Page.Name = name .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1
		
		local isFirst = (next(pages) == nil)
		Page.GroupTransparency = isFirst and 0 or 1
		Page.Visible = isFirst
		Page.ZIndex = 2
		Page.Parent = PagesContainer

		local pageCorner = Instance.new("UICorner")
		pageCorner.CornerRadius = UDim.new(0, 8)
		pageCorner.Parent = Page

		local PageScale = Instance.new("UIScale")
		PageScale.Scale = isFirst and 1 or 0.95
		PageScale.Parent = Page

		pages[name] = Page

		createNavButton(name, icon, isFirst)

		local Section = {} :: SectionType
		
		function Section:MakePage(pageConfig: PageConfig)
			local cardConfig: CardConfig = {
				Title = pageConfig.Name,
				Description = pageConfig.Description or "Configure settings inside this section",
				Icon = resolveIcon(pageConfig.Icon),
				InsideBackgroundColor = Color3.fromRGB(12, 12, 14)
			}
			return Window:CreateCard(name, cardConfig)
		end
		
		return Section
	end

	-- ==========================================
	-- INFO SECTION (ALWAYS VISIBLE - NO PAGES/TABS)
	-- ==========================================
	local InfoSectionObject = {}
	InfoSectionObject.__index = InfoSectionObject

	function InfoSectionObject.new(name: string, iconAsset: string?)
		local icon = resolveIcon(iconAsset)

		local Page = Instance.new("CanvasGroup")
		Page.Name = name .. "Page"
		Page.Size = UDim2.new(1, 0, 1, 0)
		Page.BackgroundTransparency = 1

		local isFirst = (next(pages) == nil)
		Page.GroupTransparency = isFirst and 0 or 1
		Page.Visible = isFirst
		Page.ZIndex = 2
		Page.Parent = PagesContainer

		local PageScale = Instance.new("UIScale")
		PageScale.Scale = isFirst and 1 or 0.95
		PageScale.Parent = Page

		pages[name] = Page
		createNavButton(name, icon, isFirst)

		local ContentScroll = Instance.new("ScrollingFrame")
		ContentScroll.Name = "InfoContent"
		ContentScroll.Size = UDim2.new(1, 0, 1, 0)
		ContentScroll.BackgroundTransparency = 1
		ContentScroll.BorderSizePixel = 0
		ContentScroll.ScrollBarThickness = 0
		ContentScroll.ClipsDescendants = true
		ContentScroll.ZIndex = 2
		ContentScroll.Parent = Page
		ContentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y

		local ColumnsContainer = Instance.new("Frame")
		ColumnsContainer.Name = "ColumnsContainer"
		ColumnsContainer.Size = UDim2.new(1, -24, 0, 0)
		ColumnsContainer.Position = UDim2.new(0, 12, 0, 12)
		ColumnsContainer.BackgroundTransparency = 1
		ColumnsContainer.AutomaticSize = Enum.AutomaticSize.Y
		ColumnsContainer.Parent = ContentScroll

		local LeftColumn = Instance.new("Frame")
		LeftColumn.Name = "LeftColumn"
		LeftColumn.Size = UDim2.new(0.5, -6, 0, 0)
		LeftColumn.Position = UDim2.new(0, 0, 0, 0)
		LeftColumn.BackgroundTransparency = 1
		LeftColumn.AutomaticSize = Enum.AutomaticSize.Y
		LeftColumn.Parent = ColumnsContainer

		local LeftLayout = Instance.new("UIListLayout")
		LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
		LeftLayout.Padding = UDim.new(0, 10)
		LeftLayout.Parent = LeftColumn

		local RightColumn = Instance.new("Frame")
		RightColumn.Name = "RightColumn"
		RightColumn.Size = UDim2.new(0.5, -6, 0, 0)
		RightColumn.Position = UDim2.new(0.5, 6, 0, 0)
		RightColumn.BackgroundTransparency = 1
		RightColumn.AutomaticSize = Enum.AutomaticSize.Y
		RightColumn.Parent = ColumnsContainer

		local RightLayout = Instance.new("UIListLayout")
		RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
		RightLayout.Padding = UDim.new(0, 10)
		RightLayout.Parent = RightColumn

		local self = setmetatable({
			LeftColumn = LeftColumn,
			RightColumn = RightColumn,
			Elements = {}
		}, InfoSectionObject)

		return self
	end

	function InfoSectionObject:AddLabel(labelConfig: LabelConfig)
		local tabObj = {LeftColumn = self.LeftColumn, RightColumn = self.RightColumn, Elements = self.Elements}
		CreateLabel(tabObj, labelConfig)
	end

	function InfoSectionObject:AddParagraph(paragraphConfig: ParagraphConfig)
		local tabObj = {LeftColumn = self.LeftColumn, RightColumn = self.RightColumn, Elements = self.Elements}
		CreateParagraph(tabObj, paragraphConfig)
	end

	function InfoSectionObject:AddToggle(toggleConfig: ToggleConfig): ToggleController
		local tabObj = {LeftColumn = self.LeftColumn, RightColumn = self.RightColumn, Elements = self.Elements}
		return CreateToggle(tabObj, toggleConfig)
	end

	function InfoSectionObject:AddButton(buttonConfig: ButtonConfig)
		local tabObj = {LeftColumn = self.LeftColumn, RightColumn = self.RightColumn, Elements = self.Elements}
		CreateButton(tabObj, buttonConfig)
	end

	function InfoSectionObject:AddDiscordLabel(config: {[string]: any})
		local data = config.ServerData or {}
		local position = config.Position or "Left"
		local inviteCode = data.InviteCode or "RhQa6kZu9A"

		local TargetColumn = position == "Left" and self.LeftColumn or self.RightColumn

		local Spacer = Instance.new("Frame")
		Spacer.Name = "TopSpacer"
		Spacer.Size = UDim2.new(1, 0, 0, 10)
		Spacer.BackgroundTransparency = 1
		Spacer.Parent = TargetColumn

		local MainFrame = Instance.new("Frame")
		MainFrame.Name = "DiscordInvite"
		MainFrame.Size = UDim2.new(1, 0, 0, 260)
		MainFrame.BackgroundColor3 = Color3.fromHex("#1e1f22")
		MainFrame.BorderSizePixel = 0
		MainFrame.ClipsDescendants = true
		MainFrame.Parent = TargetColumn

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
		Banner.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
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
		ServerName.Text = data.ServerName or "Astral Hub"
		ServerName.Font = Enum.Font.GothamBold
		ServerName.TextSize = 16
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
		OnlineLabel.TextSize = 12
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
		MemberLabel.TextSize = 12
		MemberLabel.TextColor3 = Color3.fromHex("#949ba4")
		MemberLabel.BackgroundTransparency = 1
		MemberLabel.LayoutOrder = 5
		MemberLabel.Parent = MetricsFrame

		local EstLabel = Instance.new("TextLabel")
		EstLabel.Name = "EstLabel"
		EstLabel.Size = UDim2.new(1, 0, 0, 14)
		EstLabel.Text = data.EstablishedDate or "Est. Jun 2025"
		EstLabel.Font = Enum.Font.GothamMedium
		EstLabel.TextSize = 12
		EstLabel.TextColor3 = Color3.fromHex("#949ba4")
		EstLabel.TextXAlignment = Enum.TextXAlignment.Left
		EstLabel.BackgroundTransparency = 1
		EstLabel.LayoutOrder = 3
		EstLabel.Parent = InfoHolder

		local DescLabel = Instance.new("TextLabel")
		DescLabel.Name = "DescLabel"
		DescLabel.Size = UDim2.new(1, 0, 0, 18)
		DescLabel.Text = data.Description or "Official Astral Hub Community"
		DescLabel.Font = Enum.Font.GothamMedium
		DescLabel.TextSize = 12
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
		GameLabel.TextSize = 12
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
		ActionButton.Text = _L("Discord.GoToServer")
		ActionButton.Font = Enum.Font.GothamBold
		ActionButton.TextSize = 13
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

			pcall(function()
				game:GetService("StarterGui"):SetCore("SendNotification", {
					Title = data.ServerName or "Discord Server",
					Text = "Invite copied to clipboard!",
					Duration = 5
				})
			end)

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
			ActionButton.Text = _L("Discord.GoToServer")
			ActionButton.BackgroundColor3 = baseColor
		end)

		MainFrame.MouseEnter:Connect(function()
			TweenService:Create(BgHighlight, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
		end)
		MainFrame.MouseLeave:Connect(function()
			TweenService:Create(BgHighlight, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
		end)

		table.insert(self.Elements, {Object = MainFrame, OriginalColumn = TargetColumn})
	end

	function InfoSectionObject:AddUserLabel(config: {[string]: any})
		local position = config.Position or "Left"
		local TargetColumn = position == "Left" and self.LeftColumn or self.RightColumn
		local users = config.Users or {}
		local mouse = Players.LocalPlayer and Players.LocalPlayer:GetMouse()

		local function loadImg(url, fileName)
			if isfile and writefile and getcustomasset then
				if not isfile(fileName) then
					local ok, data = pcall(function() return game:HttpGet(url) end)
					if ok and data then writefile(fileName, data) end
				end
				return getcustomasset(fileName)
			end
			return url
		end

		if not self._Tooltip then
			local tip = Instance.new("Frame")
			tip.Name = "UserLabelTooltip"
			tip.BackgroundColor3 = Color3.fromHex("#111214")
			tip.BorderSizePixel = 0
			tip.Visible = false
			tip.ZIndex = 100
			tip.Parent = TargetColumn:FindFirstAncestorOfClass("ScreenGui") or game:GetService("CoreGui")

			local tipCorner = Instance.new("UICorner")
			tipCorner.CornerRadius = UDim.new(0, 6)
			tipCorner.Parent = tip

			local tipText = Instance.new("TextLabel")
			tipText.Size = UDim2.new(1, 0, 1, 0)
			tipText.Font = Enum.Font.GothamMedium
			tipText.TextSize = 14
			tipText.TextColor3 = Color3.fromHex("#dbdee1")
			tipText.BackgroundTransparency = 1
			tipText.ZIndex = 101
			tipText.Parent = tip

			self._Tooltip = tip
			self._TooltipText = tipText
		end

		local function bindTooltip(element, text)
			element.MouseEnter:Connect(function()
				if self._Tooltip then
					self._TooltipText.Text = text
					self._Tooltip.Size = UDim2.new(0, self._TooltipText.TextBounds.X + 24, 0, 30)
					self._Tooltip.Visible = true
				end
			end)
			element.MouseMoved:Connect(function()
				if mouse and self._Tooltip then
					self._Tooltip.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y - 15)
				end
			end)
			element.MouseLeave:Connect(function()
				if self._Tooltip then
					self._Tooltip.Visible = false
				end
			end)
		end

		local mainH = 90 + (config.Expanded and 200 or 0)
		local MainFrame = Instance.new("Frame")
		MainFrame.Name = "UserLabel"
		MainFrame.Size = UDim2.new(1, 0, 0, mainH)
		MainFrame.BackgroundColor3 = Color3.fromHex("#1e1f22")
		MainFrame.BorderSizePixel = 0
		MainFrame.ClipsDescendants = true
		MainFrame.Parent = TargetColumn

		local MainCorner = Instance.new("UICorner")
		MainCorner.CornerRadius = UDim.new(0, 12)
		MainCorner.Parent = MainFrame

		local MainStroke = Instance.new("UIStroke")
		MainStroke.Thickness = 1
		MainStroke.Color = Color3.fromRGB(50, 50, 55)
		MainStroke.Parent = MainFrame

		local Header = Instance.new("TextLabel")
		Header.Size = UDim2.new(1, -24, 0, 16)
		Header.Position = UDim2.new(0, 12, 0, 10)
		Header.Text = "DEVELOPERS / CREDITS"
		Header.Font = Enum.Font.GothamBold
		Header.TextSize = 11
		Header.TextColor3 = Color3.fromHex("#949ba4")
		Header.TextXAlignment = Enum.TextXAlignment.Left
		Header.BackgroundTransparency = 1
		Header.Parent = MainFrame

		local ProfilesFrame = Instance.new("Frame")
		ProfilesFrame.Name = "Profiles"
		ProfilesFrame.Size = UDim2.new(1, -24, 0, 56)
		ProfilesFrame.Position = UDim2.new(0, 12, 0, 32)
		ProfilesFrame.BackgroundTransparency = 1
		ProfilesFrame.Parent = MainFrame

		local ProfilesLayout = Instance.new("UIListLayout")
		ProfilesLayout.FillDirection = Enum.FillDirection.Horizontal
		ProfilesLayout.SortOrder = Enum.SortOrder.LayoutOrder
		ProfilesLayout.Padding = UDim.new(0, 16)
		ProfilesLayout.Parent = ProfilesFrame

		local activeProfileName = nil
		local DetailsFrame = nil
		local BioLabel = nil
		local VisitBtn = nil
		local DiscordBtn = nil
		local DmLabel = nil

		local function createDetails()
			local details = Instance.new("CanvasGroup")
			details.Name = "DetailsFrame"
			details.Size = UDim2.new(1, -24, 0, 160)
			details.Position = UDim2.new(0, 12, 0, 96)
			details.BackgroundTransparency = 1
			details.GroupTransparency = 1
			details.Visible = false
			details.Parent = MainFrame

			local scroll = Instance.new("ScrollingFrame")
			scroll.Size = UDim2.new(1, 0, 0, 110)
			scroll.Position = UDim2.new(0, 0, 0, 0)
			scroll.BackgroundTransparency = 1
			scroll.BorderSizePixel = 0
			scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
			scroll.ScrollBarThickness = 4
			scroll.ScrollBarImageColor3 = Color3.fromHex("#1e1f22")
			scroll.ZIndex = 3
			scroll.Parent = details

			local bio = Instance.new("TextLabel")
			bio.Size = UDim2.new(1, -8, 0, 0)
			bio.AutomaticSize = Enum.AutomaticSize.Y
			bio.BackgroundTransparency = 1
			bio.Font = Enum.Font.Gotham
			bio.TextSize = 12
			bio.TextColor3 = Color3.fromHex("#dbdee1")
			bio.TextWrapped = true
			bio.TextXAlignment = Enum.TextXAlignment.Left
			bio.TextYAlignment = Enum.TextYAlignment.Top
			bio.LineHeight = 1.25
			bio.Text = ""
			bio.ZIndex = 3
			bio.Parent = scroll

			local btnCont = Instance.new("Frame")
			btnCont.Size = UDim2.new(1, 0, 0, 28)
			btnCont.Position = UDim2.new(0, 0, 1, -28)
			btnCont.BackgroundTransparency = 1
			btnCont.ZIndex = 3
			btnCont.Parent = details

			local btnLayout = Instance.new("UIListLayout")
			btnLayout.FillDirection = Enum.FillDirection.Horizontal
			btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
			btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
			btnLayout.Padding = UDim.new(0, 8)
			btnLayout.Parent = btnCont

			local visit = Instance.new("TextButton")
			visit.Size = UDim2.new(0, 100, 1, 0)
			visit.BackgroundColor3 = Color3.fromHex("#248046")
			visit.Font = Enum.Font.GothamBold
			visit.TextSize = 11
			visit.TextColor3 = Color3.fromHex("#ffffff")
			visit.Text = "Visit Profile"
			visit.AutoButtonColor = false
			visit.ZIndex = 3
			visit.Parent = btnCont

			local visitCorner = Instance.new("UICorner")
			visitCorner.CornerRadius = UDim.new(0, 4)
			visitCorner.Parent = visit

			local discord = Instance.new("TextButton")
			discord.Size = UDim2.new(0, 100, 1, 0)
			discord.BackgroundColor3 = Color3.fromHex("#5865f2")
			discord.Font = Enum.Font.GothamBold
			discord.TextSize = 11
			discord.TextColor3 = Color3.fromHex("#ffffff")
			discord.Text = "Copy Tag"
			discord.AutoButtonColor = false
			discord.ZIndex = 3
			discord.Parent = btnCont

			local discordCorner = Instance.new("UICorner")
			discordCorner.CornerRadius = UDim.new(0, 4)
			discordCorner.Parent = discord

			local dm = Instance.new("TextLabel")
			dm.Size = UDim2.new(1, -220, 1, 0)
			dm.BackgroundTransparency = 1
			dm.Font = Enum.Font.GothamBold
			dm.TextSize = 10
			dm.TextColor3 = Color3.fromHex("#949ba4")
			dm.Text = "DM on Discord"
			dm.TextXAlignment = Enum.TextXAlignment.Right
			dm.TextYAlignment = Enum.TextYAlignment.Center
			dm.ZIndex = 3
			dm.Parent = btnCont

			DetailsFrame = details
			BioLabel = bio
			VisitBtn = visit
			DiscordBtn = discord
			DmLabel = dm
		end

		createDetails()

		local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request

		local function copyToClipboard(text)
			if setclipboard then setclipboard(text) end
		end

		local function openDiscordProfile(discordId)
			local webUrl = "https://discord.com/users/" .. tostring(discordId)
			local protocolUrl = "discord://-/users/" .. tostring(discordId)
			if openurl then pcall(openurl, protocolUrl) end
			if requestFunc then
				task.spawn(function()
					for port = 6463, 6472 do
						pcall(function()
							requestFunc({
								Url = "http://127.0.0.1:" .. tostring(port) .. "/rpc?v=1",
								Method = "POST",
								Headers = { ["Content-Type"] = "application/json", ["Origin"] = "https://discord.com" },
								Body = HttpService:JSONEncode({ cmd = "INVITE_BROWSER", args = { code = "astralhub" }, nonce = HttpService:GenerateGUID(false) })
							})
						end)
					end
				end)
			end
			if openurl then task.delay(0.1, function() pcall(openurl, webUrl) end) end
			copyToClipboard(webUrl)
		end

		for idx, userData in ipairs(users) do
			local userName = userData.Name or _L("Users.DefaultName")
			local UserFrame = Instance.new("Frame")
			UserFrame.Name = "User_" .. userName
			UserFrame.Size = UDim2.new(0.5, -8, 1, 0)
			UserFrame.BackgroundTransparency = 1
			UserFrame.LayoutOrder = idx
			UserFrame.ClipsDescendants = true
			UserFrame.Parent = ProfilesFrame

			local uiscale = Instance.new("UIScale")
			uiscale.Parent = UserFrame

			local bgHL = Instance.new("Frame")
			bgHL.Name = "BgHighlight"
			bgHL.Size = UDim2.new(1, 8, 1, 8)
			bgHL.Position = UDim2.new(0, -4, 0, -4)
			bgHL.BackgroundColor3 = Color3.fromHex("#ffffff")
			bgHL.BackgroundTransparency = 1
			bgHL.ZIndex = 0
			bgHL.Parent = UserFrame

			local bgHLCorner = Instance.new("UICorner")
			bgHLCorner.CornerRadius = UDim.new(0, 6)
			bgHLCorner.Parent = bgHL

			local Avatar = Instance.new("ImageLabel")
			Avatar.Size = UDim2.new(0, 48, 0, 48)
			Avatar.Position = UDim2.new(0, 0, 0.5, -24)
			Avatar.Image = loadImg(userData.Avatar or "", "Avatar_" .. userName .. ".png")
			Avatar.BackgroundColor3 = Color3.fromHex("#1e1f22")
			Avatar.BorderSizePixel = 0
			Avatar.ZIndex = 2
			Avatar.Parent = UserFrame

			local AvatarCorner = Instance.new("UICorner")
			AvatarCorner.CornerRadius = UDim.new(1, 0)
			AvatarCorner.Parent = Avatar

			local InfoCont = Instance.new("Frame")
			InfoCont.Size = UDim2.new(1, -58, 1, 0)
			InfoCont.Position = UDim2.new(0, 58, 0, 0)
			InfoCont.BackgroundTransparency = 1
			InfoCont.ZIndex = 2
			InfoCont.Parent = UserFrame

			local InfoLay = Instance.new("UIListLayout")
			InfoLay.FillDirection = Enum.FillDirection.Horizontal
			InfoLay.VerticalAlignment = Enum.VerticalAlignment.Center
			InfoLay.SortOrder = Enum.SortOrder.LayoutOrder
			InfoLay.Padding = UDim.new(0, 4)
			InfoLay.Parent = InfoCont

			local Nm = Instance.new("TextLabel")
			Nm.Size = UDim2.new(0, 0, 1, 0)
			Nm.AutomaticSize = Enum.AutomaticSize.X
			Nm.Text = userName
			Nm.Font = Enum.Font.GothamBold
			Nm.TextSize = 15
			Nm.TextColor3 = Color3.fromHex("#ffffff")
			Nm.TextXAlignment = Enum.TextXAlignment.Left
			Nm.BackgroundTransparency = 1
			Nm.LayoutOrder = 1
			Nm.ZIndex = 2
			Nm.Parent = InfoCont

			local badges = userData.Badges or {}
			for bi, badge in ipairs(badges) do
				local bIcon = Instance.new("ImageLabel")
				bIcon.Size = UDim2.new(0, 18, 0, 18)
				bIcon.Image = badge.Icon
				bIcon.BackgroundTransparency = 1
				bIcon.LayoutOrder = 1 + bi
				bIcon.ZIndex = 2
				bIcon.Parent = InfoCont
				bindTooltip(bIcon, badge.Name or "")
			end

			local ClickBtn = Instance.new("TextButton")
			ClickBtn.Size = UDim2.new(1, 0, 1, 0)
			ClickBtn.BackgroundTransparency = 1
			ClickBtn.Text = ""
			ClickBtn.ZIndex = 5
			ClickBtn.Parent = UserFrame

			ClickBtn.MouseEnter:Connect(function()
				TweenService:Create(bgHL, TweenInfo.new(0.2), {BackgroundTransparency = 0.95}):Play()
			end)
			ClickBtn.MouseLeave:Connect(function()
				TweenService:Create(bgHL, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
				TweenService:Create(uiscale, TweenInfo.new(0.15), {Scale = 1}):Play()
			end)
			ClickBtn.MouseButton1Down:Connect(function()
				TweenService:Create(uiscale, TweenInfo.new(0.1), {Scale = 0.95}):Play()
			end)
			ClickBtn.MouseButton1Up:Connect(function()
				TweenService:Create(uiscale, TweenInfo.new(0.1), {Scale = 1}):Play()
			end)

			ClickBtn.MouseButton1Click:Connect(function()
				if activeProfileName == userName then
					activeProfileName = nil
					TweenService:Create(DetailsFrame, TweenInfo.new(0.15), {GroupTransparency = 1}):Play()
					TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 90)}):Play()
					task.delay(0.3, function() DetailsFrame.Visible = false end)
				else
					activeProfileName = userName
					BioLabel.Text = userData.Description or ""
					DetailsFrame.Visible = true
					local prevVisit = VisitBtn.MouseButton1Click:Connect(function() end)
					prevVisit:Disconnect()
					local prevDiscord = DiscordBtn.MouseButton1Click:Connect(function() end)
					prevDiscord:Disconnect()

					VisitBtn.MouseButton1Click:Connect(function()
						openDiscordProfile(userData.DiscordId or "")
						copyToClipboard("https://discord.com/users/" .. tostring(userData.DiscordId or ""))
						VisitBtn.Text = "Copied!"
						TweenService:Create(VisitBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromHex("#5865f2")}):Play()
						task.delay(1.5, function()
							if VisitBtn.Text == "Copied!" then
								VisitBtn.Text = "Visit Profile"
								TweenService:Create(VisitBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromHex("#248046")}):Play()
							end
						end)
					end)

					DiscordBtn.MouseButton1Click:Connect(function()
						local tag = userData.DiscordTag or ""
						copyToClipboard(tag)
						DiscordBtn.Text = "Copied Tag!"
						task.delay(1.5, function()
							if DiscordBtn.Text == "Copied Tag!" then
								DiscordBtn.Text = "Copy Tag"
							end
						end)
					end)

					TweenService:Create(MainFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 280)}):Play()
					task.delay(0.1, function()
						TweenService:Create(DetailsFrame, TweenInfo.new(0.2), {GroupTransparency = 0}):Play()
					end)
				end
			end)
		end

		MainFrame.MouseEnter:Connect(function()
			TweenService:Create(MainFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(36, 36, 40)}):Play()
			TweenService:Create(MainStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
		end)
		MainFrame.MouseLeave:Connect(function()
			TweenService:Create(MainFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(26, 26, 30)}):Play()
			TweenService:Create(MainStroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(50, 50, 55)}):Play()
		end)

		table.insert(self.Elements, {Object = MainFrame, OriginalColumn = TargetColumn})
	end

	function Window:CreateInfoSection(name: string, iconAsset: string?)
		return InfoSectionObject.new(name, iconAsset)
	end

	-- ==========================================
	-- NOTIFICATION SYSTEM
	-- ==========================================
	local notifTypeColors = {
		good = {bg = Color3.fromRGB(46, 204, 113)},
		warning = {bg = Color3.fromRGB(241, 196, 15)},
		bad = {bg = Color3.fromRGB(231, 76, 60)}
	}
	local notifTypeIcons = {
		good = Astral.Icons.Checkmark,
		warning = Astral.Icons.Warning,
		bad = Astral.Icons.Close
	}

	function Window:Notify(config)
		local nType = config.Type or "good"
		local title = config.Title or ""
		local message = config.Message or ""
		local duration = config.Duration or 10
		local actions = config.Actions or {}
		local hasActions = #actions > 0
		local tColor = notifTypeColors[nType] or notifTypeColors.good
		local tIcon = notifTypeIcons[nType] or notifTypeIcons.good
		local notifH = hasActions and 100 or 76

		local Frame = Instance.new("Frame")
		Frame.Size = UDim2.new(0, notifW, 0, notifH)
		Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 24)
		Frame.BorderSizePixel = 0
		Frame.ZIndex = 200
		Frame.ClipsDescendants = true
		Frame.Parent = NotificationContainer

		local Corner = Instance.new("UICorner")
		Corner.CornerRadius = UDim.new(0, 10)
		Corner.Parent = Frame

		local Stroke = Instance.new("UIStroke")
		Stroke.Thickness = 1
		Stroke.Color = Color3.fromRGB(45, 45, 50)
		Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		Stroke.Parent = Frame

		-- Icon (matches UI IconContainer style)
		local IconFrame = Instance.new("Frame")
		IconFrame.Size = UDim2.fromOffset(38, 38)
		IconFrame.Position = UDim2.new(0, 22, 0, hasActions and 12 or 19)
		IconFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
		IconFrame.BorderSizePixel = 0
		IconFrame.ZIndex = 200
		IconFrame.Parent = Frame

		local IconCorner = Instance.new("UICorner")
		IconCorner.CornerRadius = UDim.new(0, 8)
		IconCorner.Parent = IconFrame

		local IconStroke = Instance.new("UIStroke")
		IconStroke.Thickness = 1
		IconStroke.Color = Color3.fromRGB(55, 55, 60)
		IconStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		IconStroke.Parent = IconFrame

		local Icon = Instance.new("ImageLabel")
		Icon.Size = UDim2.fromOffset(20, 20)
		Icon.AnchorPoint = Vector2.new(0.5, 0.5)
		Icon.Position = UDim2.new(0.5, 0, 0.5, 0)
		Icon.BackgroundTransparency = 1
		Icon.Image = tIcon
		Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
		Icon.ZIndex = 200
		Icon.Parent = IconFrame

		-- Text
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
		TitleLabel.Text = title
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
		DescLabel.Text = message
		DescLabel.TextColor3 = Color3.fromRGB(160, 160, 165)
		DescLabel.TextSize = 11
		DescLabel.TextXAlignment = Enum.TextXAlignment.Left
		DescLabel.TextYAlignment = Enum.TextYAlignment.Top
		DescLabel.TextWrapped = true
		DescLabel.TextTruncate = Enum.TextTruncate.AtEnd
		DescLabel.ZIndex = 200
		DescLabel.Parent = TextFrame

		-- Bottom progress bar (neutral, matches UI - no type colors)
		local ProgressTrack = Instance.new("Frame")
		ProgressTrack.Name = "ProgressTrack"
		ProgressTrack.Size = UDim2.new(1, -32, 0, 2)
		ProgressTrack.Position = UDim2.new(0, 16, 1, -6)
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
		ProgressFill.BackgroundColor3 = Color3.fromRGB(120, 120, 125)
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

			for i, action in ipairs(actions) do
				local aType = action.Type or nType
				local aColor = (notifTypeColors[aType] or tColor).bg
				local isPrimary = (i == 1)
				local Btn = Instance.new("TextButton")
				Btn.Size = UDim2.new(0, 72, 0, 26)
				Btn.BackgroundColor3 = isPrimary and aColor or Color3.fromRGB(36, 36, 40)
				Btn.BorderSizePixel = 0
				Btn.Font = Enum.Font.GothamBold
				Btn.Text = action.Text or ""
				Btn.TextColor3 = isPrimary and Color3.fromRGB(15, 15, 15) or Color3.fromRGB(255, 255, 255)
				Btn.TextSize = 11
				Btn.AutoButtonColor = false
				Btn.ZIndex = 200
				Btn.Parent = btnRow

				local BtnCorner = Instance.new("UICorner")
				BtnCorner.CornerRadius = UDim.new(0, 6)
				BtnCorner.Parent = Btn

				if not isPrimary then
					local BtnStroke = Instance.new("UIStroke")
					BtnStroke.Thickness = 1
					BtnStroke.Color = Color3.fromRGB(55, 55, 60)
					BtnStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
					BtnStroke.Parent = Btn
				end

				local BtnScale = Instance.new("UIScale")
				BtnScale.Scale = 1
				BtnScale.Parent = Btn

				Btn.MouseEnter:Connect(function()
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
			TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(70, 70, 75)}):Play()
		end)
		Frame.MouseLeave:Connect(function()
			TweenService:Create(Stroke, TweenInfo.new(0.15), {Color = Color3.fromRGB(45, 45, 50)}):Play()
		end)

		-- Slide in from right side
		Frame.Position = UDim2.new(0, notifW + 24, 0, 0)
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
				Position = UDim2.new(0, notifW + 24, 0, 0),
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
			end)
			if elapsed >= duration then
				dismiss()
			end
		end)
	end

	return Window
end

-- ==========================================
-- INSTANTIATION & PAGE POPULATION
-- ==========================================
local Window = Astral:CreateWindow({
	Title = "Astral",
	badge = "FREEMIUM",
	badgecolor = Color3.fromRGB(120, 180, 255), -- Light Blue
	Logo = Astral.Icons.Icon1,
	Size = UDim2.fromOffset(750, 500),
	Acrylic = true,
	Theme = "Dark"
})

-- ==========================================
-- INFO SECTION (ALWAYS VISIBLE - NO PAGES/TABS)
-- ==========================================
local Info = Window:CreateInfoSection(_L("Tabs.Info"), "Heart")

Info:AddUserLabel({
	Users = {
		{
			Name = "Lucas",
			Avatar = "https://cdn.discordapp.com/avatars/1401792818158243841/089fbd38c53d39edec92e579aed3edac.png?size=1024",
			Badges = {
				{ Icon = "rbxassetid://110717496833196", Name = "Developer" },
				{ Icon = "rbxassetid://76242675699534", Name = "Owner" }
			},
			Description = "Hi, I'm Lucas. I'm a developer and owner of Astral Hub, working on creating scripts and features for Roblox projects.\n\nI speak Portuguese and English. I'm available to be hired for Roblox scripting projects, including custom scripts, game features, and Lua development. Pricing depends on the game, the difficulty, and the features you want. If you want a private or exclusive script, the price may be higher depending on the project.",
			DiscordTag = "x2.luc4s",
			DiscordId = "1401792818158243841"
		},
		{
			Name = "Velaric",
			Avatar = "https://cdn.discordapp.com/avatars/1331046247599177778/8d0cb69a4a90e9171125d881288a8168.png?size=1024",
			Badges = {
				{ Icon = "rbxassetid://110717496833196", Name = "Developer" },
				{ Icon = "rbxassetid://76242675699534", Name = "Owner" }
			},
			Description = "Hi, I'm Velaric. I'm the owner and developer of Astral Hub, focused on creating scripts, systems, and custom features for Roblox.\n\nI'm available to be hired for Roblox scripting projects, including custom Lua scripts and game development features. Pricing depends on the game, the complexity, and what you need. Private or exclusive scripts will cost more depending on the requirements and difficulty of the project.",
			DiscordTag = "x2velaric",
			DiscordId = "1331046247599177778"
		}
	},
	Position = "Left"
})

Info:AddDiscordLabel({
	ServerData = {
		ServerName = "Astral Hub",
		Description = "Official Astral Hub Community",
		EstablishedDate = "Est. Jun 2025",
		InviteCode = "RhQa6kZu9A",
		ServerIconId = "rbxassetid://106987676739927",
		BackgroundBannerId = "rbxassetid://127861212431489",
		GameLabel = "ROBLOX",
		OnlineCount = 46,
		MemberCount = 593
	},
	Position = "Left"
})

-- ==========================================
-- TEST SECTION
-- ==========================================
--[[ TEST SECTION REMOVED
local TestSection = Window:MakeSection({"Test Section", "shopping"})

local TestPage = TestSection:MakePage({
	Name = "Test Page",
	Description = "Testing random button.",
	Icon = "shopping"
})

if TestPage then
	local TestTab = TestPage:MakeTab({
		Name = "Test",
		Icon = "shopping",
		Description = "Test tab with random button."
	})

	TestTab:AddButton({
		Title = "Random Button",
		Description = "Click me to test!",
		Icon = "click_icon",
		Callback = function()
			print("Random button clicked!")
		end
	})
end
--]]

-- ==========================================
-- NAME SECTION
-- ==========================================
local NameSection = Window:MakeSection({_L("Sections.NameSection"), "Home"})

-- ==========================================
-- SETTINGS SECTION
-- ==========================================
local Settings = Window:MakeSection({"Settings", "settings"})

-- ==========================================
-- NAME SECTION PAGES (CARDS)
-- ==========================================
local ThemeCustomizer = NameSection:MakePage({
	Name = "Theme Customizer",
	Description = "Personalize the interface colors, borders, and styles.",
	Icon = "paintbrush"
})

-- ==========================================
-- SETTINGS PAGES (CARDS)
-- ==========================================
local InterfaceSettingsPage = Settings:MakePage({
	Name = "Interface Settings",
	Description = "Toggle UI elements, transparency, and scaling options.",
	Icon = "setting_ImageLabel"
})

-- NEW PAGE: UI Settings inside Settings Section
local UiSettingsPage = Settings:MakePage({
	Name = "Ui Settings",
	Description = "Configure user interface language and localization options.",
	Icon = "palette"
})

-- ==========================================
-- TEST SECTION (NOTIFICATION SPAMMER)
-- ==========================================
local TestSection = Window:MakeSection({"Tests", "shopping"})

local NotifTestPage = TestSection:MakePage({
	Name = "Notification Tests",
	Description = "Fire test notifications to preview the system.",
	Icon = "shopping"
})

if NotifTestPage then
	local SpamTab = NotifTestPage:MakeTab({
		Name = "Spam",
		Icon = "timer",
		Description = "Spam test notifications."
	})

	SpamTab:AddButton({
		Title = "Spam Notifications",
		Description = "Click to fire 6 test notifications.",
		Icon = "timer",
		Position = "Left",
		Callback = function()
			local types = {"good", "warning", "bad"}
			for i = 1, 6 do
				local t = types[((i - 1) % #types) + 1]
				Window:Notify({
					Type = t,
					Title = "Test #" .. i,
					Message = "This is " .. t .. " notification spam.",
					Duration = 6
				})
				task.wait(0.5)
			end
		end
	})

	SpamTab:AddButton({
		Title = "Spam With Actions",
		Description = "Click to fire 3 action notifications.",
		Icon = "shopping",
		Position = "Right",
		Callback = function()
			for i = 1, 3 do
				Window:Notify({
					Type = "warning",
					Title = "Confirm #" .. i,
					Message = "Action notification spam test.",
					Duration = 8,
					Actions = {
						{Text = "Yes", Type = "bad", Callback = function() print("Spam Yes", i) end},
						{Text = "No", Type = "good", Callback = function() print("Spam No", i) end}
					}
				})
				task.wait(0.7)
			end
		end
	})
end

-- ==========================================
-- TABS INSTANTIATION (THEME CUSTOMIZER)
-- ==========================================
if ThemeCustomizer then
	local ColorsTab = ThemeCustomizer:MakeTab({
		Name = "Colors",
		Icon = "palette",
		Description = "Personalize the interface colors and gradients."
	})

	local BordersTab = ThemeCustomizer:MakeTab({
		Name = "Borders",
		Icon = "CornerIcon",
		Description = "Adjust corner radiuses, stroke thicknesses, and outlines."
	})

	local StylesTab = ThemeCustomizer:MakeTab({
		Name = "Styles",
		Icon = "brush",
		Description = "Toggle acrylic blur, glass effects, and custom themes."
	})

	-- NEW COLOR PICKER (Matches Image Reference Exactly)
	ColorsTab:AddColorPicker({
		Title = "Accent Color",
		Description = "Customize the UI theme",
		Default = Color3.fromRGB(0, 153, 235), -- Blue accent
		Icon = "redo",
		Position = "Left",
		Callback = function(color)
			updateAccentColor(color)
			print("New Accent Color Selected:", color)
		end
	})

	-- NEW PARAGRAPH (Matching Image Reference with Large Image)
	ColorsTab:AddParagraph({
		Title = "Paragarp",
		Description = "DescriptionEZZZZZZZZZZZZZZZZZZZZZZZZZZZ",
		Image = "rbxassetid://16255699706", -- map_background or any image
		Position = "Left"
	})

	-- NEW STATUS LABEL (Static, Non-clickable, No Animations)
	ColorsTab:AddLabel({
		Title = "Status Label",
		Description = "This is a static status display.",
		Icon = "timer",
		Position = "Left"
	})

	-- Example Toggles & Buttons inside a Tab (Demonstrating Position Engine)
	ColorsTab:AddToggle({
		Title = "Rainbow UI Accent",
		Description = "Cycle through the color spectrum dynamically.",
		Default = false,
		Icon = "palette",
		Position = "Left",
		Callback = function(state)
			print("Rainbow UI Accent set to:", state)
		end
	})

	ColorsTab:AddToggle({
		Title = "Enable Acrylic Blur",
		Description = "Applies a premium frosted glass effect.",
		Default = true,
		Icon = "brush",
		Position = "Right",
		Callback = function(state)
			print("Acrylic Blur set to:", state)
		end
	})

	ColorsTab:AddButton({
		Title = "Reset Theme Colors",
		Description = "Revert all custom colors back to factory defaults.",
		Icon = "redo",
		Position = nil,
		Callback = function()
			print("Theme colors reset!")
		end
	})

	ColorsTab:AddButton({
		Title = "Save Configuration",
		Description = "Save your current theme setup to local storage.",
		Icon = "chest",
		Position = nil,
		Callback = function()
			print("Configuration saved!")
		end
	})

	ColorsTab:AddTick({
		Title = "Enable Custom Cursor",
		Description = "Replaces the default game cursor with a custom one.",
		Default = true,
		Position = "Left",
		Callback = function(state)
			print("Custom Cursor:", state)
		end
	})

	ColorsTab:AddSlider({
		Title = "Attack Range",
		Min = 1,
		Max = 100,
		Increase = 1,
		Default = 56,
		Icon = "click_icon",
		Position = "Right",
		Callback = function(val)
			print("Attack Range set to:", val)
		end
	})

	ColorsTab:AddTextbox({
		Title = "Custom Tag Text",
		Description = "Set a custom tag that displays next to your name.",
		Placeholder = "Enter tag...",
		Default = "Astral User",
		Icon = "profile",
		Position = "Left",
		Callback = function(text)
			print("Custom Tag set to:", text)
		end
	})

	ColorsTab:AddSelector({
		Title = "Accent Theme",
		Description = "Choose one or more accent themes to apply to the UI.",
		Options = {"Cyan", "Crimson", "Emerald", "Amethyst", "Gold", "Sapphire", "Ruby"},
		Default = "Sapphire",
		Icon = "palette",
		Search = true,
		Multi = false,
		Position = "Right",
		Callback = function(selected)
			local colors = {
				Cyan = Color3.fromRGB(0, 195, 255),
				Crimson = Color3.fromRGB(255, 45, 85),
				Emerald = Color3.fromRGB(46, 204, 113),
				Amethyst = Color3.fromRGB(130, 90, 255),
				Gold = Color3.fromRGB(241, 196, 15),
				Sapphire = Color3.fromRGB(0, 122, 255), -- Premium Electric Blue
				Ruby = Color3.fromRGB(231, 76, 60)
			}
			local targetColor = colors[selected] or colors.Sapphire
			updateAccentColor(targetColor)
			print("Accent Theme updated to:", selected)
		end
	})

	ColorsTab:AddKeybind({
		Title = "Toggle UI Keybind",
		Default = Enum.KeyCode.RightControl,
		Icon = "keyboard",
		Position = "Left",
		Callback = function(key)
			print("UI Toggle Keybind pressed:", key.Name)
		end
	})
end

-- ==========================================
-- TABS INSTANTIATION (INTERFACE SETTINGS)
-- ==========================================
if InterfaceSettingsPage then
	local GeneralTab = InterfaceSettingsPage:MakeTab({
		Name = "General",
		Icon = "setting_ImageLabel",
		Description = "Configure general interface options."
	})

	GeneralTab:AddToggle({
		Title = "Show FPS Counter",
		Description = "Displays real-time frames per second in the corner.",
		Default = true,
		Icon = "timer",
		Position = "Left",
		Callback = function(state)
			print("FPS Counter:", state)
		end
	})

	GeneralTab:AddToggle({
		Title = "Show Ping Counter",
		Description = "Displays real-time network logic.",
		Default = false,
		Icon = "clock",
		Position = "Right",
		Callback = function(state)
			print("Ping Counter:", state)
		end
	})

	GeneralTab:AddButton({
		Title = "Toggle Layout",
		Description = "Switch between 1-Column and 2-Column layouts.",
		Icon = "palette",
		Position = "Left",
		Callback = function()
			local nextMode = (currentLayoutMode == "TwoColumn") and "OneColumn" or "TwoColumn"
			Astral:SetLayoutMode(nextMode)
			print("Layout mode set to:", nextMode)
		end
	})

	local ImageTab = InterfaceSettingsPage:MakeTab({
		Name = "Image Loader",
		Icon = "palette",
		Description = "Load images from URL links."
	})

	local imageUrl = ""

	local function getAllBgImages()
		local list = {}
		local mainGen3 = ImageTab.LeftColumn:FindFirstAncestor("MainGen3")
		if mainGen3 then
			local bg = mainGen3:FindFirstChild("BackgroundImage")
			if not bg then
				bg = Instance.new("ImageLabel")
				bg.Name = "BackgroundImage"
				bg.Size = UDim2.fromScale(1, 1)
				bg.Position = UDim2.fromScale(0, 0)
				bg.BackgroundTransparency = 1
				bg.ZIndex = 1
				bg.Parent = mainGen3
			end
			table.insert(list, bg)
		end
		return list
	end

	local function getUrlFromTextbox()
		local frame = ImageTab.LeftColumn:FindFirstChild("Image URL_Textbox")
		if frame then
			local box = frame:FindFirstChild("InputBox")
			if box then return box.Text end
		end
		return ""
	end

	ImageTab:AddTextbox({
		Title = "Image URL",
		Description = "Paste a direct image link and press Load.",
		Placeholder = "https://example.com/image.png",
		Default = "",
		Position = "Left",
		Callback = function(text)
			imageUrl = text
		end
	})

	ImageTab:AddButton({
		Title = _L("ImageLoader.Title"),
		Description = "Download and set the image as UI background.",
		Icon = "palette",
		Position = "Right",
		Callback = function()
			local url = imageUrl
			if url == "" then url = getUrlFromTextbox() end
			if url == "" then return end
			local asset = GetIconOnWeb(url)
			local targets = getAllBgImages()
			for _, bg in ipairs(targets) do
				bg.Image = asset
				bg.ImageColor3 = Color3.fromRGB(255, 255, 255)
				bg.ScaleType = Enum.ScaleType.Fit
			end
			if writefile then
				pcall(function() writefile("astral_bg_url.txt", url) end)
			end
		end
	})

	ImageTab:AddButton({
		Title = _L("ImageLoader.Reset"),
		Description = "Restore the default UI background.",
		Icon = "palette",
		Position = "Left",
		Callback = function()
			local targets = getAllBgImages()
			for _, bg in ipairs(targets) do
				bg.Image = Astral.Icons.map_background
				bg.ImageColor3 = Color3.fromRGB(15, 15, 15)
				bg.ScaleType = Enum.ScaleType.Crop
			end
			if writefile then
				pcall(function() writefile("astral_bg_url.txt", "") end)
			end
		end
	})
end

-- Auto-load saved background URL on script start
if isfile and readfile and writefile then
	local ok, saved = pcall(function() return readfile("astral_bg_url.txt") end)
	if ok and saved and saved ~= "" then
		task.spawn(function()
			task.wait(0.5)
			local asset = GetIconOnWeb(saved)
			local function findAndApply(p)
				local bg = p:FindFirstChild("BackgroundImage")
				if bg then
					bg.Image = asset
					bg.ImageColor3 = Color3.fromRGB(255, 255, 255)
					bg.ScaleType = Enum.ScaleType.Fit
					return
				end
				for _, c in ipairs(p:GetChildren()) do
					findAndApply(c)
				end
			end
			local gui = PlayerGui and PlayerGui:FindFirstChild("MainGen3Gui")
			if gui then
				findAndApply(gui)
			end
		end)
	end
end

-- ==========================================
-- TABS INSTANTIATION (UI SETTINGS)
-- ==========================================
if UiSettingsPage then
	local LanguageTab = UiSettingsPage:MakeTab({
		Name = "Language",
		Icon = "guide_icon",
		Description = "Select your preferred language for the interface."
	})

	LanguageTab:AddSelector({
		Title = "Select Language",
		Description = "Choose your preferred language for the interface.",
		Options = {
			"English", 
			"Spanish (Español)", 
			"French (Français)", 
			"German (Deutsch)", 
			"Japanese (日本語)",
			"Portuguese (Português)"
		},
		Default = "English",
		Icon = "guide_icon",
		Search = true,
		Multi = false,
		Position = "Left",
		Callback = function(selected)
			Astral:SetLanguage(selected)
		end
	})
end

-- Immediate notification test
local ok, err = pcall(Window.Notify, Window, {Type = "good", Title = "Test", Message = "If you see this, notifications work!", Duration = 8})
if not ok then warn("Notify immediate error:", err) end

-- Demo notifications to preview the system
delay(0.5, function()
	local ok, err = pcall(Window.Notify, Window, {
		Type = "good",
		Title = "Welcome to Astral",
		Message = "Interface loaded successfully.",
		Duration = 6
	})
	if not ok then warn("Notify error:", err) end
end)
delay(2, function()
	local ok, err = pcall(Window.Notify, Window, {
		Type = "warning",
		Title = "Reset Configuration?",
		Message = "Would you like to restore defaults?",
		Duration = 6,
		Actions = {
			{Text = "Yes", Type = "bad", Callback = function() print("Config reset") end},
			{Text = "No", Type = "good", Callback = function() print("Kept config") end}
		}
	})
	if not ok then warn("Notify error:", err) end
end)
delay(3.5, function()
	local ok, err = pcall(Window.Notify, Window, {
		Type = "bad",
		Title = "Connection Lost",
		Message = "Failed to reach server. Retrying...",
		Duration = 6
	})
	if not ok then warn("Notify error:", err) end
end)

-- Mobile UI Scaling
if isMobile then
	local scaleGui = Instance.new("ScreenGui")
	scaleGui.Name = "AstralScaleGui"
	scaleGui.ResetOnSpawn = false
	scaleGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	scaleGui.Parent = PlayerGui
	local scale = Instance.new("UIScale")
	scale.Scale = 0.7
	scale.Parent = scaleGui
end

return Astral