local basefunc = require "Game.Common.basefunc"

GameActivityModel_caiyunmj_yyb_main = basefunc.class()
local C = GameActivityModel_caiyunmj_yyb_main
C.name = "GameActivityModel_caiyunmj_yyb_main"

function C.HandleInit(base)
	if not base then return end
	local channel = MainModel.UserInfo.channel_type
	if channel == "yyb_qq" then 
		if base.UIConfig then
			if base.UIConfig.config_map[47] then
				base.UIConfig.config_map[47].isOnOff = 0
			end
			if base.UIConfig.config_key_map["gzyl"] then
				base.UIConfig.config_key_map["gzyl"].isOnOff = 0
			end
		end
	end
end

return C.HandleInit
