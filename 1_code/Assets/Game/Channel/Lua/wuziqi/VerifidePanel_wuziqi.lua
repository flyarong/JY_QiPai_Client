local basefunc = require "Game.Common.basefunc"

VerifidePanel_wuziqi = basefunc.class()
local C = VerifidePanel_wuziqi
C.name = "VerifidePanel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    local ui = base_self.transform:Find("ImgCenter/Image/Image (1)")
	if IsEquals(ui) then
        ui.transform.localPosition = Vector3.zero
    end
    ui = base_self.transform:Find("ImgCenter/Image/Image (2)")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
    end
    ui = base_self.transform:Find("ImgCenter/Image/Image (3)")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
    end
    ui = nil
end

return C.HandleInit