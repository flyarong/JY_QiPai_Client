-- 创建时间:2021-09-16
-- Act_067_JCHDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_067_JCHDManager = {}
local M = Act_067_JCHDManager
M.key = "act_067_jchd"
GameButtonManager.ExtLoadLua(M.key,"Act_067_JCHDEnter")
local game_enter_btn_config = HotUpdateConfig("Game.CommonPrefab.Lua.game_enter_btn_config")

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
    if parm.goto_scene_parm == "enter" then
        return Act_067_JCHDEnter.Create(parm.parent, parm.cfg)
    end
    -- dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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

	this = Act_067_JCHDManager
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


function M.IsGetHintStatus(_id)
    local enter_cfg = game_enter_btn_config.all_enter[_id]
    local key = enter_cfg.parm[1]
    local  _goto_scene_parm 
    if enter_cfg.parm[2] then
        _goto_scene_parm = "enter"
    else
        _goto_scene_parm = enter_cfg.parm[2]
    end
    --dump(key,"<color=white>>>>>>>>>>>>key<<<<<<<<<<<<<<<<<<</color>")
    local status = GameManager.GetHintState({gotoui = key ,goto_scene_parm = _goto_scene_parm})
    --dump(status,"<color=white>>>>>>>>>>>>status<<<<<<<<<<<<<<<<<<</color>")
    return status == ACTIVITY_HINT_STATUS_ENUM.AT_Get
end

function M.IsRedHintStatus(_id)

    local enter_cfg = game_enter_btn_config.all_enter[_id]
    local key = enter_cfg.parm[1]
    local  _goto_scene_parm 
    if enter_cfg.parm[2] then
        _goto_scene_parm = "enter"
    else
        _goto_scene_parm = enter_cfg.parm[2]
    end

    if key == "act_042_xshb" then
        if PlayerPrefs.GetString(Act_042_XSHBManager.key .. MainModel.UserInfo.user_id,0) == os.date("%Y%m%d",os.time()) then
            return false
        else
            return true
        end
    end
    -- dump(key,"<color=white>>>>>>>>>>>>key<<<<<<<<<<<<<<<<<<</color>")
    local status = GameManager.GetHintState({gotoui = key ,goto_scene_parm = _goto_scene_parm})
    -- dump(status,"<color=white>>>>>>>>>>>>status<<<<<<<<<<<<<<<<<<</color>")
    return status == ACTIVITY_HINT_STATUS_ENUM.AT_Red
end

function M.GetKeyFromId(_id)
    local enter_cfg = game_enter_btn_config.all_enter[_id]
    return enter_cfg.parm[1]
end

function M.SetLfIds(ids)
    this.m_data.lf_ids = ids
end

