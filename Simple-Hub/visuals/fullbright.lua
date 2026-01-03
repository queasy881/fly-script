-- visuals/fullbright.lua

local Lighting = game:GetService("Lighting")

local original = {
	Ambient = Lighting.Ambient,
	Brightness = Lighting.Brightness,
	OutdoorAmbient = Lighting.OutdoorAmbient
}

_G.Hub.Fullbright = false

function _G.Hub.ToggleFullbright(state)
	_G.Hub.Fullbright = state

	if state then
		Lighting.Ambient = Color3.new(1,1,1)
		Lighting.OutdoorAmbient = Color3.new(1,1,1)
		Lighting.Brightness = 2
	else
		for k,v in pairs(original) do
			Lighting[k] = v
		end
	end
end

