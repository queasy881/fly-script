-- SIMPLE HUB v3.7
-- Main Client Bootstrap

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer

---------------- GLOBAL HUB TABLE ----------------
_G.SimpleHub = {
    Player = player,
    LoadedModules = {},
    State = {},
}

---------------- BASE URL ----------------
local BASE_URL = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

---------------- MODULE LOADER ----------------
local function requireRemote(path)
    local src = game:HttpGet(BASE_URL .. path)
    local fn = loadstring(src)
    return fn()
end

---------------- LOAD UTILS ----------------
_G.SimpleHub.Utils = {
    Helpers = requireRemote("utils/helpers.lua"),
    Math = requireRemote("utils/math.lua"),
    Raycast = requireRemote("utils/raycast.lua"),
}

---------------- LOAD UI ----------------
_G.SimpleHub.UI = {
    Animations = requireRemote("ui/animations.lua"),
    Components = requireRemote("ui/components.lua"),
    Tabs = requireRemote("ui/tabs.lua"),
}

---------------- LOAD SETTINGS ----------------
_G.SimpleHub.Settings = {
    Keybinds = requireRemote("settings/keybinds.lua"),
    Presets = requireRemote("settings/presets.lua"),
    UISettings = requireRemote("settings/ui_settings.lua"),
}

---------------- LOAD MOVEMENT ----------------
_G.SimpleHub.Movement = {
    Fly = requireRemote("movement/fly.lua"),
    Dash = requireRemote("movement/dash.lua"),
    BunnyHop = requireRemote("movement/bunnyhop.lua"),
    WalkSpeed = requireRemote("movement/walkspeed.lua"),
    JumpPower = requireRemote("movement/jumppower.lua"),
    Noclip = requireRemote("movement/no-clip.lua"),
    AirControl = requireRemote("movement/air-control.lua"),
}

---------------- LOAD COMBAT ----------------
_G.SimpleHub.Combat = {
    AimAssist = requireRemote("combat/aim_assist.lua"),
    SilentAim = requireRemote("combat/silent_aim.lua"),
    FOV = requireRemote("combat/fov.lua"),
}

---------------- LOAD ESP ----------------
_G.SimpleHub.ESP = {
    Box = requireRemote("esp/box_esp.lua"),
    Name = requireRemote("esp/name_esp.lua"),
    Health = requireRemote("esp/health_esp.lua"),
    Distance = requireRemote("esp/distance_esp.lua"),
    Chams = requireRemote("esp/chams.lua"),
    Tracers = requireRemote("esp/tracers.lua"),
    Offscreen = requireRemote("esp/offscreen_arrows.lua"),
}

---------------- LOAD EXTRA ----------------
_G.SimpleHub.Extra = {
    Teleport = requireRemote("extra/teleport.lua"),
    Invisibility = requireRemote("extra/invisibility.lua"),
    AntiAFK = requireRemote("extra/anti_afk.lua"),
    FakeLag = requireRemote("extra/fake_lag.lua"),
    FakeDeath = requireRemote("extra/fake-death.lua"),
    SpinBot = requireRemote("extra/spinbot.lua"),
    WalkOnWater = requireRemote("extra/walk-on-water.lua"),
    Fullbright = requireRemote("extra/fullbright.lua"),
    RemoveGrass = requireRemote("extra/remove-grass.lua"),
    ThirdPerson = requireRemote("extra/third-person.lua"),
}

---------------- FINALIZE ----------------
print("✅ Simple Hub v3.7 Loaded Successfully")
print("📦 Modules Loaded:", HttpService:JSONEncode(_G.SimpleHub))
