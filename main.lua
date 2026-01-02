-- SIMPLE HUB v3 – Proper Tabs + ESP
-- Press M to toggle

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
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
local skeletonESP = false

local bv, bg
local nameESPObjects = {}
local boxESPObjects = {}
local skeletonObjects = {}

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 520, 0, 360)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(14,14,14)
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

-- Tab bar
local tabBar = Instance.new("Frame", main)
tabBar.Size = UDim2.new(1,0,0,42)
tabBar.BackgroundColor3 = Color3.fromRGB(20,20,20)

local tabLayout = Instance.new("UIListLayout", tabBar)
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.HorizontalAlignment = Center
tabLayout.Padding = UDim.new(0,10)

-- Content holder
local content = Instance.new("Frame", main)
content.Position = UDim2.new(0,0,0,42)
content.Size = UDim2.new(1,0,1,-42)
content.BackgroundTransparency = 1

---------------- HELPERS ----------------
local function tabButton(text)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0,140,1,0)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	Instance.new("UICorner", b)
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
	b.Text = text .. ": OFF"
	Instance.new("UICorner", b)
	return b
end

---------------- FRAMES ----------------
local movementFrame = Instance.new("Frame", content)
movementFrame.Size = UDim2.new(1,0,1,0)
movementFrame.BackgroundTransparency = 1

local espFrame = Instance.new("Frame", content)
espFrame.Size = UDim2.new(1,0,1,0)
espFrame.BackgroundTransparency = 1
espFrame.Visible = false

for _,f in pairs({movementFrame, espFrame}) do
	local pad = Instance.new("UIPadding", f)
	pad.PaddingTop = UDim.new(0,14)
	pad.PaddingLeft = UDim.new(0,14)
	pad.PaddingRight = UDim.new(0,14)

	local layout = Instance.new("UIListLayout", f)
	layout.Padding = UDim.new(0,10)
end

---------------- MOVEMENT TAB ----------------
section(movementFrame, "Movement")

local flyBtn = button(movementFrame, "Fly")
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

local noclipBtn = button(movementFrame, "Noclip")
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

---------------- ESP TAB ----------------
section(espFrame, "ESP")

local nameBtn = button(espFrame, "Name ESP")
nameBtn.MouseButton1Click:Connect(function()
	nameESP = not nameESP
	nameBtn.Text = "Name ESP: " .. (nameESP and "ON" or "OFF")
end)

local boxBtn = button(espFrame, "Box ESP")
boxBtn.MouseButton1Click:Connect(function()
	boxESP = not boxESP
	boxBtn.Text = "Box ESP: " .. (boxESP and "ON" or "OFF")
end)

local skeletonBtn = button(espFrame, "Skeleton ESP")
skeletonBtn.MouseButton1Click:Connect(function()
	skeletonESP = not skeletonESP
	skeletonBtn.Text = "Skeleton ESP: " .. (skeletonESP and "ON" or "OFF")
end)

---------------- TAB SWITCH ----------------
local moveTab = tabButton("Movement")
local espTab = tabButton("ESP")

moveTab.MouseButton1Click:Connect(function()
	movementFrame.Visible = true
	espFrame.Visible = false
end)

espTab.MouseButton1Click:Connect(function()
	movementFrame.Visible = false
	espFrame.Visible = true
end)

---------------- INPUT ----------------
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
	end
end)

---------------- LOOPS ----------------
RunService.RenderStepped:Connect(function()
	if fly and bv and bg then
		local cam = workspace.CurrentCamera
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

print("Simple Hub v3 loaded")
