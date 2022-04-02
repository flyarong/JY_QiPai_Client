-- 创建时间:2020-04-13
-- Act_014_XYCDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_014_XYCDManager = {}
local M = Act_014_XYCDManager
M.key = "act_014_xycd"
Act_014_XYCDManager.config = GameButtonManager.ExtLoadLua(M.key,"act_014_xycd_egg_config")
Act_014_XYCDManager.shop_icon_config = GameButtonManager.ExtLoadLua(M.key,"act_014_xycd_shopicon_config")
Act_014_XYCDManager.goodsid_config = GameButtonManager.ExtLoadLua(M.key,"act_014_xycd_shopid_config")
GameButtonManager.ExtLoadLua(M.key,"Act_014_XYCDPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_014_XYCDEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_014_XYCDItemBase")
GameButtonManager.ExtLoadLua(M.key,"Act_014_XYCDIconInGame")
local this
local lister
local gift_ids
local task_map_ids
local gift_data

M.now_level = 0
M.item_key = "prop_sunshine"

local permisstions = {
    "actp_buy_gift_bag_class_lucky_egg_1",
    "actp_buy_gift_bag_class_lucky_egg_2",
}

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1591631999
    local s_time = 1591054200
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key="actp_lucky_egg_popup", is_on_hint = true}, "CheckCondition")
    if a and not b then
        return false
    end
    if M.GetNowPerMiss() then 
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
            return Act_014_XYCDPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return Act_014_XYCDEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsEggExist() then
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

function M.Refresh()
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})--刷新enter
    Event.Brocast("model_xycd_data_change_msg")--刷新panel
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

    lister["model_task_change_msg"] = this.on_model_task_change_msg--小游戏中任务改变结算阳光

    lister["PayPanel_GoodsChangeToGiftAllJingBiObj"] = this.on_PayPanel_GoodsChangeToGift
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买

    lister["PayPanelClosed"] = this.on_PayPanelClosed

    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status_response
    lister["query_all_gift_bag_status_response"] = this.on_query_all_gift_bag_status
    lister["AssetChange"] = this.on_AssetChange
    lister["EnterScene"] = this.OnEnterScene

    lister["gift_bag_status_change_msg"] = this.on_gift_bag_status_change_msg
    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg

    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
end

function M.Init()
	M.Exit()

	this = Act_014_XYCDManager
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


function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.Init()
        if M.IsActive() then
            Timer.New(function ()
                M.query_data()
            end, 1, 1):Start()
        end
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_backgroundReturn_msg()
    Event.Brocast("XYCD_on_backgroundReturn_msg")
end

