-- 创建时间:2021-02-24
-- Act_051_CZLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_051_CZLBManager = {}
local M = Act_051_CZLBManager
M.key = "act_051_czlb"
GameButtonManager.ExtLoadLua(M.key,"Act_051_CZLBEnterPrefab")

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
        return Act_051_CZLBEnterPrefab.Create(parm.parent, parm.cfg)
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    
	return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
end
function M.on_global_hint_state_set_msg(parm)
    if not table_is_null(this.m_data.lf_ids) then
        for i = 1, #this.m_data.lf_ids do
            if parm.gotoui == M.GetKeyFromId(this.m_data.lf_ids[i]) then
                Event.Brocast("global_hint_state_change_msg", { gotoui = parm.gotoui })
            end
        end
    end
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

	this = Act_051_CZLBManager
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
    local local_time_data = PlayerPrefs.GetString(enter_cfg.parm[1] .. MainModel.UserInfo.user_id,0)

    if enter_cfg.parm[1] == "sys_011_yueka_new" then  --特殊处理
        local_time_data = os.date("%Y%m%d",local_time_data)
    end
    dump(local_time_data ,"<color=red>PPP</color>")
    if local_time_data == os.date("%Y%m%d",os.time()) then
        return false
    else
        return true
    end
end

function M.GetKeyFromId(_id)
    local enter_cfg = game_enter_btn_config.all_enter[_id]
    return enter_cfg.parm[1]
end

function M.SetLfIds(ids)
    this.m_data.lf_ids = ids
end
