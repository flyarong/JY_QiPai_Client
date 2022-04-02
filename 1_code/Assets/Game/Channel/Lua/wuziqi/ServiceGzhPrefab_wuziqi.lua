local basefunc = require "Game.Common.basefunc"

ServiceGzhPrefab_wuziqi = basefunc.class()
local C = ServiceGzhPrefab_wuziqi
C.name = "ServiceGzhPrefab_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    base_self.gzh = "彩云新世界"
    base_self:InitUI()
end

return C.HandleInit