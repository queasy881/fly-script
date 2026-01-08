-- Enhanced Horizontal Hub
-- Combined features with Hitbox Expander and additional utilities
-- Fixed menu persistence and added KILL ALL function

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()
local Expanded = {}
local espCache = {}
local hitboxCache = {}

-- Colors
local Colors = {
    Background = Color3.fromRGB(20, 20, 30),
    Header = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(255, 255, 255),
    TextSoft = Color3.fromRGB(200, 200, 220),
    Accent = Color3.fromRGB(100, 120, 255),
    Secondary = Color3.fromRGB(255, 100, 100),
    Bar = Color3.fromRGB(40, 40, 50),
    Border = Color3.fromRGB(60, 60, 80)
}

-- Utility Functions
local function corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 4)
    c.Parent = parent
    return c
end

local function border(parent, color)
    local s = Instance.new("UIStroke")
    s.Color = color or Colors.Border
    s.Thickness = 1
    s.Parent = parent
    return s
end

local function tween(obj, props, time)
    local info = TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- UI Components
local Components = {}

function Components.createSectionLabel(parent, text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 25)
    label.Text = " " .. text
    label.TextColor3 = Colors.Accent
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = parent
    return label
end

function Components.createToggle(parent, text, callback, initialState)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = "  " .. text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.2, 0, 0.7, 0)
    button.Position = UDim2.new(0.6, 0, 0.15, 0)
    button.Text = "Off"
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = frame
    corner(button, 6)
    border(button)

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0.15, 0, 0.7, 0)
    keybindBtn.Position = UDim2.new(0.82, 0, 0.15, 0)
    keybindBtn.Text = "None"
    keybindBtn.BackgroundColor3 = Colors.Bar
    keybindBtn.TextColor3 = Colors.TextSoft
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.TextSize = 11
    keybindBtn.Parent = frame
    corner(keybindBtn, 6)
    border(keybindBtn)

    local state = initialState or false
    local update = function()
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Colors.Accent or Colors.Bar
        button.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Colors.Text
        callback(state)
    end

    button.MouseButton1Click:Connect(function()
        state = not state
        update()
    end)

    -- Update immediately to show correct state
    update()

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
        end,
        GetState = function()
            return state
        end
    }
end

function Components.createSelector(parent, text, options, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = "  " .. text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.35, 0, 0.7, 0)
    button.Position = UDim2.new(0.6, 0, 0.15, 0)
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = frame
    corner(button, 6)
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

function Components.createSlider(parent, text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Text = "  " .. text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame

    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(0.7, 0, 0.4, 0)
    barFrame.Position = UDim2.new(0.3, 0, 0.55, 0)
    barFrame.BackgroundColor3 = Colors.Bar
    barFrame.Parent = frame
    corner(barFrame, 4)
    border(barFrame)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Colors.Accent
    fill.Parent = barFrame
    corner(fill, 4)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 0.4, 0)
    valueLabel.Position = UDim2.new(0.8, 0, 0.55, 0)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Colors.Text
    valueLabel.BackgroundTransparency = 1
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextSize = 13
    valueLabel.Parent = frame

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
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(value)
            callback(value)
        end
    end)

    local rel = (default - min) / (max - min)
    fill.Size = UDim2.new(rel, 0, 1, 0)
    valueLabel.Text = tostring(default)

    return {
        Set = function(v)
            v = math.clamp(v, min, max)
            value = v
            local rel = (v - min) / (max - min)
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(v)
        end,
        GetValue = function()
            return value
        end
    }
end

function Components.createGroup(parent, text, callback, initialState)
    local mainFrame = Instance.new("Frame")
    mainFrame.Size = UDim2.new(1, 0, 0, 30)
    mainFrame.BackgroundTransparency = 1
    mainFrame.Parent = parent

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.5, 0, 1, 0)
    label.Text = "  " .. text
    label.TextColor3 = Colors.Text
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = mainFrame

    local expandBtn = Instance.new("TextButton")
    expandBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
    expandBtn.Position = UDim2.new(0.5, 0, 0.15, 0)
    expandBtn.Text = "+"
    expandBtn.BackgroundColor3 = Colors.Bar
    expandBtn.TextColor3 = Colors.Text
    expandBtn.Font = Enum.Font.GothamBold
    expandBtn.TextSize = 14
    expandBtn.Parent = mainFrame
    corner(expandBtn, 6)
    border(expandBtn)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.15, 0, 0.7, 0)
    button.Position = UDim2.new(0.62, 0, 0.15, 0)
    button.Text = "Off"
    button.BackgroundColor3 = Colors.Bar
    button.TextColor3 = Colors.Text
    button.Font = Enum.Font.GothamBold
    button.TextSize = 12
    button.Parent = mainFrame
    corner(button, 6)
    border(button)

    local keybindBtn = Instance.new("TextButton")
    keybindBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
    keybindBtn.Position = UDim2.new(0.79, 0, 0.15, 0)
    keybindBtn.Text = "None"
    keybindBtn.BackgroundColor3 = Colors.Bar
    keybindBtn.TextColor3 = Colors.TextSoft
    keybindBtn.Font = Enum.Font.Gotham
    keybindBtn.TextSize = 11
    keybindBtn.Parent = mainFrame
    corner(keybindBtn, 6)
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
    subPadding.PaddingLeft = UDim.new(0, 20)
    subPadding.Parent = subFrame

    local state = initialState or false
    local expanded = Expanded[text] or false

    local updateToggle = function()
        button.Text = state and "ON" or "OFF"
        button.BackgroundColor3 = state and Colors.Accent or Colors.Bar
        callback(state)
    end

    local updateExpand = function()
        expandBtn.Text = expanded and "−" or "+"
        expandBtn.BackgroundColor3 = expanded and Colors.Accent or Colors.Bar
        tween(subFrame, {Size = UDim2.new(1, 0, 0, expanded and subLayout.AbsoluteContentSize.Y or 0)}, 0.2)
    end

    button.MouseButton1Click:Connect(function()
        state = not state
        updateToggle()
    end)

    expandBtn.MouseButton1Click:Connect(function()
        expanded = not expanded
        Expanded[text] = expanded
        updateExpand()
    end)

    updateToggle()
    updateExpand()

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
            Expanded[text] = val
            updateExpand()
        end,
        SubContainer = subFrame
    }
