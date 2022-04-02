-- 创建时间:2020-04-13
-- Act_009XYCDManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_009XYCDManager = {}
local M = Act_009XYCDManager
M.key = "act_009_xycd"
Act_009XYCDManager.config = GameButtonManager.ExtLoadLua(M.key,"activity_xycd_config")
Act_009XYCDManager.shop_sun_config = GameButtonManager.ExtLoadLua(M.key,"act_xycd_shop_sunConfig")
Act_009XYCDManager.goodsid_config = GameButtonManager.ExtLoadLua(M.key,"activity_009_xycd_config").config
GameButtonManager.ExtLoadLua(M.key,"act_xycdPanel")
GameButtonManager.ExtLoadLua(M.key,"XYCDEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"act_009ItemBase")
GameButtonManager.ExtLoadLua(M.key,"SunItemInGame")
local this
local lister
local task_ids
local task_map_ids
local gift_data

M.now_level = 0
M.item_key = "prop_sunshine"

local permisstions = {
    "actp_buy_gift_bag_class_lucky_egg_1",
    "actp_buy_gift_bag_class_lucky_egg_2",
}

local max_remian = {
    1,3,5,8
}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1588003199
    local s_time = 1587423600
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
            return act_xycdPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return XYCDEnterPrefab.Create(parm.parent, parm.cfg)
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

    lister["PayPanel_GoodsChangeToGift"] = this.PayPanel_GoodsChangeToGift
    lister["paypanel_goods_created"] = this.on_paypanel_goods_created
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买

    lister["PayPanelClosed"] = this.on_PayPanelClosed

    lister["query_gift_bag_status_response"] = this.on_query_gift_bag_status_response
    lister["query_all_gift_bag_status_response"] = this.on_query_all_gift_bag_status
    lister["AssetChange"] = this.on_AssetChange
    lister["EnterScene"] = this.OnEnterScene

    lister["gift_bag_status_change_msg"] = this.on_gift_bag_status_change_msg
    lister["query_send_list_fishing_msg"] = this.on_query_send_list_fishing_msg

    lister["client_system_variant_data_change_msg"] = this.on_client_system_variant_data_change_msg
end

function M.Init()
	M.Exit()

	this = Act_009XYCDManager
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


function M.InitUIConfig()
    task_ids = {}
    task_map_ids = {}
    for i=1,#Act_009XYCDManager.config.Info do
        task_ids[i] = task_ids[i] or {}
        for k1, v1 in ipairs(Act_009XYCDManager.config.Info[i]) do
            task_ids[i][#task_ids[i] + 1] = v1.task_id
            task_map_ids[v1.task_id] = 1
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
    for k,v in ipairs(task_ids[M.now_level]) do
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
    --     --dump(task_ids,"<color=green>BBBBBBBBBB</color>")
    --     for i=1,#data.gift_bag_data do
    --         for j=1,#task_ids do
    --             if data.gift_bag_data[i].gift_bag_id == task_ids[j] then
    --                 --dump("<color=green>@@@@@@@@@@@@@@@@@@</color>")
    --                 gift_data[#gift_data+1] = data.gift_bag_data[i]
    --             end
    --         end       
    --     end
    --     M.Refresh()
    -- end
end

function M.on_AssetChange(data)
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
function M.on_paypanel_goods_created(data)
    if  1587423600 < os.time() and os.time() < 1588003199 then
        -- dump(data,"<color=red>on_PayPanel_GoodsChangeToGift</color>")
        local temp_ui = {}
        LuaHelper.GeneratingVar(data.prefab.transform, temp_ui)
        if M.CheckIsShow() then
            temp_ui.give_img.gameObject:SetActive(false)
            local GoodsData = data.goodsData
            if GoodsData.id == 7 and  GoodsData.type == "jing_bi" then-- 剔除钻石换金币
                return
            end
            local obj = newObject("act_009_xycdyangguang", temp_ui.act_node)
            obj.transform.localPosition = Vector3.New(0,144,0)
            local obj_childs = {}
            LuaHelper.GeneratingVar(obj.transform, obj_childs)           
            local task_id = M.GetTaskIDByGoodsID(GoodsData.goods_id)
            dump(task_id,"<color=red>task_id</color>")
            if task_id and M.shop_sun_config.Info[task_id] then
                obj_childs.sun_number_txt.text = "×"..M.shop_sun_config.Info[task_id].sun_txt
                if GoodsData.type == "jing_bi" then 
                    --dump("<color=green>+++++++++++++++++++++++++++++++++++</color>")
                    items.jing_bi[task_id] = obj
                elseif GoodsData.type == "goods" then
                    items.goods[task_id] = obj
                end
            else
                obj.gameObject:SetActive(false)  
            end
            M.RefreshItems()
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

-- 当前体验彩蛋的礼包ID
function M.GetCurTYCDGiftID()
   if M.now_level == 1 then
        return 10191
   end 
   if M.now_level == 2 then
        return 10196
   end
   return 0
end
function M.IsTYCDGiftID(id)
    if id == 10191 or id == 10196 then
        return true
    end
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_Hall" and MainModel.lastmyLocation == "game_MiniGame" and M.CheckIsShow() then
        if M.GetSunCount() >= 1 then
            local caidan
            if gift_data then
                caidan = gift_data[M.GetCurTYCDGiftID()]
            end
            if caidan and caidan.remain_time > 0 then
                act_xycdPanel.Create()
            end
        end
    end
end

function M.GetTaskIDByGoodsID(goods_id)
    for i = 1,#M.goodsid_config do
        if M.goodsid_config[i].shop_id == goods_id then 
            return M.goodsid_config[i].task_id
        end
    end
end

local CheckGiftDataFinish = function ()
    for k,v in ipairs(task_ids[M.now_level]) do
        if not gift_data[v] then
            return false
        end
    end
    return true
end

function M.QueryGiftData()
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
        _cur_data[i][1] = M.config.Info[M.now_level][i].ID--ID
        _cur_data[i][2] = M.config.Info[M.now_level][i].task_id--礼包ID(其实就是礼包ID)
        _cur_data[i][3] = M.config.Info[M.now_level][i].eggs_name--蛋的名字
        _cur_data[i][4] = M.config.Info[M.now_level][i].eggs_award_text--蛋的奖励text(title)
        _cur_data[i][5] = M.config.Info[M.now_level][i].eggs_image--蛋的图片
        _cur_data[i][6] = M.config.Info[M.now_level][i].sun_cost_text--阳光能量消耗text
        _cur_data[i][7] = M.config.Info[M.now_level][i].button_text--按钮text
        _cur_data[i][8] = M.config.Info[M.now_level][i].eggs_nameBG--蛋名字的背景图

        if gift_data[_cur_data[i][2]] then
            _cur_data[i][9] = gift_data[_cur_data[i][2]].status
            _cur_data[i][10] = gift_data[_cur_data[i][2]].remain_time
        else
            _cur_data[i][9] = 0
            _cur_data[i][10] = 0
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
    for k,v in pairs(task_ids[M.now_level]) do
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