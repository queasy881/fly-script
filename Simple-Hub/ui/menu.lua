return function(deps)
    local Tabs = deps.Tabs
    local Components = deps.Components

    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local RunService = game:GetService("RunService")

    local player = Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local root = character:WaitForChild("HumanoidRootPart")
    local camera = workspace.CurrentCamera

    -- GUI
    local gui = Instance.new("ScreenGui", player.PlayerGui)
    gui.Name = "SimpleHub"
    gui.ResetOnSpawn = false

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.new(0,780,0,520)
    main.Position = UDim2.fromScale(0.5,0.5)
    main.AnchorPoint = Vector2.new(0.5,0.5)
    main.Visible = false
    main.BackgroundColor3 = Color3.fromRGB(18,18,22)

    UIS.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode == Enum.KeyCode.M then
            main.Visible = not main.Visible
        end
    end)

    local tabBar = Instance.new("Frame", main)
    tabBar.Size = UDim2.new(1,0,0,50)
    tabBar.BackgroundTransparency = 1

    local pages = Instance.new("Frame", main)
    pages.Position = UDim2.new(0,0,0,50)
    pages.Size = UDim2.new(1,0,1,-50)
    pages.BackgroundTransparency = 1

    -- TABS
    local Movement = Tabs.create(tabBar, pages, "Movement")
    local Combat   = Tabs.create(tabBar, pages, "Combat")
    local ESP      = Tabs.create(tabBar, pages, "ESP")
    local Extra    = Tabs.create(tabBar, pages, "Extra")

    Movement.page.Visible = true
    Tabs.active = Movement

    ----------------------------------------------------------------
    -- MOVEMENT TAB
    ----------------------------------------------------------------
    Components.Toggle(Movement.page, "Fly", false, function(v)
        Fly.enabled = v
        if v then Fly.enable(root, camera) else Fly.disable() end
    end)

    Components.Slider(Movement.page, "Fly Speed", 10, 100, Fly.speed, function(v)
        Fly.speed = v
    end)

    Components.Toggle(Movement.page, "Noclip", false, function(v)
        Noclip.enabled = v
    end)

    Components.Toggle(Movement.page, "Bunny Hop", false, function(v)
        BunnyHop.enabled = v
    end)

    Components.Toggle(Movement.page, "Dash", false, function(v)
        Dash.enabled = v
    end)

    Components.Slider(Movement.page, "WalkSpeed", 16, 100, WalkSpeed.value, function(v)
        WalkSpeed.enabled = true
        WalkSpeed.value = v
        WalkSpeed.apply(humanoid)
    end)

    Components.Slider(Movement.page, "Jump Power", 50, 200, JumpPower.value, function(v)
        JumpPower.enabled = true
        JumpPower.value = v
        JumpPower.apply(humanoid)
    end)

    ----------------------------------------------------------------
    -- COMBAT TAB
    ----------------------------------------------------------------
    Components.Toggle(Combat.page, "Aim Assist", false, function(v)
        AimAssist.enabled = v
    end)

    Components.Slider(Combat.page, "Aim Assist FOV", 20, 500, AimAssist.fov, function(v)
        AimAssist.fov = v
    end)

    Components.Toggle(Combat.page, "Silent Aim", false, function(v)
        SilentAim.enabled = v
    end)

    Components.Slider(Combat.page, "Silent Aim FOV", 20, 500, SilentAim.fov, function(v)
        SilentAim.fov = v
    end)

    Components.Toggle(Combat.page, "FOV Circle", false, function(v)
        FOV.enabled = v
        if v then FOV.create() end
    end)

    Components.Slider(Combat.page, "FOV Circle Radius", 20, 500, FOV.radius, function(v)
        FOV.radius = v
    end)

    ----------------------------------------------------------------
    -- ESP TAB
    ----------------------------------------------------------------
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

    ----------------------------------------------------------------
    -- EXTRA TAB
    ----------------------------------------------------------------
    Components.Toggle(Extra.page, "Invisibility", false, function(v)
        Invisibility.enabled = v
    end)

    Components.Slider(Extra.page, "Invisibility Strength", 0, 1, Invisibility.amount, function(v)
        Invisibility.amount = v
    end)

    Components.Toggle(Extra.page, "Anti AFK", false, function(v)
        AntiAFK.enabled = v
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
end
