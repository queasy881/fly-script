
-- ===========================================================================
-- VERTEX HUB - CONFIG SYSTEM
-- File: Config.lua
-- Persistent configuration saving/loading with file and memory fallback
-- ===========================================================================

local HttpService = game:GetService("HttpService")

local Config = {}
Config.__index = Config

-- Storage
Config.configFolder = "VertexHub"
Config.memoryFallback = {}
Config.currentConfig = "default"

-- Executor file system functions (auto-detected)
local writefile = writefile or nil
local readfile = readfile or nil
local isfile = isfile or nil
local isfolder = isfolder or nil
local makefolder = makefolder or nil
local listfiles = listfiles or nil
local delfile = delfile or nil

-- ===========================================================================
-- FILE SYSTEM UTILITIES
-- ===========================================================================
function Config.HasFileSystem()
	return writefile ~= nil and readfile ~= nil and isfile ~= nil
end

function Config.EnsureFolder()
	if not Config.HasFileSystem() then return false end
	local success = pcall(function()
		if isfolder and not isfolder(Config.configFolder) then
			if makefolder then
				makefolder(Config.configFolder)
			end
		end
	end)
	return success
end

function Config.GetPath(name)
	return Config.configFolder .. "/" .. name .. ".json"
end

-- ===========================================================================
-- SERIALIZATION: State -> Saveable Table
-- ===========================================================================
function Config.Serialize(State)
	local data = {}
	
	-- Combat (KillAura, Reach, Targeting - REQUIRED)
	data.Combat = {
		-- Kill Aura
		KillAura = State.Combat.KillAura,
		KillAuraRange = State.Combat.KillAuraRange,
		KillAuraCPS = State.Combat.KillAuraCPS,
		KillAuraLegit = State.Combat.KillAuraLegit,
		KillAuraPlayers = State.Combat.KillAuraPlayers,
		KillAuraNPCs = State.Combat.KillAuraNPCs,
		KillAuraWallCheck = State.Combat.KillAuraWallCheck,
		
		-- Reach
		Reach = State.Combat.Reach,
		ReachDistance = State.Combat.ReachDistance,
		ReachLegit = State.Combat.ReachLegit,
		
		-- Targeting
		TargetSortMode = State.Combat.TargetSortMode or "Distance",
		
		-- Prediction
		AimPrediction = State.Combat.AimPrediction,
		PredictionAmount = State.Combat.PredictionAmount,
		
		-- Aim Assist
		AimAssist = State.Combat.AimAssist,
		AimSmoothness = State.Combat.AimSmoothness,
		AimFOV = State.Combat.AimFOV,
		ShowFOVCircle = State.Combat.ShowFOVCircle,
		
		-- Silent Aim
		SilentAim = State.Combat.SilentAim,
		SilentAimHitChance = State.Combat.SilentAimHitChance,
		
		-- Other Combat
		Triggerbot = State.Combat.Triggerbot,
		TriggerbotDelay = State.Combat.TriggerbotDelay,
		AutoParry = State.Combat.AutoParry,
		HitboxExpander = State.Combat.HitboxExpander,
		HitboxSize = State.Combat.HitboxSize,
		Backtrack = State.Combat.Backtrack,
		BacktrackTime = State.Combat.BacktrackTime,
		TargetStrafe = State.Combat.TargetStrafe,
		StrafeSpeed = State.Combat.StrafeSpeed,
		StrafeRadius = State.Combat.StrafeRadius
	}
	
	-- ESP
	data.ESP = {
		NameESP = State.ESP.NameESP,
		BoxESP = State.ESP.BoxESP,
		HealthESP = State.ESP.HealthESP,
		DistanceESP = State.ESP.DistanceESP,
		Tracers = State.ESP.Tracers,
		SkeletonESP = State.ESP.SkeletonESP,
		OffscreenArrows = State.ESP.OffscreenArrows,
		Chams = State.ESP.Chams,
		ItemESP = State.ESP.ItemESP,
		NPCESP = State.ESP.NPCESP,
		MaxDistance = State.ESP.MaxDistance,
		TeamCheck = State.ESP.TeamCheck
	}
	
	-- Movement
	data.Movement = {
		Fly = State.Movement.Fly,
		FlySpeed = State.Movement.FlySpeed,
		FlyLegit = State.Movement.FlyLegit,
		Noclip = State.Movement.Noclip,
		Speed = State.Movement.Speed,
		SpeedValue = State.Movement.SpeedValue,
		SpeedLegit = State.Movement.SpeedLegit,
		JumpPower = State.Movement.JumpPower,
		JumpValue = State.Movement.JumpValue,
		InfiniteJump = State.Movement.InfiniteJump,
		BunnyHop = State.Movement.BunnyHop,
		LongJump = State.Movement.LongJump,
		LongJumpForce = State.Movement.LongJumpForce,
		SpeedGlide = State.Movement.SpeedGlide,
		GlideSpeed = State.Movement.GlideSpeed,
		Dash = State.Movement.Dash,
		DashForce = State.Movement.DashForce,
		DashCooldown = State.Movement.DashCooldown,
		ClickTP = State.Movement.ClickTP,
		AntiVoid = State.Movement.AntiVoid,
		VoidHeight = State.Movement.VoidHeight,
		Anchor = State.Movement.Anchor,
		SpinBot = State.Movement.SpinBot,
		SpinSpeed = State.Movement.SpinSpeed,
		FakeLag = State.Movement.FakeLag,
		LagIntensity = State.Movement.LagIntensity,
		AirControl = State.Movement.AirControl
	}
	
	-- Visuals
	data.Visuals = {
		Fullbright = State.Visuals.Fullbright,
		NoFog = State.Visuals.NoFog,
		NoShadows = State.Visuals.NoShadows,
		Crosshair = State.Visuals.Crosshair,
		CrosshairSize = State.Visuals.CrosshairSize,
		CrosshairGap = State.Visuals.CrosshairGap,
		CameraFOV = State.Visuals.CameraFOV,
		ThirdPerson = State.Visuals.ThirdPerson,
		Freecam = State.Visuals.Freecam,
		FreecamSpeed = State.Visuals.FreecamSpeed,
		XRay = State.Visuals.XRay,
		XRayTransparency = State.Visuals.XRayTransparency
	}
	
	-- Player (includes Invisibility)
	data.Player = {
		GodMode = State.Player.GodMode,
		NoRagdoll = State.Player.NoRagdoll,
		AutoRespawn = State.Player.AutoRespawn,
		CharScale = State.Player.CharScale,
		Invisibility = State.Player.Invisibility,
		InvisMode = State.Player.InvisMode,
		InvisOffset = State.Player.InvisOffset,
		NoRecoil = State.Player.NoRecoil,
		NoSpread = State.Player.NoSpread,
		InfiniteStamina = State.Player.InfiniteStamina
	}
	
	-- World
	data.World = {
		TimeOfDay = State.World.TimeOfDay,
		Gravity = State.World.Gravity,
		DeleteMode = State.World.DeleteMode,
		RemoveGrass = State.World.RemoveGrass
	}
	
	-- Troll
	data.Troll = {
		AnnoyPlayer = State.Troll.AnnoyPlayer,
		AnnoyTarget = State.Troll.AnnoyTarget,
		OrbitPlayer = State.Troll.OrbitPlayer,
		OrbitTarget = State.Troll.OrbitTarget,
		OrbitRadius = State.Troll.OrbitRadius,
		OrbitSpeed = State.Troll.OrbitSpeed,
		Fling = State.Troll.Fling,
		FlingPower = State.Troll.FlingPower,
		Headless = State.Troll.Headless
	}
	
	-- Misc
	data.Misc = {
		AntiAFK = State.Misc.AntiAFK,
		ChatSpam = State.Misc.ChatSpam,
		SpamMsg = State.Misc.SpamMsg,
		SpamDelay = State.Misc.SpamDelay,
		Watermark = State.Misc.Watermark,
		FPSCounter = State.Misc.FPSCounter,
		PingDisplay = State.Misc.PingDisplay,
		PlayerCount = State.Misc.PlayerCount,
		VelocityDisplay = State.Misc.VelocityDisplay,
		TargetInfo = State.Misc.TargetInfo,
		KeybindsDisplay = State.Misc.KeybindsDisplay
	}
	
	-- Settings (Color3 needs special handling)
	data.Settings = {
		AccentColor = {
			R = State.Settings.AccentColor.R,
			G = State.Settings.AccentColor.G,
			B = State.Settings.AccentColor.B
		}
	}
	
	return data
