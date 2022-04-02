-- 创建时间:2020-11-05
-- Act_037_FKCDJManager 管理器
local basefunc = require "Game/Common/basefunc"
Act_037_FKCDJManager = {}
local M = Act_037_FKCDJManager
M.key = "act_037_fkcdj"
GameButtonManager.ExtLoadLua(M.key,"Act_037_FKCDJPanel")
M.config = {
	[12881] = {text = "电热毯",image = "fkcdj_iocn_drt"},
	[12882] = {text = "洗洁精",image = "fkcdj_iocn_xjj"},
	[12883] = {text = "大豆油",image = "fkcdj_iocn_ddy"},
--     [12221] = {text = "黄桃罐头",image = "activity_icon_gift166_htgt"},
--     [12223] = {text = "海飞丝洗发水",image = "activity_icon_gift222_hfs"},
--     [12226] = {text = "充电宝",image = "activity_icon_gift156_cdb"},
    }



    M.config_pmd = {
        [12881] = "电热毯",
        [12882] = "洗洁精",
        [12883] = "大豆油",
        [12885] = "福卡",  --4-6
        [12887] = "特殊鱼币", --80000~1200000
        [12884] = "鲸币",  --80000~120000
        --[12894] = "鲸币",
        }

    


local task_id = 21550 

local this
local lister
local convert_item_1 = "prop_double11_cjq" --抽奖券
local amount_min_1 = 4

local convert_item_2 = "shop_gold_sum" --福卡
local amount_min_2 = 2

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
    if parm.goto_scene_parm == "panel"  then
		return Act_037_FKCDJPanel.Create(parm.parent)
	end
end
-- 活动的提示状态
function M.GetHintState(parm)

    if GameItemModel.GetItemCount(convert_item_1) >= amount_min_1 or M.IsTaskAwardCanGet()  then 
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg

    lister["AssetChange"] = this.On_AssetChange
    lister["model_task_change_msg"] = this.on_model_task_change_msg
end

function M.Init()
	M.Exit()

    this = Act_037_FKCDJManager
    this.task_id=task_id
    this.convert_item_1 = convert_item_1
    this.convert_item_2 = convert_item_2
    this.amount_min_1 = amount_min_1
    this.amount_min_2 = amount_min_2
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

function M.On_AssetChange()
    M.RefreshRedHint()
end

function M.on_model_task_change_msg(data)
    if data and data.id == task_id then
        M.RefreshRedHint()
    end
end

function M.RefreshRedHint()
    Event.Brocast("global_hint_state_change_msg", { gotoui = M.key})
end

function M.IsTaskAwardCanGet()
    local data = GameTaskModel.GetTaskDataByID(task_id)
    if data and data.award_status == 1 then
        return true 
    end
    return false
end

--是否可以用抽奖券 time:1 or 10
function M.IsCanUse_XFJ(time)
    local is_c = (GameItemModel.GetItemCount(convert_item_1) >= amount_min_1 * time) and true or false 
    return is_c
end
