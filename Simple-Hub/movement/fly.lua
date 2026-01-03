-- movement/fly.lua

local Fly = {}

Fly.enabled = false
Fly.speed = 23

local bv, bg

function Fly.enable(root, camera)
	if Fly.enabled then return end
	Fly.enabled = true

	bv = Instance.new("BodyVelocity")
	bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
	bv.Parent = root

	bg = Instance.new("BodyGyro")
	bg.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
	bg.Parent = root
end

function Fly.disable()
	Fly.enabled = false
	if bv then bv:Destroy() bv = nil end
	if bg then bg:Destroy() bg = nil end
end

function Fly.update(root, camera, UIS)
	if not Fly.enabled or not bv or not bg then return end

	local move = Vector3.zero
	if UIS:IsKeyDown(Enum.KeyCode.W) then move += camera.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.S) then move -= camera.CFrame.LookVector end
	if UIS:IsKeyDown(Enum.KeyCode.A) then move -= camera.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.D) then move += camera.CFrame.RightVector end
	if UIS:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
	if UIS:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

	bv.Velocity = move.Magnitude > 0 and move.Unit * Fly.speed or Vector3.zero
	bg.CFrame = camera.CFrame
end

return Fly

