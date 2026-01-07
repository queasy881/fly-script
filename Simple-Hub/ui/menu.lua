-- menu.lua
-- Vertical Hub - Fresh Implementation
-- Fully vertical menu, optimized UX, only specified features

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- Inline components to avoid require and script.Parent issues for loadstring

local Components = {}

-- Colors (simplified palette)
local Colors = {
    Background = Color3.fromRGB(20, 20, 30),
    Header = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextSoft = Color3.fromRGB(200, 200, 220),
    Accent = Color3.fromRGB(100, 120, 255),
    Bar = Color3.fromRGB(40, 40, 50),
    Border = Color3.fromRGB(60, 60, 80)
}

-- Utility: Corner
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

-- Utility: Border
local function border(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Border
    s.Thickness = 1
    s.Parent = parent
    return s
end

-- Utility: Tween
local function tween(obj, props, time)
    local info = TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Create Section Label
function Components.createSectionLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(150, 150, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = parent
    return label
end

-- Create Toggle with Keybind
function Components.createToggle(parent, text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.2, 0, 1, 0)
    button.Position = UDim2.new(0.55, 0, 0, 0)
    button.Text = "Off"
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = frame
    corner(button)
    border(button)

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0.2, 0, 1, 0)
    keybindBtn.Position = UDim2.new(0.8, 0, 0, 0)
    keybindBtn.Text = "None"
    keybindBtn.BackgroundColor3 = Colors.Bar
    keybindBtn.TextColor3 = Colors.TextSoft
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.TextSize = 12
    keybindBtn.Parent = frame
    corner(keybindBtn)
    border(keybindBtn)

    local state = false
    local update = function()
        button.Text = state and "On" or "Off"
        tween(button, {BackgroundColor3 = state and Colors.Accent or Colors.Bar}, 0.15)
        callback(state)
    end

    button.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    return {
        Set = function(value)
            state = value
            update()
        end,
        Toggle = function()
            state = not state
            update()
        end,
        SetKeybindText = function(txt)
            keybindBtn.Text = txt
        end,
        GetKeybindButton = function()
            return keybindBtn
        end
    }
end

-- Create Group with Expandable Dropdown
function Components.createGroup(parent, text, callback)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 0, 30)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.4, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = mainFrame

    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0.1, 0, 1, 0)
    expandBtn.Position = UDim2.new(0.45, 0, 0, 0)
    expandBtn.Text = "+"
    expandBtn.BackgroundColor3 = Colors.Bar
    expandBtn.TextColor3 = Colors.Text
    expandBtn.Font = Enum.Font.Gotham
    expandBtn.TextSize = 12
    expandBtn.Parent = mainFrame
    corner(expandBtn)
    border(expandBtn)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.2, 0, 1, 0)
    button.Position = UDim2.new(0.55, 0, 0, 0)
    button.Text = "Off"
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = mainFrame
    corner(button)
    border(button)

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0.2, 0, 1, 0)
    keybindBtn.Position = UDim2.new(0.8, 0, 0, 0)
    keybindBtn.Text = "None"
    keybindBtn.BackgroundColor3 = Colors.Bar
    keybindBtn.TextColor3 = Colors.TextSoft
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.TextSize = 12
    keybindBtn.Parent = mainFrame
    corner(keybindBtn)
    border(keybindBtn)

    local subFrame = Instance.new("Frame")
    subFrame.Size = UDim2.new(1, 0, 0, 0)
    subFrame.BackgroundTransparency = 1
    subFrame.ClipsDescendants = true
    subFrame.Parent = parent
    local subLayout = Instance.new("UIListLayout")
    subLayout.SortOrder = Enum.SortOrder.LayoutOrder
    subLayout.Padding = UDim.new(0, 5)
    subLayout.Parent = subFrame
    subLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        tween(subFrame, {Size = UDim2.new(1, 0, 0, expanded and subLayout.AbsoluteContentSize.Y or 0)}, 0.2)
    end)
    local subPadding = Instance.new("UIPadding")
    subPadding.PaddingLeft = UDim.new(0, 20)  -- Indent sub options
    subPadding.Parent = subFrame

    local state = false
    local expanded = false

    local updateToggle = function()
        button.Text = state and "On" or "Off"
        tween(button, {BackgroundColor3 = state and Colors.Accent or Colors.Bar}, 0.15)
        callback(state)
    end

    local updateExpand = function()
        expandBtn.Text = expanded and "x" or "+"
        tween(subFrame, {Size = UDim2.new(1, 0, 0, expanded and subLayout.AbsoluteContentSize.Y or 0)}, 0.2)
    end

    button.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)

    expandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        updateExpand()
    end)

    return {
        Set = function(value)
            state = value
            updateToggle()
        end,
        Toggle = function()
            state = not state
            updateToggle()
        end,
        SetKeybindText = function(txt)
            keybindBtn.Text = txt
        end,
        GetKeybindButton = function()
            return keybindBtn
        end,
        Expand = function(val)
            expanded = val
            updateExpand()
        end,
        SubContainer = subFrame
    }
