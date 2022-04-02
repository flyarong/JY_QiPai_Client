
local basefunc = require "Game.Common.basefunc"

ActivityExchangeItem = basefunc.class()

local C = ActivityExchangeItem
C.name = "ActivityExchangeItem"

local PROGRESS_WIDTH = 398
local PROGRESS_HEIGHT = 28

function C.Create(parent_transform, config,goto_scene_call)
	return C.New(parent_transform, config,goto_scene_call)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:ctor(parent, config,goto_scene_call)
	self.config = config
	self.goto_scene_call = goto_scene_call
	local obj = newObject("ActivityTaskItem", parent)
	self.gameObject = obj
	self.transform = obj.transform
	self.gameObject.name = config.id
	self.uilist = {}

	self:MakeLister()
	self:AddMsgListener()

	self.title = self.transform:Find("title"):GetComponent("Text")
	self.progress = self.transform:Find("progress")
	self.progress.gameObject:SetActive(false)

	self.item_tmpl = self.transform:Find("item_tmpl")
	self.list_node = self.transform:Find("list_node")

	local btn_node = self.transform:Find("btn_node")
	self.remark_txt = self.transform:Find("remark_txt"):GetComponent("Text")
	self.complete_img = btn_node:Find("complete_img")
	self.complete_img.gameObject:SetActive(false)

	self.reward_btn = btn_node:Find("reward_btn"):GetComponent("Button")
	self.swreward_btn=btn_node:Find("swreward_btn"):GetComponent("Button")
	self.reward_btn.onClick:AddListener(function()
		self:GoBuy()
	end)
	self.reward_btn.gameObject:SetActive(false)
	self.swreward_btn.onClick:AddListener(function()
				if config.isreal then
					local string1
					string1="奖品:"..config.item[1].."，请联系客服领取奖励\n客服QQ：%s"				
					HintCopyPanel.Create({desc=string1, isQQ=true})
				end 
	end)
	self.recharge_btn = btn_node:Find("recharge_btn"):GetComponent("Button")
	self.recharge_btn.onClick:AddListener(function()
		self:Goto()
	end)
	self.recharge_btn.gameObject:SetActive(false)
	self:InitUI()
end

function C:InitUI()
	self.state = 0

	local config = self.config

	self.title.text = config.task_name
	for i = 1, #config.item, 1 do
		local item = GameItemModel.GetItemToKey(config.item[i])
		local count = config.count[i]
		if  count then
			local inst = GameObject.Instantiate(self.item_tmpl, self.list_node)
			local icon = inst.transform:Find("icon"):GetComponent("Image")
			local uicount = inst.transform:Find("icon/count"):GetComponent("Text")
			local add_txt = inst.transform:Find("@add_txt"):GetComponent("Text")
			local tag = inst.transform:Find("tag")
			local tag_txt = inst.transform:Find("tag/tag_txt"):GetComponent("Text")
			if i <= 1 then 
				add_txt.gameObject:SetActive(false)
				if config.discount then
					tag.gameObject:SetActive(true)
					tag_txt.text = config.discount
				end
			else
				add_txt.gameObject:SetActive(true)
			end 
			if item == nil then
				icon.sprite = GetTexture(config.item[i])
				uicount.text = count
			else
				icon.sprite = GetTexture(item.image)
				uicount.text = count
			end	

			inst.gameObject:SetActive(true)
			self.uilist[#self.uilist + 1] = inst
			if  config.hint_item and next(config.hint_item) then
				local v
				for j=1,#config.hint_item do
					v = config.hint_item[j]
					if config.item[i] == v then
						PointerEventListener.Get(inst.gameObject).onDown = function ()
							GameTipsPrefab.ShowDesc(config.hint_desc[j], UnityEngine.Input.mousePosition)
						end
						PointerEventListener.Get(inst.gameObject).onUp = function ()
							GameTipsPrefab.Hide()
						end
					end
				end
			end
		else
			print("[TASK] recharge reward config error:" .. config.id)
		end
	end
	if config.remarks then
		self.remark_txt.text = config.remarks
	end
end

function C:MyExit()
	self:RemoveListener()
	self:ClearUIList()
	self.item_tmpl = nil
	self.list_node = nil
	self.recharge_btn = nil
	self.reward_btn = nil
	self.complete_img = nil
end

function C:OnDestroy()
	self:MyExit()
	Destroy(self.gameObject)
end

function C:ClearUIList()
	for k, v in pairs(self.uilist) do
		if IsEquals(v) then
			Destroy(v.gameObject)
		end
	end
	self.uilist = {}
end

function C:GetID()
	return self.config.id	
end

function C:SetState(state)
	self.state = state

	self.recharge_btn.gameObject:SetActive(false)
	self.swreward_btn.gameObject:SetActive(false)
	if state == 0 then
		self.reward_btn.gameObject:SetActive(true)
		self.complete_img.gameObject:SetActive(false)
	elseif state == 1 then
		self.reward_btn.gameObject:SetActive(false)
		self.complete_img.gameObject:SetActive(true)
	end
end

--0/1/2
function C:GetState()
	return self.state
end

function C:IsComplete()
	return self:GetState() == 1
end


function C:MyRefresh(data)
	self:SetState(data.status)
end

function C:GoBuy()
	local goods_data = MainModel.GetShopingConfig(GOODS_TYPE.item, self.config.goods_id,self.config.goods_type)
	if goods_data then
		local can_pay = false
		if goods_data.use_type == "jing_bi" then
			can_pay = goods_data.use_count <= MainModel.UserInfo.jing_bi
		elseif goods_data.use_type == "diamond" then
				can_pay = goods_data.use_count <= MainModel.UserInfo.diamond
		elseif goods_data.use_type == "shop_gold_sum" then
			can_pay = goods_data.use_count <= MainModel.UserInfo.shop_gold_sum
		end
		if can_pay then
			self:PayExchangeGoods(goods_data)
		else
			self:Goto()
		end
	else
		print("<color=red>没有此商品ID！！！</color>")
	end 
end

function C:Goto()
	local goto_ui
	if not table_is_null(self.config.gotoUI)  then
		goto_ui = self.config.gotoUI[1]
		if self.goto_scene_call and type(self.goto_scene_call) == "function" and GameManager.GotoSceneMap[goto_ui] then
			if GameManager.CheckActivityYear() then
				ActivityYearPanel.Close()
			else
				Event.Brocast("ui_button_data_change_msg",{key = M.key})
			end
			self.goto_scene_call()
		else
			GameManager.GotoUI({gotoui=goto_ui, goto_scene_parm=self.config.gotoUI[2]})
		end
	else
		LittleTips.Create("参数错误")
	end
end

function C:PayExchangeGoods(goodsData)
    dump(goodsData, "<color=yellow>PayExchangeGoods</color>")
	Network.SendRequest("pay_exchange_goods",
	{goods_type = goodsData.type, goods_id = goodsData.id},"购买道具",function (data)
		if data.result ~= 0 then
			HintPanel.ErrorMsg(data.result)
		elseif data.result == 0 then
			Event.Brocast("local_pay_exchange_goods_response","local_pay_exchange_goods_response",data)
		end
	end)
end