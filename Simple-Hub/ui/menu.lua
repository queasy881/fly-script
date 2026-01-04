-- ████████████████████████████████████████████████████████████████
-- █░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█░░░░░░░░░░░░░░░░█
-- █░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀▄▀░░█
-- █░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█░░░░░░▄▀░░░░░░█░░▄▀░░░░░░░░▄▀░░█
-- █░░▄▀░░██░░▄▀░░█░░▄▀░░█████████████░░▄▀░░█████░░▄▀░░████░░▄▀░░█
-- █░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░░░█████░░▄▀░░█████░░▄▀░░░░░░░░▄▀░░█
-- █░░▄▀░░██░░▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█████░░▄▀░░█████░░▄▀▄▀▄▀▄▀▄▀▄▀░░█
-- █░░▄▀░░██░░▄▀░░█░░▄▀░░░░░░░░░░█████░░▄▀░░█████░░▄▀░░░░░░▄▀░░░░█
-- █░░▄▀░░██░░▄▀░░█░░▄▀░░█████████████░░▄▀░░█████░░▄▀░░██░░▄▀░░██
-- █░░▄▀░░░░░░▄▀░░█░░▄▀░░░░░░░░░░█████░░▄▀░░█████░░▄▀░░██░░▄▀░░██
-- █░░▄▀▄▀▄▀▄▀▄▀░░█░░▄▀▄▀▄▀▄▀▄▀░░█████░░▄▀░░█████░░▄▀░░██░░▄▀░░██
-- █░░░░░░░░░░░░░░█░░░░░░░░░░░░░░█████░░░░░░█████░░░░░░██░░░░░░██
-- ████████████████████████████████████████████████████████████████
-- VERTEX HUB ULTIMATE - ALL 100+ FEATURES
-- ████████████████████████████████████████████████████████████████

