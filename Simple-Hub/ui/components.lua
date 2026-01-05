-- components_redesigned.lua - CYBERPUNK HEXAGONAL THEME
-- Modern card-based UI with neon accents and futuristic design

local Components = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Cyberpunk Color Palette
local Colors = {
    Background = Color3.fromRGB(10, 12, 18),
    Card = Color3.fromRGB(18, 22, 32),
    CardHover = Color3.fromRGB(22, 28, 40),
    Surface = Color3.fromRGB(25, 30, 42),
    Elevated = Color3.fromRGB(30, 36, 50),
    Border = Color3.fromRGB(50, 60, 80),
    BorderGlow = Color3.fromRGB(80, 100, 140),
    Text = Color3.fromRGB(230, 235, 245),
    TextDim = Color3.fromRGB(150, 160, 180),
    TextMuted = Color3.fromRGB(100, 110, 130),
    Primary = Color3.fromRGB(0, 200, 255),      -- Cyan neon
    Secondary = Color3.fromRGB(200, 50, 255),   -- Purple neon
    Accent = Color3.fromRGB(255, 0, 200),       -- Pink neon
    Success = Color3.fromRGB(0, 255, 150),
    Warning = Color3.fromRGB(255, 200, 0),
    Error = Color3.fromRGB(255, 50, 100),
    Glow = Color3.fromRGB(0, 150, 255)
}

-- Helper: Create hexagonal corner approximation
local function createHexCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- Helper: Create glowing border
local function createGlowBorder(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.BorderGlow
    s.Thickness = 1
    s.Transparency = 0.3
    s.Parent = parent
    
    -- Add glow effect
    local glow = Instance.new("UIStroke")
    glow.Color = color or Colors.Glow
    glow.Thickness = 2
    glow.Transparency = 0.8
    glow.Parent = parent
    
    return s
end

-- Helper: Create gradient overlay
local function createGradient(parent, colors, rotation)
    local gradient = Instance.new("UIGradient")
    gradient.Color = colors or ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(1, Colors.Secondary)
    }
    gradient.Rotation = rotation or 45
    gradient.Parent = parent
    return gradient
end

-- Smooth tween
local function tween(obj, props, duration)
    if not obj then return end
    local info = TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ============================================
