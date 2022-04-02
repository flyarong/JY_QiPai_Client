-- 创建时间:2020-05-25
-- ActivityTaskManager 管理器

local basefunc = require "Game/Common/basefunc"
ActivityTaskManager = {}
local M = ActivityTaskManager
M.key = "act_ty_task"
GameButtonManager.ExtLoadLua(M.key, "ActivityTaskItem")
GameButtonManager.ExtLoadLua(M.key, "ActivityTaskPanel")
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_ty_task_config")

local this
local lister
local configs = {}
local task_ids = {}
--登录完成后自动请求的exchange_id,注意维护，当期没有这类活动记得清空
local exchange_ids = {}
--类型就是type， 是int）：配置表名
local Type2ConfigName = {}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
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
function M.CheckIsShow()
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity(parm)
    local _permission_key = parm.condi_key
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

-- 所有可以外部创建的UI
--goto_scene_parm 就是配置表的名字
function M.GotoUI(parm)
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    if parm.goto_scene_parm == "panel" then
        if not configs[parm.goto_type] then
            configs[parm.goto_type] = M.InitUIConfig(parm.goto_type)
            task_ids[parm.goto_type] = M.GetTaskIDS(configs[parm.goto_type])
            local d = M.GetActivityExchangeIDS(configs[parm.goto_type],parm.goto_type)
            M.ParseType2ConfigName(d)
        end
        PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id..parm.goto_type, os.time())
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key,goto_type = parm.goto_type})
        dump(parm.cfg)
        return ActivityTaskPanel.Create(parm.parent, parm.cfg, nil,configs[parm.goto_type])
   end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if not parm.goto_type then
        return 
    end
    local func = function ()
        if M.IsAwardCanGetByTask(task_ids[parm.goto_type]) or M.IsAwardCanGetByExchange(parm.goto_type) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id..parm.goto_type, 0))))
            if oldtime ~= newtime then
                if M.CheckIsShowInActivity(parm) then
                    return ACTIVITY_HINT_STATUS_ENUM.AT_Red
                end
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
    if not configs[parm.goto_type] then
        local config = M.InitUIConfig(parm.goto_type)
        configs[parm.goto_type] = config
        task_ids[parm.goto_type] = M.GetTaskIDS(configs[parm.goto_type])
        local d = M.GetActivityExchangeIDS(configs[parm.goto_type],parm.goto_type)
        M.ParseType2ConfigName(d)
    end
    return func()
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()

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
    lister["model_query_one_task_data_response"] = this.model_query_one_task_data_response
    lister["model_query_task_data_response"] = this.model_query_task_data_response
    lister["model_task_change_msg"] = M.model_task_change_msg
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_activity_exchange_response"] = this.on_query_activity_exchange_response
end

function M.Init()
	M.Exit()
	this = ActivityTaskManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.List2Map()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

