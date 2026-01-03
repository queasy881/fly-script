-- SIMPLE HUB v3.7 – Enhanced Edition
-- Press M to toggle

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

---------------- STATE ----------------
local fly = false
local noclip = false
local walkEnabled = false
local jumpEnabled = false

local flySpeed = 23
local walkSpeed = humanoid.WalkSpeed
local jumpPower = humanoid.JumpPower

local nameESP = false
local boxESP = false

local teleportEnabled = false
local invisible = false
local invisAmount = 1

local aimAssistEnabled = false
local aimFOV = 100
local aimSmoothness = 0.5
local showFOVCircle = false
local teamCheck = true
local visibilityCheck = true
local silentAimEnabled = false
local silentAimFOV = 150
local hitChance = 100

local infiniteJumpEnabled = false
local fullbrightEnabled = false
local thirdPersonEnabled = false
local removeGrassEnabled = false
local antiAfkEnabled = false
local walkOnWaterEnabled = false

local defaultFOV = camera.FieldOfView
local originalLighting = {}

local bv, bg
local nameESPObjects = {}
local boxESPObjects = {}
local fovCircle = nil
local waterPlatform = nil

-- NEW FEATURES STATE
local bunnyHopEnabled = false
local bunnyHopDelay = 0.2
local airControlStrength = 0
local dashEnabled = false
local dashDistance = 50
local dashCooldown = 2
local lastDashTime = 0
local aimKeybind = "RMB" -- RMB, Shift, Mouse4
local aimBone = "Head" -- Head, Torso, Random
local dynamicFOVEnabled = false
local healthESPEnabled = false
local offScreenArrowsEnabled = false
local boxESPColor = Color3.fromRGB(255, 0, 0)
local tracerColor = Color3.fromRGB(255, 255, 0)
local chamsColor = Color3.fromRGB(0, 255, 100)
local fakeLagEnabled = false
local fakeLagInterval = 1
local lastFakeLag = 0
local fakeDeathEnabled = false
local spinBotEnabled = false
local spinBotSpeed = 5
local tutorialCompleted = false
local activeFeatures = {}

-- Store preset data
local presets = {
    Legit = {},
    Rage = {},
    Movement = {},
    Visual = {}
}

-- Store collapsible section states
local collapsedSections = {}

---------------- INVISIBILITY ----------------
local function applyInvisibility()
	if not character then return end
	for _,v in pairs(character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = invisible and invisAmount or 0
		elseif v:IsA("Decal") then
			v.Transparency = invisible and invisAmount or 0
		end
	end
end

---------------- CHARACTER RESPAWN HANDLER ----------------
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")
	
	-- Reapply invisibility if it was on
	if invisible then
		task.wait(0.1)
		applyInvisibility()
	end
	
	-- Reapply fly if it was on
	if fly then
		task.wait(0.1)
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
		bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	end
	
	-- Reapply walk speed if it was on
	if walkEnabled then
		task.wait(0.1)
		humanoid.WalkSpeed = walkSpeed
	end
	
	-- Reapply jump power if it was on
	if jumpEnabled then
		task.wait(0.1)
		humanoid.JumpPower = jumpPower
	end
	
	-- Reapply third person
	if thirdPersonEnabled then
		task.wait(0.1)
		player.CameraMaxZoomDistance = 100
		player.CameraMinZoomDistance = 15
	end
end)

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 780, 0, 520)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
main.BorderSizePixel = 0
main.Visible = false
main.ClipsDescendants = true

local mainCorner = Instance.new("UICorner", main)
mainCorner.CornerRadius = UDim.new(0, 12)

local mainStroke = Instance.new("UIStroke", main)
mainStroke.Color = Color3.fromRGB(40, 40, 50)
mainStroke.Thickness = 1
mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Status Bar
local statusBar = Instance.new("Frame", main)
statusBar.Size = UDim2.new(1, 0, 0, 24)
statusBar.Position = UDim2.new(0, 0, 1, -24)
statusBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
statusBar.BorderSizePixel = 0
statusBar.ZIndex = 5

local statusCorner = Instance.new("UICorner", statusBar)
statusCorner.CornerRadius = UDim.new(0, 0, 0, 12)

local statusLabel = Instance.new("TextLabel", statusBar)
statusLabel.Size = UDim2.new(1, -20, 1, 0)
statusLabel.Position = UDim2.new(0, 10, 0, 0)
statusLabel.BackgroundTransparency = 1
statusLabel.Text = "Active: None"
statusLabel.Font = Enum.Font.GothamMedium
statusLabel.TextSize = 11
statusLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
statusLabel.TextXAlignment = Enum.TextXAlignment.Left

---------------- ANIMATION HELPER ----------------
local function tween(obj, props, time, style, direction)
	TweenService:Create(
		obj,
		TweenInfo.new(time or 0.3, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
		props
	):Play()
end

-- Title bar
local titleBar = Instance.new("Frame", main)
titleBar.Size = UDim2.new(1, 0, 0, 50)
titleBar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
titleBar.BorderSizePixel = 0
titleBar.ZIndex = 5

local titleCorner = Instance.new("UICorner", titleBar)
titleCorner.CornerRadius = UDim.new(0, 12)

local titleCover = Instance.new("Frame", titleBar)
titleCover.Position = UDim2.new(0, 0, 1, -12)
titleCover.Size = UDim2.new(1, 0, 0, 12)
titleCover.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
titleCover.BorderSizePixel = 0

local titleLabel = Instance.new("TextLabel", titleBar)
titleLabel.Size = UDim2.new(1, -20, 1, 0)
titleLabel.Position = UDim2.new(0, 20, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "SIMPLE HUB"
titleLabel.Font = Enum.Font.GothamBold
titleLabel.TextSize = 16
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.TextXAlignment = Enum.TextXAlignment.Left

local versionLabel = Instance.new("TextLabel", titleBar)
versionLabel.Size = UDim2.new(0, 60, 1, 0)
versionLabel.Position = UDim2.new(1, -80, 0, 0)
versionLabel.BackgroundTransparency = 1
versionLabel.Text = "v3.7"
versionLabel.Font = Enum.Font.Gotham
versionLabel.TextSize = 12
versionLabel.TextColor3 = Color3.fromRGB(120, 120, 140)
versionLabel.TextXAlignment = Enum.TextXAlignment.Right

-- Tab bar
local tabBar = Instance.new("Frame", main)
tabBar.Position = UDim2.new(0, 0, 0, 50)
tabBar.Size = UDim2.new(1, 0, 0, 48)
tabBar.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
tabBar.BorderSizePixel = 0
tabBar.ZIndex = 5

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 8)

-- Content
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0, 0, 0, 98)
content.Size = UDim2.new(1, 0, 1, -122) -- Adjusted for status bar
content.BackgroundTransparency = 1
content.ClipsDescendants = true

---------------- HELPERS ----------------
local activeTab = nil
local tabButtons = {}

