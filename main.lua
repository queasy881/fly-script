-- Simple Menu Toggle (Press M)

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer

-- Create ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "SimpleMenuGui"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

-- Create menu frame
local frame = Instance.new("Frame")
frame.Size = UDim2.fromScale(0.4, 0.3)
frame.Position = UDim2.fromScale(0.3, 0.35)
frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
frame.Visible = false
frame.Parent = gui

-- Optional: rounded corners
local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Toggle logic
local menuOpen = false

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end

	if input.KeyCode == Enum.KeyCode.M then
		menuOpen = not menuOpen
		frame.Visible = menuOpen
	end
end)
