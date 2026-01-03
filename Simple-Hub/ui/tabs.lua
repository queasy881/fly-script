local Anim = require(script.Parent.animations)

local Tabs = {}
Tabs.active = nil

local ACTIVE = Color3.fromRGB(88,166,255)
local INACTIVE = Color3.fromRGB(35,35,45)
local TEXT = Color3.fromRGB(220,220,230)

function Tabs.create(tabBar, pages, text)
    local btn = Instance.new("TextButton", tabBar)
    btn.Size = UDim2.new(0,140,1,0)
    btn.BackgroundColor3 = INACTIVE
    btn.Text = text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.TextColor3 = TEXT
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0,8)

    local page = Instance.new("ScrollingFrame", pages)
    page.Size = UDim2.fromScale(1,1)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.ScrollBarThickness = 6
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,10)

    local pad = Instance.new("UIPadding", page)
    pad.PaddingTop = UDim.new(0,12)
    pad.PaddingLeft = UDim.new(0,12)
    pad.PaddingRight = UDim.new(0,12)

    btn.MouseButton1Click:Connect(function()
        if Tabs.active then
            Anim.tween(Tabs.active.button, 0.15, {BackgroundColor3 = INACTIVE})
            Tabs.active.page.Visible = false
        end
        Tabs.active = {button = btn, page = page}
        page.Visible = true
        Anim.tween(btn, 0.15, {BackgroundColor3 = ACTIVE})
    end)

    return {button = btn, page = page}
end

return Tabs
