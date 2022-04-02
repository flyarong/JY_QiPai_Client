ext_require_audio("Game.normal_fishing_common.Lua.audio_by_config","by")
-- 创建时间:2019-03-06

ext_require ("Game.game_FishingMatch.Lua.FishingMatchModel")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchGamePanel")
ext_require ("Game.normal_fishing_common.Lua.FishingLoadingPanel")
ext_require ("Game.normal_fishing_common.Lua.FishingUninstallPanel")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchWaitPanel")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchOverPanel")

ext_require ("Game.game_FishingMatch.Lua.FishingMatchNorSKillPrefab")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchOperPrefab")

ext_require ("Game.normal_fishing_common.Lua.Vehicle")
ext_require ("Game.normal_fishing_common.Lua.BKManager")
ext_require ("Game.normal_fishing_common.Lua.FishManager")
ext_require ("Game.normal_fishing_common.Lua.BulletManager")
ext_require ("Game.normal_fishing_common.Lua.BulletPrefab")
ext_require ("Game.normal_fishing_common.Lua.FishExtManager")
ext_require ("Game.normal_fishing_common.Lua.FishBase")
ext_require ("Game.normal_fishing_common.Lua.Fish")
ext_require ("Game.normal_fishing_common.Lua.FishNetPrefab")
ext_require ("Game.normal_fishing_common.Lua.FishTeam")
ext_require ("Game.normal_fishing_common.Lua.FishBK")
ext_require ("Game.normal_fishing_common.Lua.FishTreasureBox")
ext_require ("Game.normal_fishing_common.Lua.VehicleManager")
ext_require ("Game.normal_fishing_common.Lua.FishingActivityManager")
ext_require ("Game.normal_fishing_common.Lua.FishingAnimManager")
ext_require ("Game.normal_fishing_common.Lua.FishingBagPanel")
ext_require ("Game.normal_fishing_common.Lua.FishingBagItem")
ext_require ("Game.normal_fishing_common.Lua.FishingSkillManager")

ext_require ("Game.game_FishingMatch.Lua.FishingMatchBuffManager")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchKJBagPanel")
ext_require ("Game.game_FishingMatch.Lua.FishingKJBagPrefab")

ext_require ("Game.game_FishingMatch.Lua.FishingMatchPlayer")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchGun")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchPlayerAss")
ext_require ("Game.game_FishingMatch.Lua.FishingMatchGunAss")
ext_require ("Game.game_FishingMatch.Lua.FishMatchDeadManager")

ext_require ("Game.game_FishingMatch.Lua.FishingMatchExtPrefab")
ext_require ("Game.game_FishingMatch.Lua.HintUnlockPanel")

ext_require ("Game.normal_fishing_common.Lua.FishingMatchComRankPanel")
ext_require "Game.normal_fishing_common.Lua.FishingMatchAwardPanel"
ext_require "Game.normal_fishing_common.Lua.FishingMatchOldRankPanel"
ext_require "Game.normal_fishing_common.Lua.FishingMatchRankPanel"
ext_require "Game.normal_fishing_common.Lua.FishingBKPanel"
ext_require "Game.normal_fishing_common.Lua.BulletPrefabZT"

ext_require "Game.game_FishingMatch.Lua.HintFMPanel"
ext_require "Game.game_FishingMatch.Lua.PopUpFMRevive"

ext_require ("Game.game_FishingMatch.Lua.GameSmallHintPanel")
ext_require ("Game.game_FishingMatch.Lua.GameSmallHintPrefab")


FishingMatchLogic = {}
-- 别名
FishingLogic = FishingMatchLogic

FishingMatchLogic.panelNameMap = {
    hall = "hall",
    game = "game",
    wait = "wait",
    over = "over",
}

local cur_panel

local this
--自己关心的事件
local lister

local is_allow_forward = false
--view关心的事件
local viewLister = {}
local have_Jh
local jh_name = "ddz_free_game"

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg

    lister["model_fsmg_all_info_test"] = this.on_fsmg_all_info
    lister["model_change_panel"] = this.on_model_change_panel
