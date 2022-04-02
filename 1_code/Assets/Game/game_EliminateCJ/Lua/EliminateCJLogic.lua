ext_require_audio("Game.game_EliminateCJ.Lua.audio_cjxxl_config","cjxxl")
EliminateCJLogic = {}
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJEnum"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJEnum"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJModel"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJModel"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJClearPanel"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJClearPanel"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJGamePanel"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJGamePanel"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJItemManager"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJItemManager"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJAnimManager"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJAnimManager"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJItem"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJItem"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJHelpPanel"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJHelpPanel"
package.loaded["Game.game_EliminateCJ.Lua.EliminateCJFreePanel"] = nil
require "Game.game_EliminateCJ.Lua.EliminateCJFreePanel"


local M = EliminateCJLogic

local panelNameMap = {
    hall = "hall",
    game = "EliminateCJGamePanel",
}
local cur_panel

local have_Jh
local jh_name = "eliminatecj_jh"
--自己关心的事件
local lister
local is_allow_forward = false
--view关心的事件
local viewLister = {}
--断线重连相关**************
local function MakeLister()
    lister = {}
    --需要切换panel的消息
    lister["model_cjxxl_enter_game_response"] = M.cjxxl_enter_game_response
    lister["model_cjxxl_quit_game_response"] = M.cjxxl_quit_game_response
    lister["model_cjxxl_all_info"] = M.cjxxl_all_info
    lister["model_cjxxl_all_info_error"] = M.cjxxl_all_info_error

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
    if M.AllInfoRight then
        M.cjxxl_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateCJModel.data.limitDealMsg = {lxxxl_all_info_response = true}
        Network.SendRequest("lxxxl_all_info",nil,"正在请求数据")
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
            cur_panel = {name = panelName, instance = EliminateCJGamePanel.Create()}
        end
    end
end

function M.cjxxl_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo()
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.cjxxl_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.cjxxl_all_info()
    --取消限制消息
    EliminateCJModel.data.limitDealMsg = nil
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
function M.cjxxl_all_info_error()
    M.change_panel(panelNameMap.hall)
end

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
    local model = EliminateCJModel.Init()
    M.change_panel(panelNameMap.game)
    MakeLister()
    AddMsgListener(lister)
    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    --请求ALL数据
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
    EliminateCJItemManager.StopShow()
    EliminateCJAnimManager.ClearAllTimer()
    EliminateCJAnimManager.ExitAnim()
    EliminateCJModel.Exit()
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("lxxxl_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
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

return M