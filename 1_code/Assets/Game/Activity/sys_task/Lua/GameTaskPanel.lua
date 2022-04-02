-- 创建时间:2018-10-15
local basefunc = require "Game.Common.basefunc"

GameTaskPanel = basefunc.class()

GameTaskPanel.name = "GameTaskPanel"

local this
local data

function GameTaskPanel.Create(task_type)
    if GameGlobalOnOff.Task == false then
        HintPanel.Create(1,"敬请期待")
        return
    end
    if not this then
        this = GameTaskPanel.New(task_type)
    end
    return this
end

function GameTaskPanel.Close()
    if this then
        this:MyExit()
    end
    this = nil
end

function GameTaskPanel:ctor(task_type)

	ExtPanel.ExtMsg(self)

    self:MakeLister()
    self:AddMsgListener()

    self.task_type = task_type
    local parent = GameObject.Find("Canvas/LayerLv4").transform
    local obj = newObject(GameTaskPanel.name, parent)
    local tran = obj.transform
    self.transform = tran
    self.gameObject = obj
    LuaHelper.GeneratingVar(self.transform, self)
    EventTriggerListener.Get(self.close_btn.gameObject).onClick = basefunc.handler(self, self.OnClickClose)

    self.tgeItem = GetPrefab("GameTaskTgeItem")
    self.taskItem = GetPrefab("GameTaskItem")
    self.svItem = GetPrefab("GameTaskSVItem")
    GameTaskModel.ReqTaskData()
    GameTaskModel.ReqHBData()
end

function GameTaskPanel:MyInit()
    local config = GameTaskModel.GetConfigDataByType()
    self:InitSV(config.task_tge)
    self:InitTge(config.task_tge)
    self:SetTaskList(config.game)
    self:SetTaskList(config.vip)
    self:SetTaskList(config.day)
    self:InitHB()
end

function GameTaskPanel:InitHB()
    local right_txt = self.sv_item_list[GameTaskModel.TaskType.game].right_txt
    EventTriggerListener.Get(right_txt.gameObject).onDown = function()
        local pos = UnityEngine.Input.mousePosition
        local tips = "提升官品等级可增加每日领取的福卡上限"
        GameTipsPrefab.ShowDesc(tips, pos, GameTipsPrefab.TipsShowStyle.TSS_34)
    end
    EventTriggerListener.Get(right_txt.gameObject).onUp = function()
        GameTipsPrefab.Hide()
    end
end

function GameTaskPanel:UpdateHB()
    self.sv_item_list[GameTaskModel.TaskType.game].right_txt.text = "今日可领取" .. StringHelper.ToRedNum(GameTaskModel.data.hb_data.upper_limit / 100) .. "福卡"
end

function GameTaskPanel:MyExit()
    if this then
        self:RemoveListener()
        self.task_type = nil
        self.sv_item_list = nil
        self.tge_item_list = nil
        self.task_item_list = nil
        destroy(self.gameObject)
        this = nil
    end

	 
end

function GameTaskPanel:MakeLister()
    self.lister = {}
    self.lister["model_query_task_data_response"] = basefunc.handler(self, self.on_task_req_data_response)
    self.lister["model_get_task_award_response"] = basefunc.handler(self, self.on_get_task_award_response)
    self.lister["model_get_duiju_hongbao_upper_limit_response"] = basefunc.handler(self, self.on_get_duiju_hongbao_upper_limit_response)

    self.lister["model_task_change_msg"] = basefunc.handler(self, self.on_task_change_msg)
end

function GameTaskPanel:AddMsgListener()
    for proto_name, func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function GameTaskPanel:RemoveListener()
    print("<color=yellow>>>>>>>>remove listener>>></color>")
    for proto_name, func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function GameTaskPanel:on_task_req_data_response()
    self:MyInit()
end

function GameTaskPanel:on_get_duiju_hongbao_upper_limit_response()
    self:UpdateHB()
end

function GameTaskPanel:on_get_task_award_response(data)
    self:RefreshTaskItem(data.id)
    self:UpdateTge()
end

function GameTaskPanel:on_task_change_msg(data)
    self:RefreshTaskItem(data.id)
    self:UpdateTge()
end

--************方法
function GameTaskPanel:SetTaskList(config)
    if config == nil then return end
    for k, v in pairs(config) do
        self:SetTaskItem(v)
    end
end

function GameTaskPanel:SetTaskItem(config)
    local data = GameTaskModel.GetTaskDataByID(config.task_id)
    if data then
        local parent = self.sv_item_list[config.task_type].running_content
        local item = GameObject.Instantiate(self.taskItem, parent)
        local ui_table = {}
        ui_table.transform = item.transform
        ui_table.gameObject = item.gameObject
        LuaHelper.GeneratingVar(item.transform, ui_table)
        ui_table.item_icon_img.sprite = GetTexture(config.icon_image)
        ui_table.item_icon_img:SetNativeSize()
        ui_table.task_info_txt.text = config.desc

        PointerEventListener.Get(ui_table.item_icon_btn.gameObject).onDown = function()
            local key = config.item_key
            local pos = UnityEngine.Input.mousePosition
            local tips = config.tips
            GameTipsPrefab.ShowDesc(tips, pos)
        end
        PointerEventListener.Get(ui_table.item_icon_btn.gameObject).onUp = function()
            GameTipsPrefab.Hide()
        end

        ui_table.get_btn.onClick:AddListener(
            function()
                if config.task_type == GameTaskModel.TaskType.game then
                    Network.SendRequest("get_task_award", {id = config.task_id})
                    GameTaskModel.ReqHBData()
                elseif config.task_type == GameTaskModel.TaskType.vip then
                    local is_vip = true
                    if is_vip then
                        HintPanel.Create(1, "vip未开发")
                    else
                        HintPanel.Create(
                            1,
                            "您当前不是Vip，是否激活Vip获得九大专属权限？",
                            function()
                                HintPanel.Create(1, "vip未开发")
                            end
                        )
                    end
                end
            end
        )

        ui_table.goto_btn.onClick:AddListener(
            function()
                ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
                print("<color=yellow>goto UI</color>",MainModel.Location, MainModel.myLocation)
                GameManager.GotoUI({gotoui=config.gotoUI, goto_scene_parm=config.goto_game_type, call=function ()
                    Event.Brocast("close_task")
                end})
            end
        )
        ui_table.slider = item.transform:Find("@item_task_btn/Slider"):GetComponent("Slider")
        self.task_item_list = self.task_item_list or {}
        self.task_item_list[config.task_id] = ui_table

        self:RefreshTaskItem(config.task_id)
    end
