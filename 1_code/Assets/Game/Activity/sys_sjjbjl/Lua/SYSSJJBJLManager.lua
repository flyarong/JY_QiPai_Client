-- 创建时间:2020-01-06
-- SYSSJJBJLManager 管理器
-- 随机金币领取

local basefunc = require "Game/Common/basefunc"
SYSSJJBJLManager = {}
local M = SYSSJJBJLManager
M.key = "sys_sjjbjl"
GameButtonManager.ExtLoadLua(M.key, "SJJBJLEnterPrefab")

local this
local lister

-- 是否有活动
function M.IsActive()
    if AdvertisingManager.IsCloseAD() then
        return false
    end
    if SYSQXManager.IsNeedWatchAD() then
        return true
    end
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if not this.m_data.state or this.m_data.state ~= 1 then
        return false
    end
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
    if parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            if this.m_data.state and this.m_data.state == 1 then
                return SJJBJLEnterPrefab.Create(parm.parent, parm.cfg)
            end
        end
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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

    lister["model_sjjbjl_msg"] = this.on_model_sjjbjl_msg
    lister["fg_get_random_jingbi_box_award_response"] = this.on_fg_get_random_jingbi_box_award

end

function M.Init()
	M.Exit()

	this = SYSSJJBJLManager
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
	end
end
function M.OnReConnecteServerSucceed()
end
function M.on_model_sjjbjl_msg(data)
    dump(data, "<color=red>EEE on_model_sjjbjl_msg</color>")
    if data and data == 1 then
        this.m_data.state = 1
    else
        this.m_data.state = 0
    end
    Event.Brocast("ui_button_data_change_msg", {key=M.key})
end
function M.on_fg_get_random_jingbi_box_award(_, data)
    dump(data, "<color=red>EEE on_fg_get_random_jingbi_box_award</color>")
    if data.result ~= 0 then
        HintPanel.ErrorMsg(data.result)
    else
        this.m_data.state = 0
        Event.Brocast("ui_button_data_change_msg", {key=M.key})
    end
end