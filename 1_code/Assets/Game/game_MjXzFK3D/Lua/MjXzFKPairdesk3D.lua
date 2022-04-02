-- 创建时间:2018-06-13

local basefunc = require "Game.Common.basefunc"

MjXzFKPairdesk = basefunc.class()

MjXzFKPairdesk.name = "MjXzFKPairdesk"

-- 自己的对象节点，玩家的UI位置
function MjXzFKPairdesk.Create(transform)
	return MjXzFKPairdesk.New(transform)
end
function MjXzFKPairdesk:ctor(transform)
	self.transform = transform
	self.gameObject = transform.gameObject
	local tran = transform

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.OffBack = tran:Find("OffBack")
	self.OffText = tran:Find("OffBack/OffText"):GetComponent("Text")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
    	Network.SendRequest("nor_mj_xzdd_cancel_signup")
    	self:Hide()
	end)
	self:InitUI()
end
function MjXzFKPairdesk:InitUI()
	self.gameObject:SetActive(false)
end

function MjXzFKPairdesk:UpdateCall()
	self.countdown = self.countdown - 1
    if self.countdown > 0 then
        self:SetOffText()
    else
    	self:CloseTime()
        self:RefreshBackBtn()
    end
end
function MjXzFKPairdesk:SetOffText()
	self.OffText.text = "(" .. self.countdown .. ")" .. "秒后可返回"
end
function MjXzFKPairdesk:RefreshBackBtn()
	if self.countdown > 0 then
	if self.timerUpdate then return end

        self.timerUpdate = Timer.New(basefunc.handler(self, self.UpdateCall), 1, -1, true)
		self.timerUpdate:Start()
		self:SetOffText()

		self.OffBack.gameObject:SetActive(true)
        self.BackButton.gameObject:SetActive(false)
    else
        self.OffBack.gameObject:SetActive(false)
        self.BackButton.gameObject:SetActive(true)
    end
end
function MjXzFKPairdesk:CloseTime()
	if self.timerUpdate then
		self.timerUpdate:Stop()
		self.timerUpdate = nil
	end
end

function MjXzFKPairdesk:Show(tm)
	self.countdown = math.floor(tm)
	self.gameObject:SetActive(true)
	self:RefreshBackBtn()
end
function MjXzFKPairdesk:Hide()
	self:CloseTime()
	if self.gameObject then
		self.gameObject:SetActive(false)
	end
end