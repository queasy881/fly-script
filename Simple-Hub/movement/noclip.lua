-- movement/noclip.lua

local Noclip = {}

Noclip.enabled = false

function Noclip.update(character)
	if not Noclip.enabled then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = false
		end
	end
end

return Noclip
