-- 创建时间:2020-02-24
-- Act_020HBFXManager 管理器

local basefunc = require "Game/Common/basefunc"
Act_020HBFXManager = {}
local M = Act_020HBFXManager
M.key = "act_020_hbfx"
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXHistoryPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXInvitePanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXLOSEPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXSUCCPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXTZListPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXWalletPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXEnterPrefab")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXGLPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXTZZDTZCGPanel")
GameButtonManager.ExtLoadLua(M.key, "Act_020HBFXTZZDTZCG2Panel")
local this
local lister

-- 是否有活动
function M.IsActive()
    -- 活动的开始与结束时间
    local e_time --= 1632153599
    local s_time
    if (e_time and os.time() > e_time) or (s_time and os.time() < s_time) then
        return false
    end

    -- 对应权限的key
    local _permission_key = "npca_challenge"
    if _permission_key then
        local a,b = GameButtonManager.RunFun({gotoui="sys_qx", _permission_key=_permission_key, is_on_hint = true}, "CheckCondition")
        dump({a,b},"<color=green>48元红包权限</color>")
        if a and not b then
            return false
        end
        return true and M.GetRemianTime() > 0
    else
        return true and M.GetRemianTime() > 0
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
    if M.GetRemianTime() <= 0 then
        return
    end
    if parm.goto_scene_parm == "panel" then
        dump(parm,"<color=red>外部创建------------------</color>")
        if M.IsActive() then
            if MainModel.UserInfo.xsyd_status == 1 and this.isCanMatch then
                return Act_020HBFXInvitePanel.Create()
            end 
            if this.hadSon and M.getMainData() and M.getMainData().challenging_num > 0 then
                return Act_020HBFXTZListPanel.Create(parm.parent,parm.backcall) 
            else
                return Act_020HBFXPanel.Create(parm.parent,parm.backcall)
            end 
        end 
    elseif parm.goto_scene_parm == "enter" then
        if M.IsActive() then
            return Act_020HBFXEnterPrefab.Create(parm.parent)
        end
    elseif parm.goto_scene_parm == "banner" then 
        if M.IsActive() then
            return Act_020HBFXPanel.Create(parm.parent,parm.backcall)
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

	this = Act_020HBFXManager
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
    if data.result == 0 then
        this.mainData = data  
        if data and data.box_player_info and next(data.box_player_info) and #data.box_player_info > 1 then 
            this.hadSon = true
        end
        Event.Brocast("global_hint_state_set_msg",{gotoui = M.key })
        Event.Brocast("model_query_npca_main_data_got")
    end
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
    else
        this.isCanMatch = false
    end
end

function M.on_hbfx_clear_uichange(parm)
    dump(parm,"<color=red>福卡分享 结算-------------</color>")
    if parm and parm.panelSelf and DdzFreeModel and DdzFreeModel.baseData.game_id == 101 and MainModel.myLocation == "game_DdzFree" then 
        parm.panelSelf.gameName_txt.gameObject.transform.parent.gameObject:SetActive(false)
        parm.panelSelf.changedesk_btn.gameObject.transform.parent.gameObject:SetActive(false)
        parm.panelSelf.ready_btn.onClick:RemoveAllListeners()
        parm.panelSelf.ready_btn.onClick:AddListener(
            function ()
                parm.panelSelf:OnBackClick()
            end
        )
        parm.panelSelf.changedesk_btn.onClick:RemoveAllListeners()
        parm.panelSelf.changedesk_btn.onClick:AddListener(
            function ()
                parm.panelSelf:OnBackClick()
            end
        )
        if parm.panelSelf.isWin  then
            Act_020HBFXSUCCPanel.Create(parm.panelSelf)
        else
            Act_020HBFXLOSEPanel.Create(parm.panelSelf)
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
    local game_id = 101
    local check
    check = function ()
        local ss = GameFreeModel.IsRoomEnter(game_id)
        if ss == 1 then
            LittleTips.Create("当前鲸币不足")
            if GameGlobalOnOff.Shop_10_gift_bag ~= nil and GameGlobalOnOff.Shop_10_gift_bag == false then
                local dd = GameFreeModel.GetGameIDToConfig(game_id)
                PayFastFreePanel.Create(dd, check)
            else
                M.BuyCoin(game_id, check)
            end
            return
        end
        if ss == 2 then
            LittleTips.Create("当前鲸币太多")
            return
        end
        GameManager.CommonGotoScence({gotoui=GameConfigToSceneCfg.game_DdzFree.SceneName, p_requset={id = game_id}}, function ()
            GameFreeModel.SetCurrGameID(game_id)
        end)
    end
    check()
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
    if this.isCanMatch and M.GetRemianTime() > 0 then 
        Act_020HBFXInvitePanel.Create()
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
            Act_020HBFXTZZDTZCGPanel.Create(this.show_data)
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

function M.GetRemianTime()
    if true then return 1 end
    return MainModel.FirstLoginTime() + 7 * 86400 - os.time()
end

function M.IsShowInExXSYD()
    return M.IsActive() and this.isCanMatch and M.GetRemianTime() > 0 and MainModel.myLocation == "game_Hall"
end

function M.BuyCoin(game_id, check)
	local dd = GameFreeModel.GetGameIDToConfig(game_id)
	if dd.order == 1 then
		OneYuanGift.Create(nil, function ()
			PayFastFreePanel.Create(dd, check)
		end)
	else
		PayFastFreePanel.Create(dd, check)
	end
end

function M.Share()
    local share_cfg
    local p = gameMgr:getMarketPlatform()
    if p == "wqp" then
        share_cfg = basefunc.deepcopy(share_link_config.img_yql48_wqp)
    else
        share_cfg = basefunc.deepcopy(share_link_config.img_yql48)
    end
    GameManager.GotoUI({gotoui = "sys_fx",goto_scene_parm = "panel",share_cfg = share_cfg})
end