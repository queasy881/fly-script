-- ui/components.lua
-- Premium component library (FIXED: sizing, hover bugs, backgrounds)

local Components = {}

-- Color palette
local Colors = {
	Background = Color3.fromRGB(12, 12, 16),
	Panel = Color3.fromRGB(18, 18, 24),
	Surface = Color3.fromRGB(24, 24, 32),
	Button = Color3.fromRGB(35, 35, 45),
	ButtonHover = Color3.fromRGB(45, 45, 58),
	Active = Color3.fromRGB(60, 120, 255),
	ActiveGlow = Color3.fromRGB(100, 200, 255),
	Text = Color3.fromRGB(220, 220, 240),
	TextDim = Color3.fromRGB(140, 140, 160),
	TextActive = Color3.fromRGB(255, 255, 255),
	Border = Color3.fromRGB(40, 40, 52),
	Accent = Color3.fromRGB(88, 166, 255)
}

-- Utility: Create rounded corner
local function addCorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = obj
	return corner
end

-- Utility: Create glow effect
local function addGlow(obj)
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
	glow.ZIndex = obj.ZIndex - 1
	glow.Parent = obj
	return glow
end

-- Utility: Create stroke
local function addStroke(obj, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Colors.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = obj
	return stroke
end

-- Get Animations safely
local function getAnimations()
	return _G.Animations
end

-- Toggle Button (FIXED: no size changes on hover/click)
function Components.createToggle(parent, text, callback)
	local Animations = getAnimations()
	
	local button = Instance.new("TextButton")
	button.Name = "Toggle_" .. text
	button.Size = UDim2.new(1, -20, 0, 42)
	button.BackgroundColor3 = Colors.Button
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	button.Parent = parent
	
	addCorner(button, 6)
	addStroke(button)
	local glow = addGlow(button)
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -16, 1, 0)
	label.Position = UDim2.new(0, 16, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 14
	label.Parent = button
	
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 0, 0, 3)
	indicator.Position = UDim2.new(0, 0, 1, -3)
	indicator.BackgroundColor3 = Colors.ActiveGlow
	indicator.BorderSizePixel = 0
	indicator.Parent = button
	
	addCorner(indicator, 2)
	
	local state = false
	
	button.MouseEnter:Connect(function()
		if Animations then
			-- Only change color, no size change
			Animations.tween(button, {
				BackgroundColor3 = Colors.ButtonHover
			}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			
			if not state then
				Animations.tween(glow, {
					ImageTransparency = 0.7
				}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			end
		end
	end)
	
	button.MouseLeave:Connect(function()
		if Animations then
			if not state then
				Animations.tween(button, {
					BackgroundColor3 = Colors.Button
				}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				
				Animations.tween(glow, {
					ImageTransparency = 1
				}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			end
		end
	end)
	
	button.MouseButton1Click:Connect(function()
		state = not state
		
		if Animations then
			if state then
				Animations.toggleOn(button)
			else
				Animations.toggleOff(button)
			end
		end
		
		if callback then
			task.spawn(callback, state)
		end
	end)
	
	return button
end

-- Slider (FIXED: proper sizing)
function Components.createSlider(parent, text, min, max, default, callback)
	local Animations = getAnimations()
	
	local container = Instance.new("Frame")
	container.Name = "Slider_" .. text
	container.Size = UDim2.new(1, -20, 0, 64)
	container.BackgroundColor3 = Colors.Button
	container.BorderSizePixel = 0
	container.Parent = parent
	
	addCorner(container, 6)
	addStroke(container)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, 20)
	label.Position = UDim2.new(0, 16, 0, 10)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.Parent = container
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 60, 0, 20)
	valueLabel.Position = UDim2.new(1, -76, 0, 10)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Colors.Active
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 13
	valueLabel.Parent = container
	
	local sliderBg = Instance.new("Frame")
	sliderBg.Name = "SliderBg"
	sliderBg.Size = UDim2.new(1, -32, 0, 6)
	sliderBg.Position = UDim2.new(0, 16, 1, -20)
	sliderBg.BackgroundColor3 = Colors.Surface
	sliderBg.BorderSizePixel = 0
	sliderBg.Parent = container
	
	addCorner(sliderBg, 3)
	
	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Colors.Active
	fill.BorderSizePixel = 0
	fill.Parent = sliderBg
	
	addCorner(fill, 3)
	
	local handle = Instance.new("Frame")
	handle.Name = "Handle"
	handle.Size = UDim2.new(0, 14, 0, 14)
	handle.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.BackgroundColor3 = Colors.ActiveGlow
	handle.BorderSizePixel = 0
	handle.ZIndex = 2
	handle.Parent = sliderBg
	
	addCorner(handle, 7)
	addGlow(handle)
	
	local dragging = false
	local value = default
	
	local function updateValue(input)
		local pos = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		value = math.floor(min + (max - min) * pos)
		valueLabel.Text = tostring(value)
		
		if Animations then
			Animations.updateSlider(sliderBg, pos)
		end
		
		if callback then
			callback(value)
		end
	end
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateValue(input)
		end
	end)
	
	handle.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateValue(input)
		end
	end)
	
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateValue(input)
		end
	end)
	
	return container
end

-- Section Header
function Components.createSection(parent, text)
	local section = Instance.new("Frame")
	section.Name = "Section_" .. text
	section.Size = UDim2.new(1, -20, 0, 36)
	section.BackgroundTransparency = 1
	section.Parent = parent
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text:upper()
	label.TextColor3 = Colors.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.Parent = section
	
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 3, 0, 18)
	line.Position = UDim2.new(0, 0, 0.5, 0)
	line.AnchorPoint = Vector2.new(0, 0.5)
	line.BackgroundColor3 = Colors.Accent
	line.BorderSizePixel = 0
	line.Parent = section
	
	addCorner(line, 2)
	
	return section
end

-- Divider
function Components.createDivider(parent)
	local divider = Instance.new("Frame")
	divider.Name = "Divider"
	divider.Size = UDim2.new(1, -40, 0, 1)
	divider.BackgroundColor3 = Colors.Border
	divider.BorderSizePixel = 0
	divider.BackgroundTransparency = 0.5
	divider.Parent = parent
	
	return divider
end

-- Info Label
function Components.createLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Name = "InfoLabel"
	label.Size = UDim2.new(1, -20, 0, 28)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextWrapped = true
	label.Parent = parent
	
	return label
end

_G.Components = Components
return Components
