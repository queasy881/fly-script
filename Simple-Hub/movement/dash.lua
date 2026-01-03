-- movement/dash.lua

local Dash = {}

Dash.enabled = false
Dash.distance = 50
Dash.cooldown = 2
local lastDash = 0

function Dash.tryDash(root, camera)
	if not Dash.enabled then return end
	if tick() - lastDash < Dash.cooldown then return end

	lastDash = tick()
	local bv = Instance.new("BodyVelocity")
	bv.Velocity = camera.CFrame.LookVector * Dash.distance
	bv.MaxForce = Vector3.new(1e5, 0, 1e5)
	bv.Parent = root

	game:GetService("Debris"):AddItem(bv, 0.2)
end

return Dash

