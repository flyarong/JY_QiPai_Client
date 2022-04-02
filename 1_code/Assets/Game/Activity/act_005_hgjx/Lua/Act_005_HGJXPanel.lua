-- 创建时间:2020-03-17
-- Panel:Act_005_HGJXPanel
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

Act_005_HGJXPanel = basefunc.class()
local C = Act_005_HGJXPanel
C.name = "Act_005_HGJXPanel"
local M = Act_005_HGJXManager
local config = M.config
function C.Create(parent,backcall)
	return C.New(parent,backcall)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["model_task_change_msg"] = basefunc.handler(self,self.on_model_task_item_change_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.main_timer then 
		self.main_timer:Stop()
	end
	if self.backcall then 
		self.backcall()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(parent,backcall)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	self.backcall = backcall
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	local a,t = GameButtonManager.RunFun({gotoui="sys_qx"}, "GetRegressTime")
	t = t or os.time()
	local temp_ui = {}
	self.task_items = {}
	self.close_btn.onClick:AddListener(
		function ()
			self:MyExit()
		end
	)
	self.out_time = 7 * 86400 - os.time() + t
	for i = 1,#config.base do 
		local b = GameObject.Instantiate(self.task_item,self.Node1)
		b.gameObject:SetActive(true)
		self.task_items[i] = b
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.task_txt.text = config.base[i].award_text
		temp_ui.choose_task_txt.text = config.base[i].award_text
		temp_ui.task_img.sprite = GetTexture(config.base[i].award_image) 
		temp_ui.task_img:SetNativeSize()
		temp_ui.click_btn.onClick:AddListener(
			function ()
				self:OnTaskItemClick(i)
			end
		)
	end 
	self:MyRefresh()
	self:InitMainTimer()
end

function C:MyRefresh()
	if not IsEquals(self.gameObject) then return end
	local temp_ui = {}
	local best_index = -1
	for i = 1,#config.base do 
		local data = GameTaskModel.GetTaskDataByID(config.base[i].task)
		dump(data,"<color=red>回归惊喜 任务数据</color>")
		if data then 
			LuaHelper.GeneratingVar(self.task_items[i].transform, temp_ui)
			if config.base[i].shop_id then 
				temp_ui.mask.gameObject:SetActive(data.now_total_process > 0)
				if data.now_total_process == 0 and best_index == -1 then 
					best_index = i
				end
			else
				temp_ui.mask.gameObject:SetActive(data.award_status == 2)
				if (data.award_status == 0 or data.award_status == 1) and best_index == -1 then 
					best_index = i
				end
			end
		end 
	end
	if best_index == -1 then best_index = 1 end 
	self:OnTaskItemClick(best_index)
end

function C:OnTaskItemClick(index)
	local temp_ui = {}
	for i = 1,#self.task_items do 
		LuaHelper.GeneratingVar(self.task_items[i].transform, temp_ui)	
		temp_ui.choose.gameObject:SetActive(i == index)
		temp_ui.task_txt.gameObject:SetActive(not (i == index))
		temp_ui.tag.gameObject:SetActive(i == index and not not config.base[i].shop_id)
	end
	self.info1_txt.text = config.base[index].task_name[1]
	self.info2_txt.text = config.base[index].task_name[2]
	--让Unity重现计算排版
	UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(self.T_Node)
	self.T_Node.gameObject:SetActive(false)
	self.T_Node.gameObject:SetActive(true)
	destroyChildren(self.Node2)
	for i = 1,#config.base[index].item do
		local item = GameItemModel.GetItemToKey(config.base[index].item[i])
		local b = GameObject.Instantiate(self.award_item,self.Node2)
		b.gameObject:SetActive(true)
		LuaHelper.GeneratingVar(b.transform, temp_ui)
		temp_ui.award_img.sprite = GetTexture(item.image)
		temp_ui.award_txt.text = config.base[index].count[i]
		temp_ui.add.gameObject:SetActive(not (i == 1))
	end
	self.go_btn.onClick:RemoveAllListeners()
	self.go_btn.gameObject:SetActive(false)
	self.go_btn.onClick:AddListener(
		function ()
			local goto_ui = config.base[index].gotoUI
			if goto_ui then 
				GameManager.GotoUI({gotoui= goto_ui[1], goto_scene_parm = goto_ui[2]})
			end 
		end
	)
	local data = GameTaskModel.GetTaskDataByID(config.base[index].task)
	if not data then return end 
	LuaHelper.GeneratingVar(self.task_items[index].transform, temp_ui)
	self.get_btn.onClick:RemoveAllListeners()
	self.get_btn.enabled = true
	if config.base[index].shop_id then 
		self.go_btn.gameObject:SetActive(false)
		if data.now_total_process > 0 then 
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("hgjx_btn_lq2")
			self.get_btn.enabled = false
		else
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("hgjx_btn_lq1")
		end
		self.get_btn.onClick:AddListener(
			function ()
				self:BuyShop(config.base[index].shop_id)
			end
		)
	else
		if data.award_status == 0 and config.base[index].gotoUI then 
			self.go_btn.gameObject:SetActive(true)
		end
		if data.award_status == 1 then 
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("hgjx_btn_lq1")
		else
			self.get_btn.transform:GetComponent("Image").sprite = GetTexture("hgjx_btn_lq2")
			self.get_btn.enabled = false
		end
		self.get_btn.onClick:AddListener(
			function ()
				Network.SendRequest("get_task_award", {id = config.base[index].task})
			end
		)
	end
end

function C:InitMainTimer()
	if self.main_timer then 
		self.main_timer:Stop()
	end
	self.time_txt.text = "活动时间剩余："..StringHelper.formatTimeDHMS2(self.out_time)
	self.main_timer = Timer.New(function()
		self.out_time = self.out_time - 1
		if self.out_time <= 0 then 
			self.time_txt.text = "活动已结束"
		else
			self.time_txt.text = "活动时间剩余："..StringHelper.formatTimeDHMS2(self.out_time)
		end
	end,1,-1)
	self.main_timer:Start()
end

function C:BuyShop(shopid)
    local shopid = shopid
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function C:on_model_task_item_change_msg(data)
	dump(data,"任务改变")
	self:MyRefresh()
end


--[[
	GetTexture("hgjx_icon_jp2")
	GetTexture("hgjx_icon_jp3")
]]