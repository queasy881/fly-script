-- settings/presets.lua

local Presets = {}

Presets.Data = {
	Legit = {},
	Rage = {},
	Movement = {},
	Visual = {}
}

function Presets.save(name, state)
	if not Presets.Data[name] then return end
	Presets.Data[name] = table.clone(state)
end

function Presets.load(name)
	return Presets.Data[name]
end

return Presets

