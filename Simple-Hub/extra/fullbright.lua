-- extra/fullbright.lua

local Lighting = game:GetService("Lighting")
local Fullbright = {}

Fullbright.enabled = false
local original = {}

function Fullbright.toggle()
	if Fullbright.enabled then
		original.Ambient = Lighting.Ambient
		original.Brightness = Lighting.Brightness
		original.OutdoorAmbient = Lighting.OutdoorAmbient

		Lighting.Ambient = Color3.new(1,1,1)
		Lighting.Brightness = 2
		Lighting.OutdoorAmbient = Color3.new(1,1,1)
	else
		if original.Ambient then
			Lighting.Ambient = original.Ambient
			Lighting.Brightness = original.Brightness
			Lighting.OutdoorAmbient = original.OutdoorAmbient
		end
	end
end

return Fullbright
