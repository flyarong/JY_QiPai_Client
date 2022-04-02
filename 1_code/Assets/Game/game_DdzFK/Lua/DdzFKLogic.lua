ext_require_audio("Game.normal_ddz_common.Lua.audio_ddz_config","ddz")
require "Game.normal_ddz_common.Lua.DdzCard"
require "Game.normal_ddz_common.Lua.DdzDzCard"
require "Game.normal_ddz_common.Lua.DdzCardTag"
require "Game.normal_ddz_common.Lua.DDZAnimation"
require "Game.normal_ddz_common.Lua.DDZParticleManager"

require "Game.game_DdzFK.Lua.DdzFKModel"
require "Game.game_DdzFK.Lua.DdzFKGamePanel"

require "Game.game_DdzFK.Lua.DdzFKPlayersActionManger"
require "Game.game_DdzFK.Lua.DdzFKActionUiManger"
require "Game.game_DdzFK.Lua.DdzFKMyCardUiManger"
require "Game.game_DdzFK.Lua.DdzFKClearing"

package.loaded["Game.normal_ddz_common.Lua.DdzHelpPanel"] = nil
require "Game.normal_ddz_common.Lua.DdzHelpPanel"

DdzFKLogic={}

--当前位置
--[[
	自由场
	--
	等待开始
	--
	等待桌子
	--
	比赛

{name  ,instance}
]]
local panelNameMap = {
	game = "DdzFKGamePanel",
}

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
local jh_name = "ddz_laizi_jh"

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --response
    lister["dfgModel_nor_ddz_nor_signup_response"] = this.on_nor_ddz_nor_signup_response
    lister["dfgModel_nor_ddz_nor_cancel_signup_response"] = this.on_nor_ddz_nor_cancel_signup_response
    lister["dfgModel_nor_ddz_nor_statusNo_error_msg"] = this.on_status_error_msg
    lister["dfgModel_nor_ddz_nor_status_info"] = this.on_nor_ddz_nor_status_info
    lister["model_friendgame_all_info"] = this.on_friendgame_all_info

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg
    lister["EnterForeGround"] = this.on_backgroundReturn_msg
    lister["EnterBackGround"] = this.on_background_msg
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

function DdzFKLogic.setViewMsgRegister(lister,registerName)
	--检测是否已经注册
	if not registerName or viewLister[registerName] then
		return false
	end
	viewLister[registerName]=lister
	ViewMsgRegister(registerName)
end
function DdzFKLogic.clearViewMsgRegister(registerName)
	print("<color=red>registerName = " .. registerName .. "</color>")
	cancelViewMsgRegister(registerName)
	viewLister[registerName]=nil
end


function DdzFKLogic.refresh_panel()
	if cur_panel then
		cur_panel.instance:MyRefresh()
	end
end

function DdzFKLogic.change_panel(panelName)
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
		if panelName==panelNameMap.game then
			cur_panel={name=panelName,instance=DdzFKGamePanel.Create()}
		else
			print("<color=red>Error: 没有界面</color>")
		end
	end
end

function DdzFKLogic.get_cur_panel()
	if cur_panel then
		return cur_panel.instance
	end
	return nil
end


function DdzFKLogic.on_nor_ddz_nor_signup_response(result)
	this.change_panel(panelNameMap.game)
	-- DdzFKClearing.Close()
end
function DdzFKLogic.on_nor_ddz_nor_cancel_signup_response(result)
	MainLogic.GotoScene("game_Hall")
end

--处理状态数据
function DdzFKLogic.on_nor_ddz_nor_status_info()

	--if  如果数据已经齐全 then
		--根据状态数据创建相应的panel
	--else
		--请求除状态数据以外的所有数据
	--end

end

--处理 请求收到所有数据消息
function DdzFKLogic.on_friendgame_all_info()
	--取消限制消息
	DdzFKModel.data.limitDealMsg=nil

	this.change_panel(panelNameMap.game)
	is_allow_forward=true
	--恢复监听
	ViewMsgRegister()
end

local function SendRequestAllInfo()
	if DdzFKModel.data and DdzFKModel.data.status==DdzFKModel.Status.gameover then
		DdzFKLogic.on_friendgame_all_info()
	else
		--限制处理消息  此时只处理指定的消息
		DdzFKModel.data.limitDealMsg={friendgame_all_info=true}
		Network.SendRequest("friendgame_req_info_by_send",{type="all"}, function (data)
			dump(data, "<color=red> SendRequestAllInfo XXXXXXXXXXXX</color>")
		end)
	end
end

--断线重连相关**************
--状态错误处理
function DdzFKLogic.on_status_error_msg()
	--断开view model
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台重进入消息
function DdzFKLogic.on_backgroundReturn_msg()
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台消息
function DdzFKLogic.on_background_msg()
	cancelViewMsgRegister()
end
--游戏网络破损消息
function DdzFKLogic.on_network_error_msg()
	cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function DdzFKLogic.on_network_repair_msg()
	
end
--游戏网络状态差
function DdzFKLogic.on_network_poor_msg()
	
end
--游戏重新连接消息
function DdzFKLogic.on_reconnect_msg()
	--请求ALL数据
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	SendRequestAllInfo()
end
--断线重连相关**************

function DdzFKLogic.Update()

end
--初始化
function DdzFKLogic.Init()
	GPSPanel.send_gps_info()
	this=DdzFKLogic
	--初始化model
	local model = DdzFKModel.Init()
	GameVoiceLogic.Init(model)

	SysInteractiveChatManager.InitLogic(model)
	SysInteractiveAniManager.InitLogic(model)

	MakeLister()
	AddMsgListener(lister)
	update=Timer.New(this.Update,updateDt,-1)
	update:Start()

	--请求ALL数据
	SendRequestAllInfo()
	DdzFKLogic.change_panel(panelNameMap.game)
end
function DdzFKLogic.Exit()
	if this then
		SysInteractiveChatManager.ExitLogic()
		SysInteractiveAniManager.ExitLogic()

		this=nil
		update:Stop()
		update=nil
		if cur_panel then
			cur_panel.instance:MyExit()
		end
		cur_panel = nil
		RemoveMsgListener(lister)
		clearAllViewMsgRegister()
		DdzFKModel.Exit()
		GameVoiceLogic.Exit()
	end
end

return DdzFKLogic














