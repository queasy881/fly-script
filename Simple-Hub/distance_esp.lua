-- Distance ESP
local Players = game:GetService("Players")

local DistanceESP = {}
DistanceESP.enabled = false
DistanceESP.objects = {}

function DistanceESP.clear()
	for _, gui in ipairs(DistanceESP.objects) do
		gui:Destroy()
	end
	DistanceESP.objects = {}
end

function DistanceESP.enable(player, gui, root)
	DistanceESP.enabled = true
	DistanceESP.clear()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0, 100, 0, 22)
			bb.Adornee = plr.Character.Head
			bb.AlwaysOnTop = true

			local txt = Instance.new("TextLabel", bb)
			txt.Size = UDim2.fromScale(1, 1)
			txt.BackgroundTransparency = 1
			txt.TextColor3 = Color3.fromRGB(255, 255, 0)
			txt.Font = Enum.Font.GothamBold
			txt.TextSize = 13

			task.spawn(function()
				while DistanceESP.enabled and root and plr.Character do
					txt.Text = math.floor((plr.Character.Head.Position - root.Position).Magnitude) .. " studs"
					task.wait(0.2)
				end
			end)

			bb.Parent = gui
			table.insert(DistanceESP.objects, bb)
		end
	end
end

function DistanceESP.disable()
	DistanceESP.enabled = false
	DistanceESP.clear()
end

return DistanceESP
