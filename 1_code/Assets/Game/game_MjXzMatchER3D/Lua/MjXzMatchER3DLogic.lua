ext_require_audio("Game.normal_mj_common.Lua.audio_mj_config","mj")
package.loaded["Game.game_MjXzMatchER3D.Lua.MjXzMatchER3DModel"] = nil
require "Game.game_MjXzMatchER3D.Lua.MjXzMatchER3DModel"

package.loaded["Game.normal_mj_common.Lua.normal_majiang_lib"] = nil
normal_majiang = require "Game.normal_mj_common.Lua.normal_majiang_lib"

package.loaded["Game.normal_mj_common.Lua.MjAnimation"] = nil
require "Game.normal_mj_common.Lua.MjAnimation"

package.loaded["Game.normal_mj_common.Lua.MJParticleManager"] = nil
require "Game.normal_mj_common.Lua.MJParticleManager"

package.loaded["Game.game_MjXzMatchER3D.Lua.MjXzMatchERGamePanel3D"] = nil
require "Game.game_MjXzMatchER3D.Lua.MjXzMatchERGamePanel3D"

package.loaded["Game.normal_mj_common.Lua.MjMyShouPaiManger3D"] = nil
require "Game.normal_mj_common.Lua.MjMyShouPaiManger3D"

package.loaded["Game.normal_mj_common.Lua.MjShouPaiManger3D"] = nil
require "Game.normal_mj_common.Lua.MjShouPaiManger3D"

package.loaded["Game.game_MjXzMatchER3D.Lua.MjXzMatchERClearing3D"] = nil
require "Game.game_MjXzMatchER3D.Lua.MjXzMatchERClearing3D"

package.loaded["Game.normal_mj_common.Lua.MjCard"] = nil
require "Game.normal_mj_common.Lua.MjCard"

package.loaded["Game.normal_mj_common.Lua.MjCard3D"] = nil
require "Game.normal_mj_common.Lua.MjCard3D"

package.loaded["Game.game_MjXzMatchER3D.Lua.MjXzMatchERPlayerManger3D"] = nil
require "Game.game_MjXzMatchER3D.Lua.MjXzMatchERPlayerManger3D"

package.loaded["Game.game_MjXzMatchER3D.Lua.MjXzMatchERPairdesk3D"] = nil
require "Game.game_MjXzMatchER3D.Lua.MjXzMatchERPairdesk3D"

package.loaded["Game.game_MjXzMatchER3D.Lua.MjXzMatchERGangsRect3D"] = nil
require "Game.game_MjXzMatchER3D.Lua.MjXzMatchERGangsRect3D"

package.loaded["Game.normal_mj_common.Lua.MjPgManager3D"] = nil
require "Game.normal_mj_common.Lua.MjPgManager3D"

package.loaded["Game.normal_mj_common.Lua.MjYiChuPaiManager3D"] = nil
require "Game.normal_mj_common.Lua.MjYiChuPaiManager3D"

package.loaded["Game.normal_mj_common.lua.MJSharePrefab"] = nil
require "Game.normal_mj_common.lua.MJSharePrefab"

package.loaded["Game.normal_mj_common.Lua.MjHelpPanel"] = nil
require "Game.normal_mj_common.Lua.MjHelpPanel"

package.loaded["Game.normal_mj_common.Lua.MjDeskCenterManager3D"] = nil
require "Game.normal_mj_common.Lua.MjDeskCenterManager3D"

package.loaded["Game.normal_commatch_common.Lua.ComMatchLogic"] = nil
require "Game.normal_commatch_common.Lua.ComMatchLogic"

MjXzLogic={}

MjXzLogic.panelNameMap = {
	hall = "hall",
	game = "game",
}

MjXzLogic.game_type = {
	nor_mj_xzdd = "nor_mj_xzdd",               ---- 血战到底
	nor_mj_xzdd_er_7 = "nor_mj_xzdd_er_7",     ---- 二人7张血战到底
	nor_mj_xzdd_er_13 = "nor_mj_xzdd_er_13",     ---- 二人13张血战到底
}

local cur_loc
local cur_panel 

