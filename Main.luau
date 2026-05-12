local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local TweenService = game:GetService("TweenService")

local services = {
	Players = Players,
	RunService = RunService,
	UserInputService = UserInputService,
	HttpService = HttpService,
	TweenService = TweenService,
}

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local URL_BASE = (...)
if type(URL_BASE) ~= "string" or URL_BASE == "" then
	error("URL_BASE missing")
end

local RemoteLoader = loadstring(game:HttpGet(URL_BASE .. "RemoteLoader.luau"))()
local loader = RemoteLoader.new(URL_BASE, HttpService)

local Config = loader:LoadFile("Config.luau")
local Spring = loader:LoadFile("Spring.luau")
local CreateState = loader:LoadFile("State.luau")
local CollectUserData = loader:LoadFile("UserDataCollector.luau")
local CreateUIElements = loader:LoadFile("UIElements.luau")

local State = CreateState(Config)
State.UserData = CollectUserData(player, services)

local function GetTheme()
	if State.Values and State.Values.ThemeName and Config.Theme[State.Values.ThemeName] then
		return Config.Theme[State.Values.ThemeName]
	end
	return Config.Theme.Dark
end

local themeBindings = {}

local function BindTheme(inst, prop, key)
	themeBindings[#themeBindings + 1] = {
		Inst = inst,
		Prop = prop,
		Key = key,
	}
end

local function ApplyTheme()
	local t = GetTheme()
	for i = #themeBindings, 1, -1 do
		local b = themeBindings[i]
		if not b.Inst or not b.Inst.Parent then
			table.remove(themeBindings, i)
		else
			b.Inst[b.Prop] = t[b.Key]
		end
	end
end

local gui = Instance.new("ScreenGui")
gui.Name = "BekezatUI"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = playerGui

local function GetEggTools()
	local tools = {}
	local function scan(container)
		if not container then
			return
		end
		for _, obj in ipairs(container:GetChildren()) do
			if obj:IsA("Tool") and string.find(string.lower(obj.Name), "egg") then
				table.insert(tools, obj.Name)
			end
		end
	end
	scan(player:FindFirstChild("Backpack"))
	scan(player.Character)
	if #tools == 0 then
		table.insert(tools, "Нет %Egg tools")
	end
	table.sort(tools)
	return tools
end

local Elements = CreateUIElements({
	Config = Config,
	Spring = Spring,
	Services = services,
	GetEggTools = GetEggTools,
	GetTheme = GetTheme,
	BindTheme = BindTheme,
})

local L = Config.Layout
local function T()
	return GetTheme()
end

local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainWindow"
mainFrame.Size = Config.Window.InitialSize
mainFrame.Position = UDim2.fromScale(0.5, 0.5)
mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
mainFrame.BackgroundColor3 = T().Glass
BindTheme(mainFrame, "BackgroundColor3", "Glass")
mainFrame.BackgroundTransparency = 0.22
mainFrame.BorderSizePixel = 0
mainFrame.Parent = gui

local uiCorner = Instance.new("UICorner")
uiCorner.CornerRadius = UDim.new(0, L.WindowCorner)
uiCorner.Parent = mainFrame

local uiStroke = Instance.new("UIStroke")
uiStroke.Thickness = L.WindowStroke
uiStroke.Color = T().Stroke
BindTheme(uiStroke, "Color", "Stroke")
uiStroke.Transparency = 0.55
uiStroke.Parent = mainFrame

local glassGradient = Instance.new("UIGradient")
glassGradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 50)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 20, 32)),
})
glassGradient.Transparency = NumberSequence.new({
	NumberSequenceKeypoint.new(0, 0.05),
	NumberSequenceKeypoint.new(1, 0.12),
})
glassGradient.Rotation = 170
glassGradient.Parent = mainFrame

local uiScale = Instance.new("UIScale")
uiScale.Scale = 1
uiScale.Parent = mainFrame

local titleBar = Instance.new("Frame")
titleBar.Name = "TitleBar"
titleBar.Size = UDim2.new(1, 0, 0, L.TitleBarHeight)
titleBar.BackgroundTransparency = 1
titleBar.Parent = mainFrame

