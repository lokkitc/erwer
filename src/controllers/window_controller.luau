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
	local restoreBtn = self.UI.RestoreButton
	local camera = workspace.CurrentCamera

	local windowScaleSpring = self.Spring.new(uiScale.Scale, self.Config.Spring.Damping, self.Config.Spring.Frequency)
	local windowAlphaSpring = self.Spring.new(0.22, self.Config.Spring.Damping, self.Config.Spring.Frequency)
	local baseScaleSpring = self.Spring.new(1, self.Config.Spring.Damping, self.Config.Spring.Frequency)
	local dragInput = nil

	local function animate()
		if self.State.Open then
			mainFrame.Visible = true
			if restoreBtn then
				restoreBtn.Visible = false
			end
			windowScaleSpring:SetTarget(1)
			windowAlphaSpring:SetTarget(0.22)
		else
			if restoreBtn then
				restoreBtn.Visible = true
			end
			windowScaleSpring:SetTarget(0.7)
			windowAlphaSpring:SetTarget(1)
		end
	end

	local function updateResponsiveScale()
		if not camera then
			camera = workspace.CurrentCamera
		end
		local vp = camera and camera.ViewportSize
		if not vp then
			return
		end
		local w = math.max(1, vp.X)
		local h = math.max(1, vp.Y)
		local sx = w / math.max(1, self.Config.Window.InitialSize.X.Offset)
		local sy = h / math.max(1, self.Config.Window.InitialSize.Y.Offset)
		local target = math.min(1, math.max(0.62, math.min(sx, sy) * 0.95))
		baseScaleSpring:SetTarget(target)
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

	if restoreBtn then
		restoreBtn.MouseButton1Click:Connect(function()
			self.State.Open = true
			animate()
		end)
	end

	-- Drag
	titleBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.State.Dragging = true
			dragInput = input
			self._dragStart = Vector2.new(input.Position.X, input.Position.Y)
			self._frameStart = mainFrame.Position
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			self.State.Dragging = false
			if dragInput == input then
				dragInput = nil
			end
		end
	end)

	RunService.RenderStepped:Connect(function(dt)
		updateResponsiveScale()
		if self.State.Dragging then
			local curPos
			if dragInput and dragInput.Position then
				curPos = Vector2.new(dragInput.Position.X, dragInput.Position.Y)
			else
				curPos = UserInputService:GetMouseLocation()
			end
			local delta = curPos - self._dragStart
			mainFrame.Position = self._frameStart + UDim2.fromOffset(delta.X, delta.Y)
		end

		local s = windowScaleSpring:Update(dt)
		local bs = baseScaleSpring:Update(dt)
		local a = windowAlphaSpring:Update(dt)
		uiScale.Scale = s * bs
		mainFrame.BackgroundTransparency = a
		if not self.State.Open and a > 0.98 then
			mainFrame.Visible = false
			if restoreBtn then
				restoreBtn.Visible = true
			end
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
