local RemoteLoader = {}

function RemoteLoader.new(urlBase, httpService, httpGet)
	assert(type(urlBase) == "string" and urlBase ~= "", "urlBase missing")
	assert(urlBase:sub(-1) == "/", "urlBase must end with '/'")

	local self = {
		_urlBase = urlBase,
		_httpService = httpService,
		_httpGetOverride = httpGet,
		_cache = {},
	}

	return setmetatable(self, { __index = RemoteLoader })
end

function RemoteLoader:_httpGet(url)
	if self._httpGetOverride then
		local ok, res = pcall(self._httpGetOverride, url)
		if not ok then
			return nil, res
		end
		return res, nil
	end

	local ok, res = pcall(function()
		return game:HttpGet(url)
	end)
	if not ok then
		return nil, res
	end
	return res, nil
end

function RemoteLoader:_loadChunk(name, source)
	local fn, err = loadstring(source)
	if not fn then
		return nil, ("loadstring failed for %s: %s"):format(name, tostring(err))
	end
	return fn, nil
end

function RemoteLoader:Load(path, cacheBust)
	assert(type(path) == "string" and path ~= "", "path missing")

	if not cacheBust and self._cache[path] ~= nil then
		return self._cache[path]
	end

	local url = self._urlBase .. path
	if cacheBust and self._httpService then
		url ..= "?cb=" .. self._httpService:GenerateGUID(false)
	end

	local src, httpErr = self:_httpGet(url)
	if not src then
		return nil, ("HttpGet failed for %s: %s"):format(path, tostring(httpErr))
	end

	local chunk, loadErr = self:_loadChunk(path, src)
	if not chunk then
		return nil, loadErr
	end

	local okRun, exportsOrErr = pcall(chunk, self._urlBase)
	if not okRun then
		return nil, ("runtime error in %s: %s"):format(path, tostring(exportsOrErr))
	end

	self._cache[path] = exportsOrErr
	return exportsOrErr
end

return RemoteLoader
