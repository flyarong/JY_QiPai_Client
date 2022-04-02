local basefunc = require "Game.Common.basefunc"

ProductRatingPanel = basefunc.class()
ProductRatingPanel.name = "ProductRatingPanel"

local instance = nil

local lister = {}
function ProductRatingPanel:MakeLister()
	lister = {}

	lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
	lister["OnLoginResponse"] = basefunc.handler(self, self.OnExitScene)
	lister["will_kick_reason"] = basefunc.handler(self, self.OnExitScene)
	lister["DisconnectServerConnect"] = basefunc.handler(self, self.OnExitScene)
end

function ProductRatingPanel:AddMsgListener()
	for proto_name, func in pairs(lister) do
		Event.AddListener(proto_name, func)
	end
end

function ProductRatingPanel:RemoveListener()
	for proto_name,func in pairs(lister) do
		Event.RemoveListener(proto_name, func)
	end
	lister = {}
end


function ProductRatingPanel.Create(parent)
	if not instance then
		instance = ProductRatingPanel.New(parent)
	end
	return instance
end

function ProductRatingPanel:ctor(parent)

	ExtPanel.ExtMsg(self)

	if not parent then
		parent = GameObject.Find("Canvas/LayerLv5").transform
	end
	local obj = newObject(ProductRatingPanel.name, parent)
	self.gameObject = obj;
	self.transform = obj.transform
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self:InitRect()
end

function ProductRatingPanel:MyExit()
	self:RemoveListener()
	self:ClearAll()
	destroy(self.gameObject)
end
function ProductRatingPanel.Close()
	if instance then
		instance:MyExit()
		nstance = nil
	end
end

function ProductRatingPanel:InitRect()
	local transform = self.transform
	self.go_btn.onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_cancel.audio_name)
		sdkMgr:ShowProductRate(true)
		Network.SendRequest("plyj_finish")
		ProductRatingPanel.Close()
	end)
end

function ProductRatingPanel:Refresh()
	local transform = self.transform
	if not IsEquals(transform) then return end

end

function ProductRatingPanel:ClearAll()
	if IsEquals(self.transform) then
		self.transform:SetParent(nil)
	end
end

function ProductRatingPanel:OnExitScene()
	ProductRatingPanel.Close()
end
