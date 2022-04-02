-- 创建时间:2020-07-21
-- Act_021_SXLBManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_021_SXLBManager = {}
local M = Act_021_SXLBManager
M.key = "act_021_sxlb"
Act_021_SXLBManager.config = GameButtonManager.ExtLoadLua(M.key,"act_021_sxlb_config").Sheet1
GameButtonManager.ExtLoadLua(M.key,"Act_021_SXLBEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_021_SXLBPanel")
Act_021_SXLBManager.shop_icon_config = GameButtonManager.ExtLoadLua(M.key,"act_021_sxlb_shop_config")
Act_021_SXLBManager.goodsid_config = GameButtonManager.ExtLoadLua(M.key,"act_021_sxlb_shop_icon_config")
local this
local lister
local permisstions = {
    "actp_buy_gift_bag_class_021_sxlb_v1",
    "actp_buy_gift_bag_class_021_sxlb_v4",
    "actp_buy_gift_bag_class_021_sxlb_v8",
}
M.now_level = 0

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1595865599
    local s_time = 1595287800
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    dump(M.GetNowPerMiss(),"<color=red>盛夏礼包权限</color>")
    if M.GetNowPerMiss() then 
        return true
    end
end

function M.GetNowPerMiss()
    local cheak_fun = function (_permission_key)
        if _permission_key then
            local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
            if a and not b then
                return false
            end
            return true
        else
            return false
        end
        return true
    end
    M.now_level = nil
    for i = 1,#permisstions do 
        if cheak_fun(permisstions[i]) then
            dump(permisstions[i],"符合条件的权限")
            M.now_level = i  
            return i
        end
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

    lister["ActivityYearPanel_Had_Finish"] = this.on_ActivityYearPanel_Had_Finish
    lister["PayPanel_GoodsChangeToGiftAllJingBiObj"] = this.on_PayPanel_GoodsChangeToGift
    lister["PayPanelClosed"] = this.on_PayPanelClosed
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买


end

function M.Init()
	M.Exit()

	this = Act_021_SXLBManager
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


function M.on_ActivityYearPanel_Had_Finish(parm)
    if M.CheckIsShow() and parm then
        Act_021_SXLBEnterPrefab.Create(parm.panelSelf.transform)
    end
end

function M.GetConfig()
    return M.config[M.now_level]
end

local items = {}
items.jing_bi = {}
items.goods = {}


function M.on_PayPanel_GoodsChangeToGift(data)
    if false then
        return
    end
    dump(data,"<color=green>++++++++data+++++++++++</color>")
    if not data or table_is_null(data) then
        return
    end 
    if  1595287800 < os.time() and os.time() < 1595865599 and M.IsActive() then
        if not data or table_is_null(data) then
            return
        end
        for k,v in pairs(data.pay_data) do
            if v.data.gift_id and MainModel.GetGiftShopStatusByID(v.data.gift_id) == 1 then
            else
                local temp_ui = {}
                LuaHelper.GeneratingVar(v.obj.transform, temp_ui)
                if M.CheckIsShow() then
                    temp_ui.give_img.gameObject:SetActive(false)
                    local GoodsData = v.data
                    if GoodsData.id == 7 and  GoodsData.type == "jing_bi" then-- 剔除钻石换金币
                        return
                    end
                    local obj = newObject("Act_021_SXLBIconInShop", temp_ui.act_node)
                    obj.transform.localPosition = Vector3.New(0,144,0)
                    local obj_childs = {}
                    LuaHelper.GeneratingVar(obj.transform, obj_childs)           
                    local gift_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
                    --dump(GoodsData.goods_id,"<color=red>GoodsData.goods_id</color>")
                    --dump(gift_id,"<color=red>gift_id</color>")
                    if gift_id and M.shop_icon_config.Info[gift_id] then
                        obj_childs.Icon_number_txt.text = "×"..M.shop_icon_config.Info[gift_id].icon_txt
                        obj_childs.icon_img.sprite = GetTexture(M.shop_icon_config.Info[gift_id].icon_img) 
                        if GoodsData.type == "jing_bi" then 
                            items.jing_bi[gift_id] = obj
                        elseif GoodsData.type == "goods" then
                            items.goods[gift_id] = obj
                        end
                    else
                        obj.gameObject:SetActive(false)  
                    end
                    M.RefreshItems()
                end
            end
        end        
    end
end

function M.on_PayPanelClosed()
    items = {}
    items.jing_bi = {}
    items.goods = {}
end

function M.on_finish_gift_shop(id)
    if --[[task_map_ids[id] and--]] gift_data and gift_data[id] then
        gift_data[id].remain_time = gift_data[id].remain_time - 1
        M.RefreshItems()
        --M.Refresh()
    end
end

function M.RefreshItems()
    for k ,v in pairs(items.jing_bi) do
        local data = GameTaskModel.GetTaskDataByID(k)
        dump(k,"<color=yellow>55555555555555555555555</color>")
        dump(data,"<color=yellow>666666666666666666666</color>")
        v.gameObject:SetActive((data and data.now_process < 1))
        if k == 21410 then
            v.gameObject:SetActive(false)
        end
    end
    for k ,v in pairs(items.goods) do
        v.gameObject:SetActive(false)
    end
end

function M.GetTaskIDByGoodsID(goods_id)
    for i = 1,#M.goodsid_config do
        if M.goodsid_config[i].shop_id == goods_id then 
            return M.goodsid_config[i].gift_id
        end
    end
end