-- 创建时间:2021-04-06
-- Panel:RCRWPanel
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
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

RCRWPanel = basefunc.class()
local C = RCRWPanel
local M = SYSRCRWManager
C.name = "RCRWPanel"

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["model_rcrw_task_change"] = basefunc.handler(self,self.on_model_rcrw_task_change)
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

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:UpdataData()
	self:InitUI()

end

function C:InitUI()

	self.refresh_btn.onClick:AddListener(function() 
		self.RefreshTask()
	end)
	self.get_btn.onClick:AddListener(function() 
		self.GetTaskAward()
	end)

	self:MyRefresh()
end

function C:MyRefresh()

end

function C:on_model_rcrw_task_change()
	self:UpdataData()
	self:RefreshTaskUI()
end

function C:UpdataData()
	self.data = M.GetCurTaskData()
	self.cfg = M.GetCurTaskCfg()
end

function C:RefreshTaskUI()
	self.target_txt.text = self.cfg.task_content .. "(<color=#34f3ff>" .. self.data.now_total_process .. "/" .. self.data.need_process .. "</color>)"
	self.award_txt.text = self.cfg.award
end

function C:RefreshTask()
	Network.SendRequest("refresh_rcrw_task")
end

function C:GetTaskAward()
	if MainModel.UserInfo.jing_bi < 500 then
		LittleTips.Create("鲸币不足")
		return
	end
	Network.SendRequest("get_task_award",{id = self.data.task_id})
end
