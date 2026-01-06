-- ═══════════════════════════════════════════════════════════════════════════════
-- VERTEX HUB COMPONENTS - NEON REDESIGN EDITION
-- Integrated with Config System | Neon Color Scheme | Save/Load Support
-- ═══════════════════════════════════════════════════════════════════════════════

local Components = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════════════════════════════
-- VIBRANT NEON COLOR PALETTE (Synchronized with main script)
-- ═══════════════════════════════════════════════════════════════════════════════
local NeonColors = {
    -- Primary vibrant colors
    ElectricPurple = Color3.fromRGB(180, 70, 255),
    BrightCyan = Color3.fromRGB(0, 255, 255),
    HotPink = Color3.fromRGB(255, 20, 147),
    LimeGreen = Color3.fromRGB(50, 255, 50),
    FieryOrange = Color3.fromRGB(255, 100, 0),
    NeonBlue = Color3.fromRGB(0, 150, 255),
    VibrantYellow = Color3.fromRGB(255, 255, 0),
    
    -- UI Colors
    Background = Color3.fromRGB(10, 10, 15),
    Glass = Color3.fromRGB(20, 20, 30),
    GlassLight = Color3.fromRGB(30, 30, 45),
    GlassHover = Color3.fromRGB(40, 40, 60),
    
    -- Text
    Text = Color3.fromRGB(255, 255, 255),
    TextSoft = Color3.fromRGB(220, 220, 240),
    TextMuted = Color3.fromRGB(150, 150, 180),
    TextDim = Color3.fromRGB(80, 80, 100),
    
    -- Accent gradients
    Accent1 = Color3.fromRGB(180, 70, 255),  -- Purple
    Accent2 = Color3.fromRGB(0, 255, 255),   -- Cyan
    Accent3 = Color3.fromRGB(255, 20, 147),  -- Pink
    
    -- Special effects
    Glow = Color3.fromRGB(100, 200, 255),
    Outline = Color3.fromRGB(0, 200, 255),
    Shadow = Color3.fromRGB(0, 0, 0)
}

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- UTILITY FUNCTIONS
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀

-- Create rounded corners
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- Create neon glow effect
local function glowEffect(parent, color, thickness)
    local glow = Instance.new("UIStroke")
    glow.Color = color or NeonColors.Glow
    glow.Thickness = thickness or 2
    glow.Transparency = 0.3
    glow.Parent = parent
    return glow
end

-- Create neon border
local function neonBorder(parent, color, thickness)
    local border = Instance.new("UIStroke")
    border.Color = color or NeonColors.Outline
    border.Thickness = thickness or 1
    border.Transparency = 0.5
    border.Parent = parent
    return border
end

