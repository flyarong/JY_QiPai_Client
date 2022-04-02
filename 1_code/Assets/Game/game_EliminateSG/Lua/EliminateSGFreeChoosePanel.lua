-- 创建时间:2021-03-24
-- Panel:EliminateSGFreeChoosePanel
--[[
 *      ┌─┐       ┌─┐
 *   ┌──┘ ┴───────┘ ┴──┐
 *   │                 │
 *   │       ───       │
 *   │  ─┬┘       └┬─  │
 *   │                 │
 *   │       ─┴─       │
 *   │                 │
 *   └───┐         ┌───┘
 *       │         │
 *       │         │
 *       │         │
 *       │         └──────────────┐
 *       │                        │
 *       │                        ├─┐
 *       │                        ┌─┘
 *       │                        │
 *       └─┐  ┐  ┌───────┬──┐  ┌──┘
 *         │ ─┤ ─┤       │ ─┤ ─┤
 *         └──┴──┘       └──┴──┘
 *                神兽保佑
 *               代码无BUG!
 -- 取消按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
 -- 确认按钮音效
 -- ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
 --]]

local basefunc = require "Game/Common/basefunc"

EliminateSGFreeChoosePanel = basefunc.class()
local C = EliminateSGFreeChoosePanel
C.name = "EliminateSGFreeChoosePanel"
local type_tab = {"hscb","ccjj"}
local instance
function C.Create()
	if not instance then
		instance = C.New()
	end
	return instance
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["xxl_sanguo_start_free_game_response"] = basefunc.handler(self,self.on_xxl_sanguo_start_free_game_response)
    self.lister["xxl_sanguo_select_free_game_type_response"] = basefunc.handler(self,self.on_xxl_sanguo_select_free_game_type_response)
    self.lister["xxl_sanguo_select_free_game_type_msg"] = basefunc.handler(self,self.on_xxl_sanguo_select_free_game_type_msg)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:StopAutoTimer()
	self:RemoveListener()
	destroy(self.gameObject)
	instance = nil
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	EliminateSGModel.is_all_info = false
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	DOTweenManager.OpenPopupUIAnim(self.transform)
end


function C:InitUI()
	Event.Brocast("gamepanel_fx_set_false_msg")
	self:MyRefresh()

	self.hscb_enter_btn.onClick:AddListener(function ()
		self:selet_game(1)
	end)
	self.ccjj_enter_btn.onClick:AddListener(function ()
		self:selet_game(2)
	end )
	self:QueryTimeOut()

end

function C:MyRefresh()
	
end

function C:selet_game(index)
	if index == 1 then
		ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_hscb.audio_name)
	elseif index == 2 then
		ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_ccjj.audio_name)
	end
	Network.SendRequest("xxl_sanguo_select_free_game_type",{game_type= type_tab[index]})
end

function C:QueryTimeOut()
	dump("<color=yellow><size=15>++++++++++请求秒数++++++++++</size></color>")
	Network.SendRequest("xxl_sanguo_start_free_game")
end

function C:on_xxl_sanguo_start_free_game_response(_,data)
	dump(data,"<color=yellow><size=15>++++++++++on_xxl_sanguo_start_free_game_response++++++++++</size></color>")
	if data and data.result == 0 then
		dump(data.status_data.time_out - os.time(),"<color=yellow><size=15>++++++++++剩余秒数++++++++++</size></color>")
		self.time_out = data.status_data.time_out - os.time()--倒计时结束时间戳
		self:TimerToAutoSelet(true)
	end
end

function C:cut_down()
	--倒计时结束的处理
	local type_tab = {"hscb","ccjj"}
	local index = math.random(1,2)
	if index == 1 then
		ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_hscb.audio_name)
	elseif index == 2 then
		ExtendSoundManager.PlaySound(audio_config.cbzz.bgm_cbzz_ccjj.audio_name)
	end
	Network.SendRequest("xxl_sanguo_select_free_game_type",{game_type= type_tab[index]})
end

function C:on_xxl_sanguo_select_free_game_type_response(_,data)
	dump(data,"<color=yellow><size=15>++++++++++on_xxl_sanguo_select_free_game_type_response++++++++++</size></color>")
	if data and data.result == 0 then
		local panelName = "EliminateSGGamePanel_"..data.game_type
		if _G[panelName] and _G[panelName].Create then
			_G[panelName].Create()
			self:MyExit()
		end
	end
end

function C:TimerToAutoSelet(b)
	self:StopAutoTimer()
	if b then
		self.time_num = self.time_out - 2
		self:RefreshTimeTxt()
		self.auto_selet_timer = Timer.New(function ()
			self.time_num = self.time_num - 1
			self:RefreshTimeTxt()
			if self.time_num <= 0 then
				self:StopAutoTimer()
				self:cut_down()
			end
		end,1,-1,false)
		self.auto_selet_timer:Start()
	end
end

function C:RefreshTimeTxt()
	self.time_txt.text = self.time_num
end

function C:StopAutoTimer()
	if self.auto_selet_timer then
		self.auto_selet_timer:Stop()
		self.auto_selet_timer = nil
	end
end

function C:on_xxl_sanguo_select_free_game_type_msg(_,data)
	dump(data,"<color=yellow><size=15>++++++++++on_xxl_sanguo_select_free_game_type_msg++++++++++</size></color>")
	if data then
		local panelName = "EliminateSGGamePanel_"..data.game_type
		if _G[panelName] and _G[panelName].Create then
			_G[panelName].Create()
			self:MyExit()
		end
	end
end