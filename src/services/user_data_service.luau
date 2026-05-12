local function CollectUserData(player, services)
	local Players = services.Players
	local UserInputService = services.UserInputService

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local head = character:FindFirstChild("Head")

	local userId = player.UserId
	local thumbUrl = Players:GetUserThumbnailAsync(userId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)

	local function safeGet(obj, prop)
		local ok, val = pcall(function()
			return obj[prop]
		end)
		return ok and val or nil
	end

	return {
		Username = player.Name,
		DisplayName = player.DisplayName,
		UserId = userId,
		AvatarUrl = thumbUrl,
		AccountAge = player.AccountAge,
		MembershipType = tostring(player.MembershipType),
		IsVerified = player.HasVerifiedBadge,
		LocaleId = player.LocaleId,
		Team = player.Team and player.Team.Name or "None",
		Neutral = player.Neutral,
		Health = humanoid and math.floor(humanoid.Health) or 0,
		MaxHealth = humanoid and math.floor(humanoid.MaxHealth) or 100,
		WalkSpeed = humanoid and humanoid.WalkSpeed or 16,
		JumpPower = humanoid and humanoid.JumpPower or 50,
		JumpHeight = humanoid and humanoid.JumpHeight or 7.2,
		HeadColor = head and tostring(head.Color) or "N/A",
		Platform = safeGet(UserInputService, "GetPlatform") and UserInputService:GetPlatform().Name or "Unknown",
		MouseEnabled = UserInputService.MouseEnabled,
		TouchEnabled = UserInputService.TouchEnabled,
		KeyboardEnabled = UserInputService.KeyboardEnabled,
		GamepadEnabled = UserInputService.GamepadEnabled,
		VREnabled = UserInputService.VREnabled,
		GyroscopeEnabled = UserInputService.GyroscopeEnabled,
		AccelSensorEnabled = UserInputService.AccelerometerEnabled,
		CameraMode = tostring(safeGet(player, "CameraMode") or "Default"),
		CameraMaxZoomDistance = safeGet(player, "CameraMaxZoomDistance") or 0.5,
		CameraMinZoomDistance = safeGet(player, "CameraMinZoomDistance") or 0.5,
		CanLoadCharacterAppearance = safeGet(player, "CanLoadCharacterAppearance") or true,
		SpawnLocationLocked = safeGet(player, "SpawnLocationLocked") or false,
	}
end

return CollectUserData
