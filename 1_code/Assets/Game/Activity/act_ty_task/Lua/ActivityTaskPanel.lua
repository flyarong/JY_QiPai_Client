local basefunc = require "Game/Common/basefunc"

ActivityTaskPanel = basefunc.class()
local C = ActivityTaskPanel
C.name = "ActivityTaskPanel"

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
	self.lister["main_model_query_all_gift_bag_status"] = basefunc.handler(self, self.RefreshItem_Shop)
	self.lister["ExitScene"] = basefunc.handler(self, self.MyExit)
	self.lister["shop_info_get"] = basefunc.handler(self,self.RefreshItem_Shop)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.handle_one_task_data_response)
	self.lister["model_task_change_msg"] = basefunc.handler(self, self.handle_task_change)
	self.lister["UpdateHallTaskRedHint"] = basefunc.handler(self, self.UpdateHallTaskRedHint)
end
 
function C:ReConnecteServerSucceed()
	-- for k,v in pairs(self.task_ids) do
	-- 	Network.RandomDelayedSendRequest("query_one_task_data", {task_id = v})
	-- end
	for k,v in pairs(self.task_ids) do
		self.task_data = self.task_data or {}
		local task_data = GameTaskModel.GetTaskDataByID(v)
		if not task_data then
			Network.RandomDelayedSendRequest("query_one_task_data", {task_id = v})
			self:HideItem(v)
		else
			self.task_data[v] = task_data
			self:RefreshItem(v)
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
	Event.Brocast("ActivityTaskPanel_Exit")
	self:ClearUIList()
	self:ClearUIList_Shop()
	self:ClearUIList_Exchange()
	self:RemoveListener()
	if IsEquals(self.transform) then
		destroy(self.transform.gameObject)
	end
	self.uilist_root = nil
	instance = nil
end

function C:ctor(parent,cfg,goto_scene_call,t_cfg)

	ExtPanel.ExtMsg(self)

	local act_key = cfg.key
	self.act_cfg = cfg
	self.goto_scene_call = goto_scene_call
	self.config = t_cfg
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

	self.goto_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnGotoClick()
	end)

	self:InitConfig()
	self:InitUI()
	self:CloseRedDay()
	self:InitHelpBtn()
	self:InitItemNum()
	Event.Brocast("ActivityTaskPanel_Had_Finish",{panelSelf = self,key = act_key})
	self:ChooseOne("tge1")
	self:UpdateHallTaskRedHint()
	CommonTimeManager.GetCutDownTimer(cfg.endTime,self.cut_time_txt)
	if self.config.base[1].key == "ydkl_ydfl" then
		self.cut_time_txt.color = Color.New(255/255, 255/255, 255/255, 255/255)
	end
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

function C:RefreshRed()
	for k,v in pairs(self.tge_item_table) do
		v.red_point.gameObject:SetActive(PlayerPrefs.GetInt(v.tge_txt.text .. MainModel.UserInfo.user_id,0) == 0)
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

	if base.is_spread and  base.is_spread == 1 then
		rect.sizeDelta = {x = 1092 , y = 670}
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
	PlayerPrefs.SetInt(self.tge_item_table[type].tge_txt.text .. MainModel.UserInfo.user_id, 1)
	self:RefreshRed()
end

