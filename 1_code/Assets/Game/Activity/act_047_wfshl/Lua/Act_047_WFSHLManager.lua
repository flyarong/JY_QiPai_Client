-- 创建时间:2021-01-15
-- Act_047_WFSHLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_047_WFSHLManager = {}
local M = Act_047_WFSHLManager
M.key = "act_047_wfshl"
GameButtonManager.ExtLoadLua(M.key, "Act_047_WFSHLPanel")
local config = GameButtonManager.ExtLoadLua(M.key, "act_047_wfshl_config")

local this
local lister

local item_keys = 
{
    "prop_fish_drop_act_1", --爱国
    "prop_fish_drop_act_2", --敬业
    "prop_fish_drop_act_3", --和谐
    "prop_fish_drop_act_4", --富强
    "prop_fish_drop_act_0", --友善
}

local item_icons = 
{
    "wfshl_icon_f1", --爱国
    "wfshl_icon_f2", --敬业
    "wfshl_icon_f3", --和谐
    "wfshl_icon_f4", --富强
    "wfshl_icon_f5", --友善
}

local item_tips = 
{
    {"爱国福","可兑换五福奖励"},
    {"敬业福","可兑换五福奖励"},
    {"和谐福","可兑换五福奖励"},
    {"富强福","可兑换五福奖励"},
    {"友善福","可兑换五福奖励"},
}

local e_time = 1612799999
local s_time = 1612222200

local help_info = 
{
    "1.	活动2月8日23:59:59结束",
    "2.	活动期间任意消消乐小游戏均可获得福字",
    "2.	活动期间街机捕鱼和任意消消乐小游戏均可获得福字",
    "3.	活动结束后所有未使用的福字全部清除，请及时使用"
}

local fq_buff = 
{
    0.1,0.3,0.5
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    --local e_time = 1612799999
    --local s_time = 1612222200
    --do return true end
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
        return Act_047_WFSHLPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    dump("--------------------------------")
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
    lister["AssetChange"] = this.on_asset_change
    lister["year_btn_created"] = this.on_year_btn_created

end

function M.Init()
	M.Exit()

	this = Act_047_WFSHLManager
    this.m_data = {}
    this.m_data.cfg = config.rewards
	MakeLister()
    AddLister()
    M.InitUIConfig()
    M.AddUnShowAward()
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


function M.GetCfg()
    return this.m_data.cfg
end

function M.GetData()
    M.UpdateData()
    return this.m_data.data
end

function M.GetEndTime()
    return e_time
end

function M.GetTexture(index)    
    --keylocal item = GameItemModel.GetItemToKey(item_keys[index])
    return GetTexture(item_icons[index])
end 

function M.GetItemTip(index)
    return item_tips[index]
end

function M.GetHelpInfo()
    if M.IsPaltFormNoWZQ() then
        return help_info[1].."\n"..help_info[3].."\n"..help_info[4]
    else
        return help_info[1].."\n"..help_info[2].."\n"..help_info[4]
    end
end

function M.GetFQBuff()
    local a,b =  GameButtonManager.RunFun({gotoui="act_ty_gifts", gift_key="gift_wflb"}, "GetBuyGiftsNumEx")
    if b == 0 then
        return 0
    else
        return fq_buff[b]
    end
end

function M.UpdateData()
    this.m_data.data = {}
    for i = 1, #item_keys do
        this.m_data.data[i] = MainModel.GetItemCount(item_keys[i])
    end
end

function M.IsHint()
    
    local is_can_get = false
    for i = 1, #this.m_data.cfg do
        if M.CheckIsExchange(i) then
            return true
        end
    end
    return false
end

function M.CheckIsExchange(reward_index)
    --dump(this.m_data.data,"<color=red>~~~~~~~~~~~~~my~~~~~~~~~~~~~~~~</color>")
    local need_lis = this.m_data.cfg[reward_index].consume_num
    --dump(need_lis,"<color=red>~~~~~~~~~~~~~~need~~~~~~~~~~~~~~~</color>")
    for i = 1, #this.m_data.data do
        if this.m_data.data[i] < need_lis[i] then
            return false
        end 
    end
    return true
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.UpdateData()
	end
end
function M.OnReConnecteServerSucceed()
    M.UpdateData()
end

function M.IsPaltFormNoWZQ()
    local _permission_key = "game_activity_show_nor"
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

function M.on_asset_change(_data)
    if not _data then
        return
    end
    --dump(_data,"<color=red>~~~~~~~~~~~~~~on_asset_change~~~~~~~~~~~~~~~</color>")
    local value = 0
    for i = 1, #item_keys do
        for _k,_v in pairs(_data.data) do
            if _v.asset_type and _v.asset_type == item_keys[i] then
                M.UpdateData()
                value = value + _data.data[_k].value
            end
        end
    end
    if value ~= 0 then
        Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
        if M.IsShowPrefab() then 
            M.PrefabCreator(value)
        end
    end
end

-------------------------图标飞行-----------------------

local btn_gameObject

function M.CheckShowFly(exchange_key)
    return M.IsExchangeActive(exchange_key)
end

function M.AddUnShowAward()
    local check_func = function (type)
        if type == "task_p_xxlyj_drop_nor" or type == "task_p_xxlyj_drop_cpl" then
            return true
        end
    end
    MainModel.AddUnShow(check_func)
end

function M.on_year_btn_created(_data)
    if _data and _data.enterSelf then
        btn_gameObject = _data.enterSelf.gameObject
    end
end

function M.PrefabCreator(value)
    local temp_ui = {}
    local can_auto = true
    local can_click = true
    local obj = newObject("Act_047_WFSHLGetPrefab", GameObject.Find("Canvas/LayerLv50").transform)
    --math.randomseed(tostring(os.time()):reverse():sub(1, 7))
    obj.transform.position = Vector3.New(0, 550, 0)
    LuaHelper.GeneratingVar(obj.transform, temp_ui)
    --temp_ui.Image:GetComponent("Image").sprite = GetTexture()
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

function M.IsShowPrefab()
    if MainModel.myLocation == "game_Fishing" then 
        return false 
    end
    if not IsEquals(GameObject.Find("Canvas/LayerLv50").transform) then
        return false
    end
    return true
end