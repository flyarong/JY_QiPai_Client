EliminateFXLogic = {}
ext_require_audio("Game.game_EliminateFX.Lua.audio_fxgz_config","fxgz")
package.loaded["Game.game_EliminateFX.Lua.eliminate_fx_algorithm"] = nil
require "Game.game_EliminateFX.Lua.eliminate_fx_algorithm"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXModel"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXModel"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXGamePanel"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXGamePanel"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXObjManager"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXObjManager"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXAnimManager"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXAnimManager"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXPartManager"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXPartManager"

package.loaded["Game.game_EliminateFX.Lua.EliminateFXDesPrefab"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXDesPrefab"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXMoneyPanel"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXMoneyPanel"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXHelpPanel"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXHelpPanel"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXButtonPrefab"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXButtonPrefab"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXClearPanel"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXClearPanel"
package.loaded["Game.game_EliminateFX.Lua.EliminateFXInfoPanel"] = nil
require "Game.game_EliminateFX.Lua.EliminateFXInfoPanel"

local M = EliminateFXLogic
local panelNameMap = {
    hall = "hall",
    game = "EliminateFXGamePanel",
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
    lister["model_xxl_fuxing_enter_game_response"] = M.xxl_fuxing_enter_game_response
    lister["model_xxl_fuxing_quit_game_response"] = M.xxl_fuxing_quit_game_response
    lister["model_xxl_fuxing_all_info"] = M.xxl_fuxing_all_info
    lister["model_xxl_fuxing_all_info_error"] = M.xxl_fuxing_all_info_error

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

local function SendRequestAllInfo(data)
    if EliminateFXModel.data and EliminateFXModel.data.model_status == EliminateFXModel.Model_Status.gameover then
        M.xxl_fuxing_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateFXModel.data.limitDealMsg = {xxl_fuxing_all_info_response = true}
        if M.is_test then
            local data = {result = 0}--M.GetTestData("nor")
            Event.Brocast("xxl_fuxing_all_info_response","xxl_fuxing_all_info_response",data)
        else
            Network.SendRequest("xxl_fuxing_all_info",nil,"正在请求数据")
        end
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
    dump(debug.traceback())
    dump(panelName, "<color=yellow>change_panel</color>")
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end

    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh(true)
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
            GameManager.GotoUI({gotoui = "game_MiniGame"})
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = EliminateFXGamePanel.Create()}
        end
    end
end

function M.xxl_fuxing_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo("enter_game")
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.xxl_fuxing_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.xxl_fuxing_all_info()
    --取消限制消息
    EliminateFXModel.data.limitDealMsg = nil
    dump(EliminateFXModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if EliminateFXModel.data.model_status == nil or EliminateFXModel.data.model_status == EliminateFXModel.Model_Status.gameover then
        --大厅界面
        go_to = panelNameMap.hall
    elseif EliminateFXModel.data.model_status == EliminateFXModel.Model_Status.gaming then
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
function M.xxl_fuxing_all_info_error()
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
    SendRequestAllInfo("status_error")
    EliminateFXGamePanel.ExitTimer()
end
--游戏后台重进入消息
function M.on_backgroundReturn_msg()
    if not have_Jh then
        have_Jh = jh_name
        FullSceneJH.Create("正在请求数据", have_Jh)
    end
    cancelViewMsgRegister()
    SendRequestAllInfo("backgroundReturn")
end
--游戏后台消息
function M.on_background_msg()
    cancelViewMsgRegister()
    EliminateFXGamePanel.ExitTimer()
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
    SendRequestAllInfo("reconnect")
end

--断线重连相关**************
function M.Update()
    
end

--初始化
function M.Init(isNotSendAllInfo)
    --初始化model
    local model = EliminateFXModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    EliminateFXObjManager.Init()
    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    M.change_panel(panelNameMap.game)
    --进入场景请求AllInfo数据
    if not isNotSendAllInfo then
        SendRequestAllInfo("Init")
    end
end

function M.Exit()
    update:Stop()
    update = nil
    if cur_panel then
        cur_panel.instance:MyExit()
    end
    cur_panel = nil

    RemoveMsgListener(lister)
    clearAllViewMsgRegister()
    EliminateFXModel.Exit()
end

M.is_test = false
--测试用的数据
function M.GetTestData(type)
    dataNor = {
        xc_data="111111177777777813288812345678",
        result = 0,
        state = "nor",
        all_rate = 10,
        all_money = 100,
    }
    dataBigGame = {
        result = 0,
        xc_data = "6654155622522624116625551233111536441242664312222563164224521124000055330000355400003564000031010000360000005200000040000000100000004000",
        state = "big_game",
        all_rate = 10,
        all_money = 100,
    }
    all_data = {
        result = 0,
        main_status = {
            has_little = 1,
            bets = {100,100,100,100,100},
            award = 500,
            rate = 1,
        },
        main_xc_data = {
            xc_data = "111111177777777123288812345678",
            xc_data_little = "1234554321777771213288812345678111111177777777813288812345678111111177777777813288812345678",
        },
    }
    local data = {}
    if type == "nor" then
        data = dataNor
    elseif type == "big_game" then
        data = dataBigGame
    end 
    return all_data
end

function M.quit_game(call, quit_msg_call)
    --test

    if M.is_test then
        if quit_msg_call then
            quit_msg_call(0)
        end
        MainLogic.ExitGame()
        if not call then
            M.change_panel(panelNameMap.hall)
        else
            DOTweenManager.KillAllStopTween()
            call()
        end
        return
    end

    if EliminateFXModel.data.status_lottery ~= EliminateFXModel.status_lottery.wait then
        LittleTips.Create("您当前正在游戏,请结束本局后再退出~")
        return
    end
    Network.SendRequest("xxl_fuxing_quit_game", nil, "请求退出", function (data)
        dump(data,"<color=yellow><size=15>++++++++++退出福星高照++++++++++</size></color>")
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                M.change_panel(panelNameMap.hall)
            else
                DOTweenManager.KillAllStopTween()
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return M