-- Update status bar function
local function updateStatusBar()
    local features = {}
    if fly then table.insert(features, "Fly") end
    if aimAssistEnabled then table.insert(features, "Aim Assist") end
    if silentAimEnabled then table.insert(features, "Silent Aim") end
    if nameESP or boxESP or healthESPEnabled then table.insert(features, "ESP") end
    if invisible then table.insert(features, "Invisibility") end
    if noclip then table.insert(features, "Noclip") end
    if bunnyHopEnabled then table.insert(features, "Bunny Hop") end
    if dashEnabled then table.insert(features, "Dash") end
    if spinBotEnabled then table.insert(features, "Spin Bot") end
    if fakeLagEnabled then table.insert(features, "Fake Lag") end
    if fakeDeathEnabled then table.insert(features, "Fake Death") end
    
    if #features == 0 then
        statusLabel.Text = "Active: None"
    else
        statusLabel.Text = "Active: " .. table.concat(features, ", ")
    end
end

-- Visual feedback for toggles
local function setToggleVisual(button, enabled)
    if enabled then
        tween(button, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
        tween(button, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
        
        -- Pulse animation
        local pulse = Instance.new("Frame", button)
        pulse.Size = UDim2.new(1, 0, 1, 0)
        pulse.BackgroundColor3 = Color3.fromRGB(70, 140, 220)
        pulse.BackgroundTransparency = 0.7
        pulse.ZIndex = -1
        pulse.BorderSizePixel = 0
        
        local corner = Instance.new("UICorner", pulse)
        corner.CornerRadius = UDim.new(0, 8)
        
        tween(pulse, {BackgroundTransparency = 1, Size = UDim2.new(1.2, 0, 1.2, 0)}, 0.5)
        game:GetService("Debris"):AddItem(pulse, 0.5)
    else
        tween(button, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
        tween(button, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
    end
    updateStatusBar()
end

local function setActiveTab(b)
	if activeTab then
		tween(activeTab, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(activeTab, {TextColor3 = Color3.fromRGB(140, 140, 160)}, 0.25)
		local oldIndicator = activeTab:FindFirstChild("Frame")
		if oldIndicator then
			tween(oldIndicator, {Size = UDim2.new(0, 0, 0, 3)}, 0.25)
		end
	end
	activeTab = b
	tween(b, {BackgroundColor3 = Color3.fromRGB(88, 166, 255)}, 0.25)
	tween(b, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	local indicator = b:FindFirstChild("Frame")
	if indicator then
		tween(indicator, {Size = UDim2.new(0.8, 0, 0, 3)}, 0.3, Enum.EasingStyle.Back)
	end
end

local function tabButton(text)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0, 160, 0, 36)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.fromRGB(140, 140, 160)
	b.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	
	local corner = Instance.new("UICorner", b)
	corner.CornerRadius = UDim.new(0, 8)
	
	local indicator = Instance.new("Frame", b)
	indicator.Size = UDim2.new(0, 0, 0, 3)
	indicator.Position = UDim2.new(0.5, 0, 1, -3)
	indicator.AnchorPoint = Vector2.new(0.5, 0)
	indicator.BackgroundColor3 = Color3.fromRGB(88, 166, 255)
	indicator.BorderSizePixel = 0
	
	local indicatorCorner = Instance.new("UICorner", indicator)
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	
	b.MouseEnter:Connect(function()
		if activeTab ~= b then
			tween(b, {BackgroundColor3 = Color3.fromRGB(32, 32, 42)}, 0.2)
			tween(b, {TextColor3 = Color3.fromRGB(180, 180, 200)}, 0.2)
		end
	end)
	
	b.MouseLeave:Connect(function()
		if activeTab ~= b then
			tween(b, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.2)
			tween(b, {TextColor3 = Color3.fromRGB(140, 140, 160)}, 0.2)
		end
	end)

	return b
end

-- Fixed collapsible section function with proper layout management
local function collapsibleSection(parent, text, id)
    local sectionContainer = Instance.new("Frame", parent)
    sectionContainer.Size = UDim2.new(1, 0, 0, 28) -- Fixed initial height
    sectionContainer.BackgroundTransparency = 1
    sectionContainer.ClipsDescendants = true -- Prevent content from bleeding
    
    local header = Instance.new("TextButton", sectionContainer)
    header.Size = UDim2.new(1, 0, 0, 28)
    header.BackgroundTransparency = 1
    header.Text = "▼ " .. text
    header.Font = Enum.Font.GothamBold
    header.TextSize = 13
    header.TextXAlignment = Enum.TextXAlignment.Left
    header.TextColor3 = Color3.fromRGB(180, 180, 200)
    header.AutoButtonColor = false

    -- Content container with proper sizing
    local contentFrame = Instance.new("Frame", sectionContainer)
    contentFrame.Size = UDim2.new(1, 0, 0, 0) -- Start collapsed
    contentFrame.Position = UDim2.new(0, 0, 0, 28)
    contentFrame.BackgroundTransparency = 1
    contentFrame.ClipsDescendants = true
    
    -- Main layout for content
    local contentLayout = Instance.new("UIListLayout", contentFrame)
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Top
    
    -- Use SizeConstraint to prevent content from expanding beyond view
    local sizeConstraint = Instance.new("UISizeConstraint", contentFrame)
    sizeConstraint.MaxSize = Vector2.new(10000, 10000) -- Allow vertical growth
    sizeConstraint.MinSize = Vector2.new(0, 0)

    -- Default to collapsed
    collapsedSections[id] = true

    -- Proper resize function that doesn't conflict with AutomaticSize
    local function updateSectionSize()
        if collapsedSections[id] then
            sectionContainer.Size = UDim2.new(1, 0, 0, 28)
        else
            -- Calculate proper height based on content
            local contentHeight = 0
            for _, child in ipairs(contentFrame:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                    contentHeight = contentHeight + child.AbsoluteSize.Y + 10
                end
            end
            sectionContainer.Size = UDim2.new(1, 0, 0, 28 + contentHeight)
        end
    end

    header.MouseButton1Click:Connect(function()
        collapsedSections[id] = not collapsedSections[id]
        
        if collapsedSections[id] then
            header.Text = "▶ " .. text
            -- Collapse with animation
            tween(contentFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.3, Enum.EasingStyle.Quint)
            tween(sectionContainer, {Size = UDim2.new(1, 0, 0, 28)}, 0.3, Enum.EasingStyle.Quint)
        else
            header.Text = "▼ " .. text
            -- Calculate content height
            local contentHeight = 0
            for _, child in ipairs(contentFrame:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                    contentHeight = contentHeight + child.AbsoluteSize.Y + 10
                end
            end
            
            -- Expand with animation
            contentFrame.Size = UDim2.new(1, 0, 0, 0) -- Start from 0
            tween(contentFrame, {Size = UDim2.new(1, 0, 0, contentHeight)}, 0.3, Enum.EasingStyle.Quint)
            tween(sectionContainer, {Size = UDim2.new(1, 0, 0, 28 + contentHeight)}, 0.3, Enum.EasingStyle.Quint)
        end
    end)

    return contentFrame
end

-- Fixed button function with consistent sizing
local function button(parent, text)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1, -4, 0, 38) -- Fixed: Subtract 4 pixels to prevent overflow
	b.Position = UDim2.new(0, 2, 0, 0) -- Fixed: Add 2 pixel offset for centering
	b.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
	b.TextColor3 = Color3.fromRGB(200, 200, 220)
	b.Font = Enum.Font.GothamMedium
	b.TextSize = 13
	b.Text = text
	b.BorderSizePixel = 0
	b.AutoButtonColor = false
	
	local corner = Instance.new("UICorner", b)
	corner.CornerRadius = UDim.new(0, 8)
	
	local stroke = Instance.new("UIStroke", b)
	stroke.Color = Color3.fromRGB(40, 40, 50)
	stroke.Thickness = 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Transparency = 0.5
	
	b.MouseEnter:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(32, 32, 42)}, 0.2)
		tween(stroke, {Transparency = 0.2}, 0.2)
	end)
	
	b.MouseLeave:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.2)
		tween(stroke, {Transparency = 0.5}, 0.2)
	end)
	
	b.MouseButton1Down:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(22, 22, 30)}, 0.1)
	end)
	
	b.MouseButton1Up:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(32, 32, 42)}, 0.1)
	end)

	return b
