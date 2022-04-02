-- 创建时间:2020-06-22
-- Act_019_CHBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_019_CHBManager = {}
local M = Act_019_CHBManager
M.key = "act_019_chb"
Act_019_CHBManager.config = GameButtonManager.ExtLoadLua(M.key,"act_019_chb_config")
GameButtonManager.ExtLoadLua(M.key,"Act_019_CHBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_019_CHBPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_019_CHBTaskItem")
local this
local lister
local hb_task_id = 21573--21573
local _time_UnrealyData

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1622476799
    local s_time = 1621899000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_040_ppccfk"
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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then
            return Act_019_CHBPanel.Create(parm.parent)
        end
    elseif parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_019_CHBEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
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

    --请求假数据
    lister["query_fake_data_response"] = this.on_query_fake_data_response
    lister["query_one_task_data_response"] = this.on_query_one_task_data_response
    lister["model_task_change_msg"] = M.model_task_change_msg
    lister["EnterScene"] = this.OnEnterScene

    lister["get_task_award_response"] = this.on_get_task_award_response
    lister["AssetChange"] = this.on_AssetChange
    lister["model_query_task_data_response"] = this.on_task_req_data_response
end



function M.Init()
	M.Exit()
	this = Act_019_CHBManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
    M.StopUpdateTime_UnrealyData()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    for i=1,#this.config do
       this.UIConfig[this.config[i].task_id] = this.UIConfig[this.config[i].task_id] or {}
       this.UIConfig[this.config[i].task_id].ID = this.config[i].ID
       this.UIConfig[this.config[i].task_id].task_id = this.config[i].task_id
       this.UIConfig[this.config[i].task_id].task_name = this.config[i].task_name
       this.UIConfig[this.config[i].task_id].award_img = this.config[i].award_img
       this.UIConfig[this.config[i].task_id].award_txt = this.config[i].award_txt
       this.UIConfig[this.config[i].task_id].GotoUI = this.config[i].GotoUI
       this.UIConfig[this.config[i].task_id].now_process = 0
       this.UIConfig[this.config[i].task_id].need_process = 0
       this.UIConfig[this.config[i].task_id].award_status = 0
    end
    if not this.m_data.task_ids then
        this.m_data.task_ids = {}
    end
    for i=1,#this.config do
        this.m_data.task_ids[i] = this.config[i].task_id
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Timer.New(function ()
            M.QueryHBCurStatus()
        end,1,1,false):Start()   
	end
end
function M.OnReConnecteServerSucceed()
end

function M.Refresh()
    --dump("<color=green>===================</color>")
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
end

----------------------跑马灯------------------------
function M.StopUpdateTime_UnrealyData()
    if _time_UnrealyData then
        _time_UnrealyData:Stop()
        _time_UnrealyData = nil
    end
end
function M.update_time_UnrealyData(b)
    M.StopUpdateTime_UnrealyData()
    if b then
        M.QueryUnrealyData()
        _time_UnrealyData = Timer.New(function ()
            M.QueryUnrealyData()
        end, 5, -1, nil, true)
        _time_UnrealyData:Start()
    end
end

function M.QueryUnrealyData()
    Network.SendRequest("query_fake_data",{ data_type = "caihongbao"})
end

function M.on_query_fake_data_response(_,data)
    if data.result == 0 then
        if not this.m_data.unrealy then
            this.m_data.unrealy = {}
        end
        this.m_data.unrealy.name = data.player_name                      --虚假数据的玩家昵称
        this.m_data.unrealy.award_data = data.award_data    --虚假数据的奖励数据
        Event.Brocast("model_chb_unrealy_change_msg")--刷新假数据
    end
end

function M.GetUnrealyPlayerName()
    return this.m_data.unrealy.name
end

function M.GetUnrealyAwardName()
    return this.m_data.unrealy.award_data--/10
end
-------------------跑马灯--------------------


function M.on_query_one_task_data_response(_,data)
    --dump(data,"<color=yellow>+++++++++++++++on_query_one_task_data_response++++++++++++++++</color>")
    if data and data.result == 0 and data.task_data then
        if data.task_data.id == hb_task_id then
            this.m_data.left_hb_status = data.task_data.award_status
            if data.task_data.other_data_str then
                this.m_data.left_hb_num = tonumber(data.task_data.other_data_str)/100
                dump(this.m_data.left_hb_num,"<color=blue>+++++++++++++++********///////////++++++++++++++++</color>")
            end
            M.Refresh()
            return
        end
    end
end

-------------------监听任务改变消息-------------------
function M.model_task_change_msg(data)
    --dump(data,"<color=yellow>+++++++++++++++model_task_change_msg++++++++++++++++</color>")
    if data.id == hb_task_id then
        this.m_data.left_hb_status = data.award_status
        if data and data.other_data_str then
            this.m_data.left_hb_num = tonumber(data.other_data_str)/100
            Event.Brocast("model_chb_hb_status_msg")
            M.Refresh()
            return
        end
    end
    for i=1,#this.m_data.task_ids do
        if this.m_data.task_ids[i] == data.id then
            --dump(data,"<color=yellow>+++++++++++++++model_task_change_msg++++++++++++++++</color>")
            this.UIConfig[data.id].now_process = data.now_process
            this.UIConfig[data.id].need_process = data.need_process
            this.UIConfig[data.id].award_status = data.award_status
            if data.award_status == 1 or data.award_status == 2 then
                Event.Brocast("model_chb_isOnefinish_msg",data.id)
            end
            Event.Brocast("model_chb_task_change_msg",data.id)
            M.Refresh()
        end
    end
end
-------------------监听任务改变消息-------------------


-------------------判断是否有任务奖励可领取-------------------
function M.IsAwardCanGet()
    for k,v in pairs(this.UIConfig) do
        if v and v.award_status and v.award_status == 1 then
            return true
        end
    end
    return false
end
-------------------判断是否有任务奖励可领取-------------------


function M.GetTaskIDs()
    return this.m_data.task_ids
end


function M.GetTaskNowProgress(id)
    return this.UIConfig[id].now_process
end
function M.GetTaskTotalProgress(id)
    return this.UIConfig[id].need_process
end
function M.GetTaskAwardStatus(id)
    return this.UIConfig[id].award_status
end


function M.OnEnterScene()
    M.Refresh()
    if MainModel.myLocation == "game_Free" and M.IsActive() and (M.GetHBAwardStatus() == 1 or M.GetHBAwardStatus() == 0) then
        Act_019_CHBPanel.Create()
    end
end

function M.GetHBAward()
    Network.SendRequest("get_task_award",{id = hb_task_id})
end

function M.QueryHBCurStatus()
    -- 获取左侧红包的状态
    Network.SendRequest("query_one_task_data",{task_id = hb_task_id})
end


function M.GetHBAwardStatus()
    return this.m_data.left_hb_status
end

function M.on_get_task_award_response(_,data)
    if data and data.result == 0 then
        if data.id == hb_task_id then
            Event.Brocast("chb_hb_is_got_msg")
        end
    end
end

function M.GetAwardTXT()
    return this.m_data.left_hb_num
end

function M.on_task_req_data_response()
    local data = {}
    data.task_list = GameTaskModel.GetTaskDataByID()
    for k,v in pairs(data.task_list) do
        for i=1,#this.m_data.task_ids do
            if v.id == this.m_data.task_ids[i] then
                this.UIConfig[v.id].now_process = v.now_process
                this.UIConfig[v.id].need_process = v.need_process
                this.UIConfig[v.id].award_status = v.award_status
            end
        end
        if hb_task_id == v.id then
            this.m_data.left_hb_status = v.award_status
        end
    end
end
