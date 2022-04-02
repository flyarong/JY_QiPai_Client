-- 创建时间:2020-06-02
-- Act_020_JBBXManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_020_JBBXManager = {}
local M = Act_020_JBBXManager
M.key = "act_020_jbbx"
Act_020_JBBXManager.config = GameButtonManager.ExtLoadLua(M.key,"act_020_jbbx_config")
GameButtonManager.ExtLoadLua(M.key,"Act_020_JBBXEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_020_JBBXPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_020_JBBXItemBase")
local this
local lister
local permisstions = {
    "actp_buy_gift_bag_class_jingbi_chest_1",
    "actp_buy_gift_bag_class_jingbi_chest_2",
    "actp_buy_gift_bag_class_jingbi_chest_3",
}

M.now_level = 0
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1595284200
    local s_time = 1594683000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    dump(M.GetNowPerMiss(),"<color=red>抽奖礼包权限</color>")
    if M.GetNowPerMiss() then 
        return true
    end
end

function M.GetNowPerMiss()
    local cheak_fun = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return false
        end
        return true
    end
    M.now_level = nil
    for i = 1,#permisstions do 
        if cheak_fun(permisstions[i]) then
            dump(permisstions[i],"符合条件的权限")
            M.now_level = i  
            return i
        end
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
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["ActivityYearPanel_Had_Finish"] = this.on_ActivityYearPanel_Had_Finish

    --请求假数据
    lister["query_box_exchange_broadcast_data_response"] = this.on_query_box_exchange_broadcast_data_response
    --监听权限改变
    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg
    lister["EnterBackGround"] = this.on_background_msg

    lister["query_box_exchange_info_response"] = this.on_query_box_exchange_info_response

    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg

    lister["AssetChange"] = this.on_AssetChange

end

function M.Init()
	M.Exit()

	this = Act_020_JBBXManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
    M.Stop_Query_UnrealyData()
    M.Stop_Query_BXData()
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
        M.Init()
        if M.IsActive() then
            M.Query_UnrealyData()
        end
    end
end

function M.OnReConnecteServerSucceed()
end

function M.on_background_msg()
    Event.Brocast("CJLB_on_background_msg")
end


function M.on_ActivityYearPanel_Had_Finish(parm)
    if M.CheckIsShow() and parm then
        Act_020_JBBXEnterPrefab.Create(parm.panelSelf.transform)
    end
end

function M.on_query_box_exchange_broadcast_data_response(_,data)
    dump(data,"<color=blue>on_get_one_login_benefits_false_lottery_data_response</color>")
    if data and data.result == 0 then
        this.m_data.unrealy = this.m_data.unrealy or {}
        this.m_data.unrealy.name = data.name            --虚假数据的玩家昵称
        this.m_data.unrealy.award_name = data.type--虚假数据的宝箱名称
        this.m_data.unrealy.award_id = data.award_id    --虚假数据的奖励id
        Event.Brocast("model_cjlb_unrealy_change_msg")--刷新假数据
    end
end


------------------------------

--获取虚假数据的玩家名字
function M.GetUnrealyPlayerName()
    return this.m_data.unrealy.name
end

--获取虚假数据的宝箱名称
function M.GetUnrealyAwardName()
    return this.m_data.unrealy.award_name
end

--获取虚假数据的奖励id
function M.GetUnrealyAwardID()
    return this.m_data.unrealy.award_id
end

----------------------------


--每30秒请求一次跑马灯数据
function M.Query_UnrealyData()
    M.Stop_Query_UnrealyData()
    M.timer = Timer.New(function ()
                M.QueryUnrealyData()
        end, 5, -1, false,true)
    M.timer:Start()
end

function M.Stop_Query_UnrealyData()
    if M.timer then
        M.timer:Stop()
        M.timer = nil
    end
end

function M.QueryUnrealyData()
    Network.SendRequest("query_box_exchange_broadcast_data",{id = M.now_level})
end

function M.on_client_system_variant_data_change_msg()
    M.IsActive()
    if M.now_level and M.now_level ~= 0 then
        M.query_data(this.m_data.id)
    end
