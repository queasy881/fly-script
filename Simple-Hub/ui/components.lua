-- ═══════════════════════════════════════════════════════════════════════════════
-- VERTEX HUB COMPONENTS - ENHANCED EDITION
-- Glassmorphism Design | Expandable Categories | Integrated Keybind System
-- ═══════════════════════════════════════════════════════════════════════════════

local Components = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")

-- ═══════════════════════════════════════════════════════════════════════════════
-- MODERN GLASSMORPHISM COLOR PALETTE
-- ═══════════════════════════════════════════════════════════════════════════════
local Colors = {
    -- Base colors
    Background = Color3.fromRGB(12, 12, 18),
    Glass = Color3.fromRGB(22, 22, 32),
    GlassLight = Color3.fromRGB(30, 30, 45),
    GlassHover = Color3.fromRGB(38, 38, 55),
    
    -- Text colors
    Text = Color3.fromRGB(255, 255, 255),
    TextSoft = Color3.fromRGB(200, 200, 220),
    TextMuted = Color3.fromRGB(120, 120, 150),
    TextDim = Color3.fromRGB(80, 80, 100),
    
    -- Accent colors
    Accent = Color3.fromRGB(100, 120, 255),
    AccentSoft = Color3.fromRGB(130, 150, 255),
    AccentGlow = Color3.fromRGB(80, 100, 255),
    AccentDark = Color3.fromRGB(60, 80, 200),
    
    -- State colors
    Success = Color3.fromRGB(80, 200, 120),
    Warning = Color3.fromRGB(255, 180, 60),
    Error = Color3.fromRGB(255, 80, 80),
    
    -- UI colors
    Border = Color3.fromRGB(50, 50, 70),
    BorderLight = Color3.fromRGB(70, 70, 95),
    Shadow = Color3.fromRGB(0, 0, 0),
    
    -- Toggle colors
    ToggleOn = Color3.fromRGB(100, 120, 255),
    ToggleOff = Color3.fromRGB(35, 35, 50),
    ToggleKnob = Color3.fromRGB(255, 255, 255),
    ToggleKnobOff = Color3.fromRGB(100, 100, 120),
    
    -- Keybind colors
    KeybindBg = Color3.fromRGB(40, 40, 60),
    KeybindActive = Color3.fromRGB(100, 120, 255),
    KeybindHover = Color3.fromRGB(55, 55, 80),
    
    -- Category colors
    CategoryBg = Color3.fromRGB(25, 25, 38),
    CategoryHover = Color3.fromRGB(32, 32, 48),
    CategoryActive = Color3.fromRGB(35, 40, 60)
}

