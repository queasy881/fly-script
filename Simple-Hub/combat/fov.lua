-- FOV Circle
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera

local FOV = {
	enabled = false,
	radius = 100,
	circle = nil
}

function FOV.create()
	if FOV.circle then return end
	local c = Drawing.new("Circle")
	c.NumSides = 64
	c.Thickness = 2
	c.Transparency = 0.8
	c.Color = Color3.fromRGB(255,255,255)
	c.Filled = false
	FOV.circle = c
end

RunService.RenderStepped:Connect(function()
	if not FOV.circle then return end
	FOV.circle.Visible = FOV.enabled
	FOV.circle.Radius = FOV.radius
	FOV.circle.Position = Vector2.new(
		camera.ViewportSize.X/2,
		camera.ViewportSize.Y/2
	)
end)

return FOV