function C:CreateGoodsItemsToContent(type, content)
	local data_list = self.config[type]
	table.sort(data_list, function(a, b) return a.id < b.id end)
	for i = 1, #data_list do
		if data_list[i].task then 
			local inst = ActivityTaskItem.Create(content,data_list[i],self.goto_scene_call)
			self.items = self.items or {}
			self.items[data_list[i].task] = self.items[data_list[i].task] or {}
			self.items[data_list[i].task][data_list[i].level] = inst
		elseif data_list[i].shop_id then 
			local inst = ActivityTaskItem.Create(content,data_list[i],self.goto_scene_call)
			self.items_shop = self.items_shop or {}
			self.items_shop[data_list[i].shop_id] = inst
		
		elseif data_list[i].activity_exchange then
			local inst = ActivityTaskItem.Create(content,data_list[i],self.goto_scene_call)
			self.items_exchange = self.items_exchange or {}
			self.items_exchange[#self.items_exchange + 1] = inst
		end
	end
end

function C:InitTaskIds()
	for k,v in pairs(self.config.tge) do
		if v.on_off and v.on_off == 1 then
			for k1,v1 in pairs(self.config[k]) do
				self.task_ids = self.task_ids or {}
				if v1.task then 
					self.task_ids[v1.task] = v1.task
				end 
			end
		end
	end
end

function C:InitData()
	self:InitTaskIds()
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
	self:RefreshItem_Shop()
	self:RefreshItem_Exchange()
	if table_is_null(self.task_data) or
		table_is_null(self.items) then 
		return
	end
	for k,v in pairs(self.task_data) do
		self:RefreshItem(v.id)
	end
end

function C:HideItem(task_id)
	if not IsEquals(self.gameObject) then return end
	if not self.items[task_id] then return end
	for k,v in pairs(self.items[task_id]) do
		if IsEquals(v.gameObject) then
			v:Hide()
		else
			v = nil
		end
	end
end

function C:RefreshItem(task_id)
	if not IsEquals(self.gameObject) then return  end 
	if table_is_null(self.task_data) or
		table_is_null(self.items) or
		not self.items[task_id] or
		not self.task_data[task_id] then 
			return
	end
	for k,v in pairs(self.items[task_id]) do
		if IsEquals(v.gameObject) then
			v:MyRefresh(self.task_data[task_id],self:get_task_count(task_id))
		else
			v = nil
		end
	end
	local tge = self:get_tge_by_task_id(task_id)
	self:SortTgeItems(tge)
	self:RefreshItem_Shop()
	self:RefreshItem_Exchange()
	self:ChooseOne()
end

function C:RefreshItem_Shop()
	if not table_is_null(self.items_shop) then 
		for k,v in pairs(self.items_shop) do
			if IsEquals(v.gameObject) then 
				v:MyRefresh_Shop(k)
			else
				v = nil
			end 
		end
	end 
end

function C:RefreshItem_Exchange()
	if not table_is_null(self.items_exchange) then 
		for k,v in pairs(self.items_exchange) do
			if IsEquals(v.gameObject) then 
				v:Refresh_Exchange(k)
			else
				v = nil
			end 
		end
	end
end


function C:OnAssetChange(data)
	dump(data,"<color=red>----奖励类型-----</color>")
	self:RefreshItem_Shop()
	self:RefreshItem_Exchange()
	self:InitInfo()
	self:RefreshItemNum()
end

function C:OnDestroy()
	self:MyExit()
	destroy(self.gameObject)
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

function C:ClearUIList_Shop()
	if table_is_null(self.items_shop) then return end
	for k, v in pairs(self.items_shop) do
		v:OnDestroy()
	end
	self.items_shop = nil
end

function C:ClearUIList_Exchange()
	if table_is_null(self.items_exchange) then return end
	for k, v in pairs(self.items_exchange) do
		v:OnDestroy()
	end
	self.items_exchange = nil
end


function C:handle_one_task_data_response(data)
	dump(data, "<color=yellow>data</color>")
	if not instance then return end
	if not self.task_ids[data.id] then return end
	instance.task_data = instance.task_data or {}
	instance.task_data[data.id] = data
	instance:RefreshItem(data.id)
end

function C:handle_task_change(data)
	dump(data, "handle_task_change")
	if not instance then return end
	if not self.task_ids[data.id] then return end
	instance.task_data = instance.task_data or {}
	instance.task_data[data.id] = data
	instance:RefreshItem(data.id)
end

function C:check_all_reawrd_state()
	local is_all_get = false
	local tge_get = {}
	for k,v in pairs(self.config.tge) do
		if v.on_off and v.on_off == 1 then
			tge_get[k] = false
		end
	end
	if table_is_null(self.task_ids) then return is_all_get, tge_get end

	for k,v in pairs(tge_get) do
		for k1,v1 in pairs(self.config[k]) do
			if v1.task then 
				if GameTaskModel.check_reward_state(v1.task,self:get_task_count(v1.task)) then
					tge_get[k] = true
					is_all_get = true
					break
				end
			end
		end
	end

	dump(tge_get,"<color=red>tge_gettge_gettge_get</color>")
	for k,v in pairs(tge_get) do
		if IsEquals(self.tge_item_table[k].red_point) then
			self.tge_item_table[k].get_point.gameObject:SetActive(v)
		end
	end
	return is_all_get, tge_get
end

function C:SortTgeItems(tge)
	if not tge then return end
	local tge_task = {}
	for k,v in pairs(self.config[tge]) do
		if v.task then 
			tge_task[v.task] = v.task
		end 
	end
	if table_is_null(tge_task) or table_is_null(self.items) then return end
	local task_index = self.config.tge[tge].task_index
	local getIndexFromId = function(id) 
		for i = 1, #task_index do
			if task_index[i] == id then
				return i
			end
		end
		return 0
	end
	local v = {}
	local tbl = {}

	-- dump(tge_task, "<color=white>tge_task</color>")  
	-- dump(self.config[tge], "<color=white>self.config[tge</color>")  
	for k,v0 in pairs(tge_task) do
		v = self.task_data[k]
		if v then
			local award_status_all = basefunc.decode_task_award_status(v.award_get_status)
			award_status_all = basefunc.decode_all_task_award_status(award_status_all, v, self:get_task_count(v.id))
			-- dump(award_status_all, "<color=white>award_status_all</color>")
			-- local index = 1
			for i,v2 in ipairs(self.config[tge]) do
				if v2.task == k then
					-- if self.config[tge][i].show_in_one and self.config[tge][i].show_in_one == 1 then
						-- 	table.insert(tbl, {cfg = self.config[tge][i], state = v.award_status, progress = v.now_process})
					-- else
							local level = self.config[tge][i].level
							table.insert(tbl, {cfg = self.config[tge][i], state = award_status_all[level], progress = v.now_process})
					-- end
					-- index = index + 1
				end
			end
		end
	end

	-- local tt1 = {}
	-- for i,v in ipairs(tbl) do
	-- 	tt1[#tt1 + 1] = { id = v.cfg.id, indexId =getIndexFromId(v.cfg.id) ,state = v.state}
	-- end
	-- dump(tt1, "<color=white>TTTTTTTT1</color>")

	table.sort(tbl, function(a, b)
		local aId = getIndexFromId(a.cfg.id)
		local bId = getIndexFromId(b.cfg.id)

		local stateA = a.state
		local stateB = b.state

		if stateA == 1 then
            stateA = -1
        end

        if stateB == 1 then
            stateB = -1
        end

		if stateA < stateB then
            return true
        elseif stateA > stateB then
            return false
        elseif aId < bId then
            return true
        elseif aId > bId then
            return false
        end
        return false
	end)

	-- local tt2 = {}
	-- for i,v in ipairs(tbl) do
	-- 	tt2[#tt2 + 1] = { id = v.cfg.id, indexId =getIndexFromId(v.cfg.id) ,state = v.state}
	-- end

	for i,v in ipairs(tbl) do
		if self.items[v.cfg.task] and self.items[v.cfg.task][v.cfg.level] and IsEquals(self.items[v.cfg.task][v.cfg.level].transform) then
			self.items[v.cfg.task][v.cfg.level].transform:SetAsLastSibling()
		end
	end
	return tbl
end

function C:get_task_count(task_id)
	local count = 0
	for k,v in pairs(self.config.tge) do
		for k1,v1 in pairs(self.config[k]) do
			if v1.task == task_id then
				count = count + 1
			end
		end
	end
	return count
end

function C:get_tge_by_task_id(task_id)
	for k,v in pairs(self.config.tge) do
		for i,v1 in ipairs(self.config[k]) do
			if v1.task == task_id then
				return k
			end
		end
	end
end

function C:UpdateHallTaskRedHint()
	self:check_all_reawrd_state()
end

function C:CloseRedDay()
	Event.Brocast("CloseRedDay",{id = self.act_cfg.ID,title=self.act_cfg.title })
	Event.Brocast("UpdateHallTaskRedHint")
end

function C:InitHelpBtn()
	local base = self.config.base[1]
	if base.key == "czcf_21_day_updata" then--充值超返
		self.config.helpinfo = {{text = "1、活动期间完成所有任务总共可获得超过2000福卡。",button_image = "czcf_btn_gz"},
								{text = "2、累计充值任务中购买带有“超值标签”的商品不计入任务。"},
								{text = "3、活动结束后未领取的奖励视为自动放弃，请及时领取所有奖励。"}}
	end
	if base.key == "yjkh_21_day_updata" then--赢金狂欢
		self.config.helpinfo = {{text = "1、活动期间完成所有任务总共可获得超过1.8万福卡。",button_image = "czcf_btn_gz"},
								{text = "2、累计赢金范围包括所有游戏，打鱼类游戏赢金按50%计算。"},
								{text = "3、活动结束后未领取的奖励视为自动放弃，请及时领取所有奖励。"}}
	end
	if self.config.helpinfo == nil or self.config.helpinfo[1] == nil then self.help_btn.gameObject:SetActive(false) return end
	self.help_btn.gameObject:SetActive(true)
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
--刷新道具数量
function C:RefreshItemNum()
	if self.config.base and self.config.base[1].item_key and self.config.base[1].item_prefab and IsEquals(self.gameObject) then
		self.num_prefab_txt.text = "x "..GameItemModel.GetItemCount( self.config.base[1].item_key)
	end
end

function C:InitItemNum()
	if self.config.base and self.config.base[1].item_key and self.config.base[1].item_prefab then
		local temp_ui = {}
		self.num_prefab = newObject(self.config.base[1].item_prefab,self.num_node)
		LuaHelper.GeneratingVar(self.num_prefab.transform,temp_ui)
		self.num_prefab_txt = temp_ui.num_txt
		self.num_prefab_txt.text = "x "..GameItemModel.GetItemCount( self.config.base[1].item_key)
	end
end