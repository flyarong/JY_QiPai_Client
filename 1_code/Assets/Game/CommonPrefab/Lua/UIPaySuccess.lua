-- 创建时间:2018-11-01

local basefunc = require "Game.Common.basefunc"

UIPaySuccess = basefunc.class()

local instance
function UIPaySuccess.Create(completeCall)
	if instance then
		instance:MyExit()
	end
	instance = UIPaySuccess.New(completeCall)
    return instance
end

function UIPaySuccess:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function UIPaySuccess:MakeLister()
    self.lister = {}
end

function UIPaySuccess:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
end

function UIPaySuccess:ctor(completeCall)
    local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject("UIPaySuccess", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj

    self:MakeLister()
    self:AddMsgListener()
    self.completeCall = completeCall

    LuaHelper.GeneratingVar(self.transform, self)

    self:InitUI()
end
function UIPaySuccess:InitUI()
    self.complete_btn.onClick:AddListener(
    function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        self:OnCompleteClick()
    end)
end

function UIPaySuccess:OnCompleteClick()
    if self.completeCall then
        self.completeCall()
    end
    self:MyExit()
end
function UIPaySuccess:MyExit()
    self:RemoveListener()
    GameObject.Destroy(self.gameObject)
end
