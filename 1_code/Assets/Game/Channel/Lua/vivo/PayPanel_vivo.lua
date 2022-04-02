local basefunc = require "Game.Common.basefunc"

PayPanel_wuziqi = basefunc.class()
local C = PayPanel_wuziqi
C.name = "PayPanel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    base_self.top_node.gameObject:SetActive(false)
end

return C.HandleInit