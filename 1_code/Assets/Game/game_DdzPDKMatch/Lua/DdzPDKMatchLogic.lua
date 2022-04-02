ext_require_audio("Game.normal_ddz_common.Lua.audio_ddz_config","ddz")
package.loaded["Game.game_DdzMatch.Lua.DdzPDKMatchModel"] = nil
require "Game.game_DdzMatch.Lua.DdzPDKMatchModel"

package.loaded["Game.game_DdzMatch.Lua.DdzPDKMatchMyCardUiManger"] = nil
require "Game.game_DdzMatch.Lua.DdzPDKMatchMyCardUiManger"

package.loaded["Game.game_DdzMatch.Lua.DdzPDKMatchPlayersActionManger"] = nil
require "Game.game_DdzMatch.Lua.DdzPDKMatchPlayersActionManger"

package.loaded["Game.game_DdzMatch.Lua.DdzPDKMatchActionUiManger"] = nil
require "Game.game_DdzMatch.Lua.DdzPDKMatchActionUiManger"

package.loaded["Game.game_DdzMatch.Lua.DdzPDKMatchGamePanel"] = nil
require "Game.game_DdzMatch.Lua.DdzPDKMatchGamePanel"

package.loaded["Game.normal_ddz_common.Lua.DdzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzDzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzDzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzCardTag"] = nil
require "Game.normal_ddz_common.Lua.DdzCardTag"

package.loaded["Game.normal_ddz_common.Lua.DDZAnimation"] = nil
require "Game.normal_ddz_common.Lua.DDZAnimation"

package.loaded["Game.normal_ddz_common.Lua.DDZParticleManager"] = nil
require "Game.normal_ddz_common.Lua.DDZParticleManager"

package.loaded["Game.normal_ddz_common.Lua.DdzHelpPanel"] = nil
require "Game.normal_ddz_common.Lua.DdzHelpPanel"

package.loaded["Game.normal_ddz_common.Lua.PDKDdzCardTag"] = nil
require "Game.normal_ddz_common.Lua.PDKDdzCardTag"

package.loaded["Game.normal_commatch_common.Lua.ComMatchLogic"] = nil
require "Game.normal_commatch_common.Lua.ComMatchLogic"

DdzPDKMatchLogic = {}

--当前位置
--[[
	大厅
	--
	等待开始
	--
	等待桌子
	--
	比赛

{name  ,instance}
]]
local panelNameMap = {
    hall = "hall",
    wait = "wait",
    wait_rematch = "wait_rematch",
    game = "game",
    rank = "rank"
}
local cur_loc
local cur_panel
local delayShowRank

local this
local updateDt = 1
local update
--请求报名人数间隔
local req_sign_num_inval = 3
local req_sign_num_count = 0
--自己关心的事件
local lister

local is_allow_forward = false
--view关心的事件
local viewLister = {}
local have_Jh
local jh_name = "ddz_pdk_match_jh"
--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --需要切换panel的消息
    lister["model_nor_mg_begin_msg"] = this.on_nor_mg_begin_msg
    lister["model_nor_mg_gameover_msg"] = this.on_nor_mg_gameover_msg
    lister["model_nor_mg_auto_cancel_signup_msg"] = this.on_nor_mg_auto_cancel_signup_msg
    lister["model_nor_mg_match_discard_msg"] = this.on_nor_mg_match_discard_msg

    --response
    lister["model_nor_mg_signup_response"] = this.on_nor_mg_signup_response
    lister["model_nor_mg_cancel_signup_response"] = this.on_nor_mg_cancel_signup_response

    lister["model_nor_mg_statusNo_error_msg"] = this.on_nor_mg_status_error_msg
    lister["model_nor_pdk_nor_status_info"] = this.on_nor_mg_status_info
    lister["model_nor_mg_all_info"] = this.on_nor_mg_all_info

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
end

local function AddMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name, func in pairs(lister) do
        Event.RemoveListener(proto_name, func)
    end
end

local function ViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] and is_allow_forward then
            AddMsgListener(viewLister[registerName])
        end
    else
        if viewLister and is_allow_forward then
            for k, lister in pairs(viewLister) do
                AddMsgListener(lister)
            end
        end
    end
end
local function cancelViewMsgRegister(registerName)
    if registerName then
        if viewLister and viewLister[registerName] then
            RemoveMsgListener(viewLister[registerName])
        end
    else
        if viewLister then
            for k, lister in pairs(viewLister) do
                RemoveMsgListener(lister)
            end
        end
    end
    DOTweenManager.KillAllStopTween()
end

local function clearAllViewMsgRegister()
    cancelViewMsgRegister()
    viewLister = {}
end

