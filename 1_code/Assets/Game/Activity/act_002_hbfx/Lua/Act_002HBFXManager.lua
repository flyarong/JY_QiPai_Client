-- 创建时间:2020-02-24
-- Act_002HBFXManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_002HBFXManager = {}
local M = Act_002HBFXManager
M.key = "act_002_hbfx"
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXHistoryPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXInvitePanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXLOSEPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXSUCCPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXTZListPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXWalletPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXGLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXTZZDTZCGPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_002HBFXTZZDTZCG2Panel")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "npca_challenge"
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
        dump(parm,"<color=red>外部创建------------------</color>")
        if M.IsActive() then
            if MainModel.UserInfo.xsyd_status == 1 and this.isCanMatch then 
                return Act_002HBFXInvitePanel.Create()
            end 
            if this.hadSon and M.getMainData() and M.getMainData().challenging_num > 0 then
                return Act_002HBFXTZListPanel.Create(parm.parent,parm.backcall) 
            else
                return Act_002HBFXPanel.Create(parm.parent,parm.backcall)
            end 
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_002HBFXEnterPrefab.Create(parm.parent)
        end
    elseif parm.goto_scene_parm == "banner" then 
        if M.IsActive() then
            return Act_002HBFXPanel.Create(parm.parent,parm.backcall)
        end 
    else
        dump(parm, "<color=red>找策划确认这个值要跳转到哪里</color>")
    end
end
-- 活动的提示状态
function M.GetHintState(parm)
    local data = M.getMainData()
    if data and #data.challenging_player_info >= 2 then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
    if data and data.can_box_award_num >= 1 then 
        return ACTIVITY_HINT_STATUS_ENUM.AT_Get
    end
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
    lister["EnterScene"] = this.OnEnterScene
    lister["OnLoginResponse"] = this.OnLoginResponse
    lister["withdraw_npca_hb_response"] = this.on_withdraw_npca_hb_response
    lister["newplayer_guide_finish"] = this.on_newplayer_guide_finish
    lister["hbfx_clear_uichange"] = this.on_hbfx_clear_uichange
    lister["get_npca_box_award_response"] = this.get_npca_box_award_response
    lister["ReConnecteServerSucceed"] = this.OnReConnecteServerSucceed
    lister["npca_slave_get_award_msg"] = this.npca_slave_get_award_msg 
    lister["global_hint_state_set_msg"] = this.on_global_hint_state_set_msg
    lister["query_npca_main_data_response"] = this.on_query_npca_main_data_response
    lister["query_npca_slave_data_list_response"] = this.on_query_npca_slave_data_list_response
    lister["query_npca_wallet_data_response"] = this.on_query_npca_wallet_data_response
    lister["query_npca_slave_challenge_state_response"] = this.on_query_npca_slave_challenge_state_response
end

function M.Init()
	M.Exit()

	this = Act_002HBFXManager
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
    if result ~= 0 or not M.IsActive() then return end
    -- 数据初始化
    Network.SendRequest("query_npca_slave_challenge_state")
    Network.SendRequest("query_npca_slave_data_list")
    Network.SendRequest("query_npca_main_data")
end

function M.OnReConnecteServerSucceed()
end

--活动主数据
function M.on_query_npca_main_data_response(_,data)
    dump(data,"<color=red>活动主数据</color>")
    this.mainData = data  
    if #data.box_player_info > 1 then 
        this.hadSon = true
    end
    Event.Brocast("global_hint_state_set_msg",{gotoui = M.key })
    Event.Brocast("model_query_npca_main_data_got")
end
--下线组队对战的情况
function M.on_query_npca_slave_data_list_response(_,data)
    dump(data,"<color=red>下线组队对战的情况</color>")
    if data and data.result == 0 then
        this.mySonData = data
        Event.Brocast("global_hint_state_set_msg",{gotoui = M.key })
    end
end
--请求我的钱包
function M.on_query_npca_wallet_data_response(_,data)
    dump(data,"<color=red>请求我的钱包</color>")
    if data.result == 0 then 
        this.walletData = data
    end
    Event.Brocast("global_hint_state_set_msg",{gotoui = M.key })
    Event.Brocast("model_query_npca_wallet_data_got")
end
--玩家请求自己是否可以作为下线进行挑战
function M.on_query_npca_slave_challenge_state_response(_,data)
    dump(data,"<color=red>玩家请求自己是否可以作为下线进行挑战</color>")
    if data.result == 0 then 
        this.isCanMatch = true
        this.master_info = data.master_info
        Event.Brocast("global_hint_state_set_msg",{gotoui = M.key })
    end
end

function M.on_hbfx_clear_uichange(parm)
    dump(parm,"<color=red>福卡分享 结算-------------</color>")
    if parm and parm.panelSelf and DdzFreeModel and DdzFreeModel.baseData.game_id == 101 and MainModel.myLocation == "game_DdzFree" then 
        parm.panelSelf.gameName_txt.gameObject.transform.parent.gameObject:SetActive(false)
        parm.panelSelf.ready_btn.onClick:RemoveAllListeners()
        parm.panelSelf.ready_btn.onClick:AddListener(
            function ()
                parm.panelSelf:OnBackClick()
            end
        )
        if parm.panelSelf.isWin  then
            Act_002HBFXSUCCPanel.Create(parm.panelSelf)
        else
            Act_002HBFXLOSEPanel.Create(parm.panelSelf)
        end
    end
end


function M.getMainData()
    return this.mainData 
end

function M.getWalletData()
    return this.walletData 
end

function M.goMatch()
    GameManager.CommonGotoScence({gotoui=GameConfigToSceneCfg.game_DdzFree.SceneName, p_requset={id = 101}}, function ()
        GameFreeModel.SetCurrGameID(101)
    end)
end 

function M.get_npca_box_award_response(_,data)
    if data and data.result == 0 then 
        Network.SendRequest("query_npca_main_data")
    end
end
--获取玩家上级信息
function M.getMasterInfo()
    return this.master_info
end

--新手引导完成
function M.on_newplayer_guide_finish()
    dump("<color=red>新手引导完成</color>")
    if this.isCanMatch then 
        Act_002HBFXInvitePanel.Create()
        this.isCanMatch = false
    end
end

function M.GetmySonData()
    return this.mySonData
end

function M.npca_slave_get_award_msg(_,data)
    dump(data,"<color=red>福卡领奖推送</color>")
    this.show_data = data
    this.isShow1Got = true
end

function M.OnEnterScene()
    if MainModel.myLocation == "game_Hall" then 
        if this.isShow1Got then 
            Act_002HBFXTZZDTZCGPanel.Create(this.show_data)
            this.isShow1Got = false
        end 
    end 
end

function M.on_withdraw_npca_hb_response(_,data)
    if data then 
        if data.result == 0 then 
        
        else
            HintPanel.Create(1,"提现失败")
        end
    end
end