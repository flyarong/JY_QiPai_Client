local basefunc = require "Game.Common.basefunc"

VIPEnterPrefab_wuziqi = basefunc.class()
local C = VIPEnterPrefab_wuziqi
C.name = "VIPEnterPrefab_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    local ui = base_self.vip2_red
	if IsEquals(ui) then
        ui.transform:GetComponent("Image").enabled = false
    end
    ui = base_self.vipnotice
	if IsEquals(ui) then
		ui.transform:GetComponent("Image").enabled = false
    end
    ui = base_self.transform:Find("@vipnotice/Text")
	if IsEquals(ui) then
		ui.gameObject:SetActive(false)
    end
    ui = nil
end

return C.HandleInit