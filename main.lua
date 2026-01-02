-- SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")

--------------------------------------------------
-- GUI
--------------------------------------------------

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 360)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local padding = Instance.new("UIPadding", main)
padding.PaddingTop = UDim.new(0,12)
padding.PaddingLeft = UDim.new(0,12)
padding.PaddingRight = UDim.new(0,12)

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Text = "Simple Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

--------------------------------------------------
-- Button helper
--------------------------------------------------

local function makeButton(name)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1,-10,0,36)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = name .. ": OFF"
	b.Parent = main
	Instance.new("UICorner", b)
	return b
end

--------------------------------------------------
-- ESP (Names)
--------------------------------------------------

local espOn = false
local espObjects = {}

local function toggleESP(btn)
	espOn = not espOn
	btn.Text = "Name ESP: " .. (espOn and "ON" or "OFF")

	for _,v in pairs(espObjects) do v:Destroy() end
	espObjects = {}

	if not espOn then return end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0,100,0,30)
			bb.AlwaysOnTop = true
			bb.Adornee = plr.Character.Head

			local txt = Instance.new("TextLabel", bb)
			txt.Size = UDim2.fromScale(1,1)
			txt.BackgroundTransparency = 1
			txt.Text = plr.Name
			txt.TextColor3 = Color3.new(1,1,1)
			txt.TextStrokeTransparency = 0

			bb.Parent = gui
			table.insert(espObjects, bb)
		end
	end
end

--------------------------------------------------
-- Chams
--------------------------------------------------

local chamsOn = false
local chams = {}

local function toggleChams(btn)
	chamsOn = not chamsOn
	btn.Text = "Chams: " .. (chamsOn and "ON" or "OFF")

	for _,h in pairs(chams) do h:Destroy() end
	chams = {}

	if not chamsOn then return end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hl = Instance.new("Highlight")
			hl.FillColor = Color3.fromRGB(255,0,0)
			hl.OutlineColor = Color3.new(1,1,1)
			hl.Parent = plr.Character
			table.insert(chams, hl)
		end
	end
end

--------------------------------------------------
-- Noclip
--------------------------------------------------

local noclip = false

RunService.Stepped:Connect(function()
	if noclip then
		for _,p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end
end)

--------------------------------------------------
-- Fly
--------------------------------------------------

local fly = false
local flySpeed = 23
local bv, bg

local function toggleFly(btn)
	fly = not fly
	btn.Text = "Fly: " .. (fly and "ON" or "OFF")

	if fly then
		bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end

RunService.RenderStepped:Connect(function()
	if not fly then return end
	local cam = workspace.CurrentCamera
	local move = Vector3.zero

	if UIS:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

	if move.Magnitude > 0 then
		move = move.Unit * flySpeed
	end

	bv.Velocity = move
	bg.CFrame = cam.CFrame
end)

--------------------------------------------------
-- Buttons
--------------------------------------------------

local espBtn = makeButton("Name ESP")
espBtn.MouseButton1Click:Connect(function() toggleESP(espBtn) end)

local chamsBtn = makeButton("Chams")
chamsBtn.MouseButton1Click:Connect(function() toggleChams(chamsBtn) end)

local noclipBtn = makeButton("Noclip")
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

local flyBtn = makeButton("Fly")
flyBtn.MouseButton1Click:Connect(function() toggleFly(flyBtn) end)

local speedUp = makeButton("Fly Speed +")
speedUp.MouseButton1Click:Connect(function()
	flySpeed += 5
	speedUp.Text = "Fly Speed: "..flySpeed
end)

--------------------------------------------------
-- Menu toggle
--------------------------------------------------

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
	end
end)