end

-- State Management
local State = {
    Movement = {
        WalkSpeed = false,
        WalkSpeedValue = 16,
        WalkMethod = "Humanoid",
        Fly = false,
        FlyMethod = "Velocity",
        FlySpeed = 50,
        Noclip = false,
        InfiniteJump = false,
        AutoJump = false,
        NoSlowdown = false,
        AntiAfk = false
    },
    Combat = {
        AimAssist = false,
        AimSmoothness = 0.15,
        AimFOV = 150,
        AimPrediction = false,
        PredictionAmount = 0.10,
        SilentAim = false,
        SilentFOV = 150,
        SilentHitChance = 100,
        HitboxExpander = false,
        HitboxMultiplier = 1.5,
        TriggerBot = false,
        TriggerDelay = 50,
        AutoClicker = false,
        CPS = 10,
        WallBang = false,
        KillAll = false,
        KillAllTarget = nil,
        KillAllCooldown = 0,
        -- NEW: Weapon Modifications
        FasterFireRate = false,
        FireRateMultiplier = 2.0,
        NoSpread = false,
        NoRecoil = false,
        AutoAutomatic = false,
        InstantReload = false,
        InfiniteAmmo = false
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
        HeadDot = false,
        Outlines = false,
        HealthBar = false,
        Weapon = false
    },
    Visuals = {
        ChangeTime = false,
        TimeOfDay = 12,
        ChangeAmbient = false,
        AmbientR = 0.5,
        AmbientG = 0.5,
        AmbientB = 0.5,
        ChangeFOV = false,
        FOV = 70,
        FullBright = false,
        NoFog = false,
        NoBloom = false,
        NoShadows = false
    },
    Misc = {
        SpeedHack = false,
        SpeedMultiplier = 1.0,
        AntiVoid = false,
        AutoFarm = false,
        AutoCollect = false,
        NoClipParts = {},
        ChatLogger = false,
        FPSBoost = false
    }
}

-- GUI Creation (Horizontal Layout)
local gui = Instance.new("ScreenGui")
gui.Name = "HorizontalHub"
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = true

-- Function to recreate GUI when player respawns/teleports
local function recreateGUI()
    if not gui or not gui.Parent then
        gui = Instance.new("ScreenGui")
        gui.Name = "HorizontalHub"
        gui.Parent = player:WaitForChild("PlayerGui")
        gui.Enabled = true
        main.Parent = gui
    end
end

-- Listen for character changes to fix menu bug
player.CharacterAdded:Connect(function()
    task.wait(0.5) -- Wait for PlayerGui to be ready
    recreateGUI()
end)

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 650, 0, 450)
main.Position = UDim2.new(0.5, -325, 0.5, -225)
main.BackgroundColor3 = Colors.Background
main.Parent = gui
corner(main, 10)
border(main, Color3.fromRGB(50, 50, 70))

-- Top Bar
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 35)
topBar.BackgroundColor3 = Colors.Header
topBar.Parent = main
corner(topBar, {topLeft = 10, topRight = 10, bottomLeft = 0, bottomRight = 0})

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0.5, 0, 1, 0)
title.Text = "HORIZONTAL HUB"
title.TextColor3 = Colors.Accent
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local version = Instance.new("TextLabel")
version.Size = UDim2.new(0.2, 0, 1, 0)
version.Position = UDim2.new(0.5, 0, 0, 0)
version.Text = "v2.1"
version.TextColor3 = Colors.TextSoft
version.BackgroundTransparency = 1
version.Font = Enum.Font.Gotham
version.TextSize = 12
version.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0.1, 0, 0.7, 0)
closeBtn.Position = UDim2.new(0.9, 0, 0.15, 0)
closeBtn.Text = "X"
closeBtn.BackgroundColor3 = Colors.Secondary
closeBtn.TextColor3 = Colors.Text
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 14
closeBtn.Parent = topBar
corner(closeBtn, 6)

-- Tab Container
local tabContainer = Instance.new("Frame")
tabContainer.Size = UDim2.new(0, 150, 1, -35)
tabContainer.Position = UDim2.new(0, 0, 0, 35)
tabContainer.BackgroundTransparency = 1
tabContainer.Parent = main

local tabLayout = Instance.new("UIListLayout")
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.Padding = UDim.new(0, 5)
tabLayout.Parent = tabContainer

local tabPadding = Instance.new("UIPadding")
tabPadding.PaddingTop = UDim.new(0, 10)
tabPadding.PaddingLeft = UDim.new(0, 10)
tabPadding.Parent = tabContainer

-- Content Container
local contentContainer = Instance.new("Frame")
contentContainer.Size = UDim2.new(1, -160, 1, -45)
contentContainer.Position = UDim2.new(0, 155, 0, 40)
contentContainer.BackgroundTransparency = 1
contentContainer.Parent = main

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 4
scroll.ScrollBarImageColor3 = Colors.Accent
scroll.Parent = contentContainer

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0, 8)
layout.Parent = scroll
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 10)
end)

local contentPadding = Instance.new("UIPadding")
contentPadding.PaddingTop = UDim.new(0, 5)
contentPadding.PaddingLeft = UDim.new(0, 10)
contentPadding.PaddingRight = UDim.new(0, 10)
contentPadding.Parent = scroll

-- Tabs
local tabs = {
    "Movement",
    "Combat",
    "ESP",
    "Visuals",
    "Miscellaneous"
}

local currentTab = "Movement"
local Toggles = {}
local Keybinds = {}
local waitingForBind = nil

-- Create Tab Buttons
local tabButtons = {}
for _, tabName in ipairs(tabs) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 40)
    btn.Text = tabName
    btn.BackgroundColor3 = Colors.Bar
    btn.TextColor3 = Colors.TextSoft
    btn.Font = Enum.Font.GothamBold
    btn.TextSize = 14
    btn.Parent = tabContainer
    corner(btn, 6)
    border(btn)
    
    btn.MouseButton1Click:Connect(function()
        currentTab = tabName
        rebuildScroll()
        for _, b in pairs(tabButtons) do
            b.BackgroundColor3 = Colors.Bar
            b.TextColor3 = Colors.TextSoft
        end
        btn.BackgroundColor3 = Colors.Accent
        btn.TextColor3 = Colors.Text
    end)
    
    table.insert(tabButtons, btn)
