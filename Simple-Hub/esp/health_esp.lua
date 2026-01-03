-- Health Bar ESP
local Players = game:GetService("Players")

local HealthESP = {}
HealthESP.enabled = false
HealthESP.objects = {}

function HealthESP.clear()
	for _, gui in ipairs(HealthESP.objects) do
		gui:Destroy()
	end
	HealthESP.objects = {}
end

function HealthESP.enable(player, gui)
	HealthESP.enabled = true
	HealthESP.clear()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character:FindFirstChild("Head") then
			local hum = plr.Character.Humanoid

			local bb = Instance.new("BillboardGui")
			bb.Size = UDim2.new(0, 6, 0, 40)
			bb.Adornee = plr.Character.Head
			bb.StudsOffset = Vector3.new(-2, 0, 0)
			bb.AlwaysOnTop = true

			local bg = Instance.new("Frame", bb)
			bg.Size = UDim2.fromScale(1, 1)
			bg.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
			bg.BorderSizePixel = 0

			local bar = Instance.new("Frame", bg)
			bar.Size = UDim2.fromScale(1, hum.Health / hum.MaxHealth)
			bar.Position = UDim2.new(0, 0, 1, 0)
			bar.AnchorPoint = Vector2.new(0, 1)
			bar.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
			bar.BorderSizePixel = 0

			hum.HealthChanged:Connect(function(h)
				bar.Size = UDim2.fromScale(1, h / hum.MaxHealth)
			end)

			bb.Parent = gui
			table.insert(HealthESP.objects, bb)
		end
	end
end

function HealthESP.disable()
	HealthESP.enabled = false
	HealthESP.clear()
end

return HealthESP
