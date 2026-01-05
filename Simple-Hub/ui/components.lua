-- components_enhanced.lua - GLASSMORPHISM WITH DROPDOWN CATEGORIES & KEYBIND SUPPORT
-- Floating cards, collapsible sections, smooth animations, keybind integration

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
-- EXPANDABLE SECTION - DROPDOWN/CONTRACTABLE
-- ============================================
function Components.createExpandableSection(parent, title, initialState)
    local sectionContainer = Instance.new("Frame")
    sectionContainer.Name = "Section_" .. (title or "Untitled")
    sectionContainer.Size = UDim2.new(1, 0, 0, 48)
    sectionContainer.BackgroundTransparency = 1
    sectionContainer.Parent = parent
    
    -- Header button (clickable)
    local header = Instance.new("TextButton")
    header.Size = UDim2.new(1, 0, 0, 48)
    header.BackgroundColor3 = Colors.Glass
    header.BackgroundTransparency = 0.2
    header.BorderSizePixel = 0
    header.AutoButtonColor = false
    header.Text = ""
    header.Parent = sectionContainer
    
    corner(header, 12)
    glassBorder(header)
    
    -- Gradient overlay
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.92),
        NumberSequenceKeypoint.new(1, 0.96)
    }
    gradient.Rotation = 135
    gradient.Parent = header
    
    -- Color accent bar
    local accentBar = Instance.new("Frame")
    accentBar.Size = UDim2.new(0, 4, 1, -16)
    accentBar.Position = UDim2.new(0, 6, 0.5, 0)
    accentBar.AnchorPoint = Vector2.new(0, 0.5)
    accentBar.BackgroundColor3 = Colors.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Parent = header
    local accentCorner = Instance.new("UICorner")
    accentCorner.CornerRadius = UDim.new(0, 8)
    accentCorner.Parent = accentBar
    
    -- Icon (expands/collapses)
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 20, 0, 20)
    icon.Position = UDim2.new(0, 24, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "+"
    icon.TextColor3 = Colors.Accent
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 16
    icon.Parent = header
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 50, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title or "SECTION"
    titleLabel.TextColor3 = Colors.Text
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Font = Enum.Font.GothamMedium
    titleLabel.TextSize = 14
    titleLabel.Parent = header
    
    -- Content container (starts hidden)
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, 0, 0, 0)
    content.Position = UDim2.new(0, 0, 0, 52)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = true
    content.Visible = false
    content.Parent = sectionContainer
    
    -- Content inner (for proper sizing)
    local contentInner = Instance.new("Frame")
    contentInner.Name = "Inner"
    contentInner.Size = UDim2.new(1, 0, 0, 0)
    contentInner.BackgroundTransparency = 1
    contentInner.Parent = content
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.Padding = UDim.new(0, 8)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentInner
    
    local contentPadding = Instance.new("UIPadding")
    contentPadding.PaddingTop = UDim.new(0, 10)
    contentPadding.PaddingBottom = UDim.new(0, 10)
    contentPadding.PaddingLeft = UDim.new(0, 8)
    contentPadding.PaddingRight = UDim.new(0, 8)
    contentPadding.Parent = contentInner
    
    -- State
    local isOpen = initialState or false
    
    -- Toggle function
    local function toggle()
        isOpen = not isOpen
        
        if isOpen then
            -- Open animation
            content.Visible = true
            
            -- Calculate content height
            local totalHeight = contentPadding.PaddingTop.Offset + contentPadding.PaddingBottom.Offset
            for _, child in ipairs(contentInner:GetChildren()) do
                if child:IsA("GuiObject") and child.Visible then
                    totalHeight = totalHeight + child.AbsoluteSize.Y
                end
            end
            totalHeight = totalHeight + (contentLayout.Padding.Offset * (#contentInner:GetChildren() - 1))
            
            -- Animate expansion
            tween(content, {Size = UDim2.new(1, 0, 0, totalHeight)}, 0.3)
            tween(sectionContainer, {Size = UDim2.new(1, 0, 0, 48 + totalHeight)}, 0.3)
            tween(icon, {Text = "×", TextColor3 = Colors.AccentSoft})
            tween(header, {BackgroundTransparency = 0.15})
            tween(titleLabel, {TextColor3 = Colors.AccentSoft})
        else
            -- Close animation
            tween(icon, {Text = "+", TextColor3 = Colors.Accent})
            tween(titleLabel, {TextColor3 = Colors.Text})
            tween(header, {BackgroundTransparency = 0.2})
            tween(content, {Size = UDim2.new(1, 0, 0, 0)}, 0.25)
            tween(sectionContainer, {Size = UDim2.new(1, 0, 0, 48)}, 0.25)
            
            task.delay(0.25, function()
                content.Visible = false
            end)
        end
    end
    
    -- Click handler
    header.MouseButton1Click:Connect(toggle)
    
    -- Hover effects
    header.MouseEnter:Connect(function()
        if not isOpen then
            tween(header, {BackgroundTransparency = 0.1})
            tween(titleLabel, {TextColor3 = Colors.TextSoft})
        end
    end)
    
    header.MouseLeave:Connect(function()
        if not isOpen then
            tween(header, {BackgroundTransparency = 0.2})
            tween(titleLabel, {TextColor3 = Colors.Text})
        end
    end)
    
    -- Open if initial state is true
    if initialState then
        task.delay(0.1, toggle)
    end
    
    -- Return the content container for adding items
    return contentInner
end

-- ============================================
-- TOGGLE WITH KEYBIND SUPPORT
-- ============================================
function Components.createToggle(parent, text, callback, initialState, keybindText)
    local container = Instance.new("TextButton")
    container.Name = "Toggle"
    container.Size = UDim2.new(1, 0, 0, 52)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    
    -- Gradient overlay
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.94),
        NumberSequenceKeypoint.new(1, 0.97)
    }
    gradient.Rotation = 135
    gradient.Parent = container
    
    -- Left color indicator
    local indicator = Instance.new("Frame")
    indicator.Size = UDim2.new(0, 0, 1, -16)
    indicator.Position = UDim2.new(0, 6, 0.5, 0)
    indicator.AnchorPoint = Vector2.new(0, 0.5)
    indicator.BackgroundColor3 = Colors.Accent
    indicator.BorderSizePixel = 0
    indicator.Parent = container
    local indCorner = Instance.new("UICorner")
    indCorner.CornerRadius = UDim.new(0, 6)
    indCorner.Parent = indicator
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 1, 0)
    label.Position = UDim2.new(0, 20, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Toggle"
    if keybindText then
        label.Text = text .. " " .. keybindText
    end
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Modern pill switch
    local switchBg = Instance.new("Frame")
    switchBg.Size = UDim2.new(0, 48, 0, 24)
    switchBg.Position = UDim2.new(1, -58, 0.5, 0)
    switchBg.AnchorPoint = Vector2.new(0, 0.5)
    switchBg.BackgroundColor3 = Colors.Glass
    switchBg.BorderSizePixel = 0
    switchBg.Parent = container
    corner(switchBg, 12)
    
    local switchStroke = Instance.new("UIStroke")
    switchStroke.Color = Colors.Border
    switchStroke.Thickness = 2
    switchStroke.Transparency = 0.6
    switchStroke.Parent = switchBg
    
    local switchCircle = Instance.new("Frame")
    switchCircle.Size = UDim2.new(0, 20, 0, 20)
    switchCircle.Position = UDim2.new(0, 2, 0.5, 0)
    switchCircle.AnchorPoint = Vector2.new(0, 0.5)
    switchCircle.BackgroundColor3 = Colors.TextMuted
    switchCircle.BorderSizePixel = 0
    switchCircle.Parent = switchBg
    corner(switchCircle, 10)
    
    local state = initialState or false
    
    local function updateVisual()
        if state then
            tween(indicator, {Size = UDim2.new(0, 4, 1, -16)})
            tween(label, {TextColor3 = Colors.Text})
            tween(switchBg, {BackgroundColor3 = Colors.Accent})
            tween(switchCircle, {
                Position = UDim2.new(1, -22, 0.5, 0),
                BackgroundColor3 = Colors.Text
            })
            tween(switchStroke, {Transparency = 0})
        else
            tween(indicator, {Size = UDim2.new(0, 0, 1, -16)})
            tween(label, {TextColor3 = Colors.TextSoft})
            tween(switchBg, {BackgroundColor3 = Colors.Glass})
            tween(switchCircle, {
                Position = UDim2.new(0, 2, 0.5, 0),
                BackgroundColor3 = Colors.TextMuted
            })
            tween(switchStroke, {Transparency = 0.6})
        end
    end
    
    updateVisual()
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.15})
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.25})
    end)
    
    container.MouseButton1Click:Connect(function()
        state = not state
        updateVisual()
        if callback then task.spawn(callback, state) end
    end)
    
    local toggleObject = {
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
        GetState = function(self) return state end,
        UpdateKeybindText = function(self, keyText)
            if keyText then
                label.Text = text .. " " .. keyText
            end
        end
    }
    
    return toggleObject
