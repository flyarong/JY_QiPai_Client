local basefunc = require "Game.Common.basefunc"

SYSVip2UpPanel_wuziqi = basefunc.class()
local C = SYSVip2UpPanel_wuziqi
C.name = "SYSVip2UpPanel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
	local ui = base_self.tips_rect
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
	end
end

return C.HandleInit