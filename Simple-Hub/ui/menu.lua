-- ui/menu.lua
return function(deps)
	local Tabs = deps.Tabs
	local Components = deps.Components
	local Animations = deps.Animations

	if not Tabs then
		error("Tabs not loaded")
	end

	print("[UI] menu.lua init")

	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")
	local player = Players.LocalPlayer

	-- ScreenGui
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHub"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	-- Main frame
	local main = Instance.new("Frame", gui)
	main.Size = UDim2.new(0, 780, 0, 520)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(18,18,22)
	main.Visible = false
	Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

	-- Toggle with M
	UIS.InputBegan:Connect(function(i,gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.M then
			main.Visible = not main.Visible
		end
	end)

	-- Tab bar example
	local tabBar = Instance.new("Frame", main)
	tabBar.Size = UDim2.new(1,0,0,50)
	tabBar.BackgroundTransparency = 1

	local moveTab = Tabs.create(tabBar, "Movement")
	Tabs.activate(moveTab)
end
