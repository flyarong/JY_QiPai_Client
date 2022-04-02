-- 创建时间:2020-08-26
local cur_path = "Game.game_LWZB.Lua."
ext_require_audio("Game.normal_lwzb_common.Lua.audio_lwzb_config","lwzb")
ext_require(cur_path .. "LWZBAnimManager")
ext_require(cur_path .. "LWZBModel")
ext_require(cur_path .. "LWZBGamePanel")
ext_require(cur_path .. "LWZBPointerPrefab")
ext_require(cur_path .. "LWZBSSPrefab")
ext_require(cur_path .. "LWZBHeadPrefab")
ext_require(cur_path .. "LWZBGunPrefab")
ext_require(cur_path .. "LWZBSnatchPanel")
ext_require(cur_path .. "LWZBSnatchItemBase")
ext_require(cur_path .. "LWZBLWPrefab")
ext_require(cur_path .. "LWZBCardTypePanel")
ext_require(cur_path .. "LWZBCardTypeItemBase")
ext_require(cur_path .. "LWZBCountDownPrefab_bet")
ext_require(cur_path .. "LWZBJLItemBase")
ext_require(cur_path .. "LWZBJLPanel")
ext_require(cur_path .. "LWZBCSDJEnterPrefab")
ext_require(cur_path .. "LWZBCSDJPanel")
ext_require(cur_path .. "LWZBCSDJTJPanel")
ext_require(cur_path .. "LWZBCSKJPanel")
ext_require(cur_path .. "LWZBCSDJHeadItemPanel")
ext_require(cur_path .. "LWZBCountDownPrefab_game")
ext_require(cur_path .. "LWZBLoadingPanel")
ext_require(cur_path .. "LWZBSettlePanel")
ext_require(cur_path .. "LWZBAnimCreator")

ext_require("Game.game_LWZBHall.Lua.LWZBHelpPanel")

LWZBLogic = {}
local L = LWZBLogic
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

    lister["model_lwzb_enter_room_response"] = this.on_model_lwzb_enter_room_response
    lister["model_lwzb_quit_room_response"] = this.on_model_lwzb_quit_room_response
    lister["send_lwzb_quit_game_msg"] = this.send_lwzb_quit_game_msg
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
    Network.SendRequest("lwzb_all_info", {type = "all"})
end

local function SendAllInfoLi(tt)
    dump(tt, "<color=red>lwzb SendAllInfoLi </color>")
    Network.SendRequest("lwzb_all_info", {type = "all"}, "", function (data)
        dump(data,"<color=green>777777777777777777</color>")
        if data.result ~= 0 then
            L.change_panel(L.panelNameMap.hall)
        elseif data.result == 0 then
            Event.Brocast("lwzb_all_info_response","lwzb_all_info_response",data)
        end
    end)
end

--状态错误处理
function L.on_status_error_msg()
    cancelViewMsgRegister()
    SendRequestAllInfo()
end
--游戏后台重进入消息
function L.on_backgroundReturn_msg()
    --[[cancelViewMsgRegister()
    SendRequestAllInfo()--]]
    if LWZBManager.GetLwzbGuideOnOff() then
        GameManager.GotoSceneName("game_MiniGame")
    else
        SendAllInfoLi()
    end
end
--游戏后台消息
function L.on_background_msg()
    cancelViewMsgRegister()
end
--游戏重新连接消息
function L.on_reconnect_msg()
    --SendRequestAllInfo()
    SendAllInfoLi()
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
    ExtendSoundManager.PlaySceneBGM(audio_config.lwzb.bgm_lwzb_beijing.audio_name)
    this = L
    dump(parm, "<color=red>LWZBLogic Init parm</color>")
    --初始化model
    if parm then
        LWZBManager.SetCurGame_id(parm.game_id)
    else
        LWZBManager.SetCurGame_id(MainModel.game_id)
    end
    local model = LWZBModel.Init()
    
    MakeLister()
    AddMsgListener(lister)

    MainLogic.EnterGame()
    --dump(LWZBManager.GetLwzbGuideOnOff(),"<color>++++++++++++++init+++++++++++++++++</color>")
    if LWZBManager.GetLwzbGuideOnOff() then
        LWZBManager.SetCurGame_id(1)
    else
        SendRequestAllInfo()
    end
    
    L.change_panel(L.panelNameMap.game)
end

function L.Exit()
    if this then
        print("<color=green>Exit  LWZBLogic</color>")
        soundMgr:CloseSound()
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        MainLogic.ExitGame()
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        LWZBModel.Exit()
    end
end

function L.change_panel(panelName,parm)
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
            MainLogic.ExitGame()
            if not table_is_null(parm) then
                GameManager.GotoSceneName("game_LWZBHall",parm.parm,parm.call,parm.enterSceneCall)
            else
                GameManager.GotoSceneName("game_LWZBHall")
            end
        elseif panelName == L.panelNameMap.game then
            cur_panel = {name = panelName, instance = LWZBGamePanel.Create()}
        end
    end
end

function L.quit_game(call, quit_msg_call)
    Network.SendRequest("lwzb_quit_room", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            DOTweenManager.KillAllStopTween()
            if not call then
                L.change_panel(L.panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end


function L.on_model_lwzb_enter_room_response()
    SendRequestAllInfo()
end

function L.on_model_lwzb_quit_room_response()
    L.change_panel(L.panelNameMap.hall)
end

function L.send_lwzb_quit_game_msg()
    MainLogic.ExitGame()
    Network.SendRequest("lwzb_quit_room", nil, "") 
end



return LWZBLogic

