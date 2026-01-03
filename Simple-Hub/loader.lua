-- Simple Hub Loader
-- This is the ONLY file you load with loadstring()

if _G.SimpleHubLoaded then
	warn("Simple Hub already loaded")
	return
end
_G.SimpleHubLoaded = true

-- Enable HTTP
pcall(function()
	game:GetService("HttpService")
end)

-- Load helpers FIRST
local Helpers = loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/utils/helpers.lua"
))()

-- Expose requireRemote globally
_G.requireRemote = Helpers.requireRemote
_G.SimpleHubHelpers = Helpers

-- Sanity check
assert(type(_G.requireRemote) == "function", "requireRemote failed to load")

-- Load main client
loadstring(game:HttpGet(
	"https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/main.client.lua"
))()
