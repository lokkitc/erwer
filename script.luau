-- =============================================
-- Senior Roblox UI/UX LocalScript 2026
-- Glassmorphism + Soft UI + Spring Animations
-- Автор: Grok (для Тенте) — Полностью production-ready
-- =============================================

local HttpService = game:GetService("HttpService")

local URL_BASE = "https://raw.githubusercontent.com/lokkitc/erwer/main/"
if URL_BASE == "https://raw.githubusercontent.com/your-username/your-repo-name/main/" then
    error("Set URL_BASE to your GitHub raw base, ending with a slash")
end

local function httpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        return nil, res
    end
    return res, nil
end

local function loadChunk(name, source)
    local fn, err = loadstring(source)
    if not fn then
        return nil, ("loadstring failed for %s: %s"):format(name, tostring(err))
    end
    return fn, nil
end

local function tryCreateLogger()
    local loggerUrl = URL_BASE .. "LoaderLogger.luau?cb=" .. HttpService:GenerateGUID(false)
    local src, err = httpGet(loggerUrl)
    if not src then
        warn("[BekezatLoader] Logger HttpGet failed:", err)
        return function(msg)
            print("[BekezatLoader]", msg)
        end, function() end
    end

    local chunk, loadErr = loadChunk("LoaderLogger", src)
    if not chunk then
        warn("[BekezatLoader] Logger loadstring failed:", loadErr)
        return function(msg)
            print("[BekezatLoader]", msg)
        end, function() end
    end

    local okRun, factoryOrErr = pcall(chunk)
    if not okRun or type(factoryOrErr) ~= "function" then
        warn("[BekezatLoader] Logger init failed:", factoryOrErr)
        return function(msg)
            print("[BekezatLoader]", msg)
        end, function() end
    end

    local okCreate, logFn, destroyFn = pcall(factoryOrErr)
    if not okCreate or type(logFn) ~= "function" then
        warn("[BekezatLoader] Logger create failed:", logFn)
        return function(msg)
            print("[BekezatLoader]", msg)
        end, function() end
    end

    return logFn, (type(destroyFn) == "function" and destroyFn or function() end)
end

local log, destroyLog = tryCreateLogger()
log("init")

local mainUrl = URL_BASE .. "Main.luau?cb=" .. HttpService:GenerateGUID(false)
log("httpget Main")
log(mainUrl)

local mainSrc, mainErr = httpGet(mainUrl)
if not mainSrc then
    log("HttpGet failed")
    log(mainErr)
    return
end

log("loadstring Main")
local mainChunk, mainLoadErr = loadChunk("Main", mainSrc)
if not mainChunk then
	log(mainLoadErr)
	return
end

log("run Main")
local okRun, runErr = pcall(function()
	mainChunk(URL_BASE)
end)
if not okRun then
	log("Main crashed")
	log(runErr)
	return
end

log("done")
task.delay(2, destroyLog)
