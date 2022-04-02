-- 创建时间:2019-01-10

local basefunc = require "Game.Common.basefunc"

CachePrefab = basefunc.class()
local C = CachePrefab

function C.Create(prefabname, parent)
	return C.New(prefabname, parent)
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

function C:ctor(prefabname, parent)
    ExtPanel.ExtMsg(self)
    local obj = GetPrefab(prefabname)
    if obj then
        self.prefabObj = GameObject.Instantiate(obj, parent)
        self.gameObject = self.prefabObj
    end
end

function C:MyExit()
    destroy(self.gameObject)
end

function C:GetObj()
	return self.prefabObj
end

function C:SetObjName(name)
    if IsEquals(self.prefabObj) then
        self.prefabObj.name = name
    end
end
function C:SetParent(parent)
	if IsEquals(parent) and IsEquals(self.prefabObj) then
		self.prefabObj.transform:SetParent(parent)
	end
end