end

-- Rebuild Scroll Content
function rebuildScroll()
    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("GuiObject") and child ~= layout and child ~= contentPadding then
            child:Destroy()
        end
    end
    
    Toggles = {}
    
    if currentTab == "Movement" then
        Components.createSectionLabel(scroll, "Movement")
        
        Toggles.WalkSpeed = Components.createToggle(scroll, "Walk Speed", function(v)
            State.Movement.WalkSpeed = v
        end, State.Movement.WalkSpeed)
        
        Components.createSlider(scroll, "Speed Value", 16, 150, State.Movement.WalkSpeedValue, function(v)
            State.Movement.WalkSpeedValue = v
        end)
        
        Toggles.Fly = Components.createToggle(scroll, "Fly", function(v)
            State.Movement.Fly = v
        end, State.Movement.Fly)
        
        local flyMethod = Components.createSelector(scroll, "Fly Method", {"Velocity", "CFrame", "BodyVelocity"}, State.Movement.FlyMethod, function(m)
            State.Movement.FlyMethod = m
        end)
        
        Components.createSlider(scroll, "Fly Speed", 10, 300, State.Movement.FlySpeed, function(v)
            State.Movement.FlySpeed = v
        end)
        
        Toggles.Noclip = Components.createToggle(scroll, "Noclip", function(v)
            State.Movement.Noclip = v
        end, State.Movement.Noclip)
        
        Toggles.InfiniteJump = Components.createToggle(scroll, "Infinite Jump", function(v)
            State.Movement.InfiniteJump = v
        end, State.Movement.InfiniteJump)
        
        Toggles.AutoJump = Components.createToggle(scroll, "Auto Jump", function(v)
            State.Movement.AutoJump = v
        end, State.Movement.AutoJump)
        
        Toggles.NoSlowdown = Components.createToggle(scroll, "No Slowdown", function(v)
            State.Movement.NoSlowdown = v
        end, State.Movement.NoSlowdown)
        
        Components.createSectionLabel(scroll, "Utilities")
        
        Toggles.AntiAfk = Components.createToggle(scroll, "Anti AFK", function(v)
            State.Movement.AntiAfk = v
        end, State.Movement.AntiAfk)
        
    elseif currentTab == "Combat" then
        Components.createSectionLabel(scroll, "Aim Assist")
        
        Toggles.AimAssist = Components.createToggle(scroll, "Aim Assist", function(v)
            State.Combat.AimAssist = v
        end, State.Combat.AimAssist)
        
        Components.createSlider(scroll, "Smoothness", 1, 50, math.floor(State.Combat.AimSmoothness * 100), function(v)
            State.Combat.AimSmoothness = v / 100
        end)
        
        Components.createSlider(scroll, "FOV", 50, 500, State.Combat.AimFOV, function(v)
            State.Combat.AimFOV = v
        end)
        
        Components.createSectionLabel(scroll, "Hitbox Expander")
        
        Toggles.HitboxExpander = Components.createToggle(scroll, "Enable Hitbox Expander", function(v)
            State.Combat.HitboxExpander = v
        end, State.Combat.HitboxExpander)
        
        Components.createSlider(scroll, "Hitbox Multiplier", 1, 50, math.floor(State.Combat.HitboxMultiplier * 10), function(v)
            State.Combat.HitboxMultiplier = v / 10
        end)
        
        Components.createSectionLabel(scroll, "Silent Aim")
        
        Toggles.SilentAim = Components.createToggle(scroll, "Silent Aim", function(v)
            State.Combat.SilentAim = v
        end, State.Combat.SilentAim)
        
        Components.createSlider(scroll, "Silent FOV", 50, 500, State.Combat.SilentFOV, function(v)
            State.Combat.SilentFOV = v
        end)
        
        Components.createSlider(scroll, "Hit Chance %", 0, 100, State.Combat.SilentHitChance, function(v)
            State.Combat.SilentHitChance = v
        end)
        
        Components.createSectionLabel(scroll, "Automation")
        
        Toggles.TriggerBot = Components.createToggle(scroll, "Trigger Bot", function(v)
            State.Combat.TriggerBot = v
        end, State.Combat.TriggerBot)
        
        Components.createSlider(scroll, "Trigger Delay (ms)", 0, 500, State.Combat.TriggerDelay, function(v)
            State.Combat.TriggerDelay = v
        end)
        
        Toggles.AutoClicker = Components.createToggle(scroll, "Auto Clicker", function(v)
            State.Combat.AutoClicker = v
        end, State.Combat.AutoClicker)
        
        Components.createSlider(scroll, "Clicks Per Second", 1, 50, State.Combat.CPS, function(v)
            State.Combat.CPS = v
        end)
        
        Toggles.WallBang = Components.createToggle(scroll, "Wall Bang", function(v)
            State.Combat.WallBang = v
        end, State.Combat.WallBang)
        
        -- NEW: Weapon Modifications Section
        Components.createSectionLabel(scroll, "Weapon Modifications")
        
        Toggles.FasterFireRate = Components.createToggle(scroll, "Faster Fire Rate", function(v)
            State.Combat.FasterFireRate = v
        end, State.Combat.FasterFireRate)
        
        Components.createSlider(scroll, "Fire Rate Multiplier", 1, 10, math.floor(State.Combat.FireRateMultiplier), function(v)
            State.Combat.FireRateMultiplier = v
        end)
        
        Toggles.NoSpread = Components.createToggle(scroll, "No Spread", function(v)
            State.Combat.NoSpread = v
        end, State.Combat.NoSpread)
        
        Toggles.NoRecoil = Components.createToggle(scroll, "No Recoil", function(v)
            State.Combat.NoRecoil = v
        end, State.Combat.NoRecoil)
        
        Toggles.AutoAutomatic = Components.createToggle(scroll, "Auto Automatic", function(v)
            State.Combat.AutoAutomatic = v
        end, State.Combat.AutoAutomatic)
        
        Toggles.InstantReload = Components.createToggle(scroll, "Instant Reload", function(v)
            State.Combat.InstantReload = v
        end, State.Combat.InstantReload)
        
        Toggles.InfiniteAmmo = Components.createToggle(scroll, "Infinite Ammo", function(v)
            State.Combat.InfiniteAmmo = v
        end, State.Combat.InfiniteAmmo)
        
        -- KILL ALL FUNCTION
        Components.createSectionLabel(scroll, "KILL ALL Function")
        
        Toggles.KillAll = Components.createToggle(scroll, "KILL ALL", function(v)
            State.Combat.KillAll = v
            if v then
                -- Automatically enable aim assist and triggerbot when Kill All is enabled
                if Toggles.AimAssist then Toggles.AimAssist.Set(true) end
                if Toggles.TriggerBot then Toggles.TriggerBot.Set(true) end
                State.Combat.KillAllTarget = nil
                State.Combat.KillAllCooldown = tick()
            end
        end, State.Combat.KillAll)
        
    elseif currentTab == "ESP" then
        Components.createSectionLabel(scroll, "ESP Settings")
        
        Toggles.Enabled = Components.createToggle(scroll, "ESP Enabled", function(v)
            State.ESP.Enabled = v
        end, State.ESP.Enabled)
        
        Components.createSectionLabel(scroll, "Player ESP")
        
        Toggles.Box = Components.createToggle(scroll, "Box ESP", function(v)
            State.ESP.Box = v
        end, State.ESP.Box)
        
        Toggles.Name = Components.createToggle(scroll, "Name Tags", function(v)
            State.ESP.Name = v
        end, State.ESP.Name)
        
        Toggles.Health = Components.createToggle(scroll, "Health Bar", function(v)
            State.ESP.Health = v
        end, State.ESP.Health)
        
        Toggles.HealthBar = Components.createToggle(scroll, "Detailed Health", function(v)
            State.ESP.HealthBar = v
        end, State.ESP.HealthBar)
        
        Toggles.Distance = Components.createToggle(scroll, "Distance", function(v)
            State.ESP.Distance = v
        end, State.ESP.Distance)
        
        Toggles.Weapon = Components.createToggle(scroll, "Weapon ESP", function(v)
            State.ESP.Weapon = v
        end, State.ESP.Weapon)
        
        Components.createSectionLabel(scroll, "Visual Features")
        
        Toggles.Tracers = Components.createToggle(scroll, "Tracers", function(v)
            State.ESP.Tracers = v
        end, State.ESP.Tracers)
        
        Toggles.Chams = Components.createToggle(scroll, "Chams", function(v)
            State.ESP.Chams = v
        end, State.ESP.Chams)
        
        Toggles.HeadDot = Components.createToggle(scroll, "Head Dot", function(v)
            State.ESP.HeadDot = v
        end, State.ESP.HeadDot)
        
        Toggles.Outlines = Components.createToggle(scroll, "Outlines", function(v)
            State.ESP.Outlines = v
        end, State.ESP.Outlines)
        
        Components.createSectionLabel(scroll, "Settings")
        
        Components.createSlider(scroll, "Max Distance", 100, 5000, State.ESP.MaxDistance, function(v)
            State.ESP.MaxDistance = v
        end)
        
        Toggles.TeamCheck = Components.createToggle(scroll, "Team Check", function(v)
            State.ESP.TeamCheck = v
        end, State.ESP.TeamCheck)
        
    elseif currentTab == "Visuals" then
        Components.createSectionLabel(scroll, "World Visuals")
        
        Toggles.ChangeTime = Components.createToggle(scroll, "Change Time", function(v)
            State.Visuals.ChangeTime = v
        end, State.Visuals.ChangeTime)
        
        Components.createSlider(scroll, "Time of Day", 0, 24, State.Visuals.TimeOfDay, function(v)
            State.Visuals.TimeOfDay = v
        end)
        
        Toggles.ChangeAmbient = Components.createToggle(scroll, "Change Ambient", function(v)
            State.Visuals.ChangeAmbient = v
        end, State.Visuals.ChangeAmbient)
        
        Components.createSlider(scroll, "Ambient R", 0, 255, math.floor(State.Visuals.AmbientR * 255), function(v)
            State.Visuals.AmbientR = v / 255
        end)
        
        Components.createSlider(scroll, "Ambient G", 0, 255, math.floor(State.Visuals.AmbientG * 255), function(v)
            State.Visuals.AmbientG = v / 255
        end)
        
        Components.createSlider(scroll, "Ambient B", 0, 255, math.floor(State.Visuals.AmbientB * 255), function(v)
            State.Visuals.AmbientB = v / 255
        end)
        
        Components.createSectionLabel(scroll, "Camera")
        
        Toggles.ChangeFOV = Components.createToggle(scroll, "Change FOV", function(v)
            State.Visuals.ChangeFOV = v
        end, State.Visuals.ChangeFOV)
        
        Components.createSlider(scroll, "FOV Value", 10, 120, State.Visuals.FOV, function(v)
            State.Visuals.FOV = v
        end)
        
        Components.createSectionLabel(scroll, "Effects")
        
        Toggles.FullBright = Components.createToggle(scroll, "Full Bright", function(v)
            State.Visuals.FullBright = v
        end, State.Visuals.FullBright)
        
        Toggles.NoFog = Components.createToggle(scroll, "No Fog", function(v)
            State.Visuals.NoFog = v
        end, State.Visuals.NoFog)
        
        Toggles.NoBloom = Components.createToggle(scroll, "No Bloom", function(v)
            State.Visuals.NoBloom = v
        end, State.Visuals.NoBloom)
        
        Toggles.NoShadows = Components.createToggle(scroll, "No Shadows", function(v)
            State.Visuals.NoShadows = v
        end, State.Visuals.NoShadows)
        
    elseif currentTab == "Miscellaneous" then
        Components.createSectionLabel(scroll, "Game Modifications")
        
        Toggles.SpeedHack = Components.createToggle(scroll, "Speed Hack", function(v)
            State.Misc.SpeedHack = v
        end, State.Misc.SpeedHack)
        
        Components.createSlider(scroll, "Speed Multiplier", 1, 100, math.floor(State.Misc.SpeedMultiplier * 10), function(v)
            State.Misc.SpeedMultiplier = v / 10
        end)
        
        Toggles.AntiVoid = Components.createToggle(scroll, "Anti Void", function(v)
            State.Misc.AntiVoid = v
        end, State.Misc.AntiVoid)
        
        Components.createSectionLabel(scroll, "Automation")
        
        Toggles.AutoFarm = Components.createToggle(scroll, "Auto Farm", function(v)
            State.Misc.AutoFarm = v
        end, State.Misc.AutoFarm)
        
        Toggles.AutoCollect = Components.createToggle(scroll, "Auto Collect", function(v)
            State.Misc.AutoCollect = v
        end, State.Misc.AutoCollect)
        
        Components.createSectionLabel(scroll, "Performance")
        
        Toggles.FPSBoost = Components.createToggle(scroll, "FPS Boost", function(v)
            State.Misc.FPSBoost = v
        end, State.Misc.FPSBoost)
        
        Toggles.ChatLogger = Components.createToggle(scroll, "Chat Logger", function(v)
            State.Misc.ChatLogger = v
        end, State.Misc.ChatLogger)
    end
    
    -- Setup keybinds
    for feature, toggle in pairs(Toggles) do
        local btn = toggle.GetKeybindButton and toggle.GetKeybindButton()
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