end


--获取配置表信息
function M.GetConfig()
    return M.config[M.now_level]
end

--请求宝箱数据
function M.query_data(id)
    if not id then return end
    this.m_data.id = id
    dump(id,"<color=yellow>++++++++++++++++请求宝箱数据++++++++++++++++</color>")
    Network.SendRequest("query_box_exchange_info",{id = id})
end


function M.on_query_box_exchange_info_response(_,data)
    dump(data,"<color>++++++++++query_box_exchange_info++++++++++</color>")
    if data then
        if data.result == 0 then
            this.m_data.time = this.m_data.time or {}
            this.m_data.time[data.id] = os.time()
            this.m_data.bx_data = this.m_data.bx_data or {}
            this.m_data.bx_data[data.id] = data
            if M.isInitAllBXData() then
                Event.Brocast("model_cjlb_bx_change_msg",data.id)
            end
        else    
            M.Query_BXData_Timer(false)
            HintPanel.ErrorMsg(data.result)
        end
    end
end

function M.GetCurBXData()
    return this.m_data.bx_data
end

function M.OpenPanelToQueryData(id)
    if this.m_data.bx_data and this.m_data.bx_data[id] and (os.time() - this.m_data.time[id]) < 5 then
        if M.isInitAllBXData() then
            Event.Brocast("model_cjlb_bx_change_msg",id)
        end 
    else    
        M.query_data(id)
    end
end


function M.Query_BXData_Timer(b,id)
    M.Stop_Query_BXData()
    if b then
        M.timer1 = Timer.New(function ()
                    dump(id,"<color>++++++++++++Query_BXData_Timer++++++++++++</color>")
                    M.query_data(id)
            end, 15, -1, false,true)
        M.timer1:Start()
    end
end

function M.Stop_Query_BXData()
    if M.timer1 then
        M.timer1:Stop()
        M.timer1 = nil
    end
end

--链式请求宝箱数据,以判断打开panel时的默认显示
function M.Query_AllBXData()
    if M.isInitAllBXData() then
        Event.Brocast("CJLB_All_BX_Data_is_Init_msg")
        return
    end
    local msg_list = {}
    for k,v in pairs(M.GetConfig()) do
        dump(v.ID,"<color>++++++++++++++v.ID+++++++++++++</color>")
        msg_list[#msg_list + 1] = {msg="query_box_exchange_info", data = {id = v.ID}}
    end
    GameManager.SendMsgList("cjlb", msg_list)
end

function M.on_query_send_list_fishing_msg(tag)
    if tag == "cjlb" then
        Event.Brocast("CJLB_All_BX_Data_is_Init_msg")
    end
end

function M.GetDefineBX()
    local config = M.GetConfig()
    local temp = 0
    local index = 0
    for i=3,1,-1 do
        if this.m_data.bx_data[config[i].ID].exchange_count > temp and this.m_data.bx_data[config[i].ID].exchange_count ~= 3 then
           temp = this.m_data.bx_data[config[i].ID].exchange_count
           index = i
        end
    end
    if index == 0 then--"都没买过"或是"都买完了",默认黄金宝箱
        if this.m_data.bx_data[config[2].ID].exchange_count == 3 then
            if this.m_data.bx_data[config[3].ID].exchange_count == 3 then
                if this.m_data.bx_data[config[1].ID].exchange_count == 3 then
                    index = 2
                else    
                    index = 1
                end
            else
                index = 3
            end
        else
            index = 2
        end
    end
    return index
end

function M.isInitAllBXData()
    local config = M.GetConfig()
    if this.m_data.bx_data then
        for i=1,3 do
            if not this.m_data.bx_data[config[i].ID] then
                return
            end
        end
    else
        return
    end
    return true
end


function M.GetNowLevel()
    return M.now_level
end


function M.on_AssetChange(data)
    dump(data,"<color=green>+++++++++++++on_AssetChange+++++++++++++</color>")
    if data and data.change_type and string.sub(data.change_type,1,26) == "box_exchange_active_award_" then
        Event.Brocast("CJLB_on_AssetChange_msg")
    end
end