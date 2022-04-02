local basefunc = require "Game.Common.basefunc"

CPL_LJYJCFK_CJXXLPrefab_wuziqi = basefunc.class()
local C = CPL_LJYJCFK_CJXXLPrefab_wuziqi
C.name = "CPL_LJYJCFK_CJXXLPrefab_wuziqi"

function C.HandleInit(base_self)
	if not base_self then return end
	base_self.RefreshHintText = function (base_self,data,level,hb)
		local re = basefunc.parse_activity_data(data.other_data_str)
		if tonumber(re.is_first_game) == 1 and data.now_lv == 1 then   
			base_self.hint_txt.text = string.format("再赢金<color=#fffd00ff>%s</color>，可抽取<color=#fffd00ff>%s福卡！</color>", StringHelper.ToCash((data.need_process - data.now_process) / 30),hb)	
		else 
			base_self.hint_txt.text = string.format("再赢金<color=#fffd00ff>%s</color>，可抽取<color=#fffd00ff>%s福卡！</color>", StringHelper.ToCash(data.need_process - data.now_process),hb)	
		end
	end
	base_self.MyRefresh(base_self)
end

return C.HandleInit