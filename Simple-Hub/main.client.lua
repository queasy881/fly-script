-- main.client.lua
-- Simple Game Selector (GitHub Repo Loader)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local HttpService = game:GetService("HttpService")

-- CHANGE THIS ONLY IF YOUR REPO URL CHANGES
local BASE =
    "https://raw.githubusercontent.com/queasy881/fly-script/main/Simple-Hub/"

-- Safe loader
local function loadFromRepo(path)
	print("[LOADING FILE]", path)

	local ok, src = pcall(function()
		return game:HttpGet(BASE .. path .. "?nocache=" .. tostring(os.clock()))
	end)

	if not ok or not src then
		warn("[LOAD FAILED]", path)
		return
	end

	local fn, err = loadstring(src)
	if not fn then
		warn("[LOADSTRING ERROR]", err)
		return
	end

	pcall(fn)
end

-- GUI
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

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 12)
Corner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(1, 0.2)
Title.BackgroundTransparency = 1
Title.Text = "Which game do you want to open?"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

local ButtonsFrame = Instance.new("Frame")
ButtonsFrame.Size = UDim2.fromScale(1, 0.8)
ButtonsFrame.Position = UDim2.fromScale(0, 0.2)
ButtonsFrame.BackgroundTransparency = 1
ButtonsFrame.Parent = Frame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.VerticalAlignment = Enum.VerticalAlignment.Center
Layout.Parent = ButtonsFrame

local function createButton(text, filePath)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.fromScale(0.8, 0.18)
	Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	Button.Text = text
	Button.TextColor3 = Color3.fromRGB(255, 255, 255)
	Button.Font = Enum.Font.Gotham
	Button.TextScaled = true
	Button.Parent = ButtonsFrame

	local BtnCorner = Instance.new("UICorner")
	BtnCorner.CornerRadius = UDim.new(0, 8)
	BtnCorner.Parent = Button

	Button.MouseButton1Click:Connect(function()
		if filePath ~= "" then
			loadFromRepo(filePath)
		else
			warn(text .. " file path not set")
		end
		ScreenGui:Destroy()
	end)
end

-- === GAME OPTIONS (LEAVE FILE NAMES BLANK) ===

createButton("RIVALS", "")
createButton("ARSENAL", "")
createButton("FLICK", "")
createButton("UNIVERSAL", "")

print("[Game Selector] Loaded")
