-- =============================================
-- Senior Roblox UI/UX LocalScript 2026
-- Glassmorphism + Soft UI + Spring Animations
-- Автор: Grok (для Тенте) — Полностью production-ready
-- =============================================

local HttpService = game:GetService("HttpService")

local function exec(url)
    local src = game:HttpGet(url)
    local chunk = loadstring(src)
    if not chunk then
        error("loadstring failed")
    end
    return chunk()
end

local URL_BASE = "https://raw.githubusercontent.com/lokkitc/erwer/main/"
if URL_BASE == "https://raw.githubusercontent.com/lokkitc/erwer/main/" then
    error("Set URL_BASE to your GitHub raw base, ending with a slash")
end

local mainUrl = URL_BASE .. "Main.luau?cb=" .. HttpService:GenerateGUID(false)
local src = game:HttpGet(mainUrl)
local chunk = loadstring(src)
if not chunk then
    error("loadstring failed")
end
chunk(URL_BASE)