local titleLabel = Instance.new("TextLabel")
titleLabel.Size = UDim2.new(1, -140, 1, 0)
titleLabel.Position = UDim2.new(0, L.IconSize + 14, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = Config.Window.Title .. " <font color='#881798'>" .. Config.Window.Version .. "</font>"
titleLabel.TextColor3 = T().Text
BindTheme(titleLabel, "TextColor3", "Text")
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.RichText = true
titleLabel.Font = L.FontTitle
titleLabel.TextSize = L.TextTitle
titleLabel.Parent = titleBar

local controls = Instance.new("Frame")
controls.Size = UDim2.new(0, L.ControlBtnSize * 3 + L.ControlBtnGap * 2 + 8, 1, 0)
controls.Position = UDim2.new(1, -L.ControlsRightMargin, 0, 0)
controls.AnchorPoint = Vector2.new(1, 0)
controls.BackgroundTransparency = 1
controls.Parent = titleBar

local function createControlButton(icon, color, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(L.ControlBtnSize, L.ControlBtnSize)
	btn.BackgroundColor3 = color
	btn.BackgroundTransparency = 0.75
	btn.Text = icon
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = L.FontButton
	btn.TextSize = L.TextControl
	btn.Parent = controls

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(callback)

	local hoverSpring = Spring.new(0.75, Config.Spring.Damping, Config.Spring.Frequency)
	btn.MouseEnter:Connect(function()
		hoverSpring:SetTarget(0.4)
	end)
	btn.MouseLeave:Connect(function()
		hoverSpring:SetTarget(0.75)
	end)

	task.spawn(function()
		while btn.Parent do
			btn.BackgroundTransparency = hoverSpring:Update(1 / 60)
			RunService.Heartbeat:Wait()
		end
	end)

	return btn
end

local function SaveState()
	local data = {
		PosXScale = mainFrame.Position.X.Scale,
		PosXOffset = mainFrame.Position.X.Offset,
		PosYScale = mainFrame.Position.Y.Scale,
		PosYOffset = mainFrame.Position.Y.Offset,
		SizeX = mainFrame.Size.X.Offset,
		SizeY = mainFrame.Size.Y.Offset,
		Volume = State.Values.Volume,
		MusicEnabled = State.Values.MusicEnabled,
		SelectedMode = State.Values.SelectedMode,
		Nickname = State.Values.Nickname,
	}
	player:SetAttribute(Config.SaveKey, HttpService:JSONEncode(data))
end

local function LoadState()
	local saved = player:GetAttribute(Config.SaveKey)
	if not saved then
		return
	end
	local ok, data = pcall(function()
		return HttpService:JSONDecode(saved)
	end)
	if not ok or type(data) ~= "table" then
		return
	end
	if data.PosXScale then
		mainFrame.Position = UDim2.new(data.PosXScale, data.PosXOffset or 0, data.PosYScale, data.PosYOffset or 0)
	end
	if data.SizeX then
		mainFrame.Size = UDim2.fromOffset(data.SizeX, data.SizeY or Config.Window.InitialSize.Y.Offset)
	end
	if data.Volume then
		State.Values.Volume = data.Volume
	end
	if data.MusicEnabled ~= nil then
		State.Values.MusicEnabled = data.MusicEnabled
	end
	if data.SelectedMode then
		State.Values.SelectedMode = data.SelectedMode
	end
	if data.Nickname then
		State.Values.Nickname = data.Nickname
	end
end

local closeBtn = createControlButton("×", T().Danger, function()
	SaveState()
	gui:Destroy()
end)
BindTheme(closeBtn, "BackgroundColor3", "Danger")
closeBtn.Position = UDim2.new(1, -2, 0.5, 0)
closeBtn.AnchorPoint = Vector2.new(1, 0.5)

local windowScaleSpring = Spring.new(uiScale.Scale, Config.Spring.Damping, Config.Spring.Frequency)
local windowAlphaSpring = Spring.new(0.22, Config.Spring.Damping, Config.Spring.Frequency)

local function AnimateWindow()
	if State.Open then
		mainFrame.Visible = true
		windowScaleSpring:SetTarget(1)
		windowAlphaSpring:SetTarget(0.22)
	else
		windowScaleSpring:SetTarget(0.7)
		windowAlphaSpring:SetTarget(1)
	end
end

local minimizeBtn = createControlButton("−", Color3.fromRGB(255, 185, 70), function()
	State.Open = not State.Open
	AnimateWindow()
end)
minimizeBtn.Position = UDim2.new(1, -L.ControlBtnGap - 2, 0.5, 0)
minimizeBtn.AnchorPoint = Vector2.new(1, 0.5)

local sidebar = Instance.new("Frame")
sidebar.Name = "Sidebar"
sidebar.Size = UDim2.new(0, L.SidebarWidth, 1, -L.TitleBarHeight)
sidebar.Position = UDim2.new(0, 0, 0, L.TitleBarHeight)
sidebar.BackgroundColor3 = T().Bg
BindTheme(sidebar, "BackgroundColor3", "Bg")
sidebar.BackgroundTransparency = 1
sidebar.BorderSizePixel = 0
sidebar.Parent = mainFrame

local sidebarList = Instance.new("UIListLayout")
sidebarList.FillDirection = Enum.FillDirection.Vertical
sidebarList.SortOrder = Enum.SortOrder.LayoutOrder
sidebarList.Padding = UDim.new(0, L.SidebarGap)
sidebarList.Parent = sidebar

local sidebarPadding = Instance.new("UIPadding")
sidebarPadding.PaddingTop = UDim.new(0, L.SidebarPaddingTop)
sidebarPadding.PaddingLeft = UDim.new(0, 8)
sidebarPadding.PaddingRight = UDim.new(0, 8)
sidebarPadding.Parent = sidebar

local indicator = Instance.new("Frame")
indicator.Name = "Indicator"
indicator.Size = UDim2.new(0, L.IndicatorWidth, 0, L.IndicatorHeight)
indicator.Position = UDim2.new(0, 0, 0, L.TitleBarHeight + L.SidebarPaddingTop)
indicator.BackgroundColor3 = T().Accent
BindTheme(indicator, "BackgroundColor3", "Accent")
indicator.BorderSizePixel = 0
indicator.ZIndex = 2
indicator.Parent = mainFrame

local indicatorCorner = Instance.new("UICorner")
indicatorCorner.CornerRadius = UDim.new(1, 0)
indicatorCorner.Parent = indicator

local indicatorSpring = Spring.new(L.TitleBarHeight + L.SidebarPaddingTop, Config.Spring.Damping, Config.Spring.Frequency)

local sidebarDivider = Instance.new("Frame")
sidebarDivider.Size = UDim2.new(0, 1, 1, -L.TitleBarHeight)
sidebarDivider.Position = UDim2.new(0, L.SidebarWidth, 0, L.TitleBarHeight)
sidebarDivider.BackgroundColor3 = T().Stroke
BindTheme(sidebarDivider, "BackgroundColor3", "Stroke")
sidebarDivider.BackgroundTransparency = 0.4
sidebarDivider.BorderSizePixel = 0
sidebarDivider.Parent = mainFrame

local content = Instance.new("Frame")
content.Name = "Content"
content.Size = UDim2.new(1, -L.SidebarWidth - L.ContentPaddingX * 2, 1, -L.ContentTopOffset - L.ContentBottomOffset)
content.Position = UDim2.new(0, L.SidebarWidth + L.ContentPaddingX, 0, L.ContentTopOffset)
content.BackgroundTransparency = 1
content.Parent = mainFrame

local tabs = {}
local tabButtons = {}

local function SwitchTab(tabName)
	State.CurrentTab = tabName
	for name, frame in pairs(tabs) do
		frame.Visible = name == tabName
	end
	for name, btn in pairs(tabButtons) do
		btn.TextColor3 = (name == tabName) and T().Text or T().TextSecondary
	end
	ApplyTheme()
	local btn = tabButtons[tabName]
	if btn then
		local targetY = btn.AbsolutePosition.Y - mainFrame.AbsolutePosition.Y + (btn.AbsoluteSize.Y - L.IndicatorHeight) / 2
		indicatorSpring:SetTarget(targetY)
	end
end

local function createTabButton(name)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, L.SidebarBtnHeight)
	btn.BackgroundTransparency = 1
	btn.Text = name
	btn.TextColor3 = T().TextSecondary
	BindTheme(btn, "TextColor3", "TextSecondary")
	btn.Font = L.FontTab
	btn.TextSize = L.TextTab
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = sidebar

	local btnPadding = Instance.new("UIPadding")
	btnPadding.PaddingLeft = UDim.new(0, 14)
	btnPadding.Parent = btn

	btn.MouseEnter:Connect(function()
		if State.CurrentTab ~= name then
			btn.TextColor3 = T().Text
		end
	end)
	btn.MouseLeave:Connect(function()
		if State.CurrentTab ~= name then
			btn.TextColor3 = T().TextSecondary
		end
	end)
	btn.MouseButton1Click:Connect(function()
		SwitchTab(name)
	end)

	return btn
end

local function CreateTabContent(tabName)
	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.fromScale(1, 1)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = L.ScrollBarThickness
	scroll.ScrollBarImageColor3 = T().Accent
	BindTheme(scroll, "ScrollBarImageColor3", "Accent")
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Visible = false
	scroll.Parent = content

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, L.ScrollPadding)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll

	if tabName == "Главная" then
		local selectedEgg = "None"
		local eggTools = GetEggTools()
		local eggDropdown = Elements.Dropdown("Egg Tool", eggTools, eggTools[1] or "None", function(value)
			selectedEgg = value
			print("🥚 Selected Egg:", value)
		end)
		eggDropdown.Parent = scroll

		local button = eggDropdown:FindFirstChildWhichIsA("TextButton")
		local clickConn

		local function attachClick(tools)
			if clickConn then
				clickConn:Disconnect()
				clickConn = nil
			end
			local currentIdx = table.find(tools, selectedEgg) or 1
			if button then
				button.Text = "Egg Tool: " .. (tools[currentIdx] or "None")
				clickConn = button.MouseButton1Click:Connect(function()
					currentIdx = (currentIdx % #tools) + 1
					local val = tools[currentIdx]
					button.Text = "Egg Tool: " .. val
					selectedEgg = val
					print("🥚 Selected Egg:", val)
				end)
			end
		end

		attachClick(eggTools)

		task.spawn(function()
			while eggDropdown.Parent do
				task.wait(2)
				local newTools = GetEggTools()
				attachClick(newTools)
			end
			if clickConn then
				clickConn:Disconnect()
			end
		end)

	elseif tabName == "Настройки" then
		local themeList = {"Dark", "Light"}
		local themeDropdown = Elements.Dropdown("Тема", themeList, State.Values.ThemeName or "Dark", function(v)
			State.Values.ThemeName = v
			ApplyTheme()
		end)
		themeDropdown.Parent = scroll
	elseif tabName == "Профиль" then
		local ud = State.UserData
		local profileRow = Instance.new("Frame")
		profileRow.Size = UDim2.new(1, 0, 0, L.AvatarSize)
		profileRow.BackgroundTransparency = 1
		profileRow.Parent = scroll

		local avatar = Instance.new("ImageLabel")
		avatar.Size = UDim2.new(0, L.AvatarSize, 0, L.AvatarSize)
		avatar.BackgroundTransparency = 1
		avatar.Image = ud.AvatarUrl or ""
		avatar.Parent = profileRow

		local avatarCorner = Instance.new("UICorner")
		avatarCorner.CornerRadius = UDim.new(0, L.AvatarCorner)
		avatarCorner.Parent = avatar

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(1, -L.AvatarSize - 12, 0, L.ProfileRowHeight)
		nameLbl.Position = UDim2.new(0, L.AvatarSize + 12, 0, (L.AvatarSize - L.ProfileRowHeight) / 2)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = ud.DisplayName .. "\n@" .. ud.Username
		nameLbl.TextColor3 = T().Text
		BindTheme(nameLbl, "TextColor3", "Text")
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextYAlignment = Enum.TextYAlignment.Center
		nameLbl.Font = L.FontTab
		nameLbl.TextSize = L.TextBody
		nameLbl.Parent = profileRow

		local infoFields = {
			{ "UserID", tostring(ud.UserId) },
			{ "Возраст аккаунта", tostring(ud.AccountAge) .. " дней" },
			{ "Подписка", ud.MembershipType },
			{ "Верифицирован", ud.IsVerified and "Да" or "Нет" },
			{ "Локаль", ud.LocaleId },
			{ "Команда", ud.Team },
			{ "Здоровье", tostring(ud.Health) .. "/" .. tostring(ud.MaxHealth) },
			{ "Скорость", tostring(ud.WalkSpeed) },
			{ "Прыжок", tostring(ud.JumpPower) },
			{ "Платформа", ud.Platform },
		}

		for _, field in ipairs(infoFields) do
			local row = Instance.new("TextLabel")
			row.Size = UDim2.new(1, 0, 0, L.ProfileRowHeight)
			row.BackgroundTransparency = 1
			row.RichText = true
			row.Text = '<font color="#9B9BAA">' .. field[1] .. '</font>  <font color="#F5F5FA">' .. tostring(field[2]) .. '</font>'
			row.TextXAlignment = Enum.TextXAlignment.Left
			row.Font = L.FontBody
			row.TextSize = 12
			BindTheme(row, "TextColor3", "Text")
			row.Parent = scroll
		end
	elseif tabName == "Инфо" then
		local info = Instance.new("TextLabel")
		info.Size = UDim2.new(1, 0, 0, L.InfoHeight)
		info.BackgroundTransparency = 1
		info.Text = "Bekezat Erdos Bot"
		info.TextColor3 = T().TextSecondary
		BindTheme(info, "TextColor3", "TextSecondary")
		info.TextWrapped = true
		info.Font = L.FontBody
		info.TextSize = L.TextInfo
		info.Parent = scroll
	end

	return scroll
end

tabButtons["Главная"] = createTabButton("Главная")
tabButtons["Настройки"] = createTabButton("Настройки")
tabButtons["Профиль"] = createTabButton("Профиль")
tabButtons["Инфо"] = createTabButton("Инфо")

tabs["Главная"] = CreateTabContent("Главная")
tabs["Настройки"] = CreateTabContent("Настройки")
tabs["Профиль"] = CreateTabContent("Профиль")
tabs["Инфо"] = CreateTabContent("Инфо")

SwitchTab("Главная")
ApplyTheme()

local dragStart = Vector2.new()
local frameStart = UDim2.new()

titleBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		State.Dragging = true
		dragStart = UserInputService:GetMouseLocation()
		frameStart = mainFrame.Position
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		State.Dragging = false
	end
end)

RunService.RenderStepped:Connect(function(dt)
	if State.Dragging then
		local delta = UserInputService:GetMouseLocation() - dragStart
		mainFrame.Position = frameStart + UDim2.fromOffset(delta.X, delta.Y)
	end
	indicator.Position = UDim2.new(0, 0, 0, indicatorSpring:Update(dt))
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end
	if input.KeyCode == Config.Keybind then
		State.Open = not State.Open
		AnimateWindow()
	end
end)

RunService.Heartbeat:Connect(function(dt)
	local s = windowScaleSpring:Update(dt)
	local a = windowAlphaSpring:Update(dt)
	uiScale.Scale = s
	mainFrame.BackgroundTransparency = a
	if not State.Open and a > 0.98 then
		mainFrame.Visible = false
	end
end)

LoadState()

task.spawn(function()
	while gui.Parent do
		task.wait(12)
		SaveState()
	end
end)

gui.Destroying:Connect(SaveState)

return true
