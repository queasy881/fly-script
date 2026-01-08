-- main.client.lua
-- Simple Game Selector GUI Loader

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Create GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "GameSelectorGui"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.fromScale(0.3, 0.4)
Frame.Position = UDim2.fromScale(0.35, 0.3)
Frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- Title
local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(1, 0.2)
Title.BackgroundTransparency = 1
Title.Text = "Which game do you want to open?"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

-- Button container
local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.fromScale(1, 0.8)
ButtonsFrame.Position = UDim2.fromScale(0, 0.2)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = Frame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Padding = UDim.new(0, 10)
UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Parent = ButtonsFrame

-- Button creator
local function createButton(text, callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromScale(0.8, 0.18)
	Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.Font = Enum.Font.Gotham
	Button.TextScaled = true
	Button.AutoButtonColor = true

	local Corner = Instance.new("UICorner")
	Corner.CornerRadius = UDim.new(0, 8)
	Corner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		pcall(callback)
		ScreenGui:Destroy()
	end)

	Button.Parent = ButtonsFrame
end

-- === GAME LOADERS (REPLACE LOADSTRINGS) ===

createButton("RIVALS", function()
	loadstring([[

		-- RIVALS SCRIPT HERE

	]])()
end)

createButton("ARSENAL", function()
	loadstring([[

		-- ARSENAL SCRIPT HERE

	]])()
end)

createButton("FLICK", function()
	loadstring([[

		-- FLICK SCRIPT HERE

	]])()
end)

createButton("UNIVERSAL", function()
	loadstring([[

		-- UNIVERSAL SCRIPT HERE

	]])()
end)

print("[Game Selector] GUI Loaded")