end

function GameTaskPanel:RefreshTaskItem(id)
    local ui_table = self.task_item_list[id]
    local data = GameTaskModel.GetTaskDataByID(id)
    local config = GameTaskModel.GetConfigDataToID(id)

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
        local parent
        if data.award_status == 2 then
            ui_table.over_btn.gameObject:SetActive(true)
            parent = self.sv_item_list[config.task_type].over_content
        elseif data.award_status == 1 then
            ui_table.get_btn.gameObject:SetActive(true)
            parent = self.sv_item_list[config.task_type].finish_content
        elseif data.award_status == 0 then
            ui_table.goto_btn.gameObject:SetActive(true)
            parent = self.sv_item_list[config.task_type].running_content
        end

        ui_table.transform.parent = parent
        --排序
        ui_table.transform:SetSiblingIndex(config.order_id  - 1)
    end
end

--Tge
function GameTaskPanel:UpdateTge()
    dump(self.tge_item_list, "<color=yellow>UpdateTge</color>")
    for k,v in pairs(self.tge_item_list) do
        --任务进度改变（忽略）
        -- v.tge_red.gameObject:SetActive(GameTaskModel.ChangeStatus[k] ~= 0)
        --任务可领取
        v.tge_red.gameObject:SetActive(GameTaskModel.CanGetStatus[k])
    end
end

function GameTaskPanel:InitTge(config)
    local list = {}
    for k, v in pairs(config) do
        list[#list + 1] = v
    end
    table.sort(
        list,
        function(a, b)
            return a.order_id < b.order_id
        end
    )
    for k, v in ipairs(list) do
        self:SetTaskTgeItem(config[v.id])
    end
    self:UpdateTge()
end

function GameTaskPanel:SetTaskTgeItem(config)
    local TG = self.SVSwitch.transform:GetComponent("ToggleGroup")
    local go = GameObject.Instantiate(self.tgeItem, self.tge_content)
    go.gameObject:SetActive(config.is_show == 1)
    go.name = config.id
    local ui_table = {}
    LuaHelper.GeneratingVar(go.transform, ui_table)
    ui_table.item_tge = go.transform:GetComponent("Toggle")
    ui_table.item_tge.group = TG
    ui_table.item_tge.onValueChanged:AddListener(
        function(val)
            ui_table.tge_txt.gameObject:SetActive(not val)
            ui_table.mark_tge_txt.gameObject:SetActive(val)
            ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
            if val then
                self:UpdateMatchInfoUIByTge(config)
                -- GameTaskModel.ChangeModelChangeStatus(config.type, 0)
                ui_table.tge_red.gameObject:SetActive(false)
            end
        end
    )
    ui_table.icon_img.sprite = GetTexture(config.icon_image)
    ui_table.tge_txt.text = config.name
    ui_table.mark_tge_txt.text = config.name

    if self.task_type then
        ui_table.item_tge.isOn = config.type == self.task_type
    else
        if config.id == 1 then
            --默认开启福卡赛
            ui_table.item_tge.isOn = true
        end
    end

    self.tge_item_list = self.tge_item_list or {}
    self.tge_item_list[config.type] = ui_table
end

function GameTaskPanel:InitSV(config)
    for k, v in ipairs(config) do
        self:SetTaskSVItem(v)
    end
end

function GameTaskPanel:SetTaskSVItem(config)
    local go = GameObject.Instantiate(self.svItem, self.Center)
    go.transform:SetSiblingIndex(0)
    go.gameObject:SetActive(false)
    go.name = config.id
    local ui_table = {}
    ui_table.transform = go.transform
    ui_table.gameObject = go.gameObject
    LuaHelper.GeneratingVar(go.transform, ui_table)

    self.sv_item_list = self.sv_item_list or {}
    self.sv_item_list[config.type] = ui_table
end

function GameTaskPanel:UpdateMatchInfoUIByTge(config)
    if config == nil then return end
    self.sv_item_list[GameTaskModel.TaskType.game].gameObject:SetActive(config.type == GameTaskModel.TaskType.game)
    self.sv_item_list[GameTaskModel.TaskType.vip].gameObject:SetActive(config.type == GameTaskModel.TaskType.vip)
    self.sv_item_list[GameTaskModel.TaskType.day].gameObject:SetActive(config.type == GameTaskModel.TaskType.day)
    self.sv_item_list[config.type].content.transform.localPosition = Vector3.New(0, 0, 0)
end
--OnClick**********************************
function GameTaskPanel:OnClickClose(go)
    ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
    Event.Brocast("close_task")
end

--[[
    GetTexture("task_icon_hb")
]]