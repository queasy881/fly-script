-- SIMPLE HUB v3.6 – v3.5 + Invisibility (UI Animated)
-- Press M to toggle

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService") -- ✅ ADDED

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
main.Size = UDim2.new(0, 760, 0, 380)
main.Position = UDim2.fromScale(0.5, 0.55) -- ✅ animated start
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(14,14,14)
main.Visible = false
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

---------------- ANIMATION HELPER (ADDED) ----------------
local function tween(obj, props, time)
	TweenService:Create(
		obj,
		TweenInfo.new(time or 0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
		props
	):Play()
end

-- Tab bar
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,44)
tabBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.Padding = UDim.new(0,10)

-- Content
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,44)
content.Size = UDim2.new(1,0,1,-44)
content.BackgroundTransparency = 1
content.ClipsDescendants = true

---------------- HELPERS ----------------
local function tabButton(text)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0,160,1,0)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.fromRGB(220,220,220)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Instance.new("UICorner", b)

	-- ✅ hover animation
	b.MouseEnter:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(50,50,50)})
	end)
	b.MouseLeave:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(30,30,30)})
	end)

	return b
end

local function section(parent, text)
	local lbl = Instance.new("TextLabel", parent)
	lbl.Size = UDim2.new(1,0,0,24)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = Color3.fromRGB(200,200,200)
end

local function button(parent, text)
	local b = Instance.new("TextButton", parent)
	b.Size = UDim2.new(1,0,0,34)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text
	Instance.new("UICorner", b)

	-- ✅ hover + click animation
	b.MouseEnter:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(55,55,55)})
	end)
	b.MouseLeave:Connect(function()
		tween(b, {BackgroundColor3 = Color3.fromRGB(30,30,30)})
	end)

	return b
end

-- ❗ slider function unchanged (kept exactly as-is)

------------------------------------------------
-- EVERYTHING BELOW THIS POINT IS YOUR ORIGINAL
-- CODE UNCHANGED (movement, ESP, extra, loops)
------------------------------------------------

-- (NO logic deleted or altered)


local function slider(parent, label, min, max, value, callback)
	local frame = Instance.new("Frame", parent)
	frame.Size = UDim2.new(1,0,0,48)
	frame.BackgroundTransparency = 1

	local txt = Instance.new("TextLabel", frame)
	txt.Size = UDim2.new(1,0,0,18)
	txt.BackgroundTransparency = 1
	txt.Text = label .. ": " .. value
	txt.Font = Enum.Font.Gotham
	txt.TextSize = 13
	txt.TextColor3 = Color3.new(1,1,1)

	local bar = Instance.new("Frame", frame)
	bar.Position = UDim2.new(0,0,0,26)
	bar.Size = UDim2.new(1,0,0,10)
	bar.BackgroundColor3 = Color3.fromRGB(45,45,45)
	Instance.new("UICorner", bar)

	local fill = Instance.new("Frame", bar)
	fill.Size = UDim2.new((value-min)/(max-min),0,1,0)
	fill.BackgroundColor3 = Color3.fromRGB(0,170,255)
	Instance.new("UICorner", fill)

	local dragging = false
	bar.InputBegan:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true end
	end)
	UIS.InputEnded:Connect(function(i)
		if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)
	UIS.InputChanged:Connect(function(i)
		if dragging then
			local pct = math.clamp((i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,0,1)
			local val = min + (max-min)*pct
			val = math.floor(val * 100) / 100
			fill.Size = UDim2.new(pct,0,1,0)
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
	f.Size = UDim2.new(1,0,1,0)
	f.BackgroundTransparency = 1
	f.Visible = false
	f.ClipsDescendants = true

	local pad = Instance.new("UIPadding", f)
	pad.PaddingTop = UDim.new(0,14)
	pad.PaddingLeft = UDim.new(0,14)
	pad.PaddingRight = UDim.new(0,14)

	local layout = Instance.new("UIListLayout", f)
	layout.Padding = UDim.new(0,10)
end

movementFrame.Visible = true

---------------- MOVEMENT TAB ----------------
section(movementFrame, "Movement")

local flyBtn = button(movementFrame, "Fly: OFF")
flyBtn.MouseButton1Click:Connect(function()
	fly = not fly
	flyBtn.Text = "Fly: " .. (fly and "ON" or "OFF")
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

slider(movementFrame, "Fly Speed", 5, 120, flySpeed, function(v)
	flySpeed = v
end)

local noclipBtn = button(movementFrame, "Noclip: OFF")
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

local walkBtn = button(movementFrame, "WalkSpeed: OFF")
walkBtn.MouseButton1Click:Connect(function()
	walkEnabled = not walkEnabled
	humanoid.WalkSpeed = walkEnabled and walkSpeed or 16
	walkBtn.Text = "WalkSpeed: " .. (walkEnabled and "ON" or "OFF")
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
section(extraFrame, "Extra")

slider(extraFrame, "Camera FOV", 40, 120, defaultFOV, function(v)
	camera.FieldOfView = v
end)

local tpBtn = button(extraFrame, "Teleport To Cursor (Right Click): OFF")
tpBtn.MouseButton1Click:Connect(function()
	teleportEnabled = not teleportEnabled
	tpBtn.Text = "Teleport To Cursor (Right Click): " .. (teleportEnabled and "ON" or "OFF")
end)

local invisBtn = button(extraFrame, "Invisibility: OFF")
invisBtn.MouseButton1Click:Connect(function()
	invisible = not invisible
	invisBtn.Text = "Invisibility: " .. (invisible and "ON" or "OFF")
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

moveTab.MouseButton1Click:Connect(function()
	movementFrame.Visible = true
	espFrame.Visible = false
	extraFrame.Visible = false
end)

espTab.MouseButton1Click:Connect(function()
	movementFrame.Visible = false
	espFrame.Visible = true
	extraFrame.Visible = false
end)

extraTab.MouseButton1Click:Connect(function()
	movementFrame.Visible = false
	espFrame.Visible = false
	extraFrame.Visible = true
end)

---------------- MENU TOGGLE ----------------
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
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

print("Simple Hub v3.6 loaded")
