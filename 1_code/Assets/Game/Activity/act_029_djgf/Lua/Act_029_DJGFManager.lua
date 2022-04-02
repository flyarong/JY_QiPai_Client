-- 创建时间:2020-09-09
-- Act_029_DJGFManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_029_DJGFManager = {}
local M = Act_029_DJGFManager
M.key = "act_029_djgf"
M.task_id = 21522
GameButtonManager.ExtLoadLua(M.key, "Act_029_DJGFPanel")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1600703999
    local s_time = 1600126200
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
        return Act_029_DJGFPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["pdkclear_created"] = this.on_pdkclear_created
    lister["ddzfreeclear_created"] = this.on_ddzfreeclear_created
    lister["mjfreeclear_created"] = this.on_mjfreeclear_created
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_common_divide_base_info_response"] = this.on_query_common_divide_base_info_response
	lister["query_common_divide_sys_info_response"] = this.on_query_common_divide_sys_info_response
end

function M.Init()
	M.Exit()

	this = Act_029_DJGFManager
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
        if M.IsActive() then
            M.UpDateData()
        end
	end
end
function M.OnReConnecteServerSucceed()
end


function M.GetNeedTime()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    dump(data,"<color=red>对局瓜分对应的任务数据</color>")
    if data then
        return data.need_process - data.now_process
    end
    return 0
end

M.CanGetTimes = 0
function M.CreateTips(data)
    Network.SendRequest("query_common_divide_base_info",{divide_type = "znq_2year_divide"})
    Timer.New(function()
        local b = newObject("Act_028_DJJTTips",data.panelSelf.transform)
        b.transform:Find("@t_txt"):GetComponent("Text").text = "再赢"..M.GetNeedTime().."局可瓜分"..(M.CanGetTimes + 1).."份"
    end,3.6,1):Start() 
end

function M.UpDateData()
	if this.UpDate_Timer then
		this.UpDate_Timer:Stop()
	end
	this.UpDate_Timer = Timer.New(
	function()
		Network.SendRequest("query_common_divide_base_info",{divide_type = "znq_2year_divide"})
		--Network.SendRequest("query_common_divide_sys_info",{divide_type = "znq_2year_divide"})
	end,20,-1)
	this.UpDate_Timer:Start()
end

function M.on_query_common_divide_base_info_response(_,data)
    if data and data.result == 0 then
        M.CanGetTimes = data.divide_num
    end
end

function M.on_query_common_divide_sys_info_response(_,data)
    if data and data.result == 0 then

    end
end

function M.on_pdkclear_created(data)
    if data and data.panelSelf and M.IsActive() then
        M.CreateTips(data)
    end
end

function M.on_ddzfreeclear_created(data)
    dump(data,"<color=red>斗地主创建</color>")
    if data and data.panelSelf and M.IsActive() then
        M.CreateTips(data)
    end
end

function M.on_mjfreeclear_created(data)
    dump(data,"<color=red>跑得快创建</color>")
    if data and data.panelSelf and M.IsActive() then
        M.CreateTips(data)
    end
end