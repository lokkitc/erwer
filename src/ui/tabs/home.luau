local function HomeTab(deps)
	local scroll = deps.Scroll
	local state = deps.State
	local elements = deps.Elements

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
