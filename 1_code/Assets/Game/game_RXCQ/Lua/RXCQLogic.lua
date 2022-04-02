-- 创建时间:2021-02-03
local cur_path = "Game.game_RXCQ.Lua."
ext_require_audio("Game.game_RXCQ.Lua.audio_rxcq_config","rxcq")
rxcq_prefab_list = ext_require(cur_path .. "rxcq_prefab_list")
rxcq_textrue2d_list = ext_require(cur_path .. "rxcq_textrue2d_list")
rxcq_main_config = ext_require(cur_path .. "rxcq_main_config")
ext_require(cur_path .. "RXCQGuaiWuPrefab")
ext_require(cur_path .. "RXCQLoadPanel")
ext_require(cur_path .. "RXCQGamePanel")
ext_require(cur_path .. "RXCQModel")
ext_require(cur_path .. "RXCQFightPrefab")
ext_require(cur_path .. "RXCQFightUIPrefab")
ext_require(cur_path .. "RXCQLotteryPrefab")
ext_require(cur_path .. "RXCQPrefabManager")
ext_require(cur_path .. "RXCQItem")
ext_require(cur_path .. "RXCQLotteryAnim")
ext_require(cur_path .. "RXCQHelpPanel")
ext_require(cur_path .. "RXCQPlayerAction")
ext_require(cur_path .. "RXCQPlayerPrefab")
ext_require(cur_path .. "RXCQWuQiPrefab")
ext_require(cur_path .. "RXCQMoneyItem")
ext_require(cur_path .. "RXCQHistoryPanel")
ext_require(cur_path .. "RXCQClearing")
ext_require(cur_path .. "RXCQSBTJManager")
ext_require(cur_path .. "RXCQNormalDie")
ext_require(cur_path .. "RXCQMiniGameDie")
ext_require(cur_path .. "RXCQShowMoneyItem")
ext_require(cur_path .. "RXCQGuaiWuManager")
ext_require(cur_path .. "RXCQTRHYManager")
ext_require(cur_path .. "RXCQXuanZhongOver")
ext_require(cur_path .. "RXCQJZSCManager")
ext_require(cur_path .. "RXCQJZSCPanel")
ext_require(cur_path .. "RXCQNpcPrefab")
ext_require(cur_path .. "RXCQJZSCChoosePanel")
ext_require(cur_path .. "RXCQJZSCManager2")
ext_require(cur_path .. "RXCQJZSCPanel2")

RXCQLogic = {}
local L = RXCQLogic
L.panelNameMap = {
    game = "game",
    hall = "hall"
}

local cur_panel

local this
--自己关心的事件
local lister
--view关心的事件
local viewLister = {}

local function MakeLister()
    lister = {}

    lister["model_status_no_error_msg"] = this.on_status_error_msg
    -- 网络
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["rxcq_quit_game_response"] = this.on_rxcq_quit_game_response
end

-- Logic
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
-- View 的消息处理相关方法
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
    Network.SendRequest("rxcq_all_info",nil,"正在请求数据")
end

--状态错误处理
function L.on_status_error_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台重进入消息
function L.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台消息
function L.on_background_msg()
    cancelViewMsgRegister()
end
--游戏重新连接消息
function L.on_reconnect_msg()
    SendRequestAllInfo()
end
--游戏网络破损消息
function L.on_network_error_msg()
    cancelViewMsgRegister()
end


function L.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function L.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

--初始化
function L.Init(parm)
    this = L
    dump(parm, "<color=red>RXCQLogic Init parm</color>")
    --初始化model
    local model = RXCQModel.Init()
    MakeLister()
    AddMsgListener(lister)

    MainLogic.EnterGame()

    SendRequestAllInfo()
    RXCQXuanZhongOver.Init()
    L.change_panel(L.panelNameMap.game)
end

function L.Exit()
    if this then
        print("<color=green>Exit  RXCQLogic</color>")
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        cur_panel = nil
        RXCQXuanZhongOver.Exit()
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        RXCQModel.Exit()
    end
end

function L.change_panel(panelName)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == L.panelNameMap.hall then
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
        if panelName == L.panelNameMap.hall then
            GameManager.GotoSceneName("game_MiniGame")
        elseif panelName == L.panelNameMap.game then
            cur_panel = {name = panelName, instance = RXCQGamePanel.Create()}
        end
    end
end

function L.quit_game(call, quit_msg_call)
    if L.IsLock then HintPanel.Create(1,"当前无法退出游戏哦~") return end
    Network.SendRequest("rxcq_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                L.change_panel(L.panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

function L.SetIsLock(IsLock)
    L.IsLock = IsLock
end

function L.on_rxcq_quit_game_response(_,data)
    if data.result == 0 then
        MainLogic.ExitGame()
        if not call then
            L.change_panel(L.panelNameMap.hall)
        else
            call()
        end
        Event.Brocast("quit_game_success")
    end
end

return RXCQLogic