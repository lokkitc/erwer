local function CreateConsole(deps)
	local Gui = deps.Gui
	local Config = deps.Config
	local ThemeService = deps.ThemeService
	local Services = deps.Services
	local L = Config.Layout

	local LogService = game:GetService("LogService")

	local function T()
		return ThemeService:GetTheme()
	end

	local screen = Instance.new("Frame")
	screen.Name = "Console"
	screen.Size = UDim2.fromOffset(520, 220)
	screen.Position = UDim2.new(0.5, 0, 1, -14)
	screen.AnchorPoint = Vector2.new(0.5, 1)
	screen.BackgroundColor3 = T().Glass
	ThemeService:Bind(screen, "BackgroundColor3", "Glass")
	screen.BackgroundTransparency = 0.08
	screen.BorderSizePixel = 0
	screen.Visible = false
	screen.Parent = Gui
	Instance.new("UICorner", screen).CornerRadius = UDim.new(0, 10)

	local stroke = Instance.new("UIStroke")
	stroke.Thickness = 1
	stroke.Transparency = 0.6
	stroke.Color = T().Stroke
	ThemeService:Bind(stroke, "Color", "Stroke")
	stroke.Parent = screen

	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(1, -12, 0, 26)
	title.Position = UDim2.new(0, 12, 0, 8)
	title.BackgroundTransparency = 1
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Text = "Console"
	title.TextColor3 = T().Text
	ThemeService:Bind(title, "TextColor3", "Text")
	title.Font = L.FontTab
	title.TextSize = 14
	title.Parent = screen

	local clearBtn = Instance.new("TextButton")
	clearBtn.Name = "Clear"
	clearBtn.Size = UDim2.fromOffset(70, 24)
	clearBtn.Position = UDim2.new(1, -12, 0, 8)
	clearBtn.AnchorPoint = Vector2.new(1, 0)
	clearBtn.BackgroundColor3 = T().Stroke
	ThemeService:Bind(clearBtn, "BackgroundColor3", "Stroke")
	clearBtn.BackgroundTransparency = 0.35
	clearBtn.BorderSizePixel = 0
	clearBtn.Text = "Clear"
	clearBtn.TextColor3 = T().Text
	ThemeService:Bind(clearBtn, "TextColor3", "Text")
	clearBtn.Font = L.FontBody
	clearBtn.TextSize = 13
	clearBtn.Parent = screen
	Instance.new("UICorner", clearBtn).CornerRadius = UDim.new(0, 8)

	local scroll = Instance.new("ScrollingFrame")
	scroll.Name = "Scroll"
	scroll.Size = UDim2.new(1, -16, 1, -50)
	scroll.Position = UDim2.new(0, 8, 0, 40)
	scroll.BackgroundTransparency = 1
	scroll.BorderSizePixel = 0
	scroll.CanvasSize = UDim2.fromOffset(0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.ScrollBarThickness = 4
	scroll.ScrollBarImageColor3 = T().Accent
	ThemeService:Bind(scroll, "ScrollBarImageColor3", "Accent")
	scroll.Parent = screen

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 4)
	list.SortOrder = Enum.SortOrder.LayoutOrder
	list.Parent = scroll

	local pad = Instance.new("UIPadding")
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = scroll

	local maxLines = 200
	local lines = {}

	local function addLine(kind, text)
		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Size = UDim2.new(1, -8, 0, 0)
		lbl.AutomaticSize = Enum.AutomaticSize.Y
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextYAlignment = Enum.TextYAlignment.Top
		lbl.Font = Enum.Font.Code
		lbl.TextSize = 13
		lbl.TextWrapped = true
		lbl.Text = "[" .. kind .. "] " .. tostring(text)
		lbl.TextColor3 = T().TextSecondary
		ThemeService:Bind(lbl, "TextColor3", "TextSecondary")
		lbl.Parent = scroll

		table.insert(lines, lbl)
		if #lines > maxLines then
			local first = table.remove(lines, 1)
			if first then
				first:Destroy()
			end
		end

		Services.RunService.Heartbeat:Wait()
		scroll.CanvasPosition = Vector2.new(0, math.huge)
	end

	clearBtn.MouseButton1Click:Connect(function()
		for _, lbl in ipairs(lines) do
			if lbl then
				lbl:Destroy()
			end
		end
		lines = {}
	end)

	local msgConn
	msgConn = LogService.MessageOut:Connect(function(message, messageType)
		local kind = "INFO"
		if messageType == Enum.MessageType.MessageWarning then
			kind = "WARN"
		elseif messageType == Enum.MessageType.MessageError then
			kind = "ERROR"
		end
		addLine(kind, message)
	end)

	local api = {}
	function api:SetVisible(v)
		screen.Visible = v and true or false
	end

	function api:Toggle()
		screen.Visible = not screen.Visible
	end

	function api:Log(kind, text)
		addLine(kind or "INFO", text)
	end

	function api:Destroy()
		if msgConn then
			msgConn:Disconnect()
			msgConn = nil
		end
		screen:Destroy()
	end

	return api
end

return CreateConsole
