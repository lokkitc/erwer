-- =============================================
-- Senior Roblox UI/UX LocalScript 2026
-- Glassmorphism + Soft UI + Spring Animations
-- Автор: Grok (для Тенте) — Полностью production-ready
-- =============================================

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local function makeLogger()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local gui = Instance.new("ScreenGui")
    gui.Name = "BekezatLoaderLog"
    gui.ResetOnSpawn = false
    gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    gui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromOffset(520, 220)
    frame.Position = UDim2.fromScale(0.5, 0.2)
    frame.AnchorPoint = Vector2.new(0.5, 0)
    frame.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
    frame.BackgroundTransparency = 0.25
    frame.BorderSizePixel = 0
    frame.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = frame

    local stroke = Instance.new("UIStroke")
    stroke.Thickness = 1
    stroke.Transparency = 0.4
    stroke.Color = Color3.fromRGB(90, 90, 110)
    stroke.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, -16, 0, 26)
    title.Position = UDim2.new(0, 8, 0, 6)
    title.BackgroundTransparency = 1
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Text = "Bekezat Loader"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(245, 245, 250)
    title.Parent = frame

    local box = Instance.new("TextLabel")
    box.Size = UDim2.new(1, -16, 1, -40)
    box.Position = UDim2.new(0, 8, 0, 34)
    box.BackgroundTransparency = 1
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.TextYAlignment = Enum.TextYAlignment.Top
    box.TextWrapped = true
    box.Text = ""
    box.Font = Enum.Font.Code
    box.TextSize = 14
    box.TextColor3 = Color3.fromRGB(200, 200, 210)
    box.Parent = frame

    local lines = {}
    local function log(msg)
        lines[#lines + 1] = tostring(msg)
        if #lines > 12 then
            table.remove(lines, 1)
        end
        box.Text = table.concat(lines, "\n")
        print("[BekezatLoader]", msg)
    end

    local function destroy()
        if gui and gui.Parent then
            gui:Destroy()
        end
    end

    return log, destroy
end

local log, destroyLog = makeLogger()
log("init")

local function exec(url)
    local src = game:HttpGet(url)
    local chunk = loadstring(src)
    if not chunk then
        error("loadstring failed")
    end
    return chunk()
end

local URL_BASE = "https://raw.githubusercontent.com/lokkitc/erwer/main/"
if URL_BASE == "https://raw.githubusercontent.com/your-username/your-repo-name/main/" then
    error("Set URL_BASE to your GitHub raw base, ending with a slash")
end

local mainUrl = URL_BASE .. "Main.luau?cb=" .. HttpService:GenerateGUID(false)
log("httpget Main: " .. mainUrl)

local okSrc, srcOrErr = pcall(function()
    return game:HttpGet(mainUrl)
end)
if not okSrc then
    log("HttpGet failed")
    log(srcOrErr)
    return
end

log("loadstring Main")
local chunk, loadErr = loadstring(srcOrErr)
if not chunk then
    log("loadstring failed")
    log(loadErr)
    return
end

log("run Main")
local okRun, runErr = pcall(function()
    chunk(URL_BASE)
end)
if not okRun then
    log("Main crashed")
    log(runErr)
    return
end

log("done")
task.delay(2, destroyLog)
