ext_require_audio("Game.game_TTL.Lua.audio_ttl_config","ttl")
-- 创建时间:2020-03-19

package.loaded["Game.game_TTL.Lua.TTLModel"] = nil
require "Game.game_TTL.Lua.TTLModel"
--弹弹乐桌面👇
package.loaded["Game.game_TTL.Lua.TTLGamePanel"] = nil
require "Game.game_TTL.Lua.TTLGamePanel"
--帮助界面👇
package.loaded["Game.game_TTL.Lua.HelpPanel"] = nil
require "Game.game_TTL.Lua.TTLHelpPanel"
--玩家信息界面👇
package.loaded["Game.game_TTL.Lua.TTLUserInfoPanel"] = nil
require "Game.game_TTL.Lua.TTLUserInfoPanel"
--被撞物体管理👇
package.loaded["Game.game_TTL.Lua.TTLItemBase"] = nil
require "Game.game_TTL.Lua.TTLItemBase"
--撞击动画和撞击加分动画管理👇
package.loaded["Game.game_TTL.Lua.TTLParticleManager"] = nil
require "Game.game_TTL.Lua.TTLParticleManager"
--玩家子弹👇
package.loaded["Game.game_TTL.Lua.TTLBullet"] = nil
require "Game.game_TTL.Lua.TTLBullet"
--时间slider界面👇
package.loaded["Game.game_TTL.Lua.TTLTimeSliderPanel"] = nil
require "Game.game_TTL.Lua.TTLTimeSliderPanel"
--结算界面👇
package.loaded["Game.game_TTL.Lua.TTLSettlePanel"] = nil
require "Game.game_TTL.Lua.TTLSettlePanel"
--灯泡摇奖界面👇
package.loaded["Game.game_TTL.Lua.TTLSwitchRollPanel"] = nil
require "Game.game_TTL.Lua.TTLSwitchRollPanel"
--闪电球爆炸一系列特效界面下
package.loaded["Game.game_TTL.Lua.TTLBombPanel"] = nil
require "Game.game_TTL.Lua.TTLBombPanel"


TTLLogic = {}

TTLLogic.panelNameMap = {
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

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg

    lister["send_tantanle_quit_game_msg"] = this.send_tantanle_quit_game_msg
    lister["model_tantanle_quit_game_response"] = this.tantanle_quit_game_response
    
    lister["model_tantanle_enter_game_response"] = this.on_tantanle_enter_game_response
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
    Network.SendRequest("tantanle_all_info", {type = "all"})
end

local function SendAllInfoLi(tt)
    dump(tt, "<color=red>TTL SendAllInfoLi </color>")
    Network.SendRequest("tantanle_all_info", {type = "all"}, "", function (data)
        dump(data)
        if data.result ~= 0 then
            TTLLogic.change_panel(TTLLogic.panelNameMap.hall)
        end
    end)
end

function TTLLogic.setViewMsgRegister(lister, registerName)
    --检测是否已经注册
    if not registerName or viewLister[registerName] then
        return false
    end
    viewLister[registerName] = lister
    ViewMsgRegister(registerName)
end

function TTLLogic.clearViewMsgRegister(registerName)
    if not registerName then
        return false
    end
    cancelViewMsgRegister(registerName)
    viewLister[registerName] = nil
end

function TTLLogic.GetPanel()
    return cur_panel.instance
end

function TTLLogic.change_panel(panelName, pram)
    if cur_panel then
        if cur_panel.name == panelName then
            cur_panel.instance:MyRefresh()
        elseif panelName == TTLLogic.panelNameMap.hall then
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
        if panelName == TTLLogic.panelNameMap.hall then
            MainLogic.ExitGame()
    		if GameGlobalOnOff.IOSTS then
    			MainLogic.GotoScene("game_Hall")
    		else
                Event.Brocast("GamePanel_on_close_TTL")
                --GameManager.GotoUI({gotoui = "game_MiniGame"})
                GameManager.GotoSceneName("game_MiniGame")
    		end
        elseif panelName == TTLLogic.panelNameMap.game then
            cur_panel = {name = panelName, instance = TTLGamePanel.Create(pram)}
        end
    end
end

-- 游戏前台消息
function TTLLogic.on_backgroundReturn_msg()
    dump("on_backgroundReturn_msg","<color=blue>0000000000000000000000000000</color>")
    Event.Brocast("model_bullet_pause_msg", {type="ht", is_pause=true})
    SendAllInfoLi("ht")
end
--游戏后台消息
function TTLLogic.on_background_msg()
    dump("on_background_msg","<color=blue>0000000000000000000000000000</color>")
    Event.Brocast("model_bullet_pause_msg", {type="ht", is_pause=false})
    Event.Brocast("model_auto_setfalse_msg")
end
--游戏网络破损消息
function TTLLogic.on_network_error_msg()
    dump("on_network_error_msg","<color=blue>0000000000000000000000000000</color>")
    Event.Brocast("model_bullet_pause_msg", {type="wlzt", is_pause=false})
    Event.Brocast("model_auto_setfalse_msg")
end
--游戏网络状态差
function TTLLogic.on_network_poor_msg()
    dump("<color=red>XXX 游戏网络状态差 XXX</color>","<color=blue>0000000000000000000000000000</color>")
end
--游戏重新连接消息
function TTLLogic.on_reconnect_msg()
    dump("on_reconnect_msg","<color=blue>0000000000000000000000000000</color>")
    Event.Brocast("model_bullet_pause_msg", {type="wlzt", is_pause=true})
    SendAllInfoLi("wlzt")
end
--断线重连相关**************
function TTLLogic.quit_game(not_chang_hall)
    dump("quit_game","<color=blue>0000000000000000000000000000</color>")
end
function TTLLogic.on_tantanle_enter_game_response()
    SendRequestAllInfo()
end

function TTLLogic.send_tantanle_quit_game_msg()
    MainLogic.ExitGame()
    Network.SendRequest("tantanle_quit_game", nil, "") 
end
function TTLLogic.tantanle_quit_game_response()
    TTLLogic.change_panel(TTLLogic.panelNameMap.hall)
end

--初始化
function TTLLogic.Init(pram)
    ExtendSoundManager.PlaySceneBGM(audio_config.ttl.bgm_ttl_beijing.audio_name)
    this = TTLLogic
    TTLModel.Init()

    MakeLister()
    AddMsgListener(lister)

    MainLogic.EnterGame()
    dump(pram)
        
    SendRequestAllInfo()

    cur_panel = {name = panelName, instance = TTLGamePanel.Create(pram)}
end

function TTLLogic.Exit()
    if this then
        this = nil
        if cur_panel then
            cur_panel.instance:MyExit()
        end
        --TTLSkillManager.MyExit()
        -- for k,v in ipairs(TTLModel.Config.fish_cache_list) do
        --     CachePrefabManager.DelCachePrefab(v.prefab)
        -- end
        soundMgr:CloseSound()
        cur_panel = nil
        RemoveMsgListener(lister)
        clearAllViewMsgRegister()
        TTLModel.Exit()
    end
end

function TTLLogic.quit_game(call, quit_msg_call)
    print(debug.traceback())
    Network.SendRequest("tantanle_quit_game", nil, "", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            Event.Brocast("GamePanel_on_close_TTL")
            MainLogic.ExitGame()
            if not call then
                TTLLogic.change_panel(panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)    
end

return TTLLogic