-- TOGGLE COMPONENT - Cyberpunk Card Style
-- ============================================
function Components.createToggle(parent, text, callback, initialState)
    local container = Instance.new("TextButton")
    container.Name = "Toggle_" .. (text or "Unknown")
    container.Size = UDim2.new(1, -12, 0, 50)
    container.BackgroundColor3 = Colors.Card
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    createHexCorner(container, 10)
    createGlowBorder(container, Colors.BorderGlow)
    
    -- Hover glow effect
    local hoverGlow = Instance.new("Frame")
    hoverGlow.Name = "HoverGlow"
    hoverGlow.Size = UDim2.new(1, 0, 1, 0)
    hoverGlow.BackgroundColor3 = Colors.Primary
    hoverGlow.BackgroundTransparency = 1
    hoverGlow.BorderSizePixel = 0
    hoverGlow.ZIndex = 0
    hoverGlow.Parent = container
    createHexCorner(hoverGlow, 10)
    
    -- Left accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 4, 0, 0)
    accentBar.Position = UDim2.new(0, 0, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = Colors.Primary
    accentBar.BorderSizePixel = 0
    accentBar.Parent = container
    createHexCorner(accentBar, 2)
    
    -- Icon background (hexagonal feel)
    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 32, 0, 32)
    iconBg.Position = UDim2.new(0, 15, 0.5, 0)
    iconBg.AnchorPoint = Vector2.new(0, 0.5)
    iconBg.BackgroundColor3 = Colors.Surface
    iconBg.BorderSizePixel = 0
    iconBg.Parent = container
    createHexCorner(iconBg, 6)
    
    local iconText = Instance.new("TextLabel")
    iconText.Size = UDim2.new(1, 0, 1, 0)
    iconText.BackgroundTransparency = 1
    iconText.Text = "●"
    iconText.TextColor3 = Colors.TextMuted
    iconText.Font = Enum.Font.GothamBold
    iconText.TextSize = 16
    iconText.Parent = iconBg
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -130, 1, 0)
    label.Position = UDim2.new(0, 55, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Colors.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Modern switch
    local switchBg = Instance.new("Frame")
    switchBg.Name = "Switch"
    switchBg.Size = UDim2.new(0, 48, 0, 24)
    switchBg.Position = UDim2.new(1, -60, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.Surface
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    createHexCorner(switchBg, 12)
    
    local switchHandle = Instance.new("Frame")
    switchHandle.Name = "Handle"
    switchHandle.Size = UDim2.new(0, 18, 0, 18)
    switchHandle.Position = UDim2.new(0, 3, 0.5, 0)
    switchHandle.AnchorPoint = Vector2.new(0, 0.5)
    switchHandle.BackgroundColor3 = Colors.TextMuted
    switchHandle.BorderSizePixel = 0
    switchHandle.Parent = switchBg
    createHexCorner(switchHandle, 9)
    
    -- Add glow to handle
    local handleGlow = Instance.new("UIStroke")
    handleGlow.Color = Colors.Primary
    handleGlow.Thickness = 2
    handleGlow.Transparency = 1
    handleGlow.Parent = switchHandle
    
    -- State
    local state = initialState or false
    
    -- Update visual state
    local function updateVisual()
        if state then
            tween(container, {BackgroundColor3 = Colors.CardHover})
            tween(label, {TextColor3 = Colors.Text})
            tween(accentBar, {Size = UDim2.new(0, 4, 1, -10)})
            tween(switchBg, {BackgroundColor3 = Colors.Primary})
            tween(switchHandle, {
                Position = UDim2.new(1, -21, 0.5, 0),
                BackgroundColor3 = Color3.new(1, 1, 1)
            })
            tween(handleGlow, {Transparency = 0.5})
            tween(iconText, {TextColor3 = Colors.Primary})
            tween(iconBg, {BackgroundColor3 = Colors.Elevated})
        else
            tween(container, {BackgroundColor3 = Colors.Card})
            tween(label, {TextColor3 = Colors.TextDim})
            tween(accentBar, {Size = UDim2.new(0, 4, 0, 0)})
            tween(switchBg, {BackgroundColor3 = Colors.Surface})
            tween(switchHandle, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Colors.TextMuted
            })
            tween(handleGlow, {Transparency = 1})
            tween(iconText, {TextColor3 = Colors.TextMuted})
            tween(iconBg, {BackgroundColor3 = Colors.Surface})
        end
    end
    
    -- Initialize
    updateVisual()
    
    -- Events
    container.MouseEnter:Connect(function()
        tween(hoverGlow, {BackgroundTransparency = 0.95})
    end)
    
    container.MouseLeave:Connect(function()
        tween(hoverGlow, {BackgroundTransparency = 1})
    end)
    
    container.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then
            task.spawn(callback, state)
        end
    end)
    
    local toggleObject = {
        Button = container,
        Label = label,
        SetState = function(self, newState)
            if typeof(newState) ~= "boolean" then return end
            if state ~= newState then
                state = newState
                updateVisual()
            end
        end,
        UpdateState = function(self, newState)
            if typeof(newState) ~= "boolean" then return end
            state = newState
            updateVisual()
            if callback then
                task.spawn(callback, state)
            end
        end,
        GetState = function(self)
            return state
        end
    }
    
    return toggleObject
end

