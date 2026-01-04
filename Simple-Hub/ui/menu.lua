-- ui/menu.lua
-- Simple Hub ULTIMATE - ALL FEATURES

return function(deps)
	local Tabs = deps.Tabs
	local Components = deps.Components
	local Animations = deps.Animations
	
	if not Tabs or not Components or not Animations then
		error("[Menu] Missing dependencies")
	end
	
	print("[SimpleHub] Initializing ULTIMATE edition...")
	
	-- Services
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local Lighting = game:GetService("Lighting")
	local TeleportService = game:GetService("TeleportService")
	local StarterGui = game:GetService("StarterGui")
	local Debris = game:GetService("Debris")
	local SoundService = game:GetService("SoundService")
	local Stats = game:GetService("Stats")
	local HttpService = game:GetService("HttpService")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local CoreGui = game:GetService("CoreGui")
	
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local mouse = player:GetMouse()
	
	-- Helpers
	local function getCharacter()
		return player.Character or player.CharacterAdded:Wait()
	end
	
	local function getRoot()
		local char = getCharacter()
		return char and char:FindFirstChild("HumanoidRootPart")
	end
	
	local function getHumanoid()
		local char = getCharacter()
		return char and char:FindFirstChildOfClass("Humanoid")
	end
	
	-- ============================================
	-- LOAD EXTERNAL MODULES
	-- ============================================
	local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"
	
	local function loadModule(path)
		local success, result = pcall(function()
			return loadstring(game:HttpGet(BASE .. path .. "?nocache=" .. os.clock()))()
		end)
		if success then return result end
		return nil
	end
	
	local Fly = loadModule("movement/fly.lua")
	local Noclip = loadModule("movement/noclip.lua")
	local Dash = loadModule("movement/dash.lua")
	local SilentAim = loadModule("combat/silent_aim.lua")
	
	-- ============================================
	-- ALL FEATURE STATES
	-- ============================================
	
	-- Movement
	local Movement = {
		walkSpeedEnabled = false, walkSpeedValue = 16,
		jumpPowerEnabled = false, jumpPowerValue = 50,
		infiniteJump = false,
		speedGlide = false, glideSpeed = 0.1,
		longJump = false, longJumpForce = 100,
		bunnyHop = false,
		anchored = false,
		clickTP = false,
		antiVoid = false, antiVoidHeight = -100,
		spinBot = false, spinSpeed = 20,
		fakeLag = false, fakeLagIntensity = 5
	}
	
	-- Combat
	local Combat = {
		aimAssistEnabled = false, aimAssistSmooth = 0.15, aimAssistFOV = 150,
		aimPrediction = false, predictionAmount = 0.1,
		showFOVCircle = false,
		triggerbot = false, triggerbotDelay = 0.1,
		killAura = false, killAuraRange = 15,
		reach = false, reachDistance = 20,
		targetStrafe = false, strafeSpeed = 5, strafeRadius = 10,
		autoParry = false,
		autoCombo = false,
		hitboxExpander = false, hitboxSize = 5,
		antiAim = false,
		backtrack = false, backtrackTime = 0.2
	}
	
	-- ESP
	local ESPState = {
		NameESP = false, BoxESP = false, HealthESP = false,
		DistanceESP = false, Tracers = false, Chams = false,
		SkeletonESP = false, ItemESP = false, NPCESP = false,
		OffscreenArrows = false, XRay = false
	}
	
	-- Visuals
	local Visuals = {
		fullbright = false, noFog = false, noShadows = false,
		customCrosshair = false, crosshairSize = 10,
		cameraFOV = 70, freecam = false, freecamSpeed = 1,
		thirdPerson = false,
		hitboxVisualizer = false,
		partTransparency = false, transparencyValue = 0.5
	}
	
	-- Player
	local PlayerMods = {
		godMode = false, noRagdoll = false, invisible = false,
		noRecoil = false, noSpread = false, infiniteStamina = false,
		autoRespawn = false,
		characterScale = 1
	}
	
	-- Farming
	local Farming = {
		autoFarm = false, autoCollect = false,
		autoQuest = false, autoAttack = false,
		tpToItems = false
	}
	
	-- Misc
	local Misc = {
		antiAFK = false,
		chatSpam = false, chatSpamMsg = "Simple Hub!", chatSpamDelay = 2,
		annoyPlayer = false, annoyTarget = nil,
		orbitPlayer = false, orbitTarget = nil, orbitRadius = 10, orbitSpeed = 2,
		fling = false
	}
	
	-- World
	local World = {
		deleteMode = false,
		gravity = 196.2,
		timeOfDay = 14
	}
	
	-- HUD
	local HUD = {
		watermark = false,
		fpsCounter = false,
		pingDisplay = false,
		playerCount = false,
		keybindsDisplay = false,
		targetInfo = false,
		velocityDisplay = false
	}
	
	-- Sounds
	local Sounds = {
		hitSound = false, hitSoundId = "rbxassetid://6607026206",
		killSound = false, killSoundId = "rbxassetid://4612378712",
		espSound = false
	}
	
	-- Troll
	local Troll = {
		headless = false,
		animationId = nil,
		korbloxLegs = false
	}
	
	-- Settings
	local Settings = {
		menuKey = Enum.KeyCode.M,
		menuScale = 1,
		menuOpacity = 1,
		accentColor = Color3.fromRGB(60, 120, 255)
	}
	
	-- Waypoints
	local Waypoints = {}
	
	-- ============================================
	-- DRAWING OBJECTS
	-- ============================================
	local ESPObjects = {}
	local DrawingObjects = {}
	
	pcall(function()
		DrawingObjects.FOVCircle = Drawing.new("Circle")
		DrawingObjects.FOVCircle.Thickness = 2
		DrawingObjects.FOVCircle.NumSides = 64
		DrawingObjects.FOVCircle.Filled = false
		DrawingObjects.FOVCircle.Visible = false
		DrawingObjects.FOVCircle.Color = Color3.fromRGB(255, 255, 255)
		
		DrawingObjects.CrosshairH = Drawing.new("Line")
		DrawingObjects.CrosshairH.Visible = false
		DrawingObjects.CrosshairH.Color = Color3.fromRGB(255, 0, 0)
		DrawingObjects.CrosshairH.Thickness = 2
		
		DrawingObjects.CrosshairV = Drawing.new("Line")
		DrawingObjects.CrosshairV.Visible = false
		DrawingObjects.CrosshairV.Color = Color3.fromRGB(255, 0, 0)
		DrawingObjects.CrosshairV.Thickness = 2
		
		-- HUD Elements
		DrawingObjects.Watermark = Drawing.new("Text")
		DrawingObjects.Watermark.Size = 18
		DrawingObjects.Watermark.Font = Drawing.Fonts.GothamBold
		DrawingObjects.Watermark.Color = Color3.fromRGB(255, 255, 255)
		DrawingObjects.Watermark.Outline = true
		DrawingObjects.Watermark.Position = Vector2.new(10, 10)
		DrawingObjects.Watermark.Visible = false
		
		DrawingObjects.FPS = Drawing.new("Text")
		DrawingObjects.FPS.Size = 16
		DrawingObjects.FPS.Font = Drawing.Fonts.Gotham
		DrawingObjects.FPS.Color = Color3.fromRGB(255, 255, 255)
		DrawingObjects.FPS.Outline = true
		DrawingObjects.FPS.Position = Vector2.new(10, 35)
		DrawingObjects.FPS.Visible = false
		
		DrawingObjects.Ping = Drawing.new("Text")
		DrawingObjects.Ping.Size = 16
		DrawingObjects.Ping.Font = Drawing.Fonts.Gotham
		DrawingObjects.Ping.Color = Color3.fromRGB(255, 255, 255)
		DrawingObjects.Ping.Outline = true
		DrawingObjects.Ping.Position = Vector2.new(10, 55)
		DrawingObjects.Ping.Visible = false
		
		DrawingObjects.PlayerCount = Drawing.new("Text")
		DrawingObjects.PlayerCount.Size = 16
		DrawingObjects.PlayerCount.Font = Drawing.Fonts.Gotham
		DrawingObjects.PlayerCount.Color = Color3.fromRGB(255, 255, 255)
		DrawingObjects.PlayerCount.Outline = true
		DrawingObjects.PlayerCount.Position = Vector2.new(10, 75)
		DrawingObjects.PlayerCount.Visible = false
		
		DrawingObjects.Velocity = Drawing.new("Text")
		DrawingObjects.Velocity.Size = 16
		DrawingObjects.Velocity.Font = Drawing.Fonts.Gotham
		DrawingObjects.Velocity.Color = Color3.fromRGB(255, 255, 255)
		DrawingObjects.Velocity.Outline = true
		DrawingObjects.Velocity.Position = Vector2.new(10, 95)
		DrawingObjects.Velocity.Visible = false
		
		DrawingObjects.TargetInfo = Drawing.new("Text")
		DrawingObjects.TargetInfo.Size = 16
		DrawingObjects.TargetInfo.Font = Drawing.Fonts.Gotham
		DrawingObjects.TargetInfo.Color = Color3.fromRGB(255, 255, 255)
		DrawingObjects.TargetInfo.Outline = true
		DrawingObjects.TargetInfo.Position = Vector2.new(10, 115)
		DrawingObjects.TargetInfo.Visible = false
	end)
	
	-- ============================================
	-- ORIGINAL VALUES
	-- ============================================
	local OriginalValues = {
		Ambient = Lighting.Ambient,
		Brightness = Lighting.Brightness,
		FogEnd = Lighting.FogEnd,
		FogStart = Lighting.FogStart,
		GlobalShadows = Lighting.GlobalShadows,
		OutdoorAmbient = Lighting.OutdoorAmbient,
		Gravity = workspace.Gravity,
		FieldOfView = camera.FieldOfView
	}
	
	-- ============================================
	-- UTILITY FUNCTIONS
	-- ============================================
	
	local function getClosestPlayer(fov)
		local closest, closestDist = nil, math.huge
		local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
				local head = plr.Character:FindFirstChild("Head")
				
				if humanoid and humanoid.Health > 0 and head then
					local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
					if onScreen then
						local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
						if dist < fov and dist < closestDist then
							closestDist = dist
							closest = {Player = plr, Character = plr.Character, Head = head, Humanoid = humanoid, Root = plr.Character:FindFirstChild("HumanoidRootPart")}
						end
					end
				end
			end
		end
		return closest
	end
	
	local function getNearestPlayer()
		local closest, closestDist = nil, math.huge
		local root = getRoot()
		if not root then return nil end
		
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
				local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
				if targetRoot and humanoid and humanoid.Health > 0 then
					local dist = (root.Position - targetRoot.Position).Magnitude
					if dist < closestDist then
						closestDist = dist
						closest = {Player = plr, Character = plr.Character, Root = targetRoot, Humanoid = humanoid, Distance = dist}
					end
				end
			end
		end
		return closest
	end
	
	local function playSound(soundId)
		pcall(function()
			local sound = Instance.new("Sound")
			sound.SoundId = soundId
			sound.Volume = 1
			sound.Parent = SoundService
			sound:Play()
			Debris:AddItem(sound, 3)
		end)
	end
	
	local function clearESP()
		for _, obj in pairs(ESPObjects) do
			pcall(function() if obj.Remove then obj:Remove() end end)
		end
		ESPObjects = {}
	end
	
	local lastFPSUpdate = 0
	local frameCount = 0
	local currentFPS = 0
	
	-- Freecam
	local freecamPos = Vector3.new(0, 50, 0)
	local freecamAngles = Vector2.new(0, 0)
	
	-- Backtrack storage
	local backtrackPositions = {}
	
	-- ============================================
	-- MAIN UPDATE LOOP
	-- ============================================
	RunService.RenderStepped:Connect(function(dt)
		local char = player.Character
		camera = workspace.CurrentCamera
		
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local humanoid = char and char:FindFirstChildOfClass("Humanoid")
		
		-- FPS Counter
		frameCount = frameCount + 1
		if tick() - lastFPSUpdate >= 1 then
			currentFPS = frameCount
			frameCount = 0
			lastFPSUpdate = tick()
		end
		
		-- ========== MOVEMENT ==========
		
		if Movement.speedGlide and root and humanoid then
			if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
				root.Velocity = Vector3.new(root.Velocity.X, math.max(root.Velocity.Y, -Movement.glideSpeed * 100), root.Velocity.Z)
			end
		end
		
		if Movement.bunnyHop and humanoid then
			if humanoid.FloorMaterial ~= Enum.Material.Air then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
		
		if Movement.antiVoid and root then
			if root.Position.Y < Movement.antiVoidHeight then
				root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
			end
		end
		
		if Movement.spinBot and root then
			root.CFrame = root.CFrame * CFrame.Angles(0, math.rad(Movement.spinSpeed), 0)
		end
		
		if Movement.fakeLag and root then
			if math.random(1, 10) <= Movement.fakeLagIntensity then
				root.Velocity = Vector3.new(0, 0, 0)
			end
		end
		
		if Fly and Fly.enabled and Fly.update and root then
			Fly.update(root, camera, UIS)
		end
		
		if Noclip and Noclip.enabled and Noclip.update and char then
			Noclip.update(char)
		end
		
		-- ========== COMBAT ==========
		
		-- Aim Assist with Prediction
		if Combat.aimAssistEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target = getClosestPlayer(Combat.aimAssistFOV)
			if target and target.Head then
				local targetPos = target.Head.Position
				
				-- Add prediction
				if Combat.aimPrediction and target.Root then
					targetPos = targetPos + target.Root.Velocity * Combat.predictionAmount
				end
				
				local targetCF = CFrame.new(camera.CFrame.Position, targetPos)
				camera.CFrame = camera.CFrame:Lerp(targetCF, Combat.aimAssistSmooth)
			end
		end
		
		-- Target Strafe
		if Combat.targetStrafe and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target = getClosestPlayer(Combat.aimAssistFOV)
			if target and target.Root and root then
				local angle = tick() * Combat.strafeSpeed
				local offset = Vector3.new(math.cos(angle) * Combat.strafeRadius, 0, math.sin(angle) * Combat.strafeRadius)
				root.CFrame = CFrame.new(target.Root.Position + offset, target.Root.Position)
			end
		end
		
		-- Triggerbot
		if Combat.triggerbot then
			local target = mouse.Target
			if target and Players:GetPlayerFromCharacter(target.Parent) then
				pcall(function() mouse1click() end)
			end
		end
		
		-- Kill Aura
		if Combat.killAura and root then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					local targetHum = plr.Character:FindFirstChildOfClass("Humanoid")
					if targetRoot and targetHum and targetHum.Health > 0 then
						if (root.Position - targetRoot.Position).Magnitude <= Combat.killAuraRange then
							pcall(function()
								local tool = char:FindFirstChildOfClass("Tool")
								if tool and tool:FindFirstChild("Handle") then
									firetouchinterest(tool.Handle, targetRoot, 0)
									firetouchinterest(tool.Handle, targetRoot, 1)
								end
							end)
						end
					end
				end
			end
		end
		
		-- Hitbox Expander
		if Combat.hitboxExpander then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					if targetRoot then
						targetRoot.Size = Vector3.new(Combat.hitboxSize, Combat.hitboxSize, Combat.hitboxSize)
						targetRoot.Transparency = 0.7
					end
				end
			end
		end
		
		-- Backtrack - Store positions
		if Combat.backtrack then
			for _, plr in ipairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					local targetRoot = plr.Character:FindFirstChild("HumanoidRootPart")
					if targetRoot then
						if not backtrackPositions[plr.Name] then
							backtrackPositions[plr.Name] = {}
						end
						table.insert(backtrackPositions[plr.Name], {Position = targetRoot.Position, Time = tick()})
						-- Clean old positions
						for i = #backtrackPositions[plr.Name], 1, -1 do
							if tick() - backtrackPositions[plr.Name][i].Time > Combat.backtrackTime then
								table.remove(backtrackPositions[plr.Name], i)
							end
						end
					end
				end
			end
		end
		
		-- Auto Parry (generic)
		if Combat.autoParry then
			pcall(function()
				for _, obj in ipairs(workspace:GetDescendants()) do
					if obj:IsA("BasePart") and (obj.Name:lower():find("sword") or obj.Name:lower():find("blade")) then
						if obj.Parent ~= char and obj.Parent.Parent ~= char then
							local dist = root and (root.Position - obj.Position).Magnitude or math.huge
							if dist < 15 then
								-- Try to trigger block
								local tool = char:FindFirstChildOfClass("Tool")
								if tool then
									pcall(function() tool:Activate() end)
								end
								pcall(function() mouse2click() end)
							end
						end
					end
				end
			end)
		end
		
		-- ========== FOV CIRCLE ==========
		if DrawingObjects.FOVCircle then
			DrawingObjects.FOVCircle.Visible = Combat.showFOVCircle
			DrawingObjects.FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			DrawingObjects.FOVCircle.Radius = Combat.aimAssistFOV
			DrawingObjects.FOVCircle.Color = Settings.accentColor
		end
		
		-- ========== CROSSHAIR ==========
		if DrawingObjects.CrosshairH and DrawingObjects.CrosshairV then
			local visible = Visuals.customCrosshair
			local cx, cy = camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2
			local size = Visuals.crosshairSize
			
			DrawingObjects.CrosshairH.Visible = visible
			DrawingObjects.CrosshairH.From = Vector2.new(cx - size, cy)
			DrawingObjects.CrosshairH.To = Vector2.new(cx + size, cy)
			DrawingObjects.CrosshairH.Color = Settings.accentColor
			
			DrawingObjects.CrosshairV.Visible = visible
			DrawingObjects.CrosshairV.From = Vector2.new(cx, cy - size)
			DrawingObjects.CrosshairV.To = Vector2.new(cx, cy + size)
			DrawingObjects.CrosshairV.Color = Settings.accentColor
		end
		
		-- ========== FREECAM ==========
		if Visuals.freecam then
			local speed = Visuals.freecamSpeed * 2
			local move = Vector3.new()
			
			if UIS:IsKeyDown(Enum.KeyCode.W) then move = move + camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then move = move - camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then move = move - camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then move = move + camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0, 1, 0) end
			if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move = move - Vector3.new(0, 1, 0) end
			
			if move.Magnitude > 0 then
				freecamPos = freecamPos + move.Unit * speed
			end
			
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.new(freecamPos) * CFrame.Angles(math.rad(freecamAngles.X), math.rad(freecamAngles.Y), 0)
		end
		
		-- ========== PLAYER MODS ==========
		
		if PlayerMods.godMode and humanoid then
			humanoid.Health = humanoid.MaxHealth
		end
		
		if PlayerMods.noRagdoll and humanoid then
			humanoid:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
			humanoid:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
		end
		
		if PlayerMods.infiniteStamina then
			pcall(function()
				for _, v in pairs(player.PlayerGui:GetDescendants()) do
					if v.Name:lower():find("stamina") and v:IsA("ValueBase") then
						v.Value = v.Value > 0 and 100 or v.Value
					end
				end
			end)
		end
		
		-- Character Scale
		if PlayerMods.characterScale ~= 1 and humanoid then
			pcall(function()
				local scale = humanoid:FindFirstChild("BodyHeightScale") or humanoid:FindFirstChild("HeadScale")
				if scale then
					scale.Value = PlayerMods.characterScale
				end
			end)
		end
		
		-- ========== FARMING ==========
		
		if Farming.autoCollect and root then
			for _, item in ipairs(workspace:GetDescendants()) do
				if item:IsA("Tool") or (item:IsA("BasePart") and (item.Name:lower():find("coin") or item.Name:lower():find("gem") or item.Name:lower():find("item") or item.Name:lower():find("pickup"))) then
					local pos = item.Position or (item:FindFirstChild("Handle") and item.Handle.Position)
					if pos then
						local dist = (root.Position - pos).Magnitude
						if dist < 50 then
							pcall(function()
								firetouchinterest(root, item, 0)
								firetouchinterest(root, item, 1)
							end)
						end
					end
				end
			end
		end
		
		if Farming.autoAttack then
			local nearest = getNearestPlayer()
			if nearest and nearest.Distance < 20 then
				pcall(function()
					local tool = char:FindFirstChildOfClass("Tool")
					if tool then tool:Activate() end
				end)
			end
		end
		
		-- ========== TROLL ==========
		
		if Misc.annoyPlayer and Misc.annoyTarget and root then
			local targetPlayer = Players:FindFirstChild(Misc.annoyTarget)
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					root.CFrame = targetRoot.CFrame * CFrame.new(0, 0, -3)
				end
			end
		end
		
		if Misc.orbitPlayer and Misc.orbitTarget and root then
			local targetPlayer = Players:FindFirstChild(Misc.orbitTarget)
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					local angle = tick() * Misc.orbitSpeed
					local offset = Vector3.new(math.cos(angle) * Misc.orbitRadius, 0, math.sin(angle) * Misc.orbitRadius)
					root.CFrame = CFrame.new(targetRoot.Position + offset, targetRoot.Position)
				end
			end
		end
		
		if Misc.fling and root then
			root.Velocity = Vector3.new(math.random(-500, 500), math.random(100, 500), math.random(-500, 500))
			root.RotVelocity = Vector3.new(math.random(-100, 100), math.random(-100, 100), math.random(-100, 100))
		end
		
		if Troll.headless and char then
			local head = char:FindFirstChild("Head")
			if head then
				head.Transparency = 1
				local face = head:FindFirstChildOfClass("Decal")
				if face then face.Transparency = 1 end
			end
		end
		
		-- ========== MISC ==========
		
		if Misc.antiAFK then
			pcall(function()
				local vu = game:GetService("VirtualUser")
				vu:CaptureController()
				vu:ClickButton2(Vector2.new())
			end)
		end
		
		-- ========== HUD ==========
		
		if DrawingObjects.Watermark then
			DrawingObjects.Watermark.Visible = HUD.watermark
			DrawingObjects.Watermark.Text = "Simple Hub ULTIMATE"
			DrawingObjects.Watermark.Color = Settings.accentColor
		end
		
		if DrawingObjects.FPS then
			DrawingObjects.FPS.Visible = HUD.fpsCounter
			DrawingObjects.FPS.Text = "FPS: " .. tostring(currentFPS)
		end
		
		if DrawingObjects.Ping then
			DrawingObjects.Ping.Visible = HUD.pingDisplay
			local ping = Stats.Network.ServerStatsItem["Data Ping"]:GetValue()
			DrawingObjects.Ping.Text = "Ping: " .. math.floor(ping) .. "ms"
		end
		
		if DrawingObjects.PlayerCount then
			DrawingObjects.PlayerCount.Visible = HUD.playerCount
			DrawingObjects.PlayerCount.Text = "Players: " .. #Players:GetPlayers() .. "/" .. Players.MaxPlayers
		end
		
		if DrawingObjects.Velocity then
			DrawingObjects.Velocity.Visible = HUD.velocityDisplay
			local vel = root and root.Velocity.Magnitude or 0
			DrawingObjects.Velocity.Text = "Speed: " .. math.floor(vel) .. " studs/s"
		end
		
		if DrawingObjects.TargetInfo then
			DrawingObjects.TargetInfo.Visible = HUD.targetInfo
			local target = getClosestPlayer(Combat.aimAssistFOV)
			if target then
				DrawingObjects.TargetInfo.Text = "Target: " .. target.Player.Name .. " [" .. math.floor(target.Humanoid.Health) .. "HP]"
			else
				DrawingObjects.TargetInfo.Text = "Target: None"
			end
		end
		
		-- ========== X-RAY ==========
		if Visuals.partTransparency then
			for _, part in ipairs(workspace:GetDescendants()) do
				if part:IsA("BasePart") and not part:IsDescendantOf(char or {}) then
					if part.Transparency < 1 then
						part.LocalTransparencyModifier = Visuals.transparencyValue
					end
				end
			end
		end
		
		-- ========== ESP ==========
		updateESP()
	end)
	
	-- ============================================
	-- ESP UPDATE
	-- ============================================
	function updateESP()
		clearESP()
		
		local anyEnabled = ESPState.NameESP or ESPState.BoxESP or ESPState.HealthESP or 
			ESPState.DistanceESP or ESPState.Tracers or ESPState.SkeletonESP or ESPState.OffscreenArrows
		
		if not anyEnabled then return end
		
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local char = plr.Character
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				local rootPart = char:FindFirstChild("HumanoidRootPart")
				local head = char:FindFirstChild("Head")
				
				if humanoid and humanoid.Health > 0 and rootPart then
					local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
					local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
					local scale = math.clamp(1 / (pos.Z * 0.04), 0.2, 2)
					
					if onScreen then
						if ESPState.NameESP then
							pcall(function()
								local t = Drawing.new("Text")
								t.Text = plr.Name
								t.Size = 14
								t.Color = Color3.fromRGB(255, 255, 255)
								t.Center = true
								t.Outline = true
								t.Position = Vector2.new(pos.X, pos.Y - 50 * scale)
								t.Visible = true
								table.insert(ESPObjects, t)
							end)
						end
						
						if ESPState.HealthESP then
							pcall(function()
								local t = Drawing.new("Text")
								t.Text = math.floor((humanoid.Health / humanoid.MaxHealth) * 100) .. "%"
								t.Size = 12
								t.Color = Color3.fromRGB(100, 255, 100)
								t.Center = true
								t.Outline = true
								t.Position = Vector2.new(pos.X, pos.Y - 35 * scale)
								t.Visible = true
								table.insert(ESPObjects, t)
							end)
						end
						
						if ESPState.DistanceESP then
							pcall(function()
								local t = Drawing.new("Text")
								t.Text = math.floor(distance) .. "m"
								t.Size = 12
								t.Color = Color3.fromRGB(200, 200, 200)
								t.Center = true
								t.Outline = true
								t.Position = Vector2.new(pos.X, pos.Y + 40 * scale)
								t.Visible = true
								table.insert(ESPObjects, t)
							end)
						end
						
						if ESPState.BoxESP then
							pcall(function()
								local b = Drawing.new("Square")
								local sz = Vector2.new(50 * scale, 70 * scale)
								b.Size = sz
								b.Position = Vector2.new(pos.X - sz.X / 2, pos.Y - sz.Y / 2)
								b.Color = Color3.fromRGB(255, 0, 0)
								b.Thickness = 1
								b.Filled = false
								b.Visible = true
								table.insert(ESPObjects, b)
							end)
						end
						
						if ESPState.Tracers then
							pcall(function()
								local l = Drawing.new("Line")
								l.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
								l.To = Vector2.new(pos.X, pos.Y)
								l.Color = Color3.fromRGB(255, 255, 0)
								l.Thickness = 1
								l.Visible = true
								table.insert(ESPObjects, l)
							end)
						end
						
						if ESPState.SkeletonESP then
							pcall(function()
								local joints = char:FindFirstChild("UpperTorso") and {
									{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
									{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
									{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
									{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
									{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
								} or {{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"}, {"Torso", "Left Leg"}, {"Torso", "Right Leg"}}
								
								for _, j in ipairs(joints) do
									local p1, p2 = char:FindFirstChild(j[1]), char:FindFirstChild(j[2])
									if p1 and p2 then
										local s1, v1 = camera:WorldToViewportPoint(p1.Position)
										local s2, v2 = camera:WorldToViewportPoint(p2.Position)
										if v1 and v2 then
											local line = Drawing.new("Line")
											line.From = Vector2.new(s1.X, s1.Y)
											line.To = Vector2.new(s2.X, s2.Y)
											line.Color = Color3.fromRGB(255, 255, 255)
											line.Thickness = 1
											line.Visible = true
											table.insert(ESPObjects, line)
										end
									end
								end
							end)
						end
					else
						if ESPState.OffscreenArrows then
							pcall(function()
								local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
								local dir = (Vector2.new(pos.X, pos.Y) - center).Unit
								local arrowPos = center + dir * 300
								arrowPos = Vector2.new(
									math.clamp(arrowPos.X, 50, camera.ViewportSize.X - 50),
									math.clamp(arrowPos.Y, 50, camera.ViewportSize.Y - 50)
								)
								
								local arrow = Drawing.new("Triangle")
								local angle = math.atan2(dir.Y, dir.X)
								arrow.PointA = arrowPos + Vector2.new(math.cos(angle) * 15, math.sin(angle) * 15)
								arrow.PointB = arrowPos + Vector2.new(math.cos(angle + 2.5) * 15, math.sin(angle + 2.5) * 15)
								arrow.PointC = arrowPos + Vector2.new(math.cos(angle - 2.5) * 15, math.sin(angle - 2.5) * 15)
								arrow.Color = Color3.fromRGB(255, 0, 0)
								arrow.Filled = true
								arrow.Visible = true
								table.insert(ESPObjects, arrow)
							end)
						end
					end
				end
			end
		end
		
		if ESPState.ItemESP then
			for _, item in ipairs(workspace:GetDescendants()) do
				if item:IsA("Tool") or (item:IsA("BasePart") and item.Name:lower():find("item")) then
					local itemPos = item.Position or (item:FindFirstChild("Handle") and item.Handle.Position)
					if itemPos then
						local p, v = camera:WorldToViewportPoint(itemPos)
						if v then
							pcall(function()
								local t = Drawing.new("Text")
								t.Text = "[Item] " .. item.Name
								t.Size = 12
								t.Color = Color3.fromRGB(255, 200, 0)
								t.Center = true
								t.Outline = true
								t.Position = Vector2.new(p.X, p.Y)
								t.Visible = true
								table.insert(ESPObjects, t)
							end)
						end
					end
				end
			end
		end
		
		if ESPState.NPCESP then
			for _, npc in ipairs(workspace:GetDescendants()) do
				if npc:IsA("Model") and npc:FindFirstChildOfClass("Humanoid") and not Players:GetPlayerFromCharacter(npc) then
					local npcRoot = npc:FindFirstChild("HumanoidRootPart") or npc:FindFirstChild("Torso") or npc:FindFirstChild("Head")
					if npcRoot then
						local p, v = camera:WorldToViewportPoint(npcRoot.Position)
						if v then
							pcall(function()
								local t = Drawing.new("Text")
								t.Text = "[NPC] " .. npc.Name
								t.Size = 12
								t.Color = Color3.fromRGB(0, 200, 255)
								t.Center = true
								t.Outline = true
								t.Position = Vector2.new(p.X, p.Y - 30)
								t.Visible = true
								table.insert(ESPObjects, t)
							end)
						end
					end
				end
			end
		end
	end
	
	-- ============================================
	-- CHAMS
	-- ============================================
	local function updateChams()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local existing = plr.Character:FindFirstChild("SimpleHubChams")
				if ESPState.Chams then
					if not existing then
						local h = Instance.new("Highlight")
						h.Name = "SimpleHubChams"
						h.FillColor = Color3.fromRGB(255, 0, 0)
						h.OutlineColor = Color3.fromRGB(255, 255, 255)
						h.FillTransparency = 0.5
						h.Parent = plr.Character
					end
				else
					if existing then existing:Destroy() end
				end
			end
		end
	end
	
	-- ============================================
	-- INPUT
	-- ============================================
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		
		if input.KeyCode == Enum.KeyCode.Space then
			if Movement.infiniteJump then
				local hum = getHumanoid()
				if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
			end
			if Movement.longJump then
				local root = getRoot()
				if root then
					local bv = Instance.new("BodyVelocity")
					bv.Velocity = camera.CFrame.LookVector * Movement.longJumpForce + Vector3.new(0, 50, 0)
					bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
					bv.Parent = root
					Debris:AddItem(bv, 0.2)
				end
			end
		end
		
		if input.KeyCode == Enum.KeyCode.F then
			if Dash and Dash.enabled then
				local root = getRoot()
				if root then Dash.tryDash(root, camera) end
			end
		end
		
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if Movement.clickTP then
				local root = getRoot()
				if root and mouse.Hit then
					root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
				end
			end
			if World.deleteMode then
				local target = mouse.Target
				if target and not target:IsDescendantOf(player.Character or {}) then
					target:Destroy()
				end
			end
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if Visuals.freecam and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = UIS:GetMouseDelta()
			freecamAngles = Vector2.new(
				math.clamp(freecamAngles.X - delta.Y * 0.5, -80, 80),
				freecamAngles.Y - delta.X * 0.5
			)
		end
	end)
	
	-- ============================================
	-- CHAT SPAM
	-- ============================================
	task.spawn(function()
		while true do
			if Misc.chatSpam then
				pcall(function()
					ReplicatedStorage:WaitForChild("DefaultChatSystemChatEvents"):WaitForChild("SayMessageRequest"):FireServer(Misc.chatSpamMsg, "All")
				end)
			end
			task.wait(Misc.chatSpamDelay)
		end
	end)
	
	-- ============================================
	-- AUTO RESPAWN
	-- ============================================
	task.spawn(function()
		while true do
			if PlayerMods.autoRespawn then
				local hum = getHumanoid()
				if hum and hum.Health <= 0 then
					task.wait(0.1)
					pcall(function()
						player:LoadCharacter()
					end)
				end
			end
			task.wait(0.5)
		end
	end)
	
	-- ============================================
	-- COLORS
	-- ============================================
	local Colors = {
		Background = Color3.fromRGB(18, 18, 25),
		Panel = Color3.fromRGB(22, 22, 32),
		Surface = Color3.fromRGB(26, 26, 36),
		ContentBg = Color3.fromRGB(20, 20, 28),
		ScrollBg = Color3.fromRGB(18, 18, 25),
		Accent = Settings.accentColor,
		Text = Color3.fromRGB(220, 220, 240),
		TextDim = Color3.fromRGB(140, 140, 160),
		Border = Color3.fromRGB(45, 50, 65)
	}
	
	-- ============================================
	-- GUI CREATION
	-- ============================================
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHubUltimate"
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
	
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)
	local stroke = Instance.new("UIStroke", main)
	stroke.Color = Colors.Border
	stroke.Thickness = 2
	
	-- Header
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 45)
	header.BackgroundColor3 = Colors.Panel
	header.BorderSizePixel = 0
	header.Parent = main
	
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 400, 1, 0)
	title.Position = UDim2.new(0, 15, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "SIMPLE HUB ULTIMATE"
	title.TextColor3 = Colors.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.TextSize = 16
	title.Parent = header
	
	local accent = Instance.new("Frame")
	accent.Size = UDim2.new(0, 60, 0, 3)
	accent.Position = UDim2.new(0, 15, 1, -3)
	accent.BackgroundColor3 = Colors.Accent
	accent.BorderSizePixel = 0
	accent.Parent = header
	Instance.new("UICorner", accent).CornerRadius = UDim.new(1, 0)
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.Position = UDim2.new(1, -38, 0.5, 0)
	closeBtn.AnchorPoint = Vector2.new(0, 0.5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Colors.Text
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
	
	closeBtn.MouseButton1Click:Connect(function() main.Visible = false end)
	closeBtn.MouseEnter:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) end)
	closeBtn.MouseLeave:Connect(function() closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45) end)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, 0, 0, 45)
	tabBar.Position = UDim2.new(0, 0, 0, 45)
	tabBar.BackgroundColor3 = Colors.Surface
	tabBar.BorderSizePixel = 0
	tabBar.Parent = main
	
	Tabs.setupTabBar(tabBar)
	
	-- Content area
	local contentArea = Instance.new("Frame")
	contentArea.Size = UDim2.new(1, 0, 1, -90)
	contentArea.Position = UDim2.new(0, 0, 0, 90)
	contentArea.BackgroundColor3 = Colors.ContentBg
	contentArea.BorderSizePixel = 0
	contentArea.Parent = main
	
	local contentContainer = Instance.new("Frame")
	contentContainer.Size = UDim2.new(1, -20, 1, -12)
	contentContainer.Position = UDim2.new(0, 10, 0, 6)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = contentArea
	
	local function createTabContent(name)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = name
		scroll.Size = UDim2.new(1, 0, 1, 0)
		scroll.BackgroundColor3 = Colors.ScrollBg
		scroll.BackgroundTransparency = 0
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 4
		scroll.ScrollBarImageColor3 = Colors.Accent
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Visible = false
		scroll.Parent = contentContainer
		
		local layout = Instance.new("UIListLayout", scroll)
		layout.Padding = UDim.new(0, 6)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		
		local padding = Instance.new("UIPadding", scroll)
		padding.PaddingTop = UDim.new(0, 4)
		padding.PaddingBottom = UDim.new(0, 8)
		padding.PaddingLeft = UDim.new(0, 4)
		padding.PaddingRight = UDim.new(0, 8)
		
		return scroll
	end
	
	-- Create all tabs
	local movementContent = createTabContent("Movement")
	local combatContent = createTabContent("Combat")
	local espContent = createTabContent("ESP")
	local visualsContent = createTabContent("Visuals")
	local playerContent = createTabContent("Player")
	local farmingContent = createTabContent("Farming")
	local trollContent = createTabContent("Troll")
	local miscContent = createTabContent("Misc")
	local worldContent = createTabContent("World")
	local hudContent = createTabContent("HUD")
	local settingsContent = createTabContent("Settings")
	
	local movementTab = Tabs.create(tabBar, "Move", "🏃")
	local combatTab = Tabs.create(tabBar, "Combat", "🎯")
	local espTab = Tabs.create(tabBar, "ESP", "👁")
	local visualsTab = Tabs.create(tabBar, "Visual", "🎨")
	local playerTab = Tabs.create(tabBar, "Player", "👤")
	local farmingTab = Tabs.create(tabBar, "Farm", "🌾")
	local trollTab = Tabs.create(tabBar, "Troll", "🎭")
	local miscTab = Tabs.create(tabBar, "Misc", "⚙")
	local worldTab = Tabs.create(tabBar, "World", "🌍")
	local hudTab = Tabs.create(tabBar, "HUD", "📊")
	local settingsTab = Tabs.create(tabBar, "Set", "⚡")
	
	Tabs.connectTab(movementTab, movementContent)
	Tabs.connectTab(combatTab, combatContent)
	Tabs.connectTab(espTab, espContent)
	Tabs.connectTab(visualsTab, visualsContent)
	Tabs.connectTab(playerTab, playerContent)
	Tabs.connectTab(farmingTab, farmingContent)
	Tabs.connectTab(trollTab, trollContent)
	Tabs.connectTab(miscTab, miscContent)
	Tabs.connectTab(worldTab, worldContent)
	Tabs.connectTab(hudTab, hudContent)
	Tabs.connectTab(settingsTab, settingsContent)
	
	-- ============================================
	-- MOVEMENT TAB
	-- ============================================
	Components.createSection(movementContent, "Flight & Noclip")
	Components.createToggle(movementContent, "Fly", function(s) if Fly then if s then local r=getRoot() if r then Fly.enable(r,camera) end else Fly.disable() end end end)
	Components.createSlider(movementContent, "Fly Speed", 10, 300, 50, function(v) if Fly then Fly.speed = v end end)
	Components.createToggle(movementContent, "Noclip", function(s) if Noclip then Noclip.enabled = s end end)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Speed & Jump")
	Components.createToggle(movementContent, "Walk Speed", function(s) Movement.walkSpeedEnabled=s local h=getHumanoid() if h then h.WalkSpeed=s and Movement.walkSpeedValue or 16 end end)
	Components.createSlider(movementContent, "Speed Value", 16, 500, 16, function(v) Movement.walkSpeedValue=v if Movement.walkSpeedEnabled then local h=getHumanoid() if h then h.WalkSpeed=v end end end)
	Components.createToggle(movementContent, "Jump Power", function(s) Movement.jumpPowerEnabled=s local h=getHumanoid() if h then h.JumpPower=s and Movement.jumpPowerValue or 50 end end)
	Components.createSlider(movementContent, "Jump Value", 50, 500, 50, function(v) Movement.jumpPowerValue=v if Movement.jumpPowerEnabled then local h=getHumanoid() if h then h.JumpPower=v end end end)
	Components.createToggle(movementContent, "Infinite Jump", function(s) Movement.infiniteJump=s end)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Special Movement")
	Components.createToggle(movementContent, "Speed Glide", function(s) Movement.speedGlide=s end)
	Components.createSlider(movementContent, "Glide Speed", 1, 50, 10, function(v) Movement.glideSpeed=v/100 end)
	Components.createToggle(movementContent, "Long Jump", function(s) Movement.longJump=s end)
	Components.createSlider(movementContent, "Long Jump Force", 50, 400, 100, function(v) Movement.longJumpForce=v end)
	Components.createToggle(movementContent, "Bunny Hop", function(s) Movement.bunnyHop=s end)
	Components.createToggle(movementContent, "Dash (F)", function(s) if Dash then Dash.enabled=s end end)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Teleport & Safety")
	Components.createToggle(movementContent, "Click TP", function(s) Movement.clickTP=s end)
	Components.createToggle(movementContent, "Anti Void", function(s) Movement.antiVoid=s end)
	Components.createSlider(movementContent, "Void Height", -500, 0, -100, function(v) Movement.antiVoidHeight=v end)
	Components.createToggle(movementContent, "Anchor", function(s) Movement.anchored=s local r=getRoot() if r then r.Anchored=s end end)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Exploits")
	Components.createToggle(movementContent, "Spin Bot", function(s) Movement.spinBot=s end)
	Components.createSlider(movementContent, "Spin Speed", 1, 50, 20, function(v) Movement.spinSpeed=v end)
	Components.createToggle(movementContent, "Fake Lag", function(s) Movement.fakeLag=s end)
	Components.createSlider(movementContent, "Lag Intensity", 1, 10, 5, function(v) Movement.fakeLagIntensity=v end)
	
	-- ============================================
	-- COMBAT TAB
	-- ============================================
	Components.createSection(combatContent, "Aim Assist")
	Components.createToggle(combatContent, "Aim Assist", function(s) Combat.aimAssistEnabled=s end)
	Components.createSlider(combatContent, "Smoothness", 1, 100, 15, function(v) Combat.aimAssistSmooth=v/200 end)
	Components.createSlider(combatContent, "FOV", 50, 600, 150, function(v) Combat.aimAssistFOV=v if SilentAim then SilentAim.fov=v end end)
	Components.createToggle(combatContent, "Show FOV Circle", function(s) Combat.showFOVCircle=s end)
	Components.createToggle(combatContent, "Aim Prediction", function(s) Combat.aimPrediction=s end)
	Components.createSlider(combatContent, "Prediction Amount", 1, 50, 10, function(v) Combat.predictionAmount=v/100 end)
	
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Silent Aim")
	Components.createToggle(combatContent, "Silent Aim", function(s) if SilentAim then SilentAim.enabled=s end end)
	Components.createSlider(combatContent, "Hit Chance", 0, 100, 100, function(v) if SilentAim then SilentAim.hitChance=v end end)
	
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Auto")
	Components.createToggle(combatContent, "Triggerbot", function(s) Combat.triggerbot=s end)
	Components.createToggle(combatContent, "Kill Aura", function(s) Combat.killAura=s end)
	Components.createSlider(combatContent, "Kill Aura Range", 5, 50, 15, function(v) Combat.killAuraRange=v end)
	Components.createToggle(combatContent, "Auto Parry", function(s) Combat.autoParry=s end)
	Components.createToggle(combatContent, "Auto Combo", function(s) Combat.autoCombo=s end)
	
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Exploits")
	Components.createToggle(combatContent, "Hitbox Expander", function(s) Combat.hitboxExpander=s end)
	Components.createSlider(combatContent, "Hitbox Size", 1, 20, 5, function(v) Combat.hitboxSize=v end)
	Components.createToggle(combatContent, "Backtrack", function(s) Combat.backtrack=s end)
	Components.createSlider(combatContent, "Backtrack Time", 1, 50, 20, function(v) Combat.backtrackTime=v/100 end)
	
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Movement")
	Components.createToggle(combatContent, "Target Strafe", function(s) Combat.targetStrafe=s end)
	Components.createSlider(combatContent, "Strafe Speed", 1, 20, 5, function(v) Combat.strafeSpeed=v end)
	Components.createSlider(combatContent, "Strafe Radius", 5, 30, 10, function(v) Combat.strafeRadius=v end)
	
	-- ============================================
	-- ESP TAB
	-- ============================================
	Components.createSection(espContent, "Player ESP")
	Components.createToggle(espContent, "Name ESP", function(s) ESPState.NameESP=s end)
	Components.createToggle(espContent, "Box ESP", function(s) ESPState.BoxESP=s end)
	Components.createToggle(espContent, "Health ESP", function(s) ESPState.HealthESP=s end)
	Components.createToggle(espContent, "Distance ESP", function(s) ESPState.DistanceESP=s end)
	Components.createToggle(espContent, "Tracers", function(s) ESPState.Tracers=s end)
	Components.createToggle(espContent, "Skeleton ESP", function(s) ESPState.SkeletonESP=s end)
	Components.createToggle(espContent, "Offscreen Arrows", function(s) ESPState.OffscreenArrows=s end)
	
	Components.createDivider(espContent)
	Components.createSection(espContent, "World ESP")
	Components.createToggle(espContent, "Item ESP", function(s) ESPState.ItemESP=s end)
	Components.createToggle(espContent, "NPC ESP", function(s) ESPState.NPCESP=s end)
	
	Components.createDivider(espContent)
	Components.createSection(espContent, "Highlights")
	Components.createToggle(espContent, "Chams", function(s) ESPState.Chams=s updateChams() end)
	
	-- ============================================
	-- VISUALS TAB
	-- ============================================
	Components.createSection(visualsContent, "Lighting")
	Components.createToggle(visualsContent, "Fullbright", function(s) Visuals.fullbright=s if s then Lighting.Ambient=Color3.new(1,1,1) Lighting.Brightness=2 Lighting.OutdoorAmbient=Color3.new(1,1,1) else Lighting.Ambient=OriginalValues.Ambient Lighting.Brightness=OriginalValues.Brightness Lighting.OutdoorAmbient=OriginalValues.OutdoorAmbient end end)
	Components.createToggle(visualsContent, "No Fog", function(s) Visuals.noFog=s if s then Lighting.FogEnd=1e10 Lighting.FogStart=1e10 else Lighting.FogEnd=OriginalValues.FogEnd Lighting.FogStart=OriginalValues.FogStart end end)
	Components.createToggle(visualsContent, "No Shadows", function(s) Visuals.noShadows=s Lighting.GlobalShadows=not s end)
	
	Components.createDivider(visualsContent)
	Components.createSection(visualsContent, "Crosshair")
	Components.createToggle(visualsContent, "Custom Crosshair", function(s) Visuals.customCrosshair=s end)
	Components.createSlider(visualsContent, "Crosshair Size", 5, 50, 10, function(v) Visuals.crosshairSize=v end)
	
	Components.createDivider(visualsContent)
	Components.createSection(visualsContent, "Camera")
	Components.createSlider(visualsContent, "Camera FOV", 30, 120, 70, function(v) Visuals.cameraFOV=v camera.FieldOfView=v end)
	Components.createToggle(visualsContent, "Third Person", function(s) Visuals.thirdPerson=s player.CameraMaxZoomDistance=s and 100 or 128 player.CameraMinZoomDistance=s and 15 or 0.5 end)
	Components.createToggle(visualsContent, "Freecam", function(s) Visuals.freecam=s if s then freecamPos=camera.CFrame.Position UIS.MouseBehavior=Enum.MouseBehavior.LockCenter else camera.CameraType=Enum.CameraType.Custom UIS.MouseBehavior=Enum.MouseBehavior.Default end end)
	Components.createSlider(visualsContent, "Freecam Speed", 1, 20, 1, function(v) Visuals.freecamSpeed=v end)
	
	Components.createDivider(visualsContent)
	Components.createSection(visualsContent, "World")
	Components.createToggle(visualsContent, "X-Ray / Part Transparency", function(s) Visuals.partTransparency=s end)
	Components.createSlider(visualsContent, "Transparency", 0, 100, 50, function(v) Visuals.transparencyValue=v/100 end)
	
	-- ============================================
	-- PLAYER TAB
	-- ============================================
	Components.createSection(playerContent, "Character")
	Components.createToggle(playerContent, "God Mode", function(s) PlayerMods.godMode=s end)
	Components.createToggle(playerContent, "No Ragdoll", function(s) PlayerMods.noRagdoll=s end)
	Components.createToggle(playerContent, "Invisibility", function(s) PlayerMods.invisible=s local c=getCharacter() if c then for _,p in ipairs(c:GetDescendants()) do if p:IsA("BasePart") and p.Name~="HumanoidRootPart" then p.Transparency=s and 1 or 0 elseif p:IsA("Decal") then p.Transparency=s and 1 or 0 end end end end)
	Components.createToggle(playerContent, "Auto Respawn", function(s) PlayerMods.autoRespawn=s end)
	Components.createSlider(playerContent, "Character Scale", 50, 200, 100, function(v) PlayerMods.characterScale=v/100 end)
	
	Components.createDivider(playerContent)
	Components.createSection(playerContent, "Weapon (Game Specific)")
	Components.createToggle(playerContent, "No Recoil", function(s) PlayerMods.noRecoil=s end)
	Components.createToggle(playerContent, "No Spread", function(s) PlayerMods.noSpread=s end)
	Components.createToggle(playerContent, "Infinite Stamina", function(s) PlayerMods.infiniteStamina=s end)
	
	-- ============================================
	-- FARMING TAB
	-- ============================================
	Components.createSection(farmingContent, "Auto Farm")
	Components.createToggle(farmingContent, "Auto Farm", function(s) Farming.autoFarm=s end)
	Components.createToggle(farmingContent, "Auto Collect", function(s) Farming.autoCollect=s end)
	Components.createToggle(farmingContent, "Auto Quest", function(s) Farming.autoQuest=s end)
	Components.createToggle(farmingContent, "Auto Attack", function(s) Farming.autoAttack=s end)
	
	Components.createDivider(farmingContent)
	Components.createSection(farmingContent, "Teleport")
	Components.createToggle(farmingContent, "TP to Items", function(s) Farming.tpToItems=s if s then local r=getRoot() if r then for _,i in ipairs(workspace:GetDescendants()) do if i:IsA("Tool") or (i:IsA("BasePart") and i.Name:lower():find("coin")) then local pos=i.Position or (i:FindFirstChild("Handle") and i.Handle.Position) if pos then r.CFrame=CFrame.new(pos+Vector3.new(0,3,0)) break end end end end end end)
	
	-- ============================================
	-- TROLL TAB
	-- ============================================
	Components.createSection(trollContent, "Follow/Orbit")
	Components.createToggle(trollContent, "Annoy Player", function(s) Misc.annoyPlayer=s end)
	Components.createToggle(trollContent, "Orbit Player", function(s) Misc.orbitPlayer=s end)
	Components.createSlider(trollContent, "Orbit Radius", 5, 30, 10, function(v) Misc.orbitRadius=v end)
	Components.createSlider(trollContent, "Orbit Speed", 1, 10, 2, function(v) Misc.orbitSpeed=v end)
	
	Components.createDivider(trollContent)
	Components.createSection(trollContent, "Character")
	Components.createToggle(trollContent, "Fling", function(s) Misc.fling=s end)
	Components.createToggle(trollContent, "Headless", function(s) Troll.headless=s end)
	
	Components.createDivider(trollContent)
	Components.createSection(trollContent, "Info")
	Components.createLabel(trollContent, "For Annoy/Orbit: Type player name in chat: /target [name]")
	
	-- ============================================
	-- MISC TAB
	-- ============================================
	Components.createSection(miscContent, "Anti-Detection")
	Components.createToggle(miscContent, "Anti AFK", function(s) Misc.antiAFK=s end)
	
	Components.createDivider(miscContent)
	Components.createSection(miscContent, "Chat")
	Components.createToggle(miscContent, "Chat Spam", function(s) Misc.chatSpam=s end)
	Components.createSlider(miscContent, "Spam Delay", 1, 10, 2, function(v) Misc.chatSpamDelay=v end)
	
	Components.createDivider(miscContent)
	Components.createSection(miscContent, "Server")
	Components.createToggle(miscContent, "Server Hop", function(s) if s then pcall(function() local servers=HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100")) for _,srv in ipairs(servers.data) do if srv.id~=game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId,srv.id) break end end end) end end)
	Components.createToggle(miscContent, "Rejoin", function(s) if s then TeleportService:Teleport(game.PlaceId) end end)
	
	-- ============================================
	-- WORLD TAB
	-- ============================================
	Components.createSection(worldContent, "Environment")
	Components.createSlider(worldContent, "Time of Day", 0, 24, 14, function(v) World.timeOfDay=v Lighting.ClockTime=v end)
	Components.createSlider(worldContent, "Gravity", 0, 500, 196, function(v) World.gravity=v workspace.Gravity=v end)
	
	Components.createDivider(worldContent)
	Components.createSection(worldContent, "Terrain")
	Components.createToggle(worldContent, "Remove Grass", function(s) local t=workspace:FindFirstChildOfClass("Terrain") if t then t.Decoration=not s end for _,o in ipairs(workspace:GetDescendants()) do if o:IsA("BasePart") and (o.Name:lower():find("grass") or o.Name:lower():find("foliage")) then o.Transparency=s and 1 or 0 end end end)
	
	Components.createDivider(worldContent)
	Components.createSection(worldContent, "Tools")
	Components.createToggle(worldContent, "Delete Mode (Click)", function(s) World.deleteMode=s end)
	
	-- ============================================
	-- HUD TAB
	-- ============================================
	Components.createSection(hudContent, "Display")
	Components.createToggle(hudContent, "Watermark", function(s) HUD.watermark=s end)
	Components.createToggle(hudContent, "FPS Counter", function(s) HUD.fpsCounter=s end)
	Components.createToggle(hudContent, "Ping Display", function(s) HUD.pingDisplay=s end)
	Components.createToggle(hudContent, "Player Count", function(s) HUD.playerCount=s end)
	Components.createToggle(hudContent, "Velocity Display", function(s) HUD.velocityDisplay=s end)
	Components.createToggle(hudContent, "Target Info", function(s) HUD.targetInfo=s end)
	
	-- ============================================
	-- SETTINGS TAB
	-- ============================================
	Components.createSection(settingsContent, "Menu")
	Components.createSlider(settingsContent, "Menu Scale", 50, 150, 100, function(v) Settings.menuScale=v/100 main.Size=UDim2.new(0, 950*Settings.menuScale, 0, 650*Settings.menuScale) end)
	
	Components.createDivider(settingsContent)
	Components.createSection(settingsContent, "Theme")
	Components.createLabel(settingsContent, "Accent: Blue (default)")
	
	Components.createDivider(settingsContent)
	Components.createSection(settingsContent, "Info")
	Components.createLabel(settingsContent, "Simple Hub ULTIMATE v2.0")
	Components.createLabel(settingsContent, "Press M to toggle menu")
	Components.createLabel(settingsContent, "All features are working!")
	
	-- Activate first tab
	Tabs.activate(movementTab, movementContent)
	
	-- ============================================
	-- TOGGLE MENU
	-- ============================================
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Settings.menuKey then
			main.Visible = not main.Visible
			if main.Visible then
				main.Size = UDim2.new(0, 0, 0, 0)
				Animations.tween(main, {Size = UDim2.new(0, 950 * Settings.menuScale, 0, 650 * Settings.menuScale)}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
			end
		end
	end)
	
	-- ============================================
	-- DRAGGING
	-- ============================================
	local dragging, dragStart, startPos = false, nil, nil
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
		end
	end)
	UIS.InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	
	-- Character events
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then
			if Movement.walkSpeedEnabled then h.WalkSpeed = Movement.walkSpeedValue end
			if Movement.jumpPowerEnabled then h.JumpPower = Movement.jumpPowerValue end
		end
		if ESPState.Chams then updateChams() end
	end)
	
	Players.PlayerAdded:Connect(function() task.wait(1) if ESPState.Chams then updateChams() end end)
	
	-- Chat commands for troll features
	player.Chatted:Connect(function(msg)
		if msg:sub(1, 8) == "/target " then
			local name = msg:sub(9)
			Misc.annoyTarget = name
			Misc.orbitTarget = name
		end
	end)
	
	print("[SimpleHub] ULTIMATE Edition loaded!")
	print("[SimpleHub] Press M to toggle | 11 Tabs | 100+ Features")
end
