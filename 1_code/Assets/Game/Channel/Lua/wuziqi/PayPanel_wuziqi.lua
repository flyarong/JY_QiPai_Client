local basefunc = require "Game.Common.basefunc"

PayPanel_wuziqi = basefunc.class()
local C = PayPanel_wuziqi
C.name = "PayPanel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    base_self:SwitchTge(GOODS_TYPE.jing_bi)
    if IsEquals(base_self.tge_item_table[GOODS_TYPE.item].gameObject) then
        base_self.tge_item_table[GOODS_TYPE.item].gameObject:SetActive(false)
    end
end

return C.HandleInit