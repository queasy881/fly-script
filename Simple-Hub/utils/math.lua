-- utils/helpers.lua
-- General helpers: player/character helpers, safe-finds, debounce, table utils.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Helpers = {}

-- Returns the LocalPlayer
function Helpers.getLocalPlayer()
	return Players.LocalPlayer
end

-- Waits for and returns a character for the given player (or LocalPlayer)
function Helpers.waitForCharacter(player)
	player = player or Players.LocalPlayer
	if not player then return nil end
	local char = player.Character
	if char and char.Parent then return char end
	return player.CharacterAdded:Wait()
end

-- Returns humanoid (or nil)
function Helpers.getHumanoid(player)
	local char = Helpers.waitForCharacter(player)
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

-- Returns HumanoidRootPart (or waits for it)
function Helpers.getRoot(player)
	local char = Helpers.waitForCharacter(player)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart")
end

-- Is player alive?
function Helpers.isAlive(player)
	local humanoid = Helpers.getHumanoid(player)
	return humanoid and humanoid.Health and humanoid.Health > 0
end

-- Return array of other players (excluding local)
function Helpers.getOtherPlayers()
	local localP = Players.LocalPlayer
	local out = {}
	for _,p in ipairs(Players:GetPlayers()) do
		if p ~= localP then
			table.insert(out, p)
		end
	end
	return out
end

-- Iterate other players with callback(plr)
function Helpers.forEachOtherPlayer(cb)
	for _,p in ipairs(Helpers.getOtherPlayers()) do
		task.spawn(cb, p)
	end
end

-- Safe FindFirstChild with timeout (seconds). Returns object or nil.
function Helpers.safeFindFirstChild(parent, name, timeout)
	if not parent then return nil end
	local found = parent:FindFirstChild(name)
	if found then return found end
	if timeout and timeout > 0 then
		local start = tick()
		repeat
			found = parent:FindFirstChild(name)
			if found then return found end
			RunService.Heartbeat:Wait()
		until tick() - start >= timeout
		return nil
	end
	return nil
end

-- Simple debounce wrapper: returns a function that only runs fn once per `delay` seconds
function Helpers.debounceWrap(fn, delay)
	delay = delay or 0.2
	local last = 0
	return function(...)
		local now = tick()
		if now - last >= delay then
			last = now
			return fn(...)
		end
	end
end

-- Returns shallow copy of table
function Helpers.shallowCopy(t)
	if type(t) ~= "table" then return t end
	local out = {}
	for k,v in pairs(t) do out[k] = v end
	return out
end

-- Merge t2 into t1 (shallow), returns t1
function Helpers.mergeTables(t1, t2)
	if type(t1) ~= "table" or type(t2) ~= "table" then return t1 end
	for k,v in pairs(t2) do t1[k] = v end
	return t1
end

-- Safe task spawn (avoids erroring whole thread)
function Helpers.safeSpawn(fn, ...)
	task.spawn(function()
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("Helpers.safeSpawn error:", err)
		end
	end)
end

return Helpers

