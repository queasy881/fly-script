-- Vertical Hub - Fresh Implementation
-- Fully vertical menu, optimized UX, only specified features

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

-- State Management
local State = {
    Movement = {
        WalkSpeed = false,
        WalkSpeedValue = 16,
        SlideBoost = false,
        Fly = false,
        FlySpeed = 50,
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
        TeamCheck = false
    }
}

-- GUI Creation
local gui = Instance.new("ScreenGui")
gui.Name = "VerticalHub"
gui.Parent = player:WaitForChild("PlayerGui")
gui.Enabled = false

local main = Instance.new("Frame")
main.Size = UDim2.new(0, 300, 0, 600)
main.Position = UDim2.new(0.5, -150, 0.5, -300)
main.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
main.Parent = gui
Instance.new("UICorner", main).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", main).Color = Color3.fromRGB(50, 50, 70)

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.Text = "Vertical Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
title.Font = Enum.Font.GothamBold
title.TextSize = 18
title.Parent = main
Instance.new("UICorner", title).CornerRadius = UDim.new(0, 8)

local scroll = Instance.new("ScrollingFrame")
scroll.Size = UDim2.new(1, 0, 1, -40)
scroll.Position = UDim2.new(0, 0, 0, 40)
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

-- UI Component Functions
local function createSectionLabel(text)
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0, 30)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(150, 150, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 14
    label.Parent = scroll
    return label
end

local function createToggle(text, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 30)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, 0, 1, 0)
    button.Position = UDim2.new(0.7, 0, 0, 0)
    button.Text = "Off"
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.Parent = frame
    Instance.new("UICorner", button).CornerRadius = UDim.new(0, 4)
    Instance.new("UIStroke", button).Color = Color3.fromRGB(60, 60, 80)

    local state = false
    button.MouseButton1Click:Connect(function()
        state = not state
        button.Text = state and "On" or "Off"
        button.BackgroundColor3 = state and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(40, 40, 50)
        callback(state)
    end)

    return {
        Set = function(value)
            state = value
            button.Text = state and "On" or "Off"
            button.BackgroundColor3 = state and Color3.fromRGB(100, 120, 255) or Color3.fromRGB(40, 40, 50)
        end
    }
end

local function createSlider(text, min, max, default, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundTransparency = 1
    frame.Parent = scroll

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 0.5, 0)
    label.Text = text
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 13
    label.Parent = frame

    local barFrame = Instance.new("Frame")
    barFrame.Size = UDim2.new(1, 0, 0.5, 0)
    barFrame.Position = UDim2.new(0, 0, 0.5, 0)
    barFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    barFrame.Parent = frame
    Instance.new("UICorner", barFrame).CornerRadius = UDim.new(0, 4)

    local fill = Instance.new("Frame")
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.BackgroundColor3 = Color3.fromRGB(100, 120, 255)
    fill.Parent = barFrame
    Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0.2, 0, 1, 0)
    valueLabel.Position = UDim2.new(0.8, 0, 0, 0)
    valueLabel.Text = tostring(default)
    valueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
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
            fill.Size = UDim2.new(rel, 0, 1, 0)
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
            fill.Size = UDim2.new(rel, 0, 1, 0)
            valueLabel.Text = tostring(v)
        end
    }
end

-- Build Menu
createSectionLabel("Movement")
createToggle("WalkSpeed", function(v) State.Movement.WalkSpeed = v end)
createSlider("WalkSpeed Value", 16, 100, 16, function(v) State.Movement.WalkSpeedValue = v end)
createToggle("Slide Boost", function(v) State.Movement.SlideBoost = v end)
createToggle("Fly", function(v) State.Movement.Fly = v end)
createSlider("Fly Speed", 10, 300, 50, function(v) State.Movement.FlySpeed = v end)
createToggle("Noclip", function(v) State.Movement.Noclip = v end)
createToggle("Infinite Jump", function(v) State.Movement.InfiniteJump = v end)

