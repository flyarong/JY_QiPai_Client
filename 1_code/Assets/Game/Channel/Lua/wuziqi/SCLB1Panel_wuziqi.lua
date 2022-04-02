local basefunc = require "Game.Common.basefunc"

SCLB1Panel_wuziqi = basefunc.class()
local C = SCLB1Panel_wuziqi
C.name = "SCLB1Panel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    local ui = base_self.transform:Find("Center/Gift1/2/@2_icon_img"):GetComponent("Image")
	if IsEquals(ui) then
        ui.sprite = GetTexture("pay_icon_gold8")
    end
    ui = base_self.transform:Find("Center/Gift1/2/@2_num_txt"):GetComponent("Text")
	if IsEquals(ui) then
		ui.text = "x1000"
    end
    ui = nil
end

return C.HandleInit