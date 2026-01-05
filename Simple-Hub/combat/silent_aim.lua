-- combat/silent_aim.lua
-- SAFE Silent Aim implementation (executor-friendly)

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local camera = Workspace.CurrentCamera
local mouse = player:GetMouse()

local SilentAim = {
	enabled = false,
	fov = 150,
	hitChance = 100,
	targetPart = "Head"
}

-- =========================
-- TARGET SELECTION
-- =========================
function SilentAim.getTarget()
	local closestPart = nil
	local closestDist = math.huge

	local screenCenter = Vector2.new(
		camera.ViewportSize.X / 2,
		camera.ViewportSize.Y / 2
	)

	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local hum = plr.Character:FindFirstChildOfClass("Humanoid")
			local part =
				plr.Character:FindFirstChild(SilentAim.targetPart)
				or plr.Character:FindFirstChild("Head")

			if hum and hum.Health > 0 and part then
				local pos, onScreen = camera:WorldToViewportPoint(part.Position)
				if onScreen then
					local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
					if dist < SilentAim.fov and dist < closestDist then
						closestDist = dist
						closestPart = part
					end
				end
			end
		end
	end

	return closestPart
end

-- =========================
-- HIT CHANCE
-- =========================
function SilentAim.shouldHit()
	return math.random(1, 100) <= SilentAim.hitChance
end

-- =========================
-- MOUSE HOOK (Hit / Target)
-- =========================
pcall(function()
	local oldIndex
	oldIndex = hookmetamethod(game, "__index", function(self, key)
		if not checkcaller() and SilentAim.enabled and self == mouse then
			if SilentAim.shouldHit() then
				local target = SilentAim.getTarget()
				if target then
					if key == "Hit" then
						return CFrame.new(target.Position)
					elseif key == "Target" then
						return target
					end
				end
			end
		end

		return oldIndex(self, key)
	end)
end)

-- =========================
-- RAYCAST HOOK (SAFE)
-- =========================
pcall(function()
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		if not checkcaller() and SilentAim.enabled then
			local method = getnamecallmethod()
			local args = { ... }

			if self == Workspace and method == "Raycast" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target and args[1] and args[2] then
						local origin = args[1]
						local direction = (target.Position - origin).Unit * args[2].Magnitude
						return oldNamecall(self, origin, direction, args[3])
					end
				end
			end
		end

		return oldNamecall(self, ...)
	end)
end)

-- =========================
-- PUBLIC API (Controller uses this)
-- =========================
function SilentAim:Set(state)
	self.enabled = state
end

function SilentAim:SetFOV(v)
	self.fov = v
end

function SilentAim:SetHitChance(v)
	self.hitChance = v
end

function SilentAim:SetTargetPart(partName)
	self.targetPart = partName
end

return SilentAim
