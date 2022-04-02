local basefunc = require "Game/Common/basefunc"

DMBJPrefab = basefunc.class()
local C = DMBJPrefab
C.name = "DMBJPrefab"

function C.Create(parm,index)
	return C.New(parm,index)
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

function C:ctor(parm,index,pos)
	--最初的创建顺序就是位置信息
	local obj = GameObject.Instantiate(DMBJPrefabManager.Prefabs.ParmItem)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)	
	self.main_img.sprite = DMBJPrefabManager.Prefabs["item_"..parm]
	self.pos = pos or index
	self.index = index
	self.parm = parm
	self.Isliang = false
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
	self:SetPos2Map()
	self.gameObject.name = index
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()

end

function C:ReSetParm(parm)
	self.parm = parm
	self.main_img.sprite = DMBJPrefabManager.Prefabs["item_"..self.parm]
	self:SetPos2Map()
end

function C:SetPos(pos)
	self.pos = pos
	self:SetPos2Map()
	self:SetImage()
end

function C:SetPos2Map()
	DMBJPrefabManager.SetPos2Map(self.pos,self)
end

function C:SetIsLiang(Isliang)
	self.Isliang = Isliang == true
	self:SetImage()
end

function C:SetImage()
	local str = self.Isliang and "item_"..self.parm.."_liang" or "item_"..self.parm
	self.main_img.sprite = DMBJPrefabManager.Prefabs[str]
end