local find_tge_func = function(base)
    local re = {}
    if type(base.tges) == "table" then
        for i = 1,#base.tges do
            local d =  M.config.tge[base.tges[i]]
            d.tge = "tge"..i
            re[#re + 1] =  M.config.tge[base.tges[i]]
        end
    else
        local d =  M.config.tge[base.tges]
        d.tge = "tge"..1
        re[#re + 1] =  M.config.tge[base.tges]
    end
    return re
end

local find_task_func = function(tge)
    local re = {}
    if type(tge.task_index) == "table" then
        for i = 1,#tge.task_index do
            local d =  M.config.task[tge.task_index[i]]
            re[#re + 1] =  M.config.task[tge.task_index[i]]
        end
    else
        local d =  M.config.task[tge.task_index]
        re[#re + 1] =  M.config.task[tge.task_index]
    end
    return re
end
--将配置转化为原来所需要的形式，这样更安全快捷
function M.InitUIConfig(goto_type)
    local data = {}
    data.base = {}
    data.base[1] = M.config.base[goto_type]
    data.tge = {}
    local tges = find_tge_func(data.base[1])
    for i = 1,#tges do
        data.tge["tge"..i] = tges[i]
    end
    for i = 1,#tges do
        data["tge"..i] = find_task_func(tges[i])
    end
    return data
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        local send_func = function()
            for i = 1,#exchange_ids do
                Network.SendRequest("query_activity_exchange",{type = exchange_ids[i]})
            end
        end
        --延时请求
        Timer.New(send_func,3,1):Start()
        --每隔10秒同步一下数据
        Timer.New(send_func,10,-1):Start()
	end
end
function M.OnReConnecteServerSucceed()

end

function M.GetTaskIDS(C)
    local _r = {}  
    local _t = M.get_task_id(C)
    for k, v in pairs(_t) do
        _r[#_r + 1] = k
    end
    return _r
end

function M.get_task_id(_config,_t)
    _t = _t or {}
    for k, v in pairs(_config) do
        if type(v) == "table" then
            M.get_task_id(v,_t)
        else
            if k == "task" then
                _t[v] = 1
            end
        end
    end
    return _t
end

function M.GetActivityExchangeIDS(C,config_name)
    local _t = M.get_activity_exchange_ID(C,config_name)
    return _t
end

function M.get_activity_exchange_ID(_config,config_name,_t)
    _t = _t or {}
    for k, v in pairs(_config) do
        --对于同一个配置表内，只统计"存在"的type和对应的配置表名字
        if k == "activity_exchange" then
            _t[v[1]] = _t[v[1]] or {}
            _t[v[1]][config_name] = 1
        elseif type(v) == "table" then
            M.get_activity_exchange_ID(v,config_name,_t)
        end
    end
    return _t
end

function M.IsAwardCanGetByTask(task_ids)
    if task_ids then 
        for k,v in pairs(task_ids) do
            local d = GameTaskModel.GetTaskDataByID(v)
            if d then 
                if d.award_status == 1 then 
                    return true
                end 
            end 
        end
    end
    return false
end

--快速刷新
local quick_refresh = {}
function M.model_task_change_msg(data)
    M.Refresh(data.id)
end

function M.Refresh(taskid)
    if not quick_refresh[taskid] then
        for k ,v in pairs(task_ids) do
            for k1,v1 in pairs(v) do
                if taskid == v1 then
                    quick_refresh[taskid] = {gotoui = M.key,goto_type = k}
                    Event.Brocast("global_hint_state_change_msg",quick_refresh[taskid])
                    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key}) 
                    return
                end
            end
        end
    else
        Event.Brocast("global_hint_state_change_msg",quick_refresh[taskid])
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key}) 
    end
end

function M.model_query_one_task_data_response(data)
    if data and data.id then
        M.Refresh(data.id)
    end
end

function M.model_query_task_data_response()
    dump(task_ids,"<color=red>此时的所有任务已经请求完成</color>")
    for k,v in pairs(task_ids) do
        for k1,v1 in pairs(v) do
            M.Refresh(v1)
        end
    end
end

local ExChange_Data = {}
function M.on_query_activity_exchange_response(_,data)
    if data and data.result == 0 then
        ExChange_Data[data.type] = ExChange_Data[data.type] or {}
        ExChange_Data[data.type] = data.exchange_day_data

        if Type2ConfigName[data.type] then
            for k,v in pairs(Type2ConfigName[data.type]) do
                Event.Brocast("global_hint_state_change_msg",{gotoui = M.key,goto_type = v})
            end
        end
    end
end

function M.IsAwardCanGetByExchange(config_name)
    local cheak_func =  function (config)
        local can_exchange = true
        local data = {}
        if config.activity_exchange and ExChange_Data[config.activity_exchange[1]] and ExChange_Data[config.activity_exchange[1]][config.activity_exchange[2]] then            
            data.type = config.activity_exchange[1]
            data.exchange_day_data = ExChange_Data[data.type]
            if  config.cheak_item then
                for i = 1,#config.cheak_item do
                    if GameItemModel.GetItemCount(config.cheak_item[i]) < config.cheak_num[i] then
                        can_exchange = false
                        break
                    end
                end
            end

            if can_exchange and	data.exchange_day_data[config.activity_exchange[2]] > 0 then
                return true
            end
        end
        return false
    end
    for i = 1,3 do
        if configs[config_name] and configs[config_name]["tge"..i] then
            for j = 1,#configs[config_name]["tge"..i] do
                if cheak_func(configs[config_name]["tge"..i][j]) then
                    return true
                end
            end
        end
    end
   
    return false
end
--对于所有的配置表，需要统计出的一个type被哪些配置表使用
function M.ParseType2ConfigName(data)
    if not table_is_null(data) then
        for k ,v in pairs(data) do
            if not table_is_null(v) then
                for k1,v1 in pairs(v) do
                    Type2ConfigName[k] = Type2ConfigName[k] or {}
                    local d = Type2ConfigName[k]
                    if not M.IsHaveSameValue(d,k1) then
                        Type2ConfigName[k][#Type2ConfigName[k] + 1] = k1
                    end     
                end
            end
        end
    end
end

function M.IsHaveSameValue(tabel,value)
    for i = 1,#tabel do
        if tabel[i] == value then
            return true
        end
    end
    return false
end

function M.List2Map()
    for i = 1,#M.config.base do
        M.config.base[M.config.base[i].key] = M.config.base[i]
    end
end