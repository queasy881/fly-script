-- ui/animations.lua
-- FIXED: Only color/transparency changes, NO size modifications

local TweenService = game:GetService("TweenService")

local Animations = {}

local Profiles = {
	Fast = {Time = 0.15, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out},
	Medium = {Time = 0.25, Style = Enum.EasingStyle.Quint, Direction = Enum.EasingDirection.Out},
	Slow = {Time = 0.4, Style = Enum.EasingStyle.Quint, Direction = Enum.EasingDirection.Out},
	Bounce = {Time = 0.5, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out},
	Elastic = {Time = 0.6, Style = Enum.EasingStyle.Elastic, Direction = Enum.EasingDirection.Out}
}

function Animations.tween(obj, props, profile)
	if not obj then return end
	profile = profile or Profiles.Medium
	
	local info = TweenInfo.new(profile.Time, profile.Style, profile.Direction)
	local tween = TweenService:Create(obj, info, props)
	tween:Play()
	return tween
end

function Animations.buttonHover(button, entering)
end

function Animations.buttonClick(button)
end

function Animations.toggleOn(button)
	Animations.tween(button, {BackgroundColor3 = Color3.fromRGB(60, 120, 255)}, Profiles.Medium)
	
	local label = button:FindFirstChild("Label")
	if label then
		Animations.tween(label, {TextColor3 = Color3.fromRGB(255, 255, 255)}, Profiles.Medium)
	end
	
	local indicator = button:FindFirstChild("Indicator")
	if indicator then
		Animations.tween(indicator, {
			BackgroundColor3 = Color3.fromRGB(100, 200, 255),
			Size = UDim2.new(1, 0, 0, 3)
		}, Profiles.Medium)
	end
	
	local innerGlow = button:FindFirstChild("InnerGlow")
	if innerGlow then
		Animations.tween(innerGlow, {BackgroundTransparency = 0.7}, Profiles.Medium)
	end
end

function Animations.toggleOff(button)
	Animations.tween(button, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)}, Profiles.Medium)
	
	local label = button:FindFirstChild("Label")
	if label then
		Animations.tween(label, {TextColor3 = Color3.fromRGB(180, 180, 200)}, Profiles.Medium)
	end
	
	local indicator = button:FindFirstChild("Indicator")
	if indicator then
		Animations.tween(indicator, {
			BackgroundColor3 = Color3.fromRGB(60, 60, 80),
			Size = UDim2.new(0, 0, 0, 3)
		}, Profiles.Medium)
	end
	
	local innerGlow = button:FindFirstChild("InnerGlow")
	if innerGlow then
		Animations.tween(innerGlow, {BackgroundTransparency = 1}, Profiles.Medium)
	end
end

function Animations.activateTab(tab)
	Animations.tween(tab, {
		BackgroundColor3 = Color3.fromRGB(60, 120, 255),
		TextColor3 = Color3.fromRGB(255, 255, 255)
	}, Profiles.Medium)
	
	local indicator = tab:FindFirstChild("Indicator")
	if indicator then
		Animations.tween(indicator, {
			Size = UDim2.new(0.8, 0, 0, 3),
			BackgroundColor3 = Color3.fromRGB(100, 200, 255)
		}, {Time = 0.3, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out})
	end
end

function Animations.deactivateTab(tab)
	Animations.tween(tab, {
		BackgroundColor3 = Color3.fromRGB(28, 28, 35),
		TextColor3 = Color3.fromRGB(140, 140, 160)
	}, Profiles.Medium)
	
	local indicator = tab:FindFirstChild("Indicator")
	if indicator then
		Animations.tween(indicator, {
			Size = UDim2.new(0, 0, 0, 3),
			BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		}, Profiles.Medium)
	end
end

function Animations.updateSlider(slider, percentage)
	local fill = slider:FindFirstChild("Fill")
	if fill then
		Animations.tween(fill, {Size = UDim2.new(percentage, 0, 1, 0)}, Profiles.Fast)
	end
	
	local handle = slider:FindFirstChild("Handle")
	if handle then
		Animations.tween(handle, {Position = UDim2.new(percentage, 0, 0.5, 0)}, Profiles.Fast)
	end
end

function Animations.fadeIn(obj, delay)
	delay = delay or 0
	obj.BackgroundTransparency = 1
	task.wait(delay)
	Animations.tween(obj, {BackgroundTransparency = 0}, Profiles.Slow)
end

function Animations.slideContent(oldContent, newContent, direction)
	direction = direction or "left"
	
	if oldContent then
		local offset = direction == "left" and -50 or 50
		Animations.tween(oldContent, {
			Position = UDim2.new(0, offset, 0, 0),
			GroupTransparency = 1
		}, Profiles.Medium)
		task.wait(0.15)
		oldContent.Visible = false
	end
	
	if newContent then
		newContent.Visible = true
		local startOffset = direction == "left" and 50 or -50
		newContent.Position = UDim2.new(0, startOffset, 0, 0)
		newContent.GroupTransparency = 1
		Animations.tween(newContent, {
			Position = UDim2.new(0, 0, 0, 0),
			GroupTransparency = 0
		}, Profiles.Medium)
	end
end

function Animations.pulse(obj, color)
	color = color or Color3.fromRGB(100, 200, 255)
	local glow = obj:FindFirstChild("Glow")
	if not glow then return end
	
	local function pulseOnce()
		Animations.tween(glow, {
			ImageTransparency = 0.3,
			ImageColor3 = color
		}, {Time = 0.8, Style = Enum.EasingStyle.Sine, Direction = Enum.EasingDirection.InOut})
		task.wait(0.8)
		Animations.tween(glow, {ImageTransparency = 1}, {Time = 0.8, Style = Enum.EasingStyle.Sine, Direction = Enum.EasingDirection.InOut})
	end
	
	task.spawn(function()
		while obj and obj.Parent do
			pulseOnce()
			task.wait(1.6)
		end
	end)
end

_G.Animations = Animations
return Animations