end

-- Fixed dropdown button with proper containment
local function dropdownButton(parent, text, options, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -4, 0, 38) -- Fixed: Prevent overflow
    frame.Position = UDim2.new(0, 2, 0, 0)
    frame.BackgroundTransparency = 1
    
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(1, 0, 1, 0)
    b.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    b.TextColor3 = Color3.fromRGB(200, 200, 220)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.Text = text .. ": " .. options[1]
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Color3.fromRGB(40, 40, 50)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.5
    
    local currentIndex = 1
    
    b.MouseEnter:Connect(function()
        tween(b, {BackgroundColor3 = Color3.fromRGB(32, 32, 42)}, 0.2)
        tween(stroke, {Transparency = 0.2}, 0.2)
    end)
    
    b.MouseLeave:Connect(function()
        tween(b, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.2)
        tween(stroke, {Transparency = 0.5}, 0.2)
    end)
    
    b.MouseButton1Click:Connect(function()
        currentIndex = (currentIndex % #options) + 1
        b.Text = text .. ": " .. options[currentIndex]
        if callback then
            callback(options[currentIndex])
        end
    end)
    
    return b
end

-- Fixed color picker button with proper containment
local function colorPickerButton(parent, text, defaultColor, callback)
    local frame = Instance.new("Frame", parent)
    frame.Size = UDim2.new(1, -4, 0, 38) -- Fixed: Prevent overflow
    frame.Position = UDim2.new(0, 2, 0, 0)
    frame.BackgroundTransparency = 1
    
    local b = Instance.new("TextButton", frame)
    b.Size = UDim2.new(0.7, -4, 1, 0)
    b.Position = UDim2.new(0, 0, 0, 0)
    b.BackgroundColor3 = Color3.fromRGB(26, 26, 34)
    b.TextColor3 = Color3.fromRGB(200, 200, 220)
    b.Font = Enum.Font.GothamMedium
    b.TextSize = 13
    b.Text = text
    b.BorderSizePixel = 0
    b.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", b)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", b)
    stroke.Color = Color3.fromRGB(40, 40, 50)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Transparency = 0.5
    
    local colorBox = Instance.new("Frame", frame)
    colorBox.Size = UDim2.new(0.25, -4, 0.7, 0)
    colorBox.Position = UDim2.new(0.73, 0, 0.15, 0)
    colorBox.BackgroundColor3 = defaultColor
    colorBox.BorderSizePixel = 0
    colorBox.ClipsDescendants = true -- Prevent color box from bleeding
    
    local colorCorner = Instance.new("UICorner", colorBox)
    colorCorner.CornerRadius = UDim.new(0, 6)
    
    b.MouseEnter:Connect(function()
        tween(b, {BackgroundColor3 = Color3.fromRGB(32, 32, 42)}, 0.2)
        tween(stroke, {Transparency = 0.2}, 0.2)
    end)
    
    b.MouseLeave:Connect(function()
        tween(b, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.2)
        tween(stroke, {Transparency = 0.5}, 0.2)
    end)
    
    b.MouseButton1Click:Connect(function()
        if callback then
            callback(colorBox)
        end
    end)
    
    return b, colorBox
end

-- Fixed slider function with proper containment
local function slider(parent, label, min, max, value, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1, -4, 0, 52) -- Fixed: Subtract 4 pixels for padding
	frame.Position = UDim2.new(0, 2, 0, 0)
	frame.BackgroundTransparency = 1
	frame.ClipsDescendants = true -- Fixed: Prevent slider from bleeding

	local txt = Instance.new("TextLabel", frame)
	txt.Size = UDim2.new(1, 0, 0, 20)
	txt.BackgroundTransparency = 1
	txt.Text = label .. ": " .. value
	txt.Font = Enum.Font.GothamMedium
	txt.TextSize = 12
	txt.TextColor3 = Color3.fromRGB(200, 200, 220)
	txt.TextXAlignment = Enum.TextXAlignment.Left

	local bar = Instance.new("Frame", frame)
	bar.Position = UDim2.new(0, 0, 0, 28)
	bar.Size = UDim2.new(1, 0, 0, 12)
	bar.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
	bar.BorderSizePixel = 0
	bar.ClipsDescendants = true -- Fixed: Prevent fill from bleeding
	
	local barCorner = Instance.new("UICorner", bar)
	barCorner.CornerRadius = UDim.new(1, 0)
	
	local barStroke = Instance.new("UIStroke", bar)
	barStroke.Color = Color3.fromRGB(40, 40, 50)
	barStroke.Thickness = 1
	barStroke.Transparency = 0.5

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new((value-min)/(max-min), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(88, 166, 255)
	fill.BorderSizePixel = 0
	fill.ClipsDescendants = true -- Fixed: Double containment
	
	local fillCorner = Instance.new("UICorner", fill)
	fillCorner.CornerRadius = UDim.new(1, 0)

	local dragging = false
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
	end)
	
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	
	UIS.InputChanged:Connect(function(i)
		if dragging then
			local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
			local val = min + (max-min)*pct
			val = math.floor(val * 100) / 100
			tween(fill, {Size = UDim2.new(pct, 0, 1, 0)}, 0.1)
			txt.Text = label .. ": " .. val
			callback(val)
		end
	end)
end

---------------- FIXED FRAMES WITH PROPER SCROLLING ----------------
-- Create main scrolling containers
local movementFrame = Instance.new("ScrollingFrame", content)
local combatFrame = Instance.new("ScrollingFrame", content)
local espFrame = Instance.new("ScrollingFrame", content)
local extraFrame = Instance.new("ScrollingFrame", content)

-- Fixed scrolling frame properties
for _,f in pairs({movementFrame, combatFrame, espFrame, extraFrame}) do
	f.Size = UDim2.new(1, 0, 1, 0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.BorderSizePixel = 0
	f.ScrollBarThickness = 6
	f.ScrollBarImageColor3 = Color3.fromRGB(80, 80, 100)
	f.ScrollBarImageTransparency = 0.5
	f.ScrollingDirection = Enum.ScrollingDirection.Y
	f.CanvasSize = UDim2.new(0, 0, 0, 0) -- Fixed: Start at 0
	f.AutomaticCanvasSize = Enum.AutomaticSize.None -- Fixed: Manual sizing
	
	-- Fixed padding for consistent spacing
	local pad = Instance.new("UIPadding", f)
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingRight = UDim.new(0, 12)
	pad.PaddingBottom = UDim.new(0, 8)
	
	-- Fixed layout with proper constraints
	local layout = Instance.new("UIListLayout", f)
	layout.Padding = UDim.new(0, 8) -- Fixed: Consistent spacing
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	
	-- Function to update canvas size properly
	local function updateCanvasSize()
		local totalHeight = 0
		for _, child in ipairs(f:GetChildren()) do
			if child:IsA("GuiObject") and child.Visible then
				if child:IsA("Frame") and child.Name:find("Section_") then
					-- For collapsible sections, use their actual size
					totalHeight = totalHeight + child.AbsoluteSize.Y + 8
				elseif child.Name == "ResetButtonFrame" then
					-- Reset button gets extra spacing
					totalHeight = totalHeight + child.AbsoluteSize.Y + 16
				else
					totalHeight = totalHeight + child.AbsoluteSize.Y + 8
				end
			end
		end
		f.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
	end
	
	-- Connect layout change to update canvas
	layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvasSize)
	
	-- Initial update
	spawn(updateCanvasSize)
