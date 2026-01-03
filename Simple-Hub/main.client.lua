-- Simple Hub main.client.lua

local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local function load(path)
	print("[LOADING]", path)
	local src = game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
	return loadstring(src)()
end

-- utils (must load first)
load("utils/helpers.lua")
load("utils/math.lua")
load("utils/raycast.lua")

-- ui
load("ui/animations.lua")
load("ui/components.lua")
load("ui/tabs.lua")
load("ui/menu.lua") -- ✅ REQUIRED


-- settings
load("settings/ui_settings.lua")
load("settings/keybinds.lua")
load("settings/presets.lua")

-- movement
load("movement/fly.lua")
load("movement/noclip.lua")
load("movement/walkspeed.lua")
load("movement/jumppower.lua")
load("movement/bunnyhop.lua")
load("movement/dash.lua")
load("movement/air-control.lua")

-- esp
load("esp/name_esp.lua")
load("esp/box_esp.lua")
load("esp/health_esp.lua")
load("esp/distance_esp.lua")
load("esp/chams.lua")
load("esp/tracers.lua")
load("esp/offscreen_arrows.lua")

-- combat
load("combat/aim_assist.lua")
load("combat/silent_aim.lua")
load("combat/fov.lua")

-- extra
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
