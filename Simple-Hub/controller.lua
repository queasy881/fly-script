-- controller.lua
-- Central feature controller that connects UI to modules

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")

local Controller = {}
Controller.modules = {}
Controller.player = Players.LocalPlayer
Controller.camera = workspace.CurrentCamera
Controller.character = nil
Controller.humanoid = nil
Controller.root = nil

-- Store loaded modules
function Controller.registerModule(name, module)
	Controller.modules[name] = module
	print("[Controller] Registered:", name)
end

-- Get character references
function Controller.updateReferences()
	Controller.character = Controller.player.Character
	if Controller.character then
		Controller.humanoid = Controller.character:FindFirstChildOfClass("Humanoid")
		Controller.root = Controller.character:FindFirstChild("HumanoidRootPart")
	end
end

-- Initialize references
Controller.updateReferences()
Controller.player.CharacterAdded:Connect(function()
	task.wait(0.5)
	Controller.updateReferences()
end)

-- ============================================
-- MOVEMENT HANDLERS
-- ============================================

function Controller.toggleFly(state)
	local Fly = Controller.modules.Fly
	if not Fly then return end
	
	if state then
		Controller.updateReferences()
		if Controller.root then
			Fly.enable(Controller.root, Controller.camera)
		end
	else
		Fly.disable()
	end
end

function Controller.toggleNoclip(state)
	local Noclip = Controller.modules.Noclip
	if Noclip then
		Noclip.enabled = state
	end
end

function Controller.setWalkSpeed(value)
	local WalkSpeed = Controller.modules.WalkSpeed
	if not WalkSpeed then return end
	
	WalkSpeed.enabled = true
	WalkSpeed.value = value
	
	if Controller.humanoid then
		WalkSpeed.apply(Controller.humanoid)
	end
end

function Controller.setJumpPower(value)
	local JumpPower = Controller.modules.JumpPower
	if not JumpPower then return end
	
	JumpPower.enabled = true
	JumpPower.value = value
	
	if Controller.humanoid then
		JumpPower.apply(Controller.humanoid)
	end
end

function Controller.toggleBunnyHop(state)
	local BunnyHop = Controller.modules.BunnyHop
	if BunnyHop then
		BunnyHop.enabled = state
	end
end

function Controller.toggleDash(state)
	local Dash = Controller.modules.Dash
	if Dash then
		Dash.enabled = state
	end
end

function Controller.setAirControl(value)
	local AirControl = Controller.modules.AirControl
	if AirControl then
		AirControl.strength = value
	end
end

-- ============================================
-- COMBAT HANDLERS
-- ============================================

function Controller.toggleAimAssist(state)
	local AimAssist = Controller.modules.AimAssist
	if AimAssist then
		AimAssist.enabled = state
	end
end

function Controller.setAimSmoothness(value)
	local AimAssist = Controller.modules.AimAssist
	if AimAssist then
		-- Convert 0-100 slider to 0.01-1.0 smoothness (inverted)
		AimAssist.smoothness = 1 - (value / 100)
	end
end

function Controller.setFOV(value)
	local AimAssist = Controller.modules.AimAssist
	local FOV = Controller.modules.FOV
	
	if AimAssist then
		AimAssist.fov = value
	end
	if FOV then
		FOV.radius = value
	end
end

function Controller.toggleFOVCircle(state)
	local FOV = Controller.modules.FOV
	if not FOV then return end
	
	if state and not FOV.circle then
		FOV.create()
	end
	FOV.enabled = state
end

function Controller.toggleSilentAim(state)
	local SilentAim = Controller.modules.SilentAim
	if SilentAim then
		SilentAim.enabled = state
	end
end

function Controller.setHitChance(value)
	local SilentAim = Controller.modules.SilentAim
	if SilentAim then
		SilentAim.hitChance = value
	end
end

-- ============================================
-- ESP HANDLERS
-- ============================================

function Controller.toggleNameESP(state)
	local NameESP = Controller.modules.NameESP
	if not NameESP then return end
	
	if state then
		local gui = Controller.player.PlayerGui:FindFirstChild("SimpleHub")
		if gui then
			NameESP.enable(Controller.player, gui)
		end
	else
		NameESP.disable()
	end
end

function Controller.toggleBoxESP(state)
	local BoxESP = Controller.modules.BoxESP
	if not BoxESP then return end
	
	if state then
		local gui = Controller.player.PlayerGui:FindFirstChild("SimpleHub")
		if gui then
			BoxESP.enable(Controller.player, gui)
		end
	else
		BoxESP.disable()
	end
end

function Controller.toggleHealthESP(state)
	local HealthESP = Controller.modules.HealthESP
	if not HealthESP then return end
	
	if state then
		local gui = Controller.player.PlayerGui:FindFirstChild("SimpleHub")
		if gui then
			HealthESP.enable(Controller.player, gui)
		end
	else
		HealthESP.disable()
	end
