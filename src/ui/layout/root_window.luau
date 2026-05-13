local function CreateRootWindow(deps)
	local gui = deps.Gui
	local Config = deps.Config
	local ThemeService = deps.ThemeService
	local Elements = deps.Elements
	local L = Config.Layout

	local function T()
		return ThemeService:GetTheme()
	end

	local function bind(inst, prop, key)
		ThemeService:Bind(inst, prop, key)
	end

	local restoreBtn = Instance.new("TextButton")
	restoreBtn.Name = "RestoreButton"
	restoreBtn.Size = UDim2.fromOffset(44, 44)
	restoreBtn.Position = UDim2.new(0, 18, 0.5, 0)
	restoreBtn.AnchorPoint = Vector2.new(0, 0.5)
	restoreBtn.BackgroundColor3 = T().Accent
	bind(restoreBtn, "BackgroundColor3", "Accent")
	restoreBtn.BackgroundTransparency = 0.15
	restoreBtn.Text = "B"
	restoreBtn.TextColor3 = Color3.new(1, 1, 1)
	restoreBtn.Font = L.FontButton
	restoreBtn.TextSize = 18
	restoreBtn.Visible = false
	restoreBtn.ZIndex = 50
	restoreBtn.Parent = gui
	Instance.new("UICorner", restoreBtn).CornerRadius = UDim.new(1, 0)
	local restoreStroke = Instance.new("UIStroke")
	restoreStroke.Thickness = 1.2
	restoreStroke.Color = T().Stroke
	bind(restoreStroke, "Color", "Stroke")
	restoreStroke.Transparency = 0.35
	restoreStroke.Parent = restoreBtn

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainWindow"
	mainFrame.Size = Config.Window.InitialSize
	mainFrame.Position = UDim2.fromScale(0.5, 0.5)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = T().Glass
	bind(mainFrame, "BackgroundColor3", "Glass")
	mainFrame.BackgroundTransparency = 0.22
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = gui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, L.WindowCorner)
	uiCorner.Parent = mainFrame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = L.WindowStroke
	uiStroke.Color = T().Stroke
	bind(uiStroke, "Color", "Stroke")
	uiStroke.Transparency = 0.55
	uiStroke.Parent = mainFrame

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
	bind(titleLabel, "TextColor3", "Text")
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

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.fromOffset(L.ControlBtnSize, L.ControlBtnSize)
	closeBtn.Position = UDim2.new(1, -2, 0.5, 0)
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.BackgroundColor3 = T().Danger
	bind(closeBtn, "BackgroundColor3", "Danger")
	closeBtn.BackgroundTransparency = 0.75
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Color3.new(1, 1, 1)
	closeBtn.Font = L.FontButton
	closeBtn.TextSize = L.TextControl
	closeBtn.Parent = controls
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)

	local minimizeBtn = Instance.new("TextButton")
	minimizeBtn.Size = UDim2.fromOffset(L.ControlBtnSize, L.ControlBtnSize)
	minimizeBtn.Position = UDim2.new(1, -L.ControlBtnGap - 2, 0.5, 0)
	minimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
	minimizeBtn.BackgroundColor3 = T().Stroke
	bind(minimizeBtn, "BackgroundColor3", "Stroke")
	minimizeBtn.BackgroundTransparency = 0.75
	minimizeBtn.Text = "−"
	minimizeBtn.TextColor3 = Color3.new(1, 1, 1)
	minimizeBtn.Font = L.FontButton
	minimizeBtn.TextSize = L.TextControl
	minimizeBtn.Parent = controls
	Instance.new("UICorner", minimizeBtn).CornerRadius = UDim.new(1, 0)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, L.SidebarWidth, 1, -L.TitleBarHeight)
	sidebar.Position = UDim2.new(0, 0, 0, L.TitleBarHeight)
	sidebar.BackgroundColor3 = T().Bg
	bind(sidebar, "BackgroundColor3", "Bg")
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
	bind(indicator, "BackgroundColor3", "Accent")
	indicator.BorderSizePixel = 0
	indicator.ZIndex = 2
	indicator.Parent = mainFrame
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(1, 0)

	local sidebarDivider = Instance.new("Frame")
	sidebarDivider.Size = UDim2.new(0, 1, 1, -L.TitleBarHeight)
	sidebarDivider.Position = UDim2.new(0, L.SidebarWidth, 0, L.TitleBarHeight)
	sidebarDivider.BackgroundColor3 = T().Stroke
	bind(sidebarDivider, "BackgroundColor3", "Stroke")
	sidebarDivider.BackgroundTransparency = 0.4
	sidebarDivider.BorderSizePixel = 0
	sidebarDivider.Parent = mainFrame

	local content = Instance.new("Frame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -L.SidebarWidth - L.ContentPaddingX * 2, 1, -L.ContentTopOffset - L.ContentBottomOffset)
	content.Position = UDim2.new(0, L.SidebarWidth + L.ContentPaddingX, 0, L.ContentTopOffset)
	content.BackgroundTransparency = 1
	content.Parent = mainFrame

	return {
		Gui = gui,
		MainFrame = mainFrame,
		TitleBar = titleBar,
		TitleLabel = titleLabel,
		Controls = controls,
		CloseButton = closeBtn,
		MinimizeButton = minimizeBtn,
		Sidebar = sidebar,
		SidebarList = sidebarList,
		Indicator = indicator,
		Content = content,
		RestoreButton = restoreBtn,
		UIScale = uiScale,
		SidebarDivider = sidebarDivider,

		Elements = Elements,
	}
end

return CreateRootWindow
