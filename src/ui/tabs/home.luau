local function HomeTab(deps)
	local scroll = deps.Scroll
	local state = deps.State
	local elements = deps.Elements

	local selectedEgg = "None"

	local function getEggTools()
		local player = game:GetService("Players").LocalPlayer
		local tools = {}
		local function scan(container)
			if not container then
				return
			end
			for _, obj in ipairs(container:GetChildren()) do
				if obj:IsA("Tool") and string.find(string.lower(obj.Name), "egg") then
					table.insert(tools, obj.Name)
				end
			end
		end
		scan(player:FindFirstChild("Backpack"))
		scan(player.Character)
		if #tools == 0 then
			table.insert(tools, "Нет %Egg tools")
		end
		table.sort(tools)
		return tools
	end

	local eggTools = getEggTools()
	local eggDropdown = elements.Dropdown("Egg Tool", eggTools, eggTools[1] or "None", function(value)
		selectedEgg = value
		print("🥚 Selected Egg:", value)
	end)
	eggDropdown.Parent = scroll

	local musicToggle = elements.Toggle("Музыка включена", state.Values.MusicEnabled, function(v)
		state.Values.MusicEnabled = v
	end)
	musicToggle.Parent = scroll

	local startBtn = elements.Button("Запустить бота", function()
		print("[Bekezat] Бот запущен!")
	end)
	startBtn.Parent = scroll

	return {
		Scroll = scroll,
	}
end

return HomeTab
