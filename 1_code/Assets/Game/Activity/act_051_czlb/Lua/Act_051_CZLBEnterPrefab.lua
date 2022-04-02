-- 创建时间:2021-02-24
-- Panel:Act_051_CZLBEnterPrefab
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

Act_051_CZLBEnterPrefab = basefunc.class()
local C = Act_051_CZLBEnterPrefab
local M = Act_051_CZLBManager
C.name = "Act_051_CZLBEnterPrefab"

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
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:MyExit()
	self:KillTween()
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
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:InitBtnNodeUI()
	EventTriggerListener.Get(self.enter_btn.gameObject).onClick = basefunc.handler(self, self.OnEnterClick)
	self:MyRefresh()
end

function C:MyRefresh()
	self:RefreshLFL()
	self:RefreshRed()
end

function C:InitBtnNodeUI()
	local btn_map = {}
	btn_map["lt"] = {self.btn_1,self.btn_2,self.btn_3}
	self.game_btn_pre = GameButtonPanel.Create(btn_map, "fishing_game_lt")
    --dump(self.game_btn_pre,"<color=white>>>>>>>>>>>>self.game_btn_pre<<<<<<<<<<<<<<<<<<</color>")
	self.lf_ids = self.game_btn_pre.cur_btn_map["lt"]
	--dump(self.lf_ids,"<color=white>>>>>>>>>>>>self.lf_ids<<<<<<<<<<<<<<<<<<</color>")
	M.SetLfIds(self.lf_ids)
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
		self:on_Tween()
	end
end

function C:on_Tween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.btn_node.transform:DOLocalMoveX(100,0.25))
end

function C:off_Tween()
	self:KillTween()
	self.seq = DoTweenSequence.Create()
	self.seq:Append(self.btn_node.transform:DOLocalMoveX(-1500,0.25))
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

function C:OnExitScene()
	self:MyExit()
end