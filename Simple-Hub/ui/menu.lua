-- ui/menu.lua
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Tabs = require(script.Parent.tabs)
local Components = require(script.Parent.components)

return function()
    print("[UI] Menu init")

    local player = Players.LocalPlayer

    local gui = Instance.new("ScreenGui")
    gui.Name = "SimpleHub"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local main = Instance.new("Frame", gui)
    main.Size = UDim2.fromOffset(780, 520)
    main.Position = UDim2.fromScale(0.5, 0.5)
    main.AnchorPoint = Vector2.new(0.5, 0.5)
    main.BackgroundColor3 = Color3.fromRGB(18,18,22)
    main.Visible = false
    Instance.new("UICorner", main).CornerRadius = UDim.new(0,12)

    -- Title
    local title = Instance.new("TextLabel", main)
    title.Size = UDim2.new(1,0,0,48)
    title.Text = "SIMPLE HUB"
    title.Font = Enum.Font.GothamBold
    title.TextSize = 16
    title.TextColor3 = Color3.new(1,1,1)
    title.BackgroundTransparency = 1

    -- Tab bar
    local tabBar = Instance.new("Frame", main)
    tabBar.Position = UDim2.new(0,0,0,48)
    tabBar.Size = UDim2.new(1,0,0,48)
    tabBar.BackgroundColor3 = Color3.fromRGB(20,20,26)

    Instance.new("UIListLayout", tabBar).Padding = UDim.new(0,8)

    -- Content
    local content = Instance.new("Frame", main)
    content.Position = UDim2.new(0,0,0,96)
    content.Size = UDim2.new(1,0,1,-96)
    content.BackgroundTransparency = 1

    -- Frames
    local movement = Instance.new("ScrollingFrame", content)
    local combat   = Instance.new("ScrollingFrame", content)
    local esp      = Instance.new("ScrollingFrame", content)
    local extra    = Instance.new("ScrollingFrame", content)

    for _,f in ipairs({movement, combat, esp, extra}) do
        f.Size = UDim2.new(1,0,1,0)
        f.ScrollBarThickness = 6
        f.Visible = false
        Instance.new("UIListLayout", f).Padding = UDim.new(0,8)
    end

    movement.Visible = true

    -- Tabs
    local tMove   = Tabs.create(tabBar, "Movement")
    local tCombat = Tabs.create(tabBar, "Combat")
    local tESP    = Tabs.create(tabBar, "ESP")
    local tExtra  = Tabs.create(tabBar, "Extra")

    Tabs.activate(tMove)

    tMove.MouseButton1Click:Connect(function()
        Tabs.activate(tMove)
        movement.Visible, combat.Visible, esp.Visible, extra.Visible = true,false,false,false
    end)

    tCombat.MouseButton1Click:Connect(function()
        Tabs.activate(tCombat)
        movement.Visible, combat.Visible, esp.Visible, extra.Visible = false,true,false,false
    end)

    tESP.MouseButton1Click:Connect(function()
        Tabs.activate(tESP)
        movement.Visible, combat.Visible, esp.Visible, extra.Visible = false,false,true,false
    end)

    tExtra.MouseButton1Click:Connect(function()
        Tabs.activate(tExtra)
        movement.Visible, combat.Visible, esp.Visible, extra.Visible = false,false,false,true
    end)

    -- KEY TOGGLE
    UIS.InputBegan:Connect(function(i,gp)
        if gp then return end
        if i.KeyCode == Enum.KeyCode.M then
            main.Visible = not main.Visible
        end
    end)

    -- EXPOSE FRAMES FOR FEATURES
    return {
        Movement = movement,
        Combat = combat,
        ESP = esp,
        Extra = extra
    }
end
