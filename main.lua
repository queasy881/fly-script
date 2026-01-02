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

local defaultFOV = camera.FieldOfView

local bv, bg
local nameESPObjects = {}
local boxESPObjects = {}

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
main.Size = UDim2.new(0, 780, 0, 420)
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

local function tabButton(text)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0, 180, 0, 36)
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
	
	b.setActive = function()
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
		tween(indicator, {Size = UDim2.new(0.8, 0, 0, 3)}, 0.3, Enum.EasingStyle.Back)
	end

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
local movementFrame = Instance.new("Frame", content)
local espFrame = Instance.new("Frame", content)
local extraFrame = Instance.new("Frame", content)

for _,f in pairs({movementFrame, espFrame, extraFrame}) do
	f.Size = UDim2.new(1, 0, 1, 0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.ClipsDescendants = true

	local pad = Instance.new("UIPadding", f)
	pad.PaddingTop = UDim.new(0, 16)
	pad.PaddingLeft = UDim.new(0, 20)
	pad.PaddingRight = UDim.new(0, 20)
	pad.PaddingBottom = UDim.new(0, 16)

	local layout = Instance.new("UIListLayout", f)
	layout.Padding = UDim.new(0, 10)
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
section(espFrame, "ESP")

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

	if not boxESP then return end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hl = Instance.new("Highlight")
			hl.FillColor = Color3.fromRGB(255,0,0)
			hl.OutlineColor = Color3.new(1,1,1)
			hl.Parent = plr.Character
			table.insert(boxESPObjects, hl)
		end
	end
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
local espTab = tabButton("ESP")
local extraTab = tabButton("Extra")

moveTab.setActive()

moveTab.MouseButton1Click:Connect(function()
	moveTab.setActive()
	movementFrame.Visible = true
	espFrame.Visible = false
	extraFrame.Visible = false
end)

espTab.MouseButton1Click:Connect(function()
	espTab.setActive()
	movementFrame.Visible = false
	espFrame.Visible = true
	extraFrame.Visible = false
end)

extraTab.MouseButton1Click:Connect(function()
	extraTab.setActive()
	movementFrame.Visible = false
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
end)

print("Simple Hub v3.6 - Polished UI Edition loaded")
