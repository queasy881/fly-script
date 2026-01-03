-- visuals/third_person.lua

local player = _G.Hub.Player

_G.Hub.ThirdPerson = false

function _G.Hub.ToggleThirdPerson(state)
	_G.Hub.ThirdPerson = state

	if state then
		player.CameraMinZoomDistance = 15
		player.CameraMaxZoomDistance = 100
	else
		player.CameraMinZoomDistance = 0.5
		player.CameraMaxZoomDistance = 128
	end
end

