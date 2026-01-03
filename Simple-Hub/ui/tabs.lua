local Tabs = {}
Tabs.active = nil

function Tabs.create(tabBar, pages, text)
    local button = Instance.new("TextButton", tabBar)
    button.Size = UDim2.new(0,140,1,0)
    button.Text = text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.BackgroundColor3 = Color3.fromRGB(30,30,40)
    button.TextColor3 = Color3.fromRGB(200,200,220)
    button.BorderSizePixel = 0
    button.AutoButtonColor = false

    Instance.new("UICorner", button).CornerRadius = UDim.new(0,8)

    local page = Instance.new("ScrollingFrame", pages)
    page.Size = UDim2.fromScale(1,1)
    page.CanvasSize = UDim2.new(0,0,0,0)
    page.ScrollBarThickness = 6
    page.Visible = false
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y

    local layout = Instance.new("UIListLayout", page)
    layout.Padding = UDim.new(0,10)

    local padding = Instance.new("UIPadding", page)
    padding.PaddingTop = UDim.new(0,10)
    padding.PaddingLeft = UDim.new(0,10)
    padding.PaddingRight = UDim.new(0,10)

    button.MouseButton1Click:Connect(function()
        if Tabs.active then
            Tabs.active.page.Visible = false
        end
        Tabs.active = {button = button, page = page}
        page.Visible = true
    end)

    return {button = button, page = page}
end

return Tabs
