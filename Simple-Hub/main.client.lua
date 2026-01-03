-- Simple Hub main.client.lua

local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local function load(path)
    print("[LOADING]", path)
    local src = game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
    return loadstring(src)()
end

----------------------------------------------------------------
-- UTILS
----------------------------------------------------------------
load("utils/helpers.lua")
load("utils/math.lua")
load("utils/raycast.lua")

----------------------------------------------------------------
-- UI
----------------------------------------------------------------
local Animations = load("ui/animations.lua")
local Components = load("ui/components.lua")
local Tabs = load("ui/tabs.lua")

----------------------------------------------------------------
-- MOVEMENT
----------------------------------------------------------------
local Fly = load("movement/fly.lua")
local WalkSpeed = load("movement/walkspeed.lua")
local JumpPower = load("movement/jumppower.lua")
local Noclip = load("movement/noclip.lua")
local BunnyHop = load("movement/bunnyhop.lua")
local Dash = load("movement/dash.lua")

----------------------------------------------------------------
-- COMBAT (NO SILENT AIM)
----------------------------------------------------------------
local AimAssist = load("combat/aim_assist.lua")
local FOV = load("combat/fov.lua")

----------------------------------------------------------------
-- ESP
----------------------------------------------------------------
local NameESP = load("esp/name_esp.lua")
local BoxESP = load("esp/box_esp.lua")
local HealthESP = load("esp/health_esp.lua")
local DistanceESP = load("esp/distance_esp.lua")
local Chams = load("esp/chams.lua")

----------------------------------------------------------------
-- EXTRA
----------------------------------------------------------------
local Invisibility = load("extra/invisibility.lua")
local AntiAFK = load("extra/anti-afk.lua")
local SpinBot = load("extra/spinbot.lua")
local FakeLag = load("extra/fake-lag.lua")
local WalkOnWater = load("extra/walk-on-water.lua")
local Fullbright = load("extra/fullbright.lua")
local RemoveGrass = load("extra/remove-grass.lua")
local ThirdPerson = load("extra/third-person.lua")

----------------------------------------------------------------
-- START MENU
----------------------------------------------------------------
local startMenu = load("ui/menu.lua")

startMenu({
    Tabs = Tabs,
    Components = Components,
    Animations = Animations,

    -- movement
    Fly = Fly,
    WalkSpeed = WalkSpeed,
    JumpPower = JumpPower,
    Noclip = Noclip,
    BunnyHop = BunnyHop,
    Dash = Dash,

    -- combat
    AimAssist = AimAssist,
    FOV = FOV,

    -- esp
    NameESP = NameESP,
    BoxESP = BoxESP,
    HealthESP = HealthESP,
    DistanceESP = DistanceESP,
    Chams = Chams,

    -- extra
    Invisibility = Invisibility,
    AntiAFK = AntiAFK,
    SpinBot = SpinBot,
    FakeLag = FakeLag,
    WalkOnWater = WalkOnWater,
    Fullbright = Fullbright,
    RemoveGrass = RemoveGrass,
    ThirdPerson = ThirdPerson
})

print("[Simple Hub] Loaded successfully")