-- ============================================
-- SLIDER COMPONENT - Cyberpunk Style
-- ============================================
function Components.createSlider(parent, text, min, max, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. (text or "Unknown")
    container.Size = UDim2.new(1, -12, 0, 70)
    container.BackgroundColor3 = Colors.Card
    container.BorderSizePixel = 0
    container.Parent = parent
    
    createHexCorner(container, 10)
    createGlowBorder(container, Colors.BorderGlow)
    
    -- Header area
    local headerBg = Instance.new("Frame")
    headerBg.Size = UDim2.new(1, 0, 0, 30)
    headerBg.BackgroundColor3 = Colors.Surface
    headerBg.BackgroundTransparency = 0.5
    headerBg.BorderSizePixel = 0
    headerBg.Parent = container
    createHexCorner(headerBg, 10)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -100, 0, 30)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = Colors.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Value display with background
    local valueBg = Instance.new("Frame")
    valueBg.Size = UDim2.new(0, 70, 0, 22)
    valueBg.Position = UDim2.new(1, -80, 0, 4)
    valueBg.BackgroundColor3 = Colors.Elevated
    valueBg.BorderSizePixel = 0
    valueBg.Parent = container
    createHexCorner(valueBg, 6)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or min)
    valueLabel.TextColor3 = Colors.Primary
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.Parent = valueBg
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -30, 0, 8)
    track.Position = UDim2.new(0, 15, 1, -20)
    track.BackgroundColor3 = Colors.Surface
    track.BorderSizePixel = 0
    track.Parent = container
    createHexCorner(track, 4)
    
    -- Add inner shadow effect
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = Colors.Background
    trackStroke.Thickness = 1
    trackStroke.Transparency = 0.5
    trackStroke.Parent = track
    
    -- Fill with gradient
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    local initialPercent = ((defaultValue or min) - min) / (max - min)
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    createHexCorner(fill, 4)
    createGradient(fill, ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(1, Colors.Secondary)
    }, 90)
    
    -- Handle
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 20, 0, 20)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Color3.new(1, 1, 1)
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    createHexCorner(handle, 10)
    
    -- Handle glow
    local handleGlow = Instance.new("UIStroke")
    handleGlow.Color = Colors.Primary
    handleGlow.Thickness = 3
    handleGlow.Transparency = 0.4
    handleGlow.Parent = handle
    
    -- State
    local value = defaultValue or min
    local dragging = false
    
    -- Update visual
    local function updateVisual(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent)
        valueLabel.Text = tostring(value)
        
        tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
        tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.1)
        
        if callback then
            task.spawn(callback, value)
        end
    end
    
    -- Handle input
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
            tween(handleGlow, {Transparency = 0.2})
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            tween(handleGlow, {Transparency = 0.2})
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(handleGlow, {Transparency = 0.4})
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
-- SECTION HEADER - Cyberpunk Style
-- ============================================
function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. (text or "Unknown")
    section.Size = UDim2.new(1, -12, 0, 40)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    -- Decorative line
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 1, -1)
    line.BackgroundColor3 = Colors.BorderGlow
    line.BackgroundTransparency = 0.5
    line.BorderSizePixel = 0
    line.Parent = section
    createGradient(line, ColorSequence.new{
        ColorSequenceKeypoint.new(0, Colors.Primary),
        ColorSequenceKeypoint.new(0.5, Colors.Secondary),
        ColorSequenceKeypoint.new(1, Colors.Primary)
    }, 0)
    
    -- Hex accent
    local hexAccent = Instance.new("Frame")
    hexAccent.Size = UDim2.new(0, 6, 0, 24)
    hexAccent.Position = UDim2.new(0, 0, 0.5, 0)
    hexAccent.AnchorPoint = Vector2.new(0, 0.5)
    hexAccent.BackgroundColor3 = Colors.Primary
    hexAccent.BorderSizePixel = 0
    hexAccent.Parent = section
    createHexCorner(hexAccent, 3)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -15, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (text or "SECTION"):upper()
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Parent = section
    
    return section
end

-- ============================================
-- DIVIDER - Minimal
-- ============================================
function Components.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -24, 0, 12)
    divider.BackgroundTransparency = 1
    divider.Parent = parent
    
    local line = Instance.new("Frame")
    line.Size = UDim2.new(1, 0, 0, 1)
    line.Position = UDim2.new(0, 0, 0.5, 0)
    line.BackgroundColor3 = Colors.Border
    line.BackgroundTransparency = 0.7
    line.BorderSizePixel = 0
    line.Parent = divider
    
    return divider
end

-- ============================================
-- LABEL - Info Text
-- ============================================
function Components.createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -12, 0, 30)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or ""
    lbl.TextColor3 = Colors.TextMuted
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.Parent = parent
    return lbl
end

-- Export
_G.VertexComponents = Components
return Components
