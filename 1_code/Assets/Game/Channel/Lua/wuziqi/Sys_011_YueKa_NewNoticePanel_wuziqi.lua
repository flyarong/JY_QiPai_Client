-- 创建时间:2020-12-08
local basefunc = require "Game.Common.basefunc"

Sys_011_YueKa_NewNoticePanel_wuziqi = basefunc.class()
local C = Sys_011_YueKa_NewNoticePanel_wuziqi
C.name = "Sys_011_YueKa_NewNoticePanel_wuziqi"

local vip_jjj_award = {
	4000,5000,6000,7000,8000,9000,10000,12000,14000,20000,20000,20000
}
function C.HandleInit(base_self)
	if not base_self then return end
	local v_l = VIPManager.get_vip_level()
    base_self.normal_txt.text = (vip_jjj_award[v_l] or 500).."鲸币"
	base_self.yueka_txt.text = (8888+(vip_jjj_award[v_l] or 500)).."鲸币"
end

return C.HandleInit