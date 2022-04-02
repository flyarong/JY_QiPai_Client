-- 创建时间:2019-12-31
-- YX_LJYJManager 管理器

local basefunc = require "Game/Common/basefunc"
YX_LJYJManager = {}
local M = YX_LJYJManager
M.key = "act_yx_ljyj"
M.lottery_type = "lantern_festival_lottery"
M.config  = GameButtonManager.ExtLoadLua(M.key, "yx_ljyj_config")
GameButtonManager.ExtLoadLua(M.key, "YX_LJYLPanel")
local this
local lister
local s_time = 1580772600
local e_time = 1581350399

local type_info = {
	type = M.lottery_type,
	start_time = s_time,
    end_time = e_time, 
    config = M.config,
}
-- 创建入口按钮时调用
function M.CheckIsShow()
    return true
end
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return YX_LJYLPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        local data = LotteryBaseManager.GetData(M.lottery_type)
        if LotteryBaseManager.IsAwardCanGet(type_info.type) and data and data.now_game_num < 6 then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            dump(newtime,"<color=red>newtimenewtimenewtimenewtimenewtime</color>")
            dump(oldtime,"<color=red>oldtimeoldtimeoldtimeoldtimeoldtime</color>")
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
end

function M.CheckIsShowInActivity()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_lantern_festival_lottery", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
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
    lister["get_one_common_lottery_info"] = M.SetData
end

function M.Init()
	M.Exit()

	this = YX_LJYJManager
	this.m_data = {}
	MakeLister()
    AddLister()
    LotteryBaseManager.AddQuery(type_info)
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
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
end

function M.SetData()
    local data = LotteryBaseManager.GetData(M.lottery_type)
    if data then
        this.m_data.at_data = data
        this.m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        if LotteryBaseManager.IsAwardCanGet(M.lottery_type) and data.now_game_num < 6  then
            this.m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            this.m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end
