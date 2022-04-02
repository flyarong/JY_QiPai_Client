-- 创建时间:2020-03-17
-- Act_005YZQJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_005YZQJManager = {}
local M = Act_005YZQJManager
M.key = "act_005_yzqj"
GameButtonManager.ExtLoadLua(M.key,"act_yzqjPanel")
local this
local lister

M.task_id = 21542
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1604332799
    local s_time = 1603755000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_21542"
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
        return act_yzqjPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if not M.IsActive() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
    if parm and parm.gotoui == M.key then
        if M.IsCanGetAward()==1 or M.IsCanGetAward()==0  then
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
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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

    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
    M.Exit()

    this = Act_005YZQJManager
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
function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
    if result == 0 then
        -- 数据初始化
        Network.RandomDelayedSendRequest("query_one_task_data",{task_id = M.task_id})
    end
end
function M.OnReConnecteServerSucceed()
end

function M.QueData()
    if this.m_data.task_data then
        Event.Brocast("model_one_task_data_act_yzqj")
    else
        Network.SendRequest("query_one_task_data",{task_id = M.task_id})
    end
end

function M.on_model_query_one_task_data_response(data)
    if data and data.id == M.task_id then
        this.m_data.task_data = data
        Event.Brocast("model_one_task_data_act_yzqj")
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end
end

function M.on_model_task_change_msg(data)
    if data and data.id == M.task_id then
        this.m_data.task_data = data
        Event.Brocast("model_one_task_data_act_yzqj")
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end
end

function M.IsCanGetAward()
    if this.m_data.task_data  then
        return this.m_data.task_data.award_status
    end
end
function M.SaveJY(txt)
    -- 存
    PlayerPrefs.SetString(MainModel.UserInfo.user_id.."yzqj_txt",txt)
end
function M.GetLocalJY()
    -- 取
    return PlayerPrefs.GetString(MainModel.UserInfo.user_id.."yzqj_txt")
end