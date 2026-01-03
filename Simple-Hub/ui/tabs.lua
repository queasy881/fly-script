local Animations = _G.Animations
assert(Animations, "[Tabs] Animations not loaded")

local Tabs = {}
Tabs.active = nil

function Tabs.create(tabBar, container, text)
    local button = Instance.new("TextButton", tabBar)
    button.Size = UDim2.new(0,160,0,36)
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.BackgroundColor3 = Color3.fromRGB(30,30,40)
    button.TextColor3 = Color3.fromRGB(200,200,220)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false

    Instance.new("UICorner", button).CornerRadius = UDim.new(0,8)

    -- page
    local page = Instance.new("ScrollingFrame", container)
    page.Size = UDim2.fromScale(1,1)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    page.Visible = false

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,8)

    button.MouseButton1Click:Connect(function()
        if Tabs.active then
            Tabs.active.page.Visible = false
        end
        Tabs.active = {button = button, page = page}
        page.Visible = true
    end)

    return {
        button = button,
        page = page
    }
end

return Tabs
