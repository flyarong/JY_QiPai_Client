-- 创建时间:2020-02-12
-- DTTJYXWManager 管理器
-- 大厅推荐游戏位

local basefunc = require "Game/Common/basefunc"
DTTJYXWManager = {}
local M = DTTJYXWManager
M.key = "sys_dttjyxw"
local hall_tjyx_config = GameButtonManager.ExtLoadLua(M.key, "hall_tjyx_config")
GameButtonManager.ExtLoadLua(M.key, "DTTJ_BYPrefab")
GameButtonManager.ExtLoadLua(M.key, "DTTJ_WZQPrefab")

local this
local lister

function M.get_tj_cfg()
    if this.UIConfig.tj_list and #this.UIConfig.tj_list > 0 then
        for k,v in ipairs(this.UIConfig.tj_list) do
            local cfg = v
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=cfg.condi_key, is_on_hint=true}, "CheckCondition")
            if not a or b then
                return cfg
            end
        end
    end
end
-- 是否有活动
function M.IsActive()
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
    if parm.goto_scene_parm == "prefab" then
        local cfg = M.get_tj_cfg()
        if cfg and _G[cfg.lua] then
            return _G[cfg.lua].Create(parm.parent, cfg)
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

	this = DTTJYXWManager
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
    this.UIConfig.tj_list = {}
    for k,v in ipairs(hall_tjyx_config.config) do
        if v.isOnOff == 1 then
            this.UIConfig.tj_list[#this.UIConfig.tj_list + 1] = v
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end