end

-- ============================================
-- SLIDER WITH MODERN DESIGN
-- ============================================
function Components.createSlider(parent, text, min, max, defaultValue, callback)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 72)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.25
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    
    -- Gradient
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 200, 220))
    }
    gradient.Transparency = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 0.94),
        NumberSequenceKeypoint.new(1, 0.97)
    }
    gradient.Rotation = 135
    gradient.Parent = container
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -100, 0, 24)
    label.Position = UDim2.new(0, 16, 0, 12)
    label.BackgroundTransparency = 1
    label.Text = text or "Slider"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Value bubble
    local valueBubble = Instance.new("Frame")
    valueBubble.Size = UDim2.new(0, 56, 0, 26)
    valueBubble.Position = UDim2.new(1, -72, 0, 11)
    valueBubble.BackgroundColor3 = Colors.Accent
    valueBubble.BorderSizePixel = 0
    valueBubble.Parent = container
    corner(valueBubble, 13)
    
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(1, 0, 1, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(defaultValue or min)
    valueLabel.TextColor3 = Colors.Text
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.Parent = valueBubble
    
    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -32, 0, 4)
    track.Position = UDim2.new(0, 16, 1, -24)
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
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = Colors.Text
    handle.BorderSizePixel = 0
    handle.ZIndex = 2
    handle.Parent = track
    corner(handle, 8)
    
    local handleShadow = Instance.new("UIStroke")
    handleShadow.Color = Colors.Accent
    handleShadow.Thickness = 3
    handleShadow.Transparency = 0.4
    handleShadow.Parent = handle
    
    local value = defaultValue or min
    local dragging = false
    
    local function updateVisual(percent)
        percent = math.clamp(percent, 0, 1)
        value = math.floor(min + (max - min) * percent)
        valueLabel.Text = tostring(value)
        
        tween(fill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.12)
        tween(handle, {Position = UDim2.new(percent, 0, 0.5, 0)}, 0.12)
        
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
-- KEYBIND CONFIGURATION BUTTON
-- ============================================
function Components.createKeybindButton(parent, text, currentKey, callback)
    local container = Instance.new("TextButton")
    container.Size = UDim2.new(1, 0, 0, 44)
    container.BackgroundColor3 = Colors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.AutoButtonColor = false
    container.Text = ""
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -120, 1, 0)
    label.Position = UDim2.new(0, 16, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Keybind"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 13
    label.Parent = container
    
    -- Key display
    local keyDisplay = Instance.new("TextButton")
    keyDisplay.Size = UDim2.new(0, 80, 0, 28)
    keyDisplay.Position = UDim2.new(1, -88, 0.5, 0)
    keyDisplay.AnchorPoint = Vector2.new(0, 0.5)
    keyDisplay.BackgroundColor3 = Colors.Accent
    keyDisplay.BorderSizePixel = 0
    keyDisplay.Text = tostring(currentKey.Name):gsub("^%l", string.upper)
    keyDisplay.TextColor3 = Colors.Text
    keyDisplay.Font = Enum.Font.GothamBold
    keyDisplay.TextSize = 12
    keyDisplay.AutoButtonColor = false
    keyDisplay.Parent = container
    corner(keyDisplay, 8)
    
    local waitingForInput = false
    
    local function startListening()
        if waitingForInput then return end
        waitingForInput = true
        
        local originalText = keyDisplay.Text
        keyDisplay.Text = "..."
        tween(keyDisplay, {BackgroundColor3 = Colors.AccentSoft}, 0.2)
        
        local connection
        connection = UIS.InputBegan:Connect(function(input, gp)
            if gp then return end
            
            if input.UserInputType == Enum.UserInputType.Keyboard then
                waitingForInput = false
                connection:Disconnect()
                
                keyDisplay.Text = tostring(input.KeyCode.Name):gsub("^%l", string.upper)
                tween(keyDisplay, {BackgroundColor3 = Colors.Accent}, 0.2)
                
                if callback then
                    callback(input.KeyCode)
                end
            end
        end)
        
        -- Cancel on ESC
        task.spawn(function()
            while waitingForInput do
                if UIS:IsKeyDown(Enum.KeyCode.Escape) then
                    waitingForInput = false
                    keyDisplay.Text = originalText
                    tween(keyDisplay, {BackgroundColor3 = Colors.Accent}, 0.2)
                    if connection then connection:Disconnect() end
                    break
                end
                task.wait()
            end
        end)
    end
    
    keyDisplay.MouseButton1Click:Connect(startListening)
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2})
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3})
    end)
    
    keyDisplay.MouseEnter:Connect(function()
        tween(keyDisplay, {BackgroundColor3 = Colors.AccentSoft})
    end)
    
    keyDisplay.MouseLeave:Connect(function()
        if not waitingForInput then
            tween(keyDisplay, {BackgroundColor3 = Colors.Accent})
        end
    end)
    
    return {
        Button = container,
        UpdateKey = function(self, newKey)
            keyDisplay.Text = tostring(newKey.Name):gsub("^%l", string.upper)
        end
    }
end

-- ============================================
-- SECTION HEADER (Simple)
-- ============================================
function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Size = UDim2.new(1, 0, 0, 32)
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
    divider.Size = UDim2.new(1, 0, 0, 12)
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

-- ============================================
-- INFO BOX
-- ============================================
function Components.createInfoBox(parent, text)
    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 60)
    container.BackgroundColor3 = Color3.fromRGB(30, 40, 60)
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 10)
    glassBorder(container)
    
    local icon = Instance.new("TextLabel")
    icon.Size = UDim2.new(0, 24, 0, 24)
    icon.Position = UDim2.new(0, 12, 0.5, 0)
    icon.AnchorPoint = Vector2.new(0, 0.5)
    icon.BackgroundTransparency = 1
    icon.Text = "ℹ"
    icon.TextColor3 = Colors.AccentSoft
    icon.Font = Enum.Font.GothamBold
    icon.TextSize = 18
    icon.Parent = container
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, -48, 1, -12)
    label.Position = UDim2.new(0, 44, 0, 6)
    label.BackgroundTransparency = 1
    label.Text = text or "Information"
    label.TextColor3 = Colors.TextSoft
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    label.TextWrapped = true
    label.Parent = container
    
    return container
end

_G.VertexComponents = Components
return Components
