-- 创建时间:2020-05-11
-- Panel:Act_044_XNFLPanel
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

Act_044_XNFLPanel = basefunc.class()
local C = Act_044_XNFLPanel
C.name = "Act_044_XNFLPanel"
C.instance = nil
local M = Act_044_XNFLManager
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
	self.lister["model_xnfl_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["model_xnfl_qfxl_num_change_msg"] = basefunc.handler(self,self.MyRefresh)
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
	self.lister["model_xnfl_receive_award_change_msg"] = basefunc.handler(self,self.on_model_xnfl_receive_award_change_msg)
	self.lister["AssetsGetPanelConfirmCallback"] = basefunc.handler(self,self.OnAssetsGetPanelConfirmCallback)
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
	self.sale_time_txt = self.sale_time:GetComponent("Text")
	CommonTimeManager.GetCutDownTimer(1641225599, self.sale_time_txt)
	self.canShowLxdl = false
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	M.QueryData()
	M.update_time_benefits(true)
end

function C:MyRefresh()
	if not self.Act_044_XNFLLotteryPanel_pre then
		self.Act_044_XNFLLotteryPanel_pre = Act_044_XNFLLotteryPanel.Create(self.left_node.transform)
	end
	if M.GetBuyTime() == 0 or M.GetBuyTime() == -1 then
		self.sale_time.gameObject:SetActive(true)
		if not self.Act_044_XNFLBeforeBuyPanel_pre then
			self.Act_044_XNFLBeforeBuyPanel_pre = Act_044_XNFLBeforeBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_044_XNFLAfterBuyPanel_pre then
			self.Act_044_XNFLAfterBuyPanel_pre:MyExit()
			self.Act_044_XNFLAfterBuyPanel_pre = nil
		end
	else
		self.sale_time.gameObject:SetActive(false)
		if not self.Act_044_XNFLAfterBuyPanel_pre then
			self.Act_044_XNFLAfterBuyPanel_pre = Act_044_XNFLAfterBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_044_XNFLBeforeBuyPanel_pre then
			self.Act_044_XNFLBeforeBuyPanel_pre:MyExit()
			self.Act_044_XNFLBeforeBuyPanel_pre = nil
		end
	end
end

function C:Exit()
	if self.Act_044_XNFLLotteryPanel_pre then
		self.Act_044_XNFLLotteryPanel_pre:MyExit()
		self.Act_044_XNFLLotteryPanel_pre = nil
	end
	if self.Act_044_XNFLAfterBuyPanel_pre then
		self.Act_044_XNFLAfterBuyPanel_pre:MyExit()
		self.Act_044_XNFLAfterBuyPanel_pre = nil
	end
	if self.Act_044_XNFLBeforeBuyPanel_pre then
		self.Act_044_XNFLBeforeBuyPanel_pre:MyExit()
		self.Act_044_XNFLBeforeBuyPanel_pre = nil
	end
end

function C:OnBackClick()
	Event.Brocast("Panel_back_xnfl")
	self:MyExit()
end

function C:on_model_xnfl_receive_award_change_msg()
	if M.GetLoginDay() == 6 then
		--播放抽奖次数增加的特效
		--newObject("Act_044_XNFL_lxdl",self.transform)
		self.canShowLxdl = true
	end
end

function C:OnAssetsGetPanelConfirmCallback()
	if self.canShowLxdl then
		newObject("Act_044_XNFL_lxdl",self.transform)
		self.canShowLxdl = false 
	end
end