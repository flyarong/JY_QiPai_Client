-- 创建时间:2020-10-23
-- Panel:EliminateCJFreePanel
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

EliminateCJFreePanel = basefunc.class()
local C = EliminateCJFreePanel
C.name = "EliminateCJFreePanel"
local Status =  EliminateCJEnum.Status
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
	if self.CD_Timer then
		self.CD_Timer:Stop()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:CountDown()
	ExtendSoundManager.PauseSceneBGM()
	ExtendSoundManager.PlaySound(audio_config.cjxxl.bgm_cjxxl_freegameout.audio_name)
	Timer.New(function()
		ExtendSoundManager.PlaySceneBGM(audio_config.cjxxl.bgm_cjxxl_freegamebj.audio_name)
	end,3,1):Start()
end

function C:InitUI()
	self.go_btn.onClick:AddListener(
		function()
			ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
			self:StartFreeGame()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:StartFreeGame()
	EliminateCJModel.Status = Status.in_free
	Event.Brocast("eliminate_cj_into_free_game")
	Event.Brocast("eliminate_cj_anim_finsh_one_roll","eliminate_cj_anim_finsh_one_roll")
	self:MyExit()
end

function C:CountDown()
	if self.CD_Timer then
		self.CD_Timer:Stop()
	end
	self.CD_Timer = nil
	local t = 20
	self.count_txt.text = t.."s"
	self.CD_Timer = Timer.New(
		function()
			t = t - 1
			self.count_txt.text = t.."s"
			if t == -1 then
				self:StartFreeGame()
			end
		end
	,1,-1)
	self.CD_Timer:Start()
end