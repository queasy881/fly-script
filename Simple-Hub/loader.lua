-- SIMPLE HUB v3.7 Loader
-- This is the ONLY file users execute with loadstring

local BASE_URL = "https://raw.githubusercontent.com/queasy881/fly-script/main/"

local function load(file)
	return loadstring(game:HttpGet(BASE_URL .. file, true))()
end

-- Basic exploit safety check
if not game:IsLoaded() then
	game.Loaded:Wait()
end

-- Prevent double execution
if _G.SIMPLE_HUB_LOADED then
	warn("Simple Hub already loaded")
	return
end
_G.SIMPLE_HUB_LOADED = true

-- Load main client
load("main.client.lua")

