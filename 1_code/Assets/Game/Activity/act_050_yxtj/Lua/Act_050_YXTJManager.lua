-- 创建时间:2020-12-28
-- Act_050_YXTJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_050_YXTJManager = {}
local M = Act_050_YXTJManager
M.key = "act_050_yxtj"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_050_yxtj_config")
GameButtonManager.ExtLoadLua(M.key, "Act_050_YXTJPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_050_YXTJBagPanel")

M.task_ids = {}
M.task_get_id = 21699

local this
local lister

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
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_050_YXTJPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsAwardCanGet() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        -- local newtime = tonumber(os.date("%Y%m%d", os.time()))
        -- local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
        -- if oldtime ~= newtime then
        --     return ACTIVITY_HINT_STATUS_ENUM.AT_Red
        -- end
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
    lister["model_task_change_msg"] = this.on_task_change_msg
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_050_YXTJManager
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
    M.InitTaskIDs()
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end

function M.OnReConnecteServerSucceed()

end

function M.InitTaskIDs()
    local ids = {}
    for i = 1,#M.config.books do 
        ids[#ids+1] = M.config.books[i].task_id
    end
    M.task_ids = ids
end


function M.on_task_change_msg()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.IsAwardCanGet()
    for i = 1,#M.task_ids do
        local data = GameTaskModel.GetTaskDataByID(M.task_ids[i])
        if data and data.award_status == 1 then
            return true
        end
    end
    local _data = GameTaskModel.GetTaskDataByID(M.task_get_id)
    if _data and _data.award_status == 1 then
        return true
    end

    return false
end