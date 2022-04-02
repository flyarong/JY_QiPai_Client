ext_require_audio("Game.normal_lhd_common.Lua.audio_dld_config","dld")
-- 创建时间:2019-11-18

ext_require("Game.game_LHD.Lua.LHDModel")
ext_require("Game.game_LHD.Lua.LHDGamePanel")
ext_require("Game.game_LHD.Lua.LHDPlayer")
ext_require("Game.game_LHD.Lua.LHDGameCenterPrefab")
ext_require("Game.game_LHD.Lua.LHDGameOperPrefab")
ext_require("Game.game_LHD.Lua.LHDAnimation")
ext_require("Game.game_LHD.Lua.LHDClearingPanel")
ext_require("Game.game_LHD.Lua.LHDEggPrefab")
ext_require("Game.game_LHD.Lua.LHDClockPrefab")
ext_require("Game.game_LHD.Lua.LHDCombatPrefab")
ext_require("Game.game_LHD.Lua.LHDWaitPanel")
ext_require("Game.game_LHD.Lua.LHDBQPanel")
ext_require("Game.game_LHD.Lua.LHDGuidePanel")
ext_require("Game.game_LHD.Lua.LHDPlayerClockPrefab")

ext_require("Game.normal_lhd_common.Lua.LHDCardPrefab")
ext_require("Game.normal_lhd_common.Lua.LHDHelpPanel")
ext_require("Game.normal_lhd_common.Lua.lhd_fun_lib")

LHDLogic = {}

LHDLogic.panelNameMap = {
    hall = "hall",
    game = "game"
}

local cur_panel

local this
--自己关心的事件
local lister

local is_allow_forward = false
--view关心的事件
local viewLister = {}

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg

    lister["model_fg_signup_response"] = this.on_fg_signup_response
    lister["model_fg_huanzhuo_response"] = this.on_fg_huanzhuo_response

    lister["model_fg_all_info"] = this.on_fg_all_info
    lister["model_fg_statusNo_error_msg"] = this.on_fg_status_error_msg
    lister["model_fg_auto_cancel_signup_msg"] = this.on_fg_auto_cancel_signup_msg
    lister["model_fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg
    lister["model_fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
end

local function SendRequestAllInfo()
    if LHDModel.data and LHDModel.data.model_status == LHDModel.Model_Status.gameover then
        LHDLogic.on_fg_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        LHDModel.data.limitDealMsg = {fg_lhd_all_info = true}
        Network.SendRequest("fg_lhd_req_info_by_send", {type = "all"}, "请求")
    end
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

function LHDLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function LHDLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function LHDLogic.change_panel(panelName, pram)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == LHDLogic.panelNameMap.hall then
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
        if panelName == LHDLogic.panelNameMap.hall then
          GameManager.GotoSceneName("game_LHDHall",LHDModel.baseData.game_type)
           -- GameManager.GotoUI({gotoui = "game_LHDHall",goto_scene_parm = LHDModel.baseData.game_type})
        elseif panelName == LHDLogic.panelNameMap.game then
            cur_panel = {name = panelName, instance = LHDGamePanel.Create(pram)}
        end
    end
end

--游戏前台消息
function LHDLogic.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台消息
function LHDLogic.on_background_msg()
    cancelViewMsgRegister()
end
--游戏网络破损消息
function LHDLogic.on_network_error_msg()
    cancelViewMsgRegister()
end
--游戏网络状态差
function LHDLogic.on_network_poor_msg()
    print("<color=red>XXX 游戏网络状态差 XXX</color>")
end
--游戏重新连接消息
function LHDLogic.on_reconnect_msg()
    SendRequestAllInfo()
end
function LHDLogic.on_fg_status_error_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--断线重连相关**************
function LHDLogic.quit_game(not_chang_hall)
end

--自动取消报名，在配桌长时间没有成功的时候服务器会主动踢出玩家
function LHDLogic.on_fg_auto_cancel_signup_msg(result)
    LHDLogic.change_panel(LHDLogic.panelNameMap.hall)
end
--自动退出游戏
function LHDLogic.on_fg_auto_quit_game_msg(result)
    LHDLogic.change_panel(LHDLogic.panelNameMap.hall)
end
-- 取消报名
function LHDLogic.on_fg_cancel_signup_response(result)
    LHDLogic.change_panel(LHDLogic.panelNameMap.hall)
end
function LHDLogic.on_fg_signup_response(result)
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
function LHDLogic.on_fg_huanzhuo_response(result)
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--处理 请求收到所有数据消息
function LHDLogic.on_fg_all_info()
    --取消限制消息
    LHDModel.data.limitDealMsg = nil

    --根据状态数据创建相应的panel
    if not LHDModel.data.model_status then
        LHDLogic.change_panel(LHDLogic.panelNameMap.hall)
        return
    end

    LHDLogic.change_panel(LHDLogic.panelNameMap.game)
    is_allow_forward = true
    --恢复监听
    ViewMsgRegister()
end

--初始化
function LHDLogic.Init(isNotSendAllInfo)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    ExtendSoundManager.PlaySceneBGM(audio_config.dld.bgm_pipeichangbeijing.audio_name)
    this = LHDLogic
    --初始化model
    local model = LHDModel.Init()
    MakeLister()
    AddMsgListener(lister)
    MainLogic.EnterGame()
    CachePrefabManager.InitCachePrefab("ComFlyGlodPrefab", 100, true)
    
    if not isNotSendAllInfo then
        SendRequestAllInfo()
    end

    LHDLogic.change_panel(LHDLogic.panelNameMap.game, pram)
end

function LHDLogic.Exit()
    if this then
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        soundMgr:CloseSound()
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        LHDModel.Exit()
    end
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("fg_lhd_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            DOTweenManager.KillAllStopTween()
            if not call then
                M.change_panel(panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return LHDLogic
