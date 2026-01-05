-- settings/presets.lua
-- SAFE PRESET SYSTEM (NO UI ASSUMPTIONS)

local State = _G.VertexState
local Toggles = _G.VertexToggleRefs

if not State or not Toggles then
	warn("[PRESETS] State or ToggleRefs missing")
	return
end

local Presets = {}

-- ============================================================
-- HELPER: APPLY STATE + SYNC UI
-- ============================================================
local function applyPreset(data)
	for category, values in pairs(data) do
		if State[category] then
			for key, value in pairs(values) do
				if State[category][key] ~= nil then
					State[category][key] = value
				end

				-- sync UI if toggle exists
				local toggle = Toggles[key]
				if toggle and toggle.UpdateState then
					toggle.UpdateState(value)
				end
			end
		end
	end
end

-- ============================================================
-- PRESETS
-- ============================================================

Presets.Legit = {
	Combat = {
		AimAssist = true,
		SilentAim = false,
		ShowFOVCircle = true,
	},
	Movement = {
		Fly = false,
		Noclip = false,
	},
	Misc = {
		Watermark = true,
		FPSCounter = false,
	}
}

Presets.Rage = {
	Combat = {
		AimAssist = true,
		SilentAim = true,
		ShowFOVCircle = true,
	},
	Movement = {
		Fly = true,
		Noclip = true,
	},
	Misc = {
		Watermark = false,
		FPSCounter = true,
	}
}

-- ============================================================
-- PUBLIC API
-- ============================================================
function Presets.Apply(name)
	local preset = Presets[name]
	if not preset then
		warn("[PRESETS] Unknown preset:", name)
		return
	end

	applyPreset(preset)
	print("[PRESETS] Applied:", name)
end

_G.VertexPresets = Presets

print("[PRESETS] Loaded successfully")
