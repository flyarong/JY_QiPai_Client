

local basefunc = require "Game/Common/basefunc"

by3d_kpshbPrefabPanel = basefunc.class()
local C = by3d_kpshbPrefabPanel
C.name = "by3d_kpshbPrefabPanel"

function C.Create(parm)
	return C.New(parm)
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

function C:ctor(parm)
	self.parm = parm
	local parent = parm.parent
	local obj = newObject("by3d_kpshbPrefab", parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)


	local ys = parm.goto_scene_parm
	if ys == "2" then
		self.transform.localPosition = Vector3.New(150, 150, 0)
	elseif ys == "3" then
		self.transform.localPosition = Vector3.New(190, 160, 0)	
	elseif ys == "4" then
		self.transform.localPosition = Vector3.New(250, 100, 0)	
	elseif ys == "5" then
		self.transform.localPosition = Vector3.New(300, 160, 0)		
	end	

	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self:MyRefresh()
end

function C:MyRefresh()
	local id = tonumber(self.parm.goto_scene_parm)
	local cfg = BY3DKPSHBManager.GetConfigByGameID(id)
	if cfg then
	 	self.show_txt.text = StringHelper.ToCash(cfg.show_hb)
	else
	 	self.show_txt.text = "0"
	end

	if BY3DKPSHBManager.IsRedGetReachMax(id) then
		self.gameObject:SetActive(false)
	else
		self.gameObject:SetActive(true)
	end
end
