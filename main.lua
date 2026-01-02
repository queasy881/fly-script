-- SIMPLE HUB | M to open
-- Built fully, no manual adding needed

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

---------------- CONFIG ----------------
local flySpeed = 23
local flyEnabled = false
local noclip = false
local espOn = false
local boxEsp = false
local distanceEsp = false
local teamCheck = false
local chamsOn = false
local chamsColor = Color3.fromRGB(255,0,0)

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 460, 0, 420)
main.Position = UDim2.fromScale(0.5,0.5)
main.AnchorPoint = Vector2.new(0.5,0.5)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0,14)

local pad = Instance.new("UIPadding", main)
pad.PaddingTop = UDim.new(0,12)
pad.PaddingLeft = UDim.new(0,12)
pad.PaddingRight = UDim.new(0,12)

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1,0,0,36)
title.BackgroundTransparency = 1
title.Text = "Simple Hub"
title.Font = Enum.Font.GothamBold
title.TextSize = 20
title.TextColor3 = Color3.new(1,1,1)

---------------- DRAG ----------------
local dragging, dragStart, startPos
main.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = true
		dragStart = i.Position
		startPos = main.Position
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1 then
		dragging = false
	end
end)
UIS.InputChanged:Connect(function(i)
	if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
		local delta = i.Position - dragStart
		main.Position = UDim2.new(
			startPos.X.Scale, startPos.X.Offset + delta.X,
			startPos.Y.Scale, startPos.Y.Offset + delta.Y
		)
	end
end)

---------------- HELPERS ----------------
local function button(text)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1,-10,0,32)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text
	Instance.new("UICorner", b)
	return b
end

local function slider(label, min, max, value, callback)
	local frame = Instance.new("Frame", main)
	frame.Size = UDim2.new(1,-10,0,50)
	frame.BackgroundTransparency = 1

	local txt = Instance.new("TextLabel", frame)
	txt.Size = UDim2.new(1,0,0,18)
	txt.BackgroundTransparency = 1
	txt.Text = label..": "..value
	txt.TextColor3 = Color3.new(1,1,1)
	txt.Font = Enum.Font.Gotham
	txt.TextSize = 14

	local bar = Instance.new("Frame", frame)
	bar.Position = UDim2.new(0,0,0,26)
	bar.Size = UDim2.new(1,0,0,10)
	bar.BackgroundColor3 = Color3.fromRGB(40,40,40)
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
			local val = math.floor(min + (max-min)*pct)
			fill.Size = UDim2.new(pct,0,1,0)
			txt.Text = label..": "..val
			callback(val)
		end
	end)
end

---------------- MOVEMENT ----------------
local bv, bg
RunService.RenderStepped:Connect(function()
	if flyEnabled then
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

---------------- BUTTONS ----------------
button("Fly").MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	if flyEnabled then
		bv = Instance.new("BodyVelocity", root)
		bv.MaxForce = Vector3.new(1e5,1e5,1e5)
		bg = Instance.new("BodyGyro", root)
		bg.MaxTorque = Vector3.new(1e5,1e5,1e5)
	else
		if bv then bv:Destroy() end
		if bg then bg:Destroy() end
	end
end)

button("Noclip").MouseButton1Click:Connect(function()
	noclip = not noclip
end)

slider("Fly Speed", 5, 100, flySpeed, function(v) flySpeed = v end)
slider("WalkSpeed", 8, 100, humanoid.WalkSpeed, function(v) humanoid.WalkSpeed = v end)
slider("JumpPower", 20, 150, humanoid.JumpPower, function(v) humanoid.JumpPower = v end)

---------------- MENU TOGGLE ----------------
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
	end
end)

print("Hub loaded")
