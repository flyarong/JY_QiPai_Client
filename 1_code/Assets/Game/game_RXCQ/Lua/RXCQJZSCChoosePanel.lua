-- 创建时间:2021-03-29
-- Panel:RXCQJZSCChoosePanel
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

RXCQJZSCChoosePanel = basefunc.class()
local C = RXCQJZSCChoosePanel
C.name = "RXCQJZSCChoosePanel"

function C.Create(parm)
	return C.New(parm)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
	self.lister["EnterForeGround"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.main_timer then
		self.main_timer:Stop()
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

function C:ctor(parm)
	ExtPanel.ExtMsg(self)
	local parent = GameObject.Find("Canvas/GUIRoot").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.parm = parm
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:CutDown()
end

function C:InitUI()
	self.choose1_img.sprite = GetTexture(self.parm.img1)
	self.choose2_img.sprite = GetTexture(self.parm.img2)

	self.choose1_btn.onClick:AddListener(
		function()
			if self.parm.call1 then
				self.parm.call1()
			end
			self:MyExit()
		end
	)
	self.choose2_btn.onClick:AddListener(
		function()
			if self.parm.call2 then
				self.parm.call2()
			end
			self:MyExit()
		end
	)
end

function C:CutDown()
	local t = 5
	self.cut_txt.text = t.."s"
	self.main_timer = Timer.New(
		function()
			t = t - 1
			self.cut_txt.text = t.."s"
			if t < 0 then
				if self.parm.call1 then
					self.parm.call1()
				end
				self:MyExit()
			end
		end
	,1,6,nil,true)
	self.main_timer:Start()
	RXCQModel.AddTimers(self.main_timer)
end