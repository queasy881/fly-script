-- ui/menu.lua
-- This file BOOTS the UI

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local player = Players.LocalPlayer

return function()
	print("[UI] Initializing menu")
	print("[UI] menu.lua loaded")


	-- ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHub"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Main window
	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 780, 0, 520)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BorderSizePixel = 0
	main.Visible = false

	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

	-- Title
	local title = Instance.new("TextLabel", main)
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "SIMPLE HUB"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.new(1, 1, 1)

	-- Toggle with M
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.KeyCode == Enum.KeyCode.M then
			main.Visible = not main.Visible
			print("[UI] Toggle:", main.Visible)
		end
	end)
end
