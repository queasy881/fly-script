-- ui/animations.lua
local TweenService = game:GetService("TweenService")

local Animations = {}

function Animations.tween(obj, props, time, style, direction)
	if not obj then return end
	local tween = TweenService:Create(
		obj,
		TweenInfo.new(
			time or 0.25,
			style or Enum.EasingStyle.Quint,
			direction or Enum.EasingDirection.Out
		),
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

_G.Animations = Animations
return Animations
