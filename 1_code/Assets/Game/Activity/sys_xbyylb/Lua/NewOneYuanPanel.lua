-- 创建时间:2019-12-03
-- Panel:NewOneYuanPanel
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

NewOneYuanPanel = basefunc.class()
local C = NewOneYuanPanel
C.name = "NewOneYuanPanel"
local task_id 
local shop_id
function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] =  basefunc.handler(self,self.on_global_hint_state_change_msg)
	--self.lister["AssetChange"] = basefunc.handler(self,self.MyRefresh)
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

function C:ctor(parm)

	ExtPanel.ExtMsg(self)

	if not parm then
		parm = {}
	end
	self.parm = parm
	local parent = parm.parent or GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	task_id	= NewOneYuanManager.GetTaskID()
	shop_id = NewOneYuanManager.GetShopID()
	self:InitUI()
end

function C:InitUI()
	self.get_award_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:BuyOrGet()
		end
	)
	self.close_btn.onClick:AddListener(
		function ()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
			self:MyExit()
			if self.parm.backcall then
				self.parm.backcall()
			end
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end 
	self.chaozhi.gameObject:SetActive(MainModel.GetGiftShopStatusByID(shop_id) == 1)
	if MainModel.GetGiftShopStatusByID(shop_id) == 0 and GameTaskModel.GetTaskDataByID(task_id) then
		self.lq1.gameObject:SetActive(true)
		local day_index = NewOneYuanManager.GetDayIndex()
		local task_data = GameTaskModel.GetTaskDataByID(task_id)
		local b = basefunc.decode_task_award_status(task_data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, task_data, NewOneYuanManager.GetTaskCount())
		for i=1,#b do
			if b[i] == 2 then 
				self["lq"..i + 1].gameObject:SetActive(true)
			else
				self["lq"..i + 1].gameObject:SetActive(false)
			end
			if b[i] == 1 and i ==  day_index then 
				self["get"..i + 1].gameObject:SetActive(true)
			else
				self["get"..i + 1].gameObject:SetActive(false)
			end
			if b[i] == 1 then
				if day_index > i then   
					self["gq"..i + 1].gameObject:SetActive(true)
				else
					self["gq"..i + 1].gameObject:SetActive(false)
				end 
			end  
		end
	else
		self.lq1.gameObject:SetActive(false)
	end
end

function C:BuyOrGet()
	local task_data = GameTaskModel.GetTaskDataByID(task_id)
	if MainModel.GetGiftShopStatusByID(shop_id) == 1 then 
		self:BuyGift(shop_id)
	elseif task_data then 
		self:GetAward()
	end 
end

function C:BuyGift(shopid)
	self.gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag,shopid)
	if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“鲸鱼新家园”公众号获取"..self.gift_config.pay_title})
	else
		PayTypePopPrefab.Create(self.gift_config.id, "￥" .. (self.gift_config.price / 100))
	end
end

function C:GetAward()
	local day_index = NewOneYuanManager.GetDayIndex()
	local task_data = GameTaskModel.GetTaskDataByID(task_id)
	dump(day_index)
	dump(task_data)
	if day_index and day_index > 0 then
		local b = basefunc.decode_task_award_status(task_data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, task_data, NewOneYuanManager.GetTaskCount())
		if b[day_index] == 1 then 
	     	Network.SendRequest("get_task_award", {id = task_id})
		else
			HintPanel.Create(1,"您今天已经领取过奖励了！")
		end 
	else
		if day_index == 0 then 
			HintPanel.Create(1,"您今天已经领取过奖励了！")
		else
			print("<color=red>ERROR ！！！礼包时间异常</color>")
		end 
	end 
end

function C:on_global_hint_state_change_msg(parm)
	if  parm.gotoui == NewOneYuanManager.key then 
		self:MyRefresh()
	end 
end