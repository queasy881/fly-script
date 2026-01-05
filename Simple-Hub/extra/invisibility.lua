-- ===========================================================================
-- VERTEX HUB - DESYNC INVISIBILITY
-- File: DesyncInvis.lua
-- ===========================================================================
-- PROPERTIES:
-- ❌ NO Transparency changes (not using Transparency = 1)
-- ❌ NO destroying parts
-- ❌ NO breaking hit detection
-- ✅ Real hitbox (HumanoidRootPart) stays at real position
-- ✅ Visual model moves ~100+ studs away
-- ✅ Camera stays locked to real hitbox position
-- ✅ Server registers hits correctly
-- ✅ KillAura continues to work normally
-- ✅ Animations preserved
-- ===========================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local DesyncInvis = {}
DesyncInvis.__index = DesyncInvis

-- ===========================================================================
-- STATE
-- ===========================================================================
DesyncInvis.enabled = false
DesyncInvis.visualOffset = Vector3.new(0, 100, 0)
DesyncInvis.connections = {}
DesyncInvis.relativeCFrames = {}
DesyncInvis.originalAutoRotate = true

-- Parts that define the HITBOX (stay at real position - server sees these)
DesyncInvis.hitboxParts = {
	"HumanoidRootPart"
}

-- ===========================================================================
-- UTILITY FUNCTIONS
-- ===========================================================================
local function getCharacter()
	return player.Character
end

local function getRoot()
	local char = getCharacter()
	return char and char:FindFirstChild("HumanoidRootPart")
end

local function getHumanoid()
	local char = getCharacter()
	return char and char:FindFirstChildOfClass("Humanoid")
end

local function isHitboxPart(partName)
	for _, name in ipairs(DesyncInvis.hitboxParts) do
		if partName == name then
			return true
		end
	end
	return false
end

-- ===========================================================================
-- GET ALL VISUAL PARTS (Everything except hitbox parts)
-- ===========================================================================
function DesyncInvis.GetVisualParts()
	local char = getCharacter()
	if not char then return {} end
	
	local parts = {}
	for _, obj in ipairs(char:GetDescendants()) do
		if obj:IsA("BasePart") and not isHitboxPart(obj.Name) then
			table.insert(parts, obj)
		end
	end
	return parts
end

-- ===========================================================================
-- STORE RELATIVE POSITIONS OF ALL PARTS
-- ===========================================================================
function DesyncInvis.StoreRelativePositions()
	local root = getRoot()
	if not root then return end
	
	DesyncInvis.relativeCFrames = {}
	
	for _, part in ipairs(DesyncInvis.GetVisualParts()) do
		-- Store each part's position RELATIVE to HumanoidRootPart
		DesyncInvis.relativeCFrames[part] = root.CFrame:ToObjectSpace(part.CFrame)
	end
end

-- ===========================================================================
-- ENABLE DESYNC INVISIBILITY
-- ===========================================================================
function DesyncInvis.Enable(State)
	local char = getCharacter()
	local root = getRoot()
	local humanoid = getHumanoid()
	local camera = workspace.CurrentCamera
	
	if not char or not root or not humanoid then
		warn("[DesyncInvis] No character available")
		return false
	end
	
	-- Disable if already running
	if DesyncInvis.enabled then
		DesyncInvis.Disable()
	end
	
	DesyncInvis.enabled = true
	
	-- Get offset from State or use default
	local offset = 100
	if State and State.Player and State.Player.InvisOffset then
		offset = State.Player.InvisOffset
	end
	DesyncInvis.visualOffset = Vector3.new(0, offset, 0)
	
	-- Store relative positions
	DesyncInvis.StoreRelativePositions()
	
	-- Store and disable auto-rotate (prevents visual snapping)
	DesyncInvis.originalAutoRotate = humanoid.AutoRotate
	humanoid.AutoRotate = false
	
	-- ===========================================================================
	-- MAIN DESYNC LOOP (Heartbeat - runs on physics step)
	-- ===========================================================================
	local heartbeatConn = RunService.Heartbeat:Connect(function(deltaTime)
		if not DesyncInvis.enabled then return end
		
		local hrp = getRoot()
		local char = getCharacter()
		
		if not hrp or not char then
			DesyncInvis.Disable()
			return
		end
		
		-- HumanoidRootPart stays at REAL position (this is the hitbox)
		-- The server only cares about HumanoidRootPart for hit registration
		
		-- Move all VISUAL parts away from the real position
		for part, relativeCFrame in pairs(DesyncInvis.relativeCFrames) do
			if part and part.Parent then
				-- Calculate where part SHOULD be (relative to real root position)
				local realPosition = hrp.CFrame * relativeCFrame
				
				-- Apply offset to move visual away
				local offsetPosition = CFrame.new(DesyncInvis.visualOffset) * realPosition
				
				-- Set the visual part's position
				pcall(function()
					part.CFrame = offsetPosition
				end)
			end
		end
	end)
	table.insert(DesyncInvis.connections, heartbeatConn)
	
	-- ===========================================================================
	-- CAMERA CONTROL (RenderStepped - runs before render)
	-- ===========================================================================
	local renderConn = RunService.RenderStepped:Connect(function(deltaTime)
		if not DesyncInvis.enabled then return end
		
		local cam = workspace.CurrentCamera
		local hum = getHumanoid()
		
		-- Ensure camera follows the Humanoid (which follows HumanoidRootPart)
		-- Since HumanoidRootPart isn't moved, camera stays at real position
		if cam and hum and cam.CameraSubject ~= hum then
			cam.CameraSubject = hum
		end
	end)
	table.insert(DesyncInvis.connections, renderConn)
	
	-- ===========================================================================
	-- HANDLE NEW PARTS (When accessories load, etc)
	-- ===========================================================================
	local descendantConn = char.DescendantAdded:Connect(function(obj)
		if not DesyncInvis.enabled then return end
		
		if obj:IsA("BasePart") and not isHitboxPart(obj.Name) then
			local root = getRoot()
			if root then
				-- Store relative position of new part
				task.wait() -- Wait for part to be positioned
				DesyncInvis.relativeCFrames[obj] = root.CFrame:ToObjectSpace(obj.CFrame)
			end
		end
	end)
	table.insert(DesyncInvis.connections, descendantConn)
	
	-- ===========================================================================
	-- HANDLE CHARACTER RESPAWN
	-- ===========================================================================
	local respawnConn = player.CharacterAdded:Connect(function(newChar)
		DesyncInvis.Disable()
	end)
	table.insert(DesyncInvis.connections, respawnConn)
	
	print("[DesyncInvis] Enabled - Offset: " .. tostring(offset) .. " studs")
	print("[DesyncInvis] Hitbox stays at real position, visuals moved away")
	return true
