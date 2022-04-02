-- 创建时间:2020-01-14
-- Panel:JYZKNewPanel
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
local JB_TASK_ID = 53
local JB_ITEM_ID = 41

JYZKNewPanel = basefunc.class()
local C = JYZKNewPanel
C.name = "JYZKNewPanel"

local instance
function C.Create(parent, backcall)
	if not instance then
		instance = C.New(parent, backcall)
	else
		instance:MyRefresh()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)

	self.lister["query_jingbi_zhouka_remain_response"] = basefunc.handler(self, self.jingbi_zhouka_remain_response)
	self.lister["jinbgi_zhouka_remain_change_msg"] = basefunc.handler(self, self.jingbi_zhouka_remain_change_msg)

	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	destroy(self.gameObject)
	self:RemoveListener()
	instance=nil
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.BuyJB = tran:Find("Rect/BuyJB"):GetComponent("Button")
	self.BuyJB.onClick:AddListener(function ()
		if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
			GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取鲸币周卡"})
		else
			local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, JB_ITEM_ID)
			PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100), function (result)
				if result == 0 then
				end
			end)
		end
	end)

	self.LQJB = tran:Find("Rect/LQJB"):GetComponent("Button")
	self.LQJB.onClick:AddListener(function ()
		Network.SendRequest("get_task_award", {id = JB_TASK_ID})
	end)
	self.LQJBInfo = tran:Find("Rect/LQJB/Info"):GetComponent("Text")

	self.WaitJB = tran:Find("Rect/WaitJB")
	self.WaitJBTitle = tran:Find("Rect/WaitJB/Title"):GetComponent("Text")
	self.WaitJBInfo = tran:Find("Rect/WaitJB/Info"):GetComponent("Text")

	self.JBHint = tran:Find("Rect/JBHint")
	local jbObject = tran:Find("BannerBG")
	EventTriggerListener.Get(jbObject.gameObject).onDown = function ()
		self.JBHint.gameObject:SetActive(true)
	end
	EventTriggerListener.Get(jbObject.gameObject).onUp = function ()
		self.JBHint.gameObject:SetActive(false)
	end

	self:InitUI()
end

function C:InitUI()
	self.jbData = {}

	Network.SendRequest("query_jingbi_zhouka_remain")
	Network.SendRequest("query_one_task_data", {task_id = JB_TASK_ID})	
end

function C:MyRefresh()
	self:RefreshJB()
end

function C.CheckTaskActivity(task_id)
	local task_data = GameTaskModel.GetTaskDataByID(task_id)
	if not task_data then return false end

	local award_status = basefunc.decode_task_award_status(task_data.award_get_status)
	for k, v in pairs(award_status) do
		if not v then
			return true
		end
	end

	return false
end

local Num2StrTbl = {"一", "二", "三", "四", "五", "六", "七", "八", "九", "十"}
function C:RefreshJB()
	self.BuyJB.gameObject:SetActive(false)
	self.LQJB.gameObject:SetActive(false)
	self.WaitJB.gameObject:SetActive(false)

	local data = self.jbData
	if data == nil or data.remain_num == nil then return end

	local task_data = GameTaskModel.GetTaskDataByID(JB_TASK_ID)
	local remain_num = data.remain_num
	if remain_num <= 0 or not task_data then	--buy
		self.BuyJB.gameObject:SetActive(true)
	else
		local has_award = C.CheckTaskActivity(JB_TASK_ID)
		if has_award then
			self.LQJB.gameObject:SetActive(true)
			self.LQJBInfo.text = string.format("剩余%d期", remain_num)
		else
			self.WaitJB.gameObject:SetActive(true)
			self.WaitJBTitle.text = "已领取"
			self.WaitJBInfo.text = string.format("剩余%d期", remain_num)
		end
	end
	Event.Brocast("JYFLInfoChange")
end

function C:OnBackClick()
	self:MyExit()
	if self.backcall then
		self.backcall()
	end
end

function C:ReConnecteServerSucceed()
	self:MyRefresh()
end

function C:OnReceivePayOrderMsg(msg)
	if msg.result == 0 then
		UIPaySuccess.Create()
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function C:jingbi_zhouka_remain_response(_,data)
	dump(data,"<color=yellow>------------  jingbi_zhouka_remain_response</color>")

	if data.result ~= 0 then
		return
	end
	if not instance then return end

	local remain_num = data.remain_num
	instance.jbData.remain_num = remain_num

	instance:RefreshJB()
end

function C:jingbi_zhouka_remain_change_msg(_,data)
	dump(data,"<color=yellow>------------  jingbi_zhouka_remain_change_msg</color>")

	if not instance then return end
	local remain_num = data.task_remain
	instance.jbData.remain_num = remain_num

	instance:RefreshJB()
end

function C.handle_one_task_data_response(_, data)
	dump(data, "handle_one_task_data_response")

	if not instance then return end

	if data.id == JB_TASK_ID then
		instance:RefreshJB()
	end
end

function C.handle_task_change(_, data)
	dump(data, "handle_task_change")

	if not instance then return end

	if data.id == JB_TASK_ID then
		instance:RefreshJB()
	end
end

function C:OnExitScene()
	self:MyExit()
end
