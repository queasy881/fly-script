-- utils/helpers.lua
-- General helpers: player/character helpers, safe-finds, debounce, table utils.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Helpers = {}

-- ========================
-- PLAYER / CHARACTER
-- ========================

function Helpers.getLocalPlayer()
	return Players.LocalPlayer
end

function Helpers.waitForCharacter(player)
	player = player or Players.LocalPlayer
	if not player then return nil end

	local char = player.Character
	if char and char.Parent then
		return char
	end

	return player.CharacterAdded:Wait()
end

function Helpers.getHumanoid(player)
	local char = Helpers.waitForCharacter(player)
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end

function Helpers.getRoot(player)
	local char = Helpers.waitForCharacter(player)
	if not char then return nil end
	return char:FindFirstChild("HumanoidRootPart")
		or char:WaitForChild("HumanoidRootPart")
end

function Helpers.isAlive(player)
	local humanoid = Helpers.getHumanoid(player)
	return humanoid and humanoid.Health > 0
end

function Helpers.getOtherPlayers()
	local localP = Players.LocalPlayer
	local out = {}

	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= localP then
			table.insert(out, p)
		end
	end

	return out
end

function Helpers.forEachOtherPlayer(cb)
	for _, p in ipairs(Helpers.getOtherPlayers()) do
		task.spawn(cb, p)
	end
end

-- ========================
-- SAFE FINDS / UTILS
-- ========================

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
	end

	return nil
end

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

function Helpers.shallowCopy(t)
	if type(t) ~= "table" then return t end
	local out = {}
	for k, v in pairs(t) do
		out[k] = v
	end
	return out
end

function Helpers.mergeTables(t1, t2)
	if type(t1) ~= "table" or type(t2) ~= "table" then
		return t1
	end

	for k, v in pairs(t2) do
		t1[k] = v
	end

	return t1
end

function Helpers.safeSpawn(fn, ...)
	task.spawn(function(...)
		local ok, err = pcall(fn, ...)
		if not ok then
			warn("Helpers.safeSpawn error:", err)
		end
	end, ...)
end

-- ========================
-- REMOTE REQUIRE (LOADSTRING)
-- ========================

function Helpers.requireRemote(path)
	local url =
		"https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"
		.. path
		.. "?nocache="
		.. tostring(os.clock())

	local source = game:HttpGet(url)
	local fn = loadstring(source)

	if not fn then
		error("Failed to load remote module: " .. path)
	end

	return fn()
end

return Helpers
