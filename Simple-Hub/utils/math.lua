-- utils/math.lua
-- Math utilities used across Simple Hub
-- SAFE: no vararg misuse, no globals, no side effects

local Math = {}

-- Clamp a number between min and max
function Math.clamp(value, min, max)
	if value < min then return min end
	if value > max then return max end
	return value
end

-- Linear interpolation
function Math.lerp(a, b, t)
	return a + (b - a) * t
end

-- Vector3 linear interpolation
function Math.lerpVector(a, b, t)
	return a:Lerp(b, t)
end

-- Distance between two Vector3 positions
function Math.distance(a, b)
	return (a - b).Magnitude
end

-- Round to N decimal places
function Math.round(num, decimals)
	decimals = decimals or 0
	local mult = 10 ^ decimals
	return math.floor(num * mult + 0.5) / mult
end

-- Map value from one range to another
function Math.map(value, inMin, inMax, outMin, outMax)
	if inMax - inMin == 0 then return outMin end
	return outMin + (value - inMin) * (outMax - outMin) / (inMax - inMin)
end

-- Check if a screen point is inside a circular FOV
function Math.isInCircle(point, center, radius)
	return (point - center).Magnitude <= radius
end

-- Safe random float
function Math.randomFloat(min, max)
	return min + math.random() * (max - min)
end

return Math
