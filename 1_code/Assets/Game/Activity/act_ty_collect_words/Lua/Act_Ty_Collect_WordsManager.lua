-- 创建时间:2021-01-04
-- Act_Ty_Collect_WordsManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_Ty_Collect_WordsManager = {}
local M = Act_Ty_Collect_WordsManager
M.key = "act_ty_collect_words"
M.config = GameButtonManager.ExtLoadLua(M.key,"act_ty_collect_words_config")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_Collect_WordsCollectPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_Collect_WordsEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_Collect_WordsGiftPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_Collect_WordsLeftPage")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_Collect_WordsPanel")
GameButtonManager.ExtLoadLua(M.key,"Act_Ty_Collect_WordsCollectItemBase")
M.permisstions = {}
M.now_level = 1
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = M.GetActEndTime()
    local s_time = M.GetActStartTime()
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    dump(M.GetNowPerMiss(),"<color=red>集字换礼权限</color>")
    if M.GetNowPerMiss() then 
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
        return Act_Ty_Collect_WordsPanel.Create(parm.parent,parm.backcall)
    elseif parm.goto_scene_parm == "enter" then
        if MainModel.myLocation == "game_Eliminate" and MainModel.UserInfo.ui_config_id == 2 then
        else
            return Act_Ty_Collect_WordsEnterPrefab.Create(parm.parent, parm.cfg)
        end
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsCollectCanGet() then
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

    lister["activity_exchange_response"] = this.on_activity_exchange_response
    lister["finish_gift_shop"] = this.on_finish_gift_shop--完成礼包购买
    lister["main_query_gift_bag_data_msg"] = this.on_main_query_gift_bag_data_msg
end

function M.Init()
	M.Exit()

	this = Act_Ty_Collect_WordsManager
	this.m_data = {}
	MakeLister()
    AddLister()
	M.InitUIConfig()
end
function M.Exit()
	if this then
        M.StopTimerToCheck()
		RemoveLister()
		this = nil
	end
end
function M.InitUIConfig()
    this.UIConfig = {}
    for i=1,#M.config.platform_or_channel_or_level do
        M.permisstions[#M.permisstions + 1] = M.config.platform_or_channel_or_level[i].permission
    end
    M.GetNowPerMiss()
    M.gfit_config = M.config[M.config.platform_or_channel_or_level[M.now_level].gift_config]
    M.collect_config = M.config[M.config.platform_or_channel_or_level[M.now_level].collect_config]

    M.care_types_and_ids = {}--关心的activity_exchange的type和id
    M.care_items_and_nums = {}--关心的items和对应的数量
    for i=1,#M.collect_config do
        M.care_types_and_ids[#M.care_types_and_ids + 1] = {type = M.collect_config[i].exchange_type,id = M.collect_config[i].exchange_id}
        M.care_items_and_nums[#M.care_items_and_nums + 1] = {item = M.collect_config[i].need_item,num = M.collect_config[i].need_num}
    end

    M.care_gift_ids = {}--关心的礼包id
    for i=1,#M.gfit_config do
        M.care_gift_ids[#M.care_gift_ids + 1] = M.gfit_config[i].gift_id
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        M.TimerToCheckGiftIsCanBuy(true)
	end
end
function M.OnReConnecteServerSucceed()
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
    M.now_level = 1
    for i = 1,#M.permisstions do 
        if cheak_fun(M.permisstions[i]) then
            dump(M.permisstions[i],"符合条件的权限")
            M.now_level = i
            return i
        end
    end
end

function M.GetGiftCfg()
    local data = basefunc.deepcopy(M.gfit_config)
    if M.config.other_data[1].is_sort == 1 then
        MathExtend.SortListCom(data, function (v1,v2)
            if MainModel.GetGiftShopStatusByID(v1.gift_id) == 0 and MainModel.GetGiftShopStatusByID(v2.gift_id) == 1 then
                return true
            end
            if v1.line > v2.line then
                return true
            end
        end)
    end
    return data
end

function M.GetCollectCfg()
    return M.collect_config
end

function M.BuyGift(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    dump(MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid))
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end

function M.GetActStartTime()
    return M.config.other_data[1].sta_t
end

function M.GetActEndTime()
    return M.config.other_data[1].end_t
end

function M.GetStart_t()
    return string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M",M.GetActStartTime()) or string.sub(os.date("%m月%d日%H:%M",M.GetActStartTime()),2)
end

function M.GetEnd_t()
    return string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),1,1) ~= "0" and os.date("%m月%d日%H:%M:%S",M.GetActEndTime()) or string.sub(os.date("%m月%d日%H:%M:%S",M.GetActEndTime()),2)
end

function M.GetCollectAward(type_,id)
    Network.SendRequest("activity_exchange",{ type = type_ , id = id })
end

function M.on_activity_exchange_response(_,data)
    dump(data,"<color=yellow><size=15>++++++++++on_activity_exchange_response++++++++++</size></color>")
    if data and data.result == 0 then
        for k,v in pairs(M.care_types_and_ids) do
            if v.type == data.type and v.id == data.id then
                Event.Brocast("ty_collect_activity_exchange_response_msg")
                break
            end
        end
    end
end

function M.IsCollectCanGet()
    for k,v in pairs(M.care_items_and_nums) do
        for i=1,#v.item do
            if GameItemModel.GetItemCount(v.item[i]) >= v.num[i] then
                return true
            end
        end
    end
    return false
end

function M.on_finish_gift_shop(id)
    if id then
        for k,v in pairs(M.care_gift_ids) do
            if v == id then
                M.QueryGiftData(id)
                break
            end
        end
    end
end


-- 用做零点刷新的timer
function M.TimerToCheckGiftIsCanBuy(b)
    M.StopTimerToCheck()
    if b then
        M.old_day = os.date("%d",os.time())
        M.timer_to_check = Timer.New(function ()
            M.new_day = os.date("%d",os.time())
            if M.new_day ~= M.old_day then
                M.old_day = M.new_day
                Event.Brocast("ty_collect_day_is_change_msg")
            end
        end,15,-1,false)
        M.timer_to_check:Start()
    end
end

function M.StopTimerToCheck()
    if M.timer_to_check then
        M.timer_to_check:Stop()
        M.timer_to_check = nil 
    end
end

function M.QueryGiftData(gift_id)
    Network.SendRequest("query_gift_bag_status",{gift_bag_id = gift_id})
end

function M.on_main_query_gift_bag_data_msg(id)
    if id then
        for k,v in pairs(M.care_gift_ids) do
            if v == id then
                Event.Brocast("ty_collect_finish_gift_shop_msg")
                break
            end
        end
    end
end