local this 
local updateDt=1
-- Logic 的 Update
local update
--请求报名人数间隔
local req_sign_num_inval=3
local req_sign_num_count=0
--自己关心的事件
local lister

local is_allow_forward=false
--view关心的事件
local viewLister={}
local have_Jh
--菊花的名字
local jh_name="mjxz_fg_jh"
--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --response
    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
	lister["DisconnectServerConnect"] = this.on_network_error_msg
	
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
	lister["EnterBackGround"] = this.on_background_msg
	
    --需要切换panel的消息
    lister["model_nor_mg_begin_msg"] = this.on_nor_mg_begin_msg
	lister["model_nor_mg_gameover_msg"] = this.on_nor_mg_gameover_msg
	lister["model_nor_mg_auto_cancel_signup_msg"] = this.on_nor_mg_auto_cancel_signup_msg

    --response
    lister["model_nor_mg_signup_response"] = this.on_nor_mg_signup_response
    lister["model_nor_mg_cancel_signup_response"] = this.on_nor_mg_cancel_signup_response

    lister["model_nor_mg_statusNo_error_msg"] = this.on_nor_mg_status_error_msg
    lister["model_nor_mg_all_info"] = this.on_nor_mg_all_info
    lister["model_nor_mg_match_discard_msg"] = this.on_nor_mg_match_discard_msg
end

local function AddMsgListener(lister)
    for proto_name,func in pairs(lister) do
        Event.AddListener(proto_name, func)
    end
end

local function RemoveMsgListener(lister)
    for proto_name,func in pairs(lister) do
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
			for k,lister in pairs(viewLister) do
				AddMsgListener(lister)
			end
		end
	end
end

local function cancelViewMsgRegister(registerName)
	if  registerName then
		if viewLister and viewLister[registerName] then 
			RemoveMsgListener(viewLister[registerName])
		end 
	else
		if viewLister then
			for k,lister in pairs(viewLister) do
				RemoveMsgListener(lister)
			end
		end
	end
	DOTweenManager.KillAllStopTween()
end

local function clearAllViewMsgRegister()
	cancelViewMsgRegister()
	viewLister={}
end

local function SendRequestAllInfo()
	if MjXzModel.data and MjXzModel.data.model_status==MjXzModel.Model_Status.gameover then
		MjXzLogic.on_nor_mg_all_info()
	else
		--限制处理消息  此时只处理指定的消息
		MjXzModel.data.limitDealMsg={nor_mg_all_info=true}
		Network.SendRequest("nor_mg_req_info_by_send",{type="all"})		
	end
end

function MjXzLogic.setViewMsgRegister(lister,registerName)
	--检测是否已经注册
	if not registerName or viewLister[registerName] then
		return false
	end
	viewLister[registerName]=lister
	ViewMsgRegister(registerName)
end
function MjXzLogic.clearViewMsgRegister(registerName)
	if not registerName then 
		return false
	end
	cancelViewMsgRegister(registerName)
	viewLister[registerName]=nil
end

function MjXzLogic.change_panel(panelName)
	if have_Jh then
		FullSceneJH.RemoveByTag(have_Jh)
		have_Jh=nil
	end
	if cur_panel then
		if cur_panel.name==panelName then
			cur_panel.instance:MyRefresh()
		else
			DOTweenManager.KillAllStopTween()
			cur_panel.instance:MyClose()
			cur_panel=nil
		end
	end
	if not cur_panel then
		if panelName==MjXzLogic.panelNameMap.hall then
			local hall_type = MatchModel.GetCurHallType()
            local parm = {hall_type = hall_type}
            --GameManager.GotoUI({gotoui = GameConfigToSceneCfg.game_MatchHall.SceneName,goto_scene_parm = parm})
            GameManager.GotoSceneName("game_MatchHall")
		elseif panelName==MjXzLogic.panelNameMap.game then
			cur_panel={name=panelName,instance=MjXzGamePanel.Create()}
		end
	end
end

--断线重连相关**************
--状态错误处理

--游戏后台重进入消息
function MjXzLogic.on_backgroundReturn_msg()
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台消息
function MjXzLogic.on_background_msg()
	DOTweenManager.CloseAllSequence()
	cancelViewMsgRegister()
