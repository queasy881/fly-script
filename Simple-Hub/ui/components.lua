-- ui/components.lua
-- FIXED: No grey backgrounds, no hover overflow

local Components = {}

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

local function addCorner(obj, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = obj
	return corner
end

local function addStroke(obj, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Colors.Border
	stroke.Thickness = thickness or 1
	stroke.Transparency = 0.5
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = obj
	return stroke
end

local function getAnimations()
	return _G.Animations
end

-- Toggle Button - FIXED: no size changes, only color/glow
function Components.createToggle(parent, text, callback)
	local Animations = getAnimations()
	
	local button = Instance.new("TextButton")
	button.Name = "Toggle_" .. text
	button.Size = UDim2.new(1, -20, 0, 42)
	button.BackgroundColor3 = Colors.Button
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	button.ClipsDescendants = true
	button.Parent = parent
	
	addCorner(button, 6)
	addStroke(button)
	
	local innerGlow = Instance.new("Frame")
	innerGlow.Name = "InnerGlow"
	innerGlow.Size = UDim2.new(1, 0, 1, 0)
	innerGlow.BackgroundColor3 = Colors.Active
	innerGlow.BackgroundTransparency = 1
	innerGlow.BorderSizePixel = 0
	innerGlow.ZIndex = button.ZIndex + 1
	innerGlow.Parent = button
	addCorner(innerGlow, 6)
	
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
	label.ZIndex = button.ZIndex + 2
	label.Parent = button
	
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 0, 0, 3)
	indicator.Position = UDim2.new(0, 0, 1, -3)
	indicator.BackgroundColor3 = Colors.ActiveGlow
	indicator.BorderSizePixel = 0
	indicator.ZIndex = button.ZIndex + 2
	indicator.Parent = button
	addCorner(indicator, 2)
	
	local state = false
	
	button.MouseEnter:Connect(function()
		if Animations then
			Animations.tween(button, {BackgroundColor3 = Colors.ButtonHover}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			if not state then
				Animations.tween(innerGlow, {BackgroundTransparency = 0.9}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			end
		end
	end)
	
	button.MouseLeave:Connect(function()
		if Animations then
			if not state then
				Animations.tween(button, {BackgroundColor3 = Colors.Button}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(innerGlow, {BackgroundTransparency = 1}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
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

-- Slider - FIXED: proper sizing, no overflow
function Components.createSlider(parent, text, min, max, default, callback)
	local Animations = getAnimations()
	
	local container = Instance.new("Frame")
	container.Name = "Slider_" .. text
	container.Size = UDim2.new(1, -20, 0, 64)
	container.BackgroundColor3 = Colors.Button
	container.BorderSizePixel = 0
	container.ClipsDescendants = true
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

-- Section Header - FIXED: no grey background, accent line only
function Components.createSection(parent, text)
	local section = Instance.new("Frame")
	section.Name = "Section_" .. text
	section.Size = UDim2.new(1, -20, 0, 36)
	section.BackgroundTransparency = 1
	section.Parent = parent
	
	local accentLine = Instance.new("Frame")
	accentLine.Size = UDim2.new(0, 3, 0, 18)
	accentLine.Position = UDim2.new(0, 0, 0.5, 0)
	accentLine.AnchorPoint = Vector2.new(0, 0.5)
	accentLine.BackgroundColor3 = Colors.Accent
	accentLine.BorderSizePixel = 0
	accentLine.Parent = section
	addCorner(accentLine, 2)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 1, 0)
	label.Position = UDim2.new(0, 16, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text:upper()
	label.TextColor3 = Colors.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.Parent = section
	
	return section
end

-- Divider - subtle line separator
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
