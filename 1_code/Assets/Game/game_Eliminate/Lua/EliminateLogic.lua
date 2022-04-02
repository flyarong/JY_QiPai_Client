ext_require_audio("Game.game_Eliminate.Lua.audio_xxl_config","xxl")
EliminateLogic = {}
package.loaded["Game.game_Eliminate.Lua.eliminate_algorithm"] = nil
require "Game.game_Eliminate.Lua.eliminate_algorithm"
package.loaded["Game.game_Eliminate.Lua.EliminateModel"] = nil
require "Game.game_Eliminate.Lua.EliminateModel"
package.loaded["Game.game_Eliminate.Lua.EliminateGamePanel"] = nil
require "Game.game_Eliminate.Lua.EliminateGamePanel"
package.loaded["Game.game_Eliminate.Lua.EliminateObjManager"] = nil
require "Game.game_Eliminate.Lua.EliminateObjManager"
package.loaded["Game.game_Eliminate.Lua.EliminateAnimManager"] = nil
require "Game.game_Eliminate.Lua.EliminateAnimManager"
package.loaded["Game.game_Eliminate.Lua.EliminatePartManager"] = nil
require "Game.game_Eliminate.Lua.EliminatePartManager"

package.loaded["Game.game_Eliminate.Lua.EliminateDesPrefab"] = nil
require "Game.game_Eliminate.Lua.EliminateDesPrefab"
package.loaded["Game.game_Eliminate.Lua.EliminateMoneyPanel"] = nil
require "Game.game_Eliminate.Lua.EliminateMoneyPanel"
package.loaded["Game.game_Eliminate.Lua.EliminateHelpPanel"] = nil
require "Game.game_Eliminate.Lua.EliminateHelpPanel"
package.loaded["Game.game_Eliminate.Lua.EliminateButtonPrefab"] = nil
require "Game.game_Eliminate.Lua.EliminateButtonPrefab"
package.loaded["Game.game_Eliminate.Lua.EliminateClearPanel"] = nil
require "Game.game_Eliminate.Lua.EliminateClearPanel"
package.loaded["Game.game_Eliminate.Lua.EliminateInfoPanel"] = nil
require "Game.game_Eliminate.Lua.EliminateInfoPanel"


local M = EliminateLogic

local panelNameMap = {
    hall = "hall",
    game = "EliminateGamePanel",
}
local cur_panel

local updateDt = 1
local update
--自己关心的事件
local lister

local is_allow_forward = false
--view关心的事件
local viewLister = {}
local have_Jh
local jh_name = "eliminate_jh"
--构建正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --需要切换panel的消息
    lister["model_xxl_enter_game_response"] = M.xxl_enter_game_response
    lister["model_xxl_quit_game_response"] = M.xxl_quit_game_response
    lister["model_xxl_all_info"] = M.xxl_all_info
    lister["model_xxl_all_info_error"] = M.xxl_all_info_error

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
    if EliminateModel.data and EliminateModel.data.model_status == EliminateModel.Model_Status.gameover then
        M.xxl_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateModel.data.limitDealMsg = {xxl_all_info_response = true}
        print("<color=yellow>SendRequest</color>")
        local data = {}
        data.result = 0
        data.award_money = 1000
        data.award_rate = 100
        data.kaijiang_maps = "6666666624355566232646565434323623225556565564434244342263664244004642330006440500003003000020030000600000004000"
        data.lucky_maps = "22223333111111111111111"
        Network.SendRequest("xxl_all_info",nil,"正在请求数据")

        --测试代码消消乐
        -- Event.Brocast("xxl_all_info_response","xxl_all_info_response",data)
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
            cur_panel = {name = panelName, instance = EliminateGamePanel.Create()}
        end
    end
end

function M.xxl_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo()
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.xxl_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.xxl_all_info()
    --取消限制消息
    EliminateModel.data.limitDealMsg = nil
    dump(EliminateModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if EliminateModel.data.model_status == nil or EliminateModel.data.model_status == EliminateModel.Model_Status.gameover then
        --大厅界面
        go_to = panelNameMap.hall
    elseif EliminateModel.data.model_status == EliminateModel.Model_Status.gaming then
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
function M.xxl_all_info_error()
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
    EliminateGamePanel.ExitTimer()
    EliminateAnimManager.ExitTimer()
    EliminateObjManager.ExitTimer()
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
    EliminateGamePanel.ExitTimer()
    EliminateAnimManager.ExitTimer()
    EliminateObjManager.ExitTimer()
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
    local model = EliminateModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    EliminateObjManager.Init()
    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    M.change_panel(panelNameMap.game)
    --请求ALL数据
    if not isNotSendAllInfo then
        SendRequestAllInfo()
    end
end

function M.Exit()
    if update then
        update:Stop()
    end
    update = nil
    if cur_panel then
        cur_panel.instance:MyExit()
    end
    cur_panel = nil

    RemoveMsgListener(lister)
    clearAllViewMsgRegister()
    EliminateModel.Exit()
    EliminateObjManager.Exit()
    EliminateGamePanel.ExitTimer()
    EliminateAnimManager.ExitTimer()
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("xxl_quit_game", nil, "请求退出", function (data)
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
