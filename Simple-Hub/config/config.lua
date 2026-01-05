-- config.lua
-- Configuration management for Simple Hub
-- Save/Load system for user preferences

local HttpService = game:GetService("HttpService")
local Config = {}

-- Default configuration
local Defaults = {
	-- UI Settings
	MenuKey = "M",
	AccentColor = {60, 120, 255},
	DefaultTab = "Combat",
	
	-- HUD Defaults
	Watermark = true,
	FPSCounter = true,
	PingDisplay = true,
	PlayerCount = false,
	VelocityDisplay = false,
	KeybindsDisplay = false,
	TargetInfo = false,
	
	-- Feature Defaults
	FlySpeed = 50,
	WalkSpeed = 32,
	JumpPower = 100,
	AimFOV = 150,
	AimSmoothness = 15,
	KillAuraRange = 15,
	KillAuraCPS = 10,
	
	-- ESP Settings
	ESP_MaxDistance = 1000,
	ESP_TeamCheck = false,
	NameESP = false,
	BoxESP = false,
	HealthESP = false,
	DistanceESP = false,
	Tracers = false,
	SkeletonESP = false,
	OffscreenArrows = false,
	Chams = false,
	ItemESP = false,
	NPCESP = false,
	
	-- Visual Settings
	Fullbright = false,
	Crosshair = true,
	CrosshairSize = 10,
	CrosshairGap = 5,
	CameraFOV = 70,
	ThirdPerson = false,
	Freecam = false,
	XRay = false,
	
	-- Movement Defaults
	FlyLegit = false,
	SpeedLegit = false,
	Noclip = false,
	InfiniteJump = false,
	BunnyHop = false,
	LongJump = false,
	SpeedGlide = false,
	Dash = false,
	ClickTP = false,
	AntiVoid = false,
	Anchor = false,
	SpinBot = false,
	FakeLag = false,
	AirControl = false,
	
	-- Combat Defaults
	AimAssist = false,
	AimPrediction = false,
	PredictionAmount = 10,
	ShowFOVCircle = false,
	SilentAim = false,
	SilentAimHitChance = 100,
	KillAura = false,
	KillAuraPlayers = true,
	KillAuraNPCs = false,
	KillAuraWallCheck = true,
	KillAuraLegit = false,
	Reach = false,
	ReachDistance = 18,
	ReachLegit = false,
	Triggerbot = false,
	TriggerbotDelay = 10,
	AutoParry = false,
	HitboxExpander = false,
	HitboxSize = 5,
	Backtrack = false,
	BacktrackTime = 20,
	TargetStrafe = false,
	StrafeSpeed = 5,
	StrafeRadius = 10,
	
	-- World Defaults
	TimeOfDay = 14,
	Gravity = 196,
	DeleteMode = false,
	RemoveGrass = false,
	
	-- Player Defaults
	GodMode = false,
	NoRagdoll = false,
	AutoRespawn = false,
	CharScale = 100,
	Invisibility = false,
	InvisMode = "Safe",
	InvisOffset = 100,
	NoRecoil = false,
	NoSpread = false,
	InfiniteStamina = false,
	
	-- Troll Defaults
	AnnoyPlayer = false,
	AnnoyTarget = "",
	OrbitPlayer = false,
	OrbitTarget = "",
	OrbitRadius = 10,
	OrbitSpeed = 2,
	Fling = false,
	FlingPower = 500,
	Headless = false,
	
	-- Misc Defaults
	AntiAFK = false,
	ChatSpam = false,
	SpamMsg = "Vertex Hub!",
	SpamDelay = 2
}

-- Load config from file
local function loadFromFile()
	if not (isfolder and isfile) then return end
	
	-- Reset to defaults first
	for k, v in pairs(Defaults) do
		Config[k] = v
	end
	
	if isfolder("SimpleHub") and isfile("SimpleHub/config.json") then
		local success, data = pcall(function()
			local content = readfile("SimpleHub/config.json")
			return HttpService:JSONDecode(content)
		end)
		
		if success and data and type(data) == "table" then
			-- Merge loaded config with defaults
			for k, v in pairs(data) do
				Config[k] = v
			end
			print("[CONFIG] Loaded from file")
			return true
		end
	end
	
	print("[CONFIG] Using defaults")
	return false
end

-- Save config to file
local function saveToFile()
	if not writefile then return false end
	
	-- Create folder if it doesn't exist
	if not isfolder("SimpleHub") then
		pcall(function() makefolder("SimpleHub") end)
	end
	
	local success = pcall(function()
		local configJson = HttpService:JSONEncode(Config)
		writefile("SimpleHub/config.json", configJson)
	end)
	
	if success then
		print("[CONFIG] Saved to file")
		return true
	end
	
	return false
end

-- Get a config value
local function get(key, default)
	return Config[key] or default
end

-- Set a config value
local function set(key, value)
	Config[key] = value
	saveToFile()
	return true
end

-- Set multiple values at once
local function setMultiple(values)
	for k, v in pairs(values) do
		Config[k] = v
	end
	saveToFile()
	return true
end

-- Reset to defaults
local function reset()
	for k, v in pairs(Defaults) do
		Config[k] = v
	end
	saveToFile()
	print("[CONFIG] Reset to defaults")
	return true
end

-- Export all config
local function getAll()
	local copy = {}
	for k, v in pairs(Config) do
		copy[k] = v
	end
	return copy
end

-- Convert to menu-ready format
local function toMenuFormat()
	return {
		MenuKey = Enum.KeyCode[Config.MenuKey or "M"],
		AccentColor = Color3.fromRGB(
			Config.AccentColor and Config.AccentColor[1] or 60,
			Config.AccentColor and Config.AccentColor[2] or 120,
			Config.AccentColor and Config.AccentColor[3] or 255
		),
		DefaultTab = Config.DefaultTab or "Combat",
		Settings = getAll()
	}
end

-- Initialize
loadFromFile()

-- Module exports
return {
	get = get,
	set = set,
	setMultiple = setMultiple,
	reset = reset,
	getAll = getAll,
	save = saveToFile,
	load = loadFromFile,
	toMenuFormat = toMenuFormat,
	
	-- Constants
	DEFAULTS = Defaults,
	VERSION = "1.0.0"
}
