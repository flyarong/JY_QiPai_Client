EliminateBSLogic = {}
ext_require_audio("Game.game_EliminateBS.Lua.audio_bsmz_config","bsmz")
ext_require("Game.game_EliminateBS.Lua.eliminate_bs_algorithm")
ext_require("Game.game_EliminateBS.Lua.EliminateBSModel")
ext_require("Game.game_EliminateBS.Lua.EliminateBSGamePanel")
ext_require("Game.game_EliminateBS.Lua.EliminateBSHJGamePanel")
ext_require("Game.game_EliminateBS.Lua.EliminateBSObjManager")
ext_require("Game.game_EliminateBS.Lua.EliminateBSAnimManager")
ext_require("Game.game_EliminateBS.Lua.EliminateBSPartManager")

ext_require("Game.game_EliminateBS.Lua.EliminateBSDesPrefab")
ext_require("Game.game_EliminateBS.Lua.EliminateBSMoneyPanel")
ext_require("Game.game_EliminateBS.Lua.EliminateBSHelpPanel")
ext_require("Game.game_EliminateBS.Lua.EliminateBSButtonPrefab")
ext_require("Game.game_EliminateBS.Lua.EliminateBSClearPanel")
ext_require("Game.game_EliminateBS.Lua.EliminateBSInfoPanel")
ext_require("Game.game_EliminateBS.Lua.EliminateBSHJMoneyPanel")


local M = EliminateBSLogic
local panelNameMap = {
    hall = "hall",
    game = "EliminateBSGamePanel",
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
    lister["model_xxl_baoshi_enter_game_response"] = M.xxl_baoshi_enter_game_response
    lister["model_xxl_baoshi_quit_game_response"] = M.xxl_baoshi_quit_game_response
    lister["model_xxl_baoshi_all_info"] = M.xxl_baoshi_all_info
    lister["model_xxl_baoshi_all_info_error"] = M.xxl_baoshi_all_info_error

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
    Event.Brocast("logic_xxl_baoshi_all_info")

    if EliminateBSModel.data and EliminateBSModel.data.model_status == EliminateBSModel.Model_Status.gameover then
        M.xxl_baoshi_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateBSModel.data.limitDealMsg = {xxl_baoshi_all_info_response = true}
        if M.is_test then
            local data = {result = 0,state = {}}--M.GetTestData("nor")
            Event.Brocast("xxl_baoshi_all_info_response","xxl_baoshi_all_info_response",data)
        else
            Network.SendRequest("xxl_baoshi_all_info",nil,"正在请求数据")
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
    dump(panelName, "<color=yellow>change_panel</color>")
    dump(cur_panel,"<color=yellow><size=15>++++++++++cur_panel++++++++++</size></color>")
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
            GameManager.GotoSceneName("game_MiniGame")
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = EliminateBSGamePanel.Create()}
        end
    end
end

function M.xxl_baoshi_enter_game_response(data)
    dump(data,"<color=yellow><size=15>++++++++111++data++++++++++</size></color>")
    if data.result == 0 then
        SendRequestAllInfo("enter_game")
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.xxl_baoshi_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.xxl_baoshi_all_info()
    --取消限制消息
    EliminateBSModel.data.limitDealMsg = nil
    dump(EliminateBSModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if EliminateBSModel.data.model_status == nil or EliminateBSModel.data.model_status == EliminateBSModel.Model_Status.gameover then
        --大厅界面
        go_to = panelNameMap.hall
    elseif EliminateBSModel.data.model_status == EliminateBSModel.Model_Status.gaming then
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
function M.xxl_baoshi_all_info_error()
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
    EliminateBSGamePanel.ExitTimer()
end
--游戏后台重进入消息
function M.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    if EliminateBSModel.data.state ~= EliminateBSModel.xc_state.bshj then
        if not have_Jh then
            have_Jh = jh_name
            FullSceneJH.Create("正在请求数据", have_Jh)
        end
        SendRequestAllInfo("backgroundReturn")
    end
end
--游戏后台消息
function M.on_background_msg()
    cancelViewMsgRegister()
    EliminateBSGamePanel.ExitTimer()
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
    local model = EliminateBSModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    EliminateBSObjManager.Init()
    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    M.change_panel(panelNameMap.game)
    --请求ALL数据
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
    EliminateBSModel.Exit()
end

M.is_test = false
function M.GetTestData(type)
    local data = {}
    
    data1 = {
      all_rate=5500,
      free_game_rate=4500,
      xc_data="55333333313333663333236344435556345353533355235514536352243366522562362145443243443354224345342053153420255315102153414022615130243451301232153013521340144213101135651011336540303166406033355020332520303655602060156030604300101034001040360010600000004000000030000000400000",
      is_local = true,
      result = 0,
      state = "nor",
    }
    data2 = {
      result = 0,
      xc_data="72347123451234572347",
      state = "bshj",
      is_local = true
    }
    if type == "nor" then
        data = data1
    elseif type == "bshj" then
        data = data2
    end

    EliminateBSModel.data.state = data.state
    if data.state == "nor" then
        EliminateBSModel.size.max_x = 8
        EliminateBSModel.size.max_y = 8
        EliminateBSModel.size.size_x = 105
        EliminateBSModel.size.size_y = 105
        EliminateBSModel.size.spac_x = 0
        EliminateBSModel.size.spac_y = 1
    end
    return data
end

function M.quit_game(call, quit_msg_call)
    if EliminateBSModel.data.status_lottery ~= EliminateBSModel.status_lottery.wait then
        LittleTips.Create("您当前正在游戏,请结束本局后再退出~")
        return
    end
    Network.SendRequest("xxl_baoshi_quit_game", nil, "请求退出", function (data)
        dump(data,"<color=yellow><size=15>++++++++++退出宝石迷阵++++++++++</size></color>")
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
