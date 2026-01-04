-- combat/silent_aim.lua
-- Silent Aim with actual working hooks

local Players = game:GetService("Players")
local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local mouse = player:GetMouse()

local SilentAim = {
	enabled = false,
	fov = 150,
	hitChance = 100,
	targetPart = "Head" -- Head, Torso, HumanoidRootPart
}

-- Get closest player in FOV
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

-- Check if should hit based on hit chance
function SilentAim.shouldHit()
	return math.random(1, 100) <= SilentAim.hitChance
end

-- ============================================
-- INSTALL HOOKS
-- ============================================

-- Hook 1: mouse.Hit and mouse.Target
pcall(function()
	local oldIndex
	oldIndex = hookmetamethod(game, "__index", function(self, key)
		if SilentAim.enabled and self == mouse then
			if key == "Hit" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target then
						return CFrame.new(target.Position)
					end
				end
			elseif key == "Target" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target then
						return target
					end
				end
			elseif key == "X" or key == "Y" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target then
						local pos = camera:WorldToViewportPoint(target.Position)
						if key == "X" then
							return pos.X
						else
							return pos.Y
						end
					end
				end
			end
		end
		return oldIndex(self, key)
	end)
	print("[SilentAim] Mouse hooks installed")
end)

-- Hook 2: Raycast methods
pcall(function()
	local oldNamecall
	oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
		local method = getnamecallmethod()
		local args = {...}
		
		if SilentAim.enabled then
			-- workspace:Raycast
			if self == workspace and method == "Raycast" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target and args[1] then
						local origin = args[1]
						local newDirection = (target.Position - origin).Unit * 1000
						return oldNamecall(self, origin, newDirection, unpack(args, 3))
					end
				end
			end
			
			-- workspace:FindPartOnRay
			if self == workspace and method == "FindPartOnRay" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target and args[1] then
						local ray = args[1]
						local origin = ray.Origin
						local newDirection = (target.Position - origin).Unit * 1000
						local newRay = Ray.new(origin, newDirection)
						return oldNamecall(self, newRay, unpack(args, 2))
					end
				end
			end
			
			-- workspace:FindPartOnRayWithIgnoreList
			if self == workspace and method == "FindPartOnRayWithIgnoreList" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target and args[1] then
						local ray = args[1]
						local origin = ray.Origin
						local newDirection = (target.Position - origin).Unit * 1000
						local newRay = Ray.new(origin, newDirection)
						return oldNamecall(self, newRay, unpack(args, 2))
					end
				end
			end
			
			-- workspace:FindPartOnRayWithWhitelist
			if self == workspace and method == "FindPartOnRayWithWhitelist" then
				if SilentAim.shouldHit() then
					local target = SilentAim.getTarget()
					if target and args[1] then
						local ray = args[1]
						local origin = ray.Origin
						local newDirection = (target.Position - origin).Unit * 1000
						local newRay = Ray.new(origin, newDirection)
						return oldNamecall(self, newRay, unpack(args, 2))
					end
				end
			end
		end
		
		return oldNamecall(self, ...)
	end)
	print("[SilentAim] Raycast hooks installed")
end)

-- Hook 3: Remote events/functions (for some games)
pcall(function()
	local oldFireServer
	oldFireServer = hookfunction(Instance.new("RemoteEvent").FireServer, function(self, ...)
		local args = {...}
		
		if SilentAim.enabled and SilentAim.shouldHit() then
			local target = SilentAim.getTarget()
			if target then
				-- Try to find and replace position/cframe arguments
				for i, arg in ipairs(args) do
					if typeof(arg) == "CFrame" then
						args[i] = CFrame.new(target.Position)
					elseif typeof(arg) == "Vector3" then
						-- Check if it looks like a position (not too far from player)
						local char = player.Character
						if char and char:FindFirstChild("HumanoidRootPart") then
							local dist = (arg - char.HumanoidRootPart.Position).Magnitude
							if dist < 500 then -- Likely a target position
								args[i] = target.Position
							end
						end
					end
				end
			end
		end
		
		return oldFireServer(self, unpack(args))
	end)
	print("[SilentAim] Remote hooks installed")
end)

return SilentAim
