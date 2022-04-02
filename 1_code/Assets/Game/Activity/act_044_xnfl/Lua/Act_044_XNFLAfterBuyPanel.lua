-- 创建时间:2020-05-12
-- Panel:Act_044_XNFLAfterBuyPanel
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

Act_044_XNFLAfterBuyPanel = basefunc.class()
local C = Act_044_XNFLAfterBuyPanel
C.name = "Act_044_XNFLAfterBuyPanel"
local M = Act_044_XNFLManager
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
	self.lister["model_xnfl_data_change_msg"] = basefunc.handler(self,self.on_model_xnfl_data_change_msg)
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
	EventTriggerListener.Get(self.get_btn.gameObject).onClick = basefunc.handler(self, self.OnGetClick)

	self:on_model_xnfl_data_change_msg()
end

function C:MyRefresh()
end


function C:on_model_xnfl_data_change_msg()
	if M.GetIsReceive() == 1 then--已经领了
		self.gray_btn.gameObject:SetActive(true)
		self.get_btn.gameObject:SetActive(false)
	else--还未领
		self.gray_btn.gameObject:SetActive(false)
		self.get_btn.gameObject:SetActive(true)
	end
	self.Continuities_txt.text = "连续领取<color=#e33628>"..M.GetLoginDay().."</color>天"
	self.Residuals_txt.text = "剩余领取天数:<color=#e33628><size=32>"..M.GetTotalRemainNum().."</size></color>天"
end

function C:OnGetClick()
	-- Network.SendRequest("login_benefits_receive_award")
	Network.SendRequest("welfare_activity_receive_award",{act_type = M.type})
end

