-- 创建时间:2020-11-20
-- Template_NAME 管理器

local basefunc = require "Game/Common/basefunc"
Act_040_XQDHManager = {}
local M = Act_040_XQDHManager
M.key = "act_040_xqdh"
Act_040_XQDHManager.config = GameButtonManager.ExtLoadLua(M.key,"act_040_xqdh_config")
GameButtonManager.ExtLoadLua(M.key,"Act_040_XQDHItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_040_XQDHPanel")

local this
local lister

local gift_ids
local gift_data
M.type = 19
M.item_key = "prop_040_snowball" --雪球
--money "106306","prop_040_snowball",100000
local limit_icons = 
{
    "xqdh_icon_xl1",
    "xqdh_icon_xl2",
    "xqdh_icon_xl3"
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1607356799
    local s_time = 1606779000
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
    if M.IsActive() then
        return true
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Act_040_XQDHPanel.Create(parm.parent,parm.backcall)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    --return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) or not M.CheakIsShow(parm.condi_key) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsItemCanGet() then
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
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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
    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg
    lister["query_activity_exchange_response"] = this.on_query_activity_exchange_response
    lister["activity_exchange_response"] = this.on_activity_exchange_response
    lister["AssetChange"] = this.on_AssetChange
end

function M.Init()
	M.Exit()

	this = Act_040_XQDHManager
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
    gift_ids = {}
    for i=1,#M.config.Info do
        gift_ids[i] = M.config.Info[i].ID or {}
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        if M.IsActive() then
            Timer.New(function ()
                M.query_data()
            end, 1, 1):Start()
        end
	end
end

function M.OnReConnecteServerSucceed()
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
    Event.Brocast("model_xqdh_data_change_msg")--刷新panel
end

function M.IsItemCanGet()
    local item = M.GetItemCount()
    for k,v in ipairs(gift_ids) do
        if gift_data and gift_data[v] and gift_data[v] ~= 0 and item >= tonumber(M.config.Info[k].item_cost_text)  then
            return k
        end
    end
end

function M.GetItemCount()
    return GameItemModel.GetItemCount(M.item_key)
end

local CheckGiftDataFinish = function ()
    for k,v in ipairs(gift_ids) do
        if not gift_data[v] then
            return false
        end
    end
    return true
end


function M.QueryGiftData()
    if not this.m_data.time then
        this.m_data.time = 0
    end
    if gift_data and CheckGiftDataFinish() and (os.time() - this.m_data.time < 5) then
        Event.Brocast("model_xqdh_data_change_msg")
    else
        M.query_data()
    end
end

function M.GetCurData()
    local _cur_data = {}
    for i=1,#M.config.Info do
        _cur_data[i] = {}
        _cur_data[i].ID = M.config.Info[i].ID--ID
        _cur_data[i].award_name = M.config.Info[i].award_name--奖励的名字
        _cur_data[i].award_image = M.config.Info[i].award_image--奖励的图片
        _cur_data[i].item_cost_text = M.config.Info[i].item_cost_text--道具消耗text
        _cur_data[i].type = M.config.Info[i].type--实物奖励为1,普通奖励为0   
        _cur_data[i].award_text = M.config.Info[i].award_text 
        _cur_data[i].limit_num = M.config.Info[i].limit_num 

        if gift_data[_cur_data[i].ID] then
            _cur_data[i].limit_num = gift_data[_cur_data[i].ID]
        else
            _cur_data[i].limit_num = 0
        end
        
        if M.config.Info[i].tips then
            _cur_data[i].tips = M.config.Info[i].tips--奖励特殊描述
        end
    end
    return _cur_data
end


function M.on_client_system_variant_data_change_msg()
    M.IsActive()
    M.query_data()
end


function M.on_query_activity_exchange_response(_,data)
    dump(data,"<color>+++++++on_query_activity_exchange_response++++++</color>")
    if data then
        if data.result == 0 then
            if data.type == M.type then
                this.m_data.time = os.time()
                gift_data = data.exchange_day_data
                M.Refresh_Status()
                Event.Brocast("model_xqdh_data_change_msg")
            end
        else
            M.Query_data_timer(false)
        end
    end
end

function M.query_data()
    if M.IsActive() then
        Network.SendRequest("query_activity_exchange",{type = M.type})
    end
end

function M.Query_data_timer(b)
    M.Stop_Query_data()
    if b then
        M.timer1 = Timer.New(function ()
                    M.query_data()
            end, 15, -1, false)
        M.timer1:Start()
    end
end

function M.Stop_Query_data()
    if M.timer1 then
        M.timer1:Stop()
        M.timer1 = nil
    end
end

function M.on_activity_exchange_response(_,data)
    dump(data,"<color>+++++++on_activity_exchange_response++++++</color>")
    if data then
        if data.result == 0 then
            M.query_data()
            Event.Brocast("xqdh_sw_kfPanel_msg",data.id)
        else
            HintPanel.ErrorMsg(data.result)
        end
    end
end

function M.CheakIsShow(_permission_key)
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

function M.on_AssetChange(data)
    if data then
        for k,v in pairs(data.data) do
            if v.asset_type and v.asset_type == M.item_key then
                M.Refresh()
            end
        end
    end
end

function M.GetLimitIcon(_index)
    if _index == -1  then
        return "xqdh_icon_bxl"
    else
        return limit_icons[_index]
    end
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end