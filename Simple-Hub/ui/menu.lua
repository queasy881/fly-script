-- ui/menu.lua
-- Premium main menu interface

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
	local player = Players.LocalPlayer
	
	-- Colors
	local Colors = {
		Background = Color3.fromRGB(12, 12, 16),
		Panel = Color3.fromRGB(18, 18, 24),
		Surface = Color3.fromRGB(24, 24, 32),
		Accent = Color3.fromRGB(60, 120, 255),
		Text = Color3.fromRGB(220, 220, 240),
		Border = Color3.fromRGB(40, 40, 52),
		ScreenBg = Color3.fromRGB(12, 14, 18) -- Dark background for full screen
	}
	
	-- Create ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHub"
	gui.ResetOnSpawn = false
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	gui.IgnoreGuiInset = true -- Cover entire screen including top bar
	gui.Parent = player:WaitForChild("PlayerGui")
	
	-- ============================================
	-- FULL SCREEN DARK BACKGROUND (NEW)
	-- ============================================
	local screenBg = Instance.new("Frame")
	screenBg.Name = "ScreenBackground"
	screenBg.Size = UDim2.new(1, 0, 1, 0)
	screenBg.Position = UDim2.new(0, 0, 0, 0)
	screenBg.BackgroundColor3 = Colors.ScreenBg
	screenBg.BackgroundTransparency = 0 -- Fully opaque, no see-through
	screenBg.BorderSizePixel = 0
	screenBg.ZIndex = 0
	screenBg.Visible = false
	screenBg.Parent = gui
	
	-- Main container
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 820, 0, 540)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Colors.Background
	main.BorderSizePixel = 0
	main.ZIndex = 1
	main.Visible = false
	main.Parent = gui
	
	-- Rounded corners
	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = main
	
	-- Border stroke
	local mainStroke = Instance.new("UIStroke")
	mainStroke.Color = Colors.Border
	mainStroke.Thickness = 1.5
	mainStroke.Transparency = 0.4
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Parent = main
	
	-- Glow effect
	local mainGlow = Instance.new("ImageLabel")
	mainGlow.Name = "Glow"
	mainGlow.Size = UDim2.new(1, 40, 1, 40)
	mainGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	mainGlow.BackgroundTransparency = 1
	mainGlow.Image = "rbxassetid://5028857472"
	mainGlow.ImageColor3 = Colors.Accent
	mainGlow.ImageTransparency = 0.7
	mainGlow.ScaleType = Enum.ScaleType.Slice
	mainGlow.SliceCenter = Rect.new(24, 24, 276, 276)
	mainGlow.ZIndex = 0
	mainGlow.Parent = main
	
	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundColor3 = Colors.Panel
	header.BorderSizePixel = 0
	header.Parent = main
	
	local headerCorner = Instance.new("UICorner")
	headerCorner.CornerRadius = UDim.new(0, 12)
	headerCorner.Parent = header
	
	-- Hide bottom corners of header
	local headerMask = Instance.new("Frame")
	headerMask.Size = UDim2.new(1, 0, 0, 12)
	headerMask.Position = UDim2.new(0, 0, 1, -12)
	headerMask.BackgroundColor3 = Colors.Panel
	headerMask.BorderSizePixel = 0
	headerMask.Parent = header
	
	-- Title
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
	
	-- Accent bar under title
	local titleAccent = Instance.new("Frame")
	titleAccent.Size = UDim2.new(0, 60, 0, 3)
	titleAccent.Position = UDim2.new(0, 24, 1, -8)
	titleAccent.BackgroundColor3 = Colors.Accent
	titleAccent.BorderSizePixel = 0
	titleAccent.Parent = header
	
	local accentCorner = Instance.new("UICorner")
	accentCorner.CornerRadius = UDim.new(1, 0)
	accentCorner.Parent = titleAccent
	
	-- Version label
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
	
	-- Close button
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
		screenBg.Visible = false
	end)
	
	closeBtn.MouseEnter:Connect(function()
		Animations.tween(closeBtn, {
			BackgroundColor3 = Color3.fromRGB(220, 50, 50)
		}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
	end)
	
	closeBtn.MouseLeave:Connect(function()
		Animations.tween(closeBtn, {
			BackgroundColor3 = Color3.fromRGB(45, 45, 58)
		}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
	end)
	
	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.Size = UDim2.new(1, 0, 0, 68)
	tabBar.Position = UDim2.new(0, 0, 0, 60)
	tabBar.BackgroundColor3 = Colors.Surface
	tabBar.BorderSizePixel = 0
	tabBar.Parent = main
	
	Tabs.setupTabBar(tabBar)
	
	-- Content container
	local contentContainer = Instance.new("Frame")
	contentContainer.Name = "ContentContainer"
	contentContainer.Size = UDim2.new(1, -32, 1, -160)
	contentContainer.Position = UDim2.new(0, 16, 0, 144)
	contentContainer.BackgroundTransparency = 1
	contentContainer.Parent = main
	
	-- Create tab content frames
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
	
	-- Create tabs
	local movementTab = Tabs.create(tabBar, "Movement", "⚡")
	local combatTab = Tabs.create(tabBar, "Combat", "🎯")
	local espTab = Tabs.create(tabBar, "ESP", "👁")
	local extraTab = Tabs.create(tabBar, "Extra", "⚙")
	
	-- Connect tabs to content
	Tabs.connectTab(movementTab, movementContent)
	Tabs.connectTab(combatTab, combatContent)
	Tabs.connectTab(espTab, espContent)
	Tabs.connectTab(extraTab, extraContent)
	
	-- Populate Movement tab (examples)
	Components.createSection(movementContent, "Basic Movement")
	Components.createToggle(movementContent, "Fly", function(state)
		print("Fly:", state)
	end)
	Components.createToggle(movementContent, "Noclip", function(state)
		print("Noclip:", state)
	end)
	Components.createSlider(movementContent, "Walk Speed", 16, 200, 16, function(value)
		print("WalkSpeed:", value)
	end)
	Components.createSlider(movementContent, "Jump Power", 50, 200, 50, function(value)
		print("JumpPower:", value)
	end)
	
	Components.createDivider(movementContent)
	Components.createSection(movementContent, "Advanced")
	Components.createToggle(movementContent, "Bunny Hop", function(state)
		print("BunnyHop:", state)
	end)
	Components.createToggle(movementContent, "Dash", function(state)
		print("Dash:", state)
	end)
	Components.createSlider(movementContent, "Air Control", 0, 10, 0, function(value)
		print("AirControl:", value)
	end)
	
	-- Populate Combat tab (examples)
	Components.createSection(combatContent, "Aim Assist")
	Components.createToggle(combatContent, "Aim Assist", function(state)
		print("AimAssist:", state)
	end)
	Components.createSlider(combatContent, "Smoothness", 0, 100, 50, function(value)
		print("Smoothness:", value)
	end)
	Components.createSlider(combatContent, "FOV", 50, 500, 100, function(value)
		print("FOV:", value)
	end)
	Components.createToggle(combatContent, "Show FOV Circle", function(state)
		print("ShowFOV:", state)
	end)
	
	Components.createDivider(combatContent)
	Components.createSection(combatContent, "Silent Aim")
	Components.createToggle(combatContent, "Silent Aim", function(state)
		print("SilentAim:", state)
	end)
	Components.createSlider(combatContent, "Hit Chance", 0, 100, 100, function(value)
		print("HitChance:", value)
	end)
	
	-- Populate ESP tab (examples)
	Components.createSection(espContent, "Player ESP")
	Components.createToggle(espContent, "Name ESP", function(state)
		print("NameESP:", state)
	end)
	Components.createToggle(espContent, "Box ESP", function(state)
		print("BoxESP:", state)
	end)
	Components.createToggle(espContent, "Health ESP", function(state)
		print("HealthESP:", state)
	end)
	Components.createToggle(espContent, "Distance ESP", function(state)
		print("DistanceESP:", state)
	end)
	Components.createToggle(espContent, "Tracers", function(state)
		print("Tracers:", state)
	end)
	
	Components.createDivider(espContent)
	Components.createSection(espContent, "Visuals")
	Components.createToggle(espContent, "Chams", function(state)
		print("Chams:", state)
	end)
	
	-- Populate Extra tab (examples)
	Components.createSection(extraContent, "Visual Tweaks")
	Components.createToggle(extraContent, "Fullbright", function(state)
		print("Fullbright:", state)
	end)
	Components.createToggle(extraContent, "Remove Grass", function(state)
		print("RemoveGrass:", state)
	end)
	Components.createToggle(extraContent, "Third Person", function(state)
		print("ThirdPerson:", state)
	end)
	
	Components.createDivider(extraContent)
	Components.createSection(extraContent, "Misc")
	Components.createToggle(extraContent, "Anti AFK", function(state)
		print("AntiAFK:", state)
	end)
	Components.createToggle(extraContent, "Invisibility", function(state)
		print("Invisibility:", state)
	end)
	Components.createToggle(extraContent, "Walk on Water", function(state)
		print("WalkOnWater:", state)
	end)
	
	-- Activate first tab
	Tabs.activate(movementTab, movementContent)
	
	-- Toggle keybind (M)
	UIS.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.M then
			local isVisible = not main.Visible
			main.Visible = isVisible
			screenBg.Visible = isVisible
			
			if isVisible then
				main.Size = UDim2.new(0, 0, 0, 0)
				Animations.tween(main, {
					Size = UDim2.new(0, 820, 0, 540)
				}, {Time = 0.4, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
			end
		end
	end)
	
	-- Dragging functionality
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
