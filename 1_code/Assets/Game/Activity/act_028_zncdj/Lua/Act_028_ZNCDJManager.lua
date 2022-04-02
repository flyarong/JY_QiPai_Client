-- 创建时间:2020-08-17
-- Act_028_ZNCDJManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_028_ZNCDJManager = {}
local M = Act_028_ZNCDJManager
M.key = "act_028_zncdj"
M.config = {
	[11388] = {text = "抽纸",image = "activity_icon_gift304_cz"},
	[11389] = {text = "挂面",image = "activity_icon_gift252_gm"},
	[11390] = {text = "大豆油",image = "activity_icon_gift227_ddy"},
    [11391] = {text = "大枣夹核桃",image = "activity_icon_gift217_dzjht"},
    [11392] = {text = "俄罗斯巧克力",image = "activity_icon_gift305_elsqkl"},
    [11393] = {text = "大米",image = "activity_icon_gift124_dm"},
    [11394] = {text = "充电宝",image = "activity_icon_gift156_cdb"},
    [11395] = {text = "小米手机",image = "activity_icon_gift303_xmsj"},
    [11396] = {text = "笔记本电脑",image = "activity_icon_gift302_bjbdn"},
}
M.task_id = 21879

GameButtonManager.ExtLoadLua(M.key,"Act_028_ZNCDJPanel")
local this
local lister
M.endTime = 1632153599

M.item_cj_1 = "prop_3rdyear_cjq"
M.item_cj_2 = "shop_gold_sum"

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.endTime
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
	if parm.goto_scene_parm == "panel"  then
		return Act_028_ZNCDJPanel.Create(parm.parent)
	end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if M.IsCanLottery() or M.IsTaskAwardCanGet()  then 
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
	end
end
-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["AssetChange"] = this.OnAssetChange
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_028_ZNCDJManager
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

function M.OnAssetChange(data)
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key})
end

function M.on_model_task_change_msg(data)
    if data and data.id == M.task_id then
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
	end 
end

function M.IsTaskAwardCanGet()
    local data = GameTaskModel.GetTaskDataByID(M.task_id)
    if data and data.award_status == 1 then
        return true 
    end
end

function M.IsCanLottery()
    return GameItemModel.GetItemCount(M.item_cj_1) >= 10
end

function M.GetLotteryStatus()
    local num1 = GameItemModel.GetItemCount(M.item_cj_1)
    --local num2 = GameItemModel.GetItemCount(M.item_cj_2)
    if num1 >= 100 then
        return 1 -- 10纪念币 100纪念币
    elseif num1 >= 10 then
        return 2 -- 10纪念币 20福卡
    else
        return 3 -- 2福卡   20福卡
    end
end