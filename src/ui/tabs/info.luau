local function InfoTab(deps)
	local scroll = deps.Scroll
	local themeService = deps.ThemeService
	local L = deps.Config.Layout

	local function T()
		return themeService:GetTheme()
	end

	local info = Instance.new("TextLabel")
	info.Size = UDim2.new(1, 0, 0, L.InfoHeight)
	info.BackgroundTransparency = 1
	info.Text = "Bekezat Erdos Bot"
	info.TextColor3 = T().TextSecondary
	themeService:Bind(info, "TextColor3", "TextSecondary")
	info.TextWrapped = true
	info.Font = L.FontBody
	info.TextSize = L.TextInfo
	info.Parent = scroll

	return {
		Scroll = scroll,
	}
end

return InfoTab
