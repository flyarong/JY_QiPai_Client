-- 创建时间:2020-04-07
-- Act_008LGFLManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_008LGFLManager = {}
local M = Act_008LGFLManager
M.key = "act_008_lgfl"
Act_008LGFLManager.config = GameButtonManager.ExtLoadLua(M.key,"activity_lgfl_config")
GameButtonManager.ExtLoadLua(M.key,"act_lgflPanel")
GameButtonManager.ExtLoadLua(M.key,"LGFLEnterPrefab")
GameButtonManager.ExtLoadLua(M.key,"act_008ItemBase")
local this
local lister
local task_ids = {}


-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time = 1587398399
    local s_time = 1586818800
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "actp_own_task_p_recharge_gift"
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
            return act_lgflPanel.Create(parm.parent,parm.backcall)
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.CheckIsShow() then
            return LGFLEnterPrefab.Create(parm.parent, parm.cfg)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end

-- 活动的提示状态
function M.GetHintState(parm)
	if parm and parm.gotoui == M.key then 
        if M.IsCanGetAward() then
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
    Event.Brocast("global_hint_state_change_msg",{gotoui = M.key})
end

function M.on_global_hint_state_set_msg(parm)
    if parm.gotoui == M.key then
        M.SetHintState()
    end
end

-- 更新活动的提示状态(针对那种 打开界面就需要修改状态的需求)
function M.SetHintState()
    --dump(task_ids,"<color=red>WWWWWWWWWWWWWWWWWWWWWWWWW</color>")
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

    --lister["model_query_one_task_data_response"] = this.on_model_query_one_task_data_response
    lister["model_task_change_msg"] = this.on_model_task_change_msg

    --lister["AssetsGetPanelConfirmCallback"]=this.on_buy_something--充值回调
end

function M.Init()
	M.Exit()

	this = Act_008LGFLManager
	this.m_data = {}
    this.ItemMap = {}
    
	MakeLister()
    AddLister()
	if M.CheckIsShow() then
        M.InitUIConfig()
    end
end

function M.Exit()
	if this then
		RemoveLister()
		this = nil
	end
end

function M.InitUIConfig()
    for i=1,#Act_008LGFLManager.config.Info do
        task_ids[i] = Act_008LGFLManager.config.Info[i].task_id
    end
end

function M.OnLoginResponse(result)
	if result == 0 then
        
    end
end

function M.OnReConnecteServerSucceed()
end


function M.GetTaskDataByID(id)
    if GameTaskModel.GetTaskDataByID(id) then
        return GameTaskModel.GetTaskDataByID(id)
    end
end

function M.on_model_task_change_msg(data)
    if data then
        for i=1,#task_ids do
            if task_ids[i] == data.id then
                M.InitItemMap()
                M.Refresh()
                if M.CheckIsShow() then
                    act_lgflPanel.Create()
                end   
                return
            end
        end
    end
end


function M.IsCareTask(task_id)
    for i=1,#task_ids do
        if task_id == task_ids[i] then 
            return true
        end 
    end
    return false
end


--[[function M.BuyShop(shopid)
    local price = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, shopid).price
    if  GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
        ServiceGzhPrefab.Create({desc="请前往公众号获取"})
    else
        PayTypePopPrefab.Create(shopid, "￥" .. (price / 100))
    end
end
--]]


function M.JudgeCanGetToChangeHint()
    for i=1,#task_ids do
        if M.GetTaskDataByID(task_ids[i]).now_process == 3 and M.GetTaskDataByID(task_ids[i]).award_status == 1 then
            return true
        end
    end
    return false
end

function M.InitItemMap()
    for i=1,#Act_008LGFLManager.config.Info do
        dump(Act_008LGFLManager.config.Info[i])
        M.ItemMap[i] = {}
        M.ItemMap[i][1]=Act_008LGFLManager.config.Info[i].ID--ID
        M.ItemMap[i][2]=Act_008LGFLManager.config.Info[i].task_recharge_Lv_text--任务充值档次text
        M.ItemMap[i][3]=Act_008LGFLManager.config.Info[i].task_award_text_img--奖励text的图片
        M.ItemMap[i][4]=Act_008LGFLManager.config.Info[i].task_award_image--图片名字
        M.ItemMap[i][5]=Act_008LGFLManager.GetTaskDataByID(Act_008LGFLManager.config.Info[i].task_id).now_process--当前进度
        M.ItemMap[i][6]=Act_008LGFLManager.GetTaskDataByID(Act_008LGFLManager.config.Info[i].task_id).award_status--奖励的领取状态
        M.ItemMap[i][7]=Act_008LGFLManager.config.Info[i].task_id--任务ID
    end
end


function M.IsCanGetAward()
    M.InitItemMap()

    for i=1,#M.ItemMap do
        if M.ItemMap[i][6] == 1 then           
            return true
        end
    end
    return false
end

