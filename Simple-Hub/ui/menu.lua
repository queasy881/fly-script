-- ---------------------------------------------------------------------------
-- VERTEX HUB - NEON SIDEBAR REDESIGN
-- Fully integrated with config file
-- ---------------------------------------------------------------------------

return function(Components)
	Components = Components or _G.VertexComponents
	
	-- ---------------------------------------------------------------------------
	-- SERVICES
	-- ---------------------------------------------------------------------------
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local RunService = game:GetService("RunService")
	local TweenService = game:GetService("TweenService")
	local Lighting = game:GetService("Lighting")
	local TeleportService = game:GetService("TeleportService")
	local Debris = game:GetService("Debris")
	local Stats = game:GetService("Stats")
	local HttpService = game:GetService("HttpService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local mouse = player:GetMouse()
	
	-- ---------------------------------------------------------------------------
	-- CONFIGURATION SYSTEM INTEGRATION
	-- ---------------------------------------------------------------------------
	local Config = {}
local ConfigLoaded = false

local function loadConfig()
	local success, configModule = pcall(function()
		if _G.VertexConfig then
			return _G.VertexConfig
		end

		for _, obj in pairs(game:GetDescendants()) do
			if obj.Name == "config" and obj:IsA("ModuleScript") then
				return require(obj)
			end
		end

		return nil
	end)

	if success and configModule then
		Config = configModule
		ConfigLoaded = true
		print("[CONFIG] Configuration loaded successfully")
		return true
	else
		print("[CONFIG] Using default configuration")

		Config = {
			get = function(key, default)
				return Config[key] or default
			end,

			set = function(key, value)
				Config[key] = value
				return true
			end,

			setMultiple = function(values)
				for k, v in pairs(values) do
					Config[k] = v
				end
				return true
			end,

			reset = function()
				return true
			end,

			getAll = function()
				return {}
			end,

			save = function()
	return true
end,

load = function()
	return true
end,

toMenuFormat = function()

				return {
					MenuKey = Enum.KeyCode.M,
					AccentColor = Color3.fromRGB(60, 120, 255),
					DefaultTab = "Combat",
					Settings = {}
				}
			end,

			DEFAULTS = {},
			VERSION = "1.0.0"
		}

		ConfigLoaded = false
		return false
	end
end

loadConfig()

	
	-- ---------------------------------------------------------------------------
	-- VIBRANT NEON COLOR PALETTE
	-- ---------------------------------------------------------------------------
	local NeonColors = {
		ElectricPurple = Color3.fromRGB(180, 70, 255),
		BrightCyan = Color3.fromRGB(0, 255, 255),
		HotPink = Color3.fromRGB(255, 20, 147),
		LimeGreen = Color3.fromRGB(50, 255, 50),
		FieryOrange = Color3.fromRGB(255, 100, 0),
		NeonBlue = Color3.fromRGB(0, 150, 255),
		VibrantYellow = Color3.fromRGB(255, 255, 0),
		Background = Color3.fromRGB(10, 10, 15),
		Glass = Color3.fromRGB(20, 20, 30),
		GlassLight = Color3.fromRGB(30, 30, 45),
		GlassHover = Color3.fromRGB(40, 40, 60),
		Text = Color3.fromRGB(255, 255, 255),
		TextSoft = Color3.fromRGB(220, 220, 240),
		TextMuted = Color3.fromRGB(150, 150, 180),
		Glow = Color3.fromRGB(100, 200, 255),
		Outline = Color3.fromRGB(0, 200, 255),
		Shadow = Color3.fromRGB(0, 0, 0, 0.8)
	}
	
	-- ---------------------------------------------------------------------------
	-- UTILITY FUNCTIONS
	-- ---------------------------------------------------------------------------
	local function getCharacter() return player.Character end
	local function getRoot() local c = getCharacter() return c and c:FindFirstChild("HumanoidRootPart") end
	local function getHumanoid() local c = getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end
	local function getHead() local c = getCharacter() return c and c:FindFirstChild("Head") end
	local function getTool() local c = getCharacter() return c and c:FindFirstChildOfClass("Tool") end
	
	local function tween(obj, props, tweenInfo)
		if not obj then return end
		local t = 0.2
		local style = Enum.EasingStyle.Quad
		local direction = Enum.EasingDirection.Out

		if type(tweenInfo) == "table" then
			t = tweenInfo.Time or t
			style = tweenInfo.Style or style
			direction = tweenInfo.Direction or direction
		elseif type(tweenInfo) == "number" then
			t = tweenInfo
		end

		local ti = TweenInfo.new(t, style, direction)
		local tw = TweenService:Create(obj, ti, props)
		tw:Play()
		return tw
	end
	
	-- ---------------------------------------------------------------------------
	-- ENTITY CACHE
	-- ---------------------------------------------------------------------------
	local EntityCache = { players = {}, npcs = {}, items = {} }
	
	local function updateEntityCache()
		for name, data in pairs(EntityCache.players) do
			if not data.Player or not data.Player.Parent then
				EntityCache.players[name] = nil
			elseif data.Character then
				if not data.Character.Parent or not data.Humanoid or data.Humanoid.Health <= 0 then
					data.Character = nil
					data.Humanoid = nil
					data.RootPart = nil
					data.Head = nil
				end
			end
		end
		
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				if not EntityCache.players[plr.Name] then
					EntityCache.players[plr.Name] = { Player = plr, IsPlayer = true, Team = plr.Team }
				end
				local data = EntityCache.players[plr.Name]
				data.Team = plr.Team
				if plr.Character and not data.Character then
					data.Character = plr.Character
					data.Humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
					data.RootPart = plr.Character:FindFirstChild("HumanoidRootPart")
					data.Head = plr.Character:FindFirstChild("Head")
				end
			end
		end
		
		EntityCache.npcs = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(obj) then
				local hum = obj:FindFirstChildOfClass("Humanoid")
				local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
				if hum and hum.Health > 0 and root then
					table.insert(EntityCache.npcs, {
						Model = obj, Name = obj.Name, Humanoid = hum, RootPart = root,
						Head = obj:FindFirstChild("Head"), IsNPC = true
					})
				end
			end
		end
		
		EntityCache.items = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Tool") then
				local handle = obj:FindFirstChild("Handle")
				if handle then
					table.insert(EntityCache.items, {Object = obj, Position = handle.Position, Name = obj.Name})
				end
			elseif obj:IsA("BasePart") then
				local n = obj.Name:lower()
				if n:find("coin") or n:find("gem") or n:find("item") or n:find("pickup") or n:find("chest") then
					table.insert(EntityCache.items, {Object = obj, Position = obj.Position, Name = obj.Name})
				end
			end
		end
	end
	
	-- ---------------------------------------------------------------------------
	-- DRAWING API CHECK
	-- ---------------------------------------------------------------------------
	local DrawingEnabled = false
	pcall(function()
		local test = Drawing.new("Line")
		if test then
			test:Remove()
			DrawingEnabled = true
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- DRAWING OBJECT POOL (FIXED VERSION)
	-- ---------------------------------------------------------------------------
	local DrawingPool = { text = {}, square = {}, line = {}, triangle = {}, circle = {} }
	local ActiveDrawings = {}
	
	local function getDrawing(drawType)
		if not DrawingEnabled then return nil end
		local pool = DrawingPool[drawType]
		if not pool then return nil end
		
		for i, obj in ipairs(pool) do
			if not obj._inUse then
				obj._inUse = true
				obj.Visible = true
				table.insert(ActiveDrawings, obj)
				return obj
			end
		end
		
		local newDraw
		local ok = pcall(function()
			if drawType == "text" then
				newDraw = Drawing.new("Text")
				newDraw.Size = 14
				newDraw.Center = true
				newDraw.Outline = true
				newDraw._inUse = false
			elseif drawType == "square" then
				newDraw = Drawing.new("Square")
				newDraw.Thickness = 1
				newDraw.Filled = false
				newDraw._inUse = false
			elseif drawType == "line" then
				newDraw = Drawing.new("Line")
				newDraw.Thickness = 1
				newDraw._inUse = false
			elseif drawType == "triangle" then
				newDraw = Drawing.new("Triangle")
				newDraw.Filled = true
				newDraw._inUse = false
			elseif drawType == "circle" then
				newDraw = Drawing.new("Circle")
				newDraw.Thickness = 2
				newDraw.NumSides = 64
				newDraw.Filled = false
				newDraw._inUse = false
			end
		end)
		
		if ok and newDraw then
			newDraw._inUse = true
			newDraw.Visible = true
			table.insert(pool, newDraw)
			table.insert(ActiveDrawings, newDraw)
			return newDraw
		end
		return nil
	end
	
	local function releaseAllDrawings()
		for _, obj in ipairs(ActiveDrawings) do
			if obj then 
				obj.Visible = false 
				obj._inUse = false 
			end
		end
		ActiveDrawings = {}
	end
	
	-- ---------------------------------------------------------------------------
	-- STATIC HUD DRAWINGS
	-- ---------------------------------------------------------------------------
	local HUD = {}
	if DrawingEnabled then
		pcall(function()
			HUD.FOVCircle = Drawing.new("Circle")
			HUD.FOVCircle.Thickness = 2
			HUD.FOVCircle.NumSides = 64
			HUD.FOVCircle.Filled = false
			HUD.FOVCircle.Visible = false
			HUD.FOVCircle.Transparency = 0.7
			
			HUD.CrosshairL = Drawing.new("Line")
			HUD.CrosshairL.Thickness = 2
			HUD.CrosshairL.Visible = false
			HUD.CrosshairR = Drawing.new("Line")
			HUD.CrosshairR.Thickness = 2
			HUD.CrosshairR.Visible = false
			HUD.CrosshairT = Drawing.new("Line")
			HUD.CrosshairT.Thickness = 2
			HUD.CrosshairT.Visible = false
			HUD.CrosshairB = Drawing.new("Line")
			HUD.CrosshairB.Thickness = 2
			HUD.CrosshairB.Visible = false
			
			HUD.Watermark = Drawing.new("Text")
			HUD.Watermark.Size = 20
			HUD.Watermark.Outline = true
			HUD.Watermark.Position = Vector2.new(10, 10)
			HUD.Watermark.Visible = false
			
			HUD.FPS = Drawing.new("Text")
			HUD.FPS.Size = 16
			HUD.FPS.Outline = true
			HUD.FPS.Position = Vector2.new(10, 35)
			HUD.FPS.Visible = false
			
			HUD.Ping = Drawing.new("Text")
			HUD.Ping.Size = 16
			HUD.Ping.Outline = true
			HUD.Ping.Position = Vector2.new(10, 55)
			HUD.Ping.Visible = false
			
			HUD.PlrCount = Drawing.new("Text")
			HUD.PlrCount.Size = 16
			HUD.PlrCount.Outline = true
			HUD.PlrCount.Position = Vector2.new(10, 75)
			HUD.PlrCount.Visible = false
			
			HUD.Velocity = Drawing.new("Text")
			HUD.Velocity.Size = 16
			HUD.Velocity.Outline = true
			HUD.Velocity.Position = Vector2.new(10, 95)
			HUD.Velocity.Visible = false
			
			HUD.TargetInfo = Drawing.new("Text")
			HUD.TargetInfo.Size = 16
			HUD.TargetInfo.Outline = true
			HUD.TargetInfo.Position = Vector2.new(10, 115)
			HUD.TargetInfo.Visible = false
			
			HUD.Keybinds = Drawing.new("Text")
			HUD.Keybinds.Size = 14
			HUD.Keybinds.Outline = true
			HUD.Keybinds.Visible = false
		end)
	end
	
	-- ---------------------------------------------------------------------------
	-- ALL STATE VARIABLES
	-- ---------------------------------------------------------------------------
	local State = {
		ESP = {
			NameESP = false, BoxESP = false, HealthESP = false, DistanceESP = false,
			Tracers = false, SkeletonESP = false, OffscreenArrows = false, Chams = false,
			ItemESP = false, NPCESP = false, MaxDistance = 1000, TeamCheck = false
		},
		Combat = {
			AimAssist = false, AimSmoothness = 0.15, AimFOV = 150, AimPrediction = false,
			PredictionAmount = 0.1, ShowFOVCircle = false,
			SilentAim = false, SilentAimHitChance = 100,
			KillAura = false, KillAuraRange = 15, KillAuraCPS = 10, KillAuraLegit = false,
			KillAuraPlayers = true, KillAuraNPCs = false, KillAuraWallCheck = true,
			Reach = false, ReachDistance = 18, ReachLegit = false,
			Triggerbot = false, TriggerbotDelay = 0.1,
			AutoParry = false, HitboxExpander = false, HitboxSize = 5,
			Backtrack = false, BacktrackTime = 0.2,
			TargetStrafe = false, StrafeSpeed = 5, StrafeRadius = 10
		},
		Movement = {
			Fly = false, FlySpeed = 50, FlyLegit = false, Noclip = false,
			Speed = false, SpeedValue = 16, SpeedLegit = false,
			JumpPower = false, JumpValue = 50, InfiniteJump = false,
			BunnyHop = false, LongJump = false, LongJumpForce = 100,
			SpeedGlide = false, GlideSpeed = 10,
			Dash = false, DashForce = 100, DashCooldown = 1,
			ClickTP = false, AntiVoid = false, VoidHeight = -100, Anchor = false,
			SpinBot = false, SpinSpeed = 20, FakeLag = false, LagIntensity = 5, AirControl = false
		},
		Visuals = {
			Fullbright = false, NoFog = false, NoShadows = false,
			Crosshair = false, CrosshairSize = 10, CrosshairGap = 5,
			CameraFOV = 70, ThirdPerson = false, Freecam = false, FreecamSpeed = 1,
			XRay = false, XRayTransparency = 0.5
		},
		World = { TimeOfDay = 14, Gravity = 196.2, DeleteMode = false, RemoveGrass = false },
		Player = {
			GodMode = false, NoRagdoll = false, AutoRespawn = false, CharScale = 1,
			Invisibility = false, InvisMode = "Safe", InvisOffset = 100,
			NoRecoil = false, NoSpread = false, InfiniteStamina = false
		},
		Troll = {
			AnnoyPlayer = false, AnnoyTarget = "", OrbitPlayer = false, OrbitTarget = "",
			OrbitRadius = 10, OrbitSpeed = 2, Fling = false, FlingPower = 500, Headless = false
		},
		Misc = {
			AntiAFK = false, ChatSpam = false, SpamMsg = "Vertex Hub!", SpamDelay = 2,
			Watermark = false, FPSCounter = false, PingDisplay = false, PlayerCount = false,
			VelocityDisplay = false, TargetInfo = false, KeybindsDisplay = false
		},
		Settings = { MenuKey = Enum.KeyCode.M, AccentColor = Color3.fromRGB(60, 120, 255) }
	}
	
	-- Load state from config
	local function loadStateFromConfig()
		if ConfigLoaded then
			local configData = Config.getAll()
			if configData then
				local menuKeyStr = Config.get("MenuKey", "M")
				if menuKeyStr and Enum.KeyCode[menuKeyStr] then
					State.Settings.MenuKey = Enum.KeyCode[menuKeyStr]
				end
				
				local accentColor = Config.get("AccentColor", {60, 120, 255})
				if accentColor then
					State.Settings.AccentColor = Color3.fromRGB(accentColor[1] or 60, accentColor[2] or 120, accentColor[3] or 255)
				end
				
				for category, values in pairs(State) do
					if category ~= "Settings" then
						for key, _ in pairs(values) do
							local configValue = Config.get(key)
							if configValue ~= nil then
								State[category][key] = configValue
							end
						end
					end
				end
				print("[CONFIG] State loaded from configuration")
			end
		end
	end
	
	-- Save state to config
	local function saveStateToConfig()
		if ConfigLoaded then
			local configValues = {}
			
			configValues["MenuKey"] = tostring(State.Settings.MenuKey):gsub("Enum.KeyCode.", "")
			
			local r, g, b = math.floor(State.Settings.AccentColor.r * 255), 
						   math.floor(State.Settings.AccentColor.g * 255), 
						   math.floor(State.Settings.AccentColor.b * 255)
			configValues["AccentColor"] = {r, g, b}
			
			for category, values in pairs(State) do
				if category ~= "Settings" then
					for key, value in pairs(values) do
						configValues[key] = value
					end
				end
			end
			
			Config.setMultiple(configValues)
			Config.save()
			print("[CONFIG] State saved to configuration")
		end
	end
	
	loadStateFromConfig()
	
	-- ---------------------------------------------------------------------------
	-- STORAGE
	-- ---------------------------------------------------------------------------
	local BacktrackPositions = {}
	local CurrentTarget = nil
	local LastAttackTime = 0
	local LastTriggerbotTime = 0
	local LastDashTime = 0
	local FreecamPos = Vector3.new(0, 50, 0)
	local FreecamAngles = Vector2.new(0, 0)
	local FPSData = { frames = 0, lastTime = tick(), fps = 60 }
	local PrevMouseState = { behavior = nil, icon = nil }
	local OriginalLighting = {
		Ambient = Lighting.Ambient, Brightness = Lighting.Brightness,
		FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
		GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime
	}
	local OriginalGravity = workspace.Gravity
	
	-- ---------------------------------------------------------------------------
	-- TARGET ACQUISITION SYSTEM
	-- ---------------------------------------------------------------------------
	local function getBestTarget(options)
		options = options or {}
		local range = options.Range or 150
		local targetPlayers = options.Players ~= false
		local targetNPCs = options.NPCs or false
		local wallCheck = options.WallCheck or false
		local useFOV = options.UseFOV or false
		local fov = options.FOV or 150
		local sortBy = options.Sort or "Distance"
		
		local myRoot = getRoot()
		if not myRoot then return nil end
		
		local targets = {}
		local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		local myTeam = player.Team
		
		if targetPlayers then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					if State.ESP.TeamCheck and data.Team and myTeam and data.Team == myTeam then continue end
					
					local dist = (myRoot.Position - data.RootPart.Position).Magnitude
					if dist <= range then
						local head = data.Head or data.RootPart
						local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
						local screenDist = onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude or math.huge
						
						if not useFOV or screenDist <= fov then
							local pass = true
							if wallCheck then
								local params = RaycastParams.new()
								params.FilterDescendantsInstances = {getCharacter(), data.Character}
								params.FilterType = Enum.RaycastFilterType.Blacklist
								local result = workspace:Raycast(myRoot.Position, data.RootPart.Position - myRoot.Position, params)
								pass = result == nil
							end
							if pass then
								table.insert(targets, { Entity = data, Distance = dist, ScreenDistance = screenDist, Health = data.Humanoid.Health })
							end
						end
					end
				end
			end
		end
		
		if targetNPCs then
			for _, data in ipairs(EntityCache.npcs) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					local dist = (myRoot.Position - data.RootPart.Position).Magnitude
					if dist <= range then
						local head = data.Head or data.RootPart
						local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
						local screenDist = onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude or math.huge
						if not useFOV or screenDist <= fov then
							table.insert(targets, { Entity = data, Distance = dist, ScreenDistance = screenDist, Health = data.Humanoid.Health })
						end
					end
				end
			end
		end
		
		if #targets == 0 then return nil end
		
		table.sort(targets, function(a, b)
			if sortBy == "Distance" then return a.Distance < b.Distance
			elseif sortBy == "Health" then return a.Health < b.Health
			elseif sortBy == "Angle" then return a.ScreenDistance < b.ScreenDistance
			end
			return a.Distance < b.Distance
		end)
		
		CurrentTarget = targets[1].Entity
		return targets[1].Entity
	end
	
	-- ---------------------------------------------------------------------------
	-- FLY SYSTEM
	-- ---------------------------------------------------------------------------
	local FlySystem = { enabled = false, bodyGyro = nil, bodyVelocity = nil, currentVel = Vector3.new() }
	
	function FlySystem:Enable()
		local root = getRoot()
		local hum = getHumanoid()
		if not root or not hum then return end
		self.enabled = true
		hum.PlatformStand = true
		self.bodyGyro = Instance.new("BodyGyro")
		self.bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		self.bodyGyro.P = 1e4
		self.bodyGyro.Parent = root
		self.bodyVelocity = Instance.new("BodyVelocity")
		self.bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		self.bodyVelocity.Velocity = Vector3.new()
		self.bodyVelocity.Parent = root
	end
	
	function FlySystem:Disable()
		self.enabled = false
		local hum = getHumanoid()
		if hum then 
			hum.PlatformStand = false 
		end
		if self.bodyGyro then 
			self.bodyGyro:Destroy() 
			self.bodyGyro = nil 
		end
		if self.bodyVelocity then 
			self.bodyVelocity:Destroy() 
			self.bodyVelocity = nil 
		end
	end
	
	function FlySystem:Update()
		if not self.enabled or not self.bodyVelocity or not self.bodyGyro then return end
		self.bodyGyro.CFrame = camera.CFrame
		local dir = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
		if dir.Magnitude > 0 then dir = dir.Unit end
		local target = dir * State.Movement.FlySpeed
		if State.Movement.FlyLegit then
			self.currentVel = self.currentVel:Lerp(target, 0.08)
			self.bodyVelocity.Velocity = self.currentVel
		else
			self.bodyVelocity.Velocity = target
		end
	end
	
	-- ---------------------------------------------------------------------------
	-- INVISIBILITY SYSTEM
	-- ---------------------------------------------------------------------------
	local InvisSystem = {
		enabled = false,
		originalTransparencies = {},
		connection = nil
	}
	
	function InvisSystem:Enable()
		local char = getCharacter()
		if not char then return end
		
		self.enabled = true
		self.originalTransparencies = {}
		
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				self.originalTransparencies[part] = part.Transparency
				part.Transparency = 1
			elseif part:IsA("Decal") or part:IsA("Texture") then
				self.originalTransparencies[part] = part.Transparency
				part.Transparency = 1
			end
		end
		
		for _, acc in ipairs(char:GetChildren()) do
			if acc:IsA("Accessory") then
				local handle = acc:FindFirstChild("Handle")
				if handle then
					self.originalTransparencies[handle] = handle.Transparency
					handle.Transparency = 1
				end
			end
		end
	end
	
	function InvisSystem:Disable()
		self.enabled = false
		
		for part, trans in pairs(self.originalTransparencies) do
			if part and part.Parent then
				pcall(function()
					part.Transparency = trans
				end)
			end
		end
		self.originalTransparencies = {}
	end
	
	-- ---------------------------------------------------------------------------
	-- EXECUTOR API SAFETY CHECK
	-- ---------------------------------------------------------------------------
	local function safeGetGlobal(name)
		local ok, val = pcall(function() return getfenv()[name] end)
		if ok and val then return val end
		ok, val = pcall(function() return _G[name] end)
		if ok and val then return val end
		return nil
	end
	
	local hookmetamethod = safeGetGlobal("hookmetamethod")
	local getnamecallmethod = safeGetGlobal("getnamecallmethod")
	local firetouchinterest = safeGetGlobal("firetouchinterest")
	local mouse1click = safeGetGlobal("mouse1click")
	local mouse2click = safeGetGlobal("mouse2click")
	
	-- ---------------------------------------------------------------------------
	-- KILLAURA - SERVER VALIDATED
	-- ---------------------------------------------------------------------------
	local LEGIT_RANGE = 14.4
	local OriginalRemotes = {}
	local KillAuraHooked = false
	
	local function hookKillAura()
		if KillAuraHooked then return end
		if not hookmetamethod or not getnamecallmethod then return end
		KillAuraHooked = true
		
		pcall(function()
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}
				
				if method == "FireServer" and State.Combat.KillAura then
					local remoteName = self.Name:lower()
					
					if remoteName:find("attack") or remoteName:find("hit") or remoteName:find("damage") or remoteName:find("swing") then
						local myRoot = getRoot()
						local target = CurrentTarget
						
						if myRoot and target and target.RootPart then
							local distance = (myRoot.Position - target.RootPart.Position).Magnitude
							
							if distance <= State.Combat.KillAuraRange and distance > LEGIT_RANGE then
								local lookVector = (target.RootPart.Position - myRoot.Position).Unit
								local offsetDistance = math.max(distance - LEGIT_RANGE, 0)
								local reportedPosition = myRoot.Position + lookVector * offsetDistance
								
								for i, arg in ipairs(args) do
									if typeof(arg) == "Vector3" then
										args[i] = reportedPosition
									elseif typeof(arg) == "CFrame" then
										args[i] = CFrame.new(reportedPosition) * (arg - arg.Position)
									elseif typeof(arg) == "table" then
										if arg.Position then
											arg.Position = reportedPosition
										end
										if arg.Origin then
											arg.Origin = reportedPosition
										end
									end
								end
							end
						end
					end
				end
				
				return oldNamecall(self, unpack(args))
			end)
		end)
	end
	
	task.defer(hookKillAura)
	
	-- ---------------------------------------------------------------------------
	-- SILENT AIM HOOKS
	-- ---------------------------------------------------------------------------
	local function getAimTarget()
		return getBestTarget({
			Range = 1000, Players = true, NPCs = true,
			UseFOV = true, FOV = State.Combat.AimFOV, Sort = "Angle"
		})
	end
	
	local function initSilentAimHooks()
		if not hookmetamethod or not getnamecallmethod then return end
		
		pcall(function()
			local oldIndex
			oldIndex = hookmetamethod(game, "__index", function(self, key)
				if State.Combat.SilentAim and self == mouse then
					if math.random(1, 100) <= State.Combat.SilentAimHitChance then
						local target = getAimTarget()
						if target then
							local pos = (target.Head or target.RootPart).Position
							if State.Combat.AimPrediction and target.RootPart then
								pos = pos + target.RootPart.Velocity * State.Combat.PredictionAmount
							end
							if key == "Hit" then return CFrame.new(pos) end
							if key == "Target" then return target.Head or target.RootPart end
							if key == "X" then return camera:WorldToViewportPoint(pos).X end
							if key == "Y" then return camera:WorldToViewportPoint(pos).Y end
						end
					end
				end
				return oldIndex(self, key)
			end)
		end)
		
		pcall(function()
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}
				
				if State.Combat.SilentAim and self == workspace then
					if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
						if math.random(1, 100) <= State.Combat.SilentAimHitChance then
							local target = getAimTarget()
							if target then
								local pos = (target.Head or target.RootPart).Position
								if State.Combat.AimPrediction and target.RootPart then
									pos = pos + target.RootPart.Velocity * State.Combat.PredictionAmount
								end
								if method == "Raycast" and args[1] then
									return oldNamecall(self, args[1], (pos - args[1]).Unit * 1000, unpack(args, 3))
								elseif args[1] and typeof(args[1]) == "Ray" then
									return oldNamecall(self, Ray.new(args[1].Origin, (pos - args[1].Origin).Unit * 1000), unpack(args, 2))
								end
							end
						end
					end
				end
				return oldNamecall(self, ...)
			end)
		end)
	end
	
	task.defer(initSilentAimHooks)
	
	-- ---------------------------------------------------------------------------
	-- BACKGROUND LOOPS
	-- ---------------------------------------------------------------------------
	task.spawn(function()
		while true do
			if State.Misc.ChatSpam then
				pcall(function()
					local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
					if chatEvents then
						local sayMsg = chatEvents:FindFirstChild("SayMessageRequest")
						if sayMsg then 
							sayMsg:FireServer(State.Misc.SpamMsg, "All") 
						end
					end
				end)
			end
			task.wait(State.Misc.SpamDelay)
		end
	end)
	
	task.spawn(function()
		while true do
			if State.Player.AutoRespawn then
				local hum = getHumanoid()
				if hum and hum.Health <= 0 then
					task.wait(0.1)
					pcall(function() player:LoadCharacter() end)
				end
			end
			task.wait(0.5)
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- CHAMS UPDATE
	-- ---------------------------------------------------------------------------
	local function updateChams()
		for name, data in pairs(EntityCache.players) do
			if data.Character then
				local existing = data.Character:FindFirstChild("VertexChams")
				if State.ESP.Chams then
					if not existing then
						local h = Instance.new("Highlight")
						h.Name = "VertexChams"
						h.FillColor = Color3.fromRGB(255, 0, 0)
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						h.FillTransparency = 0.5
						h.Parent = data.Character
					end
				else
					if existing then existing:Destroy() end
				end
			end
		end
		for _, data in ipairs(EntityCache.npcs) do
			if data.Model then
				local existing = data.Model:FindFirstChild("VertexChams")
				if State.ESP.Chams and State.ESP.NPCESP then
					if not existing then
						local h = Instance.new("Highlight")
						h.Name = "VertexChams"
						h.FillColor = Color3.fromRGB(0, 200, 255)
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						h.FillTransparency = 0.5
						h.Parent = data.Model
					end
				else
					if existing then existing:Destroy() end
				end
			end
		end
	end
	
	-- ---------------------------------------------------------------------------
	-- MAIN UPDATE LOOP (RESTORED FROM ORIGINAL)
	-- ---------------------------------------------------------------------------
	local lastCacheUpdate = 0
	
	RunService.RenderStepped:Connect(function(dt)
		camera = workspace.CurrentCamera
		local char = getCharacter()
		local root = getRoot()
		local hum = getHumanoid()
		
		if tick() - lastCacheUpdate > 0.5 then
			lastCacheUpdate = tick()
			updateEntityCache()
		end
		
		FPSData.frames = FPSData.frames + 1
		if tick() - FPSData.lastTime >= 1 then
			FPSData.fps = FPSData.frames
			FPSData.frames = 0
			FPSData.lastTime = tick()
		end
		
		if State.Movement.Fly then
			if not FlySystem.enabled then FlySystem:Enable() end
			FlySystem:Update()
		elseif FlySystem.enabled then
			FlySystem:Disable()
		end
		
		if State.Movement.Noclip and char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
		
		if State.Movement.Speed and hum then
			if State.Movement.SpeedLegit then
				hum.WalkSpeed = hum.WalkSpeed + (State.Movement.SpeedValue - hum.WalkSpeed) * 0.1
			else
				hum.WalkSpeed = State.Movement.SpeedValue
			end
		end
		
		if State.Movement.JumpPower and hum then
			hum.JumpPower = State.Movement.JumpValue
		end
		
		if State.Movement.BunnyHop and hum and hum.FloorMaterial ~= Enum.Material.Air then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		
		if State.Movement.SpeedGlide and root and hum and hum:GetState() == Enum.HumanoidStateType.Freefall then
			root.Velocity = Vector3.new(root.Velocity.X, math.max(root.Velocity.Y, -State.Movement.GlideSpeed * 10), root.Velocity.Z)
		end
		
		if State.Movement.AntiVoid and root and root.Position.Y < State.Movement.VoidHeight then
			root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
		end
		
		if State.Movement.Anchor and root then 
			root.Anchored = true
		elseif root and root.Anchored and not State.Movement.Anchor then 
			root.Anchored = false 
		end
		
		if State.Movement.SpinBot and root then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.Movement.SpinSpeed), 0)
		end
		
		if State.Movement.FakeLag and root and math.random(1, 10) <= State.Movement.LagIntensity then
			root.Velocity = Vector3.new(0, root.Velocity.Y, 0)
		end
		
		if State.Movement.AirControl and hum and root and hum:GetState() == Enum.HumanoidStateType.Freefall then
			local dir = Vector3.new()
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
			if dir.Magnitude > 0 then 
				root.Velocity = Vector3.new(dir.Unit.X * 50, root.Velocity.Y, dir.Unit.Z * 50) 
			end
		end
		
		if State.Combat.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target = getBestTarget({ Range = 1000, Players = true, NPCs = true, UseFOV = true, FOV = State.Combat.AimFOV, Sort = "Angle" })
			if target and (target.Head or target.RootPart) then
				local pos = (target.Head or target.RootPart).Position
				if State.Combat.AimPrediction and target.RootPart then
					pos = pos + target.RootPart.Velocity * State.Combat.PredictionAmount
				end
				camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, pos), State.Combat.AimSmoothness)
			end
		end
		
		if State.Combat.TargetStrafe and root and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target = getBestTarget({ Range = State.Combat.StrafeRadius * 2, Players = true, NPCs = true })
			if target and target.RootPart then
				local ang = tick() * State.Combat.StrafeSpeed
				local off = Vector3.new(math.cos(ang) * State.Combat.StrafeRadius, 0, math.sin(ang) * State.Combat.StrafeRadius)
				root.CFrame = CFrame.new(target.RootPart.Position + off, target.RootPart.Position)
			end
		end
		
		if State.Combat.KillAura and root then
			local now = tick()
			local cooldown = 1 / State.Combat.KillAuraCPS
			if State.Combat.KillAuraLegit then cooldown = cooldown * (1 + math.random() * 0.3) end
			
			if now - LastAttackTime >= cooldown then
				local target = getBestTarget({
					Range = State.Combat.KillAuraRange,
					Players = State.Combat.KillAuraPlayers,
					NPCs = State.Combat.KillAuraNPCs,
					WallCheck = State.Combat.KillAuraWallCheck
				})
				
				if target and target.RootPart then
					LastAttackTime = now
					CurrentTarget = target
					local tool = getTool()
					if tool then
						pcall(function() tool:Activate() end)
						pcall(function()
							local handle = tool:FindFirstChild("Handle")
							if handle and firetouchinterest then
								firetouchinterest(handle, target.RootPart, 0)
								task.defer(function() firetouchinterest(handle, target.RootPart, 1) end)
							end
						end)
					end
				end
			end
		end
		
		if State.Combat.Triggerbot then
			local now = tick()
			if now - LastTriggerbotTime >= State.Combat.TriggerbotDelay then
				local tgt = mouse.Target
				if tgt and Players:GetPlayerFromCharacter(tgt.Parent) then
					LastTriggerbotTime = now
					if mouse1click then
						pcall(function() mouse1click() end)
					end
				end
			end
		end
		
		if State.Combat.AutoParry and root and char then
			for _, o in ipairs(workspace:GetDescendants()) do
				if o:IsA("BasePart") and (o.Name:lower():find("sword") or o.Name:lower():find("blade")) then
					if o.Parent ~= char and (o.Parent and o.Parent.Parent ~= char) then
						if (root.Position - o.Position).Magnitude < 15 then
							local tool = getTool() 
							if tool then 
								pcall(function() tool:Activate() end) 
							end
							if mouse2click then
								pcall(function() mouse2click() end)
							end
							break
						end
					end
				end
			end
		end
		
		if State.Combat.HitboxExpander then
			for _, data in pairs(EntityCache.players) do
				if data.RootPart then
					data.RootPart.Size = Vector3.new(State.Combat.HitboxSize, State.Combat.HitboxSize, State.Combat.HitboxSize)
					data.RootPart.Transparency = 0.7
				end
			end
		end
		
		if State.Combat.Backtrack then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart then
					if not BacktrackPositions[name] then 
						BacktrackPositions[name] = {} 
					end
					table.insert(BacktrackPositions[name], { Pos = data.RootPart.Position, Time = tick() })
					for i = #BacktrackPositions[name], 1, -1 do
						if tick() - BacktrackPositions[name][i].Time > State.Combat.BacktrackTime then
							table.remove(BacktrackPositions[name], i)
						end
					end
				end
			end
		end
		
		if State.Player.GodMode and hum then hum.Health = hum.MaxHealth end
		
		if State.Player.NoRagdoll and hum then
			hum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		end
		
		if State.Player.InfiniteStamina then
			pcall(function()
				for _, v in pairs(player.PlayerGui:GetDescendants()) do
					if v.Name:lower():find("stamina") and v:IsA("ValueBase") and v.Value < 100 then 
						v.Value = 100 
					end
				end
			end)
		end
		
		if State.Troll.AnnoyPlayer and State.Troll.AnnoyTarget ~= "" and root then
			local tp = Players:FindFirstChild(State.Troll.AnnoyTarget)
			if tp and tp.Character then
				local tr = tp.Character:FindFirstChild("HumanoidRootPart")
				if tr then 
					root.CFrame = tr.CFrame * CFrame.new(0, 0, -3) 
				end
			end
		end
		
		if State.Troll.OrbitPlayer and State.Troll.OrbitTarget ~= "" and root then
			local tp = Players:FindFirstChild(State.Troll.OrbitTarget)
			if tp and tp.Character then
				local tr = tp.Character:FindFirstChild("HumanoidRootPart")
				if tr then
					local ang = tick() * State.Troll.OrbitSpeed
					local off = Vector3.new(math.cos(ang) * State.Troll.OrbitRadius, 0, math.sin(ang) * State.Troll.OrbitRadius)
					root.CFrame = CFrame.new(tr.Position + off, tr.Position)
				end
			end
		end
		
		if State.Troll.Fling and root then
			root.Velocity = Vector3.new(math.random(-State.Troll.FlingPower, State.Troll.FlingPower), math.random(100, State.Troll.FlingPower), math.random(-State.Troll.FlingPower, State.Troll.FlingPower))
			root.RotVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
		end
		
		if State.Troll.Headless and char then
			local head = char:FindFirstChild("Head")
			if head then
				head.Transparency = 1
				local face = head:FindFirstChildOfClass("Decal") 
				if face then 
					face.Transparency = 1 
				end
			end
		end
		
		if State.Visuals.Freecam then
			local spd = State.Visuals.FreecamSpeed * 2
			local dir = Vector3.new()
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
			if dir.Magnitude > 0 then 
				FreecamPos = FreecamPos + dir.Unit * spd 
			end
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.new(FreecamPos) * CFrame.Angles(math.rad(FreecamAngles.X), math.rad(FreecamAngles.Y), 0)
		end
		
		if State.Visuals.XRay then
			for _, p in ipairs(workspace:GetDescendants()) do
				if p:IsA("BasePart") and not p:IsDescendantOf(char or {}) and p.Transparency < 1 then
					p.LocalTransparencyModifier = State.Visuals.XRayTransparency
				end
			end
		end
		
		if HUD.FOVCircle then
			HUD.FOVCircle.Visible = State.Combat.ShowFOVCircle
			HUD.FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			HUD.FOVCircle.Radius = State.Combat.AimFOV
			HUD.FOVCircle.Color = State.Settings.AccentColor
		end
		
		if HUD.CrosshairL then
			local vis = State.Visuals.Crosshair
			local cx, cy = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
			local sz, gp = State.Visuals.CrosshairSize, State.Visuals.CrosshairGap
			local clr = State.Settings.AccentColor
			HUD.CrosshairL.Visible = vis
			HUD.CrosshairL.From = Vector2.new(cx - sz - gp, cy)
			HUD.CrosshairL.To = Vector2.new(cx - gp, cy)
			HUD.CrosshairL.Color = clr
			HUD.CrosshairR.Visible = vis
			HUD.CrosshairR.From = Vector2.new(cx + gp, cy)
			HUD.CrosshairR.To = Vector2.new(cx + sz + gp, cy)
			HUD.CrosshairR.Color = clr
			HUD.CrosshairT.Visible = vis
			HUD.CrosshairT.From = Vector2.new(cx, cy - sz - gp)
			HUD.CrosshairT.To = Vector2.new(cx, cy - gp)
			HUD.CrosshairT.Color = clr
			HUD.CrosshairB.Visible = vis
			HUD.CrosshairB.From = Vector2.new(cx, cy + gp)
			HUD.CrosshairB.To = Vector2.new(cx, cy + sz + gp)
			HUD.CrosshairB.Color = clr
		end
		
		if HUD.Watermark then
			HUD.Watermark.Visible = State.Misc.Watermark
			HUD.Watermark.Text = "Vertex Hub"
			HUD.Watermark.Color = State.Settings.AccentColor
		end
		
		if HUD.FPS then
			HUD.FPS.Visible = State.Misc.FPSCounter
			HUD.FPS.Text = "FPS: " .. FPSData.fps
			HUD.FPS.Color = Color3.new(1, 1, 1)
		end
		
		if HUD.Ping then
			HUD.Ping.Visible = State.Misc.PingDisplay
			local p = 0
			pcall(function() p = Stats.Network.ServerStatsItem["Data Ping"]:GetValue() end)
			HUD.Ping.Text = "Ping: " .. math.floor(p) .. "ms"
			HUD.Ping.Color = Color3.new(1, 1, 1)
		end
		
		if HUD.PlrCount then
			HUD.PlrCount.Visible = State.Misc.PlayerCount
			HUD.PlrCount.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
			HUD.PlrCount.Color = Color3.new(1, 1, 1)
		end
		
		if HUD.Velocity then
			HUD.Velocity.Visible = State.Misc.VelocityDisplay
			local v = root and root.Velocity.Magnitude or 0
			HUD.Velocity.Text = "Speed: " .. math.floor(v) .. " studs/s"
			HUD.Velocity.Color = Color3.new(1, 1, 1)
		end
		
		if HUD.TargetInfo then
			HUD.TargetInfo.Visible = State.Misc.TargetInfo
			if CurrentTarget and CurrentTarget.Humanoid then
				local n = CurrentTarget.Player and CurrentTarget.Player.Name or (CurrentTarget.Model and CurrentTarget.Model.Name) or "?"
				HUD.TargetInfo.Text = "Target: " .. n .. " [" .. math.floor(CurrentTarget.Humanoid.Health) .. "HP]"
			else
				HUD.TargetInfo.Text = "Target: None"
			end
			HUD.TargetInfo.Color = Color3.new(1, 1, 1)
		end
		
		if HUD.Keybinds then
			HUD.Keybinds.Visible = State.Misc.KeybindsDisplay
			HUD.Keybinds.Position = Vector2.new(camera.ViewportSize.X - 150, 10)
			local k = {}
			if State.Movement.Fly then table.insert(k, "Fly") end
			if State.Movement.Noclip then table.insert(k, "Noclip") end
			if State.Combat.AimAssist then table.insert(k, "Aim") end
			if State.Combat.SilentAim then table.insert(k, "Silent") end
			if State.Combat.KillAura then table.insert(k, "Aura") end
			HUD.Keybinds.Text = "[Active]\n" .. (#k > 0 and table.concat(k, "\n") or "None")
			HUD.Keybinds.Color = Color3.new(1, 1, 1)
		end
		
		releaseAllDrawings()
		
		local anyESP = State.ESP.NameESP or State.ESP.BoxESP or State.ESP.HealthESP or State.ESP.DistanceESP or State.ESP.Tracers or State.ESP.SkeletonESP or State.ESP.OffscreenArrows or State.ESP.ItemESP or State.ESP.NPCESP
		
		if anyESP and DrawingEnabled then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					local dist = root and (root.Position - data.RootPart.Position).Magnitude or 0
					if dist <= State.ESP.MaxDistance then
						local pos, onScreen = camera:WorldToViewportPoint(data.RootPart.Position)
						local sc = math.clamp(1 / (pos.Z * 0.04), 0.2, 2)
						
						if onScreen then
							if State.ESP.NameESP then
								local t = getDrawing("text")
								if t then
									t.Text = name
									t.Position = Vector2.new(pos.X, pos.Y - 50 * sc)
									t.Color = Color3.new(1, 1, 1)
									t.Size = 14
								end
							end
							if State.ESP.HealthESP then
								local t = getDrawing("text")
								if t then
									t.Text = math.floor((data.Humanoid.Health / data.Humanoid.MaxHealth) * 100) .. "%"
									t.Position = Vector2.new(pos.X, pos.Y - 35 * sc)
									t.Color = Color3.fromRGB(100, 255, 100)
									t.Size = 12
								end
							end
							if State.ESP.DistanceESP then
								local t = getDrawing("text")
								if t then
									t.Text = math.floor(dist) .. "m"
									t.Position = Vector2.new(pos.X, pos.Y + 40 * sc)
									t.Color = Color3.fromRGB(200, 200, 200)
									t.Size = 12
								end
							end
							if State.ESP.BoxESP then
								local b = getDrawing("square")
								if b then
									local sz = Vector2.new(50 * sc, 70 * sc)
									b.Size = sz
									b.Position = Vector2.new(pos.X - sz.X / 2, pos.Y - sz.Y / 2)
									b.Color = Color3.fromRGB(255, 0, 0)
								end
							end
							if State.ESP.Tracers then
								local l = getDrawing("line")
								if l then
									l.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
									l.To = Vector2.new(pos.X, pos.Y)
									l.Color = Color3.fromRGB(255, 255, 0)
								end
							end
							
							if State.ESP.SkeletonESP and data.Character then
								local joints = data.Character:FindFirstChild("UpperTorso") and {
									{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"}, {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
									{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"}, {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"},
									{"LeftLowerLeg", "LeftFoot"}, {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
								} or {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}
								for _, j in ipairs(joints) do
									local p1, p2 = data.Character:FindFirstChild(j[1]), data.Character:FindFirstChild(j[2])
									if p1 and p2 then
										local s1, v1 = camera:WorldToViewportPoint(p1.Position)
										local s2, v2 = camera:WorldToViewportPoint(p2.Position)
										if v1 and v2 then
											local ln = getDrawing("line")
											if ln then
												ln.From = Vector2.new(s1.X, s1.Y)
												ln.To = Vector2.new(s2.X, s2.Y)
												ln.Color = Color3.new(1, 1, 1)
											end
										end
									end
								end
							end
						else
							if State.ESP.OffscreenArrows then
								local ctr = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
								local dir = (Vector2.new(pos.X, pos.Y) - ctr).Unit
								local ap = ctr + dir * 300
								ap = Vector2.new(math.clamp(ap.X, 50, camera.ViewportSize.X - 50), math.clamp(ap.Y, 50, camera.ViewportSize.Y - 50))
								local arr = getDrawing("triangle")
								if arr then
									local ang = math.atan2(dir.Y, dir.X)
									arr.PointA = ap + Vector2.new(math.cos(ang) * 15, math.sin(ang) * 15)
									arr.PointB = ap + Vector2.new(math.cos(ang + 2.5) * 15, math.sin(ang + 2.5) * 15)
									arr.PointC = ap + Vector2.new(math.cos(ang - 2.5) * 15, math.sin(ang - 2.5) * 15)
									arr.Color = Color3.fromRGB(255, 0, 0)
								end
							end
						end
					end
				end
			end
			
			if State.ESP.NPCESP then
				for _, data in ipairs(EntityCache.npcs) do
					if data.RootPart then
						local p, v = camera:WorldToViewportPoint(data.RootPart.Position)
						if v then
							local t = getDrawing("text")
							if t then
								t.Text = "[NPC] " .. data.Name
								t.Position = Vector2.new(p.X, p.Y - 30)
								t.Color = Color3.fromRGB(0, 200, 255)
								t.Size = 12
							end
						end
					end
				end
			end
			
			if State.ESP.ItemESP then
				for _, data in ipairs(EntityCache.items) do
					local p, v = camera:WorldToViewportPoint(data.Position)
					if v then
						local t = getDrawing("text")
						if t then
							t.Text = "[Item] " .. data.Name
							t.Position = Vector2.new(p.X, p.Y)
							t.Color = Color3.fromRGB(255, 200, 0)
							t.Size = 12
						end
					end
				end
			end
		end
		
		if State.Misc.AntiAFK then
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- INPUT HANDLING
	-- ---------------------------------------------------------------------------
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		
		if input.KeyCode == Enum.KeyCode.Space then
			if State.Movement.InfiniteJump then
				local hum = getHumanoid()
				if hum then
					hum:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
			if State.Movement.LongJump then
				local root = getRoot()
				if root then
					local bv = Instance.new("BodyVelocity")
					bv.Velocity = camera.CFrame.LookVector * State.Movement.LongJumpForce + Vector3.new(0, 50, 0)
					bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					bv.Parent = root
					Debris:AddItem(bv, 0.2)
				end
			end
		end
		
		if input.KeyCode == Enum.KeyCode.Q and State.Movement.Dash then
			local now = tick()
			if now - LastDashTime >= State.Movement.DashCooldown then
				LastDashTime = now
				local root = getRoot()
				if root then
					local bv = Instance.new("BodyVelocity")
					bv.Velocity = camera.CFrame.LookVector * State.Movement.DashForce
					bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					bv.Parent = root
					Debris:AddItem(bv, 0.15)
				end
			end
		end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if State.Movement.ClickTP then
				local root = getRoot()
				if root and mouse.Hit then
					root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
				end
			end
			if State.World.DeleteMode then
				local tgt = mouse.Target
				if tgt and not tgt:IsDescendantOf(player.Character or {}) then
					tgt:Destroy()
				end
			end
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if State.Visuals.Freecam and input.UserInputType == Enum.UserInputType.MouseMovement then
			local d = UIS:GetMouseDelta()
			FreecamAngles = Vector2.new(math.clamp(FreecamAngles.X - d.Y * 0.5, -80, 80), FreecamAngles.Y - d.X * 0.5)
		end
	end)
	
	player.Chatted:Connect(function(msg)
		if msg:sub(1, 8) == "/target " then
			local nm = msg:sub(9)
			State.Troll.AnnoyTarget = nm
			State.Troll.OrbitTarget = nm
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- UI CREATION (SIDEBAR FIRST - NO AUTO OPEN CATEGORY)
	-- ---------------------------------------------------------------------------
	local gui = Instance.new("ScreenGui")
	gui.Name = "VertexHubNeon"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	
	-- Main sidebar container - VISIBLE ON LAUNCH
	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 220, 0, 600)
	sidebar.Position = UDim2.new(0, 20, 0.5, 0)
	sidebar.AnchorPoint = Vector2.new(0, 0.5)
	sidebar.BackgroundColor3 = NeonColors.Background
	sidebar.BackgroundTransparency = 0.1
	sidebar.BorderSizePixel = 0
	sidebar.ClipsDescendants = true
	sidebar.Visible = true
	sidebar.Parent = gui
	
	-- Neon border
	local neonBorder = Instance.new("UIStroke")
	neonBorder.Color = NeonColors.BrightCyan
	neonBorder.Thickness = 3
	neonBorder.Transparency = 0.3
	neonBorder.Parent = sidebar
	
	-- Corner rounding
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = sidebar
	
	-- Header with title
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 70)
	header.BackgroundTransparency = 1
	header.Parent = sidebar
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 40)
	title.Position = UDim2.new(0, 10, 0, 15)
	title.BackgroundTransparency = 1
	title.Text = "VERTEX HUB"
	title.TextColor3 = NeonColors.Text
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 24
	title.Parent = header
	
	-- Category navigation
	local categories = {
		{Name = "COMBAT", Icon = "⚔️", Color = NeonColors.ElectricPurple},
		{Name = "MOVEMENT", Icon = "🏃", Color = NeonColors.BrightCyan},
		{Name = "ESP", Icon = "👁️", Color = NeonColors.HotPink},
		{Name = "VISUALS", Icon = "🎨", Color = NeonColors.LimeGreen},
		{Name = "WORLD", Icon = "🌍", Color = NeonColors.FieryOrange},
		{Name = "PLAYER", Icon = "👤", Color = NeonColors.NeonBlue},
		{Name = "TROLL", Icon = "😈", Color = NeonColors.VibrantYellow},
		{Name = "MISC", Icon = "⚙️", Color = NeonColors.TextSoft},
		{Name = "SETTINGS", Icon = "⚙️", Color = NeonColors.BrightCyan}
	}
