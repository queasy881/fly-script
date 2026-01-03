-- visuals/fov_circle.lua

local RunService = game:GetService("RunService")
local camera = _G.Hub.Camera

local circle = Drawing.new("Circle")
circle.Visible = false
circle.Thickness = 2
circle.NumSides = 60
circle.Color = Color3.fromRGB(255,255,255)
circle.Filled = false
circle.Transparency = 0.8

_G.Hub.ShowFOV = false

function _G.Hub.ToggleFOVCircle(state)
	_G.Hub.ShowFOV = state
	circle.Visible = state
end

RunService.RenderStepped:Connect(function()
	if not _G.Hub.ShowFOV then return end

	circle.Position = Vector2.new(
		camera.ViewportSize.X / 2,
		camera.ViewportSize.Y / 2
	)

	circle.Radius = _G.Hub.AimFOV or 100
end)

