-- 创建时间:2020-08-12
-- SYSFCMManager 管理器

--[[
1、没有实名的玩家不能充值，点击就弹提示
2、到达1小时后弹提示，之后点击任意地方都弹提示
--]]

local basefunc = require "Game/Common/basefunc"
SYSFCMManager = {}
local M = SYSFCMManager
M.key = "sys_fcm"
GameButtonManager.ExtLoadLua(M.key, "SYSFCMHintPanel")
GameButtonManager.ExtLoadLua(M.key, "SYSFCMGlobalPanel")

local this
local lister

-- 是否有活动
function M.IsActive()
    if GameGlobalOnOff.ForceVerifide then
        do return true end -- 强制打开
    end
    if AppDefine.IsEDITOR() then -- 测试需求：强制关闭
        return false
    end
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "pt_fcm"
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
    local b,c = GameButtonManager.RunFunExt("sys_binding_verifide", "IsVerify", nil)
    if not b or c then
        return false
    end
    return M.IsActive()
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        return SYSFCMHintPanel.Create("根据国家要求，未实名认证玩家无法进行道具购买")
    elseif parm.goto_scene_parm == "sm_panel" then
        return GameManager.GotoUI({gotoui="sys_binding_verifide", goto_scene_parm="panel", backcall = parm.backcall})
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

    lister["EnterScene"] = this.OnEnterScene
    lister["global_game_panel_close_msg"] = this.on_global_game_panel_close_msg
    lister["global_game_panel_open_msg"] = this.on_global_game_panel_open_msg

    lister["query_indulge_data_response"] = this.on_query_indulge_data
    lister["MainModelUpdateVerify"] = this.onMainModelUpdateVerify
end

function M.Init()
	M.Exit()

	this = SYSFCMManager
	this.m_data = {}
    this.max_tysc = 3600 --1小时

	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        M.StopTime()
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
        M.QueryData()
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryData()
    if this.m_data.login_time then
        M.CheckTYJS()
    else
        Network.SendRequest("query_indulge_data", nil, "")
    end
end
function M.on_query_indulge_data(_, data)
    dump(data, "<color=red> OOO on_query_indulge_data</color>")
    if data.result == 0 then
        this.m_data.login_time = tonumber(data.login_time)
        this.m_data.accumulate_time = tonumber(data.accumulate_time)
        M.CheckTYJS()
    end
end
-- 是否弹提示
function M.IsPopupHint(parm)
    return M.CheckIsShow()
end
function M.GetTYTime()
    if this.m_data.accumulate_time then
        local ty = this.m_data.accumulate_time + (MainModel.GetCurTime() - this.m_data.login_time)
        return ty
    end
    return 0
end

-- 是否体验结束  1小时体验时间
function M.IsTYJS()
    if this.m_data.accumulate_time then
        local ty = M.GetTYTime()
        if ty >= this.max_tysc then
            return true
        end
    end
end

function M.CheckTYJS()
    if M.CheckIsShow() and this.m_data.accumulate_time then
        if M.IsTYJS() then
            SYSFCMGlobalPanel.Create()
        else
            this.m_data.down_t = this.max_tysc - M.GetTYTime()
            M.StartTime()
        end
    end
end

function M.OnEnterScene()
    M.CheckTYJS()
end
function M.on_global_game_panel_close_msg(parm)
    if parm.ui == "VerifidePanel" then
        M.CheckTYJS() 
    end
end
function M.on_global_game_panel_open_msg(parm)
    if parm.ui == "VerifidePanel" then
        Event.Brocast("sys_fcm_close_global_panel")
    end
end

function M.StartTime()
    M.StopTime()
    this.update_time = Timer.New(function ()
        M.StopTime()
        SYSFCMHintPanel.Create()
    end, this.m_data.down_t, 1)
    this.update_time:Start()
end

function M.StopTime()
    if this.update_time then
        this.update_time:Stop()
        this.update_time = nil
    end
end

function M.onMainModelUpdateVerify()
    if not M.CheckIsShow() then
        Event.Brocast("sys_fcm_close_global_panel")    
    end
end