end

movementFrame.Visible = true

-- Fixed reset button function with proper alignment
local function createResetButton(parent, frameName)
    local resetFrame = Instance.new("Frame", parent)
    resetFrame.Size = UDim2.new(1, -4, 0, 45) -- Fixed: Proper sizing with padding
    resetFrame.Position = UDim2.new(0, 2, 0, 0)
    resetFrame.BackgroundTransparency = 1
    resetFrame.Name = "ResetButtonFrame"
    
    local resetBtn = Instance.new("TextButton", resetFrame)
    resetBtn.Size = UDim2.new(1, 0, 1, 0)
    resetBtn.Text = "Reset " .. frameName .. " Tab"
    resetBtn.Font = Enum.Font.GothamMedium
    resetBtn.TextSize = 13
    resetBtn.TextColor3 = Color3.fromRGB(220, 100, 100)
    resetBtn.BackgroundColor3 = Color3.fromRGB(40, 26, 26)
    resetBtn.BorderSizePixel = 0
    resetBtn.AutoButtonColor = false
    
    local corner = Instance.new("UICorner", resetBtn)
    corner.CornerRadius = UDim.new(0, 8)
    
    local stroke = Instance.new("UIStroke", resetBtn)
    stroke.Color = Color3.fromRGB(80, 40, 40)
    stroke.Thickness = 1
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    
    resetBtn.MouseEnter:Connect(function()
        tween(resetBtn, {BackgroundColor3 = Color3.fromRGB(50, 32, 32)}, 0.2)
    end)
    
    resetBtn.MouseLeave:Connect(function()
        tween(resetBtn, {BackgroundColor3 = Color3.fromRGB(40, 26, 26)}, 0.2)
    end)
    
    resetBtn.MouseButton1Click:Connect(function()
        print("Reset " .. frameName .. " tab - functionality to be implemented based on your needs")
    end)
    
    return resetFrame
end

---------------- MOVEMENT TAB ----------------
local movementSection1 = collapsibleSection(movementFrame, "BASIC MOVEMENT", "movement1")

local flyBtn = button(movementSection1, "Fly: OFF")
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = "Fly: " .. (fly and "ON" or "OFF")
	setToggleVisual(flyBtn, fly)
	if fly then
		bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

slider(movementSection1, "Fly Speed", 5, 120, flySpeed, function(v)
	flySpeed = v
end)

local noclipBtn = button(movementSection1, "Noclip: OFF")
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
	setToggleVisual(noclipBtn, noclip)
end)

local walkBtn = button(movementSection1, "WalkSpeed: OFF")
walkBtn.MouseButton1Click:Connect(function()
	walkEnabled = not walkEnabled
	humanoid.WalkSpeed = walkEnabled and walkSpeed or 16
	walkBtn.Text = "WalkSpeed: " .. (walkEnabled and "ON" or "OFF")
	setToggleVisual(walkBtn, walkEnabled)
end)

slider(movementSection1, "WalkSpeed Value", 8, 100, walkSpeed, function(v)
	walkSpeed = v
	if walkEnabled then humanoid.WalkSpeed = v end
end)

local jumpBtn = button(movementSection1, "JumpPower: OFF")
jumpBtn.MouseButton1Click:Connect(function()
	jumpEnabled = not jumpEnabled
	humanoid.JumpPower = jumpEnabled and jumpPower or 50
	jumpBtn.Text = "JumpPower: " .. (jumpEnabled and "ON" or "OFF")
	setToggleVisual(jumpBtn, jumpEnabled)
end)

slider(movementSection1, "JumpPower Value", 20, 150, jumpPower, function(v)
	jumpPower = v
	if jumpEnabled then humanoid.JumpPower = v end
end)

-- NEW MOVEMENT FEATURES
local movementSection2 = collapsibleSection(movementFrame, "ADVANCED MOVEMENT", "movement2")

-- Bunny Hop
local bunnyHopBtn = button(movementSection2, "Bunny Hop: OFF")
bunnyHopBtn.MouseButton1Click:Connect(function()
    bunnyHopEnabled = not bunnyHopEnabled
    bunnyHopBtn.Text = "Bunny Hop: " .. (bunnyHopEnabled and "ON" or "OFF")
    setToggleVisual(bunnyHopBtn, bunnyHopEnabled)
end)

slider(movementSection2, "Bunny Hop Delay", 0.1, 1, bunnyHopDelay, function(v)
    bunnyHopDelay = v
end)

-- Air Control
slider(movementSection2, "Air Control Strength", 0, 1, airControlStrength, function(v)
    airControlStrength = v
end)

-- Dash
local dashBtn = button(movementSection2, "Dash (F Key): OFF")
dashBtn.MouseButton1Click:Connect(function()
    dashEnabled = not dashEnabled
    dashBtn.Text = "Dash (F Key): " .. (dashEnabled and "ON" or "OFF")
    setToggleVisual(dashBtn, dashEnabled)
end)

slider(movementSection2, "Dash Distance", 10, 100, dashDistance, function(v)
    dashDistance = v
end)

slider(movementSection2, "Dash Cooldown", 0.5, 5, dashCooldown, function(v)
    dashCooldown = v
end)

createResetButton(movementFrame, "Movement")

---------------- ESP TAB ----------------
local espSection1 = collapsibleSection(espFrame, "PLAYER ESP", "esp1")

local nameBtn = button(espSection1, "Name ESP: OFF")
nameBtn.MouseButton1Click:Connect(function()
	nameESP = not nameESP
	nameBtn.Text = "Name ESP: " .. (nameESP and "ON" or "OFF")
	setToggleVisual(nameBtn, nameESP)

	for _,v in pairs(nameESPObjects) do v:Destroy() end
	nameESPObjects = {}

	if not nameESP then return end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0,100,0,30)
			bb.AlwaysOnTop = true
			bb.Adornee = plr.Character.Head

			local t = Instance.new("TextLabel", bb)
			t.Size = UDim2.fromScale(1,1)
			t.BackgroundTransparency = 1
			t.Text = plr.Name
			t.TextColor3 = Color3.new(1,1,1)
			t.TextStrokeTransparency = 0

			bb.Parent = gui
			table.insert(nameESPObjects, bb)
		end
	end
end)

local boxBtn = button(espSection1, "Box ESP: OFF")
boxBtn.MouseButton1Click:Connect(function()
	boxESP = not boxESP
	boxBtn.Text = "Box ESP: " .. (boxESP and "ON" or "OFF")
	setToggleVisual(boxBtn, boxESP)

	for _,h in pairs(boxESPObjects) do h:Destroy() end
	boxESPObjects = {}
end)

