-- ═══════════════════════════════════════════════════════════════════════════════
-- VERTEX HUB COMPONENTS - NEON SIDEBAR EDITION
-- Reusable UI components for the Vertex Hub menu
-- ═══════════════════════════════════════════════════════════════════════════════

local Components = {}

-- ═══════════════════════════════════════════════════════════════════════════════
-- SERVICES
-- ═══════════════════════════════════════════════════════════════════════════════
local TweenService = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

-- ═══════════════════════════════════════════════════════════════════════════════
-- NEON COLOR PALETTE
-- ═══════════════════════════════════════════════════════════════════════════════
local NeonColors = {
    ElectricPurple = Color3.fromRGB(180, 70, 255),
    BrightCyan = Color3.fromRGB(0, 255, 255),
    HotPink = Color3.fromRGB(255, 20, 147),
    LimeGreen = Color3.fromRGB(50, 255, 50),
    FieryOrange = Color3.fromRGB(255, 100, 0),
    NeonBlue = Color3.fromRGB(0, 150, 255),
    VibrantYellow = Color3.fromRGB(255, 255, 0),
    Background = Color3.fromRGB(10, 10, 15),
    Glass = Color3.fromRGB(20, 20, 30),
    GlassLight = Color3.fromRGB(30, 30, 45),
    GlassHover = Color3.fromRGB(40, 40, 60),
    Text = Color3.fromRGB(255, 255, 255),
    TextSoft = Color3.fromRGB(220, 220, 240),
    TextMuted = Color3.fromRGB(150, 150, 180),
    Glow = Color3.fromRGB(100, 200, 255),
    Outline = Color3.fromRGB(0, 200, 255)
}

Components.Colors = NeonColors

-- ═══════════════════════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════════════════════

local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function glowEffect(parent, color, thickness)
    local glow = Instance.new("UIStroke")
    glow.Color = color or NeonColors.Glow
    glow.Thickness = thickness or 2
    glow.Transparency = 0.3
    glow.Parent = parent
    return glow
end

local function neonBorder(parent, color, thickness)
    local border = Instance.new("UIStroke")
    border.Color = color or NeonColors.Outline
    border.Thickness = thickness or 1
    border.Transparency = 0.5
    border.Parent = parent
    return border
end

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

local function createAnimatedGradient(parent, colors, speed)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, colors[1] or NeonColors.ElectricPurple),
        ColorSequenceKeypoint.new(0.5, colors[2] or NeonColors.BrightCyan),
        ColorSequenceKeypoint.new(1, colors[3] or NeonColors.HotPink)
    }
    gradient.Rotation = 45
    gradient.Parent = parent
    
    if speed then
        local connection
        connection = RunService.RenderStepped:Connect(function(dt)
            gradient.Rotation = gradient.Rotation + (speed * dt * 10)
            if gradient.Rotation > 360 then
                gradient.Rotation = 0
            end
        end)
        
        parent:GetPropertyChangedSignal("Parent"):Connect(function()
            if not parent.Parent then
                connection:Disconnect()
            end
        end)
    end
    
    return gradient
end

-- ═══════════════════════════════════════════════════════════════════════════════
-- UI COMPONENTS
-- ═══════════════════════════════════════════════════════════════════════════════