end

-- Create Selector (Cycle through options)
function Components.createSelector(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.4, 0, 1, 0)
    button.Position = UDim2.new(0.6, 0, 0, 0)
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = frame
    corner(button)
    border(button)

    local index = table.find(options, default) or 1
    button.Text = options[index]

    button.MouseButton1Click:Connect(function()
        index = (index % #options) + 1
        button.Text = options[index]
        callback(options[index])
    end)

    return {
        Set = function(value)
            local newIndex = table.find(options, value) or 1
            index = newIndex
            button.Text = options[index]
        end
    }
end

-- Create Slider (More appealing with gradient)
function Components.createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Text = text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(1, 0, 0.5, 0)
    barFrame.Position = UDim2.new(0, 0, 0.5, 0)
    barFrame.BackgroundColor3 = Colors.Bar
    barFrame.Parent = frame
    corner(barFrame)
    border(barFrame)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.Parent = barFrame
    corner(fill)

    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(50, 60, 200)),
        ColorSequenceKeypoint.new(1, Colors.Accent)
    })
    gradient.Parent = fill

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Colors.Text
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 12
    valueLabel.Parent = barFrame

    local value = default
    local dragging = false

    barFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local rel = math.clamp((input.Position.X - barFrame.AbsolutePosition.X) / barFrame.AbsoluteSize.X, 0, 1)
            value = math.floor(min + (max - min) * rel + 0.5)
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.1)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    end)

    -- Set default
    local rel = (default - min) / (max - min)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    valueLabel.Text = tostring(default)

    return {
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local rel = (v - min) / (max - min)
            tween(fill, {Size = UDim2.new(rel, 0, 1, 0)}, 0.15)
            valueLabel.Text = tostring(v)
        end
    }
end

-- End inline components

-- State Management
local State = {
    Movement = {
        WalkSpeed = false,
        WalkSpeedValue = 16,
        WalkMethod = "Humanoid",
        SlideBoost = false,
        Fly = false,
        FlySpeed = 50,
        FlyMethod = "Velocity",
        Noclip = false,
        InfiniteJump = false
    },
    Combat = {
        AimAssist = false,
        AimSmoothness = 0.15,
        AimFOV = 150,
        AimPrediction = false,
        PredictionAmount = 0.1,
        SilentAim = false,
        SilentFOV = 150,
        SilentHitChance = 100,
        SilentPrediction = false,
        SilentPredictionAmount = 0.1
    },
    ESP = {
        Enabled = false,
        Box = false,
        Name = false,
        Health = false,
        Distance = false,
        MaxDistance = 1000,
        TeamCheck = false,
        Tracers = false,
        Chams = false,
        HeadDot = false
    },
    Visuals = {
        ChangeTime = false,
        TimeOfDay = 12,
        ChangeAmbient = false,
        AmbientR = 0.5,
        AmbientG = 0.5,
        AmbientB = 0.5,
        ChangeFOV = false,
        FOV = 70
    }
}

-- Keybinds and Toggles
local Keybinds = {}
local Toggles = {}
local waitingForBind = nil

-- GUI Creation
local gui = Instance.new("ScreenGui")
gui.Name = "VerticalHub"
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = true  -- Start enabled but hidden via position

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 600)
main.Position = UDim2.new(1, 300, 0.5, -300)  -- Start offscreen to the right
main.AnchorPoint = Vector2.new(1, 0.5)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.Parent = gui
corner(main, 8)
border(main, Color3.fromRGB(50, 50, 70))

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Vertical Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main
corner(title, 8)

