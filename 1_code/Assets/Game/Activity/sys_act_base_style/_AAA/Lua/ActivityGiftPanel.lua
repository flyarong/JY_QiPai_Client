local basefunc = require "Game/Common/basefunc"

ActivityGiftPanel = basefunc.class()
local C = ActivityGiftPanel
C.name = "ActivityGiftPanel"

local instance
--cfg : game_activity中的活动配置
function C.Create(parent,cfg)
	instance=C.New(parent,cfg)
	return instance
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["AssetChange"] = basefunc.handler(self, self.OnAssetChange)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.onEnterBackGround)
	self.lister["EnterForeGround"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)

	--购买失败
	self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
	--购买成功
	self.lister["finish_gift_shop"] = basefunc.handler(self, self.on_finish_gift_shop)
end

function C:OnAssetChange(data)
	
end

function C:onEnterBackGround()

end

function C:ReConnecteServerSucceed()
	if not table_is_null(self.gift_ids) then
		for k,v in pairs(self.gift_ids) do
			self.gift_status = self.gift_status or {}
			self.gift_status[v] = MainModel.GetGiftShopStatusByID(v)
		end
	end
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	if IsEquals(self.gameObject) then
		destroy(self.gameObject)
	end
	self.uilist_root = nil
	instance = nil

	 
end

function C:OnReceivePayOrderMsg(msg)
	dump(msg, "<color=green>on_model_receive_pay_order</color>")
	if msg.result == 0 then
		print("<color=green>购买礼包成功</color>")
	else
		HintPanel.ErrorMsg(msg.result)
	end
end

function C:on_finish_gift_shop(id)
	dump(id, "<color=green>on_finish_gift_shop</color>")
	if not table_is_null(self.gift_ids) and self.gift_ids[id] then
		--UIPaySuccess.Create()
		--刷新
		self:ReConnecteServerSucceed()
		self:MyRefresh()
	end
end

function C:ctor(parent,cfg)

	ExtPanel.ExtMsg(self)

	self.act_cfg = cfg
	self.config = HotUpdateConfig("Game.CommonPrefab.lua." .. cfg.activity_config)
	self:InitData()
	self:InitConfig()
	local obj
	if parent~=nil then 
		obj = newObject(C.name, parent)
	else
		obj= newObject(C.name, GameObject.Find("Canvas/LayerLv5").transform)
	end
	self.gameObject = obj
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:CloseRedDay()
end

function C:InitGiftIds()
	for k,v in pairs(self.config.tge) do
		if v.on_off and v.on_off == 1 then
			for k1,v1 in pairs(self.config[k]) do
				self.gift_ids = self.gift_ids or {}
				self.gift_ids[v1.gift] = v1.gift
			end
		end
	end
end

function C:InitData()
	self:InitGiftIds()
	self:ReConnecteServerSucceed()
end

function C:InitConfig()
	self.config.tge_list = {}
	for k,v in pairs(self.config.tge) do
		table.insert( self.config.tge_list,v)
	end
	table.sort( self.config.tge_list,function(a,b)
		return a.order < b.order
	end)
	if not table_is_null(self.gift_ids) then
		for k,v in pairs(self.gift_ids) do
			self.gift_config = self.gift_config or {}
			self.gift_config[v] = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, v)
		end
	end
end

function C:InitUI()
	self:InitBase()
	for i, v in ipairs(self.config.tge_list) do
		if v.on_off and v.on_off == 1 then
			self:InitTge(v.tge)
			self:InitSV(v.tge)
		end
	end
	self:MyRefresh()
	-- self:ChooseOne("tge1")
end

function C:MyRefresh()
	self:ChooseOne()
end

function C:OnDestroy()
	self:MyExit()
end

