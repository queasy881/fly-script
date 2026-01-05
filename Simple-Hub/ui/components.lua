-- components.lua - EXECUTOR SAFE UI COMPONENTS

local Components = {}
-- SAFE FALLBACK: ensures SetState never errors
local function ensureSetState(obj)
    if obj and typeof(obj) == "Instance" and not obj.SetState then
        function obj:SetState(v)
            if typeof(v) ~= "boolean" then return end
            self._state = v
        end
    end
end

local TweenService = game:GetService("TweenService")
local TextService = game:GetService("TextService")

-- GLOBAL SAFETY PATCH FOR CONFIG SYSTEM
-- Makes SetState safe on ANY button-like object





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
-- TOGGLE COMPONENT
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
    
    -- Setter function
    function container:SetState(newState)
        if state ~= newState then
            state = newState
            updateVisual()
        end
    end
    
    -- Getter function
    function container:GetState()
        return state
    end
    
    return container
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
    label.Font = Enum.Font.GothamBold
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
    local initialPercent = (defaultValue - min) / (max - min)
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
    local function onInput(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
        end
    end
    
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            onInput(input)
        end
    end)
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local relativeX = (input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X
            updateVisual(relativeX)
        end
    end)
    
    -- Setter function
    function container:SetValue(newValue)
        newValue = math.clamp(newValue, min, max)
        value = newValue
        local percent = (value - min) / (max - min)
        valueLabel.Text = tostring(value)
        fill.Size = UDim2.new(percent, 0, 1, 0)
        handle.Position = UDim2.new(percent, 0, 0.5, 0)
    end
    
    -- Getter function
    function container:GetValue()
        return value
    end
    
    return container
end

