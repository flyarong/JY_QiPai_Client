-- 创建时间:2020-07-06
-- Act_021_SXSHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_021_SXSHLManager = {}
local M = Act_021_SXSHLManager
M.key = "act_021_sxshl"
M.item_keys = {"prop_double_card_brass","prop_double_card_silver","prop_double_card_gold"}
M.task_id = 21528
GameButtonManager.ExtLoadLua(M.key,"Act_021_SXSHLPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_021_SXSHLShowAwardPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_021_SXSHLPanel")

local this
local lister
local prefab

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1601308799
    local s_time = 1600731000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_030_cjcj"
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
            return Act_021_SXSHLPanel.Create(parm.parent)
        end
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data then
        if data.award_status == 1 and M.GetAwardNum() < 50 then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        end
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
	lister["EnterScene"] = M.EnterScene
    lister["ExitScene"] = M.ExitScene
    lister["model_task_change_msg"] = M.on_model_task_change_msg
	lister["fishing_activity_begin"] = M.fishing_activity_begin
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["query_super_money_fake_data_response"] = this.on_query_super_money_fake_data_response
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_021_SXSHLManager
    this.m_data = {}
    this.jianchi = 1688888
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
        M.UpdateJiangChiData()
        Network.SendRequest("query_one_task_data", {task_id = M.task_id})
	end
end

function M.EnterScene()

    if not M.IsActive() then return end

	if MainModel.myLocation == "game_Fishing" and gameMgr:getMarketPlatform() == "normal" then
		prefab = Act_021_SXSHLPrefab.Create()
	elseif MainModel.myLocation == "game_Eliminate" then
		prefab = Act_021_SXSHLPrefab.Create()
	elseif MainModel.myLocation == "game_EliminateCS" then
		prefab = Act_021_SXSHLPrefab.Create()
	elseif MainModel.myLocation == "game_EliminateSH" then
		prefab = Act_021_SXSHLPrefab.Create()
	elseif MainModel.myLocation == "game_EliminateXY" then
		prefab = Act_021_SXSHLPrefab.Create()
	end

   
end

function M.OnReConnecteServerSucceed()
end

--捕鱼有加载过程
function M.fishing_activity_begin()
	if prefab then
		prefab.gameObject:SetActive(true)
	end
end

function M.ExitScene()
	prefab = nil
end

function M.on_query_super_money_fake_data_response(_,data)
    if data and data.result == 0 then
        this.jianchi = data.super_money
        Event.Brocast("act_021_sxshl_get")
    end
end

function M.GetJiangChiVar()
    local v = M.number_to_array(this.jianchi)
    return v
end


function M.number_to_array(number,len)
    local tbl = {}
    local nn = number
    while nn > 0 do
        tbl[#tbl + 1] = nn % 10
        nn = math.floor(nn / 10)
    end

    local array = {}
    if len then
        if len > #tbl then
            for idx = len, 1, -1 do
                if idx > #tbl then
                    array[#array + 1] = 0
                else
                    array[#array + 1] = ""..tbl[idx]
                end
            end
        else
            for idx = #tbl, 1, -1 do
                array[#array + 1] = ""..tbl[idx]
            end
            print("<color=red>EEE 长度定义不合理 number = " .. number .. "  len = " .. len .. "</color>")
        end
    else
        for idx = #tbl, 1, -1 do
            array[#array + 1] = ""..tbl[idx]
        end
    end
    return array
end

function M.UpdateJiangChiData()
    if this.timer then
        this.timer:Stop()
    end
    Network.SendRequest("query_super_money_fake_data")
    this.timer = Timer.New(function ()
        Network.SendRequest("query_super_money_fake_data")
    end,600,-1)
    this.timer:Start()
end

function M.on_model_task_change_msg(data)
    if data.id == M.task_id  then
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end

function M.GetAwardNum()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data then
        if data.other_data_str then
            local data = basefunc.parse_activity_data(data.other_data_str)
            return data.award_num or 0
        end 
    end
    return 0
end 

function M.IButton()
    
end