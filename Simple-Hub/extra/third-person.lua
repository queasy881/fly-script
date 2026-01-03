-- extra/third_person.lua

local ThirdPerson = {}

ThirdPerson.enabled = false

function ThirdPerson.apply(player)
	if ThirdPerson.enabled then
		player.CameraMaxZoomDistance = 100
		player.CameraMinZoomDistance = 15
	else
		player.CameraMaxZoomDistance = 128
		player.CameraMinZoomDistance = 0.5
	end
end

return ThirdPerson
