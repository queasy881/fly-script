-- main.client.lua
-- Vertex Hub loader + menu bootstrap
-- FULLY FIXED FOR OBJECT-BASED TOGGLES

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

-- ============================================================
-- LOAD CORE SYSTEMS
-- ============================================================
load("utils/helpers.lua")
load("utils/math.lua")
load("utils/raycast.lua")

local Animations = load("ui/animations.lua")
local Components = load("ui/components.lua")
local Tabs = load("ui/tabs.lua")

_G.VertexAnimations = Animations
_G.VertexComponents = Components
_G.VertexTabs = Tabs

local Controller = load("controller.lua")

-- ============================================================
-- REGISTER MODULES (unchanged)
-- ============================================================
Controller.registerModule("Fly", load("movement/fly.lua"))
Controller.registerModule("Noclip", load("movement/noclip.lua"))
Controller.registerModule("WalkSpeed", load("movement/walkspeed.lua"))
Controller.registerModule("JumpPower", load("movement/jumppower.lua"))

Controller.registerModule("AimAssist", load("combat/aim_assist.lua"))
Controller.registerModule("SilentAim", load("combat/silent_aim.lua"))
Controller.registerModule("FOV", load("combat/fov.lua"))

Controller.registerModule("Fullbright", load("extra/fullbright.lua"))
Controller.registerModule("AntiAFK", load("extra/anti-afk.lua"))

-- ============================================================
-- STATE (SINGLE SOURCE OF TRUTH)
-- ============================================================
local State = {
	Combat = {
		AimAssist = false,
		SilentAim = false,
		ShowFOVCircle = false,
	},
	Movement = {
		Fly = false,
		Noclip = false,
	},
	Misc = {
		Watermark = false,
		FPSCounter = false,
	}
}

-- expose for presets
_G.VertexState = State

-- ============================================================
-- TOGGLE REGISTRY (IMPORTANT)
-- ============================================================
local ToggleRefs = {}
_G.VertexToggleRefs = ToggleRefs

-- ============================================================
-- START MENU
-- ============================================================
local startMenu = load("ui/menu.lua")

if startMenu then
	startMenu({
		Tabs = Tabs,
		Components = Components,
		Animations = Animations,
		State = State,
		ToggleRefs = ToggleRefs
	})
end

print("[Vertex Hub] main.client.lua loaded cleanly")
