-- Simple Hub Menu (M to toggle)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart")
local humanoid = character:WaitForChild("Humanoid")

------------------------------------------------
-- GUI
------------------------------------------------

local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.35, 0.45)
main.Position = UDim2.fromScale(0.325, 0.275)
main.BackgroundColor3 = Color3.fromRGB(15,15,15)
main.Visible = false

Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

local layout = Instance.new("UIListLayout", main)
layout.Padding = UDim.new(0,8)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

------------------------------------------------
-- Toggle Menu
------------------------------------------------

UIS.InputBegan:Connect(function(i,gp)
	if gp then return end
	if i.KeyCode == Enum.KeyCode.M then
		main.Visible = not main.Visible
	end
end)

------------------------------------------------
-- Button creator
------------------------------------------------

local function makeButton(text)
	local b = Instance.new("TextButton")
	b.Size = UDim2.fromScale(0.9,0.08)
	b.BackgroundColor3 = Color3.fromRGB(25,25,25)
	b.TextColor3 = Color3.new(1,1,1)
	b.Font = Enum.Font.Gotham
	b.TextSize = 14
	b.Text = text
	b.Parent = main
	Instance.new("UICorner", b)
	return b
end

------------------------------------------------
-- ESP (Names)
------------------------------------------------

local espOn = false
local espObjects = {}

local function toggleESP()
	espOn = not espOn

	if not espOn then
		for _,v in pairs(espObjects) do v:Destroy() end
		espObjects = {}
		return
	end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0,100,0,30)
			bb.AlwaysOnTop = true
			bb.Adornee = plr.Character.Head

			local txt = Instance.new("TextLabel", bb)
			txt.Size = UDim2.fromScale(1,1)
			txt.BackgroundTransparency = 1
			txt.TextColor3 = Color3.new(1,1,1)
			txt.TextStrokeTransparency = 0
			txt.Text = plr.Name

			bb.Parent = gui
			table.insert(espObjects, bb)
		end
	end
end

------------------------------------------------
-- Chams (Highlight)
------------------------------------------------

local chamsOn = false
local highlights = {}

local function toggleChams()
	chamsOn = not chamsOn

	if not chamsOn then
		for _,h in pairs(highlights) do h:Destroy() end
		highlights = {}
		return
	end

	for _,plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hl = Instance.new("Highlight")
			hl.FillColor = Color3.fromRGB(255,0,0)
			hl.OutlineColor = Color3.new(1,1,1)
			hl.Parent = plr.Character
			table.insert(highlights, hl)
		end
	end
end

------------------------------------------------
-- Noclip
------------------------------------------------

local noclip = false

RunService.Stepped:Connect(function()
	if noclip and character then
		for _,p in pairs(character:GetDescendants()) do
			if p:IsA("BasePart") then
				p.CanCollide = false
			end
		end
	end
end)

------------------------------------------------
-- Fly
------------------------------------------------

local fly = false
local flySpeed = 23
local bv, bg

local function toggleFly()
	fly = not fly

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

------------------------------------------------
-- Buttons
------------------------------------------------

makeButton("Toggle Name ESP").MouseButton1Click:Connect(toggleESP)
makeButton("Toggle Chams").MouseButton1Click:Connect(toggleChams)
makeButton("Toggle Noclip").MouseButton1Click:Connect(function()
	noclip = not noclip
end)
makeButton("Toggle Fly").MouseButton1Click:Connect(toggleFly)
makeButton("Fly Speed +5").MouseButton1Click:Connect(function()
	flySpeed += 5
end)
makeButton("Fly Speed -5").MouseButton1Click:Connect(function()
	flySpeed = math.max(5, flySpeed - 5)
end)
