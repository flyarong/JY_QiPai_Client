-- 创建时间:2020-05-06
-- Act_012_LMLHManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_012_LMLHManager = {}
local M = Act_012_LMLHManager
M.key = "act_012_lmlh"
Act_012_LMLHManager.shop_icon_config = GameButtonManager.ExtLoadLua(M.key,"act_012_shop_icon_config")
Act_012_LMLHManager.item_config = GameButtonManager.ExtLoadLua(M.key,"act_012_item_config")
Act_012_LMLHManager.goodsid_config = GameButtonManager.ExtLoadLua(M.key,"act_012_goods_id_config")
GameButtonManager.ExtLoadLua(M.key,"Act_012_LMLHIconInGame")
GameButtonManager.ExtLoadLua(M.key,"Act_012_LMLHItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_012_LMLHPanel")
local this
local lister
M.item_key = "prop_love"
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time --= 1590422399
    local s_time --= 1589844600
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "chuxiahaoli"
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
    if M.IsActive() then
        return true
    end
end
-- 活动面板调用
function M.CheckIsShowInActivity()
    return M.IsActive()
end

-- 所有可以外部创建的UI
function M.GotoUI(parm)
    if parm.goto_scene_parm == "panel" then
        if M.CheckIsShow() then
            return Act_012_LMLHPanel.Create(parm.parent,parm.backcall)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if not M.CheckIsShowInActivity(parm) then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
        end
        if M.IsItemCanGet() then
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
end
function M.on_global_hint_state_set_msg(parm)
	if parm.gotoui == M.key then
		M.SetHintState()
        Event.Brocast("global_hint_state_change_msg", parm)
	end
end

function M.Refresh_Status()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    PlayerPrefs.SetString(M.key .. MainModel.UserInfo.user_id, os.time())
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

    lister["finish_gift_shop"] = this.on_finish_gift_shop
    lister["PayPanelClosed"] = this.on_PayPanelClosed
    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status_response
    lister["AssetChange"] = this.on_AssetChange
    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg
    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg
    lister["PayPanel_GoodsChangeToGiftAllJingBiObj"] = this.on_PayPanel_GoodsChangeToGift
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["SYSACTBASEEnterPrefab_Create_icon_in_Game_response"] = this.on_SYSACTBASEEnterPrefab_Create_icon_in_Game_response
end

function M.on_backgroundReturn_msg()
    M.CloseItemPrefab()
end