end

local function SendRequestAllInfo()
    if FishingMatchModel.data and FishingMatchModel.data.model_status == FishingMatchModel.Model_Status.gameover then
        FishingMatchLogic.on_fsmg_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        FishingMatchModel.data.limitDealMsg = {fsmg_all_info_test_response = true}
        FishingMatchModel.SendAllInfo()
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

function FishingMatchLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function FishingMatchLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function FishingMatchLogic.refresh_panel()
    if cur_panel then
        cur_panel.instance:MyRefresh()
    end
end
function FishingMatchLogic.GetPanel()
    return cur_panel.instance
end

function FishingMatchLogic.change_panel(panelName, parm)
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == FishingMatchLogic.panelNameMap.hall then
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyExit()
            cur_panel = nil
        else
            DOTweenManager.KillAllStopTween()
            cur_panel.instance:MyClose()
            cur_panel = nil
        end
    end
    print("<color=red>EEE panelName = " .. panelName .. "</color>")
    if not cur_panel then
        if panelName == FishingMatchLogic.panelNameMap.hall then
            GameManager.GotoSceneName("game_FishingHall")
        elseif panelName == FishingMatchLogic.panelNameMap.game then
            cur_panel = {name = panelName, instance = FishingMatchGamePanel.Create(parm)}
        elseif panelName == FishingMatchLogic.panelNameMap.wait then
            cur_panel = {name = panelName, instance = FishingMatchWaitPanel.Create()}
        elseif panelName == FishingMatchLogic.panelNameMap.over then
            cur_panel = {name = panelName, instance = FishingMatchComRankPanel.Create(parm, function (game_id)
                FishingMatchModel.ClearMatchData(game_id)
            end)}
        end
    end
end

function FishingMatchLogic.on_fsmg_all_info(parm)
    if not FishingMatchModel.data or not FishingMatchModel.data.model_status then
        FishingMatchLogic.change_panel(FishingMatchLogic.panelNameMap.hall, parm)
    else
        local model_status = FishingMatchModel.data.model_status
        if model_status == FishingMatchModel.Model_Status.wait_begin or model_status == FishingMatchModel.Model_Status.wait_table then
            ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_bymatch_baoming.audio_name)
            FishingMatchLogic.change_panel(FishingMatchLogic.panelNameMap.wait, parm)
        elseif model_status == FishingMatchModel.Model_Status.gaming then
            ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_bymatch_youxizhong.audio_name)
            FishingMatchLogic.change_panel(FishingMatchLogic.panelNameMap.game, parm)
        else
            ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_bymatch_jiesuan.audio_name)
            FishingMatchLogic.change_panel(FishingMatchLogic.panelNameMap.over, parm)
        end
    end
end
function FishingMatchLogic.on_model_change_panel(parm)
    FishingMatchLogic.on_fsmg_all_info(parm)
end

--游戏前台消息
function FishingMatchLogic.on_backgroundReturn_msg()
    if FishingMatchLogic.is_quit then
        FishingMatchLogic.quit_game()
    else
        if not FishingMatchModel.IsLoadRes then
            if cur_panel and cur_panel.instance.on_backgroundReturn_msg then
                cur_panel.instance:on_backgroundReturn_msg()
            end
            -- FishingMatchModel.SetUpdateFrame(true)
            SendRequestAllInfo()
            print("<color=red>XXX 游戏前台消息 XXX</color>")
        end
    end
end
--游戏后台消息
function FishingMatchLogic.on_background_msg()
    if FishingMatchLogic.is_quit then
    else
        if not FishingMatchModel.IsLoadRes then
            DOTweenManager.KillAllStopTween()
            if cur_panel and cur_panel.instance.on_background_msg then
                cur_panel.instance:on_background_msg()
            end
            FishingMatchModel.SetUpdateFrame(false)
            print("<color=red>XXX 游戏后台消息 XXX</color>")
        end
    end
