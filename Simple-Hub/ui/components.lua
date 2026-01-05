-- components_redesigned.lua - GLASSMORPHISM MODERN DESIGN
-- Floating cards, blur effects, minimal aesthetic

local Components = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Modern Minimal Color Palette
local Colors = {
    Background = Color3.fromRGB(15, 15, 20),
    Glass = Color3.fromRGB(25, 25, 35),
    GlassLight = Color3.fromRGB(35, 35, 50),
    Blur = Color3.fromRGB(20, 20, 30),
    Text = Color3.fromRGB(255, 255, 255),
    TextSoft = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 140),
    Accent = Color3.fromRGB(120, 100, 255),
    AccentSoft = Color3.fromRGB(150, 130, 255),
    Success = Color3.fromRGB(100, 220, 150),
    Border = Color3.fromRGB(60, 60, 80),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- Smooth corners
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 12)
    c.Parent = parent
    return c
end

-- Glass effect border
local function glassBorder(parent)
    local s = Instance.new("UIStroke")
    s.Color = Colors.Border
    s.Thickness = 1
    s.Transparency = 0.3
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- Smooth tween
local function tween(obj, props, duration)
    if not obj then return end
    local info = TweenInfo.new(duration or 0.3, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ============================================
-- TOGGLE - Minimal Floating Card
-- ============================================
function Components.createToggle(parent, text, callback, initialState)
    local container = Instance.new("TextButton")
    container.Name = "Toggle"
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    corner(container, 16)
    glassBorder(container)
    
    -- Gradient overlay
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    }
    gradient.Rotation = 135
    gradient.Parent = container
    
    -- Left color indicator
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 0, 1, 0)
    indicator.BackgroundColor3 = Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = container
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 16)
    indCorner.Parent = indicator
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 1, 0)
    label.Position = UDim2.new(0, 24, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.Parent = container
    
    -- Modern pill switch
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 52, 0, 28)
    switchBg.Position = UDim2.new(1, -70, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.Glass
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    corner(switchBg, 14)
    
    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = Colors.Border
    switchStroke.Thickness = 2
    switchStroke.Transparency = 0.5
    switchStroke.Parent = switchBg
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 22, 0, 22)
    switchCircle.Position = UDim2.new(0, 3, 0.5, 0)
    switchCircle.AnchorPoint = Vector2.new(0, 0.5)
    switchCircle.BackgroundColor3 = Colors.TextMuted
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = switchBg
    corner(switchCircle, 11)
    
    local state = initialState or false
    
    local function updateVisual()
        if state then
            tween(indicator, {Size = UDim2.new(0, 4, 1, 0)})
            tween(label, {TextColor3 = Colors.Text})
            tween(switchBg, {BackgroundColor3 = Colors.Accent})
            tween(switchCircle, {
                Position = UDim2.new(1, -25, 0.5, 0),
                BackgroundColor3 = Colors.Text
            })
            tween(switchStroke, {Transparency = 1})
        else
            tween(indicator, {Size = UDim2.new(0, 0, 1, 0)})
            tween(label, {TextColor3 = Colors.TextSoft})
            tween(switchBg, {BackgroundColor3 = Colors.Glass})
            tween(switchCircle, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Colors.TextMuted
            })
            tween(switchStroke, {Transparency = 0.5})
        end
    end
    
    updateVisual()
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2})
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3})
    end)
    
    container.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then task.spawn(callback, state) end
    end)
    
    return {
        Button = container,
        SetState = function(self, newState)
            if typeof(newState) == "boolean" and state ~= newState then
                state = newState
                updateVisual()
            end
        end,
        UpdateState = function(self, newState)
            if typeof(newState) == "boolean" then
                state = newState
                updateVisual()
                if callback then task.spawn(callback, state) end
            end
        end,
        GetState = function(self) return state end
    }
end

-- ============================================
-- SLIDER - Floating Card
-- ============================================
function Components.createSlider(parent, text, min, max, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 80)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 16)
    glassBorder(container)
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    }
    gradient.Rotation = 135
    gradient.Parent = container
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 0, 24)
    label.Position = UDim2.new(0, 24, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 14
    label.Parent = container
    
    -- Value bubble
    local valueBubble = Instance.new("Frame")
    valueBubble.Size = UDim2.new(0, 60, 0, 28)
    valueBubble.Position = UDim2.new(1, -84, 0, 14)
    valueBubble.BackgroundColor3 = Colors.Accent
    valueBubble.BorderSizePixel = 0
    valueBubble.Parent = container
    corner(valueBubble, 14)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or min)
    valueLabel.TextColor3 = Colors.Text
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 14
    valueLabel.Parent = valueBubble
    
    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -48, 0, 4)
    track.Position = UDim2.new(0, 24, 1, -24)
    track.BackgroundColor3 = Colors.Glass
    track.BorderSizePixel = 0
    track.Parent = container
    corner(track, 2)
    
    -- Fill
    local fill = Instance.new("Frame")
    local initialPercent = ((defaultValue or min) - min) / (max - min)
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 2)
    
    -- Handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Colors.Text
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    corner(handle, 9)
    
    local handleShadow = Instance.new("UIStroke")
    handleShadow.Color = Colors.Accent
    handleShadow.Thickness = 3
    handleShadow.Transparency = 0.5
    handleShadow.Parent = handle
    
    local value = defaultValue or min
    local dragging = false
    
    local function updateVisual(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent)
        valueLabel.Text = tostring(value)
        
        tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.15)
        tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.15)
        
        if callback then task.spawn(callback, value) end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
        end
    end)
    
    return container
end

-- ============================================
-- SECTION
-- ============================================
function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 36)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = (text or "SECTION"):upper()
    label.TextColor3 = Colors.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = section
    
    return section
end

-- ============================================
-- DIVIDER
-- ============================================
function Components.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 16)
    divider.BackgroundTransparency = 1
    divider.Parent = parent
    return divider
end

-- ============================================
-- LABEL
-- ============================================
function Components.createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 28)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or ""
    lbl.TextColor3 = Colors.TextMuted
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 12
    lbl.TextWrapped = true
    lbl.Parent = parent
    return lbl
end

_G.VertexComponents = Components
return Components
