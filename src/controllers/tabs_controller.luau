local TabsController = {}

function TabsController.new(deps)
	local self = {
		Config = deps.Config,
		State = deps.State,
		ThemeService = deps.ThemeService,
		Services = deps.Services,
		UI = deps.UI,
		Elements = deps.Elements,

		_tabs = {},
		_tabButtons = {},
		_indicatorSpring = nil,
	}
	return setmetatable(self, { __index = TabsController })
end

function TabsController:Init()
	local L = self.Config.Layout
	local sidebar = self.UI.Sidebar
	local indicator = self.UI.Indicator

	self._indicatorSpring = self.Services.Spring.new(L.TitleBarHeight + L.SidebarPaddingTop, self.Config.Spring.Damping, self.Config.Spring.Frequency)

	local function createTabButton(name)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, L.SidebarBtnHeight)
		btn.BackgroundTransparency = 1
		btn.Text = name
		btn.TextColor3 = self.ThemeService:GetTheme().TextSecondary
		self.ThemeService:Bind(btn, "TextColor3", "TextSecondary")
		btn.Font = L.FontTab
		btn.TextSize = L.TextTab
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = sidebar

		local pad = Instance.new("UIPadding")
		pad.PaddingLeft = UDim.new(0, 14)
		pad.Parent = btn

		btn.MouseButton1Click:Connect(function()
			self:Switch(name)
		end)

		return btn
	end

	local function createScroll()
		local scroll = Instance.new("ScrollingFrame")
		scroll.Size = UDim2.fromScale(1, 1)
		scroll.BackgroundTransparency = 1
		scroll.CanvasSize = UDim2.fromOffset(0, 0)
		scroll.ScrollingDirection = Enum.ScrollingDirection.Y
		scroll.ClipsDescendants = false
		scroll.ScrollBarThickness = L.ScrollBarThickness
		scroll.ScrollBarImageColor3 = self.ThemeService:GetTheme().Accent
		self.ThemeService:Bind(scroll, "ScrollBarImageColor3", "Accent")
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Visible = false
		scroll.Parent = self.UI.Content

		local list = Instance.new("UIListLayout")
		list.Padding = UDim.new(0, L.ScrollPadding)
		list.SortOrder = Enum.SortOrder.LayoutOrder
		list.Parent = scroll

		return scroll
	end

	local TabHome = self.Services.Loader:Load("src/ui/tabs/home.luau")
	local TabEgg = self.Services.Loader:Load("src/ui/tabs/egg.luau")
	local TabSettings = self.Services.Loader:Load("src/ui/tabs/settings.luau")
	local TabProfile = self.Services.Loader:Load("src/ui/tabs/profile.luau")
	local TabInfo = self.Services.Loader:Load("src/ui/tabs/info.luau")
	local TabDebug
	local showDebug = false
	pcall(function()
		local p = self.Services.Players and self.Services.Players.LocalPlayer
		showDebug = (p ~= nil and p.Name == "AsuuBkzt")
	end)
	if showDebug then
		TabDebug = self.Services.Loader:Load("src/ui/tabs/debug.luau")
	end

	self._tabButtons["Главная"] = createTabButton("Главная")
	self._tabButtons["Яйцо"] = createTabButton("Яйцо")
	self._tabButtons["Настройки"] = createTabButton("Настройки")
	self._tabButtons["Профиль"] = createTabButton("Профиль")
	self._tabButtons["Инфо"] = createTabButton("Инфо")
	if showDebug then
		self._tabButtons["Дебаг"] = createTabButton("Дебаг")
	end

	self._tabs["Главная"] = TabHome({
		Scroll = createScroll(),
		Config = self.Config,
		State = self.State,
		ThemeService = self.ThemeService,
		Elements = self.Elements,
		Services = self.Services,
	})

	self._tabs["Яйцо"] = TabEgg({
		Scroll = createScroll(),
		Config = self.Config,
		State = self.State,
		ThemeService = self.ThemeService,
		Elements = self.Elements,
		Services = self.Services,
	})

	self._tabs["Настройки"] = TabSettings({
		Scroll = createScroll(),
		Config = self.Config,
		State = self.State,
		ThemeService = self.ThemeService,
		Elements = self.Elements,
		Services = self.Services,
	})

	self._tabs["Профиль"] = TabProfile({
		Scroll = createScroll(),
		Config = self.Config,
		State = self.State,
		ThemeService = self.ThemeService,
		Elements = self.Elements,
		Services = self.Services,
	})

	self._tabs["Инфо"] = TabInfo({
		Scroll = createScroll(),
		Config = self.Config,
		State = self.State,
		ThemeService = self.ThemeService,
		Elements = self.Elements,
		Services = self.Services,
	})

	if showDebug then
		self._tabs["Дебаг"] = TabDebug({
			Scroll = createScroll(),
			Config = self.Config,
			State = self.State,
			ThemeService = self.ThemeService,
			Elements = self.Elements,
			Services = self.Services,
		})
	end

	self:Switch(self.State.CurrentTab or "Главная")

	self.Services.RunService.RenderStepped:Connect(function(dt)
		indicator.Position = UDim2.new(0, 0, 0, self._indicatorSpring:Update(dt))
	end)
end

function TabsController:Switch(tabName)
	self.State.CurrentTab = tabName
	for name, data in pairs(self._tabs) do
		data.Scroll.Visible = (name == tabName)
	end

	local t = self.ThemeService:GetTheme()
	for name, btn in pairs(self._tabButtons) do
		btn.TextColor3 = (name == tabName) and t.Text or t.TextSecondary
	end

	local btn = self._tabButtons[tabName]
	if btn then
		local targetY = btn.AbsolutePosition.Y - self.UI.MainFrame.AbsolutePosition.Y + (btn.AbsoluteSize.Y - self.Config.Layout.IndicatorHeight) / 2
		self._indicatorSpring:SetTarget(targetY)
	end

	self.ThemeService:Apply()
end

return TabsController
