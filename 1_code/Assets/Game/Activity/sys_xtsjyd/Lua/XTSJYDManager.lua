-- 创建时间:2020-02-13
-- XTSJYDManager 管理器

local basefunc = require "Game/Common/basefunc"
XTSJYDManager = {}
local M = XTSJYDManager
M.key = "sys_xtsjyd"
M.taskid = 21734
GameButtonManager.ExtLoadLua(M.key, "GuideToUpdatePanel")
local this
local lister
local S_T 
local E_T
local times = 0 --进入大厅的次数
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = E_T
    local s_time = S_T
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 服务器商议后，客户端不用判断权限，直接判断任务有没有就可以 --2020/12/11
    local task = GameTaskModel.GetTaskDataByID(M.taskid)
    if not task then
        return false
    end
    if gameRuntimePlatform == "Ios" then 
        return false
    end
    return true
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
    if not M.CheckIsShow(parm) then
        return
    end
    if parm.goto_scene_parm == "panel" then
        return GuideToUpdatePanel.Create(parm.backcall)
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
    lister["Now_In_Game_Hall"] = this.on_Now_In_Game_Hall
end

function M.Init()
	M.Exit()

	this = XTSJYDManager
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
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_Now_In_Game_Hall()
    times = times + 1
    dump(times,"<color=red>进入大厅的次数</color>")
    if times >  1 then
        if M.IsActive() then 
            GuideToUpdatePanel.Create()
        end 
    end 
end
function M.GetTimeStr()
    if S_T and E_T then 
        return "活动时间："..os.date("%m月%d日%H:%M", S_T).." - "..os.date("%m月%d日%H:%M", E_T)
    else
        return ""
    end
end