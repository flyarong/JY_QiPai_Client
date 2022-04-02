-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"

AccurateTaskPanel = basefunc.class()

AccurateTaskPanel.name = "AccurateTaskPanel"

local this
local data

function AccurateTaskPanel.Create(backcall)
    return AccurateTaskPanel.New(backcall)
end

function AccurateTaskPanel.Close()
    if this then
        this:MyExit()
    end
    this = nil
end

function AccurateTaskPanel:ctor(backcall)
    this = self
	ExtPanel.ExtMsg(self)

    self:MakeLister()
    self:AddMsgListener()
    local parent = GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(AccurateTaskPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    self.backcall = backcall
    self.gameObject:SetActive(false)
    LuaHelper.GeneratingVar(self.transform, self)
	EventTriggerListener.Get(self.back_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)
    self:OnRefresh_XYJL_UI()
    GameTaskModel.ReqTaskData()
end

function AccurateTaskPanel:MyInit()
    self.config = SYSXYJLManager.GetTaskAccurateCfg()
    self:SetTaskList(self.config)
    self.task_data = SYSXYJLManager.GetAccurateTaskData()
    self.have_shop_data = (XYJLShopManager.GetData() and os.time() < XYJLShopManager.GetMaxTime() and os.time() > XYJLShopManager.GetMinTime())
    if not self.task_data and not self.have_shop_data then 
        if not self.backcall then 
            self.time_txt.text = "已结束"
        else
            self.backcall()
            self.backcall = nil
        end
        self:MyExit() 
        return
    end
    self.gameObject:SetActive(true)
    local cur_data = {}
    if self.task_data then
        for k,v in pairs(self.task_data) do
            cur_data = v
        end
    end
    self.time_txt.text = "活动时间:" .. os.date("%m月%d日%H点-", cur_data.start_valid_time or XYJLShopManager.GetMinTime()) .. os.date("%m月%d日%H点", cur_data.end_valid_time or XYJLShopManager.GetMaxTime()) 
end

function AccurateTaskPanel:MyExit()
    -- print(debug.traceback())
    if this then
        if self.backcall then 
            self.backcall()
            self.backcall = nil
        end 
        self:RemoveListener()
        self.task_item_list = nil
        destroy(self.gameObject)
        this = nil
    end

	 
end

function AccurateTaskPanel:OnExitScene(  )
	if this then
        this:MyExit()
    end
end

function AccurateTaskPanel:MakeLister()
    self.lister = {}
    self.lister["model_query_task_data_response"] = basefunc.handler(self, self.on_task_req_data_response)
    self.lister["model_get_task_award_response"] = basefunc.handler(self, self.on_get_task_award_response)
    self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_task_change_msg)
	self.lister["model_task_item_change_msg"] = basefunc.handler(self, self.model_task_item_change_msg)
	self.lister["model_query_one_task_data_response"] = basefunc.handler(self, self.model_query_one_task_data_response)
	
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	self.lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
    self.lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
    self.lister["Refresh_XYJL_UI"] = basefunc.handler(self,self.OnRefresh_XYJL_UI)
end

function AccurateTaskPanel:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function AccurateTaskPanel:RemoveListener()
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function AccurateTaskPanel:on_task_req_data_response()
    self:MyInit()
end

function AccurateTaskPanel:on_get_task_award_response(data)
    self:RefreshTaskItem(data.id)
end

function AccurateTaskPanel:on_task_change_msg(data)
    self:RefreshTaskItem(data.id)
end

function AccurateTaskPanel:model_task_item_change_msg(data)
	for k,v in pairs(data.task_item) do
        if v.change_type == "add" then
			
        elseif v.change_type == "delete" then
            if not table_is_null(self.task_item_list) then
                if IsEquals(self.task_item_list[v.task_id]) then
                    destroy(self.task_item_list[v.task_id].gameObject)
                end
                self.task_item_list[v.task_id] = nil
            end
        end
    end
end

function AccurateTaskPanel:model_query_one_task_data_response(data)
    local t_cfg = SYSXYJLManager.GetTaskAccurateCfg(data.id)
    if not t_cfg or not next(t_cfg) then return end
    self:SetTaskItem(t_cfg)
