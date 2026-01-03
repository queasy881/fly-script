-- movement/bunnyhop.lua

local BunnyHop = {}

BunnyHop.enabled = false
BunnyHop.delay = 0.2
local lastHop = 0

function BunnyHop.update(humanoid)
	if not BunnyHop.enabled then return end
	if tick() - lastHop >= BunnyHop.delay then
		if humanoid.FloorMaterial ~= Enum.Material.Air then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			lastHop = tick()
		end
	end
end

return BunnyHop

