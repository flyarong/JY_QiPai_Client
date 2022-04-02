-- 创建时间:2020-01-06
-- HallBtnShxxlManager 管理器

local basefunc = require "Game/Common/basefunc"
HallBtnShxxlManager = {}
local M = HallBtnShxxlManager
M.key = "hallbtn_shxxl"
GameButtonManager.ExtLoadLua(M.key, "hall_shxxl_EnterPrefab")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 对应权限的key
   return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if M.IsActive() then 
        -- 活动的开始与结束时间
        local e_time = 1584374399 
        local s_time = 1583796600
        if (not e_time or os.time() < e_time) and (not s_time or os.time() > s_time) then
            local _permission_key = "actp_own_task_21171"
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
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm) 
    if parm.goto_scene_parm == "enter" then
        return hall_shxxl_EnterPrefab.Create(parm.parent)
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

	this = HallBtnShxxlManager
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
