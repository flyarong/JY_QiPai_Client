-- 创建时间:2021-08-10
-- Act_064_Year3rdManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_064_Year3rdManager = {}
local M = Act_064_Year3rdManager
M.key = "act_064_year3rd"

local config = GameButtonManager.ExtLoadLua(M.key, "act_064_year3rd_config")
GameButtonManager.ExtLoadLua(M.key, "Act_064_Year3rdPanel")

--M.mrlb_task = 21856

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

    if parm.goto_scene_parm == "panel" then
        return Act_064_Year3rdPanel.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsHint() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
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
end

function M.Init()
	M.Exit()

	this = Act_064_Year3rdManager
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

--是否在周年庆中
function M.IsInYear3rd()

end


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.CurLv()
    local vipLv = VIPManager.get_vip_level()
    local lv = 0
    for i = 1, #config.vips do
        if vipLv >= config.vips[i].vip_level[1] and vipLv <= config.vips[i].vip_level[2] then
            lv = i
        end
    end
    return lv
end

function M.IsHint()
    local task_id = M.GetData(M.CurLv())
    local taskData = GameTaskModel.GetTaskDataByID(task_id)
    if taskData then
        return taskData.award_status == 1
    end
end

function M.GetData(lv)
    if not config.vips[lv] then
        return
    end
    local data = {}
    local vipShowData = config.vips[lv]
    data.vip_icon = vipShowData.icon
    data.task_id = vipShowData.task_id
    local allAwardData = {}
    for i = 1, #vipShowData.award_id do
        local curAwardData = config.awards[vipShowData.award_id[i]]
        allAwardData[#allAwardData + 1] = curAwardData
    end
    data.awardData = allAwardData
    return data
end