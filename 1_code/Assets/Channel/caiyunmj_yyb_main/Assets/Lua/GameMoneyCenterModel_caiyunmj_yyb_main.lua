local basefunc = require "Game.Common.basefunc"
GameMoneyCenterModel_caiyunmj_yyb_main = basefunc.class()
local C = GameMoneyCenterModel_caiyunmj_yyb_main
C.name = "GameMoneyCenterModel_caiyunmj_yyb_main"

function C.HandleInit()
	if not GameMoneyCenterModel then return end
	GameMoneyCenterModel.CheckIsNewPlayerSys = function(  )
        return false
    end
end

return C.HandleInit