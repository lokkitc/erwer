local function EggTab(deps)
	local scroll = deps.Scroll
	local state = deps.State
	local elements = deps.Elements
	local themeService = deps.ThemeService
	local L = deps.Config.Layout

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
