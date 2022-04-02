ext_require_audio("Game.normal_ddz_common.Lua.audio_ddz_config","ddz")
--MillionLogic
package.loaded["Game.game_DdzMillion.Lua.normal_ddz_func_lib"] = nil

package.loaded["Game.game_DdzMillion.Lua.DdzMillionModel"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionModel"

package.loaded["Game.game_DdzMillion.Lua.DdzMillionPlayersActionManger"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionPlayersActionManger"

package.loaded["Game.game_DdzMillion.Lua.DdzMillionActionUiManger"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionActionUiManger"

package.loaded["Game.game_DdzMillion.Lua.DdzMillionMyCardUiManger"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionMyCardUiManger"


package.loaded["Game.game_DdzMillion.Lua.DdzMillionHallPanel"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionHallPanel"
package.loaded["Game.game_DdzMillion.Lua.DdzMillionWaitPanel"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionWaitPanel"

package.loaded["Game.game_DdzMillion.Lua.DdzMillionGamePanel"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionGamePanel"

package.loaded["Game.game_DdzMillion.Lua.DdzMillionAwardPanel"] = nil
require "Game.game_DdzMillion.Lua.DdzMillionAwardPanel"

package.loaded["Game.normal_ddz_common.Lua.normal_ddz_func_lib"] = nil
require "Game.normal_ddz_common.Lua.normal_ddz_func_lib"

package.loaded["Game.normal_ddz_common.Lua.DdzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzDzCard"] = nil
require "Game.normal_ddz_common.Lua.DdzDzCard"

package.loaded["Game.normal_ddz_common.Lua.DdzCardTag"] = nil
require "Game.normal_ddz_common.Lua.DdzCardTag"

package.loaded["Game.normal_ddz_common.Lua.DDZAnimation"] = nil
require "Game.normal_ddz_common.Lua.DDZAnimation"

package.loaded["Game.normal_ddz_common.Lua.DDZParticleManager"] = nil
require "Game.normal_ddz_common.Lua.DDZParticleManager"

package.loaded["Game.normal_ddz_common.Lua.DdzHelpPanel"] = nil
require "Game.normal_ddz_common.Lua.DdzHelpPanel"

DdzMillionLogic={}

--当前位置
--[[
	大厅
	--
	等待开始
	--
	等待桌子
	--
	比赛

{name  ,instance}
]]
local panelNameMap={
	hall="DdzMillionHallPanel",
	wait="DdzMillionWaitPanel",
	game="DdzMillionGamePanel",
	award="DdzMillionAwardPanel",
}
local cur_loc
local cur_panel 
local cup_panel
local this 

--自己关心的事件
local lister

local is_allow_forward=false
--view关心的事件
local viewLister={}
local have_Jh
local jh_name="ddz_million_jh"
--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister={}
    --需要切换panel的消息
    lister["dbwgModel_dbwg_begin_msg"] = this.on_dbwg_begin_msg
    lister["dbwgModel_dbwg_gameover_msg"] = this.on_dbwg_gameover_msg
    --response
    lister["dbwgModel_dbwg_signup_response"] = this.on_dbwg_signup_response
    lister["dbwgModel_dbwg_cancel_signup_response"] = this.on_dbwg_cancel_signup_response
	lister["dbwgModel_dbwg_discard_msg_response"] =  this.dbwgModel_dbwg_discard_msg_response

    lister["dbwgModel_dbwg_statusNo_error_msg"] = this.on_statusNo_error_msg
    lister["dbwgModel_dbwg_status_info"] = this.on_dbwg_status_info
    lister["dbwgModel_dbwg_all_info"] = this.on_dbwg_all_info

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

function DdzMillionLogic.setViewMsgRegister(lister,registerName)
	--检测是否已经注册
	if not registerName or viewLister[registerName] then
		return false
	end
	viewLister[registerName]=lister
	ViewMsgRegister(registerName)
end
function DdzMillionLogic.clearViewMsgRegister(registerName)
	cancelViewMsgRegister(registerName)
	viewLister[registerName]=nil
end

function DdzMillionLogic.change_panel(panelName)
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
		if panelName==panelNameMap.hall then
			cur_panel={name=panelName,instance=DdzMillionHallPanel.Create()}
		elseif panelName==panelNameMap.wait then
			cur_panel={name=panelName,instance=DdzMillionWaitPanel.Create()}
		elseif panelName==panelNameMap.game then
			cur_panel={name=panelName,instance=DdzMillionGamePanel.Create()}
		elseif panelName==panelNameMap.award then
			cur_panel={name=panelName,instance=DdzMillionAwardPanel.Create()}
		end
	end
	--cur_panel=MillionPanel.Show(load_callback)
end


function DdzMillionLogic.on_dbwg_signup_response(result)
	--切换 等待开始界面  
	DdzMillionLogic.change_panel(panelNameMap.wait)
end
function DdzMillionLogic.on_dbwg_cancel_signup_response(result)
	DdzMillionLogic.change_panel(panelNameMap.hall)
end


function DdzMillionLogic.on_dbwg_begin_msg()
	--切换到 等待游戏界面 
	DdzMillionLogic.change_panel(panelNameMap.game)
end	

function DdzMillionLogic.on_dbwg_gameover_msg()
	--切换到 大结算界面
	DdzMillionLogic.change_panel(panelNameMap.award)
end
--处理 请求收到所有数据消息
function DdzMillionLogic.on_dbwg_all_info()
	--取消限制
	DdzMillionModel.data.limitDealMsg=nil
	--
	local go_to
	--根据状态数据创建相应的panel
	if DdzMillionModel.data.status==nil then
		--大厅界面
		go_to=panelNameMap.hall
	elseif DdzMillionModel.data.status==million_status.wait_begin then
		--等待开始界面
		go_to=panelNameMap.wait
	elseif DdzMillionModel.data.status==million_status.gameover then
		--大结算界面
		go_to=panelNameMap.award
	else
		--游戏界面
		go_to=panelNameMap.game
	end
	DdzMillionLogic.change_panel(go_to)
	is_allow_forward=true
	--恢复监听
	ViewMsgRegister()
end
--处理状态数据
function DdzMillionLogic.on_dbwg_status_info()

	--if  如果数据已经齐全 then
			--根据状态数据创建相应的panel
	--else 
			--请求除状态数据以外的所有数据



end

local function SendRequestAllInfo()
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	--限制处理消息  此时只处理指定的消息
	DdzMillionModel.data.limitDealMsg={dbwg_all_info=true}
	Network.SendRequest("dbwg_req_info_by_send",{type="all"})
end


--断线重连相关**************
--状态错误处理
function DdzMillionLogic.on_dbwg_status_error_msg()
	--断开view model
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台重进入消息
function DdzMillionLogic.on_backgroundReturn_msg()
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台消息
function DdzMillionLogic.on_background_msg()
	cancelViewMsgRegister()
end
--游戏网络破损消息
function DdzMillionLogic.on_network_error_msg()
	cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function DdzMillionLogic.on_network_repair_msg()
	
end
--游戏网络状态差
function DdzMillionLogic.on_network_poor_msg()
	
end
--游戏重新连接消息
function DdzMillionLogic.on_reconnect_msg()
	--请求ALL数据
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	SendRequestAllInfo()
end
--断线重连相关**************

--初始化
function DdzMillionLogic.Init()
	this=DdzMillionLogic
	--初始化model
	local model = DdzMillionModel.Init()
	MakeLister()
	AddMsgListener(lister)
	
	SysInteractiveChatManager.InitLogic(model)
	SysInteractiveAniManager.InitLogic(model)
	--在大厅
	if not MainModel.Location then
		is_allow_forward=true
	else
		have_Jh=jh_name

		FullSceneJH.Create("正在请求数据",have_Jh)
		--请求ALL数据
		SendRequestAllInfo()
	end
	DdzMillionLogic.change_panel(panelNameMap.hall)
end
function DdzMillionLogic.Exit()
	if this then
		SysInteractiveChatManager.ExitLogic()
		SysInteractiveAniManager.ExitLogic()
		this=nil
		if cur_panel then 
			cur_panel.instance:MyExit()
		end
		cur_panel = nil
		RemoveMsgListener(lister)
		clearAllViewMsgRegister()

		DdzMillionModel.Exit()
	end
end

function DdzMillionLogic.dbwgModel_dbwg_discard_msg_response()
	if DdzMillionModel.data then
		local data = DdzMillionModel.data
		if data.player_num and data.min_player then
			HintPanel.Create(1,
			"由于本次比赛当前报名人数少于开赛所需人数\n本次比赛已取消",
			function ()
				ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
				MainLogic.GotoScene("game_Hall")
			end)
		end
	end
end

return DdzMillionLogic



