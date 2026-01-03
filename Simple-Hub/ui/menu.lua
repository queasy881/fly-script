-- ui/menu.lua
-- Premium main menu interface - FULLY WIRED UP - NO GRAY

return function(deps)
	local Tabs = deps.Tabs
	local Components = deps.Components
	local Animations = deps.Animations
	
	if not Tabs or not Components or not Animations then
		error("[Menu] Missing dependencies")
	end
	
	print("[SimpleHub] Initializing premium UI...")
	
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local TweenService = game:GetService("TweenService")
	local RunService = game:GetService("RunService")
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local mouse = player:GetMouse()



	
	-- Wait for character
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
	-- LOAD ALL MODULES
	-- ============================================
	local BASE = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"
	
	local function loadModule(path)
		local success, result = pcall(function()
			local src = game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
			return loadstring(src)()
		end)
		if success then
			return result
		else
			warn("[SimpleHub] Failed to load " .. path .. ": " .. tostring(result))
			return nil
		end
	end
	
	-- Movement modules
	local Fly = loadModule("movement/fly.lua")
	local Noclip = loadModule("movement/noclip.lua")
	local WalkSpeed = loadModule("movement/walkspeed.lua")
	local JumpPower = loadModule("movement/jumppower.lua")
	local BunnyHop = loadModule("movement/bunnyhop.lua")
	local Dash = loadModule("movement/dash.lua")
	local AirControl = loadModule("movement/air-control.lua")
	
	-- Combat modules
	local AimAssist = loadModule("combat/aim_assist.lua")
	local SilentAim = loadModule("combat/silent_aim.lua")
	local FOV = loadModule("combat/fov.lua")
	
	-- Extra modules
	local Fullbright = loadModule("extra/fullbright.lua")
	local RemoveGrass = loadModule("extra/remove-grass.lua")
	local ThirdPerson = loadModule("extra/third-person.lua")
	local AntiAFK = loadModule("extra/anti-afk.lua")
	local Invisibility = loadModule("extra/invisibility.lua")
	local WalkOnWater = loadModule("extra/walk-on-water.lua")
	
	-- Create FOV circle if module loaded
	if FOV and FOV.create then
		FOV.create()
	end
	
	-- Local state for walkspeed/jumppower values
	local walkSpeedValue = 16
	local jumpPowerValue = 50
	
	-- ============================================
	-- ESP STATE (Built-in since modules may not exist)
	-- ============================================
	local ESPState = {
		NameESP = false,
		BoxESP = false,
		HealthESP = false,
		DistanceESP = false,
		Tracers = false,
		Chams = false
	}
	
	local ESPObjects = {}
	
	-- Simple ESP Drawing function
	local function updateESP()
		-- Clear old ESP
		for _, obj in pairs(ESPObjects) do
			if obj.Remove then obj:Remove() end
			if obj.Destroy then obj:Destroy() end
		end
		ESPObjects = {}
		
		if not (ESPState.NameESP or ESPState.BoxESP or ESPState.HealthESP or ESPState.DistanceESP or ESPState.Tracers) then
			return
		end
		
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				local char = plr.Character
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				local rootPart = char:FindFirstChild("HumanoidRootPart")
				local head = char:FindFirstChild("Head")
				
				if humanoid and humanoid.Health > 0 and rootPart and head then
					local pos, onScreen = camera:WorldToViewportPoint(rootPart.Position)
					
					if onScreen then
						local distance = (camera.CFrame.Position - rootPart.Position).Magnitude
						
						-- Name ESP
						if ESPState.NameESP then
							local nameTag = Drawing.new("Text")
							nameTag.Text = plr.Name
							nameTag.Size = 14
							nameTag.Color = Color3.fromRGB(255, 255, 255)
							nameTag.Center = true
							nameTag.Outline = true
							nameTag.Position = Vector2.new(pos.X, pos.Y - 50)
							nameTag.Visible = true
							table.insert(ESPObjects, nameTag)
						end
						
						-- Distance ESP
						if ESPState.DistanceESP then
							local distTag = Drawing.new("Text")
							distTag.Text = math.floor(distance) .. "m"
							distTag.Size = 12
							distTag.Color = Color3.fromRGB(200, 200, 200)
							distTag.Center = true
							distTag.Outline = true
							distTag.Position = Vector2.new(pos.X, pos.Y + 40)
							distTag.Visible = true
							table.insert(ESPObjects, distTag)
						end
						
						-- Health ESP
						if ESPState.HealthESP then
							local healthTag = Drawing.new("Text")
							healthTag.Text = math.floor(humanoid.Health) .. "/" .. math.floor(humanoid.MaxHealth)
							healthTag.Size = 12
							healthTag.Color = Color3.fromRGB(100, 255, 100)
							healthTag.Center = true
							healthTag.Outline = true
							healthTag.Position = Vector2.new(pos.X, pos.Y - 35)
							healthTag.Visible = true
							table.insert(ESPObjects, healthTag)
						end
						
						-- Box ESP
						if ESPState.BoxESP then
							local box = Drawing.new("Square")
							local size = Vector2.new(40, 60) * (1 / (distance / 100))
							box.Size = size
							box.Position = Vector2.new(pos.X - size.X/2, pos.Y - size.Y/2)
							box.Color = Color3.fromRGB(255, 0, 0)
							box.Thickness = 1
							box.Filled = false
							box.Visible = true
							table.insert(ESPObjects, box)
						end
						
						-- Tracers
						if ESPState.Tracers then
							local tracer = Drawing.new("Line")
							tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
							tracer.To = Vector2.new(pos.X, pos.Y)
							tracer.Color = Color3.fromRGB(255, 255, 0)
							tracer.Thickness = 1
							tracer.Visible = true
							table.insert(ESPObjects, tracer)
						end
					end
				end
			end
		end
	end
	
	-- Chams function
	local function updateChams()
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				for _, part in ipairs(plr.Character:GetDescendants()) do
					if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then
						local highlight = part:FindFirstChild("ESPHighlight")
						if ESPState.Chams then
							if not highlight then
								highlight = Instance.new("Highlight")
								highlight.Name = "ESPHighlight"
								highlight.FillColor = Color3.fromRGB(255, 0, 0)
								highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
								highlight.FillTransparency = 0.5
								highlight.OutlineTransparency = 0
								highlight.Adornee = plr.Character
								highlight.Parent = plr.Character
							end
						else
							if highlight then
								highlight:Destroy()
							end
						end
					end
				end
			end
		end
	end
	
	-- ============================================
	-- MAIN UPDATE LOOP
	-- ============================================
	RunService.RenderStepped:Connect(function(dt)
		local char = player.Character
		if not char then return end
		
		local root = char:FindFirstChild("HumanoidRootPart")
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if not root or not humanoid then return end
		
		-- Movement updates
		if Fly and Fly.update and Fly.enabled then
			Fly.update(root, camera, UIS)
		end
		
		if Noclip and Noclip.update and Noclip.enabled then
			Noclip.update(char)
		end
		
		if BunnyHop and BunnyHop.update and BunnyHop.enabled then
			BunnyHop.update(humanoid)
		end
		
		if AirControl and AirControl.update and AirControl.strength > 0 then
			AirControl.update(root, humanoid, camera, UIS)
		end
		
		-- Extra updates
		if AntiAFK and AntiAFK.update and AntiAFK.enabled then
			AntiAFK.update(dt)
		end
		
		if WalkOnWater and WalkOnWater.update and WalkOnWater.enabled then
			WalkOnWater.update(root)
		end
		
		-- ESP updates
		updateESP()
	end)
	
	-- ============================================
	-- COLORS - ALL DARK BLUE, NO GRAY
	-- ============================================
	local Colors = {
		Background = Color3.fromRGB(18, 18, 25),
		Panel = Color3.fromRGB(22, 22, 32),
		Surface = Color3.fromRGB(26, 26, 36),
		ContentBg = Color3.fromRGB(20, 20, 28),
		ScrollBg = Color3.fromRGB(18, 18, 25),      -- IMPORTANT: ScrollFrame background
		Accent = Color3.fromRGB(60, 120, 255),
		Text = Color3.fromRGB(220, 220, 240),
		TextDim = Color3.fromRGB(140, 140, 160),
		Border = Color3.fromRGB(45, 50, 65)
	}
	
	-- ============================================
	-- CREATE GUI
	-- ============================================
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHub"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	
	-- Main container
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 820, 0, 540)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Colors.Background
	main.BackgroundTransparency = 0
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Visible = false
	main.Parent = gui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = main
	
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Colors.Border
	mainStroke.Thickness = 2
	mainStroke.Transparency = 0.2
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Parent = main
	
	-- ============================================
	-- HEADER
	-- ============================================
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 55)
	header.Position = UDim2.new(0, 0, 0, 0)
	header.BackgroundColor3 = Colors.Panel
	header.BorderSizePixel = 0
	header.Parent = main
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0, 300, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "SIMPLE HUB"
	title.TextColor3 = Colors.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = header
	
	local titleAccent = Instance.new("Frame")
	titleAccent.Size = UDim2.new(0, 50, 0, 3)
	titleAccent.Position = UDim2.new(0, 20, 1, -3)
	titleAccent.BackgroundColor3 = Colors.Accent
	titleAccent.BorderSizePixel = 0
	titleAccent.Parent = header
	
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = titleAccent
	
	local version = Instance.new("TextLabel")
	version.Size = UDim2.new(0, 80, 0, 20)
	version.Position = UDim2.new(1, -130, 0.5, 0)
	version.AnchorPoint = Vector2.new(0, 0.5)
	version.BackgroundTransparency = 1
	version.Text = "v1.0"
	version.TextColor3 = Colors.TextDim
	version.TextXAlignment = Enum.TextXAlignment.Right
	version.Font = Enum.Font.GothamMedium
	version.TextSize = 11
	version.Parent = header
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -42, 0.5, 0)
	closeBtn.AnchorPoint = Vector2.new(0, 0.5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Colors.Text
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 20
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 6)
	closeBtnCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		main.Visible = false
	end)
	
	closeBtn.MouseEnter:Connect(function()
		Animations.tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(200, 50, 50)}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
	end)
	
	closeBtn.MouseLeave:Connect(function()
		Animations.tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
	end)
	
	-- ============================================
	-- TAB BAR
	-- ============================================
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, 0, 0, 68)
	tabBar.Position = UDim2.new(0, 0, 0, 55)
	tabBar.BackgroundColor3 = Colors.Surface
	tabBar.BorderSizePixel = 0
	tabBar.Parent = main
	
	Tabs.setupTabBar(tabBar)
	
	-- ============================================
	-- CONTENT AREA - WITH EXPLICIT DARK BACKGROUND
	-- ============================================
	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, 0, 1, -123)
	contentArea.Position = UDim2.new(0, 0, 0, 123)
	contentArea.BackgroundColor3 = Colors.ContentBg  -- DARK BLUE BACKGROUND
	contentArea.BorderSizePixel = 0
	contentArea.Parent = main
	
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -24, 1, -16)
	contentContainer.Position = UDim2.new(0, 12, 0, 8)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = contentArea
	
	-- Create tab content frames WITH DARK BACKGROUND
	local function createTabContent(name)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = name .. "Content"
		scroll.Size = UDim2.new(1, 0, 1, 0)
		scroll.BackgroundColor3 = Colors.ScrollBg  -- EXPLICIT DARK BACKGROUND
		scroll.BackgroundTransparency = 0          -- NOT TRANSPARENT
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 4
		scroll.ScrollBarImageColor3 = Colors.Accent
		scroll.ScrollBarImageTransparency = 0.3
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Visible = false
		scroll.Parent = contentContainer
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = scroll
		
		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 4)
		padding.PaddingBottom = UDim.new(0, 8)
		padding.PaddingLeft = UDim.new(0, 4)
		padding.PaddingRight = UDim.new(0, 8)
		padding.Parent = scroll
		
		return scroll
	end
	
	local movementContent = createTabContent("Movement")
	local combatContent = createTabContent("Combat")
	local espContent = createTabContent("ESP")
	local extraContent = createTabContent("Extra")
	
	-- ============================================
	-- CREATE TABS
	-- ============================================
	local movementTab = Tabs.create(tabBar, "Movement", "⚡")
	local combatTab = Tabs.create(tabBar, "Combat", "🎯")
	local espTab = Tabs.create(tabBar, "ESP", "👁")
	local extraTab = Tabs.create(tabBar, "Extra", "⚙")
	
	Tabs.connectTab(movementTab, movementContent)
	Tabs.connectTab(combatTab, combatContent)
	Tabs.connectTab(espTab, espContent)
	Tabs.connectTab(extraTab, extraContent)
	
	-- ============================================
	-- MOVEMENT TAB
	-- ============================================
	Components.createSection(movementContent, "Flight")
	
	Components.createToggle(movementContent, "Fly", function(state)
		if Fly then
			if state then
				local root = getRoot()
				if root then Fly.enable(root, camera) end
			else
				Fly.disable()
			end
		end
	end)
	
	Components.createSlider(movementContent, "Fly Speed", 10, 200, 50, function(value)
		if Fly then Fly.speed = value end
	end)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Speed & Jump")
	
	Components.createToggle(movementContent, "Walk Speed", function(state)
		if WalkSpeed then
			WalkSpeed.enabled = state
			local humanoid = getHumanoid()
			if humanoid then
				humanoid.WalkSpeed = state and walkSpeedValue or 16
			end
		end
	end)
	
	Components.createSlider(movementContent, "Speed Value", 16, 200, 16, function(value)
		walkSpeedValue = value
		if WalkSpeed and WalkSpeed.enabled then
			local humanoid = getHumanoid()
			if humanoid then humanoid.WalkSpeed = value end
		end
	end)
	
	Components.createToggle(movementContent, "Jump Power", function(state)
		if JumpPower then
			JumpPower.enabled = state
			local humanoid = getHumanoid()
			if humanoid then
				humanoid.JumpPower = state and jumpPowerValue or 50
			end
		end
	end)
	
	Components.createSlider(movementContent, "Jump Value", 50, 300, 50, function(value)
		jumpPowerValue = value
		if JumpPower and JumpPower.enabled then
			local humanoid = getHumanoid()
			if humanoid then humanoid.JumpPower = value end
		end
	end)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Other")
	
	Components.createToggle(movementContent, "Noclip", function(state)
		if Noclip then Noclip.enabled = state end
	end)
	
	Components.createToggle(movementContent, "Bunny Hop", function(state)
		if BunnyHop then BunnyHop.enabled = state end
	end)
	
	Components.createToggle(movementContent, "Dash (Press F)", function(state)
		if Dash then Dash.enabled = state end
	end)
	
	Components.createSlider(movementContent, "Air Control", 0, 10, 0, function(value)
		if AirControl then AirControl.strength = value end
	end)
	
	-- ============================================
	-- COMBAT TAB - FIXED SMOOTHNESS
	-- ============================================
	Components.createSection(combatContent, "Aim Assist")
	
	Components.createToggle(combatContent, "Aim Assist", function(state)
		if AimAssist then AimAssist.enabled = state end
	end)
	
	-- FIXED: Smoothness slider - low value = smooth (slow), high value = snappy (fast)
	-- Slider 1-100 maps to 0.01-0.30 smoothness
	Components.createSlider(combatContent, "Smoothness", 1, 100, 15, function(value)
		if AimAssist then
			-- value 1 = 0.01 (very smooth/slow)
			-- value 100 = 0.30 (very snappy/fast)
			AimAssist.smoothness = value / 333
		end
	end)
	
	Components.createSlider(combatContent, "FOV", 50, 500, 150, function(value)
		if AimAssist then AimAssist.fov = value end
		if FOV then FOV.radius = value end
	end)
	
	Components.createToggle(combatContent, "Show FOV Circle", function(state)
		if FOV then FOV.enabled = state end
	end)
	
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Silent Aim")
	
	Components.createToggle(combatContent, "Silent Aim", function(state)
		if SilentAim then SilentAim.enabled = state end
	end)
	
	Components.createSlider(combatContent, "Hit Chance", 0, 100, 100, function(value)
		if SilentAim then SilentAim.hitChance = value end
	end)
	
	-- ============================================
	-- ESP TAB - NOW WORKING
	-- ============================================
	Components.createSection(espContent, "Player ESP")
	
	Components.createToggle(espContent, "Name ESP", function(state)
		ESPState.NameESP = state
	end)
	
	Components.createToggle(espContent, "Box ESP", function(state)
		ESPState.BoxESP = state
	end)
	
	Components.createToggle(espContent, "Health ESP", function(state)
		ESPState.HealthESP = state
	end)
	
	Components.createToggle(espContent, "Distance ESP", function(state)
		ESPState.DistanceESP = state
	end)
	
	Components.createToggle(espContent, "Tracers", function(state)
		ESPState.Tracers = state
	end)
	
	Components.createDivider(espContent)
	Components.createSection(espContent, "Visuals")
	
	Components.createToggle(espContent, "Chams", function(state)
		ESPState.Chams = state
		updateChams()
	end)
	
	-- ============================================
	-- EXTRA TAB
	-- ============================================
	Components.createSection(extraContent, "Visual Tweaks")
	
	Components.createToggle(extraContent, "Fullbright", function(state)
		if Fullbright then
			Fullbright.enabled = state
			Fullbright.toggle()
		end
	end)
	
	Components.createToggle(extraContent, "Remove Grass", function(state)
		if RemoveGrass then
			RemoveGrass.enabled = state
			RemoveGrass.apply()
		end
	end)
	
	Components.createToggle(extraContent, "Third Person", function(state)
		if ThirdPerson then
			ThirdPerson.enabled = state
			ThirdPerson.apply(player)
		end
	end)
	
	Components.createDivider(extraContent)
	Components.createSection(extraContent, "Misc")
	
	Components.createToggle(extraContent, "Anti AFK", function(state)
		if AntiAFK then AntiAFK.enabled = state end
	end)
	
	Components.createToggle(extraContent, "Invisibility", function(state)
		if Invisibility then
			Invisibility.enabled = state
			Invisibility.apply(getCharacter())
		end
	end)
	
	Components.createToggle(extraContent, "Walk on Water", function(state)
		if WalkOnWater then WalkOnWater.enabled = state end
	end)
	
	-- ============================================
	-- ACTIVATE FIRST TAB
	-- ============================================
	Tabs.activate(movementTab, movementContent)
	
