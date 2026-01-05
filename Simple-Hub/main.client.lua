-- main.client.lua
-- Vertex Hub loader
-- FIXED VERSION

local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local function load(path)
	print("[LOADING]", path)
	local ok, src = pcall(function()
		return game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
	end)
	if not ok or not src then
		warn("[LOAD SKIP]", path)
		return nil
	end
	local fn, err = loadstring(src)
	if not fn then
		warn("[LOAD ERROR]", path, err)
		return nil
	end
	local ok2, result = pcall(fn)
	if not ok2 then
		warn("[RUN ERROR]", path, result)
		return nil
	end
	return result
end

-- Load utilities (safe)
pcall(function() load("utils/helpers.lua") end)
pcall(function() load("utils/math.lua") end)
pcall(function() load("utils/raycast.lua") end)

-- Load UI modules
local Animations = load("ui/animations.lua")
local Components = load("ui/components.lua")
local Tabs = load("ui/tabs.lua")

_G.VertexAnimations = Animations
_G.VertexComponents = Components
_G.VertexTabs = Tabs

-- Load controller
local Controller = load("controller.lua")

-- Register modules
if Controller and Controller.registerModule then
	pcall(function() Controller.registerModule("Fly", load("movement/fly.lua")) end)
	pcall(function() Controller.registerModule("Noclip", load("movement/noclip.lua")) end)
	pcall(function() Controller.registerModule("WalkSpeed", load("movement/walkspeed.lua")) end)
	pcall(function() Controller.registerModule("JumpPower", load("movement/jumppower.lua")) end)
	pcall(function() Controller.registerModule("AimAssist", load("combat/aim_assist.lua")) end)
	pcall(function() Controller.registerModule("SilentAim", load("combat/silent_aim.lua")) end)
	pcall(function() Controller.registerModule("FOV", load("combat/fov.lua")) end)
	pcall(function() Controller.registerModule("Fullbright", load("extra/fullbright.lua")) end)
	pcall(function() Controller.registerModule("AntiAFK", load("extra/anti-afk.lua")) end)
end

-- Load menu
local startMenu = load("ui/menu.lua")

if startMenu then
	startMenu({
		Tabs = Tabs,
		Components = Components,
		Animations = Animations
	})
end

print("[Vertex Hub] Loaded")
