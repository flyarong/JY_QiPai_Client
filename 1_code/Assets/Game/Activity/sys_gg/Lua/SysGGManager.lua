-- 创建时间:2019-12-27
-- SysGGManager 管理器


local basefunc = require "Game/Common/basefunc"
SysGGManager = {}
local M = SysGGManager
M.key = "sys_gg"
GameButtonManager.ExtLoadLua(M.key, "ShowGGPanel")

local this
local lister

-- 创建入口按钮时调用
function M.CheckIsShow()
    return true
end
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
    	local param = parm.parm
	local uiPanel = param.panelSelf
	if param.key == "match_hall" then
		param.callback = uiPanel.OnSignupClick
		uiPanel.OnSignupClick = function()
			ShowGGPanel.Create(param)
		end
	elseif param.key == "match_detail" then
		param.callback = uiPanel.SignupGMS
		uiPanel.SignupGMS = function()
			ShowGGPanel.Create(param)
		end
	else
		return
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
end

function M.Init()
	M.Exit()

	this = SysGGManager
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