local tabBar = Instance.new("Frame")
tabBar.Size = UDim2.new(1, 0, 0, 30)
tabBar.Position = UDim2.new(0, 0, 0, 40)
tabBar.BackgroundTransparency = 1
tabBar.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.FillDirection = Enum.FillDirection.Horizontal
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabBar

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -70)
scroll.Position = UDim2.new(0, 0, 0, 70)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 255)
scroll.Parent = main

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 5)
layout.Parent = scroll
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 10)
padding.PaddingRight = UDim.new(0, 10)
padding.Parent = scroll

local currentTab = "Movement"

local function rebuildScroll()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("GuiObject") and child ~= layout and child ~= padding then
            child:Destroy()
        end
    end

    Toggles = {}

    if currentTab == "Movement" then
        Components.createSectionLabel(scroll, "Movement")

        local walkGroup = Components.createGroup(scroll, "WalkSpeed", function(v) State.Movement.WalkSpeed = v end)
        Toggles.WalkSpeed = walkGroup
        local walkSub = walkGroup.SubContainer
        Components.createSelector(walkSub, "Method", {"Humanoid", "CFrame", "Velocity", "Impulse"}, State.Movement.WalkMethod, function(m) State.Movement.WalkMethod = m end)
        Components.createSlider(walkSub, "WalkSpeed Value", 16, 100, 16, function(v) State.Movement.WalkSpeedValue = v end)

        Toggles.SlideBoost = Components.createToggle(scroll, "Slide Boost", function(v) State.Movement.SlideBoost = v end)

        local flyGroup = Components.createGroup(scroll, "Fly", function(v) State.Movement.Fly = v end)
        Toggles.Fly = flyGroup
        local flySub = flyGroup.SubContainer
        Components.createSelector(flySub, "Method", {"Velocity", "CFrame", "Impulse"}, State.Movement.FlyMethod, function(m) State.Movement.FlyMethod = m end)
        Components.createSlider(flySub, "Fly Speed", 10, 300, 50, function(v) State.Movement.FlySpeed = v end)

        Toggles.Noclip = Components.createToggle(scroll, "Noclip", function(v) State.Movement.Noclip = v end)
        Toggles.InfiniteJump = Components.createToggle(scroll, "Infinite Jump", function(v) State.Movement.InfiniteJump = v end)
    elseif currentTab == "Combat" then
        Components.createSectionLabel(scroll, "Combat")

        local aimGroup = Components.createGroup(scroll, "Aim Assist", function(v) State.Combat.AimAssist = v end)
        Toggles.AimAssist = aimGroup
        local aimSub = aimGroup.SubContainer
        Components.createSlider(aimSub, "Aim Smoothness", 1, 50, 15, function(v) State.Combat.AimSmoothness = v / 100 end)
        Components.createSlider(aimSub, "Aim FOV", 50, 500, 150, function(v) State.Combat.AimFOV = v end)
        Toggles.AimPrediction = Components.createToggle(aimSub, "Aim Prediction", function(v) State.Combat.AimPrediction = v end)
        Components.createSlider(aimSub, "Prediction Amount", 1, 50, 10, function(v) State.Combat.PredictionAmount = v / 100 end)

        local silentGroup = Components.createGroup(scroll, "Silent Aim", function(v) State.Combat.SilentAim = v end)
        Toggles.SilentAim = silentGroup
        local silentSub = silentGroup.SubContainer
        Components.createSlider(silentSub, "Silent FOV", 50, 500, 150, function(v) State.Combat.SilentFOV = v end)
        Components.createSlider(silentSub, "Silent Hit Chance", 0, 100, 100, function(v) State.Combat.SilentHitChance = v end)
        Toggles.SilentPrediction = Components.createToggle(silentSub, "Silent Prediction", function(v) State.Combat.SilentPrediction = v end)
        Components.createSlider(silentSub, "Silent Prediction Amount", 1, 50, 10, function(v) State.Combat.SilentPredictionAmount = v / 100 end)
    elseif currentTab == "ESP" then
        Components.createSectionLabel(scroll, "ESP")

        local espGroup = Components.createGroup(scroll, "Enabled", function(v) State.ESP.Enabled = v end)
        Toggles.Enabled = espGroup
        local espSub = espGroup.SubContainer
        Toggles.Box = Components.createToggle(espSub, "Box", function(v) State.ESP.Box = v end)
        Toggles.Name = Components.createToggle(espSub, "Name", function(v) State.ESP.Name = v end)
        Toggles.Health = Components.createToggle(espSub, "Health", function(v) State.ESP.Health = v end)
        Toggles.Distance = Components.createToggle(espSub, "Distance", function(v) State.ESP.Distance = v end)
        Components.createSlider(espSub, "Max Distance", 100, 5000, 1000, function(v) State.ESP.MaxDistance = v end)
        Toggles.TeamCheck = Components.createToggle(espSub, "Team Check", function(v) State.ESP.TeamCheck = v end)
        Toggles.Tracers = Components.createToggle(espSub, "Tracers", function(v) State.ESP.Tracers = v end)
        Toggles.Chams = Components.createToggle(espSub, "Chams", function(v) State.ESP.Chams = v end)
        Toggles.HeadDot = Components.createToggle(espSub, "Head Dot", function(v) State.ESP.HeadDot = v end)
    elseif currentTab == "Visuals" then
        Components.createSectionLabel(scroll, "Visuals")

        local timeGroup = Components.createGroup(scroll, "Change Time of Day", function(v) State.Visuals.ChangeTime = v end)
        Toggles.ChangeTime = timeGroup
        local timeSub = timeGroup.SubContainer
        Components.createSlider(timeSub, "Time of Day", 0, 24, 12, function(v) State.Visuals.TimeOfDay = v end)

        local ambientGroup = Components.createGroup(scroll, "Change Ambience", function(v) State.Visuals.ChangeAmbient = v end)
        Toggles.ChangeAmbient = ambientGroup
        local ambientSub = ambientGroup.SubContainer
        Components.createSlider(ambientSub, "Ambient Red", 0, 255, 128, function(v) State.Visuals.AmbientR = v / 255 end)
        Components.createSlider(ambientSub, "Ambient Green", 0, 255, 128, function(v) State.Visuals.AmbientG = v / 255 end)
        Components.createSlider(ambientSub, "Ambient Blue", 0, 255, 128, function(v) State.Visuals.AmbientB = v / 255 end)

        local fovGroup = Components.createGroup(scroll, "Change FOV", function(v) State.Visuals.ChangeFOV = v end)
        Toggles.ChangeFOV = fovGroup
        local fovSub = fovGroup.SubContainer
        Components.createSlider(fovSub, "FOV Value", 10, 120, 70, function(v) State.Visuals.FOV = v end)
    end

    -- Setup keybinds for the current tab's toggles
    for feature, toggle in pairs(Toggles) do
        local btn = toggle.GetKeybindButton()
        if btn then
            btn.MouseButton1Click:Connect(function()
                btn.Text = "..."
                waitingForBind = function(key)
                    if key == Enum.KeyCode.Escape then
                        Keybinds[feature] = nil
                        btn.Text = "None"
                    else
                        Keybinds[feature] = key
                        btn.Text = key.Name
                    end
                    waitingForBind = nil
                end
            end)
        end
    end
