-- 创建时间:2019-07-03
-- Panel:FishingMatchOverPanel
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

FishingMatchOverPanel = basefunc.class()
local C = FishingMatchOverPanel
C.name = "FishingMatchOverPanel"

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
    self.lister["fsmg_quit_game_response"] = basefunc.handler(self, self.on_fsmg_quit_game)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end
function C:MyClose()
	self:MyExit()
	destroy(self.gameObject)
end
function C:MyExit()
	self:RemoveListener()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()

	self.Back_btn.onClick:AddListener(function ()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnBackClick()
    end)

	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
end

function C:OnBackClick()
	Network.SendRequest("fsmg_quit_game", nil, "请求退出")
end

function C:on_fsmg_quit_game(_, data)
	if data.result == 0 then
		MainLogic.ExitGame()
		MainLogic.GotoScene("game_Hall")
	else
		HintPanel.ErrorMsg(data.result)
	end
end
