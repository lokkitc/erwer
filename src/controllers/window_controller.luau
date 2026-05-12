local WindowController = {}

function WindowController.new(deps)
	local self = {
		Config = deps.Config,
		State = deps.State,
		ThemeService = deps.ThemeService,
		Spring = deps.Spring,
		Services = deps.Services,
		UI = deps.UI,
		Persistence = deps.Persistence,

		_dragStart = Vector2.new(),
		_frameStart = UDim2.new(),
	}
	return setmetatable(self, { __index = WindowController })
end

function WindowController:Init()
	local RunService = self.Services.RunService
	local UserInputService = self.Services.UserInputService

	local mainFrame = self.UI.MainFrame
	local titleBar = self.UI.TitleBar
	local uiScale = self.UI.UIScale

	local windowScaleSpring = self.Spring.new(uiScale.Scale, self.Config.Spring.Damping, self.Config.Spring.Frequency)
	local windowAlphaSpring = self.Spring.new(0.22, self.Config.Spring.Damping, self.Config.Spring.Frequency)

	local function animate()
		if self.State.Open then
			mainFrame.Visible = true
			windowScaleSpring:SetTarget(1)
			windowAlphaSpring:SetTarget(0.22)
		else
			windowScaleSpring:SetTarget(0.7)
			windowAlphaSpring:SetTarget(1)
		end
	end

	-- Load persisted state
	local data = self.Persistence:Load()
	if data then
		mainFrame.Position = UDim2.new(data.PosXScale or 0.5, data.PosXOffset or 0, data.PosYScale or 0.5, data.PosYOffset or 0)
		mainFrame.Size = UDim2.fromOffset(data.SizeX or self.Config.Window.InitialSize.X.Offset, data.SizeY or self.Config.Window.InitialSize.Y.Offset)
		if type(data.Values) == "table" then
			for k, v in pairs(data.Values) do
				self.State.Values[k] = v
			end
		end
	end

	animate()
	self.ThemeService:Apply()

	-- Buttons
	self.UI.CloseButton.MouseButton1Click:Connect(function()
		self.Persistence:Save(mainFrame, self.State.Values)
		self.State.Destroyed = true
		if self.UI.Gui and self.UI.Gui.Parent then
			self.UI.Gui:Destroy()
		end
	end)

	self.UI.MinimizeButton.MouseButton1Click:Connect(function()
		self.State.Open = not self.State.Open
		animate()
	end)

	-- Drag
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.State.Dragging = true
			self._dragStart = UserInputService:GetMouseLocation()
			self._frameStart = mainFrame.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			self.State.Dragging = false
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		if self.State.Dragging then
			local delta = UserInputService:GetMouseLocation() - self._dragStart
			mainFrame.Position = self._frameStart + UDim2.fromOffset(delta.X, delta.Y)
		end

		local s = windowScaleSpring:Update(dt)
		local a = windowAlphaSpring:Update(dt)
		uiScale.Scale = s
		mainFrame.BackgroundTransparency = a
		if not self.State.Open and a > 0.98 then
			mainFrame.Visible = false
		end
	end)

	-- Hotkey
	UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == self.Config.Keybind then
			self.State.Open = not self.State.Open
			animate()
		end
	end)

	-- Autosave
	task.spawn(function()
		while not self.State.Destroyed and self.UI.MainFrame and self.UI.MainFrame.Parent do
			task.wait(12)
			self.Persistence:Save(mainFrame, self.State.Values)
		end
	end)

	mainFrame.Destroying:Connect(function()
		pcall(function()
			self.Persistence:Save(mainFrame, self.State.Values)
		end)
	end)
end

return WindowController
