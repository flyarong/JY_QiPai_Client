local basefunc = require "Game/Common/basefunc"

ActivityExchangePanel = basefunc.class()
local C = ActivityExchangePanel
C.name = "ActivityExchangePanel"

local instance
--cfg : game_activity中的活动配置
function C.Create(parent,cfg,goto_scene_call,t_cfg)
	instance=C.New(parent,cfg,goto_scene_call,t_cfg)
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

	self.lister["UpdateHallTaskRedHint"] = basefunc.handler(self, self.UpdateHallTaskRedHint)

	self.lister["pay_exchange_status_response"] = basefunc.handler(self, self.pay_exchange_status)
	self.lister["local_pay_exchange_goods_response"] = basefunc.handler(self, self.pay_exchange_goods)
end
 
function C:ReConnecteServerSucceed()
	local msg_list = {}
	for k,v in ipairs(self.goods_list) do
		msg_list[#msg_list + 1] = {msg="pay_exchange_status", data = {goods_type = v.goods_type, goods_id = v.goods_id}}
	end
	GameManager.SendMsgList(Act_004FKYZDGMManager.key, msg_list)
	
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:ClearUIList()
	self:RemoveListener()
	if IsEquals(self.gameObject) then
		destroy(self.gameObject)
	end
	self.uilist_root = nil
	instance = nil

	 
end

function C:ctor(parent,cfg,goto_scene_call,t_cfg)

	ExtPanel.ExtMsg(self)

	self.act_cfg = cfg
	self.goto_scene_call = goto_scene_call
	self.config = t_cfg
	local obj
	parent = parent or GameObject.Find("Canvas/LayerLv5").transform
	obj = newObject(C.name, parent)
	self.gameObject = obj
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()

	self.goto_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGotoClick()
	end)

	self:InitConfig()
	self:InitUI()
	self:CloseRedDay()
	self:InitHelpBtn()
	Event.Brocast("ActivityExchangePanel_Had_Finish",{panelSelf = self})
	self:ChooseOne("tge1")
end

function C:InitBase()
	local base = self.config.base[1]
	if base.icon then
		self.icon_img.sprite = GetTexture(base.icon)
		self.icon_img.gameObject:SetActive(true)
	end
end

function C:OnGotoClick()
    local base = self.config.base[1]
	if base.goto_ui then
		GameManager.GotoUI({gotoui=base.goto_ui[1], goto_scene_parm=base.goto_ui[2]})
	else
		dump(self.config, "<color=red>EEE 调整配置为空</color>")
	end
end
-- 头部信息
function C:InitInfo()
    local base = self.config.base[1]
    if base.is_info and base.is_info == 1 then
    	local num = GameItemModel.GetItemCount(base.tool_key)
    	self.my_tool_num_txt.text = string.format(base.tool_desc, num)
    	self.goto_txt.text = (base.goto_desc or "前 往")
		if base.goto_ui then
			if IsEquals(self.goto_btn) then
				self.goto_btn.gameObject:SetActive(true)
			end
		else
			if IsEquals(self.goto_btn) then
				self.goto_btn.gameObject:SetActive(false)
			end
    	end
		if IsEquals(self.info_content) then
			self.info_content.gameObject:SetActive(true)
		end
	else
		if IsEquals(self.info_content) then
			self.info_content.gameObject:SetActive(false)
		end
    end
end

