
local basefunc = require "Game/Common/basefunc"

ActivityShop20_1Panel = basefunc.class()
local C = ActivityShop20_1Panel
C.name = "ActivityShop20_1Panel"

local instance
function C.Create(parent, backcall)
	if not instance then
		instance = C.New(parent, backcall)
	else
		instance:MyRefresh()
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
	self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	self.lister["ReConnecteServerSucceed"] = basefunc.handler(self, self.ReConnecteServerSucceed)
	self.lister["ReceivePayOrderMsg"] = basefunc.handler(self, self.OnReceivePayOrderMsg)
end

function C:RemoveListener()
	for proto_name,func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	instance=nil

	 
end

function C:ctor(parent, backcall)

	ExtPanel.ExtMsg(self)

	self.backcall = backcall
	local parent = parent or GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

	self:MakeLister()
	self:AddMsgListener()

	self.BackButton = tran:Find("BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		self:OnBackClick()
	end)

	self.BuyQYS = tran:Find("Rect/BuyQYS"):GetComponent("Button")
	self.BuyQYS.onClick:AddListener(function ()
		if GameGlobalOnOff.PGPay and gameRuntimePlatform == "Ios" then
			GameManager.GotoUI({gotoui = "sys_service_gzh",goto_scene_parm = "panel",desc="请关注“%s”公众号领取千元赛周卡"})
		else
			local gift_config = MainModel.GetShopingConfig(GOODS_TYPE.gift_bag, 42)
			PayTypePopPrefab.Create(gift_config.id, "￥" .. (gift_config.price / 100),
				function (result)
					if result == 0 then
					end
				end)
		end
	end)

	self:InitUI()
end

function C:InitUI()
end

function C:MyRefresh()
end

function C:OnBackClick()
	GameObject.Destroy(self.gameObject)
	self:MyExit()
	if self.backcall then
		self.backcall()
	end
end

function C:ReConnecteServerSucceed()
	self:MyRefresh()
end

function C:OnExitScene()
	self:MyExit()
end

function C:OnReceivePayOrderMsg(msg)
	self:OnBackClick()

	if msg.result == 0 then
		UIPaySuccess.Create()
	else
		HintPanel.ErrorMsg(msg.result)
	end
end
