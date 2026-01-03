-- Simple Hub Main Client

assert(_G.requireRemote, "requireRemote is missing — loader.lua did not run")

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-------------------------------------------------
-- LOAD UI CORE
-------------------------------------------------
local UI = {
	Animations = requireRemote("ui/animations.lua"),
	Components = requireRemote("ui/components.lua"),
	Tabs = requireRemote("ui/tabs.lua"),
}

-------------------------------------------------
-- LOAD SETTINGS
-------------------------------------------------
local Settings = {
	UI = requireRemote("settings/ui_settings.lua"),
	Keybinds = requireRemote("settings/keybinds.lua"),
	Presets = requireRemote("settings/presets.lua"),
}

-------------------------------------------------
-- LOAD UTILITIES
-------------------------------------------------
local Utils = {
	Helpers = requireRemote("utils/helpers.lua"),
	Math = requireRemote("utils/math.lua"),
	Raycast = requireRemote("utils/raycast.lua"),
}

-------------------------------------------------
-- LOAD MOVEMENT MODULES
-------------------------------------------------
local Movement = {
	Fly = requireRemote("movement/fly.lua"),
	Dash = requireRemote("movement/dash.lua"),
	WalkSpeed = requireRemote("movement/walkspeed.lua"),
	JumpPower = requireRemote("movement/jumppower.lua"),
	BunnyHop = requireRemote("movement/bunnyhop.lua"),
	AirControl = requireRemote("movement/air-control.lua"),
	NoClip = requireRemote("movement/no-clip.lua"),
}

-------------------------------------------------
-- LOAD ESP MODULES
-------------------------------------------------
local ESP = {
	Name = requireRemote("esp/name_esp.lua"),
	Box = requireRemote("esp/box_esp.lua"),
	Health = requireRemote("esp/health_esp.lua"),
	Distance = requireRemote("esp/distance_esp.lua"),
	Tracers = requireRemote("esp/tracers.lua"),
	Chams = requireRemote("esp/chams.lua"),
	Offscreen = requireRemote("esp/offscreen_arrows.lua"),
}

-------------------------------------------------
-- LOAD COMBAT MODULES
-------------------------------------------------
local Combat = {
	AimAssist = requireRemote("combat/aim_assist.lua"),
	SilentAim = requireRemote("combat/silent_aim.lua"),
	FOV = requireRemote("combat/fov.lua"),
}

-------------------------------------------------
-- LOAD EXTRA / MISC MODULES
-------------------------------------------------
local Extra = {
	Teleport = requireRemote("extra/teleport.lua"),
	Invisibility = requireRemote("extra/invisibility.lua"),
	Fullbright = requireRemote("extra/fullbright.lua"),
	RemoveGrass = requireRemote("extra/remove-grass.lua"),
	ThirdPerson = requireRemote("extra/third-person.lua"),
	WalkOnWater = requireRemote("extra/walk-on-water.lua"),
	AntiAFK = requireRemote("extra/anti_afk.lua"),
	FakeLag = requireRemote("extra/fake_lag.lua"),
	FakeDeath = requireRemote("extra/fake-death.lua"),
	Spinbot = requireRemote("extra/spinbot.lua"),
}

-------------------------------------------------
-- INIT UI
-------------------------------------------------
local Hub = UI.Components.createMainWindow({
	title = "SIMPLE HUB",
	version = "v3.7",
	keybind = Enum.KeyCode.M,
})

-------------------------------------------------
-- REGISTER TABS
-------------------------------------------------
UI.Tabs.register(Hub, "Movement", Movement)
UI.Tabs.register(Hub, "Combat", Combat)
UI.Tabs.register(Hub, "ESP", ESP)
UI.Tabs.register(Hub, "Extra", Extra)
UI.Tabs.register(Hub, "Settings", Settings)

-------------------------------------------------
-- FINALIZE
-------------------------------------------------
UI.Animations.intro(Hub)

print("✅ Simple Hub v3.7 fully loaded")
