-- SIMPLE HUB v2 (Fixed UI + Missing Features)
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
local flyEnabled = false
local noclip = false
local walkEnabled = false
local jumpEnabled = false
local espEnabled = false

local flySpeed = 23
local walkSpeed = humanoid.WalkSpeed
local jumpPower = humanoid.JumpPower

local bv, bg
local espObjects = {}

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 420, 0, 460)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(12,12,12)
main.Visible = false
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

local pad = Instance.new("UIPadding", main)
pad.PaddingTop = UDim.new(0,14)
pad.PaddingLeft = UDim.new(0,14)
pad.PaddingRight = UDim.new(0,14)

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,10)

---------------- HELPERS ----------------
local function section(text)
	local lbl = Instance.new("TextLabel", main)
	lbl.Size = UDim2.new(1,0,0,24)
	lbl.BackgroundTransparency = 1
	lbl.Text = text
	lbl.Font = Enum.Font.GothamBold
	lbl.TextSize = 14
	lbl.TextXAlignment = Left
	lbl.TextColor3 = Color3.fromRGB(200,200,200)
end

local function button(text)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1,0,0,34)
	b.BackgroundColor3 = Color3.fromRGB(30,30,30)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text .. ": OFF"
	Instance.new("UICorner", b)
	return b
end

local function slider(label, min, max, value, callback)
	local frame = Instance.new("Frame", main)
	frame.Size = UDim2.new(1,0,0,50)
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
			local val = math.floor(min + (max-min)*pct)
			fill.Size = UDim2.new(pct,0,1,0)
			txt.Text = label .. ": " .. val
			callback(val)
		end
	end)
end

---------------- MOVEMENT ----------------
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

---------------- ESP ----------------
local function toggleESP(btn)
	espEnabled = not espEnabled
	btn.Text = "Name ESP: " .. (espEnabled and "ON" or "OFF")

	for _,v in pairs(espObjects) do v:Destroy() end
	espObjects = {}

	if not espEnabled then return end

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
			table.insert(espObjects, bb)
		end
	end
end

---------------- UI BUILD ----------------
section("Movement")

local flyBtn = button("Fly")
flyBtn.MouseButton1Click:Connect(function()
	flyEnabled = not flyEnabled
	flyBtn.Text = "Fly: " .. (flyEnabled and "ON" or "OFF")
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

local noclipBtn = button("Noclip")
noclipBtn.MouseButton1Click:Connect(function()
	noclip = not noclip
	noclipBtn.Text = "Noclip: " .. (noclip and "ON" or "OFF")
end)

slider("Fly Speed", 5, 100, flySpeed, function(v) flySpeed = v end)

local walkBtn = button("WalkSpeed")
walkBtn.MouseButton1Click:Connect(function()
	walkEnabled = not walkEnabled
	humanoid.WalkSpeed = walkEnabled and walkSpeed or 16
	walkBtn.Text = "WalkSpeed: " .. (walkEnabled and "ON" or "OFF")
end)

slider("WalkSpeed Value", 8, 100, walkSpeed, function(v)
	walkSpeed = v
	if walkEnabled then humanoid.WalkSpeed = v end
end)

local jumpBtn = button("JumpPower")
jumpBtn.MouseButton1Click:Connect(function()
	jumpEnabled = not jumpEnabled
	humanoid.JumpPower = jumpEnabled and jumpPower or 50
	jumpBtn.Text = "JumpPower: " .. (jumpEnabled and "ON" or "OFF")
end)

slider("JumpPower Value", 20, 150, jumpPower, function(v)
	jumpPower = v
	if jumpEnabled then humanoid.JumpPower = v end
end)

section("ESP")

local espBtn = button("Name ESP")
espBtn.MouseButton1Click:Connect(function()
	toggleESP(espBtn)
end)

---------------- MENU TOGGLE ----------------
UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
	end
end)

print("Simple Hub v2 loaded")
