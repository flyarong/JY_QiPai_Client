ext_require_audio("Game.game_FishingDR.Lua.audio_by_dr_config","by_dr")
FishingDRLogic = {}
package.loaded["Game.game_FishingDR.Lua.FishingDRVector2D"] = nil
require "Game.game_FishingDR.Lua.FishingDRVector2D"
package.loaded["Game.game_FishingDR.Lua.FishingDRLoadingPanel"] = nil
require "Game.game_FishingDR.Lua.FishingDRLoadingPanel"
package.loaded["Game.game_FishingDR.Lua.FishingDRUninstallPanel"] = nil
require "Game.game_FishingDR.Lua.FishingDRUninstallPanel"

package.loaded["Game.game_FishingDR.Lua.FishingDRAnimManager"] = nil
require "Game.game_FishingDR.Lua.FishingDRAnimManager"
package.loaded["Game.game_FishingDR.Lua.FishingDRModel"] = nil
require "Game.game_FishingDR.Lua.FishingDRModel"
package.loaded["Game.game_FishingDR.Lua.FishingDRGamePanel"] = nil
require "Game.game_FishingDR.Lua.FishingDRGamePanel"
package.loaded["Game.game_FishingDR.Lua.FishingDRBetPanel"] = nil
require("Game.game_FishingDR.Lua.FishingDRBetPanel")
package.loaded["Game.game_FishingDR.Lua.FishingDROverPanel"] = nil
require "Game.game_FishingDR.Lua.FishingDROverPanel"

package.loaded["Game.game_FishingDR.Lua.FishingDRFishManager"] = nil
require "Game.game_FishingDR.Lua.FishingDRFishManager"
package.loaded["Game.game_FishingDR.Lua.FishingDRFishPrefab"] = nil
require "Game.game_FishingDR.Lua.FishingDRFishPrefab"
package.loaded["Game.game_FishingDR.Lua.FishingDRBulletManager"] = nil
require "Game.game_FishingDR.Lua.FishingDRBulletManager"
package.loaded["Game.game_FishingDR.Lua.FishingDRBulletPrefab"] = nil
require "Game.game_FishingDR.Lua.FishingDRBulletPrefab"
package.loaded["Game.game_FishingDR.Lua.FishingDRFishNetManager"] = nil
require "Game.game_FishingDR.Lua.FishingDRFishNetManager"
package.loaded["Game.game_FishingDR.Lua.FishingDRFishNetPrefab"] = nil
require "Game.game_FishingDR.Lua.FishingDRFishNetPrefab"
package.loaded["Game.game_FishingDR.Lua.FishingDRItemManager"] = nil
require "Game.game_FishingDR.Lua.FishingDRItemManager"
package.loaded["Game.game_FishingDR.Lua.FishingDRItemPrefab"] = nil
require "Game.game_FishingDR.Lua.FishingDRItemPrefab"

package.loaded["Game.game_FishingDR.Lua.FishingDRGunManager"] = nil
require "Game.game_FishingDR.Lua.FishingDRGunManager"
package.loaded["Game.game_FishingDR.Lua.FishingDRGun"] = nil
require "Game.game_FishingDR.Lua.FishingDRGun"
package.loaded["Game.game_FishingDR.Lua.FishingDRPlayerManager"] = nil
require "Game.game_FishingDR.Lua.FishingDRPlayerManager"
package.loaded["Game.game_FishingDR.Lua.FishingDRPlayer"] = nil
require "Game.game_FishingDR.Lua.FishingDRPlayer"

package.loaded["Game.game_FishingDR.Lua.FishingDRNoticePanel"] = nil
require "Game.game_FishingDR.Lua.FishingDRNoticePanel"

package.loaded["Game.game_FishingDR.Lua.FishingDRHelpPanel"] = nil
require "Game.game_FishingDR.Lua.FishingDRHelpPanel"


FishingLogic = FishingDRLogic
local M = FishingDRLogic

local panelNameMap = {
    hall = "hall",
    game = "FishingDRGamePanel",
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
local jh_name = "fishing_dr_jh"
--构建正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --需要切换panel的消息
    lister["model_fishing_dr_enter_game_response"] = M.fishing_dr_enter_game_response
    lister["model_fishing_dr_quit_game_response"] = M.fishing_dr_quit_game_response
    lister["model_fishing_dr_all_info"] = M.fishing_dr_all_info
    lister["model_fishing_dr_all_info_error"] = M.fishing_dr_all_info_error

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
    --限制处理消息  此时只处理指定的消息
    FishingDRModel.data.limitDealMsg = {fishing_dr_all_info_response = true}
    --测试数据
    print("<color=yellow>SendRequest</color>")
    local data = {}
    data.result = 0
    -- Event.Brocast("fishing_dr_all_info_response","fishing_dr_all_info_response",data)

    Network.SendRequest("fishing_dr_all_info",nil,"正在请求数据")
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
            MainLogic.GotoScene("game_FishingHall")
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = FishingDRGamePanel.Create()}
            dump(cur_panel, "<color=yellow>cur_panel</color>")
        end
    end
end

function M.fishing_dr_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo()
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.fishing_dr_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.fishing_dr_all_info()
    --取消限制消息
    FishingDRModel.data.limitDealMsg = nil
    dump(FishingDRModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if FishingDRModel.data.model_status == nil then
        --大厅界面
        go_to = panelNameMap.hall
    elseif FishingDRModel.data.model_status == FishingDRModel.Model_Status.gaming then
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
function M.fishing_dr_all_info_error()
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
    local model = FishingDRModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)

    local size = GameObject.Find("Canvas"):GetComponent("RectTransform").sizeDelta
    local width = size.x/size.y * 5.4
    local height = 5.4
    FishingDRModel.Defines.WorldDimensionUnit = {xMin=-width, xMax=width, yMin=-height, yMax=height}

    M.change_panel(panelNameMap.game)
    FishingDRLoadingPanel.Create(function( )
    end)
    -- --请求ALL数据
    -- if not isNotSendAllInfo then
    --     SendRequestAllInfo()
    -- end
end

function M.Exit()
	update:Stop()
    update = nil
    if cur_panel then
        cur_panel.instance:MyExit()
    end
    cur_panel = nil

	for k,v in ipairs(FishingModel.Config.fish_cache_list) do
		CachePrefabManager.DelCachePrefab(v.prefab)
	end

    RemoveMsgListener(lister)
    clearAllViewMsgRegister()
    FishingDRModel.Exit()
end

function M.GetPanel()
    return cur_panel.instance
end

return M
