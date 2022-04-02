-- 创建时间:2021-01-04
-- Panel:Act_Ty_Collect_WordsEnterPrefab
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

Act_Ty_Collect_WordsEnterPrefab = basefunc.class()
local C = Act_Ty_Collect_WordsEnterPrefab
C.name = "Act_Ty_Collect_WordsEnterPrefab"
local M = Act_Ty_Collect_WordsManager

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
    self.lister["ty_collect_activity_exchange_response_msg"] = basefunc.handler(self,self.on_ty_collect_activity_exchange_response_msg)
    self.lister["ty_collect_finish_gift_shop_msg"] = basefunc.handler(self,self.on_ty_collect_finish_gift_shop_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	CommonHuxiAnim.Stop(1,Vector3.New(1, 1, 1))
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
	CommonHuxiAnim.Start(self.gameObject)
	self:MyRefresh()
end

function C:MyRefresh()
	self.LFL.gameObject:SetActive(M.GetHintState({goto_ui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Get)
	self.red.gameObject:SetActive(M.GetHintState({goto_ui = M.key}) == ACTIVITY_HINT_STATUS_ENUM.AT_Red)
end

function C:OnEnterClick()
	Act_Ty_Collect_WordsPanel.Create()
end

function C:on_ty_collect_activity_exchange_response_msg()
	self:MyRefresh()
end

function C:on_ty_collect_finish_gift_shop_msg()
	self:MyRefresh()
end