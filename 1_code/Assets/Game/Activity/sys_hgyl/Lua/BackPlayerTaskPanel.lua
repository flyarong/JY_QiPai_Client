-- 创建时间:2019-10-22
-- Panel:BackPlayerTaskPanel
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

BackPlayerTaskPanel = basefunc.class()
local C = BackPlayerTaskPanel
C.name = "BackPlayerTaskPanel"
local Instance
function C.Create(parent)
	if Instance then
		return Instance
	end
	Instance = C.New(parent)
	return Instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["model_task_change_msg"]=basefunc.handler(self, self.handle_one_task_data_response)
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
	Instance = nil 

	 
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
	self:InitUI()
	Network.SendRequest("query_one_task_data", {task_id = 21021})
	Network.SendRequest("query_one_task_data", {task_id = 21022})
end

function C:InitUI()
	self.item_a.transform:Find("btn_node/reward_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			Network.SendRequest("get_task_award", {id = 21021})
		end
	)
	self.item_b.transform:Find("btn_node/recharge_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			local parm = {hall_type = MatchModel.HallType.djs}
			GameManager.GotoUI({gotoui = GameConfigToSceneCfg.game_MatchHall.SceneName,goto_scene_parm = parm})	
		end
	)
	self.item_b.transform:Find("btn_node/reward_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			Network.SendRequest("get_task_award", {id = 21022})	
		end
	)
	self.item_c.transform:Find("btn_node/reward_btn"):GetComponent("Button").onClick:AddListener(
		function ()
			self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 10043)
			if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
				GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
			else
				PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
			end
		end
	)
	self:Refresh_gift()
end

function C:Refresh_gift()
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 10043)
	self.status = MainModel.GetGiftShopStatusByID(self.gift_config.id)
    local b1 = MathExtend.isTimeValidity(self.gift_config.start_time, self.gift_config.end_time)
    if b1 then
		if self.status ~= 1 then
			self.item_c.transform:Find("btn_node/reward_btn").gameObject:SetActive(false)
			self.item_c.transform:Find("btn_node/complete_img").gameObject:SetActive(true)
		else
			self.item_c.transform:Find("btn_node/reward_btn").gameObject:SetActive(true)
			self.item_c.transform:Find("btn_node/complete_img").gameObject:SetActive(false)
		end
    else
		self.item_c.transform:Find("btn_node/reward_btn").gameObject:SetActive(false)
		self.item_c.transform:Find("btn_node/complete_img").gameObject:SetActive(true)
    end
end

function C:OnDestroy()	
	self:MyExit()
end

function C:on_finish_gift_shop(id)
	self:Refresh_gift()
end

function C:handle_one_task_data_response(data)
	dump(data,"<color=red>回归任务数据</color>")
	self:Refresh_A(data)
	self:Refresh_B(data)
end

function C:Refresh_A(data)
	if data.id == 21021 then 
		if data.award_status == 1 then
			self.item_a.transform:Find("btn_node/recharge_btn").gameObject:SetActive(false)
			self.item_a.transform:Find("btn_node/reward_btn").gameObject:SetActive(true)
			self.item_a.transform:Find("btn_node/complete_img").gameObject:SetActive(false)
		elseif data.award_status == 2 then 
			self.item_a.transform:Find("btn_node/recharge_btn").gameObject:SetActive(false)
			self.item_a.transform:Find("btn_node/reward_btn").gameObject:SetActive(false)
			self.item_a.transform:Find("btn_node/complete_img").gameObject:SetActive(true)
			self.item_a.transform:SetSiblingIndex(3)
		else
			self.item_a.gameObject:SetActive(false)
		end 
	end 
end

function C:Refresh_B(data)
	if data.id == 21022 then 
		if data.award_status == 1 then
			self.item_b.transform:Find("btn_node/recharge_btn").gameObject:SetActive(false)
			self.item_b.transform:Find("btn_node/reward_btn").gameObject:SetActive(true)
			self.item_b.transform:Find("btn_node/complete_img").gameObject:SetActive(false)
		elseif data.award_status == 2 then 
			self.item_b.transform:Find("btn_node/recharge_btn").gameObject:SetActive(false)
			self.item_b.transform:Find("btn_node/reward_btn").gameObject:SetActive(false)
			self.item_b.transform:Find("btn_node/complete_img").gameObject:SetActive(true)
			self.item_b.transform:SetSiblingIndex(3)
		else
			self.item_b.transform:Find("btn_node/recharge_btn").gameObject:SetActive(true)
			self.item_b.transform:Find("btn_node/reward_btn").gameObject:SetActive(false)
			self.item_b.transform:Find("btn_node/complete_img").gameObject:SetActive(false)
		end 
	end 
end

function C.CheckActivityState()
	local b = GameTaskModel.check_reward_state(21021,1) or GameTaskModel.check_reward_state(21022,1)
	if b then
		ActivityYearManager.on_ui_activity_state_msg({id = 23, state = ActivityYearManager.GAMState.GAM_Get})
	else
		ActivityYearManager.on_ui_activity_state_msg({id = 23, state = ActivityYearManager.GAMState.GAM_Nor})
	end
	return  b
end