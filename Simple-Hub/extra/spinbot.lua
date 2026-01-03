-- extra/spinbot.lua

local SpinBot = {}

SpinBot.enabled = false
SpinBot.speed = 5
local angle = 0

function SpinBot.update(root, dt)
	if not SpinBot.enabled or not root then return end
	angle += dt * SpinBot.speed * 10
	if angle > 360 then angle = 0 end
	root.CFrame = CFrame.new(root.Position) * CFrame.Angles(0, math.rad(angle), 0)
end

return SpinBot

