-- 创建时间:2020-03-09
-- Panel:Act_020HBFXWalletPanel
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

Act_020HBFXWalletPanel = basefunc.class()
local C = Act_020HBFXWalletPanel
C.name = "Act_020HBFXWalletPanel"
local M = Act_020HBFXManager
local button_mask = {"HBMX_MASK","TXJL_MASK"}
local node = {"hb_node","tx_node"}

local reason = {"提现","助力好友","好友组队挑战成功","宝箱开奖获得"}

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
	self.lister["model_query_npca_wallet_data_got"] = basefunc.handler(self,self.on_model_query_npca_wallet_data_got)
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

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	Network.SendRequest("query_npca_wallet_data")
	self:OnSwitchButtonClick(1)
end

function C:InitUI()
	self.close_btn.onClick:AddListener(
		function ( )
			self:MyExit()
		end
	)
	self.confirm_btn.onClick:AddListener(
		function ()
			MainModel.GetBindZFB(function(  )
				if table_is_null(MainModel.UserInfo.zfbData) or MainModel.UserInfo.zfbData.name == "" then
					LittleTips.Create("请先绑定支付宝")
					GameManager.GotoUI({gotoui = "sys_binding_zfb",goto_scene_parm = "panel"})
				else
					if GameItemModel.GetItemCount("prop_npca_hb")/100 >= 1 then 
						HintPanel.Create(2,"可提现"..Mathf.Floor((GameItemModel.GetItemCount("prop_npca_hb")/100)).."元福卡,确认提现吗？",function ()
							Network.SendRequest("withdraw_npca_hb",{hb = GameItemModel.GetItemCount("prop_npca_hb")/100},"正在提现...",function (data)
								if data.result == 0 then 
									self:MyExit()
									Act_020HBFXWalletPanel.Create()
								else
									HintPanel.Create(1,"提现失败")
								end 
							end)
						end)
					else
						HintPanel.Create(1,"余额大于1元才能提现哦，快去邀请好友获得奖励吧")
					end 
				end
			end)	
		end
	)
	self.HBMX_btn.onClick:AddListener(function ()
		self:OnSwitchButtonClick(1)
	end)
	self.TXJL_btn.onClick:AddListener(function ()
		self:OnSwitchButtonClick(2)
	end)
end

function C:on_model_query_npca_wallet_data_got()
	local data = M.getWalletData()
	local temp_ui = {}
	if data and data.result == 0 then
		self.num_txt.text = (GameItemModel.GetItemCount("prop_npca_hb")/100).."福卡"
		for i = 1,#data.data do
			if data.data[i].type > 1 then
				local b = GameObject.Instantiate(self.hb_item,self.hb_parent)
				b.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				temp_ui.hb_money_txt.text = "+"..(data.data[i].value / 100).."福卡"
				temp_ui.hb_time_txt.text = os.date("%Y.%m.%d   %X",data.data[i].time)
				temp_ui.hb_reason_txt.text = reason[data.data[i].type]
			else
				local b = GameObject.Instantiate(self.tx_item,self.tx_parent)
				b.gameObject:SetActive(true)
				LuaHelper.GeneratingVar(b.transform, temp_ui)
				temp_ui.tx_money_txt.text = "-"..(data.data[i].value / 100).."福卡"
				temp_ui.tx_time_txt.text = os.date("%Y.%m.%d   %X",data.data[i].time)
			end
		end
	end
end

function C:OnSwitchButtonClick(index)
	for i = 1,#button_mask do 
		self[button_mask[i]].gameObject:SetActive(false)
		self[node[i]].gameObject:SetActive(false)
	end
	self[button_mask[index]].gameObject:SetActive(true)
	self[node[index]].gameObject:SetActive(true)
end