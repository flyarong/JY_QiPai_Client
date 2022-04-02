ext_require_audio("Game.game_DMBJ.Lua.audio_dmbj_config","dmbj")
local basefunc = require "Game/Common/basefunc"
package.loaded["Game.game_DMBJ.Lua.DMBJModel"] = nil
require "Game.game_DMBJ.Lua.DMBJModel"
package.loaded["Game.game_DMBJ.Lua.DMBJPrefabManager"] = nil
require "Game.game_DMBJ.Lua.DMBJPrefabManager"
package.loaded["Game.game_DMBJ.Lua.DMBJAnimManager"] = nil
require "Game.game_DMBJ.Lua.DMBJAnimManager"
package.loaded["Game.game_DMBJ.Lua.DMBJPrefab"] = nil
require "Game.game_DMBJ.Lua.DMBJPrefab"
package.loaded["Game.game_DMBJ.Lua.DMBJFindPrefab"] = nil
require "Game.game_DMBJ.Lua.DMBJFindPrefab"
package.loaded["Game.game_DMBJ.Lua.DMBJTXPrefab"] = nil
require "Game.game_DMBJ.Lua.DMBJTXPrefab"
package.loaded["Game.game_DMBJ.Lua.DMBJPanel"] = nil
require "Game.game_DMBJ.Lua.DMBJPanel"
package.loaded["Game.game_DMBJ.Lua.DMBJHintPanel"] = nil
require "Game.game_DMBJ.Lua.DMBJHintPanel"
package.loaded["Game.game_DMBJ.Lua.DMBJClearPanel"] = nil
require "Game.game_DMBJ.Lua.DMBJClearPanel"
package.loaded["Game.game_DMBJ.Lua.DMBJAutoTest"] = nil
require "Game.game_DMBJ.Lua.DMBJAutoTest"
package.loaded["Game.game_DMBJ.Lua.DMBJHelpPanel"] = nil
require "Game.game_DMBJ.Lua.DMBJHelpPanel"
package.loaded["Game.game_DMBJ.Lua.DMBJMiniGamePanel"] = nil
require "Game.game_DMBJ.Lua.DMBJMiniGamePanel"
package.loaded["Game.game_DMBJ.Lua.DMBJMiniHelpGamePanel"] = nil
require "Game.game_DMBJ.Lua.DMBJMiniHelpGamePanel"

DMBJLogic = {}
local M = DMBJLogic
local this
local panelNameMap = {
    hall = "hall",
    game = "DMBJPanel",
}
local cur_panel
local have_Jh
local jh_name = "dmbj_jh"
--自己关心的事件
local lister
local is_allow_forward = false
--view关心的事件
local viewLister = {}

local function MakeLister()
    lister = {}
    --需要切换panel的消息
    lister["model_dmbj_enter_game_response"] = M.dmbj_enter_game_response
    lister["model_dmbj_quit_game_response"] = M.dmbj_quit_game_response
    lister["model_dmbj_all_info"] = M.dmbj_all_info
    lister["model_dmbj_all_info_error"] = M.dmbj_all_info_error

    lister["ReConnecteServerSucceed"] = M.on_reconnect_msg
    lister["DisconnectServerConnect"] = M.on_network_error_msg

    lister["EnterForeGround"] = M.on_backgroundReturn_msg
    lister["EnterBackGround"] = M.on_background_msg
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
    if DMBJModel.AllInfoRight then
        M.dmbj_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        print("<color=red>ALL_INFO++++++++++</color>")
        DMBJModel.limitDealMsg = {dmbj_all_info_response = true}
        Network.SendRequest("dmbj_all_info",nil,"正在请求数据")
    end
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
    dump(debug.traceback(  ), "<color=red>移除监听</color>")
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function M.change_panel(panelName)
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
            MainLogic.ExitGame()
            --GameManager.GotoUI({gotoui = "game_MiniGame"})
            GameManager.GotoSceneName("game_MiniGame")
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = DMBJPanel.Create()}
        end
    end
end

function M.dmbj_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo()
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.dmbj_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.dmbj_all_info()
    --取消限制消息
    DMBJModel.limitDealMsg = nil
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if M.AllInfoRight == false then
        --大厅界面
        go_to = panelNameMap.hall
    else
        --游戏界面
        go_to = panelNameMap.game
    end
    if go_to then
        M.change_panel(go_to)
    end
    is_allow_forward = true
    --恢复监听
    ViewMsgRegister()
end

--消息错误，回到大厅
--断线重连相关**************
--状态错误处理
function M.eliminate_status_error_msg()
    --断开view model
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台重进入消息
function M.on_backgroundReturn_msg()
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台消息
function M.on_background_msg()
    cancelViewMsgRegister()
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
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    SendRequestAllInfo()
end

--断线重连相关**************
function M.Update()
    
end

--初始化
function M.Init(isNotSendAllInfo)
    --初始化model
    DMBJModel.Init()
    M.change_panel(panelNameMap.game)
    MakeLister()
    AddMsgListener(lister)
    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    -- 请求ALL数据
    if not isNotSendAllInfo then
        SendRequestAllInfo()
    end
end

function M.Exit()
    if cur_panel then
        cur_panel.instance:MyExit()
    end
    cur_panel = nil
    RemoveMsgListener(lister)
    clearAllViewMsgRegister()
    DMBJModel.Exit()
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("dmbj_quit_game", nil, "请求退出", function (data)
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
        end
    end)
end
return M
