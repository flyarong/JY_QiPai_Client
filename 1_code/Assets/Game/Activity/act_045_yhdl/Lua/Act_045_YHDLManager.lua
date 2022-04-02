-- 创建时间:2020-12-22
-- Act_045_YHDLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_045_YHDLManager = {}
local M = Act_045_YHDLManager
M.key = "act_045_yhdl"
GameButtonManager.ExtLoadLua(M.key, "Act_045_YHDLEnterPrefab")

local this
local lister
local permission_keys = {"cymj_to_hlby_conversion","wqp_to_hlby_conversion"}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1610380800
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local check_func = function(_permission_key)
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
    for i = 1,#permission_keys do
        if check_func(permission_keys[i]) then
            return true
        end
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
    if parm and parm.goto_scene_parm == "download" then
        UnityEngine.Application.OpenURL(M.GetUrl())
    elseif parm.goto_scene_parm == "enter" then
        Act_045_YHDLEnterPrefab.Create(parm.parent)
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_045_YHDLManager
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

function M.GetAndroidUrl()
    return "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/hlby_android.apk"
end

function M.GetIosUrl()
    return "itms-services://?action=download-manifest&url=https://cdndownload.game3396.com/install/ios/qiye/hlttby/normal_aibianxian.plist"
end

function M.GetUrl()
    if gameRuntimePlatform == "Ios" then
        return M.GetIosUrl()
    else
        return M.GetAndroidUrl()
    end
end