-- Simple Hub main.client.lua
-- COMPLETE INTEGRATION VERSION

local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local function load(path)
	print("[LOADING]", path)
	local src = game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
	return loadstring(src)()
end

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
-- 6. START MENU (last, with all dependencies)
-- ============================================
local startMenu = load("ui/menu.lua")

if type(startMenu) ~= "function" then
    error("menu.lua did not return a function")
end

startMenu()

print("[Simple Hub] ✓ All features loaded and integrated")
print("[Simple Hub] ✓ Press M to open menu")