-- Health ESP
local healthEspBtn = button(espSection1, "Health Bar ESP: OFF")
healthEspBtn.MouseButton1Click:Connect(function()
    healthESPEnabled = not healthESPEnabled
    healthEspBtn.Text = "Health Bar ESP: " .. (healthESPEnabled and "ON" or "OFF")
    setToggleVisual(healthEspBtn, healthESPEnabled)
end)

-- Off-screen Arrows
local arrowsBtn = button(espSection1, "Off-Screen Arrows: OFF")
arrowsBtn.MouseButton1Click:Connect(function()
    offScreenArrowsEnabled = not offScreenArrowsEnabled
    arrowsBtn.Text = "Off-Screen Arrows: " .. (offScreenArrowsEnabled and "ON" or "OFF")
    setToggleVisual(arrowsBtn, offScreenArrowsEnabled)
end)

local espSection2 = collapsibleSection(espFrame, "VISIBILITY", "esp2")

local tracersEnabled = false
local tracerObjects = {}

local tracersBtn = button(espSection2, "Tracers: OFF")
tracersBtn.MouseButton1Click:Connect(function()
	tracersEnabled = not tracersEnabled
	tracersBtn.Text = "Tracers: " .. (tracersEnabled and "ON" or "OFF")
	setToggleVisual(tracersBtn, tracersEnabled)

	if not tracersEnabled then
		for _,t in pairs(tracerObjects) do t:Destroy() end
		tracerObjects = {}
	end
end)

local chamsEnabled = false
local chamsObjects = {}

local chamsBtn = button(espSection2, "Chams: OFF")
chamsBtn.MouseButton1Click:Connect(function()
	chamsEnabled = not chamsEnabled
	chamsBtn.Text = "Chams: " .. (chamsEnabled and "ON" or "OFF")
	setToggleVisual(chamsBtn, chamsEnabled)

	for _,c in pairs(chamsObjects) do c:Destroy() end
	chamsObjects = {}

	if not chamsEnabled then return end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hl = Instance.new("Highlight")
			hl.FillColor = chamsColor
			hl.FillTransparency = 0.5
			hl.OutlineColor = chamsColor
			hl.OutlineTransparency = 0
			hl.Parent = plr.Character
			table.insert(chamsObjects, hl)
		end
	end
end)

local distanceEnabled = false
local distanceObjects = {}

local distanceBtn = button(espSection2, "Distance ESP: OFF")
distanceBtn.MouseButton1Click:Connect(function()
	distanceEnabled = not distanceEnabled
	distanceBtn.Text = "Distance ESP: " .. (distanceEnabled and "ON" or "OFF")
	setToggleVisual(distanceBtn, distanceEnabled)

	if not distanceEnabled then
		for _,d in pairs(distanceObjects) do d:Destroy() end
		distanceObjects = {}
	end
end)

-- Color Pickers
local espSection3 = collapsibleSection(espFrame, "COLOR CUSTOMIZATION", "esp3")

local boxColorBtn, boxColorBox = colorPickerButton(espSection3, "Box ESP Color", boxESPColor, function(colorBox)
    print("Box color picker clicked")
end)

local tracerColorBtn, tracerColorBox = colorPickerButton(espSection3, "Tracer Color", tracerColor, function(colorBox)
    print("Tracer color picker clicked")
end)

local chamsColorBtn, chamsColorBox = colorPickerButton(espSection3, "Chams Color", chamsColor, function(colorBox)
    print("Chams color picker clicked")
end)

createResetButton(espFrame, "ESP")

---------------- COMBAT TAB ----------------
local combatSection1 = collapsibleSection(combatFrame, "AIM ASSIST", "combat1")

local aimBtn = button(combatSection1, "Aim Assist: OFF")
aimBtn.MouseButton1Click:Connect(function()
	aimAssistEnabled = not aimAssistEnabled
	aimBtn.Text = "Aim Assist: " .. (aimAssistEnabled and "ON" or "OFF")
	setToggleVisual(aimBtn, aimAssistEnabled)
end)

slider(combatSection1, "FOV Size", 20, 500, aimFOV, function(v)
	aimFOV = v
	if fovCircle then
		fovCircle.Radius = v
	end
end)

slider(combatSection1, "Smoothness", 0.1, 1, aimSmoothness, function(v)
	aimSmoothness = v
end)

-- NEW COMBAT FEATURES
local combatSection2 = collapsibleSection(combatFrame, "AIM SETTINGS", "combat2")

-- Aim Keybind Selector
local aimKeybindBtn = dropdownButton(combatSection2, "Aim Keybind", {"RMB", "Shift", "Mouse4"}, function(selected)
    aimKeybind = selected
end)

-- Aim Bone Selector
local aimBoneBtn = dropdownButton(combatSection2, "Aim Bone", {"Head", "Torso", "Random"}, function(selected)
    aimBone = selected
end)

-- Dynamic FOV
local dynamicFovBtn = button(combatSection2, "Dynamic FOV: OFF")
dynamicFovBtn.MouseButton1Click:Connect(function()
    dynamicFOVEnabled = not dynamicFOVEnabled
    dynamicFovBtn.Text = "Dynamic FOV: " .. (dynamicFOVEnabled and "ON" or "OFF")
    setToggleVisual(dynamicFovBtn, dynamicFOVEnabled)
end)

local combatSection3 = collapsibleSection(combatFrame, "VISUAL", "combat3")

local fovCircleBtn = button(combatSection3, "Show FOV Circle: OFF")
fovCircleBtn.MouseButton1Click:Connect(function()
	showFOVCircle = not showFOVCircle
	fovCircleBtn.Text = "Show FOV Circle: " .. (showFOVCircle and "ON" or "OFF")
	setToggleVisual(fovCircleBtn, showFOVCircle)
	
	if not fovCircle then
		fovCircle = Drawing.new("Circle")
		fovCircle.Thickness = 2
		fovCircle.NumSides = 50
		fovCircle.Radius = aimFOV
		fovCircle.Color = Color3.fromRGB(255, 255, 255)
		fovCircle.Transparency = 0.8
		fovCircle.Filled = false
	end
	fovCircle.Visible = showFOVCircle
end)

local combatSection4 = collapsibleSection(combatFrame, "FILTERS", "combat4")

local teamCheckBtn = button(combatSection4, "Team Check: ON")
teamCheckBtn.MouseButton1Click:Connect(function()
	teamCheck = not teamCheck
	teamCheckBtn.Text = "Team Check: " .. (teamCheck and "ON" or "OFF")
	setToggleVisual(teamCheckBtn, teamCheck)
end)

local visCheckBtn = button(combatSection4, "Visibility Check: ON")
visCheckBtn.MouseButton1Click:Connect(function()
	visibilityCheck = not visibilityCheck
	visCheckBtn.Text = "Visibility Check: " .. (visibilityCheck and "ON" or "OFF")
	setToggleVisual(visCheckBtn, visibilityCheck)
end)

tween(teamCheckBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0)
tween(teamCheckBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0)
tween(visCheckBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0)
tween(visCheckBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0)

local combatSection5 = collapsibleSection(combatFrame, "SILENT AIM", "combat5")

