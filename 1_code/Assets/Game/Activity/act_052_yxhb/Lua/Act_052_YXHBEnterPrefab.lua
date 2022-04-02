-- 创建时间:2021-02-22
-- Panel:Act_052_YXHBEnterPrefab
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

Act_052_YXHBEnterPrefab = basefunc.class()
local C = Act_052_YXHBEnterPrefab
local M = Act_052_YXHBManager
C.name = "Act_052_YXHBEnterPrefab"

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
	self.lister["act_052_yxhb_out_time"] = basefunc.handler(self, self.on_act_052_yxhb_out_time)
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.remain_timer then
		self.remain_timer:Stop()
	end
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
	self.act_end_time = M.GetActEndTime()
	self:InitUI()

	self.transform:GetComponent("Button").onClick:AddListener(function ()
		self:EnterPanel()
	end)

	if string.find(parent.name , "@right_node2") or string.find(parent.name , "@tr_btn_2") then
		obj.name = "Act_052_YXHBEnterPrefab_1"
	end

	self.remain_timer = Timer.New(function()
		if os.time() > self.act_end_time then
			self:MyExit()
		end
	end, 15, -1)
	self.remain_timer:Start()

end

function C:EnterPanel()
	dump("<color=white>打开迎新红包</color>")
	Act_052_YXHBPanel.Create()
	dump(os.time())
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

	--self:CheckIsInTime()
	if M.Hint() then
		self.LFL.gameObject:SetActive(true)
	else
		self.LFL.gameObject:SetActive(false)
	end
end

function C:on_act_052_yxhb_out_time()
	self:CheckIsInTime()
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == M.key then 
		self:MyRefresh()
	end 
end

function C:CheckIsInTime()
	if os.time() > self.act_end_time then
		self:MyExit()
	end
end
