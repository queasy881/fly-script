-- extra/walk_on_water.lua

local WalkOnWater = {}

WalkOnWater.enabled = false
local platform

function WalkOnWater.update(root)
	if not WalkOnWater.enabled then
		if platform then platform:Destroy() platform = nil end
		return
	end

	if not platform then
		platform = Instance.new("Part", workspace)
		platform.Size = Vector3.new(20,1,20)
		platform.Anchored = true
		platform.CanCollide = true
		platform.Transparency = 0.8
		platform.Material = Enum.Material.Ice
	end

	platform.CFrame = CFrame.new(root.Position.X, root.Position.Y - 3.5, root.Position.Z)
end

return WalkOnWater
