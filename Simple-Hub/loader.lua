-- Simple Hub Loader
-- Single entry point (use this in loadstring)

local BASE_URL = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local function loadFile(path)
    local success, result = pcall(function()
        return game:HttpGet(BASE_URL .. path)
    end)

    if not success then
        warn("[Simple Hub] Failed to load:", path)
        return nil
    end

    return result
end

-- Load main client
local mainSource = loadFile("main.client.lua")
if not mainSource then
    error("[Simple Hub] main.client.lua could not be loaded")
end

-- Execute main
local mainFunc = loadstring(mainSource)
mainFunc()