function C:InitBase()
	local base = self.config.base[1]
	if base.icon then
		self.icon_img.sprite = GetTexture(base.icon)
		self.icon_img.gameObject:SetActive(true)
	end

	dump(self.gift_config, "<color=yellow>self.gift_config</color>")
	if not table_is_null(self.gift_config) then
		for k,v in pairs(self.gift_config) do
			dump( v, "<color=white>v</color>")
			local s1 = os.date("%m月%d日%H点", v.start_time)
			local e1 = os.date("%m月%d日%H点", v.end_time)
			self.time_txt.text = string.format( "礼包下架时间：%s", e1)
			if not v.buy_limt then
				self.day_txt.text = string.format( "")
			else
				if v.buy_limt == 0 then
					self.day_txt.text = string.format( "每个礼包每天无限制")
				elseif v.buy_limt == 1 then
					self.day_txt.text = string.format( "每个礼包每天限购1次")
				elseif v.buy_limt == 2 then
					self.day_txt.text = string.format( "每个礼包每月限购1次")
				end
			end
			break
		end
	end
	self.shop_btn.onClick:AddListener(function(  )
		self:OnShopClick()
	end)
end

function C:InitTge(type)
	local cfg = self.config.tge[type]
    local TG = self.tge_content.transform:GetComponent("ToggleGroup")
    local go = GameObject.Instantiate(self.tge_item, self.tge_content)
    go.gameObject:SetActive(true)
    go.name = cfg.tge
    local ui_table = {}
    ui_table.transform = go.transform
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
        function(val)
			ui_table.tge_mark_img.gameObject:SetActive(val)
			if val then
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				self:SwitchGroup(type)
				ui_table.transform.localScale = Vector3.one
				self.cur_shopid = self.config[type][1].gift
				if cfg.shop_icon then
					local img = self.shop_btn.transform:GetComponent("Image")
					if IsEquals(img) then
						img.sprite = GetTexture(cfg.shop_icon)
					end
				end

				local gift_state = self.gift_status[self.config[type][1].gift]
				if gift_state == 0 then
					--已经购买
					ui_table.red_point.gameObject:SetActive(true)
				elseif gift_state == 1 then
					--没有购买
					ui_table.red_point.gameObject:SetActive(false)
				end
			else
				ui_table.transform.localScale = Vector3.one * 0.8
			end
        end
	)
	if cfg.tge_txt_icon then
		ui_table.tge_txt_img.sprite = GetTexture(cfg.tge_txt_icon)		
	end
	local gift_cfg = self.gift_config[self.config[type][1].gift]
	if gift_cfg then
		ui_table.tge2_txt.text = StringHelper.ToCash(gift_cfg.price / 100)
	end
	if cfg.icon then
		ui_table.tge_img.sprite = GetTexture(cfg.icon)
		ui_table.tge_img.gameObject:SetActive(true)
	end
	if cfg.mask_icon then
		ui_table.tge_mark_img.sprite = GetTexture(cfg.mask_icon)
	end
	if cfg.red_icon then
		local img = ui_table.red_point.transform:GetComponent("Image") 
		if IsEquals(img) then
			img.sprite = GetTexture(cfg.red_icon)
		end
	end

    self.tge_item_table = self.tge_item_table or {}
    self.tge_item_table[type] = ui_table
end

function C:ChooseOne(type)
	if type then
		self.tge_item_table[type].item_tge.isOn=true
		return
	end
	local is_get,get_state = self:check_all_reawrd_state()
	if not is_get then
		for k,v in ipairs(self.config.tge_list) do
			self.tge_item_table[v.tge].item_tge.isOn=true
			return
		end
	else
		for k,v in ipairs(self.config.tge_list) do
			if get_state[v.tge] then
				self.tge_item_table[v.tge].item_tge.isOn=true
				return
			end
		end
	end
end

function C:InitSV(type)
	local sv = self.sv_item
	local go = GameObject.Instantiate(sv, self.Center)
    go.gameObject:SetActive(false)
    local ui_table = {}
    ui_table.transform = go.transform
    ui_table.gameObject = go.gameObject
    LuaHelper.GeneratingVar(go.transform, ui_table)
    self.sv_item_table = self.sv_item_table or {}
	self.sv_item_table[type] = ui_table	
	self:CreateGoodsItemsToContent(type, ui_table.sv_content)
end

function C:SwitchGroup(type)
	self.sv_item_table = self.sv_item_table or {}
	for k,v in pairs(self.sv_item_table) do
		v.gameObject:SetActive(k == type)
		if k == type then
			v.sv_content.localPosition = Vector3.zero
		end
	end
end

