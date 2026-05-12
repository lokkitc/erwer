local function CreateElements(deps)
	local Config = deps.Config
	local Spring = deps.Spring
	local Services = deps.Services
	local GetTheme = deps.GetTheme
	local BindTheme = deps.BindTheme
	local L = Config.Layout

	local RunService = Services.RunService
	local UserInputService = Services.UserInputService

	local function theme()
		if GetTheme then
			return GetTheme()
		end
		if Config.Theme and Config.Theme.Current and Config.Theme[Config.Theme.Current] then
			return Config.Theme[Config.Theme.Current]
		end
		return Config.Theme.Dark
	end

	local function bind(inst, prop, key)
		if BindTheme then
			BindTheme(inst, prop, key)
		end
	end

	local function Toggle(text, default, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, L.ToggleHeight)
		frame.BackgroundTransparency = 1

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.72, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = theme().Text
		bind(label, "TextColor3", "Text")
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = L.FontBody
		label.TextSize = L.TextBody
		label.Parent = frame

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Size = UDim2.fromOffset(L.ToggleWidth, L.ToggleHeight2)
		toggleBtn.Position = UDim2.new(1, -12, 0.5, 0)
		toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
		toggleBtn.BackgroundColor3 = theme().Stroke
		bind(toggleBtn, "BackgroundColor3", "Stroke")
		toggleBtn.Text = ""
		toggleBtn.Parent = frame

		Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("Frame")
		knob.Size = UDim2.fromOffset(L.ToggleKnobSize, L.ToggleKnobSize)
		knob.Position = UDim2.new(0, 3, 0.5, 0)
		knob.AnchorPoint = Vector2.new(0, 0.5)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Parent = toggleBtn
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local enabled = default
		local posSpring = Spring.new(enabled and L.ToggleKnobOn or L.ToggleKnobOff, Config.Spring.Damping, Config.Spring.Frequency)

		local function update()
			local t = theme()
			toggleBtn.BackgroundColor3 = enabled and t.Accent or t.Stroke
			posSpring:SetTarget(enabled and L.ToggleKnobOn or L.ToggleKnobOff)
		end

		toggleBtn.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
			callback(enabled)
		end)

		task.spawn(function()
			while not frame.Parent do
				RunService.Heartbeat:Wait()
			end
			while frame.Parent do
				local dt = RunService.Heartbeat:Wait()
				local pos = posSpring:Update(dt)
				knob.Position = UDim2.new(0, pos, 0.5, 0)
			end
		end)

		update()
		return frame
	end

	local function Dropdown(title, options, default, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, L.DropdownHeight)
		frame.BackgroundTransparency = 1
		frame.ClipsDescendants = false

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, L.DropdownHeight)
		btn.BackgroundColor3 = theme().Glass
		bind(btn, "BackgroundColor3", "Glass")
		btn.Text = title .. ": " .. default
		btn.TextColor3 = theme().Text
		bind(btn, "TextColor3", "Text")
		btn.Font = L.FontBody
		btn.TextSize = L.TextBody
		btn.Parent = frame

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, L.DropdownCorner)

		local listFrame = Instance.new("Frame")
		listFrame.Name = "List"
		listFrame.Size = UDim2.new(1, 0, 0, 0)
		listFrame.Position = UDim2.new(0, 0, 0, L.DropdownHeight + 6)
		listFrame.BackgroundColor3 = theme().Glass
		bind(listFrame, "BackgroundColor3", "Glass")
		listFrame.BackgroundTransparency = 0.12
		listFrame.BorderSizePixel = 0
		listFrame.Visible = false
		listFrame.Parent = frame

		Instance.new("UICorner", listFrame).CornerRadius = UDim.new(0, L.DropdownCorner)

		local stroke = Instance.new("UIStroke")
		stroke.Thickness = 1
		stroke.Transparency = 0.6
		stroke.Color = theme().Stroke
		bind(stroke, "Color", "Stroke")
		stroke.Parent = listFrame

		local layout = Instance.new("UIListLayout")
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Padding = UDim.new(0, 4)
		layout.Parent = listFrame

		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 6)
		padding.PaddingBottom = UDim.new(0, 6)
		padding.PaddingLeft = UDim.new(0, 6)
		padding.PaddingRight = UDim.new(0, 6)
		padding.Parent = listFrame

		local isOpen = false
		local currentVal = default
		local listHeight = 0

		local function rebuild()
			for _, c in ipairs(listFrame:GetChildren()) do
				if c:IsA("TextButton") then
					c:Destroy()
				end
			end

			for i, opt in ipairs(options) do
				local item = Instance.new("TextButton")
				item.Name = "Item" .. tostring(i)
				item.Size = UDim2.new(1, 0, 0, 32)
				item.BackgroundColor3 = theme().Bg
				bind(item, "BackgroundColor3", "Bg")
				item.BackgroundTransparency = 0.25
				item.BorderSizePixel = 0
				item.Text = tostring(opt)
				item.TextColor3 = theme().Text
				bind(item, "TextColor3", "Text")
				item.Font = L.FontBody
				item.TextSize = 14
				item.Parent = listFrame
				Instance.new("UICorner", item).CornerRadius = UDim.new(0, 8)

				item.MouseButton1Click:Connect(function()
					currentVal = opt
					btn.Text = title .. ": " .. tostring(opt)
					isOpen = false
					listFrame.Visible = false
					frame.Size = UDim2.new(1, 0, 0, L.DropdownHeight)
					callback(opt)
				end)
			end
		end

		local function open()
			if isOpen then
				return
			end
			rebuild()
			isOpen = true
			listFrame.Visible = true
			local items = #options
			local targetH = math.min(items, 6) * 36 + 12
			listHeight = targetH
			listFrame.Size = UDim2.new(1, 0, 0, targetH)
			frame.Size = UDim2.new(1, 0, 0, L.DropdownHeight + 6 + targetH)
		end

		local function close()
			isOpen = false
			listFrame.Visible = false
			frame.Size = UDim2.new(1, 0, 0, L.DropdownHeight)
		end

		btn.MouseButton1Click:Connect(function()
			if isOpen then
				close()
			else
				open()
			end
		end)

		UserInputService.InputBegan:Connect(function(input, processed)
			if processed then
				return
			end
			if not isOpen then
				return
			end
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				local pos = UserInputService:GetMouseLocation()
				local absPos = frame.AbsolutePosition
				local absSize = frame.AbsoluteSize
				if pos.X < absPos.X or pos.X > absPos.X + absSize.X or pos.Y < absPos.Y or pos.Y > absPos.Y + absSize.Y then
					close()
				end
			end
		end)

		return frame
	end

	local function Button(text, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, L.ButtonHeight)
		btn.BackgroundColor3 = theme().Accent
		bind(btn, "BackgroundColor3", "Accent")
		btn.Text = text
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = L.FontButton
		btn.TextSize = L.TextButton

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, L.ButtonCorner)
		btn.MouseButton1Click:Connect(callback)
		return btn
	end

	return {
		Toggle = Toggle,
		Dropdown = Dropdown,
		Button = Button,
	}
end

return CreateElements
