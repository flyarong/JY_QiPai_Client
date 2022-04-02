-- 创建时间:2020-05-06
-- Act_012_CZQDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_012_CZQDManager = {}
local M = Act_012_CZQDManager
M.key = "act_012_czqd"
GameButtonManager.ExtLoadLua(M.key, "Act_012_CZQDPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_012_CZQDEnterPrefab")

local this
local lister
M.Normal_shopid = 10248
M.BuQian_shopids = {10249,10250,10251,10252,10253,10254,10255,}
M.Exchange_ID = 26
local m_data
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "free_huafei_20"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        if a and not b then
            --如果权限验证不过（有可能买之前是验证权限正确的），买之后依然需要向玩家展示活动，就需要看购买后的时间是否符合规则
            return false or (m_data.start_time and m_data.start_time + 8 * 86400 >= os.time())
        end
        return true and M.IsCanShow()
    else
        return true and M.IsCanShow()
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
    if parm and parm.goto_scene_parm == "panel" then
        return Act_012_CZQDPanel.Create(parm.parent)
    elseif parm and parm.goto_scene_parm == "enter" then
        return Act_012_CZQDEnterPrefab.Create(parm.parent)

    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
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
    lister["tel_bill_data_response"] = this.on_tel_bill_data_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_012_CZQDManager
    this.m_data = {}
    m_data = this.m_data
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
        Network.SendRequest("tel_bill_data")
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_tel_bill_data_response(_,data)
    dump(data,"<color=red>话费签到活动数据</color>")
    if data and data.result == 0 then
        m_data = data
        Event.Brocast("act_012_czqd_info_get")
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end

function M.GetMainData()
    return m_data
end

function M.GetDayIndex()
    local t1 = basefunc.get_today_id(m_data.start_time or os.time())
    local t2 = basefunc.get_today_id(os.time())
    return  t2 - t1 <= 0 and 1 or t2 - t1 + 1
end

function M.IsAwardCanGet()
    local data = M.GetMainData()
    if data and data.days then
        if data.days[M.GetDayIndex()] == 0 then
            return true
        else
            return false
        end
    end 
    local s = MainModel.GetGiftShopStatusByID(M.Normal_shopid)
    return s == 1
end

function M.IsCanShow()
    if m_data.start_time then
        return m_data.start_time + 8 * 86400 >= os.time()
    else
        return true
    end
end