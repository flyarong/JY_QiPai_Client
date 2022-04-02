-- 创建时间:2020-05-11
-- Sys_013_FFYDManager 管理器

local basefunc = require "Game/Common/basefunc"
Sys_013_FFYDManager = {}
local M = Sys_013_FFYDManager
M.key = "sys_013_ffyd"
GameButtonManager.ExtLoadLua(M.key, "Sys_013_FFYDGameHallPrefab")
GameButtonManager.ExtLoadLua(M.key, "Sys_013_FFYDGuidePanel")

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
    lister["hallpanel_created"] = this.on_hallpanel_created
    lister["PPC_Created"] = this.On_PPC_Created
    lister["multicast_msg"] = this.on_multicast_msg
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["EnterScene"] = this.On_EnterScene
end

function M.Init()
	M.Exit()

	this = Sys_013_FFYDManager
	this.m_data = {}
	MakeLister()
    AddLister()
    -- for i = 1,1000 do
    --     M.AddWaitData({content = "33333333333333"})
    -- end
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


function M.on_hallpanel_created(data)
    dump(data,"<color=red>大厅创建了吗？</color>")
    if data and data.panelSelf then 
        Sys_013_FFYDGameHallPrefab.Create(data.panelSelf.MINIGAMEBox.transform)
    end
end

function M.On_PPC_Created(data)
    --匹配场大厅
    -- dump(data,"<color=red>匹配场大厅</color>")
    -- if data and data.panelSelf then
    --     local old_func = data.panelSelf.OnBackClick
    --     dump(old_func)
    --     local new_func = function ()
    --         old_func(data.panelSelf)
    --         print("<color=red>付费引导</color>")
    --     end
    --     data.panelSelf.OnBackClick = new_func
    -- end
end

function M.On_EnterScene()
    --从匹配转到大厅
    if not MainModel.UserInfo or MainModel.IsHWLowPlayer() then
        return 
    end
    
    if MainModel.lastmyLocation == "game_Free" and MainModel.myLocation == "game_Hall" then
        if M.GetTimes(1) <= 100 then
            if os.time() > MainModel.UserInfo.first_login_time + 3 * 86400 and VIPManager.get_vip_level() == 0 then
                Sys_013_FFYDGuidePanel.Create(1,2)
                M.SaveTimes(1)
                return 
            end
            if VIPManager.get_vip_level() >= 1 then
                Sys_013_FFYDGuidePanel.Create(1,3)
                M.SaveTimes(1)
                return 
            end
        end
    end
    --从捕鱼到捕鱼大厅
    if MainModel.lastmyLocation == "game_Fishing" and MainModel.myLocation == "game_FishingHall" then
        if M.GetTimes(2) <= 100 then 
            if VIPManager.get_vip_level() == 0 then
                Sys_013_FFYDGuidePanel.Create(2,4)
                M.SaveTimes(2)
                return 
            end
            if VIPManager.get_vip_level() >= 1 then
                Sys_013_FFYDGuidePanel.Create(3,2)
                M.SaveTimes(2)
                return 
            end
        end
    end
end

function M.RandomToDo(mid,max)
    math.randomseed(os.time())
    local r = math.random(0,max)
    if r < mid then
        return true
    else
        return false
    end
end
--Index是某个时间的编号
--某件事做了多少次
function M.SaveTimes(Index)
    local t = M.GetTimes(Index)
    PlayerPrefs.SetInt(MainModel.UserInfo.user_id..M.key..Index,t + 1)
end

function M.GetTimes(Index)
    return PlayerPrefs.GetInt(MainModel.UserInfo.user_id..M.key..Index,0)
end

local info_data = {}
function M.on_multicast_msg(_,data)
    if data and data.type == 4 then
        M.AddWaitData(data)
    end
end

function M.AddWaitData(data)
    table.insert(info_data,1,data)
end

function M.RemoveWaitData()
    table.remove(info_data,#info_data)
end

function M.GetWaitData()
	return info_data[#info_data]
end


