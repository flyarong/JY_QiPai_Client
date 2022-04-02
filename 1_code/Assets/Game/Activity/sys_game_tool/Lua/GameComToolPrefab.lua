-- 创建时间:2019-05-16
-- Panel:GameComToolPrefab
local basefunc = require "Game/Common/basefunc"

GameComToolPrefab = basefunc.class()
local C = GameComToolPrefab
C.name = "GameComToolPrefab"

local instance
function C.Create()
	if not instance then
		instance = C.New()
	else
		instance:MyRefresh()
	end
	return instance
end
function C.Close()
	if instance then
		instance:MyExit()
	end
	instance = nil
end

function C:OnExitScene()
	C.Close()
end
function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["ExitScene"] = basefunc.handler(self, self.OnExitScene)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	GameObject.Destroy(self.transform.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv50")
	if not parent or not IsEquals(parent) then
		parent = GameObject.Find("Canvas/LayerLv5")
	end
	local obj = newObject(C.name, parent.transform)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)

	self:MakeLister()
	self:AddMsgListener()

	self.send_pay_btn.onClick:AddListener(function()
        ExtendSoundManager.PlaySound(audio_config.game.com_but_confirm.audio_name)
        dump(self.pay_txt.text)
        if self.pay_txt.text ~= "" then
    	    Network.SendRequest("complete_pay_order_test", {order_id = self.pay_txt.text}, "请求数据", function (data)
    	    	if data.result ~= 0 then
    		    	HintPanel.ErrorMsg(data.result)
	    	    end
    	    end)
        end
    end)
	self:InitUI()
end

function C:InitUI()

end
