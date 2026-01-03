-- ui/animations.lua
local TweenService = game:GetService("TweenService")

local Animations = {}

function Animations.tween(obj, props, time, style, direction)
	if not obj then return end
	local tween = TweenService:Create(
		obj,
		TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out),
		props
	)
	tween:Play()
	return tween
end

function Animations.toggle(button, enabled)
	if enabled then
		Animations.tween(button, {
			BackgroundColor3 = Color3.fromRGB(70,140,220),
			TextColor3 = Color3.fromRGB(255,255,255)
		})
	else
		Animations.tween(button, {
			BackgroundColor3 = Color3.fromRGB(26,26,34),
			TextColor3 = Color3.fromRGB(200,200,220)
		})
	end
end

function Animations.hover(button, hoverProps, normalProps)
	button.MouseEnter:Connect(function()
		Animations.tween(button, hoverProps, 0.2)
	end)
	button.MouseLeave:Connect(function()
		Animations.tween(button, normalProps, 0.2)
	end)
end

function Animations.press(button, pressedProps, normalProps)
	button.MouseButton1Down:Connect(function()
		Animations.tween(button, pressedProps, 0.1)
	end)
	button.MouseButton1Up:Connect(function()
		Animations.tween(button, normalProps, 0.1)
	end)
end

function Animations.pulse(button)
	local pulse = Instance.new("Frame")
	pulse.Size = UDim2.fromScale(1,1)
	pulse.BackgroundColor3 = Color3.fromRGB(70,140,220)
	pulse.BackgroundTransparency = 0.7
	pulse.BorderSizePixel = 0
	pulse.ZIndex = button.ZIndex - 1
	pulse.Parent = button

	local corner = Instance.new("UICorner", pulse)
	corner.CornerRadius = UDim.new(0,8)

	Animations.tween(pulse, {
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1.2,1.2)
	}, 0.5)

	game:GetService("Debris"):AddItem(pulse, 0.5)
end

return Animations

