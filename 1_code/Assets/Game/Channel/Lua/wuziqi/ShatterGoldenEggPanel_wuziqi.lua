-- 创建时间:2020-12-08
local basefunc = require "Game.Common.basefunc"

ShatterGoldenEggPanel_wuziqi = basefunc.class()
local C = ShatterGoldenEggPanel_wuziqi
C.name = "ShatterGoldenEggPanel_wuziqi"

function C.HandleInit(base_self)
	if not base_self then return end
    base_self.back_btn.onClick:RemoveAllListeners()
    base_self.back_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
        local hint = HintPanel.Create(4, "好运马上就来，您确定现在离开么？", function ()
            Event.Brocast("ZJDQuit")
            Network.SendRequest("zajindan_quit_game")
        end)
        hint:SetBtnTitle("确  定", "取  消")
    end)
	--base_self.MyRefresh(base_self)
end

return C.HandleInit