local basefunc = require "Game.Common.basefunc"

HallPanel_caiyunmj_yyb_main = basefunc.class()
local C = HallPanel_caiyunmj_yyb_main
C.name = "HallPanel_caiyunmj_yyb_main"

function C.HandleInit(panel)
	if not panel then return end

	local transform = panel.transform
	if not IsEquals(transform) then return end

	panel.hall_btn_18.gameObject:SetActive(false)
	panel.hall_btn_21.gameObject:SetActive(false)
end

return C.HandleInit
