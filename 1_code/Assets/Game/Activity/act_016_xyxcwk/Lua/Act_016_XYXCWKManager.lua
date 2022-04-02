-- 创建时间:2020-06-10
-- Act_016_XYXCWKManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_016_XYXCWKManager = {}
local M = Act_016_XYXCWKManager
M.key = "act_016_xyxcwk"
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_016_cwk_config")
GameButtonManager.ExtLoadLua(M.key, "Act_016_XYXCWKPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_016_XYXCWKLBPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_016_XYXCWKHelpPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_016_XYXCWKHintPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_016_XYXCWKEnterPrefab")

M.shop_id = 10296
M.day_task_id = 21333
M.father_task_id1 = 21334
M.father_task_id2 = 21335
local this
local lister
local max_show_lb_num = 3

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
    if parm.goto_scene_parm == "enter" then
        return Act_016_XYXCWKEnterPrefab.Create(parm.parent)
    end
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if  M.IsAwardCanGet() and os.time() < M.GetOverTime() then
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    else
        local newtime = tonumber(os.date("%Y%m%d", os.time()))
        local user_id = MainModel.UserInfo and MainModel.UserInfo.user_id or ""
        local oldtime = tonumber(os.date("%Y%m%d", tonumber(PlayerPrefs.GetString(M.key .. user_id, 0))))
        if oldtime ~= newtime then
            return ACTIVITY_HINT_STATUS_ENUM.AT_Red
        end
        return ACTIVITY_HINT_STATUS_ENUM.AT_Nor
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
    lister["chang_wan_ka_base_info_change"] = this.chang_wan_ka_base_info_change
    lister["query_chang_wan_ka_base_info_response"] = this.query_chang_wan_ka_base_info_response
	lister["minigamehall_created"] = this.on_minigamehall_created
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["model_task_change_msg"] = this.on_model_task_change_msg
    lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["EnterScene"] = this.OnEnterScene
end

function M.Init()
	M.Exit()

	this = Act_016_XYXCWKManager
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
    --以任务ID为索引
    this.UIConfig = {}
    for k,v in pairs(M.config.task_info) do
        this.UIConfig[v.task_id] = v
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        -- 数据初始化
        Network.SendRequest("query_chang_wan_ka_base_info") 
	end
end
function M.OnReConnecteServerSucceed()
end

function M.on_minigamehall_created(data)
	-- local is_change_ui = true
	-- if data and data.panelSelf then
	-- 	if is_change_ui then
	-- 		M.SetOldUI(data.panelSelf,false)
	-- 	end
	-- end
end

function M.SetOldUI(panel,status)
	local rectTop = panel.gameObject.transform:Find("TopRect/RectTop")
	rectTop.gameObject.transform:Find("ImageL").gameObject:SetActive(status)
	rectTop.gameObject.transform:Find("ImageR").gameObject:SetActive(status)
	rectTop.gameObject.transform:Find("Image1").gameObject:SetActive(status)
	rectTop.gameObject.transform:Find("Image2").gameObject:SetActive(status)
	rectTop.gameObject.transform:Find("TitleImage").gameObject:SetActive(status)
end

function M.BuyShop()
	local shopid = M.shop_id
    local gb =  MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid)
    if not gb then return end
	local price = gb.price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function M.query_chang_wan_ka_base_info_response(_,data)
    dump(data,"<color=red>畅玩卡数据get</color>")
    if data and data.result == 0 then
        this.m_data = data
        Event.Brocast("act_016_xyxcwk_new_info_get")
        M.UpDateTime()
    end
end

function M.chang_wan_ka_base_info_change(_,data)
    this.m_data = data
    dump(data,"<color=red>畅玩卡数据改变</color>")
    M.UpDateTime()
    Event.Brocast("act_016_xyxcwk_new_info_get")
end

function M.GetIsMf()
    if this.m_data and this.m_data.refresh_task_num == 0 then
        return true
    end
    return false
end

function M.GetCount(index)
    if this.m_data then
        return this.m_data["remain_num_"..index] or 0
    end
    return 0
end

function M.IsAllGet()
    local sum = 0
    for i = 1,3 do
        sum = sum + (this.m_data["remain_num_"..i] or 0)
        dump(this.m_data["remain_num_"..i],"<color=red>剩余次数</color>"..this.m_data["remain_num_"..i])
    end
    return sum == 0
end

function M.GetConfigByID(task_id)
    if task_id then
        return this.UIConfig[task_id]
    end
end

