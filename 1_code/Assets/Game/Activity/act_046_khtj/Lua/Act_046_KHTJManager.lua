-- 创建时间:2020-12-28
-- Act_046_KHTJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_046_KHTJManager = {}
local M = Act_046_KHTJManager
M.key = "act_046_khtj"
M.config = GameButtonManager.ExtLoadLua(M.key, "act_046_khtj_config")
GameButtonManager.ExtLoadLua(M.key, "Act_046_KHTJPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_046_KHTJBagPanel")

M.task_ids = {}

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
        return Act_046_KHTJPanel.Create(parm.parent)
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

	this = Act_046_KHTJManager
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
    M.task_ids = M.GetTaskIDS(M.config)
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
            if k == "task_id" then
                _t[v] = 1
            end
        end
    end
    return _t
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
end