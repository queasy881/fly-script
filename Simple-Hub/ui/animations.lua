local TweenService = game:GetService("TweenService")

local Anim = {}

function Anim.tween(obj, time, props, style)
    TweenService:Create(
        obj,
        TweenInfo.new(time or 0.18, style or Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        props
    ):Play()
end

return Anim
