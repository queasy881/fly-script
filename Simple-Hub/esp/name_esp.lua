-- Name ESP
local Players = game:GetService("Players")

local NameESP = {}
NameESP.enabled = false
NameESP.objects = {}

function NameESP.clear()
	for _, gui in ipairs(NameESP.objects) do
		gui:Destroy()
	end
	NameESP.objects = {}
end

function NameESP.enable(player, gui)
	NameESP.enabled = true
	NameESP.clear()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Head") then
			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0, 100, 0, 24)
			bb.AlwaysOnTop = true
			bb.Adornee = plr.Character.Head

			local label = Instance.new("TextLabel", bb)
			label.Size = UDim2.fromScale(1, 1)
			label.BackgroundTransparency = 1
			label.Text = plr.Name
			label.TextColor3 = Color3.new(1, 1, 1)
			label.TextStrokeTransparency = 0
			label.Font = Enum.Font.GothamBold
			label.TextSize = 13

			bb.Parent = gui
			table.insert(NameESP.objects, bb)
		end
	end
end

function NameESP.disable()
	NameESP.enabled = false
	NameESP.clear()
end

return NameESP

