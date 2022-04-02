ext_require_audio("Game.normal_zpg_common.Lua.audio_pgdz_config","pgdz")
-- 创建时间:2020-03-30

ZPGLogic = {}

ext_require("Game.game_ZPG.Lua.ZPGModel")
ext_require("Game.game_ZPG.Lua.ZPGGamePanel")
ext_require("Game.game_ZPG.Lua.ZPGPointerPrefab")
ext_require("Game.game_ZPG.Lua.ZPGBetItemPrefab")
ext_require("Game.game_ZPG.Lua.ZPGAnimManager")
ext_require("Game.game_ZPG.Lua.ZPGJinZhunTipsPrefab")
ext_require("Game.game_ZPG.Lua.ZPGHelpPanel")
ZPGLogic.panelNameMap = {
    hall = "hall",
    game = "game"
}

ZPGLogic.is_test = false

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
    lister["model_guess_apple_enter_room_response"] = this.on_guess_apple_enter_room_response
end

local function SendRequestAllInfo()
    if ZPGModel.data and ZPGModel.data.model_status == ZPGModel.Model_Status.gameover then
        ZPGLogic.on_fg_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        if not ZPGModel.data then
            ZPGModel.data = {}
        end
        ZPGModel.data.limitDealMsg = {guess_apple_all_info_response = true}
        if ZPGLogic.is_test then
            local test_history = {}
            for i = 1,50 do
                test_history[i] = math.random(1,3)
            end
            Event.Brocast("guess_apple_all_info_response","guess_apple_all_info_response",{status = "game",status_data = {status = "bet",time_out = 0},history_data = test_history, result = 0})
        else
            Network.SendRequest("guess_apple_all_info", nil, "请求数据")
        end
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

function ZPGLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function ZPGLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function ZPGLogic.change_panel(panelName, pram)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == ZPGLogic.panelNameMap.hall then
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
        if panelName == ZPGLogic.panelNameMap.hall then
            GameManager.GotoSceneName("game_MiniGame", ZPGModel.baseData.game_type)
        elseif panelName == ZPGLogic.panelNameMap.game then
            cur_panel = {name = panelName, instance = ZPGGamePanel.Create(pram)}
        end
    end
end

--游戏前台消息
function ZPGLogic.on_backgroundReturn_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台消息
function ZPGLogic.on_background_msg()
    ZPGModel.CloseUpdateTimer()
    cancelViewMsgRegister()
end
--游戏网络破损消息
function ZPGLogic.on_network_error_msg()
    cancelViewMsgRegister()
end
--游戏网络状态差
function ZPGLogic.on_network_poor_msg()
    print("<color=red>XXX 游戏网络状态差 XXX</color>")
end
--游戏重新连接消息
function ZPGLogic.on_reconnect_msg()
    SendRequestAllInfo()
end
function ZPGLogic.on_fg_status_error_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--断线重连相关**************
function ZPGLogic.quit_game(not_chang_hall)
end

--自动取消报名，在配桌长时间没有成功的时候服务器会主动踢出玩家
function ZPGLogic.on_fg_auto_cancel_signup_msg(result)
    ZPGLogic.change_panel(ZPGLogic.panelNameMap.hall)
end
--自动退出游戏
function ZPGLogic.on_fg_auto_quit_game_msg(result)
    ZPGLogic.change_panel(ZPGLogic.panelNameMap.hall)
end
-- 取消报名
function ZPGLogic.on_fg_cancel_signup_response(result)
    ZPGLogic.change_panel(ZPGLogic.panelNameMap.hall)
end
function ZPGLogic.on_fg_signup_response(result)
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
function ZPGLogic.on_fg_huanzhuo_response(result)
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--处理 请求收到所有数据消息
function ZPGLogic.on_fg_all_info()
    --取消限制消息
    ZPGModel.data.limitDealMsg = nil

    --根据状态数据创建相应的panel
    ZPGLogic.change_panel(ZPGLogic.panelNameMap.game)
    is_allow_forward = true
    --恢复监听
    ViewMsgRegister()
end
function ZPGLogic.on_guess_apple_enter_room_response()
    SendRequestAllInfo()
end
--初始化
function ZPGLogic.Init(pram)
    math.randomseed(tostring(os.time()):reverse():sub(1, 6))
    ExtendSoundManager.PlaySceneBGM(audio_config.pgdz.bgm_pipeichangbeijing.audio_name)
    this = ZPGLogic
    --初始化model
    local model = ZPGModel.Init()
    MakeLister()
    AddMsgListener(lister)
    for k,v in ipairs(ZPGModel.UIConfig.bet_item_limit_reconnect) do
        CachePrefabManager.InitCachePrefab("ZPGBetItemPrefab_" .. k,v)
    end
    SendRequestAllInfo()
    ZPGLogic.change_panel(ZPGLogic.panelNameMap.game, pram)
end

function ZPGLogic.Exit()
    if this then
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        for k,v in ipairs(ZPGModel.UIConfig.bet_item_limit_reconnect) do
            CachePrefabManager.DelCachePrefab("ZPGBetItemPrefab_" .. k)
        end
        soundMgr:CloseSound()
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        ZPGModel.Exit()
    end
end

function ZPGLogic.quit_game(call, quit_msg_call)
    print(debug.traceback())
    Network.SendRequest("guess_apple_quit_room", nil, "", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                ZPGLogic.change_panel(panelNameMap.hall)
            else
                call()
            end
        end
    end)    
end

return ZPGLogic