end
--游戏网络破损消息
function FishingMatchLogic.on_network_error_msg()
    if FishingMatchLogic.is_quit then
    else
        FishingMatchModel.SetUpdateFrame(false)
        if cur_panel and cur_panel.instance.update_time then
            cur_panel.instance.update_time:Stop()
        end
        cancelViewMsgRegister()
        print("<color=red>XXX 游戏网络破损消息 XXX</color>")
        FishingMatchModel.IsRecoverRet = true
    end
end
--游戏网络状态差
function FishingMatchLogic.on_network_poor_msg()
    print("<color=red>XXX 游戏网络状态差 XXX</color>")
end
--游戏重新连接消息
function FishingMatchLogic.on_reconnect_msg()
    if FishingMatchLogic.is_quit then
        FishingMatchLogic.quit_game()
    else
        print("<color=red>XXX 游戏重新连接消息 XXX</color>")
        FishingMatchModel.SetUpdateFrame(false)
        if cur_panel and cur_panel.instance.update_time then
            cur_panel.instance.update_time:Stop()
        end

        SendRequestAllInfo()
    end
end
--断线重连相关**************
function FishingMatchLogic.quit_game(not_chang_hall)
    if not FishingMatchLogic.is_quiting then
        MainLogic.ExitGame()
        if cur_panel.name == "game" then
            cur_panel.instance:MyExit()
        end
        Event.Brocast("ui_fsg_quit_game")

        FishingMatchLogic.is_quit = true
        Network.SendRequest("fsmg_quit_game", nil, "请求退出", function (data)
            FishingMatchLogic.is_quiting = true
            FishingUninstallPanel.Create(function()
                if not not_chang_hall then
                    FishingMatchLogic.change_panel("hall")
                end
                if data.result == 0 then
                    Event.Brocast("quit_game_success")
                end
            end)
        end)
    end
end

--初始化
function FishingMatchLogic.Init(pram)
    ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_bymatch_baoming.audio_name)
    this = FishingMatchLogic
    --初始化model
    local model = FishingMatchModel.Init()
    if pram then
        FishingMatchModel.game_id = pram.game_id
    else
        FishingMatchModel.game_id = MainModel.game_id
    end

    MakeLister()
    AddMsgListener(lister)
    
    FishingSkillManager.Init()
    FishingMatchBuffManager.Init()
    MainLogic.EnterGame()

    local size = GameObject.Find("Canvas"):GetComponent("RectTransform").sizeDelta
    local width = size.x/size.y * 5.4
    local height = 5.4
    FishingMatchModel.Defines.WorldDimensionUnit = {xMin=-width, xMax=width, yMin=-height, yMax=height}
    FishingMatchModel.IsRecoverRet = true
    FishingMatchModel.IsLoadRes = true
    dump(FishingMatchModel.Defines.WorldDimensionUnit, "<color=white>屏幕适配尺寸</color>")

    FishingMatchModel.data.limitDealMsg = {fsmg_all_info_test_response = true}

    FishingLoadingPanel.Create(function( )
    end)
    -- SendRequestAllInfo()
end

function FishingMatchLogic.Exit()
    if this then
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        FishingSkillManager.MyExit()
        FishingMatchBuffManager.MyExit()
        -- for k,v in ipairs(FishingMatchModel.Config.fish_cache_list) do
        --     CachePrefabManager.DelCachePrefab(v.prefab)
        -- end
        soundMgr:CloseSound()
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        FishingMatchModel.Exit()
    end
end

function FishingMatchLogic.quit_game(call, quit_msg_call)
    Network.SendRequest("fsmg_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            DOTweenManager.KillAllStopTween()
            MainLogic.ExitGame()
            if not call then
                FishingMatchLogic.change_panel(FishingMatchLogic.panelNameMap.hall)
            else
                call()
            end
        end
    end)
end
return FishingMatchLogic