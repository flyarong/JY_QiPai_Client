
local basefunc = require "Game/Common/basefunc"

BtnTGLBEnterPrefab = basefunc.class()
local C = BtnTGLBEnterPrefab
C.name = "BtnTGLBEnterPrefab"
function C.Create(parent)
	return C.New(parent)
end

function C:AddMsgListener()
	for proto_name, func in pairs(self.lister) do
		Event.AddListener(proto_name, func)
	end
end

function C:MakeLister()
	self.lister = {}
	self.lister["global_hint_state_change_msg"] = basefunc.handler(self, self.on_global_hint_state_change_msg)
end

function C:RemoveListener()
	for proto_name, func in pairs(self.lister) do
		Event.RemoveListener(proto_name, func)
	end
	self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end


function C:ctor(parent)
	local obj = newObject("qflb_gift_btn", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self) 
	self.transform.localPosition = Vector3.zero
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.transform:GetComponent("Button").onClick:AddListener(function()
		ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
		self:OnEnterClick()
	end)
	self:MyRefresh()
end

function C:OnEnterClick()
	GameMoneyCenterPanel.Create("tglb")
	self:MyRefresh()
end

function C:MyRefresh()
	
end

function C:on_global_hint_state_change_msg(parm)
	if parm.gotoui == TGLBManager.key then
		self:MyRefresh()
	end
end