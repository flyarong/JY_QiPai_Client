-- 创建时间:2020-05-11
-- Panel:Act_056_WYFLPanel
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

Act_056_WYFLPanel = basefunc.class()
local C = Act_056_WYFLPanel
C.name = "Act_056_WYFLPanel"
C.instance = nil
local M = Act_056_WYFLManager
function C.Create()
	if C.instance then
		C.instance:MyRefresh()
		return
	end
	C.instance = C.New()
	return C.instance
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_wyfl_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["model_wyfl_qfxl_num_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_wyfl_receive_award_change_msg"] = basefunc.handler(self,self.on_model_wyfl_receive_award_change_msg)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	M.update_time_benefits(false)
	self:Exit()
	self:RemoveListener()
	C.instance = nil
	destroy(self.gameObject)
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
	CommonTimeManager.GetCutDownTimer(1620057599,self.sale_time.transform:GetComponent("Text"))
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	M.QueryData()
	M.update_time_benefits(true)
end

function C:MyRefresh()
	if not self.Act_056_WYFLLotteryPanel_pre then
		self.Act_056_WYFLLotteryPanel_pre = Act_056_WYFLLotteryPanel.Create(self.left_node.transform)
	end
	if M.GetBuyTime() == 0 then
		self.time_bg.gameObject:SetActive(true)
		self.sale_time.gameObject:SetActive(true)
		if not self.Act_056_WYFLBeforeBuyPanel_pre then
			self.Act_056_WYFLBeforeBuyPanel_pre = Act_056_WYFLBeforeBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_056_WYFLAfterBuyPanel_pre then
			self.Act_056_WYFLAfterBuyPanel_pre:MyExit()
			self.Act_056_WYFLAfterBuyPanel_pre = nil
		end
	else
		self.sale_time.gameObject:SetActive(false)
		self.time_bg.gameObject:SetActive(false)
		if not self.Act_056_WYFLAfterBuyPanel_pre then
			self.Act_056_WYFLAfterBuyPanel_pre = Act_056_WYFLAfterBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_056_WYFLBeforeBuyPanel_pre then
			self.Act_056_WYFLBeforeBuyPanel_pre:MyExit()
			self.Act_056_WYFLBeforeBuyPanel_pre = nil
		end
	end
end

function C:Exit()
	if self.Act_056_WYFLLotteryPanel_pre then
		self.Act_056_WYFLLotteryPanel_pre:MyExit()
		self.Act_056_WYFLLotteryPanel_pre = nil
	end
	if self.Act_056_WYFLAfterBuyPanel_pre then
		self.Act_056_WYFLAfterBuyPanel_pre:MyExit()
		self.Act_056_WYFLAfterBuyPanel_pre = nil
	end
	if self.Act_056_WYFLBeforeBuyPanel_pre then
		self.Act_056_WYFLBeforeBuyPanel_pre:MyExit()
		self.Act_056_WYFLBeforeBuyPanel_pre = nil
	end
end

function C:OnBackClick()
	Event.Brocast("Panel_back_wyfl")
	self:MyExit()
end

function C:on_model_wyfl_receive_award_change_msg()
	if M.GetLoginDay() == 7 then
		--播放抽奖次数增加的特效
		newObject("Act_056_WYFL_lxdl",self.transform)
	end
end