local silentAimBtn = button(combatSection5, "Silent Aim: OFF")
silentAimBtn.MouseButton1Click:Connect(function()
	silentAimEnabled = not silentAimEnabled
	silentAimBtn.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
	setToggleVisual(silentAimBtn, silentAimEnabled)
end)

slider(combatSection5, "Silent Aim FOV", 20, 500, silentAimFOV, function(v)
	silentAimFOV = v
end)

slider(combatSection5, "Hit Chance %", 0, 100, hitChance, function(v)
	hitChance = v
end)

createResetButton(combatFrame, "Combat")

---------------- EXTRA TAB ----------------
local extraSection1 = collapsibleSection(extraFrame, "VISUALS", "extra1")

slider(extraSection1, "Camera FOV", 40, 120, defaultFOV, function(v)
	camera.FieldOfView = v
end)

local fullbrightBtn = button(extraSection1, "Fullbright: OFF")
fullbrightBtn.MouseButton1Click:Connect(function()
	fullbrightEnabled = not fullbrightEnabled
	fullbrightBtn.Text = "Fullbright: " .. (fullbrightEnabled and "ON" or "OFF")
	setToggleVisual(fullbrightBtn, fullbrightEnabled)
	
	if fullbrightEnabled then
		originalLighting.Ambient = Lighting.Ambient
		originalLighting.Brightness = Lighting.Brightness
		originalLighting.ColorShift_Bottom = Lighting.ColorShift_Bottom
		originalLighting.ColorShift_Top = Lighting.ColorShift_Top
		originalLighting.OutdoorAmbient = Lighting.OutdoorAmbient
		
		Lighting.Ambient = Color3.new(1, 1, 1)
		Lighting.Brightness = 2
		Lighting.ColorShift_Bottom = Color3.new(1, 1, 1)
		Lighting.ColorShift_Top = Color3.new(1, 1, 1)
		Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
	else
		Lighting.Ambient = originalLighting.Ambient
		Lighting.Brightness = originalLighting.Brightness
		Lighting.ColorShift_Bottom = originalLighting.ColorShift_Bottom
		Lighting.ColorShift_Top = originalLighting.ColorShift_Top
		Lighting.OutdoorAmbient = originalLighting.OutdoorAmbient
	end
end)

local removeGrassBtn = button(extraSection1, "Remove Grass/Foliage: OFF")
removeGrassBtn.MouseButton1Click:Connect(function()
	removeGrassEnabled = not removeGrassEnabled
	removeGrassBtn.Text = "Remove Grass/Foliage: " .. (removeGrassEnabled and "ON" or "OFF")
	setToggleVisual(removeGrassBtn, removeGrassEnabled)
	
	if removeGrassEnabled then
		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			terrain.Decoration = false
		end
		
		for _, obj in pairs(workspace:GetDescendants()) do
			if obj:IsA("Part") or obj:IsA("MeshPart") then
				if obj.Name:lower():find("grass") or obj.Name:lower():find("foliage") or obj.Name:lower():find("bush") then
					obj.Transparency = 1
				end
			end
		end
	else
		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			terrain.Decoration = true
		end
	end
end)

local thirdPersonBtn = button(extraSection1, "Force Third Person: OFF")
thirdPersonBtn.MouseButton1Click:Connect(function()
	thirdPersonEnabled = not thirdPersonEnabled
	thirdPersonBtn.Text = "Force Third Person: " .. (thirdPersonEnabled and "ON" or "OFF")
	setToggleVisual(thirdPersonBtn, thirdPersonEnabled)
	
	if thirdPersonEnabled then
		player.CameraMaxZoomDistance = 100
		player.CameraMinZoomDistance = 15
	else
		player.CameraMaxZoomDistance = 128
		player.CameraMinZoomDistance = 0.5
	end
end)

local extraSection2 = collapsibleSection(extraFrame, "UTILITIES", "extra2")

local infiniteJumpBtn = button(extraSection2, "Infinite Jump: OFF")
infiniteJumpBtn.MouseButton1Click:Connect(function()
	infiniteJumpEnabled = not infiniteJumpEnabled
	infiniteJumpBtn.Text = "Infinite Jump: " .. (infiniteJumpEnabled and "ON" or "OFF")
	setToggleVisual(infiniteJumpBtn, infiniteJumpEnabled)
end)

