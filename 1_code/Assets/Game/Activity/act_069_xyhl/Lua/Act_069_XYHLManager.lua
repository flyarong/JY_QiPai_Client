-- 创建时间:2021-11-17
-- Act_069_XYHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_069_XYHLManager = {}
local M = Act_069_XYHLManager
M.key = "act_069_xyhl"
local config = GameButtonManager.ExtLoadLua(M.key, "act_069_xyhl_config")
GameButtonManager.ExtLoadLua(M.key, "Act_069_XYHLBasePanel")
GameButtonManager.ExtLoadLua(M.key, "Act_069_XYHLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_069_XYHLTaskPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_069_XYHLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_069_XYHLBindIdPanel")

local this
local lister
M.is_debug = false
M.panel_cfg = {
    [1] = {
        name = "新游豪礼",
        panel = "Act_069_XYHLPanel",
        key = "xyhl",
    },
    [2] = {
        name = "充值福利",
        panel = "Act_069_XYHLTaskPanel",
        key = "czfl",
    },
    [3] = {
        name = "赢金福利",
        panel = "Act_069_XYHLTaskPanel",
        key = "yjfl",
    },
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    if not this.can_show then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    else
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow(parm, type)
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        dump(parm, "<color=red>不满足条件</color>")
        return
    end

    if parm.goto_scene_parm == "enter" then
        return Act_069_XYHLEnterPrefab.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end


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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["xyhl_get_new_game_player_info_response"] = this.on_xyhl_get_new_game_player_info_response
    lister["xyhl_set_new_game_player_id_response"] = this.on_xyhl_set_new_game_player_id_response

    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_vip_upgrade_change_msg"] = this.on_model_vip_upgrade_change_msg
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response

    lister["vip_show_mzfl_panel_create"] = this.on_vip_show_mzfl_panel_create
end

function M.Init()
	M.Exit()

	this = Act_069_XYHLManager
	this.m_data = {}
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

local function AddStateData(task_id, task_lv)
    for i = this.taskData[task_id].task_lv, task_lv do
        this.taskData[task_id].state[i] = 0
    end
    this.taskData[task_id].task_lv = task_lv
end

local function MakeNewData(task_lv, task_total)
    local data = {}
    if not task_lv then
        data.state = 0
    else
        data.state = MakeNewStateData(task_lv)
    end
    data.now_total_process = 0
    data.need_process = task_total or 0
    data.task_lv = task_lv
    return data
end

function M.InitData()
    this.taskData = {}
    local checkAndMakeData = function(task_id, task_lv, task_total)
        if not this.taskData[task_id] then
            this.taskData[task_id] = MakeNewData(task_lv, task_total)
        elseif this.taskData[task_id].task_lv and this.taskData[task_id].task_lv < task_lv then
            AddStateData(task_id, task_lv)
        end
    end
    for i = 1, #config.yjfl do
        local task_id = config.yjfl[i].task_id
        local task_lv = config.yjfl[i].task_lv
        local task_total = config.yjfl[i].task_total
        checkAndMakeData(task_id, task_lv, task_total)
    end
    for i = 1, #config.czfl  do
        local task_id = config.czfl[i].task_id
        local task_lv = config.czfl[i].task_lv
        local task_total = config.czfl[i].task_total
        checkAndMakeData(task_id, task_lv, task_total)
    end
end

function M.QueryMainData()
    dump("<color=yellow>请求新游豪礼数据</color>")
    if M.is_debug then
        Event.Brocast("xyhl_get_new_game_player_info_response","xyhl_get_new_game_player_info_response", {is_download = true,new_id = 888888,new_vip = 2,new_ljyj = 555551,new_ljcz = 6})
    else
        Network.SendRequest("xyhl_get_new_game_player_info")
    end
end

function M.QueryBind(id)
    dump(id, "<color=white> 绑定Id </color>")
    local cheakFormat = function(id)
        if id == nil then
            return false
        end

        if id == "" then
            return false
        end
        return true
    end
    if not cheakFormat(id) then
        return
    end
    if M.is_debug then
        Event.Brocast("xyhl_set_new_game_player_id_response","xyhl_set_new_game_player_id_response",{result = 0,id = 888888})
    else
        this.m_data.send_id = id
        Network.SendRequest("xyhl_set_new_game_player_id",{new_game_player_id = id})
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
    M.InitData()
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.QueryMainData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetIndexSortMap()
    local isDownloadNewGame = this.m_data.is_download == 1 or false
    if isDownloadNewGame then
        return {2, 3, 1}
    else
        return {1, 2, 3}
    end
end

function M.on_xyhl_get_new_game_player_info_response(_,data)
    dump(data,"<color=yellow><size=15>+++++新游豪礼主数据+++++</size></color>")
    if data then
        if data.result == 0 then
            this.m_data.is_download = data.is_download
            this.m_data.cpl_p_key = data.cpl_p_key
            this.m_data.new_id = data.new_game_player_id
            this.m_data.new_vip = data.new_game_player_vip_level
            this.m_data.bind_time = data.bind_time
            this.can_show = true
            Event.Brocast("model_xyhl_get_data_msg")
            Event.Brocast("ui_button_state_change_msg")
        elseif data.result == -1 then
            this.can_show = false
            Event.Brocast("ui_button_state_change_msg")
        end
    end
end

function M.on_xyhl_set_new_game_player_id_response(_,data)
    dump(data,"<color=yellow><size=15>+++++新游豪礼绑定++++++</size></color>")
    if data.result == 0 then
        this.m_data.new_id = this.m_data.send_id
        this.m_data.new_vip = data.new_game_player_vip_level
        Event.Brocast("model_xyhl_bind_success_msg")
        LittleTips.Create("绑定成功")
    else
        this.m_data.send_id = nil
        this.m_data.setIdFailTime = os.time()
        Event.Brocast("model_xyhl_bind_fail_msg")
        LittleTips.Create("ID错误，请核实后再输入")
    end
end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    if data then
        for k,v in pairs(data) do
            M.HandleTaskData(v)
        end
    end
end

function M.on_model_task_change_msg(data)
    if data then
        M.HandleTaskData(data)
    end
end

function M.on_model_vip_upgrade_change_msg()
    local a, vip = GameButtonManager.RunFun({gotoui="vip"}, "get_vip_level")
    if a and vip >= 6 then
        M.QueryMainData()
    end
end

function M.on_vip_show_mzfl_panel_create(panelUI)
    if not M.IsActive() then
        return
    end
    local itemObj = GameObject.Instantiate(panelUI.VIPMZFLChild,panelUI.VIPMZFLContent)
    local itemObjUI = {}
    LuaHelper.GeneratingVar(itemObj, itemObjUI)
    itemObj.gameObject:SetActive(true)
    itemObjUI.nameTxt = itemObj.transform:Find("Text"):GetComponent("Text")
    itemObjUI.goBtn = itemObj.transform:Find("GOButton"):GetComponent("Button")
    itemObjUI.overImg =  itemObj.transform:Find("MASK")

    itemObjUI.nameTxt.text = " 新游豪礼"
    itemObjUI.overImg.gameObject:SetActive(false)
    itemObjUI.goBtn.gameObject:SetActive(true)
    itemObjUI.goBtn.onClick:AddListener(function()
        Act_069_XYHLBasePanel.Create()
    end)
    itemObjUI.content = itemObj.transform:Find("Scroll View/Viewport/Content")
    local award = GameObject.Instantiate(panelUI.AwardChild, itemObjUI.content)
    award.gameObject:SetActive(true)
    award.transform:Find("Image"):GetComponent("Image").sprite = GetTexture("xyhl_icon_bwfl")
    award.transform:Find("Text"):GetComponent("Text").text = ""
end

function M.GetBindNewPlayer()
    return this.m_data.new_id
end

function M.GetTaskEndTime()
    if M.is_debug then
        return 1632894168
    else
        return (this.m_data.bind_time or 0) + 604800
    end
end


function M.GetNewLJYJ()
    local data = GameTaskModel.GetTaskDataByID(100039)
    if data then
        return data.now_total_process
    else
        return 0
    end
end

function M.GetNewLJCZ()
    local data = GameTaskModel.GetTaskDataByID(100040)
    if data then
        return data.now_total_process / 100
    else
        return 0
    end
end

function M.GetBindData()
    local d = {
        new_id = this.m_data.new_id,
        new_vip = this.m_data.new_vip,
        ljyj_progress = M.GetNewLJYJ(),
        ljcz_progress = M.GetNewLJCZ(),
    }
    return d
end

local function SortCfg(cfg)
    local rCfg = basefunc.deepcopy(cfg)
	table.sort(rCfg, function(a, b)
        local stateA = M.GetTaskState(a.task_id, a.task_lv)
        local stateB = M.GetTaskState(b.task_id, b.task_lv)

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
        elseif a.index < b.index then
            return true
        elseif a.index > b.index then
            return false
        end
        return false
    end)
    return rCfg
end

function M.GetTaskState(task_id, task_lv)
    if this.taskData[task_id] then
        if not task_lv then
            return this.taskData[task_id].state
        else
            return this.taskData[task_id].state[task_lv]
        end
    end
    return 0
end

function M.HandleTaskData(data)
    local curTaskId = data.id
    if not this.taskData[curTaskId] then
        return
    end
    if not this.taskData[curTaskId].task_lv then
        this.taskData[curTaskId].state = data.award_status
        this.taskData[curTaskId].need_process = data.need_process
    else
        local b = basefunc.decode_task_award_status(data.award_get_status)
        b = basefunc.decode_all_task_award_status(b, data, this.taskData[curTaskId].task_lv)
        this.taskData[curTaskId].state = b
    end
    this.taskData[curTaskId].now_total_process = data.now_total_process
    Event.Brocast("model_xyhl_task_change_msg")
    M.SetHintState()
end

function M.GetTaskConfig(key)
    return SortCfg(config[key])
end

function M.GetTaskData(task_id)
    if this.taskData[task_id] then
        return this.taskData[task_id]
    end
end

local function IsHintTaskTab(cfg)
    local checkedTask = {}
    local isHint = false
    for i = 1, #cfg do
        local task_id = cfg[i].task_id
        if this.taskData[task_id] and not checkedTask[task_id] then
            local task_lv = cfg[i].task_lv
            if task_lv then
                for j = 1, #this.taskData[task_id].state do
                    if this.taskData[task_id].state[j] == 1 then
                        return true
                    end
                end
            else
                if this.taskData[task_id].state == 1 then
                    return true
                end
            end
        end
        checkedTask[task_id] = 2
    end
    return false
end

function M.IsHint(key)
    if key == "czfl" then
        return IsHintTaskTab(config.czfl)
    elseif key == "yjfl" then
        return IsHintTaskTab(config.yjfl)
    end
end

function M.IsCareTaskId(task_id)
    for i = 1, #config.yjfl do
        if config.yjfl[i].task_id == task_id then
            return true
        end
    end
    for i = 1, #config.czfl do
        if config.czfl[i].task_id == task_id then
            return true
        end
    end
end

function M.GetCplKey()
    return this.m_data.cpl_p_key
end

function M.GetSetIdFailTime()
    return this.m_data.setIdFailTime
end