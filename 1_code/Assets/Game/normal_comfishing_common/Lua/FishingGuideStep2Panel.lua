-- 创建时间:2018-12-13

FishingGuideStep2Panel = {}


local basefunc = require "Game.Common.basefunc"

FishingGuideStep2Panel = basefunc.class()

local C = FishingGuideStep2Panel

C.name = "FishingGuideStep2Panel"

function C.Create()
	return C.New()
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:ctor()

	ExtPanel.ExtMsg(self)

	local parent = GameObject.Find("Canvas/LayerLv4").transform
	local obj = newObject(C.name, parent)
	self.gameObject = obj
	self.transform = obj.transform
	self:MakeLister()
    self:AddMsgListener()

    LuaHelper.GeneratingVar(obj.transform, self)
    self.BG_btn.onClick:AddListener(
        function(  )
            self:OnBackClick()
        end
    )
    self:InitUI()
end

function C:InitUI()
	FishingGuideLogic.CheckRunGuide("guide_step2_panel")
end

function C:MyExit()
	self:RemoveListener()
    destroy(self.gameObject)
end

function C:OnBackClick()
	self:MyExit()
end



