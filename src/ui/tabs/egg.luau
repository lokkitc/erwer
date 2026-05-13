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
				if obj:IsA("Tool") then
					local n = string.lower(obj.Name)
					if string.find(n, "egg", 1, true) then
						tools[#tools + 1] = obj.Name
					end
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
		local needle = string.lower(tostring(name))
		local backpack = player:FindFirstChild("Backpack")
		if backpack then
			local t = backpack:FindFirstChild(name)
			if t and t:IsA("Tool") then
				return t
			end
			for _, obj in ipairs(backpack:GetChildren()) do
				if obj:IsA("Tool") then
					local n = string.lower(obj.Name)
					if n == needle then
						return obj
					end
				end
			end
			for _, obj in ipairs(backpack:GetChildren()) do
				if obj:IsA("Tool") then
					local n = string.lower(obj.Name)
					if string.find(n, needle, 1, true) then
						return obj
					end
				end
			end
		end
		if player.Character then
			local t = player.Character:FindFirstChild(name)
			if t and t:IsA("Tool") then
				return t
			end
			for _, obj in ipairs(player.Character:GetChildren()) do
				if obj:IsA("Tool") then
					local n = string.lower(obj.Name)
					if n == needle then
						return obj
					end
				end
			end
			for _, obj in ipairs(player.Character:GetChildren()) do
				if obj:IsA("Tool") then
					local n = string.lower(obj.Name)
					if string.find(n, needle, 1, true) then
						return obj
					end
				end
			end
		end
		return nil
	end

	local function equipSelectedEgg()
		local toolName = state.Values.SelectedEggTool
		local tool = findToolByName(toolName)
		if not tool then
			warn("[Egg] Tool not found:", toolName)
			return nil
		end

		local character = player.Character
		if not character then
			local ok, char = pcall(function()
				return player.CharacterAdded:Wait()
			end)
			character = ok and char or player.Character
		end
		if not character then
			return nil
		end

		local humanoid = character:FindFirstChildOfClass("Humanoid")
		if not humanoid then
			local ok, hum = pcall(function()
				return character:WaitForChild("Humanoid", 2)
			end)
			humanoid = ok and hum or character:FindFirstChildOfClass("Humanoid")
		end
		if not humanoid then
			return nil
		end

		local backpack = player:FindFirstChild("Backpack")
		if tool.Parent == backpack then
			humanoid:EquipTool(tool)
			return tool
		end
		if tool.Parent == character then
			return tool
		end
		if backpack then
			pcall(function()
				tool.Parent = backpack
			end)
			if tool.Parent == backpack then
				humanoid:EquipTool(tool)
				return tool
			end
		end
		return nil
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

	local function getCanPlantSlots(maxDist)
		maxDist = maxDist or 80
		local character = player.Character
		if not character then
			return {}
		end
		local hrp = character:FindFirstChild("HumanoidRootPart")
		if not hrp or not hrp:IsA("BasePart") then
			return {}
		end
		local pl = workspace:FindFirstChild("Farm")
		local farm = pl and pl:FindFirstChild("Farm")
		local important = farm and farm:FindFirstChild("Important")
		local loc = important and important:FindFirstChild("Plant_Locations")
		if not loc then
			return {}
		end

		local slots = {}
		for _, obj in ipairs(loc:GetChildren()) do
			if obj.Name == "Can_Plant" and obj:IsA("BasePart") then
				local d = (obj.Position - hrp.Position).Magnitude
				if d <= maxDist then
					slots[#slots + 1] = obj
				end
			end
		end
		table.sort(slots, function(a, b)
			return (a.Position - hrp.Position).Magnitude < (b.Position - hrp.Position).Magnitude
		end)
		return slots
	end

	local function getHeldTool(character)
		character = character or player.Character
		if not character then
			return nil
		end
		for _, ch in ipairs(character:GetChildren()) do
			if ch:IsA("Tool") then
				return ch
			end
		end
		return nil
	end

	local function resolveFarmRoot()
		local farmFolder = workspace:FindFirstChild("Farm")
		if not farmFolder then
			return nil
		end

		local function isMine(farmModel)
			local important = farmModel:FindFirstChild("Important")
			local data = important and important:FindFirstChild("Data")
			local owner = data and data:FindFirstChild("Owner")
			if owner and owner:IsA("StringValue") and owner.Value ~= "" then
				return owner.Value == player.Name
			end
			return nil
		end

		local direct = farmFolder:FindFirstChild("Farm")
		if direct and direct:IsA("Model") then
			local mine = isMine(direct)
			if mine == true or mine == nil then
				return direct
			end
		end

		for _, child in ipairs(farmFolder:GetChildren()) do
			if child:IsA("Model") then
				local mine = isMine(child)
				if mine == true then
					return child
				end
			end
		end
		return direct
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

	local function getGroundPos(pos)
		local origin = pos + Vector3.new(0, 80, 0)
		local dir = Vector3.new(0, -200, 0)
		local hitPos = pos
		pcall(function()
			local params = RaycastParams.new()
			params.FilterType = Enum.RaycastFilterType.Exclude
			params.IgnoreWater = true
			local character = player.Character
			params.FilterDescendantsInstances = character and { character } or {}
			local result = workspace:Raycast(origin, dir, params)
			if result and result.Position then
				hitPos = result.Position
			end
		end)
		return hitPos
	end

	local function tryPlaceAt(toolName, pos, cf)
		local rs = game:GetService("ReplicatedStorage")
		local ge = rs:FindFirstChild("GameEvents")
		if not ge then
			warn("[Egg] ReplicatedStorage.GameEvents not found")
			return false
		end
		local r1 = ge:FindFirstChild("TryUsePlaceableGear")
		local r2 = ge:FindFirstChild("TryUseGear")
		if not (r1 or r2) then
			warn("[Egg] Placement remotes not found under ReplicatedStorage.GameEvents")
			return false
		end

		local function fire(remote, ...)
			if remote and remote:IsA("RemoteEvent") then
				remote:FireServer(...)
				return true
			end
			return false
		end

		local ok = false
		pcall(function()
			if not cf then
				cf = CFrame.new(pos)
			end
			ok = fire(r1, toolName, pos)
			or fire(r1, toolName, cf)
			or fire(r1, pos, toolName)
			or fire(r1, cf, toolName)
			or fire(r2, toolName, pos)
			or fire(r2, toolName, cf)
			or fire(r2, pos, toolName)
			or fire(r2, cf, toolName)
		end)
		return ok
	end

	local function spamClick()
		pcall(function()
			local fn = rawget(_G, "mouse1click") or rawget(_G, "mouse1press") or rawget(_G, "mouse1")
			if type(fn) == "function" then
				fn()
			end
		end)
		pcall(function()
			local uis = game:GetService("UserInputService")
			local vim = game:GetService("VirtualInputManager")
			if uis and vim and vim.SendMouseButtonEvent then
				local mouseLocation = uis:GetMouseLocation()
				vim:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, true, game, 0)
				vim:SendMouseButtonEvent(mouseLocation.X, mouseLocation.Y, 0, false, game, 0)
			end
		end)
	end

	local function viewportClickAt(worldPos)
		local ok = false
		pcall(function()
			local cam = workspace.CurrentCamera
			if not cam then
				return
			end
			local v2, onScreen = cam:WorldToViewportPoint(worldPos)
			if not onScreen then
				return
			end
			local vim = game:GetService("VirtualInputManager")
			if vim and vim.SendMouseButtonEvent then
				vim:SendMouseButtonEvent(v2.X, v2.Y, 0, true, game, 0)
				vim:SendMouseButtonEvent(v2.X, v2.Y, 0, false, game, 0)
				ok = true
			end
		end)
		return ok
	end

	local function getRandomPointInPart(part)
		if not part or not part:IsA("BasePart") then
			return nil
		end
		local sx = math.max(0, part.Size.X / 2 - 0.2)
		local sz = math.max(0, part.Size.Z / 2 - 0.2)
		local rx = (math.random() * 2 - 1) * sx
		local rz = (math.random() * 2 - 1) * sz
		local p = part.CFrame:PointToWorldSpace(Vector3.new(rx, 0, rz))
		return p
	end

	local function clickPlantSlotAndActivate(canPlant, tool, worldPos)
		if not canPlant or not canPlant:IsA("BasePart") or not tool then
			return false
		end
		local did = false
		pcall(function()
			local pos = worldPos or canPlant.Position
			did = viewportClickAt(pos)
			if did then
				task.wait(0.03)
			end
			tool:Activate()
		end)
		return did
	end

	local function tryHatchNearestEgg(maxDist)
		maxDist = maxDist or 30
		local character = player.Character
		local hrp = character and character:FindFirstChild("HumanoidRootPart")
		if not hrp or not hrp:IsA("BasePart") then
			return false
		end

		local farm = resolveFarmRoot()
		local important = farm and farm:FindFirstChild("Important")
		local obj = important and important:FindFirstChild("Objects_Physical")
		if not obj then
			return false
		end
		local petEgg = obj:FindFirstChild("PetEgg")
		if not petEgg then
			return false
		end

		local bestPrompt
		local bestD = maxDist
		for _, d in ipairs(petEgg:GetDescendants()) do
			if d:IsA("ProximityPrompt") then
				local txt = (d.ActionText or "") .. " " .. (d.ObjectText or "")
				txt = string.lower(txt)
				if string.find(txt, "hatch") then
					local part = d.Parent
					if part and part:IsA("BasePart") then
						local dist = (part.Position - hrp.Position).Magnitude
						if dist < bestD then
							bestD = dist
							bestPrompt = d
						end
					end
				end
			end
		end

		if not bestPrompt then
			return false
		end

		local did = false
		pcall(function()
			local fn = rawget(_G, "fireproximityprompt")
			if type(fn) == "function" then
				fn(bestPrompt)
				did = true
			end
		end)
		return did
	end

	local autoConn
	local lastPlace = 0
	local ringIndex = 0
	local canPlantIndex = 0
	local function setAutoPlace(on)
		if autoConn then
			autoConn:Disconnect()
			autoConn = nil
		end
		if not on then
			return
		end
		lastPlace = 0
		ringIndex = 0
		canPlantIndex = 0
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
			if not toolName or toolName == "" then
				warn("[Egg] SelectedEggTool is empty")
				return
			end
			local tool = findToolByName(toolName)
			if not tool then
				warn("[Egg] Tool not found:", toolName)
				return
			end
			local character = player.Character
			local held = getHeldTool(character)
			if not held or held.Name ~= toolName then
				local equipped = equipSelectedEgg()
				if equipped then
					tool = equipped
				end
			else
				tool = held
			end

			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if not hrp or not hrp:IsA("BasePart") then
				return
			end

			local fired = false
			local mode = state.Values.AutoPlaceMode or "Mouse"

			if mode == "Mouse" then
				local slots = getCanPlantSlots(80)
				if #slots == 0 then
					return
				end
				canPlantIndex += 1
				local canPlant = slots[((canPlantIndex - 1) % #slots) + 1]
				local jitterPos = getRandomPointInPart(canPlant) or canPlant.Position
				fired = clickPlantSlotAndActivate(canPlant, tool, jitterPos)
				fired = fired or tryPlaceAt(toolName, jitterPos, CFrame.new(jitterPos))
				fired = fired or tryPlaceWithRemotes(toolName, canPlant)
			else
				ringIndex += 1
				local radius = 10
				local steps = 10
				local angle = (ringIndex % steps) / steps * math.pi * 2
				local offset = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
				local rawPos = hrp.Position + offset
				local pos = getGroundPos(rawPos)
				local cf = CFrame.new(pos)
				fired = tryPlaceAt(toolName, pos, cf)
				fired = fired or viewportClickAt(pos)
			end

			if not fired then
				pcall(function()
					tool:Activate()
				end)
				spamClick()
			end
		end)
	end

	local hatchConn
	local lastHatch = 0
	local function setAutoHatch(on)
		if hatchConn then
			hatchConn:Disconnect()
			hatchConn = nil
		end
		if not on then
			return
		end
		lastHatch = 0
		hatchConn = RunService.Heartbeat:Connect(function()
			if not state.Values.AutoHatchEgg then
				return
			end
			local now = os.clock()
			if now - lastHatch < 0.6 then
				return
			end
			lastHatch = now
			tryHatchNearestEgg(30)
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

	local placeModes = { "Mouse", "ViewportRing" }
	local modeDefault = state.Values.AutoPlaceMode or "Mouse"
	if not table.find(placeModes, modeDefault) then
		modeDefault = "Mouse"
		state.Values.AutoPlaceMode = modeDefault
	end
	local modeDropdown = elements.Dropdown("AutoPlace Mode", placeModes, modeDefault, function(v)
		state.Values.AutoPlaceMode = v
	end)
	modeDropdown.Parent = scroll

	local autoToggle = elements.Toggle("Auto Place Egg", state.Values.AutoPlaceEgg, function(v)
		state.Values.AutoPlaceEgg = v
		if v then
			equipSelectedEgg()
		end
		setAutoPlace(v)
	end)
	autoToggle.Parent = scroll

	local hatchToggle = elements.Toggle("Auto Hatch Egg", state.Values.AutoHatchEgg, function(v)
		state.Values.AutoHatchEgg = v
		setAutoHatch(v)
	end)
	hatchToggle.Parent = scroll

	local equipBtn = elements.Button("Взять яйцо в руки", function()
		equipSelectedEgg()
	end)
	equipBtn.Parent = scroll

	return {
		Scroll = scroll,
	}
end

return EggTab
