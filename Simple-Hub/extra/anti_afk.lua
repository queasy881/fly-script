-- extra/anti_afk.lua

local AntiAFK = {}

AntiAFK.enabled = false
local afkTime = 0

function AntiAFK.update(dt)
	if not AntiAFK.enabled then return end
	afkTime += dt

	if afkTime >= 15 then
		afkTime = 0
		local vu = game:GetService("VirtualUser")
		vu:CaptureController()
		vu:ClickButton2(Vector2.new())
	end
end

return AntiAFK