function M.Init()
	M.Exit()

	this = Act_012_LMLHManager
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
    gift_ids = {}
    gift_map_ids = {}
    for k1, v1 in ipairs(M.item_config.Info) do
        gift_ids[#gift_ids + 1] = v1.gift_id
        gift_map_ids[v1.gift_id] = 1
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        if M.IsActive() then
            Timer.New(function ()
                M.query_data()
            end, 1, 1):Start()
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
    Event.Brocast("model_lmlh_data_change_msg")--刷新panel
end

function M.IsItemCanGet()
    local item = M.GetItemCount()
    for k,v in ipairs(gift_ids) do
        if gift_data and gift_data[v] and gift_data[v].remain_time and gift_data[v].remain_time > 0 and item >= tonumber(M.item_config.Info[k].Icon_cost)  then
            return k
        end
    end
end


function M.on_AssetChange(data)
    dump(data,"<color=blue>+++++++++++++++++++++</color>")
    M.Refresh_Status()
    if M.CheckIsShow() then
        if data.change_type then
            if string.sub(data.change_type,1,25) ~= "task_p_love_day_discount_" then
                for k,v in ipairs(data.data) do
                    if v.asset_type == "prop_love" then
                        M.Refresh()
                        return
                    end
                end
                return
            end
        end
        if #data.data >= 1 then
            Event.Brocast("Create_icon_in_Game_msg",#data.data)
            M.Refresh()
        end
    end
end

function M.on_SYSACTBASEEnterPrefab_Create_icon_in_Game_response(data)
    if data then
        M.CreateItemInGame(data.score,data.tran)
    end
end

function M.CreateItemInGame(score,tran)
    local pre = Act_012_LMLHIconInGame.Create(score,tran)
    if this.m_data.spawn_cell_list == nil then
        this.m_data.spawn_cell_list = {}
    end
    if pre then
        this.m_data.spawn_cell_list[#this.m_data.spawn_cell_list + 1] = pre
    end
end

function M.CloseItemPrefab()
    if this.m_data.spawn_cell_list then
        for k,v in ipairs(this.m_data.spawn_cell_list) do
            v:MyExit()
        end
    end
    this.m_data.spawn_cell_list = {}
end

function M.GetItemCount()
    return GameItemModel.GetItemCount(M.item_key)
end

local items = {}
items.jing_bi = {}
items.goods = {}
function M.on_PayPanel_GoodsChangeToGift(data)
    dump(data,"<color=green>++++++++data+++++++++++</color>")
    if not data or table_is_null(data) then
        return
    end 
    if  1589844600 < os.time() and os.time() < 1590422399 and M.IsActive() then
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
                    local obj = newObject("Act_012_LMLHIconInShop", temp_ui.act_node)
                    obj.transform.localPosition = Vector3.New(0,144,0)
                    local obj_childs = {}
                    LuaHelper.GeneratingVar(obj.transform, obj_childs)           
                    local gift_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
                    dump(gift_id,"<color=red>gift_id</color>")
                    if gift_id and M.shop_icon_config.Info[gift_id] then
                        obj_childs.Icon_number_txt.text = "×"..M.shop_icon_config.Info[gift_id].icon_txt
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
    if gift_map_ids[id] and gift_data and gift_data[id] then
        gift_data[id].remain_time = gift_data[id].remain_time - 1
        M.RefreshItems()
        M.Refresh()
    end
end

function M.RefreshItems()
    for k ,v in pairs(items.jing_bi) do
        local data = GameTaskModel.GetTaskDataByID(k)
        v.gameObject:SetActive((data and data.now_process < 1))
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

local CheckGiftDataFinish = function ()
    for k,v in ipairs(gift_ids) do
        if not gift_data[v] then
            return false
        end
    end
    return true
end


function M.QueryGiftData()
    if gift_data and CheckGiftDataFinish() then
        Event.Brocast("model_lmlh_data_change_msg")
    else
        M.query_data()
    end
end

function M.GetCurData()
    local _cur_data = {}
    for i=1,#M.item_config.Info do
        _cur_data[i] = {}
        _cur_data[i].gift_id = M.item_config.Info[i].gift_id--礼包ID
        _cur_data[i].title_text = M.item_config.Info[i].title_text--标题text
        _cur_data[i].award_text = M.item_config.Info[i].award_text--奖励text
        _cur_data[i].RMB_cost = M.item_config.Info[i].RMB_cost--人民币得消耗text
        _cur_data[i].Icon_cost = M.item_config.Info[i].Icon_cost--道具的消耗txet
        if gift_data[_cur_data[i].gift_id] then
            _cur_data[i].status = gift_data[_cur_data[i].gift_id].status--礼包状态
            _cur_data[i].remain_time = gift_data[_cur_data[i].gift_id].remain_time--礼包当日剩余次数
        else
            _cur_data[i].status = 0
            _cur_data[i].remain_time = 0
        end
    end
    return _cur_data
end


function M.on_query_gift_bag_status_response(_, data)
    dump(data,"<color=white>on_query_gift_bag_status_response</color>")
    if data.result == 0 then
        gift_data = gift_data or {}
        gift_data[data.gift_bag_id] = {}
        gift_data[data.gift_bag_id].status = data.status
        gift_data[data.gift_bag_id].remain_time = data.remain_time
    end
end


function M.query_data()
    local msg_list = {}
    for k,v in pairs(gift_ids) do
        msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v}}
    end
    GameManager.SendMsgList("lmlh", msg_list)
end


function M.on_query_send_list_fishing_msg(tag)
    if tag == "lmlh" then
        M.Refresh()
    end
end

function M.on_client_system_variant_data_change_msg()
    M.query_data()
end

