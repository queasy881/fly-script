-- ui/menu.lua
print("[UI] menu.lua file loaded")

local Players = game:GetService("Players")
local CAS = game:GetService("ContextActionService")

local player = Players.LocalPlayer

return function()
	print("[UI] menu init running")

	-- ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHub"
	gui.ResetOnSpawn = false
	gui.IgnoreGuiInset = true
	gui.ZIndexBehavior = Enum.ZIndexBehavior.Global
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Main window
	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 780, 0, 520)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BorderSizePixel = 0
	main.Visible = false
	main.ZIndex = 10
	main.Parent = gui

	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

	-- Title
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "SIMPLE HUB"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.new(1, 1, 1)
	title.ZIndex = 11
	title.Parent = main

	-- Toggle with M (robust)
	CAS:BindAction(
		"SimpleHubToggle",
		function(_, state)
			if state == Enum.UserInputState.Begin then
				main.Visible = not main.Visible
				print("[UI] Toggle:", main.Visible)
			end
		end,
		false,
		Enum.KeyCode.M
	)
end
