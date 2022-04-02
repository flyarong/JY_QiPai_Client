-- 创建时间:2020-05-06
-- Act_012_BBLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_012_BBLBManager = {}
local M = Act_012_BBLBManager
M.key = "act_012_bblb"
GameButtonManager.ExtLoadLua(M.key, "Act_012_BBLBPanel")
M.config = {
    {shop_id = 10237,price = 1314,title = "一生一世",award1_txt = "1314万鲸币",award2_txt = "30万鱼币", award3_txt = "520爱心"},
    {shop_id = 10238,price = 520,title = "我爱你",award1_txt = "520万鲸币",award2_txt = "10万鱼币", award3_txt = "258爱心"},
    {shop_id = 10239,price = 258,title = "爱我吧",award1_txt = "258万鲸币",award2_txt = "5万鱼币", award3_txt = "147爱心"},
    {shop_id = 10240,price = 147,title = "一世情",award1_txt = "147万鲸币",award2_txt = "3万鱼币", award3_txt = "52爱心"},
    {shop_id = 10241,price = 52,title = "吾爱",award1_txt = "52万鲸币",award2_txt = "1万鱼币", award3_txt = "28爱心"},
}

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
    if parm.goto_scene_parm == "panel" then
        return Act_012_BBLBPanel.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
    if not M.CheckIsShowInActivity(parm) then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
    end

    local newtime = tonumber(os.date("%Y%m%d", os.time()))
    local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. MainModel.UserInfo.user_id, 0))))
    if oldtime ~= newtime then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Red
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
end

function M.Init()
	M.Exit()

	this = Act_012_BBLBManager
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

function M.BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end