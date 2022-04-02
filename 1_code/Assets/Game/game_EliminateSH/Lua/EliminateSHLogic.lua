ext_require_audio("Game.game_EliminateSH.Lua.audio_shxxl_config","shxxl")
EliminateSHLogic = {}
package.loaded["Game.game_EliminateSH.Lua.eliminate_sh_algorithm"] = nil
require "Game.game_EliminateSH.Lua.eliminate_sh_algorithm"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHModel"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHModel"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHGamePanel"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHGamePanel"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHObjManager"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHObjManager"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHAnimManager"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHAnimManager"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHPartManager"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHPartManager"

package.loaded["Game.game_EliminateSH.Lua.EliminateSHDesPrefab"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHDesPrefab"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHMoneyPanel"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHMoneyPanel"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHHelpPanel"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHHelpPanel"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHButtonPrefab"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHButtonPrefab"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHClearPanel"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHClearPanel"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHInfoPanel"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHInfoPanel"
package.loaded["Game.game_EliminateSH.Lua.EliminateSHHeroManager"] = nil
require "Game.game_EliminateSH.Lua.EliminateSHHeroManager"

local M = EliminateSHLogic
local panelNameMap = {
    hall = "hall",
    game = "EliminateSHGamePanel",
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
    lister["model_xxl_shuihu_enter_game_response"] = M.xxl_shuihu_enter_game_response
    lister["model_xxl_shuihu_quit_game_response"] = M.xxl_shuihu_quit_game_response
    lister["model_xxl_shuihu_all_info"] = M.xxl_shuihu_all_info
    lister["model_xxl_shuihu_all_info_error"] = M.xxl_shuihu_all_info_error

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
    if EliminateSHModel.data and EliminateSHModel.data.model_status == EliminateSHModel.Model_Status.gameover then
        M.xxl_shuihu_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateSHModel.data.limitDealMsg = {xxl_shuihu_all_info_response = true}
        Network.SendRequest("xxl_shuihu_all_info",nil,"正在请求数据")
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
            --GameManager.GotoUI({gotoui = "game_MiniGame"})
            GameManager.GotoSceneName("game_MiniGame")
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = EliminateSHGamePanel.Create()}
        end
    end
end

function M.xxl_shuihu_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo("enter_game")
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.xxl_shuihu_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.xxl_shuihu_all_info()
    --取消限制消息
    EliminateSHModel.data.limitDealMsg = nil
    dump(EliminateSHModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if EliminateSHModel.data.model_status == nil or EliminateSHModel.data.model_status == EliminateSHModel.Model_Status.gameover then
        --大厅界面
        go_to = panelNameMap.hall
    elseif EliminateSHModel.data.model_status == EliminateSHModel.Model_Status.gaming then
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
function M.xxl_shuihu_all_info_error()
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
    EliminateSHGamePanel.ExitTimer()
    EliminateSHAnimManager.ExitTimer()
    EliminateSHObjManager.ExitTimer()
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
    EliminateSHGamePanel.ExitTimer()
    EliminateSHAnimManager.ExitTimer()
    EliminateSHObjManager.ExitTimer()
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
    local model = EliminateSHModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    EliminateSHObjManager.Init()
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
    EliminateSHModel.Exit()
    EliminateSHObjManager.Exit()
    EliminateSHHeroManager.Exit()
    EliminateSHGamePanel.ExitTimer()
    EliminateSHAnimManager.ExitTimer()
end

M.is_test = false
function M.GetTestData()
    local data =  {
        -- result = 0,
        -- award_money = 1000,
        -- all_rate=2400,
        -- total_xc_data={
        --     "1611162413631122111411144441326644413266246616662561464425311234523126656361333515135524523412242615215221512602603310000031100000510000",
        --     "42661434212646325134511121412431111154231416236463363122343351444612512242161522233334120312110000666600005040000060200000603000",
        --     "66544334641442311133163212114252146636226313326113211121513152421641323611134322100133033002630100000100000001000000040000000300",
        --     "32643121411411116111233434633111156333213553514314442111142333126562614122151115633514130633316300042431000605000001030000010400000201000004030000020000",
        -- },
        -- event_sj_zlnc=3,
        -- event_lk_bomb_list={1,3,5,1,},
        -- event_lzs_data_guding={4,1,2,2  ,3,3,1,1  ,3,3,4,3  ,3,1,1,3,},
        -- event_lzs_data_random={1,1,2,1  ,4,4,1,1  ,1,4,2,4  ,2,3,4,3  ,1,2,1,2  ,4,2,3,4  ,2,3,2,2  ,1,3,3,1  ,1,4,1,1  ,2,4,2,3  ,3,2,3,1  ,1,1,3,3,},
        -- hero_list={4,2,1,3,},

        --不要删我的测试数据
        -- result = 0,
        -- all_rate = 5000,
        -- award_money = 5000,
        -- event_lk_bomb_list = {1,2,},
        -- event_lzs_data_guding = {1,2,2,3,4,1,1,3,},
        -- event_lzs_data_random = {1,2,2,3,2,4,1,4,4,4,2,4,3,1,1,2,3,4,2,3,1,1,4,4,3,4,2,4,4,1,1,3,1,3,4,1,4,4,3,3,4,3,2,1,3,2,3,2,2,2,1,1,3,1,3,1,3,4,1,4,3,2,3,3,2,1,3,3,4,2,1,4,1,4,3,4,1,3,3,3,2,3,3,4,},
        -- event_sj_zlnc = 1,
        -- hero_list = {3,1,2,4,},
        -- total_xc_data = {
        --     "5433633355561134335414551124444513344444136354631366444311554554165621543416643434655564543615624431156435446564353465415634514456544642535664115356614000462140004224600042261000544450005442000014160000156400001261000066240000560400001400000054000000440000001300000012000000160000006400000060000000600000005000000050000000300000003000000060000000300000",
        --     "4444445533644445366444453664455436646655363361443643662536433621364654145564645455644144666421445664252051653600235431004156210066662300666665001624600036226000523230000224600000444000004340000046500000455000006130000031100000311000003430000060500000500000005000000050000000400000",
        -- },

        --不要删我的测试数据（鲁智深摇中英雄消除空行）
        -- all_rate = 240,
        -- award_money = 1152000,
        -- event_lzs_data_guding = {1,1,1,1,},
        -- event_lzs_data_random = {1,3,4,2,1,3,1,4,4,3,1,2,},
        -- hero_list = {3},
        -- result = 0,
        -- total_xc_data = {"33333622331336263336555534465552555663426116614461233341411135414143153344424333244134500411331004243050002440500045200000005000"
        -- },

        -- result = 0,
        -- award_money = 1000,
        -- all_rate        = 300,
        -- event_sj_zlnc   = 3,
        -- hero_list = {
        --     [1] = 4,
        -- },
        -- total_xc_data = {
        --     [1] = "326625132255346456156134545455452135655262456654156363366346631200004000000060000000600000006000000050000000400000003000",
        --     [2] = "456252243444612526553224444646545511344561414341445335666145144354400000",
        --     [3] = "446415645111426344365443424144431233544254444134445144614456264403551610003043600020036000200000",
        --     [4] = "463424456453154263564652546654641125656516555235665542346544466400445000002450000003000000060000",
        -- },

        result = 0,
        award_money = 1560000,
        all_rate = 2600,
        event_lzs_data_guding = {
             [1] = 4,
             [2] = 4,
             [3] = 3,
             [4] = 1,
             [5] = 4,
             [6] = 2,
             [7] = 1,
             [8] = 4,
     },
        event_lzs_data_random = {
             [1] = 4,
             [2] = 1,
             [3] = 2,
             [4] = 1,
             [5] = 4,
             [6] = 1,
             [7] = 2,
             [8] = 4,
             [9] = 2,
             [10] = 4,
             [11] = 2,
             [12] = 4,
             [13] = 2,
             [14] = 3,
             [15] = 4,
             [16] = 3,
             [17] = 1,
             [18] = 1,
             [19] = 3,
             [20] = 2,
             [21] = 2,
             [22] = 2,
             [23] = 4,
             [24] = 3,
             [25] = 1,
             [26] = 2,
             [27] = 4,
             [28] = 2,
             [29] = 3,
             [30] = 3,
             [31] = 2,
             [32] = 1,
             [33] = 1,
             [34] = 3,
             [35] = 1,
             [36] = 2,
             [37] = 4,
             [38] = 2,
             [39] = 3,
             [40] = 4,
             [41] = 1,
             [42] = 2,
             [43] = 3,
             [44] = 1,
     },
         event_sj_zlnc = 2,
         hero_list = {
             [1] = 3,
             [2] = 4,
             [3] = 1,
         },
        total_xc_data = {
             [1] = "14555645455552354565653553666244546424444445256645363416461444424425544465245455463232435454642645454165606466415065666500332660001022600000062000000600000006000000020000000600000001000000020000000200",
             [2] = "4432654444465346445656241243436142455114652145534456436246145552",
             [3] = "46644246453441434534653244446435544466536464445644644456642666166421554621335434636264241466246516524404212244060412120601161400010466000603400000041000000540000002300000025000",
     },
    }
    return data
end

function M.quit_game(call, quit_msg_call)
    Network.SendRequest("xxl_shuihu_quit_game", nil, "请求退出", function (data)
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

M.Manually = false --手动消除
return M
