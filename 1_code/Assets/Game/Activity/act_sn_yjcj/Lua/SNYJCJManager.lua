-- 创建时间:2019-12-27
-- SNYJCJManager 管理器
-- 鼠年送福利_赢金福利

local basefunc = require "Game/Common/basefunc"
SNYJCJManager = {}
local M = SNYJCJManager
M.key = "act_sn_yjcj"

M.lottery_type = "rat_delivery"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_snyjcj_config")
GameButtonManager.ExtLoadLua(M.key, "SNYJCJPanel")
GameButtonManager.ExtLoadLua(M.key, "SNYJCJPrefab")

local this
local lister
local m_data

function M.IsActive()
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_common_lottery_rat_delivery", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    return true
end
-- 创建入口按钮时调用
function M.CheckIsShow()
    if M.IsActive() then
        if os.time() < this.UIConfig.act_parm_map.e_time and os.time() > this.UIConfig.act_parm_map.s_time then
            return true
        end
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    if M.IsActive() then
        return true
    end
end
-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then 
            return SNYJCJPanel.Create(parm)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    if LotteryBaseManager.IsAwardCanGet(M.lottery_type) then
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
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
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

    lister["get_one_common_lottery_info"] = M.SetData
end

function M.Init()
	M.Exit()

	this = SNYJCJManager
	m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()

    local type_info = {
        type = M.lottery_type,
        start_time = this.UIConfig.act_parm_map.s_time,
        end_time = this.UIConfig.act_parm_map.e_time,
        config = M.config,
    }
    LotteryBaseManager.AddQuery(type_info)
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    this.UIConfig.act_parm_map = {}
    if M.config.act_parm then
        for k,v in ipairs(M.config.act_parm) do
            this.UIConfig.act_parm_map[v.key] = v.value
        end
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
	end
end
function M.OnReConnecteServerSucceed()
end

function M.SetData()
    local data = LotteryBaseManager.GetData(M.lottery_type)
    if data then
        m_data.at_data = data
        m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        if LotteryBaseManager.IsAwardCanGet(M.lottery_type) then
            m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            m_data.at_status = ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
    end
    Event.Brocast("ui_button_data_change_msg", { key = M.key })
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.GetData()
    if table_is_null(m_data) then
        return nil
    end
    return m_data
end

function M.GetGetUIPos()
    local index_map = {}
    local ui_key = M.key .. "_uipos_" .. MainModel.UserInfo.user_id
    local pos_str = PlayerPrefs.GetString(ui_key, "")
    if m_data and m_data.at_data and m_data.at_data.now_game_num > 0 then
        local att = StringHelper.Split(pos_str, ",")
        if pos_str == "" or (att and #att ~= m_data.at_data.now_game_num) then
            pos_str = ""
            local index_list = MathExtend.RandomGroup(#M.config.Award)
            for i=1, m_data.at_data.now_game_num do
                index_map[i] = index_list[i]
                if pos_str == "" then
                    pos_str = "" .. index_list[i]
                else
                    pos_str = pos_str .. "," .. index_list[i]
                end
            end
            PlayerPrefs.SetString(ui_key, pos_str)
        else
            if att then
                for i=1, m_data.at_data.now_game_num do
                    index_map[i] = tonumber(att[i])
                end
            end
        end
    end
    return index_map
end
function M.SetGetUIPos(ui, index)
    local ui_key = M.key .. "_uipos_" .. MainModel.UserInfo.user_id
    local pos_str = PlayerPrefs.GetString(ui_key, "")
    if pos_str == "" then
        pos_str = "" .. ui
    else
        pos_str = pos_str .. "," .. ui
    end
    PlayerPrefs.SetString(ui_key, pos_str)
end
