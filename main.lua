-- Roblox Flight Script with Toggle
-- Speed: 23 studs per second
-- Toggle Key: F

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

local SPEED = 23
local flying = false

-- Body movers
local bodyVelocity = Instance.new("BodyVelocity")
bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)

local bodyGyro = Instance.new("BodyGyro")
bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
bodyGyro.P = 1e4

-- Input tracking
local input = {
	W = false,
	A = false,
	S = false,
	D = false,
	Up = false,
	Down = false
}

-- Toggle flight
local function toggleFlight()
	flying = not flying

	if flying then
		humanoid:ChangeState(Enum.HumanoidStateType.Physics)
		bodyVelocity.Velocity = Vector3.zero
		bodyVelocity.Parent = root
		bodyGyro.CFrame = root.CFrame
		bodyGyro.Parent = root
	else
		bodyVelocity.Parent = nil
		bodyGyro.Parent = nil
		humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
	end
end

UserInputService.InputBegan:Connect(function(key, gp)
	if gp then return end

	if key.KeyCode == Enum.KeyCode.F then
		toggleFlight()
	end

	if key.KeyCode == Enum.KeyCode.W then input.W = true end
	if key.KeyCode == Enum.KeyCode.A then input.A = true end
	if key.KeyCode == Enum.KeyCode.S then input.S = true end
	if key.KeyCode == Enum.KeyCode.D then input.D = true end
	if key.KeyCode == Enum.KeyCode.Space then input.Up = true end
	if key.KeyCode == Enum.KeyCode.LeftShift then input.Down = true end
end)

UserInputService.InputEnded:Connect(function(key)
	if key.KeyCode == Enum.KeyCode.W then input.W = false end
	if key.KeyCode == Enum.KeyCode.A then input.A = false end
	if key.KeyCode == Enum.KeyCode.S then input.S = false end
	if key.KeyCode == Enum.KeyCode.D then input.D = false end
	if key.KeyCode == Enum.KeyCode.Space then input.Up = false end
	if key.KeyCode == Enum.KeyCode.LeftShift then input.Down = false end
end)

-- Flight movement loop
RunService.RenderStepped:Connect(function()
	if not flying then return end

	local cam = workspace.CurrentCamera
	local moveVector = Vector3.zero

	if input.W then moveVector += cam.CFrame.LookVector end
	if input.S then moveVector -= cam.CFrame.LookVector end
	if input.A then moveVector -= cam.CFrame.RightVector end
	if input.D then moveVector += cam.CFrame.RightVector end
	if input.Up then moveVector += Vector3.new(0, 1, 0) end
	if input.Down then moveVector -= Vector3.new(0, 1, 0) end

	if moveVector.Magnitude > 0 then
		moveVector = moveVector.Unit * SPEED
	end

	bodyVelocity.Velocity = moveVector
	bodyGyro.CFrame = cam.CFrame
end)
