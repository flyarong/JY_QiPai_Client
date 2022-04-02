-- 创建时间:2020-07-31
-- Panel:SYSChangeNamePanel
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

SYSChangeNamePanel = basefunc.class()
local C = SYSChangeNamePanel
C.name = "SYSChangeNamePanel"
local M = SYSChangeHeadAndNameManager
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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["SYSChangeHeadAndNameManager_Change_Name_Success_msg"] = basefunc.handler(self,self.on_SYSChangeHeadAndNameManager_Change_Name_Success_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	Event.Brocast("OnePanel_had_been_Close_msg")
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.on_BackClick)
	EventTriggerListener.Get(self.sure_btn.gameObject).onClick = basefunc.handler(self, self.on_SureClick)
	EventTriggerListener.Get(self.yes_btn.gameObject).onClick = basefunc.handler(self, self.on_YesClick)
	Event.Brocast("OnePanel_had_been_Open_msg")
	if MainModel.UserInfo.udpate_name_num == 0 then
		self.cost_txt.text = "首次免费修改"
	else
		self.cost_txt.text = "10万金币"
	end
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:on_BackClick()
	self:MyExit()
end

function C:on_SureClick()
	Network.SendRequest("update_player_name",{name = self.input_txt.text})
end

function C:on_SYSChangeHeadAndNameManager_Change_Name_Success_msg()
	self.success_hintpanel.gameObject:SetActive(true)
end

function C:on_YesClick()
	self:MyExit()
end