-- ============================================
-- KEYBINDS (FIXED)
-- ============================================
UIS.InputBegan:Connect(function(input)
	-- 🔑 MENU TOGGLE MUST IGNORE gameProcessed
	if input.KeyCode == Enum.KeyCode.M then
		local isVisible = not main.Visible
		main.Visible = isVisible
		
		if isVisible then
			-- 🔓 UNLOCK MOUSE FOR MENU
			UIS.MouseBehavior = Enum.MouseBehavior.Default
			UIS.MouseIconEnabled = true
			
			main.Size = UDim2.new(0, 0, 0, 0)
			Animations.tween(
				main,
				{Size = UDim2.new(0, 820, 0, 540)},
				{Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out}
			)
		else
			-- 🔒 LOCK MOUSE BACK TO FIRST PERSON
			UIS.MouseBehavior = Enum.MouseBehavior.LockCenter
			UIS.MouseIconEnabled = false
		end
		
		return
	end
	
	-- OTHER KEYS CAN RESPECT gameProcessed
	if input.KeyCode == Enum.KeyCode.F then
		if Dash and Dash.enabled then
			local root = getRoot()
			if root then
				Dash.tryDash(root, camera)
			end
		end
	end
end)



	
	-- ============================================
	-- DRAGGING
	-- ============================================
	local dragging = false
	local dragInput, dragStart, startPos
	
	header.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	UIS.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
		if dragging and dragInput then
			local delta = dragInput.Position - dragStart
			Animations.tween(main, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, {Time = 0.1, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	-- ============================================
	-- CHARACTER RESPAWN
	-- ============================================
	player.CharacterAdded:Connect(function(char)
		task.wait(0.5)
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			if WalkSpeed and WalkSpeed.enabled then humanoid.WalkSpeed = walkSpeedValue end
			if JumpPower and JumpPower.enabled then humanoid.JumpPower = jumpPowerValue end
		end
		if Invisibility and Invisibility.enabled then Invisibility.apply(char) end
	end)
	
	print("[SimpleHub] Premium UI loaded successfully")
	print("[SimpleHub] Press M to toggle menu")
end
