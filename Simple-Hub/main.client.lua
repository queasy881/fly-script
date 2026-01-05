-- main.client.lua
-- Simple Hub main.client.lua
-- UPDATED WITH CONFIG INTEGRATION

local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local function load(path)
	print("[LOADING]", path)
	local src = game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
	local fn, err = loadstring(src)
	if not fn then
		warn("[LOAD ERROR]", path, err)
		return nil
	end
	return fn()
end

-- ============================================
-- CONFIG LOADER
-- ============================================
local Config = {}

-- Try to load config
local function loadConfig()
	-- Try to load from local storage first
	if isfolder and isfile then
		if isfolder("SimpleHub") and isfile("SimpleHub/config.json") then
			local configJson = readfile("SimpleHub/config.json")
			Config = game:GetService("HttpService"):JSONDecode(configJson)
			print("[CONFIG] Loaded from file")
			return
		end
	end
	
	-- Fallback to default config
	Config = {
		MenuKey = "M",
		AccentColor = {60, 120, 255},
		Watermark = true,
		FPSCounter = true,
		PingDisplay = true,
		DefaultTab = "Combat"
	}
	print("[CONFIG] Using defaults")
end

loadConfig()

-- ============================================
-- 1. UTILS (no dependencies)
-- ============================================
load("utils/helpers.lua")
load("utils/math.lua")
load("utils/raycast.lua")

-- ============================================
-- 2. UI SYSTEM (must load in order)
-- ============================================
local Animations = load("ui/animations.lua")
local Components = load("ui/components.lua")
local Tabs = load("ui/tabs.lua")

-- Store in _G for menu.lua to access
_G.VertexAnimations = Animations
_G.VertexComponents = Components
_G.VertexTabs = Tabs

-- ============================================
-- 3. CONTROLLER (loads before menu)
-- ============================================
local Controller = load("controller.lua")

-- ============================================
-- 4. LOAD ALL FEATURE MODULES
-- ============================================

-- Movement
Controller.registerModule("Fly", load("movement/fly.lua"))
Controller.registerModule("Noclip", load("movement/noclip.lua"))
Controller.registerModule("WalkSpeed", load("movement/walkspeed.lua"))
Controller.registerModule("JumpPower", load("movement/jumppower.lua"))
Controller.registerModule("BunnyHop", load("movement/bunnyhop.lua"))
Controller.registerModule("Dash", load("movement/dash.lua"))
Controller.registerModule("AirControl", load("movement/air-control.lua"))

-- ESP
Controller.registerModule("NameESP", load("esp/name_esp.lua"))
Controller.registerModule("BoxESP", load("esp/box_esp.lua"))
Controller.registerModule("HealthESP", load("esp/health_esp.lua"))
Controller.registerModule("DistanceESP", load("esp/distance_esp.lua"))
Controller.registerModule("Chams", load("esp/chams.lua"))
Controller.registerModule("Tracers", load("esp/tracers.lua"))
load("esp/offscreen_arrows.lua") -- placeholder, not registered

-- Combat
Controller.registerModule("AimAssist", load("combat/aim_assist.lua"))
Controller.registerModule("SilentAim", load("combat/silent_aim.lua"))
Controller.registerModule("FOV", load("combat/fov.lua"))

-- Extra
Controller.registerModule("Fullbright", load("extra/fullbright.lua"))
Controller.registerModule("RemoveGrass", load("extra/remove-grass.lua"))
Controller.registerModule("ThirdPerson", load("extra/third-person.lua"))
Controller.registerModule("Invisibility", load("extra/invisibility.lua"))
Controller.registerModule("AntiAFK", load("extra/anti-afk.lua"))
Controller.registerModule("FakeLag", load("extra/fake-lag.lua"))
Controller.registerModule("FakeDeath", load("extra/fake-death.lua"))
Controller.registerModule("SpinBot", load("extra/spinbot.lua"))
Controller.registerModule("Teleport", load("extra/teleport.lua"))
Controller.registerModule("WalkOnWater", load("extra/walk-on-water.lua"))

-- ============================================
-- 5. SETTINGS (optional)
-- ============================================
load("settings/ui_settings.lua")
load("settings/keybinds.lua")
load("settings/presets.lua")

-- ============================================
-- 6. CONFIG WRAPPER FOR MENU
-- ============================================
local function getConfigForMenu()
	return {
		MenuKey = Enum.KeyCode[Config.MenuKey or "M"],
		AccentColor = Color3.fromRGB(
			Config.AccentColor and Config.AccentColor[1] or 60,
			Config.AccentColor and Config.AccentColor[2] or 120,
			Config.AccentColor and Config.AccentColor[3] or 255
		),
		DefaultTab = Config.DefaultTab or "Combat",
		Settings = Config -- Pass full config for reference
	}
end

-- ============================================
-- 7. START MENU WITH CONFIG
-- ============================================
local startMenu = load("ui/menu.lua")
if startMenu then
	local menuConfig = getConfigForMenu()
	
	-- Start menu with config
	local success, result = pcall(function()
		return startMenu({
			Tabs = Tabs,
			Components = Components,
			Animations = Animations,
			Config = menuConfig -- Pass config to menu
		})
	end)
	
	if success then
		print("[Simple Hub] Menu loaded with config")
		
		-- Apply initial config values
		if Config.Watermark then
			-- You'd need to expose this to the controller
			Controller.set("Watermark", true)
		end
		
		if Config.FPSCounter then
			Controller.set("FPSCounter", true)
		end
		
		if Config.PingDisplay then
			Controller.set("PingDisplay", true)
		end
		
	else
		warn("[MENU ERROR]", result)
	end
end

-- ============================================
-- 8. CONFIG SAVE FUNCTION
-- ============================================
local function saveConfig(newConfig)
	-- Merge new config with existing
	for k, v in pairs(newConfig) do
		Config[k] = v
	end
	
	-- Save to file if possible
	if writefile then
		if not isfolder then
			makefolder("SimpleHub")
		end
		
		local http = game:GetService("HttpService")
		local configJson = http:JSONEncode(Config)
		writefile("SimpleHub/config.json", configJson)
		print("[CONFIG] Saved to file")
	end
end

-- Expose save function
_G.SimpleHubSaveConfig = saveConfig

-- ============================================
-- 9. KEYBIND HANDLER
-- ============================================
local UIS = game:GetService("UserInputService")
local menuKey = Enum.KeyCode[Config.MenuKey or "M"]

UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == menuKey then
		-- This would toggle the menu if exposed
		-- For now, just notify
		print("[Simple Hub] Menu key pressed")
	end
end)

print("[Simple Hub] All features loaded with config integration")
print("[Simple Hub] Menu key:", Config.MenuKey or "M")
print("[Simple Hub] Default tab:", Config.DefaultTab or "Combat")
