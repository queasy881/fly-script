-- Simple Hub Loader (ONLY entry point)

local url = "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/main.client.lua"

local source = game:HttpGet(url)
assert(type(source) == "string", "Failed to fetch main.client.lua")

local fn, err = loadstring(source)
assert(fn, err)

return fn()
