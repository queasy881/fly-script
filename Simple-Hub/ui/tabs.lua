-- ui/tabs.lua
local Animations = require(script.Parent.animations)

local Tabs = {}
Tabs.active = nil

function Tabs.create(tabBar, text)
	local b = Instance.new("TextButton", tabBar)
	b.Size = UDim2.new(0,160,0,36)
	b.Text = text
	b.Font = Enum.Font.GothamBold
	b.TextSize = 13
	b.TextColor3 = Color3.fromRGB(200,200,220)
	b.BackgroundColor3 = Color3.fromRGB(30,30,40)
	b.BorderSizePixel = 0
	b.AutoButtonColor = false

	Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

	local indicator = Instance.new("Frame", b)
	indicator.Size = UDim2.new(0,0,0,3)
	indicator.Position = UDim2.new(0.5,0,1,-3)
	indicator.AnchorPoint = Vector2.new(0.5,0)
	indicator.BackgroundColor3 = Color3.fromRGB(88,166,255)
	indicator.BorderSizePixel = 0
	Instance.new("UICorner", indicator).CornerRadius = UDim.new(1,0)

	return b
end

function Tabs.activate(button)
	if Tabs.active then
		Animations.tween(Tabs.active, {
			BackgroundColor3 = Color3.fromRGB(30,30,40),
			TextColor3 = Color3.fromRGB(200,200,220)
		})
		Animations.tween(Tabs.active:FindFirstChild("Frame"), {Size = UDim2.new(0,0,0,3)})
	end

	Tabs.active = button
	Animations.tween(button, {
		BackgroundColor3 = Color3.fromRGB(88,166,255),
		TextColor3 = Color3.fromRGB(255,255,255)
	})
	Animations.tween(button:FindFirstChild("Frame"), {Size = UDim2.new(0.8,0,0,3)}, 0.3, Enum.EasingStyle.Back)
end

return Tabs

