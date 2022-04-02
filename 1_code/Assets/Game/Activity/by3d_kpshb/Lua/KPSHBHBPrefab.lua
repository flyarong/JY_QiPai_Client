
local basefunc = require "Game/Common/basefunc"

KPSHBHBPrefab = basefunc.class()
local C = KPSHBHBPrefab
C.name = "KPSHBHBPrefab"

function C.Create(hb,index)
	return C.New(hb,index)
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
    self.lister = {}
    self.lister["kpshb_model_task_change_msg"] = basefunc.handler(self,self.MyRefresh)
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

function C:MyClose()
	self:MyExit()
end

function C:ctor(hb,index)
	local parent = hb
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	self.index = index
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.gameObject:GetComponent("Button").onClick:AddListener(
		function ()
			print("123")
		Network.SendRequest("get_task_award_new", {award_progress_lv = self.index, id = BY3DKPSHBManager.GetCurrTaskID()})
	end)
	self:MyRefresh()
end

function C:MyRefresh()
	local b = GameTaskModel.GetTaskDataByID( M.GetCurrTaskID() )
	if b[self.index] == 0 then
	    self.gameObject:GetComponent("Animator").enabled = false
	    self.gameObject:GetComponent("Button").enabled = false
	    self.glow1.gameObject:SetActive(false)
	    self.hongbao1_img.transform.localScale = Vector3.New(0.8,0.8,1)
	elseif b[self.index] == 1 then
		self.gameObject:GetComponent("Button").enabled = true
		self.gameObject:GetComponent("Animator").enabled = true
		self.hongbao1_img.transform.localScale = Vector3.New(1,1,1)
		self.canopennode1.gameObject:SetActive(true)
		self.glow1.gameObject:SetActive(true)
	elseif b[self.index] == 2 then
		self.gameObject:GetComponent("Animator").enabled = false
		self.gameObject:GetComponent("Button").enabled=false
		self.hongbao1_img.transform.localScale = Vector3.New(0.8,0.8,1)
		self.canopennode1.gameObject:SetActive(false)
		self.mask1_img.gameObject:SetActive(true)	
		self.glow1.gameObject:SetActive(false)
		self.hongbao1_img.gameObject:GetComponent("Image").sprite = GetTexture("kpshb_icon_hbk")
	end
end

