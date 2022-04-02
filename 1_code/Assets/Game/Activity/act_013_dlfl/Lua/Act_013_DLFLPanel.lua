-- 创建时间:2020-05-11
-- Panel:Act_013_DLFLPanel
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

Act_013_DLFLPanel = basefunc.class()
local C = Act_013_DLFLPanel
C.name = "Act_013_DLFLPanel"
C.instance = nil
local M = Act_013_DLFLManager
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
    self.lister["model_dlfl_data_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["model_dlfl_qfxl_num_change_msg"] = basefunc.handler(self,self.MyRefresh)
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
    self.lister["model_dlfl_receive_award_change_msg"] = basefunc.handler(self,self.on_model_dlfl_receive_award_change_msg)
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
end

function C:InitUI()
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnBackClick)
	M.QueryData()
	M.update_time_benefits(true)
end

function C:MyRefresh()
	if not self.Act_013_DLFLLotteryPanel_pre then
		self.Act_013_DLFLLotteryPanel_pre = Act_013_DLFLLotteryPanel.Create(self.left_node.transform)
	end
	if M.GetBuyTime() == 0 then
		self.sale_time.gameObject:SetActive(true)
		if not self.Act_013_DLFLBeforeBuyPanel_pre then
			self.Act_013_DLFLBeforeBuyPanel_pre = Act_013_DLFLBeforeBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_013_DLFLAfterBuyPanel_pre then
			self.Act_013_DLFLAfterBuyPanel_pre:MyExit()
			self.Act_013_DLFLAfterBuyPanel_pre = nil
		end
	else
		self.sale_time.gameObject:SetActive(false)
		if not self.Act_013_DLFLAfterBuyPanel_pre then
			self.Act_013_DLFLAfterBuyPanel_pre = Act_013_DLFLAfterBuyPanel.Create(self.right_node.transform)
		end
		if self.Act_013_DLFLBeforeBuyPanel_pre then
			self.Act_013_DLFLBeforeBuyPanel_pre:MyExit()
			self.Act_013_DLFLBeforeBuyPanel_pre = nil
		end
	end
end

function C:Exit()
	if self.Act_013_DLFLLotteryPanel_pre then
		self.Act_013_DLFLLotteryPanel_pre:MyExit()
		self.Act_013_DLFLLotteryPanel_pre = nil
	end
	if self.Act_013_DLFLAfterBuyPanel_pre then
		self.Act_013_DLFLAfterBuyPanel_pre:MyExit()
		self.Act_013_DLFLAfterBuyPanel_pre = nil
	end
	if self.Act_013_DLFLBeforeBuyPanel_pre then
		self.Act_013_DLFLBeforeBuyPanel_pre:MyExit()
		self.Act_013_DLFLBeforeBuyPanel_pre = nil
	end
end

function C:OnBackClick()
	Event.Brocast("Panel_back_dlfl")
	self:MyExit()
end

function C:on_model_dlfl_receive_award_change_msg()
	if M.GetLoginDay() == 7 then
		--播放抽奖次数增加的特效
		newObject("Act_013_DLFL_lxdl",self.transform)
	end
end