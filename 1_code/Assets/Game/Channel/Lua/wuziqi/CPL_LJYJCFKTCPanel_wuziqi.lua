local basefunc = require "Game.Common.basefunc"

CPL_LJYJCFKTCPanel_wuziqi = basefunc.class()
local C = CPL_LJYJCFKTCPanel_wuziqi
C.name = "CPL_LJYJCFKTCPanel_wuziqi"

function C.HandleInit(base_self)
    if not base_self then return end
	base_self.RefreshNeedText = function (base_self)
		local re = basefunc.parse_activity_data(base_self.task_data.other_data_str)
		if tonumber(re.is_first_game) == 1 and base_self.task_data.now_lv == 1 then   
			base_self.need_txt.text = StringHelper.ToCash((base_self.task_data.need_process - base_self.task_data.now_process)/30)
		else 
			base_self.need_txt.text = StringHelper.ToCash(base_self.task_data.need_process - base_self.task_data.now_process)
		end
	end
	base_self.MyRefresh(base_self)
end

return C.HandleInit