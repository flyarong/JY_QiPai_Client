-- 创建时间:2020-06-15
-- Act_029_HLKBXManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_029_HLKBXManager = {}
local M = Act_029_HLKBXManager
M.key = "act_029_hlkbx"
GameButtonManager.ExtLoadLua(M.key, "Act_029_HLKBXEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_029_HLKBXPanel")

local this
local lister
local level = 0
local base_data = {
    [1] = {
        [1] = {[1]= {text = "3",image = "yjlqjnb_icon_jnb"},[2] = {text = "3~20",image = "yjlqjnb_icon_jnb"},[3] ={text = "8~50",image = "yjlqjnb_icon_jnb"}},
        [2] = {[1]= {text = "5",image = "yjlqjnb_icon_jnb"},[2] = {text = "5~30",image = "yjlqjnb_icon_jnb"},[3] ={text = "15~70",image = "yjlqjnb_icon_jnb"}},
        [3] = {[1]= {text = "8",image = "yjlqjnb_icon_jnb"},[2] = {text = "10~50",image = "yjlqjnb_icon_jnb"},[3] ={text = "20~100",image = "yjlqjnb_icon_jnb"}},
    },
    [2] = {
        [1] = {[1]= {text = "8",image = "yjlqjnb_icon_jnb"},[2] = {text = "10~50",image = "yjlqjnb_icon_jnb"},[3] ={text = "20~100",image = "yjlqjnb_icon_jnb"}},
        [2] = {[1]= {text = "10",image = "yjlqjnb_icon_jnb"},[2] = {text = "15~60",image = "yjlqjnb_icon_jnb"},[3] ={text = "60~200",image = "yjlqjnb_icon_jnb"}},
        [3] = {[1]= {text = "20",image = "yjlqjnb_icon_jnb"},[2] = {text = "40~100",image = "yjlqjnb_icon_jnb"},[3] ={text = "100~300",image = "yjlqjnb_icon_jnb"}},
    },
    [3] = {
        [1] = {[1]= {text = "10",image = "yjlqjnb_icon_jnb"},[2] = {text = "15~60",image = "yjlqjnb_icon_jnb"},[3] ={text = "60~200",image = "yjlqjnb_icon_jnb"}},
        [2] = {[1]= {text = "20",image = "yjlqjnb_icon_jnb"},[2] = {text = "40~100",image = "yjlqjnb_icon_jnb"},[3] ={text = "100~300",image = "yjlqjnb_icon_jnb"}},
        [3] = {[1]= {text = "30",image = "yjlqjnb_icon_jnb"},[2] = {text = "60~200",image = "yjlqjnb_icon_jnb"},[3] ={text = "300~800",image = "yjlqjnb_icon_jnb"}},
    },   
}
local task_ids = {
    21519,21520,21521
}
local item_keys = {
    [1] = {"prop_brass_key_1","prop_silver_key_1","prop_gold_key_1"},
    [2] = {"prop_brass_key_2","prop_silver_key_2","prop_gold_key_2"},
    [3] = {"prop_brass_key_3","prop_silver_key_3","prop_gold_key_3"},
}

local permission_keys = {
    "actp_buy_gift_bag_class_open_box_1",
    "actp_buy_gift_bag_class_open_box_2",
    "actp_buy_gift_bag_class_open_box_3",
}

local shop_ids = {
    [1] = {10410,10411,10412,},
    [2] = {10413,10414,10415,},
    [3] = {10416,10417,10418,},
}

local shop_img = {
    [1] = {"pay_icon_gold2","hlkbx_icon_6"},
    [2] = {"pay_icon_gold2","hlkbx_icon_5"},
    [3] = {"pay_icon_gold2","hlkbx_icon_4"},
}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1600703999
    local s_time
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
            return Act_029_HLKBXPanel.Create(parm.parent,parm.backcall)
        end
    elseif parm.goto_scene_parm == "enter"  then
        if parm.parent.parent.gameObject.name == "ActivityYearPanel" then
            local b = Act_029_HLKBXEnterPrefab.Create(parm.parent)
            CommonHuxiAnim.Start(b.gameObject)
            return b
        else
            return Act_029_HLKBXEnterPrefab.Create(parm.parent)
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

	this = Act_029_HLKBXManager
	this.m_data = {}
	MakeLister()
    AddLister()
    M.AddUnShow()
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

function M.AddUnShow()
    local check_func = function(_type)
        if _type == "task_happy_open_box_20_9_15" then
            return true
        end
    end
    MainModel.AddUnShow(check_func)
end