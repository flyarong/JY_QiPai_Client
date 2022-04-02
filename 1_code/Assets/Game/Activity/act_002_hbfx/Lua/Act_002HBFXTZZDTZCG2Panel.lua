-- 创建时间:2020-03-09
-- Panel:Act_002HBFXTZZDTZCG2Panel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 --]]

local basefunc = require "Game/Common/basefunc"

Act_002HBFXTZZDTZCG2Panel = basefunc.class()
local C = Act_002HBFXTZZDTZCG2Panel
C.name = "Act_002HBFXTZZDTZCG2Panel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv3").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.hb_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			HintPanel.Create(1,"您的现金福卡已存入到您的钱包中，请记得活动结束前进行提现",function ()
				self:MyExit()
				Act_002HBFXWalletPanel.Create()
			end)	
		end
	)
	self.tx_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			MainModel.GetBindZFB(function(  )
				if table_is_null(MainModel.UserInfo.zfbData) or MainModel.UserInfo.zfbData.name == "" then
					LittleTips.Create("请先绑定支付宝")
					GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
				else
					HintPanel.Create(2,"一共"..(GameItemModel.GetItemCount("prop_npca_hb")/100).."元福卡,确认提现吗？",function ()
						Network.SendRequest("withdraw_npca_hb",{hb = GameItemModel.GetItemCount("prop_npca_hb")/100})
					end)
				end
			end)	
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end