function C:CreateGoodsItemsToContent(type, content)
	local gift_cfg = self.gift_config[self.config[type][1].gift]
	dump(gift_cfg, "<color=white>礼包</color>")
	if gift_cfg then
		local first_gift = true
		for i,v in ipairs(gift_cfg.buy_asset_type) do
			local count = gift_cfg.buy_asset_count[i]
			local is_gift = false
			if not table_is_null(gift_cfg.gift_asset_type) then
				for i1,v1 in ipairs(gift_cfg.gift_asset_type) do
					--购买的数量和赠送的数量相同才是赠送的东西，适配卖啥送啥的情况
					if v == v1 and gift_cfg.gift_asset_count[i1] == count then
						is_gift = true
						break
					end				
				end	
			end
			local go 
			if is_gift then
				if first_gift then
					local g = GameObject.Instantiate(self.goods_item3, content)
					g.gameObject:SetActive(true)
					first_gift = false
				end
				go = GameObject.Instantiate(self.goods_item2, content)
			else
				go = GameObject.Instantiate(self.goods_item, content)
			end
			go.gameObject:SetActive(true)
			local ui_table = {}
			ui_table.transform = go.transform
			ui_table.gameObject = go.gameObject
			LuaHelper.GeneratingVar(go.transform, ui_table)
			
			local item_data = GameItemModel.GetItemToKey(v) 
			if item_data then
				if v == "shop_gold_sum" or v == "cash" then
					count = StringHelper.ToRedNum(count / 100)
				end
			else
				item_data = {}
				item_data.image = "com_btn_close"
				item_data.is_local_icon = 1
				item_data.desc = "?????"
			end
			ui_table.goods_img.sprite = GetTexture(item_data.image)
			ui_table.num_txt.text = count
			if is_gift then
				--赠送道具
				ui_table.gift_img.gameObject:SetActive(true)
			else
				--购买道具
				ui_table.gift_img.gameObject:SetActive(false)
			end
			PointerEventListener.Get(ui_table.goods_btn.gameObject).onDown = function(  )
    			GameTipsPrefab.ShowItem(v, UnityEngine.Input.mousePosition, GameTipsPrefab.TipsShowStyle.TSS_N)
			end
			PointerEventListener.Get(ui_table.goods_btn.gameObject).onUp = function(  )
				GameTipsPrefab.Hide()
			end
		end
	end
end

function C:check_all_reawrd_state()
	local is_all_get = false
	local tge_get = {}
	for k,v in pairs(self.config.tge) do
		if v.on_off and v.on_off == 1 then
			tge_get[k] = false
		end
	end
	if table_is_null(self.gift_ids) then return is_all_get, tge_get end

	for k,v in pairs(tge_get) do
		for k1,v1 in pairs(self.config[k]) do
			if self.gift_status[v1.gift] == 1 then
				tge_get[k] = true
				is_all_get = true
				break
			end
		end
	end

	for k,v in pairs(tge_get) do
		self.tge_item_table[k].red_point.gameObject:SetActive(not v)
	end
	return is_all_get, tge_get
end

function C:CloseRedDay()
	Event.Brocast("CloseRedDay",{id = self.act_cfg.ID,title = self.act_cfg.title})
end

function C:OnShopClick()
	ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
	local shopid = self.cur_shopid
	if self.gift_config[shopid] then
		local gift_config = self.gift_config[shopid]
		local b1 = MathExtend.isTimeValidity(gift_config.start_time, gift_config.end_time)

		dump(self.gift_status, "<color=yellow>商品状态</color>" .. shopid)
		if b1 then
			if self.gift_status[shopid] ~= 1 then
				local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
				local s1 = os.date("%m月%d日%H点", gift_config.start_time)
				local e1 = os.date("%m月%d日%H点", gift_config.end_time)
				HintPanel.Create(1, string.format( "您今日已购买过了，请明日再来购买。\n(%s-%s每天可购买1次)",s1,e1))
				return
			end
		else
			HintPanel.Create(1, "抱歉，此商品不在售卖时间内")
			return
		end
		
		if  GameGlobalOnOff.PGPay and  gameRuntimePlatform == "Ios" then
			GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
		else
			PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
		end
	else
		LittleTips.Create("未知商品")
	end
end