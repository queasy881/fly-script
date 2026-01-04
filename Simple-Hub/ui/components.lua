-- ui/components.lua
-- Premium component library - NO GRAY

local Components = {}

local Colors = {
	Background = Color3.fromRGB(18, 18, 25),
	Panel = Color3.fromRGB(22, 22, 32),
	Surface = Color3.fromRGB(26, 26, 36),
	Button = Color3.fromRGB(32, 34, 45),
	ButtonHover = Color3.fromRGB(42, 44, 58),
	Active = Color3.fromRGB(60, 120, 255),
	ActiveGlow = Color3.fromRGB(100, 200, 255),
	Text = Color3.fromRGB(220, 220, 240),
	TextDim = Color3.fromRGB(140, 140, 160),
	TextActive = Color3.fromRGB(255, 255, 255),
	Border = Color3.fromRGB(45, 48, 62),
	Accent = Color3.fromRGB(88, 166, 255),
	SliderBg = Color3.fromRGB(25, 27, 38)
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

function Components.createToggle(parent, text, callback)
	local Animations = getAnimations()
	
	local button = Instance.new("TextButton")
	button.Name = "Toggle_" .. text
	button.Size = UDim2.new(1, -20, 0, 36)
	button.BackgroundColor3 = Colors.Button
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	button.Parent = parent
	
	addCorner(button, 6)
	addStroke(button)
	
	local label = Instance.new("TextLabel")
	label.Name = "Label"
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Position = UDim2.new(0, 14, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 13
	label.Parent = button
	
	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 0, 0, 3)
	indicator.Position = UDim2.new(0, 0, 1, -3)
	indicator.BackgroundColor3 = Colors.ActiveGlow
	indicator.BorderSizePixel = 0
	indicator.Parent = button
	addCorner(indicator, 2)
	
	-- Toggle circle
	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 38, 0, 20)
	toggleBg.Position = UDim2.new(1, -48, 0.5, 0)
	toggleBg.AnchorPoint = Vector2.new(0, 0.5)
	toggleBg.BackgroundColor3 = Colors.SliderBg
	toggleBg.BorderSizePixel = 0
	toggleBg.Parent = button
	addCorner(toggleBg, 10)
	
	local toggleCircle = Instance.new("Frame")
	toggleCircle.Size = UDim2.new(0, 16, 0, 16)
	toggleCircle.Position = UDim2.new(0, 2, 0.5, 0)
	toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
	toggleCircle.BackgroundColor3 = Colors.TextDim
	toggleCircle.BorderSizePixel = 0
	toggleCircle.Parent = toggleBg
	addCorner(toggleCircle, 8)
	
	local state = false
	
	button.MouseEnter:Connect(function()
		if Animations then
			Animations.tween(button, {BackgroundColor3 = Colors.ButtonHover}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	button.MouseLeave:Connect(function()
		if Animations and not state then
			Animations.tween(button, {BackgroundColor3 = Colors.Button}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	button.MouseButton1Click:Connect(function()
		state = not state
		
		if Animations then
			if state then
				Animations.tween(button, {BackgroundColor3 = Color3.fromRGB(40, 60, 100)}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(label, {TextColor3 = Colors.TextActive}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(indicator, {Size = UDim2.new(1, 0, 0, 3), BackgroundColor3 = Colors.ActiveGlow}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(toggleBg, {BackgroundColor3 = Colors.Active}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(toggleCircle, {Position = UDim2.new(1, -18, 0.5, 0), BackgroundColor3 = Colors.TextActive}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			else
				Animations.tween(button, {BackgroundColor3 = Colors.Button}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(label, {TextColor3 = Colors.TextDim}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(indicator, {Size = UDim2.new(0, 0, 0, 3)}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(toggleBg, {BackgroundColor3 = Colors.SliderBg}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Animations.tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Colors.TextDim}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			end
		end
		
		if callback then task.spawn(callback, state) end
	end)
	
	return button
end

function Components.createSlider(parent, text, min, max, default, callback)
	local Animations = getAnimations()
	
	local container = Instance.new("Frame")
	container.Name = "Slider_" .. text
	container.Size = UDim2.new(1, -20, 0, 55)
	container.BackgroundColor3 = Colors.Button
	container.BorderSizePixel = 0
	container.Parent = parent
	
	addCorner(container, 6)
	addStroke(container)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -70, 0, 18)
	label.Position = UDim2.new(0, 14, 0, 6)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.Parent = container
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 18)
	valueLabel.Position = UDim2.new(1, -64, 0, 6)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Colors.Active
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 12
	valueLabel.Parent = container
	
	local sliderBg = Instance.new("Frame")
	sliderBg.Name = "SliderBg"
	sliderBg.Size = UDim2.new(1, -28, 0, 6)
	sliderBg.Position = UDim2.new(0, 14, 1, -16)
	sliderBg.BackgroundColor3 = Colors.SliderBg
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
			Animations.tween(fill, {Size = UDim2.new(pos, 0, 1, 0)}, {Time = 0.1, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			Animations.tween(handle, {Position = UDim2.new(pos, 0, 0.5, 0)}, {Time = 0.1, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		else
			fill.Size = UDim2.new(pos, 0, 1, 0)
			handle.Position = UDim2.new(pos, 0, 0.5, 0)
		end
		
		if callback then callback(value) end
	end
	
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateValue(input)
		end
	end)
	
	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
		end
	end)
	
	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
	
	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
			updateValue(input)
		end
	end)
	
	return container
end

function Components.createSection(parent, text)
	local section = Instance.new("Frame")
	section.Name = "Section_" .. text
	section.Size = UDim2.new(1, -20, 0, 28)
	section.BackgroundTransparency = 1
	section.Parent = parent
	
	local line = Instance.new("Frame")
	line.Size = UDim2.new(0, 3, 0, 14)
	line.Position = UDim2.new(0, 0, 0.5, 0)
	line.AnchorPoint = Vector2.new(0, 0.5)
	line.BackgroundColor3 = Colors.Accent
	line.BorderSizePixel = 0
	line.Parent = section
	addCorner(line, 2)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text:upper()
	label.TextColor3 = Colors.Text
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamBold
	label.TextSize = 11
	label.Parent = section
	
	return section
end

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

function Components.createLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -20, 0, 24)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.Gotham
	label.TextSize = 11
	label.TextWrapped = true
	label.Parent = parent
	return label
end

_G.Components = Components
return Components