-- Close Button
closeBtn.MouseButton1Click:Connect(function()
    gui.Enabled = not gui.Enabled
end)

-- Initialize
rebuildScroll()
tabButtons[1].BackgroundColor3 = Colors.Accent
tabButtons[1].TextColor3 = Colors.Text

-- Toggle Menu (RightShift Key)
local menuVisible = true
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    
    if waitingForBind then
        waitingForBind(input.KeyCode)
        return
    end
    
    if input.KeyCode == Enum.KeyCode.RightShift then
        menuVisible = not menuVisible
        main.Visible = menuVisible
    end
    
    for feature, key in pairs(Keybinds) do
        if input.KeyCode == key and Toggles[feature] then
            Toggles[feature].Toggle()
        end
    end
end)

-- Feature Implementations
local flyBodyVelocity, flyBodyGyro, walkBodyVelocity
local lastJumpTime = 0
local lastClickTime = 0

-- Store original CanCollide states for noclip
local originalCanCollideStates = {}
local partsToNoclip = {}

-- FIXED: Smart noclip that only affects buildings, not floor
local function updateNoclip()
    local char = player.Character
    if not char then return end
    
    -- Reset previous parts if noclip is off
    if not State.Movement.Noclip then
        for part, originalState in pairs(originalCanCollideStates) do
            if part and part.Parent then
                part.CanCollide = originalState
            end
        end
        originalCanCollideStates = {}
        partsToNoclip = {}
        return
    end
    
    -- Only noclip through buildings, not floor
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local playerY = root.Position.Y
    local maxDistance = 50
    
    local nearbyParts = {}
    
    for _, part in pairs(Workspace:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            local distance = (part.Position - root.Position).Magnitude
            
            if distance < maxDistance and not part:IsDescendantOf(char) then
                local isFloor = false
                local upVector = part.CFrame.UpVector
                local isHorizontal = math.abs(upVector.Y) > 0.7
                local isNearGround = part.Position.Y < playerY + 5 and part.Position.Y > playerY - 10
                local isLarge = part.Size.X * part.Size.Z > 100
                
                if isHorizontal and isNearGround and isLarge then
                    isFloor = true
                end
                
                local floorNames = {
                    "Floor", "floor", "Ground", "ground", "Baseplate", "baseplate",
                    "Terrain", "terrain", "Grass", "grass", "Road", "road"
                }
                
                for _, name in pairs(floorNames) do
                    if string.find(part.Name, name) or string.find(part.Parent.Name, name) then
                        isFloor = true
                        break
                    end
                end
                
                if not isFloor then
                    table.insert(nearbyParts, part)
                end
            end
        end
    end
    
    for _, part in pairs(nearbyParts) do
        if not originalCanCollideStates[part] then
            originalCanCollideStates[part] = part.CanCollide
            part.CanCollide = false
        end
    end
    
    for part, _ in pairs(originalCanCollideStates) do
        local found = false
        for _, nearbyPart in pairs(nearbyParts) do
            if nearbyPart == part then
                found = true
                break
            end
        end
        
        if not found and part and part.Parent then
            part.CanCollide = originalCanCollideStates[part]
            originalCanCollideStates[part] = nil
        end
    end
end

-- Weapon Modification Hooks
local originalRemotes = {}
local weaponHooks = {}

-- Hook weapon firing remotes
local function setupWeaponHooks()
    -- Find all remote events/functions related to weapons
    local remotesToHook = {}
    
    -- Check ReplicatedStorage
    local function scanFolder(folder)
        for _, item in pairs(folder:GetDescendants()) do
            if item:IsA("RemoteEvent") or item:IsA("RemoteFunction") then
                local name = item.Name:lower()
                if name:find("fire") or name:find("shoot") or name:find("weapon") or 
                   name:find("damage") or name:find("hit") or name:find("ammo") or
                   name:find("reload") or name:find("spread") or name:find("recoil") then
                    table.insert(remotesToHook, item)
                end
            end
        end
    end
    
    scanFolder(ReplicatedStorage)
    
    for _, remote in pairs(remotesToHook) do
        if not originalRemotes[remote] then
            if remote:IsA("RemoteEvent") then
                originalRemotes[remote] = remote.FireServer
                remote.FireServer = function(self, ...)
                    local args = {...}
                    
                    -- Apply weapon modifications
                    if State.Combat.FasterFireRate then
                        -- Look for fire rate/delay arguments
                        for i, arg in ipairs(args) do
                            if type(arg) == "number" and arg > 0 and arg < 1 then
                                -- This might be a fire delay
                                args[i] = arg / State.Combat.FireRateMultiplier
                            end
                        end
                    end
                    
                    if State.Combat.NoSpread then
                        -- Look for spread arguments
                        for i, arg in ipairs(args) do
                            if type(arg) == "number" and (arg == 0.1 or arg == 0.05 or arg == 0.2) then
                                -- This might be spread value
                                args[i] = 0
                            elseif type(arg) == "table" then
                                if arg.Spread then arg.Spread = 0 end
                                if arg.spread then arg.spread = 0 end
                            end
                        end
                    end
                    
                    if State.Combat.NoRecoil then
                        -- Look for recoil arguments
                        for i, arg in ipairs(args) do
                            if type(arg) == "table" then
                                if arg.Recoil then arg.Recoil = 0 end
                                if arg.recoil then arg.recoil = 0 end
                                if arg.Kick then arg.Kick = 0 end
                                if arg.kick then arg.kick = 0 end
                            end
                        end
                    end
                    
                    if State.Combat.InstantReload then
                        -- Look for reload arguments
                        for i, arg in ipairs(args) do
                            if type(arg) == "table" then
                                if arg.ReloadTime then arg.ReloadTime = 0 end
                                if arg.reloadTime then arg.reloadTime = 0 end
                                if arg.Reload then arg.Reload = 0 end
                                if arg.reload then arg.reload = 0 end
                            end
                        end
                    end
                    
                    if State.Combat.InfiniteAmmo then
                        -- Look for ammo arguments
                        for i, arg in ipairs(args) do
                            if type(arg) == "table" then
                                if arg.Ammo then arg.Ammo = 999 end
                                if arg.ammo then arg.ammo = 999 end
                                if arg.Clip then arg.Clip = 999 end
                                if arg.clip then arg.clip = 999 end
                            end
                        end
                    end
                    
                    return originalRemotes[remote](self, unpack(args))
                end
            elseif remote:IsA("RemoteFunction") then
                originalRemotes[remote] = remote.InvokeServer
                remote.InvokeServer = function(self, ...)
                    local args = {...}
                    
                    -- Apply modifications similar to above
                    if State.Combat.FasterFireRate then
                        for i, arg in ipairs(args) do
                            if type(arg) == "number" and arg > 0 and arg < 1 then
                                args[i] = arg / State.Combat.FireRateMultiplier
                            end
                        end
                    end
                    
                    return originalRemotes[remote](self, unpack(args))
                end
            end
        end
    end
end

-- Auto Automatic Weapons (makes semi-auto weapons automatic)
local autoFireConnection
local function setupAutoAutomatic()
    if autoFireConnection then
        autoFireConnection:Disconnect()
        autoFireConnection = nil
    end
    
    if State.Combat.AutoAutomatic then
        local lastAutoFire = 0
        autoFireConnection = RunService.RenderStepped:Connect(function()
            if UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
                local currentTime = tick()
                if currentTime - lastAutoFire > (1 / State.Combat.FireRateMultiplier) then
                    -- Simulate mouse click for automatic fire
                    mouse1press()
                    task.wait(0.01)
                    mouse1release()
                    lastAutoFire = currentTime
                end
            end
        end)
    end
end

-- NEW: KILL ALL FUNCTION IMPLEMENTATION
local function getClosestEnemy()
    local myTeam = player.Team
    local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
    if not myRoot then return nil end
    
    local closest = nil
    local closestDist = math.huge
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        if State.ESP.TeamCheck and plr.Team == myTeam then continue end
        
        local char = plr.Character
        if not char then continue end
        
        local hum = char:FindFirstChildOfClass("Humanoid")
        local root = char:FindFirstChild("HumanoidRootPart")
        
        if hum and hum.Health > 0 and root then
            local dist = (myRoot.Position - root.Position).Magnitude
            if dist < closestDist and dist <= State.ESP.MaxDistance then
                closestDist = dist
                closest = plr
            end
        end
    end
    
    return closest
end

local function teleportBehindTarget(targetPlayer)
    if not targetPlayer or not targetPlayer.Character then return false end
    
    local char = player.Character
    if not char then return false end
    
    local myRoot = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
    
    if not myRoot or not targetRoot then return false end
    
    -- Calculate position 3 studs behind the target
    local targetCFrame = targetRoot.CFrame
    local behindOffset = targetCFrame.LookVector * -3
    
    -- Teleport behind the target
    myRoot.CFrame = CFrame.new(targetCFrame.Position + behindOffset, targetCFrame.Position)
    
    return true
end

RunService.RenderStepped:Connect(function(delta)
    local char = player.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if hum and root then
        -- Walk Speed
        if State.Movement.WalkSpeed then
            local speed = State.Movement.WalkSpeedValue
            local moveDir = hum.MoveDirection * speed
            
            if State.Movement.WalkMethod == "Humanoid" then
                hum.WalkSpeed = speed
                if walkBodyVelocity then walkBodyVelocity:Destroy() walkBodyVelocity = nil end
            elseif State.Movement.WalkMethod == "Velocity" then
                hum.WalkSpeed = 0
                if not walkBodyVelocity then
                    walkBodyVelocity = Instance.new("BodyVelocity")
                    walkBodyVelocity.MaxForce = Vector3.new(1e5, 0, 1e5)
                    walkBodyVelocity.Parent = root
                end
                walkBodyVelocity.Velocity = moveDir
            end
        else
            hum.WalkSpeed = 16
            if walkBodyVelocity then walkBodyVelocity:Destroy() walkBodyVelocity = nil end
        end
        
        -- Auto Jump
        if State.Movement.AutoJump and hum:GetState() == Enum.HumanoidStateType.Running and tick() - lastJumpTime > 0.5 then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
            lastJumpTime = tick()
        end
        
        -- Fly
        if State.Movement.Fly then
            hum:ChangeState(Enum.HumanoidStateType.Physics)
            hum.PlatformStand = true
            
            local speed = State.Movement.FlySpeed
            local vel = Vector3.new()
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                vel = camera.CFrame:VectorToWorldSpace(dir)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - Vector3.new(0,1,0) end
            if vel.Magnitude > 0 then vel = vel.Unit * speed end
            
            if State.Movement.FlyMethod == "Velocity" then
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
            elseif State.Movement.FlyMethod == "CFrame" then
                if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
                if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
                root.CFrame = CFrame.lookAt(root.Position, root.Position + camera.CFrame.LookVector) + vel * delta
            elseif State.Movement.FlyMethod == "BodyVelocity" then
                if not flyBodyVelocity then
                    flyBodyVelocity = Instance.new("BodyVelocity")
                    flyBodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
                    flyBodyVelocity.Velocity = vel
                    flyBodyVelocity.Parent = root
                end
                flyBodyVelocity.Velocity = vel
            end
        else
            hum.PlatformStand = false
            if flyBodyVelocity then flyBodyVelocity:Destroy() flyBodyVelocity = nil end
            if flyBodyGyro then flyBodyGyro:Destroy() flyBodyGyro = nil end
        end
        
        -- FIXED: Smart Noclip (only through buildings, not floor)
        updateNoclip()
        
        -- No Slowdown
        if State.Movement.NoSlowdown then
            for _, force in ipairs(char:GetDescendants()) do
                if force:IsA("BodyForce") or force:IsA("BodyVelocity") then
                    force:Destroy()
                end
            end
        end
    end
    
    -- Weapon Modifications Update
    if State.Combat.AutoAutomatic then
        setupAutoAutomatic()
    elseif autoFireConnection then
        autoFireConnection:Disconnect()
        autoFireConnection = nil
    end
    
    -- Setup weapon hooks if not already set up
    if not weaponHooks.SetupDone then
        weaponHooks.SetupDone = true
        setupWeaponHooks()
    end
    
    -- KILL ALL FUNCTION
    if State.Combat.KillAll then
        if tick() - State.Combat.KillAllCooldown > 0.5 then
            State.Combat.KillAllCooldown = tick()
            
            if not State.Combat.KillAllTarget or not State.Combat.KillAllTarget.Character then
                State.Combat.KillAllTarget = getClosestEnemy()
            end
            
            if State.Combat.KillAllTarget and State.Combat.KillAllTarget.Character then
                local targetHum = State.Combat.KillAllTarget.Character:FindFirstChildOfClass("Humanoid")
                if not targetHum or targetHum.Health <= 0 then
                    State.Combat.KillAllTarget = getClosestEnemy()
                end
            end
            
            if State.Combat.KillAllTarget then
                teleportBehindTarget(State.Combat.KillAllTarget)
                
                if not State.Combat.AimAssist and Toggles.AimAssist then
                    Toggles.AimAssist.Set(true)
                end
                
                if not State.Combat.TriggerBot and Toggles.TriggerBot then
                    Toggles.TriggerBot.Set(true)
                end
            end
        end
    else
        State.Combat.KillAllTarget = nil
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
    if State.Visuals.FullBright then
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    end
    if State.Visuals.NoFog then
        if Lighting:FindFirstChild("FogEnd") then
            Lighting.FogEnd = 100000
        end
    end
    if State.Visuals.NoShadows then
        Lighting.GlobalShadows = false
    end
    
    -- Auto Clicker
    if State.Combat.AutoClicker and tick() - lastClickTime > (1 / State.Combat.CPS) then
        mouse1press()
        task.wait(0.01)
        mouse1release()
        lastClickTime = tick()
    end
    
    -- Speed Hack
    if State.Misc.SpeedHack then
        game:GetService("ScriptContext").ScriptsDisabled = false
        RunService:SetRobloxGuiFocused(false)
    end
end)

-- Clean up noclip states when character changes
player.CharacterAdded:Connect(function()
    originalCanCollideStates = {}
    partsToNoclip = {}
    weaponHooks.SetupDone = false
    setupWeaponHooks()
end)

-- Infinite Jump
UserInputService.JumpRequest:Connect(function()
    if State.Movement.InfiniteJump then
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

-- Anti AFK
if State.Movement.AntiAfk then
    for _, v in next, getconnections(player.Idled) do
        v:Disable()
    end
end

-- ESP Implementation
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
        
        -- Apply hitbox expansion
        local size = Vector3.new(4, 6, 2)
        if State.Combat.HitboxExpander then
            size = size * State.Combat.HitboxMultiplier
        end
        
        local corners = {}
        for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
            local pos = root.CFrame * Vector3.new(x*size.X/2, y*size.Y/2, z*size.Z/2)
            local screen, onScreen = camera:WorldToViewportPoint(pos)
            if onScreen then
                table.insert(corners, Vector2.new(screen.X, screen.Y))
            end
        end end end
        
        if #corners < 8 then continue end
        
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
        
        local key = tostring(plr)
        if not espCache[key] then
            espCache[key] = {
                box = Drawing.new("Quad"),
                name = Drawing.new("Text"),
                health = Drawing.new("Line"),
                healthBar = Drawing.new("Quad"),
                distance = Drawing.new("Text"),
                tracer = Drawing.new("Line"),
                headDot = Drawing.new("Circle"),
                weapon = Drawing.new("Text"),
                chams = Instance.new("Highlight")
            }
            espCache[key].box.Thickness = 1
            espCache[key].name.Size = 13
            espCache[key].name.Center = true
            espCache[key].name.Outline = true
            espCache[key].health.Thickness = 2
            espCache[key].healthBar.Thickness = 1
            espCache[key].distance.Size = 11
            espCache[key].distance.Center = true
            espCache[key].distance.Outline = true
            espCache[key].tracer.Thickness = 1
            espCache[key].headDot.Radius = 3
            espCache[key].headDot.NumSides = 12
            espCache[key].headDot.Filled = true
            espCache[key].weapon.Size = 11
            espCache[key].weapon.Center = true
            espCache[key].weapon.Outline = true
            espCache[key].chams.FillTransparency = 0.5
            espCache[key].chams.OutlineTransparency = 0.5
        end
        
        local drawings = espCache[key]
        local screenHead, onScreenHead = camera:WorldToViewportPoint(head.Position)
        local screenRoot, onScreenRoot = camera:WorldToViewportPoint(root.Position)
        if not onScreenHead or not onScreenRoot then continue end
        
        local color = plr.Team == myTeam and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 50, 50)
        
        if State.ESP.Box then
            drawings.box.PointA = Vector2.new(minX, minY)
            drawings.box.PointB = Vector2.new(maxX, minY)
            drawings.box.PointC = Vector2.new(maxX, maxY)
            drawings.box.PointD = Vector2.new(minX, maxY)
            drawings.box.Color = color
            drawings.box.Visible = true
        end
        
        if State.ESP.Name then
            drawings.name.Text = plr.Name
            drawings.name.Position = Vector2.new((minX + maxX)/2, minY - 14)
            drawings.name.Color = color
            drawings.name.Visible = true
        end
        
        if State.ESP.Health then
            local healthPercent = hum.Health / hum.MaxHealth
            local healthY = maxY - height * healthPercent
            local healthColor = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0)
            
            drawings.health.From = Vector2.new(minX - 4, maxY)
            drawings.health.To = Vector2.new(minX - 4, healthY)
            drawings.health.Color = healthColor
            drawings.health.Visible = true
            
            if State.ESP.HealthBar then
                drawings.healthBar.PointA = Vector2.new(minX - 6, maxY)
                drawings.healthBar.PointB = Vector2.new(minX - 6, healthY)
                drawings.healthBar.PointC = Vector2.new(minX - 2, healthY)
                drawings.healthBar.PointD = Vector2.new(minX - 2, maxY)
                drawings.healthBar.Color = healthColor
                drawings.healthBar.Visible = true
            end
        end
        
        if State.ESP.Distance then
            drawings.distance.Text = math.floor(dist) .. " studs"
            drawings.distance.Position = Vector2.new((minX + maxX)/2, maxY + 2)
            drawings.distance.Color = color
            drawings.distance.Visible = true
        end
        
        if State.ESP.Tracers then
            drawings.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
            drawings.tracer.To = Vector2.new(screenRoot.X, screenRoot.Y)
            drawings.tracer.Color = color
            drawings.tracer.Visible = true
        end
        
        if State.ESP.HeadDot then
            drawings.headDot.Position = Vector2.new(screenHead.X, screenHead.Y)
            drawings.headDot.Color = Color3.fromRGB(255, 0, 0)
            drawings.headDot.Visible = true
        end
        
        if State.ESP.Weapon then
            local weapon = plr.Character:FindFirstChildOfClass("Tool")
            drawings.weapon.Text = weapon and weapon.Name or "Unarmed"
            drawings.weapon.Position = Vector2.new((minX + maxX)/2, maxY + 14)
            drawings.weapon.Color = color
            drawings.weapon.Visible = true
        end
        
        if State.ESP.Chams then
            drawings.chams.Adornee = plr.Character
            drawings.chams.FillColor = color
            drawings.chams.OutlineColor = color
            drawings.chams.Enabled = true
            drawings.chams.Parent = plr.Character
        end
        
        if State.ESP.Outlines then
            for _, part in ipairs(plr.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.Material = Enum.Material.ForceField
                end
            end
        end
    end
end)

