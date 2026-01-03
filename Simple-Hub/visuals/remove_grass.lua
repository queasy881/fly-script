-- visuals/remove_grass.lua

local Terrain = workspace:FindFirstChildOfClass("Terrain")

_G.Hub.RemoveGrass = false

function _G.Hub.ToggleGrass(state)
	_G.Hub.RemoveGrass = state

	if Terrain then
		Terrain.Decoration = not state
	end

	for _,obj in ipairs(workspace:GetDescendants()) do
		if obj:IsA("BasePart") then
			local n = obj.Name:lower()
			if n:find("grass") or n:find("foliage") or n:find("bush") then
				obj.Transparency = state and 1 or 0
			end
		end
	end
end

