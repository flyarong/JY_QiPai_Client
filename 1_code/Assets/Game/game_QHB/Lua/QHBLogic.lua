ext_require_audio("Game.normal_qhb_common.Lua.audio_qhb_config","qhb")
package.loaded["Game.game_QHB.Lua.QHBModel"] = nil
require "Game.game_QHB.Lua.QHBModel"
package.loaded["Game.game_QHB.Lua.QHBGamePanel"] = nil
require "Game.game_QHB.Lua.QHBGamePanel"
package.loaded["Game.game_QHB.Lua.QHBSendPanel"] = nil
require "Game.game_QHB.Lua.QHBSendPanel"
package.loaded["Game.game_QHB.Lua.QHBGetPanel"] = nil
require "Game.game_QHB.Lua.QHBGetPanel"
package.loaded["Game.game_QHB.Lua.QHBDetailPanel"] = nil
require "Game.game_QHB.Lua.QHBDetailPanel"
package.loaded["Game.game_QHB.Lua.QHBHistoryPanel"] = nil
require "Game.game_QHB.Lua.QHBHistoryPanel"
package.loaded["Game.game_QHB.Lua.QHBHBManager"] = nil
require "Game.game_QHB.Lua.QHBHBManager"
package.loaded["Game.game_QHB.Lua.QHBAwardPanel"] = nil
require "Game.game_QHB.Lua.QHBAwardPanel"
package.loaded["Game.normal_qhb_common.Lua.QHBHelpPanel"] = nil
require "Game.normal_qhb_common.Lua.QHBHelpPanel"

QHBLogic = {}
local M = QHBLogic

--当前位置
M.panelNameMap = {
    hall = "QHBHallPanel",
    game = "QHBGamePanel"
}

local cur_panel
local this
local updateDt = 1
-- Logic 的 Update
local update
--自己关心的事件
local lister

local is_allow_forward = false
--view关心的事件
local viewLister = {}
local have_Jh
local jh_name = "qhb_game"
--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --response
    lister["model_qhb_quit_game_response"] = this.on_qhb_quit_game_response
    lister["model_qhb_all_info_response"] = this.on_qhb_all_info_response
    lister["model_qhb_force_quit_game_msg"] = this.on_qhb_force_quit_game_msg

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
end

local function SendRequestAllInfo()
    --限制处理消息  此时只处理指定的消息
    QHBModel.data.limitDealMsg = {qhb_all_info_response = true}
    QHBModel.request_qhb_all_info()
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

function M.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function M.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function M.refresh_panel()
    if cur_panel then
        cur_panel.instance:MyRefresh()
    end
end

function M.change_panel(panelName)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == M.panelNameMap.hall then
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
        if panelName == M.panelNameMap.hall then
            GameManager.GotoSceneName("game_QHBHall")
        elseif panelName == M.panelNameMap.game then
            cur_panel = {name = panelName, instance = QHBGamePanel.Create()}
        end
    end
end

function M.on_qhb_quit_game_response(result)
    if result == 0 then
        M.change_panel(M.panelNameMap.hall)
    end
end

function M.on_qhb_force_quit_game_msg()
    M.change_panel(M.panelNameMap.hall)
end

--处理 请求收到所有数据消息
function M.on_qhb_all_info_response(data)
    if data.result ~= 0 then
        if data.result == 1008 or data.result == 1031 then
            --请求限制重新请求数据
            HintPanel.ErrorMsg(data.result,function(  )
                QHBModel.request_qhb_all_info()
            end,nil,"HintPanelSP")
        else
            HintPanel.ErrorMsg(data.result,nil,nil,"HintPanelSP")
            M.change_panel(M.panelNameMap.hall)
        end
        return
    end
    --取消限制消息
    QHBModel.data.limitDealMsg = nil
    M.change_panel(M.panelNameMap.game)
    is_allow_forward = true
    --恢复监听
    ViewMsgRegister()
    --请求红包数据
    QHBModel.init_qhb_hb_info()
    QHBModel.request_qhb_hb_info_last()
end

--断线重连相关**************
--游戏后台重进入消息
function M.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end

--游戏后台消息
function M.on_background_msg()
    cancelViewMsgRegister()
    QHBModel.SaveData()
end

--游戏网络破损消息
function M.on_network_error_msg()
    cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function M.on_network_repair_msg()
end
--游戏网络状态差
function M.on_network_poor_msg()
end
--游戏重新连接消息
function M.on_reconnect_msg()
    --请求ALL数据
    SendRequestAllInfo()
end
--断线重连相关**************
function M.Update()
end

--初始化
function M.Init()
    this = M
    QHBModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1)
    update:Start()
    MainLogic.EnterGame()
    QHBHBManager.Init()
    have_Jh = jh_name
    M.change_panel(M.panelNameMap.game)
    SendRequestAllInfo()
end

function M.Exit()
    if this then
        update:Stop()
        update = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        QHBModel.Exit()
        QHBHBManager.Exit()
        this = nil
    end
end

function M.get_cur_panel()
    if cur_panel then
        return cur_panel.instance
    end
    return nil
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("qhb_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                M.change_panel(M.panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return M