end
--游戏网络破损消息
function MjXzLogic.on_network_error_msg()
	cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function MjXzLogic.on_network_repair_msg()
	
end
--游戏网络状态差
function MjXzLogic.on_network_poor_msg()
	
end
--游戏重新连接消息
function MjXzLogic.on_reconnect_msg()
	--请求ALL数据
	print("<color=red>游戏重新连接消息</color>")
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	SendRequestAllInfo()
end
--断线重连相关**************

function MjXzLogic.Update()
	if MjXzModel.data and MjXzModel.data.model_status==MjXzModel.Model_Status.wait_begin  then
		req_sign_num_count=req_sign_num_count+updateDt
		if req_sign_num_count>=req_sign_num_inval then
			req_sign_num_count=0
			Network.SendRequest("nor_mg_req_cur_signup_num")
		end
	end
end
--初始化
function MjXzLogic.Init(isNotSendAllInfo)
	this=MjXzLogic
	--初始化model
	local model = MjXzModel.Init()
	MakeLister()
	AddMsgListener(lister)
	update=Timer.New(MjXzLogic.Update,updateDt,-1)
	update:Start()

	SysInteractiveChatManager.InitLogic(model)
	SysInteractiveAniManager.InitLogic(model)

	have_Jh = jh_name
    FullSceneJH.Create("正在请求数据", have_Jh)
    --请求ALL数据
    if not isNotSendAllInfo then
        SendRequestAllInfo()
    end
	print("<color=yellow>----------------- MjXzMatchER3DLogic.Init --------------- </color>")
	MjXzLogic.change_panel(MjXzLogic.panelNameMap.game)

end
function MjXzLogic.Exit()

	this=nil
	update:Stop()
	update=nil
	if cur_panel then
		cur_panel.instance:MyExit()
	end
	cur_panel = nil

	SysInteractiveChatManager.ExitLogic()
	SysInteractiveAniManager.ExitLogic()
	RemoveMsgListener(lister)
	clearAllViewMsgRegister()
	MjXzModel.Exit()
end

--------------------------------------------------------------------------------------------
function MjXzLogic.on_nor_mg_begin_msg()
	--切换到 等待游戏界面 
	MjXzLogic.change_panel(MjXzLogic.panelNameMap.game)
end	

function MjXzLogic.on_nor_mg_gameover_msg()
	--切换到 大结算界面
end

function MjXzLogic.on_nor_mg_auto_cancel_signup_msg(result)
	print("--------------------- on_nor_mg_auto_cancel_signup_msg -----------------------")
	MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)
end

function MjXzLogic.on_nor_mg_signup_response(result)
	if result == 0 then
        SendRequestAllInfo()
	else
		HintPanel.ErrorMsg(result,function (  )
			MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)
		end)
	end
end

function MjXzLogic.on_nor_mg_cancel_signup_response(result)
	MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)
end

--断线重连相关**************
--状态错误处理
function MjXzLogic.on_nor_mg_status_error_msg()
	--断开view model
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end


--处理 请求收到所有数据消息
function MjXzLogic.on_nor_mg_all_info()
	--取消限制消息
	MjXzModel.data.limitDealMsg=nil
	local go_to
	--根据状态数据创建相应的panel
	if MjXzModel.data.model_status==nil then
		--print("<color=red>不可能为空</color>")
		go_to=MjXzLogic.panelNameMap.hall
		
	else
		--游戏界面
		go_to=MjXzLogic.panelNameMap.game
	end
	MjXzLogic.change_panel(go_to)
	is_allow_forward=true
	--恢复监听
	ViewMsgRegister()
end

function MjXzLogic.on_nor_mg_match_discard_msg(data)
    local cur_config = MatchModel.GetGameCfg()
    local str = string.format( "参加 %s 的人数不足，比赛已取消", cur_config.game_name)
    HintPanel.Create(1, str, function()
        MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)
    end)
end

function MjXzLogic.quit_game(call, quit_msg_call)
    Network.SendRequest("nor_mg_quit_game", nil, "请求退出", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                MjXzLogic.change_panel(L.panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)
end
return MjXzLogic














