-- 创建时间:2021-12-01
-- Act_070_ZQLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_070_ZQLBManager = {}
local M = Act_070_ZQLBManager
M.key = "act_070_zqlb"
GameButtonManager.ExtLoadLua(M.key, "Act_070_ZQLBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_070_ZQLBEnterPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "act_070_zqlb_config")

local this
local lister

M.beginTime = 1639438200
M.endTime = 1640015999

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.endTime
    local s_time = M.beginTime
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
        return Act_070_ZQLBEnterPrefab.Create(parm.parent)
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
    lister["year_panel_exit"] = this.on_year_panel_exit
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_070_ZQLBManager
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

function M.GetCurLv()
    local level = 0
    local check_func = function(_permission_key)
        local a, b = GameButtonManager.RunFun({ gotoui = "sys_qx", _permission_key = _permission_key, is_on_hint = true }, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    end

    for i = 1, #config do
        if check_func(config[i].permission) then
            level = i
        end
    end
    return level
end

function M.GetCurConfig()
    local lv = M.GetCurLv()
    return config[lv]
end

function M.IsBoughGift()
    local lv = M.GetCurLv()
    if not config[lv] then
        return true
    end 
    local giftStatus = MainModel.GetGiftShopStatusByID(config[lv].gift_id)
    --如果获取不到礼包，就按买了礼包处理
    if not giftStatus then
        return true
    end
    return giftStatus ~= 1
end

function M.on_year_panel_exit()
    dump("<color=white>AAA</color>")
    if MainModel.myLocation == "game_Fishing" and not M.IsBoughGift() then
        Act_070_ZQLBPanel.Create()
    end
end
