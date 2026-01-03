return function(Animations)
    local Components = {}

    local COLORS = {
        off = Color3.fromRGB(35,35,45),
        on = Color3.fromRGB(88,166,255),
        hover = Color3.fromRGB(55,55,70),
        text = Color3.fromRGB(220,220,230)
    }

    -- ======================
    -- TOGGLE
    -- ======================
    function Components.Toggle(parent, text, default, callback)
        local button = Instance.new("TextButton", parent)
        button.Size = UDim2.new(1, -12, 0, 38)
        button.BackgroundColor3 = default and COLORS.on or COLORS.off
        button.TextColor3 = COLORS.text
        button.Text = text .. " : " .. (default and "ON" or "OFF")
        button.Font = Enum.Font.GothamBold
        button.TextSize = 13
        button.BorderSizePixel = 0
        button.AutoButtonColor = false

        Instance.new("UICorner", button).CornerRadius = UDim.new(0,8)

        local state = default

        button.MouseEnter:Connect(function()
            Animations.tween(button, 0.12, {BackgroundColor3 = COLORS.hover})
        end)

        button.MouseLeave:Connect(function()
            Animations.tween(button, 0.12, {
                BackgroundColor3 = state and COLORS.on or COLORS.off
            })
        end)

        button.MouseButton1Click:Connect(function()
            state = not state
            button.Text = text .. " : " .. (state and "ON" or "OFF")
            Animations.tween(button, 0.12, {
                BackgroundColor3 = state and COLORS.on or COLORS.off
            })
            callback(state)
        end)

        return button
    end

    -- ======================
    -- SLIDER
    -- ======================
    function Components.Slider(parent, text, min, max, default, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -12, 0, 48)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1,0,0,18)
        label.BackgroundTransparency = 1
        label.Text = text .. " : " .. default
        label.Font = Enum.Font.GothamBold
        label.TextSize = 13
        label.TextColor3 = COLORS.text
        label.TextXAlignment = Enum.TextXAlignment.Left

        local bar = Instance.new("Frame", frame)
        bar.Position = UDim2.new(0,0,0,26)
        bar.Size = UDim2.new(1,0,0,10)
        bar.BackgroundColor3 = COLORS.off
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.fromScale((default-min)/(max-min),1)
        fill.BackgroundColor3 = COLORS.on
        fill.BorderSizePixel = 0
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

        local UIS = game:GetService("UserInputService")
        local dragging = false

        local function set(x)
            local scale = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local value = math.floor(min + (max-min)*scale)
            label.Text = text .. " : " .. value
            Animations.tween(fill, 0.08, {Size = UDim2.fromScale(scale,1)})
            callback(value)
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                set(i.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                set(i.Position.X)
            end
        end)

        return frame
    end

    return Components
end
