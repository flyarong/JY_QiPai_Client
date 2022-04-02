ext_require_audio("Game.normal_mj_common.Lua.audio_mj_config","mj")
--MatchLogic

package.loaded["Game.game_Mj3D.Lua.Mj3DModel"] = nil
require "Game.game_Mj3D.Lua.Mj3DModel"

package.loaded["Game.normal_mj_common.Lua.normal_majiang_lib"] = nil
normal_majiang = require "Game.normal_mj_common.Lua.normal_majiang_lib"

package.loaded["Game.normal_mj_common.Lua.MjAnimation"] = nil
require "Game.normal_mj_common.Lua.MjAnimation"

package.loaded["Game.normal_mj_common.Lua.MJParticleManager"] = nil
require "Game.normal_mj_common.Lua.MJParticleManager"
package.loaded["Game.game_Mj3D.Lua.MjXzHallPanel3D"] = nil
require "Game.game_Mj3D.Lua.MjXzHallPanel3D"

package.loaded["Game.game_Mj3D.Lua.MjXzGamePanel3D"] = nil
require "Game.game_Mj3D.Lua.MjXzGamePanel3D"

package.loaded["Game.normal_mj_common.Lua.MjMyShouPaiManger3D"] = nil
require "Game.normal_mj_common.Lua.MjMyShouPaiManger3D"

package.loaded["Game.normal_mj_common.Lua.MjShouPaiManger3D"] = nil
require "Game.normal_mj_common.Lua.MjShouPaiManger3D"

package.loaded["Game.game_Mj3D.Lua.MjXzClearing3D"] = nil
require "Game.game_Mj3D.Lua.MjXzClearing3D"

package.loaded["Game.normal_mj_common.Lua.MjCard"] = nil
require "Game.normal_mj_common.Lua.MjCard"

package.loaded["Game.normal_mj_common.Lua.MjCard3D"] = nil
require "Game.normal_mj_common.Lua.MjCard3D"

package.loaded["Game.game_Mj3D.Lua.MjXzPlayerManger3D"] = nil
require "Game.game_Mj3D.Lua.MjXzPlayerManger3D"

package.loaded["Game.game_Mj3D.Lua.MjXzPairdesk3D"] = nil
require "Game.game_Mj3D.Lua.MjXzPairdesk3D"

package.loaded["Game.game_Mj3D.Lua.MjXzGangsRect3D"] = nil
require "Game.game_Mj3D.Lua.MjXzGangsRect3D"

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

package.loaded["Game.game_Mj3D.Lua.MjXzHuanZhuo3D"] = nil
require "Game.game_Mj3D.Lua.MjXzHuanZhuo3D"

package.loaded["Game.normal_mj_common.Lua.VfxCoinFly"] = nil
require "Game.normal_mj_common.Lua.VfxCoinFly"


MjXzLogic={}

MjXzLogic.panelNameMap = {
	hall = "MjXzHallPanel",
	game = "MjXzGamePanel",
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
    lister["model_fg_signup_response"] = this.on_mjfg_signup_response
    lister["model_fg_cancel_signup_response"] = this.on_fg_cancel_signup_response
	lister["model_fg_auto_cancel_signup_msg"]=this.on_fg_auto_cancel_signup_msg
	lister["model_fg_auto_quit_game_msg"] = this.on_fg_auto_quit_game_msg

    lister["model_fg_statusNo_error_msg"] = this.on_mjfg_status_error_msg
    lister["model_mjfg_status_info"] = this.on_mjfg_status_info
    lister["model_fg_all_info"] = this.on_fg_all_info

    lister["ReConnecteServerSucceed"] = this.on_reconnect_msg
    lister["DisconnectServerConnect"] = this.on_network_error_msg

    lister["EnterForeGround"] = this.on_backgroundReturn_msg
	lister["EnterBackGround"] = this.on_background_msg
	
	--资产改变
    lister["AssetChange"] = this.AssetChange
end

local function SendRequestAllInfo()
	
	--限制处理消息  此时只处理指定的消息
	MjXzModel.data.limitDealMsg={fg_all_info=true}
	Network.SendRequest("fg_req_info_by_send",{type="all"})
	
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

function MjXzLogic.refresh_panel()
    if cur_panel then
        cur_panel.instance:MyRefresh()
    end
end
function MjXzLogic.change_panel(panelName)
	-- if have_Jh then
	-- 	FullSceneJH.RemoveByTag(have_Jh)
	-- 	have_Jh=nil
	-- end
	if cur_panel then
		if cur_panel.name==panelName then
			cur_panel.instance:MyRefresh()
		--[[elseif cur_panel.name == MjXzLogic.panelNameMap.game then
			DOTweenManager.KillAllStopTween()
			cur_panel.instance:MyExit()
            cur_panel = nil--]]

		else
			DOTweenManager.KillAllStopTween()
			cur_panel.instance:MyClose()
			cur_panel=nil
		end
	end
	if not cur_panel then
		if panelName==MjXzLogic.panelNameMap.hall then
			GameManager.GotoSceneName("game_Free",MjXzModel.game_type)
		elseif panelName==MjXzLogic.panelNameMap.game then
			cur_panel={name=panelName,instance=MjXzGamePanel.Create()}
		end
	end
	
end

-- 报名成功
function MjXzLogic.on_mjfg_signup_response(result)
	SendRequestAllInfo()
	--MjXzLogic.change_panel(MjXzLogic.panelNameMap.game)
	--MjXzClearing.Close()
end
-- 取消报名
function MjXzLogic.on_fg_cancel_signup_response(result)
	MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)

