-- extra/teleport.lua

local Teleport = {}

Teleport.enabled = false

function Teleport.toCursor(root, mouse)
	if not Teleport.enabled then return end
	if mouse.Hit and root then
		root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
	end
end

return Teleport

