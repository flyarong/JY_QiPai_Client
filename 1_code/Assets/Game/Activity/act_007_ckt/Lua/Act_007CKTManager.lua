-- 创建时间:2020-03-10
-- Act_007CKTManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_007CKTManager = {}
local M = Act_007CKTManager
M.key = "act_007_ckt"
GameButtonManager.ExtLoadLua(M.key, "Act_007CKTPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_007CKTEnterPrefab")
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_007_ckt_config")
local boy_names = GameButtonManager.ExtLoadLua(M.key,"act_007_robot_names_boy")
local girl_names = GameButtonManager.ExtLoadLua(M.key,"act_007_robot_names_girl")
local this
local lister
M.task_id = 21219
local this_timer
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1586793599
    local s_time = 1586302200
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_box_exchange_15"
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
    if parm.goto_scene_parm == "panel" then
        if M.IsActive() then 
            return Act_007CKTPanel.Create(parm.parent,parm.backcall)
        end 
    end 
    if parm.goto_scene_parm == "enter" then
        return Act_007CKTEnterPrefab.Create(parm.parent)
    end 
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime then
                return ACTIVITY_HINT_STATUS_ENUM.AT_Red
            end
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end 
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
    lister["AssetChange"] = this.Refresh

end

function M.Init()
	M.Exit()

	this = Act_007CKTManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.InitUIConfig()
    M.SendBroadcastInfo()
end

function M.Exit()
    if this then
        if this_timer then 
            this_timer:Stop()
        end
        this_timer = nil
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    this.UIConfig = {}
end

function M.OnLoginResponse(result)
    if result == 0 then

	end
end

function M.OnReConnecteServerSucceed()
    
end

function M.IsAwardCanGet()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data then 
        if MainModel.GetHBValue() >= 1 or data.award_status == 1 then 
            return true
        end
    end
end

function M.SendBroadcastInfo()
    math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    local random = math.random(1,8)
    local curr_Hour = tonumber(os.date("%H",os.time()))
    if curr_Hour <= 5 or curr_Hour >= 22 then 
        random = math.random(8,20)
    end 
    local func = function ()
        Event.Brocast("Act_007_ckt_Broadcast_Info",{playname = M.GetPlayerName(),awardname = M.GetRomdomAwardName()})
    end 
    if this_timer then 
        this_timer:Stop()
    end
    this_timer = nil 
    this_timer = Timer.New(function ()
        func()
        M.SendBroadcastInfo()
    end,random,1)
    this_timer:Start()
end

function M.GetPlayerName()
    local random = math.random(0,99)
    local name
    if random > 30 then 
        name = basefunc.deal_hide_player_name(boy_names[math.random(1,#boy_names)])
    else
        name = basefunc.deal_hide_player_name(girl_names[math.random(1,#girl_names)])
    end 
    return name
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.GetRomdomAwardName()
    this.total = this.total or 0
    if table_is_null(this.area) then
        local area = {}
        local get_area_fun = function (_M)
            local _min = 0
            local _max = 0
            for i = 1,_M do 
                _max = _max + M.config.fake_base[i].weight
                if i >= 2 then 
                    _min = _min + M.config.fake_base[i - 1].weight
                else
                    _min = 0
                end 
            end
            area[_M] = {_min = _min,_max = _max}
        end

        for i = 1 ,#M.config.fake_base do 
            this.total = this.total + M.config.fake_base[i].weight
            get_area_fun(i)
        end
        this.area = area
    end
    local r = math.random(1,this.total * 10)
    local get_award_index = 1
    for i = 1,#this.area do
        local r = r / 10
        if r >= this.area[i]._min and r <= this.area[i]._max then 
            get_award_index = i
            break
        end
    end
    local award_name = M.config.fake_base[get_award_index].award_name.." x"
    if M.config.fake_base[get_award_index].asset_type == "shop_gold_sum" then
        award_name = "福卡".." x"
    elseif M.config.fake_base[get_award_index].asset_type == "jing_bi" then 
        award_name = "鲸币".." x"
    end
    local award_count = 1
    if type(M.config.fake_base[get_award_index].asset_count) == "table" then 
        local r = math.random(M.config.fake_base[get_award_index].asset_count[1],M.config.fake_base[get_award_index].asset_count[2])
        award_count = r
    else
        award_count = M.config.fake_base[get_award_index].asset_count
    end
    if M.config.fake_base[get_award_index].asset_type == "shop_gold_sum" then 
        award_count = award_count / 100
    end
    return award_name..award_count
end