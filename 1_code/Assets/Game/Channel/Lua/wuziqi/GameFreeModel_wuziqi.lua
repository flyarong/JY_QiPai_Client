local basefunc = require "Game.Common.basefunc"

GameFreeModel_wuziqi = basefunc.class()
local C = GameFreeModel_wuziqi
C.name = "GameFreeModel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
    GameFreeModel.GotoGameFree = function ()
      GameManager.GotoUI({gotoui = "game_MiniGame"})
    end
end

return C.HandleInit