local basefunc = require "Game.Common.basefunc"

SYSVip3UpPanel_wuziqi = basefunc.class()
local C = SYSVip3UpPanel_wuziqi
C.name = "SYSVip3UpPanel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    SYSVip3UpPanel.ShowDesc = function(  )
        GameTipsPrefab.ShowDesc("52万鲸币+3-50福卡+50话费碎片", UnityEngine.Input.mousePosition)
    end
    if IsEquals(base_self.tips_rect) then
        base_self.tips_rect.gameObject:SetActive(false)
    end
end

return C.HandleInit