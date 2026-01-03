-- extra/fake_death.lua

local FakeDeath = {}

FakeDeath.enabled = false

function FakeDeath.apply(character, humanoid)
	if FakeDeath.enabled then
		humanoid.PlatformStand = true
	else
		humanoid.PlatformStand = false
	end
end

return FakeDeath
