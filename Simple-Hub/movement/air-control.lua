-- movement/aircontrol.lua

local AirControl = {}

AirControl.strength = 0

function AirControl.update(root, humanoid, camera, UIS)
	if AirControl.strength <= 0 then return end
	if humanoid.FloorMaterial ~= Enum.Material.Air then return end

	local move = Vector3.zero
	if UIS:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end

	if move.Magnitude > 0 then
		local bv = Instance.new("BodyVelocity")
		bv.Velocity = move.Unit * AirControl.strength * 50
		bv.MaxForce = Vector3.new(1e4, 0, 1e4)
		bv.Parent = root
		game:GetService("Debris"):AddItem(bv, 0.1)
	end
end

return AirControl
