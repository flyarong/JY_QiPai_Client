local basefunc = require "Game.Common.basefunc"

BannerModel_caiyunmj_yyb_main = basefunc.class()
local C = BannerModel_caiyunmj_yyb_main
C.name = "BannerModel_caiyunmj_yyb_main"

function C.HandleInit(base)
	if not base then return end
	local channel = MainModel.UserInfo.channel_type
	dump(channel, "<color=blue>MainModel.UserInfo.channel_type</color>")
	if channel == "yyb_qq" then 
		if base.UIConfig and base.UIConfig.hallconfig and base.UIConfig.hallconfig[47] then
			base.UIConfig.hallconfig[47].isOnOff = 0
		end
	end
end

return C.HandleInit
