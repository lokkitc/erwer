local ThemeService = {}

function ThemeService.new(config, state)
	local self = {
		_config = config,
		_state = state,
		_bindings = {},
	}
	return setmetatable(self, { __index = ThemeService })
end

function ThemeService:GetTheme()
	local name = self._state.Values and self._state.Values.ThemeName
	if name and self._config.Theme[name] then
		return self._config.Theme[name]
	end
	return self._config.Theme.Dark
end

function ThemeService:Bind(inst, prop, key)
	self._bindings[#self._bindings + 1] = { Inst = inst, Prop = prop, Key = key }
end

function ThemeService:Apply()
	local t = self:GetTheme()
	for i = #self._bindings, 1, -1 do
		local b = self._bindings[i]
		if not b.Inst or not b.Inst.Parent then
			table.remove(self._bindings, i)
		else
			b.Inst[b.Prop] = t[b.Key]
		end
	end
end

return ThemeService
