EliminateSGLogic = {}
ext_require_audio("Game.game_EliminateSG.Lua.audio_cbzz_config","cbzz")
package.loaded["Game.game_EliminateSG.Lua.eliminate_sg_algorithm"] = nil
require "Game.game_EliminateSG.Lua.eliminate_sg_algorithm"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGModel"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGModel"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGGamePanel"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGGamePanel"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGObjManager"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGObjManager"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGAnimManager"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGAnimManager"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGPartManager"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGPartManager"

package.loaded["Game.game_EliminateSG.Lua.EliminateSGDesPrefab"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGDesPrefab"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGMoneyPanel"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGMoneyPanel"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGHelpPanel"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGHelpPanel"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGButtonPrefab"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGButtonPrefab"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGClearPanel"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGClearPanel"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGInfoPanel"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGInfoPanel"

package.loaded["Game.game_EliminateSG.Lua.EliminateSGFreeChoosePanel"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGFreeChoosePanel"

package.loaded["Game.game_EliminateSG.Lua.EliminateSGGamePanel_ccjj"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGGamePanel_ccjj"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGHeroPanel_ccjj"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGHeroPanel_ccjj"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGInfoPanel_ccjj"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGInfoPanel_ccjj"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGMoneyPanel_ccjj"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGMoneyPanel_ccjj"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGButtonPrefab_ccjj"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGButtonPrefab_ccjj"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGDesPrefab_ccjj"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGDesPrefab_ccjj"

package.loaded["Game.game_EliminateSG.Lua.EliminateSGGamePanel_hscb"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGGamePanel_hscb"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGMoneyPanel_hscb"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGMoneyPanel_hscb"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGInfoPanel_hscb"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGInfoPanel_hscb"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGButtonPrefab_hscb"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGButtonPrefab_hscb"
package.loaded["Game.game_EliminateSG.Lua.EliminateSGDesPrefab_hscb"] = nil
require "Game.game_EliminateSG.Lua.EliminateSGDesPrefab_hscb"

local M = EliminateSGLogic
local panelNameMap = {
    hall = "hall",
    game = "EliminateSGGamePanel",
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
    lister["model_xxl_sanguo_enter_game_response"] = M.xxl_sanguo_enter_game_response
    lister["model_xxl_sanguo_quit_game_response"] = M.xxl_sanguo_quit_game_response
    lister["model_xxl_sanguo_all_info"] = M.xxl_sanguo_all_info
    lister["model_xxl_sanguo_all_info_error"] = M.xxl_sanguo_all_info_error

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
    if EliminateSGModel.data and EliminateSGModel.data.model_status == EliminateSGModel.Model_Status.gameover then
        M.xxl_sanguo_all_info()
    else
        --限制处理消息  此时只处理指定的消息
        EliminateSGModel.data.limitDealMsg = {xxl_sanguo_all_info_response = true}
        if M.is_test then
            local data = {result = 0,state = {}}--M.GetTestData("nor")
            Event.Brocast("xxl_sanguo_all_info_response","xxl_sanguo_all_info_response",data)
        else
            Network.SendRequest("xxl_sanguo_all_info",nil,"正在请求数据")
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
            GameManager.GotoUI({gotoui = "game_MiniGame"})
        elseif panelName == panelNameMap.game then
            cur_panel = {name = panelName, instance = EliminateSGGamePanel.Create()}
        end
    end
end

function M.xxl_sanguo_enter_game_response(data)
    if data.result == 0 then
        SendRequestAllInfo("enter_game")
    else
        HintPanel.ErrorMsg(data.result,function(  )
            M.change_panel(panelNameMap.hall)
        end)
    end
end

function M.xxl_sanguo_quit_game_response(data)
    if data.result == 0 then
        M.change_panel(panelNameMap.hall)
    else
        HintPanel.ErrorMsg(data.result)
    end
end

--处理 请求收到所有数据消息
function M.xxl_sanguo_all_info()
    --取消限制消息
    EliminateSGModel.data.limitDealMsg = nil
    dump(EliminateSGModel.data.model_status, "<color=yellow>model_status</color>")
    local go_to = panelNameMap.game
    --根据状态数据创建相应的panel
    if EliminateSGModel.data.model_status == nil or EliminateSGModel.data.model_status == EliminateSGModel.Model_Status.gameover then
        --大厅界面
        go_to = panelNameMap.hall
    elseif EliminateSGModel.data.model_status == EliminateSGModel.Model_Status.gaming then
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
function M.xxl_sanguo_all_info_error()
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
    EliminateSGGamePanel.ExitTimer()
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
    EliminateSGGamePanel.ExitTimer()
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
    local model = EliminateSGModel.Init()
    MakeLister()
    AddMsgListener(lister)
    update = Timer.New(M.Update, updateDt, -1, nil, true)
    update:Start()
    EliminateSGObjManager.Init()
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
    EliminateSGModel.Exit()
end

M.is_test = false
function M.GetTestData(type)
    local data = {}
    -- 火烧赤壁
    data1 = {
        result = 0,
      all_rate=1300,
      start_fire_index=5,
      fire_ship_num=18,
      xc_data="51774275535555575557111231244512444347574432377174471311551275732555417777100074",
      --"5153557575555557555777777777777777712344123441234412344123441234412344",
      -- "51774275535555575557111431244512444347574432377174471311551275732555417777100074",
      --"51774275535555575557111231244512444347574432377174471311551275732555417777100074",
      wind_data={1,0,1,0,0,0,},
      all_money=100,
      state = "hscb_2",
      is_local = true
    }
    -- 草船借箭
    data2 = {
        result = 0,
          all_rate=3500,
      tot_arrow_num=303,
      xc_data="455534445349953488539119911199199191111294494944949444448444433434334342333822aa392aa392aa399ba2292222922229c2922cc942cca12cc2422c24422211a2214a24144a411124111a4111a111431414114141141c91441918414124111145542c5b4325b4811b4a21b8a2152a1552814531a4531abc81cbca41bba41bba45508c550154501c1c01ccb04bcb04bbb04bb00cbb00c5b00c5500b2500bb500bbb00bbb0050b0020b0020000b0000b0000",
      arrow_num={27,66,10,200,},
      all_money=100,
      state = "ccjj",
      is_local = true
    }
    data3 = {
      all_rate=5500,
      free_game_rate=4500,
      xc_data="55333333313333663333236344435556345353533355235514536352243366522562362145443243443354224345342053153420255315102153414022615130243451301232153013521340144213101135651011336540303166406033355020332520303655602060156030604300101034001040360010600000004000000030000000400000",
      is_local = true,
      result = 0,
      state = "nor",
    }
    data4 = {
        result = 0,
      xc_data="72347123451234572347",
      state = "hscb_1",
      is_local = true
    }
    data5 = {
        result = 0,
      xc_data="12845128451284512845",
      state = "ccjj_cs",
      is_local = true
    }
    if type == "nor" then
        data = data3
    elseif type == "hscb_1" then
        data = data4
    elseif type == "hscb_2" then
        data = data1
    elseif type == "ccjj" then
        data = data2
    elseif type == "ccjj_cs" then
        data = data5
    end

    EliminateSGModel.data.state = data.state
    if data.state == "nor" then
        EliminateSGModel.size.max_x = 8
        EliminateSGModel.size.max_y = 8
        EliminateSGModel.size.size_x = 105
        EliminateSGModel.size.size_y = 105
        EliminateSGModel.size.spac_x = 0
        EliminateSGModel.size.spac_y = 1
    else
        EliminateSGModel.size.max_x = 5
        EliminateSGModel.size.max_y = 4
    end
    return data
end

function M.quit_game(call, quit_msg_call)
    if EliminateSGModel.data.status_lottery ~= EliminateSGModel.status_lottery.wait then
        LittleTips.Create("您当前正在游戏,请结束本局后再退出~")
        return
    end
    Network.SendRequest("xxl_sanguo_quit_game", nil, "请求退出", function (data)
        dump(data,"<color=yellow><size=15>++++++++++退出三国消消乐++++++++++</size></color>")
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                M.change_panel(panelNameMap.hall)
            else
                DOTweenManager.KillAllStopTween()
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end

return M