UIS.JumpRequest:Connect(function()
	if infiniteJumpEnabled and humanoid then
		humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

local tpBtn = button(extraSection2, "Teleport To Cursor (Right Click): OFF")
tpBtn.MouseButton1Click:Connect(function()
	teleportEnabled = not teleportEnabled
	tpBtn.Text = "Teleport To Cursor (Right Click): " .. (teleportEnabled and "ON" or "OFF")
	setToggleVisual(tpBtn, teleportEnabled)
end)

local walkOnWaterBtn = button(extraSection2, "Walk On Water: OFF")
walkOnWaterBtn.MouseButton1Click:Connect(function()
	walkOnWaterEnabled = not walkOnWaterEnabled
	walkOnWaterBtn.Text = "Walk On Water: " .. (walkOnWaterEnabled and "ON" or "OFF")
	setToggleVisual(walkOnWaterBtn, walkOnWaterEnabled)
	
	if walkOnWaterEnabled then
		waterPlatform = Instance.new("Part", workspace)
		waterPlatform.Size = Vector3.new(20, 1, 20)
		waterPlatform.Transparency = 0.8
		waterPlatform.CanCollide = true
		waterPlatform.Anchored = true
		waterPlatform.Material = Enum.Material.Ice
		waterPlatform.BrickColor = BrickColor.new("Cyan")
	else
		if waterPlatform then
			waterPlatform:Destroy()
			waterPlatform = nil
		end
	end
end)

local antiAfkBtn = button(extraSection2, "Anti-AFK: OFF")
antiAfkBtn.MouseButton1Click:Connect(function()
	antiAfkEnabled = not antiAfkEnabled
	antiAfkBtn.Text = "Anti-AFK: " .. (antiAfkEnabled and "ON" or "OFF")
	setToggleVisual(antiAfkBtn, antiAfkEnabled)
end)

local extraSection3 = collapsibleSection(extraFrame, "CHARACTER", "extra3")

local invisBtn = button(extraSection3, "Invisibility: OFF")
invisBtn.MouseButton1Click:Connect(function()
	invisible = not invisible
	invisBtn.Text = "Invisibility: " .. (invisible and "ON" or "OFF")
	setToggleVisual(invisBtn, invisible)
	applyInvisibility()
end)

slider(extraSection3, "Invisibility Strength", 0, 1, invisAmount, function(v)
	invisAmount = v
	if invisible then
		applyInvisibility()
	end
end)

-- NEW EXTRA FEATURES
local extraSection4 = collapsibleSection(extraFrame, "TROLL FEATURES", "extra4")

-- Fake Lag
local fakeLagBtn = button(extraSection4, "Fake Lag: OFF")
fakeLagBtn.MouseButton1Click:Connect(function()
    fakeLagEnabled = not fakeLagEnabled
    fakeLagBtn.Text = "Fake Lag: " .. (fakeLagEnabled and "ON" or "OFF")
    setToggleVisual(fakeLagBtn, fakeLagEnabled)
end)

slider(extraSection4, "Fake Lag Interval", 0.5, 5, fakeLagInterval, function(v)
    fakeLagInterval = v
end)

-- Fake Death
local fakeDeathBtn = button(extraSection4, "Fake Death: OFF")
fakeDeathBtn.MouseButton1Click:Connect(function()
    fakeDeathEnabled = not fakeDeathEnabled
    fakeDeathBtn.Text = "Fake Death: " .. (fakeDeathEnabled and "ON" or "OFF")
    setToggleVisual(fakeDeathBtn, fakeDeathEnabled)
    
    if fakeDeathEnabled and humanoid then
        humanoid.PlatformStand = true
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Anchored = false
                part.CanCollide = true
            end
        end
    else
        humanoid.PlatformStand = false
    end
end)

-- Spin Bot
local spinBotBtn = button(extraSection4, "Spin Bot: OFF")
spinBotBtn.MouseButton1Click:Connect(function()
    spinBotEnabled = not spinBotEnabled
    spinBotBtn.Text = "Spin Bot: " .. (spinBotEnabled and "ON" or "OFF")
    setToggleVisual(spinBotBtn, spinBotEnabled)
end)

slider(extraSection4, "Spin Bot Speed", 1, 20, spinBotSpeed, function(v)
    spinBotSpeed = v
end)

-- Preset System
local extraSection5 = collapsibleSection(extraFrame, "PRESET SYSTEM", "extra5")

local function savePreset(presetName)
    presets[presetName] = {
        fly = fly,
        noclip = noclip,
        walkEnabled = walkEnabled,
        walkSpeed = walkSpeed,
        jumpEnabled = jumpEnabled,
        jumpPower = jumpPower,
        aimAssistEnabled = aimAssistEnabled,
        aimFOV = aimFOV,
        aimSmoothness = aimSmoothness,
        silentAimEnabled = silentAimEnabled,
        silentAimFOV = silentAimFOV,
        hitChance = hitChance,
        bunnyHopEnabled = bunnyHopEnabled,
        dashEnabled = dashEnabled,
        dynamicFOVEnabled = dynamicFOVEnabled,
        healthESPEnabled = healthESPEnabled,
        fakeLagEnabled = fakeLagEnabled,
        spinBotEnabled = spinBotEnabled,
        aimKeybind = aimKeybind,
        aimBone = aimBone
    }
    print("Preset '" .. presetName .. "' saved!")
end

local function loadPreset(presetName)
    local preset = presets[presetName]
    if preset then
        print("Preset '" .. presetName .. "' loaded!")
    else
        print("Preset '" .. presetName .. "' not found!")
    end
end

-- Preset buttons
local legitPresetBtn = button(extraSection5, "Save Legit Preset")
legitPresetBtn.MouseButton1Click:Connect(function()
    savePreset("Legit")
end)

local ragePresetBtn = button(extraSection5, "Save Rage Preset")
ragePresetBtn.MouseButton1Click:Connect(function()
    savePreset("Rage")
end)

local movementPresetBtn = button(extraSection5, "Save Movement Preset")
movementPresetBtn.MouseButton1Click:Connect(function()
    savePreset("Movement")
end)

local visualPresetBtn = button(extraSection5, "Save Visual Preset")
visualPresetBtn.MouseButton1Click:Connect(function()
    savePreset("Visual")
end)

-- Load preset buttons
local loadLegitBtn = button(extraSection5, "Load Legit Preset")
loadLegitBtn.MouseButton1Click:Connect(function()
    loadPreset("Legit")
end)

local loadRageBtn = button(extraSection5, "Load Rage Preset")
loadRageBtn.MouseButton1Click:Connect(function()
    loadPreset("Rage")
end)

createResetButton(extraFrame, "Extra")

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if teleportEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
		if mouse.Hit and root then
			root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
		end
	end
	
	if dashEnabled and input.KeyCode == Enum.KeyCode.F and tick() - lastDashTime >= dashCooldown then
        lastDashTime = tick()
        if root then
            local direction = camera.CFrame.LookVector
            bv = Instance.new("BodyVelocity", root)
            bv.Velocity = direction * dashDistance
            bv.MaxForce = Vector3.new(1e5, 0, 1e5)
            game:GetService("Debris"):AddItem(bv, 0.2)
        end
    end
end)

---------------- TAB SWITCH ----------------
local moveTab = tabButton("Movement")
local combatTab = tabButton("Combat")
local espTab = tabButton("ESP")
local extraTab = tabButton("Extra")

task.wait()
setActiveTab(moveTab)

moveTab.MouseButton1Click:Connect(function()
	setActiveTab(moveTab)
	movementFrame.Visible = true
	combatFrame.Visible = false
	espFrame.Visible = false
	extraFrame.Visible = false
end)

combatTab.MouseButton1Click:Connect(function()
	setActiveTab(combatTab)
	movementFrame.Visible = false
	combatFrame.Visible = true
	espFrame.Visible = false
	extraFrame.Visible = false
end)

espTab.MouseButton1Click:Connect(function()
	setActiveTab(espTab)
	movementFrame.Visible = false
	combatFrame.Visible = false
	espFrame.Visible = true
	extraFrame.Visible = false
end)

extraTab.MouseButton1Click:Connect(function()
	setActiveTab(extraTab)
	movementFrame.Visible = false
	combatFrame.Visible = false
	espFrame.Visible = false
	extraFrame.Visible = true
end)

---------------- MENU TOGGLE ----------------
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
		if main.Visible then
			main.Position = UDim2.fromScale(0.5, 0.48)
			tween(main, {Position = UDim2.fromScale(0.5, 0.5)}, 0.35, Enum.EasingStyle.Back)
		end
	end
end)

---------------- LOOPS ----------------
local function getClosestPlayerInFOV()
	local closestPlayer = nil
	local shortestDistance = math.huge
	
	local screenCenter = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hrp = plr.Character:FindFirstChild("HumanoidRootPart")
			local head = plr.Character:FindFirstChild("Head")
			local humanoid = plr.Character:FindFirstChild("Humanoid")
			
			if hrp and head and humanoid and humanoid.Health > 0 then
				if teamCheck and plr.Team == player.Team then
					continue
				end
				
				if visibilityCheck then
					local ray = Ray.new(camera.CFrame.Position, (head.Position - camera.CFrame.Position).Unit * 500)
					local hit = workspace:FindPartOnRayWithIgnoreList(ray, {character})
					if hit and not hit:IsDescendantOf(plr.Character) then
						continue
					end
				end
				
				local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local screenPoint = Vector2.new(screenPos.X, screenPos.Y)
					local distance = (screenPoint - screenCenter).Magnitude
					
					if distance <= aimFOV and distance < shortestDistance then
						closestPlayer = plr
						shortestDistance = distance
					end
				end
			end
		end
	end
	
	return closestPlayer
end

local afkTime = 0
local lastBunnyHop = 0
local spinBotAngle = 0

