local Components = {}

function Components.Toggle(parent, text, default, callback)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(1, -12, 0, 36)
    b.Text = text .. ": " .. (default and "ON" or "OFF")
    b.Font = Enum.Font.GothamBold
    b.TextSize = 13
    b.BackgroundColor3 = Color3.fromRGB(30,30,40)
    b.TextColor3 = Color3.fromRGB(200,200,220)
    b.BorderSizePixel = 0
    b.AutoButtonColor = false

    Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

    local state = default

    b.MouseButton1Click:Connect(function()
        state = not state
        b.Text = text .. ": " .. (state and "ON" or "OFF")
        callback(state)
    end)

    return b
end

return Components
