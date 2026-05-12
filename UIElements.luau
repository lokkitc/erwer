local function CreateUIElements(deps)
	local Config = deps.Config
	local Spring = deps.Spring
	local Services = deps.Services
	local GetTheme = deps.GetTheme
	local L = Config.Layout

	local RunService = Services.RunService
	local UserInputService = Services.UserInputService

	local function theme()
	return (GetTheme and GetTheme()) or Config.Theme.Dark
	end

	local function CreateToggle(text, default, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, L.ToggleHeight)
		frame.BackgroundTransparency = 1
		frame.Parent = nil

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.72, 0, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = text
		label.TextColor3 = theme().Text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = L.FontBody
		label.TextSize = L.TextBody
		label.Parent = frame

		local toggleBtn = Instance.new("TextButton")
		toggleBtn.Size = UDim2.fromOffset(L.ToggleWidth, L.ToggleHeight2)
		toggleBtn.Position = UDim2.new(1, -12, 0.5, 0)
		toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
		toggleBtn.BackgroundColor3 = theme().Stroke
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
			while frame.Parent do
				local pos = posSpring:Update(1 / 60)
				knob.Position = UDim2.new(0, pos, 0.5, 0)
				RunService.Heartbeat:Wait()
			end
		end)

		update()
		return frame
	end

	local function CreateSlider(text, default, minVal, maxVal, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, L.SliderHeight)
		frame.BackgroundTransparency = 1

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1, 0, 0, L.SliderLabelHeight)
		label.BackgroundTransparency = 1
		label.Text = text .. ": <font color='#881798'>" .. default .. "</font>"
		label.RichText = true
		label.TextColor3 = theme().Text
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = L.FontBody
		label.TextSize = L.TextBody
		label.Parent = frame

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, 0, 0, L.SliderBarHeight)
		bar.Position = UDim2.new(0, 0, 0, 34)
		bar.BackgroundColor3 = theme().Stroke
		bar.Parent = frame
		Instance.new("UICorner", bar).CornerRadius = UDim.new(1, 0)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.new((default - minVal) / (maxVal - minVal), 0, 1, 0)
		fill.BackgroundColor3 = theme().Accent
		fill.Parent = bar
		Instance.new("UICorner", fill).CornerRadius = UDim.new(1, 0)

		local knob = Instance.new("TextButton")
		knob.Size = UDim2.fromOffset(L.SliderKnobSize, L.SliderKnobSize)
		knob.Position = UDim2.new((default - minVal) / (maxVal - minVal), 0, 0.5, 0)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.Text = ""
		knob.Parent = bar
		Instance.new("UICorner", knob).CornerRadius = UDim.new(1, 0)

		local dragging = false
		knob.MouseButton1Down:Connect(function()
			dragging = true
		end)

		UserInputService.InputEnded:Connect(function(inp)
			if inp.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		RunService.RenderStepped:Connect(function()
			if not dragging then
				return
			end
			local mouseX = UserInputService:GetMouseLocation().X
			local barAbs = bar.AbsolutePosition.X
			local barW = bar.AbsoluteSize.X
			local percent = math.clamp((mouseX - barAbs) / barW, 0, 1)
			local value = math.floor(minVal + percent * (maxVal - minVal))

			fill.Size = UDim2.new(percent, 0, 1, 0)
			knob.Position = UDim2.new(percent, 0, 0.5, 0)
			label.Text = text .. ": <font color='#881798'>" .. value .. "</font>"

			callback(value)
		end)

		return frame
	end

	local function CreateButton(text, callback)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 0, L.ButtonHeight)
		btn.BackgroundColor3 = theme().Accent
		btn.Text = text
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.Font = L.FontButton
		btn.TextSize = L.TextButton
		btn.Parent = nil

		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, L.ButtonCorner)

		local hoverSpring = Spring.new(0, Config.Spring.Damping, Config.Spring.Frequency)
		btn.MouseEnter:Connect(function()
			hoverSpring:SetTarget(0.2)
		end)
		btn.MouseLeave:Connect(function()
			hoverSpring:SetTarget(0)
		end)

		task.spawn(function()
			while btn.Parent do
				btn.BackgroundColor3 = theme().Accent:Lerp(Color3.new(1, 1, 1), hoverSpring:Update(1 / 60))
				RunService.Heartbeat:Wait()
			end
		end)

		btn.MouseButton1Click:Connect(callback)
		return btn
	end

	local function CreateDropdown(title, options, default, callback)
		local frame = Instance.new("Frame")
		frame.Size = UDim2.new(1, 0, 0, L.DropdownHeight)
		frame.BackgroundTransparency = 1

		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundColor3 = theme().Glass
		btn.Text = title .. ": " .. default
		btn.TextColor3 = theme().Text
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

	local function CreateTextBox(placeholder, default, callback)
		local box = Instance.new("TextBox")
		box.Size = UDim2.new(1, 0, 0, L.TextBoxHeight)
		box.BackgroundColor3 = theme().Glass
		box.PlaceholderText = placeholder
		box.Text = default
		box.TextColor3 = theme().Text
		box.Font = L.FontBody
		box.TextSize = L.TextBody
		box.ClearTextOnFocus = false

		Instance.new("UICorner", box).CornerRadius = UDim.new(0, L.TextBoxCorner)

		box.FocusLost:Connect(function()
			callback(box.Text)
		end)
		return box
	end

	return {
		Toggle = CreateToggle,
		Slider = CreateSlider,
		Button = CreateButton,
		Dropdown = CreateDropdown,
		TextBox = CreateTextBox,
		GetEggTools = deps.GetEggTools,
	}
end

return CreateUIElements