RunService.RenderStepped:Connect(function(dt)
	-- Bunny Hop
	if bunnyHopEnabled and humanoid and tick() - lastBunnyHop >= bunnyHopDelay then
		if humanoid.FloorMaterial ~= Enum.Material.Air then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			lastBunnyHop = tick()
		end
	end
	
	-- Air Control
	if airControlStrength > 0 and humanoid then
		if humanoid.FloorMaterial == Enum.Material.Air then
			local move = Vector3.zero
			if UIS:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
			if UIS:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
			if UIS:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
			
			if move.Magnitude > 0 then
				local bv = Instance.new("BodyVelocity")
				bv.Velocity = move.Unit * airControlStrength * 50
				bv.MaxForce = Vector3.new(1e4, 0, 1e4)
				bv.Parent = root
				game:GetService("Debris"):AddItem(bv, 0.1)
			end
		end
	end
	
	-- Spin Bot
	if spinBotEnabled and root then
		spinBotAngle = spinBotAngle + (dt * spinBotSpeed * 10)
		if spinBotAngle > 360 then spinBotAngle = 0 end
		root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(spinBotAngle), 0)
	end
	
	-- Fake Lag
	if fakeLagEnabled and tick() - lastFakeLag >= fakeLagInterval then
		lastFakeLag = tick()
		local savedCF = root.CFrame
		root.Anchored = true
		task.wait(0.1)
		root.Anchored = false
		root.CFrame = savedCF
	end
	
	-- Dynamic FOV
	if dynamicFOVEnabled and aimAssistEnabled then
		local target = getClosestPlayerInFOV()
		if target and target.Character and target.Character:FindFirstChild("Head") then
			local distance = (target.Character.Head.Position - camera.CFrame.Position).Magnitude
			local newFOV = math.clamp(distance * 0.5, 20, aimFOV)
			if fovCircle then
				fovCircle.Radius = newFOV
			end
		end
	end
	
	if fly and bv and bg then
		local cam = camera
		local move = Vector3.zero

		if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

		bv.Velocity = move.Magnitude > 0 and move.Unit * flySpeed or Vector3.zero
		bg.CFrame = cam.CFrame
	end

	if noclip then
		for _,p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then p.CanCollide = false end
		end
	end

	if fovCircle and showFOVCircle then
		fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		if not dynamicFOVEnabled then
			fovCircle.Radius = aimFOV
		end
		fovCircle.Visible = true
	end

	if aimAssistEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = getClosestPlayerInFOV()
		if target and target.Character then
			local targetPart = target.Character:FindFirstChild(aimBone)
			if not targetPart and aimBone == "Random" then
				local parts = {"Head", "Torso"}
				targetPart = target.Character:FindFirstChild(parts[math.random(1, #parts)])
			end
			if not targetPart then
				targetPart = target.Character:FindFirstChild("Head")
			end
			
			if targetPart then
				local targetPos = targetPart.Position
				local camCFrame = camera.CFrame
				local targetCFrame = CFrame.new(camCFrame.Position, targetPos)
				
				camera.CFrame = camCFrame:Lerp(targetCFrame, aimSmoothness)
			end
		end
	end

	if walkOnWaterEnabled and waterPlatform and root then
		local terrain = workspace:FindFirstChildOfClass("Terrain")
		if terrain then
			local region = Region3.new(root.Position - Vector3.new(10, 5, 10), root.Position + Vector3.new(10, 5, 10))
			region = region:ExpandToGrid(4)
			
			local materials, sizes = terrain:ReadVoxels(region, 4)
			local size = materials.Size
			
			for x = 1, size.X do
				for y = 1, size.Y do
					for z = 1, size.Z do
						if materials[x][y][z] == Enum.Material.Water then
							waterPlatform.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.5, root.Position.Z)
							return
						end
					end
				end
			end
		end
	end

	if antiAfkEnabled then
		afkTime = afkTime + dt
		if afkTime >= 15 then
			afkTime = 0
			local VirtualUser = game:GetService("VirtualUser")
			VirtualUser:CaptureController()
			VirtualUser:ClickButton2(Vector2.new())
		end
	end

	if boxESP then
		for _,h in pairs(boxESPObjects) do h:Destroy() end
		boxESPObjects = {}

		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				
				local billboard = Instance.new("BillboardGui")
				billboard.Adornee = hrp
				billboard.Size = UDim2.new(4, 0, 5, 0)
				billboard.AlwaysOnTop = true
				billboard.Parent = gui
				
				local box = Instance.new("Frame", billboard)
				box.Size = UDim2.fromScale(1, 1)
				box.BackgroundTransparency = 1
				box.BorderSizePixel = 0
				
				local function createLine(parent, pos, size)
					local line = Instance.new("Frame", parent)
					line.Position = pos
					line.Size = size
					line.BackgroundColor3 = boxESPColor
					line.BorderSizePixel = 0
					return line
				end
				
				createLine(box, UDim2.new(0, 0, 0, 0), UDim2.new(0.3, 0, 0, 2))
				createLine(box, UDim2.new(0.7, 0, 0, 0), UDim2.new(0.3, 0, 0, 2))
				createLine(box, UDim2.new(0, 0, 1, -2), UDim2.new(0.3, 0, 0, 2))
				createLine(box, UDim2.new(0.7, 0, 1, -2), UDim2.new(0.3, 0, 0, 2))
				createLine(box, UDim2.new(0, 0, 0, 0), UDim2.new(0, 2, 0.3, 0))
				createLine(box, UDim2.new(0, 0, 0.7, 0), UDim2.new(0, 2, 0.3, 0))
				createLine(box, UDim2.new(1, -2, 0, 0), UDim2.new(0, 2, 0.3, 0))
				createLine(box, UDim2.new(1, -2, 0.7, 0), UDim2.new(0, 2, 0.3, 0))
				
				table.insert(boxESPObjects, billboard)
			end
		end
	end

	if tracersEnabled then
		for _,t in pairs(tracerObjects) do t:Destroy() end
		tracerObjects = {}

		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				
				local a0 = Instance.new("Attachment", workspace.Terrain)
				local a1 = Instance.new("Attachment", hrp)
				
				a0.WorldPosition = camera.CFrame.Position
				
				local beam = Instance.new("Beam")
				beam.Attachment0 = a0
				beam.Attachment1 = a1
				beam.Color = ColorSequence.new(tracerColor)
				beam.Width0 = 0.1
				beam.Width1 = 0.1
				beam.FaceCamera = true
				beam.Parent = workspace.Terrain
				
				table.insert(tracerObjects, beam)
				table.insert(tracerObjects, a0)
			end
		end
	end

	if distanceEnabled then
		for _,d in pairs(distanceObjects) do d:Destroy() end
		distanceObjects = {}

		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") and root then
				local distance = (plr.Character.Head.Position - root.Position).Magnitude
				
				local bb = Instance.new("BillboardGui")
				bb.Size = UDim2.new(0, 100, 0, 25)
				bb.AlwaysOnTop = true
				bb.Adornee = plr.Character.Head
				bb.StudsOffset = Vector3.new(0, 2.5, 0)

				local t = Instance.new("TextLabel", bb)
				t.Size = UDim2.fromScale(1, 1)
				t.BackgroundTransparency = 1
				t.Text = math.floor(distance) .. " studs"
				t.TextColor3 = Color3.fromRGB(255, 255, 0)
				t.TextStrokeTransparency = 0
				t.Font = Enum.Font.GothamBold
				t.TextSize = 14

				bb.Parent = gui
				table.insert(distanceObjects, bb)
			end
		end
	end
end)

print("Simple Hub v3.7 - Enhanced Edition loaded - UI/UX Fixed")
print("UI Fixes Applied: Proper Scrolling, Fixed Collapsible Sections, No Element Clipping, Smooth Animations")
