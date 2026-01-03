-- loader.lua (CORRECT, SAFE, FINAL)

local BASE =
    "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

local Loader = {}
local cache = {}

function Loader.load(path)
    if cache[path] then
        return cache[path]
    end

    print("[LOADING]", path)

    local src = game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
    local fn, err = loadstring(src)

    assert(fn, "Loadstring failed for " .. path .. ": " .. tostring(err))

    local result = fn(Loader)
    cache[path] = result
    return result
end


Loader.load("main.client.lua")


return Loader
