-- movement/walkspeed.lua

local WalkSpeed = {}

WalkSpeed.enabled = false
WalkSpeed.value = 16

function WalkSpeed.apply(humanoid)
	if WalkSpeed.enabled then
		humanoid.WalkSpeed = WalkSpeed.value
	else
		humanoid.WalkSpeed = 16
	end
end

return WalkSpeed

