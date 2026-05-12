local function CreateState(config)
	return {
		Open = true,
		Dragging = false,
		Resizing = false,
		CurrentTab = "Главная",
		Theme = config.Theme.Dark,
		Springs = {},
		Destroyed = false,
		Values = {
			Volume = 75,
			MusicEnabled = true,
			SelectedMode = "Normal",
			Nickname = "Тенте",
		},
		UserData = {},
	}
end

return CreateState