-- Cleanup ESP when player leaves
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

-- Aim Assist
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
        
        closest = {Part = targetPart, Root = root, Player = plr}
        closestDist = dist
    end
    
    return closest
end

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

-- Trigger Bot
local function findTargetUnderCrosshair()
    local ray = camera:ViewportPointToRay(mouse.X, mouse.Y)
    local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000)
    
    if result and result.Instance then
        local model = result.Instance:FindFirstAncestorOfClass("Model")
        if model then
            local plr = Players:GetPlayerFromCharacter(model)
            if plr and plr ~= player then
                return true
            end
        end
    end
    return false
end

RunService.RenderStepped:Connect(function()
    if State.Combat.TriggerBot and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        if findTargetUnderCrosshair() then
            task.wait(State.Combat.TriggerDelay / 1000)
            mouse1press()
            task.wait(0.05)
            mouse1release()
        end
    end
end)

-- Silent Aim (Hitbox Expansion Integrated)
local Silent = {}
Silent.Target = nil

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Blacklist
rayParams.IgnoreWater = true

local function updateFilter()
    local char = player.Character
    if not char then return end
    
    local ignore = {char, camera}
    for _, obj in ipairs(char:GetDescendants()) do
        if obj:IsA("Accessory") or obj:IsA("Tool") then
            table.insert(ignore, obj)
        end
    end
    rayParams.FilterDescendantsInstances = ignore
