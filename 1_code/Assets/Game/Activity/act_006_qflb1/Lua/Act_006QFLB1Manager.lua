-- 创建时间:2020-03-24
-- Act_006QFLB1Manager 管理器

local basefunc = require "Game/Common/basefunc"
Act_006QFLB1Manager = {}
local M = Act_006QFLB1Manager
M.key = "act_006_qflb1"
GameButtonManager.ExtLoadLua(M.key, "Act_006_QFLB1Panel")
local this
local lister

-- 是否有活动
function M.IsActive()
    local data = MoneyCenterQFLBManager.get_data_all_return_lb_info()
    if not data then return end
    local n = "all_return_lb_"
    local v = data[n..1]
    if v.is_buy == 1 then
        return false
    end
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
function M.CheckIsShowInActivity(cfg)
    return M.IsActive(cfg)
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        return Act_006_QFLB1Panel.Create(parm.parent)
    elseif parm.goto_scene_parm == "enter" then
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
    lister["finish_gift_shop"] = this.on_finish_gift_shop

end

function M.Init()
	M.Exit()

	this = Act_006QFLB1Manager
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

function M.OnEnterScene()
    local a,b
    a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_buy_gift_bag_10084", is_on_hint = true}, "CheckCondition")
    if a and not b then 
        return
    end
    Network.SendRequest("query_one_task_data",{task_id = 21367},"",function (data)
        -- dump(data,"<color=yellow>+++++++++++++data+++++++++++++</color>")
        if MainModel.myLocation == "game_Free" and MainModel.FirstLoginTime() >= 1576684800 and data.result == 0 and data.task_data and data.task_data.award_status and data.task_data.award_status == 1 then
            local data = MoneyCenterQFLBManager.get_data_all_return_lb_info()
            if not data then return end
            local n = "all_return_lb_"
            local v = data[n..1]
            if v.is_buy ~= 1 then
                M.m_data.pre = QFLBFlyEnterPrefab.Create(nil,nil,1)
            end
        end
    end)
end

function M.on_finish_gift_shop(id)
    if id == 10084 then
        if M.m_data.pre then
            M.m_data.pre:MyExit()
        end
    end
end
