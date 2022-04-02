-- 创建时间:2020-04-23
-- Act_010_MQJTHManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_010_MQJTHManager = {}
local M = Act_010_MQJTHManager
M.key = "act_010_mqjth"
Act_010_MQJTHManager.shop_flower_config = GameButtonManager.ExtLoadLua(M.key,"act_010_shop_flower_config")
Act_010_MQJTHManager.item_config = GameButtonManager.ExtLoadLua(M.key,"act_010_item_config")
Act_010_MQJTHManager.goodsid_config = GameButtonManager.ExtLoadLua(M.key,"act_010_goods_id_config")
GameButtonManager.ExtLoadLua(M.key,"Act_010_MQJTHEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_010_MQJTHPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_010_MQJTHFlowerItemInGame")
GameButtonManager.ExtLoadLua(M.key,"Act_010_MQJTHItemBase")
local this
local lister
local gift_ids
local gift_qfxl_list
local gift_qfxl_map
local gift_map_ids
local gift_data
local gift_data2
local _time
M.item_key = "prop_carnation"
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1589212799
    local s_time = 1588608000
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_recharge_carnation_value"
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
        if M.CheckIsShow() then
            return Act_010_MQJTHPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return Act_010_MQJTHEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsFlowerCanGet() then
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

    lister["paypanel_goods_created"] = this.on_paypanel_goods_created
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
    lister["PayPanelClosed"] = this.on_PayPanelClosed
    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status_response
    lister["AssetChange"] = this.on_AssetChange

    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg

    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg

    lister["query_gift_bag_num_by_ids_response"] = this.on_query_gift_bag_num_by_ids_response
end

