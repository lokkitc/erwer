local function EggTab(deps)
	local scroll = deps.Scroll
	local state = deps.State
	local elements = deps.Elements
	local themeService = deps.ThemeService
	local L = deps.Config.Layout
	local Services = deps.Services
	local RunService = Services.RunService

	local Players = game:GetService("Players")
	local player = Players.LocalPlayer

	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(1, 0, 0, 22)
	header.BackgroundTransparency = 1
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Text = "Настройки яйца"
	header.TextColor3 = themeService:GetTheme().TextSecondary
	themeService:Bind(header, "TextColor3", "TextSecondary")
	header.Font = L.FontTab
	header.TextSize = 14
	header.Parent = scroll

	local function getEggTools()
		local tools = {}
		local function scan(container)
			if not container then
				return
			end
			for _, obj in ipairs(container:GetChildren()) do
				if obj:IsA("Tool") and string.find(string.lower(obj.Name), "egg") then
					tools[#tools + 1] = obj.Name
				end
			end
		end
		scan(player:FindFirstChild("Backpack"))
		scan(player.Character)
		table.sort(tools)
		return tools
	end

	local function findToolByName(name)
		if not name or name == "" then
			return nil
		end
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local t = backpack:FindFirstChild(name)
			if t and t:IsA("Tool") then
				return t
			end
		end
		if player.Character then
			local t = player.Character:FindFirstChild(name)
			if t and t:IsA("Tool") then
				return t
			end
		end
		return nil
	end

	local function equipSelectedEgg()
		local toolName = state.Values.SelectedEggTool
		local tool = findToolByName(toolName)
		if not tool then
			warn("[Egg] Tool not found:", toolName)
			return
		end

		local character = player.Character
		if not character then
			return
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			return
		end

		humanoid:EquipTool(tool)
	end

	local function getNearestCanPlant(maxDist)
		maxDist = maxDist or 80
		local character = player.Character
		if not character then
			return nil
		end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp or not hrp:IsA("BasePart") then
			return nil
		end
		local pl = workspace:FindFirstChild("Farm")
		if not pl then
			return nil
		end
		local farm = pl:FindFirstChild("Farm")
		if not farm then
			return nil
		end
		local important = farm:FindFirstChild("Important")
		if not important then
			return nil
		end
		local loc = important:FindFirstChild("Plant_Locations")
		if not loc then
			return nil
		end

		local best
		local bestD = maxDist
		for _, obj in ipairs(loc:GetChildren()) do
			if obj.Name == "Can_Plant" and obj:IsA("BasePart") then
				local d = (obj.Position - hrp.Position).Magnitude
				if d < bestD then
					bestD = d
					best = obj
				end
			end
		end
		return best
	end

	local function tryPlaceWithRemotes(toolName, canPlant)
		local rs = game:GetService("ReplicatedStorage")
		local ge = rs:FindFirstChild("GameEvents")
		if not ge then
			return false
		end

		local r1 = ge:FindFirstChild("TryUsePlaceableGear")
		local r2 = ge:FindFirstChild("TryUseGear")
		local targetPos = canPlant.Position
		local targetCf = canPlant.CFrame

		local function fire(remote, ...)
			if remote and remote:IsA("RemoteEvent") then
				remote:FireServer(...)
				return true
			end
			return false
		end

		local ok = false
		pcall(function()
			ok = fire(r1, toolName, targetPos)
			or fire(r1, toolName, targetCf)
			or fire(r1, targetPos, toolName)
			or fire(r1, targetCf, toolName)
			or fire(r2, toolName, targetPos)
			or fire(r2, toolName, targetCf)
			or fire(r2, targetPos, toolName)
			or fire(r2, targetCf, toolName)
		end)
		return ok
	end

	local autoConn
	local lastPlace = 0
	local function setAutoPlace(on)
		if autoConn then
			autoConn:Disconnect()
			autoConn = nil
		end
		if not on then
			return
		end
		lastPlace = 0
		autoConn = RunService.Heartbeat:Connect(function()
			if not state.Values.AutoPlaceEgg then
				return
			end
			local now = os.clock()
			if now - lastPlace < 0.35 then
				return
			end
			lastPlace = now

			local toolName = state.Values.SelectedEggTool
			local tool = findToolByName(toolName)
			if not tool then
				return
			end
			equipSelectedEgg()

			local canPlant = getNearestCanPlant(80)
			if not canPlant then
				return
			end

			local fired = tryPlaceWithRemotes(toolName, canPlant)
			if not fired then
				pcall(function()
					tool:Activate()
				end)
			end
		end)
	end

	local tools = getEggTools()
	if #tools == 0 then
		tools = { "Нет Egg tools" }
	end

	local defaultTool = state.Values.SelectedEggTool
	if defaultTool == "" or not table.find(tools, defaultTool) then
		defaultTool = tools[1]
		state.Values.SelectedEggTool = defaultTool
	end

	local eggDropdown = elements.Dropdown("Egg Tool", tools, defaultTool, function(value)
		state.Values.SelectedEggTool = value
		if state.Values.AutoPlaceEgg then
			equipSelectedEgg()
		end
	end)
	eggDropdown.Parent = scroll

	local autoToggle = elements.Toggle("Auto Place Egg", state.Values.AutoPlaceEgg, function(v)
		state.Values.AutoPlaceEgg = v
		if v then
			equipSelectedEgg()
		end
		setAutoPlace(v)
	end)
	autoToggle.Parent = scroll

	local equipBtn = elements.Button("Взять яйцо в руки", function()
		equipSelectedEgg()
	end)
	equipBtn.Parent = scroll

	return {
		Scroll = scroll,
	}
end

return EggTab
