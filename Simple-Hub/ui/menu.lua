-- ---------------------------------------------------------------------------
-- VERTEX HUB V2 - FULLY LOADSTRING COMPATIBLE
-- MASSIVE UPDATE: Fixed ESP, New Combat, Movement, Visual features
-- ---------------------------------------------------------------------------

return function(arg1, arg2, arg3)
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
	local SoundService = game:GetService("SoundService")
	
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
	
	local function tween(obj, props, tweenInfo)
		if not obj then return end
		tweenInfo = tweenInfo or {}
		local ti = TweenInfo.new(tweenInfo.Time or 0.2, tweenInfo.Style or Enum.EasingStyle.Quad, tweenInfo.Direction or Enum.EasingDirection.Out)
		local t = TweenService:Create(obj, ti, props)
		t:Play()
		return t
	end
	
	if not Animations then Animations = { tween = tween } end
	_G.VertexAnimations = Animations
	
	-- ---------------------------------------------------------------------------
	-- CHECK IF DRAWING API EXISTS
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
				if n:find("coin") or n:find("gem") or n:find("item") or n:find("pickup") or n:find("chest") or n:find("loot") then
					table.insert(EntityCache.items, {Object = obj, Position = obj.Position, Name = obj.Name})
				end
			end
		end
	end
	
	-- ---------------------------------------------------------------------------
	-- DRAWING SYSTEM (With fallback)
	-- ---------------------------------------------------------------------------
	local DrawingPool = { text = {}, square = {}, line = {}, triangle = {}, circle = {} }
	local ActiveDrawings = {}
	
	local function getDrawing(drawType)
		if not DrawingEnabled then return nil end
		local pool = DrawingPool[drawType]
		if not pool then return nil end
		
		for _, obj in ipairs(pool) do
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
				pcall(function() obj.Visible = false end)
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
			
			HUD.ComboCounter = Drawing.new("Text")
			HUD.ComboCounter.Size = 32
			HUD.ComboCounter.Outline = true
			HUD.ComboCounter.Center = true
			HUD.ComboCounter.Visible = false
		end)
	end
	
	-- ---------------------------------------------------------------------------
	-- ALL STATE VARIABLES (EXPANDED)
	-- ---------------------------------------------------------------------------
	local State = {
		ESP = {
			NameESP = false, BoxESP = false, HealthESP = false, DistanceESP = false,
			Tracers = false, SkeletonESP = false, OffscreenArrows = false, Chams = false,
			ItemESP = false, NPCESP = false, MaxDistance = 1000, TeamCheck = false,
			WeaponESP = false, HealthBar = false, BoxType = "2D", TracerOrigin = "Bottom",
			ShowHealth = true, ShowName = true, ShowDistance = true,
			PlayerColor = Color3.fromRGB(255, 0, 0), NPCColor = Color3.fromRGB(0, 200, 255),
			ItemColor = Color3.fromRGB(255, 200, 0), TeamColor = Color3.fromRGB(0, 255, 0),
			SoundESP = false, ProjectileESP = false, LootESP = false
		},
		Combat = {
			AimAssist = false, AimSmoothness = 0.15, AimFOV = 150, AimPrediction = false,
			PredictionAmount = 0.1, ShowFOVCircle = false, AimBone = "Head",
			SilentAim = false, SilentAimHitChance = 100,
			KillAura = false, KillAuraRange = 15, KillAuraCPS = 10, KillAuraLegit = false,
			KillAuraPlayers = true, KillAuraNPCs = false, KillAuraWallCheck = true,
			Reach = false, ReachDistance = 18, ReachLegit = false,
			Triggerbot = false, TriggerbotDelay = 0.1,
			AutoParry = false, HitboxExpander = false, HitboxSize = 5,
			Backtrack = false, BacktrackTime = 0.2,
			TargetStrafe = false, StrafeSpeed = 5, StrafeRadius = 10,
			-- NEW COMBAT
			ComboCounter = false, ComboTimeout = 2,
			AutoClicker = false, AutoClickerCPS = 12, AutoClickerJitter = true,
			AimLock = false, AimLockBone = "Head",
			DamageIndicator = false
		},
		Movement = {
			Fly = false, FlySpeed = 50, FlyLegit = false, Noclip = false,
			Speed = false, SpeedValue = 16, SpeedLegit = false,
			JumpPower = false, JumpValue = 50, InfiniteJump = false,
			BunnyHop = false, LongJump = false, LongJumpForce = 100,
			SpeedGlide = false, GlideSpeed = 10,
			Dash = false, DashForce = 100, DashCooldown = 1,
			ClickTP = false, AntiVoid = false, VoidHeight = -100, Anchor = false,
			SpinBot = false, SpinSpeed = 20, FakeLag = false, LagIntensity = 5, AirControl = false,
			-- NEW MOVEMENT
			Spider = false, SpiderSpeed = 10,
			EdgeJump = false, SafeWalk = false,
			Strafe = false, StrafeSpeed = 50,
			AutoJumpReset = false
		},
		Visuals = {
			Fullbright = false, NoFog = false, NoShadows = false,
			Crosshair = false, CrosshairSize = 10, CrosshairGap = 5, CrosshairColor = Color3.fromRGB(0, 255, 0),
			CameraFOV = 70, ThirdPerson = false, ThirdPersonDist = 10, Freecam = false, FreecamSpeed = 1,
			XRay = false, XRayTransparency = 0.5,
			-- NEW VISUALS
			AmbientColor = false, AmbientR = 128, AmbientG = 128, AmbientB = 128,
			Trail = false, TrailColor = Color3.fromRGB(255, 0, 255), TrailLifetime = 1,
			KillEffect = false, KillEffectType = "Explode",
			Radar = false, RadarSize = 150, RadarZoom = 1,
			ScreenshotMode = false
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
			VelocityDisplay = false, TargetInfo = false, KeybindsDisplay = false,
			-- NEW MISC
			Notifications = true
		},
		Settings = { MenuKey = Enum.KeyCode.M, AccentColor = Color3.fromRGB(60, 120, 255) }
	}
	
	-- ---------------------------------------------------------------------------
	-- STORAGE VARIABLES
	-- ---------------------------------------------------------------------------
	local BacktrackPositions = {}
	local CurrentTarget = nil
	local LastAttackTime = 0
	local LastTriggerbotTime = 0
	local LastDashTime = 0
	local LastClickTime = 0
	local FreecamPos = Vector3.new(0, 50, 0)
	local FreecamAngles = Vector2.new(0, 0)
	local FPSData = { frames = 0, lastTime = tick(), fps = 60 }
	local PrevMouseState = { behavior = nil, icon = nil }
	local ComboData = { count = 0, lastHit = 0 }
	local DamageIndicators = {}
	local TrailParts = {}
	local OriginalLighting = {
		Ambient = Lighting.Ambient, Brightness = Lighting.Brightness,
		FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart,
		GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient,
		ClockTime = Lighting.ClockTime
	}
	local OriginalGravity = workspace.Gravity
	local OriginalHitboxSizes = {}
	
	-- ---------------------------------------------------------------------------
	-- NOTIFICATION SYSTEM
	-- ---------------------------------------------------------------------------
	local Notifications = {}
	local function notify(title, text, duration)
		if not State.Misc.Notifications then return end
		duration = duration or 3
		-- Create GUI notification
		pcall(function()
			local gui = player:FindFirstChild("PlayerGui")
			if not gui then return end
			local notifGui = gui:FindFirstChild("VertexNotifications")
			if not notifGui then
				notifGui = Instance.new("ScreenGui")
				notifGui.Name = "VertexNotifications"
				notifGui.ResetOnSpawn = false
				notifGui.Parent = gui
			end
			
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(0, 250, 0, 60)
			frame.Position = UDim2.new(1, 0, 0.7, -#Notifications * 70)
			frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
			frame.BorderSizePixel = 0
			frame.Parent = notifGui
			
			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 8)
			corner.Parent = frame
			
			local accent = Instance.new("Frame")
			accent.Size = UDim2.new(0, 4, 1, 0)
			accent.BackgroundColor3 = State.Settings.AccentColor
			accent.BorderSizePixel = 0
			accent.Parent = frame
			
			local titleLbl = Instance.new("TextLabel")
			titleLbl.Size = UDim2.new(1, -20, 0, 25)
			titleLbl.Position = UDim2.new(0, 15, 0, 5)
			titleLbl.BackgroundTransparency = 1
			titleLbl.Text = title
			titleLbl.TextColor3 = Color3.new(1, 1, 1)
			titleLbl.TextXAlignment = Enum.TextXAlignment.Left
			titleLbl.Font = Enum.Font.GothamBold
			titleLbl.TextSize = 14
			titleLbl.Parent = frame
			
			local textLbl = Instance.new("TextLabel")
			textLbl.Size = UDim2.new(1, -20, 0, 25)
			textLbl.Position = UDim2.new(0, 15, 0, 28)
			textLbl.BackgroundTransparency = 1
			textLbl.Text = text
			textLbl.TextColor3 = Color3.fromRGB(180, 180, 180)
			textLbl.TextXAlignment = Enum.TextXAlignment.Left
			textLbl.Font = Enum.Font.Gotham
			textLbl.TextSize = 12
			textLbl.Parent = frame
			
			table.insert(Notifications, frame)
			
			-- Animate in
			tween(frame, {Position = UDim2.new(1, -270, 0.7, -#Notifications * 70)}, {Time = 0.3})
			
			-- Remove after duration
			task.delay(duration, function()
				tween(frame, {Position = UDim2.new(1, 0, frame.Position.Y.Scale, frame.Position.Y.Offset)}, {Time = 0.3})
				task.wait(0.3)
				local idx = table.find(Notifications, frame)
				if idx then table.remove(Notifications, idx) end
				frame:Destroy()
			end)
		end)
	end
	
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
						local aimPart = data.Head or data.RootPart
						if State.Combat.AimBone == "Torso" then
							aimPart = data.Character and data.Character:FindFirstChild("UpperTorso") or data.Character:FindFirstChild("Torso") or data.RootPart
						elseif State.Combat.AimBone == "Root" then
							aimPart = data.RootPart
						end
						local screenPos, onScreen = camera:WorldToViewportPoint(aimPart.Position)
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
								table.insert(targets, { Entity = data, Distance = dist, ScreenDistance = screenDist, Health = data.Humanoid.Health, AimPart = aimPart })
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
							table.insert(targets, { Entity = data, Distance = dist, ScreenDistance = screenDist, Health = data.Humanoid.Health, AimPart = head })
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
		return targets[1].Entity, targets[1].AimPart
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
		notify("Movement", "Fly enabled", 2)
	end
	
	function FlySystem:Disable()
		self.enabled = false
		local hum = getHumanoid()
		if hum then hum.PlatformStand = false end
		if self.bodyGyro then self.bodyGyro:Destroy() self.bodyGyro = nil end
		if self.bodyVelocity then self.bodyVelocity:Destroy() self.bodyVelocity = nil end
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
	local InvisSystem = { enabled = false, movedParts = {}, connection = nil }
	
	function InvisSystem:Enable()
		local char = getCharacter()
		local root = getRoot()
		if not char or not root then return end
		
		self.enabled = true
		self.movedParts = {}
		local offset = State.Player.InvisOffset
		
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
				self.movedParts[part] = true
			end
		end
		
		if self.connection then self.connection:Disconnect() end
		self.connection = RunService.Heartbeat:Connect(function()
			if not self.enabled then return end
			local r = getRoot()
			if not r then return end
			local offsetVec = Vector3.new(0, offset, 0)
			for part, _ in pairs(self.movedParts) do
				if part and part.Parent then
					part.CFrame = CFrame.new(r.Position + offsetVec) * (part.CFrame - part.Position)
				end
			end
		end)
		notify("Player", "Invisibility enabled", 2)
	end
	
	function InvisSystem:Disable()
		self.enabled = false
		if self.connection then self.connection:Disconnect() self.connection = nil end
		self.movedParts = {}
	end
	
	-- ---------------------------------------------------------------------------
	-- DAMAGE INDICATOR SYSTEM
	-- ---------------------------------------------------------------------------
	local function createDamageIndicator(position, damage)
		if not State.Combat.DamageIndicator then return end
		pcall(function()
			local billboard = Instance.new("BillboardGui")
			billboard.Size = UDim2.new(0, 100, 0, 50)
			billboard.StudsOffset = Vector3.new(0, 2, 0)
			billboard.Adornee = nil
			billboard.AlwaysOnTop = true
			
			local part = Instance.new("Part")
			part.Size = Vector3.new(0.1, 0.1, 0.1)
			part.Transparency = 1
			part.Anchored = true
			part.CanCollide = false
			part.Position = position + Vector3.new(math.random(-1, 1), 2, math.random(-1, 1))
			part.Parent = workspace
			
			billboard.Adornee = part
			billboard.Parent = part
			
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.Text = "-" .. tostring(math.floor(damage))
			label.TextColor3 = Color3.fromRGB(255, 50, 50)
			label.TextStrokeTransparency = 0
			label.Font = Enum.Font.GothamBold
			label.TextSize = 24
			label.Parent = billboard
			
			-- Animate up and fade
			local startPos = part.Position
			local startTime = tick()
			local conn
			conn = RunService.Heartbeat:Connect(function()
				local elapsed = tick() - startTime
				if elapsed > 1 then
					conn:Disconnect()
					part:Destroy()
					return
				end
				part.Position = startPos + Vector3.new(0, elapsed * 2, 0)
				label.TextTransparency = elapsed
				label.TextStrokeTransparency = elapsed
			end)
		end)
	end
	
	-- ---------------------------------------------------------------------------
	-- EXECUTOR API
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
	-- KILLAURA HOOKS
	-- ---------------------------------------------------------------------------
	local LEGIT_RANGE = 14.4
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
									if typeof(arg) == "Vector3" then args[i] = reportedPosition
									elseif typeof(arg) == "CFrame" then args[i] = CFrame.new(reportedPosition) * (arg - arg.Position)
									elseif typeof(arg) == "table" then
										if arg.Position then arg.Position = reportedPosition end
										if arg.Origin then arg.Origin = reportedPosition end
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
						local target, aimPart = getAimTarget()
						if target and aimPart then
							local pos = aimPart.Position
							if State.Combat.AimPrediction and target.RootPart then
								pos = pos + target.RootPart.Velocity * State.Combat.PredictionAmount
							end
							if key == "Hit" then return CFrame.new(pos) end
							if key == "Target" then return aimPart end
							if key == "X" then return camera:WorldToViewportPoint(pos).X end
							if key == "Y" then return camera:WorldToViewportPoint(pos).Y end
						end
					end
				end
				return oldIndex(self, key)
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
						if sayMsg then sayMsg:FireServer(State.Misc.SpamMsg, "All") end
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
	
	-- Auto Clicker Loop
	task.spawn(function()
		while true do
			if State.Combat.AutoClicker and mouse1click then
				local cps = State.Combat.AutoClickerCPS
				if State.Combat.AutoClickerJitter then
					cps = cps + math.random(-2, 2)
				end
				cps = math.max(1, cps)
				pcall(function() mouse1click() end)
				task.wait(1 / cps)
			else
				task.wait(0.1)
			end
		end
	end)
	
	-- Trail Effect Loop
	task.spawn(function()
		while true do
			if State.Visuals.Trail then
				local root = getRoot()
				if root then
					pcall(function()
						local part = Instance.new("Part")
						part.Size = Vector3.new(0.5, 0.5, 0.5)
						part.Position = root.Position
						part.Anchored = true
						part.CanCollide = false
						part.Material = Enum.Material.Neon
						part.Color = State.Visuals.TrailColor
						part.Transparency = 0.3
						part.Parent = workspace
						
						table.insert(TrailParts, {part = part, time = tick()})
						
						-- Fade and remove old trail parts
						for i = #TrailParts, 1, -1 do
							local data = TrailParts[i]
							local age = tick() - data.time
							if age > State.Visuals.TrailLifetime then
								data.part:Destroy()
								table.remove(TrailParts, i)
							else
								data.part.Transparency = 0.3 + (age / State.Visuals.TrailLifetime) * 0.7
							end
						end
					end)
				end
			end
			task.wait(0.05)
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
						h.FillColor = State.ESP.PlayerColor
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						h.FillTransparency = 0.5
						h.Parent = data.Character
					else
						existing.FillColor = State.ESP.PlayerColor
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
						h.FillColor = State.ESP.NPCColor
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
	-- MAIN UPDATE LOOP
	-- ---------------------------------------------------------------------------
	local lastCacheUpdate = 0
	
	RunService.RenderStepped:Connect(function(dt)
		camera = workspace.CurrentCamera
		local char = getCharacter()
		local root = getRoot()
		local hum = getHumanoid()
		
		-- Update cache every 0.5s
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
		
		-- Combo timeout
		if State.Combat.ComboCounter and tick() - ComboData.lastHit > State.Combat.ComboTimeout then
			ComboData.count = 0
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
		
		-- Spider (Wall Climb)
		if State.Movement.Spider and root and hum then
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			local frontRay = workspace:Raycast(root.Position, root.CFrame.LookVector * 3, params)
			if frontRay then
				root.Velocity = Vector3.new(root.Velocity.X, State.Movement.SpiderSpeed, root.Velocity.Z)
			end
		end
		
		-- Edge Jump
		if State.Movement.EdgeJump and root and hum and hum.FloorMaterial ~= Enum.Material.Air then
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			local edgeRay = workspace:Raycast(root.Position + root.CFrame.LookVector * 2, Vector3.new(0, -5, 0), params)
			if not edgeRay then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
		
		-- Safe Walk
		if State.Movement.SafeWalk and root and hum then
			local params = RaycastParams.new()
			params.FilterDescendantsInstances = {char}
			local moveDir = hum.MoveDirection
			if moveDir.Magnitude > 0 then
				local checkPos = root.Position + moveDir.Unit * 3
				local groundCheck = workspace:Raycast(checkPos, Vector3.new(0, -10, 0), params)
				if not groundCheck then
					hum.WalkSpeed = 0
				elseif State.Movement.Speed then
					hum.WalkSpeed = State.Movement.SpeedValue
				else
					hum.WalkSpeed = 16
				end
			end
		end
		
		-- Strafe Speed
		if State.Movement.Strafe and root and hum then
			if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.D) then
				if not UIS:IsKeyDown(Enum.KeyCode.W) and not UIS:IsKeyDown(Enum.KeyCode.S) then
					hum.WalkSpeed = State.Movement.StrafeSpeed
				end
			end
		end
		
		-- -----------------------------------------------------------------------
		-- COMBAT
		-- -----------------------------------------------------------------------
		if State.Combat.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target, aimPart = getBestTarget({ Range = 1000, Players = true, NPCs = true, UseFOV = true, FOV = State.Combat.AimFOV, Sort = "Angle" })
			if target and aimPart then
				local pos = aimPart.Position
				if State.Combat.AimPrediction and target.RootPart then
					pos = pos + target.RootPart.Velocity * State.Combat.PredictionAmount
				end
				camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, pos), State.Combat.AimSmoothness)
			end
		end
		
		-- Aim Lock (Hard lock, no smoothing)
		if State.Combat.AimLock and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target, aimPart = getBestTarget({ Range = 1000, Players = true, NPCs = true, UseFOV = true, FOV = State.Combat.AimFOV, Sort = "Angle" })
			if target and aimPart then
				local pos = aimPart.Position
				if State.Combat.AimPrediction and target.RootPart then
					pos = pos + target.RootPart.Velocity * State.Combat.PredictionAmount
				end
				camera.CFrame = CFrame.new(camera.CFrame.Position, pos)
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
		
		-- KillAura
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
						-- Combo counter
						if State.Combat.ComboCounter then
							ComboData.count = ComboData.count + 1
							ComboData.lastHit = tick()
						end
						-- Damage indicator
						if State.Combat.DamageIndicator and target.RootPart then
							createDamageIndicator(target.RootPart.Position, math.random(10, 25))
						end
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
					pcall(function() if mouse1click then mouse1click() end end)
				end
			end
		end
		
		if State.Combat.AutoParry and root and char then
			for _, o in ipairs(workspace:GetDescendants()) do
				if o:IsA("BasePart") and (o.Name:lower():find("sword") or o.Name:lower():find("blade")) then
					if o.Parent ~= char and (o.Parent and o.Parent.Parent ~= char) then
						if (root.Position - o.Position).Magnitude < 15 then
							local tool = getTool() 
							if tool then pcall(function() tool:Activate() end) end
							if mouse2click then pcall(function() mouse2click() end) end
							break
						end
					end
				end
			end
		end
		
		if State.Combat.HitboxExpander then
			for _, data in pairs(EntityCache.players) do
				if data.RootPart then
					if not OriginalHitboxSizes[data.Player.Name] then
						OriginalHitboxSizes[data.Player.Name] = data.RootPart.Size
					end
					data.RootPart.Size = Vector3.new(State.Combat.HitboxSize, State.Combat.HitboxSize, State.Combat.HitboxSize)
					data.RootPart.Transparency = 0.7
				end
			end
		else
			-- Restore hitboxes
			for name, size in pairs(OriginalHitboxSizes) do
				local data = EntityCache.players[name]
				if data and data.RootPart then
					data.RootPart.Size = size
					data.RootPart.Transparency = 1
				end
			end
		end
		
		if State.Combat.Backtrack then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart then
					if not BacktrackPositions[name] then BacktrackPositions[name] = {} end
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
				if tr then root.CFrame = tr.CFrame * CFrame.new(0, 0, -3) end
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
				if face then face.Transparency = 1 end
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
			if dir.Magnitude > 0 then FreecamPos = FreecamPos + dir.Unit * spd end
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.new(FreecamPos) * CFrame.Angles(math.rad(FreecamAngles.X), math.rad(FreecamAngles.Y), 0)
		end
		
		if State.Visuals.ThirdPerson and not State.Visuals.Freecam then
			player.CameraMaxZoomDistance = State.Visuals.ThirdPersonDist
			player.CameraMinZoomDistance = State.Visuals.ThirdPersonDist
		end
		
		if State.Visuals.XRay then
			for _, p in ipairs(workspace:GetDescendants()) do
				if p:IsA("BasePart") and not p:IsDescendantOf(char or {}) and p.Transparency < 1 then
					p.LocalTransparencyModifier = State.Visuals.XRayTransparency
				end
			end
		end
		
		if State.Visuals.AmbientColor then
			Lighting.Ambient = Color3.fromRGB(State.Visuals.AmbientR, State.Visuals.AmbientG, State.Visuals.AmbientB)
			Lighting.OutdoorAmbient = Color3.fromRGB(State.Visuals.AmbientR, State.Visuals.AmbientG, State.Visuals.AmbientB)
		end
		
		-- -----------------------------------------------------------------------
		-- HUD (Drawing API)
		-- -----------------------------------------------------------------------
		if DrawingEnabled then
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
				local clr = State.Visuals.CrosshairColor
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
				HUD.Watermark.Text = "Vertex Hub v2"
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
			if HUD.ComboCounter then
				HUD.ComboCounter.Visible = State.Combat.ComboCounter and ComboData.count > 0
				HUD.ComboCounter.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y * 0.7)
				HUD.ComboCounter.Text = ComboData.count .. " COMBO"
				HUD.ComboCounter.Color = Color3.fromRGB(255, 200, 0)
			end
		end
		
		-- -----------------------------------------------------------------------
		-- ESP RENDERING
		-- -----------------------------------------------------------------------
		releaseAllDrawings()
		
		if State.Visuals.ScreenshotMode then
			-- Hide all ESP for screenshots
			return
		end
		
		local anyESP = State.ESP.NameESP or State.ESP.BoxESP or State.ESP.HealthESP or State.ESP.DistanceESP or State.ESP.Tracers or State.ESP.SkeletonESP or State.ESP.OffscreenArrows or State.ESP.ItemESP or State.ESP.NPCESP or State.ESP.WeaponESP or State.ESP.HealthBar
		
		if anyESP and DrawingEnabled then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					if State.ESP.TeamCheck and data.Team and player.Team and data.Team == player.Team then continue end
					
					local dist = root and (root.Position - data.RootPart.Position).Magnitude or 0
					if dist <= State.ESP.MaxDistance then
						local pos, onScreen = camera:WorldToViewportPoint(data.RootPart.Position)
						local sc = math.clamp(1 / (pos.Z * 0.04), 0.2, 2)
						local espColor = State.ESP.PlayerColor
						
						if onScreen then
							if State.ESP.NameESP then
								local t = getDrawing("text")
								if t then
									t.Text = name
									t.Position = Vector2.new(pos.X, pos.Y - 50 * sc)
									t.Color = espColor
									t.Size = 14
								end
							end
							if State.ESP.HealthESP then
								local t = getDrawing("text")
								if t then
									local healthPct = math.floor((data.Humanoid.Health / data.Humanoid.MaxHealth) * 100)
									t.Text = healthPct .. "%"
									t.Position = Vector2.new(pos.X, pos.Y - 35 * sc)
									t.Color = Color3.fromRGB(255 - healthPct * 2.55, healthPct * 2.55, 0)
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
							if State.ESP.WeaponESP and data.Character then
								local tool = data.Character:FindFirstChildOfClass("Tool")
								if tool then
									local t = getDrawing("text")
									if t then
										t.Text = "[" .. tool.Name .. "]"
										t.Position = Vector2.new(pos.X, pos.Y + 55 * sc)
										t.Color = Color3.fromRGB(255, 150, 0)
										t.Size = 11
									end
								end
							end
							if State.ESP.BoxESP then
								local b = getDrawing("square")
								if b then
									local sz = Vector2.new(50 * sc, 70 * sc)
									b.Size = sz
									b.Position = Vector2.new(pos.X - sz.X / 2, pos.Y - sz.Y / 2)
									b.Color = espColor
								end
							end
							if State.ESP.HealthBar then
								local healthPct = data.Humanoid.Health / data.Humanoid.MaxHealth
								local barBg = getDrawing("square")
								local barFill = getDrawing("square")
								if barBg and barFill then
									local barH = 70 * sc
									local barW = 4
									barBg.Size = Vector2.new(barW, barH)
									barBg.Position = Vector2.new(pos.X - 30 * sc, pos.Y - barH / 2)
									barBg.Color = Color3.fromRGB(40, 40, 40)
									barBg.Filled = true
									
									barFill.Size = Vector2.new(barW - 2, (barH - 2) * healthPct)
									barFill.Position = Vector2.new(pos.X - 30 * sc + 1, pos.Y - barH / 2 + 1 + (barH - 2) * (1 - healthPct))
									barFill.Color = Color3.fromRGB(255 - healthPct * 255, healthPct * 255, 0)
									barFill.Filled = true
								end
							end
							if State.ESP.Tracers then
								local l = getDrawing("line")
								if l then
									local fromY = State.ESP.TracerOrigin == "Top" and 0 or (State.ESP.TracerOrigin == "Center" and camera.ViewportSize.Y / 2 or camera.ViewportSize.Y)
									l.From = Vector2.new(camera.ViewportSize.X / 2, fromY)
									l.To = Vector2.new(pos.X, pos.Y)
									l.Color = espColor
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
									arr.Color = espColor
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
								t.Color = State.ESP.NPCColor
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
							t.Color = State.ESP.ItemColor
							t.Size = 12
						end
					end
				end
			end
		end
		
		-- Radar
		if State.Visuals.Radar and DrawingEnabled and root then
			local radarSize = State.Visuals.RadarSize
			local radarPos = Vector2.new(camera.ViewportSize.X - radarSize - 20, 20)
			
			-- Radar background
			local bg = getDrawing("square")
			if bg then
				bg.Size = Vector2.new(radarSize, radarSize)
				bg.Position = radarPos
				bg.Color = Color3.fromRGB(20, 20, 30)
				bg.Filled = true
				bg.Transparency = 0.3
			end
			
			-- Center dot (you)
			local center = getDrawing("circle")
			if center then
				center.Position = radarPos + Vector2.new(radarSize / 2, radarSize / 2)
				center.Radius = 3
				center.Color = Color3.fromRGB(0, 255, 0)
				center.Filled = true
			end
			
			-- Other players
			for name, data in pairs(EntityCache.players) do
				if data.RootPart then
					local relPos = data.RootPart.Position - root.Position
					local dist = relPos.Magnitude
					if dist < 200 then
						local angle = math.atan2(relPos.Z, relPos.X) - math.rad(camera.CFrame:ToEulerAnglesYXZ())
						local scaledDist = (dist / 200) * (radarSize / 2) * State.Visuals.RadarZoom
						local radarX = radarPos.X + radarSize / 2 + math.cos(angle) * scaledDist
						local radarY = radarPos.Y + radarSize / 2 + math.sin(angle) * scaledDist
						
						if radarX > radarPos.X and radarX < radarPos.X + radarSize and radarY > radarPos.Y and radarY < radarPos.Y + radarSize then
							local dot = getDrawing("circle")
							if dot then
								dot.Position = Vector2.new(radarX, radarY)
								dot.Radius = 4
								dot.Color = State.ESP.PlayerColor
								dot.Filled = true
							end
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
 toggleObject = {
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
				tween(fill, {Size = UDim2.new(p, 0, 1, 0)}, {Time = 0.08})
				tween(handle, {Position = UDim2.new(p, 0, 0.5, 0)}, {Time = 0.08})
				if callback then callback(v) end
			end
			sbg.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true upd(i) end end)
			handle.InputBegan:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end end)
			UIS.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)
			UIS.InputChanged:Connect(function(i) if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then upd(i) end end)
			return cont
		end
		
		function Components.createInput(parent, text, placeholder, callback)
			local cont = Instance.new("Frame")
			cont.Size = UDim2.new(1, -16, 0, 40)
			cont.BackgroundColor3 = Colors.Btn
			cont.BorderSizePixel = 0
			cont.Parent = parent
			corner(cont)
			stroke(cont)
			local lbl = Instance.new("TextLabel")
			lbl.Size = UDim2.new(0, 80, 1, 0)
			lbl.Position = UDim2.new(0, 8, 0, 0)
			lbl.BackgroundTransparency = 1
			lbl.Text = text
			lbl.TextColor3 = Colors.Dim
			lbl.TextXAlignment = Enum.TextXAlignment.Left
			lbl.Font = Enum.Font.GothamMedium
			lbl.TextSize = 12
			lbl.Parent = cont
			local input = Instance.new("TextBox")
			input.Size = UDim2.new(1, -100, 1, -12)
			input.Position = UDim2.new(0, 88, 0, 6)
			input.BackgroundColor3 = Colors.SliderBg
			input.BorderSizePixel = 0
			input.Text = ""
			input.PlaceholderText = placeholder or ""
			input.TextColor3 = Colors.Text
			input.PlaceholderColor3 = Colors.Dim
			input.Font = Enum.Font.Gotham
			input.TextSize = 12
			input.ClearTextOnFocus = false
			input.Parent = cont
			corner(input, 4)
			input.FocusLost:Connect(function(enter) if enter and callback then callback(input.Text) end end)
			return cont
		end
	end
	_G.VertexComponents = Components
	
	-- ---------------------------------------------------------------------------
	-- BUILT-IN TABS
	-- ---------------------------------------------------------------------------
	if not Tabs then
		Tabs = {}
		local tabButtons = {}
		local tabContents = {}
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
			btn.Size = UDim2.new(0, 85, 0, 30)
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
		end
	end
	_G.VertexTabs = Tabs
	
	-- ---------------------------------------------------------------------------
	-- CREATE GUI
	-- ---------------------------------------------------------------------------
	local gui = Instance.new("ScreenGui")
	gui.Name = "VertexHub"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 950, 0, 650)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Colors.Background
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Visible = false
	main.Parent = gui
	
	local mc = Instance.new("UICorner")
	mc.CornerRadius = UDim.new(0, 10)
	mc.Parent = main
	local ms = Instance.new("UIStroke")
	ms.Color = Colors.Border
	ms.Thickness = 2
	ms.Parent = main
	
	-- Header
	local hdr = Instance.new("Frame")
	hdr.Size = UDim2.new(1, 0, 0, 45)
	hdr.BackgroundColor3 = Colors.Panel
	hdr.BorderSizePixel = 0
	hdr.Parent = main
	local ttl = Instance.new("TextLabel")
	ttl.Size = UDim2.new(0, 300, 1, 0)
	ttl.Position = UDim2.new(0, 15, 0, 0)
	ttl.BackgroundTransparency = 1
	ttl.Text = "VERTEX HUB V2"
	ttl.TextColor3 = Colors.Text
	ttl.TextXAlignment = Enum.TextXAlignment.Left
	ttl.Font = Enum.Font.GothamBold
	ttl.TextSize = 18
	ttl.Parent = hdr
	local acc = Instance.new("Frame")
	acc.Size = UDim2.new(0, 80, 0, 3)
	acc.Position = UDim2.new(0, 15, 1, -3)
	acc.BackgroundColor3 = Colors.Accent
	acc.BorderSizePixel = 0
	acc.Parent = hdr
	local accC = Instance.new("UICorner")
	accC.CornerRadius = UDim.new(1, 0)
	accC.Parent = acc
	
	local cls = Instance.new("TextButton")
	cls.Size = UDim2.new(0, 30, 0, 30)
	cls.Position = UDim2.new(1, -40, 0.5, 0)
	cls.AnchorPoint = Vector2.new(0, 0.5)
	cls.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	cls.Text = "X"
	cls.TextColor3 = Colors.Text
	cls.Font = Enum.Font.GothamBold
	cls.TextSize = 20
	cls.AutoButtonColor = false
	cls.Parent = hdr
	local clsC = Instance.new("UICorner")
	clsC.CornerRadius = UDim.new(0, 6)
	clsC.Parent = cls
	cls.MouseButton1Click:Connect(function() main.Visible = false UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default UIS.MouseIconEnabled = PrevMouseState.icon ~= false end)
	cls.MouseEnter:Connect(function() cls.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end)
	cls.MouseLeave:Connect(function() cls.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end)
	
	-- Tab Bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, 0, 0, 45)
	tabBar.Position = UDim2.new(0, 0, 0, 45)
	tabBar.BackgroundColor3 = Colors.Surface
	tabBar.BorderSizePixel = 0
	tabBar.Parent = main
	Tabs.setupTabBar(tabBar)
	
	-- Content Area
	local cArea = Instance.new("Frame")
	cArea.Size = UDim2.new(1, 0, 1, -90)
	cArea.Position = UDim2.new(0, 0, 0, 90)
	cArea.BackgroundColor3 = Colors.Content
	cArea.BorderSizePixel = 0
	cArea.Parent = main
	local cCont = Instance.new("Frame")
	cCont.Size = UDim2.new(1, -20, 1, -12)
	cCont.Position = UDim2.new(0, 10, 0, 6)
	cCont.BackgroundTransparency = 1
	cCont.Parent = cArea
	
	local function makeTab(nm)
		local scr = Instance.new("ScrollingFrame")
		scr.Name = nm
		scr.Size = UDim2.new(1, 0, 1, 0)
		scr.BackgroundColor3 = Colors.Scroll
		scr.BackgroundTransparency = 0
		scr.BorderSizePixel = 0
		scr.ScrollBarThickness = 4
		scr.ScrollBarImageColor3 = Colors.Accent
		scr.CanvasSize = UDim2.new(0, 0, 0, 0)
		scr.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scr.Visible = false
		scr.Parent = cCont
		local lay = Instance.new("UIListLayout")
		lay.Padding = UDim.new(0, 6)
		lay.SortOrder = Enum.SortOrder.LayoutOrder
		lay.Parent = scr
		local pad = Instance.new("UIPadding")
		pad.PaddingTop = UDim.new(0, 4)
		pad.PaddingBottom = UDim.new(0, 8)
		pad.PaddingLeft = UDim.new(0, 4)
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
	
	local combatT = Tabs.create(tabBar, "Combat", "⚔")
	local moveT = Tabs.create(tabBar, "Move", "➤")
	local espT = Tabs.create(tabBar, "ESP", "👁")
	local visT = Tabs.create(tabBar, "Visual", "✦")
	local worldT = Tabs.create(tabBar, "World", "🌍")
	local playerT = Tabs.create(tabBar, "Player", "👤")
	local trollT = Tabs.create(tabBar, "Troll", "😈")
	local miscT = Tabs.create(tabBar, "Misc", "⚙")
	
	Tabs.connectTab(combatT, combatC)
	Tabs.connectTab(moveT, moveC)
	Tabs.connectTab(espT, espC)
	Tabs.connectTab(visT, visC)
	Tabs.connectTab(worldT, worldC)
	Tabs.connectTab(playerT, playerC)
	Tabs.connectTab(trollT, trollC)
	Tabs.connectTab(miscT, miscC)
	
	-- ---------------------------------------------------------------------------
	-- COMBAT TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(combatC, "Aim Assist")
	Components.createToggle(combatC, "Aim Assist", function(v) State.Combat.AimAssist = v end)
	Components.createSlider(combatC, "Smoothness", 1, 100, 15, function(v) State.Combat.AimSmoothness = v / 200 end)
	Components.createSlider(combatC, "FOV", 50, 600, 150, function(v) State.Combat.AimFOV = v end)
	Components.createToggle(combatC, "Show FOV Circle", function(v) State.Combat.ShowFOVCircle = v end)
	Components.createToggle(combatC, "Prediction", function(v) State.Combat.AimPrediction = v end)
	Components.createSlider(combatC, "Prediction Amount", 1, 50, 10, function(v) State.Combat.PredictionAmount = v / 100 end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Aim Lock")
	Components.createToggle(combatC, "Aim Lock (Hard)", function(v) State.Combat.AimLock = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Silent Aim")
	Components.createToggle(combatC, "Silent Aim", function(v) State.Combat.SilentAim = v end)
	Components.createSlider(combatC, "Hit Chance", 0, 100, 100, function(v) State.Combat.SilentAimHitChance = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Kill Aura")
	Components.createToggle(combatC, "Kill Aura", function(v) State.Combat.KillAura = v end)
	Components.createSlider(combatC, "Range", 5, 50, 15, function(v) State.Combat.KillAuraRange = v end)
	Components.createSlider(combatC, "CPS", 1, 20, 10, function(v) State.Combat.KillAuraCPS = v end)
	Components.createToggle(combatC, "Target Players", function(v) State.Combat.KillAuraPlayers = v end)
	Components.createToggle(combatC, "Target NPCs", function(v) State.Combat.KillAuraNPCs = v end)
	Components.createToggle(combatC, "Wall Check", function(v) State.Combat.KillAuraWallCheck = v end)
	Components.createToggle(combatC, "Legit Mode", function(v) State.Combat.KillAuraLegit = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Auto")
	Components.createToggle(combatC, "Triggerbot", function(v) State.Combat.Triggerbot = v end)
	Components.createSlider(combatC, "Triggerbot Delay", 1, 50, 10, function(v) State.Combat.TriggerbotDelay = v / 100 end)
	Components.createToggle(combatC, "Auto Parry", function(v) State.Combat.AutoParry = v end)
	Components.createToggle(combatC, "Auto Clicker", function(v) State.Combat.AutoClicker = v end)
	Components.createSlider(combatC, "Auto Clicker CPS", 5, 20, 12, function(v) State.Combat.AutoClickerCPS = v end)
	Components.createToggle(combatC, "Clicker Jitter", function(v) State.Combat.AutoClickerJitter = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Extras")
	Components.createToggle(combatC, "Hitbox Expander", function(v) State.Combat.HitboxExpander = v end)
	Components.createSlider(combatC, "Hitbox Size", 5, 30, 5, function(v) State.Combat.HitboxSize = v end)
	Components.createToggle(combatC, "Reach", function(v) State.Combat.Reach = v end)
	Components.createSlider(combatC, "Reach Distance", 14, 30, 18, function(v) State.Combat.ReachDistance = v end)
	Components.createToggle(combatC, "Backtrack", function(v) State.Combat.Backtrack = v end)
	Components.createToggle(combatC, "Target Strafe", function(v) State.Combat.TargetStrafe = v end)
	Components.createSlider(combatC, "Strafe Radius", 5, 20, 10, function(v) State.Combat.StrafeRadius = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Feedback")
	Components.createToggle(combatC, "Combo Counter", function(v) State.Combat.ComboCounter = v end)
	Components.createToggle(combatC, "Damage Indicator", function(v) State.Combat.DamageIndicator = v end)
	
	-- ---------------------------------------------------------------------------
	-- MOVEMENT TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(moveC, "Flight")
	Components.createToggle(moveC, "Fly", function(v) State.Movement.Fly = v end)
	Components.createSlider(moveC, "Fly Speed", 10, 300, 50, function(v) State.Movement.FlySpeed = v end)
	Components.createToggle(moveC, "Fly Legit", function(v) State.Movement.FlyLegit = v end)
	Components.createToggle(moveC, "Noclip", function(v) State.Movement.Noclip = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Speed & Jump")
	Components.createToggle(moveC, "Speed", function(v) State.Movement.Speed = v if not v then local h = getHumanoid() if h then h.WalkSpeed = 16 end end end)
	Components.createSlider(moveC, "Speed Value", 16, 500, 16, function(v) State.Movement.SpeedValue = v end)
	Components.createToggle(moveC, "Speed Legit", function(v) State.Movement.SpeedLegit = v end)
	Components.createToggle(moveC, "Jump Power", function(v) State.Movement.JumpPower = v if not v then local h = getHumanoid() if h then h.JumpPower = 50 end end end)
	Components.createSlider(moveC, "Jump Value", 50, 500, 50, function(v) State.Movement.JumpValue = v end)
	Components.createToggle(moveC, "Infinite Jump", function(v) State.Movement.InfiniteJump = v end)
	Components.createToggle(moveC, "Bunny Hop", function(v) State.Movement.BunnyHop = v end)
	Components.createToggle(moveC, "Long Jump", function(v) State.Movement.LongJump = v end)
	Components.createSlider(moveC, "Long Jump Force", 50, 300, 100, function(v) State.Movement.LongJumpForce = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Movement Mods")
	Components.createToggle(moveC, "Speed Glide", function(v) State.Movement.SpeedGlide = v end)
	Components.createSlider(moveC, "Glide Speed", 1, 30, 10, function(v) State.Movement.GlideSpeed = v end)
	Components.createToggle(moveC, "Dash (Q)", function(v) State.Movement.Dash = v end)
	Components.createSlider(moveC, "Dash Force", 50, 500, 100, function(v) State.Movement.DashForce = v end)
	Components.createToggle(moveC, "Air Control", function(v) State.Movement.AirControl = v end)
	Components.createToggle(moveC, "Spider (Wall Climb)", function(v) State.Movement.Spider = v end)
	Components.createSlider(moveC, "Spider Speed", 5, 30, 10, function(v) State.Movement.SpiderSpeed = v end)
	Components.createToggle(moveC, "Edge Jump", function(v) State.Movement.EdgeJump = v end)
	Components.createToggle(moveC, "Safe Walk", function(v) State.Movement.SafeWalk = v end)
	Components.createToggle(moveC, "Strafe Speed", function(v) State.Movement.Strafe = v end)
	Components.createSlider(moveC, "Strafe Value", 20, 100, 50, function(v) State.Movement.StrafeSpeed = v end)
	Components.createToggle(moveC, "Auto Jump Reset", function(v) State.Movement.AutoJumpReset = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Teleport")
	Components.createToggle(moveC, "Click TP", function(v) State.Movement.ClickTP = v end)
	Components.createToggle(moveC, "Anti Void", function(v) State.Movement.AntiVoid = v end)
	Components.createSlider(moveC, "Void Height", -500, 0, -100, function(v) State.Movement.VoidHeight = v end)
	Components.createToggle(moveC, "Anchor", function(v) State.Movement.Anchor = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Advanced")
	Components.createToggle(moveC, "Spin Bot", function(v) State.Movement.SpinBot = v end)
	Components.createSlider(moveC, "Spin Speed", 5, 50, 20, function(v) State.Movement.SpinSpeed = v end)
	Components.createToggle(moveC, "Fake Lag", function(v) State.Movement.FakeLag = v end)
	Components.createSlider(moveC, "Lag Intensity", 1, 10, 5, function(v) State.Movement.LagIntensity = v end)
	
	-- ---------------------------------------------------------------------------
	-- ESP TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(espC, "Player ESP")
	Components.createToggle(espC, "Name ESP", function(v) State.ESP.NameESP = v end)
	Components.createToggle(espC, "Box ESP", function(v) State.ESP.BoxESP = v end)
	Components.createToggle(espC, "Health ESP", function(v) State.ESP.HealthESP = v end)
	Components.createToggle(espC, "Health Bar", function(v) State.ESP.HealthBar = v end)
	Components.createToggle(espC, "Distance ESP", function(v) State.ESP.DistanceESP = v end)
	Components.createToggle(espC, "Weapon ESP", function(v) State.ESP.WeaponESP = v end)
	Components.createToggle(espC, "Tracers", function(v) State.ESP.Tracers = v end)
	Components.createToggle(espC, "Skeleton ESP", function(v) State.ESP.SkeletonESP = v end)
	Components.createToggle(espC, "Offscreen Arrows", function(v) State.ESP.OffscreenArrows = v end)
	Components.createToggle(espC, "Chams", function(v) State.ESP.Chams = v updateChams() end)
	Components.createDivider(espC)
	Components.createSection(espC, "Other ESP")
	Components.createToggle(espC, "NPC ESP", function(v) State.ESP.NPCESP = v end)
	Components.createToggle(espC, "Item ESP", function(v) State.ESP.ItemESP = v end)
	Components.createDivider(espC)
	Components.createSection(espC, "Settings")
	Components.createSlider(espC, "Max Distance", 100, 2000, 1000, function(v) State.ESP.MaxDistance = v end)
	Components.createToggle(espC, "Team Check", function(v) State.ESP.TeamCheck = v end)
	Components.createLabel(espC, "Note: ESP requires executor with Drawing API")
	
	-- ---------------------------------------------------------------------------
	-- VISUALS TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(visC, "Lighting")
	Components.createToggle(visC, "Fullbright", function(v) State.Visuals.Fullbright = v if v then Lighting.Ambient = Color3.new(1, 1, 1) Lighting.Brightness = 2 else Lighting.Ambient = OriginalLighting.Ambient Lighting.Brightness = OriginalLighting.Brightness end end)
	Components.createToggle(visC, "No Fog", function(v) State.Visuals.NoFog = v if v then Lighting.FogEnd = 1e10 else Lighting.FogEnd = OriginalLighting.FogEnd end end)
	Components.createToggle(visC, "No Shadows", function(v) State.Visuals.NoShadows = v Lighting.GlobalShadows = not v end)
	Components.createToggle(visC, "Ambient Color", function(v) State.Visuals.AmbientColor = v if not v then Lighting.Ambient = OriginalLighting.Ambient Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient end end)
	Components.createSlider(visC, "Ambient R", 0, 255, 128, function(v) State.Visuals.AmbientR = v end)
	Components.createSlider(visC, "Ambient G", 0, 255, 128, function(v) State.Visuals.AmbientG = v end)
	Components.createSlider(visC, "Ambient B", 0, 255, 128, function(v) State.Visuals.AmbientB = v end)
	Components.createDivider(visC)
	Components.createSection(visC, "Crosshair")
	Components.createToggle(visC, "Custom Crosshair", function(v) State.Visuals.Crosshair = v end)
	Components.createSlider(visC, "Crosshair Size", 5, 30, 10, function(v) State.Visuals.CrosshairSize = v end)
	Components.createSlider(visC, "Crosshair Gap", 0, 20, 5, function(v) State.Visuals.CrosshairGap = v end)
	Components.createDivider(visC)
	Components.createSection(visC, "Camera")
	Components.createSlider(visC, "Camera FOV", 30, 120, 70, function(v) State.Visuals.CameraFOV = v camera.FieldOfView = v end)
	Components.createToggle(visC, "Third Person", function(v) State.Visuals.ThirdPerson = v if not v then player.CameraMaxZoomDistance = 128 player.CameraMinZoomDistance = 0.5 end end)
	Components.createSlider(visC, "Third Person Dist", 5, 30, 10, function(v) State.Visuals.ThirdPersonDist = v end)
	Components.createToggle(visC, "Freecam", function(v) State.Visuals.Freecam = v if v then FreecamPos = camera.CFrame.Position UIS.MouseBehavior = Enum.MouseBehavior.LockCenter else camera.CameraType = Enum.CameraType.Custom UIS.MouseBehavior = Enum.MouseBehavior.Default end end)
	Components.createSlider(visC, "Freecam Speed", 1, 20, 1, function(v) State.Visuals.FreecamSpeed = v end)
	Components.createDivider(visC)
	Components.createSection(visC, "Effects")
	Components.createToggle(visC, "X-Ray", function(v) State.Visuals.XRay = v if not v then for _, p in ipairs(workspace:GetDescendants()) do if p:IsA("BasePart") then p.LocalTransparencyModifier = 0 end end end end)
	Components.createSlider(visC, "X-Ray Transparency", 0, 100, 50, function(v) State.Visuals.XRayTransparency = v / 100 end)
	Components.createToggle(visC, "Trail Effect", function(v) State.Visuals.Trail = v if not v then for _, data in ipairs(TrailParts) do data.part:Destroy() end TrailParts = {} end end)
	Components.createSlider(visC, "Trail Lifetime", 1, 10, 1, function(v) State.Visuals.TrailLifetime = v end)
	Components.createToggle(visC, "Radar", function(v) State.Visuals.Radar = v end)
	Components.createSlider(visC, "Radar Size", 100, 300, 150, function(v) State.Visuals.RadarSize = v end)
	Components.createToggle(visC, "Screenshot Mode", function(v) State.Visuals.ScreenshotMode = v end)
	
	-- ---------------------------------------------------------------------------
	-- WORLD TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(worldC, "Environment")
	Components.createSlider(worldC, "Time of Day", 0, 24, 14, function(v) State.World.TimeOfDay = v Lighting.ClockTime = v end)
	Components.createSlider(worldC, "Gravity", 0, 500, 196, function(v) State.World.Gravity = v workspace.Gravity = v end)
	Components.createDivider(worldC)
	Components.createSection(worldC, "Terrain")
	Components.createToggle(worldC, "Remove Grass", function(v) State.World.RemoveGrass = v local t = workspace:FindFirstChildOfClass("Terrain") if t then t.Decoration = not v end end)
	Components.createDivider(worldC)
	Components.createSection(worldC, "Tools")
	Components.createToggle(worldC, "Delete Mode (Click)", function(v) State.World.DeleteMode = v end)
	
	-- ---------------------------------------------------------------------------
	-- PLAYER TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(playerC, "Character")
	Components.createToggle(playerC, "God Mode", function(v) State.Player.GodMode = v end)
	Components.createToggle(playerC, "No Ragdoll", function(v) State.Player.NoRagdoll = v end)
	Components.createToggle(playerC, "Auto Respawn", function(v) State.Player.AutoRespawn = v end)
	Components.createDivider(playerC)
	Components.createSection(playerC, "Invisibility")
	Components.createLabel(playerC, "Model moves away, hitbox stays.")
	Components.createToggle(playerC, "Invisibility", function(v) State.Player.Invisibility = v if v then InvisSystem:Enable() else InvisSystem:Disable() end end)
	Components.createSlider(playerC, "Invis Offset", 50, 500, 100, function(v) State.Player.InvisOffset = v end)
	Components.createDivider(playerC)
	Components.createSection(playerC, "Weapon")
	Components.createToggle(playerC, "No Recoil", function(v) State.Player.NoRecoil = v end)
	Components.createToggle(playerC, "No Spread", function(v) State.Player.NoSpread = v end)
	Components.createToggle(playerC, "Infinite Stamina", function(v) State.Player.InfiniteStamina = v end)
	
	-- ---------------------------------------------------------------------------
	-- TROLL TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(trollC, "Follow / Orbit")
	Components.createToggle(trollC, "Annoy Player", function(v) State.Troll.AnnoyPlayer = v end)
	Components.createToggle(trollC, "Orbit Player", function(v) State.Troll.OrbitPlayer = v end)
	Components.createSlider(trollC, "Orbit Radius", 5, 30, 10, function(v) State.Troll.OrbitRadius = v end)
	Components.createSlider(trollC, "Orbit Speed", 1, 10, 2, function(v) State.Troll.OrbitSpeed = v end)
	Components.createDivider(trollC)
	Components.createSection(trollC, "Character Troll")
	Components.createToggle(trollC, "Fling", function(v) State.Troll.Fling = v end)
	Components.createSlider(trollC, "Fling Power", 100, 1000, 500, function(v) State.Troll.FlingPower = v end)
	Components.createToggle(trollC, "Headless", function(v) State.Troll.Headless = v end)
	Components.createDivider(trollC)
	Components.createSection(trollC, "Info")
	Components.createLabel(trollC, "Type /target [name] in chat to set target")
	
	-- ---------------------------------------------------------------------------
	-- MISC TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(miscC, "HUD Elements")
	Components.createToggle(miscC, "Watermark", function(v) State.Misc.Watermark = v end)
	Components.createToggle(miscC, "FPS Counter", function(v) State.Misc.FPSCounter = v end)
	Components.createToggle(miscC, "Ping Display", function(v) State.Misc.PingDisplay = v end)
	Components.createToggle(miscC, "Player Count", function(v) State.Misc.PlayerCount = v end)
	Components.createToggle(miscC, "Velocity Display", function(v) State.Misc.VelocityDisplay = v end)
	Components.createToggle(miscC, "Target Info", function(v) State.Misc.TargetInfo = v end)
	Components.createToggle(miscC, "Keybinds Display", function(v) State.Misc.KeybindsDisplay = v end)
	Components.createDivider(miscC)
	Components.createSection(miscC, "Utility")
	Components.createToggle(miscC, "Anti AFK", function(v) State.Misc.AntiAFK = v end)
	Components.createToggle(miscC, "Chat Spam", function(v) State.Misc.ChatSpam = v end)
	Components.createSlider(miscC, "Spam Delay", 1, 10, 2, function(v) State.Misc.SpamDelay = v end)
	Components.createToggle(miscC, "Notifications", function(v) State.Misc.Notifications = v end)
	Components.createDivider(miscC)
	Components.createSection(miscC, "Server")
	Components.createToggle(miscC, "Server Hop", function(v) if v then pcall(function() local s = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) for _, srv in ipairs(s.data) do if srv.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id) break end end end) end end)
	Components.createToggle(miscC, "Rejoin", function(v) if v then TeleportService:Teleport(game.PlaceId) end end)
	
	-- Activate first tab
	Tabs.activate(combatT, combatC)
	
	-- ---------------------------------------------------------------------------
	-- MENU TOGGLE
	-- ---------------------------------------------------------------------------
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == State.Settings.MenuKey then
			local show = not main.Visible
			main.Visible = show
			if show then
				PrevMouseState.behavior = UIS.MouseBehavior
				PrevMouseState.icon = UIS.MouseIconEnabled
				UIS.MouseBehavior = Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = true
				main.Size = UDim2.new(0, 0, 0, 0)
				tween(main, {Size = UDim2.new(0, 950, 0, 650)}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
			else
				UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = PrevMouseState.icon ~= false
			end
		end
	end)
	
	-- Dragging
	local dragging, dragStart, startPos = false, nil, nil
	hdr.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = main.Position
			inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	
	-- Character Events
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then
			if State.Movement.Speed then h.WalkSpeed = State.Movement.SpeedValue end
			if State.Movement.JumpPower then h.JumpPower = State.Movement.JumpValue end
		end
		if State.ESP.Chams then updateChams() end
		if State.Player.Invisibility then task.wait(0.2) InvisSystem:Enable() end
	end)
	
	Players.PlayerAdded:Connect(function() task.wait(1) if State.ESP.Chams then updateChams() end end)
	Players.PlayerRemoving:Connect(function(p) EntityCache.players[p.Name] = nil BacktrackPositions[p.Name] = nil end)
	
	notify("Vertex Hub", "Loaded! Press M to toggle menu.", 3)
	print("[Vertex Hub v2] Loaded successfully! Press M to toggle menu.")
end
	
	-- ---------------------------------------------------------------------------
	-- COMBAT TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(combatC, "Aim Assist")
	Components.createToggle(combatC, "Aim Assist", function(v) State.Combat.AimAssist = v end)
	Components.createSlider(combatC, "Smoothness", 1, 100, 15, function(v) State.Combat.AimSmoothness = v / 200 end)
	Components.createSlider(combatC, "FOV", 50, 600, 150, function(v) State.Combat.AimFOV = v end)
	Components.createToggle(combatC, "Show FOV Circle", function(v) State.Combat.ShowFOVCircle = v end)
	Components.createToggle(combatC, "Prediction", function(v) State.Combat.AimPrediction = v end)
	Components.createSlider(combatC, "Prediction Amount", 1, 50, 10, function(v) State.Combat.PredictionAmount = v / 100 end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Aim Lock")
	Components.createToggle(combatC, "Aim Lock (Hard)", function(v) State.Combat.AimLock = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Silent Aim")
	Components.createToggle(combatC, "Silent Aim", function(v) State.Combat.SilentAim = v end)
	Components.createSlider(combatC, "Hit Chance", 0, 100, 100, function(v) State.Combat.SilentAimHitChance = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Kill Aura")
	Components.createToggle(combatC, "Kill Aura", function(v) State.Combat.KillAura = v end)
	Components.createSlider(combatC, "Range", 5, 50, 15, function(v) State.Combat.KillAuraRange = v end)
	Components.createSlider(combatC, "CPS", 1, 20, 10, function(v) State.Combat.KillAuraCPS = v end)
	Components.createToggle(combatC, "Legit Mode", function(v) State.Combat.KillAuraLegit = v end)
	Components.createToggle(combatC, "Target Players", function(v) State.Combat.KillAuraPlayers = v end)
	Components.createToggle(combatC, "Target NPCs", function(v) State.Combat.KillAuraNPCs = v end)
	Components.createToggle(combatC, "Wall Check", function(v) State.Combat.KillAuraWallCheck = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Auto Clicker")
	Components.createToggle(combatC, "Auto Clicker", function(v) State.Combat.AutoClicker = v end)
	Components.createSlider(combatC, "CPS", 1, 20, 12, function(v) State.Combat.AutoClickerCPS = v end)
	Components.createToggle(combatC, "Jitter", function(v) State.Combat.AutoClickerJitter = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Extra Combat")
	Components.createToggle(combatC, "Combo Counter", function(v) State.Combat.ComboCounter = v end)
	Components.createToggle(combatC, "Damage Indicator", function(v) State.Combat.DamageIndicator = v end)
	Components.createToggle(combatC, "Triggerbot", function(v) State.Combat.Triggerbot = v end)
	Components.createSlider(combatC, "Trigger Delay", 0, 100, 10, function(v) State.Combat.TriggerbotDelay = v / 100 end)
	Components.createToggle(combatC, "Auto Parry", function(v) State.Combat.AutoParry = v end)
	Components.createToggle(combatC, "Hitbox Expander", function(v) State.Combat.HitboxExpander = v end)
	Components.createSlider(combatC, "Hitbox Size", 2, 20, 5, function(v) State.Combat.HitboxSize = v end)
	Components.createToggle(combatC, "Target Strafe", function(v) State.Combat.TargetStrafe = v end)
	Components.createSlider(combatC, "Strafe Radius", 5, 20, 10, function(v) State.Combat.StrafeRadius = v end)
	
	-- ---------------------------------------------------------------------------
	-- MOVEMENT TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(moveC, "Flight")
	Components.createToggle(moveC, "Fly", function(v) State.Movement.Fly = v end)
	Components.createSlider(moveC, "Fly Speed", 10, 300, 50, function(v) State.Movement.FlySpeed = v end)
	Components.createToggle(moveC, "Legit Fly", function(v) State.Movement.FlyLegit = v end)
	Components.createToggle(moveC, "Noclip", function(v) State.Movement.Noclip = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Speed & Jump")
	Components.createToggle(moveC, "Speed", function(v) State.Movement.Speed = v if not v then local h = getHumanoid() if h then h.WalkSpeed = 16 end end end)
	Components.createSlider(moveC, "Speed Value", 16, 500, 16, function(v) State.Movement.SpeedValue = v end)
	Components.createToggle(moveC, "Legit Speed", function(v) State.Movement.SpeedLegit = v end)
	Components.createToggle(moveC, "Jump Power", function(v) State.Movement.JumpPower = v if not v then local h = getHumanoid() if h then h.JumpPower = 50 end end end)
	Components.createSlider(moveC, "Jump Value", 50, 500, 50, function(v) State.Movement.JumpValue = v end)
	Components.createToggle(moveC, "Infinite Jump", function(v) State.Movement.InfiniteJump = v end)
	Components.createToggle(moveC, "Bunny Hop", function(v) State.Movement.BunnyHop = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Advanced Movement")
	Components.createToggle(moveC, "Spider (Wall Climb)", function(v) State.Movement.Spider = v end)
	Components.createSlider(moveC, "Spider Speed", 5, 50, 10, function(v) State.Movement.SpiderSpeed = v end)
	Components.createToggle(moveC, "Edge Jump", function(v) State.Movement.EdgeJump = v end)
	Components.createToggle(moveC, "Safe Walk", function(v) State.Movement.SafeWalk = v end)
	Components.createToggle(moveC, "Strafe Speed", function(v) State.Movement.Strafe = v end)
	Components.createSlider(moveC, "Strafe Value", 20, 100, 50, function(v) State.Movement.StrafeSpeed = v end)
	Components.createToggle(moveC, "Auto Jump Reset", function(v) State.Movement.AutoJumpReset = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Dash & Glide")
	Components.createToggle(moveC, "Dash (Q)", function(v) State.Movement.Dash = v end)
	Components.createSlider(moveC, "Dash Force", 50, 300, 100, function(v) State.Movement.DashForce = v end)
	Components.createSlider(moveC, "Dash Cooldown", 1, 10, 1, function(v) State.Movement.DashCooldown = v / 10 end)
	Components.createToggle(moveC, "Long Jump", function(v) State.Movement.LongJump = v end)
	Components.createSlider(moveC, "Long Jump Force", 50, 300, 100, function(v) State.Movement.LongJumpForce = v end)
	Components.createToggle(moveC, "Speed Glide", function(v) State.Movement.SpeedGlide = v end)
	Components.createSlider(moveC, "Glide Speed", 1, 20, 10, function(v) State.Movement.GlideSpeed = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Teleport")
	Components.createToggle(moveC, "Click TP", function(v) State.Movement.ClickTP = v end)
	Components.createToggle(moveC, "Anti Void", function(v) State.Movement.AntiVoid = v end)
	Components.createSlider(moveC, "Void Height", -500, 0, -100, function(v) State.Movement.VoidHeight = v end)
	Components.createToggle(moveC, "Anchor", function(v) State.Movement.Anchor = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Misc Movement")
	Components.createToggle(moveC, "Air Control", function(v) State.Movement.AirControl = v end)
	Components.createToggle(moveC, "Spin Bot", function(v) State.Movement.SpinBot = v end)
	Components.createSlider(moveC, "Spin Speed", 1, 50, 20, function(v) State.Movement.SpinSpeed = v end)
	Components.createToggle(moveC, "Fake Lag", function(v) State.Movement.FakeLag = v end)
	Components.createSlider(moveC, "Lag Intensity", 1, 10, 5, function(v) State.Movement.LagIntensity = v end)
	
	-- ---------------------------------------------------------------------------
	-- ESP TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(espC, "Player ESP")
	Components.createToggle(espC, "Name ESP", function(v) State.ESP.NameESP = v end)
	Components.createToggle(espC, "Box ESP", function(v) State.ESP.BoxESP = v end)
	Components.createToggle(espC, "Health ESP", function(v) State.ESP.HealthESP = v end)
	Components.createToggle(espC, "Health Bar", function(v) State.ESP.HealthBar = v end)
	Components.createToggle(espC, "Distance ESP", function(v) State.ESP.DistanceESP = v end)
	Components.createToggle(espC, "Weapon ESP", function(v) State.ESP.WeaponESP = v end)
	Components.createToggle(espC, "Tracers", function(v) State.ESP.Tracers = v end)
	Components.createToggle(espC, "Skeleton ESP", function(v) State.ESP.SkeletonESP = v end)
	Components.createToggle(espC, "Offscreen Arrows", function(v) State.ESP.OffscreenArrows = v end)
	Components.createToggle(espC, "Chams", function(v) State.ESP.Chams = v updateChams() end)
	Components.createDivider(espC)
	Components.createSection(espC, "Entity ESP")
	Components.createToggle(espC, "NPC ESP", function(v) State.ESP.NPCESP = v end)
	Components.createToggle(espC, "Item ESP", function(v) State.ESP.ItemESP = v end)
	Components.createDivider(espC)
	Components.createSection(espC, "ESP Settings")
	Components.createSlider(espC, "Max Distance", 100, 2000, 1000, function(v) State.ESP.MaxDistance = v end)
	Components.createToggle(espC, "Team Check", function(v) State.ESP.TeamCheck = v end)
	if not DrawingEnabled then
		Components.createLabel(espC, "⚠ Drawing API not available - ESP disabled")
	end
	
	-- ---------------------------------------------------------------------------
	-- VISUALS TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(visC, "Lighting")
	Components.createToggle(visC, "Fullbright", function(v)
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
	Components.createToggle(visC, "No Fog", function(v)
		State.Visuals.NoFog = v
		if v then Lighting.FogEnd = 1e10 Lighting.FogStart = 1e10 else Lighting.FogEnd = OriginalLighting.FogEnd Lighting.FogStart = OriginalLighting.FogStart end
	end)
	Components.createToggle(visC, "No Shadows", function(v) State.Visuals.NoShadows = v Lighting.GlobalShadows = not v end)
	Components.createToggle(visC, "Ambient Color", function(v) State.Visuals.AmbientColor = v if not v then Lighting.Ambient = OriginalLighting.Ambient Lighting.OutdoorAmbient = OriginalLighting.OutdoorAmbient end end)
	Components.createSlider(visC, "Ambient R", 0, 255, 128, function(v) State.Visuals.AmbientR = v end)
	Components.createSlider(visC, "Ambient G", 0, 255, 128, function(v) State.Visuals.AmbientG = v end)
	Components.createSlider(visC, "Ambient B", 0, 255, 128, function(v) State.Visuals.AmbientB = v end)
	Components.createDivider(visC)
	Components.createSection(visC, "Crosshair")
	Components.createToggle(visC, "Custom Crosshair", function(v) State.Visuals.Crosshair = v end)
	Components.createSlider(visC, "Crosshair Size", 5, 30, 10, function(v) State.Visuals.CrosshairSize = v end)
	Components.createSlider(visC, "Crosshair Gap", 0, 20, 5, function(v) State.Visuals.CrosshairGap = v end)
	Components.createDivider(visC)
	Components.createSection(visC, "Camera")
	Components.createSlider(visC, "Camera FOV", 30, 120, 70, function(v) State.Visuals.CameraFOV = v camera.FieldOfView = v end)
	Components.createToggle(visC, "Third Person", function(v) State.Visuals.ThirdPerson = v if not v then player.CameraMaxZoomDistance = 128 player.CameraMinZoomDistance = 0.5 end end)
	Components.createSlider(visC, "3rd Person Dist", 5, 50, 10, function(v) State.Visuals.ThirdPersonDist = v end)
	Components.createToggle(visC, "Freecam", function(v)
		State.Visuals.Freecam = v
		if v then FreecamPos = camera.CFrame.Position UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
		else camera.CameraType = Enum.CameraType.Custom UIS.MouseBehavior = Enum.MouseBehavior.Default end
	end)
	Components.createSlider(visC, "Freecam Speed", 1, 20, 1, function(v) State.Visuals.FreecamSpeed = v end)
	Components.createDivider(visC)
	Components.createSection(visC, "Effects")
	Components.createToggle(visC, "Trail Effect", function(v) State.Visuals.Trail = v if not v then for _, t in ipairs(TrailParts) do t.part:Destroy() end TrailParts = {} end end)
	Components.createSlider(visC, "Trail Lifetime", 1, 10, 1, function(v) State.Visuals.TrailLifetime = v end)
	Components.createToggle(visC, "X-Ray", function(v) State.Visuals.XRay = v end)
	Components.createSlider(visC, "X-Ray Transparency", 0, 100, 50, function(v) State.Visuals.XRayTransparency = v / 100 end)
	Components.createToggle(visC, "Radar/Minimap", function(v) State.Visuals.Radar = v end)
	Components.createSlider(visC, "Radar Size", 100, 250, 150, function(v) State.Visuals.RadarSize = v end)
	Components.createToggle(visC, "Screenshot Mode", function(v) State.Visuals.ScreenshotMode = v end)
	
	-- ---------------------------------------------------------------------------
	-- WORLD TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(worldC, "Environment")
	Components.createSlider(worldC, "Time of Day", 0, 24, 14, function(v) State.World.TimeOfDay = v Lighting.ClockTime = v end)
	Components.createSlider(worldC, "Gravity", 0, 500, 196, function(v) State.World.Gravity = v workspace.Gravity = v end)
	Components.createDivider(worldC)
	Components.createSection(worldC, "Terrain")
	Components.createToggle(worldC, "Remove Grass", function(v)
		State.World.RemoveGrass = v
		local t = workspace:FindFirstChildOfClass("Terrain")
		if t then t.Decoration = not v end
		for _, o in ipairs(workspace:GetDescendants()) do
			if o:IsA("BasePart") and (o.Name:lower():find("grass") or o.Name:lower():find("foliage")) then
				o.Transparency = v and 1 or 0
			end
		end
	end)
	Components.createDivider(worldC)
	Components.createSection(worldC, "Tools")
	Components.createToggle(worldC, "Delete Mode (Click)", function(v) State.World.DeleteMode = v end)
	
	-- ---------------------------------------------------------------------------
	-- PLAYER TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(playerC, "Character")
	Components.createToggle(playerC, "God Mode", function(v) State.Player.GodMode = v end)
	Components.createToggle(playerC, "No Ragdoll", function(v) State.Player.NoRagdoll = v end)
	Components.createToggle(playerC, "Auto Respawn", function(v) State.Player.AutoRespawn = v end)
	Components.createDivider(playerC)
	Components.createSection(playerC, "Invisibility")
	Components.createLabel(playerC, "Model moves away, hitbox stays")
	Components.createToggle(playerC, "Invisibility", function(v) State.Player.Invisibility = v if v then InvisSystem:Enable() else InvisSystem:Disable() end end)
	Components.createSlider(playerC, "Invis Offset", 50, 500, 100, function(v) State.Player.InvisOffset = v end)
	Components.createDivider(playerC)
	Components.createSection(playerC, "Weapon")
	Components.createToggle(playerC, "No Recoil", function(v) State.Player.NoRecoil = v end)
	Components.createToggle(playerC, "No Spread", function(v) State.Player.NoSpread = v end)
	Components.createToggle(playerC, "Infinite Stamina", function(v) State.Player.InfiniteStamina = v end)
	
	-- ---------------------------------------------------------------------------
	-- TROLL TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(trollC, "Follow / Orbit")
	Components.createToggle(trollC, "Annoy Player", function(v) State.Troll.AnnoyPlayer = v end)
	Components.createToggle(trollC, "Orbit Player", function(v) State.Troll.OrbitPlayer = v end)
	Components.createSlider(trollC, "Orbit Radius", 5, 30, 10, function(v) State.Troll.OrbitRadius = v end)
	Components.createSlider(trollC, "Orbit Speed", 1, 10, 2, function(v) State.Troll.OrbitSpeed = v end)
	Components.createDivider(trollC)
	Components.createSection(trollC, "Character Troll")
	Components.createToggle(trollC, "Fling", function(v) State.Troll.Fling = v end)
	Components.createSlider(trollC, "Fling Power", 100, 1000, 500, function(v) State.Troll.FlingPower = v end)
	Components.createToggle(trollC, "Headless", function(v) State.Troll.Headless = v end)
	Components.createDivider(trollC)
	Components.createSection(trollC, "Info")
	Components.createLabel(trollC, "Type /target [name] in chat to set target")
	
	-- ---------------------------------------------------------------------------
	-- MISC TAB
	-- ---------------------------------------------------------------------------
	Components.createSection(miscC, "HUD Elements")
	Components.createToggle(miscC, "Watermark", function(v) State.Misc.Watermark = v end)
	Components.createToggle(miscC, "FPS Counter", function(v) State.Misc.FPSCounter = v end)
	Components.createToggle(miscC, "Ping Display", function(v) State.Misc.PingDisplay = v end)
	Components.createToggle(miscC, "Player Count", function(v) State.Misc.PlayerCount = v end)
	Components.createToggle(miscC, "Velocity Display", function(v) State.Misc.VelocityDisplay = v end)
	Components.createToggle(miscC, "Target Info", function(v) State.Misc.TargetInfo = v end)
	Components.createToggle(miscC, "Keybinds Display", function(v) State.Misc.KeybindsDisplay = v end)
	Components.createDivider(miscC)
	Components.createSection(miscC, "Utility")
	Components.createToggle(miscC, "Anti AFK", function(v) State.Misc.AntiAFK = v end)
	Components.createToggle(miscC, "Chat Spam", function(v) State.Misc.ChatSpam = v end)
	Components.createSlider(miscC, "Spam Delay", 1, 10, 2, function(v) State.Misc.SpamDelay = v end)
	Components.createToggle(miscC, "Notifications", function(v) State.Misc.Notifications = v end)
	Components.createDivider(miscC)
	Components.createSection(miscC, "Server")
	Components.createToggle(miscC, "Server Hop", function(v)
		if v then
			pcall(function()
				local s = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
				for _, srv in ipairs(s.data) do
					if srv.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id) break end
				end
			end)
		end
	end)
	Components.createToggle(miscC, "Rejoin", function(v) if v then TeleportService:Teleport(game.PlaceId) end end)
	
	-- Activate first tab
	Tabs.activate(combatT, combatC)
	
	-- ---------------------------------------------------------------------------
	-- MENU TOGGLE
	-- ---------------------------------------------------------------------------
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == State.Settings.MenuKey then
			local show = not main.Visible
			main.Visible = show
			if show then
				PrevMouseState.behavior = UIS.MouseBehavior
				PrevMouseState.icon = UIS.MouseIconEnabled
				UIS.MouseBehavior = Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = true
				main.Size = UDim2.new(0, 0, 0, 0)
				tween(main, {Size = UDim2.new(0, 950, 0, 650)}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
			else
				UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = PrevMouseState.icon ~= false
			end
		end
	end)
	
	-- Dragging
	local dragging, dragStart, startPos = false, nil, nil
	hdr.InputBegan:Connect(function(inp)
		if inp.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = inp.Position
			startPos = main.Position
			inp.Changed:Connect(function() if inp.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(inp)
		if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
			local d = inp.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end)
	
	-- Character Events
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then
			if State.Movement.Speed then h.WalkSpeed = State.Movement.SpeedValue end
			if State.Movement.JumpPower then h.JumpPower = State.Movement.JumpValue end
		end
		if State.ESP.Chams then updateChams() end
		if State.Player.Invisibility then task.wait(0.2) InvisSystem:Enable() end
	end)
	
	Players.PlayerAdded:Connect(function() task.wait(1) if State.ESP.Chams then updateChams() end end)
	Players.PlayerRemoving:Connect(function(p) EntityCache.players[p.Name] = nil BacktrackPositions[p.Name] = nil end)
	
	-- Done
	notify("Vertex Hub V2", "Loaded! Press M to toggle", 3)
	print("[Vertex Hub V2] Loaded successfully! Press M to toggle menu.")
end
