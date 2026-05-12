local function CreateState(config)
	return {
		Open = true,
		Dragging = false,
		Resizing = false,
		CurrentTab = "Главная",
		Destroyed = false,
		Values = {
			Volume = 75,
			MusicEnabled = true,
			SelectedMode = "Normal",
			Nickname = "AsuuBkzt",
			SelectedEggTool = "",
			AutoPlaceEgg = false,
			AutoPlaceMode = "Mouse",
			AutoHatchEgg = false,
			ThemeName = "Dark",
		},
		UserData = {},
		Config = config,
	}
end

return CreateState
