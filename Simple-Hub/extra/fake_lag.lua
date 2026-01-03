-- extra/fake_lag.lua

local FakeLag = {}

FakeLag.enabled = false
FakeLag.interval = 1
local lastLag = 0

function FakeLag.update(root)
	if not FakeLag.enabled then return end
	if tick() - lastLag < FakeLag.interval then return end

	lastLag = tick()
	local cf = root.CFrame
	root.Anchored = true
	task.wait(0.1)
	root.Anchored = false
	root.CFrame = cf
end

return FakeLag

