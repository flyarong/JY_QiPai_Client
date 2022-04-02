-- 创建时间:2020-07-21
-- Sys_023_ExXSYDManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_023_ExXSYDManager = {}
local M = Sys_023_ExXSYDManager
M.key = "sys_023_exxsyd"

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
	lister["OnLoginResponse"] = this.OnLoginResponse
	lister["ExitScene"] = this.OnExitScene
	lister["sys_023_exxsyd_panel_close"] = this.on_sys_023_exxsyd_panel_close
	lister["newplayer_guide_finish"] = this.on_newplayer_guide_finish
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Sys_023_ExXSYDManager
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



-- 新人七天乐》邮件》福利中心》福卡任务》 48元任务
-- 在对应功能得Manager或者logic种 实现一个是否可以打开面板得函数
-- 在对应得面板panel中 关闭面板时，抛出消息通知
local base_data = {
	[1] = {panel = "Act_020HBFXInvitePanel",manager = "Act_020HBFXManager"},
	[2] = {panel = "ActivityXRHB1Panel",manager = "ActivityXRHB1Logic"},
	[3] = {panel = "JYFLPanel",manager = "JYFLManager"},
	[4] = {panel = "EmailPanel",manager = "EmailLogic"},
	[5] = {panel = "XRQTLPanel",manager = "XRQTLManager"},
}
  
local now_index = #base_data
local is_ex = false
function M.on_sys_023_exxsyd_panel_close()
	if is_ex then
		M.ShowPanel(now_index)
	end
end

--新手引导完成
function M.on_newplayer_guide_finish()
	is_ex = true
	M.ShowPanel(now_index)
end

function M.ShowPanel()

	if MainModel.myLocation ~= "game_Hall" then
		return 
	end

	local show_func 
	show_func = function (index)
		if base_data[index] and base_data[index].manager and _G[base_data[index].manager] and _G[base_data[index].manager].IsShowInExXSYD and (_G[base_data[index].manager].IsShowInExXSYD)() then
			_G[base_data[index].panel].Create()
			now_index = index - 1
		else
			if index - 1 <= 0 then
				return
			else
				now_index = index - 1
				show_func (now_index)
			end
		end	
	end
	show_func(now_index)
end

function M.OnExitScene()
	is_ex = false
end