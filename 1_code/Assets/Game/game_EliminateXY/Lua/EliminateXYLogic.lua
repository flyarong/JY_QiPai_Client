ext_require_audio("Game.game_EliminateXY.Lua.audio_sdbgj_config","sdbgj")
EliminateXYLogic = {}
package.loaded["Game.game_EliminateXY.Lua.eliminate_xy_algorithm"] = nil
require "Game.game_EliminateXY.Lua.eliminate_xy_algorithm"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYModel"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYModel"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYGamePanel"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYGamePanel"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYObjManager"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYObjManager"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYAnimManager"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYAnimManager"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYPartManager"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYPartManager"

package.loaded["Game.game_EliminateXY.Lua.EliminateXYDesPrefab"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYDesPrefab"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYMoneyPanel"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYMoneyPanel"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYHelpPanel"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYHelpPanel"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYButtonPrefab"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYButtonPrefab"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYClearPanel"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYClearPanel"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYInfoPanel"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYInfoPanel"
package.loaded["Game.game_EliminateXY.Lua.EliminateXYHeroManager"] = nil
require "Game.game_EliminateXY.Lua.EliminateXYHeroManager"

local M = EliminateXYLogic
local panelNameMap = {
    hall = "hall",
    game = "EliminateXYGamePanel",
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
    lister["model_xxl_xiyou_enter_game_response"] = M.xxl_xiyou_enter_game_response
    lister["model_xxl_xiyou_quit_game_response"] = M.xxl_xiyou_quit_game_response
    lister["model_xxl_xiyou_all_info"] = M.xxl_xiyou_all_info
    lister["model_xxl_xiyou_all_info_error"] = M.xxl_xiyou_all_info_error

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
    if EliminateXYModel.data and EliminateXYModel.data.model_status == EliminateXYModel.Model_Status.gameover then
        M.xxl_xiyou_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateXYModel.data.limitDealMsg = {xxl_xiyou_all_info_response = true}
        if M.is_test then
            local data = M.GetTestData()
            Event.Brocast("xxl_xiyou_all_info_response","xxl_xiyou_all_info_response",data)
        else
            Network.SendRequest("xxl_xiyou_all_info",nil,"正在请求数据")
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
            cur_panel = {name = panelName, instance = EliminateXYGamePanel.Create()}
        end
    end
end

function M.xxl_xiyou_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo("enter_game")
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.xxl_xiyou_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.xxl_xiyou_all_info()
    --取消限制消息
    EliminateXYModel.data.limitDealMsg = nil
    dump(EliminateXYModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if EliminateXYModel.data.model_status == nil or EliminateXYModel.data.model_status == EliminateXYModel.Model_Status.gameover then
        --大厅界面
        go_to = panelNameMap.hall
    elseif EliminateXYModel.data.model_status == EliminateXYModel.Model_Status.gaming then
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
function M.xxl_xiyou_all_info_error()
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
    EliminateXYGamePanel.ExitTimer()
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
    EliminateXYGamePanel.ExitTimer()
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
    local model = EliminateXYModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    EliminateXYObjManager.Init()
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
    EliminateXYModel.Exit()
end

M.is_test = false
function M.GetTestData()
    local data =  {
        --断线重连
        result = 0,
        all_money = 7500,
        bgj_rate_vec = {10,20,50,5,5,30,10,5,5,50,},

        all_rate=250,
        xc_data="13338223182251822215242640151804032050640203001010000500002000010",
        swk_skill={3,},
        swk_skill_3={"46504254666466017403",},
        swk_skill_3_rate_vec={{10,},},
        all_add_value=106,
        free_game_num=10,
        free_game_data={
            all_rate=190,
            all_add_value=105,
            bgj_rate=55,
            xc_data="222232455233221252252444413532252384512311331551515515131121141145454121328522151452555258132585111845425325435423413518142385215242558111255531813528523484513842514123511221521454111365331853145152112441222324133583521811511524541544841518333414213832248203025020500501000030000100002000030000100002",
            swk_skill={3,3,},
            swk_skill_3={"70007777777777777770","03036020180207707005","70770077777707000700","07077707770000077700","77700070707000077007","07770077000070707707",},
            swk_skill_3_rate_vec={{6,2,6,5,9,9,1,1,5,2,8,9,4,8,3,9,},{8,3,1,},{6,6,8,6,10,10,5,4,10,3,2,},{7,10,6,5,2,10,10,4,4,1,},{9,5,1,10,8,8,4,1,7,},{1,1,6,8,6,8,3,10,4,7,},},
            change_data={"77777077070777777770","00700000077700070077","00007700070707707700","77777777777007007777","07770000000000000000","70700707007070070770","07007700000070077070","70700070007777000070","00077707000777000770","70007700777707070070",},
            change_data_rate_vec={{10,6,10,5,3,7,3,10,4,1,4,4,6,7,10,10,},{1,1,3,1,8,1,4,},{2,10,7,2,6,2,8,9,},{7,10,3,10,10,6,8,8,2,2,3,3,9,9,10,4,},{5,4,1,},{7,5,3,2,4,8,3,6,3,},{9,2,5,6,8,10,6,},{3,10,1,4,4,3,1,7,},{8,2,2,7,9,3,4,5,5,},{7,7,3,9,10,6,9,2,8,7,},},
            bgj_award_skill=2,
            bgj_award_skill_2=10,
        },
    }
    return data
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("xxl_xiyou_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            DOTweenManager.KillAllStopTween()
            if not call then
                M.change_panel(panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return M
