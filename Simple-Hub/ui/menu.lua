-- ---------------------------------------------------------------------------
-- VERTEX HUB - FULLY LOADSTRING COMPATIBLE
-- FIXED: All toggles return objects, ToggleRefs stores objects only
-- ---------------------------------------------------------------------------

return function(arg1, arg2, arg3)
	local Tabs, Components, Animations, State, ToggleRefs
	if type(arg1) == "table" and arg1.Tabs then
		Tabs = arg1.Tabs
		Components = arg1.Components
		Animations = arg1.Animations
		State = arg1.State
		ToggleRefs = arg1.ToggleRefs
	else
		Tabs = arg1
		Components = arg2
		Animations = arg3
	end
	Tabs = Tabs or _G.VertexTabs
	Components = Components or _G.VertexComponents
	Animations = Animations or _G.VertexAnimations
	ToggleRefs = ToggleRefs or _G.VertexToggleRefs or {}
	
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
	
	local function getCharacter() return player.Character end
	local function getRoot() local c = getCharacter() return c and c:FindFirstChild("HumanoidRootPart") end
	local function getHumanoid() local c = getCharacter() return c and c:FindFirstChildOfClass("Humanoid") end
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
	
	-- Safe toggle update function
	local function safeToggleUpdate(toggleObj, value)
		if not toggleObj then return false end
		if type(toggleObj) ~= "table" then return false end
		if type(toggleObj.UpdateState) ~= "function" then return false end
		toggleObj.UpdateState(toggleObj, value)
		return true
	end
	
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
					table.insert(EntityCache.npcs, { Model = obj, Name = obj.Name, Humanoid = hum, RootPart = root, Head = obj:FindFirstChild("Head"), IsNPC = true })
				end
			end
		end
	end
	
	local DrawingPool = { text = {}, square = {}, line = {}, triangle = {}, circle = {} }
	local ActiveDrawings = {}
	
	local function getDrawing(drawType)
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
			if obj then obj.Visible = false obj._inUse = false end
		end
		ActiveDrawings = {}
	end
	
	local HUD = {}
	pcall(function()
		HUD.FOVCircle = Drawing.new("Circle")
		HUD.FOVCircle.Thickness = 2
		HUD.FOVCircle.NumSides = 64
		HUD.FOVCircle.Filled = false
		HUD.FOVCircle.Visible = false
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
	end)
	
	if not State then
		State = {
			ESP = { NameESP = false, BoxESP = false, HealthESP = false, DistanceESP = false, Tracers = false, SkeletonESP = false, OffscreenArrows = false, Chams = false, ItemESP = false, NPCESP = false, MaxDistance = 1000, TeamCheck = false },
			Combat = { AimAssist = false, AimSmoothness = 0.15, AimFOV = 150, AimPrediction = false, PredictionAmount = 0.1, ShowFOVCircle = false, SilentAim = false, SilentAimHitChance = 100, KillAura = false, KillAuraRange = 15, KillAuraCPS = 10, KillAuraLegit = false, KillAuraPlayers = true, KillAuraNPCs = false, KillAuraWallCheck = true, Reach = false, ReachDistance = 18 },
			Movement = { Fly = false, FlySpeed = 50, Noclip = false, Speed = false, SpeedValue = 16, JumpPower = false, JumpValue = 50, InfiniteJump = false, BunnyHop = false, ClickTP = false, AntiVoid = false, VoidHeight = -100 },
			Visuals = { Fullbright = false, NoFog = false, NoShadows = false, Crosshair = false, CrosshairSize = 10, CrosshairGap = 5, CameraFOV = 70, Freecam = false },
			World = { TimeOfDay = 14, Gravity = 196.2, DeleteMode = false },
			Player = { GodMode = false, NoRagdoll = false, AutoRespawn = false, Invisibility = false, InvisOffset = 100 },
			Troll = { AnnoyPlayer = false, AnnoyTarget = "", OrbitPlayer = false, OrbitTarget = "", OrbitRadius = 10, OrbitSpeed = 2, Fling = false, FlingPower = 500, Headless = false },
			Misc = { AntiAFK = false, ChatSpam = false, SpamMsg = "Vertex Hub!", SpamDelay = 2, Watermark = false, FPSCounter = false, PingDisplay = false },
			Settings = { MenuKey = Enum.KeyCode.M, AccentColor = Color3.fromRGB(60, 120, 255) }
		}
	end
	
	State.ESP = State.ESP or {}
	State.Combat = State.Combat or {}
	State.Movement = State.Movement or {}
	State.Visuals = State.Visuals or {}
	State.World = State.World or {}
	State.Player = State.Player or {}
	State.Troll = State.Troll or {}
	State.Misc = State.Misc or {}
	State.Settings = State.Settings or {}
	
	local function applyStateToUI()
		for refName, toggleObj in pairs(ToggleRefs) do
			if toggleObj and type(toggleObj) == "table" and type(toggleObj.UpdateState) == "function" then
				local category = nil
				if refName:find("Aim") or refName:find("Silent") or refName:find("Kill") or refName:find("Reach") then category = "Combat"
				elseif refName:find("Fly") or refName:find("Noclip") or refName:find("Speed") or refName:find("Jump") or refName:find("Bunny") or refName:find("Click") or refName:find("Anti") then category = "Movement"
				elseif refName:find("ESP") or refName:find("Tracers") or refName:find("Chams") or refName:find("TeamCheck") then category = "ESP"
				elseif refName:find("Fullbright") or refName:find("Fog") or refName:find("Crosshair") or refName:find("Freecam") then category = "Visuals"
				elseif refName:find("Delete") then category = "World"
				elseif refName:find("God") or refName:find("Ragdoll") or refName:find("Respawn") or refName:find("Invis") then category = "Player"
				elseif refName:find("Annoy") or refName:find("Orbit") or refName:find("Fling") or refName:find("Headless") then category = "Troll"
				elseif refName:find("Watermark") or refName:find("FPS") or refName:find("Ping") or refName:find("AntiAFK") or refName:find("Chat") then category = "Misc"
				end
				if category and State[category] and State[category][refName] ~= nil then
					toggleObj.UpdateState(toggleObj, State[category][refName])
				end
			elseif toggleObj and type(toggleObj) ~= "table" then
				ToggleRefs[refName] = nil
			end
		end
	end
	
	local function saveConfig(name)
		if not name or name == "" then name = "Config_" .. os.date("%Y-%m-%d_%H-%M") end
		local configData = { ESP = State.ESP, Combat = State.Combat, Movement = State.Movement, Visuals = State.Visuals, World = State.World, Player = State.Player, Troll = State.Troll, Misc = State.Misc, Settings = State.Settings }
		local jsonData
		pcall(function() jsonData = HttpService:JSONEncode(configData) end)
		if not jsonData then return false end
		if writefile then
			local s = pcall(function() writefile("vertex_config_" .. name .. ".json", jsonData) end)
			if s then return true end
		end
		_G.VertexConfigs = _G.VertexConfigs or {}
		_G.VertexConfigs[name] = configData
		return true
	end
	
	local function loadConfig(name)
		local configData = nil
		if readfile then
			local s, d = pcall(function() return readfile("vertex_config_" .. name .. ".json") end)
			if s and d then
				local s2, dec = pcall(function() return HttpService:JSONDecode(d) end)
				if s2 then configData = dec end
			end
		end
		if not configData and _G.VertexConfigs and _G.VertexConfigs[name] then
			configData = _G.VertexConfigs[name]
		end
		if configData then
			for cat, vals in pairs(configData) do
				if State[cat] then
					for k, v in pairs(vals) do
						if State[cat][k] ~= nil then State[cat][k] = v end
					end
				end
			end
			applyStateToUI()
			return true
		end
		return false
	end
	
	local function deleteConfig(name)
		if delfile then pcall(function() delfile("vertex_config_" .. name .. ".json") end) end
		if _G.VertexConfigs then _G.VertexConfigs[name] = nil end
		return true
	end
	
	local function getConfigList()
		local list = {}
		if listfiles then
			local s, f = pcall(function() return listfiles("") end)
			if s then
				for _, file in ipairs(f) do
					if file:find("vertex_config_") and file:find(".json") then
						local n = file:gsub("vertex_config_", ""):gsub(".json", "")
						table.insert(list, n)
					end
				end
			end
		end
		if _G.VertexConfigs then
			for n in pairs(_G.VertexConfigs) do
				if not table.find(list, n) then table.insert(list, n) end
			end
		end
		table.sort(list)
		return list
	end
	
	local BacktrackPositions = {}
	local CurrentTarget = nil
	local LastAttackTime = 0
	local FreecamPos = Vector3.new(0, 50, 0)
	local FreecamAngles = Vector2.new(0, 0)
	local FPSData = { frames = 0, lastTime = tick(), fps = 60 }
	local PrevMouseState = {}
	local OriginalLighting = { Ambient = Lighting.Ambient, Brightness = Lighting.Brightness, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, GlobalShadows = Lighting.GlobalShadows, OutdoorAmbient = Lighting.OutdoorAmbient }
	
	local function getBestTarget(options)
		options = options or {}
		local range = options.Range or 150
		local myRoot = getRoot()
		if not myRoot then return nil end
		local targets = {}
		local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		for name, data in pairs(EntityCache.players) do
			if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
				local dist = (myRoot.Position - data.RootPart.Position).Magnitude
				if dist <= range then
					local pos, onScreen = camera:WorldToViewportPoint(data.RootPart.Position)
					local screenDist = onScreen and (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude or math.huge
					table.insert(targets, { Entity = data, Distance = dist, ScreenDistance = screenDist, Health = data.Humanoid.Health })
				end
			end
		end
		if #targets == 0 then return nil end
		table.sort(targets, function(a, b) return a.Distance < b.Distance end)
		CurrentTarget = targets[1].Entity
		return targets[1].Entity
	end
	
	local FlySystem = { enabled = false, bg = nil, bv = nil }
	function FlySystem:Enable()
		local root, hum = getRoot(), getHumanoid()
		if not root or not hum then return end
		self.enabled = true
		hum.PlatformStand = true
		self.bg = Instance.new("BodyGyro", root)
		self.bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		self.bg.P = 1e4
		self.bv = Instance.new("BodyVelocity", root)
		self.bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		self.bv.Velocity = Vector3.new()
	end
	function FlySystem:Disable()
		self.enabled = false
		local hum = getHumanoid()
		if hum then hum.PlatformStand = false end
		if self.bg then self.bg:Destroy() self.bg = nil end
		if self.bv then self.bv:Destroy() self.bv = nil end
	end
	function FlySystem:Update()
		if not self.enabled or not self.bv then return end
		self.bg.CFrame = camera.CFrame
		local dir = Vector3.new()
		if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then dir = dir + Vector3.new(0, 1, 0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then dir = dir - Vector3.new(0, 1, 0) end
		self.bv.Velocity = dir.Magnitude > 0 and dir.Unit * (State.Movement.FlySpeed or 50) or Vector3.new()
	end
	
	local InvisSystem = { enabled = false, movedParts = {}, connection = nil }
	function InvisSystem:Enable()
		local char, root = getCharacter(), getRoot()
		if not char or not root then return end
		self.enabled = true
		self.movedParts = {}
		local offset = State.Player.InvisOffset or 100
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
			for part in pairs(self.movedParts) do
				if part and part.Parent then
					part.CFrame = CFrame.new(r.Position + offsetVec) * (part.CFrame - part.Position)
				end
			end
		end)
	end
	function InvisSystem:Disable()
		self.enabled = false
		if self.connection then self.connection:Disconnect() self.connection = nil end
		self.movedParts = {}
	end
	
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
	
	local LEGIT_RANGE = 14.4
	local KillAuraHooked = false
	local function hookKillAura()
		if KillAuraHooked then return end
		if not hookmetamethod or not getnamecallmethod then return end
		KillAuraHooked = true
		pcall(function()
			local oldNC
			oldNC = hookmetamethod(game, "__namecall", function(self, ...)
				local method = getnamecallmethod()
				local args = {...}
				if method == "FireServer" and State.Combat.KillAura then
					local rn = self.Name:lower()
					if rn:find("attack") or rn:find("hit") or rn:find("damage") then
						local myRoot = getRoot()
						local target = CurrentTarget
						if myRoot and target and target.RootPart then
							local dist = (myRoot.Position - target.RootPart.Position).Magnitude
							if dist <= (State.Combat.KillAuraRange or 15) and dist > LEGIT_RANGE then
								local lv = (target.RootPart.Position - myRoot.Position).Unit
								local od = math.max(dist - LEGIT_RANGE, 0)
								local rp = myRoot.Position + lv * od
								for i, arg in ipairs(args) do
									if typeof(arg) == "Vector3" then args[i] = rp
									elseif typeof(arg) == "CFrame" then args[i] = CFrame.new(rp) * (arg - arg.Position)
									elseif typeof(arg) == "table" then
										if arg.Position then arg.Position = rp end
										if arg.Origin then arg.Origin = rp end
									end
								end
							end
						end
					end
				end
				return oldNC(self, unpack(args))
			end)
		end)
	end
	task.defer(hookKillAura)
	
	task.spawn(function()
		while true do
			if State.Misc.ChatSpam then
				pcall(function()
					local ce = ReplicatedStorage:FindFirstChild("DefaultChatSystemChatEvents")
					if ce then
						local sm = ce:FindFirstChild("SayMessageRequest")
						if sm then sm:FireServer(State.Misc.SpamMsg or "Vertex Hub!", "All") end
					end
				end)
			end
			task.wait(State.Misc.SpamDelay or 2)
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
	
	local function updateChams()
		for name, data in pairs(EntityCache.players) do
			if data.Character then
				local existing = data.Character:FindFirstChild("VertexChams")
				if State.ESP.Chams then
					if not existing then
						local h = Instance.new("Highlight")
						h.Name = "VertexChams"
						h.FillColor = Color3.fromRGB(255, 0, 0)
						h.FillTransparency = 0.5
						h.Parent = data.Character
					end
				else
					if existing then existing:Destroy() end
				end
			end
		end
	end
	
	local lastCacheUpdate = 0
	RunService.RenderStepped:Connect(function()
		camera = workspace.CurrentCamera
		local char, root, hum = getCharacter(), getRoot(), getHumanoid()
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
		elseif FlySystem.enabled then FlySystem:Disable() end
		if State.Movement.Noclip and char then
			for _, p in ipairs(char:GetDescendants()) do
				if p:IsA("BasePart") then p.CanCollide = false end
			end
		end
		if State.Movement.Speed and hum then hum.WalkSpeed = State.Movement.SpeedValue or 16 end
		if State.Movement.JumpPower and hum then hum.JumpPower = State.Movement.JumpValue or 50 end
		if State.Movement.BunnyHop and hum and hum.FloorMaterial ~= Enum.Material.Air then
			hum:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		if State.Movement.AntiVoid and root and root.Position.Y < (State.Movement.VoidHeight or -100) then
			root.CFrame = CFrame.new(root.Position.X, 50, root.Position.Z)
		end
		if State.Combat.AimAssist and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
			local target = getBestTarget({ Range = 1000 })
			if target and target.RootPart then
				local pos = target.RootPart.Position
				if State.Combat.AimPrediction then
					pos = pos + target.RootPart.Velocity * (State.Combat.PredictionAmount or 0.1)
				end
				camera.CFrame = camera.CFrame:Lerp(CFrame.new(camera.CFrame.Position, pos), State.Combat.AimSmoothness or 0.15)
			end
		end
		if State.Combat.KillAura and root then
			local now = tick()
			local cd = 1 / (State.Combat.KillAuraCPS or 10)
			if now - LastAttackTime >= cd then
				local target = getBestTarget({ Range = State.Combat.KillAuraRange or 15 })
				if target and target.RootPart then
					LastAttackTime = now
					CurrentTarget = target
					local tool = getTool()
					if tool then
						pcall(function() tool:Activate() end)
						if firetouchinterest then
							local handle = tool:FindFirstChild("Handle")
							if handle then
								pcall(function()
									firetouchinterest(handle, target.RootPart, 0)
									task.defer(function() firetouchinterest(handle, target.RootPart, 1) end)
								end)
							end
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
					local ang = tick() * (State.Troll.OrbitSpeed or 2)
					local off = Vector3.new(math.cos(ang) * (State.Troll.OrbitRadius or 10), 0, math.sin(ang) * (State.Troll.OrbitRadius or 10))
					root.CFrame = CFrame.new(tr.Position + off, tr.Position)
				end
			end
		end
		if State.Troll.Fling and root then
			root.Velocity = Vector3.new(math.random(-500, 500), math.random(100, 500), math.random(-500, 500))
		end
		if State.Troll.Headless and char then
			local head = char:FindFirstChild("Head")
			if head then head.Transparency = 1 end
		end
		if State.Visuals.Freecam then
			local spd = 2
			local dir = Vector3.new()
			if UIS:IsKeyDown(Enum.KeyCode.W) then dir = dir + camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then dir = dir - camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then dir = dir - camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then dir = dir + camera.CFrame.RightVector end
			if dir.Magnitude > 0 then FreecamPos = FreecamPos + dir.Unit * spd end
			camera.CameraType = Enum.CameraType.Scriptable
			camera.CFrame = CFrame.new(FreecamPos) * CFrame.Angles(math.rad(FreecamAngles.X), math.rad(FreecamAngles.Y), 0)
		end
		if HUD.FOVCircle then
			HUD.FOVCircle.Visible = State.Combat.ShowFOVCircle
			HUD.FOVCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			HUD.FOVCircle.Radius = State.Combat.AimFOV or 150
			HUD.FOVCircle.Color = State.Settings.AccentColor or Color3.fromRGB(60, 120, 255)
		end
		if HUD.Watermark then
			HUD.Watermark.Visible = State.Misc.Watermark
			HUD.Watermark.Text = "Vertex Hub"
			HUD.Watermark.Color = State.Settings.AccentColor or Color3.fromRGB(60, 120, 255)
		end
		if HUD.FPS then
			HUD.FPS.Visible = State.Misc.FPSCounter
			HUD.FPS.Text = "FPS: " .. FPSData.fps
			HUD.FPS.Color = Color3.new(1, 1, 1)
		end
		releaseAllDrawings()
		local anyESP = State.ESP.NameESP or State.ESP.BoxESP or State.ESP.HealthESP or State.ESP.Tracers
		if anyESP then
			for name, data in pairs(EntityCache.players) do
				if data.RootPart and data.Humanoid and data.Humanoid.Health > 0 then
					local dist = root and (root.Position - data.RootPart.Position).Magnitude or 0
					if dist <= (State.ESP.MaxDistance or 1000) then
						local pos, onScreen = camera:WorldToViewportPoint(data.RootPart.Position)
						local sc = math.clamp(1 / (pos.Z * 0.04), 0.2, 2)
						if onScreen then
							if State.ESP.NameESP then
								local t = getDrawing("text")
								if t then t.Text = name t.Position = Vector2.new(pos.X, pos.Y - 50 * sc) t.Color = Color3.new(1, 1, 1) t.Size = 14 end
							end
							if State.ESP.HealthESP then
								local t = getDrawing("text")
								if t then t.Text = math.floor((data.Humanoid.Health / data.Humanoid.MaxHealth) * 100) .. "%" t.Position = Vector2.new(pos.X, pos.Y - 35 * sc) t.Color = Color3.fromRGB(100, 255, 100) t.Size = 12 end
							end
							if State.ESP.BoxESP then
								local b = getDrawing("square")
								if b then local sz = Vector2.new(50 * sc, 70 * sc) b.Size = sz b.Position = Vector2.new(pos.X - sz.X / 2, pos.Y - sz.Y / 2) b.Color = Color3.fromRGB(255, 0, 0) end
							end
							if State.ESP.Tracers then
								local l = getDrawing("line")
								if l then l.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y) l.To = Vector2.new(pos.X, pos.Y) l.Color = Color3.fromRGB(255, 255, 0) end
							end
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
	
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.Space and State.Movement.InfiniteJump then
			local hum = getHumanoid()
			if hum then hum:ChangeState(Enum.HumanoidStateType.Jumping) end
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if State.Movement.ClickTP then
				local root = getRoot()
				if root and mouse.Hit then root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
			end
			if State.World.DeleteMode then
				local tgt = mouse.Target
				if tgt and not tgt:IsDescendantOf(player.Character or {}) then tgt:Destroy() end
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
	
	local Colors = {
		Background = Color3.fromRGB(12, 12, 18), Panel = Color3.fromRGB(18, 18, 26), Surface = Color3.fromRGB(22, 22, 32),
		Content = Color3.fromRGB(16, 16, 24), Scroll = Color3.fromRGB(14, 14, 20), Accent = Color3.fromRGB(60, 120, 255),
		Text = Color3.fromRGB(220, 220, 240), Dim = Color3.fromRGB(120, 120, 140), Border = Color3.fromRGB(40, 45, 60),
		Btn = Color3.fromRGB(28, 30, 40), BtnHover = Color3.fromRGB(38, 42, 55), SliderBg = Color3.fromRGB(22, 24, 32)
	}
	
	if not Components then
		Components = {}
		local function corner(o, r) local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, r or 6) c.Parent = o end
		local function stroke(o) local s = Instance.new("UIStroke") s.Color = Colors.Border s.Thickness = 1 s.Transparency = 0.4 s.Parent = o end
		
		function Components.createSection(parent, text)
			local f = Instance.new("Frame") f.Size = UDim2.new(1, -16, 0, 26) f.BackgroundTransparency = 1 f.Parent = parent
			local line = Instance.new("Frame") line.Size = UDim2.new(0, 3, 0, 14) line.Position = UDim2.new(0, 0, 0.5, 0) line.AnchorPoint = Vector2.new(0, 0.5) line.BackgroundColor3 = Colors.Accent line.BorderSizePixel = 0 line.Parent = f corner(line, 2)
			local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, -12, 1, 0) lbl.Position = UDim2.new(0, 10, 0, 0) lbl.BackgroundTransparency = 1 lbl.Text = text:upper() lbl.TextColor3 = Colors.Text lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Font = Enum.Font.GothamBold lbl.TextSize = 10 lbl.Parent = f
		end
		
		function Components.createDivider(parent)
			local d = Instance.new("Frame") d.Size = UDim2.new(1, -32, 0, 1) d.BackgroundColor3 = Colors.Border d.BorderSizePixel = 0 d.BackgroundTransparency = 0.4 d.Parent = parent
		end
		
		function Components.createLabel(parent, text)
			local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, -16, 0, 22) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Colors.Dim lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Font = Enum.Font.Gotham lbl.TextSize = 11 lbl.TextWrapped = true lbl.Parent = parent
		end
		
		function Components.createToggle(parent, text, callback)
			local state = false
			local btn = Instance.new("TextButton") btn.Name = "Toggle_" .. text:gsub("%s+", "_") btn.Size = UDim2.new(1, -16, 0, 32) btn.BackgroundColor3 = Colors.Btn btn.BorderSizePixel = 0 btn.AutoButtonColor = false btn.Text = "" btn.Parent = parent corner(btn) stroke(btn)
			local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, -50, 1, 0) lbl.Position = UDim2.new(0, 12, 0, 0) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Colors.Dim lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Font = Enum.Font.GothamMedium lbl.TextSize = 12 lbl.Parent = btn
			local ind = Instance.new("Frame") ind.Size = UDim2.new(0, 0, 0, 2) ind.Position = UDim2.new(0, 0, 1, -2) ind.BackgroundColor3 = Colors.Accent ind.BorderSizePixel = 0 ind.Parent = btn corner(ind, 1)
			local tbg = Instance.new("Frame") tbg.Size = UDim2.new(0, 34, 0, 18) tbg.Position = UDim2.new(1, -44, 0.5, 0) tbg.AnchorPoint = Vector2.new(0, 0.5) tbg.BackgroundColor3 = Colors.SliderBg tbg.BorderSizePixel = 0 tbg.Parent = btn corner(tbg, 9)
			local tc = Instance.new("Frame") tc.Size = UDim2.new(0, 14, 0, 14) tc.Position = UDim2.new(0, 2, 0.5, 0) tc.AnchorPoint = Vector2.new(0, 0.5) tc.BackgroundColor3 = Colors.Dim tc.BorderSizePixel = 0 tc.Parent = tbg corner(tc, 7)
			local function applyVisual()
				if state then
					tween(btn, {BackgroundColor3 = Color3.fromRGB(35, 50, 80)})
					tween(lbl, {TextColor3 = Color3.new(1, 1, 1)})
					tween(ind, {Size = UDim2.new(1, 0, 0, 2)})
					tween(tbg, {BackgroundColor3 = Colors.Accent})
					tween(tc, {Position = UDim2.new(1, -16, 0.5, 0), BackgroundColor3 = Color3.new(1, 1, 1)})
				else
					tween(btn, {BackgroundColor3 = Colors.Btn})
					tween(lbl, {TextColor3 = Colors.Dim})
					tween(ind, {Size = UDim2.new(0, 0, 0, 2)})
					tween(tbg, {BackgroundColor3 = Colors.SliderBg})
					tween(tc, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Colors.Dim})
				end
			end
			btn.MouseButton1Click:Connect(function()
				state = not state
				applyVisual()
				if callback then task.spawn(callback, state) end
			end)
			local toggleObject = {
				Button = btn,
				UpdateState = function(self, newState)
					if typeof(newState) ~= "boolean" then return end
					state = newState
					applyVisual()
					if callback then task.spawn(callback, state) end
				end,
				GetState = function(self) return state end
			}
			return toggleObject
		end
		
		function Components.createSlider(parent, text, min, max, default, callback)
			local cont = Instance.new("Frame") cont.Size = UDim2.new(1, -16, 0, 50) cont.BackgroundColor3 = Colors.Btn cont.BorderSizePixel = 0 cont.Parent = parent corner(cont) stroke(cont)
			local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(1, -60, 0, 18) lbl.Position = UDim2.new(0, 12, 0, 5) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Colors.Dim lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Font = Enum.Font.GothamMedium lbl.TextSize = 11 lbl.Parent = cont
			local val = Instance.new("TextLabel") val.Size = UDim2.new(0, 48, 0, 18) val.Position = UDim2.new(1, -60, 0, 5) val.BackgroundTransparency = 1 val.Text = tostring(default) val.TextColor3 = Colors.Accent val.TextXAlignment = Enum.TextXAlignment.Right val.Font = Enum.Font.GothamBold val.TextSize = 11 val.Parent = cont
			local sbg = Instance.new("Frame") sbg.Size = UDim2.new(1, -24, 0, 6) sbg.Position = UDim2.new(0, 12, 1, -15) sbg.BackgroundColor3 = Colors.SliderBg sbg.BorderSizePixel = 0 sbg.Parent = cont corner(sbg, 3)
			local fill = Instance.new("Frame") fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0) fill.BackgroundColor3 = Colors.Accent fill.BorderSizePixel = 0 fill.Parent = sbg corner(fill, 3)
			local handle = Instance.new("Frame") handle.Size = UDim2.new(0, 14, 0, 14) handle.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0) handle.AnchorPoint = Vector2.new(0.5, 0.5) handle.BackgroundColor3 = Color3.fromRGB(100, 180, 255) handle.BorderSizePixel = 0 handle.ZIndex = 2 handle.Parent = sbg corner(handle, 7)
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
			local cont = Instance.new("Frame") cont.Size = UDim2.new(1, -16, 0, 40) cont.BackgroundColor3 = Colors.Btn cont.BorderSizePixel = 0 cont.Parent = parent corner(cont) stroke(cont)
			local lbl = Instance.new("TextLabel") lbl.Size = UDim2.new(0, 80, 1, 0) lbl.Position = UDim2.new(0, 8, 0, 0) lbl.BackgroundTransparency = 1 lbl.Text = text lbl.TextColor3 = Colors.Dim lbl.TextXAlignment = Enum.TextXAlignment.Left lbl.Font = Enum.Font.GothamMedium lbl.TextSize = 12 lbl.Parent = cont
			local input = Instance.new("TextBox") input.Size = UDim2.new(1, -100, 1, -12) input.Position = UDim2.new(0, 88, 0, 6) input.BackgroundColor3 = Colors.SliderBg input.BorderSizePixel = 0 input.Text = "" input.PlaceholderText = placeholder or "" input.TextColor3 = Colors.Text input.PlaceholderColor3 = Colors.Dim input.Font = Enum.Font.Gotham input.TextSize = 12 input.ClearTextOnFocus = false input.Parent = cont corner(input, 4)
			input.FocusLost:Connect(function(enter) if enter and callback then callback(input.Text) end end)
			return cont
		end
	end
	_G.VertexComponents = Components
	
	if not Tabs then
		Tabs = {}
		local tabButtons = {}
		local tabContents = {}
		function Tabs.setupTabBar(bar)
			local layout = Instance.new("UIListLayout") layout.FillDirection = Enum.FillDirection.Horizontal layout.Padding = UDim.new(0, 4) layout.SortOrder = Enum.SortOrder.LayoutOrder layout.Parent = bar
			local pad = Instance.new("UIPadding") pad.PaddingLeft = UDim.new(0, 10) pad.PaddingTop = UDim.new(0, 8) pad.Parent = bar
		end
		function Tabs.create(bar, name, icon)
			local btn = Instance.new("TextButton") btn.Size = UDim2.new(0, 90, 0, 30) btn.BackgroundColor3 = Colors.Surface btn.BorderSizePixel = 0 btn.AutoButtonColor = false btn.Text = (icon or "") .. " " .. name btn.TextColor3 = Colors.Dim btn.Font = Enum.Font.GothamMedium btn.TextSize = 11 btn.Parent = bar
			local c = Instance.new("UICorner") c.CornerRadius = UDim.new(0, 6) c.Parent = btn
			local ind = Instance.new("Frame") ind.Size = UDim2.new(0.6, 0, 0, 2) ind.Position = UDim2.new(0.2, 0, 1, -2) ind.BackgroundColor3 = Colors.Accent ind.BackgroundTransparency = 1 ind.BorderSizePixel = 0 ind.Parent = btn
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
	
	local gui = Instance.new("ScreenGui") gui.Name = "VertexHub" gui.ResetOnSpawn = false gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling gui.Parent = player:WaitForChild("PlayerGui")
	local main = Instance.new("Frame") main.Name = "Main" main.Size = UDim2.new(0, 800, 0, 550) main.Position = UDim2.new(0.5, 0, 0.5, 0) main.AnchorPoint = Vector2.new(0.5, 0.5) main.BackgroundColor3 = Colors.Background main.BorderSizePixel = 0 main.ClipsDescendants = true main.Visible = false main.Parent = gui
	local mc = Instance.new("UICorner") mc.CornerRadius = UDim.new(0, 10) mc.Parent = main
	local ms = Instance.new("UIStroke") ms.Color = Colors.Border ms.Thickness = 2 ms.Parent = main
	
	local hdr = Instance.new("Frame") hdr.Size = UDim2.new(1, 0, 0, 45) hdr.BackgroundColor3 = Colors.Panel hdr.BorderSizePixel = 0 hdr.Parent = main
	local ttl = Instance.new("TextLabel") ttl.Size = UDim2.new(0, 300, 1, 0) ttl.Position = UDim2.new(0, 15, 0, 0) ttl.BackgroundTransparency = 1 ttl.Text = "VERTEX HUB" ttl.TextColor3 = Colors.Text ttl.TextXAlignment = Enum.TextXAlignment.Left ttl.Font = Enum.Font.GothamBold ttl.TextSize = 18 ttl.Parent = hdr
	local acc = Instance.new("Frame") acc.Size = UDim2.new(0, 60, 0, 3) acc.Position = UDim2.new(0, 15, 1, -3) acc.BackgroundColor3 = Colors.Accent acc.BorderSizePixel = 0 acc.Parent = hdr
	local accC = Instance.new("UICorner") accC.CornerRadius = UDim.new(1, 0) accC.Parent = acc
	
	local cls = Instance.new("TextButton") cls.Size = UDim2.new(0, 30, 0, 30) cls.Position = UDim2.new(1, -40, 0.5, 0) cls.AnchorPoint = Vector2.new(0, 0.5) cls.BackgroundColor3 = Color3.fromRGB(30, 30, 40) cls.Text = "X" cls.TextColor3 = Colors.Text cls.Font = Enum.Font.GothamBold cls.TextSize = 20 cls.AutoButtonColor = false cls.Parent = hdr
	local clsC = Instance.new("UICorner") clsC.CornerRadius = UDim.new(0, 6) clsC.Parent = cls
	cls.MouseButton1Click:Connect(function() main.Visible = false UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default UIS.MouseIconEnabled = PrevMouseState.icon ~= false end)
	cls.MouseEnter:Connect(function() cls.BackgroundColor3 = Color3.fromRGB(180, 50, 50) end)
	cls.MouseLeave:Connect(function() cls.BackgroundColor3 = Color3.fromRGB(30, 30, 40) end)
	
	local tabBar = Instance.new("Frame") tabBar.Size = UDim2.new(1, 0, 0, 45) tabBar.Position = UDim2.new(0, 0, 0, 45) tabBar.BackgroundColor3 = Colors.Surface tabBar.BorderSizePixel = 0 tabBar.Parent = main
	Tabs.setupTabBar(tabBar)
	
	local cArea = Instance.new("Frame") cArea.Size = UDim2.new(1, 0, 1, -90) cArea.Position = UDim2.new(0, 0, 0, 90) cArea.BackgroundColor3 = Colors.Content cArea.BorderSizePixel = 0 cArea.Parent = main
	local cCont = Instance.new("Frame") cCont.Size = UDim2.new(1, -20, 1, -12) cCont.Position = UDim2.new(0, 10, 0, 6) cCont.BackgroundTransparency = 1 cCont.Parent = cArea
	
	local function makeTab(nm)
		local scr = Instance.new("ScrollingFrame") scr.Name = nm scr.Size = UDim2.new(1, 0, 1, 0) scr.BackgroundColor3 = Colors.Scroll scr.BackgroundTransparency = 0 scr.BorderSizePixel = 0 scr.ScrollBarThickness = 4 scr.ScrollBarImageColor3 = Colors.Accent scr.CanvasSize = UDim2.new(0, 0, 0, 0) scr.AutomaticCanvasSize = Enum.AutomaticSize.Y scr.Visible = false scr.Parent = cCont
		local lay = Instance.new("UIListLayout") lay.Padding = UDim.new(0, 6) lay.SortOrder = Enum.SortOrder.LayoutOrder lay.Parent = scr
		local pad = Instance.new("UIPadding") pad.PaddingTop = UDim.new(0, 4) pad.PaddingBottom = UDim.new(0, 8) pad.PaddingLeft = UDim.new(0, 4) pad.PaddingRight = UDim.new(0, 8) pad.Parent = scr
		return scr
	end
	
	local combatC = makeTab("Combat")
	local moveC = makeTab("Movement")
	local espC = makeTab("ESP")
	local visC = makeTab("Visuals")
	local playerC = makeTab("Player")
	local miscC = makeTab("Misc")
	
	local combatT = Tabs.create(tabBar, "Combat", "*")
	local moveT = Tabs.create(tabBar, "Move", ">")
	local espT = Tabs.create(tabBar, "ESP", "o")
	local visT = Tabs.create(tabBar, "Visual", "#")
	local playerT = Tabs.create(tabBar, "Player", "U")
	local miscT = Tabs.create(tabBar, "Misc", "S")
	
	Tabs.connectTab(combatT, combatC)
	Tabs.connectTab(moveT, moveC)
	Tabs.connectTab(espT, espC)
	Tabs.connectTab(visT, visC)
	Tabs.connectTab(playerT, playerC)
	Tabs.connectTab(miscT, miscC)
	
	Components.createSection(combatC, "Aim Assist")
	ToggleRefs.AimAssist = Components.createToggle(combatC, "Aim Assist", function(v) State.Combat.AimAssist = v end)
	Components.createSlider(combatC, "Smoothness", 1, 100, 15, function(v) State.Combat.AimSmoothness = v / 200 end)
	Components.createSlider(combatC, "FOV", 50, 600, 150, function(v) State.Combat.AimFOV = v end)
	ToggleRefs.ShowFOVCircle = Components.createToggle(combatC, "Show FOV Circle", function(v) State.Combat.ShowFOVCircle = v end)
	ToggleRefs.AimPrediction = Components.createToggle(combatC, "Prediction", function(v) State.Combat.AimPrediction = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Silent Aim")
	ToggleRefs.SilentAim = Components.createToggle(combatC, "Silent Aim", function(v) State.Combat.SilentAim = v end)
	Components.createSlider(combatC, "Hit Chance", 0, 100, 100, function(v) State.Combat.SilentAimHitChance = v end)
	Components.createDivider(combatC)
	Components.createSection(combatC, "Kill Aura")
	ToggleRefs.KillAura = Components.createToggle(combatC, "Kill Aura", function(v) State.Combat.KillAura = v end)
	Components.createSlider(combatC, "Range", 5, 50, 15, function(v) State.Combat.KillAuraRange = v end)
	Components.createSlider(combatC, "CPS", 1, 20, 10, function(v) State.Combat.KillAuraCPS = v end)
	ToggleRefs.KillAuraPlayers = Components.createToggle(combatC, "Target Players", function(v) State.Combat.KillAuraPlayers = v end)
	ToggleRefs.KillAuraNPCs = Components.createToggle(combatC, "Target NPCs", function(v) State.Combat.KillAuraNPCs = v end)
	
	Components.createSection(moveC, "Flight")
	ToggleRefs.Fly = Components.createToggle(moveC, "Fly", function(v) State.Movement.Fly = v end)
	Components.createSlider(moveC, "Fly Speed", 10, 300, 50, function(v) State.Movement.FlySpeed = v end)
	ToggleRefs.Noclip = Components.createToggle(moveC, "Noclip", function(v) State.Movement.Noclip = v end)
	Components.createDivider(moveC)
	Components.createSection(moveC, "Speed & Jump")
	ToggleRefs.Speed = Components.createToggle(moveC, "Speed", function(v) State.Movement.Speed = v if not v then local h = getHumanoid() if h then h.WalkSpeed = 16 end end end)
	Components.createSlider(moveC, "Speed Value", 16, 500, 16, function(v) State.Movement.SpeedValue = v end)
	ToggleRefs.JumpPower = Components.createToggle(moveC, "Jump Power", function(v) State.Movement.JumpPower = v if not v then local h = getHumanoid() if h then h.JumpPower = 50 end end end)
	Components.createSlider(moveC, "Jump Value", 50, 500, 50, function(v) State.Movement.JumpValue = v end)
	ToggleRefs.InfiniteJump = Components.createToggle(moveC, "Infinite Jump", function(v) State.Movement.InfiniteJump = v end)
	ToggleRefs.BunnyHop = Components.createToggle(moveC, "Bunny Hop", function(v) State.Movement.BunnyHop = v end)
	Components.createDivider(moveC)
	ToggleRefs.ClickTP = Components.createToggle(moveC, "Click TP", function(v) State.Movement.ClickTP = v end)
	ToggleRefs.AntiVoid = Components.createToggle(moveC, "Anti Void", function(v) State.Movement.AntiVoid = v end)
	
	Components.createSection(espC, "Player ESP")
	ToggleRefs.NameESP = Components.createToggle(espC, "Name ESP", function(v) State.ESP.NameESP = v end)
	ToggleRefs.BoxESP = Components.createToggle(espC, "Box ESP", function(v) State.ESP.BoxESP = v end)
	ToggleRefs.HealthESP = Components.createToggle(espC, "Health ESP", function(v) State.ESP.HealthESP = v end)
	ToggleRefs.Tracers = Components.createToggle(espC, "Tracers", function(v) State.ESP.Tracers = v end)
	ToggleRefs.Chams = Components.createToggle(espC, "Chams", function(v) State.ESP.Chams = v updateChams() end)
	Components.createDivider(espC)
	Components.createSlider(espC, "Max Distance", 100, 2000, 1000, function(v) State.ESP.MaxDistance = v end)
	ToggleRefs.TeamCheck = Components.createToggle(espC, "Team Check", function(v) State.ESP.TeamCheck = v end)
	
	Components.createSection(visC, "Lighting")
	ToggleRefs.Fullbright = Components.createToggle(visC, "Fullbright", function(v) State.Visuals.Fullbright = v if v then Lighting.Ambient = Color3.new(1, 1, 1) Lighting.Brightness = 2 else Lighting.Ambient = OriginalLighting.Ambient Lighting.Brightness = OriginalLighting.Brightness end end)
	ToggleRefs.NoFog = Components.createToggle(visC, "No Fog", function(v) State.Visuals.NoFog = v if v then Lighting.FogEnd = 1e10 else Lighting.FogEnd = OriginalLighting.FogEnd end end)
	ToggleRefs.NoShadows = Components.createToggle(visC, "No Shadows", function(v) State.Visuals.NoShadows = v Lighting.GlobalShadows = not v end)
	Components.createDivider(visC)
	Components.createSection(visC, "Crosshair")
	ToggleRefs.Crosshair = Components.createToggle(visC, "Custom Crosshair", function(v) State.Visuals.Crosshair = v end)
	Components.createSlider(visC, "Camera FOV", 30, 120, 70, function(v) State.Visuals.CameraFOV = v camera.FieldOfView = v end)
	ToggleRefs.Freecam = Components.createToggle(visC, "Freecam", function(v) State.Visuals.Freecam = v if v then FreecamPos = camera.CFrame.Position UIS.MouseBehavior = Enum.MouseBehavior.LockCenter else camera.CameraType = Enum.CameraType.Custom UIS.MouseBehavior = Enum.MouseBehavior.Default end end)
	
	Components.createSection(playerC, "Character")
	ToggleRefs.GodMode = Components.createToggle(playerC, "God Mode", function(v) State.Player.GodMode = v end)
	ToggleRefs.NoRagdoll = Components.createToggle(playerC, "No Ragdoll", function(v) State.Player.NoRagdoll = v end)
	ToggleRefs.AutoRespawn = Components.createToggle(playerC, "Auto Respawn", function(v) State.Player.AutoRespawn = v end)
	Components.createDivider(playerC)
	Components.createSection(playerC, "Invisibility")
	ToggleRefs.Invisibility = Components.createToggle(playerC, "Invisibility", function(v) State.Player.Invisibility = v if v then InvisSystem:Enable() else InvisSystem:Disable() end end)
	Components.createSlider(playerC, "Invis Offset", 50, 500, 100, function(v) State.Player.InvisOffset = v end)
	
	Components.createSection(miscC, "HUD")
	ToggleRefs.Watermark = Components.createToggle(miscC, "Watermark", function(v) State.Misc.Watermark = v end)
	ToggleRefs.FPSCounter = Components.createToggle(miscC, "FPS Counter", function(v) State.Misc.FPSCounter = v end)
	ToggleRefs.AntiAFK = Components.createToggle(miscC, "Anti AFK", function(v) State.Misc.AntiAFK = v end)
	Components.createDivider(miscC)
	Components.createSection(miscC, "Config")
	local configInput = Components.createInput(miscC, "Config", "Enter name...", function() end)
	
	local cfgBtns = Instance.new("Frame") cfgBtns.Size = UDim2.new(1, -16, 0, 30) cfgBtns.BackgroundTransparency = 1 cfgBtns.Parent = miscC
	local saveBtn = Instance.new("TextButton") saveBtn.Size = UDim2.new(0.3, -4, 1, 0) saveBtn.BackgroundColor3 = Color3.fromRGB(60, 180, 80) saveBtn.Text = "Save" saveBtn.TextColor3 = Color3.new(1, 1, 1) saveBtn.Font = Enum.Font.GothamBold saveBtn.TextSize = 12 saveBtn.Parent = cfgBtns local saveC = Instance.new("UICorner") saveC.CornerRadius = UDim.new(0, 4) saveC.Parent = saveBtn
	local loadBtn = Instance.new("TextButton") loadBtn.Size = UDim2.new(0.3, -4, 1, 0) loadBtn.Position = UDim2.new(0.35, 0, 0, 0) loadBtn.BackgroundColor3 = Color3.fromRGB(60, 120, 255) loadBtn.Text = "Load" loadBtn.TextColor3 = Color3.new(1, 1, 1) loadBtn.Font = Enum.Font.GothamBold loadBtn.TextSize = 12 loadBtn.Parent = cfgBtns local loadC = Instance.new("UICorner") loadC.CornerRadius = UDim.new(0, 4) loadC.Parent = loadBtn
	local delBtn = Instance.new("TextButton") delBtn.Size = UDim2.new(0.3, -4, 1, 0) delBtn.Position = UDim2.new(0.7, 0, 0, 0) delBtn.BackgroundColor3 = Color3.fromRGB(180, 60, 60) delBtn.Text = "Delete" delBtn.TextColor3 = Color3.new(1, 1, 1) delBtn.Font = Enum.Font.GothamBold delBtn.TextSize = 12 delBtn.Parent = cfgBtns local delC = Instance.new("UICorner") delC.CornerRadius = UDim.new(0, 4) delC.Parent = delBtn
	
	saveBtn.MouseButton1Click:Connect(function()
		local inp = configInput:FindFirstChildOfClass("TextBox")
		local name = inp and inp.Text or "default"
		if name == "" then name = "default" end
		saveConfig(name)
	end)
	loadBtn.MouseButton1Click:Connect(function()
		local inp = configInput:FindFirstChildOfClass("TextBox")
		local name = inp and inp.Text or "default"
		if name == "" then name = "default" end
		loadConfig(name)
	end)
	delBtn.MouseButton1Click:Connect(function()
		local inp = configInput:FindFirstChildOfClass("TextBox")
		local name = inp and inp.Text or ""
		if name ~= "" then deleteConfig(name) end
	end)
	
	Components.createDivider(miscC)
	local serverToggle = Components.createToggle(miscC, "Server Hop", function(v)
		if v then
			pcall(function()
				local s, d = pcall(function() return HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100")) end)
				if s and d and d.data then
					for _, srv in ipairs(d.data) do
						if srv.id ~= game.JobId then TeleportService:TeleportToPlaceInstance(game.PlaceId, srv.id) break end
					end
				end
			end)
			if serverToggle and type(serverToggle) == "table" and serverToggle.UpdateState then
				serverToggle.UpdateState(serverToggle, false)
			end
		end
	end)
	local rejoinToggle = Components.createToggle(miscC, "Rejoin", function(v)
		if v then
			TeleportService:Teleport(game.PlaceId)
			if rejoinToggle and type(rejoinToggle) == "table" and rejoinToggle.UpdateState then
				rejoinToggle.UpdateState(rejoinToggle, false)
			end
		end
	end)
	
	Tabs.activate(combatT, combatC)
	
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == (State.Settings.MenuKey or Enum.KeyCode.M) then
			local show = not main.Visible
			main.Visible = show
			if show then
				PrevMouseState.behavior = UIS.MouseBehavior
				PrevMouseState.icon = UIS.MouseIconEnabled
				UIS.MouseBehavior = Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = true
				main.Size = UDim2.new(0, 0, 0, 0)
				tween(main, {Size = UDim2.new(0, 800, 0, 550)}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
			else
				UIS.MouseBehavior = PrevMouseState.behavior or Enum.MouseBehavior.Default
				UIS.MouseIconEnabled = PrevMouseState.icon ~= false
			end
		end
	end)
	
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
	
	player.CharacterAdded:Connect(function(c)
		task.wait(0.5)
		local h = c:FindFirstChildOfClass("Humanoid")
		if h then
			if State.Movement.Speed then h.WalkSpeed = State.Movement.SpeedValue or 16 end
			if State.Movement.JumpPower then h.JumpPower = State.Movement.JumpValue or 50 end
		end
		if State.ESP.Chams then updateChams() end
		if State.Player.Invisibility then task.wait(0.2) InvisSystem:Enable() end
	end)
	
	Players.PlayerAdded:Connect(function() task.wait(1) if State.ESP.Chams then updateChams() end end)
	Players.PlayerRemoving:Connect(function(p) EntityCache.players[p.Name] = nil BacktrackPositions[p.Name] = nil end)
	
	print("[Vertex Hub] Loaded! Press M to toggle menu.")
	return State
end