function Components.createToggle(parent, text, callback, initialState, configKey, saveCallback)
    local button = Instance.new("TextButton")
    button.Name = "Toggle_" .. (text or "Toggle"):gsub("%s+", "_")
    button.Size = UDim2.new(1, -10, 0, 36)
    button.BackgroundColor3 = NeonColors.Glass
    button.BackgroundTransparency = 0.3
    button.BorderSizePixel = 0
    button.AutoButtonColor = false
    button.Text = ""
    button.Parent = parent
    
    corner(button, 8)
    glowEffect(button, NeonColors.ElectricPurple)
    neonBorder(button, NeonColors.BrightCyan)
    
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
    
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = UDim2.new(0, 50, 0, 24)
    toggleFrame.Position = UDim2.new(1, -60, 0.5, 0)
    toggleFrame.AnchorPoint = Vector2.new(0, 0.5)
    toggleFrame.BackgroundColor3 = NeonColors.Glass
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = button
    
    corner(toggleFrame, 12)
    glowEffect(toggleFrame)
    
    local toggleKnob = Instance.new("Frame")
    toggleKnob.Size = UDim2.new(0, 20, 0, 20)
    toggleKnob.Position = UDim2.new(0, 2, 0.5, 0)
    toggleKnob.AnchorPoint = Vector2.new(0, 0.5)
    toggleKnob.BackgroundColor3 = NeonColors.BrightCyan
    toggleKnob.BorderSizePixel = 0
    toggleKnob.Parent = toggleFrame
    
    corner(toggleKnob, 10)
    glowEffect(toggleKnob, NeonColors.BrightCyan, 3)
    
    local state = initialState or false
    local configKey = configKey
    local saveCallback = saveCallback
    
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
    
    updateVisual()
    
    button.MouseButton1Click:Connect(doToggle)
    
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

function Components.createSlider(parent, text, min, max, defaultValue, callback, configKey, saveCallback)
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. (text or ""):gsub("%s+", "")
    container.Size = UDim2.new(1, -10, 0, 60)
    container.BackgroundColor3 = NeonColors.Glass
    container.BackgroundTransparency = 0.3
    container.BorderSizePixel = 0
    container.Parent = parent
    
    corner(container, 8)
    glowEffect(container, NeonColors.HotPink)
    neonBorder(container)
    
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
    
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 1, -20)
    track.BackgroundColor3 = NeonColors.GlassLight
    track.BorderSizePixel = 0
    track.Parent = container
    
    corner(track, 3)
    glowEffect(track, NeonColors.FieryOrange)
    
    local initialPercent = ((defaultValue or min) - min) / (max - min)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(initialPercent, 0, 1, 0)
    fill.BackgroundColor3 = NeonColors.FieryOrange
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    corner(fill, 3)
    
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(initialPercent, 0, 0.5, 0)
    handle.AnchorPoint = Vector2.new(0.5, 0.5)
    handle.BackgroundColor3 = NeonColors.BrightCyan
    handle.BorderSizePixel = 0
    handle.Parent = track
    
    corner(handle, 8)
    glowEffect(handle, NeonColors.BrightCyan, 3)
    
    local value = defaultValue or min
    local dragging = false
    local configKey = configKey
    local saveCallback = saveCallback
    
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
    
    container.MouseEnter:Connect(function()
        tween(container, {BackgroundTransparency = 0.2}, 0.15)
    end)
    
    container.MouseLeave:Connect(function()
        tween(container, {BackgroundTransparency = 0.3}, 0.15)
    end)
    
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

function Components.createSection(parent, text)
    local section = Instance.new("Frame")
    section.Name = "Section_" .. (text or ""):gsub("%s+", "")
    section.Size = UDim2.new(1, -10, 0, 28)
    section.BackgroundTransparency = 1
    section.Parent = parent
    
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
    
    btn.MouseEnter:Connect(function()
        tween(btn, {BackgroundTransparency = 0.1}, 0.15)
        tween(btn, {TextColor3 = NeonColors.Text}, 0.15)
    end)
    
    btn.MouseLeave:Connect(function()
        tween(btn, {BackgroundTransparency = 0.3}, 0.15)
        tween(btn, {TextColor3 = NeonColors.Text}, 0.15)
    end)
    
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
    
    container.ColorBtn = colorBtn
    
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

-- ═══════════════════════════════════════════════════════════════════════════════
-- EXPOSE UTILITIES
-- ═══════════════════════════════════════════════════════════════════════════════
Components.Tween = tween
Components.Corner = corner
Components.GlowEffect = glowEffect
Components.NeonBorder = neonBorder
Components.CreateAnimatedGradient = createAnimatedGradient

-- ═══════════════════════════════════════════════════════════════════════════════
-- GLOBAL REGISTRATION
-- ═══════════════════════════════════════════════════════════════════════════════
_G.VertexComponents = Components

return Components
