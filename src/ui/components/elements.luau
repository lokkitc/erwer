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
			if BindTheme then
				BindTheme(toggleBtn, "BackgroundColor3", enabled and "Accent" or "Stroke")
			end
			posSpring:SetTarget(enabled and L.ToggleKnobOn or L.ToggleKnobOff)
		end

		toggleBtn.MouseButton1Click:Connect(function()
			enabled = not enabled
			update()
			callback(enabled)
		end)

		task.spawn(function()
			while frame.Parent do
				local pos = posSpring:Update(1 / 60)
				knob.Position = UDim2.new(0, pos, 0.5, 0)
				RunService.Heartbeat:Wait()
			end
		end)

		update()
		return frame
	end

	local function Dropdown(title, options, default, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, L.DropdownHeight)
		frame.BackgroundTransparency = 1

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = theme().Glass
		bind(btn, "BackgroundColor3", "Glass")
		btn.Text = title .. ": " .. default
		btn.TextColor3 = theme().Text
		bind(btn, "TextColor3", "Text")
		btn.Font = L.FontBody
		btn.TextSize = L.TextBody
		btn.Parent = frame

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, L.DropdownCorner)

		local currentIdx = table.find(options, default) or 1
		btn.MouseButton1Click:Connect(function()
			currentIdx = (currentIdx % #options) + 1
			local val = options[currentIdx]
			btn.Text = title .. ": " .. val
			callback(val)
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
