-- components.lua
-- Vertical Hub Components - Fresh Implementation with Keybinds
-- Simplified components for vertical menu UX

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Components = {}

-- Colors (simplified palette)
local Colors = {
    Background = Color3.fromRGB(20, 20, 30),
    Header = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextSoft = Color3.fromRGB(200, 200, 220),
    Accent = Color3.fromRGB(100, 120, 255),
    Bar = Color3.fromRGB(40, 40, 50),
    Border = Color3.fromRGB(60, 60, 80)
}

-- Utility: Corner
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

-- Utility: Border
local function border(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Border
    s.Thickness = 1
    s.Parent = parent
    return s
end

-- Utility: Tween
local function tween(obj, props, time)
    local info = TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Create Section Label
function Components.createSectionLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(150, 150, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = parent
    return label
end

-- Create Toggle with Keybind
function Components.createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.2, 0, 1, 0)
    button.Position = UDim2.new(0.55, 0, 0, 0)
    button.Text = "Off"
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = frame
    corner(button)
    border(button)

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0.2, 0, 1, 0)
    keybindBtn.Position = UDim2.new(0.8, 0, 0, 0)
    keybindBtn.Text = "None"
    keybindBtn.BackgroundColor3 = Colors.Bar
    keybindBtn.TextColor3 = Colors.TextSoft
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.TextSize = 12
    keybindBtn.Parent = frame
    corner(keybindBtn)
    border(keybindBtn)

    local state = false
    local update = function()
        button.Text = state and "On" or "Off"
        tween(button, {BackgroundColor3 = state and Colors.Accent or Colors.Bar}, 0.15)
        callback(state)
    end

    button.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    return {
        Set = function(value)
            state = value
            update()
        end,
        Toggle = function()
            state = not state
            update()
        end,
        SetKeybindText = function(txt)
            keybindBtn.Text = txt
        end,
        GetKeybindButton = function()
            return keybindBtn
        end
    }
end

-- Create Group with Expandable Dropdown
function Components.createGroup(parent, text, callback)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 0, 30)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = mainFrame

    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0.1, 0, 1, 0)
    expandBtn.Position = UDim2.new(0.45, 0, 0, 0)
    expandBtn.Text = "+"
    expandBtn.BackgroundColor3 = Colors.Bar
    expandBtn.TextColor3 = Colors.Text
    expandBtn.Font = Enum.Font.Gotham
    expandBtn.TextSize = 12
    expandBtn.Parent = mainFrame
    corner(expandBtn)
    border(expandBtn)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.2, 0, 1, 0)
    button.Position = UDim2.new(0.55, 0, 0, 0)
    button.Text = "Off"
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = mainFrame
    corner(button)
    border(button)

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0.2, 0, 1, 0)
    keybindBtn.Position = UDim2.new(0.8, 0, 0, 0)
    keybindBtn.Text = "None"
    keybindBtn.BackgroundColor3 = Colors.Bar
    keybindBtn.TextColor3 = Colors.TextSoft
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.TextSize = 12
    keybindBtn.Parent = mainFrame
    corner(keybindBtn)
    border(keybindBtn)

    local subFrame = Instance.new("Frame")
    subFrame.Size = UDim2.new(1, 0, 0, 0)
    subFrame.BackgroundTransparency = 1
    subFrame.ClipsDescendants = true
    subFrame.Parent = parent
    local subLayout = Instance.new("UIListLayout")
    subLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subLayout.Padding = UDim.new(0, 5)
    subLayout.Parent = subFrame
    subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tween(subFrame, {Size = UDim2.new(1, 0, 0, expanded and subLayout.AbsoluteContentSize.Y or 0)}, 0.2)
    end)
    local subPadding = Instance.new("UIPadding")
    subPadding.PaddingLeft = UDim.new(0, 20)  -- Indent sub options
    subPadding.Parent = subFrame

    local state = false
    local expanded = false

    local updateToggle = function()
        button.Text = state and "On" or "Off"
        tween(button, {BackgroundColor3 = state and Colors.Accent or Colors.Bar}, 0.15)
        callback(state)
    end

    local updateExpand = function()
        expandBtn.Text = expanded and "x" or "+"
        tween(subFrame, {Size = UDim2.new(1, 0, 0, expanded and subLayout.AbsoluteContentSize.Y or 0)}, 0.2)
    end

    button.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)

    expandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateExpand()
    end)

    return {
        Set = function(value)
            state = value
            updateToggle()
        end,
        Toggle = function()
            state = not state
            updateToggle()
        end,
        SetKeybindText = function(txt)
            keybindBtn.Text = txt
        end,
        GetKeybindButton = function()
            return keybindBtn
        end,
        Expand = function(val)
            expanded = val
            updateExpand()
        end,
        SubContainer = subFrame
    }
end

-- Create Selector (Cycle through options)
function Components.createSelector(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.4, 0, 1, 0)
    button.Position = UDim2.new(0.6, 0, 0, 0)
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = frame
    corner(button)
    border(button)

    local index = table.find(options, default) or 1
    button.Text = options[index]

    button.MouseButton1Click:Connect(function()
        index = (index % #options) + 1
        button.Text = options[index]
        callback(options[index])
    end)

    return {
        Set = function(value)
            local newIndex = table.find(options, value) or 1
            index = newIndex
            button.Text = options[index]
        end
    }
end

-- Create Slider (More appealing with gradient)
function Components.createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(1, 0, 0.5, 0)
    barFrame.Position = UDim2.new(0, 0, 0.5, 0)
    barFrame.BackgroundColor3 = Colors.Bar
    barFrame.Parent = frame
    corner(barFrame)
    border(barFrame)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.Parent = barFrame
    corner(fill)

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 60, 200)),
        ColorSequenceKeypoint.new(1, Colors.Accent)
    })
    gradient.Parent = fill

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Colors.Text
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.Parent = barFrame

    local value = default
    local dragging = false

    barFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - barFrame.AbsolutePosition.X) / barFrame.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel + 0.5)
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.1)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    end)

    -- Set default
    local rel = (default - min) / (max - min)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    valueLabel.Text = tostring(default)

    return {
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local rel = (v - min) / (max - min)
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.15)
            valueLabel.Text = tostring(v)
        end
    }
end

return Components