end

function Controller.toggleDistanceESP(state)
	local DistanceESP = Controller.modules.DistanceESP
	if not DistanceESP then return end
	
	if state then
		Controller.updateReferences()
		local gui = Controller.player.PlayerGui:FindFirstChild("SimpleHub")
		if gui and Controller.root then
			DistanceESP.enable(Controller.player, gui, Controller.root)
		end
	else
		DistanceESP.disable()
	end
end

function Controller.toggleTracers(state)
	local Tracers = Controller.modules.Tracers
	if not Tracers then return end
	
	if state then
		Tracers.enable(Controller.player, Controller.camera)
	else
		Tracers.disable()
	end
end

function Controller.toggleChams(state)
	local Chams = Controller.modules.Chams
	if not Chams then return end
	
	if state then
		Chams.enable(Controller.player)
	else
		Chams.disable()
	end
end

-- ============================================
-- EXTRA HANDLERS
-- ============================================

function Controller.toggleFullbright(state)
	local Fullbright = Controller.modules.Fullbright
	if not Fullbright then return end
	
	Fullbright.enabled = state
	Fullbright.toggle()
end

function Controller.toggleRemoveGrass(state)
	local RemoveGrass = Controller.modules.RemoveGrass
	if not RemoveGrass then return end
	
	RemoveGrass.enabled = state
	RemoveGrass.apply()
end

function Controller.toggleThirdPerson(state)
	local ThirdPerson = Controller.modules.ThirdPerson
	if not ThirdPerson then return end
	
	ThirdPerson.enabled = state
	ThirdPerson.apply(Controller.player)
end

function Controller.toggleAntiAFK(state)
	local AntiAFK = Controller.modules.AntiAFK
	if AntiAFK then
		AntiAFK.enabled = state
	end
end

function Controller.toggleInvisibility(state)
	local Invisibility = Controller.modules.Invisibility
	if not Invisibility then return end
	
	Invisibility.enabled = state
	Controller.updateReferences()
	if Controller.character then
		Invisibility.apply(Controller.character)
	end
end

function Controller.toggleWalkOnWater(state)
	local WalkOnWater = Controller.modules.WalkOnWater
	if WalkOnWater then
		WalkOnWater.enabled = state
	end
end

function Controller.toggleSpinBot(state)
	local SpinBot = Controller.modules.SpinBot
	if SpinBot then
		SpinBot.enabled = state
	end
end

function Controller.toggleFakeLag(state)
	local FakeLag = Controller.modules.FakeLag
	if FakeLag then
		FakeLag.enabled = state
	end
end

function Controller.toggleFakeDeath(state)
	local FakeDeath = Controller.modules.FakeDeath
	if not FakeDeath then return end
	
	FakeDeath.enabled = state
	Controller.updateReferences()
	if Controller.character and Controller.humanoid then
		FakeDeath.apply(Controller.character, Controller.humanoid)
	end
end

-- ============================================
-- MAIN UPDATE LOOP
-- ============================================

RunService.RenderStepped:Connect(function(dt)
	Controller.updateReferences()
	
	if not Controller.character or not Controller.humanoid or not Controller.root then
		return
	end
	
	-- Movement updates
	local Fly = Controller.modules.Fly
	if Fly and Fly.enabled then
		Fly.update(Controller.root, Controller.camera, UIS)
	end
	
	local Noclip = Controller.modules.Noclip
	if Noclip and Noclip.enabled then
		Noclip.update(Controller.character)
	end
	
	local BunnyHop = Controller.modules.BunnyHop
	if BunnyHop and BunnyHop.enabled then
		BunnyHop.update(Controller.humanoid)
	end
	
	local AirControl = Controller.modules.AirControl
	if AirControl and AirControl.strength > 0 then
		AirControl.update(Controller.root, Controller.humanoid, Controller.camera, UIS)
	end
	
	-- Extra updates
	local AntiAFK = Controller.modules.AntiAFK
	if AntiAFK and AntiAFK.enabled then
		AntiAFK.update(dt)
	end
	
	local WalkOnWater = Controller.modules.WalkOnWater
	if WalkOnWater and WalkOnWater.enabled then
		WalkOnWater.update(Controller.root)
	end
	
	local SpinBot = Controller.modules.SpinBot
	if SpinBot and SpinBot.enabled then
		SpinBot.update(Controller.root, dt)
	end
	
	local FakeLag = Controller.modules.FakeLag
	if FakeLag and FakeLag.enabled then
		FakeLag.update(Controller.root)
	end
end)

-- Dash keybind
UIS.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	
	if input.KeyCode == Enum.KeyCode.F then
		local Dash = Controller.modules.Dash
		if Dash and Dash.enabled then
			Controller.updateReferences()
			if Controller.root then
				Dash.tryDash(Controller.root, Controller.camera)
			end
		end
	end
end)

_G.Controller = Controller
return Controller
