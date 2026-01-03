-- ui/tabs.lua
-- Premium tab navigation system

local Animations = _G.Animations
assert(Animations, "[Tabs] Animations must be loaded first")

local Tabs = {}
Tabs.active = nil
Tabs.buttons = {}

local Colors = {
	Inactive = Color3.fromRGB(28, 28, 35),
	Active = Color3.fromRGB(60, 120, 255),
	TextInactive = Color3.fromRGB(140, 140, 160),
	TextActive = Color3.fromRGB(255, 255, 255),
	Indicator = Color3.fromRGB(100, 200, 255)
}

-- Create a tab button
function Tabs.create(tabBar, text, icon)
	local button = Instance.new("TextButton")
	button.Name = "Tab_" .. text
	button.Size = UDim2.new(0, 0, 0, 44)
	button.AutoButtonColor = false
	button.BackgroundColor3 = Colors.Inactive
	button.BorderSizePixel = 0
	button.Text = ""
	button.Parent = tabBar
	
	-- Rounded corners
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button
	
	-- Stroke
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(40, 40, 52)
	stroke.Thickness = 1
	stroke.Transparency = 0.6
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = button
	
	-- Icon (optional)
	if icon then
		local iconLabel = Instance.new("TextLabel")
		iconLabel.Name = "Icon"
		iconLabel.Size = UDim2.new(0, 20, 0, 20)
		iconLabel.Position = UDim2.new(0, 12, 0.5, 0)
		iconLabel.AnchorPoint = Vector2.new(0, 0.5)
		iconLabel.BackgroundTransparency = 1
		iconLabel.Text = icon
		iconLabel.TextColor3 = Colors.TextInactive
		iconLabel.Font = Enum.Font.GothamBold
		iconLabel.TextSize = 16
		iconLabel.Parent = button
	end
	
	-- Text label
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, icon and -40 or -24, 1, 0)
	label.Position = UDim2.new(0, icon and 36 or 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextInactive
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.Parent = button
	
	-- Active indicator bar
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 0, 0, 3)
	indicator.Position = UDim2.new(0.5, 0, 1, -3)
	indicator.AnchorPoint = Vector2.new(0.5, 0)
	indicator.BackgroundColor3 = Colors.Indicator
	indicator.BorderSizePixel = 0
	indicator.Parent = button
	
	local indicatorCorner = Instance.new("UICorner")
	indicatorCorner.CornerRadius = UDim.new(1, 0)
	indicatorCorner.Parent = indicator
	
	-- Glow effect
	local glow = Instance.new("ImageLabel")
	glow.Name = "Glow"
	glow.Size = UDim2.new(1, 20, 1, 20)
	glow.Position = UDim2.new(0.5, 0, 0.5, 0)
	glow.AnchorPoint = Vector2.new(0.5, 0.5)
	glow.BackgroundTransparency = 1
	glow.Image = "rbxassetid://5028857472"
	glow.ImageColor3 = Colors.Active
	glow.ImageTransparency = 1
	glow.ScaleType = Enum.ScaleType.Slice
	glow.SliceCenter = Rect.new(24, 24, 276, 276)
	glow.ZIndex = button.ZIndex - 1
	glow.Parent = button
	
	-- Auto-size based on text
	local textSize = game:GetService("TextService"):GetTextSize(
		text,
		13,
		Enum.Font.GothamBold,
		Vector2.new(1000, 1000)
	)
	button.Size = UDim2.new(0, textSize.X + (icon and 56 or 32), 0, 44)
	
	table.insert(Tabs.buttons, button)
	return button
end

-- Activate a tab
function Tabs.activate(button, contentFrame)
	if Tabs.active == button then return end
	
	-- Deactivate previous tab
	if Tabs.active then
		Animations.deactivateTab(Tabs.active)
		
		local iconLabel = Tabs.active:FindFirstChild("Icon")
		if iconLabel then
			Animations.tween(iconLabel, {TextColor3 = Colors.TextInactive}, nil)
		end
	end
	
	-- Activate new tab
	Tabs.active = button
	Animations.activateTab(button)
	
	local iconLabel = button:FindFirstChild("Icon")
	if iconLabel then
		Animations.tween(iconLabel, {TextColor3 = Colors.TextActive}, nil)
	end
	
	-- Content switching (if provided)
	if contentFrame then
		for _, child in ipairs(contentFrame.Parent:GetChildren()) do
			if child:IsA("ScrollingFrame") and child ~= contentFrame then
				child.Visible = false
			end
		end
		contentFrame.Visible = true
		Animations.fadeIn(contentFrame, 0.1)
	end
end

-- Setup tab bar with automatic layout
function Tabs.setupTabBar(tabBar)
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = tabBar
	
	-- Padding
	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 16)
	padding.PaddingRight = UDim.new(0, 16)
	padding.PaddingTop = UDim.new(0, 12)
	padding.PaddingBottom = UDim.new(0, 12)
	padding.Parent = tabBar
end

-- Connect tab to content
function Tabs.connectTab(button, contentFrame)
	button.MouseButton1Click:Connect(function()
		Tabs.activate(button, contentFrame)
	end)
	
	-- Hover effects
	button.MouseEnter:Connect(function()
		if Tabs.active ~= button then
			Animations.tween(button, {
				BackgroundColor3 = Color3.fromRGB(38, 38, 48)
			}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	button.MouseLeave:Connect(function()
		if Tabs.active ~= button then
			Animations.tween(button, {
				BackgroundColor3 = Colors.Inactive
			}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
end

_G.Tabs = Tabs
return Tabs
