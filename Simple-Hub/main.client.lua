-- Simple Hub main.client.lua
-- FIXED: Proper load order for UI dependencies

local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local function load(path)
	print("[LOADING]", path)
	local src = game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
	return loadstring(src)()
end

-- ============================================
-- CRITICAL: Load in this exact order
-- ============================================

-- 1. Utils first (no dependencies)
load("utils/helpers.lua")
load("utils/math.lua")
load("utils/raycast.lua")

-- 2. Animations MUST load before Components and Tabs
local Animations = load("ui/animations.lua")

-- 3. Now Components and Tabs can safely load
local Components = load("ui/components.lua")
local Tabs = load("ui/tabs.lua")

-- 4. Finally, menu can load with all dependencies ready
local startMenu = load("ui/menu.lua")
startMenu({
	Tabs = Tabs,
	Components = Components,
	Animations = Animations
})

-- ============================================
-- Settings
-- ============================================
load("settings/ui_settings.lua")
load("settings/keybinds.lua")
load("settings/presets.lua")

-- ============================================
-- Movement
-- ============================================
load("movement/fly.lua")
load("movement/noclip.lua")
load("movement/walkspeed.lua")
load("movement/jumppower.lua")
load("movement/bunnyhop.lua")
load("movement/dash.lua")
load("movement/air-control.lua")

-- ============================================
-- ESP
-- ============================================
load("esp/name_esp.lua")
load("esp/box_esp.lua")
load("esp/health_esp.lua")
load("esp/distance_esp.lua")
load("esp/chams.lua")
load("esp/tracers.lua")
load("esp/offscreen_arrows.lua")

-- ============================================
-- Combat
-- ============================================
load("combat/aim_assist.lua")
load("combat/silent_aim.lua")
load("combat/fov.lua")

-- ============================================
-- Extra
-- ============================================
load("extra/fullbright.lua")
load("extra/remove-grass.lua")
load("extra/third-person.lua")
load("extra/invisibility.lua")
load("extra/anti-afk.lua")
load("extra/fake-lag.lua")
load("extra/fake-death.lua")
load("extra/spinbot.lua")
load("extra/teleport.lua")
load("extra/walk-on-water.lua")

print("[Simple Hub] Loaded successfully")
print("[Simple Hub] Press M to open menu")