function M.InitUIConfig()
    gift_ids = {}
    task_map_ids = {}
    for i=1,#Act_014_XYCDManager.config.Info do
        gift_ids[i] = gift_ids[i] or {}
        for k1, v1 in ipairs(Act_014_XYCDManager.config.Info[i]) do
            gift_ids[i][#gift_ids[i] + 1] = v1.gift_id
            task_map_ids[v1.gift_id] = 1
        end
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

function M.on_gift_bag_status_change_msg(_, data)
    dump(data, "<color=white>????????????????????????????????</color>")
end

function M.IsEggExist()
    local sun = M.GetSunCount()
    for k,v in ipairs(gift_ids[M.now_level]) do
        if gift_data and gift_data[v] and gift_data[v].remain_time > 0 and sun >= tonumber(M.config.Info[M.now_level][k].sun_cost_text)  then
            return k
        end
    end
end

function M.on_query_all_gift_bag_status(_,data)
    -- dump({_,data},"<color=white>on_query_all_gift_bag_status</color>")
    -- if M.CheckIsShow() then
    --     gift_data = {}
    --     --dump(data,"<color=green>AAAAAAAAAAAAAA</color>")
    --     --dump(gift_ids,"<color=green>BBBBBBBBBB</color>")
    --     for i=1,#data.gift_bag_data do
    --         for j=1,#gift_ids do
    --             if data.gift_bag_data[i].gift_bag_id == gift_ids[j] then
    --                 --dump("<color=green>@@@@@@@@@@@@@@@@@@</color>")
    --                 gift_data[#gift_data+1] = data.gift_bag_data[i]
    --             end
    --         end       
    --     end
    --     M.Refresh()
    -- end
end

function M.on_AssetChange(data)
    dump(data,"<color>+++++++++++++++on_AssetChange++++++++++++++++++</color>")
    if M.CheckIsShow() then
        if data.change_type then
            if string.sub(data.change_type,1,17) ~= "task_p_lucky_egg_" then
                for k,v in ipairs(data.data) do
                    if v.asset_type == "prop_sunshine" then
                        M.Refresh()
                        return
                    end
                end
                return
            end
        end
        dump(#data.data,"<color>/////////////////////////</color>")
        if #data.data >= 1 then
            Event.Brocast("xycdManager_CreateSunItemInGame",#data.data)
            M.Refresh()
        end
    end
end


function M.GetSunCount()
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
    if  1591054200 < os.time() and os.time() < 1591631999 and M.IsActive() then
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
                    local obj = newObject("Act_014_XYCDIconInShop", temp_ui.act_node)
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

function M.on_finish_gift_shop(id)
    if task_map_ids[id] and gift_data and gift_data[id] then
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

function M.on_PayPanelClosed()
    items = {}
    items.jing_bi = {}
    items.goods = {}
end


function M.OnEnterScene()
--[[    if MainModel.myLocation == "game_Hall" and MainModel.lastmyLocation == "game_MiniGame" and M.CheckIsShow() then
        if M.GetSunCount() >= 1 then
            local caidan
            if gift_data then
                caidan = gift_data[M.GetCurTYCDGiftID()]
            end
            if caidan and caidan.remain_time > 0 then
                Act_014_XYCDPanel.Create()
            end
        end
    end--]]
end

function M.GetTaskIDByGoodsID(goods_id)
    for i = 1,#M.goodsid_config do
        if M.goodsid_config[i].shop_id == goods_id then 
            return M.goodsid_config[i].gift_id
        end
    end
end

local CheckGiftDataFinish = function ()
    for k,v in ipairs(gift_ids[M.now_level]) do
        if not gift_data[v] then
            return false
        end
    end
    return true
end

function M.QueryGiftData()
    dump(gift_data,"<color>+++++++++++++++++++++++++++++++++</color>")
    if gift_data and CheckGiftDataFinish() then
        Event.Brocast("model_xycd_data_change_msg")
    else
        M.query_data()
    end
end

function M.GetCurData()
    local _cur_data = {}
    for i=1,#M.config.Info[M.now_level] do
        _cur_data[i] = {}
        _cur_data[i].ID = M.config.Info[M.now_level][i].ID--ID
        _cur_data[i].gift_id = M.config.Info[M.now_level][i].gift_id--礼包ID(其实就是礼包ID)
        _cur_data[i].eggs_name = M.config.Info[M.now_level][i].eggs_name--蛋的名字
        _cur_data[i].eggs_award_text = M.config.Info[M.now_level][i].eggs_award_text--蛋的奖励text(title)
        _cur_data[i].eggs_image = M.config.Info[M.now_level][i].eggs_image--蛋的图片
        _cur_data[i].sun_cost_text = M.config.Info[M.now_level][i].sun_cost_text--阳光能量消耗text
        _cur_data[i].button_text = M.config.Info[M.now_level][i].button_text--按钮text
        _cur_data[i].eggs_nameBG = M.config.Info[M.now_level][i].eggs_nameBG--蛋名字的背景图
        _cur_data[i].eggs_award_desc = M.config.Info[M.now_level][i].eggs_award_desc--蛋名字的背景图
        

        if gift_data[_cur_data[i].gift_id] then
            _cur_data[i].status = gift_data[_cur_data[i].gift_id].status
            _cur_data[i].remain_time = gift_data[_cur_data[i].gift_id].remain_time
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
    for k,v in pairs(gift_ids[M.now_level]) do
        msg_list[#msg_list + 1] = {msg="query_gift_bag_status", data = {gift_bag_id = v}}
    end
    GameManager.SendMsgList("xycd", msg_list)
end
function M.on_query_send_list_fishing_msg(tag)
    if tag == "xycd" then
        M.Refresh()
    end
end

function M.on_client_system_variant_data_change_msg()
    M.GetNowPerMiss()
    if M.now_level then
        M.query_data()
    end
end