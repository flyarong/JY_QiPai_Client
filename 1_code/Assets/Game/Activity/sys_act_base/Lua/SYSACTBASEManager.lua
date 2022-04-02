local basefunc = require "Game.Common.basefunc"
SYSACTBASEManager = basefunc.class()
local M = SYSACTBASEManager
M.key = "sys_act_base"
local style_config = GameButtonManager.ExtLoadLua(M.key, "sys_act_base_style")
local config = GameButtonManager.ExtLoadLua(SYSACTBASEManager.key,"game_activity_config")

GameButtonManager.ExtLoadLua(M.key, "SYSACTBASEEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityYearPanel")
GameButtonManager.ExtLoadLua(M.key, "ActivityYearLeftPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityYearRightPrefab")
GameButtonManager.ExtLoadLua(M.key, "ActivityYearNoticePrefab")

local ForceChangeIndex = {}
local task_maps = {}
local active_map = {}

--进入场景时弹出面板
local show_panel_enter_location = {
    "game_EliminateSH",
    "game_EliminateCS",
    "game_EliminateCJ",
    "game_EliminateXY",
    "game_EliminateSG",
    "game_EliminateBS",
    "game_EliminateFX",
    "game_Eliminate",
    "game_Zjd",
    "game_TTL",
    "game_ZPG",
    "game_DMBJ",
}

--加载完成显示
local show_panel_loaded_location = {
    "game_FishingDR",
    "game_Fishing",
    "game_LWZB",
    "game_RXCQ",
}

function M.IsHaveAct(parm)
    local a = M.GetActiveTagData(parm.goto_type)
    if a and #a > 0 then 
        return true
    end
end

function M.CheckIsShow(parm)
    if M.IsHaveAct(parm)  then
        if parm.goto_scene_parm == "enter" and MainModel.myLocation == "game_Eliminate" and MainModel.UserInfo.ui_config_id == 2 then
            return false
        end
        return true
    end 
end
function M.CreateHallAct(parent, backcall, parm)
    return ActivityYearPanel.Create("normal", parent, backcall, parm)
