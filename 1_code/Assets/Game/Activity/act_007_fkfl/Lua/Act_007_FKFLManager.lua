-- 创建时间:2020-04-07
-- Act_007_FKFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_007_FKFLManager = {}
local M = Act_007_FKFLManager
M.key = "act_007_fkfl"
M.now_level = 0
M.config = GameButtonManager.ExtLoadLua(M.key, "activity_007_fkfl_config")
GameButtonManager.ExtLoadLua(M.key, "Act_007_FKFLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_007_FKFLChoosePanel")
GameButtonManager.ExtLoadLua(M.key, "Act_007FKFLEnterPrefab")
local this
--只是看买没买的任务数据
M.only_buy_task = {
    21701,
    21702,
    21703,
}
local lister
local permisstions = {
    "actp_own_task_p_fkfl_nsj_nor",
    "actp_own_task_p_fkfl_nsj_v1",
    "actp_own_task_p_fkfl_nsj_v4",
    "actp_own_task_p_fkfl_nsj_v8",
}
-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1643039999
    local s_time = 1641857400
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    dump(M.GetNowPerMiss(),"<color=red>疯狂返利权限</color>")
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
        if M.IsActive() then 
            return Act_007_FKFLPanel.Create(parm.parent, parm.backcall)
        end 
    end 
    if parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            if parm.goto_scene_parm == "enter" and MainModel.myLocation == "game_Eliminate" and MainModel.UserInfo.ui_config_id == 2 then
                return
            end
            return Act_007FKFLEnterPrefab.Create(parm.parent)
        end
    end 
    dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
end
-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsAwardCanGet()   then
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
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
    Event.Brocast("global_hint_state_change_msg",{gotoui = "act_059_dwjj_jrlb"})
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
    lister["EnterScene"] = this.OnEnterScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["model_task_change_msg"] = this.model_task_change_msg
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
end

function M.Init()
	M.Exit()

	this = Act_007_FKFLManager
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
    for i = 1,#permisstions do 
        if cheak_fun(permisstions[i]) then
            dump(permisstions[i],"符合条件的权限")
            M.now_level = i
            --特殊处理
            if M.now_level >= 3 then
                M.only_buy_task = {
                    21703,
                    21702,
                    21701,
                }
            end
            return i
        end
    end
end

function M.GetShopConfig()
    local get_shop_info = function (shop_id)
        for i = 1,#M.config.shop_config do 
            if M.config.shop_config[i].shop_id == shop_id then 
                return M.config.shop_config[i]
            end
        end
    end
    if M.now_level ~= 0 then 
        local base = M.config["base_"..M.now_level]
        local shop_data = {}
        for i = 1,#base do
            shop_data[i] = get_shop_info(base[i].shop_id)
        end
        return shop_data
    end 
end

function M.GetTaskConfig( )
    if M.now_level ~= 0 then 
        local task_data = {}
        local base = M.config["base_"..M.now_level]
        for i = 1,#base do 
            task_data[i] = M.config["task_"..base[i].task_id.."_config"]
        end
        return task_data
    end
end

function M.BuyShop(shopid)
	local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
	if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
		ServiceGzhPrefab.Create({desc="请前往公众号获取"})
	else
		PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
	end
end

function M.SetOhterData(task_id,str_index)
    local str = {
        "sh_xxl","sg_xxl","xy_xxl","cs_xxl","bs_xxl","fx_xxl"
    }
    Network.SendRequest("force_set_task_data_for_little_game",{task_id = task_id,little_game_str = str[str_index]})
end

--检查是不是任务没有设置
function M.CheakIsNotSetTask()
    if M.now_level ~= 0 then 
        for i = 1,#M.only_buy_task do 
            local buy_data = GameTaskModel.GetTaskDataByID(M.only_buy_task[i])
            local task_data = GameTaskModel.GetTaskDataByID(M.config["base_"..M.now_level][i].task_id)
            if buy_data then
                if buy_data.now_total_process >= 1 and task_data.other_data_str == nil then 
                    return i
                end
            end
        end
    end
end

function M.OnEnterScene()
    do return end
    if MainModel.myLocation == "game_Hall" then 
        if M.CheakIsNotSetTask() then 
            Act_007_FKFLChoosePanel.Create()
        end 
    end
    if MainModel.myLocation == "game_Eliminate" or 
        MainModel.myLocation == "game_EliminateSH" or
        MainModel.myLocation == "game_EliminateCS" or
        MainModel.myLocation == "game_EliminateXY" or
        MainModel.myLocation == "game_EliminateCJ" 
        then      
        local enter_times = PlayerPrefs.GetInt(M.key..os.date("%Y%d%m",os.time())..MainModel.UserInfo.user_id,0)
        if M.IsActive() and enter_times < 3 and not M.IsBuyAnyShop() then 
            Act_007_FKFLPanel.Create()
            PlayerPrefs.SetInt(M.key..os.date("%Y%d%m",os.time())..MainModel.UserInfo.user_id,enter_times + 1)
        end 
    end
end

function M.model_task_change_msg()
    M.SetHintState()
end

function M.IsAwardCanGet()
    if M.now_level == 0 then
        M.GetNowPerMiss()
    end
    if M.now_level ~= 0 then 
        for i = 1,3 do 
            local task_data = GameTaskModel.GetTaskDataByID(M.config["base_"..M.now_level][i].task_id)
            if task_data and task_data.award_status == 1 then 
                return true
            end
        end
    end 
end
--至少买了一个
function M.IsBuyAnyShop()
    for i = 1,3 do 
        local buy_data = GameTaskModel.GetTaskDataByID(M.only_buy_task[i])
        if buy_data.now_total_process >= 1 then 
            return i
        end
    end
end

function M.CheckIsBuyDataChange(task_id)
    for k,v in pairs(M.only_buy_task) do
        if task_id == v then
            return true
        end
    end
    return false
end