return function(deps)
	local Tabs = deps.Tabs
	local Components = deps.Components
	local Animations = deps.Animations
	
	-- ══════════════════════════════════════════════════════════════
	-- SERVICES
	-- ══════════════════════════════════════════════════════════════
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
	local SoundService = game:GetService("SoundService")
	local VirtualInputManager = game:GetService("VirtualInputManager")
	
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local mouse = player:GetMouse()
	
	-- ══════════════════════════════════════════════════════════════
	-- UTILITY FUNCTIONS
	-- ══════════════════════════════════════════════════════════════
	local function getCharacter() return player.Character end
	local function getRoot() local c = getCharacter() return c and c:FindFirstChild("HumanoidRootPart") end
	local function getHumanoid() local c = getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end
	local function getHead() local c = getCharacter() return c and c:FindFirstChild("Head") end
	local function getTool() local c = getCharacter() return c and c:FindFirstChildOfClass("Tool") end
	
	-- ══════════════════════════════════════════════════════════════
	-- ENTITY CACHE SYSTEM
	-- ══════════════════════════════════════════════════════════════
	local EntityCache = {
		players = {},
		npcs = {},
		items = {}
	}
	
	local function updateEntityCache()
		-- Clean dead entries
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
		
		-- Update players
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player then
				if not EntityCache.players[plr.Name] then
					EntityCache.players[plr.Name] = {
						Player = plr,
						IsPlayer = true,
						Team = plr.Team
					}
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
		
		-- Update NPCs
		EntityCache.npcs = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Model") and obj:FindFirstChildOfClass("Humanoid") then
				if not Players:GetPlayerFromCharacter(obj) then
					local hum = obj:FindFirstChildOfClass("Humanoid")
					local root = obj:FindFirstChild("HumanoidRootPart") or obj:FindFirstChild("Torso") or obj:FindFirstChild("Head")
					if hum and hum.Health > 0 and root then
						table.insert(EntityCache.npcs, {
							Model = obj,
							Name = obj.Name,
							Humanoid = hum,
							RootPart = root,
							Head = obj:FindFirstChild("Head"),
							IsNPC = true
						})
					end
				end
			end
		end
		
		-- Update Items
		EntityCache.items = {}
		for _, obj in ipairs(workspace:GetDescendants()) do
			if obj:IsA("Tool") then
				local handle = obj:FindFirstChild("Handle")
				if handle then
					table.insert(EntityCache.items, {Object = obj, Position = handle.Position, Name = obj.Name, IsItem = true})
				end
			elseif obj:IsA("BasePart") then
				local n = obj.Name:lower()
				if n:find("coin") or n:find("gem") or n:find("item") or n:find("pickup") or n:find("chest") or n:find("loot") or n:find("drop") then
					table.insert(EntityCache.items, {Object = obj, Position = obj.Position, Name = obj.Name, IsItem = true})
				end
			end
		end
	end
	
	-- ══════════════════════════════════════════════════════════════
	-- DRAWING OBJECT POOL (Optimized - No recreation)
	-- ══════════════════════════════════════════════════════════════
	local DrawingPool = {
		text = {},
		square = {},
		line = {},
		triangle = {},
		circle = {},
		quad = {}
	}
	local ActiveDrawings = {}
	
	local function getDrawing(drawType)
		local pool = DrawingPool[drawType]
		if not pool then return nil end
		
		-- Find unused drawing
		for i, obj in ipairs(pool) do
			if not obj._inUse then
				obj._inUse = true
				obj.Visible = true
				table.insert(ActiveDrawings, obj)
				return obj
			end
		end
		
		-- Create new drawing
		local newDraw
		local success = pcall(function()
			if drawType == "text" then
				newDraw = Drawing.new("Text")
				newDraw.Size = 14
				newDraw.Center = true
				newDraw.Outline = true
				newDraw.Font = Drawing.Fonts.Gotham
			elseif drawType == "square" then
				newDraw = Drawing.new("Square")
				newDraw.Thickness = 1
				newDraw.Filled = false
			elseif drawType == "line" then
				newDraw = Drawing.new("Line")
				newDraw.Thickness = 1
			elseif drawType == "triangle" then
				newDraw = Drawing.new("Triangle")
				newDraw.Filled = true
			elseif drawType == "circle" then
				newDraw = Drawing.new("Circle")
				newDraw.Thickness = 2
				newDraw.NumSides = 64
				newDraw.Filled = false
			elseif drawType == "quad" then
				newDraw = Drawing.new("Quad")
				newDraw.Thickness = 1
				newDraw.Filled = false
			end
		end)
		
		if success and newDraw then
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
	
	-- ══════════════════════════════════════════════════════════════
	-- STATIC HUD DRAWINGS (Persistent elements)
	-- ══════════════════════════════════════════════════════════════
	local HUDDrawings = {}
	
	pcall(function()
		-- FOV Circle
		HUDDrawings.FOVCircle = Drawing.new("Circle")
		HUDDrawings.FOVCircle.Thickness = 2
		HUDDrawings.FOVCircle.NumSides = 64
		HUDDrawings.FOVCircle.Filled = false
		HUDDrawings.FOVCircle.Visible = false
		HUDDrawings.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
		HUDDrawings.FOVCircle.Transparency = 0.7
		
		-- Crosshair (4 lines for gap style)
		HUDDrawings.CrosshairLeft = Drawing.new("Line")
		HUDDrawings.CrosshairLeft.Thickness = 2
		HUDDrawings.CrosshairLeft.Visible = false
		
		HUDDrawings.CrosshairRight = Drawing.new("Line")
		HUDDrawings.CrosshairRight.Thickness = 2
		HUDDrawings.CrosshairRight.Visible = false
		
		HUDDrawings.CrosshairTop = Drawing.new("Line")
		HUDDrawings.CrosshairTop.Thickness = 2
		HUDDrawings.CrosshairTop.Visible = false
		
		HUDDrawings.CrosshairBottom = Drawing.new("Line")
		HUDDrawings.CrosshairBottom.Thickness = 2
		HUDDrawings.CrosshairBottom.Visible = false
		
		-- Watermark
		HUDDrawings.Watermark = Drawing.new("Text")
		HUDDrawings.Watermark.Size = 20
		HUDDrawings.Watermark.Font = Drawing.Fonts.GothamBold
		HUDDrawings.Watermark.Outline = true
		HUDDrawings.Watermark.Position = Vector2.new(10, 10)
		HUDDrawings.Watermark.Visible = false
		HUDDrawings.Watermark.Color = Color3.fromRGB(60, 120, 255)
		
		-- FPS Counter
		HUDDrawings.FPSCounter = Drawing.new("Text")
		HUDDrawings.FPSCounter.Size = 16
		HUDDrawings.FPSCounter.Font = Drawing.Fonts.Gotham
		HUDDrawings.FPSCounter.Outline = true
		HUDDrawings.FPSCounter.Position = Vector2.new(10, 35)
		HUDDrawings.FPSCounter.Visible = false
		HUDDrawings.FPSCounter.Color = Color3.fromRGB(255, 255, 255)
		
		-- Ping Display
		HUDDrawings.PingDisplay = Drawing.new("Text")
		HUDDrawings.PingDisplay.Size = 16
		HUDDrawings.PingDisplay.Font = Drawing.Fonts.Gotham
		HUDDrawings.PingDisplay.Outline = true
		HUDDrawings.PingDisplay.Position = Vector2.new(10, 55)
		HUDDrawings.PingDisplay.Visible = false
		HUDDrawings.PingDisplay.Color = Color3.fromRGB(255, 255, 255)
		
		-- Player Count
		HUDDrawings.PlayerCount = Drawing.new("Text")
		HUDDrawings.PlayerCount.Size = 16
		HUDDrawings.PlayerCount.Font = Drawing.Fonts.Gotham
		HUDDrawings.PlayerCount.Outline = true
		HUDDrawings.PlayerCount.Position = Vector2.new(10, 75)
		HUDDrawings.PlayerCount.Visible = false
		HUDDrawings.PlayerCount.Color = Color3.fromRGB(255, 255, 255)
		
		-- Velocity Display
		HUDDrawings.VelocityDisplay = Drawing.new("Text")
		HUDDrawings.VelocityDisplay.Size = 16
		HUDDrawings.VelocityDisplay.Font = Drawing.Fonts.Gotham
		HUDDrawings.VelocityDisplay.Outline = true
		HUDDrawings.VelocityDisplay.Position = Vector2.new(10, 95)
		HUDDrawings.VelocityDisplay.Visible = false
		HUDDrawings.VelocityDisplay.Color = Color3.fromRGB(255, 255, 255)
		
		-- Target Info
		HUDDrawings.TargetInfo = Drawing.new("Text")
		HUDDrawings.TargetInfo.Size = 16
		HUDDrawings.TargetInfo.Font = Drawing.Fonts.Gotham
		HUDDrawings.TargetInfo.Outline = true
		HUDDrawings.TargetInfo.Position = Vector2.new(10, 115)
		HUDDrawings.TargetInfo.Visible = false
		HUDDrawings.TargetInfo.Color = Color3.fromRGB(255, 255, 255)
		
		-- Keybinds Display
		HUDDrawings.KeybindsDisplay = Drawing.new("Text")
		HUDDrawings.KeybindsDisplay.Size = 14
		HUDDrawings.KeybindsDisplay.Font = Drawing.Fonts.Gotham
		HUDDrawings.KeybindsDisplay.Outline = true
		HUDDrawings.KeybindsDisplay.Visible = false
		HUDDrawings.KeybindsDisplay.Color = Color3.fromRGB(255, 255, 255)
	end)
	
	-- ══════════════════════════════════════════════════════════════
	-- ALL STATE VARIABLES (100+ Features)
	-- ══════════════════════════════════════════════════════════════
	local State = {
		-- ═══════════ ESP STATE ═══════════
		ESP = {
			-- Player ESP
			NameESP = false,
			BoxESP = false,
			HealthESP = false,
			DistanceESP = false,
			Tracers = false,
			SkeletonESP = false,
			OffscreenArrows = false,
			Chams = false,
			-- World ESP
			ItemESP = false,
			NPCESP = false,
			-- Settings
			MaxDistance = 1000,
			TeamCheck = false,
			FriendCheck = false,
			-- Colors
			BoxColor = Color3.fromRGB(255, 0, 0),
			NameColor = Color3.fromRGB(255, 255, 255),
			HealthColor = Color3.fromRGB(0, 255, 0),
			TracerColor = Color3.fromRGB(255, 255, 0),
			SkeletonColor = Color3.fromRGB(255, 255, 255),
			ArrowColor = Color3.fromRGB(255, 0, 0),
			ItemColor = Color3.fromRGB(255, 200, 0),
			NPCColor = Color3.fromRGB(0, 200, 255)
		},
		
		-- ═══════════ COMBAT STATE ═══════════
		Combat = {
			-- Aim Assist
			AimAssist = false,
			AimSmoothness = 0.15,
			AimFOV = 150,
			AimPrediction = false,
			PredictionAmount = 0.1,
			ShowFOVCircle = false,
			AimTargetPart = "Head",
			-- Silent Aim
			SilentAim = false,
			SilentAimHitChance = 100,
			SilentAimTargetPart = "Head",
			-- Kill Aura
			KillAura = false,
			KillAuraRange = 15,
			KillAuraCPS = 10,
			KillAuraTargetPlayers = true,
			KillAuraTargetNPCs = false,
			KillAuraWallCheck = true,
			KillAuraLegitMode = false,
			-- Reach
			Reach = false,
			ReachDistance = 18,
			ReachLegitMode = false,
			-- Triggerbot
			Triggerbot = false,
			TriggerbotDelay = 0.1,
			-- Auto
			AutoParry = false,
			AutoCombo = false,
			AutoBlock = false,
			-- Exploits
			HitboxExpander = false,
			HitboxSize = 5,
			Backtrack = false,
			BacktrackTime = 0.2,
			TargetStrafe = false,
			TargetStrafeSpeed = 5,
			TargetStrafeRadius = 10,
			AntiAim = false
		},
		
		-- ═══════════ MOVEMENT STATE ═══════════
		Movement = {
			-- Fly
			Fly = false,
			FlySpeed = 50,
			FlyLegitMode = false,
			-- Noclip
			Noclip = false,
			-- Speed
			Speed = false,
			SpeedValue = 16,
			SpeedLegitMode = false,
			-- Jump
			JumpPower = false,
			JumpPowerValue = 50,
			InfiniteJump = false,
			-- Special Movement
			BunnyHop = false,
			LongJump = false,
			LongJumpForce = 100,
			SpeedGlide = false,
			SpeedGlideValue = 10,
			Dash = false,
			DashForce = 100,
			DashCooldown = 1,
			AirControl = false,
			-- Teleport
			ClickTP = false,
			-- Safety
			AntiVoid = false,
			AntiVoidHeight = -100,
			Anchor = false,
			-- Exploits
			SpinBot = false,
			SpinBotSpeed = 20,
			FakeLag = false,
			FakeLagIntensity = 5
		},
		
		-- ═══════════ VISUALS STATE ═══════════
		Visuals = {
			-- Lighting
			Fullbright = false,
			NoFog = false,
			NoShadows = false,
			-- Crosshair
			CustomCrosshair = false,
			CrosshairSize = 10,
			CrosshairGap = 5,
			CrosshairColor = Color3.fromRGB(255, 0, 0),
			-- Camera
			CameraFOV = 70,
			ThirdPerson = false,
			Freecam = false,
			FreecamSpeed = 1,
			-- World
			XRay = false,
			XRayTransparency = 0.5,
			Ambient = false,
			AmbientColor = Color3.fromRGB(128, 128, 128)
		},
		
		-- ═══════════ WORLD STATE ═══════════
		World = {
			TimeOfDay = 14,
			Gravity = 196.2,
			DeleteMode = false,
			RemoveGrass = false,
			RemoveFog = false,
			NoClipParts = false
		},
		
		-- ═══════════ PLAYER STATE ═══════════
		Player = {
			-- Character
			GodMode = false,
			NoRagdoll = false,
			AutoRespawn = false,
			CharacterScale = 1,
			-- Invisibility
			Invisibility = false,
			InvisibilityMode = "Safe",
			InvisibilityOffset = 100,
			-- Weapon
			NoRecoil = false,
			NoSpread = false,
			InfiniteStamina = false,
			InfiniteAmmo = false,
			RapidFire = false
		},
		
		-- ═══════════ TROLL STATE ═══════════
		Troll = {
			AnnoyPlayer = false,
			AnnoyTarget = "",
			OrbitPlayer = false,
			OrbitTarget = "",
			OrbitRadius = 10,
			OrbitSpeed = 2,
			Fling = false,
			FlingPower = 500,
			Headless = false,
			InvisibleBody = false,
			SpinOthers = false
		},
		
		-- ═══════════ MISC STATE ═══════════
		Misc = {
			-- Anti Detection
			AntiAFK = false,
			-- Chat
			ChatSpam = false,
			ChatSpamMessage = "Vertex Hub on top!",
			ChatSpamDelay = 2,
			-- HUD
			Watermark = false,
			FPSCounter = false,
			PingDisplay = false,
			PlayerCount = false,
			VelocityDisplay = false,
			TargetInfo = false,
			KeybindsDisplay = false
		},
		
		-- ═══════════ SETTINGS STATE ═══════════
		Settings = {
			MenuKey = Enum.KeyCode.M,
			MenuScale = 1,
			AccentColor = Color3.fromRGB(60, 120, 255)
		}
	}
	
	-- ══════════════════════════════════════════════════════════════
	-- STORAGE FOR SPECIAL SYSTEMS
	-- ══════════════════════════════════════════════════════════════
	local BacktrackPositions = {}
	local CurrentTarget = nil
	local LastAttackTime = 0
	local LastTriggerbotTime = 0
	local LastDashTime = 0
	local FreecamPosition = Vector3.new(0, 50, 0)
	local FreecamAngles = Vector2.new(0, 0)
	local FPSCounter = {frames = 0, lastTime = tick(), fps = 60}
	local PreviousMouseState = {behavior = nil, icon = nil}
	
	-- ══════════════════════════════════════════════════════════════
	-- ORIGINAL VALUES STORAGE
	-- ══════════════════════════════════════════════════════════════
	local OriginalValues = {
		Ambient = Lighting.Ambient,
		Brightness = Lighting.Brightness,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		GlobalShadows = Lighting.GlobalShadows,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime,
		Gravity = workspace.Gravity,
		FieldOfView = camera.FieldOfView
	}
	
	-- ══════════════════════════════════════════════════════════════
	-- TARGET ACQUISITION SYSTEM
	-- ══════════════════════════════════════════════════════════════
	local function getBestTarget(options)
		options = options or {}
		local range = options.Range or 150
		local targetPlayers = options.Players ~= false
		local targetNPCs = options.NPCs or false
		local wallCheck = options.WallCheck or false
		local useFOV = options.UseFOV or false
		local fov = options.FOV or 150
		local sortBy = options.Sort or "Distance"
		local targetPart = options.TargetPart or "Head"
		
		local myRoot = getRoot()
		if not myRoot then return nil end
		
		local targets = {}
		local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		local myTeam = player.Team
		
		-- Gather player targets
		if targetPlayers then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					-- Team check
					if State.ESP.TeamCheck and data.Team and myTeam and data.Team == myTeam then
						continue
					end
					
					local targetPos = data[targetPart] and data[targetPart].Position or data.RootPart.Position
					local distance = (myRoot.Position - data.RootPart.Position).Magnitude
					
					if distance <= range then
						local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
						local screenDistance = onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude or math.huge
						
						-- FOV check
						if not useFOV or screenDistance <= fov then
							-- Wall check
							local passWallCheck = true
							if wallCheck then
								local rayOrigin = myRoot.Position
								local rayDirection = (data.RootPart.Position - myRoot.Position)
								local raycastParams = RaycastParams.new()
								raycastParams.FilterDescendantsInstances = {getCharacter(), data.Character}
								raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
								local result = workspace:Raycast(rayOrigin, rayDirection, raycastParams)
								passWallCheck = result == nil
							end
							
							if passWallCheck then
								table.insert(targets, {
									Entity = data,
									Distance = distance,
									ScreenDistance = screenDistance,
									Health = data.Humanoid.Health,
									Position = targetPos,
									IsPlayer = true
								})
							end
						end
					end
				end
			end
		end
		
		-- Gather NPC targets
		if targetNPCs then
			for _, data in ipairs(EntityCache.npcs) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					local targetPos = data.Head and data.Head.Position or data.RootPart.Position
					local distance = (myRoot.Position - data.RootPart.Position).Magnitude
					
					if distance <= range then
						local screenPos, onScreen = camera:WorldToViewportPoint(targetPos)
						local screenDistance = onScreen and (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude or math.huge
						
						if not useFOV or screenDistance <= fov then
							table.insert(targets, {
								Entity = data,
								Distance = distance,
								ScreenDistance = screenDistance,
								Health = data.Humanoid.Health,
								Position = targetPos,
								IsNPC = true
							})
						end
					end
				end
			end
		end
		
		if #targets == 0 then return nil end
		
		-- Sort targets
		table.sort(targets, function(a, b)
			if sortBy == "Distance" then
				return a.Distance < b.Distance
			elseif sortBy == "Health" then
				return a.Health < b.Health
			elseif sortBy == "Angle" or sortBy == "FOV" then
				return a.ScreenDistance < b.ScreenDistance
			elseif sortBy == "Threat" then
				return (a.Health / a.Distance) < (b.Health / b.Distance)
			end
			return a.Distance < b.Distance
		end)
		
		CurrentTarget = targets[1].Entity
		return targets[1].Entity, targets[1].Position
	end
	
	-- ══════════════════════════════════════════════════════════════
	-- FLY SYSTEM (Stealth)
	-- ══════════════════════════════════════════════════════════════
	local FlySystem = {
		enabled = false,
		bodyGyro = nil,
		bodyVelocity = nil,
		currentVelocity = Vector3.new()
	}
	
	function FlySystem:Enable()
		local root = getRoot()
		local humanoid = getHumanoid()
		if not root or not humanoid then return end
		
		self.enabled = true
		humanoid.PlatformStand = true
		
		-- Create BodyGyro for rotation
		self.bodyGyro = Instance.new("BodyGyro")
		self.bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		self.bodyGyro.P = 1e4
		self.bodyGyro.D = 100
		self.bodyGyro.Parent = root
		
		-- Create BodyVelocity for movement
		self.bodyVelocity = Instance.new("BodyVelocity")
		self.bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		self.bodyVelocity.Velocity = Vector3.new(0, 0, 0)
		self.bodyVelocity.Parent = root
		
		self.currentVelocity = Vector3.new()
	end
	
	function FlySystem:Disable()
		self.enabled = false
		
		local humanoid = getHumanoid()
		if humanoid then
			humanoid.PlatformStand = false
		end
		
		if self.bodyGyro then
			self.bodyGyro:Destroy()
			self.bodyGyro = nil
		end
		
		if self.bodyVelocity then
			self.bodyVelocity:Destroy()
			self.bodyVelocity = nil
		end
		
		self.currentVelocity = Vector3.new()
	end
	
	function FlySystem:Update()
		if not self.enabled or not self.bodyVelocity or not self.bodyGyro then return end
		
		local root = getRoot()
		if not root then return end
		
		-- Update rotation to face camera direction
		self.bodyGyro.CFrame = camera.CFrame
		
		-- Calculate movement direction
		local moveDirection = Vector3.new()
		
		if UIS:IsKeyDown(Enum.KeyCode.W) then
			moveDirection = moveDirection + camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.S) then
			moveDirection = moveDirection - camera.CFrame.LookVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.A) then
			moveDirection = moveDirection - camera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.D) then
			moveDirection = moveDirection + camera.CFrame.RightVector
		end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then
			moveDirection = moveDirection + Vector3.new(0, 1, 0)
		end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then
			moveDirection = moveDirection - Vector3.new(0, 1, 0)
		end
		
		-- Normalize direction
		if moveDirection.Magnitude > 0 then
			moveDirection = moveDirection.Unit
		end
		
		-- Calculate target velocity
		local targetVelocity = moveDirection * State.Movement.FlySpeed
		
		-- Apply smoothing for legit mode
		if State.Movement.FlyLegitMode then
			self.currentVelocity = self.currentVelocity:Lerp(targetVelocity, 0.08)
			self.bodyVelocity.Velocity = self.currentVelocity
		else
			self.bodyVelocity.Velocity = targetVelocity
		end
	end
	
	-- ══════════════════════════════════════════════════════════════
	-- INVISIBILITY SYSTEM (Hitbox-only, NO transparency)
	-- ══════════════════════════════════════════════════════════════
	local InvisibilitySystem = {
		enabled = false,
		originalCFrames = {},
		connection = nil
	}
	
	function InvisibilitySystem:Enable()
		local character = getCharacter()
		local root = getRoot()
		if not character or not root then return end
		
		self.enabled = true
		self.originalCFrames = {}
		
		-- Calculate offset based on mode
		local offset = State.Player.InvisibilityOffset
		if State.Player.InvisibilityMode == "Extreme" then
			offset = 500
		end
		
		-- Move all parts except HumanoidRootPart
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				self.originalCFrames[part] = part.CFrame:ToObjectSpace(root.CFrame)
				part.CFrame = part.CFrame + Vector3.new(0, offset, 0)
			end
		end
	end
	
	function InvisibilitySystem:Disable()
		self.enabled = false
		
		local root = getRoot()
		if not root then return end
		
		-- Restore original positions
		for part, relativeCFrame in pairs(self.originalCFrames) do
			if part and part.Parent then
				part.CFrame = root.CFrame * relativeCFrame
			end
		end
		
		self.originalCFrames = {}
	end
	
	function InvisibilitySystem:Update()
		if not self.enabled then return end
		
		local root = getRoot()
		if not root then return end
		
		local offset = State.Player.InvisibilityOffset
		if State.Player.InvisibilityMode == "Extreme" then
			offset = 500
		end
		
		-- Keep parts offset
		for part, _ in pairs(self.originalCFrames) do
			if part and part.Parent then
				part.CFrame = root.CFrame + Vector3.new(0, offset, 0)
			end
		end
	end
	
	-- ══════════════════════════════════════════════════════════════
	-- SILENT AIM HOOKS
	-- ══════════════════════════════════════════════════════════════
	local function getAimTarget()
		return getBestTarget({
			Range = 1000,
			Players = true,
			NPCs = true,
			UseFOV = true,
			FOV = State.Combat.AimFOV,
			Sort = "Angle",
			TargetPart = State.Combat.SilentAimTargetPart
		})
	end
	
	-- Hook mouse properties
	pcall(function()
		local oldIndex
		oldIndex = hookmetamethod(game, "__index", function(self, key)
			if State.Combat.SilentAim and self == mouse then
				-- Hit chance check
				if math.random(1, 100) <= State.Combat.SilentAimHitChance then
					local target, targetPos = getAimTarget()
					
					if target and targetPos then
						-- Apply prediction if enabled
						if State.Combat.AimPrediction and target.RootPart then
							targetPos = targetPos + target.RootPart.Velocity * State.Combat.PredictionAmount
						end
						
						if key == "Hit" then
							return CFrame.new(targetPos)
						elseif key == "Target" then
							return target[State.Combat.SilentAimTargetPart] or target.Head or target.RootPart
						elseif key == "X" then
							local screenPos = camera:WorldToViewportPoint(targetPos)
							return screenPos.X
						elseif key == "Y" then
							local screenPos = camera:WorldToViewportPoint(targetPos)
							return screenPos.Y
						elseif key == "UnitRay" then
							local origin = camera.CFrame.Position
							local direction = (targetPos - origin).Unit
							return Ray.new(origin, direction)
						end
					end
				end
			end
			return oldIndex(self, key)
		end)
	end)
	
	-- Hook raycast methods
	pcall(function()
		local oldNamecall
		oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
			local method = getnamecallmethod()
			local args = {...}
			
			if State.Combat.SilentAim and self == workspace then
				local methods = {
					["Raycast"] = true,
					["FindPartOnRay"] = true,
					["FindPartOnRayWithIgnoreList"] = true,
					["FindPartOnRayWithWhitelist"] = true
				}
				
				if methods[method] then
					if math.random(1, 100) <= State.Combat.SilentAimHitChance then
						local target, targetPos = getAimTarget()
						
						if target and targetPos then
							if State.Combat.AimPrediction and target.RootPart then
								targetPos = targetPos + target.RootPart.Velocity * State.Combat.PredictionAmount
							end
							
							if method == "Raycast" and args[1] then
								local origin = args[1]
								local newDirection = (targetPos - origin).Unit * 1000
								return oldNamecall(self, origin, newDirection, unpack(args, 3))
							elseif args[1] and typeof(args[1]) == "Ray" then
								local origin = args[1].Origin
								local newDirection = (targetPos - origin).Unit * 1000
								local newRay = Ray.new(origin, newDirection)
								return oldNamecall(self, newRay, unpack(args, 2))
							end
						end
					end
				end
			end
			
			return oldNamecall(self, ...)
		end)
	end)
	
	-- Hook camera ray methods
	pcall(function()
		local oldScreenPointToRay = camera.ScreenPointToRay
		local oldViewportPointToRay = camera.ViewportPointToRay
		
		local function hookCameraRay(originalFunc)
			return function(self, x, y, depth)
				if State.Combat.SilentAim and self == camera then
					if math.random(1, 100) <= State.Combat.SilentAimHitChance then
						local target, targetPos = getAimTarget()
						if target and targetPos then
							if State.Combat.AimPrediction and target.RootPart then
								targetPos = targetPos + target.RootPart.Velocity * State.Combat.PredictionAmount
							end
							local origin = camera.CFrame.Position
							local direction = (targetPos - origin).Unit
							return Ray.new(origin, direction)
						end
					end
				end
				return originalFunc(self, x, y, depth)
			end
		end
		
		if hookfunction then
			hookfunction(camera.ScreenPointToRay, hookCameraRay(oldScreenPointToRay))
			hookfunction(camera.ViewportPointToRay, hookCameraRay(oldViewportPointToRay))
		end
	end)
	
	-- ══════════════════════════════════════════════════════════════
	-- BACKGROUND LOOPS
	-- ══════════════════════════════════════════════════════════════
	
	-- Chat Spam Loop
	task.spawn(function()
		while true do
			if State.Misc.ChatSpam then
				pcall(function()
					local chatEvents = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
					if chatEvents then
						local sayMsg = chatEvents:FindFirstChild("SayMessageRequest")
						if sayMsg then
							sayMsg:FireServer(State.Misc.ChatSpamMessage, "All")
						end
					end
				end)
			end
			task.wait(State.Misc.ChatSpamDelay)
		end
	end)
	
	-- Auto Respawn Loop
	task.spawn(function()
		while true do
			if State.Player.AutoRespawn then
				local humanoid = getHumanoid()
				if humanoid and humanoid.Health <= 0 then
					task.wait(0.1)
					pcall(function()
						player:LoadCharacter()
					end)
				end
			end
			task.wait(0.5)
		end
	end)
	
	-- ══════════════════════════════════════════════════════════════
	-- CHAMS UPDATE FUNCTION
	-- ══════════════════════════════════════════════════════════════
	local function updateChams()
		for name, data in pairs(EntityCache.players) do
			if data.Character then
				local existingChams = data.Character:FindFirstChild("VertexHubChams")
				
				if State.ESP.Chams then
					if not existingChams then
						local highlight = Instance.new("Highlight")
						highlight.Name = "VertexHubChams"
						highlight.FillColor = Color3.fromRGB(255, 0, 0)
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
						highlight.FillTransparency = 0.5
						highlight.OutlineTransparency = 0
						highlight.Parent = data.Character
					end
				else
					if existingChams then
						existingChams:Destroy()
					end
				end
			end
		end
		
		-- NPC Chams
		for _, data in ipairs(EntityCache.npcs) do
			if data.Model then
				local existingChams = data.Model:FindFirstChild("VertexHubChams")
				
				if State.ESP.Chams and State.ESP.NPCESP then
					if not existingChams then
						local highlight = Instance.new("Highlight")
						highlight.Name = "VertexHubChams"
						highlight.FillColor = Color3.fromRGB(0, 200, 255)
						highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
						highlight.FillTransparency = 0.5
						highlight.OutlineTransparency = 0
						highlight.Parent = data.Model
					end
				else
					if existingChams then
						existingChams:Destroy()
					end
				end
			end
		end
	end
	
	-- ══════════════════════════════════════════════════════════════
	-- MAIN UPDATE LOOP (Single RenderStepped)
	-- ══════════════════════════════════════════════════════════════
	local lastCacheUpdate = 0
	
	RunService.RenderStepped:Connect(function(deltaTime)
		camera = workspace.CurrentCamera
		local character = getCharacter()
		local root = getRoot()
		local humanoid = getHumanoid()
		
		-- ═══════════ UPDATE CACHE (Every 0.5s) ═══════════
		if tick() - lastCacheUpdate > 0.5 then
			lastCacheUpdate = tick()
			updateEntityCache()
		end
		
		-- ═══════════ FPS COUNTER ═══════════
		FPSCounter.frames = FPSCounter.frames + 1
		if tick() - FPSCounter.lastTime >= 1 then
			FPSCounter.fps = FPSCounter.frames
			FPSCounter.frames = 0
			FPSCounter.lastTime = tick()
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- MOVEMENT FEATURES
		-- ══════════════════════════════════════════════════════════════
		
		-- Fly
		if State.Movement.Fly then
			if not FlySystem.enabled then
				FlySystem:Enable()
			end
			FlySystem:Update()
		elseif FlySystem.enabled then
			FlySystem:Disable()
		end
		
		-- Noclip
		if State.Movement.Noclip and character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
		
		-- Speed
		if State.Movement.Speed and humanoid then
			local targetSpeed = State.Movement.SpeedValue
			if State.Movement.SpeedLegitMode then
				humanoid.WalkSpeed = humanoid.WalkSpeed + (targetSpeed - humanoid.WalkSpeed) * 0.1
			else
				humanoid.WalkSpeed = targetSpeed
			end
		end
		
		-- Jump Power
		if State.Movement.JumpPower and humanoid then
			humanoid.JumpPower = State.Movement.JumpPowerValue
			humanoid.JumpHeight = State.Movement.JumpPowerValue * 0.5
		end
		
		-- Bunny Hop
		if State.Movement.BunnyHop and humanoid then
			if humanoid.FloorMaterial ~= Enum.Material.Air and humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
		
		-- Speed Glide
		if State.Movement.SpeedGlide and root and humanoid then
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				local maxFallSpeed = -State.Movement.SpeedGlideValue * 10
				if root.Velocity.Y < maxFallSpeed then
					root.Velocity = Vector3.new(root.Velocity.X, maxFallSpeed, root.Velocity.Z)
				end
			end
		end
		
		-- Anti Void
		if State.Movement.AntiVoid and root then
			if root.Position.Y < State.Movement.AntiVoidHeight then
				root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
			end
		end
		
		-- Anchor
		if State.Movement.Anchor and root then
			root.Anchored = true
		elseif root and root.Anchored and not State.Movement.Anchor then
			root.Anchored = false
		end
		
		-- Spin Bot
		if State.Movement.SpinBot and root then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(State.Movement.SpinBotSpeed), 0)
		end
		
		-- Fake Lag
		if State.Movement.FakeLag and root then
			if math.random(1, 10) <= State.Movement.FakeLagIntensity then
				root.Velocity = Vector3.new(0, root.Velocity.Y, 0)
			end
		end
		
		-- Air Control
		if State.Movement.AirControl and humanoid and root then
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				local moveDir = Vector3.new()
				if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
				if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
				if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
				
				if moveDir.Magnitude > 0 then
					moveDir = moveDir.Unit
					root.Velocity = Vector3.new(moveDir.X * 50, root.Velocity.Y, moveDir.Z * 50)
				end
			end
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- COMBAT FEATURES
		-- ══════════════════════════════════════════════════════════════
		
		-- Aim Assist
		if State.Combat.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target, targetPos = getBestTarget({
				Range = 1000,
				Players = true,
				NPCs = true,
				UseFOV = true,
				FOV = State.Combat.AimFOV,
				Sort = "Angle",
				TargetPart = State.Combat.AimTargetPart
			})
			
			if target and targetPos then
				-- Apply prediction
				if State.Combat.AimPrediction and target.RootPart then
					targetPos = targetPos + target.RootPart.Velocity * State.Combat.PredictionAmount
				end
				
				local targetCFrame = CFrame.new(camera.CFrame.Position, targetPos)
				camera.CFrame = camera.CFrame:Lerp(targetCFrame, State.Combat.AimSmoothness)
			end
		end
		
		-- Target Strafe
		if State.Combat.TargetStrafe and root and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target = getBestTarget({
				Range = State.Combat.TargetStrafeRadius * 2,
				Players = true,
				NPCs = true
			})
			
			if target and target.RootPart then
				local angle = tick() * State.Combat.TargetStrafeSpeed
				local offset = Vector3.new(
					math.cos(angle) * State.Combat.TargetStrafeRadius,
					0,
					math.sin(angle) * State.Combat.TargetStrafeRadius
				)
				root.CFrame = CFrame.new(target.RootPart.Position + offset, target.RootPart.Position)
			end
		end
		
		-- Kill Aura
		if State.Combat.KillAura and root then
			local now = tick()
			local cooldown = 1 / State.Combat.KillAuraCPS
			
			-- Add randomness for legit mode
			if State.Combat.KillAuraLegitMode then
				cooldown = cooldown * (1 + math.random() * 0.3)
			end
			
			if now - LastAttackTime >= cooldown then
				local target = getBestTarget({
					Range = State.Combat.KillAuraRange,
					Players = State.Combat.KillAuraTargetPlayers,
					NPCs = State.Combat.KillAuraTargetNPCs,
					WallCheck = State.Combat.KillAuraWallCheck,
					Sort = "Distance"
				})
				
				if target and target.RootPart then
					LastAttackTime = now
					
					local tool = getTool()
					if tool then
						-- Try to activate tool
						pcall(function()
							tool:Activate()
						end)
						
						-- Try touch interest for melee weapons
						pcall(function()
							local handle = tool:FindFirstChild("Handle")
							if handle then
								firetouchinterest(handle, target.RootPart, 0)
								task.defer(function()
									firetouchinterest(handle, target.RootPart, 1)
								end)
							end
						end)
					end
				end
			end
		end
		
		-- Triggerbot
		if State.Combat.Triggerbot then
			local now = tick()
			if now - LastTriggerbotTime >= State.Combat.TriggerbotDelay then
				local target = mouse.Target
				if target then
					local targetPlayer = Players:GetPlayerFromCharacter(target.Parent)
					if targetPlayer and targetPlayer ~= player then
						LastTriggerbotTime = now
						pcall(function()
							mouse1click()
						end)
					end
				end
			end
		end
		
		-- Auto Parry
		if State.Combat.AutoParry and root and character then
			for _, obj in ipairs(workspace:GetDescendants()) do
				if obj:IsA("BasePart") then
					local name = obj.Name:lower()
					if name:find("sword") or name:find("blade") or name:find("slash") or name:find("attack") then
						if obj.Parent ~= character and (obj.Parent and obj.Parent.Parent ~= character) then
							local distance = (root.Position - obj.Position).Magnitude
							if distance < 15 then
								local tool = getTool()
								if tool then
									pcall(function() tool:Activate() end)
								end
								pcall(function() mouse2click() end)
								break
							end
						end
					end
				end
			end
		end
		
		-- Hitbox Expander
		if State.Combat.HitboxExpander then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart then
					data.RootPart.Size = Vector3.new(
						State.Combat.HitboxSize,
						State.Combat.HitboxSize,
						State.Combat.HitboxSize
					)
					data.RootPart.Transparency = 0.7
				end
			end
		end
		
		-- Backtrack
		if State.Combat.Backtrack then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart then
					if not BacktrackPositions[name] then
						BacktrackPositions[name] = {}
					end
					
					table.insert(BacktrackPositions[name], {
						Position = data.RootPart.Position,
						Time = tick()
					})
					
					-- Clean old positions
					for i = #BacktrackPositions[name], 1, -1 do
						if tick() - BacktrackPositions[name][i].Time > State.Combat.BacktrackTime then
							table.remove(BacktrackPositions[name], i)
						end
					end
				end
			end
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- PLAYER FEATURES
		-- ══════════════════════════════════════════════════════════════
		
		-- God Mode
		if State.Player.GodMode and humanoid then
			humanoid.Health = humanoid.MaxHealth
		end
		
		-- No Ragdoll
		if State.Player.NoRagdoll and humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
		end
		
		-- Invisibility Update
		if State.Player.Invisibility then
			InvisibilitySystem:Update()
		end
		
		-- Infinite Stamina
		if State.Player.InfiniteStamina then
			pcall(function()
				for _, descendant in pairs(player.PlayerGui:GetDescendants()) do
					if descendant.Name:lower():find("stamina") and descendant:IsA("ValueBase") then
						if descendant.Value < 100 then
							descendant.Value = 100
						end
					end
				end
			end)
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- TROLL FEATURES
		-- ══════════════════════════════════════════════════════════════
		
		-- Annoy Player
		if State.Troll.AnnoyPlayer and State.Troll.AnnoyTarget ~= "" and root then
			local targetPlayer = Players:FindFirstChild(State.Troll.AnnoyTarget)
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
				end
			end
		end
		
		-- Orbit Player
		if State.Troll.OrbitPlayer and State.Troll.OrbitTarget ~= "" and root then
			local targetPlayer = Players:FindFirstChild(State.Troll.OrbitTarget)
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					local angle = tick() * State.Troll.OrbitSpeed
					local offset = Vector3.new(
						math.cos(angle) * State.Troll.OrbitRadius,
						0,
						math.sin(angle) * State.Troll.OrbitRadius
					)
					root.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
				end
			end
		end
		
		-- Fling
		if State.Troll.Fling and root then
			root.Velocity = Vector3.new(
				math.random(-State.Troll.FlingPower, State.Troll.FlingPower),
				math.random(100, State.Troll.FlingPower),
				math.random(-State.Troll.FlingPower, State.Troll.FlingPower)
			)
			root.RotVelocity = Vector3.new(
				math.random(-100, 100),
				math.random(-100, 100),
				math.random(-100, 100)
			)
		end
		
		-- Headless
		if State.Troll.Headless and character then
			local head = character:FindFirstChild("Head")
			if head then
				head.Transparency = 1
				local face = head:FindFirstChildOfClass("Decal")
				if face then
					face.Transparency = 1
				end
				for _, accessory in ipairs(character:GetChildren()) do
					if accessory:IsA("Accessory") then
						local handle = accessory:FindFirstChild("Handle")
						if handle then
							handle.Transparency = 1
						end
					end
				end
			end
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- VISUALS FEATURES
		-- ══════════════════════════════════════════════════════════════
		
		-- Freecam
		if State.Visuals.Freecam then
			local speed = State.Visuals.FreecamSpeed * 2
			local moveDir = Vector3.new()
			
			if UIS:IsKeyDown(Enum.KeyCode.W) then moveDir = moveDir + camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then moveDir = moveDir - camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then moveDir = moveDir - camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then moveDir = moveDir + camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then moveDir = moveDir + Vector3.new(0, 1, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then moveDir = moveDir - Vector3.new(0, 1, 0) end
			
			if moveDir.Magnitude > 0 then
				FreecamPosition = FreecamPosition + moveDir.Unit * speed
			end
			
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.new(FreecamPosition) * CFrame.Angles(
				math.rad(FreecamAngles.X),
				math.rad(FreecamAngles.Y),
				0
			)
		end
		
		-- X-Ray
		if State.Visuals.XRay then
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(character or {}) then
					if part.Transparency < 1 then
						part.LocalTransparencyModifier = State.Visuals.XRayTransparency
					end
				end
			end
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- HUD UPDATES
		-- ══════════════════════════════════════════════════════════════
		
		-- FOV Circle
		if HUDDrawings.FOVCircle then
			HUDDrawings.FOVCircle.Visible = State.Combat.ShowFOVCircle
			HUDDrawings.FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			HUDDrawings.FOVCircle.Radius = State.Combat.AimFOV
			HUDDrawings.FOVCircle.Color = State.Settings.AccentColor
		end
		
		-- Crosshair
		if HUDDrawings.CrosshairLeft then
			local visible = State.Visuals.CustomCrosshair
			local cx, cy = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
			local size = State.Visuals.CrosshairSize
			local gap = State.Visuals.CrosshairGap
			local color = State.Visuals.CrosshairColor
			
			HUDDrawings.CrosshairLeft.Visible = visible
			HUDDrawings.CrosshairLeft.From = Vector2.new(cx - size - gap, cy)
			HUDDrawings.CrosshairLeft.To = Vector2.new(cx - gap, cy)
			HUDDrawings.CrosshairLeft.Color = color
			
			HUDDrawings.CrosshairRight.Visible = visible
			HUDDrawings.CrosshairRight.From = Vector2.new(cx + gap, cy)
			HUDDrawings.CrosshairRight.To = Vector2.new(cx + size + gap, cy)
			HUDDrawings.CrosshairRight.Color = color
			
			HUDDrawings.CrosshairTop.Visible = visible
			HUDDrawings.CrosshairTop.From = Vector2.new(cx, cy - size - gap)
			HUDDrawings.CrosshairTop.To = Vector2.new(cx, cy - gap)
			HUDDrawings.CrosshairTop.Color = color
			
			HUDDrawings.CrosshairBottom.Visible = visible
			HUDDrawings.CrosshairBottom.From = Vector2.new(cx, cy + gap)
			HUDDrawings.CrosshairBottom.To = Vector2.new(cx, cy + size + gap)
			HUDDrawings.CrosshairBottom.Color = color
		end
		
		-- Watermark
		if HUDDrawings.Watermark then
			HUDDrawings.Watermark.Visible = State.Misc.Watermark
			HUDDrawings.Watermark.Text = "Vertex Hub"
			HUDDrawings.Watermark.Color = State.Settings.AccentColor
		end
		
		-- FPS Counter
		if HUDDrawings.FPSCounter then
			HUDDrawings.FPSCounter.Visible = State.Misc.FPSCounter
			HUDDrawings.FPSCounter.Text = "FPS: " .. tostring(FPSCounter.fps)
		end
		
		-- Ping Display
		if HUDDrawings.PingDisplay then
			HUDDrawings.PingDisplay.Visible = State.Misc.PingDisplay
			local ping = 0
			pcall(function()
				ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			end)
			HUDDrawings.PingDisplay.Text = "Ping: " .. math.floor(ping) .. "ms"
		end
		
		-- Player Count
		if HUDDrawings.PlayerCount then
			HUDDrawings.PlayerCount.Visible = State.Misc.PlayerCount
			HUDDrawings.PlayerCount.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		end
		
		-- Velocity Display
		if HUDDrawings.VelocityDisplay then
			HUDDrawings.VelocityDisplay.Visible = State.Misc.VelocityDisplay
			local velocity = root and root.Velocity.Magnitude or 0
			HUDDrawings.VelocityDisplay.Text = "Speed: " .. math.floor(velocity) .. " studs/s"
		end
		
		-- Target Info
		if HUDDrawings.TargetInfo then
			HUDDrawings.TargetInfo.Visible = State.Misc.TargetInfo
			if CurrentTarget and CurrentTarget.Humanoid then
				local name = CurrentTarget.Player and CurrentTarget.Player.Name or (CurrentTarget.Model and CurrentTarget.Model.Name) or "Unknown"
				HUDDrawings.TargetInfo.Text = "Target: " .. name .. " [" .. math.floor(CurrentTarget.Humanoid.Health) .. " HP]"
			else
				HUDDrawings.TargetInfo.Text = "Target: None"
			end
		end
		
		-- Keybinds Display
		if HUDDrawings.KeybindsDisplay then
			HUDDrawings.KeybindsDisplay.Visible = State.Misc.KeybindsDisplay
			HUDDrawings.KeybindsDisplay.Position = Vector2.new(camera.ViewportSize.X - 150, 10)
			
			local activeFeatures = {}
			if State.Movement.Fly then table.insert(activeFeatures, "Fly") end
			if State.Movement.Noclip then table.insert(activeFeatures, "Noclip") end
			if State.Movement.Speed then table.insert(activeFeatures, "Speed") end
			if State.Combat.AimAssist then table.insert(activeFeatures, "Aim") end
			if State.Combat.SilentAim then table.insert(activeFeatures, "Silent") end
			if State.Combat.KillAura then table.insert(activeFeatures, "Aura") end
			if State.ESP.BoxESP or State.ESP.NameESP then table.insert(activeFeatures, "ESP") end
			
			HUDDrawings.KeybindsDisplay.Text = "[Active]\n" .. (#activeFeatures > 0 and table.concat(activeFeatures, "\n") or "None")
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- ESP RENDERING
		-- ══════════════════════════════════════════════════════════════
		releaseAllDrawings()
		
		local anyESPEnabled = State.ESP.NameESP or State.ESP.BoxESP or State.ESP.HealthESP or 
			State.ESP.DistanceESP or State.ESP.Tracers or State.ESP.SkeletonESP or 
			State.ESP.OffscreenArrows or State.ESP.ItemESP or State.ESP.NPCESP
		
		if anyESPEnabled then
			-- Player ESP
			for name, data in pairs(EntityCache.players) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					local distance = root and (root.Position - data.RootPart.Position).Magnitude or 0
					
					if distance <= State.ESP.MaxDistance then
						local pos, onScreen = camera:WorldToViewportPoint(data.RootPart.Position)
						local scale = math.clamp(1 / (pos.Z * 0.04), 0.2, 2)
						
						if onScreen then
							-- Name ESP
							if State.ESP.NameESP then
								local text = getDrawing("text")
								if text then
									text.Text = name
									text.Position = Vector2.new(pos.X, pos.Y - 50 * scale)
									text.Color = State.ESP.NameColor
									text.Size = 14
								end
							end
							
							-- Health ESP
							if State.ESP.HealthESP then
								local text = getDrawing("text")
								if text then
									local healthPercent = math.floor((data.Humanoid.Health / data.Humanoid.MaxHealth) * 100)
									text.Text = healthPercent .. "%"
									text.Position = Vector2.new(pos.X, pos.Y - 35 * scale)
									text.Color = State.ESP.HealthColor
									text.Size = 12
								end
							end
							
							-- Distance ESP
							if State.ESP.DistanceESP then
								local text = getDrawing("text")
								if text then
									text.Text = math.floor(distance) .. "m"
									text.Position = Vector2.new(pos.X, pos.Y + 40 * scale)
									text.Color = Color3.fromRGB(200, 200, 200)
									text.Size = 12
								end
							end
							
							-- Box ESP
							if State.ESP.BoxESP then
								local box = getDrawing("square")
								if box then
									local boxSize = Vector2.new(50 * scale, 70 * scale)
									box.Size = boxSize
									box.Position = Vector2.new(pos.X - boxSize.X / 2, pos.Y - boxSize.Y / 2)
									box.Color = State.ESP.BoxColor
								end
							end
							
							-- Tracers
							if State.ESP.Tracers then
								local line = getDrawing("line")
								if line then
									line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
									line.To = Vector2.new(pos.X, pos.Y)
									line.Color = State.ESP.TracerColor
								end
							end
							
							-- Skeleton ESP
							if State.ESP.SkeletonESP and data.Character then
								local isR15 = data.Character:FindFirstChild("UpperTorso") ~= nil
								local joints
								
								if isR15 then
									joints = {
										{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
										{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
										{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
										{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
										{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
									}
								else
									joints = {
										{"Head", "Torso"},
										{"Torso", "Left Arm"}, {"Torso", "Right Arm"},
										{"Torso", "Left Leg"}, {"Torso", "Right Leg"}
									}
								end
								
								for _, joint in ipairs(joints) do
									local part1 = data.Character:FindFirstChild(joint[1])
									local part2 = data.Character:FindFirstChild(joint[2])
									
									if part1 and part2 then
										local screen1, visible1 = camera:WorldToViewportPoint(part1.Position)
										local screen2, visible2 = camera:WorldToViewportPoint(part2.Position)
										
										if visible1 and visible2 then
											local line = getDrawing("line")
											if line then
												line.From = Vector2.new(screen1.X, screen1.Y)
												line.To = Vector2.new(screen2.X, screen2.Y)
												line.Color = State.ESP.SkeletonColor
											end
										end
									end
								end
							end
						else
							-- Offscreen Arrows
							if State.ESP.OffscreenArrows then
								local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
								local direction = (Vector2.new(pos.X, pos.Y) - screenCenter).Unit
								local arrowPosition = screenCenter + direction * 300
								
								arrowPosition = Vector2.new(
									math.clamp(arrowPosition.X, 50, camera.ViewportSize.X - 50),
									math.clamp(arrowPosition.Y, 50, camera.ViewportSize.Y - 50)
								)
								
								local arrow = getDrawing("triangle")
								if arrow then
									local angle = math.atan2(direction.Y, direction.X)
									arrow.PointA = arrowPosition + Vector2.new(math.cos(angle) * 15, math.sin(angle) * 15)
									arrow.PointB = arrowPosition + Vector2.new(math.cos(angle + 2.5) * 15, math.sin(angle + 2.5) * 15)
									arrow.PointC = arrowPosition + Vector2.new(math.cos(angle - 2.5) * 15, math.sin(angle - 2.5) * 15)
									arrow.Color = State.ESP.ArrowColor
								end
							end
						end
					end
				end
			end
			
			-- NPC ESP
			if State.ESP.NPCESP then
				for _, data in ipairs(EntityCache.npcs) do
					if data.RootPart then
						local pos, onScreen = camera:WorldToViewportPoint(data.RootPart.Position)
						if onScreen then
							local text = getDrawing("text")
							if text then
								text.Text = "[NPC] " .. data.Name
								text.Position = Vector2.new(pos.X, pos.Y - 30)
								text.Color = State.ESP.NPCColor
								text.Size = 12
							end
						end
					end
				end
			end
			
			-- Item ESP
			if State.ESP.ItemESP then
				for _, data in ipairs(EntityCache.items) do
					local pos, onScreen = camera:WorldToViewportPoint(data.Position)
					if onScreen then
						local text = getDrawing("text")
						if text then
							text.Text = "[Item] " .. data.Name
							text.Position = Vector2.new(pos.X, pos.Y)
							text.Color = State.ESP.ItemColor
							text.Size = 12
						end
					end
				end
			end
		end
		
		-- ══════════════════════════════════════════════════════════════
		-- MISC FEATURES
		-- ══════════════════════════════════════════════════════════════
		
		-- Anti AFK
		if State.Misc.AntiAFK then
			pcall(function()
				local virtualUser = game:GetService("VirtualUser")
				virtualUser:CaptureController()
				virtualUser:ClickButton2(Vector2.new())
			end)
		end
	end)
	
	-- ══════════════════════════════════════════════════════════════
	-- INPUT HANDLING
	-- ══════════════════════════════════════════════════════════════
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		-- Infinite Jump
		if input.KeyCode == Enum.KeyCode.Space then
			if State.Movement.InfiniteJump then
				local humanoid = getHumanoid()
				if humanoid then
					humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end
			
			-- Long Jump
			if State.Movement.LongJump then
				local root = getRoot()
				if root then
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = camera.CFrame.LookVector * State.Movement.LongJumpForce + Vector3.new(0, 50, 0)
					bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					bodyVelocity.Parent = root
					Debris:AddItem(bodyVelocity, 0.2)
				end
			end
		end
		
		-- Dash (Q key)
		if input.KeyCode == Enum.KeyCode.Q and State.Movement.Dash then
			local now = tick()
			if now - LastDashTime >= State.Movement.DashCooldown then
				LastDashTime = now
				local root = getRoot()
				if root then
					local bodyVelocity = Instance.new("BodyVelocity")
					bodyVelocity.Velocity = camera.CFrame.LookVector * State.Movement.DashForce
					bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					bodyVelocity.Parent = root
					Debris:AddItem(bodyVelocity, 0.15)
				end
			end
		end
		
		-- Click TP
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if State.Movement.ClickTP then
				local root = getRoot()
				if root and mouse.Hit then
					root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
				end
			end
			
			-- Delete Mode
			if State.World.DeleteMode then
				local target = mouse.Target
				if target and not target:IsDescendantOf(player.Character or {}) then
					target:Destroy()
				end
			end
		end
	end)
	
	-- Freecam Mouse Movement
	UIS.InputChanged:Connect(function(input)
		if State.Visuals.Freecam and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UIS:GetMouseDelta()
			FreecamAngles = Vector2.new(
				math.clamp(FreecamAngles.X - delta.Y * 0.5, -80, 80),
				FreecamAngles.Y - delta.X * 0.5
			)
		end
	end)
	
	-- Chat Commands
	player.Chatted:Connect(function(message)
		local lowerMsg = message:lower()
		
		-- Target command
		if lowerMsg:sub(1, 8) == "/target " then
			local targetName = message:sub(9)
			State.Troll.AnnoyTarget = targetName
			State.Troll.OrbitTarget = targetName
		end
		
		-- Spam message command
		if lowerMsg:sub(1, 6) == "/spam " then
			State.Misc.ChatSpamMessage = message:sub(7)
		end
	end)
	
	-- ══════════════════════════════════════════════════════════════
	-- GUI COLORS
	-- ══════════════════════════════════════════════════════════════
	local Colors = {
		Background = Color3.fromRGB(12, 12, 18),
		Panel = Color3.fromRGB(18, 18, 26),
		Surface = Color3.fromRGB(22, 22, 32),
		ContentBg = Color3.fromRGB(16, 16, 24),
		ScrollBg = Color3.fromRGB(14, 14, 20),
		Accent = Color3.fromRGB(60, 120, 255),
		Text = Color3.fromRGB(220, 220, 240),
		TextDim = Color3.fromRGB(120, 120, 140),
		Border = Color3.fromRGB(40, 45, 60)
	}
	
	-- ══════════════════════════════════════════════════════════════
	-- GUI CREATION
	-- ══════════════════════════════════════════════════════════════
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "VertexHub"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = player:WaitForChild("PlayerGui")
	
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 950, 0, 650)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.BackgroundColor3 = Colors.Background
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.Visible = false
	mainFrame.Parent = screenGui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 10)
	mainCorner.Parent = mainFrame
	
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Colors.Border
	mainStroke.Thickness = 2
	mainStroke.Parent = mainFrame
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 45)
	header.BackgroundColor3 = Colors.Panel
	header.BorderSizePixel = 0
	header.Parent = mainFrame
	
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(0, 300, 1, 0)
	titleLabel.Position = UDim2.new(0, 15, 0, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "VERTEX HUB"
	titleLabel.TextColor3 = Colors.Text
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 18
	titleLabel.Parent = header
	
	local accentLine = Instance.new("Frame")
	accentLine.Size = UDim2.new(0, 60, 0, 3)
	accentLine.Position = UDim2.new(0, 15, 1, -3)
	accentLine.BackgroundColor3 = Colors.Accent
	accentLine.BorderSizePixel = 0
	accentLine.Parent = header
	
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = accentLine
	
	-- Close Button
	local closeButton = Instance.new("TextButton")
	closeButton.Size = UDim2.new(0, 30, 0, 30)
	closeButton.Position = UDim2.new(1, -40, 0.5, 0)
	closeButton.AnchorPoint = Vector2.new(0, 0.5)
	closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	closeButton.Text = "×"
	closeButton.TextColor3 = Colors.Text
	closeButton.Font = Enum.Font.GothamBold
	closeButton.TextSize = 20
	closeButton.AutoButtonColor = false
	closeButton.Parent = header
	
	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeButton
	
	closeButton.MouseButton1Click:Connect(function()
		mainFrame.Visible = false
		UIS.MouseBehavior = PreviousMouseState.behavior or Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = PreviousMouseState.icon ~= false
	end)
	
	closeButton.MouseEnter:Connect(function()
		closeButton.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
	end)
	
	closeButton.MouseLeave:Connect(function()
		closeButton.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	end)
	
	-- Tab Bar
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, 0, 0, 45)
	tabBar.Position = UDim2.new(0, 0, 0, 45)
	tabBar.BackgroundColor3 = Colors.Surface
	tabBar.BorderSizePixel = 0
	tabBar.Parent = mainFrame
	
	Tabs.setupTabBar(tabBar)
	
	-- Content Area
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, 0, 1, -90)
	contentArea.Position = UDim2.new(0, 0, 0, 90)
	contentArea.BackgroundColor3 = Colors.ContentBg
	contentArea.BorderSizePixel = 0
	contentArea.Parent = mainFrame
	
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -20, 1, -12)
	contentContainer.Position = UDim2.new(0, 10, 0, 6)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = contentArea
