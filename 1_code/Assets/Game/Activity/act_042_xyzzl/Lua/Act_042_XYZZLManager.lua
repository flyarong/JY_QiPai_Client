-- 创建时间:2020-12-08
-- Act_042_XYZZLManager

local basefunc = require "Game/Common/basefunc"
Act_042_XYZZLManager = {}
local M = Act_042_XYZZLManager
M.key = "act_042_xyzzl"
GameButtonManager.ExtLoadLua(M.key, "Act_042_XYZZLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_042_XYZZLPanel")
M.config = GameButtonManager.ExtLoadLua(M.key, "act_042_xyzzl_config")

local this
local lister

M.cjq_key = "prop_xyzzl_cjq" --抽奖券
--money "105829","prop_xyzzl_cjq",10000
M.cjq_icon = "com_award_icon_dhq"
M.change_id = 121

M.help_info = 
{
    "1.活动时间：12月15日7:30~12月21日23:59:59",
    "2.每次抽奖消耗1抽奖券，有机会获得100京东卡",
    "3.每个礼包每日限购3次，每日0点重置",
    "4.活动结束后所有抽奖券全部清除，请及时使用",
}

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
    end
    return true
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
    if not M.CheckIsShow() then return end
    if parm.goto_scene_parm == "panel" then
        return Act_042_XYZZLPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        return Act_042_XYZZLEnterPrefab.Create(parm.parent)
    else
        dump(parm, "<color=red>无跳转对象</color>")
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
end

function M.Init()
	M.Exit()    
	this = Act_042_XYZZLManager
    this.m_data = {}
    this.m_data.gift = M.config.gift
    M.SortAllGiftsData()
    this.m_data.award = M.config.award
	MakeLister()
    AddLister()
    M.InitUIConfig()
    
    SYSACTBASEManager.SetOtherRedHintByForce(M.key,M.GetHintState())
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

function M.SortAllGiftsData()
    local function remain_num(_a)
        return MainModel.GetRemainTimeByShopID(_a.gift_id)
    end
    local function sort(_gift)
        local un_limits = {}
        local limits = {}
        for i = 1, #_gift do
            if remain_num(_gift[i]) > 0 then
                table.insert(un_limits, _gift[i])
            else
                table.insert(limits, _gift[i])
            end
        end
        local sorted = {}
        for i, v in ipairs(un_limits) do
            table.insert(sorted, v)
        end
        for i, v in ipairs(limits) do
            table.insert(sorted, v)
        end
        return sorted
    end
    this.m_data.gift = sort(this.m_data.gift)
end

function M.GetAllGifts()
    M.SortAllGiftsData()
    return this.m_data.gift
end

function M.GetCurGift(index)
    return this.m_data.gift[index]
end

function M.GetAllAwards()
    return this.m_data.award
end

function M.GetCurAward(index)
    return this.m_data.award[index]
end

function M.IsHint()
    return MainModel.GetItemCount(M.cjq_key) > 0
end

function M.GetAwardIndex(award_id)
    for i = 1, #this.m_data.award do
        if this.m_data.award[i].award_id == award_id then
            return i
        end
    end
end

function M.MultAwardTab(single_table)
    local mult_table = {}
    for i = 1, #single_table do
        local  _asset_type = single_table[i].asset_type
        local  _value = single_table[i].value

        if i == 1 then
            mult_table[i] = single_table[i]
        else
            local mult_is_contain = false
            for j = 1, #mult_table do
                if mult_table[j].asset_type == _asset_type then
                    mult_is_contain = true
                    mult_table[j].value = mult_table[j].value + _value
                end
            end
            if not mult_is_contain then
                mult_table[#mult_table + 1] = single_table[i]
            end
        end
    end
    return mult_table
end