-- Smooth tween animation
local function tween(obj, props, duration, style, direction)
    if not obj then return end
    local info = TweenInfo.new(
        duration or 0.25,
        style or Enum.EasingStyle.Cubic,
        direction or Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Dynamic gradient creation
local function createAnimatedGradient(parent, colors, speed)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, colors[1] or NeonColors.ElectricPurple),
        ColorSequenceKeypoint.new(0.5, colors[2] or NeonColors.BrightCyan),
        ColorSequenceKeypoint.new(1, colors[3] or NeonColors.HotPink)
    }
    gradient.Rotation = 45
    gradient.Parent = parent
    
    -- Animate the gradient if speed is provided
    if speed then
        local connection
        connection = RunService.RenderStepped:Connect(function(dt)
            gradient.Rotation = gradient.Rotation + (speed * dt * 10)
            if gradient.Rotation > 360 then
                gradient.Rotation = 0
            end
        end)
        
        -- Cleanup when parent is removed
        parent:GetPropertyChangedSignal("Parent"):Connect(function()
            if not parent.Parent then
                connection:Disconnect()
            end
        end)
    end
    
    return gradient
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- TOGGLE COMPONENT WITH CONFIG INTEGRATION
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createToggle(parent, text, callback, initialState, configKey, saveCallback)
    -- Create container
    local button = Instance.new("TextButton")
    button.Name = "Toggle_" .. (text or "Toggle"):gsub("%s+", "_")
    button.Size = UDim2.new(1, -10, 0, 36)
    button.BackgroundColor3 = NeonColors.Glass
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = parent
    
    -- Apply styling
    corner(button, 8)
    glowEffect(button, NeonColors.ElectricPurple)
    neonBorder(button, NeonColors.BrightCyan)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = NeonColors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = button
    
    -- Toggle switch
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 50, 0, 24)
    toggleFrame.Position = UDim2.new(1, -60, 0.5, 0)
    toggleFrame.AnchorPoint = Vector2.new(0, 0.5)
    toggleFrame.BackgroundColor3 = NeonColors.Glass
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = button
    
    corner(toggleFrame, 12)
    glowEffect(toggleFrame)
    
    -- Toggle knob
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, 0)
    toggleKnob.AnchorPoint = Vector2.new(0, 0.5)
    toggleKnob.BackgroundColor3 = NeonColors.BrightCyan
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleFrame
    
    corner(toggleKnob, 10)
    glowEffect(toggleKnob, NeonColors.BrightCyan, 3)
    
    -- State management
    local state = initialState or false
    local configKey = configKey
    local saveCallback = saveCallback
    
    -- Update visual state
    local function updateVisual()
        if state then
            tween(toggleKnob, {
                Position = UDim2.new(1, -22, 0.5, 0),
                BackgroundColor3 = NeonColors.LimeGreen
            }, 0.2)
            tween(toggleFrame, {BackgroundColor3 = NeonColors.GlassLight}, 0.2)
            tween(label, {TextColor3 = NeonColors.Text}, 0.2)
            tween(button, {BackgroundTransparency = 0.1}, 0.2)
            glowEffect(button, NeonColors.LimeGreen)
        else
            tween(toggleKnob, {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = NeonColors.BrightCyan
            }, 0.2)
            tween(toggleFrame, {BackgroundColor3 = NeonColors.Glass}, 0.2)
            tween(label, {TextColor3 = NeonColors.TextSoft}, 0.2)
            tween(button, {BackgroundTransparency = 0.3}, 0.2)
            glowEffect(button, NeonColors.ElectricPurple)
        end
    end
    
    -- Toggle handler
    local function doToggle()
        state = not state
        updateVisual()
        if callback then 
            task.spawn(callback, state)
        end
        if saveCallback then
            saveCallback()
        end
    end
    
    -- Initialize
    updateVisual()
    
    -- Click handler
    button.MouseButton1Click:Connect(doToggle)
    
    -- Hover effects
    button.MouseEnter:Connect(function()
        if not state then
            tween(button, {BackgroundTransparency = 0.2}, 0.15)
        end
    end)
    
    button.MouseLeave:Connect(function()
        if not state then
            tween(button, {BackgroundTransparency = 0.3}, 0.15)
        end
    end)
    
    -- Return toggle object
    return {
        Button = button,
        SetState = function(self, newState)
            if typeof(newState) == "boolean" then
                state = newState
                updateVisual()
            end
        end,
        UpdateState = function(self, newState)
            if typeof(newState) == "boolean" then
                state = newState
                updateVisual()
                if callback then 
                    task.spawn(callback, state)
                end
                if saveCallback then
                    saveCallback()
                end
            end
        end,
        GetState = function(self)
            return state
        end,
        Toggle = doToggle
    }
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- SLIDER COMPONENT WITH CONFIG INTEGRATION
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createSlider(parent, text, min, max, defaultValue, callback, configKey, saveCallback)
    -- Create container
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, -10, 0, 60)
    container.BackgroundColor3 = NeonColors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    -- Apply styling
    corner(container, 8)
    glowEffect(container, NeonColors.HotPink)
    neonBorder(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 5)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = NeonColors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Parent = container
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 50, 0, 20)
    valueLabel.Position = UDim2.new(1, -60, 0, 5)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or min)
    valueLabel.TextColor3 = NeonColors.BrightCyan
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.Parent = container
    
    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -20)
    track.BackgroundColor3 = NeonColors.GlassLight
    track.BorderSizePixel = 0
    track.Parent = container
    
    corner(track, 3)
    glowEffect(track, NeonColors.FieryOrange)
    
    -- Fill
    local initialPercent = ((defaultValue or min) - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = NeonColors.FieryOrange
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    corner(fill, 3)
    
    -- Handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = NeonColors.BrightCyan
    handle.BorderSizePixel = 0
    handle.Parent = track
    
    corner(handle, 8)
    glowEffect(handle, NeonColors.BrightCyan, 3)
    
    -- State
    local value = defaultValue or min
    local dragging = false
    local configKey = configKey
    local saveCallback = saveCallback
    
    -- Update visual and trigger callbacks
    local function updateVisual(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent)
        valueLabel.Text = tostring(value)
        
        tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.1)
        
        if callback then 
            task.spawn(callback, value)
        end
        if saveCallback then
            saveCallback()
        end
    end
    
    -- Input handling
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
    
    -- Hover effects
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3}, 0.15)
    end)
    
    -- Return slider object
    return {
        Container = container,
        SetValue = function(self, newValue)
            local percent = (math.clamp(newValue, min, max) - min) / (max - min)
            updateVisual(percent)
        end,
        GetValue = function(self)
            return value
        end,
        UpdateValue = function(self, newValue)
            local percent = (math.clamp(newValue, min, max) - min) / (max - min)
            value = newValue
            valueLabel.Text = tostring(value)
            tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
            tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.1)
        end
    }
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- SECTION HEADER
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. (text or ""):gsub("%s+", "")
    section.Size = UDim2.new(1, -10, 0, 28)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    -- Animated gradient line
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 2)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.BackgroundColor3 = NeonColors.ElectricPurple
    line.BackgroundTransparency = 0.3
    line.BorderSizePixel = 0
    line.Parent = section
    
    corner(line, 1)
    createAnimatedGradient(line, {NeonColors.ElectricPurple, NeonColors.BrightCyan, NeonColors.HotPink}, 0.5)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -20, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = "| " .. (text or "SECTION") .. " |"
    label.TextColor3 = NeonColors.ElectricPurple
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Font = Enum.Font.GothamBold
    label.TextSize = 12
    label.Parent = section
    
    return section
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- LABEL COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = NeonColors.TextMuted
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextWrapped = true
    label.Parent = parent
    return label
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- DIVIDER COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -20, 0, 1)
    divider.Position = UDim2.new(0, 10, 0, 0)
    divider.BackgroundColor3 = NeonColors.ElectricPurple
    divider.BackgroundTransparency = 0.5
    divider.BorderSizePixel = 0
    divider.Parent = parent
    return divider
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- BUTTON COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createButton(parent, text, callback, color)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.BackgroundColor3 = color or NeonColors.ElectricPurple
    btn.BackgroundTransparency = 0.3
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text or "Button"
    btn.TextColor3 = NeonColors.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    
    corner(btn, 8)
    glowEffect(btn, color or NeonColors.ElectricPurple)
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.1}, 0.15)
        tween(btn, {TextColor3 = NeonColors.Text}, 0.15)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.3}, 0.15)
        tween(btn, {TextColor3 = NeonColors.Text}, 0.15)
    end)
    
    -- Click handler
    btn.MouseButton1Click:Connect(function()
        tween(btn, {BackgroundTransparency = 0.05}, 0.1)
        task.delay(0.1, function()
            tween(btn, {BackgroundTransparency = 0.3}, 0.15)
        end)
        if callback then 
            task.spawn(callback)
        end
    end)
    
    return btn
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- DROPDOWN COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createDropdown(parent, text, options, defaultIndex, callback, saveCallback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 44)
    container.BackgroundColor3 = NeonColors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = parent
    
    corner(container, 8)
    glowEffect(container, NeonColors.NeonBlue)
    neonBorder(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Dropdown"
    label.TextColor3 = NeonColors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Dropdown button
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.45, 0, 0, 30)
    dropBtn.Position = UDim2.new(1, -10, 0.5, 0)
    dropBtn.AnchorPoint = Vector2.new(1, 0.5)
    dropBtn.BackgroundColor3 = NeonColors.GlassLight
    dropBtn.BackgroundTransparency = 0.2
    dropBtn.BorderSizePixel = 0
    dropBtn.AutoButtonColor = false
    dropBtn.Text = options[defaultIndex or 1] or "Select"
    dropBtn.TextColor3 = NeonColors.Text
    dropBtn.Font = Enum.Font.GothamMedium
    dropBtn.TextSize = 11
    dropBtn.Parent = container
    
    corner(dropBtn, 6)
    glowEffect(dropBtn, NeonColors.NeonBlue)
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = NeonColors.TextMuted
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = dropBtn
    
    -- Options container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(0.45, 0, 0, 0)
    optionsFrame.Position = UDim2.new(1, -10, 1, 4)
    optionsFrame.AnchorPoint = Vector2.new(1, 0)
    optionsFrame.BackgroundColor3 = NeonColors.Glass
    optionsFrame.BackgroundTransparency = 0.1
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ClipsDescendants = true
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = container
    
    corner(optionsFrame, 8)
    glowEffect(optionsFrame, NeonColors.NeonBlue)
    
    local optionsLayout = Instance.new("UIListLayout")
    optionsLayout.Padding = UDim.new(0, 2)
    optionsLayout.Parent = optionsFrame
    
    local optionsPadding = Instance.new("UIPadding")
    optionsPadding.PaddingTop = UDim.new(0, 4)
    optionsPadding.PaddingBottom = UDim.new(0, 4)
    optionsPadding.PaddingLeft = UDim.new(0, 4)
    optionsPadding.PaddingRight = UDim.new(0, 4)
    optionsPadding.Parent = optionsFrame
    
    local selectedIndex = defaultIndex or 1
    local isOpen = false
    local saveCallback = saveCallback
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundColor3 = NeonColors.GlassLight
        optBtn.BackgroundTransparency = 0.5
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        optBtn.Text = option
        optBtn.TextColor3 = i == selectedIndex and NeonColors.BrightCyan or NeonColors.TextSoft
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextSize = 11
        optBtn.ZIndex = 11
        optBtn.Parent = optionsFrame
        
        corner(optBtn, 6)
        
        optBtn.MouseEnter:Connect(function()
            tween(optBtn, {BackgroundTransparency = 0.2}, 0.15)
        end)
        
        optBtn.MouseLeave:Connect(function()
            tween(optBtn, {BackgroundTransparency = 0.5}, 0.15)
        end)
        
        optBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            dropBtn.Text = option
            
            -- Update all option colors
            for _, child in ipairs(optionsFrame:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = child.Text == option and NeonColors.BrightCyan or NeonColors.TextSoft
                end
            end
            
            -- Close dropdown
            isOpen = false
            tween(optionsFrame, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.2)
            tween(arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function()
                optionsFrame.Visible = false
            end)
            
            if callback then 
                task.spawn(callback, option, i)
            end
            if saveCallback then
                saveCallback()
            end
        end)
    end
    
    -- Toggle dropdown
    dropBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            optionsFrame.Visible = true
            local height = (#options * 30) + 8
            tween(optionsFrame, {Size = UDim2.new(0.45, 0, 0, math.min(height, 150))}, 0.25, Enum.EasingStyle.Back)
            tween(arrow, {Rotation = 180}, 0.25)
        else
            tween(optionsFrame, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.2)
            tween(arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function()
                optionsFrame.Visible = false
            end)
        end
    end)
    
    -- Hover effects
    dropBtn.MouseEnter:Connect(function()
        tween(dropBtn, {BackgroundTransparency = 0.1}, 0.15)
    end)
    
    dropBtn.MouseLeave:Connect(function()
        tween(dropBtn, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3}, 0.15)
    end)
    
    return {
        Container = container,
        SetSelected = function(self, index)
            if options[index] then
                selectedIndex = index
                dropBtn.Text = options[index]
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.TextColor3 = child.Text == options[index] and NeonColors.BrightCyan or NeonColors.TextSoft
                    end
                end
            end
        end,
        GetSelected = function(self)
            return options[selectedIndex], selectedIndex
        end
    }
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- TEXT INPUT COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createTextInput(parent, text, placeholder, callback, saveCallback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 44)
    container.BackgroundColor3 = NeonColors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    glowEffect(container, NeonColors.FieryOrange)
    neonBorder(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Input"
    label.TextColor3 = NeonColors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.55, -10, 0, 30)
    inputBox.Position = UDim2.new(1, -10, 0.5, 0)
    inputBox.AnchorPoint = Vector2.new(1, 0.5)
    inputBox.BackgroundColor3 = NeonColors.GlassLight
    inputBox.BackgroundTransparency = 0.2
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = placeholder or "Enter text..."
    inputBox.PlaceholderColor3 = NeonColors.TextMuted
    inputBox.TextColor3 = NeonColors.Text
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.TextSize = 12
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    
    corner(inputBox, 6)
    glowEffect(inputBox, NeonColors.BrightCyan)
    
    inputBox.Focused:Connect(function()
        tween(inputBox, {BackgroundTransparency = 0.1}, 0.15)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        tween(inputBox, {BackgroundTransparency = 0.2}, 0.15)
        if callback then 
            task.spawn(callback, inputBox.Text, enterPressed)
        end
        if saveCallback then
            saveCallback()
        end
    end)
    
    -- Hover effects
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3}, 0.15)
    end)
    
    return {
        Container = container,
        SetText = function(self, newText)
            inputBox.Text = newText
        end,
        GetText = function(self)
            return inputBox.Text
        end
    }
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- COLOR PICKER COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createColorPicker(parent, text, defaultColor, callback, saveCallback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 44)
    container.BackgroundColor3 = NeonColors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    glowEffect(container, NeonColors.VibrantYellow)
    neonBorder(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Color"
    label.TextColor3 = NeonColors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Color preview button
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 50, 0, 28)
    colorBtn.Position = UDim2.new(1, -60, 0.5, 0)
    colorBtn.AnchorPoint = Vector2.new(0, 0.5)
    colorBtn.BackgroundColor3 = defaultColor or NeonColors.ElectricPurple
    colorBtn.BorderSizePixel = 0
    colorBtn.AutoButtonColor = false
    colorBtn.Text = ""
    colorBtn.Parent = container
    
    corner(colorBtn, 6)
    glowEffect(colorBtn, defaultColor or NeonColors.ElectricPurple, 2)
    
    local currentColor = defaultColor or NeonColors.ElectricPurple
    
    -- Simple color selection popup
    local colorFrame = Instance.new("Frame")
    colorFrame.Size = UDim2.new(0, 150, 0, 0)
    colorFrame.Position = UDim2.new(1, -60, 1, 4)
    colorFrame.AnchorPoint = Vector2.new(1, 0)
    colorFrame.BackgroundColor3 = NeonColors.Glass
    colorFrame.BackgroundTransparency = 0.1
    colorFrame.BorderSizePixel = 0
    colorFrame.ClipsDescendants = true
    colorFrame.Visible = false
    colorFrame.ZIndex = 10
    colorFrame.Parent = container
    
    corner(colorFrame, 8)
    glowEffect(colorFrame)
    
    local colorGrid = Instance.new("UIGridLayout")
    colorGrid.CellSize = UDim2.new(0, 32, 0, 32)
    colorGrid.CellPadding = UDim2.new(0, 6, 0, 6)
    colorGrid.Parent = colorFrame
    
    local colorPadding = Instance.new("UIPadding")
    colorPadding.PaddingTop = UDim.new(0, 8)
    colorPadding.PaddingBottom = UDim.new(0, 8)
    colorPadding.PaddingLeft = UDim.new(0, 8)
    colorPadding.PaddingRight = UDim.new(0, 8)
    colorPadding.Parent = colorFrame
    
    local presetColors = {
        NeonColors.ElectricPurple,
        NeonColors.BrightCyan,
        NeonColors.HotPink,
        NeonColors.LimeGreen,
        NeonColors.FieryOrange,
        NeonColors.NeonBlue,
        NeonColors.VibrantYellow,
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(100, 100, 100)
    }
    
    local isOpen = false
    local saveCallback = saveCallback
    
    for _, color in ipairs(presetColors) do
        local colorBtn = Instance.new("TextButton")
        colorBtn.Size = UDim2.new(0, 32, 0, 32)
        colorBtn.BackgroundColor3 = color
        colorBtn.BorderSizePixel = 0
        colorBtn.AutoButtonColor = false
        colorBtn.Text = ""
        colorBtn.ZIndex = 11
        colorBtn.Parent = colorFrame
        
        corner(colorBtn, 6)
        
        colorBtn.MouseButton1Click:Connect(function()
            currentColor = color
            container.ColorBtn.BackgroundColor3 = color
            glowEffect(container.ColorBtn, color, 2)
            
            isOpen = false
            tween(colorFrame, {Size = UDim2.new(0, 150, 0, 0)}, 0.2)
            task.delay(0.2, function()
                colorFrame.Visible = false
            end)
            
            if callback then 
                task.spawn(callback, color)
            end
            if saveCallback then
                saveCallback()
            end
        end)
    end
    
    -- Store reference to color button
    container.ColorBtn = colorBtn
    
    -- Toggle color picker
    colorBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            colorFrame.Visible = true
            tween(colorFrame, {Size = UDim2.new(0, 150, 0, 100)}, 0.25, Enum.EasingStyle.Back)
        else
            tween(colorFrame, {Size = UDim2.new(0, 150, 0, 0)}, 0.2)
            task.delay(0.2, function()
                colorFrame.Visible = false
            end)
        end
    end)
    
    -- Hover effects
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3}, 0.15)
    end)
    
    return {
        Container = container,
        SetColor = function(self, newColor)
            currentColor = newColor
            colorBtn.BackgroundColor3 = newColor
            glowEffect(colorBtn, newColor, 2)
        end,
        GetColor = function(self)
            return currentColor
        end
    }
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- KEYBIND COMPONENT (For configuring menu toggle key)
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createKeybind(parent, text, currentKey, callback, saveCallback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 44)
    container.BackgroundColor3 = NeonColors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    glowEffect(container, NeonColors.NeonBlue)
    neonBorder(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Keybind"
    label.TextColor3 = NeonColors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Key display button
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 80, 0, 28)
    keyBtn.Position = UDim2.new(1, -90, 0.5, 0)
    keyBtn.AnchorPoint = Vector2.new(0, 0.5)
    keyBtn.BackgroundColor3 = NeonColors.GlassLight
    keyBtn.BackgroundTransparency = 0.2
    keyBtn.BorderSizePixel = 0
    keyBtn.AutoButtonColor = false
    keyBtn.Text = currentKey and tostring(currentKey):gsub("Enum.KeyCode.", "") or "None"
    keyBtn.TextColor3 = NeonColors.Text
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11
    keyBtn.Parent = container
    
    corner(keyBtn, 6)
    glowEffect(keyBtn, NeonColors.BrightCyan)
    
    local waitingForInput = false
    local connection = nil
    local saveCallback = saveCallback
    
    local function startListening()
        if waitingForInput then return end
        waitingForInput = true
        
        local originalText = keyBtn.Text
        keyBtn.Text = "..."
        tween(keyBtn, {BackgroundTransparency = 0.1}, 0.15)
        tween(keyBtn, {TextColor3 = NeonColors.LimeGreen}, 0.15)
        
        connection = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                waitingForInput = false
                connection:Disconnect()
                
                if input.KeyCode == Enum.KeyCode.Escape then
                    keyBtn.Text = originalText
                elseif input.KeyCode == Enum.KeyCode.Backspace then
                    keyBtn.Text = "None"
                    if callback then 
                        task.spawn(callback, nil)
                    end
                    if saveCallback then
                        saveCallback()
                    end
                else
                    keyBtn.Text = tostring(input.KeyCode):gsub("Enum.KeyCode.", "")
                    if callback then 
                        task.spawn(callback, input.KeyCode)
                    end
                    if saveCallback then
                        saveCallback()
                    end
                end
                
                tween(keyBtn, {BackgroundTransparency = 0.2}, 0.15)
                tween(keyBtn, {TextColor3 = NeonColors.Text}, 0.15)
            end
        end)
        
        -- Timeout after 5 seconds
        task.spawn(function()
            task.wait(5)
            if waitingForInput then
                waitingForInput = false
                if connection then 
                    connection:Disconnect() 
                end
                keyBtn.Text = originalText
                tween(keyBtn, {BackgroundTransparency = 0.2}, 0.15)
                tween(keyBtn, {TextColor3 = NeonColors.Text}, 0.15)
            end
        end)
    end
    
    keyBtn.MouseButton1Click:Connect(startListening)
    
    -- Hover effects
    keyBtn.MouseEnter:Connect(function()
        if not waitingForInput then
            tween(keyBtn, {BackgroundTransparency = 0.1}, 0.15)
        end
    end)
    
    keyBtn.MouseLeave:Connect(function()
        if not waitingForInput then
            tween(keyBtn, {BackgroundTransparency = 0.2}, 0.15)
        end
    end)
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3}, 0.15)
    end)
    
    return {
        Container = container,
        UpdateKey = function(self, newKey)
            keyBtn.Text = newKey and tostring(newKey):gsub("Enum.KeyCode.", "") or "None"
        end,
        GetKey = function(self)
            return keyBtn.Text
        end
    }
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- INFO BOX COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createInfoBox(parent, text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -10, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    glowEffect(container, Color3.fromRGB(60, 80, 120))
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "ℹ"
    icon.TextColor3 = NeonColors.BrightCyan
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 16
    icon.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, -12)
    label.Position = UDim2.new(0, 42, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text or "Information"
    label.TextColor3 = NeonColors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextWrapped = true
    label.Parent = container
    
    return container
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- EXPANDABLE CATEGORY COMPONENT
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
function Components.createExpandableCategory(parent, title, icon, color)
    local categoryId = title:gsub("%s+", "_"):upper()
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Category_" .. categoryId
    container.Size = UDim2.new(1, -10, 0, 52)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.Parent = parent
    
    -- Header button
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundColor3 = NeonColors.Glass
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Text = ""
    header.Parent = container
    
    corner(header, 10)
    glowEffect(header, color or NeonColors.ElectricPurple)
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 4, 0.7, 0)
    accentBar.Position = UDim2.new(0, 8, 0.15, 0)
    accentBar.BackgroundColor3 = color or NeonColors.ElectricPurple
    accentBar.BorderSizePixel = 0
    accentBar.Parent = header
    
    corner(accentBar, 4)
    createAnimatedGradient(accentBar, {color or NeonColors.ElectricPurple, NeonColors.BrightCyan, NeonColors.HotPink}, 0.3)
    
    -- Icon
    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 32, 0, 32)
    iconBg.Position = UDim2.new(0, 20, 0.5, 0)
    iconBg.AnchorPoint = Vector2.new(0, 0.5)
    iconBg.BackgroundColor3 = color or NeonColors.ElectricPurple
    iconBg.BackgroundTransparency = 0.8
    iconBg.BorderSizePixel = 0
    iconBg.Parent = header
    
    corner(iconBg, 8)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "⚡"
    iconLabel.TextColor3 = color or NeonColors.ElectricPurple
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 16
    iconLabel.Parent = iconBg
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -140, 1, 0)
    titleLabel.Position = UDim2.new(0, 60, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "CATEGORY"
    titleLabel.TextColor3 = NeonColors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.Parent = header
    
    -- Expand/collapse indicator
    local expandIcon = Instance.new("TextLabel")
    expandIcon.Name = "ExpandIcon"
    expandIcon.Size = UDim2.new(0, 30, 0, 30)
    expandIcon.Position = UDim2.new(1, -40, 0.5, 0)
    expandIcon.AnchorPoint = Vector2.new(0, 0.5)
    expandIcon.BackgroundTransparency = 1
    expandIcon.Text = "+"
    expandIcon.TextColor3 = color or NeonColors.ElectricPurple
    expandIcon.Font = Enum.Font.GothamBold
    expandIcon.TextSize = 20
    expandIcon.Parent = header
    
    -- Content container
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 56)
    content.BackgroundColor3 = NeonColors.Glass
    content.BackgroundTransparency = 0.2
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Visible = false
    content.Parent = container
    
    corner(content, 8)
    glowEffect(content, color or NeonColors.ElectricPurple)
    
    -- Inner content frame
    local contentInner = Instance.new("Frame")
    contentInner.Name = "Inner"
    contentInner.Size = UDim2.new(1, 0, 0, 0)
    contentInner.BackgroundTransparency = 1
    contentInner.AutomaticSize = Enum.AutomaticSize.Y
    contentInner.Parent = content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentInner
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 10)
    contentPadding.PaddingRight = UDim.new(0, 10)
    contentPadding.Parent = contentInner
    
    -- State
    local isExpanded = false
    local animating = false
    
    -- Calculate content height
    local function getContentHeight()
        local totalHeight = 20 -- Padding
        for _, child in ipairs(contentInner:GetChildren()) do
            if child:IsA("GuiObject") and child.Visible then
                totalHeight = totalHeight + child.AbsoluteSize.Y + 6
            end
        end
        return math.max(totalHeight, 50)
    end
    
    -- Refresh size
    local function refreshSize()
        if isExpanded and not animating then
            local height = getContentHeight()
            content.Size = UDim2.new(1, -16, 0, height)
            container.Size = UDim2.new(1, -10, 0, 56 + height)
        end
    end
    
    -- Toggle function
    local function toggle()
        if animating then return end
        animating = true
        isExpanded = not isExpanded
        
        if isExpanded then
            -- Expand animation
            content.Visible = true
            local height = getContentHeight()
            
            tween(content, {Size = UDim2.new(1, -16, 0, height)}, 0.3, Enum.EasingStyle.Back)
            tween(container, {Size = UDim2.new(1, -10, 0, 56 + height)}, 0.3, Enum.EasingStyle.Back)
            tween(expandIcon, {Rotation = 45, TextColor3 = NeonColors.BrightCyan}, 0.25)
            tween(header, {BackgroundTransparency = 0.1}, 0.25)
            tween(accentBar, {Size = UDim2.new(0, 4, 0.85, 0)}, 0.25)
            tween(titleLabel, {TextColor3 = color or NeonColors.ElectricPurple}, 0.25)
            
            task.delay(0.3, function() 
                animating = false 
            end)
        else
            -- Collapse animation
            tween(expandIcon, {Rotation = 0, TextColor3 = color or NeonColors.ElectricPurple}, 0.25)
            tween(header, {BackgroundTransparency = 0.2}, 0.25)
            tween(accentBar, {Size = UDim2.new(0, 4, 0.7, 0)}, 0.25)
            tween(titleLabel, {TextColor3 = NeonColors.Text}, 0.25)
            tween(content, {Size = UDim2.new(1, -16, 0, 0)}, 0.25)
            tween(container, {Size = UDim2.new(1, -10, 0, 52)}, 0.25)
            
            task.delay(0.25, function()
                content.Visible = false
                animating = false
            end)
        end
    end
    
    -- Click handler
    header.MouseButton1Click:Connect(toggle)
    
    -- Hover effects
    header.MouseEnter:Connect(function()
        if not isExpanded then
            tween(header, {BackgroundTransparency = 0.15}, 0.15)
        end
    end)
    
    header.MouseLeave:Connect(function()
        if not isExpanded then
            tween(header, {BackgroundTransparency = 0.2}, 0.15)
        end
    end)
    
    -- Listen for content changes
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        task.defer(refreshSize)
    end)
    
    return {
        Container = container,
        Content = contentInner,
        Header = header,
        Toggle = toggle,
        Refresh = refreshSize,
        IsExpanded = function() 
            return isExpanded 
        end,
        Expand = function()
            if not isExpanded then
                toggle()
            end
        end,
        Collapse = function()
            if isExpanded then
                toggle()
            end
        end
    }
end

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- EXPOSE COLORS AND UTILITIES
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
Components.Colors = NeonColors
Components.Tween = tween
Components.Corner = corner
Components.GlowEffect = glowEffect
Components.NeonBorder = neonBorder
Components.CreateAnimatedGradient = createAnimatedGradient

-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
-- GLOBAL REGISTRATION
-- ␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀␀
_G.VertexComponents = Components

return Components
