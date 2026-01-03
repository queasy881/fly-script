return function(deps)
    local Tabs = deps.Tabs
    local Components = deps.Components

    local Players = game:GetService("Players")
    local UIS = game:GetService("UserInputService")
    local player = Players.LocalPlayer

    local gui = Instance.new("ScreenGui", player.PlayerGui)
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

    local pages = Instance.new("Frame", main)
    pages.Position = UDim2.new(0,0,0,50)
    pages.Size = UDim2.new(1,0,1,-50)
    pages.BackgroundTransparency = 1

    -- Tabs
    local movement = Tabs.create(tabBar, pages, "Movement")
    local esp = Tabs.create(tabBar, pages, "ESP")
    local combat = Tabs.create(tabBar, pages, "Combat")
    local visuals = Tabs.create(tabBar, pages, "Visuals")

    movement.page.Visible = true
    Tabs.active = movement
end