end

-- ===========================================================================
-- DESERIALIZATION: Saveable Table -> State
-- ===========================================================================
function Config.Deserialize(data, State)
	if not data then return false end
	
	local function applyCat(source, target)
		if not source or not target then return end
		for key, value in pairs(source) do
			if target[key] ~= nil then
				target[key] = value
			end
		end
	end
	
	-- Apply all categories
	applyCat(data.Combat, State.Combat)
	applyCat(data.ESP, State.ESP)
	applyCat(data.Movement, State.Movement)
	applyCat(data.Visuals, State.Visuals)
	applyCat(data.Player, State.Player)
	applyCat(data.World, State.World)
	applyCat(data.Troll, State.Troll)
	applyCat(data.Misc, State.Misc)
	
	-- Handle Color3
	if data.Settings and data.Settings.AccentColor then
		State.Settings.AccentColor = Color3.new(
			data.Settings.AccentColor.R or 0.235,
			data.Settings.AccentColor.G or 0.47,
			data.Settings.AccentColor.B or 1
		)
	end
	
	return true
end

-- ===========================================================================
-- SAVE CONFIG
-- ===========================================================================
function Config.SaveConfig(name, State)
	name = name or "default"
	
	-- Serialize state
	local data = Config.Serialize(State)
	
	-- Encode to JSON
	local success, json = pcall(function()
		return HttpService:JSONEncode(data)
	end)
	
	if not success then
		warn("[Vertex Config] Encode failed: " .. tostring(json))
		return false
	end
	
	-- Try file system
	if Config.HasFileSystem() then
		Config.EnsureFolder()
		local writeOk = pcall(function()
			writefile(Config.GetPath(name), json)
		end)
		if writeOk then
			Config.currentConfig = name
			print("[Vertex Config] Saved to file: " .. name)
			return true
		end
	end
	
	-- Fallback to memory
	Config.memoryFallback[name] = json
	Config.currentConfig = name
	print("[Vertex Config] Saved to memory: " .. name)
	return true
