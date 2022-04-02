-- 创建时间:2021-02-03
-- Panel:RXCQGamePanel
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

RXCQGamePanel = basefunc.class()
local C = RXCQGamePanel
C.name = "RXCQGamePanel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self.RXCQFightPrefab:MyExit()
	self.RXCQFightUIPrefab:MyExit()
	self.RXCQLotteryPrefab:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyClose()
	self:MyExit()
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	RXCQPrefabManager.Init(self.PrefabNode)
	local init_func = function()
		self.RXCQFightPrefab = RXCQFightPrefab.Create(self.Fight)
		self.RXCQFightUIPrefab = RXCQFightUIPrefab.Create(self.Fight_UI)
		self.RXCQLotteryPrefab = RXCQLotteryPrefab.Create(self.Lottery)
		self.bg = ExtendSoundManager.PlaySceneBGM(audio_config.rxcq.rxcq_background.audio_name)
		self.bg_AudioSource = GameObject.Find("GameManager").transform:GetComponent("AudioSource")
		RXCQModel.DelayCall(
			function()
				self.bg_AudioSource.volume  = 1
			end
		,0.3)
	end
	RXCQLoadPanel.Create(init_func)
	RXCQModel.SetRegisterObj("RXCQGamePanel_JZSC",self.JZSC)
	RXCQModel.SetRegisterObj("RXCQGamePanel_Fight",self.Fight)
	RXCQModel.SetRegisterObj("RXCQGamePanel_Fight_UI",self.Fight_UI)
	RXCQModel.SetRegisterObj("RXCQGamePanel_Lottery",self.Lottery)
	RXCQModel.SetRegisterObj("RXCQGamePanel_ShanGuang",self.ShanGuang)
	RXCQModel.SetRegisterObj("RXCQGamePanel_temp_player_node",self.temp_player_node)
	Network.SendRequest("rxcq_query_game_history")
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	
end
