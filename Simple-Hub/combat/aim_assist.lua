-- Aim Assist (FIXED)

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AimAssist = {
	enabled = false,
	fov = 150,
	smoothness = 0.15, -- lower = stronger
	keybind = "RMB",
	bone = "Head"
}

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function isKeyDown()
	return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
end

local function getTarget()
	local closest, dist = nil, math.huge
	local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local head = plr.Character:FindFirstChild("Head")
			if hum and hum.Health > 0 and head then
				local pos, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude
					if mag < AimAssist.fov and mag < dist then
						dist = mag
						closest = head
					end
				end
			end
		end
	end
	return closest
end

RunService.RenderStepped:Connect(function()
	if not AimAssist.enabled or not isKeyDown() then return end

	local target = getTarget()
	if not target then return end

	local cf = CFrame.new(camera.CFrame.Position, target.Position)
	camera.CFrame = camera.CFrame:Lerp(cf, AimAssist.smoothness)
end)

return AimAssist
