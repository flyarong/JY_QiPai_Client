-- 创建时间:2020-02-17
-- ACT_001YJWDManager 管理器

local basefunc = require "Game/Common/basefunc"
ACT_001YJWDManager = {}
local M = ACT_001YJWDManager
M.key = "act_001_yjwd"
M.answer_type = "answer_2020_2_25"
M.task_id = 21161
local now_answer_num = 0 
local this
local lister
GameButtonManager.ExtLoadLua(M.key, "ACT_001YJWDPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "acttivity_001_dtyj_config")

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1583164799
    local s_time = 1582587000
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
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return ACT_001YJWDPanel.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if M.Is_Can_GetAward() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
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
    lister["common_question_answer_get_player_info_response"] = this.on_common_question_answer_get_player_info_response
    lister["common_question_answer_answer_num_change_msg"] = this.on_common_question_answer_answer_num_change_msg
    lister["model_task_change_msg"] = this.Refresh
end

function M.Init()
	M.Exit()

	this = ACT_001YJWDManager
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
        Network.SendRequest("common_question_answer_get_player_info",{act_type = M.answer_type})
	end
end

function M.on_common_question_answer_get_player_info_response(_,data)
    dump(data,"<color=red>答题有奖</color>")
    if data and data.result == 0 and data.act_type == M.answer_type then 
        now_answer_num = data.now_answer_num
        Event.Brocast("ui_button_data_change_msg", { key = M.key })
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end
end

function M.OnReConnecteServerSucceed()

end

function M.GetAnswerNum()
    return now_answer_num
end

function M.Is_Can_GetAward()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data and data.award_status == 2 then 
        return false
    end
    return true
end

function M.GetFAQConfig()
    return config
end

function M.on_common_question_answer_answer_num_change_msg(_,data)
    dump(data,"<color=red>答题有奖</color>")
    if data and data.act_type == M.answer_type then 
        now_answer_num = data.now_answer_num
        Event.Brocast("ui_button_data_change_msg", { key = M.key })
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end 
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end