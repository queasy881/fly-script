-- ui/menu.lua
-- LOADSTRING SAFE MENU BOOTSTRAP

return function()
	print("[UI] menu.lua init")

	local Players = game:GetService("Players")
	local UIS = game:GetService("UserInputService")

	local player = Players.LocalPlayer

	-- sanity check
	assert(_G.Tabs, "Tabs not loaded")
	assert(_G.Components, "Components not loaded")
	assert(_G.Animations, "Animations not loaded")

	--------------------------------------------------
	-- GUI ROOT
	--------------------------------------------------
	local gui = Instance.new("ScreenGui")
	gui.Name = "SimpleHub"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")

	local main = Instance.new("Frame")
	main.Size = UDim2.new(0, 780, 0, 520)
	main.Position = UDim2.fromScale(0.5, 0.5)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BorderSizePixel = 0
	main.Visible = false
	main.Parent = gui
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

	--------------------------------------------------
	-- TITLE
	--------------------------------------------------
	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "SIMPLE HUB"
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.TextColor3 = Color3.new(1,1,1)
	title.Parent = main

	--------------------------------------------------
	-- TAB BAR
	--------------------------------------------------
	local tabBar = Instance.new("Frame")
	tabBar.Position = UDim2.new(0, 0, 0, 40)
	tabBar.Size = UDim2.new(1, 0, 0, 40)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = main

	local tabLayout = Instance.new("UIListLayout", tabBar)
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Padding = UDim.new(0, 8)

	--------------------------------------------------
	-- CONTENT HOLDER
	--------------------------------------------------
	local content = Instance.new("Frame")
	content.Position = UDim2.new(0, 0, 0, 80)
	content.Size = UDim2.new(1, 0, 1, -80)
	content.BackgroundTransparency = 1
	content.Parent = main

	--------------------------------------------------
	-- CONTENT FRAMES
	--------------------------------------------------
	local function newPage()
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, 0, 1, 0)
		f.Visible = false
		f.BackgroundTransparency = 1
		f.Parent = content

		local pad = Instance.new("UIPadding", f)
		pad.PaddingTop = UDim.new(0, 10)
		pad.PaddingLeft = UDim.new(0, 20)
		pad.PaddingRight = UDim.new(0, 20)

		local list = Instance.new("UIListLayout", f)
		list.Padding = UDim.new(0, 8)

		return f
	end

	local Pages = {
		Movement = newPage(),
		ESP      = newPage(),
		Combat   = newPage(),
		Extra    = newPage()
	}

	--------------------------------------------------
	-- TABS
	--------------------------------------------------
	local function activate(page)
		for _,p in pairs(Pages) do
			p.Visible = false
		end
		page.Visible = true
	end

	local moveTab = _G.Tabs.create(tabBar, "Movement")
	moveTab.MouseButton1Click:Connect(function()
		_G.Tabs.activate(moveTab)
		activate(Pages.Movement)
	end)

	local espTab = _G.Tabs.create(tabBar, "ESP")
	espTab.MouseButton1Click:Connect(function()
		_G.Tabs.activate(espTab)
		activate(Pages.ESP)
	end)

	local combatTab = _G.Tabs.create(tabBar, "Combat")
	combatTab.MouseButton1Click:Connect(function()
		_G.Tabs.activate(combatTab)
		activate(Pages.Combat)
	end)

	local extraTab = _G.Tabs.create(tabBar, "Extra")
	extraTab.MouseButton1Click:Connect(function()
		_G.Tabs.activate(extraTab)
		activate(Pages.Extra)
	end)

	-- default tab
	_G.Tabs.activate(moveTab)
	activate(Pages.Movement)

	--------------------------------------------------
	-- TOGGLE KEY
	--------------------------------------------------
	UIS.InputBegan:Connect(function(i, gp)
		if gp then return end
		if i.KeyCode == Enum.KeyCode.M then
			main.Visible = not main.Visible
			print("[UI] Visible:", main.Visible)
		end
	end)

	--------------------------------------------------
	-- RETURN PAGES FOR FEATURES
	--------------------------------------------------
	return Pages
end