end

-- ===========================================================================
-- LOAD CONFIG
-- ===========================================================================
function Config.LoadConfig(name, State)
	name = name or "default"
	local json = nil
	
	-- Try file system
	if Config.HasFileSystem() then
		pcall(function()
			local path = Config.GetPath(name)
			if isfile(path) then
				json = readfile(path)
			end
		end)
	end
	
	-- Fallback to memory
	if not json then
		json = Config.memoryFallback[name]
	end
	
	-- Not found
	if not json then
		warn("[Vertex Config] Not found: " .. name)
		return false
	end
	
	-- Decode JSON
	local success, data = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	
	if not success or not data then
		warn("[Vertex Config] Decode failed: " .. name)
		return false
	end
	
	-- Apply to state
	Config.Deserialize(data, State)
	Config.currentConfig = name
	print("[Vertex Config] Loaded: " .. name)
	return true
end

-- ===========================================================================
-- GET CONFIG LIST
-- ===========================================================================
function Config.GetConfigList()
	local list = {}
	
	-- From file system
	if Config.HasFileSystem() and listfiles then
		Config.EnsureFolder()
		pcall(function()
			local files = listfiles(Config.configFolder)
			if files then
				for _, filepath in ipairs(files) do
					local name = filepath:match("([^/\\]+)%.json$")
					if name then
						table.insert(list, name)
					end
				end
			end
		end)
	end
	
	-- From memory (avoid duplicates)
	for name, _ in pairs(Config.memoryFallback) do
		local exists = false
		for _, n in ipairs(list) do
			if n == name then exists = true break end
		end
		if not exists then
			table.insert(list, name)
		end
	end
	
	return list
end

-- ===========================================================================
-- DELETE CONFIG
-- ===========================================================================
function Config.DeleteConfig(name)
	-- Delete from file system
	if Config.HasFileSystem() and delfile then
		pcall(function()
			local path = Config.GetPath(name)
			if isfile(path) then
				delfile(path)
			end
		end)
	end
	
	-- Delete from memory
	Config.memoryFallback[name] = nil
	print("[Vertex Config] Deleted: " .. name)
	return true
end

-- ===========================================================================
-- EXPORT CONFIG (Returns JSON string, copies to clipboard if available)
-- ===========================================================================
function Config.ExportConfig(State)
	local data = Config.Serialize(State)
	local success, json = pcall(function()
		return HttpService:JSONEncode(data)
	end)
	
	if not success then return nil end
	
	-- Try clipboard
	local setclipboard = setclipboard or toclipboard or set_clipboard
	if setclipboard then
		pcall(function() setclipboard(json) end)
		print("[Vertex Config] Exported to clipboard")
	end
	
	return json
end

-- ===========================================================================
-- IMPORT CONFIG (From JSON string)
-- ===========================================================================
function Config.ImportConfig(json, State)
	local success, data = pcall(function()
		return HttpService:JSONDecode(json)
	end)
	
	if not success or not data then
		warn("[Vertex Config] Import failed")
		return false
	end
	
	Config.Deserialize(data, State)
	print("[Vertex Config] Imported successfully")
	return true
end

-- ===========================================================================
-- AUTO-SAVE LOOP (Call this to start auto-saving)
-- ===========================================================================
function Config.StartAutoSave(State, interval)
	interval = interval or 60
	
	task.spawn(function()
		while true do
			task.wait(interval)
			if State.Config and State.Config.AutoSave then
				Config.SaveConfig(Config.currentConfig, State)
			end
		end
	end)
end

-- Export
_G.VertexConfig = Config
return Config