-- ============================================
-- DROPDOWN COMPONENT
-- ============================================
function Components.createDropdown(parent, text, options, defaultIndex, callback)
    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. (text or "Unknown")
    container.Size = UDim2.new(1, -16, 0, 32)
    container.BackgroundColor3 = Colors.Surface
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = parent
    
    createCorner(container, 6)
    createStroke(container)
    
    -- Main button
    local mainButton = Instance.new("TextButton")
    mainButton.Name = "MainButton"
    mainButton.Size = UDim2.new(1, 0, 0, 32)
    mainButton.BackgroundTransparency = 1
    mainButton.AutoButtonColor = false
    mainButton.Text = ""
    mainButton.Parent = container
    
    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(1, -40, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text or "Dropdown"
    label.TextColor3 = Colors.TextDim
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = Enum.Font.GothamMedium
    label.TextSize = 12
    label.Parent = mainButton
    
    -- Selected value
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Name = "Value"
    valueLabel.Size = UDim2.new(0.4, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.6, 0, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = options[defaultIndex or 1] or ""
    valueLabel.TextColor3 = Colors.Text
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Font = Enum.Font.GothamMedium
    valueLabel.TextSize = 11
    valueLabel.Parent = mainButton
    
    -- Arrow
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 20, 1, 0)
    arrow.Position = UDim2.new(1, -20, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.Text = "▼"
    arrow.TextColor3 = Colors.TextDim
    arrow.TextXAlignment = Enum.TextXAlignment.Center
    arrow.Font = Enum.Font.GothamBold
    arrow.TextSize = 10
    arrow.Parent = mainButton
    
    -- Dropdown list
    local listFrame = Instance.new("Frame")
    listFrame.Name = "List"
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 1, 2)
    listFrame.BackgroundColor3 = Colors.Panel
    listFrame.BorderSizePixel = 0
    listFrame.Visible = false
    listFrame.Parent = container
    createCorner(listFrame, 6)
    createStroke(listFrame)
    
    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 1)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listFrame
    
    -- State
    local selectedIndex = defaultIndex or 1
    local isOpen = false
    local optionButtons = {}
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionBtn = Instance.new("TextButton")
        optionBtn.Name = "Option_" .. i
        optionBtn.Size = UDim2.new(1, 0, 0, 28)
        optionBtn.BackgroundColor3 = Colors.Panel
        optionBtn.BorderSizePixel = 0
        optionBtn.AutoButtonColor = false
        optionBtn.Text = option
        optionBtn.TextColor3 = Colors.TextDim
        optionBtn.Font = Enum.Font.Gotham
        optionBtn.TextSize = 11
        optionBtn.LayoutOrder = i
        optionBtn.Parent = listFrame
        
        createCorner(optionBtn, 4)
        
        optionBtn.MouseEnter:Connect(function()
            if i ~= selectedIndex then
                tween(optionBtn, {BackgroundColor3 = Color3.fromRGB(35, 35, 45)})
            end
        end)
        
        optionBtn.MouseLeave:Connect(function()
            if i ~= selectedIndex then
                tween(optionBtn, {BackgroundColor3 = Colors.Panel})
            end
        end)
        
        optionBtn.MouseButton1Click:Connect(function()
            selectedIndex = i
            valueLabel.Text = option
            
            -- Update all buttons
            for j, btn in ipairs(optionButtons) do
                if j == i then
                    tween(btn, {
                        BackgroundColor3 = Colors.Accent,
                        TextColor3 = Color3.fromRGB(255, 255, 255)
                    })
                else
                    tween(btn, {
                        BackgroundColor3 = Colors.Panel,
                        TextColor3 = Colors.TextDim
                    })
                end
            end
            
            -- Close dropdown
            isOpen = false
            tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
            task.wait(0.15)
            listFrame.Visible = false
            
            if callback then
                task.spawn(callback, i, option)
            end
        end)
        
        table.insert(optionButtons, optionBtn)
    end
    
    -- Update list size
    listFrame.Size = UDim2.new(1, 0, 0, #options * 28 + (#options - 1))
    
    -- Highlight selected
    if selectedIndex >= 1 and selectedIndex <= #options then
        tween(optionButtons[selectedIndex], {
            BackgroundColor3 = Colors.Accent,
            TextColor3 = Color3.fromRGB(255, 255, 255)
        })
    end
    
    -- Toggle dropdown
    mainButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            listFrame.Visible = true
            tween(listFrame, {Size = UDim2.new(1, 0, 0, #options * 28 + (#options - 1))}, 0.15)
            tween(arrow, {Text = "▲"}, 0.15)
        else
            tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
            tween(arrow, {Text = "▼"}, 0.15)
            task.wait(0.15)
            listFrame.Visible = false
        end
    end)
    
    -- Close when clicking outside
    local function closeDropdown()
        if isOpen then
            isOpen = false
            tween(listFrame, {Size = UDim2.new(1, 0, 0, 0)}, 0.15)
            tween(arrow, {Text = "▼"}, 0.15)
            task.wait(0.15)
            listFrame.Visible = false
        end
    end
    
    -- Getter function
    function container:GetSelected()
        return selectedIndex, options[selectedIndex]
    end
    
    -- Setter function
    function container:SetSelected(index)
        if index >= 1 and index <= #options then
            selectedIndex = index
            valueLabel.Text = options[index]
            
            -- Update button colors
            for i, btn in ipairs(optionButtons) do
                if i == index then
                    btn.BackgroundColor3 = Colors.Accent
                    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    btn.BackgroundColor3 = Colors.Panel
                    btn.TextColor3 = Colors.TextDim
                end
            end
        end
    end
    
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
    
    -- Focus events
    input.Focused:Connect(function()
        tween(input, {
            BackgroundColor3 = Color3.fromRGB(30, 30, 40)
        })
    end)
    
    input.FocusLost:Connect(function(enterPressed)
        tween(input, {
            BackgroundColor3 = Colors.Background
        })
        
        if enterPressed and callback then
            task.spawn(callback, input.Text)
        end
    end)
    
    -- Setter function
    function container:SetText(newText)
        input.Text = newText or ""
    end
    
    -- Getter function
    function container:GetText()
        return input.Text
    end
    
    return container
end

-- ============================================
-- SCROLL LIST COMPONENT
-- ============================================
function Components.createScrollList(parent, height, itemHeight)
    local container = Instance.new("Frame")
    container.Name = "ScrollList"
    container.Size = UDim2.new(1, -16, 0, height or 150)
    container.BackgroundColor3 = Colors.Panel
    container.BorderSizePixel = 0
    container.ClipsDescendants = true
    container.Parent = parent
    
    createCorner(container, 6)
    createStroke(container)
    
    -- Scrolling frame
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.ScrollBarThickness = 4
    scroll.ScrollBarImageColor3 = Colors.Accent
    scroll.ScrollBarImageTransparency = 0.6
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    scroll.Parent = container
    
    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 2)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroll
    
    local padding = Instance.new("UIPadding")
    padding.PaddingTop = UDim.new(0, 4)
    padding.PaddingBottom = UDim.new(0, 4)
    padding.PaddingLeft = UDim.new(0, 4)
    padding.PaddingRight = UDim.new(0, 4)
    padding.Parent = scroll
    
    -- Items storage
    local items = {}
    
    -- Add item function
    function container:AddItem(text, data)
        local item = Instance.new("TextButton")
        item.Name = "Item_" .. (#items + 1)
        item.Size = UDim2.new(1, -8, 0, itemHeight or 28)
        item.BackgroundColor3 = Colors.Surface
        item.BorderSizePixel = 0
        item.AutoButtonColor = false
        item.Text = text or "Item"
        item.TextColor3 = Colors.TextDim
        item.Font = Enum.Font.Gotham
        item.TextSize = 11
        item.LayoutOrder = #items + 1
        item.Parent = scroll
        
        createCorner(item, 4)
        
        item.Data = data or {}
        
        item.MouseEnter:Connect(function()
            tween(item, {
                BackgroundColor3 = Color3.fromRGB(35, 35, 45),
                TextColor3 = Colors.Text
            })
        end)
        
        item.MouseLeave:Connect(function()
            tween(item, {
                BackgroundColor3 = Colors.Surface,
                TextColor3 = Colors.TextDim
            })
        end)
        
        table.insert(items, item)
        return item
    end
    
    -- Clear function
    function container:Clear()
        for _, item in ipairs(items) do
            item:Destroy()
        end
        items = {}
    end
    
    -- Get items function
    function container:GetItems()
        return items
    end
    
    -- Select item function
    function container:SelectItem(index)
        for i, item in ipairs(items) do
            if i == index then
                tween(item, {
                    BackgroundColor3 = Colors.Accent,
                    TextColor3 = Color3.fromRGB(255, 255, 255)
                })
            else
                tween(item, {
                    BackgroundColor3 = Colors.Surface,
                    TextColor3 = Colors.TextDim
                })
            end
        end
    end
    
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
    label.Text = text:upper() or "SECTION"
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

-- Export
_G.VertexComponents = Components
return Components