function M.Init()
	M.Exit()

	this = Act_010_MQJTHManager
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
    gift_qfxl_list = {}
    gift_qfxl_map = {}
    for k1, v1 in ipairs(M.item_config.Info) do
        gift_ids[#gift_ids + 1] = v1.gift_id
        gift_map_ids[v1.gift_id] = 1
        if v1.type == 1 then
            gift_qfxl_list[#gift_qfxl_list + 1] = v1.gift_id
            gift_qfxl_map[v1.gift_id] = 1
        end
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
    Event.Brocast("model_mqjth_data_change_msg")--刷新panel
end

function M.on_gift_bag_status_change_msg(_, data)
    dump(data, "<color=white>????????????????????????????????</color>")
end


function M.IsFlowerCanGet()
    local flower = M.GetFlowerCount()
    --dump(gift_data)
    for k,v in ipairs(gift_ids) do
        --dump(M.item_config.Info[k])
        if gift_data and gift_data[v] and gift_data[v].remain_time > 0 and flower >= tonumber(M.item_config.Info[k].flower_cost)  then
            return k
        end
    end
end

function M.on_AssetChange(data)
    if M.CheckIsShow() then
        if data.change_type then
            if string.sub(data.change_type,1,27) ~= "task_p_mother_day_discount_" then
                for k,v in ipairs(data.data) do
                    if v.asset_type == "prop_carnation" then
                        M.Refresh()
                        return
                    end
                end
                return
            end
        end
        if #data.data >= 1 then
            Event.Brocast("MQJTHManager_CreateFlowerItemInGame",#data.data)
            M.Refresh()
        end
    end
end


function M.GetFlowerCount()
    return GameItemModel.GetItemCount(M.item_key)
end


local items = {}
items.jing_bi = {}
items.goods = {}
function M.on_paypanel_goods_created(data)
    if  1588608000 < os.time() and os.time() < 1589212799 then
        dump(data,"<color=red>on_PayPanel_GoodsChangeToGift</color>")
        local temp_ui = {}
        LuaHelper.GeneratingVar(data.prefab.transform, temp_ui)
        if M.CheckIsShow() then
            temp_ui.give_img.gameObject:SetActive(false)
            local GoodsData = data.goodsData
            if GoodsData.id == 7 and  GoodsData.type == "jing_bi" then-- 剔除钻石换金币
                return
            end
            local obj = newObject("Act_010_MQJTHFlowerInShop", temp_ui.act_node)
            obj.transform.localPosition = Vector3.New(0,144,0)
            local obj_childs = {}
            LuaHelper.GeneratingVar(obj.transform, obj_childs)           
            local gift_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
            dump(gift_id,"<color=red>gift_id</color>")
            if gift_id and M.shop_flower_config.Info[gift_id] then
                obj_childs.flower_number_txt.text = "×"..M.shop_flower_config.Info[gift_id].flower_txt
                if GoodsData.type == "jing_bi" then 
                    --dump("<color=green>+++++++++++++++++++++++++++++++++++</color>")
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

function M.on_PayPanelClosed()
    items = {}
    items.jing_bi = {}
    items.goods = {}
end

function M.on_finish_gift_shop(id)
    if gift_map_ids[id] and gift_data and gift_data[id] then
        if not gift_qfxl_map[id] then
            gift_data[id].remain_time = gift_data[id].remain_time - 1            
        end
        gift_data2[id].num = gift_data2[id].num - 1
        M.RefreshItems()
        M.Refresh()
        if id == 10231 then
            local timer = Timer.New(function ()
                Network.SendRequest("query_gift_bag_status",{gift_bag_id = 10231})
            end,1,1.1):Start()        
        end
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
        if not gift_data[v] or not gift_data2[v] then
            return false
        end
    end
    return true
end

function M.StopUpdateTime()
    if _time then
        _time:Stop()
        _time = nil
    end
end
function M.update_time(b)
    M.StopUpdateTime()
    if b then
        _time = Timer.New(function ()
            M.QueryQFXLGiftData()
        end, 5, -1, nil, true)
        _time:Start()
    end
end
function M.QueryQFXLGiftData()
    Network.SendRequest("query_gift_bag_num_by_ids",{gift_bag_ids = gift_qfxl_list})
end
function M.QueryGiftData()
    if gift_data and gift_data2 and CheckGiftDataFinish() then
        Event.Brocast("model_mqjth_data_change_msg")
        M.QueryQFXLGiftData()
    else
        M.query_data()
    end
end

function M.GetCurData()
    local _cur_data = {}
    for i=1,#M.item_config.Info do
        _cur_data[i] = {}
        _cur_data[i].gift_id = M.item_config.Info[i].gift_id--礼包ID
        _cur_data[i].award_text = M.item_config.Info[i].award_text--奖励text
        _cur_data[i].Item_image = M.item_config.Info[i].Item_image--物品的图片img
        _cur_data[i].origin_RMB_cost = M.item_config.Info[i].origin_RMB_cost--原价text
        _cur_data[i].need_RMB_cost = M.item_config.Info[i].need_RMB_cost--当前需要的价格text
        _cur_data[i].flower_cost = M.item_config.Info[i].flower_cost--康乃馨的消耗txet
        _cur_data[i].type = M.item_config.Info[i].type--礼包类型("0 == 每日限量"or"1 == 全服限量")
        if gift_data[_cur_data[i].gift_id] then
            _cur_data[i].status = gift_data[_cur_data[i].gift_id].status--礼包状态
            _cur_data[i].remain_time = gift_data[_cur_data[i].gift_id].remain_time--礼包当日剩余次数
        else
            _cur_data[i].status = 0
            _cur_data[i].remain_time = 0
        end
        if gift_data2[_cur_data[i].gift_id] then
            _cur_data[i].num = gift_data2[_cur_data[i].gift_id].num--全服限量个数
        else
            _cur_data[i].num = 0
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

function M.on_query_gift_bag_num_by_ids_response(_,data)
    dump(data,"<color=blue>on_query_gift_bag_num_by_ids_response</color>")
    if data.result == 0 then
        gift_data2 = gift_data2 or {}
        for i=1,#data.gift_bag_data do
            gift_data2[data.gift_bag_data[i].gift_bag_id] = {}
            gift_data2[data.gift_bag_data[i].gift_bag_id].num = data.gift_bag_data[i].num
        end
        Event.Brocast("model_mqjth_data_change_msg")
    end
end


function M.query_data()
    local msg_list = {}
    for k,v in pairs(gift_ids) do
        msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v}}
    end
    GameManager.SendMsgList("mqjth", msg_list)
    Network.SendRequest("query_gift_bag_num_by_ids",{gift_bag_ids = gift_ids})   
end


function M.on_query_send_list_fishing_msg(tag)
    if tag == "mqjth" then
        M.Refresh()
    end
end

function M.on_client_system_variant_data_change_msg()
    M.query_data()
end

