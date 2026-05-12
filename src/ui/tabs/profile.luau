local function ProfileTab(deps)
	local scroll = deps.Scroll
	local state = deps.State
	local themeService = deps.ThemeService
	local L = deps.Config.Layout

	local function T()
		return themeService:GetTheme()
	end

	local ud = state.UserData

	local profileRow = Instance.new("Frame")
	profileRow.Size = UDim2.new(1, 0, 0, L.AvatarSize)
	profileRow.BackgroundTransparency = 1
	profileRow.Parent = scroll

	local avatar = Instance.new("ImageLabel")
	avatar.Size = UDim2.new(0, L.AvatarSize, 0, L.AvatarSize)
	avatar.BackgroundTransparency = 1
	avatar.Image = ud.AvatarUrl or ""
	avatar.Parent = profileRow

	local avatarCorner = Instance.new("UICorner")
	avatarCorner.CornerRadius = UDim.new(0, L.AvatarCorner)
	avatarCorner.Parent = avatar

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -L.AvatarSize - 12, 0, L.ProfileRowHeight)
	nameLbl.Position = UDim2.new(0, L.AvatarSize + 12, 0, (L.AvatarSize - L.ProfileRowHeight) / 2)
	nameLbl.BackgroundTransparency = 1
	nameLbl.Text = (ud.DisplayName or "") .. "\n@" .. (ud.Username or "")
	nameLbl.TextColor3 = T().Text
	themeService:Bind(nameLbl, "TextColor3", "Text")
	nameLbl.TextXAlignment = Enum.TextXAlignment.Left
	nameLbl.TextYAlignment = Enum.TextYAlignment.Center
	nameLbl.Font = L.FontTab
	nameLbl.TextSize = L.TextBody
	nameLbl.Parent = profileRow

	local infoFields = {
		{ "UserID", tostring(ud.UserId) },
		{ "Возраст аккаунта", tostring(ud.AccountAge) .. " дней" },
		{ "Подписка", tostring(ud.MembershipType) },
		{ "Верифицирован", ud.IsVerified and "Да" or "Нет" },
		{ "Локаль", tostring(ud.LocaleId) },
		{ "Команда", tostring(ud.Team) },
		{ "Здоровье", tostring(ud.Health) .. "/" .. tostring(ud.MaxHealth) },
		{ "Скорость", tostring(ud.WalkSpeed) },
		{ "Прыжок", tostring(ud.JumpPower) },
		{ "Платформа", tostring(ud.Platform) },
	}

	for _, field in ipairs(infoFields) do
		local row = Instance.new("TextLabel")
		row.Size = UDim2.new(1, 0, 0, L.ProfileRowHeight)
		row.BackgroundTransparency = 1
		row.RichText = false
		row.Text = tostring(field[1]) .. ": " .. tostring(field[2])
		row.TextColor3 = T().TextSecondary
		themeService:Bind(row, "TextColor3", "TextSecondary")
		row.TextXAlignment = Enum.TextXAlignment.Left
		row.Font = L.FontBody
		row.TextSize = 12
		row.Parent = scroll
	end

	return {
		Scroll = scroll,
	}
end

return ProfileTab
