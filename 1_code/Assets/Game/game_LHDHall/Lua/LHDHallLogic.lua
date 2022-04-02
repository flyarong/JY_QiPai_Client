ext_require_audio("Game.normal_lhd_common.Lua.audio_dld_config","dld")
-- 创建时间:2019-11-18

ext_require("Game.game_LHDHall.Lua.LHDHallModel")
ext_require("Game.game_LHDHall.Lua.LHDHallGamePanel")
ext_require("Game.game_LHDHall.Lua.LHDCCPrefab")
ext_require("Game.game_LHDHall.Lua.LHDHallDeskPanel")
ext_require("Game.game_LHDHall.Lua.LHDDeskPrefab")
ext_require("Game.game_LHDHall.Lua.LHDPagePrefab")
ext_require("Game.game_LHDHall.Lua.LHDPlayerInfoPrefab")
ext_require("Game.game_LHDHall.Lua.LHDHallGuidePanel")

ext_require("Game.normal_lhd_common.Lua.LHDCardPrefab")
ext_require("Game.normal_lhd_common.Lua.LHDHelpPanel")
ext_require("Game.normal_lhd_common.Lua.lhd_fun_lib")

LHDHallLogic = {}

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

function LHDHallLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function LHDHallLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

--游戏前台消息
function LHDHallLogic.on_backgroundReturn_msg()
    cancelViewMsgRegister()
end
--游戏后台消息
function LHDHallLogic.on_background_msg()
    cancelViewMsgRegister()
end

--初始化
function LHDHallLogic.Init(parm)
    ExtendSoundManager.PlaySceneBGM(audio_config.dld.bgm_pipeichangbeijing.audio_name)
    this = LHDHallLogic
    --初始化model
    local model = LHDHallModel.Init()
    MakeLister()
    AddMsgListener(lister)
    --MainLogic.EnterGame()
    cur_panel = LHDHallGamePanel.Create(parm)
end

function LHDHallLogic.Exit()
    if this then
        this = nil
        if cur_panel then
            cur_panel:MyExit()
            cur_panel = nil
        end
        soundMgr:CloseSound()
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        LHDHallModel.Exit()
    end
end

return LHDHallLogic
