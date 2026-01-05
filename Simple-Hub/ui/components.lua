-- components.lua - EXECUTOR SAFE UI COMPONENTS
-- FIXED: Added UpdateState alias for SetState compatibility

local Components = {}

local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- Colors (executor safe)
local Colors = {
    Background = Color3.fromRGB(18, 18, 24),
    Panel = Color3.fromRGB(24, 24, 32),
    Surface = Color3.fromRGB(28, 28, 38),
    Border = Color3.fromRGB(45, 45, 60),
    Text = Color3.fromRGB(220, 220, 240),
    TextDim = Color3.fromRGB(140, 140, 160),
    Accent = Color3.fromRGB(60, 120, 255),
    Success = Color3.fromRGB(60, 200, 100),
    Warning = Color3.fromRGB(255, 180, 60),
    Error = Color3.fromRGB(255, 80, 80)
}

-- Helper functions
local function createCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 6)
    c.Parent = parent
    return c
end

local function createStroke(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Border
    s.Thickness = 1
    s.Transparency = 0.4
    s.Parent = parent
    return s
end

-- Simple tween fallback
local function tween(obj, props, duration)
    if not obj then return end
    local info = TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ============================================
-- TOGGLE COMPONENT - RETURNS TABLE, NOT INSTANCE
-- ============================================
function Components.createToggle(parent, text, callback, initialState)
    local container = Instance.new("TextButton")
    container.Name = "Toggle_" .. (text or "Unknown")
    container.Size = UDim2.new(1, -16, 0, 32)
    container.BackgroundColor3 = Colors.Surface
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    createCorner(container, 6)
    createStroke(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Colors.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Active indicator
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 0, 0, 2)
    indicator.Position = UDim2.new(0, 0, 1, -2)
    indicator.BackgroundColor3 = Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = container
    createCorner(indicator, 1)
    
    -- Toggle switch
    local switchBg = Instance.new("Frame")
    switchBg.Name = "Switch"
    switchBg.Size = UDim2.new(0, 36, 0, 18)
    switchBg.Position = UDim2.new(1, -46, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.Border
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    createCorner(switchBg, 9)
    
    local switchHandle = Instance.new("Frame")
    switchHandle.Name = "Handle"
    switchHandle.Size = UDim2.new(0, 14, 0, 14)
    switchHandle.Position = UDim2.new(0, 2, 0.5, 0)
    switchHandle.AnchorPoint = Vector2.new(0, 0.5)
    switchHandle.BackgroundColor3 = Colors.TextDim
    switchHandle.BorderSizePixel = 0
    switchHandle.Parent = switchBg
    createCorner(switchHandle, 7)
    
    -- State
    local state = initialState or false
    
    -- Update visual state
    local function updateVisual()
        if state then
            tween(container, {BackgroundColor3 = Color3.fromRGB(35, 40, 55)})
            tween(label, {TextColor3 = Colors.Text})
            tween(indicator, {Size = UDim2.new(1, 0, 0, 2)})
            tween(switchBg, {BackgroundColor3 = Colors.Accent})
            tween(switchHandle, {
                Position = UDim2.new(1, -16, 0.5, 0),
                BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            })
        else
            tween(container, {BackgroundColor3 = Colors.Surface})
            tween(label, {TextColor3 = Colors.TextDim})
            tween(indicator, {Size = UDim2.new(0, 0, 0, 2)})
            tween(switchBg, {BackgroundColor3 = Colors.Border})
            tween(switchHandle, {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = Colors.TextDim
            })
        end
    end
    
    -- Initialize
    updateVisual()
    
    -- Events
    container.MouseEnter:Connect(function()
        if not state then
            tween(container, {BackgroundColor3 = Color3.fromRGB(32, 32, 42)})
        end
    end)
    
    container.MouseLeave:Connect(function()
        if not state then
            tween(container, {BackgroundColor3 = Colors.Surface})
        end
    end)
    
    container.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then
            task.spawn(callback, state)
        end
    end)
    
    -- RETURN A TABLE OBJECT, NOT THE TEXTBUTTON
    local toggleObject = {
        Button = container,
        Label = label,
        
        -- SetState for backwards compatibility
        SetState = function(self, newState)
            if typeof(newState) ~= "boolean" then return end
            if state ~= newState then
                state = newState
                updateVisual()
            end
        end,
        
        -- UpdateState as alias (menu.lua uses this)
        UpdateState = function(self, newState)
            if typeof(newState) ~= "boolean" then return end
            state = newState
            updateVisual()
            if callback then
                task.spawn(callback, state)
            end
        end,
        
        -- GetState
        GetState = function(self)
            return state
        end
    }
    
    return toggleObject
end

-- ============================================
-- SLIDER COMPONENT
-- ============================================
function Components.createSlider(parent, text, min, max, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. (text or "Unknown")
    container.Size = UDim2.new(1, -16, 0, 54)
    container.BackgroundColor3 = Colors.Surface
    container.BorderSizePixel = 0
    container.Parent = parent
    
    createCorner(container, 6)
    createStroke(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -70, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = Colors.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.Parent = container
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -70, 0, 6)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or min)
    valueLabel.TextColor3 = Colors.Accent
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 11
    valueLabel.Parent = container
    
    -- Slider track
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -20)
    track.BackgroundColor3 = Colors.Border
    track.BorderSizePixel = 0
    track.Parent = container
    createCorner(track, 3)
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    local initialPercent = ((defaultValue or min) - min) / (max - min)
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    createCorner(fill, 3)
    
    -- Handle
    local handle = Instance.new("Frame")
    handle.Name = "Handle"
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    createCorner(handle, 8)
    
    -- State
    local value = defaultValue or min
    local dragging = false
    
    -- Update visual
    local function updateVisual(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent)
        valueLabel.Text = tostring(value)
        
        tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.08)
        tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.08)
        
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
-- BUTTON COMPONENT
-- ============================================
function Components.createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Name = "Button_" .. (text or "Unknown")
    button.Size = UDim2.new(1, -16, 0, 32)
    button.BackgroundColor3 = Colors.Surface
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = text or "Button"
    button.TextColor3 = Colors.TextDim
    button.Font = Enum.Font.GothamMedium
    button.TextSize = 12
    button.Parent = parent
    
    createCorner(button, 6)
    createStroke(button)
    
    button.MouseEnter:Connect(function()
        tween(button, {
            BackgroundColor3 = Colors.Accent,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, {
            BackgroundColor3 = Colors.Surface,
            TextColor3 = Colors.TextDim
        })
    end)
    
    button.MouseButton1Click:Connect(function()
        if callback then
            task.spawn(callback)
        end
    end)
    
    return button
end

-- ============================================
-- TEXT INPUT COMPONENT
-- ============================================
function Components.createTextInput(parent, text, placeholder, callback)
    local container = Instance.new("Frame")
    container.Name = "Input_" .. (text or "Unknown")
    container.Size = UDim2.new(1, -16, 0, 54)
    container.BackgroundColor3 = Colors.Surface
    container.BorderSizePixel = 0
    container.Parent = parent
    
    createCorner(container, 6)
    createStroke(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -20, 0, 20)
    label.Position = UDim2.new(0, 10, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text or "Input"
    label.TextColor3 = Colors.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 11
    label.Parent = container
    
    -- Input box
    local input = Instance.new("TextBox")
    input.Name = "Input"
    input.Size = UDim2.new(1, -20, 0, 24)
    input.Position = UDim2.new(0, 10, 1, -28)
    input.BackgroundColor3 = Colors.Background
    input.BorderSizePixel = 0
    input.Text = ""
    input.PlaceholderText = placeholder or "Enter text..."
    input.TextColor3 = Colors.Text
    input.PlaceholderColor3 = Colors.TextDim
    input.Font = Enum.Font.Gotham
    input.TextSize = 11
    input.Parent = container
    createCorner(input, 4)
    createStroke(input)
    
    input.FocusLost:Connect(function(enterPressed)
        if enterPressed and callback then
            task.spawn(callback, input.Text)
        end
    end)
    
    return container
end

-- ============================================
-- SECTION HEADER
-- ============================================
function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. (text or "Unknown")
    section.Size = UDim2.new(1, -16, 0, 30)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    local accent = Instance.new("Frame")
    accent.Size = UDim2.new(0, 3, 0, 16)
    accent.Position = UDim2.new(0, 0, 0.5, 0)
    accent.AnchorPoint = Vector2.new(0, 0.5)
    accent.BackgroundColor3 = Colors.Accent
    accent.BorderSizePixel = 0
    accent.Parent = section
    createCorner(accent, 2)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (text or "SECTION"):upper()
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 10
    label.Parent = section
    
    return section
end

-- ============================================
-- DIVIDER
-- ============================================
function Components.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -32, 0, 1)
    divider.Position = UDim2.new(0.5, 0, 0, 0)
    divider.AnchorPoint = Vector2.new(0.5, 0)
    divider.BackgroundColor3 = Colors.Border
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.Parent = parent
    return divider
end

-- ============================================
-- LABEL
-- ============================================
function Components.createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 22)
    lbl.BackgroundTransparency = 1
    lbl.Text = text or ""
    lbl.TextColor3 = Colors.TextDim
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.Gotham
    lbl.TextSize = 11
    lbl.TextWrapped = true
    lbl.Parent = parent
    return lbl
end

-- ============================================
-- INPUT (alias for createTextInput)
-- ============================================
function Components.createInput(parent, text, placeholder, callback)
    return Components.createTextInput(parent, text, placeholder, callback)
end

-- Export
_G.VertexComponents = Components
return Components
