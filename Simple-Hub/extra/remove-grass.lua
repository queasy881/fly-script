-- extra/remove_grass.lua

local RemoveGrass = {}

RemoveGrass.enabled = false

function RemoveGrass.apply()
	local terrain = workspace:FindFirstChildOfClass("Terrain")
	if terrain then
		terrain.Decoration = not RemoveGrass.enabled
	end

	for _, obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") or obj:IsA("MeshPart") then
			local n = obj.Name:lower()
			if n:find("grass") or n:find("foliage") or n:find("bush") then
				obj.Transparency = RemoveGrass.enabled and 1 or 0
			end
		end
	end
end

return RemoveGrass