end

local function createTabButton(name)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0.25, -5, 1, 0)
    btn.Text = name
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    btn.TextColor3 = Color3.fromRGB(200, 200, 200)
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = tabBar
    corner(btn, 6)

    btn.MouseButton1Click:Connect(function()
        currentTab = name
        rebuildScroll()
        for _, b in tabBar:GetChildren() do
            if b:IsA("TextButton") then
                b.BackgroundColor3 = (b.Text == name) and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(40, 40, 50)
                b.TextColor3 = (b.Text == name) and Color3.fromRGB(255,255,255) or Color3.fromRGB(200,200,200)
            end
        end
    end)

    return btn
end

local movementBtn = createTabButton("Movement")
local combatBtn = createTabButton("Combat")
local espBtn = createTabButton("ESP")
local visualsBtn = createTabButton("Visuals")

-- Set initial tab highlight
movementBtn.BackgroundColor3 = Color3.fromRGB(100, 120, 255)
movementBtn.TextColor3 = Color3.fromRGB(255, 255, 255)

rebuildScroll()

-- Toggle Menu (M Key) with animation
local menuVisible = false
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end

    if waitingForBind then
        waitingForBind(input.KeyCode)
        return
    end

    if input.KeyCode == Enum.KeyCode.M then
        menuVisible = not menuVisible
        local targetPos = menuVisible and UDim2.new(1, 0, 0.5, -300) or UDim2.new(1, 300, 0.5, -300)
        local tweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
        TweenService:Create(main, tweenInfo, {Position = targetPos}):Play()
    end

    for feature, key in pairs(Keybinds) do
        if input.KeyCode == key and Toggles[feature] then
            Toggles[feature].Toggle()
        end
    end
