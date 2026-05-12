local PersistenceService = {}

function PersistenceService.new(httpService, player, saveKey)
	local self = {
		_httpService = httpService,
		_player = player,
		_saveKey = saveKey,
	}
	return setmetatable(self, { __index = PersistenceService })
end

function PersistenceService:Save(mainFrame, values)
	local data = {
		PosXScale = mainFrame.Position.X.Scale,
		PosXOffset = mainFrame.Position.X.Offset,
		PosYScale = mainFrame.Position.Y.Scale,
		PosYOffset = mainFrame.Position.Y.Offset,
		SizeX = mainFrame.Size.X.Offset,
		SizeY = mainFrame.Size.Y.Offset,
		Values = values,
	}
	self._player:SetAttribute(self._saveKey, self._httpService:JSONEncode(data))
end

function PersistenceService:Load()
	local saved = self._player:GetAttribute(self._saveKey)
	if not saved then
		return nil
	end
	local ok, data = pcall(self._httpService.JSONDecode, self._httpService, saved)
	if not ok or type(data) ~= "table" then
		return nil
	end
	return data
end

return PersistenceService