end

-- ===========================================================================
-- DISABLE DESYNC INVISIBILITY
-- ===========================================================================
function DesyncInvis.Disable()
	if not DesyncInvis.enabled then return end
	
	DesyncInvis.enabled = false
	
	-- Disconnect all connections
	for _, conn in ipairs(DesyncInvis.connections) do
		if conn then
			pcall(function() conn:Disconnect() end)
		end
	end
	DesyncInvis.connections = {}
	
	-- Restore character
	local char = getCharacter()
	local root = getRoot()
	local humanoid = getHumanoid()
	
	-- Restore auto-rotate
	if humanoid then
		humanoid.AutoRotate = DesyncInvis.originalAutoRotate
	end
	
	-- Restore visual parts to correct positions
	if root then
		for part, relativeCFrame in pairs(DesyncInvis.relativeCFrames) do
			if part and part.Parent then
				pcall(function()
					part.CFrame = root.CFrame * relativeCFrame
				end)
			end
		end
	end
	
	-- Clear stored data
	DesyncInvis.relativeCFrames = {}
	
	print("[DesyncInvis] Disabled - Character restored")
end

-- ===========================================================================
-- UPDATE OFFSET (Can be called while enabled)
-- ===========================================================================
function DesyncInvis.SetOffset(offset)
	DesyncInvis.visualOffset = Vector3.new(0, offset, 0)
end

-- ===========================================================================
-- CHECK IF ENABLED
-- ===========================================================================
function DesyncInvis.IsEnabled()
	return DesyncInvis.enabled
end

-- ===========================================================================
-- GET REAL POSITION (For combat systems - returns hitbox position)
-- ===========================================================================
function DesyncInvis.GetRealPosition()
	local root = getRoot()
	return root and root.Position or nil
end

-- ===========================================================================
-- GET REAL CFRAME (For combat systems)
-- ===========================================================================
function DesyncInvis.GetRealCFrame()
	local root = getRoot()
	return root and root.CFrame or nil
end

-- ===========================================================================
-- TOGGLE
-- ===========================================================================
function DesyncInvis.Toggle(State)
	if DesyncInvis.enabled then
		DesyncInvis.Disable()
	else
		DesyncInvis.Enable(State)
	end
	return DesyncInvis.enabled
end

-- ===========================================================================
-- COMPATIBILITY NOTES
-- ===========================================================================
--[[
This desync invisibility works with KillAura and other combat systems because:

1. HumanoidRootPart (the hitbox) NEVER moves from the real position
2. Server hit detection uses HumanoidRootPart position
3. Tool:Activate() fires from HumanoidRootPart position
4. Raycasts hit the real HumanoidRootPart
5. Touch events register on HumanoidRootPart

The visual model (Head, Torso, Arms, Legs, etc.) moves far away,
but the server doesn't care about those for combat - only HumanoidRootPart matters.

Camera stays focused on the real position because:
1. Camera.CameraSubject = Humanoid
2. Humanoid's position is tied to HumanoidRootPart
3. HumanoidRootPart stays at real position
]]

-- Export
_G.VertexDesyncInvis = DesyncInvis
return DesyncInvis
