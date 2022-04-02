ext_require_audio("Game.normal_ddz_common.Lua.audio_ddz_config","ddz")
require "Game.normal_ddz_common.Lua.DdzTyCard"
require "Game.game_DdzTy.Lua.DdzTyDzCard"
require "Game.normal_ddz_common.Lua.DdzCardTag"
require "Game.normal_ddz_common.Lua.DDZAnimation"
package.loaded["Game.normal_ddz_common.Lua.DDZParticleManager"] = nil
require "Game.normal_ddz_common.Lua.DDZParticleManager"

require "Game.game_DdzTy.Lua.DdzTyModel"
require "Game.game_DdzTy.Lua.DdzTyHallPanel"
require "Game.game_DdzTy.Lua.DdzTyGamePanel"

require "Game.game_DdzTy.Lua.DdzTyPlayersActionManger"
require "Game.game_DdzTy.Lua.DdzTyActionUiManger"
require "Game.game_DdzTy.Lua.DdzTyMyCardUiManger"
require "Game.game_DdzTy.Lua.DdzTyClearing"
require "Game.normal_ddz_common.Lua.DDZSharePrefab"
require "Game.normal_ddz_common.Lua.DdzHelpPanel"

DdzTyLogic={}

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
	hall = "DdzTyHallPanel",
	game = "DdzTyGamePanel",
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
local jh_name = "ddz_Ty_jh"

--构建斗地主正常逻辑的消息事件（断线重连部分不在这里绑定）
local function MakeLister()
    lister = {}
    --response
    lister["tydfgModel_tydfg_signup_response"] = this.on_tydfg_signup_response
    lister["tydfgModel_tydfg_cancel_signup_response"] = this.on_tydfg_cancel_signup_response
    lister["tydfgModel_tydfg_auto_cancel_signup_msg"] = this.on_tydfg_auto_cancel_signup_msg
    
    lister["tydfgModel_tydfg_statusNo_error_msg"] = this.on_statusNo_error_msg
    lister["tydfgModel_tydfg_status_info"] = this.on_tydfg_status_info
    lister["tydfgModel_tydfg_all_info"] = this.on_tydfg_all_info

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

function DdzTyLogic.setViewMsgRegister(lister,registerName)
	--检测是否已经注册
	if not registerName or viewLister[registerName] then
		return false
	end
	viewLister[registerName]=lister
	ViewMsgRegister(registerName)
end
function DdzTyLogic.clearViewMsgRegister(registerName)
	cancelViewMsgRegister(registerName)
	viewLister[registerName]=nil
end

function DdzTyLogic.change_panel(panelName)
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
			cur_panel={name=panelName,instance=DdzTyHallPanel.Create()}
		elseif panelName==panelNameMap.game then
			cur_panel={name=panelName,instance=DdzTyGamePanel.Create()}
		end
	end
end

function DdzTyLogic.get_cur_panel()
	if cur_panel then
		return cur_panel.instance
	end
	return nil
end


function DdzTyLogic.on_tydfg_signup_response(result)
	print("[DDZ Ty] Logic on_tydfg_signup_response open gamePanel")
	--切换 等待开始界面
	this.change_panel(panelNameMap.game)
	DdzTyClearing.Close()
end
function DdzTyLogic.on_tydfg_cancel_signup_response(result)
	this.change_panel(panelNameMap.hall)
end

function DdzTyLogic.on_tydfg_auto_cancel_signup_msg(result)
	this.change_panel(panelNameMap.hall)
end

--处理状态数据
function DdzTyLogic.on_tydfg_status_info()

	--if  如果数据已经齐全 then
		--根据状态数据创建相应的panel
	--else
		--请求除状态数据以外的所有数据
	--end

end

--处理状态数据
function DdzTyLogic.on_statusNo_error_msg()
	
end

--处理 请求收到所有数据消息
function DdzTyLogic.on_tydfg_all_info()
	--取消限制
	DdzTyModel.data.limitDealMsg=nil
	
	local status = DdzTyModel.data.status
	local go_to
	--根据状态数据创建相应的panel
	if status==nil then
		--大厅界面
		go_to=panelNameMap.hall
	elseif status==macth_status.wait_begin then
		--等待开始界面
		go_to=panelNameMap.wait
	elseif status==macth_status.gameover then
		--大结算界面
		go_to=panelNameMap.game
	else
		--游戏界面
		go_to=panelNameMap.game
	end
	this.change_panel(go_to)
	is_allow_forward=true
	--恢复监听
	ViewMsgRegister()
end


local function SendRequestAllInfo()
	if DdzTyModel.data and DdzTyModel.data.status==macth_status.gameover then
		DdzTyLogic.on_tydfg_all_info()
	else
		--限制处理消息  此时只处理指定的消息
		DdzTyModel.data.limitDealMsg={tydfg_all_info=true}
		Network.SendRequest("tydfg_req_info_by_send",{type="all"})
	end
end
--断线重连相关**************
--状态错误处理
function DdzTyLogic.on_status_error_msg()
	--断开view model
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台重进入消息
function DdzTyLogic.on_backgroundReturn_msg()
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台消息
function DdzTyLogic.on_background_msg()
	cancelViewMsgRegister()
end
--游戏网络破损消息
function DdzTyLogic.on_network_error_msg()
	cancelViewMsgRegister()
end
--游戏网络状态恢复消息
function DdzTyLogic.on_network_repair_msg()
	
end
--游戏网络状态差
function DdzTyLogic.on_network_poor_msg()
	
end
--游戏重新连接消息
function DdzTyLogic.on_reconnect_msg()
	--请求ALL数据
	if not have_Jh then
		have_Jh=jh_name
		FullSceneJH.Create("正在请求数据",have_Jh)
	end
	SendRequestAllInfo()
end
--断线重连相关**************

function DdzTyLogic.Update()

end
--初始化
function DdzTyLogic.Init()
	this=DdzTyLogic
	--初始化model
	local model = DdzTyModel.Init()
	MakeLister()
	AddMsgListener(lister)
	update=Timer.New(this.Update,updateDt,-1)
	update:Start()
	
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
	this.change_panel(panelNameMap.hall)
end
function DdzTyLogic.Exit()
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
		DdzTyModel.Exit()
	end
end

function DdzTyLogic.quit_game(call, quit_msg_call)
    print(debug.traceback())
    Network.SendRequest("tydfg_quit_game", nil, "", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                DdzTyLogic.change_panel(panelNameMap.hall)
            else
                call()
            end
        end
    end)    
end

return DdzTyLogic