local function SendRequestAllInfo()
    if DdzPDKMatchModel.data and DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.gameover then
        DdzPDKMatchLogic.on_nor_mg_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        DdzPDKMatchModel.data.limitDealMsg = {nor_mg_all_info = true}
        Network.SendRequest("nor_mg_req_info_by_send", {type = "all"})
    end
end

function DdzPDKMatchLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end
function DdzPDKMatchLogic.clearViewMsgRegister(registerName)
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function DdzPDKMatchLogic.change_panel(panelName,enterSceneCall)
    dump(panelName, "<color=yellow>change_panel</color>")
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end

    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyExit()
            cur_panel = nil
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    if not cur_panel then
        if panelName == panelNameMap.hall then
            --游戏结束回到大厅
            print("<color=yellow>游戏结束回到大厅</color>", DdzPDKMatchModel.game_type)
            local hall_type = MatchModel.GetCurHallType()
            GameManager.GotoSceneName(GameConfigToSceneCfg.game_MatchHall.SceneName,hall_type)
        elseif panelName == panelNameMap.wait then
            cur_panel = {name = panelName, instance = ComMatchWaitStartPanel.Create({model = DdzPDKMatchModel,logic = DdzPDKMatchLogic,ani = DDZAnimation})}
        elseif panelName == panelNameMap.wait_rematch then
            cur_panel = {name = panelName, instance = ComMatchWaitRematchPanel.Create({model = DdzPDKMatchModel,logic = DdzPDKMatchLogic,ani = DDZAnimation})}
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = DdzPDKMatchGamePanel.Create()}
        elseif panelName == panelNameMap.rank then
            local parm = {}
            parm.game_name = DdzPDKMatchModel.data.name
            parm.game_id = DdzPDKMatchModel.data.game_id
            parm.fianlResult = DdzPDKMatchModel.data.nor_mg_final_result
            cur_panel = {name = panelName, instance = ComMatchRankPanel.Create(parm, function (game_id)
                DdzPDKMatchModel.ClearMatchData(game_id)
            end)}
        end
    end
    --cur_panel=MatchPanel.Show(load_callback)
end

function DdzPDKMatchLogic.on_nor_mg_signup_response(data)
    if data.result == 0 then
        SendRequestAllInfo()
    else
        DdzPDKMatchLogic.change_panel(panelNameMap.hall,function (  )
            local msg = errorCode[data.result] or ("错误："..data.result)
            LittleTips.Create(msg)
        end)
    end
end
function DdzPDKMatchLogic.on_nor_mg_cancel_signup_response(result)
    DdzPDKMatchLogic.change_panel(panelNameMap.hall)
end

function DdzPDKMatchLogic.on_nor_mg_auto_cancel_signup_msg(result)
    DdzPDKMatchLogic.change_panel(panelNameMap.hall)
end

function DdzPDKMatchLogic.on_nor_mg_match_discard_msg(data)
    local cur_config = MatchModel.GetGameCfg()
    local str = string.format( "参加 %s 的人数不足，比赛已取消",cur_config.game_name)
    HintPanel.Create(1,str,function()
        DdzPDKMatchLogic.change_panel(panelNameMap.hall)
    end)
end

--自动取消报名，在配桌长时间没有成功的时候服务器会主动踢出玩家
function DdzPDKMatchLogic.on_mjfg_auto_cancel_signup_msg(result)
    DdzPDKMatchLogic.change_panel(panelNameMap.hall)
end

function DdzPDKMatchLogic.on_nor_mg_begin_msg()
    --切换到 游戏界面
    DdzPDKMatchLogic.change_panel(panelNameMap.game)
end

function DdzPDKMatchLogic.on_nor_mg_gameover_msg()
    --切换到 大结算界面
    local gameCfg = MatchModel.GetGameCfg(MatchModel.data.game_id)
    if gameCfg.round and #gameCfg.round > 0 and DdzPDKMatchModel.data.round_info and DdzPDKMatchModel.GetCurRoundId() < #gameCfg.round then
        DdzPDKMatchLogic.DelayShowRankPanel()
    else
        DdzPDKMatchLogic.change_panel(panelNameMap.rank)
    end
end

function DdzPDKMatchLogic.DelayShowRankPanel()
    if DdzPDKMatchLogic.delayShowRank then
        DdzPDKMatchLogic.delayShowRank:Stop()
        DdzPDKMatchLogic.delayShowRank = nil
    end
    local delay = 4
    if not (DdzPDKMatchLogic.data.model_status == DdzPDKMatchLogic.Model_Status.gameover and DdzPDKMatchLogic.data.rank ~= 1) then
        delay = 2
    end
    DdzPDKMatchLogic.delayShowRank = Timer.New(function()
        DdzPDKMatchLogic.ShowRankPanel()
    end, delay, 1, false)
    DdzPDKMatchLogic.delayShowRank:Start()
