-- 创建时间:2020-06-10
-- Act_017_SMSDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_017_SMSDManager = {}
local M = Act_017_SMSDManager
M.key = "act_017_smsd"
local this
local lister
local gift_num = {}
M.base_data = {
	[1] = {
		shop_id = 10311,
		tag = "smsd_icon_2",
	},
	[2] = {
		shop_id = 10312,
		
	},
	[3] = {
		shop_id = 10313,
		
	},
	[4] = {
		shop_id = 10314,
		
	},
	[5] = {
		shop_id = 10315,
		
	},
}
GameButtonManager.ExtLoadLua(M.key,"Act_017_SMSDPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_017_SMSDEnterPrefab")
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1593446400
    local s_time = 1592866800
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
        return M.IsDuring()
    else
        return M.IsDuring()
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
        return Act_017_SMSDPanel.Create()
    elseif parm.goto_scene_parm == "enter" then
        if M.IsDuring()  then
            return Act_017_SMSDEnterPrefab.Create(parm.parent)
        end
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
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
    for i=1,#M.base_data  do
		lister["model_query_gift_bag_num_shopid_"..M.base_data[i].shop_id] = this.OnGetGiftNum
	end
end

function M.Init()
	M.Exit()

	this = Act_017_SMSDManager
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
        if M.IsActive() then
            M.UpdateNum()
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.QueryGiftNum()
    for i = 1,#M.base_data do 
        Network.SendRequest("query_gift_bag_num",{gift_bag_id = M.base_data[i].shop_id})
    end
end

function M.GetGiftNum(shop_id)
    if M.IsDuring() then
        return gift_num[shop_id] or 0
    else
        local c = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag,shop_id)
        return c.count or 0
    end
end

function M.OnGetGiftNum(data)
    gift_num[data.shopid] = data.count < 0 and 0 or data.count
end

--绑定刷新礼包数量
function M.AutoRefreshNumAtText(shop_id,Text)
    Text.text = "剩余:"..M.GetGiftNum(shop_id)
    local t = Timer.New(function ()
        if IsEquals(Text) then
            Text.text = "剩余:"..M.GetGiftNum(shop_id)
        end
    end,5,-1)
    t:Start()
    return t
end

function M.IsDuring()
    local T = tonumber(os.date("%H",os.time()))
    dump(T,"<color=red>当前时间点</color>")
    if T <= 20 and T >= 8 then
        return true
    end
end

local Update_Timer
function M.UpdateNum()
    if Update_Timer then
        Update_Timer:Stop()
    end
    Update_Timer = Timer.New(function ()
        if M.IsDuring() then
            M.QueryGiftNum()
        end
    end,10,-1)
    Update_Timer:Start()
end

function M.AutoRefreshButtonStatus(button,buttonMask,shop_id)
    local button_img = button.gameObject.transform:GetComponent("Image")
    dump(button)
    buttonMask.gameObject:SetActive(MainModel.GetGiftShopStatusByID(shop_id) == 0)
    button_img.sprite = GetTexture(M.GetGiftNum(shop_id) <= 0 and "gy_56_3_activity_act_017_smsd" or "gy_56_2_activity_act_017_smsd")
    button.enabled = M.GetGiftNum(shop_id) > 0 and MainModel.GetGiftShopStatusByID(shop_id) > 0 
    local t = Timer.New(function ()
        if IsEquals(button) and IsEquals(buttonMask) then
            dump(M.GetGiftNum(shop_id),"礼包ID；"..shop_id)
            buttonMask.gameObject:SetActive(MainModel.GetGiftShopStatusByID(shop_id) == 0)
            button_img.sprite = GetTexture(M.GetGiftNum(shop_id) <= 0 and "gy_56_3_activity_act_017_smsd" or "gy_56_2_activity_act_017_smsd")
            button.enabled = M.GetGiftNum(shop_id) > 0 and MainModel.GetGiftShopStatusByID(shop_id) > 0 
        end
    end,3,-1)
    t:Start()
    return t
end
