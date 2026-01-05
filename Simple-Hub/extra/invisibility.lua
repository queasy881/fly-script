-- ============================================================================
-- VERTEX HUB - STABLE HITBOX INVISIBILITY (VISUAL CLONE METHOD)
-- Loadstring safe | No script.Parent | No require
-- ============================================================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local InvisSystem = {}
InvisSystem.__index = InvisSystem

-- ============================================================================
-- STATE
-- ============================================================================
InvisSystem.Enabled = false
InvisSystem.VisualClone = nil
InvisSystem.Connection = nil
InvisSystem.Offset = 100

-- ============================================================================
-- HELPERS
-- ============================================================================
local function getCharacter()
	return player.Character
end

local function getRoot()
	local c = getCharacter()
	return c and c:FindFirstChild("HumanoidRootPart")
end

-- ============================================================================
-- CREATE VISUAL CLONE
-- ============================================================================
local function createVisualClone(offset)
	local char = getCharacter()
	local root = getRoot()
	if not char or not root then return nil end

	local clone = char:Clone()
	clone.Name = "VertexVisualClone"

	-- Remove scripts & humanoid from clone
	for _, v in ipairs(clone:GetDescendants()) do
		if v:IsA("Script") or v:IsA("LocalScript") then
			v:Destroy()
		elseif v:IsA("Humanoid") then
			v:Destroy()
		elseif v:IsA("BasePart") then
			v.Anchored = true
			v.CanCollide = false
			v.CastShadow = false
		end
	end

	clone.Parent = workspace

	-- Initial position
	clone:SetPrimaryPartCFrame(
		root.CFrame * CFrame.new(0, offset, 0)
	)

	return clone
end

-- ============================================================================
-- ENABLE
-- ============================================================================
function InvisSystem:Enable(State)
	if self.Enabled then return end

	local root = getRoot()
	if not root then return end

	self.Enabled = true
	self.Offset = (State and State.Player and State.Player.InvisOffset) or 100

	-- Create visual clone
	self.VisualClone = createVisualClone(self.Offset)
	if not self.VisualClone then
		self.Enabled = false
		return
	end

	-- Keep visual clone synced (WITHOUT TOUCHING REAL CHARACTER)
	self.Connection = RunService.RenderStepped:Connect(function()
		if not self.Enabled then return end
		if not self.VisualClone or not self.VisualClone.Parent then return end

		local r = getRoot()
		if not r then return end

		self.VisualClone:SetPrimaryPartCFrame(
			r.CFrame * CFrame.new(0, self.Offset, 0)
		)
	end)

	print("[Invisibility] Enabled (visual clone mode)")
end

-- ============================================================================
-- DISABLE
-- ============================================================================
function InvisSystem:Disable()
	if not self.Enabled then return end
	self.Enabled = false

	if self.Connection then
		self.Connection:Disconnect()
		self.Connection = nil
	end

	if self.VisualClone then
		self.VisualClone:Destroy()
		self.VisualClone = nil
	end

	print("[Invisibility] Disabled")
end

-- ============================================================================
-- UPDATE OFFSET LIVE
-- ============================================================================
function InvisSystem:SetOffset(v)
	self.Offset = tonumber(v) or self.Offset
end

-- ============================================================================
-- STATUS
-- ============================================================================
function InvisSystem:IsEnabled()
	return self.Enabled
end

-- ============================================================================
-- EXPORT
-- ============================================================================
_G.VertexInvisibility = InvisSystem
return InvisSystem