local categoryButtons = {}
local categoryContents = {}
local currentCategory = nil



	
	
	-- Category buttons container
	local categoryContainer = Instance.new("ScrollingFrame")
	categoryContainer.Name = "CategoryContainer"
	categoryContainer.Size = UDim2.new(1, 0, 0, 380)
	categoryContainer.Position = UDim2.new(0, 0, 0, 70)
	categoryContainer.BackgroundTransparency = 1
	categoryContainer.ScrollBarThickness = 6
	categoryContainer.ScrollBarImageColor3 = NeonColors.BrightCyan
	categoryContainer.CanvasSize = UDim2.new(0, 0, 0, #categories * 50 + 20)
	categoryContainer.Parent = sidebar
	
	local categoryLayout = Instance.new("UIListLayout")
	categoryLayout.Padding = UDim.new(0, 5)
	categoryLayout.SortOrder = Enum.SortOrder.LayoutOrder
	categoryLayout.Parent = categoryContainer
	
	local categoryPadding = Instance.new("UIPadding")
	categoryPadding.PaddingTop = UDim.new(0, 10)
	categoryPadding.PaddingLeft = UDim.new(0, 10)
	categoryPadding.PaddingRight = UDim.new(0, 10)
	categoryPadding.Parent = categoryContainer
	
	-- Create category buttons
	for i, category in ipairs(categories) do
		local btn = Instance.new("TextButton")
		btn.Name = "CategoryBtn_" .. category.Name
		btn.Size = UDim2.new(1, -20, 0, 45)
		btn.BackgroundColor3 = NeonColors.Glass
		btn.BackgroundTransparency = 0.4
		btn.BorderSizePixel = 0
		btn.AutoButtonColor = false
		btn.Text = ""
		btn.LayoutOrder = i
		btn.Parent = categoryContainer
		
		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 10)
		btnCorner.Parent = btn
		
		local btnGlow = Instance.new("UIStroke")
		btnGlow.Color = category.Color
		btnGlow.Thickness = 2
		btnGlow.Transparency = 0.7
		btnGlow.Parent = btn
		
		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0, 30, 0, 30)
		icon.Position = UDim2.new(0, 10, 0.5, 0)
		icon.AnchorPoint = Vector2.new(0, 0.5)
		icon.BackgroundTransparency = 1
		icon.Text = category.Icon
		icon.TextColor3 = category.Color
		icon.Font = Enum.Font.GothamBold
		icon.TextSize = 18
		icon.Parent = btn
		
		local label = Instance.new("TextLabel")
		label.Name = "Label"
		label.Size = UDim2.new(1, -50, 1, 0)
		label.Position = UDim2.new(0, 45, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = category.Name
		label.TextColor3 = NeonColors.TextSoft
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Font = Enum.Font.GothamBold
		label.TextSize = 12
		label.Parent = btn
		
		local indicator = Instance.new("Frame")
		indicator.Name = "Indicator"
		indicator.Size = UDim2.new(0, 4, 0.7, 0)
		indicator.Position = UDim2.new(1, -4, 0.15, 0)
		indicator.BackgroundColor3 = category.Color
		indicator.BackgroundTransparency = 0.8
		indicator.BorderSizePixel = 0
		indicator.Visible = false
		indicator.Parent = btn
		
		categoryButtons[category.Name] = {
			Button = btn,
			Icon = icon,
			Label = label,
			Indicator = indicator,
			Color = category.Color
		}
		
		btn.MouseEnter:Connect(function()
			if currentCategory ~= category.Name then
				tween(btn, {BackgroundTransparency = 0.2}, 0.2)
				tween(label, {TextColor3 = NeonColors.Text}, 0.2)
			end
		end)
		
		btn.MouseLeave:Connect(function()
			if currentCategory ~= category.Name then
				tween(btn, {BackgroundTransparency = 0.4}, 0.2)
				tween(label, {TextColor3 = NeonColors.TextSoft}, 0.2)
			end
		end)
		
		btn.MouseButton1Click:Connect(function()
			switchCategory(category.Name)
		end)
	end
	
	-- Content area (right side) - HIDDEN ON LAUNCH
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(0, 700, 0, 600)
	contentArea.Position = UDim2.new(0, 240, 0.5, 0)
	contentArea.AnchorPoint = Vector2.new(0, 0.5)
	contentArea.BackgroundColor3 = NeonColors.Background
	contentArea.BackgroundTransparency = 0.05
	contentArea.BorderSizePixel = 0
	contentArea.Visible = false
	contentArea.Parent = gui
	
	local contentCorner = Instance.new("UICorner")
	contentCorner.CornerRadius = UDim.new(0, 16)
	contentCorner.Parent = contentArea
	
	local contentGlow = Instance.new("UIStroke")
	contentGlow.Color = NeonColors.BrightCyan
	contentGlow.Thickness = 3
	contentGlow.Transparency = 0.3
	contentGlow.Parent = contentArea
	
	-- Content header
	local contentHeader = Instance.new("Frame")
	contentHeader.Size = UDim2.new(1, 0, 0, 60)
	contentHeader.BackgroundTransparency = 1
	contentHeader.Parent = contentArea
	
	local contentTitle = Instance.new("TextLabel")
	contentTitle.Size = UDim2.new(1, -20, 1, 0)
	contentTitle.Position = UDim2.new(0, 20, 0, 0)
	contentTitle.BackgroundTransparency = 1
	contentTitle.Text = "SELECT CATEGORY"
	contentTitle.TextColor3 = NeonColors.Text
	contentTitle.TextXAlignment = Enum.TextXAlignment.Left
	contentTitle.Font = Enum.Font.GothamBlack
	contentTitle.TextSize = 22
	contentTitle.Parent = contentHeader



	-- CATEGORY SWITCH FUNCTION
function switchCategory(categoryName)
	if currentCategory == categoryName then return end

	for name, content in pairs(categoryContents) do
		if content then
			content.Visible = false
		end
	end

	for name, data in pairs(categoryButtons) do
		if data and data.Button then
			tween(data.Button, {BackgroundTransparency = 0.4}, 0.2)
			if data.Label then
				tween(data.Label, {TextColor3 = NeonColors.TextSoft}, 0.2)
			end
			if data.Indicator then
				data.Indicator.Visible = false
			end
		end
	end

	if categoryContents[categoryName] then
		categoryContents[categoryName].Visible = true
		contentTitle.Text = categoryName
		currentCategory = categoryName
	end
end

	
	-- Close content button
	local closeContentBtn = Instance.new("TextButton")
	closeContentBtn.Size = UDim2.new(0, 40, 0, 40)
	closeContentBtn.Position = UDim2.new(1, -50, 0.5, 0)
	closeContentBtn.AnchorPoint = Vector2.new(0, 0.5)
	closeContentBtn.BackgroundColor3 = NeonColors.Glass
	closeContentBtn.BackgroundTransparency = 0.3
	closeContentBtn.BorderSizePixel = 0
	closeContentBtn.AutoButtonColor = false
	closeContentBtn.Text = "✕"
	closeContentBtn.TextColor3 = NeonColors.Text
	closeContentBtn.Font = Enum.Font.GothamBold
	closeContentBtn.TextSize = 20
	closeContentBtn.Parent = contentHeader
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeContentBtn
	
	closeContentBtn.MouseButton1Click:Connect(function()
		contentArea.Visible = false
		currentCategory = nil
		
		-- Reset all buttons
		for name, data in pairs(categoryButtons) do
			if data and data.Button then
				tween(data.Button, {BackgroundTransparency = 0.4}, 0.2)
				if data.Label then
					tween(data.Label, {TextColor3 = NeonColors.TextSoft}, 0.2)
				end
				if data.Indicator then
					data.Indicator.Visible = false
				end
			end
		end
	end)
	
	-- Content scroll frame
	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Name = "ContentScroll"
	contentScroll.Size = UDim2.new(1, -20, 1, -80)
	contentScroll.Position = UDim2.new(0, 10, 0, 70)
	contentScroll.BackgroundTransparency = 1
	contentScroll.ScrollBarThickness = 6
	contentScroll.ScrollBarImageColor3 = NeonColors.BrightCyan
	contentScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	contentScroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	contentScroll.Parent = contentArea
	
	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 10)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = contentScroll
	
	local contentPadding = Instance.new("UIPadding")
	contentPadding.PaddingTop = UDim.new(0, 10)
	contentPadding.PaddingLeft = UDim.new(0, 10)
	contentPadding.PaddingRight = UDim.new(0, 10)
	contentPadding.Parent = contentScroll
	
	-- Function to create category content
	local function createCategoryContent(categoryName)
		local container = Instance.new("Frame")
		container.Name = "Content_" .. categoryName
		container.Size = UDim2.new(1, 0, 0, 0)
		container.BackgroundTransparency = 1
		container.AutomaticSize = Enum.AutomaticSize.Y
		container.Visible = false
		container.Parent = contentScroll
		
		categoryContents[categoryName] = container
		return container
	end
	
	-- Create all category contents
	local combatContent = createCategoryContent("COMBAT")
	local movementContent = createCategoryContent("MOVEMENT")
	local espContent = createCategoryContent("ESP")
	local visualsContent = createCategoryContent("VISUALS")
	local worldContent = createCategoryContent("WORLD")
	local playerContent = createCategoryContent("PLAYER")
	local trollContent = createCategoryContent("TROLL")
	local miscContent = createCategoryContent("MISC")
	local settingsContent = createCategoryContent("SETTINGS")
	
	-- Function to switch category

	
	-- Save/Load buttons
	local saveLoadContainer = Instance.new("Frame")
	saveLoadContainer.Size = UDim2.new(1, -20, 0, 40)
	saveLoadContainer.Position = UDim2.new(0, 10, 1, -110)
	saveLoadContainer.BackgroundTransparency = 1
	saveLoadContainer.Parent = sidebar
	
	local saveBtn = Instance.new("TextButton")
	saveBtn.Name = "SaveButton"
	saveBtn.Size = UDim2.new(0.48, 0, 1, 0)
	saveBtn.BackgroundColor3 = NeonColors.LimeGreen
	saveBtn.BackgroundTransparency = 0.3
	saveBtn.BorderSizePixel = 0
	saveBtn.AutoButtonColor = false
	saveBtn.Text = "💾 SAVE"
	saveBtn.TextColor3 = NeonColors.Text
	saveBtn.Font = Enum.Font.GothamBold
	saveBtn.TextSize = 11
	saveBtn.Parent = saveLoadContainer
	
	local saveCorner = Instance.new("UICorner")
	saveCorner.CornerRadius = UDim.new(0, 8)
	saveCorner.Parent = saveBtn
	
	saveBtn.MouseButton1Click:Connect(function()
		saveStateToConfig()
		tween(saveBtn, {BackgroundTransparency = 0.1}, 0.1)
		task.wait(0.2)
		tween(saveBtn, {BackgroundTransparency = 0.3}, 0.3)
	end)
	
	local loadBtn = Instance.new("TextButton")
	loadBtn.Name = "LoadButton"
	loadBtn.Size = UDim2.new(0.48, 0, 1, 0)
	loadBtn.Position = UDim2.new(1, -0.48, 0, 0)
	loadBtn.BackgroundColor3 = NeonColors.NeonBlue
	loadBtn.BackgroundTransparency = 0.3
	loadBtn.BorderSizePixel = 0
	loadBtn.AutoButtonColor = false
	loadBtn.Text = "📂 LOAD"
	loadBtn.TextColor3 = NeonColors.Text
	loadBtn.Font = Enum.Font.GothamBold
	loadBtn.TextSize = 11
	loadBtn.Parent = saveLoadContainer
	
	local loadCorner = Instance.new("UICorner")
	loadCorner.CornerRadius = UDim.new(0, 8)
	loadCorner.Parent = loadBtn
	
	loadBtn.MouseButton1Click:Connect(function()
		loadStateFromConfig()
		tween(loadBtn, {BackgroundTransparency = 0.1}, 0.1)
		task.wait(0.2)
		tween(loadBtn, {BackgroundTransparency = 0.3}, 0.3)
	end)
	
	-- ---------------------------------------------------------------------------
	-- POPULATE CATEGORIES
	-- ---------------------------------------------------------------------------
	
	-- COMBAT CATEGORY
	do
		local content = combatContent
		Components.createSection(content, "AIM ASSIST")
		Components.createToggle(content, "Aim Assist", function(v)
			State.Combat.AimAssist = v
			saveStateToConfig()
		end, State.Combat.AimAssist)
		
		Components.createSlider(content, "Smoothness", 1, 100, State.Combat.AimSmoothness * 200, function(v)
			State.Combat.AimSmoothness = v / 200
			saveStateToConfig()
		end)
		
		Components.createSlider(content, "FOV", 50, 600, State.Combat.AimFOV, function(v)
			State.Combat.AimFOV = v
			saveStateToConfig()
		end)
		
		Components.createToggle(content, "Show FOV Circle", function(v)
			State.Combat.ShowFOVCircle = v
			saveStateToConfig()
		end, State.Combat.ShowFOVCircle)
		
		Components.createDivider(content)
		Components.createSection(content, "SILENT AIM")
		Components.createToggle(content, "Silent Aim", function(v)
			State.Combat.SilentAim = v
			saveStateToConfig()
		end, State.Combat.SilentAim)
		
		Components.createSlider(content, "Hit Chance", 0, 100, State.Combat.SilentAimHitChance, function(v)
			State.Combat.SilentAimHitChance = v
			saveStateToConfig()
		end)
		
		Components.createDivider(content)
		Components.createSection(content, "KILL AURA")
		Components.createToggle(content, "Kill Aura", function(v)
			State.Combat.KillAura = v
			saveStateToConfig()
		end, State.Combat.KillAura)
		
		Components.createSlider(content, "Range", 5, 50, State.Combat.KillAuraRange, function(v)
			State.Combat.KillAuraRange = v
			saveStateToConfig()
		end)
		
		Components.createSlider(content, "CPS", 1, 20, State.Combat.KillAuraCPS, function(v)
			State.Combat.KillAuraCPS = v
			saveStateToConfig()
		end)
		
		Components.createToggle(content, "Target Players", function(v)
			State.Combat.KillAuraPlayers = v
			saveStateToConfig()
		end, State.Combat.KillAuraPlayers)
		
		Components.createToggle(content, "Target NPCs", function(v)
			State.Combat.KillAuraNPCs = v
			saveStateToConfig()
		end, State.Combat.KillAuraNPCs)
		
		Components.createDivider(content)
		Components.createSection(content, "AUTO FEATURES")
		Components.createToggle(content, "Triggerbot", function(v)
			State.Combat.Triggerbot = v
			saveStateToConfig()
		end, State.Combat.Triggerbot)
		
		Components.createToggle(content, "Auto Parry", function(v)
			State.Combat.AutoParry = v
			saveStateToConfig()
		end, State.Combat.AutoParry)
		
		Components.createDivider(content)
		Components.createSection(content, "EXPLOITS")
		Components.createToggle(content, "Hitbox Expander", function(v)
			State.Combat.HitboxExpander = v
			saveStateToConfig()
		end, State.Combat.HitboxExpander)
		
		Components.createSlider(content, "Hitbox Size", 1, 20, State.Combat.HitboxSize, function(v)
			State.Combat.HitboxSize = v
			saveStateToConfig()
		end)
	end
	
	-- MOVEMENT CATEGORY
	do
		local content = movementContent
		Components.createSection(content, "FLIGHT")
		Components.createToggle(content, "Fly", function(v)
			State.Movement.Fly = v
			saveStateToConfig()
		end, State.Movement.Fly)
		
		Components.createSlider(content, "Fly Speed", 10, 300, State.Movement.FlySpeed, function(v)
			State.Movement.FlySpeed = v
			saveStateToConfig()
		end)
		
		Components.createToggle(content, "Noclip", function(v)
			State.Movement.Noclip = v
			saveStateToConfig()
		end, State.Movement.Noclip)
		
		Components.createDivider(content)
		Components.createSection(content, "SPEED & JUMP")
		Components.createToggle(content, "Speed", function(v)
			State.Movement.Speed = v
			saveStateToConfig()
		end, State.Movement.Speed)
		
		Components.createSlider(content, "Speed Value", 16, 500, State.Movement.SpeedValue, function(v)
			State.Movement.SpeedValue = v
			saveStateToConfig()
		end)
		
		Components.createToggle(content, "Infinite Jump", function(v)
			State.Movement.InfiniteJump = v
			saveStateToConfig()
		end, State.Movement.InfiniteJump)
		
		Components.createDivider(content)
		Components.createSection(content, "TELEPORT")
		Components.createToggle(content, "Click TP", function(v)
			State.Movement.ClickTP = v
			saveStateToConfig()
		end, State.Movement.ClickTP)
		
		Components.createToggle(content, "Anti Void", function(v)
			State.Movement.AntiVoid = v
			saveStateToConfig()
		end, State.Movement.AntiVoid)
	end
	
	-- ESP CATEGORY (RESTORED FROM ORIGINAL)
	do
		local content = espContent
		Components.createSection(content, "PLAYER ESP")
		Components.createToggle(content, "Name ESP", function(v)
			State.ESP.NameESP = v
			saveStateToConfig()
		end, State.ESP.NameESP)
		
		Components.createToggle(content, "Box ESP", function(v)
			State.ESP.BoxESP = v
			saveStateToConfig()
		end, State.ESP.BoxESP)
		
		Components.createToggle(content, "Health ESP", function(v)
			State.ESP.HealthESP = v
			saveStateToConfig()
		end, State.ESP.HealthESP)
		
		Components.createToggle(content, "Tracers", function(v)
			State.ESP.Tracers = v
			saveStateToConfig()
		end, State.ESP.Tracers)
		
		Components.createToggle(content, "Skeleton ESP", function(v)
			State.ESP.SkeletonESP = v
			saveStateToConfig()
		end, State.ESP.SkeletonESP)
		
		Components.createToggle(content, "Offscreen Arrows", function(v)
			State.ESP.OffscreenArrows = v
			saveStateToConfig()
		end, State.ESP.OffscreenArrows)
		
		Components.createDivider(content)
		Components.createSection(content, "HIGHLIGHTS")
		Components.createToggle(content, "Chams", function(v)
			State.ESP.Chams = v
			updateChams()
			saveStateToConfig()
		end, State.ESP.Chams)
		
		Components.createToggle(content, "Team Check", function(v)
			State.ESP.TeamCheck = v
			saveStateToConfig()
		end, State.ESP.TeamCheck)
		
		Components.createDivider(content)
		Components.createSection(content, "OTHER ENTITIES")
		Components.createToggle(content, "Item ESP", function(v)
			State.ESP.ItemESP = v
			saveStateToConfig()
		end, State.ESP.ItemESP)
		
		Components.createToggle(content, "NPC ESP", function(v)
			State.ESP.NPCESP = v
			saveStateToConfig()
		end, State.ESP.NPCESP)
		
		Components.createDivider(content)
		Components.createSection(content, "SETTINGS")
		Components.createSlider(content, "Max Distance", 100, 2000, State.ESP.MaxDistance, function(v)
			State.ESP.MaxDistance = v
			saveStateToConfig()
		end)
	end
	
	-- VISUALS CATEGORY
	do
		local content = visualsContent
		Components.createSection(content, "LIGHTING")
		Components.createToggle(content, "Fullbright", function(v)
			State.Visuals.Fullbright = v
			if v then
				Lighting.Ambient = Color3.new(1, 1, 1)
				Lighting.Brightness = 2
				Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
			else
				Lighting.Ambient = OriginalLighting.Ambient
				Lighting.Brightness = OriginalLighting.Brightness
				Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient
			end
			saveStateToConfig()
		end, State.Visuals.Fullbright)
		
		Components.createDivider(content)
		Components.createSection(content, "CROSSHAIR")
		Components.createToggle(content, "Custom Crosshair", function(v)
			State.Visuals.Crosshair = v
			saveStateToConfig()
		end, State.Visuals.Crosshair)
		
		Components.createSlider(content, "Crosshair Size", 5, 50, State.Visuals.CrosshairSize, function(v)
			State.Visuals.CrosshairSize = v
			saveStateToConfig()
		end)
		
		Components.createDivider(content)
		Components.createSection(content, "CAMERA")
		Components.createSlider(content, "Camera FOV", 30, 120, State.Visuals.CameraFOV, function(v)
			State.Visuals.CameraFOV = v
			camera.FieldOfView = v
			saveStateToConfig()
		end)
		
		Components.createToggle(content, "Freecam", function(v)
			State.Visuals.Freecam = v
			if v then
				camera.CameraType = Enum.CameraType.Scriptable
			else
				camera.CameraType = Enum.CameraType.Custom
			end
			saveStateToConfig()
		end, State.Visuals.Freecam)
	end
	
	-- WORLD CATEGORY
	do
		local content = worldContent
		Components.createSection(content, "ENVIRONMENT")
		Components.createSlider(content, "Time of Day", 0, 24, State.World.TimeOfDay, function(v)
			State.World.TimeOfDay = v
			Lighting.ClockTime = v
			saveStateToConfig()
		end)
		
		Components.createSlider(content, "Gravity", 0, 500, State.World.Gravity, function(v)
			State.World.Gravity = v
			workspace.Gravity = v
			saveStateToConfig()
		end)
		
		Components.createDivider(content)
		Components.createSection(content, "TOOLS")
		Components.createToggle(content, "Delete Mode (Click)", function(v)
			State.World.DeleteMode = v
			saveStateToConfig()
		end, State.World.DeleteMode)
	end
	
	-- PLAYER CATEGORY
	do
		local content = playerContent
		Components.createSection(content, "CHARACTER")
		Components.createToggle(content, "God Mode", function(v)
			State.Player.GodMode = v
			saveStateToConfig()
		end, State.Player.GodMode)
		
		Components.createToggle(content, "No Ragdoll", function(v)
			State.Player.NoRagdoll = v
			saveStateToConfig()
		end, State.Player.NoRagdoll)
		
		Components.createDivider(content)
		Components.createSection(content, "INVISIBILITY")
		Components.createToggle(content, "Invisibility", function(v)
			State.Player.Invisibility = v
			if v then
				InvisSystem:Enable()
			else
				InvisSystem:Disable()
			end
			saveStateToConfig()
		end, State.Player.Invisibility)
	end
	
	-- TROLL CATEGORY
	do
		local content = trollContent
		Components.createSection(content, "FOLLOW / ORBIT")
		Components.createToggle(content, "Annoy Player", function(v)
			State.Troll.AnnoyPlayer = v
			saveStateToConfig()
		end, State.Troll.AnnoyPlayer)
		
		Components.createToggle(content, "Orbit Player", function(v)
			State.Troll.OrbitPlayer = v
			saveStateToConfig()
		end, State.Troll.OrbitPlayer)
		
		Components.createDivider(content)
		Components.createSection(content, "CHARACTER TROLL")
		Components.createToggle(content, "Fling", function(v)
			State.Troll.Fling = v
			saveStateToConfig()
		end, State.Troll.Fling)
		
		Components.createSlider(content, "Fling Power", 100, 1000, State.Troll.FlingPower, function(v)
			State.Troll.FlingPower = v
			saveStateToConfig()
		end)
	end
	
	-- MISC CATEGORY
	do
		local content = miscContent
		Components.createSection(content, "HUD ELEMENTS")
		Components.createToggle(content, "Watermark", function(v)
			State.Misc.Watermark = v
			saveStateToConfig()
		end, State.Misc.Watermark)
		
		Components.createToggle(content, "FPS Counter", function(v)
			State.Misc.FPSCounter = v
			saveStateToConfig()
		end, State.Misc.FPSCounter)
		
		Components.createToggle(content, "Ping Display", function(v)
			State.Misc.PingDisplay = v
			saveStateToConfig()
		end, State.Misc.PingDisplay)
		
		Components.createToggle(content, "Player Count", function(v)
			State.Misc.PlayerCount = v
			saveStateToConfig()
		end, State.Misc.PlayerCount)
		
		Components.createToggle(content, "Velocity Display", function(v)
			State.Misc.VelocityDisplay = v
			saveStateToConfig()
		end, State.Misc.VelocityDisplay)
		
		Components.createToggle(content, "Target Info", function(v)
			State.Misc.TargetInfo = v
			saveStateToConfig()
		end, State.Misc.TargetInfo)
		
		Components.createToggle(content, "Keybinds Display", function(v)
			State.Misc.KeybindsDisplay = v
			saveStateToConfig()
		end, State.Misc.KeybindsDisplay)
		
		Components.createDivider(content)
		Components.createSection(content, "UTILITY")
		Components.createToggle(content, "Anti AFK", function(v)
			State.Misc.AntiAFK = v
			saveStateToConfig()
		end, State.Misc.AntiAFK)
		
		Components.createToggle(content, "Chat Spam", function(v)
			State.Misc.ChatSpam = v
			saveStateToConfig()
		end, State.Misc.ChatSpam)
	end
	
	-- SETTINGS CATEGORY (NEW SEPARATE PAGE)
	do
		local content = settingsContent
		Components.createSection(content, "CONFIGURATION")
		
		Components.createLabel(content, "Menu Toggle Key: " .. tostring(State.Settings.MenuKey))
		
		local keybindComponent = Components.createKeybind(content, "Change Menu Key", State.Settings.MenuKey, function(newKey)
			if newKey then
				State.Settings.MenuKey = newKey
				saveStateToConfig()
			end
		end, saveStateToConfig)
		
		Components.createDivider(content)
		Components.createSection(content, "APPEARANCE")
		
		local colorPicker = Components.createColorPicker(content, "Accent Color", State.Settings.AccentColor, function(newColor)
			State.Settings.AccentColor = newColor
			saveStateToConfig()
		end, saveStateToConfig)
		
		Components.createDivider(content)
		Components.createSection(content, "RESET")
		
		local resetBtn = Components.createButton(content, "Reset All Settings", function()
			State = {
				ESP = {
					NameESP = false, BoxESP = false, HealthESP = false, DistanceESP = false,
					Tracers = false, SkeletonESP = false, OffscreenArrows = false, Chams = false,
					ItemESP = false, NPCESP = false, MaxDistance = 1000, TeamCheck = false
				},
				Combat = {
					AimAssist = false, AimSmoothness = 0.15, AimFOV = 150, AimPrediction = false,
					PredictionAmount = 0.1, ShowFOVCircle = false,
					SilentAim = false, SilentAimHitChance = 100,
					KillAura = false, KillAuraRange = 15, KillAuraCPS = 10, KillAuraLegit = false,
					KillAuraPlayers = true, KillAuraNPCs = false, KillAuraWallCheck = true,
					Reach = false, ReachDistance = 18, ReachLegit = false,
					Triggerbot = false, TriggerbotDelay = 0.1,
					AutoParry = false, HitboxExpander = false, HitboxSize = 5,
					Backtrack = false, BacktrackTime = 0.2,
					TargetStrafe = false, StrafeSpeed = 5, StrafeRadius = 10
				},
				Movement = {
					Fly = false, FlySpeed = 50, FlyLegit = false, Noclip = false,
					Speed = false, SpeedValue = 16, SpeedLegit = false,
					JumpPower = false, JumpValue = 50, InfiniteJump = false,
					BunnyHop = false, LongJump = false, LongJumpForce = 100,
					SpeedGlide = false, GlideSpeed = 10,
					Dash = false, DashForce = 100, DashCooldown = 1,
					ClickTP = false, AntiVoid = false, VoidHeight = -100, Anchor = false,
					SpinBot = false, SpinSpeed = 20, FakeLag = false, LagIntensity = 5, AirControl = false
				},
				Visuals = {
					Fullbright = false, NoFog = false, NoShadows = false,
					Crosshair = false, CrosshairSize = 10, CrosshairGap = 5,
					CameraFOV = 70, ThirdPerson = false, Freecam = false, FreecamSpeed = 1,
					XRay = false, XRayTransparency = 0.5
				},
				World = { TimeOfDay = 14, Gravity = 196.2, DeleteMode = false, RemoveGrass = false },
				Player = {
					GodMode = false, NoRagdoll = false, AutoRespawn = false, CharScale = 1,
					Invisibility = false, InvisMode = "Safe", InvisOffset = 100,
					NoRecoil = false, NoSpread = false, InfiniteStamina = false
				},
				Troll = {
					AnnoyPlayer = false, AnnoyTarget = "", OrbitPlayer = false, OrbitTarget = "",
					OrbitRadius = 10, OrbitSpeed = 2, Fling = false, FlingPower = 500, Headless = false
				},
				Misc = {
					AntiAFK = false, ChatSpam = false, SpamMsg = "Vertex Hub!", SpamDelay = 2,
					Watermark = false, FPSCounter = false, PingDisplay = false, PlayerCount = false,
					VelocityDisplay = false, TargetInfo = false, KeybindsDisplay = false
				},
				Settings = { MenuKey = Enum.KeyCode.M, AccentColor = Color3.fromRGB(60, 120, 255) }
			}
			
			-- Update all UI toggles
			for _, category in ipairs(categories) do
				local container = categoryContents[category.Name]
				if container then
					for _, child in ipairs(container:GetChildren()) do
						if child.Name:find("Toggle_") then
							local toggleFunc = child:FindFirstChild("ToggleFunc")
							if toggleFunc then
								toggleFunc:Fire(false)
							end
						end
					end
				end
			end
			
			saveStateToConfig()
		end, NeonColors.FieryOrange)
	end
	
	-- ---------------------------------------------------------------------------
	-- MENU TOGGLE SYSTEM
	-- ---------------------------------------------------------------------------
	local menuVisible = true
	
	local function toggleMenu()
		menuVisible = not menuVisible
		
		if menuVisible then
			-- Show menu
			sidebar.Visible = true
			tween(sidebar, {Position = UDim2.new(0, 20, 0.5, 0)}, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
			
			-- Unlock mouse
			UIS.MouseBehavior = Enum.MouseBehavior.Default
			UIS.MouseIconEnabled = true
		else
			-- Hide menu
			tween(sidebar, {Position = UDim2.new(0, -240, 0.5, 0)}, 0.3)
			task.delay(0.3, function()
				sidebar.Visible = false
				contentArea.Visible = false
				currentCategory = nil
			end)
			
			-- Restore mouse
			UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default
			UIS.MouseIconEnabled = PrevMouseState.icon ~= false
		end
	end
	
	-- Listen for menu key from config
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		
		if input.KeyCode == State.Settings.MenuKey then
			toggleMenu()
		end
	end)
	
	-- Store initial mouse state
	PrevMouseState.behavior = UIS.MouseBehavior
	PrevMouseState.icon = UIS.MouseIconEnabled
	
	-- Dragging for sidebar
	local draggingSidebar = false
	local dragStartSidebar, startPosSidebar
	
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSidebar = true
			dragStartSidebar = input.Position
			startPosSidebar = sidebar.Position
		end
	end)
	
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSidebar = false
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if draggingSidebar and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStartSidebar
			sidebar.Position = UDim2.new(
				startPosSidebar.X.Scale,
				startPosSidebar.X.Offset + delta.X,
				startPosSidebar.Y.Scale,
				startPosSidebar.Y.Offset + delta.Y
			)
		end
	end)
	
	-- Dragging for content area
	local draggingContent = false
	local dragStartContent, startPosContent
	
	contentHeader.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingContent = true
			dragStartContent = input.Position
			startPosContent = contentArea.Position
		end
	end)
	
	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingContent = false
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if draggingContent and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStartContent
			contentArea.Position = UDim2.new(
				startPosContent.X.Scale,
				startPosContent.X.Offset + delta.X,
				startPosContent.Y.Scale,
				startPosContent.Y.Offset + delta.Y
			)
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- CHARACTER EVENTS
	-- ---------------------------------------------------------------------------
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then
			if State.Movement.Speed then h.WalkSpeed = State.Movement.SpeedValue end
			if State.Movement.JumpPower then h.JumpPower = State.Movement.JumpValue end
		end
		if State.ESP.Chams then updateChams() end
		if State.Player.Invisibility then
			task.wait(0.2)
			InvisSystem:Enable()
		end
	end)
	
	Players.PlayerAdded:Connect(function()
		task.wait(1)
		if State.ESP.Chams then updateChams() end
	end)
	
	Players.PlayerRemoving:Connect(function(p)
		EntityCache.players[p.Name] = nil
		BacktrackPositions[p.Name] = nil
	end)
	
	-- ---------------------------------------------------------------------------
	-- INITIALIZATION
	-- ---------------------------------------------------------------------------
	if DrawingEnabled then
		print("[Vertex Hub Neon] Loaded successfully! Press " .. tostring(State.Settings.MenuKey) .. " to toggle menu.")
	else
		print("[Vertex Hub Neon] Loaded successfully! WARNING: Drawing API not available. Press " .. tostring(State.Settings.MenuKey) .. " to toggle menu.")
	end
	
	-- Initialize Chams if enabled
	if State.ESP.Chams then
		task.wait(1)
		updateChams()
	end
	
	-- Return API functions
	return {
		ToggleMenu = toggleMenu,
		GetState = function() return State end,
		SaveConfig = saveStateToConfig,
		LoadConfig = loadConfig,

		GUI = gui,
		SwitchCategory = switchCategory
	}
end
