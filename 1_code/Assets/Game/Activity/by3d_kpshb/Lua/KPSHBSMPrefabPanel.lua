

local basefunc = require "Game/Common/basefunc"

KPSHBSMPrefabPanel = basefunc.class()
local C = KPSHBSMPrefabPanel
C.name = "KPSHBSMPrefabPanel"

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

function C:MyExit()
	self:RemoveListener()
	destroy(self.gameObject)
end

function C:OnDestroy()
	self:MyExit()
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv5").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()

	self.BackButton = tran:Find("root/BackButton"):GetComponent("Button")
	self.BackButton.onClick:AddListener(function ()
        self:OnBackClick()
    end)
end

function C:InitUI()
	self:ShowAwardById()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:OnBackClick()
    self:MyExit()
end

function C:ShowAwardById()
	local get_str_func =function (table)
		return StringHelper.ToCash(table[1]/100) .. "、" .. StringHelper.ToCash(table[2]/100) .. "、" .. StringHelper.ToCash(table[3]/100)
	end
	for i = 1,3 do	
		local t = BY3DKPSHBManager.GetHBRateConfigByIDIndex(FishingModel.game_id,i)
		self["Text"..i.."_txt"].text = "<color=#864515>可获得<color=#ED8813>"..get_str_func(t).."</color>\n三种奖励，概率各为<color=#ED8813>33.3%</color></color>"
	end
end