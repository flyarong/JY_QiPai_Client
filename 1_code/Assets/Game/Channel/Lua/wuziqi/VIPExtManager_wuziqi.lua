local basefunc = require "Game.Common.basefunc"

VIPExtManager_wuziqi = basefunc.class()
local C = VIPExtManager_wuziqi
C.name = "VIPExtManager_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    base_self.IsCanUpLevel = function(  )
        return false
    end
end

return C.HandleInit