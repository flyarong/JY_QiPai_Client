-- 创建时间:2021-06-03
-- FKZJDManager 管理器

local basefunc = require "Game/Common/basefunc"
FKZJDManager = {}
local M = FKZJDManager
M.key = "act_033_fkzjd"

GameButtonManager.ExtLoadLua(M.key, "FKZJDPanel")
GameButtonManager.ExtLoadLua(M.key, "FKZJDEnterPrefab")
local config = GameButtonManager.ExtLoadLua(M.key, "activity_fkzjd_config")

local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = config.base.Info.endTime
    local s_time = config.base.Info.beginTime
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
        return FKZJDEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return FKZJDPanel.Create()
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsHint() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get 
    end
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
    Event.Brocast("global_hint_state_change_msg",{gotoui = "act_059_dwjj_jrlb"})
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
    lister["model_task_change_msg"] = this.on_task_change_msg
end

function M.Init()
	M.Exit()

	this = FKZJDManager
	this.m_data = {}
    this.m_data.m_egg_lv = 0
    this.m_data.m_gift = {}
    this.m_data.m_task_round = {}
	MakeLister()
    AddLister()
    M.InitCfg()
	M.InitUIConfig()
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitCfg()
    M.InitGiftCfg()
    M.InitEggCfg()
end

local checkPermiss = function(condi)
    local a,b = GameButtonManager.RunFun({gotoui = "sys_qx", _permission_key = condi, is_on_hint = true}, "CheckCondition")
    if a and b then
        return true
    end
end

function M.InitGiftCfg()
    for i = 1, #config.gift do
        if checkPermiss(config.gift[i].permiss) then
            this.m_data.m_gift[#this.m_data.m_gift + 1] = config.gift[i]
        end
    end
end

function M.InitEggCfg()
    for i = 1, #config.base.Info.permissions do
        if checkPermiss(config.base.Info.permissions[i]) then
            this.m_data.m_egg_lv = i
        end
    end
end

function M.GetInfoCfg()
    return config.base.Info
end

function M.GetGiftCfg()
    return this.m_data.m_gift
end

function M.GetEggCfg(index)
    return config.egg[index]
end

function M.GetHammerCount(index)
    return GameItemModel.GetItemCount(this.m_data.m_gift[index].item[2])
end

function M.GetCurHitNum(index)
    local hit_num = 0
	local data = GameTaskModel.GetTaskDataByID(config.egg[index].task_id)
	if data ~= nil then
		local other_data = basefunc.parse_activity_data(data.other_data_str)
		hit_num = other_data.now_hit_num
	end
	return hit_num
end

function M.GetEggAward(index)
    if this.m_data.m_egg_lv == 0 then
        return 0
    end
    return config.egg[index].award[this.m_data.m_egg_lv]
end

function M.GetDefaultHamIndex()
    local _index = 3
    for i =  1, #this.m_data.m_gift do
        if GameItemModel.GetItemCount(this.m_data.m_gift[i].item[2]) > 0 then
            _index = i
        end
    end
    return _index
end

function M.IsCareTaskId(task_id)
    for i = 1, #config.egg do
        if task_id == config.egg[i].task_id then
            return true
        end
    end
end

function M.IsCareGiftId(gift_id)
    for i = 1, #this.m_data.m_gift do
        if this.m_data.m_gift[i].gift_id == gift_id then
            M.InitCfg()
            return true
        end
    end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.IsHint()
    for i = 1, 3 do
        if M.GetHammerCount(i) > 0 then
            return true
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

function M.on_task_change_msg(parm)
    if M.IsCareTaskId(parm.id) then
        M.SetHintState()
    end
end