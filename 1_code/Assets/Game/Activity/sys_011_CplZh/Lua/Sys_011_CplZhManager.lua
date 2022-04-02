-- 创建时间:2020-04-28
-- Sys_011_CplZhManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_011_CplZhManager = {}
local M = Sys_011_CplZhManager
M.key = "sys_011_CplZh"
GameButtonManager.ExtLoadLua(M.key, "Sys_011_CplNoticePanel")
GameButtonManager.ExtLoadLua(M.key, "Sys_011_CplEnterPrefab")

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
    if M.WqpCpl2Jy() or M.JyCpl2Wqp() then
        return true
    end
    return false
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
        if M.IsActive() then
            UnityEngine.Application.OpenURL(M.GetUrl())
        end
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
    lister["EnterScene"] = this.OnEnterScene
end

function M.Init()
	M.Exit()

	this = Sys_011_CplZhManager
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
    if MainModel.myLocation == "game_Hall" then
        if M.JyCpl2Wqp() or M.WqpCpl2Jy() then
            local t = PlayerPrefs.GetInt("cpl_not_show_notice".. MainModel.UserInfo.user_id,0)
            if t <= 7 and PlayerPrefs.GetInt("cpl_not_show_notice_one_day".. MainModel.UserInfo.user_id,0) == 0 then
                Sys_011_CplEnterPrefab.Create()
                PlayerPrefs.SetInt("cpl_not_show_notice".. MainModel.UserInfo.user_id,t + 1)

                --放在关闭后
            end
        end
    end
end

function M.JyCpl2Wqp()
    local _permission_key = "jyddz_type_plat"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            print("<color=red><size=19>JyCpl2Wqp_权限没过</size></color>")
            return false
        end
        return true
    else
        return true
    end
end


function M.WqpCpl2Jy()
    local _permission_key = "wqp_type_plat"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            print("<color=red><size=19>WqpCpl2Jy_权限没过</size></color>")
            return false
        end
        return true
    else
        return true
    end
end

function M.GetUrl()
    if M.WqpCpl2Jy() then
        return "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz.apk"
    end
    if M.JyCpl2Wqp() then
        return "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/wqpddz.apk"
    end
    return "http://cdnjydown.jyhd919.cn/jydown/Version2020/Install/V2/Android/jyddz.apk"
end