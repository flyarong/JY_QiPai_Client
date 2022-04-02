-- 创建时间:2021-05-17
-- ACTDNSManager 管理器

local basefunc = require "Game/Common/basefunc"
ACTDNSManager = {}
local M = ACTDNSManager
M.key = "act_dns"
local config = GameButtonManager.ExtLoadLua(M.key, "act_dns_config")
GameButtonManager.ExtLoadLua(M.key, "ACTDNSPanel")
GameButtonManager.ExtLoadLua(M.key, "ACTDNSEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTDNSPathPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACTDNSLJItemBase")

local this
local lister
local yuanbao_key = "prop_fish_drop_act_0"
local bp_key1 = "prop_nianshou_firecrackers_high"
local bp_key2 = "prop_nianshou_firecrackers_down"
M.act_type = "danianshou"
M.is_debug = false

-- 是否有活动
function M.IsActive(parm)
    -- 活动的开始与结束时间
    local e_time=M.GetActEndtime()
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key
    if parm.condi_key then
        _permission_key = parm.condi_key
    end
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
    return M.IsActive(parm)
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

    if parm.goto_scene_parm == "panel" then
        return ACTDNSPanel.Create(parm.parent, parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return ACTDNSEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
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

    lister["model_task_change_msg"] = this.on_model_task_change_msg

    lister["AssetsGetPanelCreating"] = this.on_AssetsGetPanelCreating

    lister["kill_activity_getInfo_response"] = this.on_kill_activity_getInfo_response
    lister["kill_activity_dice_response"] = this.on_kill_activity_dice_response
    lister["kill_activity_killBoss_response"] = this.on_kill_activity_killBoss_response
    lister["AssetChange"] = this.OnAssetChange
end

function M.Init()
	M.Exit()

	this = ACTDNSManager
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
    this.UIConfig.config = {}

    this.UIConfig.mapconfig = {}
    this.UIConfig.ljconfig = {}
    for i=1,#config.config do
        this.UIConfig.mapconfig[i] = {}
        this.UIConfig.ljconfig[i] = {}
        for j=1,#config.config[i].map_id_list do
            this.UIConfig.mapconfig[i][#this.UIConfig.mapconfig[i] + 1] = config.map[config.config[i].map_id_list[j]]
        end
        for j=1,#config.config[i].lj_award do
            this.UIConfig.ljconfig[i][#this.UIConfig.ljconfig[i] + 1] = config.lj[config.config[i].lj_award[j]]
        end
    end
    this.UIConfig.endTime_list = {1644854399}
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetMapConfigByPage(page_index)
    return this.UIConfig.mapconfig[page_index]
end

function M.GetActEndtime()
    for i=1,#this.UIConfig.endTime_list do
        if os.time() <= this.UIConfig.endTime_list[i] then
            this.UIConfig.endTime = this.UIConfig.endTime_list[i]
            return this.UIConfig.endTime
        end
    end
    return this.UIConfig.endTime_list[#this.UIConfig.endTime_list]
end

function M.IsHint()
    if M.GetCurYuanBaoNum() >= 100 or M.GetCurBPNum(1) > 0 or M.GetCurBPNum(2) > 0 then
        return true
    end
    local task1 = M.GetLJConfig(1)[1].task
    local task2 = M.GetLJConfig(2)[1].task
    local data1 = GameTaskModel.GetTaskDataByID(task1)
    local data2 = GameTaskModel.GetTaskDataByID(task2)
    if (data1 and (data1.award_status == 1)) or (data2 and (data2.award_status == 1)) then
        return true
    end
    return false
end
-- 网络请求
function M.QueryBaseData(sec_type)
    Network.SendRequest("kill_activity_getInfo",{act_type = M.act_type})
end

function M.on_model_task_change_msg(data)
    local task1 = M.GetLJConfig(1)[1].task
    local task2 = M.GetLJConfig(2)[1].task
    if data.id == task1 or data.id == task2 then
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    end
end

function M.on_kill_activity_getInfo_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_kill_activity_getInfo_response++++++++++</size></color>")
    if data.result == 0 then
        this.m_data.baseData = data.player_data
        M.SetLastPos()
        Event.Brocast("kill_activity_getInfo_response_msg")
    end
end

function M.on_kill_activity_dice_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_kill_activity_dice_response++++++++++</size></color>")
    if data.result == 0 then
        this.m_data.diceData = data.dice_data
        this.m_data.baseData = data.player_data
        Event.Brocast("kill_activity_dice_response_msg")
    end
end

function M.SetLastPos()
    this.m_data.lastPos1 = this.m_data.baseData.spec_pos
    this.m_data.lastPos2 = this.m_data.baseData.nor_pos
end

function M.GetLastPos(type)
    if type == 1 then
        return this.m_data.lastPos1
    elseif type == 2 then
        return this.m_data.lastPos2
    end
end

--获得资产面板创建时
function M.on_AssetsGetPanelCreating(data, panelUI)
    -- dump(data, "<color=white>MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM</color>")
    --[[local isContainSz = false
    if not table_is_null(data.data) then
        for i = 1, #data.data do
            if data.data[i].asset_type == "prop_dice" then
                isContainSz = true
                break
            end
        end
    end
    if isContainSz then
        local gotoBtnObj = GameObject.Instantiate(panelUI.confirm_btn)
        gotoBtnObj.name = "goto_btn"
        gotoBtnObj.transform:SetParent(panelUI.confirm_btn.transform.parent)
        local gotoBtn = gotoBtnObj:GetComponent("Button")
        gotoBtn.onClick:AddListener(function()
            Event.Brocast("CloseAssetsPanel")
            ACTDNSPanel.Create()
        end)
        panelUI.confirm_btn.transform.localPosition = Vector3.New(-237, -325.78, 0)
        gotoBtnObj.transform.localPosition = Vector3.New(177, -325.78, 0)
        gotoBtnObj.transform.localScale = Vector3.New(1.1, 1.1, 1.1)
        local txt = gotoBtnObj.transform:Find("ImgOneMore"):GetComponent("Text")
        txt.text = "去使用"
    end--]]
end 

function M.GetBaseData()
    return this.m_data.baseData
end

function M.GetDicData()
    return this.m_data.diceData
end


function M.GetTaskConfig()
    return this.UIConfig.task_config
end

function M.GetCurYuanBaoNum()
    local num
    if M.is_debug then
        num = 0
    else
        num = GameItemModel.GetItemCount(yuanbao_key)
    end
    return num
end

function M.GetCurBPNum(type)
    local num
    if M.is_debug then
        num = 0
    else
        if type == 1 then
            num = GameItemModel.GetItemCount(bp_key1)
        elseif type == 2 then
            num = GameItemModel.GetItemCount(bp_key2)
        end
    end
    return num
end

function M.GetLJConfig(type)
    return this.UIConfig.ljconfig[type]
end

function M.on_kill_activity_killBoss_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_kill_activity_killBoss_response++++++++++</size></color>")
    if data.result == 0 then
        this.m_data.baseData = data.player_data
        this.m_data.hurt_data = data.hurt_data
        Event.Brocast("kill_activity_killBoss_response_msg")
    end
end

function M.GetCurHurtData()
    return this.m_data.hurt_data
end

function M.OutTime()
    return os.time() > M.GetActEndtime()
end

function M.OnAssetChange(data)
    if not table_is_null(data.data) then
        for k,v in pairs(data.data) do
            if v.asset_type == yuanbao_key or v.asset_type == bp_key1 or v.asset_type == bp_key2 then
                Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
                return
            end
        end
    end
end