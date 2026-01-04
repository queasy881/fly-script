-- combat/silent_aim.lua
-- Silent Aim with hooks

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local SilentAim = {
	enabled = false,
	fov = 150,
	hitChance = 100,
	targetPart = "Head"
}

function SilentAim.getTarget()
	local closest, closestDist = nil, math.huge
	local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
	
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character then
			local humanoid = plr.Character:FindFirstChildOfClass("Humanoid")
			local targetPart = plr.Character:FindFirstChild(SilentAim.targetPart) or plr.Character:FindFirstChild("Head")
			
			if humanoid and humanoid.Health > 0 and targetPart then
				local screenPos, onScreen = camera:WorldToViewportPoint(targetPart.Position)
				
				if onScreen then
					local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
					
					if dist < SilentAim.fov and dist < closestDist then
						closestDist = dist
						closest = targetPart
					end
				end
			end
		end
	end
	
	return closest
end

function SilentAim.shouldHit()
	return math.random(1, 100) <= SilentAim.hitChance
end

-- Mouse hooks
pcall(function()
	local oldIndex
	oldIndex = hookmetamethod(game, "__index", function(self, key)
		if SilentAim.enabled and self == mouse then
			if key == "Hit" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target then return CFrame.new(target.Position) end
				end
			elseif key == "Target" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target then return target end
				end
			end
		end
		return oldIndex(self, key)
	end)
end)

-- Raycast hooks
pcall(function()
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		
		if SilentAim.enabled and self == workspace then
			if method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target then
						if method == "Raycast" and args[1] and args[2] then
							local origin = args[1]
							local newDir = (target.Position - origin).Unit * 1000
							return oldNamecall(self, origin, newDir, unpack(args, 3))
						elseif args[1] and typeof(args[1]) == "Ray" then
							local origin = args[1].Origin
							local newDir = (target.Position - origin).Unit * 1000
							local newRay = Ray.new(origin, newDir)
							return oldNamecall(self, newRay, unpack(args, 2))
						end
					end
				end
			end
		end
		
		return oldNamecall(self, ...)
	end)
end)

return SilentAim
