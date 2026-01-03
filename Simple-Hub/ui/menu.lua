return function(deps)
    local Tabs = deps.Tabs
    local Components = deps.Components

    -- movement
    local Fly = deps.Fly
    local WalkSpeed = deps.WalkSpeed
    local JumpPower = deps.JumpPower
    local Noclip = deps.Noclip
    local BunnyHop = deps.BunnyHop

    -- combat
    local AimAssist = deps.AimAssist
    local FOV = deps.FOV

    -- esp
    local NameESP = deps.NameESP
    local BoxESP = deps.BoxESP
    local HealthESP = deps.HealthESP
    local DistanceESP = deps.DistanceESP
    local Chams = deps.Chams

    -- extra
    local Invisibility = deps.Invisibility
    local AntiAFK = deps.AntiAFK
    local SpinBot = deps.SpinBot
    local FakeLag = deps.FakeLag
    local WalkOnWater = deps.WalkOnWater
    local Fullbright = deps.Fullbright
    local RemoveGrass = deps.RemoveGrass
    local ThirdPerson = deps.ThirdPerson

    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera

    ------------------------------------------------------------
    -- GUI
    ------------------------------------------------------------
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,780,0,520)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.BackgroundColor3 = Color3.fromRGB(18,18,22)
    main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

    UIS.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode == Enum.KeyCode.M then
            main.Visible = not main.Visible
        end
    end)

    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(1,0,0,44)
    tabBar.BackgroundTransparency = 1

    local tabLayout = Instance.new("UIListLayout", tabBar)
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.Padding = UDim.new(0,12)

    local pages = Instance.new("Frame", main)
    pages.Position = UDim2.new(0,0,0,44)
    pages.Size = UDim2.new(1,0,1,-44)
    pages.BackgroundTransparency = 1

    local Movement = Tabs.create(tabBar, pages, "Movement")
    local Combat   = Tabs.create(tabBar, pages, "Combat")
    local ESP      = Tabs.create(tabBar, pages, "ESP")
    local Extra    = Tabs.create(tabBar, pages, "Extra")

    Movement.page.Visible = true
    Tabs.active = Movement

    ------------------------------------------------------------
    -- MOVEMENT
    ------------------------------------------------------------
    Components.Toggle(Movement.page, "Fly", false, function(v)
        Fly.enabled = v
        if v then
            WalkSpeed.enabled = false
            JumpPower.enabled = false
            Fly.enable(root, camera)
        else
            Fly.disable()
        end
    end)

    Components.Slider(Movement.page, "Fly Speed", 10, 120, Fly.speed, function(v)
        Fly.speed = v
    end)

    Components.Toggle(Movement.page, "WalkSpeed", false, function(v)
        WalkSpeed.enabled = v
        WalkSpeed.apply(humanoid)
    end)

    Components.Slider(Movement.page, "WalkSpeed Value", 16, 100, WalkSpeed.value, function(v)
        WalkSpeed.value = v
        if WalkSpeed.enabled then
            WalkSpeed.apply(humanoid)
        end
    end)

    Components.Toggle(Movement.page, "Jump Power", false, function(v)
        JumpPower.enabled = v
        JumpPower.apply(humanoid)
    end)

    Components.Slider(Movement.page, "Jump Power Value", 50, 200, JumpPower.value, function(v)
        JumpPower.value = v
        if JumpPower.enabled then
            JumpPower.apply(humanoid)
        end
    end)

    Components.Toggle(Movement.page, "Noclip", false, function(v)
        Noclip.enabled = v
    end)

    Components.Toggle(Movement.page, "Bunny Hop", false, function(v)
        BunnyHop.enabled = v
    end)

    ------------------------------------------------------------
    -- COMBAT
    ------------------------------------------------------------
    Components.Toggle(Combat.page, "Aim Assist (Hold RMB)", false, function(v)
        AimAssist.enabled = v
        AimAssist.keybind = "RMB"
    end)

    Components.Slider(Combat.page, "Aim Assist FOV", 30, 500, AimAssist.fov, function(v)
        AimAssist.fov = v
        FOV.radius = v

    end)

    Components.Toggle(Combat.page, "FOV Circle", false, function(v)
        FOV.enabled = v
        if v then FOV.create() end
    end)

    ------------------------------------------------------------
    -- ESP
    ------------------------------------------------------------
    Components.Toggle(ESP.page, "Name ESP", false, function(v)
        if v then NameESP.enable(player, gui) else NameESP.disable() end
    end)

    Components.Toggle(ESP.page, "Box ESP", false, function(v)
        if v then BoxESP.enable(player, gui) else BoxESP.disable() end
    end)

    Components.Toggle(ESP.page, "Health ESP", false, function(v)
        if v then HealthESP.enable(player, gui) else HealthESP.disable() end
    end)

    Components.Toggle(ESP.page, "Distance ESP", false, function(v)
        if v then DistanceESP.enable(player, gui, root) else DistanceESP.disable() end
    end)

    Components.Toggle(ESP.page, "Chams", false, function(v)
        if v then Chams.enable(player) else Chams.disable() end
    end)

    ------------------------------------------------------------
    -- EXTRA
    ------------------------------------------------------------
    Components.Toggle(Extra.page, "Invisibility", false, function(v)
        Invisibility.enabled = v
    end)

    Components.Toggle(Extra.page, "Fullbright", false, function(v)
        Fullbright.enabled = v
        Fullbright.toggle()
    end)

    Components.Toggle(Extra.page, "Remove Grass", false, function(v)
        RemoveGrass.enabled = v
        RemoveGrass.apply()
    end)

    Components.Toggle(Extra.page, "Third Person", false, function(v)
        ThirdPerson.enabled = v
        ThirdPerson.apply(player)
    end)

    Components.Toggle(Extra.page, "Spinbot", false, function(v)
        SpinBot.enabled = v
    end)

    Components.Toggle(Extra.page, "Fake Lag", false, function(v)
        FakeLag.enabled = v
    end)

    Components.Toggle(Extra.page, "Walk on Water", false, function(v)
        WalkOnWater.enabled = v
    end)

    Components.Toggle(Extra.page, "Anti AFK", false, function(v)
        AntiAFK.enabled = v
    end)

    ------------------------------------------------------------
    -- UPDATE LOOP (THIS MAKES EVERYTHING ACTUALLY WORK)
    ------------------------------------------------------------
    RunService.RenderStepped:Connect(function(dt)
        if Fly.enabled then
            Fly.update(root, camera, UIS)
        end
        if Noclip.enabled then
            Noclip.update(character)
        end
        if BunnyHop.enabled then
            BunnyHop.update(humanoid)
        end
        if SpinBot.enabled then
            SpinBot.update(root, dt)
        end
        if FakeLag.enabled then
            FakeLag.update(root)
        end
        if WalkOnWater.enabled then
            WalkOnWater.update(root)
        end
        if Invisibility.enabled then
            Invisibility.apply(character)
        end
        if AntiAFK.enabled then
            AntiAFK.update(dt)
        end
    end)
end
