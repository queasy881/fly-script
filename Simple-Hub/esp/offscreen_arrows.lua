-- Offscreen Arrows (placeholder logic, safe)
local Offscreen = {}
Offscreen.enabled = false

function Offscreen.enable()
	Offscreen.enabled = true
end

function Offscreen.disable()
	Offscreen.enabled = false
end

return Offscreen