-- ═══════════════════════════════════════════════════════════════════════════════
-- KEYBIND STORAGE SYSTEM
-- ═══════════════════════════════════════════════════════════════════════════════
local KeybindStorage = {}
local KeybindConnections = {}
local ActiveKeybindListener = nil

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
    s.Transparency = 0.5
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- Create glass gradient overlay
local function glassGradient(parent)
    local g = Instance.new("UIGradient")
    g.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(180, 180, 200))
    }
    g.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(0.5, 0.95),
        NumberSequenceKeypoint.new(1, 0.98)
    }
    g.Rotation = 135
    g.Parent = parent
    return g
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
    -- Clean up common key names
    local replacements = {
        ["LeftShift"] = "L-Shift",
        ["RightShift"] = "R-Shift",
        ["LeftControl"] = "L-Ctrl",
        ["RightControl"] = "R-Ctrl",
        ["LeftAlt"] = "L-Alt",
        ["RightAlt"] = "R-Alt",
        ["Space"] = "Space",
        ["Backspace"] = "Back",
        ["Return"] = "Enter",
        ["Escape"] = "Esc"
    }
    return replacements[name] or name
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- GLOBAL KEYBIND LISTENER
-- ═══════════════════════════════════════════════════════════════════════════════
local function setupKeybindListener()
    if KeybindConnections.main then return end
    
    KeybindConnections.main = UIS.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return end
        if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
        
        -- Check all registered keybinds
        for id, data in pairs(KeybindStorage) do
            if data.keyCode and data.keyCode == input.KeyCode then
                if data.callback then
                    task.spawn(data.callback)
                end
            end
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPANDABLE CATEGORY (Dropdown Container)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createExpandableCategory(parent, title, icon)
    local categoryId = title:gsub("%s+", "_"):upper()
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Category_" .. categoryId
    container.Size = UDim2.new(1, 0, 0, 52)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = false
    container.Parent = parent
    
    -- Header button (clickable to expand/collapse)
    local header = Instance.new("TextButton")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 52)
    header.BackgroundColor3 = Colors.CategoryBg
    header.BackgroundTransparency = 0.1
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Text = ""
    header.Parent = container
    
    corner(header, 12)
    glassBorder(header, Colors.Border, 1)
    glassGradient(header)
    
    -- Accent bar on left
    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.new(0, 4, 0.7, 0)
    accentBar.Position = UDim2.new(0, 8, 0.15, 0)
    accentBar.BackgroundColor3 = Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = header
    corner(accentBar, 4)
    
    -- Glow effect for accent bar
    local accentGlow = Instance.new("UIStroke")
    accentGlow.Color = Colors.AccentGlow
    accentGlow.Thickness = 2
    accentGlow.Transparency = 0.7
    accentGlow.Parent = accentBar
    
    -- Icon container
    local iconBg = Instance.new("Frame")
    iconBg.Size = UDim2.new(0, 32, 0, 32)
    iconBg.Position = UDim2.new(0, 22, 0.5, 0)
    iconBg.AnchorPoint = Vector2.new(0, 0.5)
    iconBg.BackgroundColor3 = Colors.Accent
    iconBg.BackgroundTransparency = 0.85
    iconBg.BorderSizePixel = 0
    iconBg.Parent = header
    corner(iconBg, 8)
    
    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text = icon or "⚡"
    iconLabel.TextColor3 = Colors.Accent
    iconLabel.Font = Enum.Font.GothamBold
    iconLabel.TextSize = 16
    iconLabel.Parent = iconBg
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -140, 1, 0)
    titleLabel.Position = UDim2.new(0, 62, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "CATEGORY"
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 14
    titleLabel.Parent = header
    
    -- Expand/Collapse indicator
    local expandIcon = Instance.new("TextLabel")
    expandIcon.Name = "ExpandIcon"
    expandIcon.Size = UDim2.new(0, 36, 0, 36)
    expandIcon.Position = UDim2.new(1, -48, 0.5, 0)
    expandIcon.AnchorPoint = Vector2.new(0, 0.5)
    expandIcon.BackgroundColor3 = Colors.Glass
    expandIcon.BackgroundTransparency = 0.5
    expandIcon.BorderSizePixel = 0
    expandIcon.Text = "+"
    expandIcon.TextColor3 = Colors.Accent
    expandIcon.Font = Enum.Font.GothamBold
    expandIcon.TextSize = 20
    expandIcon.Parent = header
    corner(expandIcon, 10)
    
    -- Content container (hidden by default)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -16, 0, 0)
    content.Position = UDim2.new(0, 8, 0, 56)
    content.BackgroundColor3 = Colors.Glass
    content.BackgroundTransparency = 0.3
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.Visible = false
    content.Parent = container
    
    corner(content, 10)
    glassBorder(content, Colors.Border, 1)
    
    -- Inner content frame for proper layout
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
    
    -- Refresh size when content changes
    local function refreshSize()
        if isExpanded and not animating then
            local height = getContentHeight()
            content.Size = UDim2.new(1, -16, 0, height)
            container.Size = UDim2.new(1, 0, 0, 56 + height)
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
            
            tween(content, {Size = UDim2.new(1, -16, 0, height)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(container, {Size = UDim2.new(1, 0, 0, 56 + height)}, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            tween(expandIcon, {Rotation = 45, TextColor3 = Colors.AccentSoft}, 0.25)
            tween(header, {BackgroundColor3 = Colors.CategoryActive}, 0.25)
            tween(accentBar, {Size = UDim2.new(0, 4, 0.85, 0), BackgroundColor3 = Colors.AccentSoft}, 0.25)
            tween(titleLabel, {TextColor3 = Colors.AccentSoft}, 0.25)
            
            task.delay(0.35, function() animating = false end)
        else
            -- Collapse animation
            tween(expandIcon, {Rotation = 0, TextColor3 = Colors.Accent}, 0.25)
            tween(header, {BackgroundColor3 = Colors.CategoryBg}, 0.25)
            tween(accentBar, {Size = UDim2.new(0, 4, 0.7, 0), BackgroundColor3 = Colors.Accent}, 0.25)
            tween(titleLabel, {TextColor3 = Colors.Text}, 0.25)
            tween(content, {Size = UDim2.new(1, -16, 0, 0)}, 0.3)
            tween(container, {Size = UDim2.new(1, 0, 0, 52)}, 0.3)
            
            task.delay(0.3, function()
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
            tween(header, {BackgroundColor3 = Colors.CategoryHover}, 0.15)
            tween(expandIcon, {BackgroundTransparency = 0.3}, 0.15)
        end
    end)
    
    header.MouseLeave:Connect(function()
        if not isExpanded then
            tween(header, {BackgroundColor3 = Colors.CategoryBg}, 0.15)
            tween(expandIcon, {BackgroundTransparency = 0.5}, 0.15)
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
        IsExpanded = function() return isExpanded end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TOGGLE WITH INTEGRATED KEYBIND SELECTOR
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createToggleWithKeybind(parent, text, callback, initialState, defaultKeybind)
    local toggleId = text:gsub("%s+", "_"):upper() .. "_" .. tostring(tick())
    
    -- Initialize keybind storage
    KeybindStorage[toggleId] = {
        keyCode = defaultKeybind,
        callback = nil
    }
    
    -- Main container
    local container = Instance.new("Frame")
    container.Name = "Toggle_" .. text:gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, 48)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Colors.Border, 1)
    glassGradient(container)
    
    -- Active indicator (left bar)
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.Size = UDim2.new(0, 0, 0.7, 0)
    indicator.Position = UDim2.new(0, 6, 0.15, 0)
    indicator.BackgroundColor3 = Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = container
    corner(indicator, 3)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -160, 1, 0)
    label.Position = UDim2.new(0, 18, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Keybind button
    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Name = "KeybindBtn"
    keybindBtn.Size = UDim2.new(0, 60, 0, 28)
    keybindBtn.Position = UDim2.new(1, -130, 0.5, 0)
    keybindBtn.AnchorPoint = Vector2.new(0, 0.5)
    keybindBtn.BackgroundColor3 = Colors.KeybindBg
    keybindBtn.BorderSizePixel = 0
    keybindBtn.AutoButtonColor = false
    keybindBtn.Text = defaultKeybind and formatKeyName(defaultKeybind) or "..."
    keybindBtn.TextColor3 = Colors.TextMuted
    keybindBtn.Font = Enum.Font.GothamBold
    keybindBtn.TextSize = 11
    keybindBtn.Parent = container
    
    corner(keybindBtn, 6)
    glassBorder(keybindBtn, Colors.Border, 1)
    
    -- Toggle switch background
    local switchBg = Instance.new("Frame")
    switchBg.Name = "SwitchBg"
    switchBg.Size = UDim2.new(0, 48, 0, 26)
    switchBg.Position = UDim2.new(1, -60, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.ToggleOff
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    corner(switchBg, 13)
    
    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = Colors.Border
    switchStroke.Thickness = 2
    switchStroke.Transparency = 0.5
    switchStroke.Parent = switchBg
    
    -- Toggle knob
    local knob = Instance.new("Frame")
    knob.Name = "Knob"
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 3, 0.5, 0)
    knob.AnchorPoint = Vector2.new(0, 0.5)
    knob.BackgroundColor3 = Colors.ToggleKnobOff
    knob.BorderSizePixel = 0
    knob.Parent = switchBg
    corner(knob, 10)
    
    -- Knob inner glow
    local knobGlow = Instance.new("UIStroke")
    knobGlow.Color = Colors.Shadow
    knobGlow.Thickness = 0
    knobGlow.Transparency = 0.8
    knobGlow.Parent = knob
    
    -- State management
    local state = initialState or false
    local waitingForKeybind = false
    local keybindConnection = nil
    
    -- Update visual state
    local function updateVisual()
        if state then
            tween(indicator, {Size = UDim2.new(0, 4, 0.7, 0)}, 0.2)
            tween(label, {TextColor3 = Colors.Text}, 0.2)
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOn}, 0.2)
            tween(knob, {
                Position = UDim2.new(1, -23, 0.5, 0),
                BackgroundColor3 = Colors.ToggleKnob
            }, 0.25, Enum.EasingStyle.Back)
            tween(switchStroke, {Color = Colors.AccentGlow, Transparency = 0.3}, 0.2)
            tween(container, {BackgroundTransparency = 0.15}, 0.2)
        else
            tween(indicator, {Size = UDim2.new(0, 0, 0.7, 0)}, 0.2)
            tween(label, {TextColor3 = Colors.TextSoft}, 0.2)
            tween(switchBg, {BackgroundColor3 = Colors.ToggleOff}, 0.2)
            tween(knob, {
                Position = UDim2.new(0, 3, 0.5, 0),
                BackgroundColor3 = Colors.ToggleKnobOff
            }, 0.25, Enum.EasingStyle.Back)
            tween(switchStroke, {Color = Colors.Border, Transparency = 0.5}, 0.2)
            tween(container, {BackgroundTransparency = 0.25}, 0.2)
        end
    end
    
    -- Toggle handler
    local function doToggle()
        state = not state
        updateVisual()
        if callback then task.spawn(callback, state) end
    end
    
    -- Store callback for keybind
    KeybindStorage[toggleId].callback = doToggle
    
    -- Initialize visual state
    updateVisual()
    
    -- Setup keybind listener
    setupKeybindListener()
    
    -- Click on switch to toggle
    switchBg.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            doToggle()
        end
    end)
    
    -- Keybind button functionality
    local function startKeybindCapture()
        if waitingForKeybind then return end
        waitingForKeybind = true
        
        local originalText = keybindBtn.Text
        keybindBtn.Text = "..."
        tween(keybindBtn, {BackgroundColor3 = Colors.KeybindActive}, 0.15)
        tween(keybindBtn, {TextColor3 = Colors.Text}, 0.15)
        
        -- Disconnect previous listener if exists
        if keybindConnection then
            keybindConnection:Disconnect()
        end
        
        keybindConnection = UIS.InputBegan:Connect(function(input, gameProcessed)
            if gameProcessed then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                waitingForKeybind = false
                keybindConnection:Disconnect()
                keybindConnection = nil
                
                if input.KeyCode == Enum.KeyCode.Escape then
                    -- Cancel - remove keybind
                    KeybindStorage[toggleId].keyCode = nil
                    keybindBtn.Text = "..."
                    tween(keybindBtn, {TextColor3 = Colors.TextMuted}, 0.15)
                elseif input.KeyCode == Enum.KeyCode.Backspace then
                    -- Clear keybind
                    KeybindStorage[toggleId].keyCode = nil
                    keybindBtn.Text = "..."
                    tween(keybindBtn, {TextColor3 = Colors.TextMuted}, 0.15)
                else
                    -- Set new keybind
                    KeybindStorage[toggleId].keyCode = input.KeyCode
                    keybindBtn.Text = formatKeyName(input.KeyCode)
                    tween(keybindBtn, {TextColor3 = Colors.Accent}, 0.15)
                end
                
                tween(keybindBtn, {BackgroundColor3 = Colors.KeybindBg}, 0.15)
            end
        end)
        
        -- Cancel on click elsewhere after delay
        task.spawn(function()
            task.wait(5)
            if waitingForKeybind then
                waitingForKeybind = false
                if keybindConnection then
                    keybindConnection:Disconnect()
                    keybindConnection = nil
                end
                keybindBtn.Text = originalText
                tween(keybindBtn, {BackgroundColor3 = Colors.KeybindBg}, 0.15)
                tween(keybindBtn, {TextColor3 = Colors.TextMuted}, 0.15)
            end
        end)
    end
    
    keybindBtn.MouseButton1Click:Connect(startKeybindCapture)
    
    -- Hover effects for keybind button
    keybindBtn.MouseEnter:Connect(function()
        if not waitingForKeybind then
            tween(keybindBtn, {BackgroundColor3 = Colors.KeybindHover}, 0.15)
        end
    end)
    
    keybindBtn.MouseLeave:Connect(function()
        if not waitingForKeybind then
            tween(keybindBtn, {BackgroundColor3 = Colors.KeybindBg}, 0.15)
        end
    end)
    
    -- Hover effects for container
    container.MouseEnter:Connect(function()
        if not state then
            tween(container, {BackgroundTransparency = 0.15}, 0.15)
        end
    end)
    
    container.MouseLeave:Connect(function()
        if not state then
            tween(container, {BackgroundTransparency = 0.25}, 0.15)
        end
    end)
    
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
        SetKeybind = function(self, keyCode)
            KeybindStorage[toggleId].keyCode = keyCode
            keybindBtn.Text = keyCode and formatKeyName(keyCode) or "..."
            tween(keybindBtn, {TextColor3 = keyCode and Colors.Accent or Colors.TextMuted}, 0.15)
        end,
        GetKeybind = function(self)
            return KeybindStorage[toggleId].keyCode
        end,
        Toggle = doToggle
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SIMPLE TOGGLE (Without Keybind)
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createToggle(parent, text, callback, initialState)
    return Components.createToggleWithKeybind(parent, text, callback, initialState, nil)
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SLIDER WITH MODERN DESIGN
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createSlider(parent, text, min, max, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, 0, 0, 58)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Colors.Border, 1)
    glassGradient(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -90, 0, 20)
    label.Position = UDim2.new(0, 14, 0, 8)
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
    valueBg.Position = UDim2.new(1, -64, 0, 6)
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
    track.Size = UDim2.new(1, -28, 0, 6)
    track.Position = UDim2.new(0, 14, 1, -18)
    track.BackgroundColor3 = Colors.Glass
    track.BorderSizePixel = 0
    track.Parent = container
    corner(track, 3)
    
    local trackStroke = Instance.new("UIStroke")
    trackStroke.Color = Colors.Border
    trackStroke.Thickness = 1
    trackStroke.Transparency = 0.5
    trackStroke.Parent = track
    
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
    handle.Size = UDim2.new(0, 18, 0, 18)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Colors.Text
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    corner(handle, 9)
    
    local handleGlow = Instance.new("UIStroke")
    handleGlow.Color = Colors.AccentGlow
    handleGlow.Thickness = 3
    handleGlow.Transparency = 0.5
    handleGlow.Parent = handle
    
    local value = defaultValue or min
    local dragging = false
    
    local function updateVisual(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent)
        valueLabel.Text = tostring(value)
        
        tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.08)
        tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.08)
        
        if callback then task.spawn(callback, value) end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
            tween(handle, {Size = UDim2.new(0, 22, 0, 22)}, 0.15)
            tween(handleGlow, {Transparency = 0.3}, 0.15)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            tween(handle, {Size = UDim2.new(0, 22, 0, 22)}, 0.15)
            tween(handleGlow, {Transparency = 0.3}, 0.15)
        end
    end)
    
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
            tween(handle, {Size = UDim2.new(0, 18, 0, 18)}, 0.15)
            tween(handleGlow, {Transparency = 0.5}, 0.15)
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
        tween(container, {BackgroundTransparency = 0.25}, 0.15)
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
-- STANDALONE KEYBIND BUTTON
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createKeybindButton(parent, text, currentKey, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Colors.Border, 1)
    glassGradient(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Keybind"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Key display button
    local keyBtn = Instance.new("TextButton")
    keyBtn.Size = UDim2.new(0, 70, 0, 28)
    keyBtn.Position = UDim2.new(1, -84, 0.5, 0)
    keyBtn.AnchorPoint = Vector2.new(0, 0.5)
    keyBtn.BackgroundColor3 = Colors.Accent
    keyBtn.BorderSizePixel = 0
    keyBtn.AutoButtonColor = false
    keyBtn.Text = currentKey and formatKeyName(currentKey) or "None"
    keyBtn.TextColor3 = Colors.Text
    keyBtn.Font = Enum.Font.GothamBold
    keyBtn.TextSize = 12
    keyBtn.Parent = container
    
    corner(keyBtn, 8)
    
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
        
        -- Timeout
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
            tween(keyBtn, {BackgroundColor3 = Colors.AccentSoft}, 0.15)
        end
    end)
    
    keyBtn.MouseLeave:Connect(function()
        if not waitingForInput then
            tween(keyBtn, {BackgroundColor3 = Colors.Accent}, 0.15)
        end
    end)
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.15}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.25}, 0.15)
    end)
    
    return {
        Container = container,
        UpdateKey = function(self, newKey)
            keyBtn.Text = newKey and formatKeyName(newKey) or "None"
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- SECTION HEADER
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 28)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
    -- Accent line
    local line = Instance.new("Frame")
    line.Size = UDim2.new(0, 3, 0, 14)
    line.Position = UDim2.new(0, 4, 0.5, 0)
    line.AnchorPoint = Vector2.new(0, 0.5)
    line.BackgroundColor3 = Colors.Accent
    line.BorderSizePixel = 0
    line.Parent = section
    corner(line, 2)
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -16, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = (text or "SECTION"):upper()
    label.TextColor3 = Colors.Accent
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamBold
    label.TextSize = 11
    label.Parent = section
    
    return section
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DIVIDER
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createDivider(parent)
    local divider = Instance.new("Frame")
    divider.Size = UDim2.new(1, 0, 0, 10)
    divider.BackgroundTransparency = 1
    divider.Parent = parent
    return divider
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- LABEL
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createLabel(parent, text)
    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, 0, 0, 24)
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
-- INFO BOX
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createInfoBox(parent, text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 50)
    container.BackgroundColor3 = Color3.fromRGB(30, 40, 65)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Color3.fromRGB(60, 80, 120), 1)
    
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
-- BUTTON
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createButton(parent, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 40)
    btn.BackgroundColor3 = Colors.Accent
    btn.BorderSizePixel = 0
    btn.AutoButtonColor = false
    btn.Text = text or "Button"
    btn.TextColor3 = Colors.Text
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 13
    btn.Parent = parent
    
    corner(btn, 10)
    
    local btnStroke = Instance.new("UIStroke")
    btnStroke.Color = Colors.AccentSoft
    btnStroke.Thickness = 1
    btnStroke.Transparency = 0.5
    btnStroke.Parent = btn
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundColor3 = Colors.AccentSoft}, 0.15)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundColor3 = Colors.Accent}, 0.15)
    end)
    
    btn.MouseButton1Click:Connect(function()
        tween(btn, {BackgroundColor3 = Colors.AccentDark}, 0.05)
        task.delay(0.1, function()
            tween(btn, {BackgroundColor3 = Colors.Accent}, 0.15)
        end)
        if callback then task.spawn(callback) end
    end)
    
    return btn
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- DROPDOWN/SELECT
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createDropdown(parent, text, options, defaultIndex, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.ClipsDescendants = false
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Colors.Border, 1)
    glassGradient(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, -10, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Dropdown"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Dropdown button
    local dropBtn = Instance.new("TextButton")
    dropBtn.Size = UDim2.new(0.45, 0, 0, 30)
    dropBtn.Position = UDim2.new(1, -14, 0.5, 0)
    dropBtn.AnchorPoint = Vector2.new(1, 0.5)
    dropBtn.BackgroundColor3 = Colors.KeybindBg
    dropBtn.BorderSizePixel = 0
    dropBtn.AutoButtonColor = false
    dropBtn.Text = options[defaultIndex or 1] or "Select"
    dropBtn.TextColor3 = Colors.Text
    dropBtn.Font = Enum.Font.GothamMedium
    dropBtn.TextSize = 12
    dropBtn.Parent = container
    corner(dropBtn, 8)
    glassBorder(dropBtn, Colors.Border, 1)
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -24, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Colors.TextMuted
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = dropBtn
    
    -- Options container
    local optionsFrame = Instance.new("Frame")
    optionsFrame.Size = UDim2.new(0.45, 0, 0, 0)
    optionsFrame.Position = UDim2.new(1, -14, 1, 4)
    optionsFrame.AnchorPoint = Vector2.new(1, 0)
    optionsFrame.BackgroundColor3 = Colors.Glass
    optionsFrame.BorderSizePixel = 0
    optionsFrame.ClipsDescendants = true
    optionsFrame.Visible = false
    optionsFrame.ZIndex = 10
    optionsFrame.Parent = container
    corner(optionsFrame, 8)
    glassBorder(optionsFrame, Colors.Border, 1)
    
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
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 28)
        optBtn.BackgroundColor3 = Colors.GlassLight
        optBtn.BackgroundTransparency = 0.5
        optBtn.BorderSizePixel = 0
        optBtn.AutoButtonColor = false
        optBtn.Text = option
        optBtn.TextColor3 = i == selectedIndex and Colors.Accent or Colors.TextSoft
        optBtn.Font = Enum.Font.GothamMedium
        optBtn.TextSize = 12
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
                    child.TextColor3 = child.Text == option and Colors.Accent or Colors.TextSoft
                end
            end
            
            -- Close dropdown
            isOpen = false
            tween(optionsFrame, {Size = UDim2.new(0.45, 0, 0, 0)}, 0.2)
            tween(arrow, {Rotation = 0}, 0.2)
            task.delay(0.2, function()
                optionsFrame.Visible = false
            end)
            
            if callback then callback(option, i) end
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
        tween(dropBtn, {BackgroundColor3 = Colors.KeybindHover}, 0.15)
    end)
    
    dropBtn.MouseLeave:Connect(function()
        tween(dropBtn, {BackgroundColor3 = Colors.KeybindBg}, 0.15)
    end)
    
    return {
        Container = container,
        SetSelected = function(self, index)
            if options[index] then
                selectedIndex = index
                dropBtn.Text = options[index]
                for _, child in ipairs(optionsFrame:GetChildren()) do
                    if child:IsA("TextButton") then
                        child.TextColor3 = child.Text == options[index] and Colors.Accent or Colors.TextSoft
                    end
                end
            end
        end,
        GetSelected = function(self)
            return options[selectedIndex], selectedIndex
        end
    }
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- TEXT INPUT
-- ═══════════════════════════════════════════════════════════════════════════════
function Components.createTextInput(parent, text, placeholder, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Colors.Border, 1)
    glassGradient(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Input"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Input box
    local inputBox = Instance.new("TextBox")
    inputBox.Size = UDim2.new(0.55, -14, 0, 30)
    inputBox.Position = UDim2.new(1, -14, 0.5, 0)
    inputBox.AnchorPoint = Vector2.new(1, 0.5)
    inputBox.BackgroundColor3 = Colors.KeybindBg
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
    glassBorder(inputBox, Colors.Border, 1)
    
    inputBox.Focused:Connect(function()
        tween(inputBox, {BackgroundColor3 = Colors.KeybindHover}, 0.15)
    end)
    
    inputBox.FocusLost:Connect(function(enterPressed)
        tween(inputBox, {BackgroundColor3 = Colors.KeybindBg}, 0.15)
        if callback then callback(inputBox.Text, enterPressed) end
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
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container, Colors.Border, 1)
    glassGradient(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -80, 1, 0)
    label.Position = UDim2.new(0, 14, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Color"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Color preview
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
    
    -- Simple color presets popup
    local presetsFrame = Instance.new("Frame")
    presetsFrame.Size = UDim2.new(0, 200, 0, 0)
    presetsFrame.Position = UDim2.new(1, -64, 1, 4)
    presetsFrame.AnchorPoint = Vector2.new(1, 0)
    presetsFrame.BackgroundColor3 = Colors.Glass
    presetsFrame.BorderSizePixel = 0
    presetsFrame.ClipsDescendants = true
    presetsFrame.Visible = false
    presetsFrame.ZIndex = 10
    presetsFrame.Parent = container
    corner(presetsFrame, 8)
    glassBorder(presetsFrame, Colors.Border, 1)
    
    local presetsLayout = Instance.new("UIGridLayout")
    presetsLayout.CellSize = UDim2.new(0, 32, 0, 32)
    presetsLayout.CellPadding = UDim2.new(0, 6, 0, 6)
    presetsLayout.Parent = presetsFrame
    
    local presetsPadding = Instance.new("UIPadding")
    presetsPadding.PaddingTop = UDim.new(0, 8)
    presetsPadding.PaddingBottom = UDim.new(0, 8)
    presetsPadding.PaddingLeft = UDim.new(0, 8)
    presetsPadding.PaddingRight = UDim.new(0, 8)
    presetsPadding.Parent = presetsFrame
    
    local presetColors = {
        Color3.fromRGB(255, 80, 80),
        Color3.fromRGB(255, 150, 80),
        Color3.fromRGB(255, 220, 80),
        Color3.fromRGB(150, 255, 80),
        Color3.fromRGB(80, 255, 150),
        Color3.fromRGB(80, 255, 255),
        Color3.fromRGB(80, 150, 255),
        Color3.fromRGB(150, 80, 255),
        Color3.fromRGB(255, 80, 255),
        Color3.fromRGB(255, 80, 150),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(100, 100, 100)
    }
    
    local isOpen = false
    
    for _, color in ipairs(presetColors) do
        local presetBtn = Instance.new("TextButton")
        presetBtn.Size = UDim2.new(0, 32, 0, 32)
        presetBtn.BackgroundColor3 = color
        presetBtn.BorderSizePixel = 0
        presetBtn.AutoButtonColor = false
        presetBtn.Text = ""
        presetBtn.ZIndex = 11
        presetBtn.Parent = presetsFrame
        corner(presetBtn, 6)
        
        presetBtn.MouseButton1Click:Connect(function()
            currentColor = color
            colorBtn.BackgroundColor3 = color
            
            isOpen = false
            tween(presetsFrame, {Size = UDim2.new(0, 200, 0, 0)}, 0.2)
            task.delay(0.2, function()
                presetsFrame.Visible = false
            end)
            
            if callback then callback(color) end
        end)
    end
    
    colorBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            presetsFrame.Visible = true
            tween(presetsFrame, {Size = UDim2.new(0, 200, 0, 100)}, 0.25, Enum.EasingStyle.Back)
        else
            tween(presetsFrame, {Size = UDim2.new(0, 200, 0, 0)}, 0.2)
            task.delay(0.2, function()
                presetsFrame.Visible = false
            end)
        end
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
-- EXPOSE COLORS FOR EXTERNAL USE
-- ═══════════════════════════════════════════════════════════════════════════════
Components.Colors = Colors

-- ═══════════════════════════════════════════════════════════════════════════════
-- GLOBAL REGISTRATION
-- ═══════════════════════════════════════════════════════════════════════════════
_G.VertexComponents = Components

return Components