end

--自动取消报名，在配桌长时间没有成功的时候服务器会主动踢出玩家
function MjXzLogic.on_fg_auto_cancel_signup_msg(result)
	MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)
end

--自动退出游戏
function MjXzLogic.on_fg_auto_quit_game_msg(result)
	MjXzLogic.change_panel(MjXzLogic.panelNameMap.hall)
end

--处理 请求收到所有数据消息
function MjXzLogic.on_fg_all_info()

	--取消限制
	MjXzModel.data.limitDealMsg=nil
	local go_to
	--根据状态数据创建相应的panel
	if MjXzModel.data.model_status==nil then
		--大厅界面
		go_to=MjXzLogic.panelNameMap.hall
	else
		--游戏界面
		go_to=MjXzLogic.panelNameMap.game
	end
	MjXzLogic.change_panel(go_to)
	is_allow_forward=true
	--恢复监听
	ViewMsgRegister()
	MjXzLogic.AssetChange()
end
--处理状态数据
function MjXzLogic.on_mjfg_status_info()

	--if  如果数据已经齐全 then
			--根据状态数据创建相应的panel
	--else 
			--请求除状态数据以外的所有数据

end



--断线重连相关**************
--状态错误处理
function MjXzLogic.on_mjfg_status_error_msg()
	--断开view model
	-- if not have_Jh then
	-- 	have_Jh=jh_name
	-- 	FullSceneJH.Create("正在请求数据",have_Jh)
	-- end
	print("<color=red>状态错误处理</color>")
	--断开view model
	cancelViewMsgRegister()
	SendRequestAllInfo()
end
--游戏后台重进入消息
function MjXzLogic.on_backgroundReturn_msg()
	-- if not have_Jh then
	-- 	have_Jh=jh_name
	-- 	FullSceneJH.Create("正在请求数据",have_Jh)
	-- end
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
	-- if not have_Jh then
	-- 	have_Jh=jh_name
	-- 	FullSceneJH.Create("正在请求数据",have_Jh)
	-- end
	SendRequestAllInfo()
end
--断线重连相关**************

--资产改变
function MjXzLogic.AssetChange()
    Event.Brocast("logic_AssetChange")
end

function MjXzLogic.Update()

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

	if not isNotSendAllInfo then
		SendRequestAllInfo()
	end
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
	--Exit()
	RemoveMsgListener(lister)
	clearAllViewMsgRegister()
	MjXzModel.Exit()


end

function MjXzLogic.GetCurPanel()
	return cur_panel
end

function MjXzLogic.quit_game(call, quit_msg_call)
    print(debug.traceback())
    Network.SendRequest("fg_quit_game", nil, "", function (data)
        if quit_msg_call then
            quit_msg_call(data.result)
        end
        if data.result == 0 then
            MainLogic.ExitGame()
            if not call then
                MjXzLogic.change_panel(panelNameMap.hall)
            else
                call()
            end
            Event.Brocast("quit_game_success")
        end
    end)    
end

return MjXzLogic














