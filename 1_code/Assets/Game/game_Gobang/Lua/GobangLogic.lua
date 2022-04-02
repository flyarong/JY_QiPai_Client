ext_require_audio("Game.game_Gobang.Lua.audio_wzq_config","wzq")
package.loaded["Game.game_Gobang.Lua.GobangModel"] = nil
require "Game.game_Gobang.Lua.GobangModel"

package.loaded["Game.game_Gobang.Lua.GobangPanel"] = nil
require "Game.game_Gobang.Lua.GobangPanel"

package.loaded["Game.game_Gobang.Lua.GobangGamePanel"] = nil
require "Game.game_Gobang.Lua.GobangGamePanel"

package.loaded["Game.game_Gobang.Lua.GobangClearingPanel"] = nil
require "Game.game_Gobang.Lua.GobangClearingPanel"

package.loaded["Game.game_Gobang.Lua.GobangHelpPanel"] = nil
require "Game.game_Gobang.Lua.GobangHelpPanel"

GobangLogic = {}

GobangLogic.panelNameMap = {
	hall = "free_hall",
	game = "GobangGamePanel",
}

local this
local lister = {}
local viewLister = {}
local model = nil
local is_allow_forward = false
local cur_panel
local have_Jh
local jh_name = "gobang_free_game"

local function MakeLister()
	lister = {}
    --response
    lister["model_fg_signup_response"] = this.on_fg_signup_response
    lister["model_fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
	lister["model_fg_auto_cancel_signup_msg"]=this.on_fg_auto_cancel_signup_msg
	lister["model_fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg

    lister["model_fg_statusNo_error_msg"] = this.on_status_error_msg
    lister["model_fg_all_info"] = this.on_fg_all_info

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
	lister["EnterBackGround"] = this.on_background_msg


	lister["model_wzq_place_chess"] = GobangLogic.handle_wzq_place_chess
end

local function SendRequestAllInfo()
	--限制处理消息  此时只处理指定的消息
	GobangModel.data.limitDealMsg={fg_all_info=true}
	Network.SendRequest("fg_req_info_by_send",{type="all"})	
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
	lister = {}
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
		if viewLister[registerName] then 
			RemoveMsgListener(viewLister[registerName])
		end 
	else
		for k,lister in pairs(viewLister) do
			RemoveMsgListener(lister)
		end
	end
end

local function clearAllViewMsgRegister()
	cancelViewMsgRegister()
	viewLister={}
end

function GobangLogic.setViewMsgRegister(lister, registerName)
	--检测是否已经注册
	if not registerName or viewLister[registerName] then
		return false
	end
	viewLister[registerName]=lister
	ViewMsgRegister(registerName)
end

function GobangLogic.clearViewMsgRegister(registerName)
	cancelViewMsgRegister(registerName)
	viewLister[registerName] = nil
end

function GobangLogic.Init(isNotSendAllInfo)
	this = GobangLogic
	--初始化model
	model = GobangModel.Init()

	MakeLister()
	AddMsgListener(lister)

	if SysInteractiveChatManager then
		SysInteractiveChatManager.InitLogic(model)
	end
	if SysInteractiveAniManager then
		SysInteractiveAniManager.InitLogic(model)
	end

	this.locked = false

	if not isNotSendAllInfo then
		SendRequestAllInfo()
	end
	GobangLogic.change_panel(GobangLogic.panelNameMap.game)

	HandleLoadChannelLua("GobangLogic", GobangLogic)
end

function GobangLogic.Exit()
	this=nil
	if cur_panel then
		cur_panel.instance:MyExit()
	end
	cur_panel = nil

	if SysInteractiveChatManager then
		SysInteractiveChatManager.ExitLogic()
	end
	if SysInteractiveAniManager then
		SysInteractiveAniManager.ExitLogic()
	end
	RemoveMsgListener(lister)
	clearAllViewMsgRegister()
	GobangModel.Exit()
end

-- 报名成功
function GobangLogic.on_fg_signup_response(result)
	SendRequestAllInfo()
end
-- 取消报名
function GobangLogic.on_fg_cancel_signup_response(result)
	GobangLogic.change_panel(GobangLogic.panelNameMap.hall)
end

--自动取消报名，在配桌长时间没有成功的时候服务器会主动踢出玩家
function GobangLogic.on_fg_auto_cancel_signup_msg(result)
	GobangLogic.change_panel(GobangLogic.panelNameMap.hall)
end

--自动退出游戏
function GobangLogic.on_fg_auto_quit_game_msg(result)
	GobangLogic.change_panel(GobangLogic.panelNameMap.hall)
end

--处理 请求收到所有数据消息
function GobangLogic.on_fg_all_info()

	--取消限制
	GobangModel.data.limitDealMsg=nil
	local go_to
	--根据状态数据创建相应的panel
	if GobangModel.data.model_status==nil then
		--大厅界面
		go_to=GobangLogic.panelNameMap.hall
	else
		--游戏界面
		go_to=GobangLogic.panelNameMap.game
	end
	GobangLogic.change_panel(go_to)
	is_allow_forward=true
	--恢复监听
	ViewMsgRegister()
end

function GobangLogic.change_panel(panelName)
	if have_Jh then
		FullSceneJH.RemoveByTag(have_Jh)
		have_Jh=nil
	end
	if cur_panel then
		if cur_panel.name==panelName then
			cur_panel.instance:MyRefresh()
		else
			DOTweenManager.KillAllStopTween()
			cur_panel.instance:Close()
			cur_panel=nil
		end
	end
	if not cur_panel then
		if panelName==GobangLogic.panelNameMap.hall then
			GobangLogic.GotoHall()
		elseif panelName==GobangLogic.panelNameMap.game then
			cur_panel={name=panelName, instance=GobangGamePanel.Create()}
		end
	end
end

function GobangLogic.GotoHall()
	GameManager.GotoSceneName("game_Free",GobangModel.game_type)
end

--断线重连相关**************
--状态错误处理
function GobangLogic.on_status_error_msg()
	--断开view model
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	print("<color=red>状态错误处理</color>")
	--断开view model
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台重进入消息
function GobangLogic.on_backgroundReturn_msg()
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台消息
function GobangLogic.on_background_msg()
	DOTweenManager.CloseAllSequence()
	cancelViewMsgRegister()
end
--游戏网络破损消息
function GobangLogic.on_network_error_msg()
	cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function GobangLogic.on_network_repair_msg()
	
end
--游戏网络状态差
function GobangLogic.on_network_poor_msg()
	
end
--游戏重新连接消息
function GobangLogic.on_reconnect_msg()
	--请求ALL数据
	print("<color=red>游戏重新连接消息</color>")
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	SendRequestAllInfo()
end
--断线重连相关**************

function GobangLogic.quit_game(call, quit_msg_call)
    print(debug.traceback())
    Network.SendRequest("fg_quit_game", nil, "", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                GobangLogic.change_panel(panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)    
end

return GobangLogic
