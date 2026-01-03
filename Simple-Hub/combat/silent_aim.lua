-- Silent Aim (logic container – hook handled by executor)
local SilentAim = {
	enabled = false,
	fov = 150,
	hitChance = 100
}

-- NOTE:
-- This file intentionally does NOT hook __namecall.
-- Executors handle that externally.
-- This module only stores state used by hooks.

function SilentAim.shouldHit()
	return math.random(1,100) <= SilentAim.hitChance
end

return SilentAim

