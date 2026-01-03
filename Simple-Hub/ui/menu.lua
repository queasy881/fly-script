return function(deps)
    local Tabs = deps.Tabs
    local Components = deps.Components

    local Fly = deps.Fly
    local WalkSpeed = deps.WalkSpeed
    local JumpPower = deps.JumpPower
    local Noclip = deps.Noclip
    local BunnyHop = deps.BunnyHop
    local Dash = deps.Dash

    local AimAssist = deps.AimAssist
    local SilentAim = deps.SilentAim
    local FOV = deps.FOV

    local NameESP = deps.NameESP
    local BoxESP = deps.BoxESP
    local HealthESP = deps.HealthESP
    local DistanceESP = deps.DistanceESP
    local Chams = deps.Chams

    local Invisibility = deps.Invisibility
    local AntiAFK = deps.AntiAFK
    local SpinBot = deps.SpinBot
    local FakeLag = deps.FakeLag
    local WalkOnWater = deps.WalkOnWater

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

    -- Tabs
    local Movement = Tabs.create(tabBar, pages, "Movement")
    local Combat   = Tabs.create(tabBar, pages, "Combat")
    local ESP      = Tabs.create(tabBar, pages, "ESP")
    local Extra    = Tabs.create(tabBar, pages, "Extra")

    Movement.page.Visible = true
    Tabs.active = Movement

    ----------------------------------------------------------------
    -- EXTRA (example)
    ----------------------------------------------------------------
    Components.Toggle(Extra.page, "Invisibility", false, function(v)
        Invisibility.enabled = v
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

    ----------------------------------------------------------------
    -- CENTRAL UPDATE LOOP (THIS IS WHAT WAS MISSING)
    ----------------------------------------------------------------
    RunService.RenderStepped:Connect(function(dt)
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

        if AntiAFK.enabled then
            AntiAFK.update(dt)
        end
    end)
end
