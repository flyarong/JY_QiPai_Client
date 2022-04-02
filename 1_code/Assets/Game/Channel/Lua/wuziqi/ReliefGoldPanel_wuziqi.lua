local basefunc = require "Game.Common.basefunc"

ReliefGoldPanel_wuziqi = basefunc.class()
local C = ReliefGoldPanel_wuziqi
C.name = "ReliefGoldPanel_wuziqi"

function C.HandleInit(base_self)
	if not base_self then return end
	if IsEquals(base_self.confirm_txt) then
		base_self.confirm_txt.text = "领取"
	end
	if IsEquals( base_self.confirm_btn) then
		base_self.confirm_btn.onClick:RemoveAllListeners()
		base_self.confirm_btn.onClick:AddListener(function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			Network.SendRequest("broke_subsidy", nil, "请求数据")	
			base_self:MyExit()
		end)
	end
	base_self.ast_data = {{asset_type = "jing_bi", value = 500}}
end

return C.HandleInit