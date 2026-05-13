local function Main(urlBase)
	local Players = game:GetService("Players")
	local RunService = game:GetService("RunService")
	local UserInputService = game:GetService("UserInputService")
	local HttpService = game:GetService("HttpService")
	local TweenService = game:GetService("TweenService")

	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	local RemoteLoaderSrc = game:HttpGet(urlBase .. "src/lib/remote_loader.luau")
	local RemoteLoader = loadstring(RemoteLoaderSrc)()
	local loader = RemoteLoader.new(urlBase, HttpService, function(url)
		return game:HttpGet(url)
	end)

	local Config = loader:Load("src/constants/config.luau")
	local Spring = loader:Load("src/lib/spring.luau")
	local CreateState = loader:Load("src/models/state.luau")

	local ThemeService = loader:Load("src/services/theme_service.luau")
	local PersistenceService = loader:Load("src/services/persistence_service.luau")
	local CollectUserData = loader:Load("src/services/user_data_service.luau")

	local CreateElements = loader:Load("src/ui/components/elements.luau")
	local CreateRootWindow = loader:Load("src/ui/layout/root_window.luau")

	local TabsController = loader:Load("src/controllers/tabs_controller.luau")
	local WindowController = loader:Load("src/controllers/window_controller.luau")

	local services = {
		Players = Players,
		RunService = RunService,
		UserInputService = UserInputService,
		HttpService = HttpService,
		TweenService = TweenService,
		Loader = loader,
		Spring = Spring,
	}

	local state = CreateState(Config)
	state.UserData = CollectUserData(player, services)

	local themeService = ThemeService.new(Config, state)
	local persistence = PersistenceService.new(HttpService, player, Config.SaveKey)

	local elements = CreateElements({
		Config = Config,
		Spring = Spring,
		Services = services,
		GetTheme = function() return themeService:GetTheme() end,
		BindTheme = function(inst, prop, key) themeService:Bind(inst, prop, key) end,
	})

	local gui = Instance.new("ScreenGui")
	gui.Name = "BekezatUI"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.DisplayOrder = 999999
	gui.Parent = playerGui

	local ui = CreateRootWindow({
		Gui = gui,
		Config = Config,
		ThemeService = themeService,
		Elements = elements,
		Services = services,
	})

	local windowController = WindowController.new({
		Config = Config,
		State = state,
		ThemeService = themeService,
		Spring = Spring,
		Services = services,
		UI = ui,
		Persistence = persistence,
	})

	local tabsController = TabsController.new({
		Config = Config,
		State = state,
		ThemeService = themeService,
		Services = services,
		UI = ui,
		Elements = elements,
	})

	windowController:Init()
	tabsController:Init()

	themeService:Apply()

	return true
end

return Main