end

function DdzPDKMatchLogic.ShowRankPanel()
    DdzPDKMatchLogic.change_panel(panelNameMap.rank)
end

--处理 请求收到所有数据消息
function DdzPDKMatchLogic.on_nor_mg_all_info()
    dump(DdzPDKMatchModel.data, "<color=purple>DdzPDKMatchLogic.on_nor_mg_all_info:</color>")
    --取消限制消息
    DdzPDKMatchModel.data.limitDealMsg = nil
    local go_to
    --根据状态数据创建相应的panel
    if DdzPDKMatchModel.data.model_status == nil then
        --大厅界面
        go_to = panelNameMap.hall
    elseif DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.wait_begin then
        --等待开始界面
        if MatchModel.CheckStartTypeIsRMJK() then
            go_to = panelNameMap.wait
        else
            go_to = panelNameMap.wait_rematch
        end
    elseif DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.gameover then
        --大结算界面
        go_to = panelNameMap.rank
    elseif
        DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.gaming or
            DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.promoted or
            DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.wait_result or
            DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.wait_table or 
            DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.wait_revive
     then
        --游戏界面
        go_to = panelNameMap.game
    end
    
    if go_to then
        DdzPDKMatchLogic.change_panel(go_to)
    end
    is_allow_forward = true
    --恢复监听
    ViewMsgRegister()
end
--处理状态数据
function DdzPDKMatchLogic.on_nor_mg_status_info()
    --if  如果数据已经齐全 then
    --根据状态数据创建相应的panel
    --else
    --请求除状态数据以外的所有数据
end

--断线重连相关**************
--状态错误处理
function DdzPDKMatchLogic.on_nor_mg_status_error_msg()
    --断开view model
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台重进入消息
function DdzPDKMatchLogic.on_backgroundReturn_msg()
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台消息
function DdzPDKMatchLogic.on_background_msg()
    cancelViewMsgRegister()
end
--游戏网络破损消息
function DdzPDKMatchLogic.on_network_error_msg()
    cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function DdzPDKMatchLogic.on_network_repair_msg()
end
--游戏网络状态差
function DdzPDKMatchLogic.on_network_poor_msg()
end
--游戏重新连接消息
function DdzPDKMatchLogic.on_reconnect_msg()
    --请求ALL数据
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    SendRequestAllInfo()
end
--断线重连相关**************

function DdzPDKMatchLogic.Update()
    if DdzPDKMatchModel.data and DdzPDKMatchModel.data.model_status == DdzPDKMatchModel.Model_Status.wait_begin then
        req_sign_num_count = req_sign_num_count + updateDt
        if req_sign_num_count >= req_sign_num_inval then
            req_sign_num_count = 0
            Network.SendRequest("nor_mg_req_cur_signup_num")
        end
    end
end
--初始化
function DdzPDKMatchLogic.Init(isNotSendAllInfo)
    this = DdzPDKMatchLogic
    --初始化model
    local model = DdzPDKMatchModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(DdzPDKMatchLogic.Update, updateDt, -1, nil, true)
    update:Start()

    SysInteractiveChatManager.InitLogic(model)
    SysInteractiveAniManager.InitLogic(model)

    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    --请求ALL数据
    if not isNotSendAllInfo then
        SendRequestAllInfo()
    end

    if MatchModel.CheckStartTypeIsRMJK() then
        DdzPDKMatchLogic.change_panel(panelNameMap.wait)
    else
        DdzPDKMatchLogic.change_panel(panelNameMap.wait_rematch)
    end
    MainModel.CacheShop()
end
function DdzPDKMatchLogic.Exit()
    SysInteractiveChatManager.ExitLogic()
    SysInteractiveAniManager.ExitLogic()

    this = nil
    update:Stop()
    update = nil
    if cur_panel then
        cur_panel.instance:MyExit()
    end
    cur_panel = nil

    RemoveMsgListener(lister)
    clearAllViewMsgRegister()
    DdzPDKMatchModel.Exit()

    if DdzPDKMatchLogic.delayShowRank then
        DdzPDKMatchLogic.delayShowRank:Stop()
        DdzPDKMatchLogic.delayShowRank = nil
    end
end

function DdzPDKMatchLogic.quit_game(call, quit_msg_call)
    print(debug.traceback())
    Network.SendRequest("nor_mg_quit_game", nil, "", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                DdzPDKMatchLogic.change_panel(panelNameMap.hall)
            else
                call()
            end
        end
    end)    
end

return DdzPDKMatchLogic
