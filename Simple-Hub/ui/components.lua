-- ═══════════════════════════════════════════════════════════════════════════════
-- VERTEX HUB COMPONENTS - VERTICAL REDESIGN
-- Modern Vertical Layout | Essential Features Only
-- ═══════════════════════════════════════════════════════════════════════════════

local Components = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- ═══════════════════════════════════════════════════════════════════════════════
-- MODERN VERTICAL UI COLOR PALETTE
-- ═══════════════════════════════════════════════════════════════════════════════
local Colors = {
    -- Base colors
    Background = Color3.fromRGB(20, 20, 30),
    Panel = Color3.fromRGB(25, 25, 40),
    Surface = Color3.fromRGB(30, 30, 50),
    
    -- Text colors
    Text = Color3.fromRGB(240, 240, 255),
    TextSoft = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 150),
    
    -- Accent colors
    Accent = Color3.fromRGB(100, 150, 255),
    AccentLight = Color3.fromRGB(120, 170, 255),
    AccentDark = Color3.fromRGB(80, 130, 220),
    
    -- UI elements
    Border = Color3.fromRGB(50, 60, 80),
    SliderTrack = Color3.fromRGB(40, 50, 70),
    ToggleOff = Color3.fromRGB(40, 40, 60),
    ToggleOn = Color3.fromRGB(100, 150, 255),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    
    -- State colors
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 180, 60),
    Error = Color3.fromRGB(255, 80, 80)
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Rounded corners
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- Smooth border stroke
local function border(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Border
    s.Thickness = thickness or 1
    s.Transparency = 0.3
    s.Parent = parent
    return s
end

-- Smooth tween animation
local function tween(obj, props, duration)
    if not obj then return end
    local info = TweenInfo.new(
        duration or 0.2,
        Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION HEADER (For Vertical Layout)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createSection(parent, title)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. (title or ""):gsub("%s+", "")
    section.Size = UDim2.new(1, 0, 0, 32)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    -- Title with accent bar
    local titleFrame = Instance.new("Frame")
    titleFrame.Size = UDim2.new(1, 0, 1, 0)
    titleFrame.BackgroundTransparency = 1
    titleFrame.Parent = section
    
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 3, 0, 16)
    accentBar.Position = UDim2.new(0, 0, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = titleFrame
    corner(accentBar, 2)
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -10, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = (title or "SECTION"):upper()
    titleLabel.TextColor3 = Colors.Accent
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 12
    titleLabel.Parent = titleFrame
    
    -- Divider line
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, -1)
    divider.BackgroundColor3 = Colors.Border
    divider.BorderSizePixel = 0
    divider.BackgroundTransparency = 0.3
    divider.Parent = section
    
    return section
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOGGLE BUTTON (Vertical Design)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createToggle(parent, text, callback, initialState)
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Colors.Surface
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    border(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -50, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Toggle switch
    local switchBg = Instance.new("Frame")
    switchBg.Name = "SwitchBg"
    switchBg.Size = UDim2.new(0, 40, 0, 20)
    switchBg.Position = UDim2.new(1, -48, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    corner(switchBg, 10)
    
    local switchKnob = Instance.new("Frame")
    switchKnob.Name = "Knob"
    switchKnob.Size = UDim2.new(0, 16, 0, 16)
    switchKnob.Position = UDim2.new(0, 2, 0.5, 0)
    switchKnob.AnchorPoint = Vector2.new(0, 0.5)
    switchKnob.BackgroundColor3 = Colors.ToggleKnob
    switchKnob.BorderSizePixel = 0
    switchKnob.Parent = switchBg
    corner(switchKnob, 8)
    
    -- State management
    local state = initialState or false
    
    local function updateVisual()
        if state then
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOn}, 0.15)
            tween(switchKnob, {
                Position = UDim2.new(1, -18, 0.5, 0),
                BackgroundColor3 = Colors.Text
            }, 0.15)
            tween(label, {TextColor3 = Colors.Accent}, 0.15)
            tween(container, {BackgroundColor3 = Color3.fromRGB(35, 35, 60)}, 0.15)
        else
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOff}, 0.15)
            tween(switchKnob, {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = Colors.ToggleKnob
            }, 0.15)
            tween(label, {TextColor3 = Colors.Text}, 0.15)
            tween(container, {BackgroundColor3 = Colors.Surface}, 0.15)
        end
    end
    
    local function toggle()
        state = not state
        updateVisual()
        if callback then
            task.spawn(callback, state)
        end
    end
    
    -- Click handler
    container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    -- Hover effects
    container.MouseEnter:Connect(function()
        if not state then
            tween(container, {BackgroundColor3 = Color3.fromRGB(35, 35, 55)}, 0.15)
        end
    end)
    
    container.MouseLeave:Connect(function()
        if not state then
            tween(container, {BackgroundColor3 = Colors.Surface}, 0.15)
        end
    end)
    
    -- Initialize
    updateVisual()
    
    return {
        Container = container,
        SetState = function(self, newState)
            if typeof(newState) == "boolean" and state ~= newState then
                state = newState
                updateVisual()
            end
        end,
        GetState = function(self)
            return state
        end,
        Toggle = toggle
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SLIDER (Vertical Design)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createSlider(parent, text, min, max, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = Colors.Surface
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    border(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 0, 20)
    label.Position = UDim2.new(0, 12, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Value display
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 20)
    valueLabel.Position = UDim2.new(1, -72, 0, 8)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue)
    valueLabel.TextColor3 = Colors.Accent
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = container
    
    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -24, 0, 6)
    track.Position = UDim2.new(0, 12, 1, -22)
    track.BackgroundColor3 = Colors.SliderTrack
    track.BorderSizePixel = 0
    track.Parent = container
    corner(track, 3)
    
    -- Fill
    local initialPercent = ((defaultValue or min) - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)
    
    -- Handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 14, 0, 14)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Colors.Text
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    corner(handle, 7)
    
    -- Value state
    local value = defaultValue or min
    local dragging = false
    
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
    
    -- Interaction handlers
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
            tween(handle, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            tween(handle, {Size = UDim2.new(0, 16, 0, 16)}, 0.1)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(handle, {Size = UDim2.new(0, 14, 0, 14)}, 0.1)
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
        tween(container, {BackgroundColor3 = Color3.fromRGB(35, 35, 55)}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundColor3 = Colors.Surface}, 0.15)
    end)
    
    return {
        Container = container,
        SetValue = function(self, newValue)
            local percent = (math.clamp(newValue, min, max) - min) / (max - min)
            updateVisual(percent)
        end,
        GetValue = function(self)
            return value
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- LABEL (For Information)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = text or ""
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextWrapped = true
    label.Parent = parent
    return label
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DIVIDER (Visual Separation)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -24, 0, 1)
    divider.Position = UDim2.new(0, 12, 0, 0)
    divider.BackgroundColor3 = Colors.Border
    divider.BorderSizePixel = 0
    divider.BackgroundTransparency = 0.3
    divider.Parent = parent
    return divider
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- BUTTON (Simple Action)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createButton(parent, text, callback)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(1, 0, 0, 36)
    button.BackgroundColor3 = Colors.Accent
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = text or "Button"
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 13
    button.Parent = parent
    
    corner(button, 8)
    
    button.MouseEnter:Connect(function()
        tween(button, {BackgroundColor3 = Colors.AccentLight}, 0.15)
    end)
    
    button.MouseLeave:Connect(function()
        tween(button, {BackgroundColor3 = Colors.Accent}, 0.15)
    end)
    
    button.MouseButton1Click:Connect(function()
        tween(button, {BackgroundColor3 = Colors.AccentDark}, 0.1)
        task.delay(0.1, function()
            tween(button, {BackgroundColor3 = Colors.Accent}, 0.15)
        end)
        if callback then
            task.spawn(callback)
        end
    end)
    
    return button
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- VERTICAL CONTAINER (For Organizing Content)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createVerticalContainer(parent, padding)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 0)
    container.BackgroundTransparency = 1
    container.AutomaticSize = Enum.AutomaticSize.Y
    container.Parent = parent
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, padding or 6)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = container
    
    return {
        Container = container,
        Layout = layout
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOGGLE WITH BINDING (For Keybinds)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createToggleWithBind(parent, text, callback, initialState, keybind)
    local container = Instance.new("Frame")
    container.Name = "ToggleBind_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, 36)
    container.BackgroundColor3 = Colors.Surface
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    border(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 12, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Colors.Text
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Keybind display
    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0, 60, 0, 24)
    keybindBtn.Position = UDim2.new(1, -130, 0.5, 0)
    keybindBtn.AnchorPoint = Vector2.new(0, 0.5)
    keybindBtn.BackgroundColor3 = Colors.Border
    keybindBtn.BorderSizePixel = 0
    keybindBtn.AutoButtonColor = false
    keybindBtn.Text = keybind and keybind.Name or "..."
    keybindBtn.TextColor3 = Colors.TextSoft
    keybindBtn.Font = Enum.Font.GothamBold
    keybindBtn.TextSize = 11
    keybindBtn.Parent = container
    corner(keybindBtn, 6)
    
    -- Toggle switch
    local switchBg = Instance.new("Frame")
    switchBg.Name = "SwitchBg"
    switchBg.Size = UDim2.new(0, 40, 0, 20)
    switchBg.Position = UDim2.new(1, -48, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    corner(switchBg, 10)
    
    local switchKnob = Instance.new("Frame")
    switchKnob.Name = "Knob"
    switchKnob.Size = UDim2.new(0, 16, 0, 16)
    switchKnob.Position = UDim2.new(0, 2, 0.5, 0)
    switchKnob.AnchorPoint = Vector2.new(0, 0.5)
    switchKnob.BackgroundColor3 = Colors.ToggleKnob
    switchKnob.BorderSizePixel = 0
    switchKnob.Parent = switchBg
    corner(switchKnob, 8)
    
    -- State management
    local state = initialState or false
    local waitingForBind = false
    
    local function updateVisual()
        if state then
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOn}, 0.15)
            tween(switchKnob, {
                Position = UDim2.new(1, -18, 0.5, 0),
                BackgroundColor3 = Colors.Text
            }, 0.15)
            tween(label, {TextColor3 = Colors.Accent}, 0.15)
            tween(keybindBtn, {TextColor3 = Colors.Accent}, 0.15)
        else
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOff}, 0.15)
            tween(switchKnob, {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = Colors.ToggleKnob
            }, 0.15)
            tween(label, {TextColor3 = Colors.Text}, 0.15)
            tween(keybindBtn, {TextColor3 = Colors.TextSoft}, 0.15)
        end
    end
    
    local function toggle()
        state = not state
        updateVisual()
        if callback then
            task.spawn(callback, state)
        end
    end
    
    -- Keybind capture
    keybindBtn.MouseButton1Click:Connect(function()
        if waitingForBind then return end
        waitingForBind = true
        
        local originalText = keybindBtn.Text
        keybindBtn.Text = "..."
        tween(keybindBtn, {BackgroundColor3 = Colors.Accent}, 0.15)
        
        local connection
        connection = UIS.InputBegan:Connect(function(input, processed)
            if processed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                waitingForBind = false
                connection:Disconnect()
                
                if input.KeyCode == Enum.KeyCode.Escape then
                    keybindBtn.Text = originalText
                else
                    keybindBtn.Text = input.KeyCode.Name
                    -- Store keybind logic here
                end
                
                tween(keybindBtn, {BackgroundColor3 = Colors.Border}, 0.15)
            end
        end)
        
        -- Timeout
        task.spawn(function()
            task.wait(5)
            if waitingForBind then
                waitingForBind = false
                if connection then
                    connection:Disconnect()
                end
                keybindBtn.Text = originalText
                tween(keybindBtn, {BackgroundColor3 = Colors.Border}, 0.15)
            end
        end)
    end)
    
    -- Toggle click handlers
    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            toggle()
        end
    end)
    
    -- Initialize
    updateVisual()
    
    return {
        Container = container,
        SetState = function(self, newState)
            if typeof(newState) == "boolean" and state ~= newState then
                state = newState
                updateVisual()
            end
        end,
        GetState = function(self)
            return state
        end,
        SetKeybind = function(self, keyCode)
            keybindBtn.Text = keyCode and keyCode.Name or "..."
            tween(keybindBtn, {TextColor3 = keyCode and Colors.Accent or Colors.TextSoft}, 0.15)
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- INFO CARD (For Tips or Information)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createInfoCard(parent, text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 40)
    container.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    border(container, Color3.fromRGB(60, 80, 120))
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 8, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "ℹ"
    icon.TextColor3 = Colors.Accent
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 16
    icon.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -40, 1, -8)
    label.Position = UDim2.new(0, 36, 0, 4)
    label.BackgroundTransparency = 1
    label.Text = text or "Information"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 11
    label.TextWrapped = true
    label.Parent = container
    
    return container
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPOSE COLORS FOR EXTERNAL USE
-- ═══════════════════════════════════════════════════════════════════════════════
Components.Colors = Colors

-- ═══════════════════════════════════════════════════════════════════════════════
-- GLOBAL REGISTRATION
-- ═══════════════════════════════════════════════════════════════════════════════
_G.VertexComponents = Components

return Components
