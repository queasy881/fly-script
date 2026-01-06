-- ═══════════════════════════════════════════════════════════════════════════════
-- VERTEX HUB COMPONENTS - NEO EDITION
-- Glassmorphism Design | Modern UI | Smooth Animations
-- ═══════════════════════════════════════════════════════════════════════════════

local Components = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- ═══════════════════════════════════════════════════════════════════════════════
-- NEO COLOR PALETTE
-- ═══════════════════════════════════════════════════════════════════════════════
local Colors = {
    -- Base colors
    Background = Color3.fromRGB(10, 10, 15),
    Glass = Color3.fromRGB(20, 20, 30),
    GlassLight = Color3.fromRGB(28, 28, 40),
    GlassHover = Color3.fromRGB(35, 35, 50),
    
    -- Text colors
    Text = Color3.fromRGB(240, 240, 255),
    TextSoft = Color3.fromRGB(180, 180, 200),
    TextMuted = Color3.fromRGB(120, 120, 150),
    TextDim = Color3.fromRGB(80, 80, 100),
    
    -- Accent colors
    Accent = Color3.fromRGB(100, 140, 255),
    AccentSoft = Color3.fromRGB(120, 160, 255),
    AccentGlow = Color3.fromRGB(80, 120, 240),
    AccentDark = Color3.fromRGB(60, 100, 200),
    
    -- State colors
    Success = Color3.fromRGB(80, 220, 130),
    Warning = Color3.fromRGB(255, 190, 80),
    Error = Color3.fromRGB(255, 90, 90),
    
    -- UI colors
    Border = Color3.fromRGB(45, 50, 70),
    BorderLight = Color3.fromRGB(60, 65, 90),
    
    -- Toggle colors
    ToggleOn = Color3.fromRGB(100, 140, 255),
    ToggleOff = Color3.fromRGB(40, 40, 60),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    
    -- Slider colors
    SliderTrack = Color3.fromRGB(35, 35, 50),
    SliderFill = Color3.fromRGB(100, 140, 255),
    
    -- Dropdown colors
    DropdownBg = Color3.fromRGB(45, 45, 65),
    DropdownHover = Color3.fromRGB(55, 55, 80),
    
    -- Button colors
    ButtonBg = Color3.fromRGB(50, 60, 100),
    ButtonHover = Color3.fromRGB(60, 70, 120),
    ButtonActive = Color3.fromRGB(40, 50, 80)
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

-- Create rounded corners
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- Create glass border stroke
local function glassBorder(parent, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Border
    s.Thickness = thickness or 1
    s.Transparency = 0.4
    s.Parent = parent
    return s
end

-- Create glass gradient effect
local function applyGlassEffect(parent)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.9),
        NumberSequenceKeypoint.new(0.5, 0.92),
        NumberSequenceKeypoint.new(1, 0.94)
    }
    gradient.Rotation = 135
    gradient.Parent = parent
    return gradient
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

