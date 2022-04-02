-- 创建时间:2021-02-23
-- Panel:RXCQPlayerPrefab
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

RXCQPlayerPrefab = basefunc.class()
local C = RXCQPlayerPrefab
C.name = "RXCQPlayerPrefab"

local Prefabs_config = {
	"RXCQPlayer1",
	"RXCQPlayer2",
}

local Hit_Anim_Config = {
	"rxcq_player_1_hit",
	"RXCQPlayer2_Hit",
}

local Run_Anim_Config = {
	"rxcq_player_1_run",
	"RXCQPlayer2_Run",
}

local Stand_Anim_Config = {
	"rxcq_player_1_stand",
	"RXCQPlayer2_Stand",
}


function C.Create(parent,prefab_index)
	return C.New(parent,prefab_index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.call_timer then
		self.call_timer:Stop()
	end
	self:RemoveListener()
	destroy(self.chuansong)
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor(parent,prefab_index)
	ExtPanel.ExtMsg(self)
	local parent = parent or GameObject.Find("Canvas/GUIRoot").transform
	self.prefab_index = prefab_index or 1
	local obj = GameObject.Instantiate(RXCQPrefabManager.GetPrefab(Prefabs_config[self.prefab_index]),parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.Animator = self.transform:GetComponent("Animator")
	self:MakeLister()
	self:AddMsgListener()
	self.RXCQShowMoneyItem = RXCQShowMoneyItem.Create(self.transform)
	self.RXCQShowMoneyItem.transform.localPosition = Vector3.New(0,200)
	self.RXCQShowMoneyItem:Hide()
end

function C:Run(use_time)
	self.WuQiNode.transform.localPosition = Vector3.New(46.7,81.5,0)
	self.Animator:Play(Run_Anim_Config[self.prefab_index])
	--
	if use_time then
		self.Animator.speed = 35/60/use_time
	else
		self.Animator.speed = 1
	end
end

function C:Hit(use_time,call)
	self.WuQiNode.transform.localPosition = Vector3.New(-1.2,90.5,0)
	self.gameObject:SetActive(false)
	self.gameObject:SetActive(true)
	self.Animator:Play(Hit_Anim_Config[self.prefab_index])
	if use_time then
		self.Animator.speed = 35/60/use_time
	else
		self.Animator.speed = 1
	end
	self:CallBack(use_time or 35/60,call)
end

function C:Stand(use_time)
	self.WuQiNode.transform.localPosition = Vector3.New(18,95,0)
	self.Animator:Play(Stand_Anim_Config[self.prefab_index])
	if use_time then
		self.Animator.speed = 1/use_time
	else
		self.Animator.speed = 1
	end
end

function C:CallBack(d_t,call)
	if not call then return end
	if self.call_timer then
		self.call_timer:Stop()
	end
	self.call_timer = Timer.New(
		function()
			call()
		end
	,d_t + 0.3 ,1,nil,true)
	RXCQModel.AddTimers(self.call_timer)
	self.call_timer:Start()
end

function C:ShowChuanSong(backcall)
	self.chuansong = GameObject.Instantiate(RXCQPrefabManager.Prefabs["RXCQ_ChuanSong_Player"],self.transform)
	self.chuansong.transform.localPosition = Vector3.New(0,0)
	self.chuansong.transform.parent = self.transform.parent
	GameObject.Destroy(self.chuansong,0.5)
	RXCQModel.DelayCall(function()
		self.gameObject:SetActive(true)
		if backcall then
			backcall()
		end
	end,0.5)
end