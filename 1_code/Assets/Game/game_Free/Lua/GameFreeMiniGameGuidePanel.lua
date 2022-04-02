-- 创建时间:2020-06-18
-- Panel:GameFreeMiniGameGuidePanel
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

GameFreeMiniGameGuidePanel = basefunc.class()
local C = GameFreeMiniGameGuidePanel
C.name = "GameFreeMiniGameGuidePanel"

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
    self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:OnDestroy()
	self:MyExit()
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv4").transform
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
	self.exit_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		MainLogic.GotoScene("game_Hall")
	end)
	self.back_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:MyExit()
	end)
	self.jjby_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:GotoScene("game_FishingHall")
	end)
	self.sgxxl_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:GotoScene("game_Eliminate")
	end)
	self.zpg_btn.onClick:AddListener(function ()	
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:GotoScene("game_ZPG")
	end)

	self:MyRefresh()
end

function C:MyRefresh()
end

function C:GotoScene(goto_ui)
	GameManager.CommonGotoScence({gotoui = goto_ui,goto_scene_parm =self.config.gotoUI[2]})
end