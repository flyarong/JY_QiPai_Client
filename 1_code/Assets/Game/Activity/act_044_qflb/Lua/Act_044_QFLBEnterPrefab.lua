-- 创建时间:2020-07-17
-- Panel:Act_044_QFLBEnterPrefab
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

Act_044_QFLBEnterPrefab = basefunc.class()
local C = Act_044_QFLBEnterPrefab
C.name = "Act_044_QFLBEnterPrefab"
local M = Act_044_QFLBManager

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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["QFLBManager_on_gift_bag_status_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["QFLBManager_on_model_task_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["QFLB_Task_Data_is_Query_msg"] = basefunc.handler(self,self.on_QFLB_Task_Data_is_Query_msg)
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
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
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
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	self:MyRefresh()
end

function C:MyRefresh()
	if M.CheckAwardCanGet() then
		self.lfl.gameObject:SetActive(true)	
	else
		self.lfl.gameObject:SetActive(false)	
	end
end

function C:OnEnterClick()
	Act_044_QFLBPanel.Create()
end


function C:on_QFLB_Task_Data_is_Query_msg( ... )
	-- body
end