end
--************方法
function AccurateTaskPanel:SetTaskList(config)
    if config == nil then return end
    for k, v in pairs(config) do
        self:SetTaskItem(v)
    end

    if self.task_item_list and next(self.task_item_list) then
        local list = {}
        for k, v in pairs(self.task_item_list) do
            list[#list + 1] = v
        end
        table.sort(
            list,
            function(a, b)
                return tonumber(a.gameObject.name) < tonumber(b.gameObject.name)
            end
        )

        for i,v in ipairs(list) do
            v.transform:SetAsLastSibling()
        end
    end
end

function AccurateTaskPanel:SetTaskItem(config)
    if not config or not next(config) or not config.task_id then return end
    local data = GameTaskModel.GetTaskDataByID(config.task_id)
    if self.task_item_list and config and self.task_item_list[config.task_id] then
        return
    end
    if data then
        local parent = self.TaskNode.transform
        local item = GameObject.Instantiate(self.GameTaskItem, parent)
        ClipUIParticle(item.transform)
        item.gameObject.name = config.order_id
        local ui_table = {}
        ui_table.transform = item.transform
        ui_table.gameObject = item.gameObject
        LuaHelper.GeneratingVar(item.transform, ui_table)
        -- ui_table.item_icon_img.sprite = GetTexture(config.icon_image)
        -- ui_table.item_icon_img:SetNativeSize()
        ui_table.task_info_txt.text = config.desc
        -- ui_table.item_icon_txt.text = config.award_desc
        local award_cfg = SYSXYJLManager.GetTaskAccurateAwardCfg(config.task_id)
		-- if #award_cfg == 1 then
		-- 	PointerEventListener.Get(ui_table.item_icon_btn.gameObject).onDown = function()
		-- 		local pos = UnityEngine.Input.mousePosition
		-- 		local tips = config.tips
		-- 		GameTipsPrefab.ShowDesc(tips, pos)
		-- 	end
		-- 	PointerEventListener.Get(ui_table.item_icon_btn.gameObject).onUp = function()
		-- 		GameTipsPrefab.Hide()
		-- 	end	
		-- else
		-- 	PointerEventListener.Get(ui_table.item_icon_btn.gameObject).onClick = function()
		-- 		self:ShowTaskAward(award_cfg)
		-- 	end
		-- end
        for i=1,#award_cfg do
            local temp_ui = {}
            local b  = GameObject.Instantiate(self.item_icon_btn.gameObject,ui_table.AwardNode)
            b.gameObject:SetActive(true)
            LuaHelper.GeneratingVar(b.transform, temp_ui)
            temp_ui.item_icon_img.sprite = GetTexture(award_cfg[i].icon)
            temp_ui.item_icon_txt.text = award_cfg[i].desc
            PointerEventListener.Get(b.gameObject).onDown = function()
                local pos = UnityEngine.Input.mousePosition
                local tips = award_cfg[i].tip
                GameTipsPrefab.ShowDesc(tips, pos)
            end
            PointerEventListener.Get(b.gameObject).onUp = function()
                GameTipsPrefab.Hide()
            end	
        end

        ui_table.get_btn.onClick:AddListener(
            function()
				Network.SendRequest("get_task_award", {id = config.task_id})
            end
        )
        ui_table.goto_btn.onClick:AddListener(
            function()
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                GameManager.GotoUI(config.gotoUI[1], config.gotoUI[2],function ()
                    AccurateTaskPanel.Close()
                end)
            end
        )
		ui_table.slider = item.transform:Find("Slider"):GetComponent("Slider")
        self.task_item_list = self.task_item_list or {}
        self.task_item_list[config.task_id] = ui_table
		item.gameObject:SetActive(true)
        self:RefreshTaskItem(config.task_id)
    end
end

function AccurateTaskPanel:RefreshTaskItem(id)
    if not self.task_item_list or not next(self.task_item_list) then return end
    local ui_table = self.task_item_list[id]
    local data = GameTaskModel.GetTaskDataByID(id)
    local config = SYSXYJLManager.GetTaskAccurateCfg(id)

    if data and ui_table and config then
        local now_process = data.now_process
        local need_process = data.need_process

        ui_table.progress_txt.text = now_process .. "/" .. need_process  
        local process = now_process / need_process
        if process > 1 then
            process = 1
        end
        ui_table.slider.value = process == 0 and 0 or 0.95 * process + 0.05

        ui_table.over_btn.gameObject:SetActive(false)
        ui_table.get_btn.gameObject:SetActive(false)
        ui_table.goto_btn.gameObject:SetActive(false)
        if data.award_status == 2 then
            ui_table.over_btn.gameObject:SetActive(true)
        elseif data.award_status == 1 then
            ui_table.get_btn.gameObject:SetActive(true)
        elseif data.award_status == 0 then
            ui_table.goto_btn.gameObject:SetActive(true)
        end

        ui_table.transform.parent = self.TaskNode.transform
    end
end

function AccurateTaskPanel:ShowTaskAward(data)
	TaskAwardPanel.Create(data)
end

--OnClick**********************************
function AccurateTaskPanel:OnClickClose(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    AccurateTaskPanel.Close()
end

function AccurateTaskPanel:OnRefresh_XYJL_UI()
    local parent = self.TaskNode.transform  
    data = XYJLShopManager.GetData()
    dump(data,"<color=red>拼接好的精准推送礼包的数据</color>")
    if not table_is_null(data) then 
        for i=1,#data.gift_bag do
            local obj = self.TaskNode.transform:Find(data.gift_bag[i].config.id.."_SHOP")
            if not obj then
                if os.time() < tonumber(data.gift_bag[i].end_time)  and os.time() > tonumber(data.gift_bag[i].start_time) then                 
                    local item = GameObject.Instantiate(self.GameTaskItem, parent)
                    ClipUIParticle(item.transform)
                    item.gameObject.name = data.gift_bag[i].config.id.."_SHOP"
                    local ui_table = {}
                    ui_table.transform = item.transform
                    ui_table.gameObject = item.gameObject
                    LuaHelper.GeneratingVar(item.transform, ui_table)
                    ui_table.task_info_txt.text = "<color=#a7310eff><size=44>"..data.gift_bag[i].config.pay_title.."</size></color>"
                    item.gameObject:SetActive(true)
                    item.gameObject.transform:Find("")
                    item.gameObject.transform:SetSiblingIndex(0)
                    item.gameObject.transform:Find("Slider").gameObject:SetActive(false)
                    ui_table.goto_btn.gameObject.transform:Find("goto_btn/Text"):GetComponent("Text").text = (data.gift_bag[i].config.price/100).."元领取"
                    self:SetShopButton(ui_table,data.gift_bag[i].status) 
                    ui_table.goto_btn.onClick:AddListener(
                        function()
                            AccurateTaskPanel:GoBuy(data.gift_bag[i].config.id)
                        end
                    )
                    local award_cfg = data.gift_bag[i].config.buy_asset_type
                    for j=1,#award_cfg do
                        local temp_ui = {}
                        local b  = GameObject.Instantiate(self.item_icon_btn.gameObject,ui_table.AwardNode)
                        b.gameObject:SetActive(true)
                        LuaHelper.GeneratingVar(b.transform, temp_ui)
                        local item = GameItemModel.GetItemToKey(award_cfg[j])
                        temp_ui.item_icon_img.sprite = GetTexture(item.image)
                        temp_ui.item_icon_txt.text = data.gift_bag[i].config.content[j]
                        if j ~= 1 then 
                            temp_ui.add.gameObject:SetActive(true)
                        end
                        local gift_num =  data.gift_bag[i].config.gift_asset_type == nil and 0 or #data.gift_bag[i].config.gift_asset_type
                        if j > (#award_cfg - gift_num) then 
                            temp_ui.zeng.gameObject:SetActive(true)
                        end
                    end
                end
            else
                if IsEquals(obj) then
                    if os.time() < tonumber(data.gift_bag[i].end_time) and os.time() > tonumber(data.gift_bag[i].start_time) then      
                        local ui_table = {}
                        ui_table.transform = obj.transform
                        ui_table.gameObject = obj.gameObject
                        LuaHelper.GeneratingVar(obj.transform, ui_table)
                        self:SetShopButton(ui_table,data.gift_bag[i].status) 
                        obj.gameObject.transform:SetSiblingIndex(0)
                    else
                        obj.gameObject:SetActive(false)
                    end 
                end 
            end
        end
    end 
end

function AccurateTaskPanel:GoBuy(shopid)
    local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100))
    end
end

function AccurateTaskPanel:SetShopButton(ui_table,status) 
    if status == 1 then 
        ui_table.goto_btn.gameObject:SetActive(true)
        ui_table.get_btn.gameObject:SetActive(false)
        ui_table.over_btn.gameObject:SetActive(false)
        ui_table.goto_btn.gameObject.transform:Find("goto_btn"):GetComponent("Image").sprite = GetTexture("com_btn_5")
        ui_table.goto_btn.enabled = true
    else
        ui_table.goto_btn.gameObject:SetActive(true)
        ui_table.get_btn.gameObject:SetActive(false)
        ui_table.over_btn.gameObject:SetActive(false)
        ui_table.goto_btn.gameObject.transform:Find("goto_btn"):GetComponent("Image").sprite = GetTexture("com_btn_8")
        ui_table.goto_btn.enabled = false
    end 
end