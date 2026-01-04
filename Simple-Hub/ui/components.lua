-- ══════════════════════════════════════════════════════════════
-- VERTEX HUB - UI COMPONENTS
-- ══════════════════════════════════════════════════════════════

local Components = {}

local Colors = {
	Button = Color3.fromRGB(28, 30, 40),
	ButtonHover = Color3.fromRGB(38, 42, 55),
	ButtonActive = Color3.fromRGB(35, 50, 80),
	Active = Color3.fromRGB(60, 120, 255),
	ActiveGlow = Color3.fromRGB(100, 180, 255),
	Text = Color3.fromRGB(220, 220, 240),
	TextDim = Color3.fromRGB(130, 130, 150),
	TextWhite = Color3.fromRGB(255, 255, 255),
	Border = Color3.fromRGB(40, 45, 58),
	SliderBg = Color3.fromRGB(22, 24, 32)
}

local function createCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 6)
	corner.Parent = parent
	return corner
end

local function createStroke(parent)
	local stroke = Instance.new("UIStroke")
	stroke.Color = Colors.Border
	stroke.Thickness = 1
	stroke.Transparency = 0.4
	stroke.Parent = parent
	return stroke
end

local function getAnimations()
	return _G.Animations
end

-- ══════════════════════════════════════════════════════════════
-- TOGGLE COMPONENT
-- ══════════════════════════════════════════════════════════════
function Components.createToggle(parent, text, callback)
	local Anim = getAnimations()
	
	local button = Instance.new("TextButton")
	button.Name = "Toggle_" .. text
	button.Size = UDim2.new(1, -16, 0, 34)
	button.BackgroundColor3 = Colors.Button
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = ""
	button.Parent = parent
	createCorner(button)
	createStroke(button)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -55, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 12
	label.Parent = button
	
	local indicator = Instance.new("Frame")
	indicator.Size = UDim2.new(0, 0, 0, 2)
	indicator.Position = UDim2.new(0, 0, 1, -2)
	indicator.BackgroundColor3 = Colors.ActiveGlow
	indicator.BorderSizePixel = 0
	indicator.Parent = button
	createCorner(indicator, 1)
	
	local toggleBg = Instance.new("Frame")
	toggleBg.Size = UDim2.new(0, 36, 0, 18)
	toggleBg.Position = UDim2.new(1, -46, 0.5, 0)
	toggleBg.AnchorPoint = Vector2.new(0, 0.5)
	toggleBg.BackgroundColor3 = Colors.SliderBg
	toggleBg.BorderSizePixel = 0
	toggleBg.Parent = button
	createCorner(toggleBg, 9)
	
	local toggleCircle = Instance.new("Frame")
	toggleCircle.Size = UDim2.new(0, 14, 0, 14)
	toggleCircle.Position = UDim2.new(0, 2, 0.5, 0)
	toggleCircle.AnchorPoint = Vector2.new(0, 0.5)
	toggleCircle.BackgroundColor3 = Colors.TextDim
	toggleCircle.BorderSizePixel = 0
	toggleCircle.Parent = toggleBg
	createCorner(toggleCircle, 7)
	
	local isOn = false
	
	button.MouseEnter:Connect(function()
		if Anim then
			Anim.tween(button, {BackgroundColor3 = Colors.ButtonHover}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	button.MouseLeave:Connect(function()
		if Anim and not isOn then
			Anim.tween(button, {BackgroundColor3 = Colors.Button}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	button.MouseButton1Click:Connect(function()
		isOn = not isOn
		
		if Anim then
			if isOn then
				Anim.tween(button, {BackgroundColor3 = Colors.ButtonActive}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(label, {TextColor3 = Colors.TextWhite}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(indicator, {Size = UDim2.new(1, 0, 0, 2)}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(toggleBg, {BackgroundColor3 = Colors.Active}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(toggleCircle, {Position = UDim2.new(1, -16, 0.5, 0), BackgroundColor3 = Colors.TextWhite}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			else
				Anim.tween(button, {BackgroundColor3 = Colors.Button}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(label, {TextColor3 = Colors.TextDim}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(indicator, {Size = UDim2.new(0, 0, 0, 2)}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(toggleBg, {BackgroundColor3 = Colors.SliderBg}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
				Anim.tween(toggleCircle, {Position = UDim2.new(0, 2, 0.5, 0), BackgroundColor3 = Colors.TextDim}, {Time = 0.2, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			end
		end
		
		if callback then
			task.spawn(callback, isOn)
		end
	end)
	
	return button
end

-- ══════════════════════════════════════════════════════════════
-- SLIDER COMPONENT
-- ══════════════════════════════════════════════════════════════
function Components.createSlider(parent, text, min, max, default, callback)
	local Anim = getAnimations()
	
	local container = Instance.new("Frame")
	container.Name = "Slider_" .. text
	container.Size = UDim2.new(1, -16, 0, 52)
	container.BackgroundColor3 = Colors.Button
	container.BorderSizePixel = 0
	container.Parent = parent
	createCorner(container)
	createStroke(container)
	
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -65, 0, 20)
	label.Position = UDim2.new(0, 12, 0, 5)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Colors.TextDim
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 11
	label.Parent = container
	
	local valueLabel = Instance.new("TextLabel")
	valueLabel.Size = UDim2.new(0, 50, 0, 20)
	valueLabel.Position = UDim2.new(1, -62, 0, 5)
	valueLabel.BackgroundTransparency = 1
	valueLabel.Text = tostring(default)
	valueLabel.TextColor3 = Colors.Active
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right
	valueLabel.Font = Enum.Font.GothamBold
	valueLabel.TextSize = 11
	valueLabel.Parent = container
	
	local sliderBg = Instance.new("Frame")
	sliderBg.Size = UDim2.new(1, -24, 0, 6)
	sliderBg.Position = UDim2.new(0, 12, 1, -16)
	sliderBg.BackgroundColor3 = Colors.SliderBg
	sliderBg.BorderSizePixel = 0
	sliderBg.Parent = container
	createCorner(sliderBg, 3)
	
	local fill = Instance.new("Frame")
	fill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
	fill.BackgroundColor3 = Colors.Active
	fill.BorderSizePixel = 0
	fill.Parent = sliderBg
	createCorner(fill, 3)
	
	local handle = Instance.new("Frame")
	handle.Size = UDim2.new(0, 14, 0, 14)
	handle.Position = UDim2.new((default - min) / (max - min), 0, 0.5, 0)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.BackgroundColor3 = Colors.ActiveGlow
	handle.BorderSizePixel = 0
	handle.ZIndex = 2
	handle.Parent = sliderBg
	createCorner(handle, 7)
	
	local dragging = false
	
	local function updateSlider(input)
		local percent = math.clamp((input.Position.X - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X, 0, 1)
		local value = math.floor(min + (max - min) * percent)
		valueLabel.Text = tostring(value)
		
		if Anim then
			Anim.tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, {Time = 0.08, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
			Anim.tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, {Time = 0.08, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		else
			fill.Size = UDim2.new(percent, 0, 1, 0)
			handle.Position = UDim2.new(percent, 0, 0.5, 0)
		end
		
		if callback then
			callback(value)
		end
	end
	
	sliderBg.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			updateSlider(input)
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
			updateSlider(input)
		end
	end)
	
	return container
end

-- ══════════════════════════════════════════════════════════════
-- SECTION HEADER COMPONENT
-- ══════════════════════════════════════════════════════════════
function Components.createSection(parent, text)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, -16, 0, 28)
	section.BackgroundTransparency = 1
	section.Parent = parent
	
	local accentLine = Instance.new("Frame")
	accentLine.Size = UDim2.new(0, 3, 0, 16)
	accentLine.Position = UDim2.new(0, 0, 0.5, 0)
	accentLine.AnchorPoint = Vector2.new(0, 0.5)
	accentLine.BackgroundColor3 = Colors.Active
	accentLine.BorderSizePixel = 0
	accentLine.Parent = section
	createCorner(accentLine, 2)
	
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

-- ══════════════════════════════════════════════════════════════
-- DIVIDER COMPONENT
-- ══════════════════════════════════════════════════════════════
function Components.createDivider(parent)
	local divider = Instance.new("Frame")
	divider.Size = UDim2.new(1, -32, 0, 1)
	divider.BackgroundColor3 = Colors.Border
	divider.BorderSizePixel = 0
	divider.BackgroundTransparency = 0.4
	divider.Parent = parent
	return divider
end

-- ══════════════════════════════════════════════════════════════
-- LABEL COMPONENT
-- ══════════════════════════════════════════════════════════════
function Components.createLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -16, 0, 24)
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

-- ══════════════════════════════════════════════════════════════
-- BUTTON COMPONENT
-- ══════════════════════════════════════════════════════════════
function Components.createButton(parent, text, callback)
	local Anim = getAnimations()
	
	local button = Instance.new("TextButton")
	button.Name = "Button_" .. text
	button.Size = UDim2.new(1, -16, 0, 34)
	button.BackgroundColor3 = Colors.Button
	button.BorderSizePixel = 0
	button.AutoButtonColor = false
	button.Text = text
	button.TextColor3 = Colors.Text
	button.Font = Enum.Font.GothamMedium
	button.TextSize = 12
	button.Parent = parent
	createCorner(button)
	createStroke(button)
	
	button.MouseEnter:Connect(function()
		if Anim then
			Anim.tween(button, {BackgroundColor3 = Colors.Active}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	button.MouseLeave:Connect(function()
		if Anim then
			Anim.tween(button, {BackgroundColor3 = Colors.Button}, {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out})
		end
	end)
	
	button.MouseButton1Click:Connect(function()
		if callback then
			task.spawn(callback)
		end
	end)
	
	return button
end

_G.Components = Components
return Components