end

player.CharacterAdded:Connect(updateFilter)
if player.Character then updateFilter() end

function Silent:getClosest(fov)
    local closest = nil
    local shortestDist = math.huge
    local origin = camera.CFrame.Position
    
    for _, plr in ipairs(Players:GetPlayers()) do
        if plr == player then continue end
        
        local char = plr.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        local root = char and char:FindFirstChild("HumanoidRootPart")
        
        if not hum or not root or hum.Health <= 0 then continue end
        
        if State.ESP.TeamCheck and plr.Team == player.Team then continue end
        
        local targetPart = char:FindFirstChild("Head") or root
        local distance = (targetPart.Position - origin).Magnitude
        
        if distance < shortestDist then
            closest = {
                Player = plr,
                Character = char,
                Part = targetPart,
                Root = root
            }
            shortestDist = distance
        end
    end
    
    return closest
end

-- Hook for silent aim
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if State.Combat.SilentAim and method == "FindPartOnRayWithIgnoreList" and Silent.Target then
        if math.random(1,100) <= State.Combat.SilentHitChance then
            local targetPos = Silent.Target.Part.Position
            if State.Combat.HitboxExpander then
                targetPos = targetPos + Vector3.new(
                    (math.random() * 2 - 1) * State.Combat.HitboxMultiplier,
                    (math.random() * 2 - 1) * State.Combat.HitboxMultiplier,
                    (math.random() * 2 - 1) * State.Combat.HitboxMultiplier
                )
            end
            args[1] = Ray.new(camera.CFrame.Position, (targetPos - camera.CFrame.Position).Unit * 1000)
        end
    end
    
    return oldNamecall(self, unpack(args))
end)

-- Update silent aim target
RunService.RenderStepped:Connect(function()
    if State.Combat.SilentAim then
        Silent.Target = Silent:getClosest(State.Combat.SilentFOV)
    else
        Silent.Target = nil
    end
end)

-- FPS Boost
if State.Misc.FPSBoost then
    settings().Rendering.QualityLevel = 1
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("Part") then
            v.Material = Enum.Material.Plastic
        end
    end
end

-- Initialize weapon hooks
task.spawn(function()
    task.wait(2) -- Wait for game to load
    setupWeaponHooks()
end)

print("Horizontal Hub Loaded Successfully!")
print("Press RightShift to toggle menu")
print("Weapon Modifications added: Faster Fire Rate, No Spread, No Recoil, Auto Automatic")
print("KILL ALL function added to Combat tab")