createSectionLabel("Combat")
createToggle("Aim Assist", function(v) State.Combat.AimAssist = v end)
createSlider("Aim Smoothness", 1, 50, 15, function(v) State.Combat.AimSmoothness = v / 100 end)
createSlider("Aim FOV", 50, 500, 150, function(v) State.Combat.AimFOV = v end)
createToggle("Aim Prediction", function(v) State.Combat.AimPrediction = v end)
createSlider("Prediction Amount", 1, 50, 10, function(v) State.Combat.PredictionAmount = v / 100 end)
createToggle("Silent Aim", function(v) State.Combat.SilentAim = v end)
createSlider("Silent FOV", 50, 500, 150, function(v) State.Combat.SilentFOV = v end)
createSlider("Silent Hit Chance", 0, 100, 100, function(v) State.Combat.SilentHitChance = v end)
createToggle("Silent Prediction", function(v) State.Combat.SilentPrediction = v end)
createSlider("Silent Prediction Amount", 1, 50, 10, function(v) State.Combat.SilentPredictionAmount = v / 100 end)

createSectionLabel("ESP")
createToggle("Enabled", function(v) State.ESP.Enabled = v end)
createToggle("Box", function(v) State.ESP.Box = v end)
createToggle("Name", function(v) State.ESP.Name = v end)
createToggle("Health", function(v) State.ESP.Health = v end)
createToggle("Distance", function(v) State.ESP.Distance = v end)
createSlider("Max Distance", 100, 5000, 1000, function(v) State.ESP.MaxDistance = v end)
createToggle("Team Check", function(v) State.ESP.TeamCheck = v end)

-- Toggle Menu (Insert Key)
UserInputService.InputBegan:Connect(function(input, gp)
    if gp then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        gui.Enabled = not gui.Enabled
    end
end)

-- Feature Implementations
local flyBodyVelocity, flyBodyGyro
RunService.RenderStepped:Connect(function(delta)
    local char = player.Character
    if not char then return end

    local hum = char:FindFirstChildOfClass("Humanoid")
    local root = char:FindFirstChild("HumanoidRootPart")

    if hum then
        if State.Movement.WalkSpeed then
            hum.WalkSpeed = State.Movement.WalkSpeedValue
        end

        if State.Movement.SlideBoost and hum:GetState() == Enum.HumanoidStateType.Freefall and UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) and hum.MoveDirection.Magnitude > 0 then
            root.Velocity = root.Velocity + hum.MoveDirection * 30 * delta
        end
    end

    if root then
        if State.Movement.Fly then
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

            local vel = Vector3.new()
            local dir = hum.MoveDirection
            if dir.Magnitude > 0 then
                vel = camera.CFrame:VectorToWorldSpace(dir)
            end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then vel = vel + camera.CFrame.UpVector end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then vel = vel - camera.CFrame.UpVector end
            flyBodyVelocity.Velocity = vel.Unit * State.Movement.FlySpeed
        elseif flyBodyVelocity then
            flyBodyVelocity:Destroy()
            flyBodyVelocity = nil
            flyBodyGyro:Destroy()
            flyBodyGyro = nil
        end

        if State.Movement.Noclip then
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide then
                    part.CanCollide = false
                end
            end
        end
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
        for _, d in pairs(drawings) do d.Visible = false end
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
        local size = Vector3.new(2, 5, 1) -- Approximate character bounding box
        for x = -1, 1, 2 do for y = -1, 1, 2 do for z = -1, 1, 2 do
            local corner = camera:WorldToViewportPoint(root.CFrame * CFrame.new(x*size.X/2, y*size.Y/2, z*size.Z/2).Position)
            table.insert(corners, Vector2.new(corner.X, corner.Y))
        end end end

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
        if width < 5 or height < 5 then continue end -- Offscreen or too small

        local key = tostring(plr)
        if not espCache[key] then
            espCache[key] = {
                box = Drawing.new("Quad"),
                name = Drawing.new("Text"),
                health = Drawing.new("Line"),
                distance = Drawing.new("Text")
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
        end

        local drawings = espCache[key]
        local screenHead = camera:WorldToViewportPoint(head.Position)
        local screenRoot = camera:WorldToViewportPoint(root.Position)

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
    end
end)

Players.PlayerRemoving:Connect(function(plr)
    local key = tostring(plr)
    if espCache[key] then
        for _, d in pairs(espCache[key]) do d:Remove() end
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

-- Silent Aim (Raycast Hook)
local oldNamecall = nil
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    if not State.Combat.SilentAim or getnamecallmethod() ~= "Raycast" or self ~= Workspace then
        return oldNamecall(self, ...)
    end

    if math.random(1, 100) > State.Combat.SilentHitChance then
        return oldNamecall(self, ...)
    end

    local args = {...}
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
