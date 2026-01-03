local TweenService = game:GetService("TweenService")

local Animations = {}

function Animations.tween(obj, time, props, style)
    local info = TweenInfo.new(
        time or 0.15,
        style or Enum.EasingStyle.Quad,
        Enum.EasingDirection.Out
    )
    TweenService:Create(obj, info, props):Play()
end

return Animations
