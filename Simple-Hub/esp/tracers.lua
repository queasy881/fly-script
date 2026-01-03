-- Tracers
local Players = game:GetService("Players")

local Tracers = {}
Tracers.enabled = false
Tracers.objects = {}
Tracers.color = Color3.fromRGB(255, 255, 0)

function Tracers.clear()
	for _, v in ipairs(Tracers.objects) do
		v:Destroy()
	end
	Tracers.objects = {}
end

function Tracers.enable(player, camera)
	Tracers.enabled = true
	Tracers.clear()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local a0 = Instance.new("Attachment", workspace.Terrain)
			local a1 = Instance.new("Attachment", plr.Character.HumanoidRootPart)

			local beam = Instance.new("Beam")
			beam.Attachment0 = a0
			beam.Attachment1 = a1
			beam.Color = ColorSequence.new(Tracers.color)
			beam.Width0 = 0.1
			beam.Width1 = 0.1
			beam.FaceCamera = true
			beam.Parent = workspace.Terrain

			table.insert(Tracers.objects, beam)
			table.insert(Tracers.objects, a0)
		end
	end
end

function Tracers.disable()
	Tracers.enabled = false
	Tracers.clear()
end

return Tracers

