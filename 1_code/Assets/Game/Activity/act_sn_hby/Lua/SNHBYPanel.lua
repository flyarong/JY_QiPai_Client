-- 创建时间:2019-12-30
-- Panel:SNHBYPanel
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
 --]]

local basefunc = require "Game/Common/basefunc"

SNHBYPanel = basefunc.class()
local C = SNHBYPanel
C.name = "SNHBYPanel"

function C.Create(reward)
	return C.New(reward)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end
function C:OnExitScene()
	self:MyExit()
end
function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.anim_t then
		self.anim_t:Stop()
		self.anim_t = nil
	end
	local old_audio = ExtendSoundManager.GetOldAudioName()
	if old_audio and old_audio == audio_config.game.bgm_7bei.audio_name then
		print("<color=white>上一个背景音是当前背景音</color>")
		ExtendSoundManager.PlayLastBGM()
	else
		ExtendSoundManager.PlayOldBGM()
	end
	self:RemoveListener()
	destroy(self.gameObject)

	 
end

function C:ctor(reward)

	ExtPanel.ExtMsg(self)

	self.reward = reward
	local parent = GameObject.Find("Canvas/LayerLv50").transform
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
	self.cur_hb_cell_num = 0
	self.st = 0.08
	self.cur_run_t = 0
	self.cur_state = 1
	self:MyRefresh()
end

function C:MyRefresh()
	if self.anim_t then
		self.anim_t:Stop()
		self.anim_t = nil
	end
	self.hint1_node.gameObject:SetActive(true)
	self.hint2_node.gameObject:SetActive(false)
	self.Kai.gameObject:SetActive(false)
	ExtendSoundManager.PlaySceneBGM(audio_config.game.bgm_7bei.audio_name)
	self:RunAnim()
end

function C:RunAnim()
	self.anim_t = Timer.New(function ()
		self.cur_run_t = self.cur_run_t + self.st
		if self.cur_state == 1 and self.cur_run_t > 0.6 then
			self.cur_run_t = 0
			self.cur_state = 2
			self.hint2_node.gameObject:SetActive(true)
		elseif self.cur_state == 2 then
			if self.cur_run_t > 0.8 then
				self.hint1_node.gameObject:SetActive(false)
			end
			if self.cur_run_t < 5 then

			else
				self.cur_run_t = 0
				self.cur_state = 3
				self.Kai.gameObject:SetActive(true)
			end
		elseif self.cur_state == 3 and self.cur_run_t > 2 then
			self.cur_state = 4
			self.anim_t:Stop()
			self.anim_t = nil
			self:ShowHB()
		end
	end, self.st, -1, nil, true)
	self.anim_t:Start()
end

function C:ShowHB()
	Event.Brocast("AssetGet",{data = {{asset_type="jing_bi", value=self.reward}}, tips="恭喜发财"})
	self:MyExit()
end