end
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        return ActivityYearPanel.Create(parm.goto_type, nil, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return SYSACTBASEEnterPrefab.Create(parm.parent, parm.goto_type)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

local this
local lister
local function AddLister()
    for msg,cbk in pairs(lister) do
        Event.AddListener(msg, cbk)
    end
end
local function RemoveLister()
    if lister then
        for msg,cbk in pairs(lister) do
            Event.RemoveListener(msg, cbk)
        end
    end
    lister=nil
end
local function MakeLister()
    lister = {}
    lister["quit_game_success"] = this.quit_game_success

    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["EnterScene"] = this.OnEnterScene
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed

    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["global_hint_state_change_msg"] = this.on_global_hint_state_change_msg
    lister["UpdateHallActivityYearRedHint"] = this.UpdateHallActivityYearRedHint

    lister["ui_button_data_change_msg"] = this.on_ui_button_data_change_msg
    lister["loding_finish"] = this.on_loading_finish
    lister["year_btn_created"] = this.on_year_btn_created
end

function M.GetIDByGotoUI(parm)
    if not parm then return end 
    local gotoui = parm.gotoui or parm.key -- 有些消息传的是key，后面要统一
    if this.UIConfig and this.UIConfig.activity_map then
        if not parm.goto_type then
            local list = this.UIConfig.activity_map[gotoui]
            if list then
                for k,v in ipairs(list) do
                    local cfg = this.UIConfig.config_id_map[v]
                    if M.ActivityIsHave(cfg) then
                        return v
                    end
                end
            end
        end
        if parm.goto_type and this.UIConfig.activity_map[gotoui] then
            local list = this.UIConfig.activity_map[gotoui][parm.goto_type]
            if list then
                for k,v in ipairs(list) do
                    local cfg = this.UIConfig.config_id_map[v]
                    if M.ActivityIsHave(cfg) then
                        return v
                    end
                end
            end
        end
    end
end

function M.GetGotoUIByID(id)
    if this.UIConfig.config_id_map then
        v =  this.UIConfig.config_id_map[id]
        if v and v.gotoUI then
            local parm = {}
            SetTempParm(parm, v.gotoUI, "panel")
            return parm
        end
    end
end

function M.on_ui_button_data_change_msg(parm)
    local id = M.GetIDByGotoUI( parm )
    if id then
        -- 同一消息不能在同一帧连续广播
        -- 广播消息"aaa" -> fun1() 收到后不能立刻广播消息"aaa"，得等一帧
        coroutine.start(function ( )
            Yield(0)
            local cfg = this.UIConfig.config_id_map[id]
            Event.Brocast("ui_button_data_change_msg", { key = M.key, goto_type = cfg.act_type })
        end)
    end
end

function M.on_global_hint_state_change_msg(parm)
    local id = M.GetIDByGotoUI(parm)
    if not id then
        return
    end
    local state = GameManager.GetHintState(parm)

    if this.activityRedMap[id] == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
        return
    end
    if not state or state == ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
        this.activityRedMap[id] = nil
    else
        this.activityRedMap[id] = state
    end
    Event.Brocast("UpdateHallActivityYearRedHint")
end

function M.Init()
	M.Exit()
	this = M
	MakeLister()
    AddLister()
    M.InitUIConfig()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    this.UIConfig = 
    {
        config_list = {},
        config_map = {},
        config_id_map = {},
    }

    this.UIConfig.style_list = {}
    this.UIConfig.style_map = {}
    for k,v in ipairs(style_config) do
        this.UIConfig.style_list[#this.UIConfig.style_list + 1] = v
        this.UIConfig.style_map[v.key] = this.UIConfig.style_map[v.key] or {}
        this.UIConfig.style_map[v.key][#this.UIConfig.style_map[v.key] + 1] = v
    end

    this.activityRedMap = {}

    this.UIConfig.activity_map = {}
    for k,v in ipairs(config.config) do
        if v.is_on_off == 1 then
            if v.showType == "notice" then
                v.local_type = "notice"
            else
                v.local_type = "activity"
            end
            this.UIConfig.config_list[#this.UIConfig.config_list + 1] = v
            this.UIConfig.config_map[v.act_type] = this.UIConfig.config_map[v.act_type] or {}
            this.UIConfig.config_map[v.act_type][#this.UIConfig.config_map[v.act_type] + 1] = v
            this.UIConfig.config_id_map[v.ID] = v

            if v.gotoUI then
                local parm = {}
                SetTempParm(parm, v.gotoUI, "panel")
                if parm.goto_type then
                    this.UIConfig.activity_map[parm.gotoui] = this.UIConfig.activity_map[parm.gotoui] or {}
                    this.UIConfig.activity_map[parm.gotoui][parm.goto_type] = this.UIConfig.activity_map[parm.gotoui][parm.goto_type] or {}
                    this.UIConfig.activity_map[parm.gotoui][parm.goto_type][#this.UIConfig.activity_map[parm.gotoui][parm.goto_type] + 1] = v.ID
                else
                    this.UIConfig.activity_map[parm.gotoui] = this.UIConfig.activity_map[parm.gotoui] or {}
                    this.UIConfig.activity_map[parm.gotoui][#this.UIConfig.activity_map[parm.gotoui] + 1] = v.ID
                end
            end
        end
    end
end

function M.ActivityIsHave(v)
    local nowT = os.time()
    if CheckTimeInRange(nowT, v.beginTime, v.endTime) then
        local aa,bb = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint = true}, "CheckCondition")
        if aa and bb then
            local parm = {condi_key = v.condi_key}
            SetTempParm(parm, v.gotoUI, "panel")
            if parm.gotoui then
                if parm.gotoui == "shop" then
                    if MainModel.GetGiftShopShowByID(parm.goto_scene_parm) then
                        return true
                    end
                else
                    if GameButtonManager.GetModuleByKey(parm.gotoui) then
                        local a, b = GameButtonManager.RunFun(parm, "CheckIsShow")
                        if a and b then
                            return true
                        end
                    else
                        return true
                    end
                end
            else
                return true
            end
        end
    end
    return false
end
function M.GetActiveTagData(goto_type, tag)
    if not this.UIConfig or not this.UIConfig.config_map or not this.UIConfig.config_map[goto_type] then
        return {}
    end
    local list = this.UIConfig.config_map[goto_type]

    local tagMap = {"activity", "notice"}
    local tagStr = tagMap[tag]

    local data = {}
    local nowT = os.time()
    for k,v in ipairs(list) do
        if (not tagStr or v.local_type == tagStr) and M.ActivityIsHave(v) then
            data[#data + 1] = v
        end
    end
    return data
end


--强制改变某一个分栏得排序，index是排第几个，如果想要给到最后，就给高点得值就可以了，会自动计算到最大得值,
--call是满足什么条件，没有call就默认满足，有call就是call返回值为true的时候才强制修改
--脱离了order排序，不是通过修改order来排序，因为如果原数据中order有相同的，可能会有问题
function M.ForceToChangeIndex(key,index,call)
    local data = {}
    data.key = key
    data.index = index
    data.call = call
    ForceChangeIndex[#ForceChangeIndex + 1] = data
end

function M.ReSetOrder(activityList)
    local find_index_by_key_func = function(key)
        for i = 1,#activityList do
            if activityList[i].gotoUI and activityList[i].gotoUI[1] == key then
               return i
            end
        end
    end

    for i = 1,#ForceChangeIndex do
        local index = find_index_by_key_func(ForceChangeIndex[i].key)
        if index then
            if not ForceChangeIndex[i].call or ForceChangeIndex[i].call() then
                local data = activityList[index]
                local max_index = #activityList
                table.remove(activityList, index)
                table.insert(activityList,ForceChangeIndex[i].index >= max_index and max_index or ForceChangeIndex[i].index,data)
            end
        end
    end
    return activityList
end

local GetActivityRedKey = function (id)
    return "ActivityYearRedKey_UserID" .. MainModel.UserInfo.user_id .. "_ID" .. id
end

function M.IsActiveRedHint(id)
    if this.activityRedMap and this.activityRedMap[id] and this.activityRedMap[id] == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
        if this.UIConfig.config_id_map[id] and (this.UIConfig.config_id_map[id].beginTime == -1 or this.UIConfig.config_id_map[id].beginTime <= os.time()) and 
        (this.UIConfig.config_id_map[id].endTime == -1 or this.UIConfig.config_id_map[id].endTime >= os.time()) then
            return true
        end
    end
    return false
end

function M.IsActiveGetHint(id)
    if this.activityRedMap and this.activityRedMap[id] == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
        if this.UIConfig.config_id_map[id] and (this.UIConfig.config_id_map[id].beginTime == -1 or this.UIConfig.config_id_map[id].beginTime <= os.time()) and 
        (this.UIConfig.config_id_map[id].endTime == -1 or this.UIConfig.config_id_map[id].endTime >= os.time()) then
            return true
        end
    end
    return false
end
function M.OnLoginResponse(result)
    if result == 0 then
    end
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_Hall" then
        M.InitActiveRedHint()
    end
end

function M.on_loading_finish()
    M.ShowPanel(show_panel_loaded_location)
end

function M.on_year_btn_created()
    M.ShowPanel(show_panel_enter_location)
end

function M.ShowPanel(show_tab)
    for i = 1,#show_tab do
        if MainModel.myLocation == show_tab[i] then
            local _backcall = function()
                Event.Brocast("year_panel_exit")
            end
            local parm = {gotoui = M.key, goto_type = "weekly", goto_scene_parm = "panel" , backcall= _backcall}
            GameManager.GotoUI(parm)
        end
    end
end

function M.OnReConnecteServerSucceed()
    
end

-- 清除红点标记
function M.CloseActiveRedHint(id)
    if this.activityRedMap and this.activityRedMap[id] then
        PlayerPrefs.SetString(GetActivityRedKey(id), os.time())
        if this.activityRedMap[id] == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
            return
        end
        this.activityRedMap[id] = nil
        local gotoui = M.GetGotoUIByID(id)
        if gotoui then
            Event.Brocast("global_hint_state_set_msg",gotoui)
        end
        Event.Brocast("UpdateHallActivityYearRedHint")
    end
end

function M.InitActiveRedHint(goto_type)
    if not goto_type then
        for k,v in pairs(this.UIConfig.config_map) do
            M.InitActiveRedHint(k)
        end
        Event.Brocast("UpdateHallActivityYearRedHint")
    else
        local cfg = M.GetActiveTagData(goto_type)
        for k,v in ipairs(cfg) do
            local ss = PlayerPrefs.GetString(GetActivityRedKey(v.ID), "")
            -- v.local_type == "activity"
            if v.showType == "prefab" then
                local parm = {condi_key = v.condi_key}
                SetTempParm(parm, v.gotoUI, "panel")
                local a,b = GameButtonManager.RunFunExt(parm.gotoui, "GetHintState", nil, parm)
                if a and b ~= ACTIVITY_HINT_STATUS_ENUM.AT_Nor then
                    this.activityRedMap[v.ID] = b
                elseif ss == "" then
                    this.activityRedMap[v.ID] = ACTIVITY_HINT_STATUS_ENUM.AT_Red
                end
            else
                if ss == "" then
                    this.activityRedMap[v.ID] = ACTIVITY_HINT_STATUS_ENUM.AT_Red
                end
            end
        end
    end
end

--游戏退出成功
function M.quit_game_success()
    -- if not table_is_null(this.gotoUI) then
    --     local gotoUI = this.gotoUI
    --         if gotoUI then
    --             GameManager.GotoUI({gotoui=gotoUI[1], goto_scene_parm=gotoUI[2]})
    --         end
    --     this.gotoUI = nil
    -- end    
end

-- 活动的提示状态
function M.GetHintState(parm)
    local state = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    if this.activityRedMap and next(this.activityRedMap) then
        for k,v in pairs(this.activityRedMap) do
            local cfg = this.UIConfig.config_id_map[k]
            if cfg and cfg.act_type == parm.goto_type then
                if v == ACTIVITY_HINT_STATUS_ENUM.AT_Get then
                    state = ACTIVITY_HINT_STATUS_ENUM.AT_Get
                    break
                end
                if v == ACTIVITY_HINT_STATUS_ENUM.AT_Red then
                    state = ACTIVITY_HINT_STATUS_ENUM.AT_Red
                end
            end
        end
    end
    return state
end

function M.SetHintState(parm)
	if parm.gotoui == M.key then
		PlayerPrefs.SetInt(M.key .. MainModel.UserInfo.user_id  ..os.date("%x",os.time()),1)
		Event.Brocast("global_hint_state_change_msg", parm)
	end
end

function M.on_global_hint_state_set_msg(parm)
    if parm.gotoui == M.key then
        M.SetHintState(parm)
    end
end

function M.UpdateHallActivityYearRedHint()

end

function M.GetBtnNodeHint()
    local key = "act_033_fkzjd"
    local isOpen, hint = GameButtonManager.RunFun({gotoui = key,}, "GetHintState")
    if isOpen then
        return hint
    end
    return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end

-- 皮肤
function M.GetStyleConfig(goto_type)
    local cfg = basefunc.deepcopy(this.UIConfig.style_list[1])
    if not this.UIConfig or not this.UIConfig.style_map or not this.UIConfig.style_map[goto_type] then
        return cfg
    end

    local list = this.UIConfig.style_map[goto_type]
    local cur_t = os.time()
    for k,v in ipairs(list) do
        if CheckTimeInRange(cur_t, v.beginTime, v.endTime) then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=v.condi_key, is_on_hint = true}, "CheckCondition")
            if a and b then
                cfg = basefunc.deepcopy(v)
                break
            end
        end
    end
    cfg.prefab_map = {}
    if cfg.prefab_list then
        for k,v in ipairs(cfg.prefab_list) do
            cfg.prefab_map[v] = 1
        end
    end
    return cfg
end