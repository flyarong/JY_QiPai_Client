-- 创建时间:2021-06-30
-- Act_061_CZJCCardManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_061_CZJCCardManager = {}
local M = Act_061_CZJCCardManager
M.key = "act_061_czjccard"
GameButtonManager.ExtLoadLua(M.key, "Act_061_CZJCCardQP")
GameButtonManager.ExtLoadLua(M.key, "Act_061_CZJCCardFly")
GameButtonManager.ExtLoadLua(M.key, "Act_061_CZJCCardPayItem")

local this
local lister

local config = {
    [1] = {
        item_key = "obj_recharge_bonus_card_3",
        add_rate = 3,
        fly_img = "czk_icon_pfl",

    },
    [2] = {
        item_key = "obj_recharge_bonus_card_5",
        add_rate = 5,
        fly_img = "czk_icon_pfh",
    },
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

    if parm.goto_scene_parm == "pay_item" then
        return Act_061_CZJCCardPayItem.Create(parm.parent)
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
    lister["hallpanel_created"] = this.on_hallpanel_created
    lister["ExitScene"] = this.OnExitScene
    lister["PayPanelCreate"] = this.OnPayPanelCreate
    lister["PayPanelClosed"] = this.OnPayPanelClosed
    lister["AssetChange"] = this.OnAssetChange
    lister["sys_czjc"] = this.on_sys_czjc
end

function M.Init()
	M.Exit()

	this = Act_061_CZJCCardManager
	this.m_data = {}
    this.shopEnter = nil
    this.cardHallQp = nil
    this.cardData = {}
    this.usingCard = {}
	MakeLister()
    AddLister()
	--M.InitUIConfig()
    M.InitConfig()
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

function M.InitConfig()
    this.cardCfg = {}
    for i = 1, #config do
        local cfg = GameItemModel.GetItemToKey(config[i].item_key)
        cfg.add_rate = config[i].add_rate
        cfg.fly_img = config[i].fly_img
        this.cardCfg[i] = cfg
    end
end

function M.IsHaveCard()
    return M.GetCurCardCfg()
end

--可以使用的加成卡
function M.GetCurCardCfg()
    local _cfg
    for i = 1, #this.cardCfg do
        if not table_is_null(this.cardData[i]) and (not M.IsUsingCard() or this.usingCard.index < i) then
            local objs = this.cardData[i]
            for j = 1, #objs do
                if objs[j].valid_time > os.time() 
                and objs[j].is_use ~= 1 then
                    _cfg = this.cardCfg[i]
                    _cfg.valid_time = objs[j].valid_time
                end
            end
        end
    end
    return _cfg
end

function M.InitCardData()
    this.cardData = {}
    this.usingCard = {}
    this.usingCard.is_use = false
    for i = 1, #this.cardCfg do
        local item_key = this.cardCfg[i].item_key
        local objs = MainModel.GetObjInfoByKey(item_key)
        this.cardData[i] = objs or {}
        for j = 1, #objs do
            if objs[j].is_use == 1 then
                this.usingCard.is_use = true
                this.usingCard.index = i
                this.usingCard.valid_time = objs[j].valid_time
            end
        end
    end
end

function M.UpdateCardData()
    M.InitCardData()
    dump(this.cardData, "<color=white>【充值加成卡:刷新数据】</color>")
    Event.Brocast("model_czjccard_data_change")
    M.CheckView()
end

function M.IsUsingCard()
    if this.usingCard.is_use and tonumber(this.usingCard.valid_time) > os.time() then
        return true
    end
    return false
end

--正在使用的加成卡
function Act_061_CZJCCardManager.GetUsingCard()
    return this.usingCard
end

function Act_061_CZJCCardManager.GetUsingCardCfg()
    if M.IsUsingCard() then
        return this.cardCfg[this.usingCard.index]
    end
end

function M.on_sys_czjc(data)
    M.UseCard(data)
end

--商城按钮创建时
function M.on_hallpanel_created(data)
    M.InitCardData()
    this.shopEnter = data.panelSelf.hall_btn_14
    this.RefreshCZJCCradInHall()
end

--进入商城时
function M.OnPayPanelCreate(data)
    this.shopPanel = data.panelSelf
    this.RefreshCZJCCradInShop()
end

function M.OnExitScene()
    if this.shopEnter then
        this.shopEnter = nil
    end
end

function M.OnPayPanelClosed()
    if this.shopPanel then
        this.shopPanel = nil
    end
end

function M.CheckView()
    if this.shopEnter then
        this.RefreshCZJCCradInHall()
    end

    if this.shopPanel then
        this.RefreshCZJCCradInShop()
    end
end

function M.OnAssetChange(data)
    dump(data, "<color=red>AssetChange</color>")
    if data.data and not table_is_null(data.data) then
        for k,v in pairs(data.data) do
            for i = 1, #this.cardCfg do
                if this.cardCfg[i].item_key == v.asset_type then
                    M.UpdateCardData()
                    break
                end
            end
        end
    end
    -- if data.data and not table_is_null(data.obj_assets_list) then
    --     for k,v in pairs(data.obj_assets_list) do
    --         for i = 1, #this.cardCfg do
    --             if this.cardCfg[i].item_key == v.key then
    --                 M.UpdateCardData()
    --             end
    --         end
    --     end
    -- end
end

function M.RefreshCZJCCradInHall()
    if M.IsUsingCard() or M.IsHaveCard() then
        Act_061_CZJCCardQP.Create(this.shopEnter.transform)
    end
end

function M.RefreshCZJCCradInShop()
    if M.IsHaveCard() then
        Act_061_CZJCCardFly.Create(this.shopPanel.transform)
    end
end

function M.UseCard(_item_key)
    local useCard = function()
        local _obj_type = _item_key or M.GetCurCardCfg().item_key
        dump({obj_type = _obj_type},"<color=red>【充值加成卡:使用】</color>")
        Network.SendRequest("use_recharge_bonus_card",{obj_type = _obj_type}, nil, function(data)
            if data.result == 0 then
                LittleTips.Create("加成卡使用成功")
                Event.Brocast("czjccard_used_success")
                PayPanel.Create(GOODS_TYPE.jing_bi, "normal")
            else
                HintPanel.ErrorMsg(data.result)
            end
        end)
    end
    if M.IsUsingCard() then
        HintPanel.Create(2,"是否使用新的加成卡？使用后当前的充值加成卡将失效!",function ()
            useCard()
        end)
    else
        useCard()
    end
end
