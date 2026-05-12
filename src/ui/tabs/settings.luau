local function SettingsTab(deps)
	local scroll = deps.Scroll
	local state = deps.State
	local themeService = deps.ThemeService
	local elements = deps.Elements

	local themeList = {"Dark", "Light"}
	local themeDropdown = elements.Dropdown("Тема", themeList, state.Values.ThemeName or "Dark", function(v)
		state.Values.ThemeName = v
		themeService:Apply()
	end)
	themeDropdown.Parent = scroll

	return {
		Scroll = scroll,
	}
end

return SettingsTab
