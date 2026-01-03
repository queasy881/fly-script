-- movement/jumppower.lua

local JumpPower = {}

JumpPower.enabled = false
JumpPower.value = 50

function JumpPower.apply(humanoid)
	if JumpPower.enabled then
		humanoid.JumpPower = JumpPower.value
	else
		humanoid.JumpPower = 50
	end
end

return JumpPower