-- Format keycode to display string
local function formatKeyName(keyCode)
    if not keyCode then return "None" end
    local name = keyCode.Name
    local replacements = {
        ["LeftShift"] = "L-Shift",
        ["RightShift"] = "R-Shift",
        ["LeftControl"] = "L-Ctrl",
        ["RightControl"] = "R-Ctrl",
        ["LeftAlt"] = "L-Alt",
        ["RightAlt"] = "R-Alt",
        ["Space"] = "Space",
        ["Return"] = "Enter",
        ["Escape"] = "Esc"
    }
    return replacements[name] or name
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- MODERN TOGGLE SWITCH
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createToggle(parent, text, callback, initialState)
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, -16, 0, 40)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    applyGlassEffect(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -60, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Toggle switch background
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 40, 0, 22)
    switchBg.Position = UDim2.new(1, -50, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    corner(switchBg, 11)
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 18, 0, 18)
    knob.Position = UDim2.new(0, 2, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = Colors.ToggleKnob
    knob.BorderSizePixel = 0
    knob.Parent = switchBg
    corner(knob, 9)
    
    -- State management
    local state = initialState or false
    local enabled = false
    
    -- Update visual state
    local function updateVisual()
        if state then
            tween(container, {BackgroundTransparency = 0.1}, 0.15)
            tween(label, {TextColor3 = Colors.Text}, 0.15)
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOn}, 0.15)
            tween(knob, {
                Position = UDim2.new(1, -20, 0.5, 0),
                BackgroundColor3 = Colors.Accent
            }, 0.2, Enum.EasingStyle.Back)
        else
            tween(container, {BackgroundTransparency = 0.2}, 0.15)
            tween(label, {TextColor3 = Colors.TextSoft}, 0.15)
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOff}, 0.15)
            tween(knob, {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = Colors.ToggleKnob
            }, 0.2, Enum.EasingStyle.Back)
        end
    end
    
    -- Toggle function
    local function doToggle()
        if not enabled then return end
        state = not state
        updateVisual()
        if callback then task.spawn(callback, state) end
    end
    
    -- Click handler
    container.MouseButton1Click:Connect(doToggle)
    switchBg.MouseButton1Click:Connect(doToggle)
    
    -- Hover effects
    container.MouseEnter:Connect(function()
        if not state then
            tween(container, {BackgroundTransparency = 0.15}, 0.15)
        end
    end)
    
    container.MouseLeave:Connect(function()
        if not state then
            tween(container, {BackgroundTransparency = 0.2}, 0.15)
        end
    end)
    
    -- Enable after creation
    enabled = true
    updateVisual()
    
    -- Return toggle object
    return {
        Container = container,
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
        GetState = function(self)
            return state
        end,
        Toggle = doToggle
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SLIDER WITH MODERN DESIGN
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createSlider(parent, text, min, max, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, -16, 0, 60)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    applyGlassEffect(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -70, 0, 20)
    label.Position = UDim2.new(0, 15, 0, 8)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Value display
    local valueBg = Instance.new("Frame")
    valueBg.Size = UDim2.new(0, 50, 0, 22)
    valueBg.Position = UDim2.new(1, -65, 0, 6)
    valueBg.BackgroundColor3 = Colors.Accent
    valueBg.BackgroundTransparency = 0.2
    valueBg.BorderSizePixel = 0
    valueBg.Parent = container
    corner(valueBg, 6)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or min)
    valueLabel.TextColor3 = Colors.Text
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 12
    valueLabel.Parent = valueBg
    
    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -30, 0, 6)
    track.Position = UDim2.new(0, 15, 1, -22)
    track.BackgroundColor3 = Colors.SliderTrack
    track.BorderSizePixel = 0
    track.Parent = container
    corner(track, 3)
    
    -- Fill
    local initialPercent = ((defaultValue or min) - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = Colors.SliderFill
    fill.BorderSizePixel = 0
    fill.Parent = track
    corner(fill, 3)
    
    -- Handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Colors.ToggleKnob
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    corner(handle, 8)
    
    -- Handle glow
    local handleGlow = Instance.new("UIStroke")
    handleGlow.Color = Colors.AccentGlow
    handleGlow.Thickness = 2
    handleGlow.Transparency = 0.6
    handleGlow.Parent = handle
    
    -- State
    local value = defaultValue or min
    local dragging = false
    
    -- Update function
    local function updateVisual(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent)
        valueLabel.Text = tostring(value)
        
        tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.08)
        tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.08)
        
        if callback then task.spawn(callback, value) end
    end
    
    -- Input handling
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
            tween(handle, {Size = UDim2.new(0, 20, 0, 20)}, 0.15)
            tween(handleGlow, {Transparency = 0.4}, 0.15)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            tween(handle, {Size = UDim2.new(0, 20, 0, 20)}, 0.15)
            tween(handleGlow, {Transparency = 0.4}, 0.15)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(handle, {Size = UDim2.new(0, 16, 0, 16)}, 0.15)
            tween(handleGlow, {Transparency = 0.6}, 0.15)
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
        tween(container, {BackgroundTransparency = 0.15}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
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
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DROPDOWN/SELECT
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createDropdown(parent, text, options, defaultIndex, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    applyGlassEffect(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Dropdown"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Dropdown button
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.45, 0, 0, 30)
    dropBtn.Position = UDim2.new(1, -15, 0.5, 0)
    dropBtn.AnchorPoint = Vector2.new(1, 0.5)
    dropBtn.BackgroundColor3 = Colors.DropdownBg
    dropBtn.BorderSizePixel = 0
    dropBtn.AutoButtonColor = false
    dropBtn.Text = options[defaultIndex or 1] or "Select"
    dropBtn.TextColor3 = Colors.Text
    dropBtn.Font = Enum.Font.GothamMedium
    dropBtn.TextSize = 11
    dropBtn.Parent = container
    corner(dropBtn, 8)
    glassBorder(dropBtn)
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -10, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Colors.TextMuted
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = dropBtn
    
    -- Options container (simple version - for full dropdown you'd make a popup)
    local selected = defaultIndex or 1
    local isOpen = false
    
    -- Simple cycling dropdown
    dropBtn.MouseButton1Click:Connect(function()
        selected = (selected % #options) + 1
        dropBtn.Text = options[selected]
        if callback then callback(options[selected], selected) end
    end)
    
    -- Hover effects
    dropBtn.MouseEnter:Connect(function()
        tween(dropBtn, {BackgroundColor3 = Colors.DropdownHover}, 0.15)
    end)
    
    dropBtn.MouseLeave:Connect(function()
        tween(dropBtn, {BackgroundColor3 = Colors.DropdownBg}, 0.15)
    end)
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.15}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    -- Return dropdown object
    return {
        Container = container,
        SetSelected = function(self, index)
            if options[index] then
                selected = index
                dropBtn.Text = options[index]
            end
        end,
        GetSelected = function(self)
            return options[selected], selected
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION HEADER
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, -16, 0, 30)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    -- Title with accent bar
    local titleContainer = Instance.new("Frame")
    titleContainer.Size = UDim2.new(1, 0, 1, 0)
    titleContainer.BackgroundTransparency = 1
    titleContainer.Parent = section
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 0, 16)
    accentBar.Position = UDim2.new(0, 0, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = titleContainer
    corner(accentBar, 2)
    
    -- Title text
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -10, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (text or "SECTION"):upper()
    label.TextColor3 = Colors.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Parent = titleContainer
    
    -- Divider line
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 1)
    divider.Position = UDim2.new(0, 0, 1, 0)
    divider.BackgroundColor3 = Colors.Border
    divider.BackgroundTransparency = 0.6
    divider.BorderSizePixel = 0
    divider.Parent = section
    
    return section
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DIVIDER
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, -32, 0, 1)
    divider.BackgroundColor3 = Colors.Border
    divider.BackgroundTransparency = 0.7
    divider.BorderSizePixel = 0
    divider.Parent = parent
    return divider
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- LABEL
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -16, 0, 24)
    lbl.Position = UDim2.new(0, 8, 0, 0)
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- BUTTON
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -16, 0, 40)
    btn.BackgroundColor3 = Colors.ButtonBg
    btn.BackgroundTransparency = 0.2
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text or "Button"
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.GothamMedium
    btn.TextSize = 13
    btn.Parent = parent
    
    corner(btn, 10)
    glassBorder(btn)
    applyGlassEffect(btn)
    
    -- Hover effects
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Colors.ButtonHover}, 0.15)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Colors.ButtonBg}, 0.15)
    end)
    
    -- Click effects
    btn.MouseButton1Down:Connect(function()
        tween(btn, {BackgroundColor3 = Colors.ButtonActive}, 0.05)
    end)
    
    btn.MouseButton1Up:Connect(function()
        tween(btn, {BackgroundColor3 = Colors.ButtonHover}, 0.1)
    end)
    
    btn.MouseButton1Click:Connect(function()
        if callback then task.spawn(callback) end
    end)
    
    return btn
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TEXT INPUT
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createTextInput(parent, text, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    applyGlassEffect(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Input"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.55, -14, 0, 30)
    inputBox.Position = UDim2.new(1, -14, 0.5, 0)
    inputBox.AnchorPoint = Vector2.new(1, 0.5)
    inputBox.BackgroundColor3 = Colors.DropdownBg
    inputBox.BorderSizePixel = 0
    inputBox.Text = ""
    inputBox.PlaceholderText = placeholder or "Enter text..."
    inputBox.PlaceholderColor3 = Colors.TextMuted
    inputBox.TextColor3 = Colors.Text
    inputBox.Font = Enum.Font.GothamMedium
    inputBox.TextSize = 12
    inputBox.ClearTextOnFocus = false
    inputBox.Parent = container
    corner(inputBox, 8)
    glassBorder(inputBox)
    
    -- Focus effects
    inputBox.Focused:Connect(function()
        tween(inputBox, {BackgroundColor3 = Colors.DropdownHover}, 0.15)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        tween(inputBox, {BackgroundColor3 = Colors.DropdownBg}, 0.15)
        if callback then callback(inputBox.Text, enterPressed) end
    end)
    
    -- Hover effects for container
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.15}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- COLOR PICKER (Simple version)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createColorPicker(parent, text, defaultColor, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    applyGlassEffect(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Color"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Color preview button
    local colorBtn = Instance.new("TextButton")
    colorBtn.Size = UDim2.new(0, 50, 0, 28)
    colorBtn.Position = UDim2.new(1, -64, 0.5, 0)
    colorBtn.AnchorPoint = Vector2.new(0, 0.5)
    colorBtn.BackgroundColor3 = defaultColor or Colors.Accent
    colorBtn.BorderSizePixel = 0
    colorBtn.AutoButtonColor = false
    colorBtn.Text = ""
    colorBtn.Parent = container
    corner(colorBtn, 8)
    glassBorder(colorBtn, Colors.Border, 2)
    
    local currentColor = defaultColor or Colors.Accent
    
    -- Simple color change on click (for full color picker, you'd make a popup)
    colorBtn.MouseButton1Click:Connect(function()
        -- Cycle through some preset colors
        local presets = {
            Colors.Accent,
            Colors.Success,
            Colors.Warning,
            Colors.Error,
            Color3.fromRGB(255, 150, 80),
            Color3.fromRGB(150, 255, 80),
            Color3.fromRGB(80, 255, 255),
            Color3.fromRGB(255, 80, 255)
        }
        
        for i, color in ipairs(presets) do
            if currentColor == color then
                currentColor = presets[(i % #presets) + 1]
                break
            end
        end
        
        colorBtn.BackgroundColor3 = currentColor
        if callback then callback(currentColor) end
    end)
    
    -- Hover effect
    colorBtn.MouseEnter:Connect(function()
        tween(colorBtn, {BackgroundTransparency = 0.8}, 0.15)
    end)
    
    colorBtn.MouseLeave:Connect(function()
        tween(colorBtn, {BackgroundTransparency = 0}, 0.15)
    end)
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.15}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    return {
        Container = container,
        SetColor = function(self, newColor)
            currentColor = newColor
            colorBtn.BackgroundColor3 = newColor
        end,
        GetColor = function(self)
            return currentColor
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- INFO BOX
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createInfoBox(parent, text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Color3.fromRGB(60, 80, 120), 1)
    applyGlassEffect(container)
    
    -- Icon
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "ℹ"
    icon.TextColor3 = Colors.AccentSoft
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 16
    icon.Parent = container
    
    -- Text
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, -12)
    label.Position = UDim2.new(0, 42, 0, 6)
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
-- KEYBIND BUTTON
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createKeybindButton(parent, text, currentKey, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.2
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    applyGlassEffect(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 15, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Keybind"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = container
    
    -- Key display button
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 70, 0, 28)
    keyBtn.Position = UDim2.new(1, -84, 0.5, 0)
    keyBtn.AnchorPoint = Vector2.new(0, 0.5)
    keyBtn.BackgroundColor3 = Colors.Accent
    keyBtn.BackgroundTransparency = 0.2
    keyBtn.BorderSizePixel = 0
    keyBtn.AutoButtonColor = false
    keyBtn.Text = currentKey and formatKeyName(currentKey) or "None"
    keyBtn.TextColor3 = Colors.Text
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 11
    keyBtn.Parent = container
    
    corner(keyBtn, 8)
    glassBorder(keyBtn)
    
    local waitingForInput = false
    local connection = nil
    
    local function startListening()
        if waitingForInput then return end
        waitingForInput = true
        
        local originalText = keyBtn.Text
        keyBtn.Text = "..."
        tween(keyBtn, {BackgroundColor3 = Colors.AccentSoft}, 0.15)
        
        connection = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                waitingForInput = false
                connection:Disconnect()
                
                if input.KeyCode == Enum.KeyCode.Escape then
                    keyBtn.Text = originalText
                else
                    keyBtn.Text = formatKeyName(input.KeyCode)
                    if callback then callback(input.KeyCode) end
                end
                
                tween(keyBtn, {BackgroundColor3 = Colors.Accent}, 0.15)
            end
        end)
        
        -- Timeout after 5 seconds
        task.spawn(function()
            task.wait(5)
            if waitingForInput then
                waitingForInput = false
                if connection then connection:Disconnect() end
                keyBtn.Text = originalText
                tween(keyBtn, {BackgroundColor3 = Colors.Accent}, 0.15)
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
        tween(container, {BackgroundTransparency = 0.15}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    return {
        Container = container,
        UpdateKey = function(self, newKey)
            keyBtn.Text = newKey and formatKeyName(newKey) or "None"
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPANDABLE CATEGORY
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createExpandableCategory(parent, title, icon)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, -16, 0, 52)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.Parent = parent
    
    -- Header
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundColor3 = Colors.Glass
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Text = ""
    header.Parent = container
    
    corner(header, 10)
    glassBorder(header)
    applyGlassEffect(header)
    
    -- Accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 0.7, 0)
    accentBar.Position = UDim2.new(0, 8, 0.15, 0)
    accentBar.BackgroundColor3 = Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = header
    corner(accentBar, 2)
    
    -- Icon
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(0, 30, 0, 30)
    iconLabel.Position = UDim2.new(0, 20, 0.5, 0)
    iconLabel.AnchorPoint = Vector2.new(0, 0.5)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "▶"
    iconLabel.TextColor3 = Colors.Accent
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 14
    iconLabel.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -70, 1, 0)
    titleLabel.Position = UDim2.new(0, 58, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "CATEGORY"
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextSize = 13
    titleLabel.Parent = header
    
    -- Expand indicator
    local expandIcon = Instance.new("TextLabel")
    expandIcon.Size = UDim2.new(0, 20, 0, 20)
    expandIcon.Position = UDim2.new(1, -30, 0.5, 0)
    expandIcon.AnchorPoint = Vector2.new(0, 0.5)
    expandIcon.BackgroundTransparency = 1
    expandIcon.Text = "+"
    expandIcon.TextColor3 = Colors.TextMuted
    expandIcon.Font = Enum.Font.GothamBold
    expandIcon.TextSize = 16
    expandIcon.Parent = header
    
    -- Content container
    local content = Instance.new("Frame")
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 56)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Visible = false
    content.Parent = container
    
    local contentInner = Instance.new("Frame")
    contentInner.Size = UDim2.new(1, 0, 0, 0)
    contentInner.BackgroundTransparency = 1
    contentInner.AutomaticSize = Enum.AutomaticSize.Y
    contentInner.Parent = content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentInner
    
    -- State
    local isExpanded = false
    
    local function toggle()
        isExpanded = not isExpanded
        
        if isExpanded then
            content.Visible = true
            tween(expandIcon, {Rotation = 45, TextColor3 = Colors.Accent}, 0.25)
            tween(header, {BackgroundTransparency = 0.1}, 0.25)
            tween(accentBar, {Size = UDim2.new(0, 4, 0.85, 0)}, 0.25)
            
            -- Animate content height
            local height = contentInner.AbsoluteContentSize.Y
            tween(content, {Size = UDim2.new(1, 0, 0, height)}, 0.3)
            tween(container, {Size = UDim2.new(1, -16, 0, 52 + height)}, 0.3)
        else
            tween(expandIcon, {Rotation = 0, TextColor3 = Colors.TextMuted}, 0.25)
            tween(header, {BackgroundTransparency = 0.2}, 0.25)
            tween(accentBar, {Size = UDim2.new(0, 4, 0.7, 0)}, 0.25)
            tween(content, {Size = UDim2.new(1, 0, 0, 0)}, 0.3)
            tween(container, {Size = UDim2.new(1, -16, 0, 52)}, 0.3)
            
            task.delay(0.3, function()
                content.Visible = false
            end)
        end
    end
    
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
    
    -- Listen for content size changes
    contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if isExpanded then
            local height = contentInner.AbsoluteContentSize.Y
            tween(content, {Size = UDim2.new(1, 0, 0, height)}, 0.2)
            tween(container, {Size = UDim2.new(1, -16, 0, 52 + height)}, 0.2)
        end
    end)
    
    return {
        Container = container,
        Content = contentInner,
        Header = header,
        Toggle = toggle,
        IsExpanded = function() return isExpanded end
    }
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
