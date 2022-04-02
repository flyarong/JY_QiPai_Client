-- 创建时间:2020-01-06
-- SYSMFLHBManager 管理器
-- 免费领福卡

local basefunc = require "Game/Common/basefunc"
SYSMFLHBManager = {}
local M = SYSMFLHBManager
M.key = "sys_mflhb"
GameButtonManager.ExtLoadLua(M.key, "SYSMFLHB_JYFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "SYSMFLHBEnterPrefab")

local this
local lister

-- 是否有活动
function M.IsActive()
    if AdvertisingManager.IsCloseAD() then
        return false
    end
    
    if SYSQXManager.IsNeedWatchAD() and M.GetNum() > 0 then
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if M.IsActive() then
        -- 活动的开始与结束时间
        local e_time
        local s_time
        if (not e_time or os.time() < e_time) and (not s_time or os.time() > s_time) then
            return true
        end
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.IsActive() then
        dump(parm, "<color=red>IsActive false</color>")
        return
    end

    if parm.goto_scene_parm == "enter" then
        return SYSMFLHBEnterPrefab.Create(parm.parent, parm)
    elseif parm.goto_scene_parm == "jyfl_enter" then
        return SYSMFLHB_JYFLEnterPrefab.Create(parm.parent, parm)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsActive() then
        if M.GetNum() > 0 and M.GetCD() == 0 then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    else
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["query_everyday_free_hb_response"] = this.on_query_everyday_free_hb
    lister["get_everyday_free_hb_response"] = this.on_get_everyday_free_hb

end

function M.Init()
	M.Exit()

	this = SYSMFLHBManager
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
    this.UIConfig={
    }
end

function M.OnLoginResponse(result)
	if result == 0 then
        Network.RandomDelayedSendRequest("query_everyday_free_hb")

        M.get_cd_key = M.key .. MainModel.UserInfo.user_id .. "_cd"
        M.max_cd = 120 -- 2分钟领取间隔
	end
end
function M.OnReConnecteServerSucceed()
end
function M.on_query_everyday_free_hb(_, data)
    -- dump(data, "<color=red>on_query_everyday_free_hb</color>")
    if data.result == 0 then
        this.m_data.get_num = data.num
    else
        this.m_data.get_num = 0
    end
    Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
    Event.Brocast("model_everyday_free_hb_msg_sys_mflhb")
    Event.Brocast("ui_button_state_change_msg")
end
function M.on_get_everyday_free_hb(_, data)
    -- dump(data, "<color=red>on_get_everyday_free_hb</color>")
    if data.result == 0 then
        PlayerPrefs.SetString(M.get_cd_key, os.time() .. "")

        this.m_data.get_num = this.m_data.get_num - 1
        Event.Brocast("global_hint_state_change_msg", {gotoui=M.key})
        Event.Brocast("model_everyday_free_hb_msg_sys_mflhb")
        Event.Brocast("ui_button_state_change_msg")
    else
        HintPanel.ErrorMsg(data.result)
    end
end

-- 领取的剩余CD
function M.GetCD()
    local oldtime = tonumber(PlayerPrefs.GetString(M.get_cd_key, 0))
    local cur_t = os.time()
    if oldtime == 0 or (cur_t - oldtime) > M.max_cd then
        return 0
    else
        return M.max_cd - (cur_t - oldtime)
    end
end
-- 获取剩余领取次数
function M.GetNum()
    if this.m_data.get_num then
        return this.m_data.get_num
    end
    return 0
end