Area
	
	-- Tab Content Creator Function
	local function createTabContent(name)
		local scrollFrame = Instance.new("ScrollingFrame")
		scrollFrame.Name = name
		scrollFrame.Size = UDim2.new(1, 0, 1, 0)
		scrollFrame.BackgroundColor3 = Colors.ScrollBg
		scrollFrame.BackgroundTransparency = 0
		scrollFrame.BorderSizePixel = 0
		scrollFrame.ScrollBarThickness = 4
		scrollFrame.ScrollBarImageColor3 = Colors.Accent
		scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
		scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scrollFrame.Visible = false
		scrollFrame.Parent = contentContainer
		
		local listLayout = Instance.new("UIListLayout")
		listLayout.Padding = UDim.new(0, 6)
		listLayout.SortOrder = Enum.SortOrder.LayoutOrder
		listLayout.Parent = scrollFrame
		
		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 4)
		padding.PaddingBottom = UDim.new(0, 8)
		padding.PaddingLeft = UDim.new(0, 4)
		padding.PaddingRight = UDim.new(0, 8)
		padding.Parent = scrollFrame
		
		return scrollFrame
	end
	
	-- Create All Tab Contents
	local combatContent = createTabContent("Combat")
	local movementContent = createTabContent("Movement")
	local espContent = createTabContent("ESP")
	local visualsContent = createTabContent("Visuals")
	local worldContent = createTabContent("World")
	local playerContent = createTabContent("Player")
	local trollContent = createTabContent("Troll")
	local miscContent = createTabContent("Misc")
	
	-- Create Tab Buttons
	local combatTab = Tabs.create(tabBar, "Combat", "🎯")
	local movementTab = Tabs.create(tabBar, "Move", "🏃")
	local espTab = Tabs.create(tabBar, "ESP", "👁")
	local visualsTab = Tabs.create(tabBar, "Visual", "🎨")
	local worldTab = Tabs.create(tabBar, "World", "🌍")
	local playerTab = Tabs.create(tabBar, "Player", "👤")
	local trollTab = Tabs.create(tabBar, "Troll", "🎭")
	local miscTab = Tabs.create(tabBar, "Misc", "⚙")
	
	-- Connect Tabs
	Tabs.connectTab(combatTab, combatContent)
	Tabs.connectTab(movementTab, movementContent)
	Tabs.connectTab(espTab, espContent)
	Tabs.connectTab(visualsTab, visualsContent)
	Tabs.connectTab(worldTab, worldContent)
	Tabs.connectTab(playerTab, playerContent)
	Tabs.connectTab(trollTab, trollContent)
	Tabs.connectTab(miscTab, miscContent)
	
	-- COMBAT TAB
	Components.createSection(combatContent, "Aim Assist")
	Components.createToggle(combatContent, "Aim Assist", function(state) State.Combat.AimAssist = state end)
	Components.createSlider(combatContent, "Smoothness", 1, 100, 15, function(value) State.Combat.AimSmoothness = value / 200 end)
	Components.createSlider(combatContent, "FOV", 50, 600, 150, function(value) State.Combat.AimFOV = value end)
	Components.createToggle(combatContent, "Show FOV Circle", function(state) State.Combat.ShowFOVCircle = state end)
	Components.createToggle(combatContent, "Prediction", function(state) State.Combat.AimPrediction = state end)
	Components.createSlider(combatContent, "Prediction Amount", 1, 50, 10, function(value) State.Combat.PredictionAmount = value / 100 end)
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Silent Aim")
	Components.createToggle(combatContent, "Silent Aim", function(state) State.Combat.SilentAim = state end)
	Components.createSlider(combatContent, "Hit Chance", 0, 100, 100, function(value) State.Combat.SilentAimHitChance = value end)
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Kill Aura")
	Components.createToggle(combatContent, "Kill Aura", function(state) State.Combat.KillAura = state end)
	Components.createSlider(combatContent, "Range", 5, 50, 15, function(value) State.Combat.KillAuraRange = value end)
	Components.createSlider(combatContent, "CPS", 1, 20, 10, function(value) State.Combat.KillAuraCPS = value end)
	Components.createToggle(combatContent, "Target Players", function(state) State.Combat.KillAuraTargetPlayers = state end)
	Components.createToggle(combatContent, "Target NPCs", function(state) State.Combat.KillAuraTargetNPCs = state end)
	Components.createToggle(combatContent, "Wall Check", function(state) State.Combat.KillAuraWallCheck = state end)
	Components.createToggle(combatContent, "Legit Mode", function(state) State.Combat.KillAuraLegitMode = state end)
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Reach")
	Components.createToggle(combatContent, "Reach", function(state) State.Combat.Reach = state end)
	Components.createSlider(combatContent, "Reach Distance", 10, 30, 18, function(value) State.Combat.ReachDistance = value end)
	Components.createToggle(combatContent, "Reach Legit Mode", function(state) State.Combat.ReachLegitMode = state end)
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Auto Features")
	Components.createToggle(combatContent, "Triggerbot", function(state) State.Combat.Triggerbot = state end)
	Components.createSlider(combatContent, "Trigger Delay", 1, 50, 10, function(value) State.Combat.TriggerbotDelay = value / 100 end)
	Components.createToggle(combatContent, "Auto Parry", function(state) State.Combat.AutoParry = state end)
	Components.createToggle(combatContent, "Auto Combo", function(state) State.Combat.AutoCombo = state end)
	Components.createToggle(combatContent, "Auto Block", function(state) State.Combat.AutoBlock = state end)
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Exploits")
	Components.createToggle(combatContent, "Hitbox Expander", function(state) State.Combat.HitboxExpander = state end)
	Components.createSlider(combatContent, "Hitbox Size", 1, 20, 5, function(value) State.Combat.HitboxSize = value end)
	Components.createToggle(combatContent, "Backtrack", function(state) State.Combat.Backtrack = state end)
	Components.createSlider(combatContent, "Backtrack Time", 1, 50, 20, function(value) State.Combat.BacktrackTime = value / 100 end)
	Components.createToggle(combatContent, "Target Strafe", function(state) State.Combat.TargetStrafe = state end)
	Components.createSlider(combatContent, "Strafe Speed", 1, 20, 5, function(value) State.Combat.TargetStrafeSpeed = value end)
	Components.createSlider(combatContent, "Strafe Radius", 5, 30, 10, function(value) State.Combat.TargetStrafeRadius = value end)
	Components.createToggle(combatContent, "Anti Aim", function(state) State.Combat.AntiAim = state end)
	
	-- MOVEMENT TAB
	Components.createSection(movementContent, "Flight")
	Components.createToggle(movementContent, "Fly", function(state) State.Movement.Fly = state end)
	Components.createSlider(movementContent, "Fly Speed", 10, 300, 50, function(value) State.Movement.FlySpeed = value end)
	Components.createToggle(movementContent, "Fly Legit Mode", function(state) State.Movement.FlyLegitMode = state end)
	Components.createToggle(movementContent, "Noclip", function(state) State.Movement.Noclip = state end)
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Speed & Jump")
	Components.createToggle(movementContent, "Speed", function(state) State.Movement.Speed = state if not state then local h = getHumanoid() if h then h.WalkSpeed = 16 end end end)
	Components.createSlider(movementContent, "Speed Value", 16, 500, 16, function(value) State.Movement.SpeedValue = value end)
	Components.createToggle(movementContent, "Speed Legit Mode", function(state) State.Movement.SpeedLegitMode = state end)
	Components.createToggle(movementContent, "Jump Power", function(state) State.Movement.JumpPower = state if not state then local h = getHumanoid() if h then h.JumpPower = 50 end end end)
	Components.createSlider(movementContent, "Jump Value", 50, 500, 50, function(value) State.Movement.JumpPowerValue = value end)
	Components.createToggle(movementContent, "Infinite Jump", function(state) State.Movement.InfiniteJump = state end)
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Special Movement")
	Components.createToggle(movementContent, "Bunny Hop", function(state) State.Movement.BunnyHop = state end)
	Components.createToggle(movementContent, "Long Jump (Space)", function(state) State.Movement.LongJump = state end)
	Components.createSlider(movementContent, "Long Jump Force", 50, 400, 100, function(value) State.Movement.LongJumpForce = value end)
	Components.createToggle(movementContent, "Speed Glide", function(state) State.Movement.SpeedGlide = state end)
	Components.createSlider(movementContent, "Glide Speed", 1, 50, 10, function(value) State.Movement.SpeedGlideValue = value end)
	Components.createToggle(movementContent, "Dash (Q)", function(state) State.Movement.Dash = state end)
	Components.createSlider(movementContent, "Dash Force", 50, 300, 100, function(value) State.Movement.DashForce = value end)
	Components.createSlider(movementContent, "Dash Cooldown", 1, 50, 10, function(value) State.Movement.DashCooldown = value / 10 end)
	Components.createToggle(movementContent, "Air Control", function(state) State.Movement.AirControl = state end)
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Teleport & Safety")
	Components.createToggle(movementContent, "Click TP", function(state) State.Movement.ClickTP = state end)
	Components.createToggle(movementContent, "Anti Void", function(state) State.Movement.AntiVoid = state end)
	Components.createSlider(movementContent, "Void Height", -500, 0, -100, function(value) State.Movement.AntiVoidHeight = value end)
	Components.createToggle(movementContent, "Anchor", function(state) State.Movement.Anchor = state end)
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Exploits")
	Components.createToggle(movementContent, "Spin Bot", function(state) State.Movement.SpinBot = state end)
	Components.createSlider(movementContent, "Spin Speed", 1, 50, 20, function(value) State.Movement.SpinBotSpeed = value end)
	Components.createToggle(movementContent, "Fake Lag", function(state) State.Movement.FakeLag = state end)
	Components.createSlider(movementContent, "Lag Intensity", 1, 10, 5, function(value) State.Movement.FakeLagIntensity = value end)
	
	-- ESP TAB
	Components.createSection(espContent, "Player ESP")
	Components.createToggle(espContent, "Name ESP", function(state) State.ESP.NameESP = state end)
	Components.createToggle(espContent, "Box ESP", function(state) State.ESP.BoxESP = state end)
	Components.createToggle(espContent, "Health ESP", function(state) State.ESP.HealthESP = state end)
	Components.createToggle(espContent, "Distance ESP", function(state) State.ESP.DistanceESP = state end)
	Components.createToggle(espContent, "Tracers", function(state) State.ESP.Tracers = state end)
	Components.createToggle(espContent, "Skeleton ESP", function(state) State.ESP.SkeletonESP = state end)
	Components.createToggle(espContent, "Offscreen Arrows", function(state) State.ESP.OffscreenArrows = state end)
	Components.createDivider(espContent)
	Components.createSection(espContent, "World ESP")
	Components.createToggle(espContent, "NPC ESP", function(state) State.ESP.NPCESP = state end)
	Components.createToggle(espContent, "Item ESP", function(state) State.ESP.ItemESP = state end)
	Components.createDivider(espContent)
	Components.createSection(espContent, "Highlights")
	Components.createToggle(espContent, "Chams", function(state) State.ESP.Chams = state updateChams() end)
	Components.createDivider(espContent)
	Components.createSection(espContent, "Settings")
	Components.createSlider(espContent, "Max Distance", 100, 2000, 1000, function(value) State.ESP.MaxDistance = value end)
	Components.createToggle(espContent, "Team Check", function(state) State.ESP.TeamCheck = state end)
	Components.createToggle(espContent, "Friend Check", function(state) State.ESP.FriendCheck = state end)
	
	-- VISUALS TAB
	Components.createSection(visualsContent, "Lighting")
	Components.createToggle(visualsContent, "Fullbright", function(state) State.Visuals.Fullbright = state if state then Lighting.Ambient = Color3.new(1,1,1) Lighting.Brightness = 2 Lighting.OutdoorAmbient = Color3.new(1,1,1) else Lighting.Ambient = OriginalValues.Ambient Lighting.Brightness = OriginalValues.Brightness Lighting.OutdoorAmbient = OriginalValues.OutdoorAmbient end end)
	Components.createToggle(visualsContent, "No Fog", function(state) State.Visuals.NoFog = state if state then Lighting.FogEnd = 1e10 Lighting.FogStart = 1e10 else Lighting.FogEnd = OriginalValues.FogEnd Lighting.FogStart = OriginalValues.FogStart end end)
	Components.createToggle(visualsContent, "No Shadows", function(state) State.Visuals.NoShadows = state Lighting.GlobalShadows = not state end)
	Components.createDivider(visualsContent)
	Components.createSection(visualsContent, "Crosshair")
	Components.createToggle(visualsContent, "Custom Crosshair", function(state) State.Visuals.CustomCrosshair = state end)
	Components.createSlider(visualsContent, "Crosshair Size", 5, 50, 10, function(value) State.Visuals.CrosshairSize = value end)
	Components.createSlider(visualsContent, "Crosshair Gap", 0, 20, 5, function(value) State.Visuals.CrosshairGap = value end)
	Components.createDivider(visualsContent)
	Components.createSection(visualsContent, "Camera")
	Components.createSlider(visualsContent, "Camera FOV", 30, 120, 70, function(value) State.Visuals.CameraFOV = value camera.FieldOfView = value end)
	Components.createToggle(visualsContent, "Third Person", function(state) State.Visuals.ThirdPerson = state player.CameraMaxZoomDistance = state and 100 or 128 player.CameraMinZoomDistance = state and 15 or 0.5 end)
	Components.createToggle(visualsContent, "Freecam", function(state) State.Visuals.Freecam = state if state then FreecamPosition = camera.CFrame.Position UIS.MouseBehavior = Enum.MouseBehavior.LockCenter else camera.CameraType = Enum.CameraType.Custom UIS.MouseBehavior = Enum.MouseBehavior.Default end end)
	Components.createSlider(visualsContent, "Freecam Speed", 1, 20, 1, function(value) State.Visuals.FreecamSpeed = value end)
	Components.createDivider(visualsContent)
	Components.createSection(visualsContent, "World Visuals")
	Components.createToggle(visualsContent, "X-Ray", function(state) State.Visuals.XRay = state end)
	Components.createSlider(visualsContent, "X-Ray Transparency", 0, 100, 50, function(value) State.Visuals.XRayTransparency = value / 100 end)
	
	-- WORLD TAB
	Components.createSection(worldContent, "Environment")
	Components.createSlider(worldContent, "Time of Day", 0, 24, 14, function(value) State.World.TimeOfDay = value Lighting.ClockTime = value end)
	Components.createSlider(worldContent, "Gravity", 0, 500, 196, function(value) State.World.Gravity = value workspace.Gravity = value end)
	Components.createDivider(worldContent)
	Components.createSection(worldContent, "Terrain")
	Components.createToggle(worldContent, "Remove Grass", function(state) State.World.RemoveGrass = state local t = workspace:FindFirstChildOfClass("Terrain") if t then t.Decoration = not state end for _, o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and (o.Name:lower():find("grass") or o.Name:lower():find("foliage")) then o.Transparency = state and 1 or 0 end end end)
	Components.createDivider(worldContent)
	Components.createSection(worldContent, "Tools")
	Components.createToggle(worldContent, "Delete Mode (Click)", function(state) State.World.DeleteMode = state end)
	
	-- PLAYER TAB
	Components.createSection(playerContent, "Character")
	Components.createToggle(playerContent, "God Mode", function(state) State.Player.GodMode = state end)
	Components.createToggle(playerContent, "No Ragdoll", function(state) State.Player.NoRagdoll = state end)
	Components.createToggle(playerContent, "Auto Respawn", function(state) State.Player.AutoRespawn = state end)
	Components.createSlider(playerContent, "Character Scale", 50, 200, 100, function(value) State.Player.CharacterScale = value / 100 end)
	Components.createDivider(playerContent)
	Components.createSection(playerContent, "Invisibility (Hitbox-Only)")
	Components.createToggle(playerContent, "Invisibility", function(state) State.Player.Invisibility = state if state then InvisibilitySystem:Enable() else InvisibilitySystem:Disable() end end)
	Components.createSlider(playerContent, "Invis Offset", 50, 500, 100, function(value) State.Player.InvisibilityOffset = value end)
	Components.createDivider(playerContent)
	Components.createSection(playerContent, "Weapon")
	Components.createToggle(playerContent, "No Recoil", function(state) State.Player.NoRecoil = state end)
	Components.createToggle(playerContent, "No Spread", function(state) State.Player.NoSpread = state end)
	Components.createToggle(playerContent, "Infinite Stamina", function(state) State.Player.InfiniteStamina = state end)
	Components.createToggle(playerContent, "Infinite Ammo", function(state) State.Player.InfiniteAmmo = state end)
	Components.createToggle(playerContent, "Rapid Fire", function(state) State.Player.RapidFire = state end)
	
	-- TROLL TAB
	Components.createSection(trollContent, "Follow / Orbit")
	Components.createToggle(trollContent, "Annoy Player", function(state) State.Troll.AnnoyPlayer = state end)
	Components.createToggle(trollContent, "Orbit Player", function(state) State.Troll.OrbitPlayer = state end)
	Components.createSlider(trollContent, "Orbit Radius", 5, 30, 10, function(value) State.Troll.OrbitRadius = value end)
	Components.createSlider(trollContent, "Orbit Speed", 1, 10, 2, function(value) State.Troll.OrbitSpeed = value end)
	Components.createDivider(trollContent)
	Components.createSection(trollContent, "Character Troll")
	Components.createToggle(trollContent, "Fling", function(state) State.Troll.Fling = state end)
	Components.createSlider(trollContent, "Fling Power", 100, 1000, 500, function(value) State.Troll.FlingPower = value end)
	Components.createToggle(trollContent, "Headless", function(state) State.Troll.Headless = state end)
	Components.createToggle(trollContent, "Invisible Body", function(state) State.Troll.InvisibleBody = state end)
	Components.createDivider(trollContent)
	Components.createSection(trollContent, "Info")
	Components.createLabel(trollContent, "Type /target [name] in chat")
	
	-- MISC TAB
	Components.createSection(miscContent, "HUD Elements")
	Components.createToggle(miscContent, "Watermark", function(state) State.Misc.Watermark = state end)
	Components.createToggle(miscContent, "FPS Counter", function(state) State.Misc.FPSCounter = state end)
	Components.createToggle(miscContent, "Ping Display", function(state) State.Misc.PingDisplay = state end)
	Components.createToggle(miscContent, "Player Count", function(state) State.Misc.PlayerCount = state end)
	Components.createToggle(miscContent, "Velocity Display", function(state) State.Misc.VelocityDisplay = state end)
	Components.createToggle(miscContent, "Target Info", function(state) State.Misc.TargetInfo = state end)
	Components.createToggle(miscContent, "Keybinds Display", function(state) State.Misc.KeybindsDisplay = state end)
	Components.createDivider(miscContent)
	Components.createSection(miscContent, "Utility")
	Components.createToggle(miscContent, "Anti AFK", function(state) State.Misc.AntiAFK = state end)
	Components.createToggle(miscContent, "Chat Spam", function(state) State.Misc.ChatSpam = state end)
	Components.createSlider(miscContent, "Spam Delay", 1, 10, 2, function(value) State.Misc.ChatSpamDelay = value end)
	Components.createDivider(miscContent)
	Components.createSection(miscContent, "Server")
	Components.createToggle(miscContent, "Server Hop", function(state) if state then pcall(function() local s = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) for _, srv in ipairs(s.data) do if srv.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id) break end end end) end end)
	Components.createToggle(miscContent, "Rejoin", function(state) if state then TeleportService:Teleport(game.PlaceId) end end)
	
	Tabs.activate(combatTab, combatContent)
	
	-- MENU TOGGLE
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == State.Settings.MenuKey then
			local show = not mainFrame.Visible
			mainFrame.Visible = show
			if show then
				PreviousMouseState.behavior = UIS.MouseBehavior
				PreviousMouseState.icon = UIS.MouseIconEnabled
				UIS.MouseBehavior = Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = true
				mainFrame.Size = UDim2.new(0, 0, 0, 0)
				Animations.tween(mainFrame, {Size = UDim2.new(0, 950, 0, 650)}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
			else
				UIS.MouseBehavior = PreviousMouseState.behavior or Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = PreviousMouseState.icon ~= false
			end
		end
	end)
	
	-- DRAGGING
	local dragging, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(inp) if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true dragStart = inp.Position startPos = mainFrame.Position inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end) end end)
	UIS.InputChanged:Connect(function(inp) if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then local d = inp.Position - dragStart mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y) end end)
	
	-- CHARACTER EVENTS
	player.CharacterAdded:Connect(function(c) task.wait(0.5) local h = c:FindFirstChildOfClass("Humanoid") if h then if State.Movement.Speed then h.WalkSpeed = State.Movement.SpeedValue end if State.Movement.JumpPower then h.JumpPower = State.Movement.JumpPowerValue end end if State.ESP.Chams then updateChams() end if State.Player.Invisibility then task.wait(0.2) InvisibilitySystem:Enable() end end)
	Players.PlayerAdded:Connect(function() task.wait(1) if State.ESP.Chams then updateChams() end end)
	Players.PlayerRemoving:Connect(function(p) EntityCache.players[p.Name] = nil BacktrackPositions[p.Name] = nil end)
	
	print("[Vertex Hub] Loaded! Press M to toggle | 8 Tabs | 100+ Features")
end
