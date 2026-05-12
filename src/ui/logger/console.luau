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
	local spyEnabled = false
	local oldNamecall
	local hookedMt

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

	local function valueToShortString(v)
		local t = typeof(v)
		if t == "string" then
			if #v > 80 then
				return string.format("%q", v:sub(1, 77) .. "...")
			end
			return string.format("%q", v)
		end
		if t == "number" or t == "boolean" or t == "nil" then
			return tostring(v)
		end
		if t == "Instance" then
			return v:GetFullName()
		end
		if t == "Vector3" then
			return string.format("Vector3(%.2f, %.2f, %.2f)", v.X, v.Y, v.Z)
		end
		if t == "CFrame" then
			local p = v.Position
			return string.format("CFrame(%.2f, %.2f, %.2f)", p.X, p.Y, p.Z)
		end
		return "<" .. t .. ">"
	end

	local function argsToShortString(args)
		local parts = {}
		for i = 1, math.min(#args, 8) do
			parts[#parts + 1] = valueToShortString(args[i])
		end
		if #args > 8 then
			parts[#parts + 1] = "..."
		end
		return table.concat(parts, ", ")
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

	function api:EnableRemoteSpy()
		if spyEnabled then
			return true
		end
		local getrawmetatableFn = rawget(_G, "getrawmetatable")
		local setreadonlyFn = rawget(_G, "setreadonly")
		local hookmetamethodFn = rawget(_G, "hookmetamethod")
		local getnamecallmethodFn = rawget(_G, "getnamecallmethod")
		local checkcallerFn = rawget(_G, "checkcaller")
		local newcclosureFn = rawget(_G, "newcclosure")

		if type(getrawmetatableFn) ~= "function" then
			addLine("WARN", "RemoteSpy unavailable: getrawmetatable missing")
			return false
		end
		if type(getnamecallmethodFn) ~= "function" then
			addLine("WARN", "RemoteSpy unavailable: getnamecallmethod missing")
			return false
		end

		local ok, err = pcall(function()
			local mt = getrawmetatableFn(game)
			hookedMt = mt
			if type(setreadonlyFn) == "function" then
				setreadonlyFn(mt, false)
			end

			local function handler(self, ...)
				if type(checkcallerFn) == "function" and checkcallerFn() then
					return oldNamecall(self, ...)
				end

				local method = getnamecallmethodFn()
				if method == "FireServer" or method == "InvokeServer" then
					local cls = typeof(self) == "Instance" and self.ClassName or "?"
					if cls == "RemoteEvent" or cls == "RemoteFunction" then
						local args = { ... }
						addLine("REMOTE", cls .. " " .. self:GetFullName() .. ":" .. method .. "(" .. argsToShortString(args) .. ")")
					end
				end

				return oldNamecall(self, ...)
			end

			if type(hookmetamethodFn) == "function" then
				oldNamecall = hookmetamethodFn(game, "__namecall", (type(newcclosureFn) == "function" and newcclosureFn(handler) or handler))
			else
				oldNamecall = mt.__namecall
				mt.__namecall = (type(newcclosureFn) == "function" and newcclosureFn(handler) or handler)
			end

			if type(setreadonlyFn) == "function" then
				setreadonlyFn(mt, true)
			end
		end)

		if not ok then
			addLine("WARN", "RemoteSpy enable failed: " .. tostring(err))
			return false
		end

		spyEnabled = true
		addLine("INFO", "RemoteSpy enabled")
		return true
	end

	function api:DisableRemoteSpy()
		if not spyEnabled then
			return true
		end
		spyEnabled = false
		addLine("INFO", "RemoteSpy disabled")
		return true
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
