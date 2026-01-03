-- ui/menu.lua
-- FIXED: Dark backgrounds, contained glow, no overflow

return function(deps)
	local Tabs = deps.Tabs
	local Components = deps.Components
	local Animations = deps.Animations
	local Controller = deps.Controller
	
	if not Tabs or not Components or not Animations or not Controller then
		error("[Menu] Missing dependencies")
	end
	
	print("[SimpleHub] Initializing premium UI...")
	
	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local player = Players.LocalPlayer
	
	local Colors = {
		Background = Color3.fromRGB(12, 12, 16),
		Panel = Color3.fromRGB(18, 18, 24),
		Surface = Color3.fromRGB(24, 24, 32),
		Accent = Color3.fromRGB(60, 120, 255),
		Text = Color3.fromRGB(220, 220, 240),
		Border = Color3.fromRGB(40, 40, 52)
	}
	
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHub"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.Parent = player:WaitForChild("PlayerGui")
	
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 820, 0, 540)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Colors.Background
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Visible = false
	main.Parent = gui
	
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = main
	
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Colors.Border
	mainStroke.Thickness = 1.5
	mainStroke.Transparency = 0.4
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Parent = main
	
	local mainGlow = Instance.new("ImageLabel")
	mainGlow.Name = "Glow"
	mainGlow.Size = UDim2.new(1, 30, 1, 30)
	mainGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	mainGlow.BackgroundTransparency = 1
	mainGlow.Image = "rbxassetid://5028857472"
	mainGlow.ImageColor3 = Colors.Accent
	mainGlow.ImageTransparency = 0.85
	mainGlow.ScaleType = Enum.ScaleType.Slice
	mainGlow.SliceCenter = Rect.new(24, 24, 276, 276)
	mainGlow.ZIndex = 0
	mainGlow.Parent = main
	
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.Panel
	header.BorderSizePixel = 0
	header.ZIndex = 1
	header.Parent = main
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header
	
	local headerMask = Instance.new("Frame")
	headerMask.Size = UDim2.new(1, 0, 0, 12)
	headerMask.Position = UDim2.new(0, 0, 1, -12)
	headerMask.BackgroundColor3 = Colors.Panel
	headerMask.BorderSizePixel = 0
	headerMask.Parent = header
	
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0, 300, 1, 0)
	title.Position = UDim2.new(0, 24, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "SIMPLE HUB"
	title.TextColor3 = Colors.Text
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = header
	
	local titleAccent = Instance.new("Frame")
	titleAccent.Size = UDim2.new(0, 60, 0, 3)
	titleAccent.Position = UDim2.new(0, 24, 1, -8)
	titleAccent.BackgroundColor3 = Colors.Accent
	titleAccent.BorderSizePixel = 0
	titleAccent.Parent = header
	
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = titleAccent
	
	local version = Instance.new("TextLabel")
	version.Size = UDim2.new(0, 100, 0, 20)
	version.Position = UDim2.new(1, -120, 0.5, 0)
	version.AnchorPoint = Vector2.new(0, 0.5)
	version.BackgroundTransparency = 1
	version.Text = "v1.0"
	version.TextColor3 = Color3.fromRGB(100, 100, 120)
	version.TextXAlignment = Enum.TextXAlignment.Right
	version.Font = Enum.Font.GothamMedium
	version.TextSize = 11
	version.Parent = header
	
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.Size = UDim2.new(0, 36, 0, 36)
	closeBtn.Position = UDim2.new(1, -48, 0.5, 0)
	closeBtn.AnchorPoint = Vector2.new(0, 0.5)
	closeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 58)
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Colors.Text
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 24
	closeBtn.AutoButtonColor = false
	closeBtn.Parent = header
	
	local closeBtnCorner = Instance.new("UICorner")
	closeBtnCorner.CornerRadius = UDim.new(0, 6)
	closeBtnCorner.Parent = closeBtn
	
	closeBtn.MouseButton1Click:Connect(function()
		main.Visible = false
	end)
	
	closeBtn.MouseEnter:Connect(function()
		Animations.tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
	end)
	
	closeBtn.MouseLeave:Connect(function()
		Animations.tween(closeBtn, {BackgroundColor3 = Color3.fromRGB(45, 45, 58)}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
	end)
	
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, 0, 0, 68)
	tabBar.Position = UDim2.new(0, 0, 0, 60)
	tabBar.BackgroundColor3 = Colors.Surface
	tabBar.BorderSizePixel = 0
	tabBar.ZIndex = 1
	tabBar.Parent = main
	
	Tabs.setupTabBar(tabBar)
	
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -32, 1, -160)
	contentContainer.Position = UDim2.new(0, 16, 0, 144)
	contentContainer.BackgroundColor3 = Colors.Background
	contentContainer.BorderSizePixel = 0
	contentContainer.ClipsDescendants = true
	contentContainer.ZIndex = 1
	contentContainer.Parent = main
	
	local function createTabContent(name)
		local scroll = Instance.new("ScrollingFrame")
		scroll.Name = name .. "Content"
		scroll.Size = UDim2.new(1, 0, 1, 0)
		scroll.BackgroundTransparency = 1
		scroll.BorderSizePixel = 0
		scroll.ScrollBarThickness = 4
		scroll.ScrollBarImageColor3 = Colors.Accent
		scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
		scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
		scroll.Visible = false
		scroll.Parent = contentContainer
		
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = scroll
		
		local padding = Instance.new("UIPadding")
		padding.PaddingTop = UDim.new(0, 8)
		padding.PaddingBottom = UDim.new(0, 8)
		padding.PaddingLeft = UDim.new(0, 8)
		padding.PaddingRight = UDim.new(0, 12)
		padding.Parent = scroll
		
		return scroll
	end
	
	local movementContent = createTabContent("Movement")
	local combatContent = createTabContent("Combat")
	local espContent = createTabContent("ESP")
	local extraContent = createTabContent("Extra")
	
	local movementTab = Tabs.create(tabBar, "Movement", "⚡")
	local combatTab = Tabs.create(tabBar, "Combat", "🎯")
	local espTab = Tabs.create(tabBar, "ESP", "👁")
	local extraTab = Tabs.create(tabBar, "Extra", "⚙")
	
	Tabs.connectTab(movementTab, movementContent)
	Tabs.connectTab(combatTab, combatContent)
	Tabs.connectTab(espTab, espContent)
	Tabs.connectTab(extraTab, extraContent)
	
	Components.createSection(movementContent, "Basic Movement")
	Components.createToggle(movementContent, "Fly", Controller.toggleFly)
	Components.createToggle(movementContent, "Noclip", Controller.toggleNoclip)
	Components.createSlider(movementContent, "Walk Speed", 16, 200, 16, Controller.setWalkSpeed)
	Components.createSlider(movementContent, "Jump Power", 50, 200, 50, Controller.setJumpPower)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Advanced")
	Components.createToggle(movementContent, "Bunny Hop", Controller.toggleBunnyHop)
	Components.createToggle(movementContent, "Dash (Press F)", Controller.toggleDash)
	Components.createSlider(movementContent, "Air Control", 0, 10, 0, Controller.setAirControl)
	
	Components.createSection(combatContent, "Aim Assist")
	Components.createToggle(combatContent, "Aim Assist (Hold RMB)", Controller.toggleAimAssist)
	Components.createSlider(combatContent, "Smoothness", 0, 100, 15, Controller.setAimSmoothness)
	Components.createSlider(combatContent, "FOV", 50, 500, 150, Controller.setFOV)
	Components.createToggle(combatContent, "Show FOV Circle", Controller.toggleFOVCircle)
	
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Silent Aim")
	Components.createToggle(combatContent, "Silent Aim", Controller.toggleSilentAim)
	Components.createSlider(combatContent, "Hit Chance", 0, 100, 100, Controller.setHitChance)
	
	Components.createSection(espContent, "Player ESP")
	Components.createToggle(espContent, "Name ESP", Controller.toggleNameESP)
	Components.createToggle(espContent, "Box ESP", Controller.toggleBoxESP)
	Components.createToggle(espContent, "Health ESP", Controller.toggleHealthESP)
	Components.createToggle(espContent, "Distance ESP", Controller.toggleDistanceESP)
	Components.createToggle(espContent, "Tracers", Controller.toggleTracers)
	
	Components.createDivider(espContent)
	Components.createSection(espContent, "Visuals")
	Components.createToggle(espContent, "Chams", Controller.toggleChams)
	
	Components.createSection(extraContent, "Visual Tweaks")
	Components.createToggle(extraContent, "Fullbright", Controller.toggleFullbright)
	Components.createToggle(extraContent, "Remove Grass", Controller.toggleRemoveGrass)
	Components.createToggle(extraContent, "Third Person", Controller.toggleThirdPerson)
	
	Components.createDivider(extraContent)
	Components.createSection(extraContent, "Misc")
	Components.createToggle(extraContent, "Anti AFK", Controller.toggleAntiAFK)
	Components.createToggle(extraContent, "Invisibility", Controller.toggleInvisibility)
	Components.createToggle(extraContent, "Walk on Water", Controller.toggleWalkOnWater)
	Components.createToggle(extraContent, "Spin Bot", Controller.toggleSpinBot)
	Components.createToggle(extraContent, "Fake Lag", Controller.toggleFakeLag)
	Components.createToggle(extraContent, "Fake Death", Controller.toggleFakeDeath)
	
	Tabs.activate(movementTab, movementContent)
	
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.M then
			main.Visible = not main.Visible
			
			if main.Visible then
				main.Size = UDim2.new(0, 0, 0, 0)
				Animations.tween(main, {
					Size = UDim2.new(0, 820, 0, 540)
				}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
			end
		end
	end)
	
	local dragging = false
	local dragInput, dragStart, startPos
	
	local function update(input)
		local delta = input.Position - dragStart
		Animations.tween(main, {
			Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		}, {Time = 0.1, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
	end
	
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
			update(dragInput)
		end
	end)
	
	print("[SimpleHub] Premium UI loaded successfully")
	print("[SimpleHub] Press M to toggle menu")
end
