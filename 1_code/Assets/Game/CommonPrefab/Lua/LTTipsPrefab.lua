local basefunc = require "Game/Common/basefunc"

LTTipsPrefab = basefunc.class()
local C = LTTipsPrefab
C.name = "LTTipsPrefab"
local Instance
function C.Create()
	if Instance then 
		return  Instance
	else
		Instance = C.New()
		return Instance
	end 
end

function C:AddMsgListener()
    for proto_name,func in pairs(self.lister) do
        Event.AddListener(proto_name, func)
    end
end

function C:MakeLister()
	self.lister = {}
	self.lister["ExitScene"] = basefunc.handler(self,self.MyExit)
end

function C:RemoveListener()
    for proto_name,func in pairs(self.lister) do
        Event.RemoveListener(proto_name, func)
    end
    self.lister = {}
end

function C:MyExit()
	self:RemoveListener()
	Instance = nil
	destroy(self.gameObject)
end

function C:ctor()
	local parent = GameObject.Find("Canvas/LayerLv50").transform
	local obj = newObject(C.name, parent)
	local tran = obj.transform
	self.transform = tran
	self.gameObject = obj
	LuaHelper.GeneratingVar(self.transform, self)
	
	self:MakeLister()
	self:AddMsgListener()
	self:InitUI()
end

function C:InitUI()
	self.hidedesc_btn.onClick:AddListener(
		function ()
			self.hidedesc_btn.gameObject:SetActive(false)
			for i=1,4 do	
				destroyChildren(self["discnode"..i])
				self["showdisc"..i].gameObject:SetActive(false)
			end
			self.tip_item.gameObject:SetActive(false)
			if Instance.backcall then 
				Instance.backcall()
			end
			Instance.backcall = nil
			C.Hide()
		end
	)
	self:MyRefresh()
end

function C:MyRefresh()
end


--type 为1，2，3，4，象限
function C.Show(PosNode,_type,desc,backcall)
	if Instance then
		Instance.backcall = backcall 
		Instance:SetDesc(Instance["discnode".._type],desc)
		Instance["showdisc".._type].gameObject.transform.parent = PosNode
		Instance["showdisc".._type].gameObject.transform.localPosition = Vector3.zero
		Instance["showdisc".._type].gameObject.transform.parent = Instance.transform
		Instance["showdisc".._type].gameObject:SetActive(true)
		Instance.hidedesc_btn.gameObject:SetActive(true)
	else
		C.Create()
		C.Show(PosNode,_type,desc,backcall)
	end
end


function C.Show2(PosNode,title,desc)
	if Instance then
		Instance.tips_tit_txt.text = title
		Instance.tips_desc_txt.text = desc
		Instance.tip_item.gameObject:SetActive(true)
		Instance.tip_item.gameObject.transform.parent = PosNode
		Instance.tip_item.gameObject.transform.localPosition = Vector3.zero
		Instance.tip_item.gameObject.transform.parent = Instance.transform
		Instance.hidedesc_btn.gameObject:SetActive(true)
	else
		C.Create()
		C.Show2(PosNode,title,desc)
	end
end

function C.Hide()
	if Instance then
		Instance:MyExit()
	end
end

function C:SetDesc(parent,desc)
	local settext = function (text,parent)
		local b = GameObject.Instantiate(self.desc_item,self.transform)
		b.gameObject:SetActive(true)
		b.transform.parent = parent
		local t = b.gameObject.transform:GetComponent("Text")
		t.text = text
		b.gameObject:SetActive(true)
	end
	if type(desc) == "table" then
		for i=1,#desc do
			settext(desc[i],parent)
		end
	else
		settext(desc,parent)
	end 
end
