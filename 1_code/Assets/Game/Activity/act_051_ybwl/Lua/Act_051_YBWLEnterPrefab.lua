-- 创建时间:2020-11-02
-- Panel:Act_051_YBWLEnterPrefab
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

Act_051_YBWLEnterPrefab = basefunc.class()
local C = Act_051_YBWLEnterPrefab
C.name = "Act_051_YBWLEnterPrefab"
local M = Act_051_YBWLManager
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
    self.lister["ExitScene"]=basefunc.handler(self,self.MyExit)
    self.lister["ybwl_task_has_change_msg"] = basefunc.handler(self,self.on_ybwl_task_has_change_msg)
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
	if M.GetHintState({gotoui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get then 
		self.lfl.gameObject:SetActive(true)
	else
		self.lfl.gameObject:SetActive(false)
		if PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then 
			self.red.gameObject:SetActive(false)
		else
			self.red.gameObject:SetActive(true)
		end 
	end
end

function C:OnEnterClick()
	PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.date("%Y%m%d",os.time()))
	Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
	Act_051_YBWLGamePanel.Create()
	self:MyRefresh()
end

function C:on_ybwl_task_has_change_msg()
	self:MyRefresh()
end