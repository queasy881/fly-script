-- SIMPLE HUB v3.7 – Main Client
-- DO NOT EXECUTE DIRECTLY (use loader.lua)

---------------- SERVICES ----------------
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

---------------- PLAYER ----------------
local player = Players.LocalPlayer
local mouse = player:GetMouse()
local camera = workspace.CurrentCamera

---------------- CHARACTER ----------------
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

---------------- GLOBAL STATE ----------------
_G.Hub = {
	Player = player,
	Mouse = mouse,
	Camera = camera,
	Character = character,
	Humanoid = humanoid,
	Root = root,

	-- Toggles
	Fly = false,
	Noclip = false,
	WalkEnabled = false,
	JumpEnabled = false,
	Invisible = false,
	AimAssist = false,
	SilentAim = false,
	BoxESP = false,
	NameESP = false,
	Teleport = false,

	-- Values
	FlySpeed = 23,
	WalkSpeed = humanoid.WalkSpeed,
	JumpPower = humanoid.JumpPower,
	InvisAmount = 1,
	AimFOV = 100,
	AimSmoothness = 0.5,

	-- UI
	UIOpen = false,
}

---------------- CHARACTER RESPAWN ----------------
player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = char:WaitForChild("Humanoid")
	root = char:WaitForChild("HumanoidRootPart")

	_G.Hub.Character = character
	_G.Hub.Humanoid = humanoid
	_G.Hub.Root = root
end)

---------------- MODULE LOADER ----------------
local BASE_URL = "https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/"

local function load(file)
	return loadstring(game:HttpGet(BASE_URL .. file, true))()
end

---------------- LOAD UI ----------------
load("ui/components.lua")
load("ui/animations.lua")
load("ui/tabs.lua")

---------------- LOAD FEATURES ----------------
-- Movement
load("movement/fly.lua")
load("movement/walkspeed.lua")
load("movement/jump.lua")

-- Combat
load("combat/aim_assist.lua")
load("combat/silent_aim.lua")

-- ESP
load("esp/box_esp.lua")
load("esp/name_esp.lua")

-- Extra
load("extra/invisibility.lua")
load("extra/teleport.lua")

---------------- MENU TOGGLE ----------------
UIS.InputBegan:Connect(function(input, gp)
	if gp then return end
	if input.KeyCode == Enum.KeyCode.M then
		_G.Hub.UIOpen = not _G.Hub.UIOpen
		if _G.Hub.ToggleUI then
			_G.Hub.ToggleUI(_G.Hub.UIOpen)
		end
	end
end)

print("✅ Simple Hub v3.7 main.client.lua loaded")

