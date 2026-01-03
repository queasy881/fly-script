-- extra/invisibility.lua

local Invisibility = {}

Invisibility.enabled = false
Invisibility.amount = 1

function Invisibility.apply(character)
	if not character then return end
	for _, v in ipairs(character:GetDescendants()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.Transparency = Invisibility.enabled and Invisibility.amount or 0
		elseif v:IsA("Decal") then
			v.Transparency = Invisibility.enabled and Invisibility.amount or 0
		end
	end
end

return Invisibility

