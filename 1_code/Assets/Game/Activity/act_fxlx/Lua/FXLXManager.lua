-- 创建时间:2020-01-15
-- FXLXManager 管理器

local basefunc = require "Game/Common/basefunc"
FXLXManager = {}
local M = FXLXManager
M.key = "act_fxlx"

local this
local lister
local this_timer
local boy_names = GameButtonManager.ExtLoadLua(M.key,"robot_names_boy")
local girl_names = GameButtonManager.ExtLoadLua(M.key,"robot_names_girl")
GameButtonManager.ExtLoadLua(M.key,"FXLXPanel")
GameButtonManager.ExtLoadLua(M.key,"FXLXEnterPrefab")

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1586188799
    local s_time = 1585609200
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
-- 免费用户
function M.IsMfyh()
    local _permission_key = "invitation_gift"
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
        return FXLXPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return FXLXEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if  this.is_not_share or M.IsAwardCanGet() or not M.IsEnough() then 
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
    lister["fxlx_Broadcast_Info"] = this.on_fxlx_Broadcast_Info
    lister["query_fxlx_data_response"] = this.on_query_fxlx_data_response
    lister["shared_finish_response"] = this.on_shared_finish_response
    lister["query_everyday_shared_award_response"] = this.on_query_everyday_shared_award_response
end

function M.Init()
	M.Exit()
	this = FXLXManager
    this.m_data = {}
    this.is_not_share = false
	MakeLister()
    AddLister()
    M.InitUIConfig()
    M.SendBroadcastInfo()
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
        Network.SendRequest("query_fxlx_data")
        Network.SendRequest("query_everyday_shared_award", {type="shared_friend"})
	end
end

function M.OnReConnecteServerSucceed()

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
--持续发送广播信息
function M.SendBroadcastInfo()
    local random = math.random(0,8)
    local curr_Hour = tonumber(os.date("%H",os.time()))
    if curr_Hour <= 5 or curr_Hour >= 22 then 
        random = math.random(8,20)
    end 
    local func = function ()
        Event.Brocast("fxlx_Broadcast_Info",{playname = M.GetPlayerName()})
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

function M.on_fxlx_Broadcast_Info(data)
    --dump(data,"-----------名字信息----"..StringHelper.formatTimeDHMS2(os.time()))
end

function M.on_query_fxlx_data_response(_,data)
    dump(data,"<color=red>分享拉新-------------------------</color>")
    if data and data.result == 0 then 
        this.m_data = data.data
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end
end

function M.IsAwardCanGet()
    local data = M.GetData()
    if data then
        for i=1,#data do
            if data[i].get_award == 0 then 
                return true
            end 
        end
    end
    return false
end

function M.IsEnough()
    local data = M.GetData()
    if data then
        if #data >= 5 then 
            return true
        end
    end
    return false
end 

function M.GetData()
    if not table_is_null(this.m_data) then 
        return  this.m_data
    end
    return false
end

function M.on_shared_finish_response(_,data)
    if data and data.result == 0 then 
        this.is_not_share = false
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
        Network.SendRequest("query_fxlx_data")
    end
end

function M.on_query_everyday_shared_award_response(_,data)
    if data and data.status then
        if data.status == 1 then 
            this.is_not_share = true
        else
            this.is_not_share = false
        end 
        Event.Brocast("global_hint_state_set_msg", { gotoui = M.key })
    end
end

function M.GetIsNotShare()
    return  this.is_not_share
end 

function M.ShowPanel(parm)
    if parm and parm.backcall and M.IsMfyh() then 
        FXLXPanel.Create(nil,parm.backcall)
    else
        parm.backcall()
    end 
end