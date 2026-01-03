-- Chams
local Players = game:GetService("Players")

local Chams = {}
Chams.enabled = false
Chams.objects = {}
Chams.color = Color3.fromRGB(0, 255, 100)

function Chams.clear()
	for _, hl in ipairs(Chams.objects) do
		hl:Destroy()
	end
	Chams.objects = {}
end

function Chams.enable(player)
	Chams.enabled = true
	Chams.clear()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hl = Instance.new("Highlight")
			hl.FillColor = Chams.color
			hl.FillTransparency = 0.5
			hl.OutlineColor = Chams.color
			hl.OutlineTransparency = 0
			hl.Parent = plr.Character
			table.insert(Chams.objects, hl)
		end
	end
end

function Chams.disable()
	Chams.enabled = false
	Chams.clear()
end

return Chams

