-- 创建时间:2019-03-06
ext_require_audio("Game.normal_fishing_common.Lua.audio_by_config","by")

package.loaded["Game.game_Fishing.Lua.FishingModel"] = nil
require "Game.game_Fishing.Lua.FishingModel"
package.loaded["Game.game_Fishing.Lua.FishingGamePanel"] = nil
require "Game.game_Fishing.Lua.FishingGamePanel"
package.loaded["Game.normal_fishing_common.Lua.FishingLoadingPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingLoadingPanel"
package.loaded["Game.normal_fishing_common.Lua.FishingUninstallPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingUninstallPanel"
package.loaded["Game.game_Fishing.Lua.FishingNorSKillPrefab"] = nil
require "Game.game_Fishing.Lua.FishingNorSKillPrefab"
package.loaded["Game.game_Fishing.Lua.FishingOperPrefab"] = nil
require "Game.game_Fishing.Lua.FishingOperPrefab"

package.loaded["Game.normal_fishing_common.Lua.Vehicle"] = nil
require "Game.normal_fishing_common.Lua.Vehicle"


package.loaded["Game.normal_fishing_common.Lua.BKManager"] = nil
require "Game.normal_fishing_common.Lua.BKManager"
package.loaded["Game.normal_fishing_common.Lua.FishManager"] = nil
require "Game.normal_fishing_common.Lua.FishManager"
package.loaded["Game.normal_fishing_common.Lua.BulletManager"] = nil
require "Game.normal_fishing_common.Lua.BulletManager"
package.loaded["Game.normal_fishing_common.Lua.BulletPrefab"] = nil
require "Game.normal_fishing_common.Lua.BulletPrefab"
package.loaded["Game.normal_fishing_common.Lua.FishExtManager"] = nil
require "Game.normal_fishing_common.Lua.FishExtManager"
package.loaded["Game.normal_fishing_common.Lua.FishBase"] = nil
require "Game.normal_fishing_common.Lua.FishBase"
package.loaded["Game.normal_fishing_common.Lua.Fish"] = nil
require "Game.normal_fishing_common.Lua.Fish"
package.loaded["Game.normal_fishing_common.Lua.FishNetPrefab"] = nil
require "Game.normal_fishing_common.Lua.FishNetPrefab"
package.loaded["Game.normal_fishing_common.Lua.FishTeam"] = nil
require "Game.normal_fishing_common.Lua.FishTeam"
package.loaded["Game.normal_fishing_common.Lua.HintYBPrefab"] = nil
require "Game.normal_fishing_common.Lua.HintYBPrefab"
package.loaded["Game.normal_fishing_common.Lua.FishBK"] = nil
require "Game.normal_fishing_common.Lua.FishBK"
package.loaded["Game.normal_fishing_common.Lua.FishTreasureBox"] = nil
require "Game.normal_fishing_common.Lua.FishTreasureBox"
package.loaded["Game.normal_fishing_common.Lua.FishingAnimManager"] = nil
require "Game.normal_fishing_common.Lua.FishingAnimManager"
package.loaded["Game.normal_fishing_common.Lua.FishingSkillManager"] = nil
require "Game.normal_fishing_common.Lua.FishingSkillManager"

package.loaded["Game.normal_fishing_common.Lua.FishingBagPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingBagPanel"
package.loaded["Game.normal_fishing_common.Lua.FishingBagItem"] = nil
require "Game.normal_fishing_common.Lua.FishingBagItem"

--机器人
package.loaded["Game.normal_fishing_common.Lua.FishingPlayerAIManager"] = nil
require "Game.normal_fishing_common.Lua.FishingPlayerAIManager"
package.loaded["Game.normal_fishing_common.Lua.FishingActivityManager"] = nil
require "Game.normal_fishing_common.Lua.FishingActivityManager"

package.loaded["Game.game_Fishing.Lua.FishDeadManager"] = nil
require "Game.game_Fishing.Lua.FishDeadManager"
package.loaded["Game.game_Fishing.Lua.FishingPlayer"] = nil
require "Game.game_Fishing.Lua.FishingPlayer"
package.loaded["Game.game_Fishing.Lua.FishingGun"] = nil
require "Game.game_Fishing.Lua.FishingGun"

require "Game.normal_fishing_common.Lua.VehicleManager"

package.loaded["Game.normal_comfishing_common.Lua.FishingGuideLogic"] = nil
require "Game.normal_comfishing_common.Lua.FishingGuideLogic"


package.loaded["Game.normal_fishing_common.Lua.BulletPrefabZT"] = nil
require "Game.normal_fishing_common.Lua.BulletPrefabZT"

package.loaded["Game.normal_fishing_common.Lua.FishCS"] = nil
require "Game.normal_fishing_common.Lua.FishCS"

package.loaded["Game.normal_fishing_common.Lua.FishZcm"] = nil
require "Game.normal_fishing_common.Lua.FishZcm"

package.loaded["Game.normal_fishing_common.Lua.FishingFHDeadPrefab"] = nil
require "Game.normal_fishing_common.Lua.FishingFHDeadPrefab"

ext_require("Game.normal_fishing_common.Lua.BYKJBagPanel")

package.loaded["Game.normal_fishing_common.Lua.FishingBKPanel"] = nil
require "Game.normal_fishing_common.Lua.FishingBKPanel"

FishingLogic = {}

FishingLogic.panelNameMap = {
    hall = "hall",
    game = "game"
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

end

local function SendRequestAllInfo()
    if FishingModel.data and FishingModel.data.model_status == FishingModel.Model_Status.gameover then
        FishingLogic.on_fg_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        FishingModel.data.limitDealMsg = {fsg_all_info_test_response = true}
        FishingModel.SendAllInfo()
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

function FishingLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function FishingLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function FishingLogic.refresh_panel()
    if cur_panel then
        cur_panel.instance:MyRefresh()
    end
end
function FishingLogic.GetPanel()
    if cur_panel then
        return cur_panel.instance
    end
end

function FishingLogic.change_panel(panelName, pram)
    if have_Jh then
        FullSceneJH.RemoveByTag(have_Jh)
        have_Jh = nil
    end
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == FishingLogic.panelNameMap.hall then
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
        if panelName == FishingLogic.panelNameMap.hall then
		if GameGlobalOnOff.IOSTS then
			MainLogic.GotoScene("game_Hall")
		else
			GameManager.GotoSceneName("game_FishingHall")
		end
        elseif panelName == FishingLogic.panelNameMap.game then
            cur_panel = {name = panelName, instance = FishingGamePanel.Create(pram)}
        end
    end
end

--游戏前台消息
function FishingLogic.on_backgroundReturn_msg()
    if FishingLogic.is_quit then
        FishingLogic.quit_game()
    else
        if not FishingModel.IsLoadRes then
            if cur_panel then
                cur_panel.instance:on_backgroundReturn_msg()
            end
            -- FishingModel.SetUpdateFrame(true)
            SendRequestAllInfo()
            print("<color=red>XXX 游戏前台消息 XXX</color>")
        end
    end
end
--游戏后台消息
function FishingLogic.on_background_msg()
    if FishingLogic.is_quit then
    else
        if not FishingModel.IsLoadRes then
            DOTweenManager.KillAllStopTween()
            if cur_panel then
                cur_panel.instance:on_background_msg()
            end
            FishingModel.SetUpdateFrame(false)
            print("<color=red>XXX 游戏后台消息 XXX</color>")
        end
    end
end
--游戏网络破损消息
function FishingLogic.on_network_error_msg()
    if FishingLogic.is_quit then
    else
        FishingModel.SetUpdateFrame(false)
        if cur_panel and cur_panel.instance.update_time then
            cur_panel.instance.update_time:Stop()
        end
        cancelViewMsgRegister()
        print("<color=red>XXX 游戏网络破损消息 XXX</color>")
        FishingModel.IsRecoverRet = true
    end
end
--游戏网络状态差
function FishingLogic.on_network_poor_msg()
    print("<color=red>XXX 游戏网络状态差 XXX</color>")
end
--游戏重新连接消息
function FishingLogic.on_reconnect_msg()
    if FishingLogic.is_quit then
        FishingLogic.quit_game()
    else
        print("<color=red>XXX 游戏重新连接消息 XXX</color>")
        FishingModel.SetUpdateFrame(false)
        if cur_panel and cur_panel.instance.update_time then
            cur_panel.instance.update_time:Stop()
        end

        SendRequestAllInfo()
    end
end
--断线重连相关**************
function FishingLogic.quit_game(call, quit_msg_call)
    if not FishingLogic.is_quiting then        
        FishingLogic.is_quiting = true

        FishingLogic.is_quit = true
        Network.SendRequest("fsg_quit_game", nil, "请求退出", function (data)
            if quit_msg_call then
                quit_msg_call(data.result)
            end
            if data.result == 0 then

                MainLogic.ExitGame()
                Event.Brocast("ui_fsg_quit_game")
                
                if cur_panel.name == "game" then
                    cur_panel.instance:MyExit()
                end
                DOTweenManager.KillAllStopTween()
                DOTweenManager.KillAllExitTween()
                DOTweenManager.CloseAllSequence()

                FishingUninstallPanel.Create(function()
                    if not call then
                        FishingLogic.change_panel("hall")
                    else
                        call()
                    end
                    Event.Brocast("quit_game_success")
                end)
            end
        end)
    end
end

--初始化
function FishingLogic.Init(pram)
    dump(pram, "<color=red><size=16>OOOOOOOOOOOOOOOO FishingLogic.Init</size></color>")
    ExtendSoundManager.PlaySceneBGM(audio_config.by.bgm_by_game.audio_name)
    this = FishingLogic
    --初始化model
    local model = FishingModel.Init()
    if pram then
        FishingModel.game_id = pram.game_id
    else
        FishingModel.game_id = MainModel.game_id
    end
    dump(FishingModel.game_id)

    MakeLister()
    AddMsgListener(lister)

    FishingSkillManager.Init()
    MainLogic.EnterGame()

    local size = GameObject.Find("Canvas"):GetComponent("RectTransform").sizeDelta
    local width = size.x/size.y * 5.4
    local height = 5.4
    FishingModel.Defines.WorldDimensionUnit = {xMin=-width, xMax=width, yMin=-height, yMax=height}
    FishingModel.IsRecoverRet = true
    FishingModel.IsLoadRes = true
    dump(FishingModel.Defines.WorldDimensionUnit, "<color=white>屏幕适配尺寸</color>")

    FishingModel.data.limitDealMsg = {fsg_all_info_test_response = true}

    FishingLogic.change_panel(FishingLogic.panelNameMap.game, pram)
    --Event.Brocast("fishing_enter_game")
end

function FishingLogic.Exit()
    if this then
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        FishingSkillManager.MyExit()
        -- for k,v in ipairs(FishingModel.Config.fish_cache_list) do
        --     CachePrefabManager.DelCachePrefab(v.prefab)
        -- end
        soundMgr:CloseSound()
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        FishingModel.Exit()
    end
end

return FishingLogic