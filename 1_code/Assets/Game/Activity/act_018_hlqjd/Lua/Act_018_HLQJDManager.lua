-- 创建时间:2020-06-15
-- Act_018_HLQJDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_018_HLQJDManager = {}
local M = Act_018_HLQJDManager
M.key = "act_018_hlqjd"
GameButtonManager.ExtLoadLua(M.key, "Act_018_HLQJDPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_018_HLQJDPanel")

local this
local lister
local level = 0
local base_data = {
    [1] = {
        [1] = {[1]= {text = "1话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "8000-5万",image = "pay_icon_gold2"},[3] ={text = "1.8万-10万",image = "pay_icon_gold3"}},
        [2] = {[1]= {text = "2话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "1万-10万",image = "pay_icon_gold2"},[3] ={text = "2.5万-20万",image = "pay_icon_gold3"}},
        [3] = {[1]= {text = "4话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "1.5万-15万",image = "pay_icon_gold2"},[3] ={text = "5万-30万",image = "pay_icon_gold3"}},
    },
    [2] = {
        [1] = {[1]= {text = "4话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "1.5万-15万",image = "pay_icon_gold2"},[3] ={text = "5万-30万",image = "pay_icon_gold3"}},
        [2] = {[1]= {text = "6话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "3万-20万",image = "pay_icon_gold2"},[3] ={text = "10万-50万",image = "pay_icon_gold3"}},
        [3] = {[1]= {text = "8话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "6万-50万",image = "pay_icon_gold2"},[3] ={text = "18万-100万",image = "pay_icon_gold3"}},
    },
    [3] = {
        [1] = {[1]= {text = "6话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "3万-20万",image = "pay_icon_gold2"},[3] ={text = "10万-50万",image = "pay_icon_gold3"}},
        [2] = {[1]= {text = "8话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "6万-50万",image = "pay_icon_gold2"},[3] ={text = "18万-100万",image = "pay_icon_gold3"}},
        [3] = {[1]= {text = "10话费碎片",image = "com_award_icon_hfsp"},[2] = {text = "12万-100万",image = "pay_icon_gold2"},[3] ={text = "50万-300万",image = "pay_icon_gold3"}},
    },   
}
local task_ids = {
    21566,21567,21568
}
local item_keys = {
    [1] = {"prop_brass_hammer_1","prop_silver_hammer_1","prop_gold_hammer_1"},
    [2] = {"prop_brass_hammer_2","prop_silver_hammer_2","prop_gold_hammer_2"},
    [3] = {"prop_brass_hammer_3","prop_silver_hammer_3","prop_gold_hammer_3"},
}

local permission_keys = {
    "actp_buy_gift_bag_class_golden_egg_1",
    "actp_buy_gift_bag_class_golden_egg_2",
    "actp_buy_gift_bag_class_golden_egg_3",
}

local shop_ids = {
    [1] = {10320,10321,10322,},
    [2] = {10323,10324,10325,},
    [3] = {10326,10327,10328,},
}

local shop_img = {
    [1] = {"pay_icon_gold2","com_award_icon_cz2"},
    [2] = {"pay_icon_gold2","com_award_icon_cz3"},
    [3] = {"pay_icon_gold2","com_award_icon_cz4"},
}
-- 是否有活动
function M.IsActive()

    -- level = 1
    -- do return true end
    -- 活动的开始与结束时间
    local e_time = 1607356799
    local s_time = 1606779000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    if M.SetLevel() then
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
            return Act_018_HLQJDPanel.Create(parm.parent,parm.backcall)
        end
    elseif parm.goto_scene_parm == "enter"  then
        if parm.parent.parent.gameObject.name == "ActivityYearPanel" then
            local b = Act_018_HLQJDPrefab.Create(parm.parent)
            CommonHuxiAnim.Start(b.gameObject)
            return b
        else
            return Act_018_HLQJDPrefab.Create(parm.parent)
        end
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    for i = 1,3 do
        if  M.GetCzNum(i) > 0 then
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
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_018_HLQJDManager
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

function M.SetLevel()
    local func = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        end
    end
    for i = 1,#permission_keys do
        if func(permission_keys[i]) then
            level = i
            return i
        end
    end
end

function M.GetBaseData()
    return base_data[level]
end

function M.GetCzNum(index)
    local num  = GameItemModel.GetItemCount(item_keys[level][index])
    --do return  0 end 
    return num
end

function M.GetShopIDs()
    return shop_ids[level]
end

function M.GetShopImg()
    return shop_img
end

function M.GetTaskIDs()
    return task_ids
end