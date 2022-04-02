-- 创建时间:2020-01-07
-- Panel:QHBEnterPrefab
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

Sys_011_CplEnterPrefab = basefunc.class()
local C = Sys_011_CplEnterPrefab
C.name = "Sys_011_CplEnterPrefab"

function C.Create(parent, cfg)
	return C.New(parent, cfg)
end

function C:AddMsgListener()
	for proto_name,func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["EnterForeGround"] = basefunc.handler(self, self.on_backgroundReturn_msg)
	self.lister["EnterBackGround"] = basefunc.handler(self, self.on_background_msg)
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	if self.seq then
		self.seq:Kill()
	end
	self:RemoveListener()
	destroy(self.gameObject)
end
function C:OnDestroy()
	self:MyExit()
end

function C:ctor(parent, cfg)
	local obj = newObject(C.name, parent or GameObject.Find("Canvas/LayerLv5").transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.enter_btn = self.transform:GetComponent("Button")
	self.enter_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	self.width = Screen.width
	self.height = Screen.height
	if self.width / self.height < 1 then
		self.width,self.height = self.height,self.width
	end
	self.width = self.width - 400
	self.height = self.height - 400
	local x = math.random(1, self.width) - self.width/2
	local y = math.random(1, self.height) - self.height/2
	self.transform.localPosition = Vector3.New(x, y, 0)
	self:MoveAnim()
	
end
function C:OnEnterClick()
	local str
	if Sys_011_CplZhManager.WqpCpl2Jy() then
		str = "彩云麻将"
	elseif Sys_011_CplZhManager.JyCpl2Wqp() then
		str = "玩棋牌斗地主"
	end
	local v = Sys_011_CplNoticePanel.Create(str,
	function()
		UnityEngine.Application.OpenURL(Sys_011_CplZhManager.GetUrl())
	end
	)

	v:SetButtonText("不再提示","立马下载")
	if Sys_011_CplZhManager.WqpCpl2Jy() then
		v:SetTitleImage("xbbfl_bg_14")
	elseif Sys_011_CplZhManager.JyCpl2Wqp() then
		v:SetTitleImage("xbbfl_bg_15")
	end
end

function C:MoveAnim()
	if not IsEquals(self.transform) then
		return
	end
	local x = 0
	local y = 0
	local p = self.transform.localPosition
	if p.x > 0 and p.y > 0 then
		local r = math.random(1, 200)
		if r > 100 then
			x = -1 * self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = -1 * self.height/2
		end
	elseif p.x < 0 and p.y > 0 then
		local r = math.random(1, 200)
		if r > 100 then
			x = self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = -1 * self.height/2
		end
	elseif p.x < 0 and p.y < 0 then
		local r = math.random(1, 200)
		if r > 100 then
			x = self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = self.height/2
		end
	else
		local r = math.random(1, 200)
		if r > 100 then
			x = -1 * self.width/2
			y = math.random(1, self.height) - self.height/2
		else
			x = math.random(1, self.width) - self.width/2
			y = self.height/2
		end
	end

	local endPos = Vector3.New(x, y, 0)
	self:MoveBezier(endPos)
end

function C:MoveBezier(endPos)
	local beginPos = self.transform.localPosition
	self.seq = DoTweenSequence.Create()
	local len = math.sqrt( (beginPos.x - endPos.x) * (beginPos.x - endPos.x) + (beginPos.y - endPos.y) * (beginPos.y - endPos.y) )
	local HH = 35
	local t = len / 150
	local h = math.random(100, 200)
	self.seq:Append(self.transform:DOMoveBezier(endPos, h, t):SetEase(DG.Tweening.Ease.Linear))
	self.seq:OnKill(function ()
		self.seq = nil
		self:MoveAnim()
	end)
end

function C:OnExitScene()
	self:MyExit()
end

function C:on_backgroundReturn_msg()
	if self.seq then
		self.seq:Kill()
	end
	self:MoveAnim()
end
function C:on_background_msg()
	if self.seq then
		self.seq:Kill()
	end
end


--[[
	GetTexture("xbbfl_bg_14")
	GetTexture("xbbfl_bg_15")
]]