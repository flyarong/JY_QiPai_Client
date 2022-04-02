-- 创建时间:2020-03-09
-- Panel:Act_002HBFXSUCCPanel
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

Act_002HBFXSUCCPanel = basefunc.class()
local C = Act_002HBFXSUCCPanel
C.name = "Act_002HBFXSUCCPanel"

function C.Create(panelSelf)
	return C.New(panelSelf)
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

function C:ctor(panelSelf)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.panelSelf = panelSelf
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	if Act_002HBFXManager.getMasterInfo() then 
		self.tips_txt.text = "等待好友玩家 【"..Act_002HBFXManager.getMasterInfo().name.."】 再邀请一位还有挑战成功"
	end 
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
		end
	)
	self.go_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "panel",share_cfg = share_link_config.img_yql48})
			self:MyExit()
		end
	)
	self.cancel_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			local backcall = basefunc.handler(self.panelSelf, self.panelSelf.OnBackClick)
			GameButtonManager.RunFun({gotoui="sys_act_operator",showHint = true,callback = callback}, "CanLeaveGameBeforeEnd")
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end
