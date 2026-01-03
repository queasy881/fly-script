-- Aim Assist (Legit Aim)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local AimAssist = {
	enabled = false,
	fov = 100,
	smoothness = 0.5,
	teamCheck = true,
	visibilityCheck = true,
	keybind = "RMB",
	bone = "Head"
}

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local function isKeyDown()
	if AimAssist.keybind == "RMB" then
		return UIS:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)
	elseif AimAssist.keybind == "Shift" then
		return UIS:IsKeyDown(Enum.KeyCode.LeftShift)
	end
	return false
end

local function getTarget()
	local closest, dist = nil, math.huge
	local center = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y/2)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hum = plr.Character:FindFirstChild("Humanoid")
			local head = plr.Character:FindFirstChild("Head")
			if hum and hum.Health > 0 and head then
				if AimAssist.teamCheck and plr.Team == player.Team then continue end

				local pos, onScreen = camera:WorldToViewportPoint(head.Position)
				if onScreen then
					local mag = (Vector2.new(pos.X,pos.Y) - center).Magnitude
					if mag < AimAssist.fov and mag < dist then
						dist = mag
						closest = plr
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
	if not target or not target.Character then return end

	local part =
		AimAssist.bone == "Head" and target.Character:FindFirstChild("Head")
		or target.Character:FindFirstChild("UpperTorso")
		or target.Character:FindFirstChild("Torso")

	if part then
		local cf = CFrame.new(camera.CFrame.Position, part.Position)
		camera.CFrame = camera.CFrame:Lerp(cf, AimAssist.smoothness)
	end
end)

return AimAssist

