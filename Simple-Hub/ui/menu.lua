-- ---------------------------------------------------------------------------
-- VERTEX HUB - FULLY LOADSTRING COMPATIBLE
-- No require(), No script.Parent, No undefined dependencies
-- ---------------------------------------------------------------------------

return function(arg1, arg2, arg3)
	-- Handle both: func({Tabs=..., Components=..., Animations=...}) AND func(Tabs, Components, Animations)
	local Tabs, Components, Animations
	if type(arg1) == "table" and arg1.Tabs then
		Tabs = arg1.Tabs
		Components = arg1.Components
		Animations = arg1.Animations
	else
		Tabs = arg1
		Components = arg2
		Animations = arg3
	end
	Tabs = Tabs or _G.VertexTabs
	Components = Components or _G.VertexComponents
	Animations = Animations or _G.VertexAnimations
	
	-- ---------------------------------------------------------------------------
	-- BUILT-IN: Tabs, Components, Animations (no external deps needed)
	-- ---------------------------------------------------------------------------
	
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
	-- UTILITY FUNCTIONS
	-- ---------------------------------------------------------------------------
	local function getCharacter() return player.Character end
	local function getRoot() local c = getCharacter() return c and c:FindFirstChild("HumanoidRootPart") end
	local function getHumanoid() local c = getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end
	local function getHead() local c = getCharacter() return c and c:FindFirstChild("Head") end
	local function getTool() local c = getCharacter() return c and c:FindFirstChildOfClass("Tool") end
	
	-- Simple tween function (fallback if Animations not provided)
	local function tween(obj, props, tweenInfo)
		if not obj then return end
		tweenInfo = tweenInfo or {}
		local ti = TweenInfo.new(
			tweenInfo.Time or 0.2,
			tweenInfo.Style or Enum.EasingStyle.Quad,
			tweenInfo.Direction or Enum.EasingDirection.Out
		)
		local t = TweenService:Create(obj, ti, props)
		t:Play()
		return t
	end
	
	-- Use provided Animations or fallback
	if not Animations then
		Animations = { tween = tween }
	end
	_G.VertexAnimations = Animations
	_G.VertexTween = tween -- Expose globally for UI components
	
	-- ---------------------------------------------------------------------------
	-- ENTITY CACHE (Updated every 0.5s, not every frame)
	-- ---------------------------------------------------------------------------
	local EntityCache = { players = {}, npcs = {}, items = {} }
	
	local function updateEntityCache()
		-- Clean dead player entries
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
		
		-- Update NPCs
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
		
		-- Update Items
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
	-- CHECK IF DRAWING API EXISTS
	-- ---------------------------------------------------------------------------
	local DrawingEnabled = false
	local DrawingTest = nil
	pcall(function()
		DrawingTest = Drawing.new("Line")
		if DrawingTest then
			DrawingTest:Remove()
			DrawingEnabled = true
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- FIXED DRAWING OBJECT POOL (Wrapper table system - NO custom properties)
	-- ---------------------------------------------------------------------------
	local DrawingPool = { 
		text = {}, 
		square = {}, 
		line = {}, 
		triangle = {}, 
		circle = {} 
	}
	local ActiveDrawings = {}  -- Stores wrapper tables
	
	local function getDrawing(drawType)
		if not DrawingEnabled then return nil end
		local pool = DrawingPool[drawType]
		if not pool then return nil end
		
		-- Find an available wrapper
		for _, wrapper in ipairs(pool) do
			if not wrapper.inUse then
				wrapper.inUse = true
				wrapper.draw.Visible = true
				table.insert(ActiveDrawings, wrapper)
				return wrapper.draw
			end
		end
		
		-- Create new Drawing object with wrapper
		local newDraw = nil
		local ok = pcall(function()
			if drawType == "text" then
				newDraw = Drawing.new("Text")
				newDraw.Size = 14
				newDraw.Center = true
				newDraw.Outline = true
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
			end
		end)
		
		if ok and newDraw then
			local wrapper = {
				draw = newDraw,
				inUse = true,
				drawType = drawType
			}
			newDraw.Visible = true
			table.insert(pool, wrapper)
			table.insert(ActiveDrawings, wrapper)
			return newDraw
		end
		return nil
	end
	
	local function releaseAllDrawings()
		for _, wrapper in ipairs(ActiveDrawings) do
			if wrapper and wrapper.draw then 
				wrapper.draw.Visible = false 
				wrapper.inUse = false
			end
		end
		ActiveDrawings = {}
	end
	
	-- ---------------------------------------------------------------------------
	-- STATIC HUD DRAWINGS (Created once, reused)
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
	-- KEYBIND SYSTEM - GLOBAL
	-- ---------------------------------------------------------------------------
	local KeybindSystem = {
		binds = {},  -- featureName -> {keyCode, toggleFunction, displayName}
		enabled = true
	}
	
	function KeybindSystem:register(featureName, defaultKey, toggleFunc, displayName)
		self.binds[featureName] = {
			key = defaultKey,
			func = toggleFunc,
			display = displayName or featureName,
			active = false
		}
	end
	
	function KeybindSystem:setKey(featureName, newKey)
		if self.binds[featureName] then
			self.binds[featureName].key = newKey
			return true
		end
		return false
	end
	
	function KeybindSystem:getKey(featureName)
		return self.binds[featureName] and self.binds[featureName].key
	end
	
	function KeybindSystem:getDisplayText(featureName)
		local bind = self.binds[featureName]
		if not bind then return "" end
		return " [" .. tostring(bind.key.Name):gsub("^%l", string.upper) .. "]"
	end
	
	-- Listen for key presses
	UIS.InputBegan:Connect(function(input, gp)
		if gp or not KeybindSystem.enabled then return end
		
		for featureName, bind in pairs(KeybindSystem.binds) do
			if input.KeyCode == bind.key and bind.func then
				-- Toggle the feature
				bind.active = not bind.active
				bind.func(bind.active)
				break
			end
		end
	end)
	
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
	
	-- Register keybinds for all toggleable features
	KeybindSystem:register("AimAssist", Enum.KeyCode.C, function(state)
		State.Combat.AimAssist = state
		-- Update UI if needed
	end, "Aim Assist")
	
	KeybindSystem:register("KillAura", Enum.KeyCode.V, function(state)
		State.Combat.KillAura = state
	end, "Kill Aura")
	
	KeybindSystem:register("Fly", Enum.KeyCode.F, function(state)
		State.Movement.Fly = state
	end, "Fly")
	
	KeybindSystem:register("Noclip", Enum.KeyCode.N, function(state)
		State.Movement.Noclip = state
	end, "Noclip")
	
	KeybindSystem:register("Speed", Enum.KeyCode.Z, function(state)
		State.Movement.Speed = state
		if not state then
			local h = getHumanoid()
			if h then h.WalkSpeed = 16 end
		end
	end, "Speed")
	
	KeybindSystem:register("ESP", Enum.KeyCode.X, function(state)
		State.ESP.NameESP = state
		State.ESP.BoxESP = state
		State.ESP.HealthESP = state
	end, "ESP")
	
	KeybindSystem:register("SilentAim", Enum.KeyCode.B, function(state)
		State.Combat.SilentAim = state
	end, "Silent Aim")
	
	KeybindSystem:register("Triggerbot", Enum.KeyCode.T, function(state)
		State.Combat.Triggerbot = state
	end, "Triggerbot")
	
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
	-- INVISIBILITY SYSTEM (Transparency-based - WORKS PROPERLY)
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
		
		-- Store original transparencies and make invisible
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				self.originalTransparencies[part] = part.Transparency
				part.Transparency = 1
			elseif part:IsA("Decal") or part:IsA("Texture") then
				self.originalTransparencies[part] = part.Transparency
				part.Transparency = 1
			end
		end
		
		-- Hide accessories
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
		
		-- Restore original transparencies
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
	-- KILLAURA - SERVER VALIDATED (Per spec: modify reported position only)
	-- NO teleporting, NO spamming remotes, NO fake damage
	-- Hook the legitimate attack, modify reported self position
	-- ---------------------------------------------------------------------------
	local LEGIT_RANGE = 14.4 -- Default sword range
	local OriginalRemotes = {}
	local KillAuraHooked = false
	
	local function hookKillAura()
		if KillAuraHooked then return end
		if not hookmetamethod or not getnamecallmethod then return end
		KillAuraHooked = true
		
		-- Hook remote events that handle combat
		pcall(function()
			local oldNamecall
			oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}
				
				-- Hook FireServer for combat remotes
				if method == "FireServer" and State.Combat.KillAura then
					local remoteName = self.Name:lower()
					
					-- Common combat remote patterns
					if remoteName:find("attack") or remoteName:find("hit") or remoteName:find("damage") or remoteName:find("swing") then
						local myRoot = getRoot()
						local target = CurrentTarget
						
						if myRoot and target and target.RootPart then
							local distance = (myRoot.Position - target.RootPart.Position).Magnitude
							
							-- Only modify if target is within our extended range but outside legit range
							if distance <= State.Combat.KillAuraRange and distance > LEGIT_RANGE then
								-- Calculate the offset needed to make the attack valid
								local lookVector = (target.RootPart.Position - myRoot.Position).Unit
								local offsetDistance = math.max(distance - LEGIT_RANGE, 0)
								local reportedPosition = myRoot.Position + lookVector * offsetDistance
								
								-- Modify args if they contain position data
								for i, arg in ipairs(args) do
									if typeof(arg) == "Vector3" then
										args[i] = reportedPosition
									elseif typeof(arg) == "CFrame" then
										args[i] = CFrame.new(reportedPosition) * (arg - arg.Position)
									elseif typeof(arg) == "table" then
										-- Check for position in table
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
	
	-- Initialize hook
	-- DEFERRED: Hook after script fully loads
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
	
	-- DEFERRED: Initialize hooks after script fully loads
	task.defer(initSilentAimHooks)
	
	-- ---------------------------------------------------------------------------
	-- BACKGROUND LOOPS (Spawned once, not per-frame)
	-- ---------------------------------------------------------------------------
	
	-- Chat Spam (runs in background, respects delay)
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
	
	-- Auto Respawn (runs in background)
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
	-- CHAMS UPDATE (Called when needed, not every frame)
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
	-- SINGLE MAIN UPDATE LOOP (Per spec: ONE RenderStepped, not multiple)
	-- ---------------------------------------------------------------------------
	local lastCacheUpdate = 0
	
	RunService.RenderStepped:Connect(function(dt)
		camera = workspace.CurrentCamera
		local char = getCharacter()
		local root = getRoot()
		local hum = getHumanoid()
		
		-- Update cache every 0.5s (not every frame)
		if tick() - lastCacheUpdate > 0.5 then
			lastCacheUpdate = tick()
			updateEntityCache()
		end
		
		-- FPS counter
		FPSData.frames = FPSData.frames + 1
		if tick() - FPSData.lastTime >= 1 then
			FPSData.fps = FPSData.frames
			FPSData.frames = 0
			FPSData.lastTime = tick()
		end
		
		-- -----------------------------------------------------------------------
		-- MOVEMENT
		-- -----------------------------------------------------------------------
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
		
		-- -----------------------------------------------------------------------
		-- COMBAT
		-- -----------------------------------------------------------------------
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
		
		-- KillAura - respects CPS, uses validated position offset
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
					pcall(function() mouse1click() end)
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
							pcall(function() mouse2click() end)
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
		
		-- -----------------------------------------------------------------------
		-- PLAYER
		-- -----------------------------------------------------------------------
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
		
		-- -----------------------------------------------------------------------
		-- TROLL
		-- -----------------------------------------------------------------------
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
		
		-- -----------------------------------------------------------------------
		-- VISUALS
		-- -----------------------------------------------------------------------
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
		
		-- -----------------------------------------------------------------------
		-- HUD
		-- -----------------------------------------------------------------------
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
			HUD.Watermark.Text = "Vertex Hub" .. (State.Misc.KeybindsDisplay and " | Keybinds Active" or "")
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
			for featureName, bind in pairs(KeybindSystem.binds) do
				if bind.active then
					table.insert(k, bind.display .. " [" .. tostring(bind.key.Name):gsub("^%l", string.upper) .. "]")
				end
			end
			HUD.Keybinds.Text = "[Active Keybinds]\n" .. (#k > 0 and table.concat(k, "\n") or "None")
			HUD.Keybinds.Color = Color3.new(1, 1, 1)
		end
		
		-- -----------------------------------------------------------------------
		-- ESP RENDERING (Uses fixed pooled drawings)
		-- -----------------------------------------------------------------------
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
		
		-- -----------------------------------------------------------------------
		-- MISC
		-- -----------------------------------------------------------------------
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
	-- GUI COLORS
	-- ---------------------------------------------------------------------------
	local Colors = {
		Background = Color3.fromRGB(12, 12, 18),
		Panel = Color3.fromRGB(18, 18, 26),
		Surface = Color3.fromRGB(22, 22, 32),
		Content = Color3.fromRGB(16, 16, 24),
		Scroll = Color3.fromRGB(14, 14, 20),
		Accent = Color3.fromRGB(60, 120, 255),
		Text = Color3.fromRGB(220, 220, 240),
		Dim = Color3.fromRGB(120, 120, 140),
		Border = Color3.fromRGB(40, 45, 60),
		Btn = Color3.fromRGB(28, 30, 40),
		BtnHover = Color3.fromRGB(38, 42, 55),
		SliderBg = Color3.fromRGB(22, 24, 32)
	}
	
	-- ---------------------------------------------------------------------------
	-- BUILT-IN COMPONENTS (No external dependency)
	-- ---------------------------------------------------------------------------
	if not Components then
		Components = {}
		
		local function corner(o, r)
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, r or 6)
			c.Parent = o
		end
		local function stroke(o)
			local s = Instance.new("UIStroke")
			s.Color = Colors.Border
			s.Thickness = 1
			s.Transparency = 0.4
			s.Parent = o
		end
		
		function Components.createSection(parent, text)
			local f = Instance.new("Frame")
			f.Size = UDim2.new(1, -16, 0, 26)
			f.BackgroundTransparency = 1
			f.Parent = parent
			local line = Instance.new("Frame")
			line.Size = UDim2.new(0, 3, 0, 14)
			line.Position = UDim2.new(0, 0, 0.5, 0)
			line.AnchorPoint = Vector2.new(0, 0.5)
			line.BackgroundColor3 = Colors.Accent
			line.BorderSizePixel = 0
			line.Parent = f
			corner(line, 2)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -12, 1, 0)
			lbl.Position = UDim2.new(0, 10, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text:upper()
			lbl.TextColor3 = Colors.Text
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamBold
			lbl.TextSize = 10
			lbl.Parent = f
		end
		
		function Components.createDivider(parent)
			local d = Instance.new("Frame")
			d.Size = UDim2.new(1, -32, 0, 1)
			d.BackgroundColor3 = Colors.Border
			d.BorderSizePixel = 0
			d.BackgroundTransparency = 0.4
			d.Parent = parent
		end
		
		function Components.createLabel(parent, text)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -16, 0, 22)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = Colors.Dim
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.Gotham
			lbl.TextSize = 11
			lbl.TextWrapped = true
			lbl.Parent = parent
		end
		
		function Components.createToggle(parent, text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, -16, 0, 32)
			btn.BackgroundColor3 = Colors.Btn
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Text = ""
			btn.Parent = parent
			corner(btn)
			stroke(btn)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -50, 1, 0)
			lbl.Position = UDim2.new(0, 12, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = Colors.Dim
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextSize = 12
			lbl.Parent = btn
			local ind = Instance.new("Frame")
			ind.Size = UDim2.new(0, 0, 0, 2)
			ind.Position = UDim2.new(0, 0, 1, -2)
			ind.BackgroundColor3 = Colors.Accent
			ind.BorderSizePixel = 0
			ind.Parent = btn
			corner(ind, 1)
			local tbg = Instance.new("Frame")
			tbg.Size = UDim2.new(0, 34, 0, 18)
			tbg.Position = UDim2.new(1, -44, 0.5, 0)
			tbg.AnchorPoint = Vector2.new(0, 0.5)
			tbg.BackgroundColor3 = Colors.SliderBg
			tbg.BorderSizePixel = 0
			tbg.Parent = btn
			corner(tbg, 9)
			local tc = Instance.new("Frame")
			tc.Size = UDim2.new(0, 14, 0, 14)
			tc.Position = UDim2.new(0, 2, 0.5, 0)
			tc.AnchorPoint = Vector2.new(0, 0.5)
			tc.BackgroundColor3 = Colors.Dim
			tc.BorderSizePixel = 0
			tc.Parent = tbg
			corner(tc, 7)
			local state = false
			local function updateVisual()
				if state then
					if tween then
						tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 50, 80)})
						tween(lbl, {TextColor3 = Color3.new(1, 1, 1)})
						tween(ind, {Size = UDim2.new(1, 0, 0, 2)})
						tween(tbg, {BackgroundColor3 = Colors.Accent})
						tween(tc, {Position = UDim2.new(1, -16, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1)})
					end
				else
					if tween then
						tween(btn, {BackgroundColor3 = Colors.Btn})
						tween(lbl, {TextColor3 = Colors.Dim})
						tween(ind, {Size = UDim2.new(0, 0, 0, 2)})
						tween(tbg, {BackgroundColor3 = Colors.SliderBg})
						tween(tc, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Colors.Dim})
					end
				end
			end
			btn.MouseButton1Click:Connect(function()
				state = not state
				updateVisual()
				if callback then task.spawn(callback, state) end
			end)
			local toggleObject = {
				Button = btn,
				SetState = function(self, newState)
					if typeof(newState) ~= "boolean" then return end
					state = newState
					updateVisual()
				end,
				UpdateState = function(self, newState)
					if typeof(newState) ~= "boolean" then return end
					state = newState
					updateVisual()
					if callback then task.spawn(callback, state) end
				end,
				GetState = function(self)
					return state
				end
			}
			return toggleObject
		end
		
		function Components.createSlider(parent, text, min, max, default, callback)
			local cont = Instance.new("Frame")
			cont.Size = UDim2.new(1, -16, 0, 50)
			cont.BackgroundColor3 = Colors.Btn
			cont.BorderSizePixel = 0
			cont.Parent = parent
			corner(cont)
			stroke(cont)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(1, -60, 0, 18)
			lbl.Position = UDim2.new(0, 12, 0, 5)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = Colors.Dim
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextSize = 11
			lbl.Parent = cont
			local val = Instance.new("TextLabel")
			val.Size = UDim2.new(0, 48, 0, 18)
			val.Position = UDim2.new(1, -60, 0, 5)
			val.BackgroundTransparency = 1
			val.Text = tostring(default)
			val.TextColor3 = Colors.Accent
			val.TextXAlignment = Enum.TextXAlignment.Right
			val.Font = Enum.Font.GothamBold
			val.TextSize = 11
			val.Parent = cont
			local sbg = Instance.new("Frame")
			sbg.Size = UDim2.new(1, -24, 0, 6)
			sbg.Position = UDim2.new(0, 12, 1, -15)
			sbg.BackgroundColor3 = Colors.SliderBg
			sbg.BorderSizePixel = 0
			sbg.Parent = cont
			corner(sbg, 3)
			local fill = Instance.new("Frame")
			fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
			fill.BackgroundColor3 = Colors.Accent
			fill.BorderSizePixel = 0
			fill.Parent = sbg
			corner(fill, 3)
			local handle = Instance.new("Frame")
			handle.Size = UDim2.new(0, 14, 0, 14)
			handle.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
			handle.AnchorPoint = Vector2.new(0.5, 0.5)
			handle.BackgroundColor3 = Color3.fromRGB(100, 180, 255)
			handle.BorderSizePixel = 0
			handle.ZIndex = 2
			handle.Parent = sbg
			corner(handle, 7)
			local dragging = false
			local function upd(inp)
				local p = math.clamp((inp.Position.X - sbg.AbsolutePosition.X) / sbg.AbsoluteSize.X, 0, 1)
				local v = math.floor(min + (max - min) * p)
				val.Text = tostring(v)
				if tween then
					tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, {Time = 0.08})
					tween(handle, {Position = UDim2.new(p, 0, 0.5, 0)}, {Time = 0.08})
				end
				if callback then callback(v) end
			end
			sbg.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
					upd(i)
				end
			end)
			handle.InputBegan:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = true
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType == Enum.UserInputType.MouseButton1 then
					dragging = false
				end
			end)
			UIS.InputChanged:Connect(function(i)
				if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
					upd(i)
				end
			end)
			return cont
		end
	end
	_G.VertexComponents = Components
	
	-- ---------------------------------------------------------------------------
	-- BUILT-IN TABS WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	if not Tabs then
		Tabs = {}
		local tabButtons = {}
		local tabContents = {}
		local currentTab = nil
		
		function Tabs.setupTabBar(bar)
			local layout = Instance.new("UIListLayout")
			layout.FillDirection = Enum.FillDirection.Horizontal
			layout.Padding = UDim.new(0, 4)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = bar
			local pad = Instance.new("UIPadding")
			pad.PaddingLeft = UDim.new(0, 10)
			pad.PaddingTop = UDim.new(0, 8)
			pad.Parent = bar
		end
		
		function Tabs.create(bar, name, icon)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(0, 90, 0, 30)
			btn.BackgroundColor3 = Colors.Surface
			btn.BorderSizePixel = 0
			btn.AutoButtonColor = false
			btn.Text = (icon or "") .. " " .. name
			btn.TextColor3 = Colors.Dim
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 11
			btn.Parent = bar
			local c = Instance.new("UICorner")
			c.CornerRadius = UDim.new(0, 6)
			c.Parent = btn
			local ind = Instance.new("Frame")
			ind.Size = UDim2.new(0.6, 0, 0, 2)
			ind.Position = UDim2.new(0.2, 0, 1, -2)
			ind.BackgroundColor3 = Colors.Accent
			ind.BackgroundTransparency = 1
			ind.BorderSizePixel = 0
			ind.Parent = btn
			btn._indicator = ind
			table.insert(tabButtons, btn)
			return btn
		end
		
		function Tabs.connectTab(btn, content)
			table.insert(tabContents, {btn = btn, content = content})
			btn.MouseButton1Click:Connect(function()
				for _, tc in ipairs(tabContents) do
					tc.content.Visible = false
					tc.btn.TextColor3 = Colors.Dim
					tc.btn.BackgroundColor3 = Colors.Surface
					if tc.btn._indicator then tc.btn._indicator.BackgroundTransparency = 1 end
				end
				content.Visible = true
				btn.TextColor3 = Color3.new(1, 1, 1)
				btn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
				if btn._indicator then btn._indicator.BackgroundTransparency = 0 end
				currentTab = btn
			end)
		end
		
		function Tabs.activate(btn, content)
			for _, tc in ipairs(tabContents) do
				tc.content.Visible = false
				tc.btn.TextColor3 = Colors.Dim
				tc.btn.BackgroundColor3 = Colors.Surface
				if tc.btn._indicator then tc.btn._indicator.BackgroundTransparency = 1 end
			end
			content.Visible = true
			btn.TextColor3 = Color3.new(1, 1, 1)
			btn.BackgroundColor3 = Color3.fromRGB(35, 40, 55)
			if btn._indicator then btn._indicator.BackgroundTransparency = 0 end
			currentTab = btn
		end
		
		-- NEW: Expandable/Collapsible Section Creator
		function Tabs.createExpandableSection(parent, title, initialState)
			local sectionContainer = Instance.new("Frame")
			sectionContainer.Name = "Section_" .. (title or "Untitled")
			sectionContainer.Size = UDim2.new(1, -16, 0, 40)
			sectionContainer.BackgroundTransparency = 1
			sectionContainer.Parent = parent
			
			-- Header
			local header = Instance.new("TextButton")
			header.Size = UDim2.new(1, 0, 0, 40)
			header.BackgroundColor3 = Colors.Btn
			header.BorderSizePixel = 0
			header.AutoButtonColor = false
			header.Text = ""
			header.Parent = sectionContainer
			corner(header, 6)
			stroke(header)
			
			-- Icon (expands/collapses)
			local icon = Instance.new("TextLabel")
			icon.Size = UDim2.new(0, 24, 0, 24)
			icon.Position = UDim2.new(0, 10, 0.5, 0)
			icon.AnchorPoint = Vector2.new(0, 0.5)
			icon.BackgroundTransparency = 1
			icon.Text = "+"
			icon.TextColor3 = Colors.Accent
			icon.Font = Enum.Font.GothamBold
			icon.TextSize = 18
			icon.Parent = header
			
			-- Title
			local titleLabel = Instance.new("TextLabel")
			titleLabel.Size = UDim2.new(1, -60, 1, 0)
			titleLabel.Position = UDim2.new(0, 40, 0, 0)
			titleLabel.BackgroundTransparency = 1
			titleLabel.Text = title or "Section"
			titleLabel.TextColor3 = Colors.Text
			titleLabel.TextXAlignment = Enum.TextXAlignment.Left
			titleLabel.Font = Enum.Font.GothamMedium
			titleLabel.TextSize = 13
			titleLabel.Parent = header
			
			-- Content container (starts collapsed)
			local content = Instance.new("Frame")
			content.Name = "Content"
			content.Size = UDim2.new(1, 0, 0, 0)
			content.Position = UDim2.new(0, 0, 0, 45)
			content.BackgroundTransparency = 1
			content.ClipsDescendants = true
			content.Visible = false
			content.Parent = sectionContainer
			
			local contentInner = Instance.new("Frame")
			contentInner.Name = "Inner"
			contentInner.Size = UDim2.new(1, 0, 0, 0)
			contentInner.BackgroundTransparency = 1
			contentInner.Parent = content
			
			local layout = Instance.new("UIListLayout")
			layout.Padding = UDim.new(0, 6)
			layout.SortOrder = Enum.SortOrder.LayoutOrder
			layout.Parent = contentInner
			
			local pad = Instance.new("UIPadding")
			pad.PaddingTop = UDim.new(0, 8)
			pad.PaddingBottom = UDim.new(0, 8)
			pad.PaddingLeft = UDim.new(0, 5)
			pad.PaddingRight = UDim.new(0, 5)
			pad.Parent = contentInner
			
			local isOpen = initialState or false
			
			local function toggle()
				isOpen = not isOpen
				
				if isOpen then
					-- Expand
					content.Visible = true
					icon.Text = "×"
					
					-- Calculate total height
					local totalHeight = 8 + 8 + 4  -- padding top + bottom + extra
					for _, child in ipairs(contentInner:GetChildren()) do
						if child:IsA("GuiObject") and child.Visible then
							totalHeight = totalHeight + child.AbsoluteSize.Y
							if child:IsA("Frame") and child.Name == "Content" then
								-- Nested section
								for _, nested in ipairs(child:GetChildren()) do
									if nested:IsA("GuiObject") and nested.Visible then
										totalHeight = totalHeight + nested.AbsoluteSize.Y
									end
								end
							end
						end
					end
					
					totalHeight = totalHeight + (layout.Padding.Offset * (#contentInner:GetChildren() - 1))
					
					-- Animate expansion
					if tween then
						tween(content, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3)
						tween(sectionContainer, {Size = UDim2.new(1, -16, 0, 45 + totalHeight)}, 0.3)
						tween(header, {BackgroundColor3 = Color3.fromRGB(35, 40, 55)})
						tween(icon, {TextColor3 = Color3.new(1, 0.5, 0.5)})
					end
				else
					-- Collapse
					icon.Text = "+"
					if tween then
						tween(content, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
						tween(sectionContainer, {Size = UDim2.new(1, -16, 0, 40)}, 0.3)
						tween(header, {BackgroundColor3 = Colors.Btn})
						tween(icon, {TextColor3 = Colors.Accent})
						
						task.delay(0.3, function()
							content.Visible = false
						end)
					else
						content.Visible = false
						sectionContainer.Size = UDim2.new(1, -16, 0, 40)
						header.BackgroundColor3 = Colors.Btn
						icon.TextColor3 = Colors.Accent
					end
				end
			end
			
			header.MouseButton1Click:Connect(toggle)
			
			-- Hover effects
			header.MouseEnter:Connect(function()
				if tween then
					tween(header, {BackgroundColor3 = Color3.fromRGB(35, 38, 48)})
				end
			end)
			header.MouseLeave:Connect(function()
				if not isOpen and tween then
					tween(header, {BackgroundColor3 = Colors.Btn})
				end
			end)
			
			-- Open if initial state is true
			if initialState then
				task.delay(0.1, toggle)
			end
			
			return contentInner
		end
	end
	_G.VertexTabs = Tabs
	
	-- ---------------------------------------------------------------------------
	-- GUI CREATION
	-- ---------------------------------------------------------------------------
	local gui = Instance.new("ScreenGui")
	gui.Name = "VertexHub"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 1000, 0, 700)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Colors.Background
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Visible = false
	main.Parent = gui
	local mc = Instance.new("UICorner")
	mc.CornerRadius = UDim.new(0, 12)
	mc.Parent = main
	local ms = Instance.new("UIStroke")
	ms.Color = Colors.Border
	ms.Thickness = 2
	ms.Parent = main
	
	-- Header
	local hdr = Instance.new("Frame")
	hdr.Size = UDim2.new(1, 0, 0, 50)
	hdr.BackgroundColor3 = Colors.Panel
	hdr.BorderSizePixel = 0
	hdr.Parent = main
	local ttl = Instance.new("TextLabel")
	ttl.Size = UDim2.new(0, 300, 1, 0)
	ttl.Position = UDim2.new(0, 15, 0, 0)
	ttl.BackgroundTransparency = 1
	ttl.Text = "VERTEX HUB v2.0"
	ttl.TextColor3 = Colors.Text
	ttl.TextXAlignment = Enum.TextXAlignment.Left
	ttl.Font = Enum.Font.GothamBold
	ttl.TextSize = 20
	ttl.Parent = hdr
	local acc = Instance.new("Frame")
	acc.Size = UDim2.new(0, 80, 0, 3)
	acc.Position = UDim2.new(0, 15, 1, -3)
	acc.BackgroundColor3 = Colors.Accent
	acc.BorderSizePixel = 0
	acc.Parent = hdr
	local ac = Instance.new("UICorner")
	ac.CornerRadius = UDim.new(1, 0)
	ac.Parent = acc
	
	-- Close button
	local cls = Instance.new("TextButton")
	cls.Size = UDim2.new(0, 35, 0, 35)
	cls.Position = UDim2.new(1, -45, 0.5, 0)
	cls.AnchorPoint = Vector2.new(0, 0.5)
	cls.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	cls.Text = "✕"
	cls.TextColor3 = Colors.Text
	cls.Font = Enum.Font.GothamBold
	cls.TextSize = 22
	cls.AutoButtonColor = false
	cls.Parent = hdr
	local clc = Instance.new("UICorner")
	clc.CornerRadius = UDim.new(0, 8)
	clc.Parent = cls
	cls.MouseButton1Click:Connect(function()
		main.Visible = false
		UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default
		UIS.MouseIconEnabled = PrevMouseState.icon ~= false
	end)
	cls.MouseEnter:Connect(function() cls.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end)
	cls.MouseLeave:Connect(function() cls.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, 0, 0, 50)
	tabBar.Position = UDim2.new(0, 0, 0, 50)
	tabBar.BackgroundColor3 = Colors.Surface
	tabBar.BorderSizePixel = 0
	tabBar.Parent = main
	Tabs.setupTabBar(tabBar)
	
	-- Content
	local cArea = Instance.new("Frame")
	cArea.Size = UDim2.new(1, 0, 1, -100)
	cArea.Position = UDim2.new(0, 0, 0, 100)
	cArea.BackgroundColor3 = Colors.Content
	cArea.BorderSizePixel = 0
	cArea.Parent = main
	local cCont = Instance.new("ScrollingFrame")
	cCont.Size = UDim2.new(1, 0, 1, 0)
	cCont.BackgroundTransparency = 1
	cCont.ScrollBarThickness = 4
	cCont.ScrollBarImageColor3 = Colors.Accent
	cCont.CanvasSize = UDim2.new(0, 0, 0, 0)
	cCont.AutomaticCanvasSize = Enum.AutomaticSize.Y
	cCont.Parent = cArea
	
	local function makeTab(nm)
		local scr = Instance.new("ScrollingFrame")
		scr.Name = nm
		scr.Size = UDim2.new(1, 0, 1, 0)
		scr.BackgroundTransparency = 1
		scr.BorderSizePixel = 0
		scr.ScrollBarThickness = 4
		scr.ScrollBarImageColor3 = Colors.Accent
		scr.CanvasSize = UDim2.new(0, 0, 0, 0)
		scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scr.Visible = false
		scr.Parent = cCont
		local lay = Instance.new("UIListLayout")
		lay.Padding = UDim.new(0, 8)
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Parent = scr
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 8)
		pad.PaddingBottom = UDim.new(0, 8)
		pad.PaddingLeft = UDim.new(0, 8)
		pad.PaddingRight = UDim.new(0, 8)
		pad.Parent = scr
		return scr
	end
	
	local combatC = makeTab("Combat")
	local moveC = makeTab("Movement")
	local espC = makeTab("ESP")
	local visC = makeTab("Visuals")
	local worldC = makeTab("World")
	local playerC = makeTab("Player")
	local trollC = makeTab("Troll")
	local miscC = makeTab("Misc")
	
	local combatT = Tabs.create(tabBar, "Combat", "⚔️")
	local moveT = Tabs.create(tabBar, "Move", "🏃")
	local espT = Tabs.create(tabBar, "ESP", "👁️")
	local visT = Tabs.create(tabBar, "Visual", "🎨")
	local worldT = Tabs.create(tabBar, "World", "🌍")
	local playerT = Tabs.create(tabBar, "Player", "👤")
	local trollT = Tabs.create(tabBar, "Troll", "😈")
	local miscT = Tabs.create(tabBar, "Misc", "⚙️")
	
	Tabs.connectTab(combatT, combatC)
	Tabs.connectTab(moveT, moveC)
	Tabs.connectTab(espT, espC)
	Tabs.connectTab(visT, visC)
	Tabs.connectTab(worldT, worldC)
	Tabs.connectTab(playerT, playerC)
	Tabs.connectTab(trollT, trollC)
	Tabs.connectTab(miscT, miscC)
	
	-- ---------------------------------------------------------------------------
	-- COMBAT TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local aimSection = Tabs.createExpandableSection(combatC, "Aim Assist", false)
		Components.createToggle(aimSection, "Aim Assist" .. KeybindSystem:getDisplayText("AimAssist"), 
			function(v) 
				State.Combat.AimAssist = v 
				KeybindSystem.binds["AimAssist"].active = v
			end)
		Components.createSlider(aimSection, "Smoothness", 1, 100, 15, function(v) State.Combat.AimSmoothness = v / 200 end)
		Components.createSlider(aimSection, "FOV", 50, 600, 150, function(v) State.Combat.AimFOV = v end)
		Components.createToggle(aimSection, "Show FOV Circle", function(v) State.Combat.ShowFOVCircle = v end)
		Components.createToggle(aimSection, "Prediction", function(v) State.Combat.AimPrediction = v end)
		Components.createSlider(aimSection, "Prediction Amount", 1, 50, 10, function(v) State.Combat.PredictionAmount = v / 100 end)
		
		local silentSection = Tabs.createExpandableSection(combatC, "Silent Aim", false)
		Components.createToggle(silentSection, "Silent Aim" .. KeybindSystem:getDisplayText("SilentAim"), 
			function(v) 
				State.Combat.SilentAim = v 
				KeybindSystem.binds["SilentAim"].active = v
			end)
		Components.createSlider(silentSection, "Hit Chance", 0, 100, 100, function(v) State.Combat.SilentAimHitChance = v end)
		
		local auraSection = Tabs.createExpandableSection(combatC, "Kill Aura", false)
		Components.createToggle(auraSection, "Kill Aura" .. KeybindSystem:getDisplayText("KillAura"), 
			function(v) 
				State.Combat.KillAura = v 
				KeybindSystem.binds["KillAura"].active = v
			end)
		Components.createSlider(auraSection, "Range", 5, 50, 15, function(v) State.Combat.KillAuraRange = v end)
		Components.createSlider(auraSection, "CPS", 1, 20, 10, function(v) State.Combat.KillAuraCPS = v end)
		Components.createToggle(auraSection, "Target Players", function(v) State.Combat.KillAuraPlayers = v end)
		Components.createToggle(auraSection, "Target NPCs", function(v) State.Combat.KillAuraNPCs = v end)
		Components.createToggle(auraSection, "Wall Check", function(v) State.Combat.KillAuraWallCheck = v end)
		Components.createToggle(auraSection, "Legit Mode", function(v) State.Combat.KillAuraLegit = v end)
		
		local reachSection = Tabs.createExpandableSection(combatC, "Reach", false)
		Components.createToggle(reachSection, "Reach", function(v) State.Combat.Reach = v end)
		Components.createSlider(reachSection, "Reach Distance", 10, 30, 18, function(v) State.Combat.ReachDistance = v end)
		Components.createToggle(reachSection, "Reach Legit", function(v) State.Combat.ReachLegit = v end)
		
		local autoSection = Tabs.createExpandableSection(combatC, "Auto Features", false)
		Components.createToggle(autoSection, "Triggerbot" .. KeybindSystem:getDisplayText("Triggerbot"), 
			function(v) 
				State.Combat.Triggerbot = v 
				KeybindSystem.binds["Triggerbot"].active = v
			end)
		Components.createSlider(autoSection, "Trigger Delay", 1, 50, 10, function(v) State.Combat.TriggerbotDelay = v / 100 end)
		Components.createToggle(autoSection, "Auto Parry", function(v) State.Combat.AutoParry = v end)
		
		local exploitSection = Tabs.createExpandableSection(combatC, "Exploits", false)
		Components.createToggle(exploitSection, "Hitbox Expander", function(v) State.Combat.HitboxExpander = v end)
		Components.createSlider(exploitSection, "Hitbox Size", 1, 20, 5, function(v) State.Combat.HitboxSize = v end)
		Components.createToggle(exploitSection, "Backtrack", function(v) State.Combat.Backtrack = v end)
		Components.createSlider(exploitSection, "Backtrack Time", 1, 50, 20, function(v) State.Combat.BacktrackTime = v / 100 end)
		Components.createToggle(exploitSection, "Target Strafe", function(v) State.Combat.TargetStrafe = v end)
		Components.createSlider(exploitSection, "Strafe Speed", 1, 20, 5, function(v) State.Combat.StrafeSpeed = v end)
		Components.createSlider(exploitSection, "Strafe Radius", 5, 30, 10, function(v) State.Combat.StrafeRadius = v end)
	end
	
	-- ---------------------------------------------------------------------------
	-- MOVEMENT TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local flySection = Tabs.createExpandableSection(moveC, "Flight", false)
		Components.createToggle(flySection, "Fly" .. KeybindSystem:getDisplayText("Fly"), 
			function(v) 
				State.Movement.Fly = v 
				KeybindSystem.binds["Fly"].active = v
			end)
		Components.createSlider(flySection, "Fly Speed", 10, 300, 50, function(v) State.Movement.FlySpeed = v end)
		Components.createToggle(flySection, "Fly Legit", function(v) State.Movement.FlyLegit = v end)
		Components.createToggle(flySection, "Noclip" .. KeybindSystem:getDisplayText("Noclip"), 
			function(v) 
				State.Movement.Noclip = v 
				KeybindSystem.binds["Noclip"].active = v
			end)
		
		local speedSection = Tabs.createExpandableSection(moveC, "Speed & Jump", false)
		Components.createToggle(speedSection, "Speed" .. KeybindSystem:getDisplayText("Speed"), 
			function(v) 
				State.Movement.Speed = v 
				KeybindSystem.binds["Speed"].active = v
				if not v then
					local h = getHumanoid()
					if h then h.WalkSpeed = 16 end
				end
			end)
		Components.createSlider(speedSection, "Speed Value", 16, 500, 16, function(v) State.Movement.SpeedValue = v end)
		Components.createToggle(speedSection, "Speed Legit", function(v) State.Movement.SpeedLegit = v end)
		Components.createToggle(speedSection, "Jump Power", function(v)
			State.Movement.JumpPower = v
			if not v then
				local h = getHumanoid()
				if h then h.JumpPower = 50 end
			end
		end)
		Components.createSlider(speedSection, "Jump Value", 50, 500, 50, function(v) State.Movement.JumpValue = v end)
		Components.createToggle(speedSection, "Infinite Jump", function(v) State.Movement.InfiniteJump = v end)
		
		local specialSection = Tabs.createExpandableSection(moveC, "Special Movement", false)
		Components.createToggle(specialSection, "Bunny Hop", function(v) State.Movement.BunnyHop = v end)
		Components.createToggle(specialSection, "Long Jump (Space)", function(v) State.Movement.LongJump = v end)
		Components.createSlider(specialSection, "Long Jump Force", 50, 400, 100, function(v) State.Movement.LongJumpForce = v end)
		Components.createToggle(specialSection, "Speed Glide", function(v) State.Movement.SpeedGlide = v end)
		Components.createSlider(specialSection, "Glide Speed", 1, 50, 10, function(v) State.Movement.GlideSpeed = v end)
		Components.createToggle(specialSection, "Dash (Q)", function(v) State.Movement.Dash = v end)
		Components.createSlider(specialSection, "Dash Force", 50, 300, 100, function(v) State.Movement.DashForce = v end)
		Components.createSlider(specialSection, "Dash Cooldown", 1, 50, 10, function(v) State.Movement.DashCooldown = v / 10 end)
		Components.createToggle(specialSection, "Air Control", function(v) State.Movement.AirControl = v end)
		
		local tpSection = Tabs.createExpandableSection(moveC, "Teleport & Safety", false)
		Components.createToggle(tpSection, "Click TP", function(v) State.Movement.ClickTP = v end)
		Components.createToggle(tpSection, "Anti Void", function(v) State.Movement.AntiVoid = v end)
		Components.createSlider(tpSection, "Void Height", -500, 0, -100, function(v) State.Movement.VoidHeight = v end)
		Components.createToggle(tpSection, "Anchor", function(v) State.Movement.Anchor = v end)
		
		local exploitSection = Tabs.createExpandableSection(moveC, "Movement Exploits", false)
		Components.createToggle(exploitSection, "Spin Bot", function(v) State.Movement.SpinBot = v end)
		Components.createSlider(exploitSection, "Spin Speed", 1, 50, 20, function(v) State.Movement.SpinSpeed = v end)
		Components.createToggle(exploitSection, "Fake Lag", function(v) State.Movement.FakeLag = v end)
		Components.createSlider(exploitSection, "Lag Intensity", 1, 10, 5, function(v) State.Movement.LagIntensity = v end)
	end
	
	-- ---------------------------------------------------------------------------
	-- ESP TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local playerSection = Tabs.createExpandableSection(espC, "Player ESP", true)
		Components.createToggle(playerSection, "Name ESP", function(v) State.ESP.NameESP = v end)
		Components.createToggle(playerSection, "Box ESP", function(v) State.ESP.BoxESP = v end)
		Components.createToggle(playerSection, "Health ESP", function(v) State.ESP.HealthESP = v end)
		Components.createToggle(playerSection, "Distance ESP", function(v) State.ESP.DistanceESP = v end)
		Components.createToggle(playerSection, "Tracers", function(v) State.ESP.Tracers = v end)
		Components.createToggle(playerSection, "Skeleton ESP", function(v) State.ESP.SkeletonESP = v end)
		Components.createToggle(playerSection, "Offscreen Arrows", function(v) State.ESP.OffscreenArrows = v end)
		
		local worldSection = Tabs.createExpandableSection(espC, "World ESP", false)
		Components.createToggle(worldSection, "NPC ESP", function(v) State.ESP.NPCESP = v end)
		Components.createToggle(worldSection, "Item ESP", function(v) State.ESP.ItemESP = v end)
		
		local highlightSection = Tabs.createExpandableSection(espC, "Highlights", false)
		Components.createToggle(highlightSection, "Chams", function(v) State.ESP.Chams = v updateChams() end)
		
		local settingsSection = Tabs.createExpandableSection(espC, "ESP Settings", false)
		Components.createSlider(settingsSection, "Max Distance", 100, 2000, 1000, function(v) State.ESP.MaxDistance = v end)
		Components.createToggle(settingsSection, "Team Check", function(v) State.ESP.TeamCheck = v end)
	end
	
	-- ---------------------------------------------------------------------------
	-- VISUALS TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local lightingSection = Tabs.createExpandableSection(visC, "Lighting", false)
		Components.createToggle(lightingSection, "Fullbright", function(v)
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
		end)
		Components.createToggle(lightingSection, "No Fog", function(v)
			State.Visuals.NoFog = v
			if v then
				Lighting.FogEnd = 1e10
				Lighting.FogStart = 1e10
			else
				Lighting.FogEnd = OriginalLighting.FogEnd
				Lighting.FogStart = OriginalLighting.FogStart
			end
		end)
		Components.createToggle(lightingSection, "No Shadows", function(v) State.Visuals.NoShadows = v Lighting.GlobalShadows = not v end)
		
		local crosshairSection = Tabs.createExpandableSection(visC, "Crosshair", false)
		Components.createToggle(crosshairSection, "Custom Crosshair", function(v) State.Visuals.Crosshair = v end)
		Components.createSlider(crosshairSection, "Crosshair Size", 5, 50, 10, function(v) State.Visuals.CrosshairSize = v end)
		Components.createSlider(crosshairSection, "Crosshair Gap", 0, 20, 5, function(v) State.Visuals.CrosshairGap = v end)
		
		local cameraSection = Tabs.createExpandableSection(visC, "Camera", false)
		Components.createSlider(cameraSection, "Camera FOV", 30, 120, 70, function(v) State.Visuals.CameraFOV = v camera.FieldOfView = v end)
		Components.createToggle(cameraSection, "Third Person", function(v) State.Visuals.ThirdPerson = v player.CameraMaxZoomDistance = v and 100 or 128 player.CameraMinZoomDistance = v and 15 or 0.5 end)
		Components.createToggle(cameraSection, "Freecam", function(v) 
			State.Visuals.Freecam = v 
			if v then 
				FreecamPos = camera.CFrame.Position 
				UIS.MouseBehavior = Enum.MouseBehavior.LockCenter 
			else 
				camera.CameraType = Enum.CameraType.Custom 
				UIS.MouseBehavior = Enum.MouseBehavior.Default 
			end 
		end)
		Components.createSlider(cameraSection, "Freecam Speed", 1, 20, 1, function(v) State.Visuals.FreecamSpeed = v end)
		
		local worldSection = Tabs.createExpandableSection(visC, "World Visuals", false)
		Components.createToggle(worldSection, "X-Ray", function(v) State.Visuals.XRay = v end)
		Components.createSlider(worldSection, "X-Ray Transparency", 0, 100, 50, function(v) State.Visuals.XRayTransparency = v / 100 end)
	end
	
	-- ---------------------------------------------------------------------------
	-- WORLD TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local envSection = Tabs.createExpandableSection(worldC, "Environment", false)
		Components.createSlider(envSection, "Time of Day", 0, 24, 14, function(v) State.World.TimeOfDay = v Lighting.ClockTime = v end)
		Components.createSlider(envSection, "Gravity", 0, 500, 196, function(v) State.World.Gravity = v workspace.Gravity = v end)
		
		local terrainSection = Tabs.createExpandableSection(worldC, "Terrain", false)
		Components.createToggle(terrainSection, "Remove Grass", function(v)
			State.World.RemoveGrass = v
			local t = workspace:FindFirstChildOfClass("Terrain")
			if t then t.Decoration = not v end
			for _, o in ipairs(workspace:GetDescendants()) do
				if o:IsA("BasePart") and (o.Name:lower():find("grass") or o.Name:lower():find("foliage")) then
					o.Transparency = v and 1 or 0
				end
			end
		end)
		
		local toolsSection = Tabs.createExpandableSection(worldC, "Tools", false)
		Components.createToggle(toolsSection, "Delete Mode (Click)", function(v) State.World.DeleteMode = v end)
	end
	
	-- ---------------------------------------------------------------------------
	-- PLAYER TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local charSection = Tabs.createExpandableSection(playerC, "Character", false)
		Components.createToggle(charSection, "God Mode", function(v) State.Player.GodMode = v end)
		Components.createToggle(charSection, "No Ragdoll", function(v) State.Player.NoRagdoll = v end)
		Components.createToggle(charSection, "Auto Respawn", function(v) State.Player.AutoRespawn = v end)
		Components.createSlider(charSection, "Character Scale", 50, 200, 100, function(v) State.Player.CharScale = v / 100 end)
		
		local invisSection = Tabs.createExpandableSection(playerC, "Invisibility", false)
		Components.createLabel(invisSection, "Transparency-based invisibility")
		Components.createToggle(invisSection, "Invisibility", function(v)
			State.Player.Invisibility = v
			if v then
				InvisSystem:Enable()
			else
				InvisSystem:Disable()
			end
		end)
		Components.createSlider(invisSection, "Invis Offset", 50, 500, 100, function(v) State.Player.InvisOffset = v end)
		
		local weaponSection = Tabs.createExpandableSection(playerC, "Weapon", false)
		Components.createToggle(weaponSection, "No Recoil", function(v) State.Player.NoRecoil = v end)
		Components.createToggle(weaponSection, "No Spread", function(v) State.Player.NoSpread = v end)
		Components.createToggle(weaponSection, "Infinite Stamina", function(v) State.Player.InfiniteStamina = v end)
	end
	
	-- ---------------------------------------------------------------------------
	-- TROLL TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local followSection = Tabs.createExpandableSection(trollC, "Follow / Orbit", false)
		Components.createToggle(followSection, "Annoy Player", function(v) State.Troll.AnnoyPlayer = v end)
		Components.createToggle(followSection, "Orbit Player", function(v) State.Troll.OrbitPlayer = v end)
		Components.createSlider(followSection, "Orbit Radius", 5, 30, 10, function(v) State.Troll.OrbitRadius = v end)
		Components.createSlider(followSection, "Orbit Speed", 1, 10, 2, function(v) State.Troll.OrbitSpeed = v end)
		
		local charSection = Tabs.createExpandableSection(trollC, "Character Troll", false)
		Components.createToggle(charSection, "Fling", function(v) State.Troll.Fling = v end)
		Components.createSlider(charSection, "Fling Power", 100, 1000, 500, function(v) State.Troll.FlingPower = v end)
		Components.createToggle(charSection, "Headless", function(v) State.Troll.Headless = v end)
		
		local infoSection = Tabs.createExpandableSection(trollC, "Info", true)
		Components.createLabel(infoSection, "Type /target [name] in chat to set target")
		Components.createLabel(infoSection, "Example: /target Player1")
	end
	
	-- ---------------------------------------------------------------------------
	-- MISC TAB WITH EXPANDABLE SECTIONS
	-- ---------------------------------------------------------------------------
	do
		local hudSection = Tabs.createExpandableSection(miscC, "HUD Elements", true)
		Components.createToggle(hudSection, "Watermark", function(v) State.Misc.Watermark = v end)
		Components.createToggle(hudSection, "FPS Counter", function(v) State.Misc.FPSCounter = v end)
		Components.createToggle(hudSection, "Ping Display", function(v) State.Misc.PingDisplay = v end)
		Components.createToggle(hudSection, "Player Count", function(v) State.Misc.PlayerCount = v end)
		Components.createToggle(hudSection, "Velocity Display", function(v) State.Misc.VelocityDisplay = v end)
		Components.createToggle(hudSection, "Target Info", function(v) State.Misc.TargetInfo = v end)
		Components.createToggle(hudSection, "Keybinds Display", function(v) State.Misc.KeybindsDisplay = v end)
		
		local utilitySection = Tabs.createExpandableSection(miscC, "Utility", false)
		Components.createToggle(utilitySection, "Anti AFK", function(v) State.Misc.AntiAFK = v end)
		Components.createToggle(utilitySection, "Chat Spam", function(v) State.Misc.ChatSpam = v end)
		Components.createSlider(utilitySection, "Spam Delay", 1, 10, 2, function(v) State.Misc.SpamDelay = v end)
		
		local serverSection = Tabs.createExpandableSection(miscC, "Server", false)
		Components.createToggle(serverSection, "Server Hop", function(v)
			if v then
				pcall(function()
					local s = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
					for _, srv in ipairs(s.data) do
						if srv.id ~= game.JobId then
							TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id)
							break
						end
					end
				end)
			end
		end)
		Components.createToggle(serverSection, "Rejoin", function(v)
			if v then
				TeleportService:Teleport(game.PlaceId)
			end
		end)
		
		local keybindSection = Tabs.createExpandableSection(miscC, "Keybind Settings", true)
		Components.createLabel(keybindSection, "Current Keybinds:")
		Components.createLabel(keybindSection, "C - Aim Assist")
		Components.createLabel(keybindSection, "V - Kill Aura")
		Components.createLabel(keybindSection, "F - Fly")
		Components.createLabel(keybindSection, "N - Noclip")
		Components.createLabel(keybindSection, "Z - Speed")
		Components.createLabel(keybindSection, "X - ESP")
		Components.createLabel(keybindSection, "B - Silent Aim")
		Components.createLabel(keybindSection, "T - Triggerbot")
		Components.createLabel(keybindSection, "Press M to toggle menu")
	end
	
	-- Activate first tab
	Tabs.activate(combatT, combatC)
	
	-- ---------------------------------------------------------------------------
	-- MENU TOGGLE (M KEY) - WITH MOUSE UNLOCK
	-- ---------------------------------------------------------------------------
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == State.Settings.MenuKey then
			local show = not main.Visible
			main.Visible = show
			
			if show then
				-- Store previous mouse state
				PrevMouseState.behavior = UIS.MouseBehavior
				PrevMouseState.icon = UIS.MouseIconEnabled
				
				-- UNLOCK MOUSE (Required per spec)
				UIS.MouseBehavior = Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = true
				
				-- Animate open
				main.Size = UDim2.new(0, 0, 0, 0)
				if tween then
					tween(main, {Size = UDim2.new(0, 1000, 0, 700)}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
				else
					main.Size = UDim2.new(0, 1000, 0, 700)
				end
			else
				-- Restore previous mouse state
				UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = PrevMouseState.icon ~= false
			end
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- DRAGGING
	-- ---------------------------------------------------------------------------
	local dragging, dragStart, startPos = false, nil, nil
	hdr.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = main.Position
			inp.Changed:Connect(function()
				if inp.UserInputState == Enum.UserInputState.End then dragging = false end
			end)
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	
	-- ---------------------------------------------------------------------------
	-- CHARACTER EVENTS (Reapply features on respawn)
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
	-- INITIALIZATION COMPLETE
	-- ---------------------------------------------------------------------------
	if DrawingEnabled then
		print("[Vertex Hub v2.0] Loaded successfully! Drawing API available. Press M to toggle menu.")
		print("[Keybinds] C=AimAssist V=KillAura F=Fly N=Noclip Z=Speed X=ESP B=SilentAim T=Triggerbot")
	else
		print("[Vertex Hub v2.0] Loaded successfully! WARNING: Drawing API not available - ESP features disabled. Press M to toggle menu.")
	end
end
