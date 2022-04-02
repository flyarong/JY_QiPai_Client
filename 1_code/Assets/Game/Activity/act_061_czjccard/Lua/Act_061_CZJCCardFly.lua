-- 创建时间:2021-06-30
-- Panel:Act_061_CZJCCardFly
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

Act_061_CZJCCardFly = basefunc.class()
local C = Act_061_CZJCCardFly
C.name = "Act_061_CZJCCardFly"
local M = Act_061_CZJCCardManager
local instance
function C.Create(parent)
	if not instance then
		instance = C.New(parent)
	else
		instance:RefreshMyView()
	end
	return instance
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
	self.lister["czjccard_used_success"] = basefunc.handler(self, self.on_czjccard_used_success)
	self.lister["model_czjccard_data_change"] = basefunc.handler(self, self.on_model_czjccard_data_change)
	self.lister["PayPanelClosed"] = basefunc.handler(self, self.OnPayPanelClosed)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	if self.mTimer then
		self.mTimer:Stop()
		self.mTimer = nil
	end
	if self.seq then
		self.seq:Kill()
	end
	dump("<color=red> 【充值加成卡:销毁充值面板飞行】 </color>")
	instance = nil
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
	self.canvas = self.transform:GetComponent("Canvas")
	self.use_btn.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:UseCard()
	end)
	self:InitView()
	self:MyRefresh()
	self:MakeTimer()
end

function C:InitView()
	self.cfg = M.GetCurCardCfg()
	self.fly_img.sprite = GetTexture(self.cfg.fly_img)
end

function C:on_czjccard_used_success()
	self:MyExit()
end

-- 使用充值加成卡
function C:UseCard()
	M.UseCard()
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

function C:MoveAnim()
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

function C:on_model_czjccard_data_change()
	self:RefreshMyView()
end

function C:MakeTimer()
	if self.mTimer then
		self.mTimer:Stop()
		self.mTimer = nil
	end
	local tempTime = self.cfg.valid_time - os.time()
	self.mTimer = Timer.New(function()
		tempTime = tempTime - 1 
		if tempTime <= 0 then
			if self.gameObject then
				self:RefreshMyView()
			end
		end
	end,1,-1)
	self.mTimer:Start()
end

function C:RefreshMyView()
	if M.IsHaveCard() then
		self:InitView()
		self:MakeTimer()
	else
		self:MyExit()
	end
end

function C:OnPayPanelClosed()
	self:MyExit()
end