-- Box ESP
local Players = game:GetService("Players")

local BoxESP = {}
BoxESP.enabled = false
BoxESP.objects = {}
BoxESP.color = Color3.fromRGB(255, 0, 0)

function BoxESP.clear()
	for _, v in ipairs(BoxESP.objects) do
		v:Destroy()
	end
	BoxESP.objects = {}
end

function BoxESP.enable(player, gui)
	BoxESP.enabled = true
	BoxESP.clear()

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart

			local billboard = Instance.new("BillboardGui")
			billboard.Adornee = hrp
			billboard.Size = UDim2.new(4, 0, 5, 0)
			billboard.AlwaysOnTop = true
			billboard.Parent = gui

			local frame = Instance.new("Frame", billboard)
			frame.Size = UDim2.fromScale(1, 1)
			frame.BackgroundTransparency = 1

			local function line(pos, size)
				local l = Instance.new("Frame", frame)
				l.Position = pos
				l.Size = size
				l.BackgroundColor3 = BoxESP.color
				l.BorderSizePixel = 0
			end

			line(UDim2.new(0,0,0,0), UDim2.new(0.3,0,0,2))
			line(UDim2.new(0.7,0,0,0), UDim2.new(0.3,0,0,2))
			line(UDim2.new(0,0,1,-2), UDim2.new(0.3,0,0,2))
			line(UDim2.new(0.7,0,1,-2), UDim2.new(0.3,0,0,2))

			table.insert(BoxESP.objects, billboard)
		end
	end
end

function BoxESP.disable()
	BoxESP.enabled = false
	BoxESP.clear()
end

return BoxESP

