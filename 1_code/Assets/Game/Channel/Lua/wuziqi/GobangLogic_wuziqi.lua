local basefunc = require "Game.Common.basefunc"

GobangLogic_wuziqi = basefunc.class()
local C = GobangLogic_wuziqi
C.name = "GobangLogic_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    GobangLogic.GotoHall = function ()
      GameManager.GotoUI({gotoui = "game_MiniGame"})
    end
end

return C.HandleInit