-- utils/raycast.lua
-- Visibility / line-of-sight helpers. Uses modern Raycast API when available,
-- falls back to FindPartOnRayWithIgnoreList for compatibility.

local RaycastUtils = {}
local Workspace = game:GetService("Workspace")

-- Build RaycastParams from an ignore list (array of Instances)
local function buildParams(ignoreList, includeDescendants)
	local params = RaycastParams.new()
	if type(ignoreList) == "table" and #ignoreList > 0 then
		params.FilterType = Enum.RaycastFilterType.Blacklist
		params.FilterDescendantsInstances = ignoreList
	else
		params.FilterType = Enum.RaycastFilterType.Whitelist
		params.FilterDescendantsInstances = {}
	end
	-- allow front/back by default
	params.IgnoreWater = true
	-- allow user to specify inclusion of descendants via param; default false
	if includeDescendants then
		-- no extra behavior needed, FilterDescendantsInstances already works
	end
	return params
end

-- Perform a raycast between originVec and targetVec. Returns the raycast result or nil.
function RaycastUtils.raycast(originVec, targetVec, ignoreList, maxDistance)
	local direction = (targetVec - originVec)
	if maxDistance and direction.Magnitude > maxDistance then
		-- shorten direction
		direction = direction.Unit * maxDistance
	end

	-- Prefer Raycast if available
	local ok, result
	local success, err = pcall(function()
		local params = buildParams(ignoreList)
		result = Workspace:Raycast(originVec, direction, params)
	end)
	if success then
		return result
	end

	-- Fallback to legacy Ray
	local ray = Ray.new(originVec, direction)
	local hit, position = Workspace:FindPartOnRayWithIgnoreList(ray, ignoreList or {}, false, true)
	if hit then
		return {Instance = hit, Position = position}
	end

	return nil
end

-- Returns true if there is a clear line of sight from originVec to targetVec.
-- ignoreList: array of instances to ignore (e.g., local character)
-- optional maxDistance to early-out.
function RaycastUtils.lineOfSight(originVec, targetVec, ignoreList, maxDistance)
	local res = RaycastUtils.raycast(originVec, targetVec, ignoreList, maxDistance)
	if not res then
		-- nothing hit -> unobstructed
		return true
	end

	-- If using new API, result.Instance exists and result.Position
	if res.Instance then
		-- If the hit instance is the same as the target's descendant, consider visible.
		-- The caller can pass an ignoreList that excludes the target character; simple boolean:
		return false
	end

	-- Legacy fallback structure: if hit returned then obstructed
	return false
end

-- Helper: can we see the part from the camera position.
-- targetPart must be a BasePart (Head, HumanoidRootPart, etc.)
function RaycastUtils.canSeePart(targetPart, originVec, ignoreList, maxDistance)
	if not targetPart or not targetPart.Position then return false end
	ignoreList = ignoreList or {}
	-- If the caller didn't include the target's descendants in the ignored list, we still want to know whether the hit part belongs to the target.
	local res = RaycastUtils.raycast(originVec, targetPart.Position, ignoreList, maxDistance)
	if not res then
		return true
	end

	-- If using new API, res.Instance is the hit part
	if res.Instance then
		-- if the hit instance is descendant of the targetPart.Parent (the character), it's visible
		if res.Instance:IsDescendantOf(targetPart.Parent) then
			return true
		else
			return false
		end
	end

	-- Legacy fallback (table with Instance/Position) handled above
	return false
end

return RaycastUtils

