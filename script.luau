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

local function safeHttpGet(url)
    local ok, res = pcall(function()
        return game:HttpGet(url)
    end)
    if not ok then
        return nil, res
    end
    return res, nil
end

local remoteLoaderSrc, rlErr = safeHttpGet(URL_BASE .. "src/lib/remote_loader.luau?cb=" .. HttpService:GenerateGUID(false))
if not remoteLoaderSrc then
    warn("[BekezatLoader] HttpGet RemoteLoader failed:", rlErr)
    return
end

local RemoteLoaderFn, rlLoadErr = loadstring(remoteLoaderSrc)
if not RemoteLoaderFn then
    warn("[BekezatLoader] loadstring RemoteLoader failed:", rlLoadErr)
    return
end

local okRL, RemoteLoader = pcall(RemoteLoaderFn)
if not okRL or type(RemoteLoader) ~= "table" then
    warn("[BekezatLoader] RemoteLoader init failed:", RemoteLoader)
    return
end

local loader = RemoteLoader.new(URL_BASE, HttpService, function(url)
    return game:HttpGet(url)
end)

local function fallbackLog(msg)
    print("[BekezatLoader]", msg)
end

local log = fallbackLog
local destroyLog = function() end

do
    local loggerFactory, loggerErr = loader:Load("src/ui/logger/loader_logger.luau", true)
    if type(loggerFactory) == "function" then
        local okCreate, l, d = pcall(loggerFactory)
        if okCreate and type(l) == "function" then
            log = l
            destroyLog = (type(d) == "function" and d or destroyLog)
        end
    else
        warn("[BekezatLoader] Logger load failed:", loggerErr)
    end
end

log("init")

local mainChunk, mainErr = loader:Load("src/app/main.luau", true)
if type(mainChunk) ~= "function" then
    log("Main load failed")
    log(mainErr)
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