function C:InitTge(type)
    local cfg = self.config.tge[type]
    local TG = self.tge_content.transform:GetComponent("ToggleGroup")
    local go = GameObject.Instantiate(self.tge_item, self.tge_content)
    go.gameObject:SetActive( #self.config.tge_list > 1 and cfg.is_show and cfg.is_show == 1)
    go.name = cfg.tge
    local ui_table = {}
    ui_table.transform = go.transform
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
        function(val)
            ui_table.tge_txt.gameObject:SetActive(not val)
            ui_table.mark_tge_txt.gameObject:SetActive(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			if val then
                self:SwitchGroup(type)
            end
        end
    )
    ui_table.tge_txt.text = cfg.name
    ui_table.mark_tge_txt.text = cfg.name
	if cfg.icon then
		ui_table.cz_img.sprite = GetTexture(cfg.icon)
		ui_table.cz_img.gameObject:SetActive(true)
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
    local rect = go.transform:GetComponent("RectTransform")
    local base = self.config.base[1]
    if base.is_info and base.is_info == 1 then
    	if #self.config.tge_list > 1 then
		    rect.sizeDelta = {x = 1092, y = 348}
    	else
		    rect.sizeDelta = {x = 1092, y = 390}
    	end
    else
    	if #self.config.tge_list > 1 then
		    rect.sizeDelta = {x = 1092, y = 462}
    	else
		    rect.sizeDelta = {x = 1092, y = 516}
    	end
    end
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
	local data_list = self.config[type]
	table.sort(data_list, function(a, b) return a.sort < b.sort end)	
	for k, v in pairs(data_list) do
		local inst = ActivityExchangeItem.Create(content,v,self.goto_scene_call)
		self.items = self.items or {}
		self.items[v.goods_type] = self.items[v.goods_type] or {}
		self.items[v.goods_type][v.goods_id] = inst
	end
end

function C:InitGoodsIds()
	for k,v in pairs(self.config.tge) do
		if v.on_off and v.on_off == 1 then
			for k1,v1 in pairs(self.config[k]) do
				self.goods_list = self.goods_list or {}
				self.goods_list[#self.goods_list + 1] = v1
				self.goods_list[#self.goods_list].tge = k
				self.goods_list[#self.goods_list].status = 1
			end
		end
	end
end

function C:InitData()
	self:InitGoodsIds()
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
end

function C:InitUI()
	self:InitBase()
	self:InitInfo()
	local base = self.config.base[1]
    if base.is_info and base.is_info == 1 then
    	if #self.config.tge_list > 1 then
	    	self.tge_ScrollView.localPosition = Vector3.New(0, 24, 0)
    	end
    else
    	if #self.config.tge_list > 1 then
	    	self.tge_ScrollView.localPosition = Vector3.New(0, 138, 0)
    	end
    end

	for i, v in ipairs(self.config.tge_list) do
		if v.on_off and v.on_off == 1 then
			self:InitTge(v.tge)
			self:InitSV(v.tge)
		end
	end
	self:InitData()
	self:MyRefresh()
end

function C:MyRefresh()
	if table_is_null(self.goods_list) or
		table_is_null(self.items) then 
		return
	end
	for k,v in pairs(self.goods_list) do
		self:RefreshItem(v)
	end
end

function C:RefreshItem(v)
	if not IsEquals(self.gameObject) then return  end 
	if table_is_null(self.goods_list) or
		table_is_null(self.items) or
		not self.items[v.goods_type] or not self.items[v.goods_type][v.goods_id] then 
		return 
	end
	local _v = self.items[v.goods_type][v.goods_id]

	if IsEquals(_v.gameObject) then 
		_v:MyRefresh(v)
	else
		self.items[v.goods_type][v.goods_id] = nil
	end 
	self:SortTgeItems(v.tge)
	self:ChooseOne()
end

function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	self:InitInfo()
end

function C:OnDestroy()
	self:MyExit()
end

function C:onEnterBackGround()

end

function C:ClearUIList()
	if table_is_null(self.items) then return end
	for k, v in pairs(self.items) do
		for k1,v1 in pairs(v) do
			v1:OnDestroy()
		end
	end
	self.items = nil
end

function C:check_all_reawrd_state()
	local is_all_get = false
	local tge_get = {}
	for k,v in pairs(self.config.tge) do
		if v.on_off and v.on_off == 1 then
			tge_get[k] = false
		end
	end
	if table_is_null(self.goods_list) then return is_all_get, tge_get end

	for i,v in ipairs(self.goods_list) do
		if v.status == 0 then
			tge_get[v.tge] = true
			is_all_get = true
			break
		end
	end

	if instance then
		for k,v in pairs(tge_get) do
			if IsEquals(instance.tge_item_table[k].red_point) then
				instance.tge_item_table[k].red_point.gameObject:SetActive(v)
			end
		end
	end
	return is_all_get, tge_get
end

function C:SortTgeItems(tge)
	if not tge then return end
	local goods_list_tge = {}
	for i,v in ipairs(self.goods_list) do
		if v.tge == tge then
			table.insert(goods_list_tge,v)
		end
	end
	if table_is_null(goods_list_tge) or table_is_null(self.items) then return end

	table.sort(goods_list_tge, function(a, b)
		if a.status == 0 or b.status == 0 then
			if a.status == 0 and b.status == 0 then
				return a.sort < b.sort
			else
				return a.status < b.status
			end
		end

		if a.status == 1 or b.status == 1 then
			if a.status == 1 and b.status == 1 then
				return a.sort < b.sort
			else
				return a.status > b.status
			end
		end

		return a.sort < b.sort
	end)

	for i,v in ipairs(goods_list_tge) do
		if self.items[v.goods_type] and self.items[v.goods_type][v.goods_id] and IsEquals(self.items[v.goods_type][v.goods_id].transform) then
			self.items[v.goods_type][v.goods_id].transform:SetAsLastSibling()
		end
	end
	return goods_list_tge
end

function C:UpdateHallTaskRedHint()
	self:check_all_reawrd_state()
end

function C:CloseRedDay()
	Event.Brocast("CloseRedDay",{id = self.act_cfg.ID,title=self.act_cfg.title })
	Event.Brocast("UpdateHallTaskRedHint")
end

function C:InitHelpBtn()
	if self.config.helpinfo == nil or self.config.helpinfo[1] == nil then self.help_btn.gameObject:SetActive(false) return end
	local str = self.config.helpinfo[1].text
	for i = 2, #self.config.helpinfo do
		str = str .. "\n" .. self.config.helpinfo[i].text
	end
	self.introduce_txt.text = str
	self.help_btn.gameObject.transform:GetComponent("Image").sprite = GetTexture(self.config.helpinfo[1].button_image)
	self.help_btn.gameObject.transform:GetComponent("Image"):SetNativeSize()
	self.help_btn.onClick:AddListener(
		function ()
			IllustratePanel.Create({ self.introduce_txt }, GameObject.Find("Canvas/LayerLv5").transform)
		end
	)
end

function C:pay_exchange_status(_,data)
	dump(data, "<color=white>状态查询</color>")
	if not table_is_null(self.goods_list) then
		local v = {}
		for i=1,#self.goods_list do
			v = self.goods_list[i]
			if v.goods_type == data.goods_type and v.goods_id == data.goods_id then
				v.status = 1
				if data.result == 0 then
					v.status = 0
				end
				self:MyRefresh()
			end
		end
	end
end

function C:pay_exchange_goods(_,data)
	dump(data, "<color=white>购买成功</color>")
	if not table_is_null(self.goods_list) then
		local v = {}
		for i=1,#self.goods_list do
			v = self.goods_list[i]
			if v.goods_type == data.goods_type and v.goods_id == data.goods_id then
				v.status = 1
				self:MyRefresh()
			end
		end
	end
end