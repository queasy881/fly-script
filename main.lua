-- SIMPLE HUB v3.4 – UI overflow fixed + Teleport keybind
-- Press M to toggle

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

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
local defaultFOV = camera.FieldOfView

local bv, bg
local nameESPObjects = {}
local boxESPObjects = {}

---------------- GUI ----------------
local gui = Instance.new("ScreenGui", player.PlayerGui)
gui.ResetOnSpawn = false

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 760, 0, 380)
main.Position = UDim2.fromScale(0.5, 0.5)
main.AnchorPoint = Vector2.new(0.5, 0.5)
main.BackgroundColor3 = Color3.fromRGB(14,14,14)
main.Visible = false
main.ClipsDescendants = true
Instance.new("UICorner", main).CornerRadius = UDim.new(0,16)

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
	b.Text = text
	Instance.new("UICorner", b)
	return b
end

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
			local val = math.floor(min + (max-min)*pct)
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

print("Simple Hub v3.4 loaded")
