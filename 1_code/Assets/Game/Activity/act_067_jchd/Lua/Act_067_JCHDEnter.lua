-- 创建时间:2021-09-16
-- Panel:Act_067_JCHDEnter
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

Act_067_JCHDEnter = basefunc.class()
local C = Act_067_JCHDEnter
C.name = "Act_067_JCHDEnter"
local M = Act_067_JCHDManager

function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self,self.on_global_hint_state_change_msg)
	self.lister["view_fg_gameover_msg"] = basefunc.handler(self, self.on_view_fg_gameover_msg)
	self.lister["fg_close_clearing"] = basefunc.handler(self, self.on_fg_close_clearing)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if not table_is_null(self.game_btn_pre) then
		self.game_btn_pre:MyExit()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.isInGame = true

	
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	if DdzFreeClearing and DdzFreeModel and DdzFreeModel.data and (DdzFreeModel.data.status == DdzFreeModel.Status.settlement or DdzFreeModel.data.status == DdzFreeModel.Status.gameover) then
		self.isInGame = false
	end
	
	if MjXzClearing and MjXzModel and MjXzModel.data and (MjXzModel.data.status == MjXzModel.Status.settlement or MjXzModel.data.status == MjXzModel.Status.gameover) then
		self.isInGame = false
	end
end

function C:InitUI()
	local btn_map = {}
	btn_map["left"] = {self.btn_1,self.btn_2,self.btn_3,self.btn_4,self.btn_5}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "ddz_free_game_l")
    --dump(self.game_btn_pre,"<color=white>>>>>>>>>>>>self.game_btn_pre<<<<<<<<<<<<<<<<<<</color>")
	self.lf_ids = self.game_btn_pre.cur_btn_map["left"]
	--dump(self.lf_ids,"<color=white>>>>>>>>>>>>self.lf_ids<<<<<<<<<<<<<<<<<<</color>")
	if table_is_null(self.lf_ids) then
		self:MyExit()
		return
	end
	M.SetLfIds(self.lf_ids)
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshLFL()
	self:RefreshRed()
end

function C:RefreshLFL()
	self.lfl_state = false
	for i = 1, #self.lf_ids do
		if M.IsGetHintStatus(self.lf_ids[i]) then
			self.lfl_state = true
			break
		end
	end
	self.LFL.gameObject:SetActive(self.lfl_state)
end

function C:RefreshRed()
	self.red_state = false
	for i = 1, #self.lf_ids do
		if M.IsRedHintStatus(self.lf_ids[i]) then
			self.red_state = true
			break
		end
	end
	self.red.gameObject:SetActive(self.red_state)
end

function C:OnEnterClick()
	if self.is_on then
		self.is_on = false
		self:off_Tween()
	else
		self.is_on = true
		self:on_Tween(false)
	end
end

function C:on_view_fg_gameover_msg(clearingPanelSelf)
	if GameGlobalOnOff.IsOpenGuide and MainModel.UserInfo.xsyd_status ~= 1 and not self.isInGame then
		if IsEquals(clearingPanelSelf) then
			clearingPanelSelf.gameObject:SetActive(true)
			self:SetOnImmediately()
		end
	end
end

function C:SetOnImmediately()
	self.is_on = true
	--self.jchd_btn_node.transform.localPosition = Vector3.New(0,self.jchd_btn_node.transform.localPosition.y, 0)
	self:on_Tween(true)
end


function C:on_Tween(isGuide)
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.jchd_btn_node.transform:DOLocalMoveX(0,0.25))
	self.seq:OnKill(function()
		if isGuide then
			Event.Brocast("WQP_Guide_Check",{guide = 3 ,guide_step =1})
			if GuideLogic then
				GuideLogic.CheckRunGuide("free_js")
			end
		end
	end)
end

function C:off_Tween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.jchd_btn_node.transform:DOLocalMoveX(-1500,0.25))
end

function C:KillTween()
	if self.seq then
		self.seq:Kill()
		self.seq = nil
	end
end

function C:on_global_hint_state_change_msg(parm)
	if table_is_null(self.lf_ids) then
		return 
	end
	for i = 1, #self.lf_ids do
		if parm.gotoui == M.GetKeyFromId(self.lf_ids[i]) then
			self:MyRefresh()
		end
	end
end

function C:on_fg_close_clearing()
	self:off_Tween()
end