end)

-- Feature Implementations
local flyBodyVelocity, flyBodyGyro, walkBodyVelocity
RunService.RenderStepped:Connect(function(delta)
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if hum and root then
        -- WalkSpeed
        if State.Movement.WalkSpeed then
            local speed = State.Movement.WalkSpeedValue
            local moveDir = hum.MoveDirection * speed
            local method = State.Movement.WalkMethod

            if method == "Humanoid" then
                hum.WalkSpeed = speed
                if walkBodyVelocity then walkBodyVelocity:Destroy() walkBodyVelocity = nil end
            elseif method == "Velocity" then
                hum.WalkSpeed = 0  -- Prevent default movement
                if not walkBodyVelocity then
                    walkBodyVelocity = Instance.new("BodyVelocity")
                    walkBodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
                    walkBodyVelocity.Parent = root
                end
                walkBodyVelocity.Velocity = moveDir
            elseif method == "CFrame" then
                hum.WalkSpeed = 0
                root.CFrame = root.CFrame + moveDir * delta
                if walkBodyVelocity then walkBodyVelocity:Destroy() walkBodyVelocity = nil end
            elseif method == "Impulse" then
                hum.WalkSpeed = 0
                local mass = root.AssemblyMass
                root:ApplyImpulse(moveDir * mass * delta)
                if walkBodyVelocity then walkBodyVelocity:Destroy() walkBodyVelocity = nil end
            end
        else
            hum.WalkSpeed = 16
            if walkBodyVelocity then walkBodyVelocity:Destroy() walkBodyVelocity = nil end
        end

        -- SlideBoost
        if State.Movement.SlideBoost and hum:GetState() == Enum.HumanoidStateType.Freefall and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and hum.MoveDirection.Magnitude > 0 then
            root.Velocity = root.Velocity + hum.MoveDirection * 30 * delta
        end

        -- Fly
        if State.Movement.Fly then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hum.UseJumpPower = false
            hum.PlatformStand = true

            local speed = State.Movement.FlySpeed
            local method = State.Movement.FlyMethod

            local vel = Vector3.new()
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                vel = camera.CFrame:VectorToWorldSpace(dir)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end
            if vel.Magnitude > 0 then vel = vel.Unit * speed end

            if method == "Velocity" then
                if not flyBodyVelocity then
                    flyBodyVelocity = Instance.new("BodyVelocity")
                    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    flyBodyVelocity.Parent = root
                    flyBodyGyro = Instance.new("BodyGyro")
                    flyBodyGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
                    flyBodyGyro.P = 1e4
                    flyBodyGyro.Parent = root
                end
                flyBodyGyro.CFrame = camera.CFrame
                flyBodyVelocity.Velocity = vel
            elseif method == "CFrame" then
                if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
                if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
                root.CFrame = CFrame.lookAt(root.Position, root.Position + camera.CFrame.LookVector) + vel * delta
            elseif method == "Impulse" then
                if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
                if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
                local mass = root.AssemblyMass
                root:ApplyImpulse(vel * mass * delta)
                root.CFrame = CFrame.lookAt(root.Position, root.Position + camera.CFrame.LookVector)
            end
        else
            hum.PlatformStand = false
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        end

        -- Noclip
        if State.Movement.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
    end

    -- Visuals
    if State.Visuals.ChangeTime then
        Lighting.TimeOfDay = string.format("%02d:00:00", State.Visuals.TimeOfDay)
    end
    if State.Visuals.ChangeAmbient then
        Lighting.Ambient = Color3.new(State.Visuals.AmbientR, State.Visuals.AmbientG, State.Visuals.AmbientB)
    end
    if State.Visuals.ChangeFOV then
        camera.FieldOfView = State.Visuals.FOV
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.Movement.InfiniteJump then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- ESP Implementation
local espCache = {}
RunService.RenderStepped:Connect(function()
    for _, drawings in pairs(espCache) do
        for _, d in pairs(drawings) do
            if typeof(d) == "Instance" then
                d.Enabled = false
            else
                d.Visible = false
            end
        end
    end

    if not State.ESP.Enabled then return end

    local myTeam = player.Team
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return end

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player or not plr.Character then continue end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        local head = plr.Character:FindFirstChild("Head")
        if not root or not hum or hum.Health <= 0 then continue end

        if State.ESP.TeamCheck and plr.Team == myTeam then continue end

        local dist = (myRoot.Position - root.Position).Magnitude
        if dist > State.ESP.MaxDistance then continue end

        local corners = {}
        local size = Vector3.new(4, 6, 2) -- Adjusted larger bounding box
        for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
            local pos = root.CFrame * Vector3.new(x*size.X/2, y*size.Y/2, z*size.Z/2)
            local screen, onScreen = camera:WorldToViewportPoint(pos)
            if onScreen then
                table.insert(corners, Vector2.new(screen.X, screen.Y))
            end
        end end end

        if #corners == 0 then continue end  -- Changed from <8 to ==0

        local minX, minY = math.huge, math.huge
        local maxX, maxY = -math.huge, -math.huge
        for _, pos in ipairs(corners) do
            minX = math.min(minX, pos.X)
            minY = math.min(minY, pos.Y)
            maxX = math.max(maxX, pos.X)
            maxY = math.max(maxY, pos.Y)
        end

        local width = maxX - minX
        local height = maxY - minY
        if width < 5 or height < 5 then continue end

        local key = tostring(plr)
        if not espCache[key] then
            espCache[key] = {
                box = Drawing.new("Quad"),
                name = Drawing.new("Text"),
                health = Drawing.new("Line"),
                distance = Drawing.new("Text"),
                tracer = Drawing.new("Line"),
                headDot = Drawing.new("Circle"),
                chams = Instance.new("Highlight")
            }
            espCache[key].box.Thickness = 1
            espCache[key].box.Color = Color3.fromRGB(255, 255, 255)
            espCache[key].name.Size = 13
            espCache[key].name.Color = Color3.fromRGB(255, 255, 255)
            espCache[key].name.Center = true
            espCache[key].name.Outline = true
            espCache[key].health.Thickness = 2
            espCache[key].health.Color = Color3.fromRGB(0, 255, 0)
            espCache[key].distance.Size = 13
            espCache[key].distance.Color = Color3.fromRGB(255, 255, 255)
            espCache[key].distance.Center = true
            espCache[key].distance.Outline = true
            espCache[key].tracer.Thickness = 1
            espCache[key].tracer.Color = Color3.fromRGB(255, 255, 255)
            espCache[key].headDot.Radius = 3
            espCache[key].headDot.NumSides = 100
            espCache[key].headDot.Color = Color3.fromRGB(255, 0, 0)
            espCache[key].headDot.Filled = true
            espCache[key].chams.FillTransparency = 0.5
            espCache[key].chams.FillColor = Color3.fromRGB(255, 0, 0)
            espCache[key].chams.OutlineColor = Color3.fromRGB(255, 255, 255)
            espCache[key].chams.OutlineTransparency = 0
            espCache[key].chams.Adornee = plr.Character
            espCache[key].chams.Parent = plr.Character
        end

        local drawings = espCache[key]
        local screenHead, onScreenHead = camera:WorldToViewportPoint(head.Position)
        local screenRoot, onScreenRoot = camera:WorldToViewportPoint(root.Position)
        if not onScreenHead or not onScreenRoot then continue end

        if State.ESP.Box then
            drawings.box.PointA = Vector2.new(minX, minY)
            drawings.box.PointB = Vector2.new(maxX, minY)
            drawings.box.PointC = Vector2.new(maxX, maxY)
            drawings.box.PointD = Vector2.new(minX, maxY)
            drawings.box.Visible = true
        end

        if State.ESP.Name then
            drawings.name.Text = plr.Name
            drawings.name.Position = Vector2.new((minX + maxX)/2, minY - 14)
            drawings.name.Visible = true
        end

        if State.ESP.Health then
            local healthY = minY + height * (1 - (hum.Health / hum.MaxHealth))
            drawings.health.From = Vector2.new(minX - 4, maxY)
            drawings.health.To = Vector2.new(minX - 4, healthY)
            drawings.health.Visible = true
        end

        if State.ESP.Distance then
            drawings.distance.Text = math.floor(dist) .. " studs"
            drawings.distance.Position = Vector2.new((minX + maxX)/2, maxY + 2)
            drawings.distance.Visible = true
        end

        if State.ESP.Tracers then
            drawings.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            drawings.tracer.To = Vector2.new(screenRoot.X, screenRoot.Y)
            drawings.tracer.Visible = true
        end

        if State.ESP.HeadDot then
            drawings.headDot.Position = Vector2.new(screenHead.X, screenHead.Y)
            drawings.headDot.Visible = true
        end

        if State.ESP.Chams then
            drawings.chams.Enabled = true
        end
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    local key = tostring(plr)
    if espCache[key] then
        for _, d in pairs(espCache[key]) do
            if typeof(d) == "Instance" then
                d:Destroy()
            else
                d:Remove()
            end
        end
        espCache[key] = nil
    end
end)

-- Target Acquisition
local function getClosestTarget(fov)
    local closest, closestDist = nil, fov
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player or not plr.Character then continue end
        local root = plr.Character:FindFirstChild("HumanoidRootPart")
        local head = plr.Character:FindFirstChild("Head")
        local hum = plr.Character:FindFirstChildOfClass("Humanoid")
        if not root or not hum or hum.Health <= 0 then continue end

        local targetPart = head or root
        local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
        if not onScreen then continue end

        local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
        if dist >= closestDist then continue end

        closest = {Part = targetPart, Root = root}
        closestDist = dist
    end

    return closest
end

-- Aim Assist
RunService.RenderStepped:Connect(function()
    if not State.Combat.AimAssist then return end

    local target = getClosestTarget(State.Combat.AimFOV)
    if not target then return end

    local aimPos = target.Part.Position
    if State.Combat.AimPrediction then
        local myVel = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") or {}).AssemblyLinearVelocity or Vector3.zero
        local relVel = target.Root.AssemblyLinearVelocity - myVel
        aimPos += relVel * State.Combat.PredictionAmount
    end

    local targetDir = (aimPos - camera.CFrame.Position).Unit
    local newLook = camera.CFrame.LookVector:Lerp(targetDir, 1 - State.Combat.AimSmoothness)
    camera.CFrame = CFrame.lookAt(camera.CFrame.Position, camera.CFrame.Position + newLook)
end)

-- Silent Aim (Raycast Hook) with weapon check
local oldNamecall = nil
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    if method ~= "Raycast" or self ~= Workspace then
        return oldNamecall(self, ...)
    end

    local args = {...}
    if not State.Combat.SilentAim or typeof(args[1]) ~= "Vector3" or typeof(args[2]) ~= "Vector3" then
        return oldNamecall(self, ...)
    end

    local char = player.Character
    if not char then return oldNamecall(self, ...) end
    local tool = char:FindFirstChildOfClass("Tool")
    if not tool then return oldNamecall(self, ...) end  -- Only if holding a weapon/tool

    if math.random(1, 100) > State.Combat.SilentHitChance then
        return oldNamecall(self, ...)
    end

    local origin = args[1]
    local direction = args[2]

    local target = getClosestTarget(State.Combat.SilentFOV)
    if not target then return oldNamecall(self, ...) end

    local aimPos = target.Part.Position
    if State.Combat.SilentPrediction then
        local myVel = (player.Character and player.Character:FindFirstChild("HumanoidRootPart") or {}).AssemblyLinearVelocity or Vector3.zero
        local relVel = target.Root.AssemblyLinearVelocity - myVel
        aimPos += relVel * State.Combat.SilentPredictionAmount
    end

    args[2] = (aimPos - origin).Unit * direction.Magnitude
    return oldNamecall(self, unpack(args))
end)
