-- settings/ui_settings.lua

local UISettings = {}

-- Window
UISettings.WindowSize = UDim2.new(0, 780, 0, 520)
UISettings.ToggleKey = Enum.KeyCode.M

-- Colors
UISettings.Colors = {
	Background = Color3.fromRGB(18,18,22),
	Panel = Color3.fromRGB(22,22,28),
	Button = Color3.fromRGB(26,26,34),
	ButtonHover = Color3.fromRGB(32,32,42),
	ButtonActive = Color3.fromRGB(70,140,220),
	Text = Color3.fromRGB(200,200,220),
	TextActive = Color3.fromRGB(255,255,255),
	Accent = Color3.fromRGB(88,166,255),
	Stroke = Color3.fromRGB(40,40,50)
}

-- Animation
UISettings.AnimationSpeed = 0.25
UISettings.EasingStyle = Enum.EasingStyle.Quint
UISettings.EasingDirection = Enum.EasingDirection.Out

-- Scrolling
UISettings.ScrollBarThickness = 6
UISettings.ScrollBarTransparency = 0.5

return UISettings

