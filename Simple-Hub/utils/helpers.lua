-- utils/helpers.lua
-- General helpers: player/character helpers, safe-finds, debounce, table utils.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Helpers = {}

-- Remote loader
function Helpers.requireRemote(path)
    local url =
        "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/" .. path
    local source = game:HttpGet(url)
    local fn, err = loadstring(source)
    if not fn then
        error("Loadstring failed for " .. path .. ": " .. tostring(err))
    end
    return fn()
end

-- Returns the LocalPlayer
function Helpers.getLocalPlayer()
    return Players.LocalPlayer
end

-- Waits for and returns character
function Helpers.waitForCharacter(player)
    player = player or Players.LocalPlayer
    if not player then return nil end
    if player.Character and player.Character.Parent then
        return player.Character
    end
    return player.CharacterAdded:Wait()
end

-- Returns humanoid
function Helpers.getHumanoid(player)
    local char = Helpers.waitForCharacter(player)
    return char and char:FindFirstChildOfClass("Humanoid")
end

-- Returns HumanoidRootPart
function Helpers.getRoot(player)
    local char = Helpers.waitForCharacter(player)
    return char and (char:FindFirstChild("HumanoidRootPart") or char:WaitForChild("HumanoidRootPart"))
end

-- Alive check
function Helpers.isAlive(player)
    local hum = Helpers.getHumanoid(player)
    return hum and hum.Health > 0
end

-- Other players
function Helpers.getOtherPlayers()
    local localP = Players.LocalPlayer
    local t = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= localP then
            table.insert(t, p)
        end
    end
    return t
end

-- Safe spawn
function Helpers.safeSpawn(fn, ...)
    task.spawn(function(...)
        local ok, err = pcall(fn, ...)
        if not ok then
            warn("[Helpers.safeSpawn]", err)
        end
    end, ...)
end

-- Debounce wrapper
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

-- Table helpers
function Helpers.shallowCopy(t)
    local o = {}
    for k, v in pairs(t) do o[k] = v end
    return o
end

function Helpers.mergeTables(a, b)
    for k, v in pairs(b) do a[k] = v end
    return a
end

return Helpers
