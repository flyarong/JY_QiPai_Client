-- 创建时间:2021-08-23
-- Act_066_JNBJLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_066_JNBJLManager = {}
local M = Act_066_JNBJLManager
M.key = "act_066_jnbjl"
local config = GameButtonManager.ExtLoadLua(M.key, "act_066_jnbjl_config")
GameButtonManager.ExtLoadLua(M.key, "Act_066_JNBJLPanel")

local this
local lister

M.startTime = 1630971000
M.endTime = 1631548799

M.task_id = 21874
M.v3_task_id = 21875
M.v6_task_id = 21876

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.endTime
    local s_time = M.startTime
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
    if parm.goto_scene_parm == "panel" then
        return Act_066_JNBJLPanel.Create(parm.parent)
    end

    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsHint() or M.IsCanGetVIPAward(3) or M.IsCanGetVIPAward(6) then
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
    lister["model_query_task_data_response"] = this.on_model_query_task_data_response
    lister["AssetChange"] = this.OnAssetChange
    lister["year_btn_created"] = this.on_year_btn_created
    lister["model_vip_upgrade_change_msg"] = this.on_model_vip_upgrade_change_msg
end

function M.Init()
	M.Exit()

	this = Act_066_JNBJLManager
	this.m_data = {}
    this.m_data.task_data = {}
    this.m_data.task_cfg = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
    M.SetTaskData()
end
function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}

    this.m_data.task_cfg = config.tasks
    this.m_data.vip_task_cfg = config.other_tasks
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

local function SetData(_award_status, _now_total_process, _need_process)
	this.m_data.task_data.award_status = _award_status
	this.m_data.task_data.now_total_process = _now_total_process
	this.m_data.task_data.need_processte = _need_process
end