function M.on_model_task_change_msg(data)
    if M.day_task_id == data.id or M.father_task_id1 == data.id or M.father_task_id2 == data.id
    or this.UIConfig[data.id] then
        Event.Brocast("global_hint_state_change_msg", { gotoui = M.key })
    end
end

function M.on_model_query_one_task_data_response(data)
    if M.day_task_id == data.id or M.father_task_id1 == data.id or M.father_task_id2 == data.id
    or this.UIConfig[data.id] then
        Event.Brocast("act_016_xyxcwk_new_info_get")
    end
end

--获取今天的普通任务
function M.GetTodayTask1()
    local father_data = GameTaskModel.GetTaskDataByID(M.father_task_id1)
    if father_data and father_data.other_data_str then
        return tonumber(father_data.other_data_str)
    else
        Network.SendRequest("query_one_task_data",{task_id = M.father_task_id1})
    end
end
--获取今天的特殊任务
function M.GetTodayTask2()
    local father_data = GameTaskModel.GetTaskDataByID(M.father_task_id2)
    if father_data and father_data.other_data_str then
        return tonumber(father_data.other_data_str)
    else
        Network.SendRequest("query_one_task_data",{task_id = M.father_task_id2})
    end
end

local UpTimer
local TextTable = {}
function M.UpDateTime(Text)
    if not this.m_data.over_time then return end
    local t = this.m_data.over_time - os.time()
    if Text then
        TextTable[#TextTable + 1] = Text
    end
    if UpTimer then
        UpTimer:Stop()
    end
    for k,v in pairs(TextTable) do
        if IsEquals(v) then
            v.text = "剩余时间："..StringHelper.formatTimeDHMS3(t)
        else
            v = nil
        end
    end
    UpTimer = Timer.New(function ()
        if t > 0 then
            t = t - 1
            for k,v in pairs(TextTable) do
                if IsEquals(v) then
                    v.text = "剩余时间："..StringHelper.formatTimeDHMS3(t)
                else
                    v = nil
                end
            end
        else
            UpTimer:Stop()
            --时间结束
            Event.Brocast("act_016_cwk_time_over")
        end
    end,1,-1)
    UpTimer:Start()
end

function M.GetOverTime()
    local t =  this.m_data.over_time or 0
    return  tonumber(t)
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_MiniGame" then
        if M.GetLbCurDayShowNum() >= max_show_lb_num then
            return
        end
        local status = MainModel.GetGiftShopStatusByID(M.shop_id)
        if status == 1 or M.GetOverTime() <= os.time() or M.IsAllGet() then
            --重来没买过
            if  M.GetOverTime() == 0 then
                Act_016_XYXCWKLBPanel.Create()
                this.SetLbCurDayShowNum(1,false)
            elseif M.IsAllGet() then
                Act_016_XYXCWKHintPanel.Create(1)
            else
                Act_016_XYXCWKHintPanel.Create(2)
            end
        else
            Act_016_XYXCWKPanel.Create()
        end
    end
end

--当日畅玩卡礼包（Act_016_XYXCWKLBPanel）弹出的次数
function M.GetLbCurDayShowNum()
    local _last_time = PlayerPrefs.GetInt("CWKLB_CUR_DAY_SHOW_TIME" .. MainModel.UserInfo.user_id,0)
    local _cur_time = tonumber(os.date("%Y%m%d", os.time()))
    if _cur_time > _last_time then
        M.SetLbCurDayShowNum(0,true)
        PlayerPrefs.SetInt("CWKLB_CUR_DAY_SHOW_TIME" .. MainModel.UserInfo.user_id, _cur_time)
        _last_time = nil
        _cur_time = nil
    end
    return PlayerPrefs.GetInt("CWKLB_CUR_DAY_SHOW_NUM" .. MainModel.UserInfo.user_id, 0)
end

function M.SetLbCurDayShowNum(add_num,is_clear)
    if is_clear then
        PlayerPrefs.SetInt("CWKLB_CUR_DAY_SHOW_NUM" .. MainModel.UserInfo.user_id,0)
    else
        PlayerPrefs.SetInt("CWKLB_CUR_DAY_SHOW_NUM" .. MainModel.UserInfo.user_id, M.GetLbCurDayShowNum() + add_num)
    end
end

function M.IsAwardCanGet()
    local task_id = {}
    task_id[1] = M.day_task_id
	task_id[2] = M.GetTodayTask1()
    task_id[3] = M.GetTodayTask2()
    local func = function (id)
        if id then
            local data =  GameTaskModel.GetTaskDataByID(id)
            if data and data.award_status == 1 then
                return true
            end
        end
    end
    for k,v in pairs(task_id) do
        if func(v) then
            return true
        end
    end
    return false
end