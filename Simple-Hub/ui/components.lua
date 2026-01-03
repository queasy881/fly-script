return function(Anim)
    local Components = {}

    local C = {
        bg     = Color3.fromRGB(15,17,21),
        panel  = Color3.fromRGB(21,25,35),
        off    = Color3.fromRGB(30,35,48),
        on     = Color3.fromRGB(59,130,246),
        hover  = Color3.fromRGB(42,49,66),
        text   = Color3.fromRGB(229,231,235),
        muted  = Color3.fromRGB(156,163,175)
    }

    ----------------------------------------------------------------
    -- TOGGLE
    ----------------------------------------------------------------
    function Components.Toggle(parent, text, default, callback)
        local btn = Instance.new("TextButton", parent)
        btn.Size = UDim2.new(1, -12, 0, 42)
        btn.Active = true
        btn.AutoButtonColor = false
        btn.BorderSizePixel = 0
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.TextColor3 = C.text

        local state = default
        btn.BackgroundColor3 = state and C.on or C.off
        btn.Text = text .. " — " .. (state and "ON" or "OFF")

        Instance.new("UICorner", btn).CornerRadius = UDim.new(0,10)

        btn.MouseEnter:Connect(function()
            Anim.tween(btn, 0.15, {
                BackgroundColor3 = state and C.on or C.hover,
                Size = UDim2.new(1, -8, 0, 44)
            })
        end)

        btn.MouseLeave:Connect(function()
            Anim.tween(btn, 0.15, {
                BackgroundColor3 = state and C.on or C.off,
                Size = UDim2.new(1, -12, 0, 42)
            })
        end)

        btn.MouseButton1Click:Connect(function()
            state = not state
            btn.Text = text .. " — " .. (state and "ON" or "OFF")
            Anim.tween(btn, 0.12, {
                BackgroundColor3 = state and C.on or C.off,
                Size = UDim2.new(1, -10, 0, 40)
            })
            callback(state)
        end)
    end

    ----------------------------------------------------------------
    -- SLIDER
    ----------------------------------------------------------------
    function Components.Slider(parent, text, min, max, value, callback)
        local frame = Instance.new("Frame", parent)
        frame.Size = UDim2.new(1, -12, 0, 52)
        frame.BackgroundTransparency = 1

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1,0,0,20)
        label.BackgroundTransparency = 1
        label.Font = Enum.Font.GothamMedium
        label.TextSize = 13
        label.TextColor3 = C.muted
        label.TextXAlignment = Enum.TextXAlignment.Left  -- ✅ FIX
        label.Text = text .. ": " .. value

        local bar = Instance.new("Frame", frame)
        bar.Position = UDim2.new(0,0,0,28)
        bar.Size = UDim2.new(1,0,0,10)
        bar.BackgroundColor3 = C.off
        bar.BorderSizePixel = 0
        Instance.new("UICorner", bar).CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.fromScale((value-min)/(max-min),1)
        fill.BackgroundColor3 = C.on
        Instance.new("UICorner", fill).CornerRadius = UDim.new(1,0)

        local UIS = game:GetService("UserInputService")
        local dragging = false

        local function set(x)
            local s = math.clamp((x - bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1)
            local v = math.floor(min + (max-min)*s)
            label.Text = text .. ": " .. v
            Anim.tween(fill, 0.1, {Size = UDim2.fromScale(s,1)})
            callback(v)
        end

        bar.InputBegan:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                set(i.Position.X)
            end
        end)

        UIS.InputChanged:Connect(function(i)
            if dragging and i.UserInputType == Enum.UserInputType.MouseMovement then
                set(i.Position.X)
            end
        end)

        UIS.InputEnded:Connect(function(i)
            if i.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)
    end

    return Components
end
