-- SIMPLE HUB v3.6 – Polished UI Edition
-- Press M to toggle

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- Character respawn handler
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
end)

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

local defaultFOV = camera.FieldOfView

local bv, bg
local nameESPObjects = {}
local boxESPObjects = {}
local fovCircle = nil

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

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 780, 0, 480)
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
versionLabel.Text = "v3.6"
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

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.Padding = UDim.new(0, 8)

-- Content
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0, 0, 0, 98)
content.Size = UDim2.new(1, 0, 1, -98)
content.BackgroundTransparency = 1
content.ClipsDescendants = true

---------------- HELPERS ----------------
local activeTab = nil
local tabButtons = {}

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

local function section(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Size = UDim2.new(1, 0, 0, 28)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 13
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = Color3.fromRGB(180, 180, 200)
end

local function button(parent, text)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1, 0, 0, 38)
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

local function slider(parent, label, min, max, value, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1, 0, 0, 52)
	frame.BackgroundTransparency = 1

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

---------------- FRAMES ----------------
local movementFrame = Instance.new("ScrollingFrame", content)
local combatFrame = Instance.new("ScrollingFrame", content)
local espFrame = Instance.new("ScrollingFrame", content)
local extraFrame = Instance.new("ScrollingFrame", content)

for _,f in pairs({movementFrame, combatFrame, espFrame, extraFrame}) do
	f.Size = UDim2.new(1, 0, 1, 0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.ClipsDescendants = false
	f.BorderSizePixel = 0
	f.ScrollBarThickness = 6
	f.ScrollBarImageColor3 = Color3.fromRGB(88, 166, 255)
	f.CanvasSize = UDim2.new(0, 0, 2, 0)
	f.AutomaticCanvasSize = Enum.AutomaticSize.Y
	f.ScrollingDirection = Enum.ScrollingDirection.Y

	local pad = Instance.new("UIPadding", f)
	pad.PaddingTop = UDim.new(0, 16)
	pad.PaddingLeft = UDim.new(0, 20)
	pad.PaddingRight = UDim.new(0, 26)
	pad.PaddingBottom = UDim.new(0, 16)

	local layout = Instance.new("UIListLayout", f)
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
end

movementFrame.Visible = true

---------------- MOVEMENT TAB ----------------
section(movementFrame, "MOVEMENT")

local flyBtn = button(movementFrame, "Fly: OFF")
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = "Fly: " .. (fly and "ON" or "OFF")
	if fly then
		tween(flyBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(flyBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
		bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	else
		tween(flyBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(flyBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

slider(movementFrame, "Fly Speed", 5, 120, flySpeed, function(v)
	flySpeed = v
end)

local noclipBtn = button(movementFrame, "Noclip: OFF")
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
	if noclip then
		tween(noclipBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(noclipBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(noclipBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(noclipBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

local walkBtn = button(movementFrame, "WalkSpeed: OFF")
walkBtn.MouseButton1Click:Connect(function()
	walkEnabled = not walkEnabled
	humanoid.WalkSpeed = walkEnabled and walkSpeed or 16
	walkBtn.Text = "WalkSpeed: " .. (walkEnabled and "ON" or "OFF")
	if walkEnabled then
		tween(walkBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(walkBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(walkBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(walkBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

slider(movementFrame, "WalkSpeed Value", 8, 100, walkSpeed, function(v)
	walkSpeed = v
	if walkEnabled then humanoid.WalkSpeed = v end
end)

local jumpBtn = button(movementFrame, "JumpPower: OFF")
jumpBtn.MouseButton1Click:Connect(function()
	jumpEnabled = not jumpEnabled
	humanoid.JumpPower = jumpEnabled and jumpPower or 50
	jumpBtn.Text = "JumpPower: " .. (jumpEnabled and "ON" or "OFF")
	if jumpEnabled then
		tween(jumpBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(jumpBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(jumpBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(jumpBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

slider(movementFrame, "JumpPower Value", 20, 150, jumpPower, function(v)
	jumpPower = v
	if jumpEnabled then humanoid.JumpPower = v end
end)

---------------- ESP TAB ----------------
section(espFrame, "PLAYER ESP")

local nameBtn = button(espFrame, "Name ESP: OFF")
nameBtn.MouseButton1Click:Connect(function()
	nameESP = not nameESP
	nameBtn.Text = "Name ESP: " .. (nameESP and "ON" or "OFF")

	if nameESP then
		tween(nameBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(nameBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(nameBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(nameBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end

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

local boxBtn = button(espFrame, "Box ESP: OFF")
boxBtn.MouseButton1Click:Connect(function()
	boxESP = not boxESP
	boxBtn.Text = "Box ESP: " .. (boxESP and "ON" or "OFF")

	if boxESP then
		tween(boxBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(boxBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(boxBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(boxBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end

	for _,h in pairs(boxESPObjects) do h:Destroy() end
	boxESPObjects = {}
end)

section(espFrame, "VISIBILITY")

local tracersEnabled = false
local tracerObjects = {}

local tracersBtn = button(espFrame, "Tracers: OFF")
tracersBtn.MouseButton1Click:Connect(function()
	tracersEnabled = not tracersEnabled
	tracersBtn.Text = "Tracers: " .. (tracersEnabled and "ON" or "OFF")

	if tracersEnabled then
		tween(tracersBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(tracersBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(tracersBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(tracersBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
		for _,t in pairs(tracerObjects) do t:Destroy() end
		tracerObjects = {}
	end
end)

local chamsEnabled = false
local chamsObjects = {}

local chamsBtn = button(espFrame, "Chams: OFF")
chamsBtn.MouseButton1Click:Connect(function()
	chamsEnabled = not chamsEnabled
	chamsBtn.Text = "Chams: " .. (chamsEnabled and "ON" or "OFF")

	if chamsEnabled then
		tween(chamsBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(chamsBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(chamsBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(chamsBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
		for _,c in pairs(chamsObjects) do c:Destroy() end
		chamsObjects = {}
	end

	for _,c in pairs(chamsObjects) do c:Destroy() end
	chamsObjects = {}

	if not chamsEnabled then return end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hl = Instance.new("Highlight")
			hl.FillColor = Color3.fromRGB(0, 255, 100)
			hl.FillTransparency = 0.5
			hl.OutlineColor = Color3.fromRGB(0, 200, 80)
			hl.OutlineTransparency = 0
			hl.Parent = plr.Character
			table.insert(chamsObjects, hl)
		end
	end
end)

local distanceEnabled = false
local distanceObjects = {}

local distanceBtn = button(espFrame, "Distance ESP: OFF")
distanceBtn.MouseButton1Click:Connect(function()
	distanceEnabled = not distanceEnabled
	distanceBtn.Text = "Distance ESP: " .. (distanceEnabled and "ON" or "OFF")

	if distanceEnabled then
		tween(distanceBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(distanceBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(distanceBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(distanceBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
		for _,d in pairs(distanceObjects) do d:Destroy() end
		distanceObjects = {}
	end
end)

---------------- AIM ASSIST TAB ----------------
section(aimFrame, "AIM ASSIST")

local aimBtn = button(aimFrame, "Aim Assist: OFF")
aimBtn.MouseButton1Click:Connect(function()
	aimAssistEnabled = not aimAssistEnabled
	aimBtn.Text = "Aim Assist: " .. (aimAssistEnabled and "ON" or "OFF")
	if aimAssistEnabled then
		tween(aimBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(aimBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(aimBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(aimBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

slider(aimFrame, "FOV Size", 20, 500, aimFOV, function(v)
	aimFOV = v
	if fovCircle then
		fovCircle.Radius = v
	end
end)

slider(aimFrame, "Smoothness", 0.1, 1, aimSmoothness, function(v)
	aimSmoothness = v
end)

section(aimFrame, "VISUAL")

local fovCircleBtn = button(aimFrame, "Show FOV Circle: OFF")
fovCircleBtn.MouseButton1Click:Connect(function()
	showFOVCircle = not showFOVCircle
	fovCircleBtn.Text = "Show FOV Circle: " .. (showFOVCircle and "ON" or "OFF")
	if showFOVCircle then
		tween(fovCircleBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(fovCircleBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
		
		if not fovCircle then
			fovCircle = Drawing.new("Circle")
			fovCircle.Thickness = 2
			fovCircle.NumSides = 50
			fovCircle.Radius = aimFOV
			fovCircle.Color = Color3.fromRGB(255, 255, 255)
			fovCircle.Transparency = 0.8
			fovCircle.Filled = false
		end
		fovCircle.Visible = true
	else
		tween(fovCircleBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(fovCircleBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
		if fovCircle then
			fovCircle.Visible = false
		end
	end
end)

section(aimFrame, "FILTERS")

local teamCheckBtn = button(aimFrame, "Team Check: ON")
teamCheckBtn.MouseButton1Click:Connect(function()
	teamCheck = not teamCheck
	teamCheckBtn.Text = "Team Check: " .. (teamCheck and "ON" or "OFF")
	if teamCheck then
		tween(teamCheckBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(teamCheckBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(teamCheckBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(teamCheckBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

local visCheckBtn = button(aimFrame, "Visibility Check: ON")
visCheckBtn.MouseButton1Click:Connect(function()
	visibilityCheck = not visibilityCheck
	visCheckBtn.Text = "Visibility Check: " .. (visibilityCheck and "ON" or "OFF")
	if visibilityCheck then
		tween(visCheckBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(visCheckBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(visCheckBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(visCheckBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

-- Set initial state
tween(teamCheckBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0)
tween(teamCheckBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0)
tween(visCheckBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0)
tween(visCheckBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0)

section(aimFrame, "SILENT AIM")

local silentAimBtn = button(aimFrame, "Silent Aim: OFF")
silentAimBtn.MouseButton1Click:Connect(function()
	silentAimEnabled = not silentAimEnabled
	silentAimBtn.Text = "Silent Aim: " .. (silentAimEnabled and "ON" or "OFF")
	if silentAimEnabled then
		tween(silentAimBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(silentAimBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(silentAimBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(silentAimBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

slider(aimFrame, "Silent Aim FOV", 20, 500, silentAimFOV, function(v)
	silentAimFOV = v
end)

slider(aimFrame, "Hit Chance %", 0, 100, hitChance, function(v)
	hitChance = v
end)

---------------- EXTRA TAB ----------------
section(extraFrame, "EXTRA")

slider(extraFrame, "Camera FOV", 40, 120, defaultFOV, function(v)
	camera.FieldOfView = v
end)

local tpBtn = button(extraFrame, "Teleport To Cursor (Right Click): OFF")
tpBtn.MouseButton1Click:Connect(function()
	teleportEnabled = not teleportEnabled
	tpBtn.Text = "Teleport To Cursor (Right Click): " .. (teleportEnabled and "ON" or "OFF")
	if teleportEnabled then
		tween(tpBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(tpBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(tpBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(tpBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
end)

local invisBtn = button(extraFrame, "Invisibility: OFF")
invisBtn.MouseButton1Click:Connect(function()
	invisible = not invisible
	invisBtn.Text = "Invisibility: " .. (invisible and "ON" or "OFF")
	if invisible then
		tween(invisBtn, {BackgroundColor3 = Color3.fromRGB(70, 140, 220)}, 0.25)
		tween(invisBtn, {TextColor3 = Color3.fromRGB(255, 255, 255)}, 0.25)
	else
		tween(invisBtn, {BackgroundColor3 = Color3.fromRGB(26, 26, 34)}, 0.25)
		tween(invisBtn, {TextColor3 = Color3.fromRGB(200, 200, 220)}, 0.25)
	end
	applyInvisibility()
end)

slider(extraFrame, "Invisibility Strength", 0, 1, invisAmount, function(v)
	invisAmount = v
	if invisible then
		applyInvisibility()
	end
end)

UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if teleportEnabled and input.UserInputType == Enum.UserInputType.MouseButton2 then
		if mouse.Hit and root then
			root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0,3,0))
		end
	end
end)

---------------- TAB SWITCH ----------------
local moveTab = tabButton("Movement")
local combatTab = tabButton("Combat")
local espTab = tabButton("ESP")
local extraTab = tabButton("Extra")

-- Set initial active tab
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
-- Aim assist helper function
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
				-- Team check
				if teamCheck and plr.Team == player.Team then
					continue
				end
				
				-- Visibility check
				if visibilityCheck then
					local ray = Ray.new(camera.CFrame.Position, (head.Position - camera.CFrame.Position).Unit * 500)
					local hit = workspace:FindPartOnRayWithIgnoreList(ray, {character})
					if hit and not hit:IsDescendantOf(plr.Character) then
						continue
					end
				end
				
				-- Check if in FOV
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

RunService.RenderStepped:Connect(function()
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

	-- Update FOV circle position
	if fovCircle and showFOVCircle then
		fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		fovCircle.Radius = aimFOV
		fovCircle.Visible = true
	end

	-- Aim assist logic
	if aimAssistEnabled and UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
		local target = getClosestPlayerInFOV()
		if target and target.Character then
			local head = target.Character:FindFirstChild("Head")
			if head then
				local targetPos = head.Position
				local camCFrame = camera.CFrame
				local targetCFrame = CFrame.new(camCFrame.Position, targetPos)
				
				-- Smooth aim
				camera.CFrame = camCFrame:Lerp(targetCFrame, aimSmoothness)
			end
		end
	end

	-- Box ESP update (actual boxes)
	if boxESP then
		for _,h in pairs(boxESPObjects) do h:Destroy() end
		boxESPObjects = {}

		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				
				-- Create BillboardGui for the box
				local billboard = Instance.new("BillboardGui")
				billboard.Adornee = hrp
				billboard.Size = UDim2.new(4, 0, 5, 0)
				billboard.AlwaysOnTop = true
				billboard.Parent = gui
				
				-- Create the box frame
				local box = Instance.new("Frame", billboard)
				box.Size = UDim2.fromScale(1, 1)
				box.BackgroundTransparency = 1
				box.BorderSizePixel = 0
				
				-- Create box corners/edges
				local function createLine(parent, pos, size)
					local line = Instance.new("Frame", parent)
					line.Position = pos
					line.Size = size
					line.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
					line.BorderSizePixel = 0
					return line
				end
				
				-- Top lines
				createLine(box, UDim2.new(0, 0, 0, 0), UDim2.new(0.3, 0, 0, 2))
				createLine(box, UDim2.new(0.7, 0, 0, 0), UDim2.new(0.3, 0, 0, 2))
				
				-- Bottom lines
				createLine(box, UDim2.new(0, 0, 1, -2), UDim2.new(0.3, 0, 0, 2))
				createLine(box, UDim2.new(0.7, 0, 1, -2), UDim2.new(0.3, 0, 0, 2))
				
				-- Left lines
				createLine(box, UDim2.new(0, 0, 0, 0), UDim2.new(0, 2, 0.3, 0))
				createLine(box, UDim2.new(0, 0, 0.7, 0), UDim2.new(0, 2, 0.3, 0))
				
				-- Right lines
				createLine(box, UDim2.new(1, -2, 0, 0), UDim2.new(0, 2, 0.3, 0))
				createLine(box, UDim2.new(1, -2, 0.7, 0), UDim2.new(0, 2, 0.3, 0))
				
				table.insert(boxESPObjects, billboard)
			end
		end
	end

	-- Tracers update
	if tracersEnabled then
		for _,t in pairs(tracerObjects) do t:Destroy() end
		tracerObjects = {}

		for _,plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
				local hrp = plr.Character.HumanoidRootPart
				
				-- Create beam for tracer
				local a0 = Instance.new("Attachment", workspace.Terrain)
				local a1 = Instance.new("Attachment", hrp)
				
				a0.WorldPosition = camera.CFrame.Position
				
				local beam = Instance.new("Beam")
				beam.Attachment0 = a0
				beam.Attachment1 = a1
				beam.Color = ColorSequence.new(Color3.fromRGB(255, 255, 0))
				beam.Width0 = 0.1
				beam.Width1 = 0.1
				beam.FaceCamera = true
				beam.Parent = workspace.Terrain
				
				table.insert(tracerObjects, beam)
				table.insert(tracerObjects, a0)
			end
		end
	end

	-- Distance ESP update
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

print("Simple Hub v3.6 - Polished UI Edition loaded")