function M.SetTaskData()
	local _cur_task_data = GameTaskModel.GetTaskDataByID(M.task_id)
	if _cur_task_data then
		local b = basefunc.decode_task_award_status(_cur_task_data.award_get_status)
		b = basefunc.decode_all_task_award_status(b, _cur_task_data, #this.m_data.task_cfg)
		SetData(b, _cur_task_data.now_total_process, _cur_task_data.need_process)
	else
		local status = {}
		for i = 1, #this.m_data.task_cfg do
			status[i] = 0
		end
		SetData(status, 0, 0)
	end
    Event.Brocast("model_jnbjl_task_refresh")
    M.SetHintState()
end

function M.on_model_task_change_msg(data)
    -- dump(data,"<color=yellow>BBBBBBB</color>")
    if data and data.id == M.task_id then
        M.SetTaskData()
    end

    if data and (data.id == M.v3_task_id or data.id == M.v6_task_id) then
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
        Event.Brocast("model_jnbjl_vip_task_refresh")
    end
end

function M.on_model_query_task_data_response()
    local data = GameTaskModel.GetTaskDataByID()
    if data then
        for k,v in pairs(data) do
            if v.id == M.task_id then
                M.SetTaskData()
            end
        end
    end
end

function M.on_model_vip_upgrade_change_msg()
    -- dump("<color=yellow>&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&</color>")
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
end

function M.GetTaskData()
    return this.m_data.task_data
end

function M.GetTaskCfg()
    return this.m_data.task_cfg
end

function M.GetTaskLv()
    if this.m_data.task_data.now_total_process >= this.m_data.task_cfg[#this.m_data.task_cfg].task_level then
        return #this.m_data.task_cfg + 1
    end
    for i = 1, #this.m_data.task_cfg do
        if this.m_data.task_data.now_total_process < this.m_data.task_cfg[i].task_level then
            return i
        end
    end
    return
end

function M.GetVipCfg(vipLv)
    if vipLv ~= 3 and vipLv ~= 6 then
        HintPanel.Create("获取VIP奖励配置错误")
        return
    end
    local key
    if vipLv == 3 then
        key = "v3"
    end
    if vipLv == 6 then
        key = "v6"
    end
    return this.m_data.vip_task_cfg[key]
end

function M.IsHint()
    for i = 1, #this.m_data.task_data.award_status do
        if this.m_data.task_data.award_status[i] == 1 then
            return true
        end
    end
end

function M.IsCanGetVIPAward(vipLv)
    if vipLv ~= 3 and vipLv ~= 6 then
        HintPanel.Create("获取VIP奖励配置错误")
        return
    end
    local task_id
    local permiss
    if vipLv == 3 then
        task_id = M.v3_task_id
        permiss = "actp_own_task_21875"
    end
    if vipLv == 6 then
        task_id = M.v6_task_id
        permiss = "actp_own_task_21876"
    end
    local taskData = GameTaskModel.GetTaskDataByID(task_id)
    local checkPermiss = function(permission_key)
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            return false
        end
        return true
    end

    dump(vipLv, "<color=yellow>Lv</color>")
    dump(task_id, "<color=yellow>task_id</color>")
    dump(taskData, "<color=yellow>taskData</color>")
    if taskData and taskData.award_status == 1 and checkPermiss(permiss) then
        return true
    end
    return false
end

----------------------图标飞行----------------------
local btn_gameObject

function M.on_year_btn_created(_data)
    if _data and _data.enterSelf then
        btn_gameObject = _data.enterSelf.gameObject
    end
end

function M.CheckShowFly(change_type) 
    if not M.IsActive() then
        return false
    end
    if change_type == "task_p_continuity_shop_nor" then
        return false
    end
    if change_type == "task_award" then
        return false
    end
    if MainModel.myLocation == "game_Fishing" then 
        return false 
    end
    return true
end

function M.OnAssetChange(_data)
    for _k,_v in pairs(_data.data) do
        if _v.asset_type and _v.asset_type == "prop_fish_drop_act_0" then
            if M.CheckShowFly(_data.change_type) then
                M.PrefabCreator(_v.value)
            end
        end
    end
end

function M.PrefabCreator(value)
    local base_layer = GameObject.Find("Canvas/LayerLv50")
    if not base_layer then return end
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_Ty_ExchangeItemGetPrefab", base_layer.transform)
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0, 550, 0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    local fly_img = temp_ui.Image:GetComponent("Image")
	SetTextureExtend(fly_img, "act_019_dangao_act_ty_by_drop_7")
    temp_ui.num_txt.text = "+" .. value
    local t = Timer.New(function()
        if can_auto then
            M.FlyAnim(obj)
            can_click = false
        end
    end, 1, 1)
    t:Start()
end

function M.FlyAnim(obj)
    if not IsEquals(obj) then return end
    local a = obj.transform.position
    local seq = DoTweenSequence.Create({ dotweenLayerKey = M.key })
    local path = {}
    path[0] = a
    path[1] = Vector3.New(0, 0, 0)
    seq:Append(obj.transform:DOLocalPath(path, 2, DG.Tweening.PathType.CatmullRom))
    seq:AppendInterval(1.6)
    if IsEquals(btn_gameObject) then
        local b = btn_gameObject.transform.position
        local path2 = {}
        path2[0] = Vector3.New(0, 0, 0)
        path2[1] = Vector3.New(b.x - 30, b.y + 30, 0)
        seq:Append(obj.transform:DOLocalPath(path2, 2, DG.Tweening.PathType.CatmullRom))
    end
    seq:OnKill(function()
        if IsEquals(obj) then
            local temp_ui = {}
            LuaHelper.GeneratingVar(obj.transform, temp_ui)
            temp_ui.Image.gameObject:SetActive(false)
            temp_ui.glow_01.gameObject:SetActive(false)
            temp_ui.num_txt.gameObject:SetActive(true)
            Timer.New(function()
                if IsEquals(obj) then
                    destroy(obj)
                end
            end, 2, 1):Start()
        end
    end)
end