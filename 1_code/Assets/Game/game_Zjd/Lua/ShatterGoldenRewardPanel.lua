local basefunc = require "Game.Common.basefunc"

ShatterGoldenRewardPanel = basefunc.class()
ShatterGoldenRewardPanel.name = "ShatterGoldenRewardPanel"

local instance = nil
local updateTimer = nil

local lister = {}
function ShatterGoldenRewardPanel:MakeLister()
	lister = {}

	lister["view_sge_reward_close"] = basefunc.handler(self, self.handle_sge_close)
	lister["view_sge_close"] = basefunc.handler(self, self.handle_sge_close)
	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function ShatterGoldenRewardPanel.Create(params)
	if not instance then
		instance = ShatterGoldenRewardPanel.New(params)
	end
	return instance
end

function ShatterGoldenRewardPanel:ctor(params)
	local parent = AdaptLayerParent("Canvas/LayerLv5", params)
	if not parent then return end

	local obj = newObject(ShatterGoldenRewardPanel.name, parent)
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	ShatterGoldenEggLogic.setViewMsgRegister(lister, ShatterGoldenRewardPanel.name)

	self:InitRect(params)

	DOTweenManager.OpenPopupUIAnim(self.transform)
end

function ShatterGoldenRewardPanel.Close()
	if instance then
		ShatterGoldenEggLogic.clearViewMsgRegister(ShatterGoldenRewardPanel.name)
		instance:ClearAll()
		destroy(instance.transform.gameObject)
		instance = nil
	end
end

function ShatterGoldenRewardPanel:InitRect(params)
	dump(params,"<color=red>48947684684684684684684684684654654</color>")
	local transform = self.transform

	self.callback = params.callback

	self.showState = 0
	--EventTriggerListener.Get(self.BG_btn.gameObject).onClick = basefunc.handler(self, function()
	self.BG_btn.onClick:AddListener(function()
		if self.showState == 0 then
			self.showState = 1
		else
			ShatterGoldenRewardPanel.Close()
		end
	end)

	local split = 80
	local step = math.floor(params.money / split)
	local count = 0
	updateTimer = Timer.New(function()
		if self.showState > 0 then
			self.gold_txt.text = params.money
			return
		end

		count = count + step
		if count > params.money then
			count = params.money
			self.showState = 1
		end
		self.gold_txt.text = count
	end, 0.05, split + 2, false, false)
	updateTimer:Start()

	self:Refresh()
end

function ShatterGoldenRewardPanel:Refresh()
end

function ShatterGoldenRewardPanel:Update()
end

function ShatterGoldenRewardPanel:ClearAll()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end

	if updateTimer then
		updateTimer:Stop()
		updateTimer = nil
	end

	if self.callback then
		self.callback()
		self.callback = nil
	end
	self.showState = 0
end

function ShatterGoldenRewardPanel:handle_click()
	ShatterGoldenRewardPanel.Close()
end

function ShatterGoldenRewardPanel:handle_sge_close()
	ShatterGoldenRewardPanel.Close()
end

function ShatterGoldenRewardPanel:OnExitScene()
	ShatterGoldenRewardPanel.Close()
end
