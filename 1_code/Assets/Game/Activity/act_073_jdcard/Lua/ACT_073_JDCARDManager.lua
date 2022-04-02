-- 创建时间:2022-03-02
-- ACT_073_JDCARDManager 管理器

local basefunc = require "Game/Common/basefunc"
ACT_073_JDCARDManager = {}
local M = ACT_073_JDCARDManager
M.key = "act_073_jdcard"
local config = GameButtonManager.ExtLoadLua(M.key, "act_073_jdcard_config").config
GameButtonManager.ExtLoadLua(M.key, "ACT_073_JDCARDEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "ACT_073_JDCARDItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACT_073_JDCARDJLItemBase")
GameButtonManager.ExtLoadLua(M.key, "ACT_073_JDCARDJLPanel")
GameButtonManager.ExtLoadLua(M.key, "ACT_073_JDCARDPanel")
GameButtonManager.ExtLoadLua(M.key, "ACT_073_JDCARDXQPanel")
GameButtonManager.ExtLoadLua(M.key, "ACT_073_JDCARDWaitWebPanel")
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
    local _permission_key = "actp_own_task_p_xsjdk_all_v1"
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
        return ACT_073_JDCARDEnterPrefab.Create(parm.parent)
    elseif parm.goto_scene_parm == "panel" then
        return ACT_073_JDCARDPanel.Create(parm.parent,parm.backcall)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if parm and parm.gotoui == M.key then 
        if M.IsCanGet() then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Get
        else
            local newtime = tonumber(os.date("%Y%m%d", os.time()))
            local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
            if oldtime ~= newtime and MainModel.UserInfo.vip_level >= 1 then
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

    lister["get_jdcard_taskInfo_response"] = this.on_get_jdcard_taskInfo_response
    lister["unlock_jd_card_task_response"] = this.on_unlock_jd_card_task_response
    lister["get_jdcard_record_response"] = this.on_get_jdcard_record_response
    lister["get_task_award_response"] = this.on_get_task_award_response
end

function M.Init()
	M.Exit()

	this = ACT_073_JDCARDManager
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
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
	end
end
function M.OnReConnecteServerSucceed()
end

function M.GetConfig()
    return config
end

function M.QueryJDCardInfo()
    Network.SendRequest("get_jdcard_taskInfo")
end

function M.on_get_jdcard_taskInfo_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_get_jdcard_taskInfo_response++++++++++</size></color>")
    if data and data.result == 0 then
        for k,v in pairs(data.data) do
            this.m_data[v.unlock_id] = this.m_data[v.unlock_id] or {}
            this.m_data[v.unlock_id].unlock_type = v.unlock_type 
            this.m_data[v.unlock_id].single_lock_num  = v.single_lock_num
            this.m_data[v.unlock_id].lock_status = v.lock_status
            this.m_data[v.unlock_id].all_lock_num  = v.all_lock_num
            this.m_data[v.unlock_id].get_award_times  = v.get_award_times
        end
        Event.Brocast("get_jdcard_taskInfo_msg")
    end
end

function M.UnLock(unlock_id)
    Network.SendRequest("unlock_jd_card_task",{unlock_id = unlock_id})
end

function M.on_unlock_jd_card_task_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_unlock_jd_card_task_response++++++++++</size></color>")
    if data and data.result == 0 then
        this.m_data[data.data.unlock_id] = this.m_data[data.data.unlock_id] or {}
        this.m_data[data.data.unlock_id].unlock_type = data.data.unlock_type
        this.m_data[data.data.unlock_id].single_lock_num = data.data.single_lock_num
        this.m_data[data.data.unlock_id].lock_status = data.data.lock_status
        this.m_data[data.data.unlock_id].all_lock_num = data.data.all_lock_num
        this.m_data[data.data.unlock_id].get_award_times = data.data.get_award_times
        Event.Brocast("unlock_jd_card_task_msg")
    end
end

function M.QueryJDCardHistory()
    Network.SendRequest("get_jdcard_record")
end

function M.on_get_jdcard_record_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_get_jdcard_record_response++++++++++</size></color>")
    if data and data.result == 0 then
        if not table_is_null(data.data) then
            this.history = {}
            for k,v in pairs(data.data) do
                this.history[#this.history + 1] = v
            end
            Event.Brocast("get_jdcard_record_msg")
        end
    end
end

function M.IsCareTask(id)
    for k,v in pairs(config) do
        if v.task_id == id then
            return true
        end
    end
    return false
end

function M.GetJDCardSingleLockNum(unlock_id)
    if this.m_data[unlock_id] then
        return this.m_data[unlock_id].single_lock_num
    else
        return 0
    end
end

function M.IsAwardGet(unlock_id)
    local time = this.m_data[unlock_id].get_award_times or 0
    --目前是终身1次,如果终身多次需要和解锁次数对比
    return time == 1
end

function M.GetJDCardAllLockRemainNum(unlock_id)
    if this.m_data[unlock_id] then
        return config[unlock_id].all_num - this.m_data[unlock_id].all_lock_num
    else
        return tonumber(config[unlock_id].all_num) or 0
    end
end

function M.CheckCurUnlock(unlock_id)
    if this.m_data[unlock_id] then
        return this.m_data[unlock_id].lock_status == 1
    else
        return false
    end
end

function M.SpecialUnlockid(unlock_id)
    if this.m_data[unlock_id] and this.m_data[unlock_id].unlock_type == 1 then
        return true
    else
        return false
    end
end

function M.GetHistory(index)
    if index then
        return this.history[index]
    else
        return this.history
    end
end


function M.on_get_task_award_response(_, data)
    if data.result == 0 then
        if M.IsCareTask(data.id) then
            LittleTips.Create("领取成功!")
            ACT_073_JDCARDWaitWebPanel.Create(M.GetUnLockidByTaskid(data.id))
        end
    end
end

function M.GetUnLockidByTaskid(task_id)
    for k,v in pairs(config) do
        if v.task_id == task_id then
            return v.id
        end
    end
end

function M.IsCanGet()
    for k,v in pairs(config) do
        local data = GameTaskModel.GetTaskDataByID(v.task_id)
        if data then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key = v.condi_exchange, is_on_hint = true}, "CheckCondition")
            if data.award_status == 1 and a and b and tonumber(StringHelper.ToRedNum(MainModel.GetHBValue())) >= v.cost then
                if M.SpecialUnlockid(v.id) then
                    if M.GetJDCardSingleLockNum(v.id) == 0 then
                        return true
                    else
                        return false
                    end
                else
                    if M.GetJDCardAllLockRemainNum(v.id) > 0 then
                        return true
                    else
                        return false
                    end
                end
                return true
            end
        end
    end
    return false
end

function M.MarkTime(unlock_id)
    this.markTime = this.markTime or {}
    this.markTime[unlock_id] = os.time() + 120
end


function M.CheckTime(unlock_id)
    if this.markTime and this.markTime[unlock_id] then
        return os.time() >= this.markTime[unlock_id]
    else
        return true
    end
end

function M.Decrycty(_str)
    if not _str or  _str == "" then
        return _str
    end
    local len = #_str
    local byteNum = 0
    local new_str, ss = nil, nil
    local string_char = string.char
    local string_byte = string.byte
    local string_sub = string.sub
    local string_format = string.format
    for i=1, len do
        byteNum = string_byte(string_sub(_str, i, i)) - i%3
        ss = string_char(byteNum)
        if not new_str then
            new_str = ss
        else
            new_str = string_format("%s%s", new_str, ss)
        end
    end
    new_str = string.reverse(new_str)
    return new_str
end